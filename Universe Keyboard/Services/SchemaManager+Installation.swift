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
        let luaAvailable = (settings.object(forKey: "rime_lua_available") as? Bool) ?? true
        try archiveInstaller.installRimeIceFiles(from: extractDir, luaAvailable: luaAvailable)
    }

    func activateRimeIce() {
        settings.set("rime_ice", forKey: "rime_active_schema")
        activeSchemaID = "rime_ice"
        requestDeploy()
    }

    func uninstallRimeIce() {
        archiveInstaller.uninstallRimeIceFiles()

        for key in [
            "rime_ice_installed", "rime_ice_version", "rime_ice_license_accepted",
            "rime_ice_download_url", "rime_ice_etag", "rime_ice_checksum",
        ] {
            settings.removeObject(forKey: key)
        }

        switchToSchema("luna_pinyin")
        rimeIceDownloadState = .idle
        rimeIceLicenseAccepted = false
        rimeIceVersion = nil
        refreshSchemaList()
    }

    func checkForUpdate() async -> Bool {
        do {
            guard let url = try await fetchLatestReleaseURL() else { return false }
            let newVersion = releaseVersionIdentifier(from: url)
            return newVersion != rimeIceVersion
        } catch {
            return false
        }
    }

    func rimeIceFilesExist() -> Bool {
        archiveInstaller.containsInstalledRimeIceSchema()
    }

    func checkDiskSpace(needed: Int64) throws {
        try archiveInstaller.checkDiskSpace(needed: needed)
    }
}
