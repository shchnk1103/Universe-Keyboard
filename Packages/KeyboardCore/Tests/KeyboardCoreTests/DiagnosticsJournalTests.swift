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

    func testLiveRefreshIdentityChangesWhenBytesAreAppended() async throws {
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
        let first = try await reader.liveRefreshIdentity()
        XCTAssertEqual(first.generation, 1)
        XCTAssertGreaterThan(first.totalByteWatermark, 0)

        try await writer.append([makeEvent(sequence: 2, processInstanceID: processID)])
        let second = try await reader.liveRefreshIdentity()
        XCTAssertEqual(second.generation, first.generation)
        XCTAssertGreaterThan(second.totalByteWatermark, first.totalByteWatermark)
    }

    func testLiveRefreshIdentityAndDateCatalogDoNotTakeExclusiveFence() async throws {
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

        let releaseHold = DispatchSemaphore(value: 0)
        await withCheckedContinuation { (started: CheckedContinuation<Void, Never>) in
            DispatchQueue.global().async {
                do {
                    try DiagnosticsJournalIdentityLock.withSharedSnapshotFence(rootURL: rootURL) {
                        started.resume()
                        releaseHold.wait()
                    }
                } catch {
                    started.resume()
                }
            }
        }
        let reader = DiagnosticsJournalReader(rootURL: rootURL)
        let identity = try await reader.liveRefreshIdentity()
        let catalog = try await reader.availableDateCatalog()
        do {
            _ = try await reader.beginPage()
            XCTFail("beginPage must still take the exclusive snapshot fence")
        } catch let error as DiagnosticsJournalError {
            XCTAssertEqual(error, .lockBusy)
        }
        releaseHold.signal()

        XCTAssertGreaterThan(identity.totalByteWatermark, 0)
        XCTAssertFalse(catalog.ranges.isEmpty)
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

    func testReaderAcceptsMixedV3V4V5HistoryWithoutRewritingOldRecords() async throws {
        let rootURL = makeTemporaryDirectory()
        defer { try? FileManager.default.removeItem(at: rootURL) }
        let processID = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
        let extensionID = UUID(uuidString: "00000000-0000-0000-0000-000000000002")!
        let timestamp = Date(timeIntervalSince1970: 1_723_123_456)
        let writer = DiagnosticsJournalWriter(
            rootURL: rootURL,
            origin: .mainApp,
            processInstanceID: processID,
            isMainAppWriter: true
        )
        try await writer.prepareRootIfOwnedByMainApp()
        let measuredEvent = DiagnosticEvent(
            utcTimestamp: timestamp,
            monotonicNanoseconds: 2,
            origin: .mainApp,
            processInstanceID: processID,
            localSequence: 2,
            code: .typoRecallQueryMeasured,
            level: .info,
            category: .performance,
            fields: [
                .typoRecallQuery(
                    .init(
                        operationOrdinal: 2,
                        stage: .stageOne,
                        readiness: .ready,
                        resultState: .candidatesReturned,
                        returnedCandidateBucket: .oneToThree,
                        disposition: .applied,
                        facadeElapsedMicroseconds: 42,
                        durationState: .measured
                    )
                )
            ]
        )
        try await writer.append([
            makeEvent(sequence: 1, processInstanceID: processID, timestamp: timestamp),
            measuredEvent,
        ])

        var v3Record = rawEventObject(
            version: 3,
            origin: .mainApp,
            processID: processID,
            sequence: 3
        )
        v3Record["utcTimestamp"] = "2024-08-08T12:24:16Z"
        let mainSegment = try XCTUnwrap(
            FileManager.default.contentsOfDirectory(
                at: rootURL.appendingPathComponent("g1/open"),
                includingPropertiesForKeys: nil
            ).first { $0.pathExtension == "jsonl" }
        )
        try appendRawRecord(v3Record, to: mainSegment)

        var v4Record = rawEventObject(
            version: 4,
            origin: .keyboardExtension,
            processID: extensionID,
            sequence: 4
        )
        v4Record["utcTimestamp"] = "2024-08-08T12:24:16Z"
        v4Record["code"] = DiagnosticEvent.Code.keyboardLifecyclePhaseChanged.rawValue
        v4Record["level"] = Logger.Level.debug.rawValue
        v4Record["category"] = Logger.Category.display.rawValue
        v4Record["keyboardLifecyclePayload"] = ["phase": "view_did_appear"]
        let extensionSegment =
            rootURL
            .appendingPathComponent("g1/open", isDirectory: true)
            .appendingPathComponent("keyboard_extension-\(extensionID.uuidString)-20240808T12-0.jsonl")
        try appendRawRecord(v4Record, to: extensionSegment)
        var v6Record = v4Record
        v6Record["schemaVersion"] = 6
        v6Record["localSequence"] = 5
        v6Record["monotonicNanoseconds"] = 5
        try appendRawRecord(v6Record, to: extensionSegment)
        let originalBytes = try Data(contentsOf: extensionSegment)

        let reader = DiagnosticsJournalReader(rootURL: rootURL)
        let latest = try await reader.latest()
        XCTAssertTrue(latest.completeness.isComplete)
        XCTAssertEqual(latest.events.count, 5)
        XCTAssertEqual(Set(latest.events.map(\.schemaVersion)), Set([3, 4, 5, 6]))
        XCTAssertTrue(latest.events.contains { $0.code == .typoRecallQueryMeasured })
        XCTAssertTrue(latest.events.contains { $0.keyboardLifecyclePayload?.phase == .viewDidAppear })

        let firstPage = try await reader.beginPage(maximumEventCount: 1)
        XCTAssertTrue(firstPage.completeness.isComplete)
        var pagedEvents = firstPage.events
        var cursor = firstPage.nextCursor
        while let currentCursor = cursor {
            let page = try await reader.nextPage(after: currentCursor, maximumEventCount: 1)
            XCTAssertTrue(page.completeness.isComplete)
            pagedEvents.append(contentsOf: page.events)
            cursor = page.nextCursor
        }
        XCTAssertEqual(pagedEvents.count, 5)
        XCTAssertEqual(Set(pagedEvents.map(\.schemaVersion)), Set([3, 4, 5, 6]))

        let catalog = try await reader.availableDateCatalog(timeZone: TimeZone(secondsFromGMT: 0)!)
        let dateRange = try XCTUnwrap(catalog.ranges.first)
        let preview = try await reader.recentPreview(in: dateRange)
        XCTAssertTrue(preview.completeness.isComplete)
        XCTAssertEqual(preview.events.count, 5)

        XCTAssertEqual(try Data(contentsOf: extensionSegment), originalBytes)

        let decodedV3 = try XCTUnwrap(latest.events.first { $0.schemaVersion == 3 })
        do {
            try await writer.append([decodedV3])
            XCTFail("The v5 writer must not rewrite a retained v3 record")
        } catch let error as DiagnosticsJournalError {
            XCTAssertEqual(error, .writeFailed)
        }
    }

    func testRejectedRecordsRemainIncompleteAcrossPagesAndReaderPaths() async throws {
        let rootURL = makeTemporaryDirectory()
        defer { try? FileManager.default.removeItem(at: rootURL) }
        let processID = UUID()
        let timestamp = Date(timeIntervalSince1970: 1_723_123_456)
        let writer = DiagnosticsJournalWriter(
            rootURL: rootURL,
            origin: .mainApp,
            processInstanceID: processID,
            isMainAppWriter: true
        )
        try await writer.prepareRootIfOwnedByMainApp()
        try await writer.append([
            makeEvent(sequence: 1, processInstanceID: processID, timestamp: timestamp),
            makeEvent(sequence: 2, processInstanceID: processID, timestamp: timestamp),
        ])
        let segment = try XCTUnwrap(
            FileManager.default.contentsOfDirectory(
                at: rootURL.appendingPathComponent("g1/open"),
                includingPropertiesForKeys: nil
            ).first { $0.pathExtension == "jsonl" }
        )

        var unknownCode = rawEventObject(
            version: 6,
            origin: .mainApp,
            processID: processID,
            sequence: 3
        )
        unknownCode["code"] = "unrecognized.event.code"
        try appendRawRecord(unknownCode, to: segment)

        var malformedPayload = rawEventObject(
            version: 6,
            origin: .keyboardExtension,
            processID: UUID(),
            sequence: 4
        )
        malformedPayload["code"] = DiagnosticEvent.Code.keyboardLifecyclePhaseChanged.rawValue
        malformedPayload["level"] = Logger.Level.debug.rawValue
        malformedPayload["category"] = Logger.Category.display.rawValue
        malformedPayload["keyboardLifecyclePayload"] = [:]
        let extensionSegment =
            rootURL
            .appendingPathComponent("g1/open", isDirectory: true)
            .appendingPathComponent("keyboard_extension-00000000-0000-0000-0000-000000000004-20240808T12-0.jsonl")
        try appendRawRecord(malformedPayload, to: extensionSegment)

        let expectedReasons: Set<DiagnosticsJournalRejectionReason> = [
            .unsupportedCode,
            .malformedPayload,
        ]
        let reader = DiagnosticsJournalReader(rootURL: rootURL)

        let latest = try await reader.latest()
        XCTAssertEqual(latest.completeness.rejectionReasons, expectedReasons)
        XCTAssertEqual(latest.events.count, 2)

        let firstPage = try await reader.beginPage(maximumEventCount: 1)
        XCTAssertEqual(firstPage.completeness.rejectionReasons, expectedReasons)
        XCTAssertEqual(firstPage.events.count, 1)
        let cursor = try XCTUnwrap(firstPage.nextCursor)
        let nextPage = try await reader.nextPage(after: cursor, maximumEventCount: 1)
        XCTAssertEqual(nextPage.completeness.rejectionReasons, expectedReasons)
        XCTAssertEqual(nextPage.events.count, 1)
        XCTAssertNil(nextPage.nextCursor)

        let catalog = try await reader.availableDateCatalog(timeZone: TimeZone(secondsFromGMT: 0)!)
        let dateRange = try XCTUnwrap(catalog.ranges.first)
        let preview = try await reader.recentPreview(in: dateRange)
        XCTAssertEqual(preview.completeness.rejectionReasons, expectedReasons)
        XCTAssertEqual(preview.events.count, 2)
    }

    func testV5WriterRejectsDecodedV6Marker() async throws {
        let rootURL = makeTemporaryDirectory()
        defer { try? FileManager.default.removeItem(at: rootURL) }
        let processID = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
        var rawMarker = rawEventObject(
            version: 6,
            origin: .keyboardExtension,
            processID: processID,
            sequence: 1
        )
        rawMarker["code"] = DiagnosticEvent.Code.keyboardLifecyclePhaseChanged.rawValue
        rawMarker["level"] = Logger.Level.debug.rawValue
        rawMarker["category"] = Logger.Category.display.rawValue
        rawMarker["keyboardLifecyclePayload"] = ["phase": "view_did_appear"]

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let markerData = try JSONSerialization.data(withJSONObject: rawMarker)
        let marker = try decoder.decode(DiagnosticEvent.self, from: markerData)
        XCTAssertEqual(marker.schemaVersion, 6)

        let writer = DiagnosticsJournalWriter(
            rootURL: rootURL,
            origin: .keyboardExtension,
            processInstanceID: processID,
            isMainAppWriter: false
        )
        do {
            try await writer.append([marker])
            XCTFail("Production v5 writer must reject a decoded v6 marker")
        } catch let error as DiagnosticsJournalError {
            XCTAssertEqual(error, .writeFailed)
        }
    }

    func testRejectedOnlyV6HistoryRemainsIncomplete() async throws {
        let rootURL = makeTemporaryDirectory()
        defer { try? FileManager.default.removeItem(at: rootURL) }
        let processID = UUID(uuidString: "00000000-0000-0000-0000-000000000004")!
        let writer = DiagnosticsJournalWriter(
            rootURL: rootURL,
            origin: .mainApp,
            processInstanceID: processID,
            isMainAppWriter: true
        )
        try await writer.prepareRootIfOwnedByMainApp()

        let extensionID = UUID(uuidString: "00000000-0000-0000-0000-000000000005")!
        var invalidMarker = rawEventObject(
            version: 6,
            origin: .keyboardExtension,
            processID: extensionID,
            sequence: 1
        )
        invalidMarker["code"] = DiagnosticEvent.Code.keyboardLifecyclePhaseChanged.rawValue
        invalidMarker["level"] = Logger.Level.debug.rawValue
        invalidMarker["category"] = Logger.Category.display.rawValue
        invalidMarker["keyboardLifecyclePayload"] = ["phase": "unrecognized_phase"]
        let segment =
            rootURL
            .appendingPathComponent("g1/open", isDirectory: true)
            .appendingPathComponent("keyboard_extension-\(extensionID.uuidString)-20240808T12-0.jsonl")
        try appendRawRecord(invalidMarker, to: segment)

        let result = try await DiagnosticsJournalReader(rootURL: rootURL).latest()
        let expectedReasons: Set<DiagnosticsJournalRejectionReason> = [.unknownValue]
        XCTAssertTrue(result.events.isEmpty)
        XCTAssertFalse(result.completeness.isComplete)
        XCTAssertEqual(result.completeness.rejectionReasons, expectedReasons)
    }

    private func rawEventObject(
        version: Int,
        origin: DiagnosticEvent.Origin,
        processID: UUID,
        sequence: UInt64
    ) -> [String: Any] {
        [
            "schemaVersion": version,
            "utcTimestamp": "2024-08-08T12:24:16Z",
            "monotonicNanoseconds": sequence,
            "origin": origin.rawValue,
            "processInstanceID": processID.uuidString,
            "localSequence": sequence,
            "code": DiagnosticEvent.Code.journalStarted.rawValue,
            "level": Logger.Level.info.rawValue,
            "category": Logger.Category.general.rawValue,
            "fields": [],
        ]
    }

    private func appendRawRecord(_ object: [String: Any], to segmentURL: URL) throws {
        let data = try JSONSerialization.data(withJSONObject: object, options: [.sortedKeys])
        if !FileManager.default.fileExists(atPath: segmentURL.path) {
            try FileManager.default.createDirectory(
                at: segmentURL.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            FileManager.default.createFile(atPath: segmentURL.path, contents: nil)
        }
        let handle = try FileHandle(forWritingTo: segmentURL)
        defer { try? handle.close() }
        try handle.seekToEnd()
        try handle.write(contentsOf: data)
        try handle.write(contentsOf: Data([0x0A]))
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
