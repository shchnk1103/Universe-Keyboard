import Foundation
import KeyboardCore
import RimeBridge

extension SchemaManager {
    /// Full enable path for nine-key.
    ///
    /// Fail-closed: before any asset-mutating step, force 26-key and invalidate readiness.
    /// Only after prepare → deploy → smoke → fingerprint all succeed may readiness and nineKey be written (nineKey last).
    /// Returns `nil` on success, or a user-visible failure message.
    @MainActor
    func enableNineKeyLayout() async -> String? {
        await enableNineKeyLayout(schemeID: "t9")
    }

    /// Enables one registered nine-key scheme. Fog-only callers keep `enableNineKeyLayout()`.
    @MainActor
    func enableNineKeyLayout(schemeID: String) async -> String? {
        guard let scheme = NineKeySchemeRegistry.scheme(schemeID) else {
            return "该方案不能用于九键"
        }
        let operationID = UUID()
        guard await acquireSchemeDeliveryCommitLease(operationID: operationID) else {
            return Self.userMessage(for: .deployFailed)
        }
        defer { releaseSchemeDeliveryCommitLease(operationID: operationID) }

        let failure = await NineKeyEnableOrchestrator.enable(
            using: makeActiveNineKeyDependencies(scheme: scheme, leaseOperationID: operationID)
        )
        return failure.map { Self.userMessage(for: $0, scheme: scheme) }
    }

    /// Production dependency wiring for the shared orchestrator (also used by tests via injection).
    @MainActor
    func makeNineKeyEnableDependencies(
        leaseOperationID: UUID? = nil
    ) -> NineKeyEnableOrchestrator.Dependencies {
        NineKeyEnableOrchestrator.Dependencies(
            iceInstalled: { [weak self] in
                self?.rimeIceFilesExist() ?? false
            },
            resolveDirectories: { [weak self] in
                guard let directories = try? self?.archiveInstaller.deploymentDirectories() else {
                    return nil
                }
                return NineKeyEnableOrchestrator.Directories(
                    sharedDataURL: directories.sharedDataURL,
                    userDataURL: directories.userDataURL
                )
            },
            beginTransaction: { [weak self] in
                self?.beginNineKeyEnableTransaction()
            },
            prepare: { sharedDataURL in
                _ = try T9DeploymentSupport.ensureCompatibleT9Schema(in: sharedDataURL)
            },
            deploy: { [weak self] in
                guard let self else { return false }
                // deployRimeConfig reapplies T9 compatibility after a successful deploy.
                return await self.deployRimeConfig(leaseOperationID: leaseOperationID)
            },
            smoke: { shared, user in
                T9DeploymentSupport.verifyT9Smoke(sharedDataDir: shared, userDataDir: user)
            },
            fingerprint: { sharedDataURL in
                T9DeploymentSupport.resourceFingerprint(sharedDataURL: sharedDataURL)
            },
            writeMatchedReadiness: { [weak self] fingerprint in
                guard let self else { return }
                T9DeploymentSupport.writeMatchedReadiness(
                    fingerprint: fingerprint,
                    upstreamVersion: self.installedVersion(for: "rime_ice"),
                    settings: self.settings
                )
            },
            publishNineKey: { [weak self] in
                guard let self else { return }
                T9DeploymentSupport.persistLayout(.nineKey, settings: self.settings)
                self.settings.set("t9", forKey: KeyboardLayoutSettingsKey.schemeBinding9)
            }
        )
    }

