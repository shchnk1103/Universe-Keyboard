import XCTest
@testable import KeyboardCore

final class InputModeTests: XCTestCase {

    var controller: KeyboardController!
    var client: FakeTextInputClient!

    override func setUp() {
        super.setUp()
        client = FakeTextInputClient()
        controller = KeyboardController()
        controller.textClient = client
    }

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
}
