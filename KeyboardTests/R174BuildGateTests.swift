import XCTest

@testable import KeyboardCore

@MainActor
final class R174BuildGateTests: XCTestCase {
    func testR174DefaultMatchesOnlyTheExplicitSimulatorTestBuild() {
        let controller = KeyboardController()
        #if DEBUG && targetEnvironment(simulator) && INPUT_RELIABILITY_R174_SIMULATOR_TEST
            XCTAssertTrue(controller.isT9ExactRetypeRecoveryEnabled)
        #else
            XCTAssertFalse(controller.isT9ExactRetypeRecoveryEnabled)
        #endif
        XCTAssertFalse(controller.isT9InputRecoveryPending)
        XCTAssertFalse(controller.isPartialCommitFailureRecoveryPending)
    }
}
