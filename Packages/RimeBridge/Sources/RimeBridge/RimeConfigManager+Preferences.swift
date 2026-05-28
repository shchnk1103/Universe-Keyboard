import Foundation
import KeyboardCore

private let preferencesAppGroupID = "group.com.DoubleShy0N.Universe-Keyboard"

extension RimeConfigManager {
    // MARK: - Configuration UI helpers (called by main app via UserDefaults)

    private static var defaults: UserDefaults? {
        UserDefaults(suiteName: preferencesAppGroupID)
    }

    /// 获取当前候选数量。默认 9。
    static func currentPageSize() -> Int {
        let val = defaults?.integer(forKey: "rime_page_size") ?? 0
        return val > 0 ? val : 9
    }

    /// 设置候选数量（5-20）。写入 default.custom.yaml。
    static func setPageSize(_ value: Int) {
        let clamped = max(5, min(20, value))
        defaults?.set(clamped, forKey: "rime_page_size")
        writeCustomYaml(
            filename: "default.custom.yaml",
            patch: [
                "\"menu/page_size\"": clamped
            ])
        requestDeploy()
    }

    /// 获取默认简繁状态。true = 简体。
    static func currentSimplification() -> Bool {
        if defaults?.object(forKey: "rime_simplification") == nil {
            return true  // 默认简体
        }
        return defaults?.bool(forKey: "rime_simplification") ?? true
    }

    /// 设置默认简繁。true = 简体（reset=1），false = 繁体（reset=0）。
    static func setSimplification(_ simplified: Bool) {
        defaults?.set(simplified, forKey: "rime_simplification")
        writeCustomYaml(
            filename: "luna_pinyin.custom.yaml",
            patch: [
                "\"switches/@1/reset\"": simplified ? 1 : 0
            ])
        requestDeploy()
    }

    /// 设置部署标记；完整部署必须由主 App 显式执行。
    static func requestDeploy() {
        defaults?.set(false, forKey: "rime_deployed")
        defaults?.set(true, forKey: "rime_needs_deploy")
        defaults?.synchronize()
        Logger.shared.info("Deploy requested — rime_needs_deploy set", category: .config)
    }

    /// 将 patch 字典写入 user_data_dir 下的 .custom.yaml 文件。
    private static func writeCustomYaml(filename: String, patch: [String: Any]) {
        guard
            let containerURL = FileManager.default.containerURL(
                forSecurityApplicationGroupIdentifier: preferencesAppGroupID
            )
        else { return }

        let userDir = containerURL.appendingPathComponent("Rime/user")
        try? FileManager.default.createDirectory(at: userDir, withIntermediateDirectories: true)

        var yaml = "patch:\n"
        for (key, value) in patch {
            if let intVal = value as? Int {
                yaml += "  \(key): \(intVal)\n"
            } else if let boolVal = value as? Bool {
                yaml += "  \(key): \(boolVal)\n"
            } else if let strVal = value as? String {
                yaml += "  \(key): \(strVal)\n"
            }
        }

        let fileURL = userDir.appendingPathComponent(filename)
        try? yaml.write(to: fileURL, atomically: true, encoding: .utf8)
        Logger.shared.info("Wrote \(filename): \(yaml.replacingOccurrences(of: "\n", with: " "))", category: .config)
    }
}
