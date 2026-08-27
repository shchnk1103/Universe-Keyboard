import Foundation
import KeyboardCore
import Observation
import RimeBridge

// MARK: - Schema Manager

@MainActor
@Observable
final class SchemaManager {
    private struct CommitLeaseAvailabilityWaiter {
        let id: UUID
        let operationID: UUID
        let continuation: CheckedContinuation<Bool, Never>
    }

    nonisolated static let appGroupID = "group.com.DoubleShy0N.Universe-Keyboard"

    let schemeCatalog: [RimeSchemeCatalogEntry]
    let settings: any SharedSettingsStoring
    let sourceSelector: any SchemaSourceSelecting
    let archiveDownloader: any SchemaArchiveDownloading
    let artifactVerifier: any SchemaArtifactVerifying
    let temporaryArtifactCleaner: any SchemaTemporaryArtifactCleaning
    let deliveryDiagnostics: any SchemaDeliveryDiagnosing
    let archiveInstaller: any SchemaArchiveInstalling
    let deploymentService: any RimeDeploymentServicing

    var activeSchemaID: String
    var schemas: [SchemaMetadata] = []
    var rimeIceDownloadState: DownloadState = .idle
    var rimeIceLicenseAccepted: Bool = false
    var rimeIceVersion: String?
    var currentDownloadTask: Task<Void, Never>?
    var activeDownloadOperationID: UUID?
    var schemeDeliveryCommitLeaseOperationID: UUID?
    var schemeDeliveryCommitLeaseHandoffPending = false
    private var schemeDeliveryCommitLeaseAvailabilityWaiters: [CommitLeaseAvailabilityWaiter] = []
    var schemeDeliveryCommitLeaseAvailabilityWaiterCount: Int {
        schemeDeliveryCommitLeaseAvailabilityWaiters.count
    }
    var activeRimeDeploymentID: UUID?
    var activeRimeDeploymentTask: Task<Bool, Never>?
    var schemeDeliveryDeploymentWaiters: [CheckedContinuation<Bool, Never>] = []
    var queuedSchemeMutationIntents: [SchemeMutationIntent] = []
    var deferredDownloadCancellationRequested = false

    init(
        schemeCatalog: [RimeSchemeCatalogEntry] = RimeSchemeCatalog.entries,
        settings: (any SharedSettingsStoring)? = nil,
        sourceSelector: any SchemaSourceSelecting = URLSessionSchemaSourceSelector(),
        archiveDownloader: any SchemaArchiveDownloading = URLSessionSchemaArchiveDownloader(),
        artifactVerifier: any SchemaArtifactVerifying = SchemaArtifactVerifier(),
        temporaryArtifactCleaner: any SchemaTemporaryArtifactCleaning =
            FileSystemSchemaTemporaryArtifactCleaner(),
        deliveryDiagnostics: any SchemaDeliveryDiagnosing = SchemaDeliveryDiagnostics.live,
        archiveInstaller: (any SchemaArchiveInstalling)? = nil,
        deploymentService: any RimeDeploymentServicing = RimeDeploymentService()
    ) {
        let settings = settings ?? AppGroupSharedSettingsStore(appGroupID: Self.appGroupID)
        self.schemeCatalog = schemeCatalog
        self.settings = settings
        self.sourceSelector = sourceSelector
        self.archiveDownloader = archiveDownloader
        self.artifactVerifier = artifactVerifier
        self.temporaryArtifactCleaner = temporaryArtifactCleaner
        self.deliveryDiagnostics = deliveryDiagnostics
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
        guard schemeDeliveryCommitLeaseOperationID == nil else {
            enqueueSchemeMutation(.switchSchema(schemaID))
            return
        }
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
        guard schemeDeliveryCommitLeaseOperationID == nil else {
            enqueueSchemeMutation(.startDownload(schemaID: schemaID, force: false))
            return
        }
        guard downloadableEntry(for: schemaID) != nil, licenseAccepted(for: schemaID) else { return }
        switch rimeIceDownloadState {
        case .idle, .completed, .failed: break
        default: return
        }
        beginVerifiedDownload(schemaID: schemaID)
    }

