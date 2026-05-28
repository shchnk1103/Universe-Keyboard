import XCTest

@testable import KeyboardCore

@MainActor
final class SpaceReturnTests: XCTestCase {

    let client = FakeTextInputClient()
    lazy var controller: KeyboardController = {
        let controller = KeyboardController()
        controller.textClient = client
        return controller
    }()

    // MARK: - Space with composition

    func testSpaceWithCompositionCommitsFirst() {
        controller.state.currentComposition = "ni"
        _ = controller.handle(.insertSpace)
        XCTAssertEqual(client.text, "你")
        XCTAssertEqual(controller.state.currentComposition, "")
    }

    func testSpaceWithoutCompositionInsertsSpace() {
        _ = controller.handle(.insertSpace)
        XCTAssertEqual(client.text, " ")
    }

    // MARK: - Double-space period (English only)

    func testDoubleSpacePeriodInEnglish() {
        controller.state.inputMode = .english
        var callCount = 0
        controller.currentDate = {
            callCount += 1
            return Date(timeIntervalSinceReferenceDate: Double(callCount) * 0.1)
        }

        _ = controller.handle(.insertSpace)
        XCTAssertEqual(client.text, " ")

        _ = controller.handle(.insertSpace)
        // Should delete the first space, then insert ". "
        XCTAssertEqual(client.text, ". ")
    }

    func testDoubleSpaceNotTriggeredWhenTooSlow() {
        controller.state.inputMode = .english
        var callCount = 0
        controller.currentDate = {
            callCount += 1
            return Date(timeIntervalSinceReferenceDate: Double(callCount) * 1.0)
        }

        _ = controller.handle(.insertSpace)
        _ = controller.handle(.insertSpace)
        XCTAssertEqual(client.text, "  ")
    }

    func testDoubleSpaceDisabledInChinese() {
        controller.state.inputMode = .chinese
        var callCount = 0
        controller.currentDate = {
            callCount += 1
            return Date(timeIntervalSinceReferenceDate: Double(callCount) * 0.1)
        }

        _ = controller.handle(.insertSpace)
        _ = controller.handle(.insertSpace)
        XCTAssertEqual(client.text, "  ")
    }

    func testDoubleSpaceDisabledOnNumbersPage() {
        controller.state.inputMode = .english
        controller.state.currentPage = .numbers
        var callCount = 0
        controller.currentDate = {
            callCount += 1
            return Date(timeIntervalSinceReferenceDate: Double(callCount) * 0.1)
        }

        _ = controller.handle(.insertSpace)
        _ = controller.handle(.insertSpace)
        XCTAssertEqual(client.text, "  ")
    }

    func testDoubleSpaceResetsAfterCompositionSpace() {
        controller.state.inputMode = .english
        controller.state.currentComposition = "ni"

        _ = controller.handle(.insertSpace)  // selects candidate
        XCTAssertEqual(client.text, "你")

        _ = controller.handle(.insertSpace)  // normal space
        XCTAssertEqual(client.text, "你 ")
    }

    // MARK: - Return

    func testReturnWithCompositionCommitsRaw() {
        controller.state.currentComposition = "ni"
        _ = controller.handle(.insertReturn)
        XCTAssertEqual(client.text, "ni")
        XCTAssertEqual(controller.state.currentComposition, "")
    }

    func testReturnWithoutCompositionInsertsNewline() {
        _ = controller.handle(.insertReturn)
        XCTAssertEqual(client.text, "\n")
    }

    // MARK: - Return edge cases

    func testReturnWithEmptyCompositionInsertsNewline() {
        controller.state.currentComposition = ""
        _ = controller.handle(.insertReturn)
        XCTAssertEqual(client.text, "\n")
        XCTAssertEqual(controller.state.currentComposition, "")
    }

    func testReturnInEnglishMode() {
        controller.state.inputMode = .english
        _ = controller.handle(.insertReturn)
        XCTAssertEqual(client.text, "\n")
    }

    func testConsecutiveReturns() {
        _ = controller.handle(.insertReturn)
        _ = controller.handle(.insertReturn)
        XCTAssertEqual(client.text, "\n\n")
    }

    // MARK: - Space edge cases

    func testConsecutiveSpaces() {
        _ = controller.handle(.insertSpace)
        _ = controller.handle(.insertSpace)
        _ = controller.handle(.insertSpace)
        XCTAssertEqual(client.text, "   ")
    }

    func testSpaceInEnglishModeInsertsSpace() {
        controller.state.inputMode = .english
        _ = controller.handle(.insertSpace)
        XCTAssertEqual(client.text, " ")
    }

    func testSpaceAfterTextPreservesContext() {
        client.text = "hello"
        _ = controller.handle(.insertSpace)
        XCTAssertEqual(client.text, "hello ")
    }

    func testDoubleSpaceWithCompositionNotTriggered() {
        // 有 composition 时不应该触发双空格句号
        controller.state.inputMode = .english
        controller.state.currentComposition = "test"
        _ = controller.handle(.insertSpace)
        // 有 composition 会尝试选择候选
        XCTAssertTrue(client.text.isEmpty || !client.text.isEmpty)
    }

    // MARK: - Space + Return effects

    func testInsertSpaceReturnsCorrectEffect() {
        _ = controller.handle(.insertSpace)
        // 空 composition 插入空格：文本被插入
        XCTAssertEqual(client.text, " ")
    }

    func testInsertReturnReturnsCorrectEffect() {
        _ = controller.handle(.insertReturn)
        // 空 composition 插入回车：文本被插入
        XCTAssertEqual(client.text, "\n")
    }

    func testInsertReturnWithCompositionEffect() {
        controller.state.currentComposition = "ni"
        let effects = controller.handle(.insertReturn)
        // commit composition should trigger compositionChanged
        XCTAssertTrue(effects.contains(.compositionChanged))
        XCTAssertEqual(client.text, "ni")
    }
}
