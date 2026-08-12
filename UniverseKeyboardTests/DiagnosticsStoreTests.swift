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

    func testDateBrowserDefaultsToNewestDayAndReloadsSelectedDay() async {
        let oldDay = DiagnosticsLogDay(
            range: DiagnosticsJournalDateRange(
                start: Date(timeIntervalSince1970: 1_723_392_000),
                end: Date(timeIntervalSince1970: 1_723_478_400)
            )
        )
        let newDay = DiagnosticsLogDay(
            range: DiagnosticsJournalDateRange(
                start: Date(timeIntervalSince1970: 1_723_478_400),
                end: Date(timeIntervalSince1970: 1_723_564_800)
            )
        )
        let source = DatedStubLogSource(
            days: [newDay, oldDay],
            textByDayStart: [
                newDay.range.start: "newest day event",
                oldDay.range.start: "older day event",
            ]
        )
        let store = DiagnosticsStore(logSource: source)

        store.loadLog()
        await waitUntil {
            store.selectedLogDay == newDay && store.lines == ["newest day event"]
        }

        store.selectLogDay(oldDay)
        await waitUntil {
            !store.isRefreshing
                && store.selectedLogDay == oldDay
                && store.lines == ["older day event"]
        }
    }

    func testClearInvalidatesAnOlderLoadThatFinishesLater() async {
        let source = ControlledLogSource()
        let store = DiagnosticsStore(logSource: source)

        store.loadLog()
        await waitUntil { source.loadContinuation != nil }
        store.performClear()
        await waitUntil { !store.isClearing }

        source.finishLoad(with: "stale event")
        await Task.yield()

        XCTAssertTrue(store.lines.isEmpty)
        XCTAssertNil(store.displayedNotice)
    }

    func testUnavailableDayCatalogPreservesVisibleStateAndDoesNotIssueUnboundedLoad() async {
        let source = ControlledDatedLogSource(catalog: .unavailable)
        let store = DiagnosticsStore(logSource: source)
        store.lines = ["visible event"]

        store.loadLog()
        await waitUntil { !store.isRefreshing }

        XCTAssertEqual(store.lines, ["visible event"])
        XCTAssertEqual(store.pagingNotice, "日志正在轮转或回收，请刷新后查看当前记录。")
        XCTAssertEqual(source.loadCallCount, 0)
    }

    func testLiveRefreshFollowsNewestDayWhenFirstEventArrivesAfterMidnight() async {
        let oldDay = makeDay(start: 1_723_392_000)
        let newDay = makeDay(start: 1_723_478_400)
        let source = ControlledDatedLogSource(
            catalog: .available(generation: 1, days: [oldDay]),
            textByDayStart: [oldDay.range.start: "yesterday event"]
        )
        let store = DiagnosticsStore(logSource: source)
        store.loadLog()
        await waitUntil { store.lines == ["yesterday event"] }

        source.catalog = .available(generation: 1, days: [newDay, oldDay])
        source.textByDayStart[newDay.range.start] = "new day event"
        await store.performLiveRefreshTick()

        XCTAssertEqual(store.selectedLogDay, newDay)
        XCTAssertEqual(store.lines, ["new day event"])
    }

    func testLiveRootRefreshPreventsOlderPageFromStartingWhileCatalogIsInFlight() async {
        let day = makeDay(start: 1_723_478_400)
        let source = ControlledDatedLogSource(
            catalog: .available(generation: 1, days: [day]),
            textByDayStart: [day.range.start: "root event"],
            hasMorePages: true
        )
        let store = DiagnosticsStore(logSource: source)
        store.loadLog()
        await waitUntil { store.lines == ["root event"] }

        source.shouldSuspendCatalog = true
        let liveRefresh = Task { await store.performLiveRefreshTick() }
        await waitUntil { source.catalogContinuation != nil }

        XCTAssertTrue(store.isRefreshing)
        store.loadMore()
        XCTAssertNil(source.loadMoreContinuation)

        source.finishCatalogDiscovery()
        await liveRefresh.value

        XCTAssertFalse(store.isRefreshing)
        XCTAssertEqual(store.lines, ["root event"])
    }

    func testSelectingAnotherDayInvalidatesAnInFlightOlderPage() async {
        let newestDay = makeDay(start: 1_723_478_400)
        let olderDay = makeDay(start: 1_723_392_000)
        let source = ControlledDatedLogSource(
            catalog: .available(generation: 1, days: [newestDay, olderDay]),
            textByDayStart: [
                newestDay.range.start: "newest root",
                olderDay.range.start: "older root",
            ],
            hasMorePages: true
        )
        let store = DiagnosticsStore(logSource: source)
        store.loadLog()
        await waitUntil { store.lines == ["newest root"] }

        store.loadMore()
        await waitUntil { source.loadMoreContinuation != nil }
        store.selectLogDay(olderDay)
        await waitUntil { store.lines == ["older root"] }
        source.finishLoadMore(with: "stale newest page")
        await Task.yield()

        XCTAssertEqual(store.selectedLogDay, olderDay)
        XCTAssertEqual(store.lines, ["older root"])
        XCTAssertFalse(store.isLoadingMore)
    }

    func testPartialWindowCanBeEmptyWithoutLookingLikeNoLogsExist() async {
        let day = makeDay(start: 1_723_478_400)
        let source = ControlledDatedLogSource(
            catalog: .available(generation: 1, days: [day]),
            isPartialWindow: true
        )
        let store = DiagnosticsStore(logSource: source)

        store.loadLog()
        await waitUntil { !store.isRefreshing }

        XCTAssertTrue(store.lines.isEmpty)
        XCTAssertTrue(store.isPartialWindow)
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

    private func makeDay(start: TimeInterval) -> DiagnosticsLogDay {
        DiagnosticsLogDay(
            range: DiagnosticsJournalDateRange(
                start: Date(timeIntervalSince1970: start),
                end: Date(timeIntervalSince1970: start + 86_400)
            )
        )
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
    func isPartialLogWindow() async -> Bool { false }
}

@MainActor
private final class DatedStubLogSource: DiagnosticsDatedLogSource {
    let days: [DiagnosticsLogDay]
    let textByDayStart: [Date: String]
    var selectedDay: DiagnosticsLogDay?

    init(days: [DiagnosticsLogDay], textByDayStart: [Date: String]) {
        self.days = days
        self.textByDayStart = textByDayStart
    }

    func availableLogDayCatalog() -> DiagnosticsLogDayCatalog {
        guard !days.isEmpty else { return .empty(generation: 1) }
        return .available(generation: 1, days: days)
    }

    func selectLogDay(_ day: DiagnosticsLogDay?) {
        selectedDay = day
    }

    func loadLogText() -> String? {
        guard let selectedDay else { return nil }
        return textByDayStart[selectedDay.range.start]
    }

    func loadMoreLogText() -> String? { nil }
    func hasMoreLogPages() -> Bool { false }
    func pagingNotice() -> String? { nil }
    func isPartialLogWindow() -> Bool { false }
    func clearLog() -> DiagnosticsLogClearResult { .cleared }
}

@MainActor
private final class ControlledLogSource: DiagnosticsLogPagingSource {
    var loadContinuation: CheckedContinuation<String?, Never>?

    func loadLogText() async -> String? {
        await withCheckedContinuation { continuation in
            loadContinuation = continuation
        }
    }

    func finishLoad(with text: String?) {
        let continuation = loadContinuation
        loadContinuation = nil
        continuation?.resume(returning: text)
    }

    func loadMoreLogText() -> String? { nil }
    func hasMoreLogPages() -> Bool { false }
    func pagingNotice() -> String? { nil }
    func isPartialLogWindow() -> Bool { false }
    func clearLog() -> DiagnosticsLogClearResult { .cleared }
}

@MainActor
private final class ControlledDatedLogSource: DiagnosticsDatedLogSource {
    var catalog: DiagnosticsLogDayCatalog
    var textByDayStart: [Date: String]
    var selectedDay: DiagnosticsLogDay?
    var hasMorePages: Bool
    var isPartialWindow: Bool
    var shouldSuspendCatalog = false
    var catalogContinuation: CheckedContinuation<Void, Never>?
    var loadMoreContinuation: CheckedContinuation<String?, Never>?
    private(set) var loadCallCount = 0

    init(
        catalog: DiagnosticsLogDayCatalog,
        textByDayStart: [Date: String] = [:],
        hasMorePages: Bool = false,
        isPartialWindow: Bool = false
    ) {
        self.catalog = catalog
        self.textByDayStart = textByDayStart
        self.hasMorePages = hasMorePages
        self.isPartialWindow = isPartialWindow
    }

    func availableLogDayCatalog() async -> DiagnosticsLogDayCatalog {
        if shouldSuspendCatalog {
            shouldSuspendCatalog = false
            await withCheckedContinuation { continuation in
                catalogContinuation = continuation
            }
        }
        return catalog
    }

    func finishCatalogDiscovery() {
        let continuation = catalogContinuation
        catalogContinuation = nil
        continuation?.resume()
    }

    func selectLogDay(_ day: DiagnosticsLogDay?) {
        selectedDay = day
    }

    func loadLogText() -> String? {
        loadCallCount += 1
        guard let selectedDay else { return nil }
        return textByDayStart[selectedDay.range.start]
    }

    func loadMoreLogText() async -> String? {
        await withCheckedContinuation { continuation in
            loadMoreContinuation = continuation
        }
    }

    func finishLoadMore(with text: String?) {
        let continuation = loadMoreContinuation
        loadMoreContinuation = nil
        continuation?.resume(returning: text)
    }

    func hasMoreLogPages() -> Bool { hasMorePages }
    func pagingNotice() -> String? { nil }
    func isPartialLogWindow() -> Bool { isPartialWindow }
    func clearLog() -> DiagnosticsLogClearResult { .cleared }
}
