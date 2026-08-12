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
    private var hasLoadedOlderPages = false
    var selectedSummaryFilter: SummaryFilter = .all
    var selectedCategory: Logger.Category?

    private let logSource: any DiagnosticsLogSource

    private var liveRefreshTask: Task<Void, Never>?

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
        Task {
            await replaceWithLatestPage()
        }
    }

    func startLiveRefresh() {
        guard liveRefreshTask == nil else { return }
        liveRefreshTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1))
                guard let self, !Task.isCancelled else { return }
                // 已展开更早历史时不重置冻结分页查询；用户可手动刷新以开始新快照。
                guard !self.hasLoadedOlderPages, !self.isClearing else { continue }
                await self.replaceWithLatestPage()
            }
        }
    }

    func stopLiveRefresh() {
        liveRefreshTask?.cancel()
        liveRefreshTask = nil
    }

    func refresh() {
        guard !isRefreshing, !isClearing else { return }
        isRefreshing = true
        clearFailureNotice = nil

        Task {
            try? await Task.sleep(for: .milliseconds(400))
            await replaceWithLatestPage()
            isRefreshing = false
        }
    }

    func performClear() {
        guard !isClearing else { return }
        isClearing = true
        clearFailureNotice = nil

        Task {
            try? await Task.sleep(for: .milliseconds(300))
            let result = await logSource.clearLog()
            if result == .cleared {
                lines = []
                hasMorePages = false
                hasLoadedOlderPages = false
                pagingNotice = nil
            } else {
                clearFailureNotice = "未能完整清空诊断日志，请稍后重试。现有记录可能仍然存在。"
            }
            isClearing = false
        }
    }

    func loadMore() {
        guard hasMorePages, !isLoadingMore, lines.count < Self.exportMaximumRecordCount else { return }
        guard let pagingSource = logSource as? any DiagnosticsLogPagingSource else {
            hasMorePages = false
            return
        }
        isLoadingMore = true
        Task {
            if let text = await pagingSource.loadMoreLogText() {
                let remainingCapacity = Self.exportMaximumRecordCount - lines.count
                lines.append(contentsOf: Self.lines(from: text).prefix(remainingCapacity))
                hasLoadedOlderPages = true
            }
            hasMorePages =
                await pagingSource.hasMoreLogPages()
                && lines.count < Self.exportMaximumRecordCount
            pagingNotice = await pagingSource.pagingNotice()
            isLoadingMore = false
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

    private func replaceWithLatestPage() async {
        lines = Self.lines(from: await logSource.loadLogText())
        hasLoadedOlderPages = false
        if let pagingSource = logSource as? any DiagnosticsLogPagingSource {
            hasMorePages = await pagingSource.hasMoreLogPages()
            pagingNotice = await pagingSource.pagingNotice()
        } else {
            hasMorePages = false
            pagingNotice = nil
        }
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
