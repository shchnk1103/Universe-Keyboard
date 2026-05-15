import Foundation

/// 将键盘中的 RIME 运行状态写入共享 UserDefaults，供主 App 诊断显示。
struct RimeDiagnostics {
    private let appGroupID = "group.com.DoubleShy0N.Universe-Keyboard"
    private var lines: [String] = []

    mutating func log(_ message: String) {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        let timestamp = formatter.string(from: Date())
        lines.append("[\(timestamp)] \(message)")
        print("[RimeDiag] \(message)")
    }

    func save() {
        guard let defaults = UserDefaults(suiteName: appGroupID) else { return }
        // 追加到已有日志（RimeEngineImpl.init() 可能已经写入了版本/schema 信息）
        var allLines = defaults.string(forKey: "rime_diag_log")?.components(separatedBy: "\n") ?? []
        allLines.append(contentsOf: lines)
        defaults.set(allLines.joined(separator: "\n"), forKey: "rime_diag_log")
        defaults.set(lines.last ?? "", forKey: "rime_diag_summary")
        defaults.synchronize()
    }
}
