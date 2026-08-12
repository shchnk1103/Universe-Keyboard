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
    var isClearing = false
    var isLoadingMore = false
    var hasMorePages = false
    var pagingNotice: String?
    var clearFailureNotice: String?
    var isPartialWindow = false
    var availableLogDays: [DiagnosticsLogDay] = []
    var selectedLogDay: DiagnosticsLogDay?
    private var hasLoadedOlderPages = false
    private var isFollowingLatestDay = true
    var selectedSummaryFilter: SummaryFilter = .all
    var selectedCategory: Logger.Category?

    private let logSource: any DiagnosticsLogSource

    private var liveRefreshTask: Task<Void, Never>?
    private var queryRevision: UInt64 = 0

    init(logSource: any DiagnosticsLogSource = CompositeDiagnosticsLogSource(appGroupID: universeAppGroupID)) {
        self.logSource = logSource
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
        !isClearing && (!lines.isEmpty || pagingNotice != nil || clearFailureNotice != nil)
    }

    var displayedNotice: String? {
        clearFailureNotice ?? pagingNotice
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
        let revision = advanceQueryRevision()
        isRefreshing = true
        isLoadingMore = false
        Task {
            await replaceWithLatestPage(refreshDays: true, revision: revision)
            guard revision == queryRevision else { return }
            isRefreshing = false
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
    }

    func refresh() {
        guard !isRefreshing, !isClearing, !isLoadingMore else { return }
        let revision = advanceQueryRevision()
        isRefreshing = true
        clearFailureNotice = nil

        Task {
            try? await Task.sleep(for: .milliseconds(400))
            guard revision == queryRevision else { return }
            await replaceWithLatestPage(refreshDays: true, revision: revision)
            guard revision == queryRevision else { return }
            isRefreshing = false
        }
    }

    func performClear() {
        guard !isClearing else { return }
        let revision = advanceQueryRevision()
        isClearing = true
        isRefreshing = false
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
                availableLogDays = []
                selectedLogDay = nil
                isPartialWindow = false
                isFollowingLatestDay = true
            } else {
                clearFailureNotice = "未能完整清空诊断日志，请稍后重试。现有记录可能仍然存在。"
            }
            isClearing = false
        }
    }

    func loadMore() {
        guard
            hasMorePages,
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
        let revision = advanceQueryRevision()
        // 日期选择是新的根查询，可以主动废弃尚未完成的旧页，而不是吞掉用户点击。
        isLoadingMore = false
        selectedLogDay = day
        isFollowingLatestDay = day == availableLogDays.first
        isRefreshing = true
        clearFailureNotice = nil
        Task {
            await replaceWithLatestPage(refreshDays: false, revision: revision)
            guard revision == queryRevision else { return }
            isRefreshing = false
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
            !isClearing,
            !isRefreshing,
            !isLoadingMore
        else { return }
        let revision = queryRevision
        await replaceWithLatestPage(refreshDays: true, revision: revision)
    }

    private func replaceWithLatestPage(refreshDays: Bool, revision: UInt64) async {
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
        isPartialWindow = isPartial
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
