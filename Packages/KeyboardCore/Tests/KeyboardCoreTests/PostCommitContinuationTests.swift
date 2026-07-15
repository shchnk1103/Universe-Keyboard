import XCTest

@testable import KeyboardCore

final class ContinuationSuggestionProviderTests: XCTestCase {
    func testUsesLongestMatchingSuffix() {
        let provider = BundledContinuationSuggestionProvider(entries: [
            ContinuationEntry(context: "吃", suggestions: ["饭"]),
            ContinuationEntry(context: "吃了", suggestions: ["吗"]),
        ])

        XCTAssertEqual(provider.suggestions(for: "我们吃了", limit: 8), ["吗"])
    }

    func testDeduplicatesAndHonorsLimit() {
        let provider = BundledContinuationSuggestionProvider(entries: [
            ContinuationEntry(context: "好", suggestions: ["的", "的", "呀", "！"]),
        ])

        XCTAssertEqual(provider.suggestions(for: "好", limit: 2), ["的", "呀"])
    }

    func testEmptyAndUnknownContextReturnNoSuggestions() {
        let provider = BundledContinuationSuggestionProvider(entries: [
            ContinuationEntry(context: "今天", suggestions: ["天气"]),
        ])

        XCTAssertTrue(provider.suggestions(for: "", limit: 8).isEmpty)
        XCTAssertTrue(provider.suggestions(for: "明天", limit: 8).isEmpty)
        XCTAssertTrue(provider.suggestions(for: "今天", limit: 0).isEmpty)
    }

    func testBundledResourceContainsRepresentativeChain() {
        XCTAssertEqual(
            BundledContinuationSuggestionProvider.shared.suggestions(for: "吃了", limit: 8).first,
            "吗"
        )
        XCTAssertEqual(
            BundledContinuationSuggestionProvider.shared.suggestions(for: "吃了吗", limit: 8).first,
            "？"
        )
    }
}

@MainActor
final class PostCommitContinuationControllerTests: XCTestCase {
    private let provider = BundledContinuationSuggestionProvider(entries: [
        ContinuationEntry(context: "吃", suggestions: ["了"]),
        ContinuationEntry(context: "吃了", suggestions: ["吗", "饭"]),
        ContinuationEntry(context: "吃了吗", suggestions: ["？"]),
        ContinuationEntry(context: "好", suggestions: ["的"]),
    ])

    func testFinalCommitCreatesSuggestionsAndSelectionChainsExactlyOnce() {
        let client = FakeTextInputClient()
        let controller = makeController(client: client)
        var events: [CommittedTextEvent] = []
        controller.onCommittedText = { events.append($0) }

        let firstEffects = controller.handle(.insertDirectText("吃了"))

        XCTAssertEqual(client.text, "吃了")
        XCTAssertEqual(controller.state.continuation.context, "吃了")
        XCTAssertEqual(controller.state.continuation.suggestions, ["吗", "饭"])
        XCTAssertTrue(firstEffects.contains(.continuationChanged))

        let secondEffects = controller.handle(.insertCandidate("吗", kind: .continuationCandidate))

        XCTAssertEqual(client.text, "吃了吗")
        XCTAssertEqual(controller.state.continuation.context, "吃了吗")
        XCTAssertEqual(controller.state.continuation.suggestions, ["？"])
        XCTAssertTrue(secondEffects.contains(.continuationChanged))
        XCTAssertEqual(events, [
            CommittedTextEvent(text: "吃了", source: .directText),
            CommittedTextEvent(text: "吗", source: .candidate),
        ])
    }

    func testStaleContinuationCandidateIsIgnored() {
        let client = FakeTextInputClient()
        let controller = makeController(client: client)
        _ = controller.handle(.insertDirectText("吃了"))

        let effects = controller.handle(.insertCandidate("不存在", kind: .continuationCandidate))

        XCTAssertTrue(effects.isEmpty)
        XCTAssertEqual(client.text, "吃了")
    }

    func testStartingCompositionHidesAtPresentationBoundaryButPreservesContext() {
        let client = FakeTextInputClient()
        let controller = makeController(client: client)
        controller.enableDefaultRimeEngine()
        _ = controller.handle(.insertDirectText("吃了"))

        _ = controller.handle(.insertKey("n"))

        XCTAssertFalse(controller.state.currentComposition.isEmpty)
        XCTAssertEqual(controller.state.continuation.context, "吃了")
        XCTAssertEqual(controller.state.continuation.suggestions, ["吗", "饭"])
    }

    func testNewlineDeleteEnglishModeVisibilityAndDisableClearState() {
        let client = FakeTextInputClient()
        let controller = makeController(client: client)

        _ = controller.handle(.insertDirectText("吃了"))
        _ = controller.handle(.insertReturn)
        XCTAssertTrue(controller.state.continuation.isEmpty)

        _ = controller.handle(.insertDirectText("吃了"))
        _ = controller.handle(.deleteBackward)
        XCTAssertTrue(controller.state.continuation.isEmpty)

        _ = controller.handle(.insertDirectText("吃了"))
        _ = controller.handle(.toggleInputMode)
        XCTAssertTrue(controller.state.continuation.isEmpty)

        _ = controller.handle(.toggleInputMode)
        _ = controller.handle(.insertDirectText("吃了"))
        _ = controller.abandonCompositionForVisibilityChange()
        XCTAssertTrue(controller.state.continuation.isEmpty)

        _ = controller.handle(.insertDirectText("吃了"))
        let effects = controller.setPostCommitContinuationEnabled(false)
        XCTAssertTrue(effects.contains(.continuationChanged))
        XCTAssertTrue(controller.state.continuation.isEmpty)
    }

    func testMissingTextClientDoesNotCreateContext() {
        let controller = KeyboardController(continuationSuggestionProvider: provider)

        _ = controller.handle(.insertDirectText("吃了"))

        XCTAssertTrue(controller.state.continuation.isEmpty)
    }

    func testContextIsBoundedByGraphemeCount() {
        let client = FakeTextInputClient()
        let controller = makeController(client: client)
        let prefix = String(repeating: "🙂", count: 40)

        _ = controller.handle(.insertDirectText(prefix + "好"))

        XCTAssertEqual(controller.state.continuation.context.count, ContinuationState.maximumContextLength)
        XCTAssertTrue(controller.state.continuation.context.hasSuffix("好"))
        XCTAssertEqual(controller.state.continuation.suggestions, ["的"])
    }

    func testSymbolPageCommitRefreshesCandidatePresentationState() {
        let client = FakeTextInputClient()
        let controller = makeController(client: client)
        _ = controller.handle(.insertDirectText("吃了"))
        _ = controller.handle(.togglePage)

        let effects = controller.handle(.insertKey("？"))

        XCTAssertEqual(client.text, "吃了？")
        XCTAssertEqual(controller.state.continuation.context, "吃了？")
        XCTAssertTrue(controller.state.continuation.suggestions.isEmpty)
        XCTAssertTrue(effects.contains(.continuationChanged))
    }

    private func makeController(client: FakeTextInputClient) -> KeyboardController {
        let controller = KeyboardController(continuationSuggestionProvider: provider)
        controller.textClient = client
        return controller
    }
}
