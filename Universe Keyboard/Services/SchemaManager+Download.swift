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

        guard let entry = downloadableEntry(for: schemaID), licenseAccepted(for: schemaID) else { return }
        if let plan = entry.installationPlan {
            archiveInstaller.clearBuildCache(plan: plan)
        }
        startVerifiedDownload(schemaID: schemaID)
    }

    func fetchAndDownload() async {
        await fetchAndDownload(schemaID: "rime_ice")
    }

    func fetchAndDownload(schemaID: String) async {
        let operationID = activeDownloadOperationID ?? UUID()
        activeDownloadOperationID = operationID
        await fetchAndDownload(schemaID: schemaID, operationID: operationID)
    }

    private func fetchAndDownload(schemaID: String, operationID: UUID) async {
        let schemeName = downloadSchemeDisplayName(for: schemaID)
        var temporaryItems: [URL] = []

        do {
            guard
                let entry = downloadableEntry(for: schemaID),
                let distribution = entry.distribution,
                let plan = entry.installationPlan
            else {
                throw DownloadError.unsupportedScheme
            }
            try ensureActive(operationID)

            let manifest = distribution.manifest
            let preferredSourceID = entry.storage.sourceVariant.flatMap {
                settings.string(forKey: $0)
            }
            let selectedSource = try await sourceSelector.selectSource(
                from: manifest.sourceVariants,
                preferredSourceID: preferredSourceID
            )
            try ensureActive(operationID)

            let sources = [selectedSource] + manifest.sourceVariants.filter { $0.id != selectedSource.id }
            let archiveResult = try await downloadFirstValidArchive(
                from: sources,
                schemeName: schemeName,
                operationID: operationID
            )
            let archive = archiveResult.archive
            temporaryItems.append(archive.localURL)
            let source = archiveResult.source
            let archiveSHA256 = archiveResult.archiveSHA256
            let diskNeeded = source.expectedByteCount * 3 + 100_000_000
            try checkDiskSpace(needed: diskNeeded)
            try ensureActive(operationID)

            rimeIceDownloadState = .extracting(schemeName: schemeName)
            let extractDir = try archiveInstaller.prepareExtractionDirectory(for: distribution)
            temporaryItems.append(extractDir)
            _ = try await Task.detached(priority: .userInitiated) {
                try Unzip.extract(zipPath: archive.localURL.path, to: extractDir)
            }.value
            try ensureActive(operationID)

            guard let schemaURL = await findSchemaFile(named: plan.schemaFileName, in: extractDir) else {
                throw DownloadError.corruptArchive
            }

            rimeIceDownloadState = .postProcessing(schemeName: schemeName)
            let luaAvailable = (settings.object(forKey: "rime_lua_available") as? Bool) ?? true
            if !luaAvailable {
                try await stripLuaIfNeeded(at: schemaURL)
            }
            if schemaID == "rime_ice" {
                try await sanitizeT9SchemaIfPresent(in: extractDir)
            }
            try ensureActive(operationID)

            let stagedContentSHA256 = try await Task.detached(priority: .userInitiated) {
                try self.artifactVerifier.stagedContentSHA256(
                    in: extractDir,
                    plan: plan,
                    luaAvailable: luaAvailable
                )
            }.value
            let expectedStagedSHA256 =
                luaAvailable
                ? manifest.stagedContentSHA256WithLua
                : manifest.stagedContentSHA256WithoutLua
            guard !expectedStagedSHA256.isEmpty,
                stagedContentSHA256 == expectedStagedSHA256
            else {
                throw DownloadError.integrityMismatch
            }
            try ensureActive(operationID)

            try installSchemaFiles(from: extractDir, plan: plan, luaAvailable: luaAvailable)
            try ensureActive(operationID)

            if schemaID == "rime_ice", let shared = archiveInstaller.sharedDataDirectoryURL() {
                // T9 compatibility rewriting must precede deployment so RIME compiles
                // the sanitized schema instead of the upstream Lua-dependent version.
                _ = try T9DeploymentSupport.ensureCompatibleT9Schema(in: shared)
            }

            activateSchema(schemaID)
            rimeIceDownloadState = .deploying(schemeName: schemeName)
            let deployed = await deployRimeConfig()
            try ensureActive(operationID)
            guard deployed else {
                throw DownloadError.deploymentFailed
            }

            persistVerifiedInstallation(
                entry: entry,
                manifest: manifest,
                source: source,
                archiveSHA256: archiveSHA256,
                stagedContentSHA256: stagedContentSHA256
            )
            if schemaID == "rime_ice" {
                rimeIceVersion = manifest.version
            }

            cleanupTemporaryItems(temporaryItems)
            activeDownloadOperationID = nil
            currentDownloadTask = nil
            rimeIceDownloadState = .completed(schemeName: schemeName)
            refreshSchemaList()
        } catch is CancellationError {
            cleanupTemporaryItems(temporaryItems)
            if activeDownloadOperationID == operationID {
                activeDownloadOperationID = nil
                rimeIceDownloadState = .idle
            }
        } catch {
            cleanupTemporaryItems(temporaryItems)
            if activeDownloadOperationID == operationID {
                activeDownloadOperationID = nil
                currentDownloadTask = nil
                rimeIceDownloadState = .failed(
                    schemeName: schemeName,
                    message: DownloadError.userFacingDescription(for: error)
                )
            }
        }
    }

    func beginVerifiedDownload(schemaID: String) {
        startVerifiedDownload(schemaID: schemaID)
    }

    private func startVerifiedDownload(schemaID: String) {
        let operationID = UUID()
        activeDownloadOperationID = operationID
        let schemeName = downloadSchemeDisplayName(for: schemaID)
        rimeIceDownloadState = .fetchingReleaseInfo(schemeName: schemeName)
        currentDownloadTask = Task { [weak self] in
            await self?.fetchAndDownload(schemaID: schemaID, operationID: operationID)
        }
    }

    private func downloadFirstValidArchive(
        from sources: [RimeSchemeSourceVariant],
        schemeName: String,
        operationID: UUID
    ) async throws -> (
        archive: DownloadedSchemaArchive,
        source: RimeSchemeSourceVariant,
        archiveSHA256: String
    ) {
        var lastTransportError: Error?
        for source in sources {
            try ensureActive(operationID)
            rimeIceDownloadState = .downloading(
                schemeName: schemeName,
                sourceName: source.displayName,
                progress: nil
            )
            do {
                let archive = try await archiveDownloader.downloadArchive(from: source) { [weak self] fraction in
                    Task { @MainActor in
                        guard let self, self.activeDownloadOperationID == operationID else { return }
                        guard case .downloading(let name, let sourceName, _) = self.rimeIceDownloadState,
                            name == schemeName, sourceName == source.displayName
                        else { return }
                        self.rimeIceDownloadState = .downloading(
                            schemeName: schemeName,
                            sourceName: source.displayName,
                            progress: fraction
                        )
                    }
                }
                let archiveSHA256: String
                do {
                    // Once URLSession has produced a copied temporary file, every
                    // cancellation or verification failure must remove that file.
                    try ensureActive(operationID)
                    archiveSHA256 = try await Task.detached(priority: .userInitiated) {
                        try self.artifactVerifier.verifyArchive(at: archive.localURL, source: source)
                    }.value
                } catch {
                    archiveInstaller.removeTemporaryItem(at: archive.localURL)
                    throw error
                }
                return (archive, source, archiveSHA256)
            } catch is CancellationError {
                throw CancellationError()
            } catch let error as DownloadError where error == .integrityMismatch {
                throw error
            } catch {
                lastTransportError = error
            }
        }
        throw lastTransportError ?? DownloadError.allSourcesUnavailable
    }

    private func ensureActive(_ operationID: UUID) throws {
        try Task.checkCancellation()
        guard activeDownloadOperationID == operationID else { throw CancellationError() }
    }

    private func findSchemaFile(named name: String, in root: URL) async -> URL? {
        await Task.detached(priority: .userInitiated) {
            let fileManager = FileManager.default
            var pendingDirectories = [root]
            while let directory = pendingDirectories.popLast() {
                let children =
                    (try? fileManager.contentsOfDirectory(
                        at: directory,
                        includingPropertiesForKeys: [.isDirectoryKey],
                        options: [.skipsHiddenFiles]
                    )) ?? []
                for url in children {
                    if url.lastPathComponent == name { return url }
                    if (try? url.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) == true {
                        pendingDirectories.append(url)
                    }
                }
            }
            return nil
        }.value
    }

    private func stripLuaIfNeeded(at schemaURL: URL) async throws {
        try await Task.detached(priority: .userInitiated) {
            let schemaContent = try String(contentsOf: schemaURL, encoding: .utf8)
            let processed = RimeConfigPostProcessor.stripLuaDependencies(from: schemaContent)
            guard RimeConfigPostProcessor.validateStrippedSchema(processed) else {
                throw DownloadError.postProcessingFailed("高级功能兼容处理后配置无效")
            }
            try processed.write(to: schemaURL, atomically: true, encoding: .utf8)
        }.value
    }

    private func sanitizeT9SchemaIfPresent(in extractionDirectory: URL) async throws {
        let t9URL = extractionDirectory.appendingPathComponent("t9.schema.yaml")
        guard FileManager.default.fileExists(atPath: t9URL.path) else {
            throw DownloadError.corruptArchive
        }
        try await Task.detached(priority: .userInitiated) {
            let upstream = try String(contentsOf: t9URL, encoding: .utf8)
            let compatible = try T9SchemaCompatibility.makeCompatibleSchema(fromUpstreamYAML: upstream)
            try compatible.write(to: t9URL, atomically: true, encoding: .utf8)
        }.value
    }

    private func persistVerifiedInstallation(
        entry: RimeSchemeCatalogEntry,
        manifest: RimeSchemeArtifactManifest,
        source: RimeSchemeSourceVariant,
        archiveSHA256: String,
        stagedContentSHA256: String
    ) {
        if let key = entry.storage.version { settings.set(manifest.version, forKey: key) }
        if let key = entry.storage.installed { settings.set(true, forKey: key) }
        if let key = entry.storage.sourceVariant { settings.set(source.id, forKey: key) }
        if let key = entry.storage.checksum { settings.set(archiveSHA256, forKey: key) }
        if let key = entry.storage.stagedContentChecksum {
            settings.set(stagedContentSHA256, forKey: key)
        }
        settings.synchronize()
    }

    private func cleanupTemporaryItems(_ urls: [URL]) {
        for url in Set(urls) {
            archiveInstaller.removeTemporaryItem(at: url)
        }
    }
}
