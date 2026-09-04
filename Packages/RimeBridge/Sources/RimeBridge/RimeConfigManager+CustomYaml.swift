import Foundation
import KeyboardCore

private let customYamlAppGroupID = "group.com.DoubleShy0N.Universe-Keyboard"

extension RimeConfigManager {
    /// 从 App Group 的 UserDefaults 读取配置并生成 .custom.yaml 文件到 user_data_dir。
    /// 在部署前调用，确保用户通过主 App 修改的配置被写入。
    @discardableResult
    public static func syncCustomYamlFiles() -> Bool {
        guard
            let containerURL = FileManager.default.containerURL(
                forSecurityApplicationGroupIdentifier: customYamlAppGroupID
            )
        else { return false }

        let rimeRoot = containerURL.appendingPathComponent("Rime", isDirectory: true)
        return syncCustomYamlFiles(
            defaults: UserDefaults(suiteName: customYamlAppGroupID),
            rimeRoot: rimeRoot
        )
    }

    /// 生产同步的可测试实现：defaults 与 rimeRoot 由调用方注入。
    @discardableResult
    static func syncCustomYamlFiles(defaults: UserDefaults?, rimeRoot: URL) -> Bool {
        let activeSchema = defaults?.string(forKey: "rime_active_schema") ?? "luna_pinyin"

        // default.custom.yaml — active schema and candidate page size.
        // The app writes this before full deployment so the keyboard only consumes compiled results.
        let pageSize = defaults?.integer(forKey: "rime_page_size") ?? 0
        // Keep t9 compiled and selectable when fog-song is installed/active.
        // Layout mode selects t9 at runtime; do not store t9 as base active schema.
        var defaultYaml = "patch:\n  schema_list:\n    - schema: \(activeSchema)\n"
        var listed = Set([activeSchema])
        func appendSchema(_ id: String) {
            guard !listed.contains(id) else { return }
            defaultYaml += "    - schema: \(id)\n"
            listed.insert(id)
        }
        // Fog-song family: keep t9 + rime_ice compiled when installed (layout-bound select).
        if activeSchema == "rime_ice" || (defaults?.bool(forKey: "rime_ice_installed") ?? false) {
            appendSchema("t9")
            appendSchema("rime_ice")
        }
        // 万象拼音（全拼）when installed — ADR 0026 / PD-RIME-SCHEME-WANXIANG-001.
        if activeSchema == "wanxiang" || (defaults?.bool(forKey: "wanxiang_installed") ?? false) {
            appendSchema("wanxiang")
        }
        if pageSize >= 5 {
            defaultYaml += "  \"menu/page_size\": \(pageSize)\n"
        }
        var artifacts = [
            CustomYamlArtifact(filename: "default.custom.yaml", content: defaultYaml)
        ]

        // {schema}.custom.yaml — schema-specific preferences.
        //
        // User dictionary learning is intentionally written for both built-in
        // pinyin schemas so switching schemes does not silently lose the user's
        // selected learning policy. T9 uses the fog-song dictionary preference.
        // 简繁 key 缺失时按产品默认简体写 reset=1，与设置页读取逻辑保持一致。
        let simplificationEnabled = simplificationPreference(from: defaults)
        let userDictionarySettings = RimeUserDictionarySettings(
            lunaPinyinEnabled: defaults?.object(
                forKey: RimeUserDictionarySettings.lunaPinyinEnabledKey
            ) as? Bool ?? true,
            rimeIceEnabled: defaults?.object(
                forKey: RimeUserDictionarySettings.rimeIceEnabledKey
            ) as? Bool ?? true
        )
        let iceInstalled = defaults?.bool(forKey: "rime_ice_installed") ?? false
        let wanxiangInstalled = defaults?.bool(forKey: "wanxiang_installed") ?? false
        let fuzzySettings = RimeFuzzyPinyinSettings(
            enabled: defaults?.object(forKey: RimeFuzzyPinyinSettings.enabledKey) as? Bool ?? false,
            zhZEnabled: defaults?.object(forKey: RimeFuzzyPinyinSettings.zhZKey) as? Bool ?? true,
            chCEnabled: defaults?.object(forKey: RimeFuzzyPinyinSettings.chCKey) as? Bool ?? true,
            shSEnabled: defaults?.object(forKey: RimeFuzzyPinyinSettings.shSKey) as? Bool ?? true,
            nLEnabled: defaults?.object(forKey: RimeFuzzyPinyinSettings.nLKey) as? Bool ?? true
        )
        let plan = planSchemaCustomYamlFiles(
            rimeIceInstalled: iceInstalled,
            wanxiangInstalled: wanxiangInstalled,
            simplificationEnabled: simplificationEnabled,
            userDictionarySettings: userDictionarySettings,
            fuzzyPinyinSettings: fuzzySettings
        )
        artifacts.append(
            contentsOf: plan.map {
                CustomYamlArtifact(filename: $0.filename, content: $0.content)
            })
        do {
            try replaceCustomYamlArtifacts(
                artifacts,
                rimeRoot: rimeRoot,
            )
            Logger.shared.info(
                "Synced RIME custom YAML files count=\(artifacts.count) "
                    + "activeSchema=\(activeSchema) pageSize=\(pageSize)",
                category: .config
            )
            return true
        } catch {
            Logger.shared.error("Failed to commit RIME custom YAML generation", category: .config)
            return false
        }
    }

