import XCTest

@testable import KeyboardCore

final class TypingStatisticsClassifierTests: XCTestCase {
    func testClassifiesUserPerceivedGraphemesWithoutRetainingContent() {
        let delta = TypingStatisticsClassifier.classify("中Aé1， 😀\n")

        XCTAssertEqual(delta.committedGraphemeCount, 8)
        XCTAssertEqual(delta.cjkCharacterCount, 1)
        XCTAssertEqual(delta.latinLetterCount, 2)
        XCTAssertEqual(delta.digitCount, 1)
        XCTAssertEqual(delta.punctuationCount, 1)
        XCTAssertEqual(delta.whitespaceCount, 1)
        XCTAssertEqual(delta.newlineCount, 1)
        XCTAssertEqual(delta.emojiCount, 1)
        XCTAssertEqual(delta.otherCount, 0)
    }

    func testJoinedEmojiAndKeycapEachCountAsOneGrapheme() {
        let delta = TypingStatisticsClassifier.classify("👨‍👩‍👧‍👦1️⃣🇨🇳")

        XCTAssertEqual(delta.committedGraphemeCount, 3)
        XCTAssertEqual(delta.emojiCount, 3)
        XCTAssertEqual(delta.digitCount, 0)
    }

    func testCRLFCountsAsOneNewlineGrapheme() {
        let delta = TypingStatisticsClassifier.classify("\r\n")

        XCTAssertEqual(delta.committedGraphemeCount, 1)
        XCTAssertEqual(delta.newlineCount, 1)
    }

    func testUnknownSymbolUsesContentFreeOtherBucket() {
        let delta = TypingStatisticsClassifier.classify("€")

        XCTAssertEqual(delta.committedGraphemeCount, 1)
        XCTAssertEqual(delta.otherCount, 1)
    }
}

@MainActor
final class CommittedTextObservationTests: XCTestCase {
    func testDirectEnglishKeyEmitsOneEventAfterInsertion() {
        let client = FakeTextInputClient()
        let controller = KeyboardController()
        controller.textClient = client
        controller.state.inputMode = .english
        var events: [CommittedTextEvent] = []
        controller.onCommittedText = { events.append($0) }

        _ = controller.handle(.insertKey("a"))

        XCTAssertEqual(client.text, "a")
        XCTAssertEqual(events, [CommittedTextEvent(text: "a", source: .key)])
    }

    func testMarkedTextUpdateDoesNotEmitUntilFinalCommit() {
        let client = FakeTextInputClient()
        let engine = FakeRimeEngine()
        let controller = KeyboardController()
        controller.textClient = client
        controller.rimeEngine = engine
        var events: [CommittedTextEvent] = []
        controller.onCommittedText = { events.append($0) }

        _ = controller.handle(.insertKey("n"))
        _ = controller.handle(.insertKey("i"))
        XCTAssertTrue(events.isEmpty)

        _ = controller.handle(.insertSpace)

        XCTAssertEqual(events, [CommittedTextEvent(text: "你", source: .space)])
    }

    func testDifferentMarkedTextFinalizationEmitsExactlyOnce() {
        let client = FakeTextInputClient()
        let engine = FakeRimeEngine(preeditFormatter: { $0 == "nih" ? "ni h" : $0 })
        let controller = KeyboardController()
        controller.textClient = client
        controller.rimeEngine = engine
        var events: [CommittedTextEvent] = []
        controller.onCommittedText = { events.append($0) }

        for character in "nih" {
            _ = controller.handle(.insertKey(String(character)))
        }
        _ = controller.handle(.insertReturn)

        XCTAssertEqual(events, [CommittedTextEvent(text: "nih", source: .returnKey)])
    }

    func testVisibilityAbandonmentDoesNotEmit() {
        let client = FakeTextInputClient()
        let controller = KeyboardController()
        controller.textClient = client
        controller.enableDefaultRimeEngine()
        var events: [CommittedTextEvent] = []
        controller.onCommittedText = { events.append($0) }

        _ = controller.handle(.insertKey("n"))
        _ = controller.abandonCompositionForVisibilityChange()

        XCTAssertTrue(events.isEmpty)
    }

    func testMissingTextClientDoesNotReportACommit() {
        let controller = KeyboardController()
        controller.state.inputMode = .english
        var events: [CommittedTextEvent] = []
        controller.onCommittedText = { events.append($0) }

        _ = controller.handle(.insertKey("a"))

        XCTAssertTrue(events.isEmpty)
    }

    func testEmojiUsesCoreCommitPathAndSource() {
        let client = FakeTextInputClient()
        let controller = KeyboardController()
        controller.textClient = client
        var events: [CommittedTextEvent] = []
        controller.onCommittedText = { events.append($0) }

        _ = controller.handle(.insertEmoji("😀"))

        XCTAssertEqual(client.text, "😀")
        XCTAssertEqual(events, [CommittedTextEvent(text: "😀", source: .emoji)])
    }
}
