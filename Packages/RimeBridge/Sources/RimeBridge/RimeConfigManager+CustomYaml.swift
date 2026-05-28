import Foundation
import KeyboardCore

private let customYamlAppGroupID = "group.com.DoubleShy0N.Universe-Keyboard"

extension RimeConfigManager {
    /// 从 UserDefaults 读取配置并生成 .custom.yaml 文件到 user_data_dir。
    /// 在部署前调用，确保用户通过主 App 修改的配置被写入。
    public static func syncCustomYamlFiles() {
        guard
            let containerURL = FileManager.default.containerURL(
                forSecurityApplicationGroupIdentifier: customYamlAppGroupID
            )
        else { return }

        let userDir = containerURL.appendingPathComponent("Rime/user")
        try? FileManager.default.createDirectory(at: userDir, withIntermediateDirectories: true)

        let defs = UserDefaults(suiteName: customYamlAppGroupID)
        let activeSchema = defs?.string(forKey: "rime_active_schema") ?? "luna_pinyin"

        // default.custom.yaml — active schema and candidate page size.
        // The app writes this before full deployment so the keyboard only consumes compiled results.
        let pageSize = defs?.integer(forKey: "rime_page_size") ?? 0
        var defaultYaml = "patch:\n  schema_list:\n    - schema: \(activeSchema)\n"
        if pageSize >= 5 {
            defaultYaml += "  \"menu/page_size\": \(pageSize)\n"
        }
        try? defaultYaml.write(
            to: userDir.appendingPathComponent("default.custom.yaml"), atomically: true, encoding: .utf8)
        Logger.shared.info(
            "Synced default.custom.yaml (activeSchema=\(activeSchema), page_size=\(pageSize))",
            category: .config
        )

        // {schema}.custom.yaml — 简繁（schema-specific）
        if defs?.object(forKey: "rime_simplification") != nil {
            let simplified = defs?.bool(forKey: "rime_simplification") ?? true
            let reset = simplified ? 1 : 0
            let yaml = "patch:\n  \"switches/@1/reset\": \(reset)\n"
            let filename = "\(activeSchema).custom.yaml"
            try? yaml.write(to: userDir.appendingPathComponent(filename), atomically: true, encoding: .utf8)
            Logger.shared.info("Synced \(filename) (simplification.reset=\(reset))", category: .config)
        }
    }
}
