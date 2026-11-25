import UIKit
import XCTest

@testable import KeyboardCore

/// Real chrome: layout table, space long-press, shortcut strip. No UIKit frames.
nonisolated final class T9NumberPadChromeTests: XCTestCase {
    @MainActor
    func testNumbersChromeMatchesLayoutTableAndKeepsSpaceLongPress() throws {
        let sut = try installedKeyboard()
        sut.controller.state.inputMode = .chinese
        sut.controller.state.currentPage = .numbers
        sut.cachedLayoutStyle = .nineKey
        sut.cachedT9ReadinessMatched = true
        sut.reloadKeyboard()

        let host = try XCTUnwrap(sut.rootStack.arrangedSubviews.compactMap { $0 as? T9NineKeyChromeHost }.first)
        XCTAssertEqual(host.touchColumns.count, 3)
        XCTAssertEqual(host.touchColumns.map { $0.rows.count }, [4, 4, 3])
        XCTAssertEqual(host.touchColumns[1].rows.map(\.count), [3, 3, 3, 3])

        let leftTitles = host.touchColumns[0].rows.map { $0.map { $0.currentTitle ?? "" } }
        XCTAssertEqual(leftTitles, [["@"], ["+"], ["-"], ["#+="]])
        let middleTitles = host.touchColumns[1].rows.map { $0.map { $0.currentTitle ?? "" } }
        XCTAssertEqual(middleTitles, [["1", "2", "3"], ["4", "5", "6"], ["7", "8", "9"], ["返回", "0", "."]])

        let delete = host.touchColumns[2].rows[0][0]
        XCTAssertEqual(delete.accessibilityIdentifier, "delete")
        let space = host.touchColumns[2].rows[1][0]
        XCTAssertEqual(space.accessibilityIdentifier, " ")
        let spaceActions = space.actions(forTarget: sut, forControlEvent: .touchUpInside) ?? []
        XCTAssertTrue(spaceActions.contains("insertT9NumberPadLiteral:"))
        XCTAssertFalse(spaceActions.contains("insertSpace:"))
        let longPresses =
            space.gestureRecognizers?.compactMap { $0 as? UILongPressGestureRecognizer } ?? []
        XCTAssertEqual(longPresses.count, 1)
        XCTAssertTrue(
            String(describing: longPresses[0]).contains("handleSpaceCursorLongPress:"),
            String(describing: longPresses[0]))
        XCTAssertTrue(sut.returnButton === host.touchColumns[2].rows[2][0])
        let returnElsewhere = host.touchColumns.enumerated().flatMap { column, touch in
            touch.rows.enumerated().flatMap { row, keys in
                keys.compactMap { key in
                    key === sut.returnButton && (column != 2 || row != 2) ? key : nil
                }
            }
        }
        XCTAssertTrue(returnElsewhere.isEmpty)
        let titles = host.touchColumns.flatMap(\.rows).flatMap { $0 }.map { $0.currentTitle ?? "" }
        for banned in ["😊", "选拼音", "ABC", "DEF"] {
            XCTAssertFalse(titles.contains(banned), banned)
        }
    }

    @MainActor
    func testShortcutStripIsExactAndDoesNotEmitSelection() throws {
        let sut = try installedKeyboard()
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 390, height: 300))
        window.rootViewController = sut
        window.makeKeyAndVisible()
        defer { window.isHidden = true }
        let textClient = FakeTextInputClient()
        sut.controller.textClient = textClient
        sut.controller.state.inputMode = .chinese
        sut.controller.state.currentPage = .numbers
        sut.controller.state.currentComposition = ""
        sut.cachedLayoutStyle = .nineKey
        sut.cachedT9ReadinessMatched = true
        sut.reloadKeyboard()

        let bar = try XCTUnwrap(sut.candidateBar as? CandidateBarView)
        let scroll = try shortcutScroll(in: bar)
        let strip = try XCTUnwrap(scroll.subviews.compactMap { $0 as? UIStackView }.first)
        let titles = strip.arrangedSubviews.compactMap { ($0 as? UIButton)?.currentTitle }
        XCTAssertEqual(titles, ["/", "%", "#", "÷", "=", ":"])
        XCTAssertEqual(Set(titles), Set(T9NumberPadLayout.shortcutSymbols))

        var seen: [KeyboardAction] = []
        sut.controller.onActionObserved = { seen.append($0) }
        let slash = try XCTUnwrap(strip.arrangedSubviews.first as? UIButton)
        slash.sendActions(for: .touchUpInside)
        XCTAssertEqual(
            seen, [.insertT9NumberPadText("/")],
            "adjusting=\(sut.isKeyboardHeightAdjusting) expanded=\(sut.isCandidateExpanded) enabled=\(slash.isEnabled) identifier=\(String(describing: slash.accessibilityIdentifier))"
        )
        XCTAssertEqual(textClient.text, "/")
        XCTAssertFalse(
            seen.contains { action in
                if case .insertCandidate = action { return true }
                return false
            })

        sut.controller.state.currentComposition = "ni"
        sut.refreshCandidateBar()
        XCTAssertNil(bar.subviews.first { $0.accessibilityIdentifier == "numberPadShortcuts" })

        sut.controller.state.currentComposition = ""
        sut.cachedLayoutStyle = .twentySixKey
        sut.reloadKeyboard()
        let idle = try XCTUnwrap(sut.candidateBar as? CandidateBarView)
        XCTAssertNil(idle.subviews.first { $0.accessibilityIdentifier == "numberPadShortcuts" })
        XCTAssertTrue(sut.rootStack.arrangedSubviews.compactMap { $0 as? T9NineKeyChromeHost }.isEmpty)
    }

    @MainActor
    func testNumberPadShortcutViewportScrolls() throws {
        let sut = try installedKeyboard()
        sut.controller.state.inputMode = .chinese
        sut.controller.state.currentPage = .numbers
        sut.cachedLayoutStyle = .nineKey
        sut.cachedT9ReadinessMatched = true
        sut.reloadKeyboard()
        let bar = try XCTUnwrap(sut.candidateBar as? CandidateBarView)
        bar.frame = CGRect(x: 0, y: 0, width: 220, height: 46)
        bar.layoutIfNeeded()
        let scroll = try shortcutScroll(in: bar)
        scroll.layoutIfNeeded()
        XCTAssertTrue(scroll.isScrollEnabled)
        XCTAssertGreaterThan(scroll.contentSize.width, scroll.bounds.width)
        scroll.setContentOffset(CGPoint(x: 30, y: 0), animated: false)
        XCTAssertEqual(scroll.contentOffset.x, 30, accuracy: 0.1)
    }

    @MainActor
    func testNumberPadShortcutReceivesHit() throws {
        let sut = try installedKeyboard()
        sut.controller.state.inputMode = .chinese
        sut.controller.state.currentPage = .numbers
        sut.cachedLayoutStyle = .nineKey
        sut.cachedT9ReadinessMatched = true
        sut.reloadKeyboard()
        let bar = try XCTUnwrap(sut.candidateBar as? CandidateBarView)
        bar.frame = CGRect(x: 0, y: 0, width: 390, height: 46)
        bar.layoutIfNeeded()
        let scroll = try shortcutScroll(in: bar)
        let strip = try XCTUnwrap(scroll.subviews.compactMap { $0 as? UIStackView }.first)
        let button = try XCTUnwrap(strip.arrangedSubviews.first as? UIButton)
        let point = button.convert(CGPoint(x: button.bounds.midX, y: button.bounds.midY), to: bar)
        let hit = bar.hitTest(point, with: nil)
        XCTAssertTrue(
            hit === button,
            "hit=\(String(describing: hit)) point=\(point) button=\(button.frame) scroll=\(scroll.frame) bar=\(bar.bounds)"
        )
    }

    @MainActor
    func testNumberPadShortcutTextUsesCandidateColor() throws {
        let sut = try installedKeyboard()
        sut.controller.state.inputMode = .chinese
        sut.controller.state.currentPage = .numbers
        sut.cachedLayoutStyle = .nineKey
        sut.cachedT9ReadinessMatched = true
        sut.reloadKeyboard()
        let bar = try XCTUnwrap(sut.candidateBar as? CandidateBarView)
        let scroll = try shortcutScroll(in: bar)
        let strip = try XCTUnwrap(scroll.subviews.compactMap { $0 as? UIStackView }.first)
        let button = try XCTUnwrap(strip.arrangedSubviews.first as? UIButton)
        let light = UITraitCollection(userInterfaceStyle: .light)
        let dark = UITraitCollection(userInterfaceStyle: .dark)
        XCTAssertEqual(button.currentTitleColor.resolvedColor(with: light), .black)
        XCTAssertEqual(button.currentTitleColor.resolvedColor(with: dark), .white)
        button.isHighlighted = true
        XCTAssertEqual(button.currentTitleColor.resolvedColor(with: light), .white)
        XCTAssertEqual(button.currentTitleColor.resolvedColor(with: dark), .black)
        XCTAssertEqual(button.backgroundColor?.resolvedColor(with: light), .black)
        XCTAssertEqual(button.backgroundColor?.resolvedColor(with: dark), .white)
    }

    @MainActor
    func testNumberPadShortcutBarCanExpand() throws {
        let sut = try installedKeyboard()
        sut.controller.state.inputMode = .chinese
        sut.controller.state.currentPage = .numbers
        sut.cachedLayoutStyle = .nineKey
        sut.cachedT9ReadinessMatched = true
        sut.reloadKeyboard()
        UIView.setAnimationsEnabled(false)
        defer { UIView.setAnimationsEnabled(true) }
        sut.handleCandidateBarTrailingButton()
        XCTAssertTrue(sut.isCandidateExpanded)
        let panel = try XCTUnwrap(sut.candidateExpandedPanel as? ExpandedCandidatePanelContainerView)
        let row = try XCTUnwrap(
            panel.revealViewport.subviews.first {
                $0.accessibilityIdentifier == "t9NumberPadExpandedShortcuts"
            } as? UIStackView)
        let button = try XCTUnwrap(row.arrangedSubviews.first as? UIButton)
        var seen: [KeyboardAction] = []
        sut.controller.onActionObserved = { seen.append($0) }
        button.sendActions(for: .touchUpInside)
        XCTAssertEqual(seen, [.insertT9NumberPadText("/")])
        XCTAssertFalse(sut.isCandidateExpanded)
    }

    @MainActor
    func testNumberPadPreferencePersistsAcrossKeyboardInstances() throws {
        let suite = "T9NumberPadChromeTests.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        defaults.set(true, forKey: "twenty_six_key_number_pad_enabled")
        let sut = try installedKeyboard()
        sut.sharedDefaults = try XCTUnwrap(UserDefaults(suiteName: suite))
        sut.refreshCachedSettings()
        sut.controller.state.inputMode = .chinese
        sut.cachedLayoutStyle = .twentySixKey
        sut.controller.state.currentPage = .numbers
        sut.reloadKeyboard()
        XCTAssertFalse(sut.rootStack.arrangedSubviews.compactMap { $0 as? T9NineKeyChromeHost }.isEmpty)
    }

    @MainActor
    func testTwentySixKeyNumberPadDefaultsOff() throws {
        let sut = try installedKeyboard()
        let suite = "T9NumberPadChromeTests.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        sut.sharedDefaults = defaults
        sut.refreshCachedSettings()
        sut.cachedLayoutStyle = .twentySixKey
        sut.controller.state.inputMode = .chinese
        sut.controller.state.currentPage = .numbers
        sut.reloadKeyboard()
        XCTAssertTrue(sut.rootStack.arrangedSubviews.compactMap { $0 as? T9NineKeyChromeHost }.isEmpty)
    }

    @MainActor
    func testTwentySixKeyNumberPadSettingRoutesAndReturns() throws {
        let sut = try installedKeyboard()
        sut.controller.state.inputMode = .chinese
        sut.cachedLayoutStyle = .twentySixKey
        sut.cachedT9ReadinessMatched = false
        let suite = "T9NumberPadChromeTests.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        defaults.set(true, forKey: "twenty_six_key_number_pad_enabled")
        sut.sharedDefaults = defaults
        sut.refreshCachedSettings()
        sut.cachedLayoutStyle = .twentySixKey
        sut.controller.state.currentPage = .numbers
        sut.reloadKeyboard()
        XCTAssertFalse(sut.rootStack.arrangedSubviews.compactMap { $0 as? T9NineKeyChromeHost }.isEmpty)
        sut.controller.state.currentPage = .letters
        sut.reloadKeyboard()
        XCTAssertTrue(sut.rootStack.arrangedSubviews.compactMap { $0 as? T9NineKeyChromeHost }.isEmpty)
    }

    @MainActor
    private func shortcutScroll(in bar: CandidateBarView) throws -> UIScrollView {
        try XCTUnwrap(bar.subviews.first { $0.accessibilityIdentifier == "numberPadShortcuts" } as? UIScrollView)
    }

    @MainActor
    private func installedKeyboard() throws -> KeyboardViewController {
        let sut = KeyboardViewController()
        sut.loadViewIfNeeded()
        sut.view.frame = CGRect(x: 0, y: 0, width: 390, height: 300)
        sut.keyboardRowHeightSource = { 45 }
        sut.keyboardHeightGeometrySource = { .init(screenHeight: 844, isLandscape: false) }
        sut.prepareKeyboardHeightForAppearance()
        sut.installPreferredKeyboardHeight()
        sut.installKeyboardUIIfNeeded()
        _ = try XCTUnwrap(sut.rootStack)
        return sut
    }

}
