import Foundation
import KeyboardCore
import XCTest

@testable import Universe_Keyboard

final class DiagnosticsLogSourceTests: XCTestCase {
    @MainActor
    func testCandidateTouchEventsDisplayCoarseBandAndCorrelationSequence() async throws {
        let rootURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: rootURL) }
        let processID = UUID()
        let rootOwner = DiagnosticsJournalWriter(
            rootURL: rootURL,
            origin: .mainApp,
            processInstanceID: UUID(),
            isMainAppWriter: true
        )
        let writer = DiagnosticsJournalWriter(
            rootURL: rootURL,
            origin: .keyboardExtension,
            processInstanceID: processID,
            isMainAppWriter: false
        )
        try await rootOwner.prepareRootIfOwnedByMainApp()
        try await writer.append([
            DiagnosticEvent(
                utcTimestamp: Date(),
                monotonicNanoseconds: 1,
                origin: .keyboardExtension,
                processInstanceID: processID,
                localSequence: 1,
                actionSequence: 7,
                code: .candidateTouchRouted,
                level: .info,
                category: .display,
                fields: [
                    .count(.candidateTouchBand, DiagnosticEvent.CandidateTouchBand.upper.rawValue),
                    .flag(.didHitCandidateCell, false),
                ]
            )
        ])
        let source = V1DiagnosticsLogSource(
            appGroupID: "test.group",
            rootURLProvider: { rootURL }
        )
        let catalog = await source.availableLogDayCatalog()
        guard case let .available(_, days) = catalog else {
            return XCTFail("Expected an available day catalog")
        }
        await source.selectLogDay(try XCTUnwrap(days.first))

        let loadedText = await source.loadLogText()
        let text = try XCTUnwrap(loadedText)

        XCTAssertTrue(text.contains("candidate.touch_routed"))
        XCTAssertTrue(text.contains("action=7"))
        XCTAssertTrue(text.contains("candidate_touch_band=upper"))
        XCTAssertTrue(text.contains("candidate_cell_hit=false"))
        XCTAssertFalse(text.contains("candidate_index"))
    }

    @MainActor
    func testRimeSyncEventsDisplayFiniteCorrelatedContext() async throws {
        let rootURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: rootURL) }
        let processID = UUID()
        let operationID = UUID()
        let writer = DiagnosticsJournalWriter(
            rootURL: rootURL,
            origin: .mainApp,
            processInstanceID: processID,
            isMainAppWriter: true
        )
        try await writer.prepareRootIfOwnedByMainApp()
        try await writer.append([
            DiagnosticEvent(
                utcTimestamp: Date(),
                monotonicNanoseconds: 1,
                origin: .mainApp,
                processInstanceID: processID,
                localSequence: 1,
                code: .rimeSyncTerminal,
                level: .error,
                category: .config,
                rimeSyncPayload: .terminal(
                    .init(
                        context: .init(
                            operationID: operationID,
                            source: .backgroundAutomatic
                        ),
                        result: .failed,
                        phase: .standardRimeData,
                        failure: .accessDenied
                    )
                )
            )
        ])
        let source = V1DiagnosticsLogSource(
            appGroupID: "test.group",
            rootURLProvider: { rootURL }
        )
        let catalog = await source.availableLogDayCatalog()
        guard case let .available(_, days) = catalog else {
            return XCTFail("Expected an available day catalog")
        }
        await source.selectLogDay(try XCTUnwrap(days.first))

        let loadedText = await source.loadLogText()
        let text = try XCTUnwrap(loadedText)

        XCTAssertTrue(text.contains("rime_sync.terminal"))
        XCTAssertTrue(text.contains(operationID.uuidString.lowercased()))
        XCTAssertTrue(text.contains("source=background_automatic"))
        XCTAssertTrue(text.contains("phase=standard_rime_data"))
        XCTAssertTrue(text.contains("result=failed"))
        XCTAssertTrue(text.contains("failure=access_denied"))
        XCTAssertFalse(text.contains("path="))
        XCTAssertFalse(text.contains("message="))
    }

    @MainActor
    func testV1ReadFailureStaysInV1WithControlledUnavailableNotice() async {
        let missingRoot = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let source = V1DiagnosticsLogSource(
            appGroupID: "test.group",
            rootURLProvider: { missingRoot }
        )

        let text = await source.loadLogText()
        let usedV1 = await source.didUseV1Result()
        let notice = await source.pagingNotice()

        XCTAssertNil(text)
        XCTAssertTrue(usedV1)
        XCTAssertEqual(notice, "诊断日志暂时不可用；旧日志不会在此状态下自动混入当前视图。")
    }

    @MainActor
    func testMissingV1RootStaysInV1WithControlledUnavailableNotice() async {
        let source = V1DiagnosticsLogSource(
            appGroupID: "test.group",
            rootURLProvider: { nil }
        )

        let text = await source.loadLogText()
        let usedV1 = await source.didUseV1Result()
        let notice = await source.pagingNotice()

        XCTAssertNil(text)
        XCTAssertTrue(usedV1)
        XCTAssertEqual(notice, "诊断日志暂时不可用；旧日志不会在此状态下自动混入当前视图。")
    }

    @MainActor
    func testIncompleteEmptyV1SuppressesLegacyFallback() async throws {
        let rootURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: rootURL) }
        let appGroupID = "test.group.keyboard-wake-incomplete"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: appGroupID))
        defaults.set("legacy fallback sentinel", forKey: "rime_diag_log")
        defer { defaults.removeObject(forKey: "rime_diag_log") }

        let processID = UUID()
        let writer = DiagnosticsJournalWriter(
            rootURL: rootURL,
            origin: .mainApp,
            processInstanceID: processID,
            isMainAppWriter: true
        )
        try await writer.prepareRootIfOwnedByMainApp()
        try await writer.append([
            DiagnosticEvent(
                utcTimestamp: Date(timeIntervalSince1970: 1_723_123_456),
                monotonicNanoseconds: 1,
                origin: .mainApp,
                processInstanceID: processID,
                localSequence: 1,
                code: .journalStarted,
                level: .info,
                category: .general
            )
        ])
        let segmentURL = try XCTUnwrap(
            FileManager.default.contentsOfDirectory(
                at: rootURL.appendingPathComponent("g1/open"),
                includingPropertiesForKeys: nil
            ).first { $0.pathExtension == "jsonl" }
        )
        let rejectedRecord =
            #"{"schemaVersion":5,"utcTimestamp":"2024-08-08T12:24:16Z","monotonicNanoseconds":2,"origin":"main_app","processInstanceID":"00000000-0000-0000-0000-000000000002","localSequence":2,"code":"unknown.event","level":"INFO","category":"GEN","fields":[]}"#
        try Data((rejectedRecord + "\n").utf8).write(to: segmentURL, options: .atomic)

        let source = CompositeDiagnosticsLogSource(
            appGroupID: appGroupID,
            rootURLProvider: { rootURL }
        )
        let text = await source.loadLogText()
        let notice = await source.pagingNotice()

        XCTAssertNil(text)
        XCTAssertTrue(notice?.contains("部分诊断记录无法读取") == true)
        XCTAssertFalse(text?.contains("legacy fallback sentinel") ?? false)
    }

    @MainActor
    func testV6HistoriesPropagateCompletenessThroughCompositeQuery() async throws {
        // Keep a legacy sentinel in every scenario: incomplete v6 history must never look empty.
        let scenarios: [(name: String, versions: [Int], rejected: Set<Int>)] = [
            ("v6-only", [6], []),
            ("mixed-complete", [5, 6], []),
            ("v6-incomplete", [6, 6], [1]),
            ("mixed-incomplete", [5, 6, 6], [2]),
            ("rejected-only", [6], [0]),
        ]
        for scenario in scenarios {
            let rootURL = FileManager.default.temporaryDirectory
                .appendingPathComponent("wake-v6-\(UUID().uuidString)", isDirectory: true)
            let appGroupID = "test.group.keyboard-wake-v6-\(UUID().uuidString)"
            let sentinel = "legacy-v6-\(UUID().uuidString)"
            let defaults = try XCTUnwrap(UserDefaults(suiteName: appGroupID))
            defaults.set(sentinel, forKey: "rime_diag_log")
            defer {
                defaults.removePersistentDomain(forName: appGroupID)
                try? FileManager.default.removeItem(at: rootURL)
            }

            let processID = UUID()
            let writer = DiagnosticsJournalWriter(
                rootURL: rootURL, origin: .mainApp, processInstanceID: processID,
                isMainAppWriter: true
            )
            try await writer.prepareRootIfOwnedByMainApp()
            // Raw fixtures go only into this test-owned temporary segment; no runtime emits v6.
            var fixtureData = Data()
            for (index, version) in scenario.versions.enumerated() {
                let object: [String: Any] = [
                    "schemaVersion": version,
                    "utcTimestamp": "2024-08-08T12:24:16Z",
                    "monotonicNanoseconds": index + 1,
                    "origin": DiagnosticEvent.Origin.mainApp.rawValue,
                    "processInstanceID": processID.uuidString,
                    "localSequence": index + 1,
                    "code": scenario.rejected.contains(index) ? "unknown.event" : "journal.started",
                    "level": Logger.Level.info.rawValue,
                    "category": Logger.Category.general.rawValue,
                    "fields": [],
                ]
                fixtureData.append(try JSONSerialization.data(withJSONObject: object, options: [.sortedKeys]))
                fixtureData.append(0x0A)
            }
            let segmentURL = rootURL.appendingPathComponent("g1/open", isDirectory: true)
                .appendingPathComponent("main_app-\(processID.uuidString)-20240808T12-0.jsonl")
            // Preparing the control file does not create a generation's segment directories.
            try FileManager.default.createDirectory(
                at: segmentURL.deletingLastPathComponent(), withIntermediateDirectories: true
            )
            try fixtureData.write(to: segmentURL, options: .atomic)

            let source = CompositeDiagnosticsLogSource(
                appGroupID: appGroupID, rootURLProvider: { rootURL }
            )
            let text = await source.loadLogText()
            let notice = await source.pagingNotice()
            let validCount = scenario.versions.count - scenario.rejected.count
            if validCount == 0 {
                XCTAssertNil(text, scenario.name)
            } else {
                let displayedCount =
                    try XCTUnwrap(text)
                    .components(separatedBy: "journal.started").count - 1
                XCTAssertEqual(displayedCount, validCount, scenario.name)
            }
            XCTAssertFalse(text?.contains(sentinel) ?? false, scenario.name)
            XCTAssertEqual(
                notice?.contains("部分诊断记录无法读取") ?? false,
                !scenario.rejected.isEmpty, scenario.name
            )
            XCTAssertEqual(try Data(contentsOf: segmentURL), fixtureData, scenario.name)
        }
    }

    @MainActor
    func testCompleteEmptyV1AllowsLegacyFallback() async throws {
        let rootURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: rootURL) }
        let appGroupID = "test.group.keyboard-wake-empty"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: appGroupID))
        defaults.set("legacy fallback sentinel", forKey: "rime_diag_log")
        defer { defaults.removeObject(forKey: "rime_diag_log") }

        let writer = DiagnosticsJournalWriter(
            rootURL: rootURL,
            origin: .mainApp,
            isMainAppWriter: true
        )
        try await writer.prepareRootIfOwnedByMainApp()

        let source = CompositeDiagnosticsLogSource(
            appGroupID: appGroupID,
            rootURLProvider: { rootURL }
        )
        let text = await source.loadLogText()

        XCTAssertEqual(text, "legacy fallback sentinel")
    }

    @MainActor
    func testClearReportsFailureWhenJournalRootIsUnavailable() async {
        let source = V1DiagnosticsLogSource(
            appGroupID: "test.group",
            rootURLProvider: { nil }
        )

        let result = await source.clearLog()

        XCTAssertEqual(result, .failed)
    }

    @MainActor
    func testClearAdvancesGenerationAndReportsSuccess() async throws {
        let rootURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: rootURL) }
        let source = V1DiagnosticsLogSource(
            appGroupID: "test.group",
            rootURLProvider: { rootURL }
        )

        let result = await source.clearLog()

        XCTAssertEqual(result, .cleared)
        let controlData = try Data(contentsOf: rootURL.appendingPathComponent("control.json"))
        let control = try JSONDecoder().decode(DiagnosticsJournalControl.self, from: controlData)
        XCTAssertEqual(control.currentGeneration, 2)
    }

    @MainActor
    func testOversizedJournalReturnsBoundedRecentPreviewInsteadOfBlankScreen() async throws {
        let rootURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
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
            DiagnosticEvent(
                utcTimestamp: Date(timeIntervalSince1970: 1_723_478_400),
                monotonicNanoseconds: 1,
                origin: .mainApp,
                processInstanceID: processID,
                localSequence: 1,
                code: .journalStarted,
                level: .info,
                category: .general,
                fields: [
                    .count(.queueDepth, 1),
                    .duration(.elapsedMilliseconds, 1),
                    .flag(.isHighFidelityEnabled, false),
                    .reason(.queueFull),
                ]
            )
        ])

        let segmentURL = try XCTUnwrap(
            FileManager.default.enumerator(at: rootURL, includingPropertiesForKeys: nil)?
                .compactMap { $0 as? URL }
                .first { $0.pathExtension == "jsonl" }
        )
        let encodedLine = try Data(contentsOf: segmentURL)
        var oversizedPayload = Data()
        while encodedLine.count + oversizedPayload.count
            <= DiagnosticsJournalReader.defaultMaximumReadBytes
        {
            oversizedPayload.append(encodedLine)
        }
        let handle = try FileHandle(forWritingTo: segmentURL)
        try handle.seekToEnd()
        try handle.write(contentsOf: oversizedPayload)
        try handle.close()

        let source = V1DiagnosticsLogSource(
            appGroupID: "test.group",
            rootURLProvider: { rootURL }
        )
        let catalog = await source.availableLogDayCatalog()
        guard case let .available(_, days) = catalog else {
            return XCTFail("Expected an available day catalog")
        }
        await source.selectLogDay(try XCTUnwrap(days.first))

        let text = await source.loadLogText()
        let isPartial = await source.isPartialLogWindow()
        let notice = await source.pagingNotice()

        XCTAssertNotNil(text)
        XCTAssertFalse(text?.isEmpty ?? true)
        XCTAssertTrue(isPartial)
        XCTAssertEqual(
            notice,
            "当前日期的完整日志超过安全读取上限，下面仅展示有界最近窗口；较早记录仍保留在设备上。"
        )
    }
}
