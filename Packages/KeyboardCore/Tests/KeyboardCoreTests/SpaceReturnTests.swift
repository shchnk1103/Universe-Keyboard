import XCTest
@testable import KeyboardCore

final class SpaceReturnTests: XCTestCase {

    var controller: KeyboardController!
    var client: FakeTextInputClient!

    override func setUp() {
        super.setUp()
        client = FakeTextInputClient()
        controller = KeyboardController()
        controller.textClient = client
    }

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

        _ = controller.handle(.insertSpace) // selects candidate
        XCTAssertEqual(client.text, "你")

        _ = controller.handle(.insertSpace) // normal space
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
}
