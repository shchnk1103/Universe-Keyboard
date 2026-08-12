import Foundation
import KeyboardCore

nonisolated enum DiagnosticsLogClearResult: Equatable, Sendable {
    case cleared
    case failed
}

protocol DiagnosticsLogSource: Sendable {
    func loadLogText() async -> String?
    func clearLog() async -> DiagnosticsLogClearResult
}

/// 只有 v1 journal 支持连续分页；legacy 文本只作为过渡期只读回退，因此不会
/// 被悄悄全量迁移或重新持久化。
protocol DiagnosticsLogPagingSource: DiagnosticsLogSource {
    func loadMoreLogText() async -> String?
    func hasMoreLogPages() async -> Bool
    func pagingNotice() async -> String?
}

struct SharedDefaultsDiagnosticsLogSource: DiagnosticsLogSource {
    let appGroupID: String

    func loadLogText() async -> String? {
        let defaults = UserDefaults(suiteName: appGroupID)
        guard let log = defaults?.string(forKey: "rime_diag_log"), !log.isEmpty else { return nil }
        // 统一让诊断页以“最新优先”展示，避免 legacy 与 v1 的视觉顺序不同。
        return
            log
            .split(separator: "\n", omittingEmptySubsequences: true)
            .reversed()
            .joined(separator: "\n")
    }

    func clearLog() async -> DiagnosticsLogClearResult {
        guard let defaults = UserDefaults(suiteName: appGroupID) else { return .failed }
        defaults.removeObject(forKey: "rime_diag_log")
        defaults.removeObject(forKey: "rime_diag_summary")
        defaults.synchronize()
        guard
            defaults.object(forKey: "rime_diag_log") == nil,
            defaults.object(forKey: "rime_diag_summary") == nil
        else {
            return .failed
        }
        return .cleared
    }
}

/// 迁移期间优先展示 v1 journal；尚未迁移的旧自由文本日志仅作为只读回退，
/// 绝不重新编码或写入 v1。
actor CompositeDiagnosticsLogSource: DiagnosticsLogPagingSource {
    private enum ActiveSource {
        case v1
        case legacy
    }

    let appGroupID: String
    private let v1Source: V1DiagnosticsLogSource
    private var activeSource: ActiveSource?

    init(appGroupID: String) {
        self.appGroupID = appGroupID
        v1Source = V1DiagnosticsLogSource(appGroupID: appGroupID)
    }

    func loadLogText() async -> String? {
        let journalText = await v1Source.loadLogText()
        let usedV1Result = await v1Source.didUseV1Result()
        if journalText != nil || usedV1Result {
            activeSource = .v1
            return journalText
        }
        activeSource = .legacy
        return await SharedDefaultsDiagnosticsLogSource(appGroupID: appGroupID).loadLogText()
    }

    func loadMoreLogText() async -> String? {
        guard case .v1? = activeSource else { return nil }
        return await v1Source.loadMoreLogText()
    }

    func hasMoreLogPages() async -> Bool {
        guard case .v1? = activeSource else { return false }
        return await v1Source.hasMoreLogPages()
    }

    func pagingNotice() async -> String? {
        guard case .v1? = activeSource else { return nil }
        return await v1Source.pagingNotice()
    }

    func clearLog() async -> DiagnosticsLogClearResult {
        let v1Result = await v1Source.clearLog()
        let legacyResult = await SharedDefaultsDiagnosticsLogSource(appGroupID: appGroupID).clearLog()
        guard v1Result == .cleared, legacyResult == .cleared else { return .failed }
        activeSource = nil
        return .cleared
    }
}

