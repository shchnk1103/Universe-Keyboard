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
