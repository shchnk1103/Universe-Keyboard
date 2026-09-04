import Foundation
import KeyboardCore
import RimeBridge
import XCTest

@testable import Universe_Keyboard

@MainActor
final class RimeSettingsStoreTests: XCTestCase {
    func testDefaultAppGroupSettingsStoreDeinitDoesNotAbort() async {
        var settings: AppGroupSharedSettingsStore? = AppGroupSharedSettingsStore(
            appGroupID: SchemaManager.appGroupID
        )
        settings?.synchronize()
        settings = nil
        XCTAssertNil(settings)
    }

    func testDefaultSchemaManagerDeinitDoesNotAbort() async {
        var manager: SchemaManager? = SchemaManager()
        _ = manager?.activeSchemaID
        manager = nil
        XCTAssertNil(manager)
    }

    func testLoadReadsPreferencesThroughInjectedPersistence() async {
        let persistence = StubRimeSettingsPersistence(
            values: ["rime_page_size": 12, "rime_simplification": false]
        )
        let deploymentService = StoreDeploymentService(succeeded: true)
        let store = makeIsolatedStore(
            persistence: persistence,
            deploymentService: deploymentService
        )

        store.load()

        XCTAssertEqual(store.pageSize, 12)
        XCTAssertFalse(store.simplified)
        XCTAssertFalse(store.fuzzyEnabled)
        XCTAssertTrue(store.fuzzyZhZEnabled)
        XCTAssertTrue(store.fuzzyChCEnabled)
        XCTAssertTrue(store.fuzzyShSEnabled)
        XCTAssertTrue(store.fuzzyNLEnabled)
        XCTAssertTrue(store.advancedInputMasterEnabled)
        XCTAssertTrue(store.isAdvancedInputFeatureEnabled(.dateTime))
        XCTAssertTrue(store.lunaPinyinUserDictionaryEnabled)
        XCTAssertTrue(store.rimeIceUserDictionaryEnabled)
        XCTAssertFalse(store.userDictionaryAutoBackupEnabled)
    }

    func testLoadSeedsBuiltinDeployIntentOnFreshAppGroup() async {
        let persistence = StubRimeSettingsPersistence()
        let deploymentService = StoreDeploymentService(succeeded: true)
        let store = makeIsolatedStore(
            persistence: persistence,
            deploymentService: deploymentService
        )

        store.load()

        XCTAssertEqual(persistence.value(forKey: "rime_needs_deploy") as? Bool, true)
        XCTAssertEqual(store.deploymentState, .needsDeploy)
    }

    func testLoadDoesNotSeedDeployIntentWhenAlreadyDeployed() async {
        let persistence = StubRimeSettingsPersistence(values: ["rime_deployed": true])
        let deploymentService = StoreDeploymentService(succeeded: true)
        let store = makeIsolatedStore(
            persistence: persistence,
            deploymentService: deploymentService
        )

        store.load()

        XCTAssertNil(persistence.value(forKey: "rime_needs_deploy"))
        XCTAssertEqual(store.deploymentState, .deployed)
    }

    func testLoadDoesNotSeedDeployIntentWhenAutomaticRetryIsSuppressed() async {
        let persistence = StubRimeSettingsPersistence(
            values: ["rime_deploy_auto_retry_suppressed": true]
        )
        let deploymentService = StoreDeploymentService(succeeded: true)
        let store = makeIsolatedStore(
            persistence: persistence,
            deploymentService: deploymentService
        )

        store.load()

        XCTAssertNil(persistence.value(forKey: "rime_needs_deploy"))
        XCTAssertEqual(store.deploymentState, .idle)
    }

    func testTriggerPendingDeploymentIfNeededRunsAfterFreshLoadSeed() async {
        let settings = StoreSharedSettingsStore()
        let deploymentService = StoreDeploymentService(succeeded: true)
        let persistence = StubRimeSettingsPersistence()
        let store = makeIsolatedStore(
            persistence: persistence,
            deploymentService: deploymentService,
            settings: settings
        )

        store.load()
        XCTAssertEqual(persistence.value(forKey: "rime_needs_deploy") as? Bool, true)

        await store.triggerPendingDeploymentIfNeeded()

        let requests = await deploymentService.requests
        XCTAssertEqual(requests.count, 1)
        XCTAssertEqual(store.deploymentState, .deployed)
    }

    func testLoadReadsStoredFuzzyPinyinPreferences() async {
        let persistence = StubRimeSettingsPersistence(
            values: [
                RimeFuzzyPinyinSettings.enabledKey: false,
                RimeFuzzyPinyinSettings.zhZKey: false,
                RimeFuzzyPinyinSettings.chCKey: true,
                RimeFuzzyPinyinSettings.shSKey: false,
                RimeFuzzyPinyinSettings.nLKey: false,
            ]
        )
        let deploymentService = StoreDeploymentService(succeeded: true)
        let store = makeIsolatedStore(
            persistence: persistence,
            deploymentService: deploymentService
        )

        store.load()

        XCTAssertFalse(store.fuzzyEnabled)
        XCTAssertFalse(store.fuzzyZhZEnabled)
        XCTAssertTrue(store.fuzzyChCEnabled)
        XCTAssertFalse(store.fuzzyShSEnabled)
        XCTAssertFalse(store.fuzzyNLEnabled)
    }

    func testLoadReadsStoredUserDictionaryPreferences() {
        let persistence = StubRimeSettingsPersistence(
            values: [
                RimeUserDictionarySettings.lunaPinyinEnabledKey: false,
                RimeUserDictionarySettings.rimeIceEnabledKey: true,
            ]
        )
        let deploymentService = StoreDeploymentService(succeeded: true)
        let store = makeIsolatedStore(
            persistence: persistence,
            deploymentService: deploymentService
        )

        store.load()

        XCTAssertFalse(store.lunaPinyinUserDictionaryEnabled)
        XCTAssertTrue(store.rimeIceUserDictionaryEnabled)
    }

    func testLoadReadsStoredAdvancedInputPreferences() {
        let persistence = StubRimeSettingsPersistence(
            values: [
                RimeAdvancedInputSettings.masterEnabledKey: true,
                RimeAdvancedInputSettings.enabledKey(for: .dateTime): false,
                RimeAdvancedInputSettings.enabledKey(for: .calculator): true,
            ]
        )
        let deploymentService = StoreDeploymentService(succeeded: true)
        let store = makeIsolatedStore(
            persistence: persistence,
            deploymentService: deploymentService
        )

        store.load()

        XCTAssertTrue(store.advancedInputMasterEnabled)
        XCTAssertFalse(store.isAdvancedInputFeatureEnabled(.dateTime))
        XCTAssertTrue(store.isAdvancedInputFeatureEnabled(.calculator))
    }

