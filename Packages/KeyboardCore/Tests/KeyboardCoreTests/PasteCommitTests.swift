import XCTest

@testable import KeyboardCore

@MainActor
final class PasteCommitTests: XCTestCase {
    func testPasteClearsContinuationAndDeleteHistoryWithoutCommitEvent() {
        let client = FakeTextInputClient()
        let controller = KeyboardController()
        controller.textClient = client
        controller.state.continuation = ContinuationState(context: "甲", suggestions: ["好"])
        controller.t9UnconfirmedDeleteHistory.spellings["426"] = "hao"
        let engine = FakeRimeEngine()
        controller.rimeEngine = engine
        var events = 0
        controller.onCommittedText = { _ in events += 1 }

        XCTAssertEqual(controller.commitPastedPlainText("乙"), .inserted)
        XCTAssertEqual(client.text, "乙")
        XCTAssertTrue(controller.state.continuation.context.isEmpty)
        XCTAssertTrue(controller.state.continuation.suggestions.isEmpty)
        XCTAssertTrue(controller.t9UnconfirmedDeleteHistory.spellings.isEmpty)
        XCTAssertEqual(events, 0)
        XCTAssertEqual(engine.processKeyCallCount, 0)
        _ = controller.handle(.insertDirectText("丙"))
        XCTAssertEqual(controller.state.continuation.context, "丙")
    }

    func testRejectedPastePreservesState() {
        let client = FakeTextInputClient()
        let controller = KeyboardController()
        controller.textClient = client
        controller.state.continuation = ContinuationState(context: "甲", suggestions: ["好"])
        controller.t9UnconfirmedDeleteHistory.spellings["426"] = "hao"
        XCTAssertEqual(controller.commitPastedPlainText(""), .rejectedEmpty)
        controller.state.currentComposition = "ni"
        XCTAssertEqual(controller.commitPastedPlainText("乙"), .rejectedNotIdle)
        XCTAssertTrue(client.text.isEmpty)
        XCTAssertEqual(controller.state.continuation.context, "甲")
        XCTAssertEqual(controller.t9UnconfirmedDeleteHistory.spellings["426"], "hao")
        controller.state.currentComposition = ""
        controller.textClient = nil
        controller.t9UnconfirmedDeleteHistory.spellings["426"] = "hao"
        XCTAssertEqual(controller.commitPastedPlainText("乙"), .rejectedNoClient)
        XCTAssertEqual(controller.state.continuation.context, "甲")
        XCTAssertEqual(controller.t9UnconfirmedDeleteHistory.spellings["426"], "hao")
    }
}

@MainActor
private final class ReentrantPasteClient: TextInputClient {
    var onInsert: (() -> Void)?
    var inserted: [String] = []
    var hasTextBeforeInput: Bool { false }
    func insertText(_ text: String) {
        inserted.append(text)
        onInsert?()
    }
    func deleteBackward() {}
    func adjustTextPosition(byCharacterOffset offset: Int) {}
    func setMarkedText(_ text: String, selectedRange: Range<Int>) {}
    func unmarkText() {}
}

extension PasteCommitTests {
    func testOwnedMutationPreservesRecoveryDuringSynchronousHostCallback() {
        let client = ReentrantPasteClient()
        let controller = KeyboardController()
        controller.textClient = client
        let owner = UUID()
        controller.partialCommitFailureRecovery = .init(ownerID: owner, editingGeneration: 42)
        client.onInsert = {
            XCTAssertTrue(controller.isPerformingOwnedHostMutation)
            _ = controller.noteExternalDocumentChange()
        }

        XCTAssertEqual(controller.commitPastedPlainText("乙"), .inserted)
        XCTAssertEqual(client.inserted, ["乙"])
        XCTAssertEqual(controller.partialCommitFailureRecovery?.ownerID, owner)
        XCTAssertEqual(controller.partialCommitFailureRecovery?.editingGeneration, 42)
        XCTAssertEqual(controller.partialCommitFailureRecovery?.phase, .blockedRemainder)
        XCTAssertEqual(controller.partialCommitFailureRecovery?.hostBindingValid, true)
    }
}
