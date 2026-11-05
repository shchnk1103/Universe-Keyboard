import UIKit
import XCTest

@testable import KeyboardCore

nonisolated final class KeyTouchCellMultiTouchTests: XCTestCase {
    @MainActor
    func testTwentySixKeyGapDoesNotTakeExclusiveTouch() throws {
        let owner = makeOwner(style: .twentySixKey)
        let keys = descendants(owner.rootStack).compactMap { $0 as? KeyboardKeyButton }
        let q = try XCTUnwrap(keys.first { $0.currentTitle?.lowercased() == "q" })
        let w = try XCTUnwrap(keys.first { $0.currentTitle?.lowercased() == "w" })
        let left = q.touchLayoutFrame(in: owner.view)
        let right = w.touchLayoutFrame(in: owner.view)
        let gap = right.minX - left.maxX
        XCTAssertGreaterThan(gap, 0)
        let point = CGPoint(x: left.maxX + gap / 4, y: left.midY)
        XCTAssertGreaterThan(point.x, left.maxX)
        XCTAssertLessThan(point.x, right.minX)
        XCTAssertFalse(left.contains(point))
        XCTAssertFalse(right.contains(point))
        XCTAssertNotEqual(point.x - left.maxX, right.minX - point.x)
        try assertGap(point, belongsTo: q, in: owner)
        assertKeyFace(q, in: owner)
    }

    @MainActor
    func testNineKeyGapDoesNotTakeExclusiveTouch() throws {
        let owner = makeOwner(style: .nineKey)
        let chrome = try XCTUnwrap(descendants(owner.rootStack).compactMap { $0 as? T9NineKeyChromeHost }.first)
        let jkl = try XCTUnwrap(chrome.touchColumns.first?.rows[1].first { $0.currentTitle == "JKL" })
        let tuv = try XCTUnwrap(chrome.touchColumns.first?.rows[2].first { $0.currentTitle == "TUV" })
        let upper = jkl.touchLayoutFrame(in: owner.view)
        let lower = tuv.touchLayoutFrame(in: owner.view)
        let gap = lower.minY - upper.maxY
        XCTAssertGreaterThan(gap, 0)
        let point = CGPoint(x: upper.midX, y: (upper.maxY + lower.minY) / 2 - 0.5)
        XCTAssertGreaterThan(point.y, upper.maxY)
        XCTAssertLessThan(point.y, lower.minY)
        XCTAssertFalse(upper.contains(point))
        XCTAssertFalse(lower.contains(point))
        XCTAssertNotEqual(point.y - upper.maxY, lower.minY - point.y)
        try assertGap(point, belongsTo: jkl, in: owner)
        assertKeyFace(jkl, in: owner)
    }

    @MainActor
    private func assertGap(_ point: CGPoint, belongsTo key: KeyboardKeyButton, in owner: KeyboardViewController) throws
    {
        let hit = try XCTUnwrap(owner.view.hitTest(point, with: nil))
        let source = Mirror(reflecting: hit).children.first { $0.label == "sourceButton" }?.value as? KeyboardKeyButton
        XCTAssertTrue(source === key)
        let control = try XCTUnwrap(hit as? UIControl)
        XCTAssertFalse(control.isExclusiveTouch)
    }

    @MainActor
    private func assertKeyFace(_ key: KeyboardKeyButton, in owner: KeyboardViewController) {
        let point = key.convert(CGPoint(x: key.bounds.midX, y: key.bounds.midY), to: owner.view)
        let hit = owner.view.hitTest(point, with: nil)
        XCTAssertTrue(hit === key || hit?.isDescendant(of: key) == true)
    }

    @MainActor
    private func makeOwner(style: KeyboardLayoutStyle) -> GapLayoutController {
        let owner = GapLayoutController()
        owner.loadViewIfNeeded()
        owner.controller = KeyboardController(state: KeyboardState())
        owner.cachedLayoutStyle = style
        owner.cachedT9ReadinessMatched = true
        owner.view.frame = CGRect(x: 0, y: 0, width: 390, height: owner.preferredKeyboardHeight)
        owner.setupRootStack()
        owner.reloadKeyboard()
        owner.view.frame.size.height = owner.preferredKeyboardHeight
        owner.view.setNeedsLayout()
        owner.view.layoutIfNeeded()
        (owner.rootStack as? KeyboardInputHitAreaStackView)?.refreshKeyTouchGeometry()
        return owner
    }

    @MainActor
    private func descendants(_ view: UIView) -> [UIView] {
        view.subviews.flatMap { [$0] + descendants($0) }
    }
}

@MainActor
private final class GapLayoutController: KeyboardViewController {
    override func viewDidLoad() {
        // Keep the fixture local to layout, without bootstrapping an extension session.
    }
}
