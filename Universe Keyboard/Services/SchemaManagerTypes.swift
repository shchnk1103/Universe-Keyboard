import Foundation

struct SchemaMetadata: Codable, Identifiable, Equatable {
    var id: String { schemaID }
    let schemaID: String
    let name: String
    let description: String
    let source: SchemaSource
    let version: String?
    var installed: Bool
    let requiresLua: Bool
    let downloadSize: String
    let installedSize: String?
    let licenseName: String?
    let supportsUserDictionary: Bool
    let isDownloadable: Bool

    enum SchemaSource: String, Codable {
        case builtin
        case downloaded
    }
}

struct RimeSchemeCatalogEntry: Identifiable, Equatable {
    var id: String { schemaID }
    let schemaID: String
    let name: String
    let description: String
    let source: SchemaMetadata.SchemaSource
    let requiresLua: Bool
    let supportsUserDictionary: Bool
    let downloadSize: String
    let installedSize: String?
    let licenseName: String?
    let distribution: RimeSchemeDistribution?
    let storage: RimeSchemeStorageKeys
    let installationPlan: RimeSchemeInstallationPlan?
}

struct RimeSchemeDistribution: Equatable, Sendable {
    let githubOwner: String
    let githubRepository: String
    let assetName: String
    let cachedArchiveFileName: String
    let extractionDirectoryName: String
}

struct RimeSchemeStorageKeys: Equatable, Sendable {
    let installed: String?
    let version: String?
    let licenseAccepted: String?
    let eTag: String?
    let checksum: String?

    static let builtin = RimeSchemeStorageKeys(
        installed: nil,
        version: nil,
        licenseAccepted: nil,
        eTag: nil,
        checksum: nil
    )

    static func downloaded(prefix: String) -> RimeSchemeStorageKeys {
        RimeSchemeStorageKeys(
            installed: "\(prefix)_installed",
            version: "\(prefix)_version",
            licenseAccepted: "\(prefix)_license_accepted",
            eTag: "\(prefix)_etag",
            checksum: "\(prefix)_checksum"
        )
    }
}

struct RimeSchemeInstallationPlan: Equatable, Sendable {
    let schemaFileName: String
    let luaDirectoryPrefix: String?
    let skippedPrefixes: [String]
    let skippedFiles: [String]
    let removableFiles: [String]
    let removableDirectories: [String]
    let removableBuildFileSubstrings: [String]

    func prefixesToSkip(luaAvailable: Bool) -> [String] {
        guard !luaAvailable, let luaDirectoryPrefix else { return skippedPrefixes }
        return skippedPrefixes + [luaDirectoryPrefix]
    }
}

