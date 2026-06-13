import Foundation
import KeyboardCore
import RimeBridge

extension SchemaManager {
    func requestDeploy() {
        settings.set(false, forKey: "rime_deployed")
        settings.set(true, forKey: "rime_needs_deploy")
        settings.synchronize()
    }

    @discardableResult
    func deployRimeConfig() async -> Bool {
        let directories: SchemaDeploymentDirectories
        do {
            directories = try archiveInstaller.deploymentDirectories()
        } catch {
            Logger.shared.error("deployRimeConfig: App Group 不可用", category: .deployment)
            return false
        }

        Logger.shared.info("deployRimeConfig: 开始主 App 端全量部署", category: .deployment)

        await Task.detached(priority: .userInitiated) {
            RimeConfigManager.syncCustomYamlFiles()
        }.value
        applyFuzzyPinyinPostProcessing(to: directories.sharedDataURL)
        settings.set(true, forKey: "rime_deploying")
        settings.set(false, forKey: "rime_deployed")
        settings.synchronize()

        do {
            let result = try await deploymentService.deploy(
                RimeDeploymentRequest(
                    mode: .fullCheck,
                    sharedDataURL: directories.sharedDataURL,
                    userDataURL: directories.userDataURL
                )
            )
            Logger.shared.info("deployRimeConfig: \(result.diagnosticMessage)", category: .deployment)
            if result.succeeded {
                Logger.shared.info("deployRimeConfig: 部署成功 ✓", category: .deployment)
                settings.set(true, forKey: "rime_deployed")
                settings.set(false, forKey: "rime_needs_deploy")
                settings.set(false, forKey: "rime_deploying")
                settings.synchronize()
                return true
            } else {
                Logger.shared.error("deployRimeConfig: 部署失败，请在主 App 中重试", category: .deployment)
                settings.set(false, forKey: "rime_deployed")
                settings.set(true, forKey: "rime_needs_deploy")
                settings.set(false, forKey: "rime_deploying")
            }
        } catch {
            Logger.shared.error(
                "deployRimeConfig: deployment service failed: \(error.localizedDescription)",
                category: .deployment
            )
            settings.set(false, forKey: "rime_deployed")
            settings.set(true, forKey: "rime_needs_deploy")
            settings.set(false, forKey: "rime_deploying")
        }

        settings.synchronize()
        return false
    }

    private func applyFuzzyPinyinPostProcessing(to sharedDataURL: URL) {
        let activeSchema = settings.string(forKey: "rime_active_schema") ?? "luna_pinyin"
        let schemaURL = sharedDataURL.appendingPathComponent("\(activeSchema).schema.yaml")
        guard let originalYaml = try? String(contentsOf: schemaURL, encoding: .utf8) else {
            Logger.shared.warning(
                "deployRimeConfig: fuzzy pinyin skipped, schema file missing: \(activeSchema)",
                category: .deployment
            )
            return
        }

        let fuzzySettings = RimeFuzzyPinyinSettings(
            zhZEnabled: settings.object(forKey: RimeFuzzyPinyinSettings.zhZKey) as? Bool ?? true,
            chCEnabled: settings.object(forKey: RimeFuzzyPinyinSettings.chCKey) as? Bool ?? true,
            shSEnabled: settings.object(forKey: RimeFuzzyPinyinSettings.shSKey) as? Bool ?? true,
            nLEnabled: settings.object(forKey: RimeFuzzyPinyinSettings.nLKey) as? Bool ?? true
        )

        let result = RimeFuzzyPinyinPostProcessor.apply(settings: fuzzySettings, to: originalYaml)
        guard result.yaml != originalYaml else {
            Logger.shared.info(
                "deployRimeConfig: fuzzy pinyin unchanged (\(activeSchema), status=\(result.status))",
                category: .deployment
            )
            return
        }

        do {
            try result.yaml.write(to: schemaURL, atomically: true, encoding: .utf8)
            Logger.shared.info(
                "deployRimeConfig: fuzzy pinyin \(result.status) for \(activeSchema)",
                category: .deployment
            )
        } catch {
            Logger.shared.warning(
                "deployRimeConfig: fuzzy pinyin write failed for \(activeSchema): \(error.localizedDescription)",
                category: .deployment
            )
        }
    }
}
