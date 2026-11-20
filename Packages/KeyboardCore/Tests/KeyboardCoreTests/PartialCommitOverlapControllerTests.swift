import XCTest

@testable import KeyboardCore

@MainActor
final class PartialCommitOverlapControllerTests: XCTestCase {
    /// "你好" confirmed, engine commit "好安排" overlaps the confirmed suffix,
    /// so the seam must not duplicate "好": expected "你好安排".
    func testCandidateFinaleDedupsOverlapBetweenConfirmedSuffixAndEngineCommit() {
        let engine = FakeRimeEngine(
            dictionary: [
                "nihaoanpai": ["你好安排", "你好"],
                "aoanpai": ["好安排"],
            ],
            selectionRemainders: ["nihaoanpai": [1: "aoanpai"]]
        )
        let client = FakeTextInputClient()
        let controller = KeyboardController()
        controller.textClient = client
        controller.rimeEngine = engine
        for character in "nihaoanpai" {
            _ = controller.handle(.insertKey(String(character)))
        }

        _ = controller.handle(
            .insertCandidate(
                "你好",
                kind: .candidate,
                selectionReference: CandidateSelectionReference(page: 0, indexOnPage: 1)
            )
        )
        XCTAssertEqual(controller.state.partialCommit?.confirmedText, "你好")

        _ = controller.handle(
            .insertCandidate(
                "好安排",
                kind: .candidate,
                selectionReference: CandidateSelectionReference(page: 0, indexOnPage: 0)
            )
        )

        XCTAssertEqual(client.text, "你好安排")
        XCTAssertEqual(client.markedText, "")
        XCTAssertEqual(controller.state.currentComposition, "")
        XCTAssertNil(controller.state.partialCommit)
    }
}