enum RimeSchemeCatalog {
    static let entries: [RimeSchemeCatalogEntry] = [
        RimeSchemeCatalogEntry(
            schemaID: "luna_pinyin",
            name: "朙月拼音",
            description: "RIME 官方基础拼音方案，内置于 App。词库较小，适合测试和快速输入。",
            source: .builtin,
            requiresLua: false,
            supportsUserDictionary: true,
            downloadSize: "内置",
            installedSize: nil,
            licenseName: nil,
            distribution: nil,
            storage: .builtin,
            installationPlan: nil
        ),
        RimeSchemeCatalogEntry(
            schemaID: "rime_ice",
            name: "雾凇拼音",
            description: "社区维护的高质量简体词库，词条丰富、更新活跃。",
            source: .downloaded,
            requiresLua: true,
            supportsUserDictionary: true,
            downloadSize: "16 MB",
            installedSize: "约 60 MB",
            licenseName: "GPL-3.0",
            distribution: RimeSchemeDistribution(
                githubOwner: "iDvel",
                githubRepository: "rime-ice",
                assetName: "full.zip",
                cachedArchiveFileName: "rime_ice_full.zip",
                extractionDirectoryName: "rime_ice_extract"
            ),
            storage: .downloaded(prefix: "rime_ice"),
            installationPlan: RimeSchemeInstallationPlan(
                schemaFileName: "rime_ice.schema.yaml",
                luaDirectoryPrefix: "lua/",
                skippedPrefixes: ["squirrel", "weasel", "recipe", "others/"],
                skippedFiles: [],
                removableFiles: [
                    "rime_ice.schema.yaml", "rime_ice.dict.yaml",
                    "radical_pinyin.schema.yaml", "radical_pinyin.dict.yaml",
                    "melt_eng.schema.yaml", "melt_eng.dict.yaml",
                    "symbols_v.yaml", "symbols_caps_v.yaml",
                    "custom_phrase.txt",
                    "rime.lua",
                    "t9.schema.yaml",
                    "t9.custom.yaml",
                ],
                removableDirectories: ["cn_dicts", "en_dicts"],
                removableBuildFileSubstrings: ["rime_ice", "melt_eng", "radical_pinyin", "t9"]
            )
        ),
        // PD-RIME-SCHEME-WANXIANG-001 V1 全拼：官方 base 包（非双拼辅助码包）。
        // schema_id = wanxiang；语法模型 .gram 为可选后续切片（未钉进本包）。
        RimeSchemeCatalogEntry(
            schemaID: "wanxiang",
            name: "万象拼音",
            description: "社区万象拼音（全拼）。词库与体验较强；体积大于雾凇。语法模型可另装以增强整句（本版先装方案本体）。",
            source: .downloaded,
            requiresLua: true,
            supportsUserDictionary: true,
            downloadSize: "约 34 MB",
            installedSize: "约 80–120 MB",
            licenseName: "CC BY 4.0",
            distribution: RimeSchemeDistribution(
                githubOwner: "amzxyz",
                githubRepository: "rime-wanxiang",
                assetName: "rime-wanxiang-base.zip",
                cachedArchiveFileName: "rime_wanxiang_base.zip",
                extractionDirectoryName: "rime_wanxiang_extract"
            ),
            storage: .downloaded(prefix: "wanxiang"),
            installationPlan: RimeSchemeInstallationPlan(
                schemaFileName: "wanxiang.schema.yaml",
                luaDirectoryPrefix: "lua/",
                skippedPrefixes: [
                    "docs/",
                    ".github/",
                    "custom/",
                ],
                skippedFiles: [
                    "weasel.yaml",
                    "default.yaml",
                    "README.md",
                    "CHANGELOG.md",
                    "LICENSE",
                    "mkdocs.yml",
                    "version.txt",
                    "custom_phrase.txt",
                    ".gitattributes",
                    ".gitignore",
                    ".yamlfmt",
                    "release-please-config.json",
                    ".release-please-manifest.json",
                ],
                removableFiles: [
                    "wanxiang.schema.yaml",
                    "wanxiang.dict.yaml",
                    "wanxiang_algebra.yaml",
                    "wanxiang_symbols.yaml",
                    "wanxiang_english.schema.yaml",
                    "wanxiang_english.dict.yaml",
                    "wanxiang_mixedcode.schema.yaml",
                    "wanxiang_mixedcode.dict.yaml",
                    "wanxiang_reverse.schema.yaml",
                    "wanxiang_reverse.dict.yaml",
                    "wanxiang_t9.schema.yaml",
                    "wanxiang_t9i.schema.yaml",
                ],
                removableDirectories: [
                    "dicts",
                ],
                removableBuildFileSubstrings: [
                    "wanxiang",
                ]
            )
        ),
    ]

    static func entry(for schemaID: String) -> RimeSchemeCatalogEntry? {
        entries.first { $0.schemaID == schemaID }
    }

    static var downloadableEntries: [RimeSchemeCatalogEntry] {
        entries.filter { $0.distribution != nil && $0.installationPlan != nil }
    }
}

/// Main-App scheme download pipeline state (toast + download UI).
///
/// Active phases carry `schemeName` for multi-scheme honesty (TD-009).
/// `downloading.progress` is `nil` when total size is unknown (indeterminate UI);
/// otherwise a fraction in `0...1`.
enum DownloadState: Equatable {
    case idle
    case fetchingReleaseInfo(schemeName: String)
    case downloading(schemeName: String, progress: Double?)
    case extracting(schemeName: String)
    case postProcessing(schemeName: String)
    case deploying(schemeName: String)
    case completed(schemeName: String)
    case failed(schemeName: String, message: String)

    var schemeName: String? {
        switch self {
        case .idle:
            return nil
        case .fetchingReleaseInfo(let name),
            .downloading(let name, _),
            .extracting(let name),
            .postProcessing(let name),
            .deploying(let name),
            .completed(let name),
            .failed(let name, _):
            return name
        }
    }
}

struct RimeLuaCapabilityDiagnostic: Equatable, Sendable {
    enum Status: Equatable, Sendable {
        case available
        case notInstalled
        case inactiveSchema
        case needsDeploy
        case engineUnavailable
        case runtimeModuleMissing
        case schemaMissing
        case schemaStripped
        case luaFilesMissing
    }

