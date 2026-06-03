import Foundation
import KeyboardCore
import Observation
import RimeBridge

// MARK: - Schema Manager

@MainActor
@Observable
final class SchemaManager {
    static let appGroupID = "group.com.DoubleShy0N.Universe-Keyboard"

    let settings: any SharedSettingsStoring
    let catalogClient: any SchemaCatalogClient
    let archiveDownloader: any SchemaArchiveDownloading
    let archiveInstaller: any SchemaArchiveInstalling
    let deploymentService: any RimeDeploymentServicing

    var activeSchemaID: String
    var schemas: [SchemaMetadata] = []
    var rimeIceDownloadState: DownloadState = .idle
    var rimeIceLicenseAccepted: Bool = false
    var rimeIceVersion: String?

    var currentDownloadTask: Task<Void, Never>?

    init(
        settings: (any SharedSettingsStoring)? = nil,
        catalogClient: any SchemaCatalogClient = GitHubSchemaCatalogClient(),
        archiveDownloader: any SchemaArchiveDownloading = URLSessionSchemaArchiveDownloader(),
        archiveInstaller: (any SchemaArchiveInstalling)? = nil,
        deploymentService: any RimeDeploymentServicing = RimeDeploymentService()
    ) {
        let settings = settings ?? AppGroupSharedSettingsStore(appGroupID: Self.appGroupID)
        self.settings = settings
        self.catalogClient = catalogClient
        self.archiveDownloader = archiveDownloader
        self.archiveInstaller =
            archiveInstaller ?? SharedContainerSchemaArchiveInstaller(appGroupID: Self.appGroupID)
        self.deploymentService = deploymentService
        self.activeSchemaID = settings.string(forKey: "rime_active_schema") ?? "luna_pinyin"
        self.rimeIceLicenseAccepted = settings.bool(forKey: "rime_ice_license_accepted")
        self.rimeIceVersion = settings.string(forKey: "rime_ice_version")
        refreshSchemaList()
    }

    func refreshSchemaList() {
        let installed = settings.bool(forKey: "rime_ice_installed") && rimeIceFilesExist()

        var list: [SchemaMetadata] = [
            SchemaMetadata(
                schemaID: "luna_pinyin",
                name: "朙月拼音",
                description: "RIME 官方基础拼音方案，内置于 App。词库较小，适合测试和快速输入。",
                source: .builtin,
                version: nil,
                installed: true,
                requiresLua: false,
                downloadSize: "内置"
            )
        ]

        if installed || settings.bool(forKey: "rime_ice_installed") {
            let version = rimeIceVersion ?? settings.string(forKey: "rime_ice_version")
            list.append(
                SchemaMetadata(
                    schemaID: "rime_ice",
                    name: "雾凇拼音",
                    description: "社区维护的高质量简体词库，词条丰富、更新活跃。需要下载约 16 MB。",
                    source: .downloaded,
                    version: version,
                    installed: installed,
                    requiresLua: true,
                    downloadSize: "16 MB"
                ))
        }

        if !installed && !settings.bool(forKey: "rime_ice_installed") {
            list.append(
                SchemaMetadata(
                    schemaID: "rime_ice",
                    name: "雾凇拼音",
                    description: "社区维护的高质量简体词库，词条丰富、更新活跃。需要下载约 16 MB。",
                    source: .downloaded,
                    version: nil,
                    installed: false,
                    requiresLua: true,
                    downloadSize: "16 MB"
                ))
        }

        // 去重
        var seen: Set<String> = []
        schemas = list.filter { seen.insert($0.schemaID + ($0.version ?? "") + String($0.installed)).inserted }
    }

    func switchToSchema(_ schemaID: String) {
        guard activeSchemaID != schemaID else { return }
        activeSchemaID = schemaID
        settings.set(schemaID, forKey: "rime_active_schema")
        requestDeploy()
        refreshSchemaList()
    }

    func acceptLicense() {
        rimeIceLicenseAccepted = true
        settings.set(true, forKey: "rime_ice_license_accepted")
    }

    func startDownload() {
        switch rimeIceDownloadState {
        case .idle, .completed, .failed: break
        default: return
        }
        rimeIceDownloadState = .fetchingReleaseInfo
        currentDownloadTask = Task { [weak self] in
            await self?.fetchAndDownload()
        }
    }

    func cancelDownload() {
        currentDownloadTask?.cancel()
        currentDownloadTask = nil
        rimeIceDownloadState = .idle
    }
}
