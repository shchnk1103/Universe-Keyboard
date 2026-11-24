import XCTest

@testable import KeyboardCore

/// Controller contract tests for English prefix candidates and the
/// candidate-autospace commit contract (EN-CANDIDATE-AUTOSPACE-IMPL-001).
///
/// Commit contract (aligned with URL-MODE-ENGLISH): English letters go
/// straight to the host as before; a confirmed candidate commit verifies the
/// typed prefix still sits before the caret, replaces it by deleting it
/// backward, and inserts the candidate body plus at most one trailing ASCII
/// space as one insertion transaction.
@MainActor
final class EnglishCandidateControllerTests: XCTestCase {
    private final class TrackingClient: TextInputClient {
        let inner = FakeTextInputClient()
        var insertCalls: [String] = []

        var deleteCount: Int { inner.deletedCount }

        var hasTextBeforeInput: Bool {
            inner.hasTextBeforeInput
        }

        var text: String {
            inner.text
        }

        func seed(_ text: String) {
            inner.text = text
        }

        func moveCursor(to offset: Int) {
            inner.cursorOffset = offset
        }

        func insertText(_ text: String) {
            insertCalls.append(text)
            inner.insertText(text)
        }

        func deleteBackward() {
            inner.deleteBackward()
        }

        func adjustTextPosition(byCharacterOffset offset: Int) {
            inner.adjustTextPosition(byCharacterOffset: offset)
        }

        func setMarkedText(_ text: String, selectedRange: Range<Int>) {
            inner.setMarkedText(text, selectedRange: selectedRange)
        }

        func unmarkText() {
            inner.unmarkText()
        }
    }

    private func makeController(
        provider: (any EnglishCandidateProviding)? = BundledEnglishCandidateProvider(
            words: ["word", "world", "workshop", "work", "worry", "would"],
            sourceVersion: "test-1"
        ),
        state: KeyboardState = KeyboardState(inputMode: .english),
        before: String? = "Hello ",
        after: String? = "here"
    ) -> (KeyboardController, TrackingClient) {
        let client = TrackingClient()
        client.seed(before ?? "")
        let controller = KeyboardController(state: state, englishCandidateProvider: provider)
        controller.textClient = client
        // The fake host answers left-context reads from its own live text
        // before the caret; the right-context read stays a constant so each
        // test can pin an exact right neighbor for the autospace decision.
        controller.documentContextBeforeInput = { [client] in
            String(client.inner.text.prefix(client.inner.cursorOffset))
        }
        controller.documentContextAfterInput = { after }
        return (controller, client)
    }

    private func type(_ controller: KeyboardController, _ keys: String) {
        for key in keys.map(String.init) {
            _ = controller.handle(.insertKey(key))
        }
    }

    // MARK: - Prefix tracking and generation

    func testTypingLettersBuildsPrefixAndSuggestions() {
        let (controller, _) = makeController()

        type(controller, "wor")

        XCTAssertEqual(controller.state.englishCandidate.prefix, "wor")
        XCTAssertEqual(controller.state.englishCandidate.sourceVersion, "test-1")
        XCTAssertEqual(
            controller.state.englishCandidate.suggestions,
            ["word", "work", "workshop", "world", "worry"]
        )
    }

    func testNonLetterKeyClearsPrefix() {
        let (controller, _) = makeController()

        type(controller, "wor")
        _ = controller.handle(.insertKey("5"))

        XCTAssertEqual(controller.state.englishCandidate.prefix, "")
        XCTAssertTrue(controller.state.englishCandidate.suggestions.isEmpty)
    }

