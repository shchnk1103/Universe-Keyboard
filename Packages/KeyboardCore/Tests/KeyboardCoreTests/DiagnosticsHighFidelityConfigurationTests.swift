import Foundation
import XCTest

@testable import KeyboardCore

final class DiagnosticsHighFidelityConfigurationTests: XCTestCase {
    func testAbsoluteExpirationControlsEnabledState() {
        let suiteName = "DiagnosticsHighFidelityConfigurationTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)
        defer { UserDefaults.standard.removePersistentDomain(forName: suiteName) }
        let now = Date(timeIntervalSince1970: 1_700_000_000)

        defaults?.set(
            now.addingTimeInterval(DiagnosticsHighFidelityConfiguration.duration),
            forKey: DiagnosticsHighFidelityConfiguration.expirationKey
        )
        XCTAssertTrue(DiagnosticsHighFidelityConfiguration.isEnabled(in: defaults, now: now))
        XCTAssertFalse(
            DiagnosticsHighFidelityConfiguration.isEnabled(
                in: defaults,
                now: now.addingTimeInterval(DiagnosticsHighFidelityConfiguration.duration)
            )
        )
    }
}
