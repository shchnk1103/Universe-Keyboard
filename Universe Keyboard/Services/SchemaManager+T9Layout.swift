import Foundation
import KeyboardCore
import RimeBridge

extension SchemaManager {
    /// Full enable path for nine-key: ensure T9 schema → deploy → verify → readiness → layout last.
    @MainActor
    /// Returns `nil` on success, or a user-visible failure message.
    func enableNineKeyLayout() async -> String? {
        guard rimeIceFilesExist() else {
            return "需要先安装雾凇拼音才能使用九键"
        }
        guard let directories = try? archiveInstaller.deploymentDirectories() else {
            return "App Group 不可用"
        }

        do {
            _ = try T9DeploymentSupport.ensureCompatibleT9Schema(in: directories.sharedDataURL)
        } catch {
            return "无法准备九键方案文件：\(error.localizedDescription)"
        }

        let deployed = await deployRimeConfig()
        guard deployed else {
            return "RIME 部署失败，已保持原布局"
        }

        let verified = T9DeploymentSupport.verifyT9Smoke(
            sharedDataDir: directories.sharedDataURL.path,
            userDataDir: directories.userDataURL.path
        )
        guard verified else {
            T9DeploymentSupport.invalidateReadiness(settings: settings)
            return "九键验证失败（无法产生候选或删除异常），已保持原布局"
        }

        guard let fingerprint = T9DeploymentSupport.resourceFingerprint(sharedDataURL: directories.sharedDataURL) else {
            return "无法计算九键资源指纹"
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
