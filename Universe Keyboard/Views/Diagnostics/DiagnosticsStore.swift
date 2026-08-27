import Foundation
import KeyboardCore
import Observation

@MainActor
@Observable
final class DiagnosticsStore {
    private static let exportMaximumRecordCount = 10_000
    private static let exportMaximumByteCount = 5 * 1_024 * 1_024

    enum SummaryFilter {
        case all
        case slowEvents
        case warnings
    }

    private struct SearchPageAdmission {
        let didAppend: Bool
        let reachedBudget: Bool
    }

    let filterOptions: [(String, Logger.Category?)] = [
        ("全部", nil),
        ("性能", .performance),
        ("画面", .display),
        ("引擎", .engine),
        ("配置", .config),
        ("部署", .deployment),
        ("通用", .general),
    ]

    var lines: [String] = []
    var searchQuery = ""
    var isRefreshing = false
    var isManualRefreshing = false
    var isSearchPresented = false
    var isClearing = false
    var isLoadingMore = false
    var hasMorePages = false
    var pagingNotice: String?
    var searchLimitNotice: String?
    var clearFailureNotice: String?
    var isPartialWindow = false
    var availableLogDays: [DiagnosticsLogDay] = []
    var selectedLogDay: DiagnosticsLogDay?
    private var hasLoadedOlderPages = false
    private var isFollowingLatestDay = true
    var selectedSummaryFilter: SummaryFilter = .all
    var selectedCategory: Logger.Category?

    private let logSource: any DiagnosticsLogSource
    private let searchMaximumRecordCount: Int
    private let searchMaximumByteCount: Int

    private var liveRefreshTask: Task<Void, Never>?
    private var searchExpansionTask: Task<Void, Never>?
    private var searchExpansionID: UUID?
    private var searchLoadingID: UUID?
    private var shouldReloadAfterSearchFinishes = false
    private var pendingLogDayAfterSearch: DiagnosticsLogDay?
    private var queryRevision: UInt64 = 0
    private var lastLiveRefreshIdentity: String?

    init(
        logSource: any DiagnosticsLogSource = CompositeDiagnosticsLogSource(appGroupID: universeAppGroupID),
        searchMaximumRecordCount: Int = DiagnosticsStore.exportMaximumRecordCount,
        searchMaximumByteCount: Int = DiagnosticsStore.exportMaximumByteCount
    ) {
        self.logSource = logSource
        self.searchMaximumRecordCount = max(1, searchMaximumRecordCount)
        self.searchMaximumByteCount = max(1, searchMaximumByteCount)
    }

    var filteredLines: [String] {
        let scopedLines: [String]
        switch selectedSummaryFilter {
        case .all:
            scopedLines = lines
        case .slowEvents:
            scopedLines = lines.filter(isSlowEvent)
        case .warnings:
            scopedLines = lines.filter(isWarning)
        }

        let categoryScopedLines: [String]
        if let category = selectedCategory {
            let tag = "[\(category.rawValue)]"
            categoryScopedLines = scopedLines.filter { $0.contains(tag) }
        } else {
            categoryScopedLines = scopedLines
        }

        let normalizedQuery = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalizedQuery.isEmpty else { return categoryScopedLines }
        return categoryScopedLines.filter {
            $0.localizedCaseInsensitiveContains(normalizedQuery)
        }
    }

    var displayedLines: [String] {
        filteredLines
    }

    var slowEventCount: Int {
        lines.filter(isSlowEvent).count
    }

    var warningCount: Int {
        lines.filter(isWarning).count
    }

    var selectionDescription: String {
        switch (selectedSummaryFilter, selectedCategory) {
        case (.all, nil):
            return "全部日志"
        case (.slowEvents, nil):
            return "慢事件"
        case (.warnings, nil):
            return "警告"
        case (.all, .some(let category)):
            return "\(category.rawValue) 分类"
        case (.slowEvents, .some(let category)):
            return "慢事件 · \(category.rawValue)"
        case (.warnings, .some(let category)):
            return "警告 · \(category.rawValue)"
        }
    }

