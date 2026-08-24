import XCTest

@testable import KeyboardCore

@MainActor
final class PendingKaomojiTests: XCTestCase {
    private let client = FakeTextInputClient()
    private var now = Date(timeIntervalSince1970: 1_700_000_000)
    private lazy var controller: KeyboardController = makeController()

    private func makeController(
        continuation: any ContinuationSuggestionProviding = BundledContinuationSuggestionProvider.shared
    ) -> KeyboardController {
        let controller = KeyboardController(continuationSuggestionProvider: continuation)
        controller.textClient = client
        controller.currentDate = { [unowned self] in self.now }
        controller.isPostCommitContinuationEnabled = true
        return controller
    }

    func testFirstPressInsertsDefaultPendingAndIncludesItInCompact() {
        let effects = controller.handle(.pressKaomoji)

        XCTAssertTrue(effects.contains(.pendingKaomojiChanged))
        XCTAssertEqual(client.text, "^_^")
        XCTAssertEqual(controller.state.pendingKaomoji?.text, "^_^")
        XCTAssertEqual(
            controller.pendingKaomojiCandidateItems(expanded: false).map(\.title).prefix(3),
            ["^_^", "＾ω＾", "＾＾"]
        )
        XCTAssertEqual(
            controller.pendingKaomojiCandidateItems(expanded: false).first?.title,
            "^_^"
        )
        XCTAssertTrue(controller.state.continuation.isEmpty)
    }

    func testSameKeyAcceptsThenStartsNewDefaultWithoutCycling() {
        _ = controller.handle(.pressKaomoji)
        now.addTimeInterval(0.2)
        _ = controller.handle(.pressKaomoji)
        XCTAssertEqual(client.text, "^_^^_^")
        XCTAssertEqual(controller.state.pendingKaomoji?.text, "^_^")

        now.addTimeInterval(0.2)
        _ = controller.handle(.pressKaomoji)
        XCTAssertEqual(client.text, "^_^^_^^_^")
        XCTAssertNil(controller.state.pendingPunctuation)
    }

    func testCandidateReplacesPendingAndKeepsOwnership() {
        _ = controller.handle(.pressKaomoji)
        let effects = controller.handle(
            .insertCandidate("＾ω＾", kind: .kaomojiCandidate)
        )

        XCTAssertTrue(effects.contains(.pendingKaomojiChanged))
        XCTAssertEqual(client.text, "＾ω＾")
        XCTAssertEqual(controller.state.pendingKaomoji?.text, "＾ω＾")

        let compact = controller.pendingKaomojiCandidateItems(expanded: false).map(\.title)
        XCTAssertEqual(compact.first, "^_^")
        XCTAssertTrue(compact.contains("＾ω＾"))
    }

    func testTappingAlreadyPendingItemDoesNotAppend() {
        _ = controller.handle(.pressKaomoji)
        let effects = controller.handle(
            .insertCandidate("^_^", kind: .kaomojiCandidate)
        )
        XCTAssertTrue(effects.contains(.pendingKaomojiChanged))
        XCTAssertEqual(client.text, "^_^")
        XCTAssertEqual(controller.state.pendingKaomoji?.text, "^_^")
    }

    func testCompactIncludesExpandedOnlyPending() {
        _ = controller.handle(.pressKaomoji)
        _ = controller.handle(.insertCandidate(":)", kind: .kaomojiCandidate))
        XCTAssertEqual(client.text, ":)")
        let compact = controller.pendingKaomojiCandidateItems(expanded: false).map(\.title)
        XCTAssertEqual(compact.first, "^_^")
        XCTAssertEqual(compact.last, ":)")
    }

    func testUnknownKaomojiCandidateDoesNotAppend() {
        _ = controller.handle(.pressKaomoji)
        let effects = controller.handle(
            .insertCandidate("吗", kind: .kaomojiCandidate)
        )
        XCTAssertTrue(effects.isEmpty)
        XCTAssertEqual(client.text, "^_^")
    }

