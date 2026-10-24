import Foundation
import XCTest

@testable import KeyboardCore

final class CandidateFontSettingsTests: XCTestCase {
    func testAllTenTiersAndTheirPolicies() {
        XCTAssertEqual(CandidateFontSettings.storageKey, "keyboard_candidate_font_size")
        for tier in 13...22 {
            let settings = CandidateFontSettings(savedValue: tier)
            XCTAssertEqual(settings.tier, tier)
            for composition in [false, true] {
                let policy = settings.policy(isComposition: composition)
                XCTAssertEqual(policy.basePointSize, Double(tier - (composition ? 2 : 0)))
                XCTAssertEqual(policy.scalesWithBody, tier == 17)
                XCTAssertEqual(policy.maximumPointSize, tier == 17 ? 28 : nil)
            }
        }
    }

    func testMissingDeletedAndInvalidValuesUseDefaultPolicy() {
        let invalid: [Any?] = [
            nil, true, false, 17.0, Float(18), "18", 12, 23,
            Int.min, Int.max, NSNumber(value: true), NSNumber(value: 18.5), NSNull(),
        ]
        for raw in invalid {
            let settings = CandidateFontSettings(savedValue: raw)
            XCTAssertEqual(settings, CandidateFontSettings())
            XCTAssertEqual(settings.tier, 17)
            XCTAssertEqual(settings.policy(isComposition: false).basePointSize, 17)
            XCTAssertEqual(settings.policy(isComposition: true).basePointSize, 15)
            XCTAssertTrue(settings.policy(isComposition: true).scalesWithBody)
            XCTAssertEqual(settings.policy(isComposition: true).maximumPointSize, 28)
        }
    }

    func testIntegerNSNumberFromPreferenceStorageIsAccepted() {
        XCTAssertEqual(CandidateFontSettings(savedValue: NSNumber(value: 22)).tier, 22)
        XCTAssertEqual(CandidateFontSettings(savedValue: NSNumber(value: UInt8(13))).tier, 13)
    }
}