    func testSaveFuzzyPinyinSettingsPersistsAndMarksDeploymentNeeded() {
        let persistence = StubRimeSettingsPersistence()
        let store = makeIsolatedStore(persistence: persistence)
        store.fuzzyEnabled = true
        store.fuzzyZhZEnabled = false
        store.fuzzyChCEnabled = true
        store.fuzzyShSEnabled = false
        store.fuzzyNLEnabled = true

        store.saveFuzzyPinyinSettings()

        XCTAssertEqual(persistence.value(forKey: RimeFuzzyPinyinSettings.enabledKey) as? Bool, true)
        XCTAssertEqual(persistence.value(forKey: RimeFuzzyPinyinSettings.zhZKey) as? Bool, false)
        XCTAssertEqual(persistence.value(forKey: RimeFuzzyPinyinSettings.chCKey) as? Bool, true)
        XCTAssertEqual(persistence.value(forKey: RimeFuzzyPinyinSettings.shSKey) as? Bool, false)
        XCTAssertEqual(persistence.value(forKey: RimeFuzzyPinyinSettings.nLKey) as? Bool, true)
        XCTAssertEqual(persistence.value(forKey: "rime_deployed") as? Bool, false)
        XCTAssertEqual(persistence.value(forKey: "rime_needs_deploy") as? Bool, true)
        XCTAssertEqual(store.deploymentState, .needsDeploy)
    }

    func testSaveFuzzyPinyinSettingsSkipsDeployWhenSignatureAlreadyMatches() {
        // Multi-scheme deploy uses preference-only signature (`schema=all`), not
        // the active letter schema id (see RimeSettingsStore.updateFuzzyDeploymentIntent).
        let signature = RimeFuzzyPinyinSettings().deploymentSignature(activeSchemaID: "all")
        let persistence = StubRimeSettingsPersistence(
            values: [RimeFuzzyPinyinSettings.deployedSignatureKey: signature]
        )
        let store = makeIsolatedStore(persistence: persistence)

        store.saveFuzzyPinyinSettings()

        XCTAssertEqual(persistence.value(forKey: RimeFuzzyPinyinSettings.pendingDeployKey) as? Bool, false)
        XCTAssertNil(persistence.value(forKey: "rime_needs_deploy"))
        XCTAssertEqual(store.deploymentState, .idle)
    }

    func testSaveUserDictionarySettingsPersistsAndMarksDeploymentNeeded() {
        let persistence = StubRimeSettingsPersistence()
        let store = makeIsolatedStore(persistence: persistence)
        store.lunaPinyinUserDictionaryEnabled = false
        store.rimeIceUserDictionaryEnabled = true

        store.saveUserDictionarySettings()

        XCTAssertEqual(persistence.value(forKey: RimeUserDictionarySettings.lunaPinyinEnabledKey) as? Bool, false)
        XCTAssertEqual(persistence.value(forKey: RimeUserDictionarySettings.rimeIceEnabledKey) as? Bool, true)
        XCTAssertEqual(persistence.value(forKey: RimeUserDictionarySettings.pendingDeployKey) as? Bool, true)
        XCTAssertEqual(persistence.value(forKey: "rime_deployed") as? Bool, false)
        XCTAssertEqual(persistence.value(forKey: "rime_needs_deploy") as? Bool, true)
        XCTAssertEqual(store.deploymentState, .needsDeploy)
    }

    func testSaveUserDictionarySettingsSkipsDeployWhenSignatureAlreadyMatches() {
        let signature = RimeUserDictionarySettings().deploymentSignature()
        let persistence = StubRimeSettingsPersistence(
            values: [RimeUserDictionarySettings.deployedSignatureKey: signature]
        )
        let store = makeIsolatedStore(persistence: persistence)

        store.saveUserDictionarySettings()

        XCTAssertEqual(persistence.value(forKey: RimeUserDictionarySettings.pendingDeployKey) as? Bool, false)
        XCTAssertNil(persistence.value(forKey: "rime_needs_deploy"))
        XCTAssertEqual(store.deploymentState, .idle)
    }

    func testSaveAdvancedInputSettingsPersistsAndMarksDeploymentNeeded() {
        let settings = StoreSharedSettingsStore(values: ["rime_active_schema": "rime_ice"])
        let persistence = StubRimeSettingsPersistence()
        let store = makeIsolatedStore(persistence: persistence, settings: settings)
        store.advancedInputMasterEnabled = true
        store.advancedInputFeatureEnabled[.dateTime] = false

        store.saveAdvancedInputSettings()

        XCTAssertEqual(persistence.value(forKey: RimeAdvancedInputSettings.masterEnabledKey) as? Bool, true)
        XCTAssertEqual(
            persistence.value(forKey: RimeAdvancedInputSettings.enabledKey(for: .dateTime)) as? Bool,
            false
        )
        XCTAssertEqual(persistence.value(forKey: RimeAdvancedInputSettings.pendingDeployKey) as? Bool, true)
        XCTAssertEqual(persistence.value(forKey: "rime_deployed") as? Bool, false)
        XCTAssertEqual(persistence.value(forKey: "rime_needs_deploy") as? Bool, true)
        XCTAssertEqual(store.deploymentState, .needsDeploy)
    }

    func testSaveAdvancedInputSettingsSkipsDeployWhenSignatureAlreadyMatches() {
        let settings = StoreSharedSettingsStore(values: ["rime_active_schema": "rime_ice"])
        let signature = RimeAdvancedInputSettings().deploymentSignature(
            activeSchemaID: "rime_ice",
            supportedFeatures: Set(RimeAdvancedInputFeature.allCases)
        )
        let persistence = StubRimeSettingsPersistence(
            values: [RimeAdvancedInputSettings.deployedSignatureKey: signature]
        )
        let store = makeIsolatedStore(persistence: persistence, settings: settings)

        store.saveAdvancedInputSettings()

        XCTAssertEqual(persistence.value(forKey: RimeAdvancedInputSettings.pendingDeployKey) as? Bool, false)
        XCTAssertNil(persistence.value(forKey: "rime_needs_deploy"))
        XCTAssertEqual(store.deploymentState, .idle)
    }

