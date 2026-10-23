import XCTest

@testable import KeyboardCore

final class KeyboardHeightSettingsTests: XCTestCase {
    func testMissingValueKeepsDefaultGeometry() throws {
        let settings = KeyboardHeightSettings()
        XCTAssertNil(settings.savedRowHeight)
        for (fixedHeight, expectedTotal) in [(74.0, 254.0), (108.0, 288.0)] {
            let row = try settings.effectiveRowHeight(
                orientation: .portrait, screenHeight: 844, fixedHeight: fixedHeight)
            XCTAssertEqual(row, 45)
            XCTAssertEqual(fixedHeight + 4 * Double(row), expectedTotal)
        }
        XCTAssertEqual(
            try settings.effectiveRowHeight(
                orientation: .landscape, screenHeight: 390, fixedHeight: 74), 45)
    }

    func testSavePreservesAnIntegerPreference() throws {
        var settings = KeyboardHeightSettings()
        settings.save(rowHeight: 61)
        XCTAssertEqual(settings.savedRowHeight, 61)
        XCTAssertEqual(
            try settings.effectiveRowHeight(
                orientation: .portrait, screenHeight: 844, fixedHeight: 74), 61)
    }

    func testValuesBelowMinimumAreClampedWithoutChangingPreference() throws {
        for saved in [Int.min, -1, 0, 39, 40] {
            let settings = KeyboardHeightSettings(savedRowHeight: saved)
            for orientation in [KeyboardHeightSettings.Orientation.portrait, .landscape] {
                XCTAssertEqual(
                    try settings.effectiveRowHeight(
                        orientation: orientation, screenHeight: 844, fixedHeight: 74), 40)
                XCTAssertEqual(settings.savedRowHeight, saved)
            }
        }
    }

    func testLandscapeCapsHeightAndPortraitRestoresPreference() throws {
        let settings = KeyboardHeightSettings(savedRowHeight: 70)
        XCTAssertEqual(
            try settings.effectiveRowHeight(
                orientation: .landscape, screenHeight: 390, fixedHeight: 108), 45)
        XCTAssertEqual(settings.savedRowHeight, 70)
        XCTAssertEqual(
            try settings.effectiveRowHeight(
                orientation: .portrait, screenHeight: 844, fixedHeight: 108), 70)
    }

    func testPortraitCapIncludesVisiblePathAndRoundsDown() throws {
        let settings = KeyboardHeightSettings(savedRowHeight: 100)
        for (fixedHeight, expectedRow) in [(74.0, 87), (108.0, 78)] {
            let row = try settings.effectiveRowHeight(
                orientation: .portrait, screenHeight: 844, fixedHeight: fixedHeight)
            XCTAssertEqual(row, expectedRow)
            XCTAssertLessThanOrEqual(fixedHeight + 4 * Double(row), 844 * 0.5)
            XCTAssertGreaterThan(fixedHeight + 4 * Double(row + 1), 844 * 0.5)
            XCTAssertEqual(settings.savedRowHeight, 100)
        }
    }

    func testFractionalGeometryNeverRoundsAboveCap() throws {
        let row = try KeyboardHeightSettings(savedRowHeight: 100).effectiveRowHeight(
            orientation: .portrait, screenHeight: 845.5, fixedHeight: 74.25)
        XCTAssertEqual(row, 87)
        XCTAssertLessThanOrEqual(74.25 + 4 * Double(row), 845.5 * 0.5)
    }

    func testResetRemovesSavedValueInsteadOfSavingDefault() throws {
        var settings = KeyboardHeightSettings(savedRowHeight: 70)
        settings.reset()
        XCTAssertNil(settings.savedRowHeight)
        XCTAssertEqual(settings, KeyboardHeightSettings())
        XCTAssertEqual(
            try settings.effectiveRowHeight(
                orientation: .portrait, screenHeight: 844, fixedHeight: 74), 45)
    }

    func testExactMinimumBudgetSucceedsButSmallerBudgetFails() throws {
        let settings = KeyboardHeightSettings(savedRowHeight: 80)
        XCTAssertEqual(
            try settings.effectiveRowHeight(
                orientation: .portrait, screenHeight: 468, fixedHeight: 74), 40)
        XCTAssertThrowsError(
            try settings.effectiveRowHeight(
                orientation: .portrait, screenHeight: 467.9, fixedHeight: 74)
        ) { error in
            XCTAssertEqual(error as? KeyboardHeightSettings.ResolutionError, .insufficientHeight)
        }
        XCTAssertEqual(settings.savedRowHeight, 80)
    }

    func testInvalidPortraitGeometryIsReported() {
        let settings = KeyboardHeightSettings()
        for screenHeight in [Double.nan, .infinity, -.infinity, 0, -1] {
            assertInvalidGeometry(settings, screenHeight: screenHeight, fixedHeight: 74)
        }
        for fixedHeight in [Double.nan, .infinity, -.infinity, -1] {
            assertInvalidGeometry(settings, screenHeight: 844, fixedHeight: fixedHeight)
        }
    }

    func testExtremeFiniteValuesDoNotOverflow() throws {
        let settings = KeyboardHeightSettings(savedRowHeight: Int.max)
        XCTAssertEqual(
            try settings.effectiveRowHeight(
                orientation: .portrait, screenHeight: .greatestFiniteMagnitude, fixedHeight: 74),
            Int.max)
        XCTAssertEqual(
            try settings.effectiveRowHeight(
                orientation: .portrait, screenHeight: 844, fixedHeight: 74), 87)
        XCTAssertEqual(settings.savedRowHeight, Int.max)
    }

    private func assertInvalidGeometry(
        _ settings: KeyboardHeightSettings, screenHeight: Double, fixedHeight: Double,
        file: StaticString = #filePath, line: UInt = #line
    ) {
        XCTAssertThrowsError(
            try settings.effectiveRowHeight(
                orientation: .portrait, screenHeight: screenHeight, fixedHeight: fixedHeight),
            file: file, line: line
        ) { error in
            XCTAssertEqual(
                error as? KeyboardHeightSettings.ResolutionError, .invalidGeometry,
                file: file, line: line)
        }
    }
}
