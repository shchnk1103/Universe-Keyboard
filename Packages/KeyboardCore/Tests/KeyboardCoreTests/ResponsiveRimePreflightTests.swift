import XCTest
@testable import KeyboardCore

final class ResponsiveRimePreflightTests: XCTestCase {
    func testReleaseNeverArmsFromUserDefaultsAlone() {
        let suite = "ResponsiveRimePreflightTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }
        defaults.set(true, forKey: ResponsiveRimePreflight.dualGateKey)

        XCTAssertFalse(
            ResponsiveRimePreflight.shouldArmDualGate(
                defaults: defaults,
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
                compileFlagEnabled: false
            )
        )
    }

    func testCompileFlagArmsEvenWithoutKey() {
        XCTAssertTrue(
            ResponsiveRimePreflight.shouldArmDualGate(
                defaults: nil,
                isDebugBuild: false,
                compileFlagEnabled: true
            )
        )
    }

    func testPathMarkerIsContentFree() {
        let line = ResponsiveRimePreflight.pathMarkerLine(
            path: .threadAffine,
            dualGateRequested: true,
            dualGateActive: true
        )
        XCTAssertTrue(line.contains("T9RESP marker=PATH"))
        XCTAssertTrue(line.contains("path=thread-affine"))
        XCTAssertTrue(line.contains("fixture=\(ResponsiveRimePreflight.fixtureID)"))
        XCTAssertFalse(line.contains("你好"))
        XCTAssertFalse(line.contains("nihao"))
    }

    func testPublishMarkerIsContentFree() {
        let line = ResponsiveRimePreflight.publishMarkerLine(epoch: 2, revision: 9)
        XCTAssertEqual(
            line,
            "T9RESP marker=PUBLISH fixture=\(ResponsiveRimePreflight.fixtureID) epoch=2 rev=9"
        )
    }
}
