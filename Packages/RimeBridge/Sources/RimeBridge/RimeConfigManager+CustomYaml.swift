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
        // Keep t9 compiled and selectable when fog-song is installed/active.
        // Layout mode selects t9 at runtime; do not store t9 as base active schema.
        var defaultYaml = "patch:\n  schema_list:\n    - schema: \(activeSchema)\n"
        if activeSchema == "rime_ice" || (defs?.bool(forKey: "rime_ice_installed") ?? false) {
            if activeSchema != "t9" {
                defaultYaml += "    - schema: t9\n"
            }
            if activeSchema != "rime_ice" {
                defaultYaml += "    - schema: rime_ice\n"
            }
        }
        if pageSize >= 5 {
            defaultYaml += "  \"menu/page_size\": \(pageSize)\n"
        }
        try? defaultYaml.write(
            to: userDir.appendingPathComponent("default.custom.yaml"), atomically: true, encoding: .utf8)
        Logger.shared.info(
            "Synced default.custom.yaml (activeSchema=\(activeSchema), page_size=\(pageSize))",
            category: .config
        )

        // {schema}.custom.yaml — schema-specific preferences.
        //
        // User dictionary learning is intentionally written for both built-in
        // pinyin schemas so switching schemes does not silently lose the user's
        // selected learning policy. T9 uses the fog-song dictionary preference.
        var simplification: Bool?
        if defs?.object(forKey: "rime_simplification") != nil {
            simplification = defs?.bool(forKey: "rime_simplification") ?? true
        }
        let userDictionarySettings = RimeUserDictionarySettings(
            lunaPinyinEnabled: defs?.object(
                forKey: RimeUserDictionarySettings.lunaPinyinEnabledKey
            ) as? Bool ?? true,
            rimeIceEnabled: defs?.object(
                forKey: RimeUserDictionarySettings.rimeIceEnabledKey
            ) as? Bool ?? true
        )
        let iceInstalled = defs?.bool(forKey: "rime_ice_installed") ?? false
        let plan = planSchemaCustomYamlFiles(
            rimeIceInstalled: iceInstalled,
            simplificationEnabled: simplification,
            userDictionarySettings: userDictionarySettings
        )
        for file in plan {
            try? file.content.write(
                to: userDir.appendingPathComponent(file.filename),
                atomically: true,
                encoding: .utf8
            )
            Logger.shared.info("Synced \(file.filename) user dictionary settings", category: .config)
        }
    }

    /// One planned `{schema}.custom.yaml` write for production sync / tests.
    public struct SchemaCustomYamlFile: Equatable, Sendable {
        public let schemaID: String
        public let filename: String
        public let content: String
        /// Schema ID used to resolve user-dictionary preference (`rime_ice` for `t9`).
        public let userDictionarySchemaID: String
    }

    /// Pure production plan: which custom YAML files to write and with which content.
    ///
    /// - `luna_pinyin` and `rime_ice` always planned.
    /// - `t9.custom.yaml` only when fog-song is installed, using **rime_ice** user-dict preference.
    public static func planSchemaCustomYamlFiles(
        rimeIceInstalled: Bool,
        simplificationEnabled: Bool?,
        userDictionarySettings: RimeUserDictionarySettings
    ) -> [SchemaCustomYamlFile] {
        var targets: [(schemaID: String, dictSchemaID: String)] = [
            ("luna_pinyin", "luna_pinyin"),
            ("rime_ice", "rime_ice"),
        ]
        if rimeIceInstalled {
            // T9 is the nine-key presentation of fog-song preferences, not a separate base scheme.
            targets.append(("t9", "rime_ice"))
        }

        var files: [SchemaCustomYamlFile] = []
        for target in targets {
            let enabled = userDictionarySettings.isEnabled(for: target.dictSchemaID)
            guard let content = makeSchemaCustomYamlContent(
                simplificationEnabled: simplificationEnabled,
                userDictionaryEnabled: enabled
            ) else { continue }
            files.append(
                SchemaCustomYamlFile(
                    schemaID: target.schemaID,
                    filename: "\(target.schemaID).custom.yaml",
                    content: content,
                    userDictionarySchemaID: target.dictSchemaID
                )
            )
        }
        return files
    }

    /// Pure helper for tests: builds schema custom YAML from preference values.
    public static func makeSchemaCustomYamlContent(
        simplificationEnabled: Bool?,
        userDictionaryEnabled: Bool
    ) -> String? {
        var patch: [(String, String)] = []
        if let simplificationEnabled {
            let reset = simplificationEnabled ? 1 : 0
            patch.append(("\"switches/@1/reset\"", "\(reset)"))
        }
        patch.append((
            "\"translator/enable_user_dict\"",
            userDictionaryEnabled ? "true" : "false"
        ))
        guard !patch.isEmpty else { return nil }
        var yaml = "patch:\n"
        for (key, value) in patch {
            yaml += "  \(key): \(value)\n"
        }
        return yaml
    }
}
