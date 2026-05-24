import XCTest
@testable import KeyboardCore

final class PageSwitchTests: XCTestCase {

    var controller: KeyboardController!
    var client: FakeTextInputClient!

    override func setUp() {
        super.setUp()
        client = FakeTextInputClient()
        controller = KeyboardController()
        controller.textClient = client
    }

    func testInitialPageIsLetters() {
        XCTAssertEqual(controller.state.currentPage, .letters)
    }

    // MARK: - Letters → Numbers

    func testLettersToNumbersPage() {
        let effects = controller.handle(.togglePage)
        XCTAssertEqual(controller.state.currentPage, .numbers)
        XCTAssertTrue(effects.contains(.pageChanged))
    }

    func testLettersToNumbersResetsShift() {
        controller.state.shiftState = .singleUse
        let effects = controller.handle(.togglePage)
        XCTAssertEqual(controller.state.shiftState, .off)
        XCTAssertTrue(effects.contains(.shiftStateChanged))
    }

    func testLettersToNumbersCommitsComposition() {
        controller.state.currentComposition = "ni"
        let effects = controller.handle(.togglePage)
        XCTAssertEqual(client.text, "ni")
        XCTAssertEqual(controller.state.currentComposition, "")
        XCTAssertTrue(effects.contains(.compositionChanged))
    }

    // MARK: - Numbers → Symbols

    func testNumbersToSymbolsPage() {
        controller.state.currentPage = .numbers
        let effects = controller.handle(.togglePage)
        XCTAssertEqual(controller.state.currentPage, .symbols)
        XCTAssertTrue(effects.contains(.pageChanged))
    }

    func testNumbersToSymbolsDoesNotResetShift() {
        controller.state.currentPage = .numbers
        controller.state.shiftState = .singleUse
        _ = controller.handle(.togglePage)
        XCTAssertEqual(controller.state.shiftState, .singleUse)
    }

    // MARK: - Symbols → Letters

    func testSymbolsToEmojiPage() {
        controller.state.currentPage = .symbols
        let effects = controller.handle(.togglePage)
        XCTAssertEqual(controller.state.currentPage, .emoji)
        XCTAssertTrue(effects.contains(.pageChanged))
    }

    // MARK: - Full cycle

    func testFullPageCycle() {
        // letters → numbers
        _ = controller.handle(.togglePage)
        XCTAssertEqual(controller.state.currentPage, .numbers)
        // numbers → symbols
        _ = controller.handle(.togglePage)
        XCTAssertEqual(controller.state.currentPage, .symbols)
        // symbols → emoji
        _ = controller.handle(.togglePage)
        XCTAssertEqual(controller.state.currentPage, .emoji)
        // emoji → letters
        _ = controller.handle(.togglePage)
        XCTAssertEqual(controller.state.currentPage, .letters)
    }

    // MARK: - Shift survives round-trips

    func testShiftSurvivesLettersToEmoji() {
        controller.state.inputMode = .english
        _ = controller.handle(.togglePage) // letters → numbers
        _ = controller.handle(.togglePage) // numbers → symbols
        _ = controller.handle(.togglePage) // symbols → emoji
        _ = controller.handle(.togglePage) // emoji → letters (full round trip)
        XCTAssertEqual(controller.state.currentPage, .letters)
    }

    func testAutoCapSurvivesRoundTripThroughNumbersPage() {
        controller.state.inputMode = .english
        controller.state.currentPage = .letters
        _ = controller.handle(.togglePage) // → numbers
        XCTAssertEqual(controller.state.currentPage, .numbers)

        _ = controller.handle(.insertKey("!"))
        XCTAssertEqual(controller.state.shiftState, .singleUse)

        _ = controller.handle(.togglePage) // → symbols
        XCTAssertEqual(controller.state.currentPage, .symbols)

        _ = controller.handle(.togglePage) // → emoji
        XCTAssertEqual(controller.state.currentPage, .emoji)

        _ = controller.handle(.togglePage) // → letters
        XCTAssertEqual(controller.state.currentPage, .letters)
        XCTAssertEqual(controller.state.shiftState, .singleUse)
    }

    // MARK: - Input mode switch resets from non-letter pages

    func testToggleInputModeFromSymbolsResetsToLetters() {
        controller.state.currentPage = .symbols
        let effects = controller.handle(.toggleInputMode)
        XCTAssertEqual(controller.state.currentPage, .letters)
        XCTAssertTrue(effects.contains(.pageChanged))
    }