    let luaCompiledIn: Bool
    let luaModuleRegistered: Bool
    let luaComponentsRegistered: Bool
    let deploymentModules: [String]
    let persistedLuaAvailable: Bool?
    let rimeIceInstalled: Bool
    let activeSchemaID: String
    let rimeDeployed: Bool
    let rimeNeedsDeploy: Bool
    let runtimeSmokePassed: Bool
    let schemaExists: Bool
    let schemaHasLuaComponents: Bool
    let luaDirectoryExists: Bool
    let luaEntryScriptRequired: Bool
    let luaEntryScriptExists: Bool
    let dateTranslatorExists: Bool
    let requiredLuaComponentNames: [String]
    let missingLuaComponentNames: [String]
    let missingLuaDependencyNames: [String]

    var status: Status {
        guard rimeIceInstalled else { return .notInstalled }
        guard activeSchemaID == "rime_ice" else { return .inactiveSchema }
        guard luaCompiledIn, deploymentModules.contains("lua"), persistedLuaAvailable != false else {
            return .engineUnavailable
        }
        guard luaModuleRegistered else { return .runtimeModuleMissing }
        guard schemaExists else { return .schemaMissing }
        guard schemaHasLuaComponents else { return .schemaStripped }
        guard
            luaDirectoryExists,
            !luaEntryScriptRequired || luaEntryScriptExists,
            dateTranslatorExists,
            missingLuaComponentNames.isEmpty,
            missingLuaDependencyNames.isEmpty
        else {
            return .luaFilesMissing
        }
        guard runtimeSmokePassed || (rimeDeployed && !rimeNeedsDeploy) else { return .needsDeploy }
        return .available
    }

    var developerSummary: String {
        let modulesSummary = deploymentModules.joined(separator: "+")
        let persistedLuaSummary = persistedLuaAvailable.map { String($0) } ?? "nil"
        let requiredComponentsSummary = requiredLuaComponentNames.joined(separator: "+")
        let missingComponentsSummary = missingLuaComponentNames.joined(separator: "+")
        let missingDependenciesSummary = missingLuaDependencyNames.joined(separator: "+")
        return [
            "status=\(status)",
            "luaCompiledIn=\(luaCompiledIn)",
            "luaModuleRegistered=\(luaModuleRegistered)",
            "luaComponentsRegistered=\(luaComponentsRegistered)",
            "deploymentModules=\(modulesSummary)",
            "persistedLuaAvailable=\(persistedLuaSummary)",
            "activeSchema=\(activeSchemaID)",
            "installed=\(rimeIceInstalled)",
            "schemaExists=\(schemaExists)",
            "schemaHasLua=\(schemaHasLuaComponents)",
            "luaDir=\(luaDirectoryExists)",
            "luaEntryScriptRequired=\(luaEntryScriptRequired)",
            "luaEntryScript=\(luaEntryScriptExists)",
            "dateTranslator=\(dateTranslatorExists)",
            "requiredLuaComponents=\(requiredComponentsSummary)",
            "missingLuaComponents=\(missingComponentsSummary)",
            "missingLuaDependencies=\(missingDependenciesSummary)",
            "deployed=\(rimeDeployed)",
            "needsDeploy=\(rimeNeedsDeploy)",
            "runtimeSmokePassed=\(runtimeSmokePassed)",
        ].joined(separator: ";")
    }
}

enum DownloadError: Error, LocalizedError {
    case networkError(String)
    case gitHubRateLimit
    case diskSpaceInsufficient(needed: Int64, available: Int64)
    case corruptArchive
    case extractionFailed(String)
    case postProcessingFailed(String)

    var errorDescription: String? {
        switch self {
        case .networkError(let message):
            return "网络错误：\(message)"
        case .gitHubRateLimit:
            return "GitHub API 限流，请稍后再试（约 1 小时后重置）"
        case .diskSpaceInsufficient(let needed, let available):
            let needMB = needed / 1_000_000
            let availableMB = available / 1_000_000
            return "存储空间不足（需要约 \(needMB) MB，可用 \(availableMB) MB）"
        case .corruptArchive:
            return "下载文件损坏，请重试"
        case .extractionFailed(let message):
            return "解压失败：\(message)"
        case .postProcessingFailed(let message):
            return "配置文件处理失败：\(message)"
        }
    }
}
