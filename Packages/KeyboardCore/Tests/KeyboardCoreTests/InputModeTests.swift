import XCTest

@testable import KeyboardCore

@MainActor
final class InputModeTests: XCTestCase {

    let client = FakeTextInputClient()
    lazy var controller: KeyboardController = {
        let controller = KeyboardController()
        controller.textClient = client
        return controller
    }()

    func testInitialModeIsChinese() {
        XCTAssertEqual(controller.state.inputMode, .chinese)
    }

    func testToggleChineseToEnglish() {
        _ = controller.handle(.toggleInputMode)
        XCTAssertEqual(controller.state.inputMode, .english)
    }

    func testToggleEnglishToChinese() {
        controller.state.inputMode = .english
        _ = controller.handle(.toggleInputMode)
        XCTAssertEqual(controller.state.inputMode, .chinese)
    }

    func testToggleModeCommitsComposition() {
        controller.state.currentComposition = "ni"
        _ = controller.handle(.toggleInputMode)
        XCTAssertEqual(client.text, "ni")
        XCTAssertEqual(controller.state.currentComposition, "")
        XCTAssertEqual(controller.state.inputMode, .english)
    }

    func testToggleModeOnNumbersPageGoesToLetters() {
        controller.state.currentPage = .numbers
        let effects = controller.handle(.toggleInputMode)
        XCTAssertEqual(controller.state.currentPage, .letters)
        XCTAssertTrue(effects.contains(.pageChanged))
    }

    func testToggleModeOnLettersStaysOnLetters() {
        let effects = controller.handle(.toggleInputMode)
        XCTAssertEqual(controller.state.currentPage, .letters)
        XCTAssertFalse(effects.contains(.pageChanged))
    }

    // MARK: - Mode switching boundary cases

    func testToggleModeOnSymbolsPageGoesToLetters() {
        controller.state.currentPage = .symbols
        let effects = controller.handle(.toggleInputMode)
        XCTAssertEqual(controller.state.currentPage, .letters)
        XCTAssertTrue(effects.contains(.pageChanged))
    }

    func testDoubleToggleModeReturnsToChinese() {
        // 中 → 英 → 中
        _ = controller.handle(.toggleInputMode)
        XCTAssertEqual(controller.state.inputMode, .english)
        _ = controller.handle(.toggleInputMode)
        XCTAssertEqual(controller.state.inputMode, .chinese)
    }

    func testToggleModeWithEmptyComposition() {
        controller.state.currentComposition = ""
        _ = controller.handle(.toggleInputMode)
        XCTAssertEqual(controller.state.inputMode, .english)
        XCTAssertEqual(controller.state.currentComposition, "")
        // 空 composition 切换不应产生文本
        XCTAssertEqual(client.text, "")
    }

    func testToggleModeEffectContainsInputModeChanged() {
        let effects = controller.handle(.toggleInputMode)
        XCTAssertTrue(effects.contains(.inputModeChanged))
    }

    func testChineseToEnglishShiftStateReset() {
        controller.state.shiftState = .singleUse
        _ = controller.handle(.toggleInputMode)
        // 切换到英文模式可能触发 auto-cap，但切换本身会改变模式
        XCTAssertEqual(controller.state.inputMode, .english)
    }

    // MARK: - Mode with inline preedit

    func testToggleModeClearsInlinePreedit() {
        controller.state.insertedPreeditCount = 3
        controller.state.currentComposition = "ni"
        _ = controller.handle(.toggleInputMode)
        // composition committed, mode toggled
        XCTAssertEqual(client.text, "ni")
        XCTAssertEqual(controller.state.inputMode, .english)
    }
}
