import XCTest

@testable import KeyboardCore

final class OrdinaryKeyRolloverStateMachineTests: XCTestCase {
    private typealias Machine = OrdinaryKeyRolloverStateMachine<String, String>
    private typealias Effect = OrdinaryKeyRolloverEffect<String>

    func testShortRolloverConsumesAAndBInPressOrderWithoutDuplicateOnLift() {
        var machine = Machine()
        let epoch = machine.sessionEpoch
        let payloadA = FrozenOrdinaryKeyPayload(rawKey: "a", effectiveText: "a")
        let payloadB = FrozenOrdinaryKeyPayload(rawKey: "b", effectiveText: "b")

        XCTAssertEqual(machine.began(touchID: "t1", buttonID: "keyA", payload: payloadA), [])
        XCTAssertEqual(
            machine.began(touchID: "t2", buttonID: "keyB", payload: payloadB),
            [
                .consumeKey(buttonID: "keyA", payload: payloadA),
                .suppressLongPress(buttonID: "keyA"),
                .consumeKey(buttonID: "keyB", payload: payloadB),
                .suppressLongPress(buttonID: "keyB"),
            ]
        )

        // Lifting B first, then A must only clear highlights, never duplicate.
        XCTAssertEqual(machine.endedInside(touchID: "t2", epoch: epoch), [.clearHighlight(buttonID: "keyB")])
        XCTAssertEqual(machine.endedInside(touchID: "t1", epoch: epoch), [.clearHighlight(buttonID: "keyA")])
        XCTAssertEqual(machine.activeTouchCount, 0)
    }

    func testVariantPopupInterruptedBySecondKeyDismissesVariantAndOutputsAB() {
        var machine = Machine()
        let epoch = machine.sessionEpoch
        let payloadA = FrozenOrdinaryKeyPayload(rawKey: "a", effectiveText: "a")
        let payloadB = FrozenOrdinaryKeyPayload(rawKey: "b", effectiveText: "b")

        XCTAssertEqual(machine.began(touchID: "t1", buttonID: "keyA", payload: payloadA), [])
        XCTAssertTrue(machine.longPressBegan(buttonID: "keyA"))
        // UIButton.cancelTracking during long-press takeover must be a no-op (r3 §1).
        XCTAssertEqual(
            machine.uiButtonCancelTracking(touchID: "t1", buttonID: "keyA", epoch: epoch),
            []
        )
        XCTAssertEqual(machine.phase(forButtonID: "keyA"), .variantOwned)

        XCTAssertEqual(
            machine.began(touchID: "t2", buttonID: "keyB", payload: payloadB),
            [
                .dismissVariantAndSuppressLongPress(buttonID: "keyA"),
                .consumeKey(buttonID: "keyA", payload: payloadA),
                .consumeKey(buttonID: "keyB", payload: payloadB),
                .suppressLongPress(buttonID: "keyB"),
            ]
        )
        // Only keyB remains active; interrupted .variantOwned keyA has been removed.
        XCTAssertEqual(machine.activeTouchCount, 1)
        XCTAssertNil(machine.phase(forButtonID: "keyA"))

        // Subsequent variant end must be rejected to prevent double-writing a + à.
        XCTAssertFalse(machine.variantEndedOrCancelled(buttonID: "keyA"))
        XCTAssertEqual(machine.endedInside(touchID: "t2", epoch: epoch), [.clearHighlight(buttonID: "keyB")])
        XCTAssertEqual(machine.activeTouchCount, 0)

        // Tapping keyA again works normally, and long-pressing keyC still enters .variantOwned.
        XCTAssertEqual(machine.began(touchID: "t3", buttonID: "keyA", payload: payloadA), [])
        XCTAssertEqual(
            machine.endedInside(touchID: "t3", epoch: epoch),
            [.consumeKey(buttonID: "keyA", payload: payloadA), .clearHighlight(buttonID: "keyA")]
        )
        XCTAssertEqual(machine.activeTouchCount, 0)

        let payloadC = FrozenOrdinaryKeyPayload(rawKey: "c", effectiveText: "c")
        XCTAssertEqual(machine.began(touchID: "t4", buttonID: "keyC", payload: payloadC), [])
        XCTAssertTrue(machine.longPressBegan(buttonID: "keyC"))
        XCTAssertTrue(machine.variantEndedOrCancelled(buttonID: "keyC"))
        XCTAssertEqual(machine.activeTouchCount, 0)
    }

    func testStandaloneLongPressCommitsNormally() {
        var machine = Machine()
        let payloadA = FrozenOrdinaryKeyPayload(rawKey: "a", effectiveText: "a")

        XCTAssertEqual(machine.began(touchID: "t1", buttonID: "keyA", payload: payloadA), [])
        XCTAssertTrue(machine.longPressBegan(buttonID: "keyA"))
        XCTAssertTrue(machine.variantEndedOrCancelled(buttonID: "keyA"))
        XCTAssertEqual(machine.activeTouchCount, 0)
    }

