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
}
