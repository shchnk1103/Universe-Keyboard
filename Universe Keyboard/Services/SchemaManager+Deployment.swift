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

    var hasLiveRimeDeployment: Bool { activeRimeDeploymentTask != nil }

    var isDeploymentMarkedInProgress: Bool { settings.bool(forKey: "rime_deploying") }

    func markDeploymentInProgress() {
        settings.set(true, forKey: "rime_deploying")
        settings.set(false, forKey: "rime_deployed")
        settings.synchronize()
    }

    func markDeploymentInterrupted() {
        settings.set(false, forKey: "rime_deploying")
        settings.set(true, forKey: "rime_needs_deploy")
        settings.set(false, forKey: "rime_deployed")
        settings.set(true, forKey: "rime_deploy_auto_retry_suppressed")
        settings.synchronize()
    }

    func cancelActiveRimeDeployment() {
        guard activeRimeDeploymentID != nil || activeRimeDeploymentTask != nil else { return }
        activeRimeDeploymentID = nil
        let task = activeRimeDeploymentTask
        activeRimeDeploymentTask = nil
        task?.cancel()
    }

    @discardableResult
    func deployRimeConfig(
        leaseOperationID: UUID? = nil,
        pendingSchemaID: String? = nil,
        publishNineKeyReadiness: Bool = true
    ) async -> Bool {
        if let owner = schemeDeliveryCommitLeaseOperationID, owner != leaseOperationID {
            return await waitForPostCommitDeployment()
        }
        if let activeRimeDeploymentTask {
            return await activeRimeDeploymentTask.value
        }
        let deploymentID = UUID()
        activeRimeDeploymentID = deploymentID
        // 只在真正新建部署任务时申请。租约等待和复用进行中的任务不申请。
        // 取消只清句柄，token 要等到这次 await 返回才结束。到期不改部署结果。
        let suspensionToken = MainAppSuspensionGuard.shared.begin(reason: "rime-deployment")
        let task = Task { @MainActor [weak self] in
            guard let self else { return false }
            return await self.performRimeDeployment(
                deploymentID: deploymentID,
                pendingSchemaID: pendingSchemaID,
                publishNineKeyReadiness: publishNineKeyReadiness
            )
        }
        activeRimeDeploymentTask = task
        let succeeded = await task.value
        if let suspensionToken {
            MainAppSuspensionGuard.shared.end(suspensionToken)
        }
        if activeRimeDeploymentID == deploymentID {
            activeRimeDeploymentID = nil
            activeRimeDeploymentTask = nil
        }
        return succeeded
    }

    /// The only body that mutates shared deployment files. All public callers
    /// enter through `deployRimeConfig`, which provides process-local single-flight.
    private func performRimeDeployment(
        deploymentID: UUID,
        pendingSchemaID: String?,
        publishNineKeyReadiness: Bool
    ) async -> Bool {
        guard isActiveRimeDeployment(deploymentID) else { return false }
        // Invalidate before any writable resource preparation. A thrown
        // `deploymentDirectories` still leaves both markers unready.
        T9DeploymentSupport.invalidateAllReadiness(settings: settings)

        let directories: SchemaDeploymentDirectories
        do {
            directories = try archiveInstaller.deploymentDirectories(pendingSchemaID: pendingSchemaID)
        } catch {
            // Keep the log content-free while distinguishing preparation from
            // the later librime deployment transaction.
            Logger.shared.error(
                "deployRimeConfig: 内置资源验证或 App Group 准备失败",
                category: .deployment
            )
            return false
        }

        guard isActiveRimeDeployment(deploymentID) else { return false }
        Logger.shared.info("deployRimeConfig: 开始主 App 端全量部署", category: .deployment)

        // `deploymentDirectories()` commits immutable resources and dynamic
        // overlays inside one recoverable main-App transaction. Do not repeat
        // overlay writes here or split their authorization from the base
        // generation receipt.
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

        let wanxiangNineKeyInstalled =
            settings.bool(forKey: "wanxiang_installed") || pendingSchemaID == "wanxiang"
        var suppressWanxiangNineKeyMarker = false
        if wanxiangNineKeyInstalled {
            let prepared = WanxiangT9DeploymentSupport.prepare(
                sharedDataURL: directories.sharedDataURL,
                userDataURL: directories.userDataURL
            )
            for step in prepared.steps {
                Logger.shared.info(
                    "deployRimeConfig: \(WanxiangT9DeploymentSupport.logText(step))",
                    category: .deployment
                )
            }
            // Design §B: a failed prepare leaves this scheme unready. The shared deploy still runs.
            if prepared.failed {
                suppressWanxiangNineKeyMarker = true
                Logger.shared.warning(
                    "deployRimeConfig: wanxiang nine-key prepare failed; marker stays unready",
                    category: .deployment
                )
            }
        }

        guard isActiveRimeDeployment(deploymentID) else { return false }
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
            guard isActiveRimeDeployment(deploymentID) else { return false }
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
                guard
                    let librimeVersion = RimeDeploymentIdentity.normalizedVersion(
                        from: result.librimeVersion
                    )
                else {
                    Logger.shared.error(
                        "deployRimeConfig: missing librime identity; deployment remains pending",
                        category: .deployment
                    )
                    settings.set(false, forKey: "rime_deployed")
                    settings.set(true, forKey: "rime_needs_deploy")
                    settings.set(false, forKey: "rime_deploying")
                    settings.synchronize()
                    return false
                }
                Logger.shared.info(
                    "deployRimeConfig: 部署成功 ✓ librime=\(librimeVersion)",
                    category: .deployment
                )
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
                if wanxiangNineKeyInstalled {
                    let check = WanxiangT9DeploymentSupport.recheckCompiled(
                        sharedDataURL: directories.sharedDataURL,
                        userDataURL: directories.userDataURL
                    )
                    Logger.shared.info(
                        "deployRimeConfig: \(WanxiangT9DeploymentSupport.logText(check.step))",
                        category: .deployment
                    )
                }
                if publishNineKeyReadiness {
                    _ = publishIndependentNineKeyReadiness(
                        sharedDataURL: directories.sharedDataURL,
                        userDataURL: directories.userDataURL,
                        pendingSchemaID: pendingSchemaID,
                        suppressSchemaIDs: suppressWanxiangNineKeyMarker
                            ? [WanxiangT9DeploymentSupport.schemaID] : []
                    )
                }
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

    /// After a shared deploy: per installed family, rewrite check, select+smoke, marker.
    /// Opens the engine only when that family's compiled schema is already on disk.
    /// Returns whether the user route was restored; failure forces 26-key.
    @discardableResult
    func publishIndependentNineKeyReadiness(
        sharedDataURL: URL,
        userDataURL: URL,
        pendingSchemaID: String? = nil,
        schemes: [NineKeyScheme]? = nil,
        suppressSchemaIDs: Set<String> = []
    ) -> Bool {
        let ordered = schemes ?? NineKeySchemeRegistry.entries
        var openedEngine = false
        for scheme in ordered where nineKeyFamilyInstalled(scheme, pendingSchemaID: pendingSchemaID) {
            if suppressSchemaIDs.contains(scheme.schemaID) { continue }
            guard
                nineKeyCompiledSchemaIsClean(
                    scheme,
                    sharedDataURL: sharedDataURL,
                    userDataURL: userDataURL
                )
            else { continue }
            let input = NineKeySchemeRegistry.smokeInput(for: scheme.schemaID) ?? ""
            openedEngine = true
            let smoked =
                NineKeyPublishSmoke.override?(
                    sharedDataURL.path,
                    userDataURL.path,
                    scheme.schemaID,
                    input
                )
                ?? RimeT9SmokeProbe.verify(
                    sharedDataDir: sharedDataURL.path,
                    userDataDir: userDataURL.path,
                    schemaID: scheme.schemaID,
                    input: input
                )
            guard
                smoked,
                let fingerprint = T9DeploymentSupport.resourceFingerprint(
                    schemaID: scheme.schemaID,
                    sharedDataURL: sharedDataURL
                )
            else { continue }
            let upstreamFamily = scheme.familyID == "rime_ice" ? "rime_ice" : scheme.familyID
            T9DeploymentSupport.writeMatchedReadiness(
                schemaID: scheme.schemaID,
                fingerprint: fingerprint,
                upstreamVersion: installedVersion(for: upstreamFamily),
                settings: settings
            )
        }
        guard openedEngine else { return true }
        let restored = restoreNineKeyEngineRoute(sharedDataURL: sharedDataURL, userDataURL: userDataURL)
        if !restored {
            T9DeploymentSupport.persistLayout(.twentySixKey, settings: settings)
        }
        return restored
    }

    func nineKeyFamilyInstalled(_ scheme: NineKeyScheme, pendingSchemaID: String? = nil) -> Bool {
        switch scheme.familyID {
        case "rime_ice":
            return rimeIceFilesExist()
        case "wanxiang":
            return settings.bool(forKey: "wanxiang_installed") || pendingSchemaID == "wanxiang"
        default:
            return false
        }
    }

    func nineKeyCompiledSchemaIsClean(
        _ scheme: NineKeyScheme,
        sharedDataURL: URL,
        userDataURL: URL
    ) -> Bool {
        if scheme.familyID == "wanxiang" {
            return WanxiangT9DeploymentSupport.rewriteCheckPassed(
                sharedDataURL: sharedDataURL,
                userDataURL: userDataURL
            )
        }
        let userBuild = userDataURL.appendingPathComponent("build/\(scheme.schemaFileName)")
        let sharedBuild = sharedDataURL.appendingPathComponent("build/\(scheme.schemaFileName)")
        let loaded = FileManager.default.fileExists(atPath: userBuild.path) ? userBuild : sharedBuild
        guard FileManager.default.fileExists(atPath: loaded.path),
            let text = try? String(contentsOf: loaded, encoding: .utf8)
        else { return false }
        if text.contains("t9_processor") { return false }
        return !T9SchemaForceGCInspector.forceGCTranslatorPresent(inYAML: text)
    }

    func registeredNineKeyRouteInputs(sharedDataURL: URL?) -> (
        readinessBySchema: [String: Bool], installedFamilies: Set<String>
    ) {
        var readinessBySchema: [String: Bool] = [:]
        var installedFamilies = Set<String>()
        for scheme in NineKeySchemeRegistry.entries {
            let fingerprint = sharedDataURL.flatMap {
                T9DeploymentSupport.resourceFingerprint(schemaID: scheme.schemaID, sharedDataURL: $0)
            }
            let marker = T9DeploymentSupport.loadMarker(schemaID: scheme.schemaID, settings: settings)
            readinessBySchema[scheme.schemaID] = NineKeyReadiness.isMatched(
                schemaID: scheme.schemaID,
                marker: marker,
                fingerprint: fingerprint
            )
            if nineKeyFamilyInstalled(scheme) {
                installedFamilies.insert(scheme.familyID)
            }
        }
        return (readinessBySchema, installedFamilies)
    }

    func registeredRuntimeSelection(sharedDataURL: URL?) -> RimeRuntimeSelection {
        ensureLayoutSchemeBindingsMigrated()
        let inputs = registeredNineKeyRouteInputs(sharedDataURL: sharedDataURL)
        let fingerprint = sharedDataURL.flatMap {
            T9DeploymentSupport.resourceFingerprint(sharedDataURL: $0)
        }
        return RimeRuntimeSelection.resolveRegistered(
            baseSchemaID: settings.string(forKey: "rime_active_schema") ?? activeSchemaID,
            layoutRawValue: settings.string(forKey: KeyboardLayoutSettingsKey.layoutStyle),
            readinessMarker: T9DeploymentSupport.loadMarker(settings: settings),
            onDiskFingerprint: fingerprint,
            schemeBinding26: schemeBinding26(),
            schemeBinding9: schemeBinding9(),
            readinessBySchema: inputs.readinessBySchema,
            installedFamilies: inputs.installedFamilies
        )
    }

    func restoreNineKeyEngineRoute(sharedDataURL: URL, userDataURL: URL) -> Bool {
        let selection = registeredRuntimeSelection(sharedDataURL: sharedDataURL)
        return RimeT9SmokeProbe.selectAndConfirm(
            sharedDataDir: sharedDataURL.path,
            userDataDir: userDataURL.path,
            schemaID: selection.effectiveSchemaID
        )
    }

    private func isActiveRimeDeployment(_ deploymentID: UUID) -> Bool {
        activeRimeDeploymentID == deploymentID && !Task.isCancelled
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
    func fuzzyTargetSchemaIDs(sharedDataURL: URL) -> [String] {
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
            .filter { schemaID in
                // Fog `t9` is already mapped to `rime_ice`. Other registered nine-key
                // schemas are not full-keyboard post-process targets.
                if let scheme = NineKeySchemeRegistry.scheme(schemaID), scheme.familyID != "rime_ice" {
                    return false
                }
                return RimeRuntimeSelection.isTwentySixKeyCapable(schemaID)
            }
            .sorted()
    }

    private var activeSchemaIDForDeployment: String {
        settings.string(forKey: "rime_active_schema") ?? "luna_pinyin"
    }

    private func currentFuzzyPinyinSettings() -> RimeFuzzyPinyinSettings {
        RimeFuzzyPinyinSettings(
            enabled: settings.object(forKey: RimeFuzzyPinyinSettings.enabledKey) as? Bool ?? false,
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

    /// Download and full deploy both pass the runtime user directory into prepare.
    /// A missing runtime directory keeps prepare's sibling fallback and is logged.
    func prepareWanxiangNineKeyDownloadSource(sharedDataURL: URL) throws {
        let source = sharedDataURL.appendingPathComponent(WanxiangT9DeploymentSupport.sourceFileName)
        guard FileManager.default.fileExists(atPath: source.path) else { return }
        let userDataURL = (try? archiveInstaller.runtimeDirectories())?.userDataURL
        if userDataURL == nil {
            Logger.shared.warning(
                "deployRimeConfig: wanxiang nine-key prepare has no runtime user directory",
                category: .deployment
            )
        }
        let prepared = WanxiangT9DeploymentSupport.prepare(
            sharedDataURL: sharedDataURL,
            userDataURL: userDataURL
        )
        for step in prepared.steps {
            Logger.shared.info(
                "deployRimeConfig: \(WanxiangT9DeploymentSupport.logText(step))",
                category: .deployment
            )
        }
        if prepared.failed {
            throw DownloadError.postProcessingFailed(prepared.steps.last?.reason ?? "rewriteFailed")
        }
    }

    private func supportedAdvancedInputFeatures(for schemaID: String) -> Set<RimeAdvancedInputFeature> {
        RimeSchemeCapabilityMatrix.profile(for: schemaID).supportsProductAdvancedInput
            ? Set(RimeAdvancedInputFeature.allCases)
            : []
    }
}

/// Nil in production. Tests substitute nine-key smoke without opening librime.
@MainActor
enum NineKeyPublishSmoke {
    static var override: ((String, String, String, String) -> Bool)?
}
