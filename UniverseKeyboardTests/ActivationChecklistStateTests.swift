import XCTest

@testable import Universe_Keyboard

@MainActor
final class ActivationChecklistStateTests: XCTestCase {
    private func baseState(
        keyboardAdded: Bool = false,
        fullAccess: ActivationChecklistState.FullAccessPresentation = .unknown,
        fullAccessDeferred: Bool = false,
        activeSchemaID: String = ActivationChecklistState.builtinSchemaID,
        activeSchemaInstalled: Bool = false,
        rimeDeployed: Bool = false,
        isDeploying: Bool = false,
        deploymentFailed: Bool = false,
        firstInput: Bool = false
    ) -> ActivationChecklistState {
        ActivationChecklistState(
            keyboardAddedAffirmed: keyboardAdded,
            fullAccess: fullAccess,
            fullAccessDeferred: fullAccessDeferred,
            activeSchemaID: activeSchemaID,
            activeSchemaInstalled: activeSchemaInstalled,
            rimeDeployed: rimeDeployed,
            isDeploying: isDeploying,
            deploymentFailed: deploymentFailed,
            firstInputAffirmed: firstInput
        )
    }

    func testNextStepStartsAtAddKeyboard() {
        let state = baseState()
        XCTAssertEqual(state.nextStep, .addKeyboard)
        XCTAssertFalse(state.isFullyActivated)
    }

    func testProgressesThroughFullAccessAndResources() {
        var state = baseState(keyboardAdded: true)
        XCTAssertEqual(state.nextStep, .fullAccess)

        state.fullAccess = .userAffirmed
        XCTAssertEqual(state.nextStep, .prepareResources)

        // Deploy alone is not enough — active scheme must be installed.
        state.rimeDeployed = true
        XCTAssertEqual(state.nextStep, .prepareResources)

        state.activeSchemaInstalled = true
        XCTAssertEqual(state.nextStep, .firstInput)

        state.firstInputAffirmed = true
        XCTAssertNil(state.nextStep)
        XCTAssertTrue(state.isFullyActivated)
    }

    func testDeferredFullAccessYieldsToResourcesAndFirstInputThenReturns() {
        var state = baseState(
            keyboardAdded: true,
            fullAccessDeferred: true
        )

        XCTAssertEqual(state.nextStep, .prepareResources)
        XCTAssertFalse(state.isStepComplete(.fullAccess))
        XCTAssertEqual(state.statusTitle(for: .fullAccess), "已暂缓，待完成")

        state.activeSchemaInstalled = true
        state.rimeDeployed = true
        XCTAssertEqual(state.nextStep, .firstInput)

        state.firstInputAffirmed = true
        XCTAssertEqual(state.nextStep, .fullAccess)
        XCTAssertFalse(state.isFullyActivated)
        XCTAssertTrue(state.shouldShowHelpTab)
    }

    func testSharedDataFailureOverridesFullAccessDeferral() {
        let state = baseState(
            keyboardAdded: true,
            fullAccess: .sharedDataUnavailable,
            fullAccessDeferred: true
        )

        XCTAssertEqual(state.nextStep, .fullAccess)
        XCTAssertEqual(state.statusTitle(for: .fullAccess), "共享数据不可用")
    }

    func testResourcesRequireInstalledActiveSchemaAndDeploy() {
        let incomplete = baseState(
            keyboardAdded: true,
            fullAccess: .userAffirmed,
            activeSchemaID: ActivationChecklistState.recommendedSchemaID,
            activeSchemaInstalled: false,
            rimeDeployed: true
        )
        XCTAssertFalse(incomplete.isResourcesReadyForProgress)
        XCTAssertEqual(incomplete.statusTitle(for: .prepareResources), "方案未安装")

        let notDeployed = baseState(
            keyboardAdded: true,
            fullAccess: .userAffirmed,
            activeSchemaID: ActivationChecklistState.recommendedSchemaID,
            activeSchemaInstalled: true,
            rimeDeployed: false
        )
        XCTAssertFalse(notDeployed.isResourcesReadyForProgress)
        XCTAssertEqual(notDeployed.statusTitle(for: .prepareResources), "待部署")

        let ready = baseState(
            keyboardAdded: true,
            fullAccess: .userAffirmed,
            activeSchemaID: ActivationChecklistState.recommendedSchemaID,
            activeSchemaInstalled: true,
            rimeDeployed: true
        )
        XCTAssertTrue(ready.isResourcesReadyForProgress)
        XCTAssertEqual(ready.statusTitle(for: .prepareResources), "已就绪")
    }

