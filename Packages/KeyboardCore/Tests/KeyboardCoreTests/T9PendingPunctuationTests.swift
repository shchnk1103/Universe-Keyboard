import XCTest

@testable import KeyboardCore

@MainActor
final class T9PendingPunctuationTests: XCTestCase {
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

    func testFirstPressInsertsPendingCommaAndPalette() {
        let effects = controller.handle(.pressT9CommonPunctuation)

        XCTAssertTrue(effects.contains(.pendingPunctuationChanged))
        XCTAssertEqual(client.text, "，")
        XCTAssertEqual(controller.state.pendingPunctuation?.text, "，")
        XCTAssertEqual(controller.state.pendingPunctuation?.cycleIndex, 0)
        XCTAssertTrue(controller.state.pendingPunctuation?.cycleArmed ?? false)
        XCTAssertEqual(
            controller.pendingPunctuationCandidateItems(expanded: false).map(\.title).prefix(3),
            ["。", "？", "！"]
        )
        XCTAssertFalse(
            controller.pendingPunctuationCandidateItems(expanded: false).contains { $0.title == "，" }
        )
        XCTAssertTrue(controller.state.continuation.isEmpty)
    }

    func testSameKeyCyclesWithinOneSecondAndWraps() {
        _ = controller.handle(.pressT9CommonPunctuation)
        now.addTimeInterval(0.4)
        _ = controller.handle(.pressT9CommonPunctuation)
        XCTAssertEqual(client.text, "。")
        now.addTimeInterval(0.4)
        _ = controller.handle(.pressT9CommonPunctuation)
        XCTAssertEqual(client.text, "？")
        now.addTimeInterval(0.4)
        _ = controller.handle(.pressT9CommonPunctuation)
        XCTAssertEqual(client.text, "！")
        now.addTimeInterval(0.4)
        _ = controller.handle(.pressT9CommonPunctuation)
        XCTAssertEqual(client.text, "，")
        XCTAssertEqual(controller.state.pendingPunctuation?.cycleIndex, 0)
    }

    func testSameKeyAfterTimeoutStartsNewComma() {
        _ = controller.handle(.pressT9CommonPunctuation)
        now.addTimeInterval(1.1)
        _ = controller.handle(.pressT9CommonPunctuation)
        XCTAssertEqual(client.text, "，，")
        XCTAssertEqual(controller.state.pendingPunctuation?.text, "，")
    }

    func testCandidateReplacesPendingAndDisarmsCycle() {
        _ = controller.handle(.pressT9CommonPunctuation)
        let effects = controller.handle(
            .insertCandidate("……", kind: .punctuationCandidate)
        )

        XCTAssertTrue(effects.contains(.pendingPunctuationChanged))
        XCTAssertEqual(client.text, "……")
        XCTAssertEqual(controller.state.pendingPunctuation?.text, "……")
        XCTAssertFalse(controller.state.pendingPunctuation?.cycleArmed ?? true)

        now.addTimeInterval(0.2)
        _ = controller.handle(.pressT9CommonPunctuation)
        XCTAssertEqual(client.text, "……，")
        XCTAssertEqual(controller.state.pendingPunctuation?.text, "，")
    }

    func testUnknownPunctuationCandidateDoesNotAppend() {
        _ = controller.handle(.pressT9CommonPunctuation)
        let effects = controller.handle(
            .insertCandidate("吗", kind: .punctuationCandidate)
        )
        XCTAssertTrue(effects.isEmpty)
        XCTAssertEqual(client.text, "，")
    }

    func testDeleteRemovesOnlyPendingSpan() {
        _ = controller.handle(.insertDirectText("好"))
        _ = controller.handle(.pressT9CommonPunctuation)
        XCTAssertEqual(client.text, "好，")
        _ = controller.handle(.deleteBackward)
        XCTAssertEqual(client.text, "好")
        XCTAssertNil(controller.state.pendingPunctuation)
        _ = controller.handle(.deleteBackward)
        XCTAssertEqual(client.text, "")
    }

