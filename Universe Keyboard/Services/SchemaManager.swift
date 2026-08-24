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
        migrateLegacyLicenseAcceptanceIfNeeded()
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
        if activeSchemaID == "rime_ice", schemaID != "rime_ice" {
            applyLayoutFallbackWhenLeavingRimeIce(newSchemaID: schemaID)
        }
        activeSchemaID = schemaID
        settings.set(schemaID, forKey: "rime_active_schema")
        // ADR 0026: detail-page "设为当前" updates the 26-key layout slot.
        if RimeRuntimeSelection.isTwentySixKeyCapable(schemaID) {
            settings.set(schemaID, forKey: KeyboardLayoutSettingsKey.schemeBinding26)
        }
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
        guard downloadableEntry(for: schemaID) != nil, licenseAccepted(for: schemaID) else { return }
        switch rimeIceDownloadState {
        case .idle, .completed, .failed: break
        default: return
        }
        let schemeName = downloadSchemeDisplayName(for: schemaID)
        rimeIceDownloadState = .fetchingReleaseInfo(schemeName: schemeName)
        currentDownloadTask = Task { [weak self] in
            await self?.fetchAndDownload(schemaID: schemaID)
        }
    }

    func cancelDownload() {
        currentDownloadTask?.cancel()
        currentDownloadTask = nil
        rimeIceDownloadState = .idle
    }

    /// User-facing name for download toast / progress (TD-009).
    func downloadSchemeDisplayName(for schemaID: String) -> String {
        catalogEntry(for: schemaID)?.name ?? schemaID
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
        guard let entry = catalogEntry(for: schemaID), let license = entry.license else { return true }
        guard let key = entry.storage.licenseAcceptanceRevision else { return false }
        return settings.string(forKey: key) == license.acceptanceRevision
    }

    func acceptLicense(for schemaID: String) {
        guard let entry = catalogEntry(for: schemaID), let license = entry.license else { return }
        guard let revisionKey = entry.storage.licenseAcceptanceRevision else { return }
        settings.set(license.acceptanceRevision, forKey: revisionKey)
        if let legacyKey = entry.storage.licenseAccepted {
            settings.set(true, forKey: legacyKey)
        }
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
            licenseName: entry.license?.licenseName,
            licenseDescriptor: entry.license,
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

    /// The historical fog-song dialog correctly showed GPL-3.0, so its old
    /// Boolean acknowledgement can be upgraded once. Wanxiang is deliberately
    /// excluded because the former shared dialog displayed the wrong project.
    private func migrateLegacyLicenseAcceptanceIfNeeded() {
        guard let entry = catalogEntry(for: "rime_ice"), let license = entry.license else { return }
        guard
            let legacyKey = entry.storage.licenseAccepted,
            let revisionKey = entry.storage.licenseAcceptanceRevision,
            settings.bool(forKey: legacyKey),
            settings.string(forKey: revisionKey) == nil
        else { return }
        settings.set(license.acceptanceRevision, forKey: revisionKey)
    }
}
