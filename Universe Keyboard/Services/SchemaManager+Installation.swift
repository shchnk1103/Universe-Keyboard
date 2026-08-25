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

    func activateSchema(_ schemaID: String) {
        settings.set(schemaID, forKey: "rime_active_schema")
        activeSchemaID = schemaID
        // ADR 0026: activating a 26-key-capable scheme updates the 26-key layout slot.
        if RimeRuntimeSelection.isTwentySixKeyCapable(schemaID) {
            settings.set(schemaID, forKey: KeyboardLayoutSettingsKey.schemeBinding26)
        }
        requestDeploy()
    }

    func uninstallRimeIce() {
        uninstallSchema("rime_ice")
    }

    func uninstallSchema(_ schemaID: String) {
        guard let entry = downloadableEntry(for: schemaID), let plan = entry.installationPlan else { return }

        // ADR 0018: layout fallback and readiness invalidation before resource removal.
        if schemaID == "rime_ice" {
            prepareRimeIceUninstallWithLayoutFallback()
        }

        archiveInstaller.uninstallSchemaFiles(plan: plan)

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

        if activeSchemaID == schemaID {
            switchToSchema("luna_pinyin")
        } else {
            requestDeploy()
        }
        rimeIceDownloadState = .idle
        if schemaID == "rime_ice" {
            rimeIceLicenseAccepted = false
            rimeIceVersion = nil
        }
        refreshSchemaList()
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
