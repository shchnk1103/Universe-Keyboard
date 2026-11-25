import KeyboardCore
import SwiftUI
import UIKit
import XCTest

@testable import Universe_Keyboard

nonisolated final class NumberPadSettingsPageTests: XCTestCase {
    @MainActor
    func testSwitchWritesSharedDefaults() async throws {
        let suite = "NumberPadSettingsPageTests.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        let scene = try XCTUnwrap(UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.first)
        let previous = scene.windows.first(where: \.isKeyWindow)
        let window = UIWindow(windowScene: scene)
        let host = UIHostingController(rootView: TwentySixKeyNumberPadSettingsRow(defaults: defaults))
        window.rootViewController = host
        window.makeKeyAndVisible()
        defer { window.isHidden = true; previous?.makeKey() }
        await Task.yield()
        host.view.layoutIfNeeded()
        func switches(_ view: UIView) -> [UISwitch] {
            (view as? UISwitch).map { [$0] } ?? view.subviews.flatMap { switches($0) }
        }
        let control = try XCTUnwrap(switches(host.view).first)
        XCTAssertFalse(control.isOn)
        control.setOn(true, animated: false)
        control.sendActions(for: .valueChanged)
        await Task.yield()
        XCTAssertTrue(defaults.bool(forKey: KeyboardInputSettingsKey.twentySixKeyNumberPadEnabled))
        let otherReader = try XCTUnwrap(UserDefaults(suiteName: suite))
        XCTAssertTrue(otherReader.bool(forKey: KeyboardInputSettingsKey.twentySixKeyNumberPadEnabled))
        control.setOn(false, animated: false)
        control.sendActions(for: .valueChanged)
        await Task.yield()
        XCTAssertFalse(otherReader.bool(forKey: KeyboardInputSettingsKey.twentySixKeyNumberPadEnabled))
    }
}