    func cancelDownload() {
        if schemeDeliveryCommitLeaseOperationID == activeDownloadOperationID,
            activeDownloadOperationID != nil
        {
            deferredDownloadCancellationRequested = true
            return
        }
        let operationID = activeDownloadOperationID
        currentDownloadTask?.cancel()
        if let operationID {
            cancelSchemeDeliveryCommitLeaseAvailabilityWaiters(operationID: operationID)
        }
        currentDownloadTask = nil
        activeDownloadOperationID = nil
        rimeIceDownloadState = .idle
    }

    func acquireSchemeDeliveryCommitLease(operationID: UUID) async -> Bool {
        while true {
            if schemeDeliveryCommitLeaseOperationID != nil
                || schemeDeliveryCommitLeaseHandoffPending
            {
                let becameAvailable = await waitForSchemeDeliveryCommitLeaseAvailability(
                    operationID: operationID
                )
                if !becameAvailable || Task.isCancelled { return false }
                continue
            }

            if let deploymentID = activeRimeDeploymentID,
                let deploymentTask = activeRimeDeploymentTask
            {
                _ = await deploymentTask.value
                // The original caller may not have resumed on MainActor yet. The
                // lease acquirer may safely retire the same completed single-flight
                // task, but never a newer deployment.
                if activeRimeDeploymentID == deploymentID {
                    activeRimeDeploymentID = nil
                    activeRimeDeploymentTask = nil
                }
                if Task.isCancelled { return false }
                continue
            }

            guard schemeDeliveryCommitLeaseOperationID == nil else { continue }
            guard activeRimeDeploymentTask == nil else { continue }
            schemeDeliveryCommitLeaseOperationID = operationID
            deferredDownloadCancellationRequested = false
            return true
        }
    }

    func releaseSchemeDeliveryCommitLease(operationID: UUID) {
        guard schemeDeliveryCommitLeaseOperationID == operationID else { return }
        schemeDeliveryCommitLeaseOperationID = nil
        deferredDownloadCancellationRequested = false
        let deploymentWaiters = schemeDeliveryDeploymentWaiters
        schemeDeliveryDeploymentWaiters.removeAll()

        let intents = queuedSchemeMutationIntents
        queuedSchemeMutationIntents.removeAll()
        let deferredStart = intents.last {
            if case .startDownload = $0 { return true }
            return false
        }
        for intent in intents where !intent.isStartDownload {
            switch intent {
            case .startDownload:
                break
            case .switchSchema(let schemaID):
                switchToSchema(schemaID)
            case .uninstall(let schemaID):
                uninstallSchema(schemaID)
            case .requestDeploy:
                requestDeploy()
            }
        }
        if case .startDownload(let schemaID, let force) = deferredStart {
            if downloadableEntry(for: schemaID) == nil || !licenseAccepted(for: schemaID) {
                rimeIceDownloadState = .failed(
                    schemeName: downloadSchemeDisplayName(for: schemaID),
                    message: "下载请求已失效，请重新确认许可证后再试"
                )
            } else {
                force ? forceRedownload(schemaID: schemaID) : startDownload(schemaID: schemaID)
            }
        }

        // All callers that attempted a deployment during the lease share one
        // post-commit deployment. Waking every caller to deploy independently
        // would race RIME's shared build directory.
        guard !deploymentWaiters.isEmpty else {
            resumeSchemeDeliveryCommitLeaseAvailabilityWaiters()
            return
        }
        schemeDeliveryCommitLeaseHandoffPending = true
        Task { @MainActor [weak self] in
            guard let self else {
                deploymentWaiters.forEach { $0.resume(returning: false) }
                return
            }
            let succeeded = await self.deployRimeConfig()
            deploymentWaiters.forEach { $0.resume(returning: succeeded) }
            self.schemeDeliveryCommitLeaseHandoffPending = false
            self.resumeSchemeDeliveryCommitLeaseAvailabilityWaiters()
        }
    }

    private func resumeSchemeDeliveryCommitLeaseAvailabilityWaiters() {
        let waiters = schemeDeliveryCommitLeaseAvailabilityWaiters
        schemeDeliveryCommitLeaseAvailabilityWaiters.removeAll()
        waiters.forEach { $0.continuation.resume(returning: true) }
    }