    func testDeleteRemovesOnlyPendingSpan() {
        _ = controller.handle(.insertDirectText("好"))
        _ = controller.handle(.pressKaomoji)
        XCTAssertEqual(client.text, "好^_^")
        _ = controller.handle(.deleteBackward)
        XCTAssertEqual(client.text, "好")
        XCTAssertNil(controller.state.pendingKaomoji)
        _ = controller.handle(.deleteBackward)
        XCTAssertEqual(client.text, "")
    }

    func testExternalDocumentChangeDropsOwnershipWithoutDeleting() {
        _ = controller.handle(.pressKaomoji)
        let effects = controller.noteExternalDocumentChange()
        XCTAssertTrue(effects.contains(.pendingKaomojiChanged))
        XCTAssertNil(controller.state.pendingKaomoji)
        XCTAssertEqual(client.text, "^_^")
    }

    func testSpaceAcceptsThenInsertsSpace() {
        _ = controller.handle(.pressKaomoji)
        _ = controller.handle(.insertSpace)
        XCTAssertEqual(client.text, "^_^ ")
        XCTAssertNil(controller.state.pendingKaomoji)
    }

    func testLetterKeyAcceptsThenStartsComposition() {
        _ = controller.handle(.pressKaomoji)
        _ = controller.handle(.insertKey("n"))
        XCTAssertEqual(client.markedText, "n")
        XCTAssertTrue(client.text.hasPrefix("^_^"))
        XCTAssertNil(controller.state.pendingKaomoji)
    }

    func testPageSwitchAcceptsPending() {
        _ = controller.handle(.pressKaomoji)
        _ = controller.handle(.togglePage)
        XCTAssertEqual(client.text, "^_^")
        XCTAssertNil(controller.state.pendingKaomoji)
        XCTAssertEqual(controller.state.currentPage, .numbers)
    }

    func testCompositionCommitsFirstCandidateThenDefaultKaomoji() {
        _ = controller.handle(.insertKey("n"))
        _ = controller.handle(.insertKey("i"))
        XCTAssertEqual(controller.state.currentComposition, "ni")

        _ = controller.handle(.pressKaomoji)

        XCTAssertEqual(client.markedText, "")
        XCTAssertEqual(client.text, "你^_^")
        XCTAssertEqual(controller.state.currentComposition, "")
        XCTAssertEqual(controller.state.pendingKaomoji?.text, "^_^")
        XCTAssertTrue(controller.state.t9PinyinPathState.compactPaths.isEmpty)
    }

    func testCompositionWithoutCandidatesRejectsKey() {
        controller.state.currentComposition = "zzzz"
        controller.state.lastRimeOutput = RimeOutput(
            rawInput: "zzzz",
            composition: RimeComposition(preeditText: "zzzz", cursorPosition: 4),
            candidates: []
        )
        let before = client.text
        let effects = controller.handle(.pressKaomoji)
        XCTAssertTrue(effects.isEmpty)
        XCTAssertEqual(controller.state.currentComposition, "zzzz")
        XCTAssertNil(controller.state.pendingKaomoji)
        XCTAssertEqual(client.text, before)
    }

    func testKaomojiAndPunctuationAreMutuallyExclusive() {
        _ = controller.handle(.pressT9CommonPunctuation)
        XCTAssertEqual(client.text, "，")
        XCTAssertNotNil(controller.state.pendingPunctuation)

        _ = controller.handle(.pressKaomoji)
        XCTAssertEqual(client.text, "，^_^")
        XCTAssertNil(controller.state.pendingPunctuation)
        XCTAssertEqual(controller.state.pendingKaomoji?.text, "^_^")

        _ = controller.handle(.pressT9CommonPunctuation)
        XCTAssertEqual(client.text, "，^_^，")
        XCTAssertNil(controller.state.pendingKaomoji)
        XCTAssertEqual(controller.state.pendingPunctuation?.text, "，")
    }

    func testPunctuationCycleStillWorksAfterKaomojiAccept() {
        _ = controller.handle(.pressKaomoji)
        _ = controller.handle(.pressT9CommonPunctuation)
        now.addTimeInterval(0.4)
        _ = controller.handle(.pressT9CommonPunctuation)
        XCTAssertEqual(client.text, "^_^。")
        XCTAssertEqual(controller.state.pendingPunctuation?.cycleIndex, 1)
    }