    func testExternalDocumentChangeDropsOwnershipWithoutDeleting() {
        _ = controller.handle(.pressT9CommonPunctuation)
        let effects = controller.noteExternalDocumentChange()
        XCTAssertTrue(effects.contains(.pendingPunctuationChanged))
        XCTAssertNil(controller.state.pendingPunctuation)
        XCTAssertEqual(client.text, "，")
    }

    func testSpaceAcceptsThenInsertsSpace() {
        _ = controller.handle(.pressT9CommonPunctuation)
        _ = controller.handle(.insertSpace)
        XCTAssertEqual(client.text, "， ")
        XCTAssertNil(controller.state.pendingPunctuation)
    }

    func testLetterKeyAcceptsThenStartsComposition() {
        _ = controller.handle(.pressT9CommonPunctuation)
        _ = controller.handle(.insertKey("n"))
        XCTAssertEqual(client.markedText, "n")
        XCTAssertTrue(client.text.hasPrefix("，"))
        XCTAssertNil(controller.state.pendingPunctuation)
    }

    func testPageSwitchAcceptsPending() {
        _ = controller.handle(.pressT9CommonPunctuation)
        _ = controller.handle(.togglePage)
        XCTAssertEqual(client.text, "，")
        XCTAssertNil(controller.state.pendingPunctuation)
        XCTAssertEqual(controller.state.currentPage, .numbers)
    }

    func testCompositionCommitsFirstCandidateThenPendingComma() {
        _ = controller.handle(.insertKey("n"))
        _ = controller.handle(.insertKey("i"))
        XCTAssertEqual(controller.state.currentComposition, "ni")

        _ = controller.handle(.pressT9CommonPunctuation)

        XCTAssertEqual(client.markedText, "")
        XCTAssertEqual(client.text, "你，")
        XCTAssertEqual(controller.state.currentComposition, "")
        XCTAssertEqual(controller.state.pendingPunctuation?.text, "，")
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
        let effects = controller.handle(.pressT9CommonPunctuation)
        XCTAssertTrue(effects.isEmpty)
        XCTAssertEqual(controller.state.currentComposition, "zzzz")
        XCTAssertNil(controller.state.pendingPunctuation)
        XCTAssertEqual(client.text, before)
    }

    func testPairedOpenerTracksBothSidesAndReplacesCleanly() {
        _ = controller.handle(.pressT9CommonPunctuation)
        _ = controller.handle(.insertCandidate("（", kind: .punctuationCandidate))
        XCTAssertEqual(client.text, "（）")
        XCTAssertEqual(client.cursorOffset, 1)
        XCTAssertEqual(controller.state.pendingPunctuation?.beforeCursor, "（")
        XCTAssertEqual(controller.state.pendingPunctuation?.afterCursor, "）")

        _ = controller.handle(.insertCandidate("。", kind: .punctuationCandidate))
        XCTAssertEqual(client.text, "。")
        XCTAssertEqual(controller.state.pendingPunctuation?.text, "。")
    }

    func testExpandedCatalogIncludesCurrentPending() {
        _ = controller.handle(.pressT9CommonPunctuation)
        let expanded = controller.pendingPunctuationCandidateItems(expanded: true)
        XCTAssertTrue(expanded.contains { $0.title == "，" })
        XCTAssertEqual(expanded.count, PendingPunctuationState.catalogTokens.count + 1)
    }

    func testProvisionalAheadRejectsPunctuationKeyAndKeepsComposition() {
        controller.state.currentComposition = "ni"
        controller.testingForceProvisionalAhead()
        XCTAssertTrue(controller.isResponsiveProvisionalAhead)

        let effects = controller.handle(.pressT9CommonPunctuation)

        XCTAssertTrue(effects.isEmpty)
        XCTAssertEqual(controller.state.currentComposition, "ni")
        XCTAssertNil(controller.state.pendingPunctuation)
        XCTAssertEqual(client.text, "")
    }

