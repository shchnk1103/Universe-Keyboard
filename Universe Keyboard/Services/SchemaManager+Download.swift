import Foundation
import KeyboardCore

extension SchemaManager {
    func forceRedownload() {
        forceRedownload(schemaID: "rime_ice")
    }

    func forceRedownload(schemaID: String) {
        switch rimeIceDownloadState {
        case .idle, .completed, .failed:
            break
        default:
            return
        }

        guard let entry = downloadableEntry(for: schemaID) else { return }
        if let key = entry.storage.eTag {
            settings.removeObject(forKey: key)
        }
        if let key = entry.storage.version {
            settings.removeObject(forKey: key)
        }
        rimeIceDownloadState = .fetchingReleaseInfo
        currentDownloadTask = Task { [weak self] in
            await self?.fetchAndDownload(schemaID: schemaID)
        }
    }

    func fetchAndDownload() async {
        await fetchAndDownload(schemaID: "rime_ice")
    }

    func fetchAndDownload(schemaID: String) async {
        do {
            guard
                let entry = downloadableEntry(for: schemaID),
                let distribution = entry.distribution,
                let plan = entry.installationPlan
            else {
                throw DownloadError.networkError("暂不支持下载这个方案")
            }

            let releaseURL = try await fetchLatestReleaseURL(for: entry)
            guard let url = releaseURL else {
                throw DownloadError.networkError("无法获取最新版本信息")
            }
            let version = releaseVersionIdentifier(from: url)

            rimeIceDownloadState = .downloading(progress: 0)

            let archive = try await downloadZip(from: url)
            let tempURL = archive.localURL
            let expectedSize = archive.expectedContentLength
            guard expectedSize > 0 || expectedSize == -1 else {
                throw DownloadError.networkError("服务器未提供文件大小")
            }
            let diskNeeded = expectedSize > 0 ? expectedSize * 3 + 100_000_000 : 200_000_000
            try checkDiskSpace(needed: diskNeeded)

            rimeIceDownloadState = .extracting

            let extractDir = try archiveInstaller.prepareExtractionDirectory(for: distribution)

            _ = try Unzip.extract(zipPath: tempURL.path, to: extractDir)
            guard let schemaURL = findFile(named: plan.schemaFileName, in: extractDir) else {
                throw DownloadError.corruptArchive
            }

            rimeIceDownloadState = .postProcessing
            try await Task.sleep(nanoseconds: 200_000_000)

            let luaAvailable = settings.object(forKey: "rime_lua_available") as? Bool
            if luaAvailable == false {
                let schemaContent = try String(contentsOf: schemaURL, encoding: .utf8)
                let processed = RimeConfigPostProcessor.stripLuaDependencies(from: schemaContent)
                guard RimeConfigPostProcessor.validateStrippedSchema(processed) else {
                    throw DownloadError.postProcessingFailed("剥离 Lua 后 schema 无效")
                }
                try processed.write(to: schemaURL, atomically: true, encoding: .utf8)
            }

            try installSchemaFiles(from: extractDir, plan: plan)
            archiveInstaller.removeTemporaryItem(at: extractDir)
            archiveInstaller.removeTemporaryItem(at: tempURL)

            if let key = entry.storage.version {
                settings.set(version, forKey: key)
            }
            if let key = entry.storage.installed {
                settings.set(true, forKey: key)
            }
            if schemaID == "rime_ice" {
                rimeIceVersion = version
            }

            activateSchema(schemaID)
            rimeIceDownloadState = .deploying
            await deployRimeConfig()

            rimeIceDownloadState = .completed
            refreshSchemaList()
        } catch let error as DownloadError {
            rimeIceDownloadState = .failed(error.localizedDescription)
        } catch {
            rimeIceDownloadState = .failed(error.localizedDescription)
        }
    }

    func fetchLatestReleaseURL() async throws -> URL? {
        guard let entry = downloadableEntry(for: "rime_ice") else { return nil }
        return try await fetchLatestReleaseURL(for: entry)
    }

    func fetchLatestReleaseURL(for entry: RimeSchemeCatalogEntry) async throws -> URL? {
        guard let distribution = entry.distribution else { return nil }
        return try await catalogClient.latestArchiveURL(for: distribution)
    }

    func downloadZip(from url: URL) async throws -> DownloadedSchemaArchive {
        guard let entry = downloadableEntry(for: "rime_ice") else {
            throw DownloadError.networkError("暂不支持下载这个方案")
        }
        return try await downloadZip(from: url, for: entry)
    }

    func downloadZip(from url: URL, for entry: RimeSchemeCatalogEntry) async throws -> DownloadedSchemaArchive {
        guard let distribution = entry.distribution else {
            throw DownloadError.networkError("暂不支持下载这个方案")
        }
        let archive = try await archiveDownloader.downloadArchive(
            from: url,
            existingETag: entry.storage.eTag.flatMap { settings.string(forKey: $0) },
            cachedArchiveURL: archiveInstaller.cachedArchiveURL(for: distribution)
        )
        if let eTag = archive.eTag, let key = entry.storage.eTag {
            settings.set(eTag, forKey: key)
        }
        return archive
    }
}
