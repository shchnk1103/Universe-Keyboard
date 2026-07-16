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
        guard rimeIceFilesExist() else {
            return "需要先安装雾凇拼音才能使用九键"
        }
        guard let directories = try? archiveInstaller.deploymentDirectories() else {
            // No asset mutation yet; keep previous state.
            return "App Group 不可用"
        }

        // Before any operation that can alter T9/RIME assets: observable safe 26-key + unmatched readiness.
        beginNineKeyEnableTransaction()

        do {
            _ = try T9DeploymentSupport.ensureCompatibleT9Schema(in: directories.sharedDataURL)
        } catch {
            return "无法准备九键方案文件：\(error.localizedDescription)。已回退 26 键"
        }

        let deployed = await deployRimeConfig()
        guard deployed else {
            return "RIME 部署失败，已回退 26 键"
        }

        let verified = T9DeploymentSupport.verifyT9Smoke(
            sharedDataDir: directories.sharedDataURL.path,
            userDataDir: directories.userDataURL.path
        )
        guard verified else {
            // Already invalidated at transaction start; keep 26-key.
            return "九键验证失败（无法产生候选或删除异常），已回退 26 键"
        }

        guard let fingerprint = T9DeploymentSupport.resourceFingerprint(sharedDataURL: directories.sharedDataURL) else {
            return "无法计算九键资源指纹，已回退 26 键"
        }
        T9DeploymentSupport.writeMatchedReadiness(
            fingerprint: fingerprint,
            upstreamVersion: installedVersion(for: "rime_ice"),
            settings: settings
        )
        // Layout last.
        T9DeploymentSupport.persistLayout(.nineKey, settings: settings)
        return nil
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
