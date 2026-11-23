import Foundation
import KeyboardCore
import XCTest

nonisolated final class MixedScriptSpacingFeedbackTests: XCTestCase {
    @MainActor
    func testRefreshUsesStoredBooleanAndRestoresItAfterAccessReturns() {
        let owner = PasteOwner()
        owner.controller = KeyboardController()
        let defaults = PasteMemoryDefaults()
        owner.sharedDefaults = defaults
        let key = KeyboardInputSettingsKey.mixedScriptSpacingEnabled
        let cases: [(String, Any?, Bool)] = [
            ("missing", nil, true),
            ("false", NSNumber(value: false), false),
            ("true", NSNumber(value: true), true),
            ("integer zero", NSNumber(value: 0), true),
            ("integer one", NSNumber(value: 1), true),
            ("string", "false", true),
        ]
        for (label, value, expected) in cases {
            if let value { defaults.set(value, forKey: key) } else { defaults.removeObject(forKey: key) }
            let before = defaults.dictionaryRepresentation() as NSDictionary
            owner.access = true
            owner.refreshCachedSettings()
            XCTAssertEqual(owner.controller.mixedScriptSpacingEnabled, expected, label)
            XCTAssertEqual(defaults.dictionaryRepresentation() as NSDictionary, before, label)
            owner.access = false
            owner.refreshCachedSettings()
            XCTAssertTrue(owner.controller.mixedScriptSpacingEnabled, label)
            XCTAssertEqual(defaults.dictionaryRepresentation() as NSDictionary, before, label)
            owner.access = true
            owner.refreshCachedSettings()
            XCTAssertEqual(owner.controller.mixedScriptSpacingEnabled, expected, label)
            XCTAssertEqual(defaults.dictionaryRepresentation() as NSDictionary, before, label)
        }
    }
}
