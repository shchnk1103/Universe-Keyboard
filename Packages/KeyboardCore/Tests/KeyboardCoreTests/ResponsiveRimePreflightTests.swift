import XCTest
@testable import KeyboardCore

final class ResponsiveRimePreflightTests: XCTestCase {
    func testReleaseNeverArmsFromUserDefaultsAloneWithoutProductGate() {
        let suite = "ResponsiveRimePreflightTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }
        defaults.set(true, forKey: ResponsiveRimePreflight.dualGateKey)

        XCTAssertFalse(
            ResponsiveRimePreflight.shouldArmDualGate(
                defaults: defaults,
                isDebugBuild: false,
                compileFlagEnabled: false,
                productDefaultOn: false
            )
        )
    }

    func testProductGateDefaultOnArmsReleaseWithoutUserDefaults() {
        XCTAssertTrue(ResponsiveRimePreflight.productGateReleaseDefaultOn)
        XCTAssertTrue(
            ResponsiveRimePreflight.shouldArmDualGate(
                defaults: nil,
                isDebugBuild: false,
                compileFlagEnabled: false,
                productDefaultOn: true
            )
        )
        // Default parameter follows Product Gate constant.
        XCTAssertTrue(
            ResponsiveRimePreflight.shouldArmDualGate(
                defaults: nil,
                isDebugBuild: false,
                compileFlagEnabled: false
            )
        )
    }

    func testDebugArmsWhenAppGroupKeyTrue() {
        let suite = "ResponsiveRimePreflightTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }
        defaults.set(true, forKey: ResponsiveRimePreflight.dualGateKey)

        XCTAssertTrue(
            ResponsiveRimePreflight.shouldArmDualGate(
                defaults: defaults,
                isDebugBuild: true,
                compileFlagEnabled: false,
                productDefaultOn: false
            )
        )
    }

    func testCompileFlagArmsEvenWithoutKey() {
        XCTAssertTrue(
            ResponsiveRimePreflight.shouldArmDualGate(
                defaults: nil,
                isDebugBuild: false,
                compileFlagEnabled: true,
                productDefaultOn: false
            )
        )
    }

    func testPathMarkerIsContentFree() {
        let line = ResponsiveRimePreflight.pathMarkerLine(
            path: .threadAffine,
            dualGateRequested: true,
            dualGateActive: true,
            runToken: "S6A-0123456789ABCDEF0123456789ABCDEF"
        )
        XCTAssertTrue(line.contains("T9RESP marker=PATH"))
        XCTAssertTrue(line.contains("schema=v1"))
        XCTAssertTrue(line.contains("path=thread-affine"))
        XCTAssertTrue(line.contains("fixture=\(ResponsiveRimePreflight.fixtureID)"))
        XCTAssertTrue(line.contains("run=S6A-0123456789ABCDEF0123456789ABCDEF"))
        XCTAssertFalse(line.contains("你好"))
        XCTAssertFalse(line.contains("nihao"))
    }

    func testOwnerReadinessMarkersDistinguishReadyAndTimeout() {
        let runToken = "S6A-0123456789ABCDEF0123456789ABCDEF"
        let ready = ResponsiveRimePreflight.ownerReadinessMarkerLine(
            runToken: runToken,
            isReady: true
        )
        XCTAssertTrue(ready.contains("marker=READY"))
        XCTAssertTrue(ready.contains("schema=v1"))
        XCTAssertTrue(ready.contains("bootstrap=config-only"))
        XCTAssertTrue(ready.contains("session=owner-thread"))

        let notReady = ResponsiveRimePreflight.ownerReadinessMarkerLine(
            runToken: runToken,
            isReady: false,
            reason: "owner-timeout"
        )
        XCTAssertTrue(notReady.contains("marker=NOT_READY"))
        XCTAssertTrue(notReady.contains("schema=v1"))
        XCTAssertTrue(notReady.contains("reason=owner-timeout"))
        XCTAssertFalse(notReady.contains("marker=READY"))
    }

    func testPublishMarkerIsContentFree() {
        let line = ResponsiveRimePreflight.publishMarkerLine(epoch: 2, revision: 9)
        XCTAssertEqual(
            line,
            "T9RESP marker=PUBLISH schema=v1 fixture=\(ResponsiveRimePreflight.fixtureID) epoch=2 rev=9"
        )
    }
}