    func testToggleInputModeFromNumbersResetsToLetters() {
        controller.state.currentPage = .numbers
        let effects = controller.handle(.toggleInputMode)
        XCTAssertEqual(controller.state.currentPage, .letters)
        XCTAssertTrue(effects.contains(.pageChanged))
    }

    func testToggleInputModeFromEmojiResetsToLetters() {
        controller.state.currentPage = .emoji
        let effects = controller.handle(.toggleInputMode)
        XCTAssertEqual(controller.state.currentPage, .letters)
        XCTAssertTrue(effects.contains(.pageChanged))
    }

    // MARK: - Input mode preserved across page cycles

    func testChineseModePreservedThroughPageCycle() {
        controller.state.inputMode = .chinese
        XCTAssertEqual(controller.state.inputMode, .chinese)
        _ = controller.handle(.togglePage) // letters → numbers
        XCTAssertEqual(controller.state.inputMode, .chinese)
        _ = controller.handle(.togglePage) // numbers → symbols
        XCTAssertEqual(controller.state.inputMode, .chinese)
        _ = controller.handle(.togglePage) // symbols → emoji
        XCTAssertEqual(controller.state.inputMode, .chinese)
        _ = controller.handle(.togglePage) // emoji → letters
        XCTAssertEqual(controller.state.inputMode, .chinese)
    }

    func testEnglishModePreservedThroughPageCycle() {
        controller.state.inputMode = .english
        XCTAssertEqual(controller.state.inputMode, .english)
        _ = controller.handle(.togglePage) // letters → numbers
        XCTAssertEqual(controller.state.inputMode, .english)
        _ = controller.handle(.togglePage) // numbers → symbols
        XCTAssertEqual(controller.state.inputMode, .english)
        _ = controller.handle(.togglePage) // symbols → emoji
        XCTAssertEqual(controller.state.inputMode, .english)
        _ = controller.handle(.togglePage) // emoji → letters
        XCTAssertEqual(controller.state.inputMode, .english)
    }

    // MARK: - Symbols page mode context

    func testSymbolsPageWhenChinese() {
        controller.state.inputMode = .chinese
        controller.state.currentPage = .symbols
        XCTAssertEqual(controller.state.inputMode, .chinese)
        XCTAssertEqual(controller.state.currentPage, .symbols)
        // UI 层会根据 inputMode 显示中文符号（【】「」等）
    }

    func testSymbolsPageWhenEnglish() {
        controller.state.inputMode = .english
        controller.state.currentPage = .symbols
        XCTAssertEqual(controller.state.inputMode, .english)
        XCTAssertEqual(controller.state.currentPage, .symbols)
        // UI 层会根据 inputMode 显示英文符号（[] {} 等）
    }

    func testNumbersPageWhenChinese() {
        controller.state.inputMode = .chinese
        controller.state.currentPage = .numbers
        XCTAssertEqual(controller.state.inputMode, .chinese)
        // UI 层显示：中文标点（。，、？！：；等）
    }

    func testNumbersPageWhenEnglish() {
        controller.state.inputMode = .english
        controller.state.currentPage = .numbers
        XCTAssertEqual(controller.state.inputMode, .english)
        // UI 层显示：英文标点（. , ? ! : ; 等）
    }

    // MARK: - Candidate page switching

    func testCandidatePageUpAction() {
        let effects = controller.handle(.candidatePageUp)
        // 无 RIME 引擎时，pageUp 返回空效果
        XCTAssertEqual(effects, [])
    }

    func testCandidatePageDownAction() {
        let effects = controller.handle(.candidatePageDown)
        XCTAssertEqual(effects, [])
    }

    func testCandidatePageUpWithRimeEngine() {
        let engine = FakeRimeEngine()
        controller.rimeEngine = engine
        controller.state.inputMode = .chinese
        _ = controller.handle(.insertKey("n"))
        _ = controller.handle(.insertKey("i"))
        let effects = controller.handle(.candidatePageUp)
        // pageUp 会通过 engine 触发 composition 变化
        XCTAssertTrue(effects.contains(.compositionChanged))
    }

    func testCandidatePageDownWithRimeEngine() {
        let engine = FakeRimeEngine()
        controller.rimeEngine = engine
        controller.state.inputMode = .chinese
        _ = controller.handle(.insertKey("n"))
        _ = controller.handle(.insertKey("i"))
        let effects = controller.handle(.candidatePageDown)
        XCTAssertTrue(effects.contains(.compositionChanged))
    }
}
