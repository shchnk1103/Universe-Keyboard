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
        sut.controller.textClient = FakeTextInputClient()
        sut.controller.state.inputMode = .chinese
        sut.controller.state.currentPage = .numbers
        sut.controller.state.currentComposition = ""
        sut.cachedLayoutStyle = .nineKey
        sut.cachedT9ReadinessMatched = true
        sut.reloadKeyboard()

        let bar = try XCTUnwrap(sut.candidateBar as? CandidateBarView)
        let strip = try XCTUnwrap(
            bar.subviews.first { $0.accessibilityIdentifier == "t9NumberPadShortcutStrip" } as? UIStackView)
        let titles = strip.arrangedSubviews.compactMap { ($0 as? UIButton)?.currentTitle }
        XCTAssertEqual(titles, ["/", "%", "#", "÷", "=", ":"])
        XCTAssertEqual(Set(titles), Set(T9NumberPadLayout.shortcutSymbols))

        var seen: [KeyboardAction] = []
        sut.controller.onActionObserved = { seen.append($0) }
        let slash = try XCTUnwrap(strip.arrangedSubviews.first as? UIButton)
        sut.insertT9NumberPadLiteral(slash)
        XCTAssertEqual(seen, [.insertT9NumberPadText("/")])
        XCTAssertFalse(
            seen.contains { action in
                if case .insertCandidate = action { return true }
                return false
            })

        sut.controller.state.currentComposition = "ni"
        sut.refreshCandidateBar()
        XCTAssertNil(bar.subviews.first { $0.accessibilityIdentifier == "t9NumberPadShortcutStrip" })

        sut.controller.state.currentComposition = ""
        sut.cachedLayoutStyle = .twentySixKey
        sut.reloadKeyboard()
        let idle = try XCTUnwrap(sut.candidateBar as? CandidateBarView)
        XCTAssertNil(idle.subviews.first { $0.accessibilityIdentifier == "t9NumberPadShortcutStrip" })
        XCTAssertTrue(sut.rootStack.arrangedSubviews.compactMap { $0 as? T9NineKeyChromeHost }.isEmpty)
    }

    @MainActor
    private func installedKeyboard() throws -> KeyboardViewController {
        let sut = KeyboardViewController()
        sut.loadViewIfNeeded()
        sut.keyboardRowHeightSource = { 45 }
        sut.keyboardHeightGeometrySource = { .init(screenHeight: 844, isLandscape: false) }
        sut.prepareKeyboardHeightForAppearance()
        sut.installPreferredKeyboardHeight()
        sut.installKeyboardUIIfNeeded()
        _ = try XCTUnwrap(sut.rootStack)
        return sut
    }

}
