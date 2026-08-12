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

    func testOversizedSnapshotNoticeKeepsClearActionAvailable() async {
        let source = StubLogSource(
            notice: "当前日志快照过大，无法在安全读取上限内严格排序；请使用右上角垃圾桶清空后重新记录。"
        )
        let store = DiagnosticsStore(logSource: source)

        store.loadLog()
        await waitUntil { store.pagingNotice != nil }

        XCTAssertTrue(store.lines.isEmpty)
        XCTAssertTrue(store.canClearLog)
    }

    func testFailedClearKeepsRecoveryActionAndReportsFailure() async {
        let store = DiagnosticsStore(
            logSource: StubLogSource(notice: "日志超出读取预算", clearResult: .failed)
        )
        store.lines = ["existing event"]

        store.performClear()
        await waitUntil { !store.isClearing }

        XCTAssertEqual(store.lines, ["existing event"])
        XCTAssertTrue(store.canClearLog)
        XCTAssertEqual(store.displayedNotice, "未能完整清空诊断日志，请稍后重试。现有记录可能仍然存在。")
    }

    func testSuccessfulClearResetsVisibleState() async {
        let store = DiagnosticsStore(logSource: StubLogSource(notice: "日志超出读取预算"))
        store.lines = ["existing event"]
        store.pagingNotice = "日志超出读取预算"
        store.hasMorePages = true

        store.performClear()
        await waitUntil { !store.isClearing }

        XCTAssertTrue(store.lines.isEmpty)
        XCTAssertFalse(store.hasMorePages)
        XCTAssertNil(store.displayedNotice)
        XCTAssertFalse(store.canClearLog)
    }

    private func waitUntil(
        timeout: Duration = .seconds(2),
        condition: @escaping @MainActor () -> Bool
    ) async {
        let clock = ContinuousClock()
        let deadline = clock.now.advanced(by: timeout)
        while !condition(), clock.now < deadline {
            await Task.yield()
        }
        XCTAssertTrue(condition())
    }
}

private struct StubLogSource: DiagnosticsLogSource {
    var text: String?
    var notice: String?
    var clearResult: DiagnosticsLogClearResult

    init(
        text: String? = nil,
        notice: String? = nil,
        clearResult: DiagnosticsLogClearResult = .cleared
    ) {
        self.text = text
        self.notice = notice
        self.clearResult = clearResult
    }

    func loadLogText() async -> String? { text }
    func clearLog() async -> DiagnosticsLogClearResult { clearResult }
}

extension StubLogSource: DiagnosticsLogPagingSource {
    func loadMoreLogText() async -> String? { nil }
    func hasMoreLogPages() async -> Bool { false }
    func pagingNotice() async -> String? { notice }
}