    func testAdvancedInputUnsupportedSchemeKeepsSettingsButDisablesCapability() {
        let settings = StoreSharedSettingsStore(values: [
            "rime_active_schema": "luna_pinyin",
            KeyboardLayoutSettingsKey.schemeBinding26: "luna_pinyin",
            KeyboardLayoutSettingsKey.layoutStyle: KeyboardLayoutStyle.twentySixKey.rawValue,
        ])
        let store = makeIsolatedStore(settings: settings)

        XCTAssertFalse(store.activeSchemaSupportsAdvancedInput)
        XCTAssertFalse(store.supportsProductAdvancedInput)
        XCTAssertFalse(store.advancedInputFeatureIsSupported(.dateTime))
        // TD-011 A: luna uses native status note (not the generic「暂不支持」line).
        XCTAssertTrue(store.activeSchemaAdvancedInputStatusText.contains("朙月"))
        XCTAssertTrue(store.activeSchemaAdvancedInputStatusText.contains("选择会保留"))
    }

    func testAdvancedInputSupportedSchemeReportsAvailablePreferences() {
        let settings = StoreSharedSettingsStore(
            values: [
                "rime_active_schema": "rime_ice",
                "rime_ice_installed": true,
                KeyboardLayoutSettingsKey.schemeBinding26: "rime_ice",
                KeyboardLayoutSettingsKey.layoutStyle: KeyboardLayoutStyle.twentySixKey.rawValue,
            ]
        )
        let store = makeIsolatedStore(
            settings: settings,
            archiveInstaller: StoreArchiveInstaller(containsInstalledSchema: true)
        )

        XCTAssertTrue(store.activeSchemaSupportsAdvancedInput)
        XCTAssertTrue(store.supportsProductAdvancedInput)
        XCTAssertTrue(store.advancedInputFeatureIsSupported(RimeAdvancedInputFeature.calculator))
        XCTAssertTrue(store.activeSchemaAdvancedInputStatusText.contains("支持这些高级输入功能"))
    }

    func testWanxiangLayoutBindingGatesFuzzyAndAdvancedWithoutClearingPreferences() {
        let settings = StoreSharedSettingsStore(
            values: [
                "rime_active_schema": "wanxiang",
                KeyboardLayoutSettingsKey.schemeBinding26: "wanxiang",
                KeyboardLayoutSettingsKey.layoutStyle: KeyboardLayoutStyle.twentySixKey.rawValue,
                RimeFuzzyPinyinSettings.enabledKey: true,
                RimeAdvancedInputSettings.masterEnabledKey: true,
            ]
        )
        let persistence = StubRimeSettingsPersistence(
            values: [
                "rime_deployed": true,
                RimeFuzzyPinyinSettings.enabledKey: true,
                RimeAdvancedInputSettings.masterEnabledKey: true,
            ]
        )
        let store = makeIsolatedStore(persistence: persistence, settings: settings)
        store.load()

        XCTAssertEqual(store.settingsCapabilitySchemaID, "wanxiang")
        XCTAssertFalse(store.supportsManagedFuzzyPinyin)
        XCTAssertFalse(store.supportsProductAdvancedInput)
        XCTAssertTrue(store.fuzzyEnabled, "stored preference must remain")
        XCTAssertTrue(store.advancedInputMasterEnabled, "stored preference must remain")
        XCTAssertTrue(store.fuzzyPinyinCapabilityStatusText.contains("万象"))
        XCTAssertTrue(store.fuzzyPinyinCapabilityStatusText.contains("暂不支持"))
        XCTAssertTrue(
            store.activeSchemaAdvancedInputStatusText.contains("/rq")
                || store.activeSchemaAdvancedInputStatusText.contains("orq"),
            "万象 advanced status should teach native triggers (TD-011 A)"
        )

        store.fuzzyEnabled = false
        store.saveFuzzyPinyinSettings()
        XCTAssertEqual(
            persistence.value(forKey: RimeFuzzyPinyinSettings.enabledKey) as? Bool,
            true,
            "unsupported scheme must not write fuzzy prefs or mark deploy"
        )
        XCTAssertNil(persistence.value(forKey: "rime_needs_deploy"))

        // Switch back to 雾凇: stored preference must still be on without re-picking.
        settings.set("rime_ice", forKey: "rime_active_schema")
        settings.set("rime_ice", forKey: KeyboardLayoutSettingsKey.schemeBinding26)
        store.load()
        XCTAssertTrue(store.supportsManagedFuzzyPinyin)
        XCTAssertTrue(store.fuzzyEnabled)
        XCTAssertTrue(store.advancedInputMasterEnabled)
    }

    func testNineKeyLayoutUsesFogCapabilityWhileTwentySixKeyIsWanxiang() {
        let settings = StoreSharedSettingsStore(
            values: [
                "rime_active_schema": "wanxiang",
                KeyboardLayoutSettingsKey.schemeBinding26: "wanxiang",
                KeyboardLayoutSettingsKey.schemeBinding9: "t9",
                KeyboardLayoutSettingsKey.layoutStyle: KeyboardLayoutStyle.nineKey.rawValue,
            ]
        )
        let store = makeIsolatedStore(settings: settings)
        XCTAssertEqual(store.settingsCapabilitySchemaID, "rime_ice")
        XCTAssertTrue(store.supportsManagedFuzzyPinyin)
        XCTAssertTrue(store.supportsProductAdvancedInput)
    }

    func testTriggerFuzzyDeploymentIfNeededOnlyRunsWhenPending() async {
        let settings = StoreSharedSettingsStore()
        let deploymentService = StoreDeploymentService(succeeded: true)
        let persistence = StubRimeSettingsPersistence(
            values: [RimeFuzzyPinyinSettings.pendingDeployKey: true]
        )
        let store = RimeSettingsStore(
            schemaManager: SchemaManager(
                settings: settings,
                sourceSelector: StoreSourceSelector(),
                archiveDownloader: StoreArchiveDownloader(),
                archiveInstaller: StoreArchiveInstaller(),
                deploymentService: deploymentService
            ),
            persistence: persistence
        )

        await store.triggerFuzzyDeploymentIfNeeded()

        let requests = await deploymentService.requests
        XCTAssertEqual(requests.count, 1)
        XCTAssertEqual(store.deploymentState, .deployed)
    }

    func testTriggerPendingDeploymentIfNeededRunsForUserDictionaryIntent() async {
        let settings = StoreSharedSettingsStore()
        let deploymentService = StoreDeploymentService(succeeded: true)
        let persistence = StubRimeSettingsPersistence(
            values: [RimeUserDictionarySettings.pendingDeployKey: true]
        )
        let store = RimeSettingsStore(
            schemaManager: SchemaManager(
                settings: settings,
                sourceSelector: StoreSourceSelector(),
                archiveDownloader: StoreArchiveDownloader(),
                archiveInstaller: StoreArchiveInstaller(),
                deploymentService: deploymentService
            ),
            persistence: persistence
        )

        await store.triggerPendingDeploymentIfNeeded()

        let requests = await deploymentService.requests
        XCTAssertEqual(requests.count, 1)
        XCTAssertEqual(store.deploymentState, .deployed)
    }

