import XCTest

@testable import KeyboardCore

final class T9IdlePathHintPolicyTests: XCTestCase {
    func testShowsOnIdleNineKeyEmptySurface() {
        XCTAssertTrue(
            T9IdlePathHintPolicy.shouldShow(
                isNineKeyChineseLettersSurface: true,
                usesT9InputSemantics: true,
                rawInput: nil,
                segmentSourceDigits: nil,
                pathCount: 0
            )
        )
        XCTAssertEqual(T9IdlePathHintPolicy.displayText, "点选拼音可加快输入")
    }

    func testHidesWhenNotNineKeySurface() {
        XCTAssertFalse(
            T9IdlePathHintPolicy.shouldShow(
                isNineKeyChineseLettersSurface: false,
                usesT9InputSemantics: true,
                rawInput: nil,
                segmentSourceDigits: nil,
                pathCount: 0
            )
        )
    }

    func testHidesImmediatelyWhenCompositionRawPresent() {
        XCTAssertFalse(
            T9IdlePathHintPolicy.shouldShow(
                isNineKeyChineseLettersSurface: true,
                usesT9InputSemantics: true,
                rawInput: "6",
                segmentSourceDigits: nil,
                pathCount: 0
            )
        )
        XCTAssertFalse(
            T9IdlePathHintPolicy.shouldShow(
                isNineKeyChineseLettersSurface: true,
                usesT9InputSemantics: true,
                rawInput: "64426",
                segmentSourceDigits: "64426",
                pathCount: 0
            )
        )
    }

    func testHidesWhenSegmentLedgerStillHoldsDigits() {
        XCTAssertFalse(
            T9IdlePathHintPolicy.shouldShow(
                isNineKeyChineseLettersSurface: true,
                usesT9InputSemantics: true,
                rawInput: nil,
                segmentSourceDigits: "64",
                pathCount: 0
            )
        )
    }

    func testHidesWhenPathsVisible() {
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

    func testDoesNotShowWithoutT9SemanticsEvenIfRawLooksValid() {
        // Fail closed: without T9 semantics, composition policy is inactive,
        // but idle education is nine-key only and still requires empty surface.
        // Surface flag false is the normal 26-key case.
        XCTAssertFalse(
            T9IdlePathHintPolicy.shouldShow(
                isNineKeyChineseLettersSurface: false,
                usesT9InputSemantics: false,
                rawInput: nil,
                segmentSourceDigits: nil,
                pathCount: 0
            )
        )
    }
}
