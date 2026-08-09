import XCTest

@testable import KeyboardCore

final class DiagnosticsJournalTests: XCTestCase {
    func testMainAppCreatesControlAndWritesOnlyItsOwnSegment() async throws {
        let rootURL = makeTemporaryDirectory()
        defer { try? FileManager.default.removeItem(at: rootURL) }
        let processID = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
        let writer = DiagnosticsJournalWriter(
            rootURL: rootURL,
            origin: .mainApp,
            processInstanceID: processID,
            isMainAppWriter: true
        )

        try await writer.prepareRootIfOwnedByMainApp()
        try await writer.append([makeEvent(sequence: 1, processInstanceID: processID)])

        let control = try decodeControl(at: rootURL.appendingPathComponent("control.json"))
        XCTAssertEqual(control.currentGeneration, 1)
        let lines = try journalLines(in: rootURL.appendingPathComponent("g1/open"))
        XCTAssertEqual(lines.count, 1)
        XCTAssertEqual(lines[0].origin, .mainApp)
        XCTAssertEqual(lines[0].processInstanceID, processID)
    }

    func testClearAdvancesGenerationAndLeavesOldSegmentOutOfNewGeneration() async throws {
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
        try await writer.append([makeEvent(sequence: 1, processInstanceID: processID)])
        let nextGeneration = try await writer.advanceGenerationForClear()
        XCTAssertEqual(nextGeneration, 2)
        try await writer.append([makeEvent(sequence: 2, processInstanceID: processID)])

        XCTAssertEqual(try journalLines(in: rootURL.appendingPathComponent("g1/sealed")).count, 1)
        XCTAssertTrue(
            try FileManager.default.contentsOfDirectory(
                at: rootURL.appendingPathComponent("g1/open"),
                includingPropertiesForKeys: nil
            ).isEmpty
        )
        let currentLines = try journalLines(in: rootURL.appendingPathComponent("g2/open"))
        XCTAssertEqual(currentLines.map(\.localSequence), [2])
    }

    func testWriterSealsPreviousHourBeforeOpeningNewSegment() async throws {
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

        try await writer.append([
            makeEvent(
                sequence: 1,
                processInstanceID: processID,
                timestamp: Date(timeIntervalSince1970: 1_723_123_456)
            )
        ])
        try await writer.append([
            makeEvent(
                sequence: 2,
                processInstanceID: processID,
                timestamp: Date(timeIntervalSince1970: 1_723_127_056)
            )
        ])

        XCTAssertEqual(try journalLines(in: rootURL.appendingPathComponent("g1/sealed")).map(\.localSequence), [1])
        XCTAssertEqual(try journalLines(in: rootURL.appendingPathComponent("g1/open")).map(\.localSequence), [2])
    }

    func testPageCursorReturnsFrozenNewestFirstOffsetsWithoutLoadingWholeJournal() async throws {
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
        try await writer.append(
            (1...5).map { makeEvent(sequence: UInt64($0), processInstanceID: processID) }
        )

        let reader = DiagnosticsJournalReader(rootURL: rootURL)
        let firstPage = try await reader.beginPage(maximumEventCount: 2, maximumReadBytes: 16 * 1_024)
        let secondPage = try await reader.nextPage(
            after: try XCTUnwrap(firstPage.nextCursor),
            maximumEventCount: 2,
            maximumReadBytes: 16 * 1_024
        )
        let thirdPage = try await reader.nextPage(
            after: try XCTUnwrap(secondPage.nextCursor),
            maximumEventCount: 2,
            maximumReadBytes: 16 * 1_024
        )

        XCTAssertEqual(firstPage.events.map(\.localSequence), [5, 4])
        XCTAssertEqual(secondPage.events.map(\.localSequence), [3, 2])
        XCTAssertEqual(thirdPage.events.map(\.localSequence), [1])
        XCTAssertNil(thirdPage.nextCursor)
    }