    func testTriggerPendingDeploymentIfNeededRunsForGenericNeedsDeployIntent() async {
        let settings = StoreSharedSettingsStore()
        let deploymentService = StoreDeploymentService(succeeded: true)
        let persistence = StubRimeSettingsPersistence(values: ["rime_needs_deploy": true])
        let store = RimeSettingsStore(
            schemaManager: SchemaManager(
                settings: settings,
                sourceSelector: StoreSourceSelector(),
                archiveDownloader: StoreArchiveDownloader(),
                archiveInstaller: StoreArchiveInstaller(),
                deploymentService: deploymentService
            ),
            persistence: persistence
        )

        await store.triggerPendingDeploymentIfNeeded()

        let requests = await deploymentService.requests
        XCTAssertEqual(requests.count, 1)
        XCTAssertEqual(store.deploymentState, .deployed)
    }

    func testTriggerPendingDeploymentIfNeededDoesNotLoopAfterFailure() async {
        let settings = StoreSharedSettingsStore()
        let deploymentService = StoreDeploymentService(succeeded: false)
        let persistence = StubRimeSettingsPersistence(values: ["rime_needs_deploy": true])
        let store = RimeSettingsStore(
            schemaManager: SchemaManager(
                settings: settings,
                sourceSelector: StoreSourceSelector(),
                archiveDownloader: StoreArchiveDownloader(),
                archiveInstaller: StoreArchiveInstaller(),
                deploymentService: deploymentService
            ),
            persistence: persistence
        )

        await store.triggerPendingDeploymentIfNeeded()
        await store.triggerPendingDeploymentIfNeeded()

        let requests = await deploymentService.requests
        XCTAssertEqual(requests.count, 1)
        XCTAssertEqual(store.deploymentState, .failed)
    }

    func testFailedAutomaticDeploymentRemainsSuppressedAfterLoadAndRelaunch() async {
        let settings = StoreSharedSettingsStore()
        let deploymentService = StoreDeploymentService(succeeded: false)
        let persistence = StubRimeSettingsPersistence(values: ["rime_needs_deploy": true])
        let schemaManager = SchemaManager(
            settings: settings,
            sourceSelector: StoreSourceSelector(),
            archiveDownloader: StoreArchiveDownloader(),
            archiveInstaller: StoreArchiveInstaller(),
            deploymentService: deploymentService
        )
        let store = RimeSettingsStore(schemaManager: schemaManager, persistence: persistence)

        await store.triggerPendingDeploymentIfNeeded()
        store.load()
        await store.triggerPendingDeploymentIfNeeded()

        let relaunchedStore = RimeSettingsStore(schemaManager: schemaManager, persistence: persistence)
        // App 启动时会先 load；这里复现真实生命周期，再验证失败锁存不会被自动重试绕过。
        relaunchedStore.load()
        await relaunchedStore.triggerPendingDeploymentIfNeeded()

        let requests = await deploymentService.requests
        XCTAssertEqual(requests.count, 1)
        XCTAssertEqual(store.deploymentState, .failed)
        XCTAssertEqual(relaunchedStore.deploymentState, .failed)
    }

    func testManualDeploymentCanRetryAfterAutomaticFailure() async {
        let settings = StoreSharedSettingsStore()
        let deploymentService = StoreDeploymentService(succeeded: false)
        let persistence = StubRimeSettingsPersistence(values: ["rime_needs_deploy": true])
        let store = RimeSettingsStore(
            schemaManager: SchemaManager(
                settings: settings,
                sourceSelector: StoreSourceSelector(),
                archiveDownloader: StoreArchiveDownloader(),
                archiveInstaller: StoreArchiveInstaller(),
                deploymentService: deploymentService
            ),
            persistence: persistence
        )

        await store.triggerPendingDeploymentIfNeeded()
        await store.triggerDeployment()

        let requests = await deploymentService.requests
        XCTAssertEqual(requests.count, 2)
        XCTAssertEqual(store.deploymentState, .failed)
    }

    func testNewGenericIntentAllowsOneAutomaticAttemptAfterPriorFailure() async {
        let persistence = StoreSharedSettingsStore(values: ["rime_needs_deploy": true])
        let deploymentService = StoreDeploymentService(succeeded: false)
        let schemaManager = SchemaManager(
            settings: persistence,
            sourceSelector: StoreSourceSelector(),
            archiveDownloader: StoreArchiveDownloader(),
            archiveInstaller: StoreArchiveInstaller(),
            deploymentService: deploymentService
        )
        let store = RimeSettingsStore(schemaManager: schemaManager, persistence: persistence)

        await store.triggerPendingDeploymentIfNeeded()
        schemaManager.requestDeploy()
        store.load()
        await store.triggerPendingDeploymentIfNeeded()
        await store.triggerPendingDeploymentIfNeeded()

        let requests = await deploymentService.requests
        XCTAssertEqual(requests.count, 2)
        XCTAssertEqual(store.deploymentState, .failed)
    }

    func testBackupUserDictionaryShowsPlainUserMessage() {
        let backupService = StoreUserDictionaryBackupService(
            backupResult: .init(succeeded: true, message: "已备份 朙月拼音 的学习记录。")
        )
        let store = makeIsolatedStore(userDictionaryBackupService: backupService)

        store.backupUserDictionary(for: "luna_pinyin")

        XCTAssertEqual(store.userDictionaryMessage, "已备份 朙月拼音 的学习记录。")
        XCTAssertTrue(store.userDictionaryMessageSucceeded)
        XCTAssertEqual(store.userDictionaryMessageVersion, 1)
    }

    func testRestoreUserDictionaryMarksPendingDeploymentWhenSuccessful() {
        let persistence = StubRimeSettingsPersistence()
        let backupService = StoreUserDictionaryBackupService(
            restoreResult: .init(succeeded: true, message: "已恢复 朙月拼音 最近一次备份。")
        )
        let store = makeIsolatedStore(
            persistence: persistence,
            userDictionaryBackupService: backupService
        )

        store.restoreLatestUserDictionaryBackup(for: "luna_pinyin")

        XCTAssertEqual(store.userDictionaryMessage, "已恢复 朙月拼音 最近一次备份。")
        XCTAssertEqual(persistence.value(forKey: RimeUserDictionarySettings.pendingDeployKey) as? Bool, true)
        XCTAssertEqual(persistence.value(forKey: "rime_needs_deploy") as? Bool, true)
        XCTAssertEqual(store.deploymentState, .needsDeploy)
    }

