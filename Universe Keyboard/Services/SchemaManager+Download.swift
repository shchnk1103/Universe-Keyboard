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
        switch downloadState {
        case .idle, .completed, .failed:
            break
        default:
            return
        }

        guard let entry = downloadableEntry(for: schemaID), licenseAccepted(for: schemaID) else { return }
        if let plan = entry.installationPlan {
            archiveInstaller.clearBuildCache(plan: plan)
        }
        // Force still verifies archive/staged identity; identical-receipt no-op is
        // bypassed so a deliberate reinstall can repair same-identity corruption.
        startVerifiedDownload(schemaID: schemaID, force: true)
    }

    func fetchAndDownload() async {
        await fetchAndDownload(schemaID: "rime_ice")
    }

    func fetchAndDownload(schemaID: String) async {
        let operationID = activeDownloadOperationID ?? UUID()
        activeDownloadOperationID = operationID
        await fetchAndDownload(schemaID: schemaID, operationID: operationID, force: false)
    }

    private func fetchAndDownload(schemaID: String, operationID: UUID, force: Bool) async {
        let schemeName = downloadSchemeDisplayName(for: schemaID)
        var temporaryItems: [URL] = []
        var diagnosticContext: DiagnosticEvent.SchemeDeliveryContext?
        var ownsCommitLease = false
        var installed = false
        var deployed = false
        var upgradeCheckpoint: SchemaUpgradeCheckpoint?
        let priorActiveSchemaID = activeSchemaID

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
            let selectionContext = diagnosticContext
            let diagnostics = deliveryDiagnostics
            let selectedSource = try await sourceSelector.selectSource(
                from: manifest.sourceVariants,
                preferredSourceID: preferredSourceID,
                onProbe: { source, result in
                    guard let context = selectionContext,
                        case .rejected(let reason) = result,
                        let sourceID = SchemeDeliveryDiagnosticMapper.source(source.id)
                    else { return }
                    diagnostics.record(
                        .phaseChanged(
                            .init(
                                context: context, attempt: nil, source: sourceID, host: nil,
                                phase: .selecting, result: .failed, probeFailure: reason
                            )))
                }
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

            downloadState = .extracting(schemeName: schemeName)
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

            downloadState = .postProcessing(schemeName: schemeName)
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
            // P3: Ice T9 sanitize via SchemePostExtractHooks (no literal schemaID fork).
            if SchemeAdapterRegistry.shouldSanitizeT9OnExtract(for: schemaID) {
                try await sanitizeT9SchemaIfPresent(in: extractDir)
            }
            // SharedDefault post-extract via SchemeAdapter registry
            // (Ice / Wanxiang privatePreset; Luna no-op).
            try await applySharedDefaultPostExtractIfNeeded(for: schemaID, in: extractDir)
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

            // CS-03/04: identical staged identity vs installed receipt → idempotent
            // no-op (no checkpoint, no live replace, no selection thrash). Force
            // redownload bypasses this gate.
            if !force,
                shouldSkipIdenticalReinstall(
                    schemaID: schemaID,
                    stagedContentSHA256: stagedContentSHA256
                )
            {
                cleanupTemporaryItems(temporaryItems)
                activeDownloadOperationID = nil
                currentDownloadTask = nil
                downloadState = .completed(schemeName: schemeName)
                refreshSchemaList()
                recordTerminal(
                    diagnosticContext,
                    result: .completed,
                    installed: true,
                    deployed: true,
                    failure: nil
                )
                return
            }

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
            // Wanxiang upgrade-only: checkpoint prior generation before live replace.
            upgradeCheckpoint = try archiveInstaller.createUpgradeCheckpoint(
                plan: plan,
                luaAvailable: luaAvailable
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

            // P3: Ice T9 pre-deploy ensure via SchemePostExtractHooks (behavior unchanged).
            if SchemeAdapterRegistry.shouldEnsureCompatibleT9PreDeploy(for: schemaID),
                let shared = archiveInstaller.sharedDataDirectoryURL()
            {
                // T9 compatibility rewriting must precede deployment so RIME compiles
                // the sanitized schema instead of the upstream Lua-dependent version.
                _ = try T9DeploymentSupport.ensureCompatibleT9Schema(in: shared)
            }

            downloadState = .deploying(schemeName: schemeName)
            recordPhase(
                diagnosticContext,
                attempt: archiveResult.attempt,
                source: source,
                host: archive.finalHost,
                phase: .deploying,
                result: .started
            )
            // Shared manager seam: activate → deploy; on failure restore checkpoint /
            // prior selection (same path Q-UR-P2-01 pins). Receipt stays below.
            let deploymentSucceeded = await deployInstalledUpgradeOrRestoreOnFailure(
                schemaID: schemaID,
                checkpoint: &upgradeCheckpoint,
                priorActiveSchemaID: priorActiveSchemaID,
                leaseOperationID: operationID
            )
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
            if let checkpoint = upgradeCheckpoint {
                archiveInstaller.commitUpgradeCheckpoint(checkpoint)
                upgradeCheckpoint = nil
            }
            if schemaID == "rime_ice" {
                rimeIceVersion = manifest.version
            }
            recordPhase(diagnosticContext, phase: .committingReceipt, result: .succeeded)

            cleanupTemporaryItems(temporaryItems)
            activeDownloadOperationID = nil
            currentDownloadTask = nil
            downloadState = .completed(schemeName: schemeName)
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
            restoreAfterFailedUpgradeIfNeeded(
                checkpoint: &upgradeCheckpoint,
                priorActiveSchemaID: priorActiveSchemaID
            )
            if activeDownloadOperationID == operationID {
                activeDownloadOperationID = nil
                downloadState = .idle
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
            restoreAfterFailedUpgradeIfNeeded(
                checkpoint: &upgradeCheckpoint,
                priorActiveSchemaID: priorActiveSchemaID
            )
            let failureMessage: String
            if upgradeCheckpoint != nil {
                // Restore failed: retain checkpoint and surface distinct recovery type.
                failureMessage = DownloadError.userFacingDescription(
                    for: SchemaUpgradeRecoveryError.upgradeRollbackIncomplete
                )
            } else if error is SchemaUpgradeRecoveryError {
                failureMessage = DownloadError.userFacingDescription(for: error)
            } else {
                failureMessage = DownloadError.userFacingDescription(for: error)
            }
            if activeDownloadOperationID == operationID {
                activeDownloadOperationID = nil
                currentDownloadTask = nil
                downloadState = .failed(
                    schemaID: schemaID,
                    schemeName: schemeName,
                    message: failureMessage
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

    private func startVerifiedDownload(schemaID: String, force: Bool = false) {
        let operationID = UUID()
        activeDownloadOperationID = operationID
        let schemeName = downloadSchemeDisplayName(for: schemaID)
        downloadState = .fetchingReleaseInfo(schemeName: schemeName)
        currentDownloadTask = Task { [weak self] in
            await self?.fetchAndDownload(
                schemaID: schemaID,
                operationID: operationID,
                force: force
            )
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
            downloadState = .downloading(
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
                        guard case .downloading(let name, let sourceName, _) = self.downloadState,
                            name == schemeName, sourceName == source.displayName
                        else { return }
                        self.downloadState = .downloading(
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
        case .sourceArtifactChanged:
            return .sourceArtifactChanged
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
    ///
    /// P3: post-process revision comes from the registry for any id (nil when unknown).
    /// Download production paths pass letter schema ids; `t9` inherits Ice via normalize.
    private func postProcessingRevision(for schemaID: String) -> String? {
        SchemeAdapterRegistry.postProcessingRevision(for: schemaID)
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

    /// SharedDefault post-extract via `SchemeAdapterRegistry` (Ice / Wanxiang
    /// `privatePreset`; Luna / consumePrelude no-op).
    private func applySharedDefaultPostExtractIfNeeded(
        for schemaID: String,
        in extractionDirectory: URL
    ) async throws {
        guard SchemeAdapterRegistry.sharedDefaultApplicator(for: schemaID) != nil else {
            return
        }
        try await Task.detached(priority: .userInitiated) {
            do {
                try SchemeAdapterRegistry.applySharedDefaultPostExtract(
                    for: schemaID,
                    in: extractionDirectory
                )
            } catch {
                throw DownloadError.postProcessingFailed("方案公共配置无法改写为独立预设")
            }
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

    /// Manager-level seam for Wanxiang upgrade deploy-failure (Q-UR-P2-01).
    /// After checkpoint + live install, activates the target scheme and attempts
    /// `deployRimeConfig`. On deploy failure runs `restoreAfterFailedUpgradeIfNeeded`
    /// (prior generation restore and/or retained checkpoint + prior selection).
    /// Does **not** call `persistVerifiedInstallation` — receipt remains gated to
    /// the success path in `fetchAndDownload` after this returns `true`.
    @discardableResult
    func deployInstalledUpgradeOrRestoreOnFailure(
        schemaID: String,
        checkpoint: inout SchemaUpgradeCheckpoint?,
        priorActiveSchemaID: String,
        leaseOperationID: UUID? = nil
    ) async -> Bool {
        activateSchema(schemaID, leaseOperationID: leaseOperationID)
        let deploymentSucceeded = await deployRimeConfig(leaseOperationID: leaseOperationID)
        guard deploymentSucceeded else {
            restoreAfterFailedUpgradeIfNeeded(
                checkpoint: &checkpoint,
                priorActiveSchemaID: priorActiveSchemaID
            )
            return false
        }
        return true
    }

    /// Restores a Wanxiang upgrade checkpoint when present and returns prior
    /// scheme selection. On restore failure the checkpoint is retained and the
    /// inout remains non-nil so callers can surface upgrade recovery-required.
    /// Internal so manager-level tests can pin the deploy-failure exit seam.
    func restoreAfterFailedUpgradeIfNeeded(
        checkpoint: inout SchemaUpgradeCheckpoint?,
        priorActiveSchemaID: String
    ) {
        if let activeCheckpoint = checkpoint {
            do {
                try archiveInstaller.restoreUpgradeCheckpoint(activeCheckpoint)
                checkpoint = nil
            } catch {
                // Retain the only surviving prior-generation copy.
                Logger.shared.error(
                    "upgrade: 回滚未完成，升级检查点已保留",
                    category: .deployment
                )
            }
        }
        if activeSchemaID != priorActiveSchemaID {
            setActiveSchemaWithoutDeployment(priorActiveSchemaID)
        }
    }

    /// Returns true when an installed receipt already matches the staged content
    /// about to be committed. Callers skip destructive replace / upgrade
    /// checkpoint and keep the current scheme selection.
    func shouldSkipIdenticalReinstall(schemaID: String, stagedContentSHA256: String) -> Bool {
        guard !stagedContentSHA256.isEmpty,
            let entry = downloadableEntry(for: schemaID),
            let installedKey = entry.storage.installed,
            settings.bool(forKey: installedKey),
            let plan = entry.installationPlan,
            archiveInstaller.containsInstalledSchema(plan: plan),
            let stagedKey = entry.storage.stagedContentChecksum,
            settings.string(forKey: stagedKey) == stagedContentSHA256
        else {
            return false
        }
        return true
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
