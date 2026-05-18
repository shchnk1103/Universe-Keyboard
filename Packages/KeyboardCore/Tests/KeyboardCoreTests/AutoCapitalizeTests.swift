import XCTest
@testable import KeyboardCore

final class AutoCapitalizeTests: XCTestCase {

    var controller: KeyboardController!
    var client: FakeTextInputClient!

    override func setUp() {
        super.setUp()
        client = FakeTextInputClient()
        controller = KeyboardController()
        controller.textClient = client
    }

    // MARK: - shouldAutoCapitalize

    func testNilContextShouldCapitalize() {
        XCTAssertTrue(controller.shouldAutoCapitalize(contextBeforeInput: nil))
    }

    func testEmptyContextShouldCapitalize() {
        XCTAssertTrue(controller.shouldAutoCapitalize(contextBeforeInput: ""))
    }

    func testPeriodFollowedBySpaceTriggersCapitalize() {
        XCTAssertTrue(controller.shouldAutoCapitalize(contextBeforeInput: "hello. "))
    }

    func testExclamationTriggersCapitalize() {
        XCTAssertTrue(controller.shouldAutoCapitalize(contextBeforeInput: "wow! "))
    }

    func testQuestionTriggersCapitalize() {
        XCTAssertTrue(controller.shouldAutoCapitalize(contextBeforeInput: "really? "))
    }

    func testChinesePeriodTriggersCapitalize() {
        XCTAssertTrue(controller.shouldAutoCapitalize(contextBeforeInput: "你好。"))
    }

    func testChineseExclamationTriggersCapitalize() {
        XCTAssertTrue(controller.shouldAutoCapitalize(contextBeforeInput: "太棒了！"))
    }

    func testChineseQuestionTriggersCapitalize() {
        XCTAssertTrue(controller.shouldAutoCapitalize(contextBeforeInput: "为什么？"))
    }

    func testMidSentenceDoesNotCapitalize() {
        XCTAssertFalse(controller.shouldAutoCapitalize(contextBeforeInput: "hello wo"))
    }

    func testCommaDoesNotCapitalize() {
        XCTAssertFalse(controller.shouldAutoCapitalize(contextBeforeInput: "hello, "))
    }

    func testWhitespaceOnlyContextCapitalizes() {
        XCTAssertTrue(controller.shouldAutoCapitalize(contextBeforeInput: "   "))
    }

    func testNewlineAfterPeriodTriggersCapitalize() {
        XCTAssertTrue(controller.shouldAutoCapitalize(contextBeforeInput: "done.\n"))
    }

    // MARK: - applyAutoCapitalization

    func testApplyAutoCapSetsSingleUseWhenAtSentenceStart() {
        controller.state.inputMode = .english
        let effect = controller.applyAutoCapitalization(contextBeforeInput: nil)
        XCTAssertEqual(controller.state.shiftState, .singleUse)
        XCTAssertTrue(effect.contains(.shiftStateChanged))
    }

    func testApplyAutoCapDoesNothingInChineseMode() {
        controller.state.inputMode = .chinese
        let effect = controller.applyAutoCapitalization(contextBeforeInput: nil)
        XCTAssertEqual(controller.state.shiftState, .off)
        XCTAssertEqual(effect, [])
    }

    func testApplyAutoCapDoesNotOverrideCapsLock() {
        controller.state.inputMode = .english
        controller.state.shiftState = .capsLock
        let effect = controller.applyAutoCapitalization(contextBeforeInput: nil)
        XCTAssertEqual(controller.state.shiftState, .capsLock)
        XCTAssertEqual(effect, [])
    }

    func testApplyAutoCapDoesNotOverrideExistingSingleUse() {
        controller.state.inputMode = .english
        controller.state.shiftState = .singleUse
        let effect = controller.applyAutoCapitalization(contextBeforeInput: nil)
        XCTAssertEqual(controller.state.shiftState, .singleUse)
        XCTAssertEqual(effect, [])
    }

    func testApplyAutoCapDoesNothingMidSentence() {
        controller.state.inputMode = .english
        let effect = controller.applyAutoCapitalization(contextBeforeInput: "hello ")
        XCTAssertEqual(controller.state.shiftState, .off)
        XCTAssertEqual(effect, [])
    }

    // MARK: - Integration: auto-cap consumed by typing

    func testAutoCappedCharacterConsumedAndInsertsUppercase() {
        controller.state.inputMode = .english
        _ = controller.applyAutoCapitalization(contextBeforeInput: nil)
        XCTAssertEqual(controller.state.shiftState, .singleUse)

        // In the real app the button title is already "H" because displayTitle(for:)
        // reads the shift state. So the action receives "H", not "h".
        let effects = controller.handle(.insertKey("H"))
        XCTAssertEqual(client.text, "H")
        XCTAssertEqual(controller.state.shiftState, .off)
        XCTAssertTrue(effects.contains(.shiftStateChanged))
    }

    // MARK: - isSentenceTerminator

    func testPeriodIsSentenceTerminator() {
        XCTAssertTrue(KeyboardController.isSentenceTerminator("."))
    }

    func testExclamationIsSentenceTerminator() {
        XCTAssertTrue(KeyboardController.isSentenceTerminator("!"))
    }

    func testQuestionIsSentenceTerminator() {
        XCTAssertTrue(KeyboardController.isSentenceTerminator("?"))
    }

    func testLetterIsNotSentenceTerminator() {
        XCTAssertFalse(KeyboardController.isSentenceTerminator("h"))
    }

    func testMultiCharIsNotSentenceTerminator() {
        XCTAssertFalse(KeyboardController.isSentenceTerminator(".com"))
    }

    // MARK: - English sentence terminator triggers auto-cap on insert

    func testEnglishPeriodInsertTriggersAutoCap() {
        controller.state.inputMode = .english
        let effects = controller.handle(.insertKey("."))
        XCTAssertEqual(controller.state.shiftState, .singleUse)
        XCTAssertTrue(effects.contains(.shiftStateChanged))
    }

    func testEnglishPeriodInsertOnNumbersPageTriggersAutoCap() {
        controller.state.inputMode = .english
        controller.state.currentPage = .numbers
        let effects = controller.handle(.insertKey("."))
        XCTAssertEqual(controller.state.shiftState, .singleUse)
    }

    func testChineseModePunctuationDoesNotTriggerAutoCap() {
        controller.state.inputMode = .chinese
        _ = controller.handle(.insertKey("."))
        XCTAssertEqual(controller.state.shiftState, .off)
    }

    // MARK: - Edge cases

    func testAutoCapAfterEmoji() {
        // emoji 不是句尾标点，不应触发自动大写
        XCTAssertFalse(controller.shouldAutoCapitalize(contextBeforeInput: "hello 😊"))
    }

    func testAutoCapAfterMixedPunctuation() {
        // 多标点后应触发自动大写
        XCTAssertTrue(controller.shouldAutoCapitalize(contextBeforeInput: "hello..."))
    }

    func testAutoCapOnEmptyDocumentAfterDelete() {
        // 空/nil 上下文应触发自动大写
        XCTAssertTrue(controller.shouldAutoCapitalize(contextBeforeInput: nil))
        XCTAssertTrue(controller.shouldAutoCapitalize(contextBeforeInput: ""))
    }
}
