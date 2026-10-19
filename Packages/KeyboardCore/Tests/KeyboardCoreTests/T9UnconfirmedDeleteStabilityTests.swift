import XCTest

@testable import KeyboardCore

@MainActor
final class T9UnconfirmedDeleteStabilityTests: XCTestCase {
    func testDeleteRestoresPreviouslyDisplayedHaoWithoutConfirmationOrExtraCall() throws {
        let (controller, host, engine) = makeController()
        type("42682", on: controller)
        XCTAssertEqual(controller.t9UnconfirmedDeleteHistory.spellings["426"], "hao")
        engine.resetCallCounts()
        _ = controller.handle(.deleteBackward)
        XCTAssertEqual(engine.replaceInputCallCount, 1)
        _ = controller.handle(.deleteBackward)
        XCTAssertEqual(engine.replaceInputCallCount, 2)
        XCTAssertEqual(engine.candidateWindowCallCount, 0)
        XCTAssertEqual(controller.state.lastRimeOutput?.rawInput, "hao")
        XCTAssertEqual(host.markedText, "hao")
        XCTAssertEqual(controller.state.lastRimeOutput?.candidates.first?.text, "好")
        let pathState = controller.state.t9PinyinPathState
        XCTAssertEqual(pathState.segmentSourceDigits, "426")
        XCTAssertTrue(pathState.confirmedSegmentValues.isEmpty)
        XCTAssertNil(pathState.selectedPath)
        let preferred = try XCTUnwrap(pathState.compactPaths.first { $0.id == pathState.provisionalPathID })
        XCTAssertEqual(preferred.displayText, "hao")
        // An ordinary same-output refresh must not replace the soft interpretation.
        _ = controller.refreshT9PinyinPathStateForSameSnapshot()
        XCTAssertEqual(controller.t9CompositionPresentationSnapshot().visiblePreedit, "hao")
        XCTAssertEqual(host.text, host.markedText)
    }

    func testNewInputAfterRestoreUsesDigitLedgerAndAllowsNewInterpretation() {
        let (controller, host, engine) = makeController()
        type("42682", on: controller)
        _ = controller.handle(.deleteBackward)
        _ = controller.handle(.deleteBackward)
        engine.resetCallCounts()
        type("92", on: controller)
        XCTAssertEqual(controller.state.t9PinyinPathState.segmentSourceDigits, "42692")
        XCTAssertEqual(controller.state.lastRimeOutput?.rawInput, "42692")
        XCTAssertNil(controller.t9UnconfirmedDeleteHistory.preferred)
        XCTAssertTrue(controller.state.t9PinyinPathState.confirmedSegmentValues.isEmpty)
        XCTAssertEqual(engine.processKeyCallCount, 2)
        // The existing mixed-raw recovery runs on the first append only.
        XCTAssertEqual(engine.replaceInputCallCount, 1)
        XCTAssertEqual(engine.candidateWindowCallCount, 0)
        XCTAssertEqual(host.text, host.markedText)
    }

    func testExplicitChoiceClearsPredictionAndKeepsUserOwnership() throws {
        let (controller, host, _) = makeController()
        type("42682", on: controller)
        let gan = try XCTUnwrap(
            controller.state.t9PinyinPathState.compactPaths.first {
                $0.kind == .completeSyllable && $0.displayText == "gan"
            })
        _ = controller.handle(.selectT9PinyinPath(gan))
        XCTAssertTrue(controller.t9UnconfirmedDeleteHistory.spellings.isEmpty)
        XCTAssertEqual(controller.state.t9PinyinPathState.confirmedSegmentValues, ["gan"])
        _ = controller.handle(.deleteBackward)
        XCTAssertTrue(host.markedText.hasPrefix("gan"))
        XCTAssertNil(controller.t9UnconfirmedDeleteHistory.preferred)
    }

