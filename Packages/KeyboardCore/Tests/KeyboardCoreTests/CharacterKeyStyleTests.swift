import Foundation
import XCTest

@testable import KeyboardCore

final class CharacterKeyStyleTests: XCTestCase {
    func testDefaultsAndInvalidValues() throws {
        let name = "CharacterKeyStyleTests.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: name))
        defer { defaults.removePersistentDomain(forName: name) }
        let expected = CharacterKeyStyle(defaults: nil)
        XCTAssertEqual(expected.size, 17)
        XCTAssertFalse(expected.bold)
        XCTAssertEqual(expected.chinese26, .upper)
        XCTAssertEqual(expected.chinese9, .upper)
        XCTAssertEqual(expected.english26, .followShift)
        XCTAssertEqual(CharacterKeyStyle(defaults: defaults), expected)
        for invalid in [true as Any, 12, 23, "19", 19.5] {
            defaults.set(invalid, forKey: CharacterKeyStyle.sizeKey)
            XCTAssertEqual(CharacterKeyStyle(defaults: defaults).size, 17)
        }
        defaults.set(1, forKey: CharacterKeyStyle.boldKey)
        defaults.set("invalid", forKey: CharacterKeyStyle.chinese26Key)
        defaults.set("invalid", forKey: CharacterKeyStyle.chinese9Key)
        defaults.set("invalid", forKey: CharacterKeyStyle.english26Key)
        XCTAssertEqual(CharacterKeyStyle(defaults: defaults), expected)
    }

    func testReturningToDefaultRemovesSizeWithoutChangingCandidateSetting() throws {
        let name = "CharacterKeyStyleTests.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: name))
        defer { defaults.removePersistentDomain(forName: name) }
        defaults.set(21, forKey: CandidateFontSettings.storageKey)
        CharacterKeyStyle.saveSize(22, defaults: defaults)
        XCTAssertEqual(defaults.integer(forKey: CharacterKeyStyle.sizeKey), 22)
        CharacterKeyStyle.saveSize(17, defaults: defaults)
        XCTAssertNil(defaults.object(forKey: CharacterKeyStyle.sizeKey))
        XCTAssertEqual(defaults.integer(forKey: CandidateFontSettings.storageKey), 21)
    }

    func testChineseCasesPreserveInputIdentity() throws {
        let name = "CharacterKeyStyleTests.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: name))
        defer { defaults.removePersistentDomain(forName: name) }
        for (mode, letter, group) in [("upper", "A", "ABC"), ("lower", "a", "abc")] {
            defaults.set(mode, forKey: CharacterKeyStyle.chinese26Key)
            defaults.set(mode, forKey: CharacterKeyStyle.chinese9Key)
            let style = CharacterKeyStyle(defaults: defaults)
            XCTAssertEqual(style.displayTitle("a", layout: .chinese26, shifted: false), letter)
            XCTAssertEqual(style.inputPayload("A", layout: .chinese26, shifted: false), "a")
            XCTAssertEqual(style.inputPayload("a", layout: .chinese26, shifted: false), "a")
            XCTAssertEqual(style.inputPayload(",", layout: .chinese26, shifted: false), ",")
            XCTAssertEqual(style.displayTitle("ABC", layout: .chinese9, shifted: false), group)
            XCTAssertEqual(style.inputPayload("2", layout: .chinese9, shifted: false), "2")
        }
    }

    func testEnglishShiftMatrix() throws {
        let name = "CharacterKeyStyleTests.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: name))
        defer { defaults.removePersistentDomain(forName: name) }
        for (mode, unshifted, shifted) in [("followShift", "a", "A"), ("upper", "A", "A"), ("lower", "a", "a")] {
            defaults.set(mode, forKey: CharacterKeyStyle.english26Key)
            let style = CharacterKeyStyle(defaults: defaults)
            for (shift, expected) in [(false, unshifted), (true, shifted)] {
                XCTAssertEqual(style.displayTitle("a", layout: .english26, shifted: shift), expected)
                XCTAssertEqual(style.inputPayload("a", layout: .english26, shifted: shift), expected)
            }
        }
    }
}