    func testDeleteBackwardShrinksPrefixAndRefreshes() {
        let (controller, _) = makeController()

        type(controller, "wor")
        _ = controller.handle(.deleteBackward)

        XCTAssertEqual(controller.state.englishCandidate.prefix, "wo")
        XCTAssertEqual(
            controller.state.englishCandidate.suggestions,
            ["word", "work", "workshop", "world", "worry", "would"]
        )

        type(controller, "\u{08}")
        _ = controller.handle(.deleteBackward)
        _ = controller.handle(.deleteBackward)
        XCTAssertEqual(controller.state.englishCandidate.prefix, "")
        XCTAssertTrue(controller.state.englishCandidate.suggestions.isEmpty)
    }

    func testSpaceAndReturnClearPrefix() {
        let (controller, _) = makeController()
        type(controller, "wor")
        _ = controller.handle(.insertSpace)
        XCTAssertEqual(controller.state.englishCandidate.prefix, "")
        XCTAssertTrue(controller.state.englishCandidate.suggestions.isEmpty)

        type(controller, "wor")
        _ = controller.handle(.insertReturn)
        XCTAssertEqual(controller.state.englishCandidate.prefix, "")
        XCTAssertTrue(controller.state.englishCandidate.suggestions.isEmpty)
    }

    // MARK: - Invalidation matrix

    func testModeSwitchInvalidatesCandidates() {
        let (controller, _) = makeController()
        type(controller, "wor")
        XCTAssertFalse(controller.state.englishCandidate.suggestions.isEmpty)

        _ = controller.handle(.toggleInputMode)

        XCTAssertEqual(controller.state.inputMode, .chinese)
        XCTAssertTrue(controller.state.englishCandidate.isEmpty)
    }

    func testHostTypeSwitchInvalidatesCandidates() {
        let (controller, _) = makeController()
        type(controller, "wor")
        XCTAssertFalse(controller.state.englishCandidate.suggestions.isEmpty)

        _ = controller.handle(.keyboardTypeChanged(.URL))

        XCTAssertTrue(controller.state.englishCandidate.isEmpty)
    }

    func testExternalDocumentChangeInvalidatesCandidates() {
        let (controller, _) = makeController()
        type(controller, "wor")
        XCTAssertFalse(controller.state.englishCandidate.suggestions.isEmpty)

        _ = controller.noteExternalDocumentChange()

        XCTAssertTrue(controller.state.englishCandidate.isEmpty)
    }

    func testCandidateSuggestionsAreBoundToProviderSourceVersion() {
        let (controller, _) = makeController()
        type(controller, "wor")

        XCTAssertEqual(controller.state.englishCandidate.sourceVersion, "test-1")
        XCTAssertEqual(controller.englishCandidateProvider?.sourceVersion, "test-1")
    }

    // MARK: - Commit contract

    func testCandidateCommitReplacesTypedPrefixAndAppendsExactlyOneSpaceInOneTransaction() {
        let (controller, client) = makeController()
        type(controller, "wor")
        XCTAssertEqual(client.insertCalls, ["w", "o", "r"])

        let effects = controller.handle(.insertCandidate("world", kind: .englishCandidate))

        XCTAssertEqual(client.insertCalls, ["w", "o", "r", "world "])
        XCTAssertEqual(client.text, "Hello world ")
        XCTAssertTrue(controller.state.englishCandidate.isEmpty)
        XCTAssertTrue(effects.refreshesCandidatePresentation)
    }

    func testCandidateCommitSkipsSpaceWhenRightNeighborUnknown() {
        let (controller, client) = makeController(after: nil)
        type(controller, "wor")

        _ = controller.handle(.insertCandidate("world", kind: .englishCandidate))

        XCTAssertEqual(client.insertCalls, ["w", "o", "r", "world"])
        XCTAssertEqual(client.text, "Hello world")
    }

    func testCandidateCommitSkipsSpaceAtDocumentEnd() {
        let (controller, client) = makeController(after: "")
        type(controller, "wor")

        _ = controller.handle(.insertCandidate("world", kind: .englishCandidate))

        XCTAssertEqual(client.insertCalls, ["w", "o", "r", "world"])
        XCTAssertEqual(client.text, "Hello world")
    }

