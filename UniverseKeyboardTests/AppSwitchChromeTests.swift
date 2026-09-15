import UIKit
import XCTest

@testable import Universe_Keyboard

final class AppSwitchChromeTests: XCTestCase {
    func testOnTintFollowsLabelInBothAppearances() {
        XCTAssertEqual(AppSwitchChrome.onTintColor(), UIColor.label)
    }

    func testLightModeThumbStaysWhiteWhetherOnOrOff() {
        XCTAssertEqual(AppSwitchChrome.thumbTintColor(isOn: true, isDark: false), .white)
        XCTAssertEqual(AppSwitchChrome.thumbTintColor(isOn: false, isDark: false), .white)
    }

    func testDarkModeOnThumbIsBlack() {
        XCTAssertEqual(AppSwitchChrome.thumbTintColor(isOn: true, isDark: true), .black)
    }

    func testDarkModeOffThumbStaysWhite() {
        XCTAssertEqual(AppSwitchChrome.thumbTintColor(isOn: false, isDark: true), .white)
    }
}