    func testExpandedCatalogKeepsDefaultFirst() {
        _ = controller.handle(.pressKaomoji)
        let expanded = controller.pendingKaomojiCandidateItems(expanded: true)
        XCTAssertEqual(expanded.first?.title, "^_^")
        XCTAssertEqual(expanded.count, PendingKaomojiState.catalogTokens.count)
        XCTAssertEqual(expanded.last?.title, "(*＾_＾*)")
    }

    func testProvisionalAheadRejectsKaomojiKeyAndKeepsComposition() {
        controller.state.currentComposition = "ni"
        controller.testingForceProvisionalAhead()
        XCTAssertTrue(controller.isResponsiveProvisionalAhead)

        let effects = controller.handle(.pressKaomoji)

        XCTAssertTrue(effects.isEmpty)
        XCTAssertEqual(controller.state.currentComposition, "ni")
        XCTAssertNil(controller.state.pendingKaomoji)
        XCTAssertEqual(client.text, "")
    }

    func testAcceptingPendingRefreshesContinuationFromLeftover() {
        let local = FakeTextInputClient()
        let controller = KeyboardController(
            continuationSuggestionProvider: BundledContinuationSuggestionProvider(entries: [
                ContinuationEntry(context: "^_^", suggestions: ["呀"])
            ])
        )
        controller.textClient = local
        controller.currentDate = { [unowned self] in self.now }
        controller.isPostCommitContinuationEnabled = true

        _ = controller.handle(.pressKaomoji)
        XCTAssertTrue(controller.state.continuation.isEmpty)

        _ = controller.handle(.togglePage)
        XCTAssertEqual(local.text, "^_^")
        XCTAssertNil(controller.state.pendingKaomoji)
        XCTAssertEqual(controller.state.continuation.suggestions, ["呀"])
    }

    func testStaleAheadKaomojiCandidateIsFailClosed() {
        _ = controller.handle(.pressKaomoji)
        controller.testingForceProvisionalAhead()
        let before = client.text
        let effects = controller.handle(
            .insertCandidate("＾ω＾", kind: .kaomojiCandidate)
        )
        XCTAssertTrue(effects.isEmpty)
        XCTAssertEqual(client.text, before)
        XCTAssertEqual(controller.state.pendingKaomoji?.text, "^_^")
    }

    func testKaomojiCandidateWithoutPendingDoesNotAppend() {
        let before = client.text
        let effects = controller.handle(
            .insertCandidate("＾ω＾", kind: .kaomojiCandidate)
        )
        XCTAssertTrue(effects.isEmpty)
        XCTAssertEqual(client.text, before)
        XCTAssertNil(controller.state.pendingKaomoji)
    }

    func testKaomojiCandidateAfterLosingSpanDoesNotAppend() {
        _ = controller.handle(.pressKaomoji)
        _ = controller.noteExternalDocumentChange()
        XCTAssertEqual(client.text, "^_^")
        let effects = controller.handle(
            .insertCandidate("＾ω＾", kind: .kaomojiCandidate)
        )
        XCTAssertTrue(effects.isEmpty)
        XCTAssertEqual(client.text, "^_^")
        XCTAssertNil(controller.state.pendingKaomoji)
    }

    func testReturnAndEnglishToggleAcceptPending() {
        _ = controller.handle(.pressKaomoji)
        _ = controller.handle(.insertReturn)
        XCTAssertEqual(client.text, "^_^\n")
        XCTAssertNil(controller.state.pendingKaomoji)

        _ = controller.handle(.pressKaomoji)
        _ = controller.handle(.toggleInputMode)
        XCTAssertTrue(client.text.hasSuffix("^_^"))
        XCTAssertNil(controller.state.pendingKaomoji)
        XCTAssertEqual(controller.state.inputMode, .english)
    }

    func testVisibilityAbandonClearsKaomojiStateWithoutDeletingHost() {
        _ = controller.handle(.pressKaomoji)
        let effects = controller.abandonCompositionForVisibilityChange()
        XCTAssertTrue(effects.contains(.pendingKaomojiChanged))
        XCTAssertNil(controller.state.pendingKaomoji)
        XCTAssertEqual(client.text, "^_^")
    }
}
