import XCTest
@testable import KeyboardCore

final class ShiftStateTests: XCTestCase {

    var controller: KeyboardController!
    var client: FakeTextInputClient!

    override func setUp() {
        super.setUp()
        client = FakeTextInputClient()
        controller = KeyboardController()
        controller.textClient = client
    }

    // MARK: - Initial state

    func testInitialShiftStateIsOff() {
        XCTAssertEqual(controller.state.shiftState, .off)
    }

    // MARK: - Single tap

    func testSingleTapTurnsOnSingleUse() {
        _ = controller.handle(.toggleShift)
        XCTAssertEqual(controller.state.shiftState, .singleUse)
    }

    func testSingleTapTurnsOffSingleUse() {
        controller.state.shiftState = .singleUse
        _ = controller.handle(.toggleShift)
        XCTAssertEqual(controller.state.shiftState, .off)
    }

    func testSingleTapTurnsOffCapsLock() {
        controller.state.shiftState = .capsLock
        _ = controller.handle(.toggleShift)
        XCTAssertEqual(controller.state.shiftState, .off)
    }

    // MARK: - Double tap (Caps Lock)

    func testDoubleTapEntersCapsLock() {
        var callCount = 0
        controller.currentDate = {
            callCount += 1
            return Date(timeIntervalSinceReferenceDate: Double(callCount) * 0.1)
        }
        _ = controller.handle(.toggleShift)
        XCTAssertEqual(controller.state.shiftState, .singleUse)
        _ = controller.handle(.toggleShift)
        XCTAssertEqual(controller.state.shiftState, .capsLock)
    }

    func testSlowDoubleTapDoesNotEnterCapsLock() {
        var callCount = 0
        controller.currentDate = {
            callCount += 1
            return Date(timeIntervalSinceReferenceDate: Double(callCount) * 1.0)
        }
        _ = controller.handle(.toggleShift)
        XCTAssertEqual(controller.state.shiftState, .singleUse)
        _ = controller.handle(.toggleShift)
        XCTAssertEqual(controller.state.shiftState, .off)
    }

    // MARK: - Consume single-use

    func testConsumeSingleUseAfterKeyInsert() {
        controller.state.shiftState = .singleUse
        controller.state.currentPage = .letters
        controller.state.inputMode = .english

        let effects = controller.handle(.insertKey("a"))

        XCTAssertEqual(controller.state.shiftState, .off)
        XCTAssertTrue(effects.contains(.shiftStateChanged))
        XCTAssertEqual(client.text, "a")
    }

    func testConsumeSingleUseDoesNotFireWhenOff() {
        controller.state.shiftState = .off
        let effects = controller.handle(.insertKey("a"))
        XCTAssertFalse(effects.contains(.shiftStateChanged))
    }

    // MARK: - Reset

    func testResetShiftState() {
        controller.state.shiftState = .capsLock
        _ = controller.resetShiftState()
        XCTAssertEqual(controller.state.shiftState, .off)
    }
}