    func testRestoreUserDictionaryDoesNotDeployWhenNoBackupExists() {
        let persistence = StubRimeSettingsPersistence()
        let backupService = StoreUserDictionaryBackupService(
            restoreResult: .init(succeeded: false, message: "朙月拼音 还没有可恢复的备份。")
        )
        let store = makeIsolatedStore(
            persistence: persistence,
            userDictionaryBackupService: backupService
        )

        store.restoreLatestUserDictionaryBackup(for: "luna_pinyin")

        XCTAssertEqual(store.userDictionaryMessage, "朙月拼音 还没有可恢复的备份。")
        XCTAssertNil(persistence.value(forKey: RimeUserDictionarySettings.pendingDeployKey))
        XCTAssertNil(persistence.value(forKey: "rime_needs_deploy"))
    }

    func testResetUserDictionaryDoesNotDeployWhenSafetyPreparationFails() {
        let persistence = StubRimeSettingsPersistence()
        let backupService = StoreUserDictionaryBackupService(
            resetResult: .init(succeeded: false, message: "清空未完成，当前学习记录已还原。")
        )
        let store = makeIsolatedStore(
            persistence: persistence,
            userDictionaryBackupService: backupService
        )

        store.resetUserDictionary(for: "luna_pinyin")

        XCTAssertEqual(backupService.resetRequests, ["luna_pinyin"])
        XCTAssertEqual(store.userDictionaryMessage, "清空未完成，当前学习记录已还原。")
        XCTAssertNil(persistence.value(forKey: RimeUserDictionarySettings.pendingDeployKey))
        XCTAssertNil(persistence.value(forKey: "rime_needs_deploy"))
    }

    func testUserDictionaryStatusUsesPlainTextForInstalledSchema() {
        let store = makeIsolatedStore()

        XCTAssertEqual(
            store.userDictionaryLearningStatusText(for: "luna_pinyin"),
            "已开启：键盘会记住你常选的词。"
        )
    }

    func testUserDictionaryBackupStatusExplainsLearningAndBackupState() {
        let backupDate = Date(timeIntervalSince1970: 1_800_000_000)
        let store = makeIsolatedStore(
            userDictionaryBackupService: StoreUserDictionaryBackupService(
                status: .init(
                    hasLearningData: true,
                    latestBackupDate: backupDate,
                    readiness: .hasNewLearningData
                )
            )
        )

        XCTAssertEqual(
            store.userDictionaryBackupStatusText(for: "luna_pinyin"),
            "有新的学习记录，可以更新备份。"
        )
        XCTAssertTrue(store.userDictionaryCanBackup(for: "luna_pinyin"))
    }

    func testUserDictionaryBackupStatusDisablesBackupWhenUpToDate() {
        let store = makeIsolatedStore(
            userDictionaryBackupService: StoreUserDictionaryBackupService(
                status: .init(
                    hasLearningData: true,
                    latestBackupDate: Date(timeIntervalSince1970: 1_800_000_000),
                    readiness: .upToDate
                )
            )
        )

        XCTAssertEqual(
            store.userDictionaryBackupStatusText(for: "luna_pinyin"),
            "已备份，暂无新的学习记录。"
        )
        XCTAssertFalse(store.userDictionaryCanBackup(for: "luna_pinyin"))
        XCTAssertEqual(store.userDictionaryListStatusText(for: "luna_pinyin"), "已开启 · 已备份")
        XCTAssertEqual(store.userDictionaryStatusSymbol(for: "luna_pinyin"), .upToDate)
    }

    func testAutoBackupIsOffByDefaultAndDoesNotBackup() {
        let backupService = StoreUserDictionaryBackupService(
            status: .init(hasLearningData: true, latestBackupDate: nil, readiness: .needsInitialBackup),
            backupResult: .init(succeeded: true, message: "已备份 朙月拼音 的学习记录。")
        )
        let store = makeIsolatedStore(userDictionaryBackupService: backupService)

        store.runAutomaticUserDictionaryBackupIfNeeded()

        XCTAssertEqual(backupService.backupRequests, [])
        XCTAssertNil(store.userDictionaryMessage)
    }

    func testAutoBackupRunsForChangedLearningDataWhenEnabled() {
        let persistence = StubRimeSettingsPersistence(
            values: ["rime_user_dict_auto_backup_enabled": true]
        )
        let backupService = StoreUserDictionaryBackupService(
            status: .init(hasLearningData: true, latestBackupDate: nil, readiness: .needsInitialBackup),
            backupResult: .init(succeeded: true, message: "已备份 朙月拼音 的学习记录。")
        )
        let deploymentService = StoreDeploymentService(succeeded: true)
        let store = makeIsolatedStore(
            persistence: persistence,
            deploymentService: deploymentService,
            userDictionaryBackupService: backupService
        )
        store.load()

        store.runAutomaticUserDictionaryBackupIfNeeded()

        XCTAssertEqual(backupService.backupRequests, ["luna_pinyin"])
        XCTAssertEqual(store.userDictionaryMessage, "已自动备份 朙月拼音 的学习记录。")
        XCTAssertNotNil(persistence.value(forKey: "rime_user_dict_auto_backup_last_run_luna_pinyin"))
    }

    func testAutoBackupSkipsWhenLatestBackupMatchesCurrentLearningData() {
        let persistence = StubRimeSettingsPersistence(
            values: ["rime_user_dict_auto_backup_enabled": true]
        )
        let backupService = StoreUserDictionaryBackupService(
            status: .init(
                hasLearningData: true,
                latestBackupDate: Date(timeIntervalSince1970: 1_800_000_000),
                readiness: .upToDate
            ),
            backupResult: .init(succeeded: true, message: "已备份 朙月拼音 的学习记录。")
        )
        let deploymentService = StoreDeploymentService(succeeded: true)
        let store = makeIsolatedStore(
            persistence: persistence,
            deploymentService: deploymentService,
            userDictionaryBackupService: backupService
        )
        store.load()

        store.runAutomaticUserDictionaryBackupIfNeeded()

        XCTAssertEqual(backupService.backupRequests, [])
        XCTAssertNil(store.userDictionaryMessage)
    }

    func testTriggerDeploymentCompletesInsideMainAppBeforeKeyboardUse() async {
        let settings = StoreSharedSettingsStore()
        let deploymentService = StoreDeploymentService(succeeded: true)
        let store = RimeSettingsStore(
            schemaManager: SchemaManager(
                settings: settings,
                sourceSelector: StoreSourceSelector(),
                archiveDownloader: StoreArchiveDownloader(),
                archiveInstaller: StoreArchiveInstaller(),
                deploymentService: deploymentService
            ),
            persistence: StubRimeSettingsPersistence()
        )

        await store.triggerDeployment()

        let requests = await deploymentService.requests
        XCTAssertEqual(requests.count, 1)
        guard case .fullCheck = requests[0].mode else {
            return XCTFail("The main app must own full deployment.")
        }
        XCTAssertEqual(store.deploymentState, .deployed)
        XCTAssertTrue(store.deploymentLog.contains { $0.contains("键盘可直接使用") })
    }

