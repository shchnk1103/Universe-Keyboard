import XCTest

@testable import KeyboardCore

/// Shortcut closure is a literal set compare, not a contains check (Alex review).
nonisolated final class T9NumberPadShortcutTests: XCTestCase {
    func testShortcutSymbolsMatchFrozenSetExactly() {
        XCTAssertEqual(T9NumberPadLayout.shortcutSymbols, ["/", "%", "#", "÷", "=", ":"])
    }

    func testSpaceKeyInLayoutInstallsCursorLongPress() {
        let space = T9NumberPadLayout.columns[2][1][0]
        XCTAssertEqual(space.tap, .literal(" "))
        XCTAssertTrue(space.installsSpaceCursorLongPress)
        let flagged = T9NumberPadLayout.columns.flatMap { $0 }.flatMap { $0 }.filter(\.installsSpaceCursorLongPress)
        XCTAssertEqual(flagged, [space])
    }
}