    private func waitForSchemeDeliveryCommitLeaseAvailability(operationID: UUID) async -> Bool {
        let waiterID = UUID()
        // Build the hop on MainActor first. `onCancel` is `@Sendable` and
        // nonisolated; capturing `self` or `weak self` there is a Swift 6.0
        // data race (Xcode 26.6 CI), even when the inner Task is MainActor.
        let cancelWaiter: @MainActor @Sendable () -> Void = { [weak self] in
            self?.cancelSchemeDeliveryCommitLeaseAvailabilityWaiter(id: waiterID)
        }
        return await withTaskCancellationHandler {
            await withCheckedContinuation { continuation in
                schemeDeliveryCommitLeaseAvailabilityWaiters.append(
                    CommitLeaseAvailabilityWaiter(
                        id: waiterID,
                        operationID: operationID,
                        continuation: continuation
                    )
                )

                // Register first so cancellation cannot run between the
                // preflight check and insertion, leaving a stranded waiter.
                if Task.isCancelled {
                    cancelWaiter()
                }
            }
        } onCancel: {
            Task { await cancelWaiter() }
        }
    }

    private func cancelSchemeDeliveryCommitLeaseAvailabilityWaiter(id: UUID) {
        guard
            let index = schemeDeliveryCommitLeaseAvailabilityWaiters.firstIndex(where: {
                $0.id == id
            })
        else { return }
        let waiter = schemeDeliveryCommitLeaseAvailabilityWaiters.remove(at: index)
        waiter.continuation.resume(returning: false)
    }

    private func cancelSchemeDeliveryCommitLeaseAvailabilityWaiters(operationID: UUID) {
        let cancelled = schemeDeliveryCommitLeaseAvailabilityWaiters.filter {
            $0.operationID == operationID
        }
        schemeDeliveryCommitLeaseAvailabilityWaiters.removeAll {
            $0.operationID == operationID
        }
        cancelled.forEach { $0.continuation.resume(returning: false) }
    }

    func waitForPostCommitDeployment() async -> Bool {
        guard schemeDeliveryCommitLeaseOperationID != nil else {
            return await deployRimeConfig()
        }
        return await withCheckedContinuation { continuation in
            schemeDeliveryDeploymentWaiters.append(continuation)
        }
    }

    func enqueueSchemeMutation(_ intent: SchemeMutationIntent) {
        switch intent {
        case .uninstall:
            queuedSchemeMutationIntents.append(intent)
        case .startDownload:
            // SchemaManager owns one download state/task. Preserve only the
            // latest deferred start intent so a second schema cannot be
            // silently dropped when the first changes the shared state.
            queuedSchemeMutationIntents.removeAll {
                if case .startDownload = $0 { return true }
                return false
            }
            queuedSchemeMutationIntents.append(intent)
        case .switchSchema:
            queuedSchemeMutationIntents.removeAll {
                if case .switchSchema = $0 { return true }
                return false
            }
            queuedSchemeMutationIntents.append(intent)
        case .requestDeploy:
            guard !queuedSchemeMutationIntents.contains(.requestDeploy) else { return }
            queuedSchemeMutationIntents.append(intent)
        }
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

    func sourceVariant(for schemaID: String) -> RimeSchemeSourceVariant? {
        guard let entry = downloadableEntry(for: schemaID),
            let manifest = entry.distribution?.manifest
        else { return nil }
        guard let key = entry.storage.sourceVariant,
            let sourceID = settings.string(forKey: key)
        else { return nil }
        return manifest.sourceVariants.first { $0.id == sourceID }
    }

    func manifestVersion(for schemaID: String) -> String? {
        downloadableEntry(for: schemaID)?.distribution?.manifest.version
    }

    func hasVerifiedReceipt(for schemaID: String) -> Bool {
        guard let entry = downloadableEntry(for: schemaID),
            let manifest = entry.distribution?.manifest,
            let source = sourceVariant(for: schemaID),
            let archiveKey = entry.storage.checksum,
            let stagedKey = entry.storage.stagedContentChecksum,
            settings.string(forKey: archiveKey) == source.archiveSHA256,
            let stagedDigest = settings.string(forKey: stagedKey)
        else { return false }
        guard let identity = try? manifest.resolvedStagedIdentity(for: source) else { return false }
        return stagedDigest == identity.stagedContentSHA256WithLua
            || stagedDigest == identity.stagedContentSHA256WithoutLua
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
