import Foundation
import KeyboardCore

extension SchemaManager {
    func forceRedownload() {
        forceRedownload(schemaID: "rime_ice")
    }

    func forceRedownload(schemaID: String) {
        guard schemeDeliveryCommitLeaseOperationID == nil else {
            enqueueSchemeMutation(.startDownload(schemaID: schemaID, force: true))
            return
        }
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
        var diagnosticContext: DiagnosticEvent.SchemeDeliveryContext?
        var ownsCommitLease = false
        var installed = false
        var deployed = false

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
            let resolvedIdentities = try manifest.sourceVariants.map {
                try manifest.resolvedStagedIdentity(for: $0)
            }
            guard let stagedIdentity = resolvedIdentities.first,
                resolvedIdentities.allSatisfy({ $0 == stagedIdentity })
            else {
                throw DownloadError.invalidArtifactManifest
            }
            guard let postProcessingRevision = postProcessingRevision(for: schemaID) else {
                throw DownloadError.invalidArtifactManifest
            }
            try manifest.validateImplementationBinding(
                stagedIdentity,
                installationPlan: plan,
                postProcessingRevision: postProcessingRevision
            )
            diagnosticContext = SchemeDeliveryDiagnosticMapper.context(
                operationID: operationID,
                identity: stagedIdentity
            )
            recordPhase(diagnosticContext, phase: .selecting, result: .started)
            let preferredSourceID = entry.storage.sourceVariant.flatMap {
                settings.string(forKey: $0)
            }
            let selectedSource = try await sourceSelector.selectSource(
                from: manifest.sourceVariants,
                preferredSourceID: preferredSourceID
            )
            try ensureActive(operationID)
            recordPhase(
                diagnosticContext,
                source: selectedSource,
                phase: .selecting,
                result: .succeeded
            )

            let sources = [selectedSource] + manifest.sourceVariants.filter { $0.id != selectedSource.id }
            let archiveResult = try await downloadFirstValidArchive(
                from: sources,
                schemeName: schemeName,
                operationID: operationID,
                diagnosticContext: diagnosticContext
            )
            let archive = archiveResult.archive
            temporaryItems.append(archive.localURL)
            let source = archiveResult.source
            let archiveSHA256 = archiveResult.archiveSHA256
            let diskNeeded = source.expectedByteCount * 3 + 100_000_000
            try checkDiskSpace(needed: diskNeeded)
            try ensureActive(operationID)

            rimeIceDownloadState = .extracting(schemeName: schemeName)
            recordPhase(
                diagnosticContext,
                attempt: archiveResult.attempt,
                source: source,
                host: archive.finalHost,
                phase: .extracting,
                result: .started
            )
            let extractDir = try archiveInstaller.prepareExtractionDirectory(for: distribution)
            temporaryItems.append(extractDir)
            _ = try await Task.detached(priority: .userInitiated) {
                try Unzip.extract(zipPath: archive.localURL.path, to: extractDir)
            }.value
            try ensureActive(operationID)
            recordPhase(
                diagnosticContext,
                attempt: archiveResult.attempt,
                source: source,
                host: archive.finalHost,
                phase: .extracting,
                result: .succeeded
            )

            guard let schemaURL = await findSchemaFile(named: plan.schemaFileName, in: extractDir) else {
                throw DownloadError.corruptArchive
            }

            rimeIceDownloadState = .postProcessing(schemeName: schemeName)
            recordPhase(
                diagnosticContext,
                attempt: archiveResult.attempt,
                source: source,
                host: archive.finalHost,
                phase: .postProcessing,
                result: .started
            )
            let luaAvailable = (settings.object(forKey: "rime_lua_available") as? Bool) ?? true
            if !luaAvailable {
                try await stripLuaIfNeeded(at: schemaURL)
            }
            if schemaID == "rime_ice" {
                try await sanitizeT9SchemaIfPresent(in: extractDir)
            }
            try ensureActive(operationID)
            recordPhase(
                diagnosticContext,
                attempt: archiveResult.attempt,
                source: source,
                host: archive.finalHost,
                phase: .postProcessing,
                result: .succeeded
            )

            let verifier = artifactVerifier
            recordPhase(
                diagnosticContext,
                attempt: archiveResult.attempt,
                source: source,
                host: archive.finalHost,
                phase: .verifyingStagedContent,
                result: .started
            )
            let stagedContentSHA256 = try await Task.detached(priority: .userInitiated) {
                try verifier.stagedContentSHA256(
                    in: extractDir,
                    plan: plan,
                    luaAvailable: luaAvailable
                )
            }.value
            let expectedStagedSHA256 =
                luaAvailable
                ? stagedIdentity.stagedContentSHA256WithLua
                : stagedIdentity.stagedContentSHA256WithoutLua
            guard !expectedStagedSHA256.isEmpty,
                stagedContentSHA256 == expectedStagedSHA256
            else {
                let failure = DownloadIntegrityFailure.stagedContent(
                    expected: expectedStagedSHA256,
                    actual: stagedContentSHA256
                )
                recordIntegrityFailure(
                    failure,
                    context: diagnosticContext,
                    attempt: archiveResult.attempt,
                    source: source,
                    host: archive.finalHost
                )
                throw DownloadError.integrityMismatch(failure)
            }
            try ensureActive(operationID)
            recordPhase(
                diagnosticContext,
                attempt: archiveResult.attempt,
                source: source,
                host: archive.finalHost,
                phase: .verifyingStagedContent,
                result: .succeeded
            )

            try await acquireActiveSchemeDeliveryCommitLease(operationID: operationID)
            ownsCommitLease = true
            recordPhase(
                diagnosticContext,
                attempt: archiveResult.attempt,
                source: source,
                host: archive.finalHost,
                phase: .installing,
                result: .started
            )
            try installSchemaFiles(from: extractDir, plan: plan, luaAvailable: luaAvailable)
            installed = true
            try ensureActive(operationID)
            recordPhase(
                diagnosticContext,
                attempt: archiveResult.attempt,
                source: source,
                host: archive.finalHost,
                phase: .installing,
                result: .succeeded
            )

            if schemaID == "rime_ice", let shared = archiveInstaller.sharedDataDirectoryURL() {
                // T9 compatibility rewriting must precede deployment so RIME compiles
                // the sanitized schema instead of the upstream Lua-dependent version.
                _ = try T9DeploymentSupport.ensureCompatibleT9Schema(in: shared)
            }

            activateSchema(schemaID, leaseOperationID: operationID)
            rimeIceDownloadState = .deploying(schemeName: schemeName)
            recordPhase(
                diagnosticContext,
                attempt: archiveResult.attempt,
                source: source,
                host: archive.finalHost,
                phase: .deploying,
                result: .started
            )
            let deploymentSucceeded = await deployRimeConfig(leaseOperationID: operationID)
            try ensureActive(operationID)
            guard deploymentSucceeded else {
                throw DownloadError.deploymentFailed
            }
            deployed = true
            recordPhase(
                diagnosticContext,
                attempt: archiveResult.attempt,
                source: source,
                host: archive.finalHost,
                phase: .deploying,
                result: .succeeded
            )

            recordPhase(diagnosticContext, phase: .committingReceipt, result: .started)
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
            recordPhase(diagnosticContext, phase: .committingReceipt, result: .succeeded)

            cleanupTemporaryItems(temporaryItems)
            activeDownloadOperationID = nil
            currentDownloadTask = nil
            rimeIceDownloadState = .completed(schemeName: schemeName)
            refreshSchemaList()
            recordTerminal(
                diagnosticContext,
                result: .completed,
                installed: installed,
                deployed: deployed,
                failure: nil
            )
            if ownsCommitLease {
                releaseSchemeDeliveryCommitLease(operationID: operationID)
                ownsCommitLease = false
            }
        } catch is CancellationError {
            cleanupTemporaryItems(temporaryItems)
            if activeDownloadOperationID == operationID {
                activeDownloadOperationID = nil
                rimeIceDownloadState = .idle
            }
            recordTerminal(
                diagnosticContext,
                result: .cancelled,
                installed: installed,
                deployed: deployed,
                failure: nil
            )
            if ownsCommitLease {
                releaseSchemeDeliveryCommitLease(operationID: operationID)
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
            recordTerminal(
                diagnosticContext,
                result: .failed,
                installed: installed,
                deployed: deployed,
                failure: terminalFailure(for: error)
            )
            if ownsCommitLease {
                releaseSchemeDeliveryCommitLease(operationID: operationID)
            }
        }
    }