    struct CustomYamlArtifact: Equatable, Sendable {
        let filename: String
        let content: String
    }

    enum CustomYamlTransactionError: Error, Equatable {
        case invalidArtifactSet
        case rollbackFailed
    }

    /// Commits the overlay files and their authorization receipt as one
    /// recoverable transaction. A normal write failure restores the previous
    /// coherent files and receipt; process death remains governed by ADR 0006.
    static func replaceCustomYamlArtifacts(
        _ artifacts: [CustomYamlArtifact],
        rimeRoot: URL,
        beforeReplacing: ((String) throws -> Void)? = nil
    ) throws {
        let filenames = artifacts.map(\.filename)
        guard
            !artifacts.isEmpty,
            Set(filenames).count == artifacts.count,
            filenames.allSatisfy({ !$0.isEmpty && ($0 as NSString).lastPathComponent == $0 })
        else {
            throw CustomYamlTransactionError.invalidArtifactSet
        }

        let fileManager = FileManager.default
        let userDir = rimeRoot.appendingPathComponent("user", isDirectory: true)
        let transactionRoot = rimeRoot.appendingPathComponent(
            ".builtin-overlay-transaction-\(UUID().uuidString)",
            isDirectory: true
        )
        let stagedDir = transactionRoot.appendingPathComponent("staged", isDirectory: true)
        let backupDir = transactionRoot.appendingPathComponent("backup", isDirectory: true)
        let receiptName = RimeBuiltinResourceInstaller.overlayReceiptFileName
        let receiptURL = rimeRoot.appendingPathComponent(receiptName)
        defer { try? fileManager.removeItem(at: transactionRoot) }

        try fileManager.createDirectory(at: userDir, withIntermediateDirectories: true)
        try fileManager.createDirectory(at: stagedDir, withIntermediateDirectories: true)
        try fileManager.createDirectory(at: backupDir, withIntermediateDirectories: true)
        for artifact in artifacts {
            try artifact.content.write(
                to: stagedDir.appendingPathComponent(artifact.filename),
                atomically: true,
                encoding: .utf8
            )
        }
        for filename in filenames {
            let current = userDir.appendingPathComponent(filename)
            if fileManager.fileExists(atPath: current.path) {
                try fileManager.copyItem(at: current, to: backupDir.appendingPathComponent(filename))
            }
        }
        if fileManager.fileExists(atPath: receiptURL.path) {
            try fileManager.copyItem(at: receiptURL, to: backupDir.appendingPathComponent(receiptName))
        }

        do {
            if fileManager.fileExists(atPath: receiptURL.path) {
                try fileManager.removeItem(at: receiptURL)
            }
            for artifact in artifacts {
                try beforeReplacing?(artifact.filename)
                let destination = userDir.appendingPathComponent(artifact.filename)
                if fileManager.fileExists(atPath: destination.path) {
                    try fileManager.removeItem(at: destination)
                }
                try fileManager.moveItem(
                    at: stagedDir.appendingPathComponent(artifact.filename),
                    to: destination
                )
            }
            try RimeBuiltinResourceInstaller().recordOverlayReceipt(
                rimeRoot: rimeRoot,
                userDataURL: userDir
            )
        } catch {
            do {
                for filename in filenames {
                    let destination = userDir.appendingPathComponent(filename)
                    if fileManager.fileExists(atPath: destination.path) {
                        try fileManager.removeItem(at: destination)
                    }
                    let backup = backupDir.appendingPathComponent(filename)
                    if fileManager.fileExists(atPath: backup.path) {
                        try fileManager.copyItem(at: backup, to: destination)
                    }
                }
                if fileManager.fileExists(atPath: receiptURL.path) {
                    try fileManager.removeItem(at: receiptURL)
                }
                let receiptBackup = backupDir.appendingPathComponent(receiptName)
                if fileManager.fileExists(atPath: receiptBackup.path) {
                    try fileManager.copyItem(at: receiptBackup, to: receiptURL)
                }
            } catch {
                throw CustomYamlTransactionError.rollbackFailed
            }
            throw error
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
    /// - `wanxiang.custom.yaml` when 万象 is installed (uses rime_ice learning toggle as conservative default).
    public static func planSchemaCustomYamlFiles(
        rimeIceInstalled: Bool,
        wanxiangInstalled: Bool = false,
        simplificationEnabled: Bool?,
        userDictionarySettings: RimeUserDictionarySettings,
        fuzzyPinyinSettings: RimeFuzzyPinyinSettings = RimeFuzzyPinyinSettings(enabled: false)
    ) -> [SchemaCustomYamlFile] {
        var targets: [(schemaID: String, dictSchemaID: String)] = [
            ("luna_pinyin", "luna_pinyin"),
            ("rime_ice", "rime_ice"),
        ]
        if wanxiangInstalled {
            targets.append(("wanxiang", "rime_ice"))
        }
        if rimeIceInstalled {
            // T9 is the nine-key presentation of fog-song preferences, not a separate base scheme.
            targets.append(("t9", "rime_ice"))
        }

        var files: [SchemaCustomYamlFile] = []
        for target in targets {
            let enabled = userDictionarySettings.isEnabled(for: target.dictSchemaID)
            guard
                let content = makeSchemaCustomYamlContent(
                    schemaID: target.schemaID,
                    simplificationEnabled: simplificationEnabled,
                    userDictionaryEnabled: enabled,
                    fuzzyPinyinSettings: fuzzyPinyinSettings
                )
            else { continue }
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
        makeSchemaCustomYamlContent(
            schemaID: "rime_ice",
            simplificationEnabled: simplificationEnabled,
            userDictionaryEnabled: userDictionaryEnabled,
            fuzzyPinyinSettings: RimeFuzzyPinyinSettings(enabled: false)
        )
    }

    /// Builds a schema overlay without mutating the pinned upstream schema.
    /// Official Luna places the simplified/traditional option at switch 2;
    /// existing downloadable product schemes use switch 1.
    public static func makeSchemaCustomYamlContent(
        schemaID: String,
        simplificationEnabled: Bool?,
        userDictionaryEnabled: Bool,
        fuzzyPinyinSettings: RimeFuzzyPinyinSettings
    ) -> String? {
        var patch: [(String, String)] = []
        if let simplificationEnabled {
            let reset = simplificationEnabled ? 1 : 0
            let switchIndex = schemaID == "luna_pinyin" ? 2 : 1
            patch.append(("\"switches/@\(switchIndex)/reset\"", "\(reset)"))
        }
        patch.append(
            (
                "\"translator/enable_user_dict\"",
                userDictionaryEnabled ? "true" : "false"
            ))
        guard !patch.isEmpty else { return nil }
        var yaml = "patch:\n"
        for (key, value) in patch {
            yaml += "  \(key): \(value)\n"
        }
        if schemaID == "luna_pinyin", fuzzyPinyinSettings.hasEnabledRules {
            yaml += "  \"speller/algebra/+\":\n"
            for rule in fuzzyPinyinSettings.algebraRules {
                yaml += "    - \(rule)\n"
            }
        }
        return yaml
    }
}
