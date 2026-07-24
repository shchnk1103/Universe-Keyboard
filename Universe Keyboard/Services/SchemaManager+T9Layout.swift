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
        let failure = await NineKeyEnableOrchestrator.enable(using: makeNineKeyEnableDependencies())
        return failure.map(Self.userMessage(for:))
    }

    /// Production dependency wiring for the shared orchestrator (also used by tests via injection).
    @MainActor
    func makeNineKeyEnableDependencies() -> NineKeyEnableOrchestrator.Dependencies {
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
                return await self.deployRimeConfig()
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
            }
        )
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
        T9DeploymentSupport.persistLayout(.twentySixKey, settings: settings)
    }

    /// ADR order: layout → invalidate readiness → remove resources (existing uninstall).
    @MainActor
    func prepareRimeIceUninstallWithLayoutFallback() {
        T9DeploymentSupport.persistLayout(.twentySixKey, settings: settings)
        T9DeploymentSupport.invalidateReadiness(settings: settings)
    }

    /// When switching base scheme away from rime_ice, fall layout back but keep readiness if fingerprint still matches.
    @MainActor
    func applyLayoutFallbackWhenLeavingRimeIce(newSchemaID: String) {
        guard newSchemaID != "rime_ice" else { return }
        T9DeploymentSupport.persistLayout(.twentySixKey, settings: settings)
    }

    func currentLayoutStyle() -> KeyboardLayoutStyle {
        KeyboardLayoutStyle.resolve(settings.string(forKey: KeyboardLayoutSettingsKey.layoutStyle))
    }

    func currentT9ReadinessMatched() -> Bool {
        guard let directories = try? archiveInstaller.deploymentDirectories() else { return false }
        let fingerprint = T9DeploymentSupport.resourceFingerprint(sharedDataURL: directories.sharedDataURL)
        return RimeT9Readiness.isMatched(
            marker: T9DeploymentSupport.loadMarker(settings: settings),
            onDiskFingerprint: fingerprint
        )
    }
}