    func testSharedDataUnavailableBlocksFullAccessProgress() {
        let state = baseState(
            keyboardAdded: true,
            fullAccess: .sharedDataUnavailable,
            activeSchemaInstalled: true,
            rimeDeployed: true
        )
        XCTAssertEqual(state.nextStep, .fullAccess)
        XCTAssertFalse(state.isFullAccessSatisfiedForProgress)
        XCTAssertEqual(state.statusTitle(for: .fullAccess), "共享数据不可用")
    }

    func testUserAffirmedFullAccessIsWeakButProgressable() {
        let state = baseState(
            keyboardAdded: true,
            fullAccess: .userAffirmed,
            activeSchemaInstalled: true,
            rimeDeployed: true
        )
        XCTAssertTrue(state.isFullAccessSatisfiedForProgress)
        XCTAssertEqual(state.statusTitle(for: .fullAccess), "已按你的确认开启")
        XCTAssertEqual(state.nextStep, .firstInput)
    }

    func testDeploymentInProgressIsNotReady() {
        let state = baseState(
            keyboardAdded: true,
            fullAccess: .sharedCapabilityOK,
            activeSchemaInstalled: true,
            rimeDeployed: false,
            isDeploying: true
        )
        XCTAssertEqual(state.nextStep, .prepareResources)
        XCTAssertEqual(state.statusTitle(for: .prepareResources), "准备中")
    }

    func testCanonicalCopyBoundariesRemainNonEmpty() {
        XCTAssertFalse(ActivationCopy.systemLimitation.isEmpty)
        XCTAssertFalse(ActivationCopy.degradedBasicTyping.isEmpty)
        XCTAssertFalse(ActivationCopy.fullAccessNotUpload.isEmpty)
        XCTAssertEqual(ActivationCopy.keyboardDisplayName, "Universe Keyboard")
        XCTAssertFalse(ActivationCopy.degradedBasicTyping.contains("必须"))
        XCTAssertTrue(
            ActivationCopy.degradedBasicTyping.contains("震动")
                || ActivationCopy.degradedBasicTyping.contains("共享"))
        XCTAssertEqual(ActivationChecklistState.recommendedSchemaID, "rime_ice")
    }

    func testWelcomePresentationKeysAndCopyAreBound() {
        XCTAssertEqual(
            ActivationPresentationStorage.welcomeSeenKey,
            "activation_welcome_seen"
        )
        XCTAssertEqual(
            ActivationPresentationStorage.fullAccessDeferredKey,
            "activation_full_access_deferred"
        )
        XCTAssertFalse(ActivationCopy.welcomeStartTitle.isEmpty)
        XCTAssertFalse(ActivationCopy.welcomeSkipTitle.isEmpty)
        XCTAssertFalse(ActivationCopy.welcomeHeadline.isEmpty)
        XCTAssertFalse(ActivationCopy.systemLimitation.contains("必须开启完全访问"))
        XCTAssertFalse(ActivationCopy.fullAccessDeferTitle.isEmpty)
        XCTAssertTrue(ActivationCopy.fullAccessDeferHint.contains("不会标记为已开启"))
    }

    func testHelpTabVisibleWhileActivationIncomplete() {
        let state = baseState()
        XCTAssertTrue(state.shouldShowHelpTab)
    }

