import Foundation
import KeyboardCore

/// 管理 RIME 配置文件的部署和数据目录。
///
/// 小文件以字符串字面量写入，大文件（官方词典）从 bundle 复制。
struct RimeConfigManager {

    private static let appGroupID = "group.com.DoubleShy0N.Universe-Keyboard"

    // MARK: - Public

    static func prepareDirectories() -> (sharedDir: String, userDir: String)? {
        guard let containerURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: appGroupID
        ) else {
            Logger.shared.error("App Group 容器不可用", category: .config)
            return nil
        }

        let rimeRoot = containerURL.appendingPathComponent("Rime")
        let sharedDir = rimeRoot.appendingPathComponent("shared")
        let userDir = rimeRoot.appendingPathComponent("user")

        for dir in [sharedDir, userDir] {
            try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        }

        // 列出 bundle 中所有可用的 yaml 文件
        let bundleYamls = Bundle.main.urls(forResourcesWithExtension: "yaml", subdirectory: nil) ?? []
        let bundleRimes = Bundle.main.urls(forResourcesWithExtension: "yaml", subdirectory: "Resources") ?? []
        Logger.shared.info("Bundle yaml (root): \(bundleYamls.map { $0.lastPathComponent }.joined(separator: ", "))", category: .config)
        Logger.shared.info("Bundle yaml (Resources/): \(bundleRimes.map { $0.lastPathComponent }.joined(separator: ", "))", category: .config)

        // 1. 写入小文件（字符串字面量）
        let defs = UserDefaults(suiteName: appGroupID)
        let activeSchema = defs?.string(forKey: "rime_active_schema") ?? "luna_pinyin"
        let rimeIceInstalled = defs?.bool(forKey: "rime_ice_installed") ?? false
        let defaultYaml = RimeConfigTemplates.generateDefaultYaml(activeSchemaID: activeSchema, rimeIceInstalled: rimeIceInstalled, pageSize: currentPageSize())
        Logger.shared.info("rime_ice_installed=\(rimeIceInstalled), active=\(activeSchema), schema_list has rime_ice: \(defaultYaml.contains("rime_ice"))", category: .config)
        writeIfChanged(name: "default.yaml", content: defaultYaml, to: sharedDir)
        writeIfChanged(name: "installation.yaml", content: RimeConfigTemplates.installationYaml, to: sharedDir)
        writeIfChanged(name: "luna_pinyin.schema.yaml", content: RimeConfigTemplates.lunaPinyinSchema, to: sharedDir)

        // 2. 复制官方词典
        copyFromBundleIfNeeded(name: "luna_pinyin.dict.yaml", to: sharedDir)

        // 3. 复制预编译二进制到 prebuilt_data_dir (shared/build/)
        //    macOS librime 1.16.1 编译产出，跨平台兼容
        let buildDir = sharedDir.appendingPathComponent("build")
        try? FileManager.default.createDirectory(at: buildDir, withIntermediateDirectories: true)
        for name in ["luna_pinyin.table.bin", "luna_pinyin.prism.bin", "luna_pinyin.reverse.bin"] {
            copyFromBundleIfNeeded(name: name, to: buildDir)
        }

        // 4. 写入 OpenCC 配置文件 + 字典（简繁转换）
        let openccDir = sharedDir.appendingPathComponent("opencc")
        try? FileManager.default.createDirectory(at: openccDir, withIntermediateDirectories: true)
        writeIfChanged(name: "t2s.json", content: RimeConfigTemplates.openccT2S, to: openccDir)
        writeIfChanged(name: "s2t.json", content: RimeConfigTemplates.openccS2T, to: openccDir)
        for name in ["TSCharacters.ocd2", "TSPhrases.ocd2", "STCharacters.ocd2", "STPhrases.ocd2"] {
            copyFromBundleIfNeeded(name: name, to: openccDir)
        }
        Logger.shared.info("OpenCC configs written to shared/opencc/", category: .config)

        // 5. 检查配置版本号，高于已部署版本则清除 build 缓存
        let currentGen = 3  // Phase 5: 多 schema 支持 + 雾凇拼音集成
        let deployedGen = defs?.integer(forKey: "config_generation") ?? 0
        if currentGen > deployedGen {
            if FileManager.default.fileExists(atPath: buildDir.path) {
                try? FileManager.default.removeItem(at: buildDir)
                try? FileManager.default.createDirectory(at: buildDir, withIntermediateDirectories: true)
            }
            for name in ["luna_pinyin.table.bin", "luna_pinyin.prism.bin", "luna_pinyin.reverse.bin"] {
                copyFromBundleIfNeeded(name: name, to: buildDir)
            }
            defs?.set(currentGen, forKey: "config_generation")
            defs?.set(false, forKey: "rime_deployed")
            defs?.set(true, forKey: "rime_needs_deploy")
            defs?.synchronize()
            Logger.shared.info("Config gen \(deployedGen) → \(currentGen), cleared build cache", category: .config)
        }

        // 6. rime_ice 配置修复：若主 App 已完成部署（rime_deployed=true），跳过修复
        //    主 App 的 deployRimeConfig 已编译全部 schema，键盘不应覆盖其结果
        //    仅在部署标记为 false 且 schema 损坏时才修复
        let rimeDeployed = defs?.bool(forKey: "rime_deployed") ?? false
        if rimeIceInstalled && !rimeDeployed {
            let iceSchemaURL = sharedDir.appendingPathComponent("rime_ice.schema.yaml")
            let existingContent = (try? String(contentsOf: iceSchemaURL, encoding: .utf8)) ?? ""
            let hasLua = existingContent.contains("lua_translator@") ||
                          existingContent.contains("lua_filter@") ||
                          existingContent.contains("lua_processor@")
            if !hasLua {
                writeIfChanged(name: "rime_ice.schema.yaml", content: RimeConfigTemplates.rimeIceMinimalSchema, to: sharedDir)
                if FileManager.default.fileExists(atPath: buildDir.path) {
                    try? FileManager.default.removeItem(at: buildDir)
                    try? FileManager.default.createDirectory(at: buildDir, withIntermediateDirectories: true)
                }
                defs?.set(false, forKey: "rime_deployed")
                defs?.set(true, forKey: "rime_needs_deploy")
                defs?.synchronize()
                Logger.shared.info("rime_ice.schema.yaml was Lua-stripped — replaced with minimal working schema", category: .config)
            }
        }

