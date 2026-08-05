#if T9_RESPONSIVE_CANARY_INTERNAL

import KeyboardCore
import XCTest

@MainActor
final class ResponsiveRimeCanaryLifecycleTests: XCTestCase {
    func testTimeoutCannotGrantBaselineCreation() {
        let coordinator = ResponsiveRimeCanaryModeCoordinator()
        let configuration = ResponsiveRimeCanaryConfiguration(
            explicitEnable: true,
            killSwitch: false,
            bootstrapAvailable: true,
            configurationValid: true,
            expiresAtUnixSeconds: 200,
            runID: "lifecycle-1"
        )
        _ = coordinator.evaluateStartup(configuration, nowUnixSeconds: 100)
        _ = coordinator.markCanaryReady()
        _ = coordinator.beginActiveKill(
            runID: "lifecycle-1",
            acceptedThroughRevision: 3
        )

        coordinator.failClosed("ownerTimeout")

        XCTAssertFalse(coordinator.permitsBaselineCreation)
        guard case .fencedUnavailable(let reason) = coordinator.state else {
            return XCTFail("timeout must remain fenced")
        }
        XCTAssertEqual(reason, "ownerTimeout")
    }
}

#endif
