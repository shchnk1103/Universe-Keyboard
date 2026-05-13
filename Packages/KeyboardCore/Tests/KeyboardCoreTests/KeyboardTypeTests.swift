import XCTest
@testable import KeyboardCore

final class KeyboardTypeTests: XCTestCase {

    var controller: KeyboardController!
    var client: FakeTextInputClient!

    override func setUp() {
        super.setUp()
        client = FakeTextInputClient()
        controller = KeyboardController()
        controller.textClient = client
    }

    func testEmailTypeSwitchesToEnglish() {
        let effects = controller.handle(.keyboardTypeChanged(.emailAddress))
        XCTAssertEqual(controller.state.inputMode, .english)
        XCTAssertTrue(effects.contains(.inputModeChanged))
    }

    func testURLTypeSwitchesToEnglish() {
        _ = controller.handle(.keyboardTypeChanged(.URL))
        XCTAssertEqual(controller.state.inputMode, .english)
    }

    func testWebSearchTypeSwitchesToEnglish() {
        _ = controller.handle(.keyboardTypeChanged(.webSearch))
        XCTAssertEqual(controller.state.inputMode, .english)
    }

    func testDefaultTypeDoesNotChangeMode() {
        let effects = controller.handle(.keyboardTypeChanged(.default))
        XCTAssertEqual(controller.state.inputMode, .chinese)
        XCTAssertFalse(effects.contains(.inputModeChanged))
    }

    func testKeyboardTypeChangeCommitsComposition() {
        controller.state.currentComposition = "ni"
        let effects = controller.handle(.keyboardTypeChanged(.emailAddress))
        XCTAssertEqual(client.text, "ni")
        XCTAssertEqual(controller.state.currentComposition, "")
        XCTAssertTrue(effects.contains(.compositionChanged))
    }

    func testSameKeyboardTypeIsNoOp() {
        let effects = controller.handle(.keyboardTypeChanged(.default))
        XCTAssertEqual(effects, [])
    }
}