    func testReclaimedWriterRotatesIdentityAndCanAppendAgain() async throws {
        let rootURL = makeTemporaryDirectory()
        defer { try? FileManager.default.removeItem(at: rootURL) }
        let oldIdentity = UUID()
        let writer = DiagnosticsJournalWriter(
            rootURL: rootURL,
            origin: .mainApp,
            processInstanceID: oldIdentity,
            isMainAppWriter: true
        )
        try await writer.prepareRootIfOwnedByMainApp()
        try await writer.append([makeEvent(sequence: 1, processInstanceID: oldIdentity)])

        let tombstoneURL =
            rootURL
            .appendingPathComponent("g1/reclaimed")
            .appendingPathComponent("main_app-\(oldIdentity.uuidString).json")
        try FileManager.default.createDirectory(
            at: tombstoneURL.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        let tombstone = DiagnosticsJournalTombstone(
            generation: 1,
            origin: .mainApp,
            processInstanceID: oldIdentity,
            fence: 1,
            reclaimedAt: Date(),
            reason: .expiredLease
        )
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        try encoder.encode(tombstone).write(to: tombstoneURL, options: .atomic)

        do {
            try await writer.append([makeEvent(sequence: 2, processInstanceID: oldIdentity)])
            XCTFail("The tombstoned identity must be rejected before rotation")
        } catch {
            XCTAssertEqual(error as? DiagnosticsJournalError, .writerReclaimed)
        }

        await writer.rotateIdentityAfterReclaim()
        try await writer.append([makeEvent(sequence: 2, processInstanceID: oldIdentity)])
        let leaseFiles = try FileManager.default.contentsOfDirectory(
            at: rootURL.appendingPathComponent("g1/leases"),
            includingPropertiesForKeys: nil
        )
        XCTAssertEqual(leaseFiles.count, 2)
    }

    func testExtensionCannotCreateMissingRoot() async throws {
        let rootURL = makeTemporaryDirectory()
        defer { try? FileManager.default.removeItem(at: rootURL) }
        try FileManager.default.removeItem(at: rootURL)
        let writer = DiagnosticsJournalWriter(
            rootURL: rootURL,
            origin: .keyboardExtension,
            isMainAppWriter: false
        )

        do {
            try await writer.prepareRootIfOwnedByMainApp()
            XCTFail("Expected Extension writer root preparation to fail")
        } catch {
            XCTAssertEqual(error as? DiagnosticsJournalError, .rootUnavailable)
        }
    }

    func testExtensionAppendDoesNotCreateMissingRoot() async throws {
        let rootURL = makeTemporaryDirectory()
        defer { try? FileManager.default.removeItem(at: rootURL) }
        try FileManager.default.removeItem(at: rootURL)
        let processID = UUID()
        let writer = DiagnosticsJournalWriter(
            rootURL: rootURL,
            origin: .keyboardExtension,
            processInstanceID: processID,
            isMainAppWriter: false
        )

        do {
            try await writer.append([
                makeEvent(
                    sequence: 1,
                    processInstanceID: processID,
                    origin: .keyboardExtension
                )
            ])
            XCTFail("Expected Extension append to reject a missing root")
        } catch {
            XCTAssertEqual(error as? DiagnosticsJournalError, .rootUnavailable)
        }
        XCTAssertFalse(FileManager.default.fileExists(atPath: rootURL.path))
    }

    func testAppendRenewsIdentityLeaseWithIncreasingFence() async throws {
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

        try await writer.append([makeEvent(sequence: 1, processInstanceID: processID)])
        let firstLease = try decodeLease(at: leaseURL(rootURL: rootURL, processID: processID))
        try await writer.append([makeEvent(sequence: 2, processInstanceID: processID)])
        let secondLease = try decodeLease(at: leaseURL(rootURL: rootURL, processID: processID))

        XCTAssertEqual(secondLease.generation, 1)
        XCTAssertEqual(secondLease.origin, .mainApp)
        XCTAssertEqual(secondLease.processInstanceID, processID)
        XCTAssertEqual(secondLease.fence, firstLease.fence + 1)
        XCTAssertGreaterThan(secondLease.expiresAt, secondLease.renewedAt)
    }

    func testReaderIgnoresPartialTailAndReturnsOnlyCurrentGeneration() async throws {
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
        try await writer.append([makeEvent(sequence: 1, processInstanceID: processID)])

        let oldSegment = try XCTUnwrap(
            FileManager.default.contentsOfDirectory(
                at: rootURL.appendingPathComponent("g1/open"),
                includingPropertiesForKeys: nil
            ).first
        )
        let appendHandle = try FileHandle(forWritingTo: oldSegment)
        try appendHandle.seekToEnd()
        try appendHandle.write(contentsOf: Data("{\"incomplete\":".utf8))
        try appendHandle.close()

        _ = try await writer.advanceGenerationForClear()
        try await writer.append([makeEvent(sequence: 2, processInstanceID: processID)])
        let reader = DiagnosticsJournalReader(rootURL: rootURL)

        let snapshot = try await reader.latest()
        XCTAssertEqual(snapshot.generation, 2)
        XCTAssertEqual(snapshot.events.map(\.localSequence), [2])
    }

    private func makeEvent(
        sequence: UInt64,
        processInstanceID: UUID,
        origin: DiagnosticEvent.Origin = .mainApp,
        timestamp: Date = Date(timeIntervalSince1970: 1_723_123_456)
    ) -> DiagnosticEvent {
        DiagnosticEvent(
            utcTimestamp: timestamp,
            monotonicNanoseconds: sequence,
            origin: origin,
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

    private func decodeControl(at url: URL) throws -> DiagnosticsJournalControl {
        try JSONDecoder().decode(DiagnosticsJournalControl.self, from: Data(contentsOf: url))
    }

    private func decodeLease(at url: URL) throws -> DiagnosticsJournalLease {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(DiagnosticsJournalLease.self, from: Data(contentsOf: url))
    }

    private func leaseURL(rootURL: URL, processID: UUID) -> URL {
        rootURL
            .appendingPathComponent("g1/leases")
            .appendingPathComponent("main_app-\(processID.uuidString).json")
    }

    private func journalLines(in directory: URL) throws -> [DiagnosticEvent] {
        let files = try FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)
        let file = try XCTUnwrap(files.first)
        let data = try Data(contentsOf: file)
        let lines = try XCTUnwrap(String(data: data, encoding: .utf8))
            .split(separator: "\n")
            .map { Data($0.utf8) }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try lines.map { try decoder.decode(DiagnosticEvent.self, from: $0) }
    }
}
