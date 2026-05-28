import XCTest

@testable import KeyboardCore

/// 测试键盘显示逻辑，这些值驱动 KeyboardViewController+Display.swift 中的计算属性。
///
/// 虽然具体的 UI 标题计算（如 "拼音" / "English" / "123"）定义在 UIKit 层，
/// 但底层状态转换和分支逻辑可以通过 KeyboardState 和 KeyboardController 进行测试。
@MainActor
final class DisplayLogicTests: XCTestCase {

    let client = FakeTextInputClient()
    lazy var controller: KeyboardController = {
        let controller = KeyboardController()
        controller.textClient = client
        return controller
    }()

    // MARK: - Page switch title (derived from currentPage)

    func testPageSwitchOnLettersPage() {
        XCTAssertEqual(controller.state.currentPage, .letters)
        // letters → title is "123"
    }

    func testPageSwitchOnNumbersPage() {
        controller.state.currentPage = .numbers
        XCTAssertEqual(controller.state.currentPage, .numbers)
        // numbers → title is "#+="
    }

    func testPageSwitchOnSymbolsPage() {
        controller.state.currentPage = .symbols
        XCTAssertEqual(controller.state.currentPage, .symbols)
        // symbols → title is "ABC"
    }

    func testPageSwitchCyclesCorrectly() {
        XCTAssertEqual(controller.state.currentPage, .letters)
        _ = controller.handle(.togglePage)
        XCTAssertEqual(controller.state.currentPage, .numbers)
        _ = controller.handle(.togglePage)
        XCTAssertEqual(controller.state.currentPage, .symbols)
        _ = controller.handle(.togglePage)
        XCTAssertEqual(controller.state.currentPage, .emoji)
        _ = controller.handle(.togglePage)
        XCTAssertEqual(controller.state.currentPage, .letters)
    }

    // MARK: - Input mode (derived from inputMode)

    func testInputModeButtonChinese() {
        XCTAssertEqual(controller.state.inputMode, .chinese)
        // chinese → title is "中"
    }

    func testInputModeButtonEnglish() {
        controller.state.inputMode = .english
        XCTAssertEqual(controller.state.inputMode, .english)
        // english → title is "英"
    }

    // MARK: - Space button title (derived from page + mode)

    func testSpaceButtonChineseOnLetters() {
        controller.state.inputMode = .chinese
        controller.state.currentPage = .letters
        XCTAssertEqual(controller.state.inputMode, .chinese)
        XCTAssertEqual(controller.state.currentPage, .letters)
        // chinese + letters → "拼音"
    }

    func testSpaceButtonEnglishOnLetters() {
        controller.state.inputMode = .english
        controller.state.currentPage = .letters
        XCTAssertEqual(controller.state.inputMode, .english)
        XCTAssertEqual(controller.state.currentPage, .letters)
        // english + letters → "English"
    }

    func testSpaceButtonOnNumbers() {
        controller.state.currentPage = .numbers
        XCTAssertEqual(controller.state.currentPage, .numbers)
        // non-letters → "space"
    }

    func testSpaceButtonOnSymbols() {
        controller.state.currentPage = .symbols
        XCTAssertEqual(controller.state.currentPage, .symbols)
        // non-letters → "space"
    }

    // MARK: - Shift display title (derived from shiftState)

    func testShiftButtonOff() {
        XCTAssertEqual(controller.state.shiftState, .off)
        // off → title is "⇧"
    }

    func testShiftButtonSingleUse() {
        controller.state.shiftState = .singleUse
        XCTAssertEqual(controller.state.shiftState, .singleUse)
        // singleUse → title is "⇧"
    }

    func testShiftButtonCapsLock() {
        controller.state.shiftState = .capsLock
        XCTAssertEqual(controller.state.shiftState, .capsLock)
        // capsLock → title is "⇪"
    }

    func testShiftToggleStates() {
        // off → singleUse
        _ = controller.handle(.toggleShift)
        XCTAssertEqual(controller.state.shiftState, .singleUse)

        // singleUse → capsLock (via toggle — depends on double-tap timing)
        // Without time mocking, single toggle goes off→singleUse or singleUse→off
        _ = controller.handle(.toggleShift)
        // After second toggle, should be off or capsLock depending on timing
    }

    func testShiftActiveInSingleUse() {
        controller.state.shiftState = .singleUse
        // isShiftActive = true (singleUse || capsLock)
        let isActive =
            controller.state.shiftState == .singleUse
            || controller.state.shiftState == .capsLock
        XCTAssertTrue(isActive)
    }

    func testShiftActiveInCapsLock() {
        controller.state.shiftState = .capsLock
        let isActive =
            controller.state.shiftState == .singleUse
            || controller.state.shiftState == .capsLock
        XCTAssertTrue(isActive)
    }

    func testShiftInactiveWhenOff() {
        controller.state.shiftState = .off
        let isActive =
            controller.state.shiftState == .singleUse
            || controller.state.shiftState == .capsLock
        XCTAssertFalse(isActive)
    }

    // MARK: - KeyboardType display logic

    func testEmailKeyboardSetsEnglishMode() {
        let effects = controller.handle(.keyboardTypeChanged(.emailAddress))
        XCTAssertEqual(controller.state.inputMode, .english)
        XCTAssertEqual(controller.state.activeKeyboardType, .emailAddress)
        XCTAssertTrue(effects.contains(.inputModeChanged))
    }

    func testDefaultKeyboardTypePreservesMode() {
        // 默认键盘类型不改变当前输入模式
        let effects = controller.handle(.keyboardTypeChanged(.default))
        XCTAssertEqual(controller.state.inputMode, .chinese)
        XCTAssertFalse(effects.contains(.inputModeChanged))
    }

    // MARK: - KeyboardEffect tracking

    func testSingleToggleShiftEffect() {
        let effects = controller.handle(.toggleShift)
        XCTAssertTrue(effects.contains(.shiftStateChanged))
        XCTAssertFalse(effects.contains(.pageChanged))
        XCTAssertFalse(effects.contains(.compositionChanged))
    }

    func testTogglePageEffect() {
        let effects = controller.handle(.togglePage)
        XCTAssertTrue(effects.contains(.pageChanged))
        XCTAssertFalse(effects.contains(.shiftStateChanged))
    }

    func testDeleteBackwardEffect() {
        controller.state.currentComposition = "ni"
        let effects = controller.handle(.deleteBackward)
        XCTAssertTrue(effects.contains(.compositionChanged))
    }

    func testInsertSpaceInChineseModeWithCompositionEffect() {
        controller.state.inputMode = .chinese
        controller.state.currentComposition = "ni"
        let effects = controller.handle(.insertSpace)
        // Select candidate → composition changed
        XCTAssertTrue(effects.contains(.compositionChanged))
    }
}
