import XCTest

@testable import KeyboardCore

final class T9IdlePathHintPolicyTests: XCTestCase {
    func testNeverShowsIdleEducationCopy() {
        XCTAssertFalse(
            T9IdlePathHintPolicy.shouldShow(
                isNineKeyChineseLettersSurface: true,
                usesT9InputSemantics: true,
                rawInput: nil,
                segmentSourceDigits: nil,
                pathCount: 0
            )
        )
        XCTAssertFalse(
            T9IdlePathHintPolicy.shouldShow(
                isNineKeyChineseLettersSurface: false,
                usesT9InputSemantics: true,
                rawInput: nil,
                segmentSourceDigits: nil,
                pathCount: 0
            )
        )
        XCTAssertFalse(
            T9IdlePathHintPolicy.shouldShow(
                isNineKeyChineseLettersSurface: true,
                usesT9InputSemantics: true,
                rawInput: "6",
                segmentSourceDigits: "6",
                pathCount: 3
            )
        )
    }
}
