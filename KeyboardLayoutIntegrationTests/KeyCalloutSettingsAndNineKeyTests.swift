import Foundation
import UIKit
import XCTest

@testable import KeyboardCore

/// PB-019-PR2-KEY-POPUP-SETTINGS-AND-T9-001 red tests.
///
/// Covers the `keyboard.keyPopupEnabled` App Group switch (default on; cached
/// snapshot toggles take effect immediately in the same keyboard process),
/// nine-key first-row letter-group callout eligibility with non-first-row and
/// digits-page suppression, and the iPad fail-closed / rebuild force-hide
/// contract (arch review Minor-1).
nonisolated final class KeyCalloutSettingsAndNineKeyTests: XCTestCase {

    // MARK: - Helpers

    @MainActor
    private func installedKeyboard(width: CGFloat = 390) throws -> KeyboardViewController {
        let sut = KeyboardViewController()
        sut.loadViewIfNeeded()
        sut.view.frame = CGRect(x: 0, y: 0, width: width, height: 300)
        sut.keyboardRowHeightSource = { 45 }
        sut.keyboardHeightGeometrySource = { .init(screenHeight: 844, isLandscape: false) }
        sut.prepareKeyboardHeightForAppearance()
        sut.installPreferredKeyboardHeight()
        sut.installKeyboardUIIfNeeded()
        _ = try XCTUnwrap(sut.rootStack)
        return sut
    }

    /// 带窗口挂载的键盘：按键 press 路径需要真实布局（convert 依赖 frame）。
    /// 调用方负责 `defer { window.isHidden = true }`。
    @MainActor
    private func makeWindowedKeyboard(width: CGFloat = 390) throws -> (
        sut: KeyboardViewController, window: UIWindow
    ) {
        let sut = try installedKeyboard(width: width)
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: width, height: 300))
        window.rootViewController = sut
        window.makeKeyAndVisible()
        sut.view.layoutIfNeeded()
        return (sut, window)
    }

    @MainActor
    private func button(withIdentifier identifier: String, in root: UIView) -> UIButton? {
        if let button = root as? UIButton, button.accessibilityIdentifier == identifier {
            return button
        }
        for subview in root.subviews {
            if let button = button(withIdentifier: identifier, in: subview) {
                return button
            }
        }
        return nil
    }

    /// Nine-key function keys（123 / #+= 等）没有 `accessibilityIdentifier`，
    /// 只能按可见标题查找。
    @MainActor
    private func button(withTitle title: String, in root: UIView) -> UIButton? {
        if let button = root as? UIButton, button.title(for: .normal) == title {
            return button
        }
        for subview in root.subviews {
            if let button = button(withTitle: title, in: subview) {
                return button
            }
        }
        return nil
    }

    @MainActor
    private func windowedLettersPageTwentySixKeyKeyboard(width: CGFloat = 390) throws -> (
        sut: KeyboardViewController, window: UIWindow
    ) {
        let (sut, window) = try makeWindowedKeyboard(width: width)
        sut.controller.state.inputMode = .chinese
        sut.controller.state.currentPage = .letters
        sut.cachedLayoutStyle = .twentySixKey
        sut.cachedT9ReadinessMatched = false
        sut.reloadKeyboard()
        sut.view.layoutIfNeeded()
        return (sut, window)
    }

    // MARK: - App Group switch: default on, immediate same-process round trip

    @MainActor
    func testKeyPopupDefaultsToEnabledAndToggleRoundTripTakesEffectImmediately() throws {
        let suiteName = "KeyCalloutSettingsRoundTrip-\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let (sut, window) = try windowedLettersPageTwentySixKeyKeyboard()
        defer { window.isHidden = true }
        sut.sharedDefaults = defaults
        sut.refreshCachedSettings()
        sut.reloadKeyboard()
        sut.view.layoutIfNeeded()

        // Default: no stored key → the callout switch is on.
        XCTAssertTrue(sut.cachedKeyPopupEnabled)

        let key = try XCTUnwrap(button(withIdentifier: "q", in: sut.view))

        sut.keyTouchDown(key)
        XCTAssertFalse(sut.keyCalloutView?.isHidden ?? true, "default-on must show the callout")
        sut.keyTouchUp(key)
        XCTAssertTrue(sut.keyCalloutView?.isHidden ?? true)

        // Toggle off: one refresh snapshot, no controller rebuild, next press suppressed.
        defaults.set(false, forKey: KeyboardKeyPopupSettings.enabledKey)
        sut.refreshCachedSettings()
        XCTAssertFalse(sut.cachedKeyPopupEnabled)
        sut.keyTouchDown(key)
        XCTAssertTrue(sut.keyCalloutView?.isHidden ?? true, "off must suppress the callout immediately")
        sut.keyTouchUp(key)

        // Toggle back on: same process, next press shows again.
        defaults.set(true, forKey: KeyboardKeyPopupSettings.enabledKey)
        sut.refreshCachedSettings()
        XCTAssertTrue(sut.cachedKeyPopupEnabled)
        sut.keyTouchDown(key)
        XCTAssertFalse(sut.keyCalloutView?.isHidden ?? true, "re-enable must show the callout immediately")
        XCTAssertEqual(sut.keyCalloutView?.characterText, "Q")
        sut.keyTouchUp(key)
    }

    // MARK: - Nine-key first-row letter groups

    @MainActor
    func testNineKeyFirstRowLetterGroupsShowCalloutAndOtherKeysAreSuppressed() throws {
        let (sut, window) = try makeWindowedKeyboard()
        defer { window.isHidden = true }
        sut.controller.state.inputMode = .chinese
        sut.controller.state.currentPage = .letters
        sut.cachedLayoutStyle = .nineKey
        sut.cachedT9ReadinessMatched = true
        sut.reloadKeyboard()
        sut.view.layoutIfNeeded()

        let firstRowABC = try XCTUnwrap(button(withIdentifier: "2", in: sut.view))
        sut.keyTouchDown(firstRowABC)
        XCTAssertFalse(sut.keyCalloutView?.isHidden ?? true, "first-row ABC must show the callout")
        XCTAssertEqual(sut.keyCalloutView?.characterText, "ABC")
        sut.keyTouchUp(firstRowABC)
        XCTAssertTrue(sut.keyCalloutView?.isHidden ?? true)

        let firstRowDEF = try XCTUnwrap(button(withIdentifier: "3", in: sut.view))
        sut.keyTouchDown(firstRowDEF)
        XCTAssertFalse(sut.keyCalloutView?.isHidden ?? true, "first-row DEF must show the callout")
        XCTAssertEqual(sut.keyCalloutView?.characterText, "DEF")
        sut.keyTouchUp(firstRowDEF)

        // Non-first-row letter groups stay suppressed.
        for identifier in ["4", "5", "7", "9"] {
            let key = try XCTUnwrap(button(withIdentifier: identifier, in: sut.view), identifier)
            sut.keyTouchDown(key)
            XCTAssertTrue(
                sut.keyCalloutView?.isHidden ?? true,
                "non-first-row digit \(identifier) must stay suppressed")
            sut.keyTouchUp(key)
        }

        // Function key（123）、delete key stay suppressed.
        let numbersKey = try XCTUnwrap(button(withTitle: "123", in: sut.view))
        sut.keyTouchDown(numbersKey)
        XCTAssertTrue(sut.keyCalloutView?.isHidden ?? true, "function key must stay suppressed")
        sut.keyTouchUp(numbersKey)

        let deleteKey = try XCTUnwrap(button(withIdentifier: "delete", in: sut.view))
        sut.keyTouchDown(deleteKey)
        XCTAssertTrue(sut.keyCalloutView?.isHidden ?? true, "delete key must stay suppressed")
        sut.keyTouchUp(deleteKey)
    }

    @MainActor
    func testNineKeyDigitsPageKeysNeverShowCallout() throws {
        let (sut, window) = try makeWindowedKeyboard()
        defer { window.isHidden = true }
        sut.controller.state.inputMode = .chinese
        sut.controller.state.currentPage = .numbers
        sut.cachedLayoutStyle = .nineKey
        sut.cachedT9ReadinessMatched = true
        sut.reloadKeyboard()
        sut.view.layoutIfNeeded()

        let digitKey = try XCTUnwrap(button(withIdentifier: "2", in: sut.view))
        sut.keyTouchDown(digitKey)
        XCTAssertTrue(sut.keyCalloutView?.isHidden ?? true, "digits-page keys must never show the callout")
        sut.keyTouchUp(digitKey)
    }

    @MainActor
    func testNineKeyLettersPagePunctuationUtilityKeyStaysSuppressed() throws {
        // The multi-character punctuation key（，。？！）cannot confirm a single
        // character inside the key-width bubble, so it stays excluded even
        // though it is styled as a character key on the nine-key letters page.
        let (sut, window) = try makeWindowedKeyboard()
        defer { window.isHidden = true }
        sut.controller.state.inputMode = .chinese
        sut.controller.state.currentPage = .letters
        sut.cachedLayoutStyle = .nineKey
        sut.cachedT9ReadinessMatched = true
        sut.reloadKeyboard()
        sut.view.layoutIfNeeded()

        let punctuationKey = try XCTUnwrap(
            button(withTitle: "123", in: sut.view),
            "sanity: function key exists"
        )
        XCTAssertFalse(sut.isKeyCalloutCandidate(punctuationKey))

        let abc = try XCTUnwrap(button(withIdentifier: "2", in: sut.view))
        XCTAssertTrue(sut.isKeyCalloutCandidate(abc))
        let ghi = try XCTUnwrap(button(withIdentifier: "4", in: sut.view))
        XCTAssertFalse(sut.isKeyCalloutCandidate(ghi))
    }

    // MARK: - iPad fail-closed (arch review Minor-1)

    @MainActor
    func testSplitViewRegularHeightKeyboardShowsClampedCallout() throws {
        // iPad split view: narrower container, regular keyboard height. The
        // leading Q bubble must clamp inside the container instead of clipping.
        let (sut, window) = try windowedLettersPageTwentySixKeyKeyboard(width: 464)
        defer { window.isHidden = true }
        let key = try XCTUnwrap(button(withIdentifier: "q", in: sut.view))
        sut.keyTouchDown(key)
        let callout = try XCTUnwrap(sut.keyCalloutView)
        XCTAssertFalse(callout.isHidden)
        let bounds = sut.view.bounds
        XCTAssertGreaterThanOrEqual(callout.frame.minX, KeyCalloutView.edgeInset)
        XCTAssertLessThanOrEqual(callout.frame.maxX, bounds.width - KeyCalloutView.edgeInset)
        XCTAssertGreaterThanOrEqual(callout.frame.minY, bounds.minY)
        sut.keyTouchUp(key)
    }

    @MainActor
    func testExtremelyShortFloatingKeyboardSuppressesCalloutFailClosed() throws {
        let (sut, window) = try windowedLettersPageTwentySixKeyKeyboard()
        defer { window.isHidden = true }

        // Predicate: the 44pt bubble itself must fit between the container top
        // edge and the key top; the 6pt gap is elastic.
        XCTAssertTrue(
            sut.canShowKeyCallout(
                keyFrame: CGRect(x: 4, y: 56, width: 33, height: 45),
                containerBounds: CGRect(x: 0, y: 0, width: 320, height: 260)
            ))
        // Host layout: top letter row at 48pt → gap clamps from 6pt to 4pt.
        XCTAssertTrue(
            sut.canShowKeyCallout(
                keyFrame: CGRect(x: 4, y: 48, width: 33, height: 45),
                containerBounds: CGRect(x: 0, y: 0, width: 320, height: 260)
            ))
        let hostLayoutBubble = sut.clampedCalloutFrame(
            keyFrame: CGRect(x: 4, y: 48, width: 33, height: 45),
            containerBounds: CGRect(x: 0, y: 0, width: 320, height: 260)
        )
        XCTAssertEqual(hostLayoutBubble.minY, 0, accuracy: 0.001)
        XCTAssertEqual(hostLayoutBubble.height, KeyCalloutView.preferredHeight, accuracy: 0.001)
        // Genuinely insufficient height: suppress entirely.
        XCTAssertFalse(
            sut.canShowKeyCallout(
                keyFrame: CGRect(x: 4, y: 40, width: 33, height: 30),
                containerBounds: CGRect(x: 0, y: 0, width: 320, height: 100)
            ))

        // Behavioral: a key whose bubble would pierce the container top edge
        // is suppressed entirely instead of showing a clipped bubble.
        let probe = UIButton(type: .system)
        probe.setTitle("Q", for: .normal)
        probe.frame = CGRect(x: 100, y: 40, width: 33, height: 45)
        sut.view.addSubview(probe)

        sut.showKeyCallout(for: probe)
        XCTAssertTrue(
            sut.keyCalloutView?.isHidden ?? true,
            "callout piercing the container top must fail closed")
        XCTAssertTrue(sut.keyCalloutView?.sourceButton == nil)

        // The same key at a feasible height still shows.
        probe.frame = CGRect(x: 100, y: 100, width: 33, height: 45)
        sut.showKeyCallout(for: probe)
        XCTAssertFalse(sut.keyCalloutView?.isHidden ?? true)
        XCTAssertEqual(sut.keyCalloutView?.characterText, "Q")
    }

    // MARK: - Rebuild force-hide (rotation / mode change)

    @MainActor
    func testReloadKeyboardAfterOrientationChangeForceHidesCallout() throws {
        let (sut, window) = try windowedLettersPageTwentySixKeyKeyboard()
        defer { window.isHidden = true }
        let key = try XCTUnwrap(button(withIdentifier: "q", in: sut.view))
        sut.keyTouchDown(key)
        XCTAssertFalse(sut.keyCalloutView?.isHidden ?? true)

        // Landscape rebuild: the resident callout must be force-hidden and the
        // single instance must survive the rebuild.
        sut.keyboardHeightGeometrySource = { .init(screenHeight: 844, isLandscape: true) }
        sut.reloadKeyboard()

        let callout = try XCTUnwrap(sut.keyCalloutView, "resident callout must survive the rebuild")
        XCTAssertTrue(callout.isHidden, "rebuild must force-hide the callout")
        sut.keyTouchUp(key)
    }
}
