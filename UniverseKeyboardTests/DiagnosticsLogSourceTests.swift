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
}