    func testCheckForUpdateReportsAlreadyCurrentWithoutStartingDownload() async {
        let settings = StoreSharedSettingsStore(values: ["rime_ice_version": "nightly"])
        let store = RimeSettingsStore(
            schemaManager: SchemaManager(
                settings: settings,
                sourceSelector: StoreSourceSelector(),
                archiveDownloader: StoreArchiveDownloader(),
                archiveInstaller: StoreArchiveInstaller(),
                deploymentService: StoreDeploymentService(succeeded: true)
            ),
            persistence: StubRimeSettingsPersistence()
        )

        await store.checkForUpdateAndDownload()

        XCTAssertEqual(store.updateStatusMessage, "已是最新版本")
        XCTAssertEqual(store.downloadState, .idle)
    }

    func testAdvancedInputStatusUsesReadyTextForAvailableDiagnostic() {
        let store = makeIsolatedStore()
        let diagnostic = makeAdvancedInputDiagnostic(status: .available)

        XCTAssertEqual(store.advancedInputStatusText(for: diagnostic), "基础检查通过")
        XCTAssertTrue(store.advancedInputStatusDetail(for: diagnostic).contains("高级输入可以使用"))
        XCTAssertNil(store.advancedInputRecoveryAction(for: diagnostic))
    }

    func testAdvancedInputStatusOffersApplyWhenDeploymentIsPending() {
        let store = makeIsolatedStore()
        let diagnostic = makeAdvancedInputDiagnostic(status: .needsDeploy)

        XCTAssertEqual(store.advancedInputStatusText(for: diagnostic), "需要重新部署")
        XCTAssertEqual(store.advancedInputRecoveryAction(for: diagnostic), .applySettings)
    }

    func testAdvancedInputStatusRejectsSmokePassFromStaleDeployment() {
        let store = makeIsolatedStore()
        let diagnostic = RimeLuaCapabilityDiagnostic(
            luaCompiledIn: true,
            luaModuleRegistered: true,
            luaComponentsRegistered: false,
            deploymentModules: ["core", "dict", "gears", "lua"],
            persistedLuaAvailable: true,
            rimeIceInstalled: true,
            activeSchemaID: "rime_ice",
            rimeDeployed: false,
            rimeNeedsDeploy: true,
            runtimeSmokePassed: true,
            schemaExists: true,
            schemaHasLuaComponents: true,
            luaDirectoryExists: true,
            luaEntryScriptRequired: false,
            luaEntryScriptExists: false,
            dateTranslatorExists: true,
            requiredLuaComponentNames: ["date_translator"],
            missingLuaComponentNames: [],
            missingLuaDependencyNames: []
        )

        XCTAssertEqual(diagnostic.status, .needsDeploy)
        XCTAssertEqual(store.advancedInputStatusText(for: diagnostic), "需要重新部署")
    }

    func testAdvancedInputStatusOffersRedownloadForStrippedOrMissingLuaFiles() {
        let store = makeIsolatedStore()

        XCTAssertEqual(
            store.advancedInputRecoveryAction(for: makeAdvancedInputDiagnostic(status: .schemaStripped)),
            .redownloadSchema
        )
        XCTAssertEqual(
            store.advancedInputRecoveryAction(for: makeAdvancedInputDiagnostic(status: .luaFilesMissing)),
            .redownloadSchema
        )
    }

    func testAdvancedInputStatusOffersSchemaSwitchForInactiveRimeIce() {
        let store = makeIsolatedStore()
        let diagnostic = makeAdvancedInputDiagnostic(status: .inactiveSchema)

        XCTAssertEqual(store.advancedInputStatusText(for: diagnostic), "未使用")
        XCTAssertEqual(store.advancedInputRecoveryAction(for: diagnostic), .setCurrentSchema)
    }

    func testAdvancedInputStatusExplainsRuntimeLuaModuleMissing() {
        let store = makeIsolatedStore()
        let diagnostic = makeAdvancedInputDiagnostic(status: .runtimeModuleMissing)

        XCTAssertEqual(store.advancedInputStatusText(for: diagnostic), "暂不可用")
        XCTAssertTrue(store.advancedInputStatusDetail(for: diagnostic).contains("没有加载高级输入能力"))
        XCTAssertNil(store.advancedInputRecoveryAction(for: diagnostic))
    }

    /// Keep SchemaManager off the default App-Group store. Isolated deinit of
    /// `AppGroupSharedSettingsStore` still aborts some XCTest host teardowns.
    private func makeIsolatedStore(
        persistence: any RimeSettingsPersisting = StubRimeSettingsPersistence(),
        deploymentService: StoreDeploymentService? = nil,
        userDictionaryBackupService: (any RimeUserDictionaryBackingUp)? = nil,
        settings: StoreSharedSettingsStore? = nil,
        archiveInstaller: StoreArchiveInstaller = StoreArchiveInstaller()
    ) -> RimeSettingsStore {
        let settings = settings ?? StoreSharedSettingsStore()
        let service = deploymentService ?? StoreDeploymentService(succeeded: true)
        let backup =
            userDictionaryBackupService ?? StoreUserDictionaryBackupService()
        return RimeSettingsStore(
            schemaManager: SchemaManager(
                settings: settings,
                sourceSelector: StoreSourceSelector(),
                archiveDownloader: StoreArchiveDownloader(),
                archiveInstaller: archiveInstaller,
                deploymentService: service
            ),
            persistence: persistence,
            userDictionaryBackupService: backup
        )
    }

