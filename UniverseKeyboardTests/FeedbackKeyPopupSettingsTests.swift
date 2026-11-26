import KeyboardCore
import XCTest

@testable import Universe_Keyboard

/// PB-019-PR2-KEY-POPUP-SETTINGS-AND-T9-001 red tests: the shared
/// `keyboard.keyPopupEnabled` App Group switch resolves with a strict boolean
/// contract and defaults to on.
final class FeedbackKeyPopupSettingsTests: XCTestCase {
    func testEnabledKeyIsTheFrozenAppGroupName() {
        XCTAssertEqual(KeyboardKeyPopupSettings.enabledKey, "keyboard.keyPopupEnabled")
    }

    func testMissingOrNonBooleanStoredValueFallsBackToDefaultOn() {
        XCTAssertTrue(KeyboardKeyPopupSettings.isEnabled(stored: nil), "missing key defaults to on")
        XCTAssertTrue(
            KeyboardKeyPopupSettings.isEnabled(stored: "false"),
            "non-boolean string never disables the feature")
        XCTAssertTrue(
            KeyboardKeyPopupSettings.isEnabled(stored: NSNumber(value: 0)),
            "integer 0 is not a boolean and must not disable the feature")
        XCTAssertTrue(
            KeyboardKeyPopupSettings.isEnabled(stored: NSNumber(value: 1)),
            "integer 1 is not a boolean and defaults to on")
    }

    func testStoredBooleanWinsOverTheDefault() {
        XCTAssertTrue(KeyboardKeyPopupSettings.isEnabled(stored: NSNumber(value: true)))
        XCTAssertFalse(KeyboardKeyPopupSettings.isEnabled(stored: NSNumber(value: false)))
    }

    func testUserDefaultsRoundTripResolvesImmediately() throws {
        let suiteName = "FeedbackKeyPopupSettings-\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defer { defaults.removePersistentDomain(forName: suiteName) }

        XCTAssertTrue(
            KeyboardKeyPopupSettings.isEnabled(
                stored: defaults.object(forKey: KeyboardKeyPopupSettings.enabledKey)),
            "fresh defaults resolve to the default-on value")

        defaults.set(false, forKey: KeyboardKeyPopupSettings.enabledKey)
        XCTAssertFalse(
            KeyboardKeyPopupSettings.isEnabled(
                stored: defaults.object(forKey: KeyboardKeyPopupSettings.enabledKey)))

        defaults.set(true, forKey: KeyboardKeyPopupSettings.enabledKey)
        XCTAssertTrue(
            KeyboardKeyPopupSettings.isEnabled(
                stored: defaults.object(forKey: KeyboardKeyPopupSettings.enabledKey)))
    }
}
