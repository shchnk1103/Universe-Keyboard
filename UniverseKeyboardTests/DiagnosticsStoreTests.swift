import KeyboardCore
import XCTest

@testable import Universe_Keyboard

@MainActor
final class DiagnosticsStoreTests: XCTestCase {
    func testSummaryAndCategoryFiltersDeriveExpectedLines() {
        let store = DiagnosticsStore(logSource: StubLogSource())
        store.lines = [
            "[12:00:00.000] [INFO] [PERF] SLOW candidate refresh (51.0ms)",
            "[12:00:01.000] [WARN] [ENGINE] session recovery retried",
            "[12:00:02.000] [INFO] [DISP] keyboard presented",
        ]

        XCTAssertEqual(store.slowEventCount, 1)
        XCTAssertEqual(store.warningCount, 1)

        store.selectSummaryFilter(.slowEvents)
        XCTAssertEqual(
            store.filteredLines,
            ["[12:00:00.000] [INFO] [PERF] SLOW candidate refresh (51.0ms)"]
        )
        XCTAssertEqual(store.selectionDescription, "慢事件")

        store.selectCategory(.engine)
        XCTAssertEqual(
            store.filteredLines,
            ["[12:00:01.000] [WARN] [ENGINE] session recovery retried"]
        )
        XCTAssertEqual(store.selectionDescription, "ENGINE 分类")
    }

    func testColorForLineMapsSeverityAndCategoryMarkers() {
        let store = DiagnosticsStore(logSource: StubLogSource())

        XCTAssertEqual(store.colorForLine("[12:00:00.000] [ERROR] [ENGINE] crash"), "error")
        XCTAssertEqual(store.colorForLine("[12:00:00.000] [WARN] [ENGINE] retry"), "warning")
        XCTAssertEqual(store.colorForLine("[12:00:00.000] [PERF] [PERF] sample"), "primary")
        XCTAssertEqual(store.colorForLine("[12:00:00.000] [DISP] [DISP] sample"), "secondary")
    }

    func testSearchFiltersAndExportUseTheSameVisibleResult() {
        let store = DiagnosticsStore(logSource: StubLogSource())
        store.lines = [
            "[12:00:00.000] [INFO] [DISP] presentation.appeared",
            "[12:00:01.000] [WARN] [ENGINE] journal.dropped reason=queue_full",
        ]
        store.searchQuery = "QUEUE_FULL"

        XCTAssertEqual(store.filteredLines, ["[12:00:01.000] [WARN] [ENGINE] journal.dropped reason=queue_full"])
        XCTAssertEqual(store.exportText, "[12:00:01.000] [WARN] [ENGINE] journal.dropped reason=queue_full")
    }

    func testExportRequiresNarrowerFilterWhenResultExceedsRecordLimit() {
        let store = DiagnosticsStore(logSource: StubLogSource())
        store.lines = Array(repeating: "[12:00:00.000] [INFO] [GEN] journal.started", count: 10_001)

        XCTAssertFalse(store.canExportCurrentSelection)
        XCTAssertEqual(store.exportText, "")
        XCTAssertEqual(store.exportLimitMessage, "当前结果超过 10,000 条，请缩小筛选范围后复制。")
    }
}

private struct StubLogSource: DiagnosticsLogSource {
    func loadLogText() async -> String? { nil }
    func clearLog() async {}
}
