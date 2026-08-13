import Foundation
import KeyboardCore
import XCTest

@testable import Universe_Keyboard

final class DiagnosticsLogSourceTests: XCTestCase {
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
