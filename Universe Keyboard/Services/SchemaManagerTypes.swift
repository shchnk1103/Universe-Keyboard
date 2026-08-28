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
    let licenseDescriptor: ThirdPartyLicenseDescriptor?
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
    let license: ThirdPartyLicenseDescriptor?
    let distribution: RimeSchemeDistribution?
    let storage: RimeSchemeStorageKeys
    let installationPlan: RimeSchemeInstallationPlan?
}

nonisolated struct RimeSchemeDistribution: Equatable, Sendable {
    let manifest: RimeSchemeArtifactManifest
    let cachedArchiveFileName: String
    let extractionDirectoryName: String
}

/// One immutable scheme artifact. Every source variant has its own archive
/// receipt, while both variants must converge on the same staged content.
nonisolated struct RimeSchemeArtifactManifest: Equatable, Sendable {
    let schemeID: String
    let version: String
    let assetName: String
    let sourceVariants: [RimeSchemeSourceVariant]
    let stagedIdentities: [RimeSchemeStagedIdentity]

    func resolvedStagedIdentity(for source: RimeSchemeSourceVariant) throws
        -> RimeSchemeStagedIdentity
    {
        guard sourceVariants.contains(source),
            !schemeID.isEmpty,
            !version.isEmpty,
            !assetName.isEmpty
        else {
            throw DownloadError.invalidArtifactManifest
        }
        guard (1...8).contains(sourceVariants.count) else {
            throw DownloadError.invalidArtifactManifest
        }
        guard Set(sourceVariants.map(\.id)).count == sourceVariants.count,
            Set(stagedIdentities.map(\.id)).count == stagedIdentities.count
        else {
            throw DownloadError.invalidArtifactManifest
        }
        guard
            sourceVariants.allSatisfy({ source in
                !source.id.isEmpty
                    && !source.upstreamRevision.isEmpty
                    && source.expectedByteCount > 0
                    && Self.isSHA256(source.archiveSHA256)
                    && !source.allowedRedirectHosts.isEmpty
                    && source.downloadURL.scheme?.lowercased() == "https"
                    && !source.stagedIdentityID.isEmpty
            })
        else {
            throw DownloadError.invalidArtifactManifest
        }

        let matches = stagedIdentities.filter { $0.id == source.stagedIdentityID }
        guard matches.count == 1, let identity = matches.first,
            !identity.id.isEmpty,
            !identity.artifactIdentityID.isEmpty,
            identity.schemeID == schemeID,
            identity.version == version,
            Self.isSHA256(identity.stagedContentSHA256WithLua),
            Self.isSHA256(identity.stagedContentSHA256WithoutLua),
            !identity.installationPlanRevision.isEmpty,
            !identity.postProcessingRevision.isEmpty
        else {
            throw DownloadError.invalidArtifactManifest
        }
        return identity
    }

    func validateImplementationBinding(
        _ identity: RimeSchemeStagedIdentity,
        installationPlan: RimeSchemeInstallationPlan,
        postProcessingRevision: String
    ) throws {
        guard identity.installationPlanRevision == installationPlan.revision,
            identity.postProcessingRevision == postProcessingRevision
        else {
            throw DownloadError.invalidArtifactManifest
        }
    }

    private static func isSHA256(_ value: String) -> Bool {
        value.count == 64
            && value.unicodeScalars.allSatisfy {
                CharacterSet(charactersIn: "0123456789abcdef").contains($0)
            }
    }
}

nonisolated struct RimeSchemeSourceVariant: Equatable, Sendable, Identifiable {
    let id: String
    let displayName: String
    let downloadURL: URL
    let upstreamRevision: String
    let expectedByteCount: Int64
    let archiveSHA256: String
    let allowedRedirectHosts: Set<String>
    let stagedIdentityID: String
}

/// Sources are interchangeable only when they resolve to this complete,
/// immutable installed-content identity. Visible version text is insufficient.
nonisolated struct RimeSchemeStagedIdentity: Equatable, Sendable, Identifiable {
    let id: String
    let artifactIdentityID: String
    let schemeID: String
    let version: String
    let stagedContentSHA256WithLua: String
    let stagedContentSHA256WithoutLua: String
    let installationPlanRevision: String
    let postProcessingRevision: String
}