    func testCandidateCommitSkipsSpaceBeforeWhitespaceOrPunctuationOrConnector() {
        for after in [" ", ".", "@", ":", "#", "/", ",", "。"] {
            let (controller, client) = makeController(after: after)
            type(controller, "wor")

            _ = controller.handle(.insertCandidate("world", kind: .englishCandidate))

            XCTAssertEqual(client.insertCalls, ["w", "o", "r", "world"], "right neighbor \(after)")
            XCTAssertEqual(client.text, "Hello world", "right neighbor \(after)")
        }
    }

    func testCandidateCommitSkipsSpaceWhenExistingTrailingWhitespace() {
        let (controller, client) = makeController(after: " world")
        type(controller, "wor")

        _ = controller.handle(.insertCandidate("world", kind: .englishCandidate))

        XCTAssertEqual(client.insertCalls, ["w", "o", "r", "world"])
        XCTAssertEqual(client.text, "Hello world")
    }

    func testCandidateCommitObeysDisabledHostTypes() {
        for hostType in [KeyboardType.URL, .emailAddress, .webSearch] {
            let (controller, client) = makeController(
                state: KeyboardState(inputMode: .english, activeKeyboardType: hostType)
            )
            type(controller, "wor")

            _ = controller.handle(.insertCandidate("world", kind: .englishCandidate))

            XCTAssertEqual(client.insertCalls, ["w", "o", "r", "world"], "\(hostType)")
            XCTAssertEqual(client.text, "Hello world", "\(hostType)")
        }
    }

    func testCandidateCommitObeysAutospaceSetting() {
        let (controller, client) = makeController()
        controller.englishCandidateAutospaceEnabled = false
        type(controller, "wor")

        _ = controller.handle(.insertCandidate("world", kind: .englishCandidate))

        XCTAssertEqual(client.insertCalls, ["w", "o", "r", "world"])
        XCTAssertEqual(client.text, "Hello world")
    }

    func testCandidateCommitAfterCJKLeftNeighborDoesNotDoubleSpace() {
        let (controller, client) = makeController(before: "中", after: "here")
        type(controller, "wor")
        // MixedScriptSpacing added the boundary space with the first letter;
        // the remaining letters stay tight and the stored prefix tracks the
        // typed letters only.
        XCTAssertEqual(client.insertCalls, [" w", "o", "r"])
        XCTAssertEqual(client.text, "中 wor")

        _ = controller.handle(.insertCandidate("world", kind: .englishCandidate))

        XCTAssertEqual(client.insertCalls, [" w", "o", "r", "world "])
        XCTAssertEqual(client.text, "中 world ")
        XCTAssertFalse(client.text.contains("  "))
    }

    func testCommitRejectsWhenTypedPrefixNoLongerAtCaret() {
        let (controller, client) = makeController()
        type(controller, "wor")

        client.moveCursor(to: 0)
        _ = controller.handle(.insertCandidate("world", kind: .englishCandidate))

        XCTAssertEqual(client.insertCalls, ["w", "o", "r"])
        XCTAssertEqual(client.text, "Hello wor")
        XCTAssertTrue(controller.state.englishCandidate.isEmpty)
    }

    func testStaleCandidateIsRejected() {
        let (controller, client) = makeController()
        type(controller, "wor")

        _ = controller.handle(.insertCandidate("zebra", kind: .englishCandidate))

        XCTAssertEqual(client.insertCalls, ["w", "o", "r"])
        XCTAssertEqual(client.text, "Hello wor")
        XCTAssertFalse(controller.state.englishCandidate.isEmpty)
    }

    func testCandidateFromDifferentSourceVersionIsRejected() {
        let (controller, client) = makeController()
        type(controller, "wor")
        controller.englishCandidateProvider = BundledEnglishCandidateProvider(
            words: ["word", "world"],
            sourceVersion: "test-2"
        )

        _ = controller.handle(.insertCandidate("world", kind: .englishCandidate))

        XCTAssertEqual(client.insertCalls, ["w", "o", "r"])
        XCTAssertEqual(client.text, "Hello wor")
    }