    @MainActor
    func makeActiveNineKeyDependencies(
        scheme: NineKeyScheme,
        leaseOperationID: UUID? = nil
    ) -> NineKeyEnableOrchestrator.ActiveDependencies {
        NineKeyEnableOrchestrator.ActiveDependencies(
            target: scheme,
            familyInstalled: { [weak self] in
                self?.nineKeyFamilyInstalled(scheme) ?? false
            },
            resolveDirectories: { [weak self] in
                guard let directories = try? self?.archiveInstaller.deploymentDirectories() else {
                    return nil
                }
                return NineKeyEnableOrchestrator.Directories(
                    sharedDataURL: directories.sharedDataURL,
                    userDataURL: directories.userDataURL
                )
            },
            beginTargetTransaction: { [weak self] in
                guard let self else { return }
                T9DeploymentSupport.persistLayout(.twentySixKey, settings: self.settings)
                T9DeploymentSupport.invalidateReadiness(schemaID: scheme.schemaID, settings: self.settings)
            },
            prepare: { sharedDataURL in
                if scheme.schemaID == "t9" {
                    _ = try T9DeploymentSupport.ensureCompatibleT9Schema(in: sharedDataURL)
                    return
                }
                let prepared = WanxiangT9DeploymentSupport.prepare(sharedDataURL: sharedDataURL)
                if prepared.failed {
                    throw T9DeploymentError.missingUpstreamSchema
                }
            },
            invalidateAllMarkers: { [weak self] in
                guard let self else { return }
                T9DeploymentSupport.invalidateAllReadiness(settings: self.settings)
            },
            deploy: { [weak self] in
                guard let self else { return false }
                return await self.deployRimeConfig(
                    leaseOperationID: leaseOperationID,
                    publishNineKeyReadiness: false
                )
            },
            schemesToVerify: { [weak self] in
                guard let self else { return [] }
                return NineKeySchemeRegistry.entries.filter { self.nineKeyFamilyInstalled($0) }
            },
            rewriteCheck: { [weak self] candidate, sharedDataURL in
                guard let self else { return false }
                let user =
                    (try? self.archiveInstaller.deploymentDirectories())?.userDataURL
                    ?? sharedDataURL.deletingLastPathComponent().appendingPathComponent("user")
                return self.nineKeyCompiledSchemaIsClean(
                    candidate,
                    sharedDataURL: sharedDataURL,
                    userDataURL: user
                )
            },
            smoke: { candidate, shared, user in
                let input = NineKeySchemeRegistry.smokeInput(for: candidate.schemaID) ?? ""
                return RimeT9SmokeProbe.verify(
                    sharedDataDir: shared,
                    userDataDir: user,
                    schemaID: candidate.schemaID,
                    input: input
                )
            },
            fingerprint: { candidate, sharedDataURL in
                T9DeploymentSupport.resourceFingerprint(
                    schemaID: candidate.schemaID,
                    sharedDataURL: sharedDataURL
                )
            },
            restoreRoute: { [weak self] in
                guard let self else { return false }
                guard let directories = try? self.archiveInstaller.deploymentDirectories() else {
                    return false
                }
                return self.restoreNineKeyEngineRoute(
                    sharedDataURL: directories.sharedDataURL,
                    userDataURL: directories.userDataURL
                )
            },
            forceTwentySix: { [weak self] in
                guard let self else { return }
                T9DeploymentSupport.persistLayout(.twentySixKey, settings: self.settings)
            },
            writeMarker: { [weak self] candidate, fingerprint in
                guard let self else { return }
                T9DeploymentSupport.writeMatchedReadiness(
                    schemaID: candidate.schemaID,
                    fingerprint: fingerprint,
                    upstreamVersion: self.installedVersion(for: candidate.familyID),
                    settings: self.settings
                )
            },
            publishBinding: { [weak self] schemaID in
                self?.settings.set(schemaID, forKey: KeyboardLayoutSettingsKey.schemeBinding9)
                self?.settings.synchronize()
            },
            publishLayout: { [weak self] in
                guard let self else { return }
                T9DeploymentSupport.persistLayout(.nineKey, settings: self.settings)
            }
        )
    }

    private static func userMessage(
        for failure: NineKeyEnableOrchestrator.ActiveFailure,
        scheme: NineKeyScheme
    ) -> String {
        switch failure {
        case .familyNotInstalled:
            if scheme.schemaID == "t9" {
                return "需要先安装雾凇拼音才能使用九键"
            }
            return "需要先安装该九键方案所属的输入方案"
        case .directoriesUnavailable:
            return "App Group 不可用"
        case .prepareFailed:
            return "无法准备九键方案文件，已回退 26 键"
        case .deployFailed:
            return "RIME 部署失败，已回退 26 键"
        case .rewriteFailed, .smokeFailed:
            return "九键验证失败（无法产生候选或删除异常），已回退 26 键"
        case .fingerprintUnavailable:
            return "无法计算九键资源指纹，已回退 26 键"
        case .restoreFailed:
            return "九键验证后无法恢复当前输入方案，已回退 26 键"
        case .targetNotReady:
            return "九键验证失败（无法产生候选或删除异常），已回退 26 键"
        }
    }

    private static func userMessage(for failure: NineKeyEnableOrchestrator.Failure) -> String {
        switch failure {
        case .iceNotInstalled:
            return "需要先安装雾凇拼音才能使用九键"
        case .directoriesUnavailable:
            return "App Group 不可用"
        case .prepareFailed:
            return "无法准备九键方案文件，已回退 26 键"
        case .deployFailed:
            return "RIME 部署失败，已回退 26 键"
        case .smokeFailed:
            return "九键验证失败（无法产生候选或删除异常），已回退 26 键"
        case .fingerprintUnavailable:
            return "无法计算九键资源指纹，已回退 26 键"
        }
    }

    /// Observable safe state before risky enable/update work (ADR 0018 fail-closed).
    @MainActor
    func beginNineKeyEnableTransaction() {
        T9DeploymentSupport.persistLayout(.twentySixKey, settings: settings)
        T9DeploymentSupport.invalidateReadiness(settings: settings)
    }