    private func makeAdvancedInputDiagnostic(
        status: RimeLuaCapabilityDiagnostic.Status
    ) -> RimeLuaCapabilityDiagnostic {
        RimeLuaCapabilityDiagnostic(
            luaCompiledIn: status != .engineUnavailable,
            luaModuleRegistered: status != .runtimeModuleMissing,
            luaComponentsRegistered: status != .runtimeModuleMissing,
            deploymentModules: status == .engineUnavailable
                ? ["core", "dict", "gears"] : ["core", "dict", "gears", "lua"],
            persistedLuaAvailable: status == .engineUnavailable ? false : true,
            rimeIceInstalled: status != .notInstalled,
            activeSchemaID: status == .inactiveSchema ? "luna_pinyin" : "rime_ice",
            rimeDeployed: status != .needsDeploy,
            rimeNeedsDeploy: status == .needsDeploy,
            runtimeSmokePassed: status == .available ? true : false,
            schemaExists: status != .schemaMissing,
            schemaHasLuaComponents: status != .schemaStripped && status != .schemaMissing,
            luaDirectoryExists: status != .luaFilesMissing,
            luaEntryScriptRequired: false,
            luaEntryScriptExists: status != .luaFilesMissing,
            dateTranslatorExists: status != .luaFilesMissing,
            requiredLuaComponentNames: ["date_translator"],
            missingLuaComponentNames: status == .luaFilesMissing ? ["date_translator"] : [],
            missingLuaDependencyNames: []
        )
    }
}

@MainActor
final class RimeUserDictionaryBackupServiceTests: XCTestCase {
    func testBackupAndRestoreLatestUserDictionaryFiles() throws {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent("rime-user-dict-backup-\(UUID().uuidString)")
        let userDir = root.appendingPathComponent("Rime/user")
        try FileManager.default.createDirectory(at: userDir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: root) }

        let userDB = userDir.appendingPathComponent("luna_pinyin.userdb")
        try FileManager.default.createDirectory(at: userDB, withIntermediateDirectories: true)
        try "old".write(to: userDB.appendingPathComponent("CURRENT"), atomically: true, encoding: .utf8)

        let service = AppGroupRimeUserDictionaryBackupService(containerURL: root)
        let backup = service.backup(schemaID: "luna_pinyin", displayName: "朙月拼音")

        XCTAssertTrue(backup.succeeded)
        XCTAssertFalse(service.status(for: "luna_pinyin").canBackup)
        try FileManager.default.removeItem(at: userDB)
        let restore = service.restoreLatest(schemaID: "luna_pinyin", displayName: "朙月拼音")

        XCTAssertTrue(restore.succeeded)
        let restored = try String(contentsOf: userDB.appendingPathComponent("CURRENT"), encoding: .utf8)
        XCTAssertEqual(restored, "old")
    }

    func testRestoreCreatesRecoveryBackupBeforeReplacingNewerLearningData() throws {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent("rime-user-dict-recovery-\(UUID().uuidString)")
        let userDir = root.appendingPathComponent("Rime/user")
        try FileManager.default.createDirectory(at: userDir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: root) }

        let userDB = userDir.appendingPathComponent("luna_pinyin.userdb")
        try FileManager.default.createDirectory(at: userDB, withIntermediateDirectories: true)
        let currentFile = userDB.appendingPathComponent("CURRENT")
        try "old".write(to: currentFile, atomically: true, encoding: .utf8)

        let service = AppGroupRimeUserDictionaryBackupService(containerURL: root)
        XCTAssertTrue(service.backup(schemaID: "luna_pinyin", displayName: "朙月拼音").succeeded)
        try "new".write(to: currentFile, atomically: true, encoding: .utf8)

        let restore = service.restoreLatest(schemaID: "luna_pinyin", displayName: "朙月拼音")

        XCTAssertTrue(restore.succeeded)
        XCTAssertEqual(try String(contentsOf: currentFile, encoding: .utf8), "old")
        let backupRoot = root.appendingPathComponent("Rime/user_dictionary_backups/luna_pinyin")
        let containsRecoveryCopy = try FileManager.default.contentsOfDirectory(
            at: backupRoot, includingPropertiesForKeys: nil
        )
        .contains { backupURL in
            let recoveryFile = backupURL.appendingPathComponent("luna_pinyin.userdb/CURRENT")
            return (try? String(contentsOf: recoveryFile, encoding: .utf8)) == "new"
        }
        XCTAssertTrue(containsRecoveryCopy)
    }

    func testResetCreatesRecoveryBackupBeforeDeletingLearningData() throws {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent("rime-user-dict-reset-\(UUID().uuidString)")
        let userDir = root.appendingPathComponent("Rime/user")
        try FileManager.default.createDirectory(at: userDir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: root) }

        let userDB = userDir.appendingPathComponent("luna_pinyin.userdb")
        try FileManager.default.createDirectory(at: userDB, withIntermediateDirectories: true)
        try "learned".write(
            to: userDB.appendingPathComponent("CURRENT"),
            atomically: true,
            encoding: .utf8
        )

        let service = AppGroupRimeUserDictionaryBackupService(containerURL: root)
        let result = service.resetLearningData(schemaID: "luna_pinyin", displayName: "朙月拼音")

        XCTAssertTrue(result.succeeded)
        XCTAssertFalse(FileManager.default.fileExists(atPath: userDB.path))
        let backupRoot = root.appendingPathComponent("Rime/user_dictionary_backups/luna_pinyin")
        let containsRecoveryCopy = try FileManager.default.contentsOfDirectory(
            at: backupRoot, includingPropertiesForKeys: nil
        )
        .contains { backupURL in
            let recoveryFile = backupURL.appendingPathComponent("luna_pinyin.userdb/CURRENT")
            return (try? String(contentsOf: recoveryFile, encoding: .utf8)) == "learned"
        }
        XCTAssertTrue(containsRecoveryCopy)
    }

    func testBackupReportsNoLearningDataWhenUserDBIsMissing() throws {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent("rime-user-dict-empty-\(UUID().uuidString)")
        try FileManager.default.createDirectory(
            at: root.appendingPathComponent("Rime/user"),
            withIntermediateDirectories: true
        )
        defer { try? FileManager.default.removeItem(at: root) }

        let service = AppGroupRimeUserDictionaryBackupService(containerURL: root)
        let result = service.backup(schemaID: "luna_pinyin", displayName: "朙月拼音")

        XCTAssertFalse(result.succeeded)
        XCTAssertEqual(result.message, "朙月拼音 还没有可备份的学习记录。")
    }

    func testBackupDetectsNewLearningDataAfterManifestChanges() throws {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent("rime-user-dict-changed-\(UUID().uuidString)")
        let userDir = root.appendingPathComponent("Rime/user")
        try FileManager.default.createDirectory(at: userDir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: root) }

        let userDB = userDir.appendingPathComponent("luna_pinyin.userdb")
        try FileManager.default.createDirectory(at: userDB, withIntermediateDirectories: true)
        let currentFile = userDB.appendingPathComponent("CURRENT")
        try "old".write(to: currentFile, atomically: true, encoding: .utf8)

        let service = AppGroupRimeUserDictionaryBackupService(containerURL: root)
        XCTAssertTrue(service.backup(schemaID: "luna_pinyin", displayName: "朙月拼音").succeeded)
        try "new".write(to: currentFile, atomically: true, encoding: .utf8)

        let status = service.status(for: "luna_pinyin")
        XCTAssertEqual(status.readiness, .hasNewLearningData)
        XCTAssertTrue(status.canBackup)
    }
}