        // 列出已部署文件
        let sharedFiles = (try? FileManager.default.contentsOfDirectory(at: sharedDir, includingPropertiesForKeys: nil)) ?? []
        Logger.shared.info("SharedDir: \(sharedFiles.map { "\($0.lastPathComponent)(\((try? $0.resourceValues(forKeys: [.fileSizeKey]).fileSize) ?? 0)/1024K)" }.joined(separator: ", "))", category: .config)

        return (sharedDir.path, userDir.path)
    }

    // MARK: - Configuration (custom.yaml)

    /// 从 UserDefaults 读取配置并生成 .custom.yaml 文件到 user_data_dir。
    /// 在部署前调用，确保用户通过主 App 修改的配置被写入。
    static func syncCustomYamlFiles() {
        guard let containerURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: appGroupID
        ) else { return }

        let userDir = containerURL.appendingPathComponent("Rime/user")
        try? FileManager.default.createDirectory(at: userDir, withIntermediateDirectories: true)

        let defs = UserDefaults(suiteName: appGroupID)
        let activeSchema = defs?.string(forKey: "rime_active_schema") ?? "luna_pinyin"

        // default.custom.yaml — 候选数量（全局）
        let pageSize = defs?.integer(forKey: "rime_page_size") ?? 0
        if pageSize >= 5 {
            let yaml = "patch:\n  \"menu/page_size\": \(pageSize)\n"
            try? yaml.write(to: userDir.appendingPathComponent("default.custom.yaml"), atomically: true, encoding: .utf8)
            Logger.shared.info("Synced default.custom.yaml (page_size=\(pageSize))", category: .config)
        }

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

    // MARK: - Configuration UI helpers (called by main app via UserDefaults)

    private static var defaults: UserDefaults? {
        UserDefaults(suiteName: appGroupID)
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
        writeCustomYaml(filename: "default.custom.yaml", patch: [
            "\"menu/page_size\"": clamped,
        ])
        requestDeploy()
    }

    /// 获取默认简繁状态。true = 简体。
    static func currentSimplification() -> Bool {
        if defaults?.object(forKey: "rime_simplification") == nil {
            return true // 默认简体
        }
        return defaults?.bool(forKey: "rime_simplification") ?? true
    }

    /// 设置默认简繁。true = 简体（reset=1），false = 繁体（reset=0）。
    static func setSimplification(_ simplified: Bool) {
        defaults?.set(simplified, forKey: "rime_simplification")
        writeCustomYaml(filename: "luna_pinyin.custom.yaml", patch: [
            "\"switches/@1/reset\"": simplified ? 1 : 0,
        ])
        requestDeploy()
    }

    /// 设置部署标记，键盘下次按键时自动部署。
    static func requestDeploy() {
        defaults?.set(false, forKey: "rime_deployed")
        defaults?.set(true, forKey: "rime_needs_deploy")
        defaults?.synchronize()
        Logger.shared.info("Deploy requested — rime_needs_deploy set", category: .config)
    }

    /// 将 patch 字典写入 user_data_dir 下的 .custom.yaml 文件。
    private static func writeCustomYaml(filename: String, patch: [String: Any]) {
        guard let containerURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: appGroupID
        ) else { return }

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

    // MARK: - Private helpers

    @discardableResult
    private static func writeIfChanged(name: String, content: String, to dir: URL) -> Bool {
        let url = dir.appendingPathComponent(name)
        if (try? String(contentsOf: url, encoding: .utf8)) == content { return false }
        try? content.write(to: url, atomically: true, encoding: .utf8)
        Logger.shared.info("已写入 \(name)", category: .config)
        return true
    }

    private static func copyFromBundleIfNeeded(name: String, to dir: URL) {
        let dest = dir.appendingPathComponent(name)

        // 尝试多个可能的 bundle 路径
        let resourceName = (name as NSString).deletingPathExtension
        let ext = (name as NSString).pathExtension

        let sourceURL = Bundle.main.url(forResource: resourceName, withExtension: ext)
                     ?? Bundle.main.url(forResource: resourceName, withExtension: ext, subdirectory: "Resources")

        guard let source = sourceURL else {
            Logger.shared.warning("Bundle 中未找到 \(name)，使用内嵌词库", category: .config)
            writeIfChanged(name: name, content: RimeConfigTemplates.fallbackDict, to: dir)
            return
        }

        let sourceSize = (try? source.resourceValues(forKeys: [.fileSizeKey]).fileSize) ?? 0
        let destSize = (try? dest.resourceValues(forKeys: [.fileSizeKey]).fileSize) ?? 0

        // 始终用 bundle 中的版本替换（bundle 中的官方词典 > 内嵌回退）
        if sourceSize != destSize {
            try? FileManager.default.removeItem(at: dest)
            try? FileManager.default.copyItem(at: source, to: dest)
            Logger.shared.info("已从 bundle 复制 \(name) (\(sourceSize/1024) KB)", category: .config)
        } else {
            Logger.shared.info("\(name) 已是最新 (\(sourceSize/1024) KB)", category: .config)
        }
    }

}
