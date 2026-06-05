import XCTest

@testable import KeyboardCore

final class PartialCommitStateTests: XCTestCase {
    func testKeyboardStatePartialCommitDefaultsToNil() {
        XCTAssertNil(KeyboardState().partialCommit)
    }

    func testPartialCommitStateStoresSingleCheckpointContract() {
        let checkpoint = PartialCommitCheckpoint(
            previousRawInput: "nihaoanpai",
            previousPreeditText: "ni hao an pai",
            previousDisplayText: "nihaoanpai"
        )
        let partialCommit = PartialCommitState(
            confirmedText: "你好",
            remainingRawInput: "anpai",
            remainingPreeditText: "an pai",
            displayText: "你好an pai",
            checkpoint: checkpoint
        )

        let state = KeyboardState(partialCommit: partialCommit)

        XCTAssertEqual(state.partialCommit, partialCommit)
        XCTAssertEqual(state.partialCommit?.checkpoint, checkpoint)
        XCTAssertEqual(state.partialCommit?.source, .rime)
    }

    func testPartialCommitStateStoresTypoCorrectionSource() {
        let partialCommit = PartialCommitState(
            confirmedText: "你好",
            remainingRawInput: "anpai",
            remainingPreeditText: "an pai",
            displayText: "你好an pai",
            source: .typoCorrection
        )

        XCTAssertEqual(partialCommit.source, .typoCorrection)
    }
}
