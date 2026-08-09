import Foundation
import KeyboardCore
import XCTest

@testable import Universe_Keyboard

final class DiagnosticsJournalRetentionCoordinatorTests: XCTestCase {
    func testExpiredLeaseIsTombstonedSealedAndRevoked() async throws {
        let rootURL = makeTemporaryDirectory()
        defer { try? FileManager.default.removeItem(at: rootURL) }
        let processID = UUID()
        let writer = DiagnosticsJournalWriter(
            rootURL: rootURL,
            origin: .mainApp,
            processInstanceID: processID,
            isMainAppWriter: true
        )
        try await writer.prepareRootIfOwnedByMainApp()
        try await writer.append([makeEvent(processInstanceID: processID)])

        let leaseURL =
            rootURL
            .appendingPathComponent("g1/leases")
            .appendingPathComponent("main_app-\(processID.uuidString).json")
        let lease = try decodeLease(at: leaseURL)
        let expiredLease = DiagnosticsJournalLease(
            generation: lease.generation,
            origin: lease.origin,
            processInstanceID: lease.processInstanceID,
            fence: lease.fence,
            renewedAt: Date(timeIntervalSince1970: 1_000),
            expiresAt: Date(timeIntervalSince1970: 1_001)
        )
        try encodeLease(expiredLease, to: leaseURL)

        let coordinator = DiagnosticsJournalRetentionCoordinator(rootURL: rootURL)
        let report = await coordinator.runReclaim(now: Date(timeIntervalSince1970: 1_002))

        XCTAssertEqual(report.recoveredOpenSegmentCount, 1)
        XCTAssertFalse(FileManager.default.fileExists(atPath: leaseURL.path))
        XCTAssertTrue(
            FileManager.default.fileExists(
                atPath:
                    rootURL
                    .appendingPathComponent("g1/reclaimed")
                    .appendingPathComponent("main_app-\(processID.uuidString).json")
                    .path
            )
        )
        XCTAssertEqual(
            try jsonlFileCount(in: rootURL.appendingPathComponent("g1/sealed")),
            1
        )
        do {
            try await writer.append([makeEvent(processInstanceID: processID)])
            XCTFail("A reclaimed writer must not reopen its old generation")
        } catch {
            XCTAssertEqual(error as? DiagnosticsJournalError, .writerReclaimed)
        }
    }

    func testRetentionDeletesOnlySealedSegmentsOlderThanPolicy() async throws {
        let rootURL = makeTemporaryDirectory()
        defer { try? FileManager.default.removeItem(at: rootURL) }
        let processID = UUID()
        let writer = DiagnosticsJournalWriter(
            rootURL: rootURL,
            origin: .mainApp,
            processInstanceID: processID,
            isMainAppWriter: true
        )
        try await writer.prepareRootIfOwnedByMainApp()
        try await writer.append([makeEvent(processInstanceID: processID)])
        _ = try await writer.advanceGenerationForClear()

        let sealedURL = try XCTUnwrap(
            FileManager.default.contentsOfDirectory(
                at: rootURL.appendingPathComponent("g1/sealed"),
                includingPropertiesForKeys: nil
            ).first
        )
        try FileManager.default.setAttributes(
            [.modificationDate: Date(timeIntervalSince1970: 1_000)],
            ofItemAtPath: sealedURL.path
        )

        let coordinator = DiagnosticsJournalRetentionCoordinator(
            rootURL: rootURL,
            policy: .init(maximumAge: 10, maximumTotalBytes: 1_024 * 1_024)
        )
        let report = await coordinator.runReclaim(now: Date(timeIntervalSince1970: 1_011))

        XCTAssertEqual(report.deletedSealedSegmentCount, 1)
        XCTAssertEqual(try jsonlFileCount(in: rootURL.appendingPathComponent("g1/sealed")), 0)
    }

