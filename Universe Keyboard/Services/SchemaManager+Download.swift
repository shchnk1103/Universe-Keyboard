import Foundation
import KeyboardCore

extension SchemaManager {
    func forceRedownload() {
        switch rimeIceDownloadState {
        case .idle, .failed:
            break
        default:
            return
        }

        settings.removeObject(forKey: "rime_ice_etag")
        settings.removeObject(forKey: "rime_ice_version")
        rimeIceDownloadState = .fetchingReleaseInfo
        currentDownloadTask = Task { [weak self] in
            await self?.fetchAndDownload()
        }
    }

    func fetchAndDownload() async {
        do {
            let releaseURL = try await fetchLatestReleaseURL()
            guard let url = releaseURL else {
                throw DownloadError.networkError("无法获取最新版本信息")
            }

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

            let extractDir = try archiveInstaller.prepareExtractionDirectory()

            let extractedFiles = try Unzip.extract(zipPath: tempURL.path, to: extractDir)
            guard let schemaURL = findFile(named: "rime_ice.schema.yaml", in: extractDir) else {
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

            try installRimeIceFiles(from: extractDir)
            archiveInstaller.removeTemporaryItem(at: extractDir)
            archiveInstaller.removeTemporaryItem(at: tempURL)

            let version = extractVersionFrom(files: extractedFiles) ?? "unknown"
            rimeIceVersion = version
            settings.set(version, forKey: "rime_ice_version")
            settings.set(true, forKey: "rime_ice_installed")

            activateRimeIce()
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
        try await catalogClient.latestRimeIceArchiveURL()
    }

    func downloadZip(from url: URL) async throws -> DownloadedSchemaArchive {
        let archive = try await archiveDownloader.downloadArchive(
            from: url,
            existingETag: settings.string(forKey: "rime_ice_etag"),
            cachedArchiveURL: archiveInstaller.cachedArchiveURL
        )
        if let eTag = archive.eTag {
            settings.set(eTag, forKey: "rime_ice_etag")
        }
        return archive
    }
}
