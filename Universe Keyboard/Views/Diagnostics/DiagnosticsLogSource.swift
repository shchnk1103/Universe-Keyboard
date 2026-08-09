import Foundation
import KeyboardCore

protocol DiagnosticsLogSource: Sendable {
    func loadLogText() async -> String?
    func clearLog() async
}

/// 只有 v1 journal 支持连续分页；legacy 文本只作为过渡期只读回退，因此不会
/// 被悄悄全量迁移或重新持久化。
protocol DiagnosticsLogPagingSource: DiagnosticsLogSource {
    func loadMoreLogText() async -> String?
    func hasMoreLogPages() async -> Bool
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

    func clearLog() async {
        let defaults = UserDefaults(suiteName: appGroupID)
        defaults?.removeObject(forKey: "rime_diag_log")
        defaults?.removeObject(forKey: "rime_diag_summary")
        defaults?.synchronize()
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
        if let journalText = await v1Source.loadLogText() {
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

    func clearLog() async {
        await v1Source.clearLog()
        await SharedDefaultsDiagnosticsLogSource(appGroupID: appGroupID).clearLog()
        activeSource = nil
    }
}

/// Main-App-only repository adapter. File enumeration and JSONL parsing stay in
/// `DiagnosticsJournalReader`; this type only obtains the App Group root and
/// formats already allowlisted events for the presentation layer.
private actor V1DiagnosticsLogSource: DiagnosticsLogPagingSource {
    let appGroupID: String
    private var reader: DiagnosticsJournalReader?
    private var nextCursor: DiagnosticsJournalPageCursor?

    init(appGroupID: String) {
        self.appGroupID = appGroupID
    }

    func loadLogText() async -> String? {
        guard let rootURL = journalRootURL() else { return nil }
        let reader = DiagnosticsJournalReader(rootURL: rootURL)
        guard let page = try? await reader.beginPage(), !page.events.isEmpty else {
            self.reader = nil
            nextCursor = nil
            return nil
        }
        self.reader = reader
        nextCursor = page.nextCursor
        return formattedText(for: page.events)
    }

    func loadMoreLogText() async -> String? {
        guard let reader, let nextCursor,
            let page = try? await reader.nextPage(after: nextCursor), !page.events.isEmpty
        else {
            self.nextCursor = nil
            return nil
        }
        self.nextCursor = page.nextCursor
        return formattedText(for: page.events)
    }

    func hasMoreLogPages() -> Bool {
        nextCursor != nil
    }

    func clearLog() async {
        guard let rootURL = journalRootURL() else { return }
        let writer = DiagnosticsJournalWriter(
            rootURL: rootURL,
            origin: .mainApp,
            isMainAppWriter: true
        )
        guard (try? await writer.prepareRootIfOwnedByMainApp()) != nil else { return }
        _ = try? await writer.advanceGenerationForClear()
        reader = nil
        nextCursor = nil
    }

    private func journalRootURL() -> URL? {
        FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: appGroupID)?
            .appendingPathComponent("Diagnostics/v1", isDirectory: true)
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