    func testCommitPageResetAndUnbindInvalidateHistory() {
        let actions: [KeyboardAction] = [.insertSpace, .togglePage, .toggleInputMode]
        for action in actions {
            let (controller, _, _) = makeController()
            type("426", on: controller)
            XCTAssertFalse(controller.t9UnconfirmedDeleteHistory.spellings.isEmpty)
            _ = controller.handle(action)
            XCTAssertTrue(controller.t9UnconfirmedDeleteHistory.spellings.isEmpty)
        }
        let (fallback, _, _) = makeController()
        type("426", on: fallback)
        _ = fallback.appendFallbackCompositionKey("8")
        XCTAssertTrue(fallback.t9UnconfirmedDeleteHistory.spellings.isEmpty)
        let (controller, _, _) = makeController()
        type("426", on: controller)
        controller.resetRimeSessionForVisibilityChange()
        XCTAssertTrue(controller.t9UnconfirmedDeleteHistory.spellings.isEmpty)
        let (other, _, _) = makeController()
        type("426", on: other)
        other.textClient = FakeTextInputClient()
        XCTAssertEqual(other.t9UnconfirmedDeleteHistory.spellings["426"], "hao")
        other.textClient = nil
        XCTAssertTrue(other.t9UnconfirmedDeleteHistory.spellings.isEmpty)
    }

    func testOwnerReplacementDoesNotReuseHistory() {
        let (controller, _, _) = makeController()
        type("42682", on: controller)
        let (_, _, newEngine) = makeController()
        controller.rimeEngine = newEngine
        XCTAssertNil(controller.t9HistoricalSpellingForDelete(digits: "426"))
        XCTAssertTrue(controller.t9UnconfirmedDeleteHistory.spellings.isEmpty)
    }

    func testRejectedHistoricalReplaceFailsClosedWithoutCommitOrRetry() {
        let (controller, host, engine) = makeController()
        type("42682", on: controller)
        _ = controller.handle(.deleteBackward)
        engine.replaceInputShouldFail = true
        engine.resetCallCounts()
        _ = controller.handle(.deleteBackward)
        XCTAssertEqual(engine.replaceInputCallCount, 1)
        XCTAssertEqual(engine.sessionResetCount, 1)
        XCTAssertNil(controller.state.lastRimeOutput)
        XCTAssertTrue(controller.t9UnconfirmedDeleteHistory.spellings.isEmpty)
        XCTAssertEqual(host.markedText, "")
        XCTAssertEqual(host.text, host.markedText)
    }

    func testInvalidHistoricalSpellingIsIgnoredAndStorageStaysBounded() {
        let (controller, _, engine) = makeController()
        type("42682", on: controller)
        XCTAssertLessThanOrEqual(controller.t9UnconfirmedDeleteHistory.spellings.count, 2)
        controller.t9UnconfirmedDeleteHistory.spellings["426"] = "ni"
        engine.resetCallCounts()
        _ = controller.handle(.deleteBackward)
        _ = controller.handle(.deleteBackward)
        XCTAssertNotEqual(controller.state.lastRimeOutput?.rawInput, "ni")
        XCTAssertEqual(engine.replaceInputCallCount, 2)
        XCTAssertNil(controller.t9UnconfirmedDeleteHistory.preferred)
    }

    private func type(_ digits: String, on controller: KeyboardController) {
        for digit in digits { _ = controller.handle(.insertKey(String(digit))) }
    }

    private func makeController() -> (KeyboardController, FakeTextInputClient, FakeRimeEngine) {
        let dictionary = [
            "4": ["个"], "42": ["哈"], "426": ["好"],
            "4268": ["感"], "42682": ["感他"], "hao": ["好"],
            "gan": ["敢"], "gan'8": ["敢"], "gan82": ["敢他"], "gan'82": ["敢他"], "4269": ["岗位"],
            "42692": ["高雅"],
        ]
        let comments = [
            "4": ["ge"], "42": ["ha"], "426": ["hao"],
            "4268": ["gan t"], "42682": ["gan ta"], "hao": ["hao"],
            "gan": ["gan"], "gan'8": ["gan t"], "gan82": ["gan ta"], "gan'82": ["gan ta"], "4269": ["gan w"],
            "42692": ["gao ya"],
        ]
        let engine = FakeRimeEngine(dictionary: dictionary, comments: comments)
        engine.appendDigitsToComposition = true
        let host = FakeTextInputClient()
        let controller = KeyboardController()
        controller.rimeEngine = engine
        controller.textClient = host
        controller.usesT9InputSemantics = true
        return (controller, host, engine)
    }
}