/// Main-App-only repository adapter. File enumeration and JSONL parsing stay in
/// `DiagnosticsJournalReader`; this type only obtains the App Group root and
/// formats already allowlisted events for the presentation layer.
actor V1DiagnosticsLogSource: DiagnosticsLogPagingSource {
    let appGroupID: String
    private let rootURLProvider: @Sendable () -> URL?
    private var reader: DiagnosticsJournalReader?
    private var nextCursor: DiagnosticsJournalPageCursor?
    private var lastPageStatus: DiagnosticsJournalPageStatus = .completed
    private var usedV1Result = false

    init(
        appGroupID: String,
        rootURLProvider: (@Sendable () -> URL?)? = nil
    ) {
        self.appGroupID = appGroupID
        if let rootURLProvider {
            self.rootURLProvider = rootURLProvider
        } else {
            self.rootURLProvider = {
                FileManager.default
                    .containerURL(forSecurityApplicationGroupIdentifier: appGroupID)?
                    .appendingPathComponent("Diagnostics/v1", isDirectory: true)
            }
        }
    }

    func loadLogText() async -> String? {
        usedV1Result = false
        guard let rootURL = journalRootURL() else {
            reader = nil
            nextCursor = nil
            lastPageStatus = .journalUnavailable
            // App Group 不可用不是“v1 正常为空”。保持在 v1 视图可避免将
            // 无法验证来源的 legacy 自由文本悄悄混入当前诊断结果。
            usedV1Result = true
            return nil
        }
        // 诊断页刷新只投递受控 cadence；scheduler 在 utility task 内完成 reclaim，
        // 不阻塞本次 v1 查询，更不会进入 Keyboard Extension 热路径。
        _ = await DiagnosticsJournalRetentionScheduler.shared.requestReclaim(rootURL: rootURL)
        let reader = DiagnosticsJournalReader(rootURL: rootURL)
        let page: DiagnosticsJournalPage
        do {
            page = try await reader.beginPage()
        } catch {
            self.reader = nil
            nextCursor = nil
            lastPageStatus = .journalUnavailable
            usedV1Result = true
            return nil
        }
        lastPageStatus = page.status
        // 空的正常 v1 journal 仍应允许 legacy 只读回退；只有 v1 实际有事件，
        // 或它明确报告受控 failure/invalidation 时，才由 v1 占据诊断视图。
        usedV1Result = !page.events.isEmpty || page.status != .completed
        guard !page.events.isEmpty else {
            self.reader = nil
            nextCursor = nil
            return nil
        }
        self.reader = reader
        nextCursor = page.nextCursor
        return formattedText(for: page.events)
    }

    func loadMoreLogText() async -> String? {
        guard let reader, let nextCursor else {
            self.nextCursor = nil
            return nil
        }
        let page: DiagnosticsJournalPage
        do {
            page = try await reader.nextPage(after: nextCursor)
        } catch {
            self.nextCursor = nil
            lastPageStatus = .journalUnavailable
            usedV1Result = true
            return nil
        }
        lastPageStatus = page.status
        self.nextCursor = page.nextCursor
        guard !page.events.isEmpty else { return nil }
        return formattedText(for: page.events)
    }

    func hasMoreLogPages() -> Bool {
        nextCursor != nil
    }

    func pagingNotice() -> String? {
        switch lastPageStatus {
        case .hasMore, .completed:
            nil
        case .invalidatedByGeneration:
            "日志已清空，请刷新后查看当前记录。"
        case .invalidatedByReclaim:
            "日志已被自动回收，请刷新后继续查看。"
        case .cursorUnavailable:
            "日志分页已失效，请刷新后继续查看。"
        case .snapshotExceedsReadBudget:
            "当前日志快照过大，无法在安全读取上限内严格排序；请使用右上角垃圾桶清空后重新记录。"
        case .snapshotExceedsEventBudget:
            "当前日志快照超过安全事件上限；请使用右上角垃圾桶清空后重新记录。"
        case .snapshotUnavailable:
            "日志正在轮转或回收，请刷新后查看当前记录。"
        case .journalUnavailable:
            "诊断日志暂时不可用；旧日志不会在此状态下自动混入当前视图。"
        }
    }

    func didUseV1Result() -> Bool {
        usedV1Result
    }

    func clearLog() async -> DiagnosticsLogClearResult {
        guard let rootURL = journalRootURL() else { return .failed }
        let writer = DiagnosticsJournalWriter(
            rootURL: rootURL,
            origin: .mainApp,
            isMainAppWriter: true
        )
        do {
            try await writer.prepareRootIfOwnedByMainApp()
            _ = try await writer.advanceGenerationForClear()
        } catch {
            return .failed
        }
        reader = nil
        nextCursor = nil
        lastPageStatus = .completed
        usedV1Result = false
        return .cleared
    }

    private func journalRootURL() -> URL? {
        rootURLProvider()
    }

    private func formattedText(for events: [DiagnosticEvent]) -> String {
        events.map(DiagnosticsEventDisplayFormatter.line).joined(separator: "\n")
    }
}

private enum DiagnosticsEventDisplayFormatter {
    nonisolated static func line(_ event: DiagnosticEvent) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSS"
        let timestamp = formatter.string(from: event.utcTimestamp)
        let fields = event.fields.map(fieldDescription).joined(separator: " ")
        let suffix = fields.isEmpty ? "" : " \(fields)"
        return "[\(timestamp)] [\(event.level.rawValue)] [\(event.category.rawValue)] \(event.code.rawValue)\(suffix)"
    }

    private nonisolated static func fieldDescription(_ field: DiagnosticEvent.Field) -> String {
        switch field {
        case let .count(name, value):
            return "\(name.rawValue)=\(value)"
        case let .duration(name, value):
            return "\(name.rawValue)=\(value)"
        case let .flag(name, value):
            return "\(name.rawValue)=\(value)"
        case let .reason(reason):
            return "reason=\(reason.rawValue)"
        }
    }
}