    func testAcceptingPendingRefreshesContinuationFromLeftover() {
        let local = FakeTextInputClient()
        let controller = KeyboardController(
            continuationSuggestionProvider: BundledContinuationSuggestionProvider(entries: [
                ContinuationEntry(context: "，", suggestions: ["呀"])
            ])
        )
        controller.textClient = local
        controller.currentDate = { [unowned self] in self.now }
        controller.isPostCommitContinuationEnabled = true

        _ = controller.handle(.pressT9CommonPunctuation)
        XCTAssertTrue(controller.state.continuation.isEmpty)

        // 切页只接受 pending，不再写入新文本，所以 leftover 必须能打开 0017。
        _ = controller.handle(.togglePage)
        XCTAssertEqual(local.text, "，")
        XCTAssertNil(controller.state.pendingPunctuation)
        XCTAssertEqual(controller.state.continuation.suggestions, ["呀"])
    }

    func testPairedOpenerDeleteRemovesBothSides() {
        _ = controller.handle(.pressT9CommonPunctuation)
        _ = controller.handle(.insertCandidate("（", kind: .punctuationCandidate))
        XCTAssertEqual(client.text, "（）")

        _ = controller.handle(.deleteBackward)
        XCTAssertEqual(client.text, "")
        XCTAssertNil(controller.state.pendingPunctuation)
    }

    func testPairCompletionDisabledInsertsOpenerOnly() {
        controller.isPairedSymbolCompletionEnabled = false
        _ = controller.handle(.pressT9CommonPunctuation)
        _ = controller.handle(.insertCandidate("（", kind: .punctuationCandidate))
        XCTAssertEqual(client.text, "（")
        XCTAssertEqual(controller.state.pendingPunctuation?.beforeCursor, "（")
        XCTAssertEqual(controller.state.pendingPunctuation?.afterCursor, "")
    }

    func testStaleAheadPunctuationCandidateIsFailClosed() {
        _ = controller.handle(.pressT9CommonPunctuation)
        controller.testingForceProvisionalAhead()
        let before = client.text
        let effects = controller.handle(
            .insertCandidate("。", kind: .punctuationCandidate)
        )
        XCTAssertTrue(effects.isEmpty)
        XCTAssertEqual(client.text, before)
        XCTAssertEqual(controller.state.pendingPunctuation?.text, "，")
    }

    func testPunctuationCandidateWithoutPendingDoesNotAppend() {
        let before = client.text
        let effects = controller.handle(
            .insertCandidate("。", kind: .punctuationCandidate)
        )
        XCTAssertTrue(effects.isEmpty)
        XCTAssertEqual(client.text, before)
        XCTAssertNil(controller.state.pendingPunctuation)
    }

    func testPunctuationCandidateAfterLosingSpanDoesNotAppend() {
        _ = controller.handle(.pressT9CommonPunctuation)
        _ = controller.noteExternalDocumentChange()
        XCTAssertEqual(client.text, "，")
        let effects = controller.handle(
            .insertCandidate("。", kind: .punctuationCandidate)
        )
        XCTAssertTrue(effects.isEmpty)
        XCTAssertEqual(client.text, "，")
        XCTAssertNil(controller.state.pendingPunctuation)
    }

    func testReturnAndEnglishToggleAcceptPending() {
        _ = controller.handle(.pressT9CommonPunctuation)
        _ = controller.handle(.insertReturn)
        XCTAssertEqual(client.text, "，\n")
        XCTAssertNil(controller.state.pendingPunctuation)

        _ = controller.handle(.pressT9CommonPunctuation)
        _ = controller.handle(.toggleInputMode)
        XCTAssertTrue(client.text.hasSuffix("，"))
        XCTAssertNil(controller.state.pendingPunctuation)
        XCTAssertEqual(controller.state.inputMode, .english)
    }
}