    func testRetentionCapacityDoesNotDeleteActiveOpenSegment() async throws {
        let rootURL = makeTemporaryDirectory()
        defer { try? FileManager.default.removeItem(at: rootURL) }
        let processID = UUID()
        let writer = DiagnosticsJournalWriter(
            rootURL: rootURL,
            origin: .mainApp,
            processInstanceID: processID,
            isMainAppWriter: true
        )
        try await writer.prepareRootIfOwnedByMainApp()
        try await writer.append([makeEvent(processInstanceID: processID)])

        let coordinator = DiagnosticsJournalRetentionCoordinator(
            rootURL: rootURL,
            policy: .init(maximumAge: 7 * 24 * 60 * 60, maximumTotalBytes: 1)
        )
        let report = await coordinator.runReclaim()

        XCTAssertEqual(report.deletedSealedSegmentCount, 0)
        XCTAssertEqual(try jsonlFileCount(in: rootURL.appendingPathComponent("g1/open")), 1)
    }

    func testRetentionSkipsExpiredLeaseWhenWriterLockIsBusy() async throws {
        let rootURL = makeTemporaryDirectory()
        defer { try? FileManager.default.removeItem(at: rootURL) }
        let processID = UUID()
        let writer = DiagnosticsJournalWriter(
            rootURL: rootURL,
            origin: .mainApp,
            processInstanceID: processID,
            isMainAppWriter: true
        )
        try await writer.prepareRootIfOwnedByMainApp()
        try await writer.append([makeEvent(processInstanceID: processID)])

        let leaseURL =
            rootURL
            .appendingPathComponent("g1/leases")
            .appendingPathComponent("main_app-\(processID.uuidString).json")
        let lease = try decodeLease(at: leaseURL)
        try encodeLease(
            DiagnosticsJournalLease(
                generation: lease.generation,
                origin: lease.origin,
                processInstanceID: lease.processInstanceID,
                fence: lease.fence,
                renewedAt: Date(timeIntervalSince1970: 1_000),
                expiresAt: Date(timeIntervalSince1970: 1_001)
            ),
            to: leaseURL
        )

        let coordinator = DiagnosticsJournalRetentionCoordinator(rootURL: rootURL)
        let lockAcquired = expectation(description: "writer identity lock acquired")
        let releaseLock = DispatchSemaphore(value: 0)
        let lockHolder = Thread {
            _ = try? DiagnosticsJournalIdentityLock.withExclusiveLock(
                rootURL: rootURL,
                origin: .mainApp,
                processInstanceID: processID
            ) {
                lockAcquired.fulfill()
                releaseLock.wait()
            }
        }
        lockHolder.start()
        await fulfillment(of: [lockAcquired], timeout: 1)
        defer { releaseLock.signal() }

        let report = await coordinator.runReclaim(now: Date(timeIntervalSince1970: 1_002))
        XCTAssertEqual(report.skippedBusyLeaseCount, 1)
        XCTAssertTrue(FileManager.default.fileExists(atPath: leaseURL.path))
        XCTAssertEqual(try jsonlFileCount(in: rootURL.appendingPathComponent("g1/open")), 1)
    }

    private func makeEvent(processInstanceID: UUID) -> DiagnosticEvent {
        DiagnosticEvent(
            utcTimestamp: Date(timeIntervalSince1970: 1_000),
            monotonicNanoseconds: 1,
            origin: .mainApp,
            processInstanceID: processInstanceID,
            localSequence: 1,
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

    private func decodeLease(at url: URL) throws -> DiagnosticsJournalLease {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(DiagnosticsJournalLease.self, from: Data(contentsOf: url))
    }

    private func encodeLease(_ lease: DiagnosticsJournalLease, to url: URL) throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        try encoder.encode(lease).write(to: url, options: .atomic)
    }

    private func jsonlFileCount(in directory: URL) throws -> Int {
        try FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)
            .filter { $0.pathExtension == "jsonl" }
            .count
    }
}
