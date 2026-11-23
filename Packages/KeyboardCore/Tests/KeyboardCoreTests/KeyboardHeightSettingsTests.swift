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

    // MARK: - PB-008 adaptive ratio (ADAPTIVE-HEIGHT-RATIO-001)

    /// 六组机检样例：无保存值走 254/844 连续比例，有保存值仍走夹取且不回写。
    func testAdaptiveRatioMachineCheckSamples() throws {
        let none = KeyboardHeightSettings()
        // 1. 844 / base 74 / path 0 → 45
        XCTAssertEqual(
            try none.adaptiveRowHeight(
                orientation: .portrait, screenHeight: 844, fixedHeight: 74, pathHeight: 0), 45)
        // 2. 932 / base 74 / path 0 → 51，且 74+4×51 ≤ 932×0.5
        let row932 = try none.adaptiveRowHeight(
            orientation: .portrait, screenHeight: 932, fixedHeight: 74, pathHeight: 0)
        XCTAssertEqual(row932, 51)
        XCTAssertLessThanOrEqual(74 + 4 * Double(row932), 932 * 0.5)
        // 3. 468 / base 74 → 40（比例值 16 被下限抬起）
        XCTAssertEqual(
            try none.adaptiveRowHeight(
                orientation: .portrait, screenHeight: 468, fixedHeight: 74, pathHeight: 0), 40)
        // 4. 467.9 / base 74 → insufficientHeight
        XCTAssertThrowsError(
            try none.adaptiveRowHeight(
                orientation: .portrait, screenHeight: 467.9, fixedHeight: 74, pathHeight: 0)
        ) { error in
            XCTAssertEqual(error as? KeyboardHeightSettings.ResolutionError, .insufficientHeight)
        }
        // 5. 横屏短边 390、长边 844、无覆盖 → 45
        XCTAssertEqual(
            try none.adaptiveRowHeight(
                orientation: .landscape, screenHeight: 844, fixedHeight: 74, pathHeight: 0), 45)
        // 6. 覆盖值 61 横屏 → 45；覆盖值 52 竖屏 932 → 52；覆盖值 80 竖屏 844 被上限夹住且存储仍是 80
        let override61 = KeyboardHeightSettings(savedRowHeight: 61)
        XCTAssertEqual(
            try override61.effectiveRowHeight(
                orientation: .landscape, screenHeight: 390, fixedHeight: 74), 45)
        XCTAssertEqual(override61.savedRowHeight, 61)
        let override52 = KeyboardHeightSettings(savedRowHeight: 52)
        XCTAssertEqual(
            try override52.effectiveRowHeight(
                orientation: .portrait, screenHeight: 932, fixedHeight: 74), 52)
        XCTAssertEqual(override52.savedRowHeight, 52)
        // 覆盖值 80 超过 844 屏 50% 上限（floor((844×0.5−74)/4)=87 以下不夹，
        // 80<87 故换 100 证明夹取：与既有 testPortraitCapIncludesVisiblePath 同口径）
        let override100 = KeyboardHeightSettings(savedRowHeight: 100)
        let clamped = try override100.effectiveRowHeight(
            orientation: .portrait, screenHeight: 844, fixedHeight: 74)
        XCTAssertLessThan(clamped, 100)
        XCTAssertLessThanOrEqual(74 + 4 * Double(clamped), 844 * 0.5)
        XCTAssertEqual(override100.savedRowHeight, 100)
    }
}