    var exportText: String {
        guard canExportCurrentSelection else { return "" }
        return filteredLines.joined(separator: "\n")
    }

    var canExportCurrentSelection: Bool {
        exportLimitMessage == nil && !filteredLines.isEmpty
    }

    var canClearLog: Bool {
        !isClearing && !isRefreshing && !isLoadingMore && searchExpansionTask == nil
            && (!lines.isEmpty || pagingNotice != nil || searchLimitNotice != nil || clearFailureNotice != nil)
    }

    var displayedNotice: String? {
        clearFailureNotice ?? searchLimitNotice ?? pagingNotice
    }

    var exportLimitMessage: String? {
        let records = filteredLines
        guard records.count <= Self.exportMaximumRecordCount else {
            return "当前结果超过 10,000 条，请缩小筛选范围后复制。"
        }
        let byteCount = records.reduce(into: 0) { $0 += $1.utf8.count + 1 }
        guard byteCount <= Self.exportMaximumByteCount else {
            return "当前结果超过 5 MiB，请缩小筛选范围后复制。"
        }
        return nil
    }

    func loadLog() {
        guard !isClearing else { return }
        if searchLoadingID != nil {
            shouldReloadAfterSearchFinishes = true
            invalidateSearchExpansion()
            return
        }
        guard !isLoadingMore else { return }
        invalidateSearchExpansion()
        let revision = advanceQueryRevision()
        isRefreshing = true
        isLoadingMore = false
        Task {
            await replaceWithLatestPagePeeking(refreshDays: true, revision: revision)
            guard revision == queryRevision else { return }
            isRefreshing = false
            scheduleSearchExpansionIfNeeded()
        }
    }

