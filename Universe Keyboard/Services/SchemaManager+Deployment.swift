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
        applyAdvancedInputPostProcessing(to: directories.sharedDataURL)
        applyFuzzyPinyinPostProcessing(to: directories.sharedDataURL)

        // Strip T9 force_gc **before** librime compiles build/t9.schema.yaml.
        if FileManager.default.fileExists(
            atPath: directories.sharedDataURL.appendingPathComponent("t9.schema.yaml").path
        ) {
            do {
                _ = try T9DeploymentSupport.ensureCompatibleT9Schema(in: directories.sharedDataURL)
                Logger.shared.info(
                    "deployRimeConfig: T9 compatibility applied before deploy",
                    category: .deployment
                )
            } catch {
                Logger.shared.warning(
                    "deployRimeConfig: T9 compatibility before deploy failed: \(error.localizedDescription)",
                    category: .deployment
                )
            }
        }

        settings.set(true, forKey: "rime_deploying")
        settings.set(false, forKey: "rime_deployed")
        settings.synchronize()

        do {
            let result = try await deploymentService.deploy(
                RimeDeploymentRequest(
                    mode: .fullCheck,
                    sharedDataURL: directories.sharedDataURL,
                    userDataURL: directories.userDataURL,
                    runtimeSmokeSchemaID: activeSchemaIDForDeployment
                )
            )
            Logger.shared.info("deployRimeConfig: \(result.diagnosticMessage)", category: .deployment)
            if let runtimeSmokePassed = result.runtimeSmokePassed {
                settings.set(runtimeSmokePassed, forKey: "rime_ice_lua_smoke_passed")
                settings.set(Int(Date().timeIntervalSince1970), forKey: "rime_ice_lua_smoke_timestamp")
            }
            if result.succeeded {
                Logger.shared.info("deployRimeConfig: 部署成功 ✓", category: .deployment)
                settings.set(true, forKey: "rime_deployed")
                settings.set(false, forKey: "rime_needs_deploy")
                settings.set(false, forKey: "rime_deploying")
                settings.set(false, forKey: RimeFuzzyPinyinSettings.pendingDeployKey)
                settings.set(false, forKey: RimeUserDictionarySettings.pendingDeployKey)
                settings.set(false, forKey: RimeAdvancedInputSettings.pendingDeployKey)
                settings.set(
                    currentFuzzyPinyinSettings().deploymentSignature(activeSchemaID: activeSchemaIDForDeployment),
                    forKey: RimeFuzzyPinyinSettings.deployedSignatureKey
                )
                settings.set(
                    currentUserDictionarySettings().deploymentSignature(),
                    forKey: RimeUserDictionarySettings.deployedSignatureKey
                )
                settings.set(
                    currentAdvancedInputSettings().deploymentSignature(
                        activeSchemaID: activeSchemaIDForDeployment,
                        supportedFeatures: supportedAdvancedInputFeatures(for: activeSchemaIDForDeployment)
                    ),
                    forKey: RimeAdvancedInputSettings.deployedSignatureKey
                )
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

    private func applyAdvancedInputPostProcessing(to sharedDataURL: URL) {
        let activeSchema = activeSchemaIDForDeployment
        guard activeSchema == "rime_ice" else { return }

        let schemaURL = sharedDataURL.appendingPathComponent("\(activeSchema).schema.yaml")
        let result = RimeAdvancedInputPostProcessor.apply(
            settings: currentAdvancedInputSettings(),
            supportedFeatures: supportedAdvancedInputFeatures(for: activeSchema),
            schemaURL: schemaURL
        )

        switch result.status {
        case .unchanged:
            Logger.shared.info(
                "deployRimeConfig: advanced input unchanged (\(activeSchema))",
                category: .deployment
            )
        case .restoredAllFeatures:
            Logger.shared.info(
                "deployRimeConfig: advanced input restored all features (\(activeSchema))",
                category: .deployment
            )
        case .disabledComponents(let names):
            Logger.shared.info(
                "deployRimeConfig: advanced input disabled components=\(names.joined(separator: "+"))",
                category: .deployment
            )
        case .missingSchema:
            Logger.shared.warning(
                "deployRimeConfig: advanced input skipped, schema file missing: \(activeSchema)",
                category: .deployment
            )
        case .noRestorableSource:
            Logger.shared.warning(
                "deployRimeConfig: advanced input skipped, no restorable source: \(activeSchema)",
                category: .deployment
            )
        }
    }

    private func applyFuzzyPinyinPostProcessing(to sharedDataURL: URL) {
        let activeSchema = activeSchemaIDForDeployment
        let schemaURL = sharedDataURL.appendingPathComponent("\(activeSchema).schema.yaml")
        guard let originalYaml = try? String(contentsOf: schemaURL, encoding: .utf8) else {
            Logger.shared.warning(
                "deployRimeConfig: fuzzy pinyin skipped, schema file missing: \(activeSchema)",
                category: .deployment
            )
            return
        }

        let fuzzySettings = currentFuzzyPinyinSettings()

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

    private var activeSchemaIDForDeployment: String {
        settings.string(forKey: "rime_active_schema") ?? "luna_pinyin"
    }

    private func currentFuzzyPinyinSettings() -> RimeFuzzyPinyinSettings {
        RimeFuzzyPinyinSettings(
            enabled: settings.object(forKey: RimeFuzzyPinyinSettings.enabledKey) as? Bool ?? true,
            zhZEnabled: settings.object(forKey: RimeFuzzyPinyinSettings.zhZKey) as? Bool ?? true,
            chCEnabled: settings.object(forKey: RimeFuzzyPinyinSettings.chCKey) as? Bool ?? true,
            shSEnabled: settings.object(forKey: RimeFuzzyPinyinSettings.shSKey) as? Bool ?? true,
            nLEnabled: settings.object(forKey: RimeFuzzyPinyinSettings.nLKey) as? Bool ?? true
        )
    }

    private func currentUserDictionarySettings() -> RimeUserDictionarySettings {
        RimeUserDictionarySettings(
            lunaPinyinEnabled: settings.object(
                forKey: RimeUserDictionarySettings.lunaPinyinEnabledKey
            ) as? Bool ?? true,
            rimeIceEnabled: settings.object(
                forKey: RimeUserDictionarySettings.rimeIceEnabledKey
            ) as? Bool ?? true
        )
    }

    private func currentAdvancedInputSettings() -> RimeAdvancedInputSettings {
        let featureValues = Dictionary(
            uniqueKeysWithValues: RimeAdvancedInputFeature.allCases.map { feature in
                (
                    feature,
                    settings.object(forKey: RimeAdvancedInputSettings.enabledKey(for: feature)) as? Bool ?? true
                )
            }
        )

        return RimeAdvancedInputSettings(
            masterEnabled: settings.object(forKey: RimeAdvancedInputSettings.masterEnabledKey) as? Bool ?? true,
            featureEnabled: featureValues
        )
    }

    private func supportedAdvancedInputFeatures(for schemaID: String) -> Set<RimeAdvancedInputFeature> {
        schemaID == "rime_ice" ? Set(RimeAdvancedInputFeature.allCases) : []
    }
}
