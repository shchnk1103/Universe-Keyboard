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

    func testSymbolsToLettersPage() {
        controller.state.currentPage = .symbols
        let effects = controller.handle(.togglePage)
        XCTAssertEqual(controller.state.currentPage, .letters)
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
        // symbols → letters
        _ = controller.handle(.togglePage)
        XCTAssertEqual(controller.state.currentPage, .letters)
    }

    // MARK: - Shift survives round-trips

    func testShiftSurvivesLettersToSymbols() {
        controller.state.inputMode = .english
        _ = controller.handle(.togglePage) // letters → numbers
        _ = controller.handle(.togglePage) // numbers → symbols
        _ = controller.handle(.togglePage) // symbols → letters
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
}
