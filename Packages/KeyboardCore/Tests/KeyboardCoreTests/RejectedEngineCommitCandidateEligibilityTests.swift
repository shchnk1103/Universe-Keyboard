import XCTest

@testable import KeyboardCore

@MainActor
final class RejectedEngineCommitCandidateEligibilityTests: XCTestCase {
    func testRejectedCommitWithRemainingCompositionRevokesPagingAuthority() {
        let engine = FakeRimeEngine()
        engine.processKeyScript = [
            RimeOutput(
                rawInput: "6",
                composition: RimeComposition(preeditText: "n", cursorPosition: 1),
                candidates: [RimeCandidate(text: "你", comment: "n", globalIndex: 0)],
                hasMorePages: true,
                highlightedIndex: 0
            ),
            // The RimeOutput boundary permits a commit and remaining composition.
            // The raw-digit commit was never offered as a semantic candidate.
            RimeOutput(
                rawInput: "64",
                composition: RimeComposition(preeditText: "ni", cursorPosition: 2),
                candidates: [RimeCandidate(text: "拟", comment: "ni", globalIndex: 0)],
                committedText: "64",
                hasMorePages: true,
                highlightedIndex: 0
            ),
        ]
        let client = FakeTextInputClient()
        let controller = KeyboardController()
        controller.textClient = client
        controller.rimeEngine = engine
        controller.usesT9InputSemantics = true

        _ = controller.handle(.insertKey("6"))
        XCTAssertTrue(controller.state.lastRimeOutput?.hasMorePages == true)
        XCTAssertFalse(controller.state.lastRimeOutput?.candidates.contains { $0.text == "64" } ?? true)

        let effects = controller.handle(.insertKey("4"))

        XCTAssertFalse(client.text.contains("64"))
        XCTAssertEqual(client.markedText, "")
        XCTAssertTrue(controller.state.currentComposition.isEmpty)
        XCTAssertNil(controller.state.partialCommit)
        XCTAssertFalse(engine.isComposing())
        XCTAssertTrue(effects.contains(.compositionChanged))
        XCTAssertNil(controller.state.lastRimeOutput)
        XCTAssertFalse(controller.t9CompositionPresentationSnapshot().hasMorePages)
        XCTAssertTrue(controller.t9CompositionPresentationSnapshot().candidates.isEmpty)
    }
}
