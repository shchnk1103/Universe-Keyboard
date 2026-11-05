import Foundation
import KeyboardCore

private let customYamlAppGroupID = "group.com.DoubleShy0N.Universe-Keyboard"

extension RimeConfigManager {
    /// 从 App Group 的 UserDefaults 读取配置并生成 .custom.yaml 文件到 user_data_dir。
    /// 在部署前调用，确保用户通过主 App 修改的配置被写入。
    @discardableResult
    public static func syncCustomYamlFiles(proveCompileInput: Bool = true) -> Bool {
        guard
            let containerURL = FileManager.default.containerURL(
                forSecurityApplicationGroupIdentifier: customYamlAppGroupID
            )
        else { return false }

        let rimeRoot = containerURL.appendingPathComponent("Rime", isDirectory: true)
        return syncCustomYamlFiles(
            defaults: UserDefaults(suiteName: customYamlAppGroupID),
            rimeRoot: rimeRoot,
            proveCompileInput: proveCompileInput
        )
    }

    /// 生产同步的可测试实现：defaults 与 rimeRoot 由调用方注入。
    @discardableResult
    static func syncCustomYamlFiles(
        defaults: UserDefaults?,
        rimeRoot: URL,
        pendingSchemaID: String? = nil,
        proveCompileInput: Bool = true
    ) -> Bool {
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
        let wanxiangInstalledForList = defaults?.bool(forKey: "wanxiang_installed") ?? false
        if activeSchema == "wanxiang" || wanxiangInstalledForList {
            appendSchema("wanxiang")
        }
        if wanxiangInstalledForList || pendingSchemaID == "wanxiang" {
            appendSchema(WanxiangT9SchemaCompatibility.schemaID)
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
        let targets = schemaSwitchTargets(
            rimeRoot: rimeRoot,
            iceInstalled: iceInstalled,
            wanxiangInstalled: wanxiangInstalled,
            pendingSchemaID: pendingSchemaID
        )
        let plan = planSchemaCustomYamlFiles(
            targets: targets,
            simplificationEnabled: simplificationEnabled,
            userDictionarySettings: userDictionarySettings,
            fuzzyPinyinSettings: fuzzySettings,
            grammarYamlPresent: grammarYamlPresent(rimeRoot: rimeRoot),
            compileInputProven: proveCompileInput,
            advancedDisabledComponents: advancedDisabledComponents(from: defaults)
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

    /// One schema whose custom overlay is generated for this deployment.
    /// `sourceText` is the shared schema that will be compiled. It is nil when
    /// that file is not on disk yet. Grammar presence stays with the caller.
    public struct SchemaSwitchTarget: Equatable, Sendable {
        public let schemaID: String
        public let userDictionarySchemaID: String
        public let sourceText: String?
        public let wanxiangFamily: Bool

        public init(
            schemaID: String,
            userDictionarySchemaID: String,
            sourceText: String?,
            wanxiangFamily: Bool
        ) {
            self.schemaID = schemaID
            self.userDictionarySchemaID = userDictionarySchemaID
            self.sourceText = sourceText
            self.wanxiangFamily = wanxiangFamily
        }
    }

    /// Plans overlays from the schemas participating in this deployment.
    /// Switch keys come only from the resolver. A missing source, a failed
    /// recognition, or an unproven post-process leaves the other keys in place.
    public static func planSchemaCustomYamlFiles(
        targets: [SchemaSwitchTarget],
        simplificationEnabled: Bool?,
        userDictionarySettings: RimeUserDictionarySettings,
        fuzzyPinyinSettings: RimeFuzzyPinyinSettings = RimeFuzzyPinyinSettings(enabled: false),
        grammarYamlPresent: Bool = false,
        compileInputProven: Bool = true,
        advancedDisabledComponents: Set<String> = []
    ) -> [SchemaCustomYamlFile] {
        var files: [SchemaCustomYamlFile] = []
        for target in targets {
            let enabled = userDictionarySettings.isEnabled(for: target.userDictionarySchemaID)
            let switches = switchPatches(
                for: target,
                simplificationEnabled: simplificationEnabled,
                fuzzyPinyinSettings: fuzzyPinyinSettings,
                grammarYamlPresent: grammarYamlPresent,
                compileInputProven: compileInputProven,
                advancedDisabledComponents: advancedDisabledComponents
            )
            guard
                let content = makeSchemaCustomYamlContent(
                    schemaID: target.schemaID,
                    userDictionaryEnabled: enabled,
                    fuzzyPinyinSettings: fuzzyPinyinSettings,
                    switchPatches: switches
                )
            else { continue }
            files.append(
                SchemaCustomYamlFile(
                    schemaID: target.schemaID,
                    filename: "\(target.schemaID).custom.yaml",
                    content: content,
                    userDictionarySchemaID: target.userDictionarySchemaID
                )
            )
        }
        return files
    }

    /// Builds a schema overlay without mutating the pinned upstream schema.
    /// Switch keys are supplied by the resolver; this function does not invent indexes.
    public static func makeSchemaCustomYamlContent(
        schemaID: String,
        userDictionaryEnabled: Bool,
        fuzzyPinyinSettings: RimeFuzzyPinyinSettings,
        switchPatches: [(key: String, value: String)] = []
    ) -> String? {
        var patch: [(String, String)] = []
        for item in switchPatches {
            patch.append(("\"\(item.key)\"", item.value))
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

    static func schemaSwitchTargets(
        rimeRoot: URL,
        iceInstalled: Bool,
        wanxiangInstalled: Bool,
        pendingSchemaID: String?
    ) -> [SchemaSwitchTarget] {
        let includeIceFamily = iceInstalled || pendingSchemaID == "rime_ice"
        let includeWanxiang = wanxiangInstalled || pendingSchemaID == "wanxiang"
        var specs: [(String, String, Bool)] = [
            ("luna_pinyin", "luna_pinyin", false),
            ("rime_ice", "rime_ice", false),
        ]
        if includeWanxiang {
            specs.append(("wanxiang", "rime_ice", true))
            specs.append((WanxiangT9SchemaCompatibility.schemaID, "rime_ice", true))
        }
        if includeIceFamily {
            specs.append(("t9", "rime_ice", false))
        }
        return specs.map { schemaID, dictionaryID, wanxiangFamily in
            SchemaSwitchTarget(
                schemaID: schemaID,
                userDictionarySchemaID: dictionaryID,
                sourceText: schemaSourceText(schemaID, rimeRoot: rimeRoot),
                wanxiangFamily: wanxiangFamily
            )
        }
    }

    private static func schemaSourceText(_ schemaID: String, rimeRoot: URL) -> String? {
        let url =
            rimeRoot
            .appendingPathComponent("shared", isDirectory: true)
            .appendingPathComponent("\(schemaID).schema.yaml")
        return try? String(contentsOf: url, encoding: .utf8)
    }

    private static func grammarYamlPresent(rimeRoot: URL) -> Bool {
        let fileManager = FileManager.default
        let names = ["shared", "user"]
        return names.contains { name in
            fileManager.fileExists(
                atPath: rimeRoot.appendingPathComponent(name, isDirectory: true)
                    .appendingPathComponent("grammar.yaml").path
            )
        }
    }

    private static func advancedDisabledComponents(from defaults: UserDefaults?) -> Set<String> {
        let master = defaults?.object(forKey: RimeAdvancedInputSettings.masterEnabledKey) as? Bool ?? true
        var features: [RimeAdvancedInputFeature: Bool] = [:]
        for feature in RimeAdvancedInputFeature.allCases {
            if let enabled = defaults?.object(forKey: RimeAdvancedInputSettings.enabledKey(for: feature)) as? Bool {
                features[feature] = enabled
            }
        }
        let settings = RimeAdvancedInputSettings(masterEnabled: master, featureEnabled: features)
        return settings.disabledComponentNames(supportedFeatures: Set(RimeAdvancedInputFeature.allCases))
    }

    private static func switchPatches(
        for target: SchemaSwitchTarget,
        simplificationEnabled: Bool?,
        fuzzyPinyinSettings: RimeFuzzyPinyinSettings,
        grammarYamlPresent: Bool,
        compileInputProven: Bool,
        advancedDisabledComponents: Set<String>
    ) -> [(key: String, value: String)] {
        guard let simplificationEnabled else { return [] }
        // Fog-song nine-key switches arrive through a whole-file include.
        if target.schemaID == "t9" {
            logSwitchOmission(schemaID: target.schemaID, setting: "simplification", reason: "switchesPatched")
            return []
        }
        // Luna's closed exemption proves the installed source by hash and by the
        // absence of grammar.yaml, independent of a following compile. Keep it on
        // paths such as standard RIME sync so Luna behaves as before.
        guard compileInputProven || target.schemaID == "luna_pinyin" else {
            logSwitchOmission(schemaID: target.schemaID, setting: "simplification", reason: "compileInputUnproven")
            return []
        }
        guard let source = target.sourceText else {
            logSwitchOmission(schemaID: target.schemaID, setting: "simplification", reason: "sourceMissing")
            return []
        }
        if !postProcessKeepsSwitches(
            schemaID: target.schemaID,
            source: source,
            fuzzyPinyinSettings: fuzzyPinyinSettings,
            advancedDisabledComponents: advancedDisabledComponents
        ) {
            logSwitchOmission(schemaID: target.schemaID, setting: "simplification", reason: "compileInputUnproven")
            return []
        }
        let parsed: Result<[SchemaSwitchResolver.Item], SchemaSwitchResolver.Failure>
        if target.schemaID == "luna_pinyin" {
            parsed = SchemaSwitchResolver.recognizeLuna(
                source: source,
                sourceSHA256: SchemaSwitchResolver.builtinLunaSHA256,
                grammarYamlPresent: grammarYamlPresent
            )
        } else {
            parsed = SchemaSwitchResolver.recognize(source)
        }
        let items: [SchemaSwitchResolver.Item]
        switch parsed {
        case .success(let value):
            items = value
        case .failure(let failure):
            logSwitchOmission(schemaID: target.schemaID, setting: "simplification", reason: failure.rawValue)
            return []
        }
        var patches: [(key: String, value: String)] = []
        switch SchemaSwitchResolver.simplification(in: items) {
        case .success(let selection):
            let reset = simplificationEnabled ? selection.simplifiedReset : selection.traditionalReset
            patches.append((selection.key, String(reset)))
        case .failure(let failure):
            logSwitchOmission(schemaID: target.schemaID, setting: "simplification", reason: failure.rawValue)
        }
        guard target.wanxiangFamily else { return patches }
        switch SchemaSwitchResolver.emojiReset(in: items, wanxiangFamily: true) {
        case .success(let emoji):
            if let emoji {
                patches.append((emoji.key, String(emoji.reset)))
            }
        case .failure(let failure):
            logSwitchOmission(schemaID: target.schemaID, setting: "emoji", reason: failure.rawValue)
        }
        return patches
    }

    /// Replays the pure post-processors that run after custom YAML is written.
    /// A changed switch sequence means this source is not a proven compile input.
    private static func postProcessKeepsSwitches(
        schemaID: String,
        source: String,
        fuzzyPinyinSettings: RimeFuzzyPinyinSettings,
        advancedDisabledComponents: Set<String>
    ) -> Bool {
        let original: [SchemaSwitchResolver.Item]
        switch SchemaSwitchResolver.recognize(source) {
        case .success(let value):
            original = value
        case .failure:
            // Luna's pinned patch is recognized only by the exemption path.
            return schemaID == "luna_pinyin"
        }
        let originalIdentity = switchIdentity(original)
        var variants = [
            RimeFuzzyPinyinPostProcessor.apply(settings: fuzzyPinyinSettings, to: source).yaml
        ]
        if schemaID == "rime_ice" {
            variants.append(RimeConfigPostProcessor.stripLuaDependencies(from: source))
            variants.append(
                RimeAdvancedInputPostProcessor.previewRemovingDisabledComponents(
                    advancedDisabledComponents,
                    from: source
                )
            )
        }
        if schemaID == "t9" {
            variants.append((try? T9SchemaCompatibility.makeCompatibleSchema(fromUpstreamYAML: source)) ?? source)
        }
        if schemaID == WanxiangT9SchemaCompatibility.schemaID {
            switch WanxiangT9SchemaCompatibility.rewrite(source) {
            case .rewritten(let text):
                variants.append(text)
            case .alreadyCompatible:
                variants.append(source)
            case .failed:
                return false
            }
        }
        for variant in variants {
            switch SchemaSwitchResolver.recognize(variant) {
            case .success(let items):
                if switchIdentity(items) != originalIdentity { return false }
            case .failure:
                return false
            }
        }
        return true
    }

    private static func switchIdentity(_ items: [SchemaSwitchResolver.Item]) -> [String] {
        items.map { item in
            let options = item.options?.joined(separator: ",") ?? ""
            let states = item.states?.joined(separator: ",") ?? ""
            let reset = item.reset.map(String.init) ?? ""
            return "\(item.index)|\(item.name ?? "")|\(options)|\(states)|\(reset)"
        }
    }

    private static func logSwitchOmission(schemaID: String, setting: String, reason: String) {
        Logger.shared.warning(
            "schemaSwitch schemaID=\(schemaID) setting=\(setting) reason=\(reason)",
            category: .deployment
        )
    }

}
