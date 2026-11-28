import XCTest

@testable import KeyboardCore

/// T9-SWIPE-DELETE-PARTIAL-COMMIT-FIX-001 regression coverage.
///
/// Bug: after partial-selecting "轻" from "qingwei" (state "轻wei"), a
/// swipe-left Delete clears "wei" but keeps the PartialCommitCheckpoint; the
/// next Delete tap then resurrects "qingwei" instead of deleting normally.
@MainActor
final class PartialCommitSwipeDeleteTests: XCTestCase {

    private let dictionary = ["qingwei": ["轻喂"], "wei": ["喂"]]

    private func makeController() -> (KeyboardController, FakeTextInputClient, FakeRimeEngine) {
        let engine = FakeRimeEngine(
            dictionary: dictionary,
            selectedSegments: [
                "qingwei": [0: FakeRimeSelectedSegment(rawPrefix: "qing", text: "轻")]
            ],
            partialSelectionEmitsCommit: false
        )
        let client = FakeTextInputClient()
        let controller = KeyboardController()
        controller.textClient = client
        controller.rimeEngine = engine
        return (controller, client, engine)
    }

    private func type(_ input: String, into controller: KeyboardController) {
        for character in input {
            _ = controller.handle(.insertKey(String(character)))
        }
    }

    private func selectQing(using controller: KeyboardController) {
        _ = controller.handle(
            .insertCandidate(
                "轻",
                kind: .candidate,
                selectionReference: CandidateSelectionReference(page: 0, indexOnPage: 0)
            )
        )
    }

    func testSwipeLeftDeleteInvalidatesCheckpointAndNextDeleteDoesNotResurrectRaw() {
        let (controller, client, _) = makeController()
        type("qingwei", into: controller)
        selectQing(using: controller)

        XCTAssertEqual(client.markedText, "轻wei")
        XCTAssertEqual(controller.state.partialCommit?.confirmedText, "轻")
        XCTAssertEqual(controller.state.partialCommit?.displayText, "轻wei")
        XCTAssertNotNil(controller.state.partialCommit?.checkpoint)

        // Swipe-left Delete: abandon the remaining preedit, keep confirmed prefix.
        _ = controller.dropRemainingPreeditKeepingConfirmedPrefix()
        XCTAssertEqual(client.markedText, "轻")
        XCTAssertNil(controller.state.partialCommit?.checkpoint)

        // The next Delete tap deletes normally; "qingwei" must not resurrect.
        _ = controller.handle(.deleteBackward)
        XCTAssertNotEqual(client.markedText, "qingwei")
        XCTAssertNotEqual(controller.state.currentComposition, "qingwei")
        XCTAssertEqual(client.text, "")
        XCTAssertEqual(client.markedText, "")
        XCTAssertNil(controller.state.partialCommit)
        XCTAssertEqual(controller.state.currentComposition, "")
    }

    func testSingleTapDeleteAfterPartialSelectionStillRestoresRawInput() {
        let (controller, client, _) = makeController()
        type("qingwei", into: controller)
        selectQing(using: controller)

        XCTAssertEqual(client.markedText, "轻wei")

        _ = controller.handle(.deleteBackward)

        XCTAssertEqual(client.text, "qingwei")
        XCTAssertEqual(client.markedText, "qingwei")
        XCTAssertEqual(controller.state.lastRimeOutput?.rawInput, "qingwei")
        XCTAssertNil(controller.state.partialCommit)
    }
}