    /// Persist 26-key immediately without touching readiness when resources remain.
    @MainActor
    func selectTwentySixKeyLayout() {
        ensureLayoutSchemeBindingsMigrated()
        T9DeploymentSupport.persistLayout(.twentySixKey, settings: settings)
    }

    /// ADR order: layout → invalidate readiness → remove resources (existing uninstall).
    /// P1-5: Ice semantics live in `IceUninstallLayoutFallback` / SchemeAdapter registry.
    @MainActor
    func prepareRimeIceUninstallWithLayoutFallback() {
        IceUninstallLayoutFallback.apply(
            set: { self.settings.set($0, forKey: $1) },
            synchronize: { self.settings.synchronize() }
        )
    }

    /// When switching base scheme away from rime_ice, fall layout back only if nine-key is not ready.
    /// ADR 0026: 26-key scheme and nine-key binding are independent once T9 readiness matches.
    @MainActor
    func applyLayoutFallbackWhenLeavingRimeIce(newSchemaID: String) {
        guard newSchemaID != "rime_ice" else { return }
        if currentT9ReadinessMatched() { return }
        T9DeploymentSupport.persistLayout(.twentySixKey, settings: settings)
    }

    func currentLayoutStyle() -> KeyboardLayoutStyle {
        KeyboardLayoutStyle.resolve(settings.string(forKey: KeyboardLayoutSettingsKey.layoutStyle))
    }

    func currentT9ReadinessMatched() -> Bool {
        guard let directories = try? archiveInstaller.runtimeDirectories() else { return false }
        let fingerprint = T9DeploymentSupport.resourceFingerprint(sharedDataURL: directories.sharedDataURL)
        return RimeT9Readiness.isMatched(
            marker: T9DeploymentSupport.loadMarker(settings: settings),
            onDiskFingerprint: fingerprint
        )
    }

    /// ADR 0026 migration + read helpers for layout settings.
    @MainActor
    func ensureLayoutSchemeBindingsMigrated() {
        let existing26 = settings.string(forKey: KeyboardLayoutSettingsKey.schemeBinding26)
        let existing9 = settings.string(forKey: KeyboardLayoutSettingsKey.schemeBinding9)
        guard (existing26?.isEmpty != false) && (existing9?.isEmpty != false) else { return }

        guard let dirs = try? archiveInstaller.runtimeDirectories() else {
            migrateBindings(onDiskFingerprint: nil)
            return
        }
        let fingerprint = T9DeploymentSupport.resourceFingerprint(sharedDataURL: dirs.sharedDataURL)
        migrateBindings(onDiskFingerprint: fingerprint)
    }

    private func migrateBindings(onDiskFingerprint: String?) {
        let existing26 = settings.string(forKey: KeyboardLayoutSettingsKey.schemeBinding26)
        let existing9 = settings.string(forKey: KeyboardLayoutSettingsKey.schemeBinding9)
        if (existing26?.isEmpty == false) || (existing9?.isEmpty == false) { return }
        let base = settings.string(forKey: "rime_active_schema") ?? "luna_pinyin"
        let normalized = base == "t9" ? "rime_ice" : base
        settings.set(normalized, forKey: KeyboardLayoutSettingsKey.schemeBinding26)
        if RimeT9Readiness.isMatched(
            marker: T9DeploymentSupport.loadMarker(settings: settings),
            onDiskFingerprint: onDiskFingerprint
        ) {
            settings.set("t9", forKey: KeyboardLayoutSettingsKey.schemeBinding9)
        }
    }

    func schemeBinding26() -> String {
        ensureLayoutSchemeBindingsMigrated()
        let raw =
            settings.string(forKey: KeyboardLayoutSettingsKey.schemeBinding26)
            ?? settings.string(forKey: "rime_active_schema")
            ?? "luna_pinyin"
        return raw == "t9" ? "rime_ice" : raw
    }

    func schemeBinding9() -> String? {
        ensureLayoutSchemeBindingsMigrated()
        let raw = settings.string(forKey: KeyboardLayoutSettingsKey.schemeBinding9)
        return (raw?.isEmpty == false) ? raw : nil
    }

