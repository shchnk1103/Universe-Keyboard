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
                skippedFiles: ["radical_pinyin.schema.yaml", "radical_pinyin.dict.yaml"],
                removableFiles: [
                    "rime_ice.schema.yaml", "rime_ice.dict.yaml",
                    "melt_eng.schema.yaml", "melt_eng.dict.yaml",
                    "symbols_v.yaml", "symbols_caps_v.yaml",
                    "custom_phrase.txt",
                ],
                removableDirectories: ["cn_dicts", "en_dicts"],
                removableBuildFileSubstrings: ["rime_ice", "melt_eng"]
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

enum DownloadState: Equatable {
    case idle
    case fetchingReleaseInfo
    case downloading(progress: Double)
    case extracting
    case postProcessing
    case deploying
    case completed
    case failed(String)
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