    func testHelpTabHiddenWhenFullyActivatedAndHealthy() {
        let state = baseState(
            keyboardAdded: true,
            fullAccess: .userAffirmed,
            activeSchemaInstalled: true,
            rimeDeployed: true,
            firstInput: true
        )
        XCTAssertTrue(state.isFullyActivated)
        XCTAssertFalse(state.shouldShowHelpTab)
    }

    func testHelpTabReturnsWhenSharedDataUnavailable() {
        let state = baseState(
            keyboardAdded: true,
            fullAccess: .sharedDataUnavailable,
            activeSchemaInstalled: true,
            rimeDeployed: true,
            firstInput: true
        )
        XCTAssertFalse(state.isFullyActivated)
        XCTAssertTrue(state.shouldShowHelpTab)
    }

    func testHelpTabReturnsWhenDeploymentFailed() {
        let state = baseState(
            keyboardAdded: true,
            fullAccess: .sharedCapabilityOK,
            activeSchemaInstalled: true,
            rimeDeployed: false,
            deploymentFailed: true,
            firstInput: true
        )
        XCTAssertEqual(state.nextStep, .prepareResources)
        XCTAssertTrue(state.shouldShowHelpTab)
    }

    func testHelpSettingsEntryCopyDoesNotImplyProgressReset() {
        XCTAssertFalse(ActivationCopy.settingsHelpEntryTitle.isEmpty)
        XCTAssertTrue(ActivationCopy.settingsHelpEntrySubtitle.contains("不会清除"))
        XCTAssertTrue(ActivationCopy.reReadOnlyBanner.contains("不会清除"))
    }

    func testTipInvalidationFlagsTrackChecklistSteps() {
        var state = baseState()
        var flags = ActivationTips.CompletionFlags(state: state)
        XCTAssertFalse(flags.addKeyboard)
        XCTAssertFalse(flags.fullAccess)
        XCTAssertFalse(flags.prepareResources)
        XCTAssertFalse(flags.firstInput)

        state.keyboardAddedAffirmed = true
        state.fullAccess = .userAffirmed
        state.activeSchemaInstalled = true
        state.rimeDeployed = true
        state.firstInputAffirmed = true
        flags = ActivationTips.CompletionFlags(state: state)
        XCTAssertTrue(flags.addKeyboard)
        XCTAssertTrue(flags.fullAccess)
        XCTAssertTrue(flags.prepareResources)
        XCTAssertTrue(flags.firstInput)
    }

    func testTipCopyDoesNotEmbedFullPrivacyPolicyOrFAHardRequirement() {
        XCTAssertFalse(ActivationCopy.fullAccessPurpose.contains("隐私政策"))
        XCTAssertFalse(ActivationCopy.mainAppPreparesResources.contains("必须开启完全访问"))
        XCTAssertFalse(ActivationCopy.nextActionTitle(for: .firstInput).contains("必须"))
    }

    func testJ3CopyPointsToInlinePrepareNotOnlySettings() {
        XCTAssertTrue(ActivationCopy.nextActionTitle(for: .prepareResources).contains("选择方案"))
        XCTAssertFalse(ActivationCopy.resourcesActivateAndDeploy.isEmpty)
    }

    func testFirstInputCopyAllowsAnyContentAndSearchCTA() {
        XCTAssertTrue(ActivationCopy.nextActionTitle(for: .firstInput).contains("任意"))
        XCTAssertFalse(ActivationCopy.firstInputTryCTA.isEmpty)
        XCTAssertTrue(ActivationCopy.firstInputExample.contains("可选"))
    }

    func testSettingsSearchCatalogMatchesKeywords() {
        let layout = SettingsSearchCatalog.matches(query: "9键")
        XCTAssertTrue(layout.contains(where: { $0.destination == .keyboardLayout }))
        let fuzzy = SettingsSearchCatalog.matches(query: "模糊")
        XCTAssertTrue(fuzzy.contains(where: { $0.destination == .fuzzyPinyin }))
        XCTAssertTrue(SettingsSearchCatalog.matches(query: "   ").isEmpty)
    }
}