    func beginVerifiedDownload(schemaID: String) {
        startVerifiedDownload(schemaID: schemaID)
    }

    /// Acquires the shared mutation lease and rolls it back if cancellation or
    /// operation-generation invalidation is observed immediately after the
    /// suspension point. A caller that returns successfully owns the lease.
    func acquireActiveSchemeDeliveryCommitLease(operationID: UUID) async throws {
        let acquired = await acquireSchemeDeliveryCommitLease(operationID: operationID)
        if !acquired, Task.isCancelled {
            throw CancellationError()
        }
        guard acquired else {
            throw DownloadError.deploymentFailed
        }
        do {
            try ensureActive(operationID)
        } catch {
            releaseSchemeDeliveryCommitLease(operationID: operationID)
            throw error
        }
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

    func downloadFirstValidArchive(
        from sources: [RimeSchemeSourceVariant],
        schemeName: String,
        operationID: UUID, diagnosticContext: DiagnosticEvent.SchemeDeliveryContext?
    ) async throws -> (
        archive: DownloadedSchemaArchive,
        source: RimeSchemeSourceVariant,
        archiveSHA256: String,
        attempt: DiagnosticEvent.SchemeDeliveryAttempt
    ) {
        var lastRecoverableError: Error?
        var archiveIntegrityFailureCount = 0
        var sawArchiveSizeFailure = false
        var sawArchiveDigestFailure = false
        let verifier = artifactVerifier
        for (index, source) in sources.enumerated() {
            let attempt = DiagnosticEvent.SchemeDeliveryAttempt(index + 1)!
            try ensureActive(operationID)
            rimeIceDownloadState = .downloading(
                schemeName: schemeName,
                sourceName: source.displayName,
                progress: nil
            )
            recordPhase(
                diagnosticContext,
                attempt: attempt,
                source: source,
                phase: .downloading,
                result: .started
            )
            do {
                let attemptID = UUID()
                let archive = try await archiveDownloader.downloadArchive(
                    from: source,
                    operationID: operationID,
                    attemptID: attemptID
                ) { [weak self] fraction in
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
                recordPhase(
                    diagnosticContext,
                    attempt: attempt,
                    source: source,
                    host: archive.finalHost,
                    phase: .downloading,
                    result: .succeeded
                )
                let archiveSHA256: String
                do {
                    // Once URLSession has produced a copied temporary file, every
                    // cancellation or verification failure must remove that file.
                    try ensureActive(operationID)
                    recordPhase(
                        diagnosticContext,
                        attempt: attempt,
                        source: source,
                        host: archive.finalHost,
                        phase: .verifyingArchiveSize,
                        result: .started
                    )
                    try await Task.detached(priority: .userInitiated) {
                        try verifier.verifyArchiveSize(at: archive.localURL, source: source)
                    }.value
                    recordPhase(
                        diagnosticContext,
                        attempt: attempt,
                        source: source,
                        host: archive.finalHost,
                        phase: .verifyingArchiveSize,
                        result: .succeeded
                    )
                    recordPhase(
                        diagnosticContext,
                        attempt: attempt,
                        source: source,
                        host: archive.finalHost,
                        phase: .verifyingArchiveDigest,
                        result: .started
                    )
                    archiveSHA256 = try await Task.detached(priority: .userInitiated) {
                        try verifier.verifyArchiveDigest(at: archive.localURL, source: source)
                    }.value
                    recordPhase(
                        diagnosticContext,
                        attempt: attempt,
                        source: source,
                        host: archive.finalHost,
                        phase: .verifyingArchiveDigest,
                        result: .succeeded
                    )
                } catch {
                    if case DownloadError.integrityMismatch(let failure) = error,
                        failure.permitsPinnedSourceFallback
                    {
                        recordIntegrityFailure(
                            failure,
                            context: diagnosticContext,
                            attempt: attempt,
                            source: source,
                            host: archive.finalHost
                        )
                        recordPhase(
                            diagnosticContext,
                            attempt: attempt,
                            source: source,
                            host: archive.finalHost,
                            phase: .cleanup,
                            result: .started
                        )
                        let receipt = try await temporaryArtifactCleaner.removeAndVerifyAbsent(
                            archive.ownedTemporaryArtifact
                        )
                        try ensureActive(operationID)
                        guard receipt.provesRemoval(of: archive.ownedTemporaryArtifact) else {
                            throw DownloadError.temporaryCleanupFailed
                        }
                        recordPhase(
                            diagnosticContext,
                            attempt: attempt,
                            source: source,
                            host: archive.finalHost,
                            phase: .cleanup,
                            result: .succeeded
                        )
                        lastRecoverableError = error
                        archiveIntegrityFailureCount += 1
                        switch failure {
                        case .archiveSize:
                            sawArchiveSizeFailure = true
                        case .archiveDigest:
                            sawArchiveDigestFailure = true
                        case .stagedContent:
                            preconditionFailure("staged-content mismatch cannot enter archive fallback")
                        }
                        if index < sources.count - 1 {
                            recordFallback(
                                context: diagnosticContext,
                                attempt: attempt,
                                from: source,
                                to: sources[index + 1],
                                fromHost: archive.finalHost,
                                reason: fallbackReason(for: failure)
                            )
                        }
                        // The last integrity failure also reaches the loop
                        // aggregate below instead of escaping as a misleading
                        // single-source mismatch.
                        continue
                    } else {
                        archiveInstaller.removeTemporaryItem(at: archive.localURL)
                    }
                    throw error
                }
                return (archive, source, archiveSHA256, attempt)
            } catch is CancellationError {
                throw CancellationError()
            } catch let error as DownloadError where error == .temporaryCleanupFailed {
                throw error
            } catch {
                // Only ordinary transport failures may fall through to the next
                // pinned source here. Verifier/filesystem failures remain
                // fail-closed unless the classified archive mismatch branch
                // above has already crossed the exact cleanup barrier.
                guard isTransportFailure(error) else { throw error }
                lastRecoverableError = error
                if index < sources.count - 1 {
                    recordFallback(
                        context: diagnosticContext,
                        attempt: attempt,
                        from: source,
                        to: sources[index + 1],
                        reason: .transport
                    )
                }
            }
        }
        if archiveIntegrityFailureCount == sources.count {
            let aggregate: DownloadIntegrityAggregate
            switch (sawArchiveSizeFailure, sawArchiveDigestFailure) {
            case (true, false): aggregate = .archiveSize
            case (false, true): aggregate = .archiveDigest
            case (true, true): aggregate = .mixed
            case (false, false): preconditionFailure("archive failures require a classification")
            }
            throw DownloadError.allSourcesFailedIntegrity(aggregate)
        }
        throw lastRecoverableError ?? DownloadError.allSourcesUnavailable
    }

    private func recordPhase(
        _ context: DiagnosticEvent.SchemeDeliveryContext?,
        attempt: DiagnosticEvent.SchemeDeliveryAttempt? = nil,
        source: RimeSchemeSourceVariant? = nil,
        host: String? = nil,
        phase: DiagnosticEvent.SchemeDeliveryPhase,
        result: DiagnosticEvent.SchemeDeliveryResult
    ) {
        guard let context else { return }
        deliveryDiagnostics.record(
            .phaseChanged(
                .init(
                    context: context,
                    attempt: attempt,
                    source: source.flatMap { SchemeDeliveryDiagnosticMapper.source($0.id) },
                    host: host.flatMap(SchemeDeliveryDiagnosticMapper.host),
                    phase: phase,
                    result: result
                )
            )
        )
    }

    private func recordIntegrityFailure(
        _ failure: DownloadIntegrityFailure,
        context: DiagnosticEvent.SchemeDeliveryContext?,
        attempt: DiagnosticEvent.SchemeDeliveryAttempt,
        source: RimeSchemeSourceVariant,
        host: String
    ) {
        guard let context,
            let sourceID = SchemeDeliveryDiagnosticMapper.source(source.id),
            let host = SchemeDeliveryDiagnosticMapper.host(host),
            let observation = SchemeDeliveryDiagnosticMapper.observation(failure)
        else { return }
        deliveryDiagnostics.record(
            .integrityFailed(
                .init(
                    context: context,
                    attempt: attempt,
                    source: sourceID,
                    host: host,
                    observation: observation
                )
            )
        )
    }

    private func recordFallback(
        context: DiagnosticEvent.SchemeDeliveryContext?,
        attempt: DiagnosticEvent.SchemeDeliveryAttempt,
        from: RimeSchemeSourceVariant,
        to: RimeSchemeSourceVariant,
        fromHost: String? = nil,
        toHost: String? = nil,
        reason: DiagnosticEvent.SchemeDeliveryFallbackReason?
    ) {
        guard let context,
            let from = SchemeDeliveryDiagnosticMapper.source(from.id),
            let to = SchemeDeliveryDiagnosticMapper.source(to.id),
            let reason
        else { return }
        deliveryDiagnostics.record(
            .fallback(
                .init(
                    context: context,
                    fromAttempt: attempt,
                    toAttempt: DiagnosticEvent.SchemeDeliveryAttempt(attempt.value + 1)!,
                    from: from,
                    to: to,
                    fromHost: fromHost.flatMap(SchemeDeliveryDiagnosticMapper.host),
                    toHost: toHost.flatMap(SchemeDeliveryDiagnosticMapper.host),
                    reason: reason
                )
            )
        )
    }

    private func fallbackReason(
        for failure: DownloadIntegrityFailure
    ) -> DiagnosticEvent.SchemeDeliveryFallbackReason? {
        switch failure {
        case .archiveSize: .archiveSize
        case .archiveDigest: .archiveDigest
        case .stagedContent: nil
        }
    }

    private func isTransportFailure(_ error: Error) -> Bool {
        if error is URLError { return true }
        if case DownloadError.networkError = error { return true }
        return false
    }

    private func recordTerminal(
        _ context: DiagnosticEvent.SchemeDeliveryContext?,
        result: DiagnosticEvent.SchemeDeliveryTerminalResult,
        installed: Bool,
        deployed: Bool,
        failure: DiagnosticEvent.SchemeDeliveryTerminalFailure?
    ) {
        guard let context else { return }
        deliveryDiagnostics.record(
            .terminal(
                .init(
                    context: context,
                    result: result,
                    installed: installed,
                    deployed: deployed,
                    failure: failure
                )
            )
        )
    }

    private func terminalFailure(for error: Error) -> DiagnosticEvent.SchemeDeliveryTerminalFailure {
        if error is URLError { return .transport }
        guard let error = error as? DownloadError else { return .localIO }
        switch error {
        case .networkError, .gitHubRateLimit:
            return .transport
        case .unsupportedScheme, .invalidArtifactManifest:
            return .invalidManifest
        case .allSourcesUnavailable:
            return .allSourcesUnavailable
        case .allSourcesFailedIntegrity(let aggregate):
            switch aggregate {
            case .archiveSize: return .allSourcesArchiveSize
            case .archiveDigest: return .allSourcesArchiveDigest
            case .mixed: return .allSourcesMixedIntegrity
            }
        case .integrityMismatch(let failure):
            switch failure {
            case .archiveSize: return .archiveSize
            case .archiveDigest: return .archiveDigest
            case .stagedContent: return .stagedContent
            }
        case .temporaryArtifactRegistrationFailed:
            return .temporaryArtifact
        case .temporaryCleanupFailed:
            return .cleanup
        case .corruptArchive, .extractionFailed:
            return .extraction
        case .postProcessingFailed:
            return .postProcessing
        case .deploymentFailed:
            return .deployment
        case .diskSpaceInsufficient:
            return .localIO
        }
    }

    /// Bump this reviewed value whenever deterministic processing for the
    /// corresponding scheme changes. A stale manifest then fails before bytes
    /// are downloaded or installed.
    private func postProcessingRevision(for schemaID: String) -> String? {
        switch schemaID {
        case "rime_ice": "rime-ice-post-1"
        case "wanxiang": "wanxiang-post-1"
        default: nil
        }
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
