import XCTest

@testable import KeyboardCore

@MainActor
final class ShiftStateTests: XCTestCase {

    let client = FakeTextInputClient()
    lazy var controller: KeyboardController = {
        let controller = KeyboardController()
        controller.textClient = client
        return controller
    }()

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

    // MARK: - Edge cases

    func testShiftDuringComposition() {
        controller.state.currentComposition = "ni"
        _ = controller.handle(.toggleShift)
        // composition 存在时 shift 切换不影响输入
        XCTAssertEqual(controller.state.shiftState, .singleUse)
    }

    func testCapsLockPersistence() {
        // Double tap → caps lock
        _ = controller.handle(.toggleShift)
        _ = controller.handle(.toggleShift)
        XCTAssertEqual(controller.state.shiftState, .capsLock)
        // 换页后 caps lock 应 reset
        _ = controller.handle(.togglePage)
        XCTAssertEqual(controller.state.shiftState, .off)
    }

    func testRapidShiftToggle() {
        // 快速双击 (<0.35s) 触发 caps lock
        _ = controller.handle(.toggleShift)
        XCTAssertEqual(controller.state.shiftState, .singleUse)
        _ = controller.handle(.toggleShift)
        XCTAssertEqual(controller.state.shiftState, .capsLock)
        // 第三次单击退出 caps lock
        _ = controller.handle(.toggleShift)
        XCTAssertEqual(controller.state.shiftState, .off)
    }
}
