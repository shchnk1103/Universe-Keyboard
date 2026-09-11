import Dispatch
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
        let operationStartedAt = DispatchTime.now().uptimeNanoseconds
        guard await acquireSchemeDeliveryCommitLease(operationID: operationID) else { return }
        defer { releaseSchemeDeliveryCommitLease(operationID: operationID) }

        let schemaID = entry.schemaID
        let routeSnapshot = currentRuntimeRouteSnapshot()
        recordActiveUninstallRoutePhase(
            operationID: operationID,
            phase: "route_before",
            route: routeSnapshot.effectiveRoute,
            operationStartedAt: operationStartedAt
        )
        let routeMutation: RimeRuntimeRouteMutation?
        switch RimeRuntimeRouteReconciler.reconcileAfterSchemaRemoval(
            snapshot: routeSnapshot,
            removedSchemaID: schemaID
        ) {
        case .success(let mutation):
            routeMutation = mutation
            // Do not use `switchToSchema`: that path defers deployment. The
            // route state must be durable before Luna deploys and before files
            // belonging to the effective route can become removable.
            applyRuntimeRouteState(mutation.after)
            recordActiveUninstallRoutePhase(
                operationID: operationID,
                phase: "route_after_deploy_pending",
                route: mutation.after.effectiveRoute,
                operationStartedAt: operationStartedAt
            )
            let fallbackSucceeded = await deployRimeConfig(leaseOperationID: operationID)
            guard fallbackSucceeded else {
                recordActiveUninstallRoutePhase(
                    operationID: operationID,
                    phase: "fallback_deploy_failed",
                    route: mutation.after.effectiveRoute,
                    isFailure: true,
                    operationStartedAt: operationStartedAt
                )
                await restoreSchemaAfterFailedUninstall(
                    mutation.before,
                    operationID: operationID,
                    reason: "Luna 回退部署失败",
                    operationStartedAt: operationStartedAt
                )
                return
            }
            recordActiveUninstallRoutePhase(
                operationID: operationID,
                phase: "fallback_deploy_succeeded",
                route: mutation.after.effectiveRoute,
                operationStartedAt: operationStartedAt
            )
        case .failure(.inactiveRoute):
            routeMutation = nil
            recordActiveUninstallRoutePhase(
                operationID: operationID,
                phase: "inactive_route",
                route: routeSnapshot.effectiveRoute,
                operationStartedAt: operationStartedAt
            )
        case .failure:
            // A malformed route descriptor must not be reclassified as an
            // inactive uninstall: preserving target files is safer than
            // deleting resources that a contradictory route may still use.
            recordActiveUninstallRoutePhase(
                operationID: operationID,
                phase: "reconciliation_failed",
                route: routeSnapshot.effectiveRoute,
                isFailure: true,
                operationStartedAt: operationStartedAt
            )
            return
        }

        let staging: SchemaUninstallStaging
        do {
            recordActiveUninstallRoutePhase(
                operationID: operationID,
                phase: "staging_started",
                route: routeMutation?.after.effectiveRoute ?? routeSnapshot.effectiveRoute,
                operationStartedAt: operationStartedAt
            )
            staging = try archiveInstaller.stageSchemaUninstall(plan: plan)
        } catch is SchemaUninstallRecoveryError {
            // The original resource tree may be incomplete. Keep the deployed
            // fallback and the recovery files; do not redeploy the broken tree.
            Logger.shared.error(
                "uninstallSchema: 回滚未完成，恢复文件已保留，停止卸载",
                category: .deployment
            )
            recordActiveUninstallRoutePhase(
                operationID: operationID,
                phase: "staging_rollback_incomplete",
                route: routeMutation?.after.effectiveRoute ?? routeSnapshot.effectiveRoute,
                isFailure: true,
                operationStartedAt: operationStartedAt
            )
            return
        } catch {
            recordActiveUninstallRoutePhase(
                operationID: operationID,
                phase: "staging_failed",
                route: routeMutation?.after.effectiveRoute ?? routeSnapshot.effectiveRoute,
                isFailure: true,
                operationStartedAt: operationStartedAt
            )
            if let routeMutation {
                await restoreSchemaAfterFailedUninstall(
                    routeMutation.before,
                    operationID: operationID,
                    reason: "方案文件暂存失败",
                    operationStartedAt: operationStartedAt
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
        // P1-5: route Ice uninstall layout fallback via SchemeUninstallHooks
        // (behavior unchanged; no Discovery A/B UI).
        SchemeAdapterRegistry.prepareUninstallLayoutFallback(
            for: schemaID,
            set: { self.settings.set($0, forKey: $1) },
            synchronize: { self.settings.synchronize() }
        )

        archiveInstaller.commitSchemaUninstall(staging, plan: plan)
        recordActiveUninstallRoutePhase(
            operationID: operationID,
            phase: "commit_succeeded",
            route: routeMutation?.after.effectiveRoute ?? routeSnapshot.effectiveRoute,
            operationStartedAt: operationStartedAt
        )

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

        if routeMutation == nil {
            requestDeploy(leaseOperationID: operationID)
        }
        rimeIceDownloadState = .idle
        if schemaID == "rime_ice" {
            rimeIceLicenseAccepted = false
            rimeIceVersion = nil
        }
        refreshSchemaList()
    }

    /// Download/upgrade rollback restores only the legacy active schema. The
    /// active-uninstall route transaction uses `applyRuntimeRouteState(_:)`
    /// instead because layout-bound bindings are part of its rollback state.
    func setActiveSchemaWithoutDeployment(_ schemaID: String) {
        activeSchemaID = schemaID
        settings.set(schemaID, forKey: "rime_active_schema")
        settings.synchronize()
    }

    /// Fail-closed restore must finish while the uninstall lease is still held.
    /// A detached Task would race `defer { release… }` and could observe a
    /// foreign lease or skip the redeploy entirely.
    private func restoreSchemaAfterFailedUninstall(
        _ state: RimeRuntimeRouteState,
        operationID: UUID,
        reason: String,
        operationStartedAt: UInt64
    ) async {
        applyRuntimeRouteState(state)
        recordActiveUninstallRoutePhase(
            operationID: operationID,
            phase: "route_restored_deploy_pending",
            route: state.effectiveRoute,
            operationStartedAt: operationStartedAt
        )
        let restored = await deployRimeConfig(leaseOperationID: operationID)
        recordActiveUninstallRoutePhase(
            operationID: operationID,
            phase: restored ? "rollback_deploy_succeeded" : "rollback_deploy_failed",
            route: state.effectiveRoute,
            isFailure: !restored,
            operationStartedAt: operationStartedAt
        )
        refreshSchemaList()
        Logger.shared.error(
            restored
                ? "uninstallSchema: \(reason)，已保留原方案文件并恢复原方案选择"
                : "uninstallSchema: \(reason)，已保留原方案文件，但原方案部署恢复未完成",
            category: .deployment
        )
    }

    /// These fields are finite route identifiers and an operation UUID only;
    /// no text input, file path, source URL, or exception text enters logs.
    private func recordActiveUninstallRoutePhase(
        operationID: UUID,
        phase: String,
        route: RimeRuntimeEffectiveRoute,
        isFailure: Bool = false,
        operationStartedAt: UInt64? = nil
    ) {
        guard
            let payload = runtimeRouteDiagnosticPayload(
                operationID: operationID,
                phase: phase,
                route: route,
                elapsedMilliseconds: operationStartedAt.map {
                    min(Int((DispatchTime.now().uptimeNanoseconds &- $0) / 1_000_000), 600_000)
                } ?? 0
            )
        else { return }
        deliveryDiagnostics.recordRuntimeRoute(payload, isFailure: isFailure)
        let message =
            "uninstallRoute operation=\(operationID.uuidString)"
            + " phase=\(phase) schema=\(route.schemaID)"
            + " layout=\(route.layoutStyle.rawValue) state=\(route.state)"
        if isFailure {
            Logger.shared.error(message, category: .deployment)
        } else {
            Logger.shared.info(message, category: .deployment)
        }
    }

    private func runtimeRouteDiagnosticPayload(
        operationID: UUID,
        phase: String,
        route: RimeRuntimeEffectiveRoute,
        elapsedMilliseconds: Int
    ) -> DiagnosticEvent.RuntimeRoutePhaseEvent? {
        guard let schema = DiagnosticEvent.RuntimeRouteSchema(rawValue: route.schemaID) else { return nil }
        let layout: DiagnosticEvent.RuntimeRouteLayout =
            route.layoutStyle == .nineKey ? .nineKey : .twentySixKey
        let state: DiagnosticEvent.RuntimeRouteState =
            route.state == .ready ? .ready : .failClosed
        let value: (DiagnosticEvent.RuntimeRoutePhase, DiagnosticEvent.RuntimeRouteResult)
        switch phase {
        case "route_before": value = (.before, .started)
        case "reconciliation_failed": value = (.reconciliation, .failed)
        case "route_after_deploy_pending": value = (.fallbackDeploy, .started)
        case "fallback_deploy_succeeded": value = (.fallbackDeploy, .succeeded)
        case "fallback_deploy_failed": value = (.fallbackDeploy, .failed)
        case "route_restored_deploy_pending": value = (.rollbackDeploy, .started)
        case "rollback_deploy_succeeded": value = (.rollbackDeploy, .succeeded)
        case "rollback_deploy_failed": value = (.rollbackDeploy, .failed)
        case "staging_started": value = (.staging, .started)
        case "staging_failed": value = (.staging, .failed)
        case "staging_rollback_incomplete": value = (.staging, .recoveryIncomplete)
        case "commit_succeeded": value = (.commit, .succeeded)
        case "inactive_route": value = (.inactive, .skipped)
        default: return nil
        }
        return .init(
            operationID: operationID,
            phase: value.0,
            result: value.1,
            schema: schema,
            layout: layout,
            state: state,
            elapsedMilliseconds: elapsedMilliseconds
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