    func startLiveRefresh() {
        guard liveRefreshTask == nil else { return }
        liveRefreshTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1))
                guard let self, !Task.isCancelled else { return }
                await self.performLiveRefreshTick()
            }
        }
    }

    func stopLiveRefresh() {
        liveRefreshTask?.cancel()
        liveRefreshTask = nil
        shouldReloadAfterSearchFinishes = false
        pendingLogDayAfterSearch = nil
        invalidateSearchExpansion()
    }

    func refresh() {
        guard !isSearchPresented, !isRefreshing, !isClearing, !isLoadingMore else { return }
        let revision = advanceQueryRevision()
        isRefreshing = true
        isManualRefreshing = true
        clearFailureNotice = nil

        Task {
            try? await Task.sleep(for: .milliseconds(400))
            guard revision == queryRevision else {
                isManualRefreshing = false
                return
            }
            await replaceWithLatestPagePeeking(refreshDays: true, revision: revision)
            guard revision == queryRevision else {
                isManualRefreshing = false
                return
            }
            isRefreshing = false
            isManualRefreshing = false
        }
    }

    func updateSearchQuery(_ query: String) {
        searchQuery = query
    }

    func setSearchPresented(_ presented: Bool) {
        guard isSearchPresented != presented else { return }
        isSearchPresented = presented
        if presented {
            scheduleSearchExpansionIfNeeded()
        } else {
            let mustReloadRoot = hasLoadedOlderPages || searchLoadingID != nil
            shouldReloadAfterSearchFinishes = searchLoadingID != nil
            invalidateSearchExpansion()
            // Search may have expanded the frozen cursor to older pages. Reset
            // to the newest root page so the one-second live follower can
            // resume without mixing a new root with an old snapshot.
            if mustReloadRoot, searchLoadingID == nil {
                loadLog()
            }
        }
    }

    func performClear() {
        guard !isClearing, !isLoadingMore, searchExpansionTask == nil else { return }
        invalidateSearchExpansion()
        let revision = advanceQueryRevision()
        isClearing = true
        isRefreshing = false
        isManualRefreshing = false
        isLoadingMore = false
        clearFailureNotice = nil

        Task {
            try? await Task.sleep(for: .milliseconds(300))
            guard revision == queryRevision else { return }
            let result = await logSource.clearLog()
            guard revision == queryRevision else { return }
            if result == .cleared {
                lines = []
                hasMorePages = false
                hasLoadedOlderPages = false
                pagingNotice = nil
                searchLimitNotice = nil
                availableLogDays = []
                selectedLogDay = nil
                isPartialWindow = false
                isFollowingLatestDay = true
                lastLiveRefreshIdentity = nil
            } else {
                clearFailureNotice = "未能完整清空诊断日志，请稍后重试。现有记录可能仍然存在。"
            }
            isClearing = false
        }
    }

    func loadMore() {
        guard
            hasMorePages,
            !isSearchPresented,
            !isLoadingMore,
            !isRefreshing,
            !isClearing,
            lines.count < Self.exportMaximumRecordCount
        else { return }
        guard let pagingSource = logSource as? any DiagnosticsLogPagingSource else {
            hasMorePages = false
            return
        }
        let revision = queryRevision
        isLoadingMore = true
        Task {
            let text = await pagingSource.loadMoreLogText()
            guard revision == queryRevision else { return }
            let sourceHasMorePages = await pagingSource.hasMoreLogPages()
            guard revision == queryRevision else { return }
            let notice = await pagingSource.pagingNotice()
            guard revision == queryRevision else { return }
            let isPartial = await pagingSource.isPartialLogWindow()
            guard revision == queryRevision else { return }

            if let text {
                let remainingCapacity = Self.exportMaximumRecordCount - lines.count
                lines.append(contentsOf: Self.lines(from: text).prefix(remainingCapacity))
                hasLoadedOlderPages = true
            }
            hasMorePages =
                sourceHasMorePages
                && lines.count < Self.exportMaximumRecordCount
            pagingNotice = notice
            isPartialWindow = isPartial
            isLoadingMore = false
        }
    }

    func selectLogDay(_ day: DiagnosticsLogDay) {
        guard day != selectedLogDay, !isRefreshing, !isClearing else { return }
        if searchLoadingID != nil {
            pendingLogDayAfterSearch = day
            invalidateSearchExpansion()
            return
        }
        invalidateSearchExpansion()
        let revision = advanceQueryRevision()
        // 日期选择是新的根查询，可以主动废弃尚未完成的旧页，而不是吞掉用户点击。
        isLoadingMore = false
        selectedLogDay = day
        isFollowingLatestDay = day == availableLogDays.first
        isRefreshing = true
        clearFailureNotice = nil
        Task {
            await replaceWithLatestPagePeeking(refreshDays: false, revision: revision)
            guard revision == queryRevision else { return }
            isRefreshing = false
            scheduleSearchExpansionIfNeeded()
        }
    }

    func selectSummaryFilter(_ filter: SummaryFilter) {
        selectedSummaryFilter = filter
        selectedCategory = nil
    }

    func selectCategory(_ category: Logger.Category?) {
        selectedSummaryFilter = .all
        selectedCategory = category
    }

    func colorForLine(_ line: String) -> String {
        if line.contains("[ERROR]") { return "error" }
        if line.contains("[WARN]") { return "warning" }
        if line.contains("[PERF]") { return "primary" }
        if line.contains("[DISP]") { return "secondary" }
        return "secondary"
    }

    func performLiveRefreshTick() async {
        // 用户正在浏览历史日期或已展开旧页时，实时刷新不得重置其上下文。
        guard
            isFollowingLatestDay,
            !hasLoadedOlderPages,
            !isSearchPresented,
            !isClearing,
            !isRefreshing,
            !isLoadingMore
        else { return }
        let peekedIdentity = await liveRefreshIdentity()
        if let peekedIdentity, peekedIdentity == lastLiveRefreshIdentity {
            return
        }
        // 实时根刷新与手动根查询遵守同一 revision 边界。先占用刷新状态，
        // 避免刷新在 source await 期间又启动一个旧 cursor 的 load-more。
        let revision = advanceQueryRevision()
        isRefreshing = true
        await replaceWithLatestPage(
            refreshDays: true,
            revision: revision,
            peekedLiveRefreshIdentity: peekedIdentity
        )
        guard revision == queryRevision else { return }
        isRefreshing = false
    }

    private func scheduleSearchExpansionIfNeeded() {
        guard searchExpansionTask == nil, isSearchPresented, hasMorePages else { return }
        guard searchBudgetAllowsAnotherLine else {
            hasMorePages = false
            return
        }
        let revision = queryRevision
        let expansionID = UUID()
        searchExpansionID = expansionID
        searchExpansionTask = Task { @MainActor [weak self] in
            guard let self else { return }
            defer {
                if self.searchExpansionID == expansionID {
                    self.searchExpansionID = nil
                    self.searchExpansionTask = nil
                }
                if let pendingDay = self.pendingLogDayAfterSearch {
                    self.pendingLogDayAfterSearch = nil
                    self.shouldReloadAfterSearchFinishes = false
                    self.selectLogDay(pendingDay)
                } else if self.shouldReloadAfterSearchFinishes {
                    self.shouldReloadAfterSearchFinishes = false
                    self.loadLog()
                }
            }
            // Manual pagination owns the same source cursor. Search waits for
            // that request to finish instead of consuming the cursor twice.
            while self.isRefreshing || self.isClearing || self.isLoadingMore {
                try? await Task.sleep(for: .milliseconds(20))
                guard self.isCurrentSearchExpansion(expansionID, revision: revision) else { return }
            }
            guard self.isCurrentSearchExpansion(expansionID, revision: revision) else { return }
            await self.loadRemainingPagesForSearch(expansionID: expansionID, revision: revision)
        }
    }

    private func loadRemainingPagesForSearch(expansionID: UUID, revision: UInt64) async {
        guard let pagingSource = logSource as? any DiagnosticsLogPagingSource else { return }
        searchLoadingID = expansionID
        isLoadingMore = true
        defer {
            if searchLoadingID == expansionID {
                searchLoadingID = nil
                isLoadingMore = false
            }
        }

        while isCurrentSearchExpansion(expansionID, revision: revision), hasMorePages,
            searchBudgetAllowsAnotherLine
        {
            let previousCount = lines.count
            let text = await pagingSource.loadMoreLogText()
            guard isCurrentSearchExpansion(expansionID, revision: revision) else { return }
            let sourceHasMorePages = await pagingSource.hasMoreLogPages()
            guard isCurrentSearchExpansion(expansionID, revision: revision) else { return }
            let notice = await pagingSource.pagingNotice()
            guard isCurrentSearchExpansion(expansionID, revision: revision) else { return }
            let isPartial = await pagingSource.isPartialLogWindow()
            guard isCurrentSearchExpansion(expansionID, revision: revision) else { return }

            let admission = text.map(appendSearchPageWithinBudget)
            hasLoadedOlderPages = admission?.didAppend == true || hasLoadedOlderPages
            hasMorePages =
                admission?.reachedBudget != true
                && sourceHasMorePages
                && searchBudgetAllowsAnotherLine
            pagingNotice = notice
            isPartialWindow = isPartial
            // A source that returns no data but keeps its cursor must not spin.
            guard lines.count > previousCount else { return }
        }
    }

    private func replaceWithLatestPagePeeking(refreshDays: Bool, revision: UInt64) async {
        let peekedIdentity = await liveRefreshIdentity()
        await replaceWithLatestPage(
            refreshDays: refreshDays,
            revision: revision,
            peekedLiveRefreshIdentity: peekedIdentity
        )
    }

    private func replaceWithLatestPage(
        refreshDays: Bool,
        revision: UInt64,
        peekedLiveRefreshIdentity: String?
    ) async {
        if let datedSource = logSource as? any DiagnosticsDatedLogSource {
            if refreshDays || availableLogDays.isEmpty {
                let catalog = await datedSource.availableLogDayCatalog()
                guard revision == queryRevision else { return }
                switch catalog {
                case let .available(_, days):
                    availableLogDays = days
                    if isFollowingLatestDay {
                        selectedLogDay = days.first
                    } else if let selectedLogDay, days.contains(selectedLogDay) {
                        self.selectedLogDay = selectedLogDay
                    } else {
                        selectedLogDay = days.first
                        isFollowingLatestDay = true
                    }
                case .empty:
                    availableLogDays = []
                    selectedLogDay = nil
                    isFollowingLatestDay = true
                case .unavailable:
                    // 保留当前日期和可见内容；“暂不可读”绝不能变成无范围查询。
                    hasMorePages = false
                    isPartialWindow = false
                    pagingNotice = "日志正在轮转或回收，请刷新后查看当前记录。"
                    return
                }
            }
            await datedSource.selectLogDay(selectedLogDay)
            guard revision == queryRevision else { return }
        }
        let text = await logSource.loadLogText()
        guard revision == queryRevision else { return }
        let sourceHasMorePages: Bool
        let notice: String?
        let isPartial: Bool
        if let pagingSource = logSource as? any DiagnosticsLogPagingSource {
            sourceHasMorePages = await pagingSource.hasMoreLogPages()
            guard revision == queryRevision else { return }
            notice = await pagingSource.pagingNotice()
            guard revision == queryRevision else { return }
            isPartial = await pagingSource.isPartialLogWindow()
            guard revision == queryRevision else { return }
        } else {
            sourceHasMorePages = false
            notice = nil
            isPartial = false
        }

        lines = Self.lines(from: text)
        hasLoadedOlderPages = false
        hasMorePages = sourceHasMorePages
        pagingNotice = notice
        searchLimitNotice = nil
        isPartialWindow = isPartial
        // Skip 必须绑定触发本次解码的 peek，不能在 fence 释放后再采样盘面。
        lastLiveRefreshIdentity = peekedLiveRefreshIdentity
    }

    private func liveRefreshIdentity() async -> String? {
        guard let identifying = logSource as? any DiagnosticsLiveRefreshIdentifying else {
            return nil
        }
        return await identifying.liveRefreshIdentity()
    }

    private func invalidateSearchExpansion() {
        searchExpansionTask?.cancel()
    }

    private func isCurrentSearchExpansion(_ expansionID: UUID, revision: UInt64) -> Bool {
        !Task.isCancelled
            && searchExpansionID == expansionID
            && revision == queryRevision
            && isSearchPresented
    }

    private var searchBudgetAllowsAnotherLine: Bool {
        guard lines.count < searchMaximumRecordCount else {
            searchLimitNotice = "搜索已达到 10,000 条安全上限；请缩小条件后重新搜索。"
            return false
        }
        guard currentLineByteCount < searchMaximumByteCount else {
            searchLimitNotice = "搜索已达到 5 MiB 安全上限；请缩小条件后重新搜索。"
            return false
        }
        return true
    }

    private var currentLineByteCount: Int {
        lines.reduce(into: 0) { $0 += $1.utf8.count + 1 }
    }

    /// Returns true when at least one complete record was admitted. Partial
    /// records are never appended, so search/export always sees valid lines.
    private func appendSearchPageWithinBudget(_ text: String) -> SearchPageAdmission {
        var byteCount = currentLineByteCount
        var didAppend = false
        var reachedBudget = false
        for line in Self.lines(from: text) {
            guard lines.count < searchMaximumRecordCount else {
                searchLimitNotice = "搜索已达到 10,000 条安全上限；请缩小条件后重新搜索。"
                reachedBudget = true
                break
            }
            let lineByteCount = line.utf8.count + 1
            guard byteCount + lineByteCount <= searchMaximumByteCount else {
                searchLimitNotice = "搜索已达到 5 MiB 安全上限；请缩小条件后重新搜索。"
                reachedBudget = true
                break
            }
            lines.append(line)
            byteCount += lineByteCount
            didAppend = true
        }
        return SearchPageAdmission(didAppend: didAppend, reachedBudget: reachedBudget)
    }

    @discardableResult
    private func advanceQueryRevision() -> UInt64 {
        queryRevision = queryRevision == UInt64.max ? 1 : queryRevision + 1
        return queryRevision
    }

    private static func lines(from text: String?) -> [String] {
        guard let text else { return [] }
        return text.split(separator: "\n", omittingEmptySubsequences: true).map(String.init)
    }

    private func isSlowEvent(_ line: String) -> Bool {
        line.contains("SLOW ")
    }

    private func isWarning(_ line: String) -> Bool {
        line.contains("[WARN]") || line.contains("[ERROR]")
    }
}
