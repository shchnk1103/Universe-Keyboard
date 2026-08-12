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

    func testPageCursorReturnsFrozenNewestFirstPages() async throws {
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

    func testPageCursorExcludesEventsAppendedAfterItsFrozenWatermark() async throws {
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
        try await writer.append((1...3).map { makeEvent(sequence: UInt64($0), processInstanceID: processID) })

        let reader = DiagnosticsJournalReader(rootURL: rootURL)
        let firstPage = try await reader.beginPage(maximumEventCount: 1)
        try await writer.append([makeEvent(sequence: 4, processInstanceID: processID)])

        let secondPage = try await reader.nextPage(
            after: try XCTUnwrap(firstPage.nextCursor),
            maximumEventCount: 1
        )
        let thirdPage = try await reader.nextPage(
            after: try XCTUnwrap(secondPage.nextCursor),
            maximumEventCount: 1
        )

        XCTAssertEqual(firstPage.events.map(\.localSequence), [3])
        XCTAssertEqual(secondPage.events.map(\.localSequence), [2])
        XCTAssertEqual(thirdPage.events.map(\.localSequence), [1])
        XCTAssertEqual(thirdPage.status, .completed)
    }

    func testPageCursorUsesDeterministicTieBreakAcrossSameHourSegments() async throws {
        let rootURL = makeTemporaryDirectory()
        defer { try? FileManager.default.removeItem(at: rootURL) }
        let lowerID = UUID(uuidString: "00000000-0000-0000-0000-000000000010")!
        let higherID = UUID(uuidString: "00000000-0000-0000-0000-000000000020")!
        let lowerWriter = DiagnosticsJournalWriter(
            rootURL: rootURL,
            origin: .mainApp,
            processInstanceID: lowerID,
            isMainAppWriter: true
        )
        let higherWriter = DiagnosticsJournalWriter(
            rootURL: rootURL,
            origin: .keyboardExtension,
            processInstanceID: higherID,
            isMainAppWriter: false
        )
        try await lowerWriter.prepareRootIfOwnedByMainApp()
        let timestamp = Date(timeIntervalSince1970: 1_723_123_456)
        try await lowerWriter.append([makeEvent(sequence: 7, processInstanceID: lowerID, timestamp: timestamp)])
        try await higherWriter.append([
            makeEvent(
                sequence: 7,
                processInstanceID: higherID,
                origin: .keyboardExtension,
                timestamp: timestamp
            )
        ])

        let page = try await DiagnosticsJournalReader(rootURL: rootURL).beginPage()

        XCTAssertEqual(page.events.map(\.processInstanceID), [higherID, lowerID])
    }

    func testPageSnapshotContinuesWhenWriterSealsSameSegmentAfterManifestCapture() async throws {
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

        let reader = DiagnosticsJournalReader(rootURL: rootURL) { [rootURL] in
            let openDirectory = rootURL.appendingPathComponent("g1/open", isDirectory: true)
            let sealedDirectory = rootURL.appendingPathComponent("g1/sealed", isDirectory: true)
            guard
                let segment = try? FileManager.default.contentsOfDirectory(
                    at: openDirectory,
                    includingPropertiesForKeys: nil
                ).first
            else { return }
            try? FileManager.default.createDirectory(at: sealedDirectory, withIntermediateDirectories: true)
            try? FileManager.default.moveItem(
                at: segment,
                to: sealedDirectory.appendingPathComponent(segment.lastPathComponent)
            )
        }

        let page = try await reader.beginPage()

        XCTAssertEqual(page.events.map(\.localSequence), [1])
        XCTAssertEqual(page.status, .completed)
    }

    func testPageCursorReportsReclaimInvalidationWhenSnapshotSegmentDisappears() async throws {
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
        try await writer.append((1...2).map { makeEvent(sequence: UInt64($0), processInstanceID: processID) })

        let reader = DiagnosticsJournalReader(rootURL: rootURL)
        let firstPage = try await reader.beginPage(maximumEventCount: 1)
        let segment = try XCTUnwrap(
            FileManager.default.contentsOfDirectory(
                at: rootURL.appendingPathComponent("g1/open"),
                includingPropertiesForKeys: nil
            ).first
        )
        try FileManager.default.removeItem(at: segment)

        let invalidated = try await reader.nextPage(after: try XCTUnwrap(firstPage.nextCursor))

        XCTAssertTrue(invalidated.events.isEmpty)
        XCTAssertEqual(invalidated.status, .invalidatedByReclaim)
        XCTAssertNil(invalidated.nextCursor)
    }

    func testPageSnapshotRejectsMoreThanHardEventLimitEvenWhenCallerRequestsMore() async throws {
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
            (1...DiagnosticsJournalReader.defaultMaximumEventCount + 1).map {
                makeEvent(sequence: UInt64($0), processInstanceID: processID)
            }
        )

        let page = try await DiagnosticsJournalReader(rootURL: rootURL).beginPage(
            maximumEventCount: DiagnosticsJournalReader.defaultMaximumEventCount + 1,
            maximumReadBytes: DiagnosticsJournalReader.defaultMaximumReadBytes * 2
        )

        XCTAssertTrue(page.events.isEmpty)
        XCTAssertEqual(page.status, .snapshotExceedsEventBudget)
        XCTAssertNil(page.nextCursor)
    }

    func testPageCursorGloballyMergesInterleavedWriterSegments() async throws {
        let rootURL = makeTemporaryDirectory()
        defer { try? FileManager.default.removeItem(at: rootURL) }
        let mainID = UUID(uuidString: "00000000-0000-0000-0000-000000000010")!
        let extensionID = UUID(uuidString: "00000000-0000-0000-0000-000000000020")!
        let mainWriter = DiagnosticsJournalWriter(
            rootURL: rootURL,
            origin: .mainApp,
            processInstanceID: mainID,
            isMainAppWriter: true
        )
        let extensionWriter = DiagnosticsJournalWriter(
            rootURL: rootURL,
            origin: .keyboardExtension,
            processInstanceID: extensionID,
            isMainAppWriter: false
        )
        try await mainWriter.prepareRootIfOwnedByMainApp()

        let base = Date(timeIntervalSince1970: 1_723_123_456)
        try await mainWriter.append([
            makeEvent(sequence: 1, processInstanceID: mainID, timestamp: base.addingTimeInterval(1)),
            makeEvent(sequence: 3, processInstanceID: mainID, timestamp: base.addingTimeInterval(3)),
        ])
        try await extensionWriter.append([
            makeEvent(
                sequence: 2,
                processInstanceID: extensionID,
                origin: .keyboardExtension,
                timestamp: base.addingTimeInterval(2)
            ),
            makeEvent(
                sequence: 4,
                processInstanceID: extensionID,
                origin: .keyboardExtension,
                timestamp: base.addingTimeInterval(4)
            ),
        ])

        let reader = DiagnosticsJournalReader(rootURL: rootURL)
        let firstPage = try await reader.beginPage(maximumEventCount: 2, maximumReadBytes: 16 * 1_024)
        let secondPage = try await reader.nextPage(
            after: try XCTUnwrap(firstPage.nextCursor),
            maximumEventCount: 2,
            maximumReadBytes: 16 * 1_024
        )

        XCTAssertEqual(firstPage.events.map(\.localSequence), [4, 3])
        XCTAssertEqual(firstPage.status, .hasMore)
        XCTAssertEqual(secondPage.events.map(\.localSequence), [2, 1])
        XCTAssertEqual(secondPage.status, .completed)
        XCTAssertNil(secondPage.nextCursor)
    }

    func testPageCursorReportsGenerationInvalidationInsteadOfEmptyCompletion() async throws {
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
            (1...3).map { makeEvent(sequence: UInt64($0), processInstanceID: processID) }
        )

        let reader = DiagnosticsJournalReader(rootURL: rootURL)
        let firstPage = try await reader.beginPage(maximumEventCount: 1, maximumReadBytes: 16 * 1_024)
        _ = try await writer.advanceGenerationForClear()
        let invalidated = try await reader.nextPage(
            after: try XCTUnwrap(firstPage.nextCursor),
            maximumEventCount: 1,
            maximumReadBytes: 16 * 1_024
        )

        XCTAssertEqual(invalidated.generation, 2)
        XCTAssertTrue(invalidated.events.isEmpty)
        XCTAssertEqual(invalidated.status, .invalidatedByGeneration)
        XCTAssertNil(invalidated.nextCursor)
    }

    func testPageSnapshotRefusesPartialSegmentBudgetRatherThanReturningMisorderedEvents() async throws {
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

        let reader = DiagnosticsJournalReader(rootURL: rootURL)
        let page = try await reader.beginPage(maximumEventCount: 1, maximumReadBytes: 1)

        XCTAssertTrue(page.events.isEmpty)
        XCTAssertEqual(page.status, .snapshotExceedsReadBudget)
        XCTAssertNil(page.nextCursor)
    }

    func testAvailableDateRangesMapUTCHourSegmentsIntoLocalCalendarDays() async throws {
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
        // Asia/Shanghai 的午夜落在 UTC 16:00；两个事件应映射到相邻本地日期。
        let beforeLocalMidnight = Date(timeIntervalSince1970: 1_723_477_400)
        let afterLocalMidnight = beforeLocalMidnight.addingTimeInterval(60 * 60)
        try await writer.append([
            makeEvent(sequence: 1, processInstanceID: processID, timestamp: beforeLocalMidnight)
        ])
        try await writer.append([
            makeEvent(sequence: 2, processInstanceID: processID, timestamp: afterLocalMidnight)
        ])

        let timeZone = try XCTUnwrap(TimeZone(identifier: "Asia/Shanghai"))
        let ranges = try await DiagnosticsJournalReader(rootURL: rootURL).availableDateRanges(
            timeZone: timeZone
        )

        XCTAssertEqual(ranges.count, 2)
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        XCTAssertNotEqual(
            calendar.component(.day, from: ranges[0].start),
            calendar.component(.day, from: ranges[1].start)
        )
    }

    func testDateRangePageExcludesEventsFromAdjacentLocalDay() async throws {
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
        let firstDayEvent = Date(timeIntervalSince1970: 1_723_477_400)
        let secondDayEvent = firstDayEvent.addingTimeInterval(60 * 60)
        try await writer.append([
            makeEvent(sequence: 1, processInstanceID: processID, timestamp: firstDayEvent)
        ])
        try await writer.append([
            makeEvent(sequence: 2, processInstanceID: processID, timestamp: secondDayEvent)
        ])
        let timeZone = try XCTUnwrap(TimeZone(identifier: "Asia/Shanghai"))
        let ranges = try await DiagnosticsJournalReader(rootURL: rootURL).availableDateRanges(
            timeZone: timeZone
        )

        let page = try await DiagnosticsJournalReader(rootURL: rootURL).beginPage(
            in: try XCTUnwrap(ranges.first)
        )

        XCTAssertEqual(page.events.map(\.localSequence), [2])
        XCTAssertEqual(page.status, .completed)
    }

    func testRecentPreviewIsExplicitlyPartialAndKeepsNewestSampledEvents() async throws {
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
        let timestamp = Date(timeIntervalSince1970: 1_723_477_400)
        try await writer.append(
            (1...20).map {
                makeEvent(
                    sequence: UInt64($0),
                    processInstanceID: processID,
                    timestamp: timestamp.addingTimeInterval(Double($0))
                )
            }
        )
        let timeZone = try XCTUnwrap(TimeZone(identifier: "Asia/Shanghai"))
        let ranges = try await DiagnosticsJournalReader(rootURL: rootURL).availableDateRanges(
            timeZone: timeZone
        )
        let range = try XCTUnwrap(ranges.first)

        let preview = try await DiagnosticsJournalReader(rootURL: rootURL).recentPreview(
            in: range,
            maximumEventCount: 3,
            maximumReadBytes: 16 * 1_024
        )

        XCTAssertEqual(preview.events.map(\.localSequence), [20, 19, 18])
        XCTAssertEqual(preview.status, .partialRecentWindow)
        XCTAssertNil(preview.nextCursor)
    }

    func testRecentPreviewExcludesEventsAppendedAfterFrozenWatermark() async throws {
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
        let timestamp = Date(timeIntervalSince1970: 1_723_477_400)
        try await writer.append([
            makeEvent(sequence: 1, processInstanceID: processID, timestamp: timestamp)
        ])
        let ranges = try await DiagnosticsJournalReader(rootURL: rootURL).availableDateRanges()
        let range = try XCTUnwrap(ranges.first)
        let manifestCaptured = expectation(description: "preview manifest captured")
        let allowPreviewRead = DispatchSemaphore(value: 0)
        let reader = DiagnosticsJournalReader(
            rootURL: rootURL,
            snapshotCaptureHook: {
                manifestCaptured.fulfill()
                allowPreviewRead.wait()
            }
        )

        let previewTask = Task {
            try await reader.recentPreview(
                in: range,
                maximumEventCount: 10,
                maximumReadBytes: 16 * 1_024
            )
        }
        await fulfillment(of: [manifestCaptured], timeout: 2)
        try await writer.append([
            makeEvent(
                sequence: 2,
                processInstanceID: processID,
                timestamp: timestamp.addingTimeInterval(1)
            )
        ])
        allowPreviewRead.signal()

        let preview = try await previewTask.value
        XCTAssertEqual(preview.events.map(\.localSequence), [1])
        XCTAssertEqual(preview.status, .partialRecentWindow)
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

    func testBeginPageIgnoresPartialTailInCurrentGeneration() async throws {
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

        let segment = try XCTUnwrap(
            FileManager.default.contentsOfDirectory(
                at: rootURL.appendingPathComponent("g1/open"),
                includingPropertiesForKeys: nil
            ).first
        )
        let appendHandle = try FileHandle(forWritingTo: segment)
        try appendHandle.seekToEnd()
        try appendHandle.write(contentsOf: Data("{\"incomplete\":".utf8))
        try appendHandle.close()

        let page = try await DiagnosticsJournalReader(rootURL: rootURL).beginPage()

        XCTAssertEqual(page.events.map(\.localSequence), [1])
        XCTAssertEqual(page.status, .completed)
    }

    func testSnapshotFenceRejectsWriterMutationWhileManifestIsCaptured() async throws {
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

        XCTAssertThrowsError(
            try DiagnosticsJournalIdentityLock.withExclusiveSnapshotFence(rootURL: rootURL) {
                try DiagnosticsJournalIdentityLock.withSharedSnapshotFence(rootURL: rootURL) {}
            }
        ) { error in
            XCTAssertEqual(error as? DiagnosticsJournalError, .lockBusy)
        }
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