    func testMissingProviderDisablesCandidates() {
        let (controller, client) = makeController(provider: nil)
        type(controller, "wor")

        XCTAssertTrue(controller.state.englishCandidate.isEmpty)
        _ = controller.handle(.insertCandidate("world", kind: .englishCandidate))
        XCTAssertEqual(client.insertCalls, ["w", "o", "r"])
        XCTAssertEqual(client.text, "Hello wor")
    }

    func testCandidateCommitWithoutHostClientIsRejectedAndClearsState() {
        // No host text proxy at all: the commit must be rejected fail-closed
        // at the entry — no host write and no context consultation — and the
        // visible candidates must be cleared.
        let controller = KeyboardController(
            state: KeyboardState(inputMode: .english),
            englishCandidateProvider: BundledEnglishCandidateProvider(
                words: ["word", "world", "work"],
                sourceVersion: "test-1"
            )
        )
        var contextReads = 0
        // A matching left prefix proves the rejection is not an accident of
        // scope-mismatch: even a would-be valid commit is cut off without a
        // host proxy.
        controller.documentContextBeforeInput = {
            contextReads += 1
            return "wor"
        }
        controller.documentContextAfterInput = { "here" }
        type(controller, "wor")
        XCTAssertFalse(controller.state.englishCandidate.isEmpty)
        let contextReadsBeforeCommit = contextReads

        _ = controller.handle(.insertCandidate("world", kind: .englishCandidate))

        XCTAssertEqual(contextReads, contextReadsBeforeCommit)
        XCTAssertTrue(controller.state.englishCandidate.isEmpty)
    }

    // MARK: - Deferred trailing autospace (EN-mode fix r1, real-device bug)

    private func makeAutospaceController(
        before: String,
        after: String = ""
    ) -> (KeyboardController, TrackingClient) {
        makeController(
            provider: BundledEnglishCandidateProvider(
                words: ["word", "hello", "world"],
                sourceVersion: "test-enmode"
            ),
            before: before,
            after: after
        )
    }

    /// Real-device bug scenario 1 (Human 2026-11-24): in pure English mode,
    /// typing `wor`, committing the candidate `Word` at the document end and
    /// continuing with `hello` must yield `Word hello`, not `Wordhello`.
    func testRealDeviceScenarioPureEnglishWordThenHelloAutospaces() {
        let (controller, client) = makeAutospaceController(before: "")
        type(controller, "Wor")

        _ = controller.handle(.insertCandidate("Word", kind: .englishCandidate))
        XCTAssertEqual(client.insertCalls, ["W", "o", "r", "Word"])

        type(controller, "hello")

        XCTAssertEqual(client.text, "Word hello")
    }

    func testCandidateCommitAtDocumentEndArmsDeferredSpaceForNextLetter() {
        let (controller, client) = makeAutospaceController(before: "")
        type(controller, "Wor")

        _ = controller.handle(.insertCandidate("Word", kind: .englishCandidate))

        XCTAssertEqual(client.insertCalls, ["W", "o", "r", "Word"])
        XCTAssertTrue(controller.state.pendingEnglishAutospace)

        type(controller, "h")

        XCTAssertEqual(client.insertCalls, ["W", "o", "r", "Word", " h"])
        XCTAssertEqual(client.text, "Word h")
        XCTAssertFalse(controller.state.pendingEnglishAutospace)
    }

