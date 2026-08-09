import Foundation
import XCTest

@testable import KeyboardCore

final class DiagnosticsJournalIngressTests: XCTestCase {
    func testIngressIsBoundedAndWritesOnUtilityFlush() async throws {
        let rootURL = makeTemporaryDirectory()
        defer { try? FileManager.default.removeItem(at: rootURL) }
        let processID = UUID()
        let ingress = DiagnosticsJournalIngress(
            origin: .mainApp,
            processInstanceID: processID,
            isMainAppWriter: true,
            rootURL: { rootURL },
            isCategoryEnabled: { _ in true },
            flushDelay: 5
        )

        for sequence in 0..<(DiagnosticsJournalIngress.maximumPendingEventCount + 1) {
            ingress.record(makeEvent(sequence: UInt64(sequence), processInstanceID: processID))
        }
        ingress.requestFlush()

        try await waitForJournal(at: rootURL)
        let events = try readEvents(at: rootURL)
        XCTAssertEqual(events.count, DiagnosticsJournalIngress.maximumPendingEventCount)
        let expectedSequences = Array(0..<UInt64(DiagnosticsJournalIngress.maximumPendingEventCount))
        XCTAssertEqual(events.map(\.localSequence), expectedSequences)
    }

    func testDisabledCategoryIsNotWritten() async throws {
        let rootURL = makeTemporaryDirectory()
        defer { try? FileManager.default.removeItem(at: rootURL) }
        try FileManager.default.removeItem(at: rootURL)
        let processID = UUID()
        let ingress = DiagnosticsJournalIngress(
            origin: .mainApp,
            processInstanceID: processID,
            isMainAppWriter: true,
            rootURL: { rootURL },
            isCategoryEnabled: { _ in false },
            flushDelay: 0
        )

        ingress.record(makeEvent(sequence: 1, processInstanceID: processID))
        ingress.requestFlush()
        try await Task.sleep(for: .milliseconds(100))

        XCTAssertFalse(FileManager.default.fileExists(atPath: rootURL.path))
    }

    func testSuspendDiscardsDelayedTailWithoutCreatingJournal() async throws {
        let rootURL = makeTemporaryDirectory()
        defer { try? FileManager.default.removeItem(at: rootURL) }
        try FileManager.default.removeItem(at: rootURL)
        let processID = UUID()
        let ingress = DiagnosticsJournalIngress(
            origin: .mainApp,
            processInstanceID: processID,
            isMainAppWriter: true,
            rootURL: { rootURL },
            isCategoryEnabled: { _ in true },
            flushDelay: 0.1
        )

        ingress.record(makeEvent(sequence: 1, processInstanceID: processID))
        ingress.suspendForExtensionLifecycle()
        try await Task.sleep(for: .milliseconds(250))

        XCTAssertFalse(FileManager.default.fileExists(atPath: rootURL.path))
    }

    func testSuspendedRecordsAreReportedThenNewVisibleEventsWrite() async throws {
        let rootURL = makeTemporaryDirectory()
        defer { try? FileManager.default.removeItem(at: rootURL) }
        let processID = UUID()
        let ingress = DiagnosticsJournalIngress(
            origin: .mainApp,
            processInstanceID: processID,
            isMainAppWriter: true,
            rootURL: { rootURL },
            isCategoryEnabled: { _ in true },
            flushDelay: 5
        )

        ingress.suspendForExtensionLifecycle()
        ingress.record(makeEvent(sequence: 1, processInstanceID: processID))
        ingress.record(makeEvent(sequence: 2, processInstanceID: processID))
        XCTAssertEqual(ingress.resumeForExtensionLifecycle(), 2)
        ingress.record(makeEvent(sequence: 3, processInstanceID: processID))
        ingress.requestFlush()

        try await waitForJournal(at: rootURL)
        XCTAssertEqual(try readEvents(at: rootURL).map(\.localSequence), [3])
    }

    private func makeEvent(sequence: UInt64, processInstanceID: UUID) -> DiagnosticEvent {
        DiagnosticEvent(
            utcTimestamp: Date(),
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

    private func waitForJournal(at rootURL: URL) async throws {
        for _ in 0..<50 {
            if FileManager.default.fileExists(atPath: rootURL.appendingPathComponent("g1/open").path) {
                return
            }
            try await Task.sleep(for: .milliseconds(20))
        }
        XCTFail("Timed out waiting for journal output")
    }

    private func readEvents(at rootURL: URL) throws -> [DiagnosticEvent] {
        let file = try XCTUnwrap(
            FileManager.default.contentsOfDirectory(
                at: rootURL.appendingPathComponent("g1/open"),
                includingPropertiesForKeys: nil
            ).first
        )
        let lines = try XCTUnwrap(String(data: Data(contentsOf: file), encoding: .utf8))
            .split(separator: "\n")
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try lines.map { try decoder.decode(DiagnosticEvent.self, from: Data($0.utf8)) }
    }
}
