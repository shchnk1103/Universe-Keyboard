import Foundation
import KeyboardCore

extension SchemaManager {
    func findFile(named name: String, in dir: URL) -> URL? {
        guard let enumerator = FileManager.default.enumerator(at: dir, includingPropertiesForKeys: nil) else {
            return nil
        }
        for case let url as URL in enumerator {
            if url.lastPathComponent == name {
                return url
            }
        }
        return nil
    }

    func releaseVersionIdentifier(from url: URL) -> String {
        let components = url.pathComponents
        if let downloadIndex = components.firstIndex(of: "download"),
            components.indices.contains(downloadIndex + 1)
        {
            return components[downloadIndex + 1]
        }

        return url.lastPathComponent
    }

    func installRimeIceFiles(from extractDir: URL) throws {
        guard let plan = downloadableEntry(for: "rime_ice")?.installationPlan else {
            throw DownloadError.networkError("暂不支持安装这个方案")
        }
        try installSchemaFiles(from: extractDir, plan: plan)
    }

    func installSchemaFiles(from extractDir: URL, plan: RimeSchemeInstallationPlan) throws {
        let luaAvailable = (settings.object(forKey: "rime_lua_available") as? Bool) ?? true
        try installSchemaFiles(from: extractDir, plan: plan, luaAvailable: luaAvailable)
    }

    func installSchemaFiles(
        from extractDir: URL,
        plan: RimeSchemeInstallationPlan,
        luaAvailable: Bool
    ) throws {
        try archiveInstaller.installSchemaFiles(from: extractDir, plan: plan, luaAvailable: luaAvailable)
    }

    func activateRimeIce() {
        activateSchema("rime_ice")
    }

    func activateSchema(_ schemaID: String, leaseOperationID: UUID? = nil) {
        settings.set(schemaID, forKey: "rime_active_schema")
        activeSchemaID = schemaID
        // ADR 0026: activating a 26-key-capable scheme updates the 26-key layout slot.
        if RimeRuntimeSelection.isTwentySixKeyCapable(schemaID) {
            settings.set(schemaID, forKey: KeyboardLayoutSettingsKey.schemeBinding26)
        }
        requestDeploy(leaseOperationID: leaseOperationID)
    }

    @discardableResult
    func uninstallRimeIce() -> Task<Void, Never>? {
        uninstallSchema("rime_ice")
    }

    @discardableResult
    func uninstallSchema(_ schemaID: String) -> Task<Void, Never>? {
        guard schemeDeliveryCommitLeaseOperationID == nil else {
            enqueueSchemeMutation(.uninstall(schemaID))
            return nil
        }
        guard let entry = downloadableEntry(for: schemaID), let plan = entry.installationPlan else {
            return nil
        }

        return Task { @MainActor [weak self] in
            await self?.performSchemaUninstall(entry: entry, plan: plan)
        }
    }

    private func performSchemaUninstall(
        entry: RimeSchemeCatalogEntry,
        plan: RimeSchemeInstallationPlan
    ) async {
        let operationID = UUID()
        guard await acquireSchemeDeliveryCommitLease(operationID: operationID) else { return }
        defer { releaseSchemeDeliveryCommitLease(operationID: operationID) }

        let schemaID = entry.schemaID
        let originalSchemaID = activeSchemaID
        let requiresActiveFallback = originalSchemaID == schemaID

        if requiresActiveFallback {
            // Do not use `switchToSchema`: it only records a later deployment.
            // P4 requires Luna's deployment to finish before any target files
            // become removable.
            setActiveSchemaWithoutDeployment("luna_pinyin")
            let fallbackSucceeded = await deployRimeConfig(leaseOperationID: operationID)
            guard fallbackSucceeded else {
                await restoreSchemaAfterFailedUninstall(
                    originalSchemaID,
                    operationID: operationID,
                    reason: "Luna 回退部署失败"
                )
                return
            }
        }

        let staging: SchemaUninstallStaging
        do {
            staging = try archiveInstaller.stageSchemaUninstall(plan: plan)
        } catch {
            if requiresActiveFallback {
                await restoreSchemaAfterFailedUninstall(
                    originalSchemaID,
                    operationID: operationID,
                    reason: "方案文件暂存失败"
                )
            } else {
                Logger.shared.error(
                    "uninstallSchema: 方案文件暂存失败，保留原方案文件",
                    category: .deployment
                )
            }
            return
        }

        // ADR 0018: only invalidate T9 after Luna is deployed and the target
        // files have been staged successfully.
        if schemaID == "rime_ice" {
            prepareRimeIceUninstallWithLayoutFallback()
        }

        archiveInstaller.commitSchemaUninstall(staging, plan: plan)

        for key in [
            entry.storage.installed,
            entry.storage.version,
            entry.storage.licenseAccepted,
            entry.storage.licenseAcceptanceRevision,
            entry.storage.eTag,
            entry.storage.checksum,
            entry.storage.sourceVariant,
            entry.storage.stagedContentChecksum,
        ].compactMap({ $0 }) {
            settings.removeObject(forKey: key)
        }

        if !requiresActiveFallback {
            requestDeploy(leaseOperationID: operationID)
        }
        rimeIceDownloadState = .idle
        if schemaID == "rime_ice" {
            rimeIceLicenseAccepted = false
            rimeIceVersion = nil
        }
        refreshSchemaList()
    }

    private func setActiveSchemaWithoutDeployment(_ schemaID: String) {
        activeSchemaID = schemaID
        settings.set(schemaID, forKey: "rime_active_schema")
        settings.synchronize()
    }

    /// Fail-closed restore must finish while the uninstall lease is still held.
    /// A detached Task would race `defer { release… }` and could observe a
    /// foreign lease or skip the redeploy entirely.
    private func restoreSchemaAfterFailedUninstall(
        _ schemaID: String,
        operationID: UUID,
        reason: String
    ) async {
        setActiveSchemaWithoutDeployment(schemaID)
        _ = await deployRimeConfig(leaseOperationID: operationID)
        refreshSchemaList()
        Logger.shared.error(
            "uninstallSchema: \(reason)，已保留原方案文件并恢复原方案选择",
            category: .deployment
        )
    }

    func checkForUpdate() async -> Bool {
        await checkForUpdate(schemaID: "rime_ice")
    }

    func checkForUpdate(schemaID: String) async -> Bool {
        guard let manifest = downloadableEntry(for: schemaID)?.distribution?.manifest else {
            return false
        }
        return manifest.version != installedVersion(for: schemaID)
    }

    func rimeIceFilesExist() -> Bool {
        guard let plan = downloadableEntry(for: "rime_ice")?.installationPlan else { return false }
        return archiveInstaller.containsInstalledSchema(plan: plan)
    }

    func checkDiskSpace(needed: Int64) throws {
        try archiveInstaller.checkDiskSpace(needed: needed)
    }
}
