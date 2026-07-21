import XCTest

@testable import KeyboardCore

@MainActor
final class KaomojiDirectTextRegressionTests: XCTestCase {
    func testKaomojiDirectTextInsertsExactTextWithoutComposition() {
        let client = FakeTextInputClient()
        let controller = KeyboardController()
        controller.textClient = client
        var events: [CommittedTextEvent] = []
        controller.onCommittedText = { events.append($0) }

        let effects = controller.handle(.insertDirectText("^_^"))

        XCTAssertEqual(client.text, "^_^")
        XCTAssertEqual(client.markedText, "")
        XCTAssertEqual(controller.state.currentComposition, "")
        XCTAssertEqual(events, [CommittedTextEvent(text: "^_^", source: .directText)])
        XCTAssertTrue(effects.contains(.continuationChanged))
        XCTAssertFalse(effects.contains(.compositionChanged))
    }

    func testKaomojiDirectTextFinalizesCompositionBeforeExactInsertion() {
        let client = FakeTextInputClient()
        let engine = FakeRimeEngine()
        let controller = KeyboardController()
        controller.textClient = client
        controller.rimeEngine = engine
        var events: [CommittedTextEvent] = []
        controller.onCommittedText = { events.append($0) }

        _ = controller.handle(.insertKey("n"))
        _ = controller.handle(.insertKey("i"))
        XCTAssertEqual(client.markedText, "ni")

        let effects = controller.handle(.insertDirectText("^_^"))

        XCTAssertEqual(client.text, "ni^_^")
        XCTAssertEqual(client.markedText, "")
        XCTAssertEqual(controller.state.currentComposition, "")
        XCTAssertNil(controller.state.lastRimeOutput)
        XCTAssertEqual(engine.sessionResetCount, 1)
        XCTAssertEqual(
            events,
            [
                CommittedTextEvent(text: "ni", source: .compositionFinalization),
                CommittedTextEvent(text: "^_^", source: .directText),
            ]
        )
        XCTAssertTrue(effects.contains(.compositionChanged))
        XCTAssertTrue(effects.contains(.continuationChanged))
    }
}