nonisolated struct RimeSchemeStorageKeys: Equatable, Sendable {
    let installed: String?
    let version: String?
    let licenseAccepted: String?
    let licenseAcceptanceRevision: String?
    let eTag: String?
    let checksum: String?
    let sourceVariant: String?
    let stagedContentChecksum: String?

    static let builtin = RimeSchemeStorageKeys(
        installed: nil,
        version: nil,
        licenseAccepted: nil,
        licenseAcceptanceRevision: nil,
        eTag: nil,
        checksum: nil,
        sourceVariant: nil,
        stagedContentChecksum: nil
    )

    static func downloaded(prefix: String) -> RimeSchemeStorageKeys {
        RimeSchemeStorageKeys(
            installed: "\(prefix)_installed",
            version: "\(prefix)_version",
            licenseAccepted: "\(prefix)_license_accepted",
            licenseAcceptanceRevision: "\(prefix)_license_acceptance_revision",
            eTag: "\(prefix)_etag",
            checksum: "\(prefix)_checksum",
            sourceVariant: "\(prefix)_source_variant",
            stagedContentChecksum: "\(prefix)_staged_content_checksum"
        )
    }
}

nonisolated struct RimeSchemeInstallationPlan: Equatable, Sendable {
    let revision: String
    let schemaFileName: String
    let luaDirectoryPrefix: String?
    let allowedFiles: Set<String>
    let allowedPrefixes: [String]
    let skippedPrefixes: [String]
    let skippedFiles: [String]
    let removableFiles: [String]
    let removableDirectories: [String]
    let removableBuildFileSubstrings: [String]

    func prefixesToSkip(luaAvailable: Bool) -> [String] {
        guard !luaAvailable, let luaDirectoryPrefix else { return skippedPrefixes }
        return skippedPrefixes + [luaDirectoryPrefix]
    }

    func shouldInstall(relativePath: String, luaAvailable: Bool) -> Bool {
        guard
            allowedFiles.contains(relativePath)
                || allowedPrefixes.contains(where: { relativePath.hasPrefix($0) })
        else {
            return false
        }
        guard !skippedFiles.contains((relativePath as NSString).lastPathComponent) else {
            return false
        }
        return !prefixesToSkip(luaAvailable: luaAvailable).contains(where: {
            relativePath.hasPrefix($0)
        })
    }

    func normalizedRelativePath(for fileURL: URL, under rootURL: URL) throws -> String {
        let rootPath = rootURL.standardizedFileURL.path
        let filePath = fileURL.standardizedFileURL.path
        let prefix = rootPath.hasSuffix("/") ? rootPath : rootPath + "/"
        guard filePath.hasPrefix(prefix) else { throw DownloadError.corruptArchive }
        let relativePath = String(filePath.dropFirst(prefix.count))
        let components = relativePath.split(separator: "/", omittingEmptySubsequences: false)
        guard !relativePath.isEmpty,
            !relativePath.hasPrefix("/"),
            components.allSatisfy({ !$0.isEmpty && $0 != "." && $0 != ".." })
        else {
            throw DownloadError.corruptArchive
        }
        return relativePath
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
            license: nil,
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
            license: ThirdPartyLicenseCatalog.rimeIce,
            distribution: RimeSchemeDistribution(
                manifest: RimeSchemeArtifactManifest(
                    schemeID: "rime_ice",
                    version: "nightly",
                    assetName: "full.zip",
                    sourceVariants: [
                        RimeSchemeSourceVariant(
                            id: "nju",
                            displayName: "南京大学开源镜像",
                            downloadURL: URL(
                                string:
                                    "https://mirror.nju.edu.cn/github-release/iDvel/rime-ice/nightly%20build/full.zip"
                            )!,
                            upstreamRevision: "sha256:f60aa4f3bf5bcae5",
                            expectedByteCount: 16_041_786,
                            archiveSHA256: "f60aa4f3bf5bcae5f49697cd529fa0c990c91f7349acd350073bcae75ff7410f",
                            allowedRedirectHosts: ["mirror.nju.edu.cn"],
                            stagedIdentityID: "rime-ice-nightly-plan1-post1"
                        ),
                        RimeSchemeSourceVariant(
                            id: "github",
                            displayName: "GitHub 官方发布",
                            downloadURL: URL(
                                string: "https://github.com/iDvel/rime-ice/releases/download/nightly/full.zip"
                            )!,
                            upstreamRevision: "sha256:f60aa4f3bf5bcae5",
                            expectedByteCount: 16_041_786,
                            archiveSHA256: "f60aa4f3bf5bcae5f49697cd529fa0c990c91f7349acd350073bcae75ff7410f",
                            allowedRedirectHosts: [
                                "github.com", "release-assets.githubusercontent.com",
                                "objects.githubusercontent.com",
                            ],
                            stagedIdentityID: "rime-ice-nightly-plan1-post1"
                        ),
                    ],
                    stagedIdentities: [
                        RimeSchemeStagedIdentity(
                            id: "rime-ice-nightly-plan1-post1",
                            artifactIdentityID: "rime-ice-nightly-f60aa4f3",
                            schemeID: "rime_ice",
                            version: "nightly",
                            stagedContentSHA256WithLua:
                                "1b42482113be8973869efe66f0d95e7b48bfb2d2af7e6b7cd7c94aa988fca17d",
                            stagedContentSHA256WithoutLua:
                                "2d6b9355c0719a60fbabb4c7b061a5b718e5edefc2f778c72799d91e23f9447c",
                            installationPlanRevision: "rime-ice-plan-1",
                            postProcessingRevision: "rime-ice-post-1"
                        )
                    ]
                ),
                cachedArchiveFileName: "rime_ice_full.zip",
                extractionDirectoryName: "rime_ice_extract"
            ),
            storage: .downloaded(prefix: "rime_ice"),
            installationPlan: RimeSchemeInstallationPlan(
                revision: "rime-ice-plan-1",
                schemaFileName: "rime_ice.schema.yaml",
                luaDirectoryPrefix: "lua/",
                allowedFiles: [
                    "rime_ice.schema.yaml", "rime_ice.dict.yaml",
                    "radical_pinyin.schema.yaml", "radical_pinyin.dict.yaml",
                    "melt_eng.schema.yaml", "melt_eng.dict.yaml",
                    "symbols_v.yaml", "symbols_caps_v.yaml",
                    "custom_phrase.txt", "default.yaml", "t9.schema.yaml",
                ],
                allowedPrefixes: ["cn_dicts/", "en_dicts/", "lua/", "opencc/"],
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
            license: ThirdPartyLicenseCatalog.wanxiang,
            distribution: RimeSchemeDistribution(
                manifest: RimeSchemeArtifactManifest(
                    schemeID: "wanxiang",
                    version: "17.5.9",
                    assetName: "rime-wanxiang-base.zip",
                    sourceVariants: [
                        RimeSchemeSourceVariant(
                            id: "cnb",
                            displayName: "CNB 国内源",
                            downloadURL: URL(
                                string:
                                    "https://cnb.cool/amzxyz/rime-wanxiang/-/releases/download/v17.5.9/rime-wanxiang-base.zip"
                            )!,
                            upstreamRevision: "9f0bd587f886132b1b1dabfd81fd0dcf60a5f8be",
                            expectedByteCount: 35_027_247,
                            archiveSHA256: "9bfcf60e62d85dd168cd2748e5b2d126fcb3355939969eb80455ba71cbf67732",
                            allowedRedirectHosts: ["cnb.cool", "asset.cnb.cool"],
                            stagedIdentityID: "wanxiang-17.5.9-plan1-post1"
                        ),
                        RimeSchemeSourceVariant(
                            id: "github",
                            displayName: "GitHub 官方发布",
                            downloadURL: URL(
                                string:
                                    "https://github.com/amzxyz/rime-wanxiang/releases/download/v17.5.9/rime-wanxiang-base.zip"
                            )!,
                            upstreamRevision: "7aefc0cc38e744e33cd18e6abd5996c00a8d2c5a",
                            expectedByteCount: 35_020_530,
                            archiveSHA256: "73f8c9da0f09b982629aae3cbc4a8ca33640e1bdaf7557ded49b71f94b7b2c87",
                            allowedRedirectHosts: [
                                "github.com", "release-assets.githubusercontent.com",
                                "objects.githubusercontent.com",
                            ],
                            stagedIdentityID: "wanxiang-17.5.9-plan1-post1"
                        ),
                    ],
                    stagedIdentities: [
                        RimeSchemeStagedIdentity(
                            id: "wanxiang-17.5.9-plan1-post1",
                            artifactIdentityID: "wanxiang-17.5.9-cnb9bfc-github73f8",
                            schemeID: "wanxiang",
                            version: "17.5.9",
                            stagedContentSHA256WithLua:
                                "5b182801298152236c790e29fd190d41b509c7da373babb0c02e65fa4eaf07cf",
                            stagedContentSHA256WithoutLua:
                                "289929084bd8ebc751a9ef9e936327331bf14670be5eeae4722221c0bf810682",
                            installationPlanRevision: "wanxiang-plan-1",
                            postProcessingRevision: "wanxiang-post-1"
                        )
                    ]
                ),
                cachedArchiveFileName: "rime_wanxiang_base.zip",
                extractionDirectoryName: "rime_wanxiang_extract"
            ),
            storage: .downloaded(prefix: "wanxiang"),
            installationPlan: RimeSchemeInstallationPlan(
                revision: "wanxiang-plan-1",
                schemaFileName: "wanxiang.schema.yaml",
                luaDirectoryPrefix: "lua/",
                allowedFiles: [
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
                allowedPrefixes: ["dicts/", "lua/"],
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
                    "dicts"
                ],
                removableBuildFileSubstrings: [
                    "wanxiang"
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
    case downloading(schemeName: String, sourceName: String, progress: Double?)
    case extracting(schemeName: String)
    case postProcessing(schemeName: String)
    case deploying(schemeName: String)
    case completed(schemeName: String)
    case failed(schemeName: String, message: String)

    var schemeName: String? {
        switch self {
        case .idle:
            return nil
        case .downloading(let name, _, _):
            return name
        case .fetchingReleaseInfo(let name),
            .extracting(let name),
            .postProcessing(let name),
            .deploying(let name),
            .completed(let name),
            .failed(let name, _):
            return name
        }
    }
}

/// Mutations received while verified installation owns the commit boundary.
/// Destructive intents keep FIFO order; idempotent intents are coalesced.
enum SchemeMutationIntent: Equatable {
    case startDownload(schemaID: String, force: Bool)
    case switchSchema(String)
    case uninstall(String)
    case requestDeploy

    var isStartDownload: Bool {
        if case .startDownload = self { return true }
        return false
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
    /// `nil` is a legacy/no-receipt state; explicit `false` must fail closed.
    let runtimeSmokePassed: Bool?
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
        guard rimeDeployed, !rimeNeedsDeploy, runtimeSmokePassed != false else { return .needsDeploy }
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
            "runtimeSmokePassed=\(runtimeSmokePassed.map(String.init) ?? "nil")",
        ].joined(separator: ";")
    }
}

nonisolated enum DownloadIntegrityFailure: Error, Equatable, Sendable {
    case archiveSize(expected: Int64, actual: Int64)
    case archiveDigest(expected: String, actual: String)
    case stagedContent(expected: String, actual: String)

    var permitsPinnedSourceFallback: Bool {
        switch self {
        case .archiveSize, .archiveDigest: true
        case .stagedContent: false
        }
    }
}

/// A bounded summary of archive-level failures after every pinned source has
/// been exhausted. It intentionally carries no digest or byte values.
nonisolated enum DownloadIntegrityAggregate: Equatable, Sendable {
    case archiveSize
    case archiveDigest
    case mixed
}

enum DownloadError: Error, LocalizedError, Equatable {
    case networkError(String)
    case gitHubRateLimit
    case unsupportedScheme
    case allSourcesUnavailable
    case allSourcesFailedIntegrity(DownloadIntegrityAggregate)
    case integrityMismatch(DownloadIntegrityFailure)
    case invalidArtifactManifest
    case temporaryArtifactRegistrationFailed
    case temporaryCleanupFailed
    case deploymentFailed
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
        case .unsupportedScheme:
            return "暂不支持下载这个方案"
        case .allSourcesUnavailable:
            return "当前所有下载源均不可用，请检查网络后重试"
        case .allSourcesFailedIntegrity(let aggregate):
            switch aggregate {
            case .archiveSize:
                return "所有下载源的文件大小均未通过校验，已停止安装，请稍后重试"
            case .archiveDigest:
                return "所有下载源均未通过安全校验，已停止安装，请稍后重试"
            case .mixed:
                return "所有下载源均未通过完整性校验，已停止安装，请稍后重试"
            }
        case .integrityMismatch(let failure):
            switch failure {
            case .archiveSize:
                return "下载文件不完整，已停止安装，请检查网络后重试"
            case .archiveDigest:
                return "下载文件未通过安全校验，已停止安装，请稍后重试"
            case .stagedContent:
                return "方案内容未通过安装前校验，已停止安装，请稍后重试"
            }
        case .invalidArtifactManifest:
            return "方案下载清单无效，已停止安装，请等待 App 更新"
        case .temporaryArtifactRegistrationFailed:
            return "无法安全登记下载文件，已停止安装，请稍后重试"
        case .temporaryCleanupFailed:
            return "未能安全清理失败的下载文件，已停止切换下载源，请稍后重试"
        case .deploymentFailed:
            return "方案文件已准备，但 RIME 部署失败，请稍后重试"
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

    static func userFacingDescription(for error: Error) -> String {
        if let downloadError = error as? DownloadError {
            return downloadError.localizedDescription
        }
        guard let urlError = error as? URLError else {
            return "操作未能完成，请稍后重试"
        }
        switch urlError.code {
        case .notConnectedToInternet, .networkConnectionLost:
            return "网络连接不可用，请检查蜂窝网络或 Wi-Fi 后重试"
        case .timedOut:
            return "下载源响应超时，已尝试切换其他来源，请稍后重试"
        case .cannotFindHost, .cannotConnectToHost, .dnsLookupFailed:
            return "暂时无法连接下载源，请稍后重试"
        case .secureConnectionFailed, .serverCertificateUntrusted,
            .serverCertificateHasBadDate, .serverCertificateHasUnknownRoot:
            return "无法建立安全连接，请检查系统时间和网络设置"
        case .cancelled:
            return "下载已取消"
        default:
            return "网络请求失败，请检查网络后重试"
        }
    }
}
