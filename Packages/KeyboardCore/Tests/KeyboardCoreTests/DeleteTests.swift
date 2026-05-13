import XCTest
@testable import KeyboardCore

final class DeleteTests: XCTestCase {

    var controller: KeyboardController!
    var client: FakeTextInputClient!

    override func setUp() {
        super.setUp()
        client = FakeTextInputClient()
        controller = KeyboardController()
        controller.textClient = client
    }

    func testDeleteFromCompositionFirst() {
        controller.state.currentComposition = "nihao"
        _ = controller.handle(.deleteBackward)
        XCTAssertEqual(controller.state.currentComposition, "niha")
    }

    func testDeleteLastCharOfComposition() {
        controller.state.currentComposition = "n"
        _ = controller.handle(.deleteBackward)
        XCTAssertEqual(controller.state.currentComposition, "")
    }

    func testDeleteEmptyCompositionHitsProxy() {
        controller.state.currentComposition = ""
        client.text = "hello"
        _ = controller.handle(.deleteBackward)
        XCTAssertEqual(client.text, "hell")
    }

    func testDeleteWhenBothEmpty() {
        _ = controller.handle(.deleteBackward)
        XCTAssertEqual(controller.state.currentComposition, "")
        XCTAssertEqual(client.text, "")
    }

    func testCompositionDeleteSequence() {
        // Type "ni"
        controller.state.currentComposition = "ni"
        // Delete once → "n"
        _ = controller.handle(.deleteBackward)
        XCTAssertEqual(controller.state.currentComposition, "n")
        // Delete again → ""
        _ = controller.handle(.deleteBackward)
        XCTAssertEqual(controller.state.currentComposition, "")
        // Delete again → hits proxy
        client.text = "abc"
        _ = controller.handle(.deleteBackward)
        XCTAssertEqual(client.text, "ab")
    }
}
