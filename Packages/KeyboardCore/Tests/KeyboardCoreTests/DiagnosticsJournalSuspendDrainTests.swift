import Darwin
import Foundation
import Synchronization
import XCTest

@testable import KeyboardCore

final class DiagnosticsJournalSuspendDrainTests: XCTestCase {
    func testPauseHoldsBothLocksUntilAdmissionAndUnregistersOnce() async throws {
        let rootURL = makeTemporaryDirectory()
        defer { try? FileManager.default.removeItem(at: rootURL) }
        let processID = UUID()
        let writer = DiagnosticsJournalWriter(
            rootURL: rootURL, origin: .mainApp, processInstanceID: processID, isMainAppWriter: true
        )
        try await writer.prepareRootIfOwnedByMainApp()
        let ingress = makeIngress(rootURL: rootURL, processID: processID, writer: writer)
        let reached = expectation(description: "inside both locks")
        let release = DispatchSemaphore(value: 0)
        await writer.installBeforeFinalAdmissionForTesting {
            reached.fulfill()
            _ = release.wait(timeout: .now() + 5)
        }
        ingress.record(makeEvent(sequence: 1, processInstanceID: processID))
        ingress.requestFlush()
        await fulfillment(of: [reached], timeout: 5)
        XCTAssertTrue(exclusiveLockIsBusy(rootURL.appendingPathComponent("locks/snapshot.lock")))
        XCTAssertTrue(
            exclusiveLockIsBusy(
                rootURL.appendingPathComponent("locks/main_app-\(processID.uuidString).lock")
            )
        )
        let outcome = Task { await ingress.closeAndDrainAppends { false } }
        try await Task.sleep(nanoseconds: 50_000_000)
        let countsWhileHeld = ingress.testingAppendAdmissionCounts()
        XCTAssertEqual(countsWhileHeld.inFlight, 1)
        release.signal()
        let drained = await outcome.value
        XCTAssertEqual(drained, .drained)
        let counts = ingress.testingAppendAdmissionCounts()
        XCTAssertEqual(counts.entered, 1)
        XCTAssertEqual(counts.left, 1)
        XCTAssertEqual(counts.inFlight, 0)
        XCTAssertFalse(exclusiveLockIsBusy(rootURL.appendingPathComponent("locks/snapshot.lock")))
    }

    func testThrownAppendUnregistersOnce() async throws {
        let rootURL = makeTemporaryDirectory()
        defer { try? FileManager.default.removeItem(at: rootURL) }
        let processID = UUID()
        let writer = DiagnosticsJournalWriter(
            rootURL: rootURL, origin: .mainApp, processInstanceID: processID, isMainAppWriter: true
        )
        try await writer.prepareRootIfOwnedByMainApp()
        let ingress = makeIngress(rootURL: rootURL, processID: processID, writer: writer)
        await writer.installAfterAdmissionForTesting {
            throw DiagnosticsJournalError.writeFailed
        }
        ingress.record(makeEvent(sequence: 1, processInstanceID: processID))
        ingress.requestFlush()
        let deadline = Date().addingTimeInterval(5)
        while ingress.testingAppendAdmissionCounts().entered < 1, Date() < deadline {
            try await Task.sleep(nanoseconds: 20_000_000)
        }
        let outcome = await ingress.closeAndDrainAppends { false }
        XCTAssertEqual(outcome, .drained)
        let counts = ingress.testingAppendAdmissionCounts()
        XCTAssertEqual(counts.entered, 1)
        XCTAssertEqual(counts.left, 1)
    }

    func testCloseRejectsANewAppend() async throws {
        let rootURL = makeTemporaryDirectory()
        defer { try? FileManager.default.removeItem(at: rootURL) }
        let processID = UUID()
        let writer = DiagnosticsJournalWriter(
            rootURL: rootURL, origin: .mainApp, processInstanceID: processID, isMainAppWriter: true
        )
        try await writer.prepareRootIfOwnedByMainApp()
        let ingress = makeIngress(rootURL: rootURL, processID: processID, writer: writer)
        ingress.closeAppendAdmission()
        ingress.record(makeEvent(sequence: 1, processInstanceID: processID))
        ingress.requestFlush()
        try await Task.sleep(nanoseconds: 100_000_000)
        let counts = ingress.testingAppendAdmissionCounts()
        XCTAssertEqual(counts.entered, 0)
        XCTAssertTrue(counts.closed)
        let outcome = await ingress.drainClosedAppends { false }
        XCTAssertEqual(outcome, .drained)
    }

    func testClearIsOutsideAppendDrain() async throws {
        let rootURL = makeTemporaryDirectory()
        defer { try? FileManager.default.removeItem(at: rootURL) }
        let processID = UUID()
        let writer = DiagnosticsJournalWriter(
            rootURL: rootURL, origin: .mainApp, processInstanceID: processID, isMainAppWriter: true
        )
        try await writer.prepareRootIfOwnedByMainApp()
        let ingress = makeIngress(rootURL: rootURL, processID: processID, writer: writer)
        let locksDirectory = rootURL.appendingPathComponent("locks", isDirectory: true)
        try FileManager.default.createDirectory(at: locksDirectory, withIntermediateDirectories: true)
        let lockURL = locksDirectory.appendingPathComponent("snapshot.lock")
        let descriptor = open(lockURL.path, O_RDWR | O_CREAT | O_CLOEXEC, S_IRUSR | S_IWUSR)
        XCTAssertGreaterThanOrEqual(descriptor, 0)
        defer {
            _ = flock(descriptor, LOCK_UN)
            _ = close(descriptor)
        }
        XCTAssertEqual(flock(descriptor, LOCK_EX), 0)
        let outcome = await ingress.closeAndDrainAppends { false }
        XCTAssertEqual(outcome, .drained)
        do {
            _ = try await writer.advanceGenerationForClear()
            XCTFail("clear takes the shared snapshot fence and must see the held exclusive lock")
        } catch {
            XCTAssertEqual(error as? DiagnosticsJournalError, .lockBusy)
        }
    }

    private func makeIngress(
        rootURL: URL,
        processID: UUID,
        writer: DiagnosticsJournalWriter
    ) -> DiagnosticsJournalIngress {
        let ingress = DiagnosticsJournalIngress(
            origin: .mainApp,
            processInstanceID: processID,
            isMainAppWriter: true,
            rootURL: { rootURL },
            isCategoryEnabled: { _ in true },
            flushDelay: 5
        )
        ingress.installBatchWriterFactoryForTesting { _ in writer }
        return ingress
    }

    private func exclusiveLockIsBusy(_ url: URL) -> Bool {
        let descriptor = open(url.path, O_RDWR | O_CREAT | O_CLOEXEC, S_IRUSR | S_IWUSR)
        guard descriptor >= 0 else { return false }
        defer { _ = close(descriptor) }
        let locked = flock(descriptor, LOCK_EX | LOCK_NB)
        if locked == 0 {
            _ = flock(descriptor, LOCK_UN)
            return false
        }
        return true
    }

    private func makeEvent(sequence: UInt64, processInstanceID: UUID) -> DiagnosticEvent {
        DiagnosticEvent(
            utcTimestamp: Date(timeIntervalSince1970: 1_723_123_456),
            monotonicNanoseconds: sequence,
            origin: .mainApp,
            processInstanceID: processInstanceID,
            localSequence: sequence,
            code: .journalStarted,
            level: .info,
            category: .general
        )
    }

    private func makeTemporaryDirectory() -> URL {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try! FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        return directory
    }
}
