import UIKit
import UIKit.UIGestureRecognizerSubclass
import XCTest

@testable import KeyboardCore

nonisolated final class OrdinaryKeyRolloverIntegrationTests: XCTestCase {
    @MainActor
    func testSyntheticSendActionsAndFunctionKeyIsolationRemainIntact() throws {
        let client = FakeTextInputClient()
        let owner = makeOwner(style: .twentySixKey, inputMode: .english, textClient: client)

        let shift = try XCTUnwrap(owner.shiftButton)
        let keyButtonA = try XCTUnwrap(findButton(title: "a", in: owner.rootStack))
        let keyButtonB = try XCTUnwrap(findButton(title: "b", in: owner.rootStack))

        XCTAssertFalse((shift as? KeyboardKeyButton)?.isOrdinaryRolloverParticipant ?? true)
        XCTAssertTrue(keyButtonA.isOrdinaryRolloverParticipant)
        XCTAssertTrue(keyButtonB.isOrdinaryRolloverParticipant)

        // Direct insertKey(_:) compatibility (e.g., gap forwarding / test invocation) must stay intact.
        owner.insertKey(keyButtonA)
        owner.insertKey(keyButtonB)
        XCTAssertEqual(client.text, "ab")
    }

    @MainActor
    func testNineKeyDigitsParticipateInOrdinaryRolloverWithoutRawHostCommit() throws {
        let owner = makeOwner(style: .nineKey, inputMode: .chinese, textClient: FakeTextInputClient())
        let chrome = try XCTUnwrap(
            descendants(owner.rootStack).compactMap { $0 as? T9NineKeyChromeHost }.first
        )
        let key2 = try XCTUnwrap(chrome.touchColumns.first?.rows[0].first { $0.accessibilityIdentifier == "2" })
        let key3 = try XCTUnwrap(chrome.touchColumns.first?.rows[0].first { $0.accessibilityIdentifier == "3" })

        XCTAssertTrue(key2.isOrdinaryRolloverParticipant)
        XCTAssertTrue(key3.isOrdinaryRolloverParticipant)

        var observedKeys: [String] = []
        owner.controller.onActionObserved = { action in
            if case .insertKey(let key) = action {
                observedKeys.append(key)
            }
        }

        let t1 = UITouch()
        let t2 = UITouch()
        XCTAssertTrue(key2.beginTracking(t1, with: nil))
        XCTAssertTrue(key3.beginTracking(t2, with: nil))
        XCTAssertEqual(observedKeys, ["2", "3"])

        key3.endTracking(t2, with: nil)
        key2.endTracking(t1, with: nil)
        XCTAssertEqual(observedKeys, ["2", "3"])
    }

    @MainActor
    func testLongPressVariantInterruptedBySecondKeySuppressesVariantAndEmitsABWithoutDoubleWrite() throws {
        let client = FakeTextInputClient()
        let owner = makeOwner(style: .twentySixKey, inputMode: .english, textClient: client)

        let keyA = try XCTUnwrap(findButton(title: "a", in: owner.rootStack))
        let keyB = try XCTUnwrap(findButton(title: "b", in: owner.rootStack))
        let longPressA = try XCTUnwrap(
            keyA.gestureRecognizers?.compactMap { $0 as? RolloverTestLongPress }.first
                ?? {
                    let g = RolloverTestLongPress(
                        target: owner, action: #selector(KeyboardViewController.handleKeyLongPress(_:)))
                    keyA.addGestureRecognizer(g)
                    return g
                }()
        )

        var observedKeys: [String] = []
        owner.controller.onActionObserved = { action in
            if case .insertKey(let key) = action {
                observedKeys.append(key)
            }
        }

        let t1 = UITouch()
        XCTAssertTrue(keyA.beginTracking(t1, with: nil))

        longPressA.testState = .began
        owner.handleKeyLongPress(longPressA)
        XCTAssertNotNil(owner.variantPopupView)

        let t2 = UITouch()
        XCTAssertTrue(keyB.beginTracking(t2, with: nil))
        XCTAssertNil(owner.variantPopupView)
        XCTAssertEqual(observedKeys, ["a", "b"])
        XCTAssertEqual(owner.ordinaryRolloverStateMachine.activeTouchCount, 1)

        // Ending the long-press gesture afterwards must not commit a variant character.
        longPressA.testState = .ended
        owner.handleKeyLongPress(longPressA)
        keyB.endTracking(t2, with: nil)

        XCTAssertEqual(owner.ordinaryRolloverStateMachine.activeTouchCount, 0)
        XCTAssertEqual(observedKeys, ["a", "b"])
        XCTAssertEqual(client.text, "ab")

        // Tapping keyA again must insert "a", and long-pressing keyC must still open its variant popup.
        let t3 = UITouch()
        XCTAssertTrue(keyA.beginTracking(t3, with: nil))
        keyA.endTracking(t3, with: nil)
        XCTAssertEqual(client.text, "aba")
        XCTAssertEqual(owner.ordinaryRolloverStateMachine.activeTouchCount, 0)

        let keyC = try XCTUnwrap(findButton(title: "c", in: owner.rootStack))
        let longPressC = RolloverTestLongPress(
            target: owner, action: #selector(KeyboardViewController.handleKeyLongPress(_:)))
        keyC.addGestureRecognizer(longPressC)
        let t4 = UITouch()
        XCTAssertTrue(keyC.beginTracking(t4, with: nil))
        longPressC.testState = .began
        owner.handleKeyLongPress(longPressC)
        XCTAssertNotNil(owner.variantPopupView)
        longPressC.testState = .cancelled
        owner.handleKeyLongPress(longPressC)
        XCTAssertEqual(owner.ordinaryRolloverStateMachine.activeTouchCount, 0)
    }

    @MainActor
    func testShiftSingleUseFrozenAtBeganForOverlappingKeys() throws {
        let client = FakeTextInputClient()
        let owner = makeOwner(style: .twentySixKey, inputMode: .english, textClient: client)
        owner.controller.state.shiftState = .singleUse
        owner.refreshLetterButtons()

        let keyA = try XCTUnwrap(findButton(title: "A", in: owner.rootStack))

        let t1 = UITouch()
        XCTAssertTrue(keyA.beginTracking(t1, with: nil))
        // Pressing B while A is .pending with Shift.singleUse must consume A ("A"),
        // reset Shift to .off, and resolve B as lowercase "b" (never "AB").
        let keyBWhilePending = try XCTUnwrap(findButton(title: "B", in: owner.rootStack))
        let t2 = UITouch()
        XCTAssertTrue(keyBWhilePending.beginTracking(t2, with: nil))
        XCTAssertEqual(owner.controller.state.shiftState, .off)
        XCTAssertEqual(client.text, "Ab")

        keyBWhilePending.endTracking(t2, with: nil)
        // Pressing B again while A is still held produces "Abb".
        let t3 = UITouch()
        XCTAssertTrue(keyBWhilePending.beginTracking(t3, with: nil))
        keyBWhilePending.endTracking(t3, with: nil)
        keyA.endTracking(t1, with: nil)

        XCTAssertEqual(client.text, "Abb")
        XCTAssertEqual(owner.ordinaryRolloverStateMachine.activeTouchCount, 0)
    }

    @MainActor
    func testSingleTapAndBothLiftOrdersAndTouchesEndedSuppression() throws {
        let client = FakeTextInputClient()
        let owner = makeOwner(style: .twentySixKey, inputMode: .english, textClient: client)

        let keyA = try XCTUnwrap(findButton(title: "a", in: owner.rootStack))
        let keyB = try XCTUnwrap(findButton(title: "b", in: owner.rootStack))

        // 1. Single tap: touchesEnded + endTracking must insert "a" once without double-write.
        let tSingle = UITouch()
        XCTAssertTrue(keyA.beginTracking(tSingle, with: nil))
        keyA.touchesEnded([tSingle], with: nil)
        keyA.endTracking(tSingle, with: nil)
        XCTAssertEqual(client.text, "a")

        // 2. Overlap lift order 1: B lifts before A.
        let t1 = UITouch()
        let t2 = UITouch()
        XCTAssertTrue(keyA.beginTracking(t1, with: nil))
        XCTAssertTrue(keyB.beginTracking(t2, with: nil))
        keyB.touchesEnded([t2], with: nil)
        keyB.endTracking(t2, with: nil)
        keyA.touchesEnded([t1], with: nil)
        keyA.endTracking(t1, with: nil)
        XCTAssertEqual(client.text, "aab")

        // 3. Overlap lift order 2: A lifts before B.
        let t3 = UITouch()
        let t4 = UITouch()
        XCTAssertTrue(keyA.beginTracking(t3, with: nil))
        XCTAssertTrue(keyB.beginTracking(t4, with: nil))
        keyA.touchesEnded([t3], with: nil)
        keyA.endTracking(t3, with: nil)
        keyB.touchesEnded([t4], with: nil)
        keyB.endTracking(t4, with: nil)
        XCTAssertEqual(client.text, "aabab")
        XCTAssertEqual(owner.ordinaryRolloverStateMachine.activeTouchCount, 0)
    }

    @MainActor
    func testFunctionKeyGapControlDoesNotEnterPressOrderQueue() throws {
        let client = FakeTextInputClient()
        let owner = makeOwner(style: .twentySixKey, inputMode: .english, textClient: client)

        let shift = try XCTUnwrap(owner.shiftButton as? KeyboardKeyButton)
        let z = try XCTUnwrap(findButton(title: "z", in: owner.rootStack))
        let gapControl = try XCTUnwrap(
            owner.view.hitTest(try XCTUnwrap(gapPointBetween(left: shift, right: z, in: owner)), with: nil)
                as? UIControl
        )

        let t1 = UITouch()
        XCTAssertTrue(gapControl.beginTracking(t1, with: nil))
        // Function-key gap control must not trigger press-order consumption when z is pressed.
        let t2 = UITouch()
        XCTAssertTrue(z.beginTracking(t2, with: nil))
        XCTAssertEqual(client.text, "")
        // Function-key gap must also have no long-press variant recognizer (T8).
        XCTAssertTrue(
            (gapControl.gestureRecognizers ?? []).allSatisfy { !($0 is UILongPressGestureRecognizer) }
        )
    }

    @MainActor
    func testT3CrossSubregionBoundsContainBothGapAndFace() throws {
        let client = FakeTextInputClient()
        let owner = makeOwner(style: .twentySixKey, inputMode: .english, textClient: client)

        let q = try XCTUnwrap(findButton(title: "q", in: owner.rootStack))
        let w = try XCTUnwrap(findButton(title: "w", in: owner.rootStack))
        let gapPoint = try XCTUnwrap(gapPointBetween(left: q, right: w, in: owner))
        let gapControl = try XCTUnwrap(owner.view.hitTest(gapPoint, with: nil) as? UIControl)

        // T3: gapControl bounds cover q's visual face, and q.localTouchBounds covers gapPoint.
        let qCenterInGap = q.convert(CGPoint(x: q.bounds.midX, y: q.bounds.midY), to: gapControl)
        XCTAssertTrue(gapControl.bounds.contains(qCenterInGap))
        let gapInQ = owner.view.convert(gapPoint, to: q)
        XCTAssertTrue(q.point(inside: gapInQ, with: nil))
    }

    // MARK: - Touch Region Consistency (T1–T8)

    @MainActor
    func testT1GapTapAndDragExitCancel() throws {
        let client = FakeTextInputClient()
        let owner = makeOwner(style: .twentySixKey, inputMode: .english, textClient: client)

        let q = try XCTUnwrap(findButton(title: "q", in: owner.rootStack))
        let w = try XCTUnwrap(findButton(title: "w", in: owner.rootStack))
        let gapPoint = try XCTUnwrap(gapPointBetween(left: q, right: w, in: owner))
        let gapControl = try XCTUnwrap(owner.view.hitTest(gapPoint, with: nil) as? UIControl)

        let t1 = UITouch()
        XCTAssertTrue(gapControl.beginTracking(t1, with: nil))
        // T1: while held alone, gap must be .pending (no premature insert).
        XCTAssertEqual(client.text, "")
        gapControl.endTracking(t1, with: nil)
        XCTAssertEqual(client.text, "q")
        XCTAssertEqual(owner.ordinaryRolloverStateMachine.activeTouchCount, 0)
    }

    @MainActor
    func testT2AndT8VariantLongPressOnlyOnVariantKeysInGap() throws {
        let client = FakeTextInputClient()
        let owner = makeOwner(style: .twentySixKey, inputMode: .english, textClient: client)

        let a = try XCTUnwrap(findButton(title: "a", in: owner.rootStack))
        let s = try XCTUnwrap(findButton(title: "s", in: owner.rootStack))
        let gapA = try XCTUnwrap(
            owner.view.hitTest(try XCTUnwrap(gapPointBetween(left: a, right: s, in: owner)), with: nil)
                as? UIControl
        )
        // T2: "a" has variants -> gap control must have a 0.3s UILongPressGestureRecognizer with delegate.
        let lpA = try XCTUnwrap(
            gapA.gestureRecognizers?.compactMap { $0 as? UILongPressGestureRecognizer }.first
        )
        XCTAssertEqual(lpA.minimumPressDuration, 0.3, accuracy: 0.001)
        XCTAssertNotNil(lpA.delegate)

        // T2: simulate long-press .began on gapA -> popup anchored to visual button "a".
        let lpTest = RolloverTestLongPress(
            target: owner, action: #selector(KeyboardViewController.handleKeyLongPress(_:)))
        gapA.addGestureRecognizer(lpTest)
        let t1 = UITouch()
        XCTAssertTrue(gapA.beginTracking(t1, with: nil))
        lpTest.testState = .began
        owner.handleKeyLongPress(lpTest)
        let popup = try XCTUnwrap(owner.variantPopupView)
        let aFrame = a.convert(a.bounds, to: owner.view)
        XCTAssertLessThan(popup.frame.maxY, aFrame.minY)
        lpTest.testState = .cancelled
        owner.handleKeyLongPress(lpTest)
        XCTAssertEqual(client.text, "")
        XCTAssertEqual(owner.ordinaryRolloverStateMachine.activeTouchCount, 0)

        // T8: "q" (no variants) and Shift (function key) must NOT have long-press on their gap controls.
        let q = try XCTUnwrap(findButton(title: "q", in: owner.rootStack))
        let w = try XCTUnwrap(findButton(title: "w", in: owner.rootStack))
        let gapQ = try XCTUnwrap(
            owner.view.hitTest(try XCTUnwrap(gapPointBetween(left: q, right: w, in: owner)), with: nil)
                as? UIControl
        )
        XCTAssertTrue(
            (gapQ.gestureRecognizers ?? []).allSatisfy { !($0 is UILongPressGestureRecognizer) }
        )
    }

    @MainActor
    func testT4AndT6GapPlusFaceRolloverAndShiftSingleUse() throws {
        let client = FakeTextInputClient()
        let owner = makeOwner(style: .twentySixKey, inputMode: .english, textClient: client)
        owner.controller.state.shiftState = .singleUse
        owner.refreshLetterButtons()

        let a = try XCTUnwrap(findButton(title: "A", in: owner.rootStack))
        let s = try XCTUnwrap(findButton(title: "S", in: owner.rootStack))
        let gapA = try XCTUnwrap(
            owner.view.hitTest(try XCTUnwrap(gapPointBetween(left: a, right: s, in: owner)), with: nil)
                as? UIControl
        )

        let t1 = UITouch()
        XCTAssertTrue(gapA.beginTracking(t1, with: nil))
        // T6: pressing S while A's gap is held consumes "A", resets Shift.singleUse, and consumes "s".
        let t2 = UITouch()
        XCTAssertTrue(s.beginTracking(t2, with: nil))
        XCTAssertEqual(client.text, "As")
        XCTAssertEqual(owner.controller.state.shiftState, .off)

        s.endTracking(t2, with: nil)
        let t3 = UITouch()
        XCTAssertTrue(s.beginTracking(t3, with: nil))
        s.endTracking(t3, with: nil)
        gapA.endTracking(t1, with: nil)
        XCTAssertEqual(client.text, "Ass")
        XCTAssertEqual(owner.ordinaryRolloverStateMachine.activeTouchCount, 0)
    }

    @MainActor
    func testT5GapVariantInterruptedBySecondKeyAndRecovered() throws {
        let client = FakeTextInputClient()
        let owner = makeOwner(style: .twentySixKey, inputMode: .english, textClient: client)

        let a = try XCTUnwrap(findButton(title: "a", in: owner.rootStack))
        let s = try XCTUnwrap(findButton(title: "s", in: owner.rootStack))
        let gapA = try XCTUnwrap(
            owner.view.hitTest(try XCTUnwrap(gapPointBetween(left: a, right: s, in: owner)), with: nil)
                as? UIControl
        )
        let lpTest = RolloverTestLongPress(
            target: owner, action: #selector(KeyboardViewController.handleKeyLongPress(_:)))
        gapA.addGestureRecognizer(lpTest)

        let t1 = UITouch()
        XCTAssertTrue(gapA.beginTracking(t1, with: nil))
        lpTest.testState = .began
        owner.handleKeyLongPress(lpTest)
        XCTAssertNotNil(owner.variantPopupView)

        let t2 = UITouch()
        XCTAssertTrue(s.beginTracking(t2, with: nil))
        XCTAssertNil(owner.variantPopupView)
        XCTAssertEqual(client.text, "as")

        lpTest.testState = .ended
        owner.handleKeyLongPress(lpTest)
        s.endTracking(t2, with: nil)
        XCTAssertEqual(owner.ordinaryRolloverStateMachine.activeTouchCount, 0)
        XCTAssertEqual(client.text, "as")

        // Subsequent tap on gapA works normally.
        let t3 = UITouch()
        XCTAssertTrue(gapA.beginTracking(t3, with: nil))
        gapA.endTracking(t3, with: nil)
        XCTAssertEqual(client.text, "asa")
    }

    @MainActor
    func testT7SameKeyFacePlusGapMutualExclusion() throws {
        let client = FakeTextInputClient()
        let owner = makeOwner(style: .twentySixKey, inputMode: .english, textClient: client)

        let a = try XCTUnwrap(findButton(title: "a", in: owner.rootStack))
        let s = try XCTUnwrap(findButton(title: "s", in: owner.rootStack))
        let gapA = try XCTUnwrap(
            owner.view.hitTest(try XCTUnwrap(gapPointBetween(left: a, right: s, in: owner)), with: nil)
                as? UIControl
        )
        let lpGapA = try XCTUnwrap(
            gapA.gestureRecognizers?.compactMap { $0 as? UILongPressGestureRecognizer }.first
        )

        let t1 = UITouch()
        XCTAssertTrue(a.beginTracking(t1, with: nil))
        // T7: second finger on same key's gap must be rejected by both beginTracking and longPress delegate.
        let t2 = UITouch()
        XCTAssertFalse(gapA.beginTracking(t2, with: nil))
        XCTAssertFalse(lpGapA.delegate?.gestureRecognizerShouldBegin?(lpGapA) ?? true)

        a.endTracking(t1, with: nil)
        XCTAssertEqual(client.text, "a")
        XCTAssertEqual(owner.ordinaryRolloverStateMachine.activeTouchCount, 0)
    }

    @MainActor
    private func gapPointBetween(
        left: KeyboardKeyButton,
        right: KeyboardKeyButton,
        in owner: KeyboardViewController
    ) -> CGPoint? {
        let leftFrame = left.touchLayoutFrame(in: owner.view)
        let rightFrame = right.touchLayoutFrame(in: owner.view)
        let gap = rightFrame.minX - leftFrame.maxX
        guard gap > 0 else { return nil }
        return CGPoint(x: leftFrame.maxX + gap / 4, y: leftFrame.midY)
    }

    @MainActor
    private func makeOwner(
        style: KeyboardLayoutStyle,
        inputMode: InputMode,
        textClient: FakeTextInputClient
    ) -> RolloverLayoutController {
        let owner = RolloverLayoutController()
        owner.loadViewIfNeeded()
        var state = KeyboardState()
        state.inputMode = inputMode
        owner.controller = KeyboardController(state: state)
        owner.controller.textClient = textClient
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
    private func findButton(title: String, in root: UIView) -> KeyboardKeyButton? {
        descendants(root)
            .compactMap { $0 as? KeyboardKeyButton }
            .first { $0.title(for: .normal) == title }
    }

    @MainActor
    private func descendants(_ view: UIView) -> [UIView] {
        view.subviews.flatMap { [$0] + descendants($0) }
    }
}

@MainActor
private final class RolloverLayoutController: KeyboardViewController {
    override func viewDidLoad() {
        // Keep fixture local to layout and controller state.
    }
}

private final class RolloverTestLongPress: UILongPressGestureRecognizer {
    var testState: UIGestureRecognizer.State = .possible
    override var state: UIGestureRecognizer.State {
        get { testState }
        set { testState = newValue }
    }
}
