import Foundation

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
        if
            let downloadIndex = components.firstIndex(of: "download"),
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
        try archiveInstaller.installSchemaFiles(from: extractDir, plan: plan, luaAvailable: luaAvailable)
    }

    func activateRimeIce() {
        activateSchema("rime_ice")
    }

    func activateSchema(_ schemaID: String) {
        settings.set(schemaID, forKey: "rime_active_schema")
        activeSchemaID = schemaID
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
            entry.storage.eTag,
            entry.storage.checksum,
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
        do {
            guard
                let entry = downloadableEntry(for: schemaID),
                let url = try await fetchLatestReleaseURL(for: entry)
            else { return false }
            let newVersion = releaseVersionIdentifier(from: url)
            return newVersion != installedVersion(for: schemaID)
        } catch {
            return false
        }
    }

    func rimeIceFilesExist() -> Bool {
        guard let plan = downloadableEntry(for: "rime_ice")?.installationPlan else { return false }
        return archiveInstaller.containsInstalledSchema(plan: plan)
    }

    func checkDiskSpace(needed: Int64) throws {
        try archiveInstaller.checkDiskSpace(needed: needed)
    }
}