    /// Captures the same resolved route that the Extension will derive from
    /// layout-bound preferences. A persisted nine-key preference alone is not
    /// enough: unavailable T9 resources must make the 26-key binding effective.
    @MainActor
    func currentRuntimeRouteSnapshot() -> RimeRuntimeRouteSnapshot {
        ensureLayoutSchemeBindingsMigrated()

        let persistedLayout = currentLayoutStyle()
        let binding26 = schemeBinding26()
        let binding9 = schemeBinding9()
        let sharedDataURL = (try? archiveInstaller.runtimeDirectories())?.sharedDataURL
        let selection = registeredRuntimeSelection(sharedDataURL: sharedDataURL)
        let effectiveState: RimeRuntimeEffectiveRoute.State =
            selection.effectiveLayoutStyle == persistedLayout ? .ready : .failClosed
        let supportedTwentySixKeySchemaIDs =
            ["luna_pinyin"]
            + schemeCatalog
            .map(\.schemaID)
            .filter {
                $0 != "luna_pinyin" && RimeRuntimeSelection.isTwentySixKeyCapable($0)
            }

        return RimeRuntimeRouteSnapshot(
            selectedLayoutStyle: persistedLayout,
            effectiveRoute: RimeRuntimeEffectiveRoute(
                schemaID: selection.effectiveSchemaID,
                layoutStyle: selection.effectiveLayoutStyle,
                usesT9InputSemantics: selection.usesT9InputSemantics,
                state: effectiveState
            ),
            activeSchemaID: activeSchemaID,
            slots: [
                RimeRuntimeRouteSlot(
                    preferenceKey: KeyboardLayoutSettingsKey.schemeBinding26,
                    layoutStyle: .twentySixKey,
                    boundSchemaID: binding26,
                    supportedSchemaIDs: supportedTwentySixKeySchemaIDs,
                    fallback: RimeRuntimeRouteFallback(
                        layoutStyle: .twentySixKey,
                        preferenceKey: KeyboardLayoutSettingsKey.schemeBinding26,
                        schemaID: "luna_pinyin",
                        // Luna is the immutable built-in closure. The subsequent
                        // deployment remains the runtime availability proof.
                        availability: .available
                    )
                ),
                RimeRuntimeRouteSlot(
                    preferenceKey: KeyboardLayoutSettingsKey.schemeBinding9,
                    layoutStyle: .nineKey,
                    boundSchemaID: binding9,
                    supportedSchemaIDs: ["t9"],
                    dependencySchemaIDs: ["rime_ice"],
                    fallback: RimeRuntimeRouteFallback(
                        layoutStyle: .twentySixKey,
                        preferenceKey: KeyboardLayoutSettingsKey.schemeBinding26,
                        schemaID: "luna_pinyin",
                        availability: .available
                    )
                ),
            ]
        )
    }

    /// Applies a reconciler state as one ordered main-App write set. The caller
    /// owns the schema-delivery lease and performs deployment afterwards.
    ///
    /// App Group preferences do not provide a multi-key transaction. Bindings
    /// therefore move first, then layout, then the legacy alias: an Extension
    /// observing a prefix can use only still-present resources or Luna, never
    /// the scheme whose files will later be removed.
    @MainActor
    func applyRuntimeRouteState(_ state: RimeRuntimeRouteState) {
        for binding in state.bindings {
            if let schemaID = binding.schemaID {
                settings.set(schemaID, forKey: binding.preferenceKey)
            } else {
                settings.removeObject(forKey: binding.preferenceKey)
            }
        }
        settings.set(state.selectedLayoutStyle.rawValue, forKey: KeyboardLayoutSettingsKey.layoutStyle)
        activeSchemaID = state.activeSchemaID
        settings.set(state.activeSchemaID, forKey: "rime_active_schema")
        settings.synchronize()
    }

    @MainActor
    func setSchemeBinding26(_ schemaID: String) {
        guard RimeRuntimeSelection.isTwentySixKeyCapable(schemaID) else { return }
        settings.set(schemaID, forKey: KeyboardLayoutSettingsKey.schemeBinding26)
        settings.set(schemaID, forKey: "rime_active_schema")
        activeSchemaID = schemaID
        requestDeploy()
        refreshSchemaList()
    }

    @MainActor
    func setSchemeBinding9(_ schemaID: String) async -> String? {
        guard NineKeySchemeRegistry.scheme(schemaID) != nil,
            RimeRuntimeSelection.isNineKeyCapable(schemaID)
        else { return "该方案不能用于九键" }
        if nineKeySchemeIsReady(schemaID) {
            settings.set(schemaID, forKey: KeyboardLayoutSettingsKey.schemeBinding9)
            settings.synchronize()
            return nil
        }
        return await enableNineKeyLayout(schemeID: schemaID)
    }

    func nineKeySchemeIsReady(_ schemaID: String) -> Bool {
        guard let directories = try? archiveInstaller.runtimeDirectories() else { return false }
        let fingerprint = T9DeploymentSupport.resourceFingerprint(
            schemaID: schemaID,
            sharedDataURL: directories.sharedDataURL
        )
        return NineKeyReadiness.isMatched(
            schemaID: schemaID,
            marker: T9DeploymentSupport.loadMarker(schemaID: schemaID, settings: settings),
            fingerprint: fingerprint
        )
    }

    func wanxiangFamilyInstalled() -> Bool {
        settings.bool(forKey: "wanxiang_installed")
    }
}
