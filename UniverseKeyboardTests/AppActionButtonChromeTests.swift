import UIKit
import XCTest

@testable import Universe_Keyboard

final class AppActionButtonChromeTests: XCTestCase {
    func testPrimaryLabelIsSystemBackgroundInBothAppearances() {
        XCTAssertEqual(
            AppActionButtonChrome.labelColor(prominence: .primary),
            UIColor.systemBackground
        )
    }

    func testPrimarySolidFillFollowsLabel() {
        XCTAssertEqual(
            AppActionButtonChrome.solidFillColor(prominence: .primary),
            UIColor.label
        )
    }

    func testSecondaryUsesLabelTextAndGroupedFill() {
        XCTAssertEqual(
            AppActionButtonChrome.labelColor(prominence: .secondary),
            UIColor.label
        )
        XCTAssertEqual(
            AppActionButtonChrome.solidFillColor(prominence: .secondary),
            UIColor.secondarySystemGroupedBackground
        )
    }

    func testDestructiveStaysRed() {
        XCTAssertEqual(
            AppActionButtonChrome.labelColor(prominence: .destructive),
            UIColor.systemRed
        )
        XCTAssertEqual(
            AppActionButtonChrome.solidFillColor(prominence: .destructive),
            UIColor.systemRed.withAlphaComponent(
                AppActionButtonChrome.destructiveSolidFillOpacity
            )
        )
    }

    func testDisabledKeepsTheSamePairAndFadesTheControl() {
        XCTAssertEqual(AppActionButtonChrome.controlOpacity(isEnabled: true), 1)
        XCTAssertEqual(
            AppActionButtonChrome.controlOpacity(isEnabled: false),
            AppActionButtonChrome.disabledOpacity
        )
    }

    func testGlassIsUsedUnlessReduceTransparencyIsOn() {
        XCTAssertTrue(AppActionButtonChrome.usesGlassMaterial(reduceTransparency: false))
        XCTAssertFalse(AppActionButtonChrome.usesGlassMaterial(reduceTransparency: true))
    }

    func testDestructiveGlassTintIsStrongerInDarkMode() {
        XCTAssertEqual(
            AppActionButtonChrome.destructiveGlassTintOpacity(isDark: false),
            AppActionButtonChrome.destructiveGlassTintOpacityLight
        )
        XCTAssertEqual(
            AppActionButtonChrome.destructiveGlassTintOpacity(isDark: true),
            AppActionButtonChrome.destructiveGlassTintOpacityDark
        )
    }

    func testPrimaryGlassTintStaysNearlyOpaque() {
        XCTAssertEqual(AppActionButtonChrome.primaryGlassTintOpacity, 0.92)
    }
}