    /// Real-device bug scenario 2 (Human 2026-11-24): after `Word hello.`,
    /// committing the next sentence word candidate `Hello` must yield
    /// `Word hello. Hello`, not `Word hello.Hello`.
    func testRealDeviceScenarioPeriodThenHelloCandidateGetsSentenceSpace() {
        let (controller, client) = makeAutospaceController(before: "")
        type(controller, "Wor")
        _ = controller.handle(.insertCandidate("Word", kind: .englishCandidate))
        type(controller, "hello.")
        XCTAssertEqual(client.text, "Word hello.")

        type(controller, "Hel")
        _ = controller.handle(.insertCandidate("Hello", kind: .englishCandidate))

        XCTAssertEqual(client.text, "Word hello. Hello")
    }

    func testCandidateCommitAfterSentenceTerminatorAddsLeadingSpace() {
        let (controller, client) = makeAutospaceController(before: "Word.")
        type(controller, "hel")
        XCTAssertEqual(client.insertCalls, ["h", "e", "l"])

        _ = controller.handle(.insertCandidate("hello", kind: .englishCandidate))

        XCTAssertEqual(client.insertCalls, ["h", "e", "l", " hello"])
        XCTAssertEqual(client.text, "Word. hello")
    }

    /// 标点豁免：延后空格不落在标点前（`Word.` 而非 `Word .`），标点输入
    /// 撤回武装，紧随其后的字母不再补格（连接符号语义 `google.com`）。
    func testDeferredAutospaceExemptsPunctuationAndRecalls() {
        let (controller, client) = makeAutospaceController(before: "")
        type(controller, "Wor")
        _ = controller.handle(.insertCandidate("Word", kind: .englishCandidate))
        XCTAssertTrue(controller.state.pendingEnglishAutospace)

        type(controller, ".")

        XCTAssertEqual(client.insertCalls.last, ".")
        XCTAssertEqual(client.text, "Word.")
        XCTAssertFalse(controller.state.pendingEnglishAutospace)

        type(controller, "h")

        XCTAssertEqual(client.insertCalls.last, "h")
        XCTAssertEqual(client.text, "Word.h")
    }

    /// 退格撤回：武装后退格删除已提交词尾并撤回武装，手工接词不得出现
    /// 意外空格（`Wor` + `l` → `Worl`）。
    func testDeferredAutospaceRecalledByBackspace() {
        let (controller, client) = makeAutospaceController(before: "")
        type(controller, "Wor")
        _ = controller.handle(.insertCandidate("Word", kind: .englishCandidate))
        XCTAssertTrue(controller.state.pendingEnglishAutospace)

        _ = controller.handle(.deleteBackward)

        XCTAssertEqual(client.text, "Wor")
        XCTAssertFalse(controller.state.pendingEnglishAutospace)

        type(controller, "l")

        XCTAssertEqual(client.insertCalls.last, "l")
        XCTAssertEqual(client.text, "Worl")
    }

    func testDeferredAutospaceExemptOnSpaceAndReturn() {
        let (controller, client) = makeAutospaceController(before: "")
        type(controller, "Wor")
        _ = controller.handle(.insertCandidate("Word", kind: .englishCandidate))

        _ = controller.handle(.insertSpace)

        XCTAssertEqual(client.text, "Word ")
        XCTAssertFalse(controller.state.pendingEnglishAutospace)
        type(controller, "h")
        XCTAssertEqual(client.text, "Word h")

        let (controller2, client2) = makeAutospaceController(before: "")
        type(controller2, "Wor")
        _ = controller2.handle(.insertCandidate("Word", kind: .englishCandidate))
        _ = controller2.handle(.insertReturn)
        XCTAssertFalse(controller2.state.pendingEnglishAutospace)
        type(controller2, "h")
        XCTAssertEqual(client2.insertCalls.last, "h")
        XCTAssertFalse(client2.text.hasSuffix("\n h"))
    }

    // MARK: - Candidate kind

    func testEnglishCandidateKindIsRegistered() {
        XCTAssertEqual(CandidateKind.englishCandidate.rawValue, 7)
        XCTAssertTrue(CandidateKind.englishCandidate.expandsCandidateBarPanel)
    }
}