@MainActor
private final class StubRimeSettingsPersistence: RimeSettingsPersisting {
    private var values: [String: Any]

    init(values: [String: Any] = [:]) {
        self.values = values
    }

    func string(forKey key: String) -> String? { values[key] as? String }
    func integer(forKey key: String) -> Int { values[key] as? Int ?? 0 }
    func bool(forKey key: String) -> Bool { values[key] as? Bool ?? false }
    func hasValue(forKey key: String) -> Bool { values[key] != nil }
    func set(_ value: Any?, forKey key: String) { values[key] = value }
    func synchronize() {}
    func value(forKey key: String) -> Any? { values[key] }
}

@MainActor
private final class StoreUserDictionaryBackupService: RimeUserDictionaryBackingUp {
    var status: RimeUserDictionaryBackupStatus
    var backupResult: RimeUserDictionaryOperationResult
    var restoreResult: RimeUserDictionaryOperationResult
    var resetResult: RimeUserDictionaryOperationResult
    var resetRequests: [String] = []
    var backupRequests: [String] = []

    init(
        status: RimeUserDictionaryBackupStatus = .init(
            hasLearningData: false,
            latestBackupDate: nil,
            readiness: .noLearningData
        ),
        backupResult: RimeUserDictionaryOperationResult = .init(succeeded: false, message: ""),
        restoreResult: RimeUserDictionaryOperationResult = .init(succeeded: false, message: ""),
        resetResult: RimeUserDictionaryOperationResult = .init(succeeded: false, message: "")
    ) {
        self.status = status
        self.backupResult = backupResult
        self.restoreResult = restoreResult
        self.resetResult = resetResult
    }

    func status(for schemaID: String) -> RimeUserDictionaryBackupStatus { status }
    func backup(schemaID: String, displayName: String) -> RimeUserDictionaryOperationResult {
        backupRequests.append(schemaID)
        return backupResult
    }
    func restoreLatest(schemaID: String, displayName: String) -> RimeUserDictionaryOperationResult { restoreResult }
    func resetLearningData(schemaID: String, displayName: String) -> RimeUserDictionaryOperationResult {
        resetRequests.append(schemaID)
        return resetResult
    }
}

@MainActor
private final class StoreSharedSettingsStore: SharedSettingsStoring, RimeSettingsPersisting {
    private var values: [String: Any]

    init(values: [String: Any] = [:]) {
        self.values = values
    }

    func string(forKey key: String) -> String? { values[key] as? String }
    func integer(forKey key: String) -> Int { values[key] as? Int ?? 0 }
    func bool(forKey key: String) -> Bool { values[key] as? Bool ?? false }
    func hasValue(forKey key: String) -> Bool { values[key] != nil }
    func object(forKey key: String) -> Any? { values[key] }
    func set(_ value: Any?, forKey key: String) { values[key] = value }
    func removeObject(forKey key: String) { values.removeValue(forKey: key) }
    func synchronize() {}
}

nonisolated private struct StoreSourceSelector: SchemaSourceSelecting {
    func selectSource(
        from variants: [RimeSchemeSourceVariant],
        preferredSourceID: String?
    ) async throws -> RimeSchemeSourceVariant {
        if let preferredSourceID, let preferred = variants.first(where: { $0.id == preferredSourceID }) {
            return preferred
        }
        guard let first = variants.first else { throw DownloadError.allSourcesUnavailable }
        return first
    }
}

private struct StoreArchiveDownloader: SchemaArchiveDownloading {
    func downloadArchive(
        from source: RimeSchemeSourceVariant,
        operationID: UUID,
        attemptID: UUID,
        onProgress: (@Sendable (Double?) -> Void)?
    ) async throws -> DownloadedSchemaArchive {
        onProgress?(1)
        return DownloadedSchemaArchive(
            localURL: URL(fileURLWithPath: "/tmp/\(UUID().uuidString).zip"),
            expectedContentLength: source.expectedByteCount,
            operationID: operationID,
            attemptID: attemptID,
            sourceID: source.id,
            artifactID: UUID(),
            finalHost: source.downloadURL.host ?? "github.com"
        )
    }
}

@MainActor
private final class StoreArchiveInstaller: SchemaArchiveInstalling {
    private let containsInstalledSchemaValue: Bool

    init(containsInstalledSchema: Bool = false) {
        self.containsInstalledSchemaValue = containsInstalledSchema
    }

    func cachedArchiveURL(for distribution: RimeSchemeDistribution) -> URL {
        URL(fileURLWithPath: "/tmp/\(distribution.cachedArchiveFileName)")
    }
    func prepareExtractionDirectory(for distribution: RimeSchemeDistribution) throws -> URL {
        URL(fileURLWithPath: "/tmp/\(distribution.extractionDirectoryName)")
    }
    func removeTemporaryItem(at url: URL) {}
    func containsInstalledSchema(plan: RimeSchemeInstallationPlan) -> Bool { containsInstalledSchemaValue }
    func checkDiskSpace(needed: Int64) throws {}
    func installSchemaFiles(from extractDir: URL, plan: RimeSchemeInstallationPlan, luaAvailable: Bool) throws {}
    func uninstallSchemaFiles(plan: RimeSchemeInstallationPlan) {}
    func clearBuildCache(plan: RimeSchemeInstallationPlan) {}
    func sharedDataDirectoryURL() -> URL? { URL(fileURLWithPath: "/tmp/shared") }
    func runtimeDirectories() throws -> SchemaDeploymentDirectories {
        SchemaDeploymentDirectories(
            sharedDataURL: URL(fileURLWithPath: "/tmp/shared"),
            userDataURL: URL(fileURLWithPath: "/tmp/user")
        )
    }
    func deploymentDirectories() throws -> SchemaDeploymentDirectories {
        SchemaDeploymentDirectories(
            sharedDataURL: URL(fileURLWithPath: "/tmp/shared"),
            userDataURL: URL(fileURLWithPath: "/tmp/user")
        )
    }
}

private actor StoreDeploymentService: RimeDeploymentServicing {
    let succeeded: Bool
    private(set) var requests: [RimeDeploymentRequest] = []

    init(succeeded: Bool) {
        self.succeeded = succeeded
    }

    func deploy(_ request: RimeDeploymentRequest) async throws -> RimeDeploymentResult {
        requests.append(request)
        return RimeDeploymentResult(succeeded: succeeded, diagnosticMessage: "test")
    }
}
