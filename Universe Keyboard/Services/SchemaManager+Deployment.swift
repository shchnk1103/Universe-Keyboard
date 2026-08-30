import Foundation
import KeyboardCore
import RimeBridge

extension SchemaManager {
    func requestDeploy(leaseOperationID: UUID? = nil) {
        if let owner = schemeDeliveryCommitLeaseOperationID, owner != leaseOperationID {
            enqueueSchemeMutation(.requestDeploy)
            return
        }
        settings.set(false, forKey: "rime_deployed")
        settings.set(true, forKey: "rime_needs_deploy")
        // Every caller represents a new deployment intent. It may receive one
        // automatic attempt even when the previous intent failed.
        settings.set(false, forKey: "rime_deploy_auto_retry_suppressed")
        if activeSchemaIDForDeployment == "rime_ice" {
            // A prior Lua receipt cannot authorize a new fog deployment intent.
            settings.removeObject(forKey: "rime_ice_lua_smoke_passed")
            settings.removeObject(forKey: "rime_ice_lua_smoke_timestamp")
        }
        settings.synchronize()
    }

    @discardableResult
    func deployRimeConfig(leaseOperationID: UUID? = nil) async -> Bool {
        if let owner = schemeDeliveryCommitLeaseOperationID, owner != leaseOperationID {
            return await waitForPostCommitDeployment()
        }
        if let activeRimeDeploymentTask {
            return await activeRimeDeploymentTask.value
        }
        let deploymentID = UUID()
        let task = Task { @MainActor [weak self] in
            guard let self else { return false }
            return await self.performRimeDeployment()
        }
        activeRimeDeploymentID = deploymentID
        activeRimeDeploymentTask = task
        let succeeded = await task.value
        if activeRimeDeploymentID == deploymentID {
            activeRimeDeploymentID = nil
            activeRimeDeploymentTask = nil
        }
        return succeeded
    }

    /// The only body that mutates shared deployment files. All public callers
    /// enter through `deployRimeConfig`, which provides process-local single-flight.
    private func performRimeDeployment() async -> Bool {
        let directories: SchemaDeploymentDirectories
        do {
            directories = try archiveInstaller.deploymentDirectories()
        } catch {
            // Keep the log content-free while distinguishing preparation from
            // the later librime deployment transaction.
            Logger.shared.error(
                "deployRimeConfig: 内置资源验证或 App Group 准备失败",
                category: .deployment
            )
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
                Logger.shared.warning("deployRimeConfig: T9 compatibility before deploy failed", category: .deployment)
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
            Logger.shared.info(
                "deployRimeConfig: deployment service completed "
                    + "succeeded=\(result.succeeded) runtimeSmokeReported=\(result.runtimeSmokePassed != nil)",
                category: .deployment
            )
            if let luaRuntimeSmokePassed = result.luaRuntimeSmokePassed {
                settings.set(luaRuntimeSmokePassed, forKey: "rime_ice_lua_smoke_passed")
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
                    currentFuzzyPinyinSettings().deploymentSignature(activeSchemaID: "all"),
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
            Logger.shared.error("deployRimeConfig: deployment service failed", category: .deployment)
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
        // Multi-scheme: patch every installed 26-key schema file present in shared,
        // not only `rime_active_schema`. Otherwise toggling fuzzy while 万象 is active
        // leaves 雾凇 without the managed block (and the reverse).
        let fuzzySettings = currentFuzzyPinyinSettings()
        let schemaIDs = fuzzyTargetSchemaIDs(sharedDataURL: sharedDataURL)
        guard !schemaIDs.isEmpty else {
            Logger.shared.warning(
                "deployRimeConfig: fuzzy pinyin skipped, no target schema files",
                category: .deployment
            )
            return
        }

        for schemaID in schemaIDs {
            // The official Luna source is immutable. Its fuzzy rules live in
            // luna_pinyin.custom.yaml, generated before deployment.
            guard schemaID != "luna_pinyin" else { continue }
            let schemaURL = sharedDataURL.appendingPathComponent("\(schemaID).schema.yaml")
            guard let originalYaml = try? String(contentsOf: schemaURL, encoding: .utf8) else {
                Logger.shared.warning(
                    "deployRimeConfig: fuzzy pinyin skipped, schema file missing: \(schemaID)",
                    category: .deployment
                )
                continue
            }

            let result = RimeFuzzyPinyinPostProcessor.apply(settings: fuzzySettings, to: originalYaml)
            guard result.yaml != originalYaml else {
                Logger.shared.info(
                    "deployRimeConfig: fuzzy pinyin unchanged (\(schemaID), status=\(result.status))",
                    category: .deployment
                )
                continue
            }

            do {
                try result.yaml.write(to: schemaURL, atomically: true, encoding: .utf8)
                Logger.shared.info(
                    "deployRimeConfig: fuzzy pinyin \(result.status) for \(schemaID)",
                    category: .deployment
                )
            } catch {
                Logger.shared.warning("deployRimeConfig: fuzzy pinyin write failed", category: .deployment)
            }
        }
    }

    /// Schemas that should receive the managed fuzzy algebra block on deploy.
    private func fuzzyTargetSchemaIDs(sharedDataURL: URL) -> [String] {
        var ids = Set<String>()
        ids.insert(activeSchemaIDForDeployment)
        if let binding26 = settings.string(forKey: KeyboardLayoutSettingsKey.schemeBinding26),
            !binding26.isEmpty
        {
            ids.insert(binding26 == "t9" ? "rime_ice" : binding26)
        }
        // Always include installed downloadable letter schemes when their schema file exists.
        for entry in RimeSchemeCatalog.downloadableEntries {
            let id = entry.schemaID
            let url = sharedDataURL.appendingPathComponent("\(id).schema.yaml")
            if FileManager.default.fileExists(atPath: url.path) {
                ids.insert(id)
            }
        }
        let luna = sharedDataURL.appendingPathComponent("luna_pinyin.schema.yaml")
        if FileManager.default.fileExists(atPath: luna.path) {
            ids.insert("luna_pinyin")
        }
        return
            ids
            .map { $0 == "t9" ? "rime_ice" : $0 }
            .filter { RimeRuntimeSelection.isTwentySixKeyCapable($0) }
            .sorted()
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
        RimeSchemeCapabilityMatrix.profile(for: schemaID).supportsProductAdvancedInput
            ? Set(RimeAdvancedInputFeature.allCases)
            : []
    }
}
