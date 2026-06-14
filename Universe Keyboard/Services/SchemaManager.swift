import Foundation
import KeyboardCore
import Observation
import RimeBridge

// MARK: - Schema Manager

@MainActor
@Observable
final class SchemaManager {
    static let appGroupID = "group.com.DoubleShy0N.Universe-Keyboard"

    let schemeCatalog: [RimeSchemeCatalogEntry]
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
        schemeCatalog: [RimeSchemeCatalogEntry] = RimeSchemeCatalog.entries,
        settings: (any SharedSettingsStoring)? = nil,
        catalogClient: any SchemaCatalogClient = GitHubSchemaCatalogClient(),
        archiveDownloader: any SchemaArchiveDownloading = URLSessionSchemaArchiveDownloader(),
        archiveInstaller: (any SchemaArchiveInstalling)? = nil,
        deploymentService: any RimeDeploymentServicing = RimeDeploymentService()
    ) {
        let settings = settings ?? AppGroupSharedSettingsStore(appGroupID: Self.appGroupID)
        self.schemeCatalog = schemeCatalog
        self.settings = settings
        self.catalogClient = catalogClient
        self.archiveDownloader = archiveDownloader
        self.archiveInstaller =
            archiveInstaller ?? SharedContainerSchemaArchiveInstaller(appGroupID: Self.appGroupID)
        self.deploymentService = deploymentService
        self.activeSchemaID = settings.string(forKey: "rime_active_schema") ?? "luna_pinyin"
        self.rimeIceLicenseAccepted = licenseAccepted(for: "rime_ice")
        self.rimeIceVersion = installedVersion(for: "rime_ice")
        refreshSchemaList()
    }

    func refreshSchemaList() {
        rimeIceVersion = installedVersion(for: "rime_ice")
        rimeIceLicenseAccepted = licenseAccepted(for: "rime_ice")
        schemas = schemeCatalog.map { metadata(for: $0) }
    }

    func switchToSchema(_ schemaID: String) {
        guard activeSchemaID != schemaID else { return }
        activeSchemaID = schemaID
        settings.set(schemaID, forKey: "rime_active_schema")
        requestDeploy()
        refreshSchemaList()
    }

    func acceptLicense() {
        acceptLicense(for: "rime_ice")
    }

    func startDownload() {
        startDownload(schemaID: "rime_ice")
    }

    func startDownload(schemaID: String) {
        guard downloadableEntry(for: schemaID) != nil else { return }
        switch rimeIceDownloadState {
        case .idle, .completed, .failed: break
        default: return
        }
        rimeIceDownloadState = .fetchingReleaseInfo
        currentDownloadTask = Task { [weak self] in
            await self?.fetchAndDownload(schemaID: schemaID)
        }
    }

    func cancelDownload() {
        currentDownloadTask?.cancel()
        currentDownloadTask = nil
        rimeIceDownloadState = .idle
    }

    func catalogEntry(for schemaID: String) -> RimeSchemeCatalogEntry? {
        schemeCatalog.first { $0.schemaID == schemaID }
    }

    func downloadableEntry(for schemaID: String) -> RimeSchemeCatalogEntry? {
        guard let entry = catalogEntry(for: schemaID), entry.distribution != nil, entry.installationPlan != nil else {
            return nil
        }
        return entry
    }

    func installedVersion(for schemaID: String) -> String? {
        guard let key = catalogEntry(for: schemaID)?.storage.version else { return nil }
        return settings.string(forKey: key)
    }

    func licenseAccepted(for schemaID: String) -> Bool {
        guard let key = catalogEntry(for: schemaID)?.storage.licenseAccepted else { return true }
        return settings.bool(forKey: key)
    }

    func acceptLicense(for schemaID: String) {
        guard let key = catalogEntry(for: schemaID)?.storage.licenseAccepted else { return }
        settings.set(true, forKey: key)
        if schemaID == "rime_ice" {
            rimeIceLicenseAccepted = true
        }
        refreshSchemaList()
    }

    private func metadata(for entry: RimeSchemeCatalogEntry) -> SchemaMetadata {
        SchemaMetadata(
            schemaID: entry.schemaID,
            name: entry.name,
            description: entry.description,
            source: entry.source,
            version: installedVersion(for: entry.schemaID),
            installed: isInstalled(entry),
            requiresLua: entry.requiresLua,
            downloadSize: entry.downloadSize,
            installedSize: entry.installedSize,
            licenseName: entry.licenseName,
            supportsUserDictionary: entry.supportsUserDictionary,
            isDownloadable: entry.distribution != nil
        )
    }

    private func isInstalled(_ entry: RimeSchemeCatalogEntry) -> Bool {
        guard let installedKey = entry.storage.installed else { return true }
        let recordedInstalled = settings.bool(forKey: installedKey)
        guard let plan = entry.installationPlan else { return recordedInstalled }
        return recordedInstalled && archiveInstaller.containsInstalledSchema(plan: plan)
    }
}