    func testHoldingAAndRepeatedlyTappingBProducesABBB() {
        var machine = Machine()
        let epoch = machine.sessionEpoch
        let payloadA = FrozenOrdinaryKeyPayload(rawKey: "a", effectiveText: "a")
        let payloadB = FrozenOrdinaryKeyPayload(rawKey: "b", effectiveText: "b")

        XCTAssertEqual(machine.began(touchID: "tA", buttonID: "keyA", payload: payloadA), [])
        XCTAssertEqual(
            machine.began(touchID: "tB1", buttonID: "keyB", payload: payloadB),
            [
                .consumeKey(buttonID: "keyA", payload: payloadA),
                .suppressLongPress(buttonID: "keyA"),
                .consumeKey(buttonID: "keyB", payload: payloadB),
                .suppressLongPress(buttonID: "keyB"),
            ]
        )
        XCTAssertEqual(machine.endedInside(touchID: "tB1", epoch: epoch), [.clearHighlight(buttonID: "keyB")])

        // Second and third B taps while A is still held consume B immediately on down.
        XCTAssertEqual(
            machine.began(touchID: "tB2", buttonID: "keyB", payload: payloadB),
            [
                .consumeKey(buttonID: "keyB", payload: payloadB),
                .suppressLongPress(buttonID: "keyB"),
            ]
        )
        XCTAssertEqual(machine.endedInside(touchID: "tB2", epoch: epoch), [.clearHighlight(buttonID: "keyB")])

        XCTAssertEqual(
            machine.began(touchID: "tB3", buttonID: "keyB", payload: payloadB),
            [
                .consumeKey(buttonID: "keyB", payload: payloadB),
                .suppressLongPress(buttonID: "keyB"),
            ]
        )
        XCTAssertEqual(machine.endedInside(touchID: "tB3", epoch: epoch), [.clearHighlight(buttonID: "keyB")])

        // Late longPressBegan on already-consumed A must be rejected.
        XCTAssertFalse(machine.longPressBegan(buttonID: "keyA"))
        XCTAssertEqual(machine.endedInside(touchID: "tA", epoch: epoch), [.clearHighlight(buttonID: "keyA")])
        XCTAssertEqual(machine.activeTouchCount, 0)
    }

    func testSingleKeyDragExitAndCancelDoNotConsumeAndPreserveFrozenShiftPayload() {
        var machine = Machine()
        let epoch = machine.sessionEpoch
        let shiftedA = FrozenOrdinaryKeyPayload(rawKey: "a", effectiveText: "A")
        let payloadB = FrozenOrdinaryKeyPayload(rawKey: "b", effectiveText: "b")

        XCTAssertEqual(machine.began(touchID: "t1", buttonID: "keyA", payload: shiftedA), [])
        XCTAssertEqual(machine.dragExit(touchID: "t1", epoch: epoch), [.clearHighlight(buttonID: "keyA")])
        XCTAssertEqual(machine.activeTouchCount, 0)

        // New touch with frozen uppercase A followed by B still emits uppercase A.
        XCTAssertEqual(machine.began(touchID: "t2", buttonID: "keyA", payload: shiftedA), [])
        XCTAssertEqual(
            machine.began(touchID: "t3", buttonID: "keyB", payload: payloadB),
            [
                .consumeKey(buttonID: "keyA", payload: shiftedA),
                .suppressLongPress(buttonID: "keyA"),
                .consumeKey(buttonID: "keyB", payload: payloadB),
                .suppressLongPress(buttonID: "keyB"),
            ]
        )

        // Cancelling A after consumption does not retract A.
        XCTAssertEqual(
            machine.uiButtonCancelTracking(touchID: "t2", buttonID: "keyA", epoch: epoch),
            [.clearHighlight(buttonID: "keyA")]
        )
    }

    func testSameKeySecondFingerIgnoredAndInvalidateAllDropsStaleEpoch() {
        var machine = Machine()
        let oldEpoch = machine.sessionEpoch
        let payloadA = FrozenOrdinaryKeyPayload(rawKey: "a", effectiveText: "a")

        XCTAssertEqual(machine.began(touchID: "t1", buttonID: "keyA", payload: payloadA), [])
        XCTAssertEqual(machine.began(touchID: "t2", buttonID: "keyA", payload: payloadA), [])

        let invalidation = machine.invalidateAll()
        XCTAssertEqual(invalidation, [.clearHighlight(buttonID: "keyA")])
        XCTAssertEqual(machine.sessionEpoch, oldEpoch + 1)
        XCTAssertEqual(machine.endedInside(touchID: "t1", epoch: oldEpoch), [])
    }
}
