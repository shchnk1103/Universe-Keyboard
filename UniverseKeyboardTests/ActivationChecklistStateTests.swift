import XCTest

@testable import Universe_Keyboard

@MainActor
final class ActivationChecklistStateTests: XCTestCase {
    func testNextStepStartsAtAddKeyboard() {
        let state = ActivationChecklistState(
            keyboardAddedAffirmed: false,
            fullAccess: .unknown,
            rimeDeployed: false,
            isDeploying: false,
            deploymentFailed: false,
            firstInputAffirmed: false
        )
        XCTAssertEqual(state.nextStep, .addKeyboard)
        XCTAssertFalse(state.isFullyActivated)
    }

    func testProgressesThroughFullAccessAndResources() {
        var state = ActivationChecklistState(
            keyboardAddedAffirmed: true,
            fullAccess: .unknown,
            rimeDeployed: false,
            isDeploying: false,
            deploymentFailed: false,
            firstInputAffirmed: false
        )
        XCTAssertEqual(state.nextStep, .fullAccess)

        state.fullAccess = .userAffirmed
        XCTAssertEqual(state.nextStep, .prepareResources)

        state.rimeDeployed = true
        XCTAssertEqual(state.nextStep, .firstInput)

        state.firstInputAffirmed = true
        XCTAssertNil(state.nextStep)
        XCTAssertTrue(state.isFullyActivated)
    }

    func testSharedDataUnavailableBlocksFullAccessProgress() {
        let state = ActivationChecklistState(
            keyboardAddedAffirmed: true,
            fullAccess: .sharedDataUnavailable,
            rimeDeployed: true,
            isDeploying: false,
            deploymentFailed: false,
            firstInputAffirmed: false
        )
        XCTAssertEqual(state.nextStep, .fullAccess)
        XCTAssertFalse(state.isFullAccessSatisfiedForProgress)
        XCTAssertEqual(state.statusTitle(for: .fullAccess), "共享数据不可用")
    }

    func testUserAffirmedFullAccessIsWeakButProgressable() {
        let state = ActivationChecklistState(
            keyboardAddedAffirmed: true,
            fullAccess: .userAffirmed,
            rimeDeployed: true,
            isDeploying: false,
            deploymentFailed: false,
            firstInputAffirmed: false
        )
        XCTAssertTrue(state.isFullAccessSatisfiedForProgress)
        XCTAssertEqual(state.statusTitle(for: .fullAccess), "已按你的确认开启")
        XCTAssertEqual(state.nextStep, .firstInput)
    }

    func testDeploymentInProgressIsNotReady() {
        let state = ActivationChecklistState(
            keyboardAddedAffirmed: true,
            fullAccess: .sharedCapabilityOK,
            rimeDeployed: false,
            isDeploying: true,
            deploymentFailed: false,
            firstInputAffirmed: false
        )
        XCTAssertEqual(state.nextStep, .prepareResources)
        XCTAssertEqual(state.statusTitle(for: .prepareResources), "准备中")
    }

    func testCanonicalCopyBoundariesRemainNonEmpty() {
        XCTAssertFalse(ActivationCopy.systemLimitation.isEmpty)
        XCTAssertFalse(ActivationCopy.degradedBasicTyping.isEmpty)
        XCTAssertFalse(ActivationCopy.fullAccessNotUpload.isEmpty)
        XCTAssertEqual(ActivationCopy.keyboardDisplayName, "Universe Keyboard")
        // Device matrix: do not claim Chinese input is impossible without FA.
        XCTAssertFalse(ActivationCopy.degradedBasicTyping.contains("必须"))
        XCTAssertTrue(ActivationCopy.degradedBasicTyping.contains("震动")
            || ActivationCopy.degradedBasicTyping.contains("共享"))
    }
}
