import Foundation
import KeyboardCore
import Observation

@MainActor
@Observable
final class DiagnosticsStore {
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
    var isRefreshing = false
    var isClearing = false
    var selectedSummaryFilter: SummaryFilter = .all
    var selectedCategory: Logger.Category?

    private let logSource: any DiagnosticsLogSource

    init(logSource: any DiagnosticsLogSource = SharedDefaultsDiagnosticsLogSource(appGroupID: universeAppGroupID)) {
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

        guard let category = selectedCategory else { return scopedLines }
        let tag = "[\(category.rawValue)]"
        return scopedLines.filter { $0.contains(tag) }
    }

    var displayedLines: [String] {
        Array(filteredLines.reversed())
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
        filteredLines.joined(separator: "\n")
    }

    func loadLog() {
        Task {
            lines = await currentLines()
        }
    }

    func refresh() {
        guard !isRefreshing else { return }
        isRefreshing = true

        Task {
            try? await Task.sleep(for: .milliseconds(400))
            lines = await currentLines()
            isRefreshing = false
        }
    }

    func performClear() {
        guard !isClearing else { return }
        isClearing = true

        Task {
            try? await Task.sleep(for: .milliseconds(300))
            await logSource.clearLog()
            lines = []
            isClearing = false
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

    private func currentLines() async -> [String] {
        guard let log = await logSource.loadLogText() else { return [] }
        return log.components(separatedBy: "\n")
    }

    private func isSlowEvent(_ line: String) -> Bool {
        line.contains("SLOW ")
    }

    private func isWarning(_ line: String) -> Bool {
        line.contains("[WARN]") || line.contains("[ERROR]")
    }
}
