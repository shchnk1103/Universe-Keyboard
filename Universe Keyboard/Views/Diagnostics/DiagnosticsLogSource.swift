import Foundation

protocol DiagnosticsLogSource: Sendable {
    func loadLogText() async -> String?
    func clearLog() async
}

struct SharedDefaultsDiagnosticsLogSource: DiagnosticsLogSource {
    let appGroupID: String

    func loadLogText() async -> String? {
        let defaults = UserDefaults(suiteName: appGroupID)
        guard let log = defaults?.string(forKey: "rime_diag_log"), !log.isEmpty else { return nil }
        return log
    }

    func clearLog() async {
        let defaults = UserDefaults(suiteName: appGroupID)
        defaults?.removeObject(forKey: "rime_diag_log")
        defaults?.removeObject(forKey: "rime_diag_summary")
        defaults?.synchronize()
    }
}
