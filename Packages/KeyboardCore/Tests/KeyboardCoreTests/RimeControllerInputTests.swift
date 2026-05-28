import XCTest

@testable import KeyboardCore

final class RimeControllerInputTests: RimeControllerTestSupport {
    func testProcessKeySetsLastRimeOutput() {
        _ = controller.handle(.insertKey("n"))
        XCTAssertNotNil(controller.state.lastRimeOutput)
        XCTAssertEqual(controller.state.lastRimeOutput?.composition?.preeditText, "n")
        XCTAssertEqual(controller.state.currentComposition, "n")
    }

    func testProcessKeyAccumulatesComposition() {
        _ = controller.handle(.insertKey("n"))
        _ = controller.handle(.insertKey("i"))
        let output = controller.state.lastRimeOutput
        XCTAssertEqual(output?.composition?.preeditText, "ni")
        XCTAssertEqual(output?.candidates.map(\.text), ["你", "呢", "尼"])
        XCTAssertEqual(controller.state.currentComposition, "ni")
    }

    func testProcessKeyNonChineseGoesDirectlyToClient() {
        controller.state.inputMode = .english
        _ = controller.handle(.insertKey("h"))
        XCTAssertEqual(client.text, "h")
        XCTAssertFalse(engine.isComposing())
    }

    func testDeleteBackwardRemovesFromComposition() {
        _ = controller.handle(.insertKey("n"))
        _ = controller.handle(.insertKey("i"))
        _ = controller.handle(.deleteBackward)
        XCTAssertEqual(controller.state.lastRimeOutput?.composition?.preeditText, "n")
        XCTAssertEqual(controller.state.currentComposition, "n")
    }

    func testDeleteBackwardClearsCompositionThenHitsProxy() {
        _ = controller.handle(.insertKey("n"))
        _ = controller.handle(.deleteBackward)
        XCTAssertEqual(controller.state.currentComposition, "")
        XCTAssertFalse(engine.isComposing())

        client.insertText("x")
        _ = controller.handle(.deleteBackward)
        XCTAssertEqual(client.deletedCount, 2)
    }

    func testDeleteBackwardEmptySkipsEngine() {
        client.insertText("x")
        _ = controller.handle(.deleteBackward)
        XCTAssertEqual(client.deletedCount, 1)
        XCTAssertFalse(engine.isComposing())
    }

    func testSpaceWithCompositionSelectsFirstCandidate() {
        _ = controller.handle(.insertKey("n"))
        _ = controller.handle(.insertKey("i"))
        _ = controller.handle(.insertSpace)

        XCTAssertEqual(client.text, "你")
        XCTAssertEqual(controller.state.currentComposition, "")
        XCTAssertNil(controller.state.lastRimeOutput?.composition)
    }

    func testSpaceWithUnknownCompositionCommitsRaw() {
        _ = controller.handle(.insertKey("z"))
        _ = controller.handle(.insertKey("z"))
        _ = controller.handle(.insertKey("z"))
        _ = controller.handle(.insertSpace)

        XCTAssertEqual(client.text, "zzz")
        XCTAssertEqual(controller.state.currentComposition, "")
    }

    func testSpaceWithoutCompositionInsertsSpace() {
        _ = controller.handle(.insertSpace)
        XCTAssertEqual(client.text, " ")
        XCTAssertEqual(engine.sessionResetCount, 0)
    }

    func testInsertCandidateSelectsByTitle() {
        _ = controller.handle(.insertKey("n"))
        _ = controller.handle(.insertKey("i"))
        _ = controller.handle(.insertCandidate("呢", kind: .candidate))

        XCTAssertEqual(client.text, "呢")
        XCTAssertEqual(controller.state.currentComposition, "")
    }

    func testInsertCandidateCompositionKindCommitsRawAndResets() {
        _ = controller.handle(.insertKey("n"))
        _ = controller.handle(.insertKey("i"))
        _ = controller.handle(.insertCandidate("ni", kind: .composition))

        XCTAssertEqual(client.text, "ni")
        XCTAssertEqual(engine.sessionResetCount, 1)
        XCTAssertEqual(controller.state.currentComposition, "")
    }

    func testInsertCandidatePlaceholderDoesNothing() {
        _ = controller.handle(.insertKey("n"))
        _ = controller.handle(.insertCandidate("placeholder text", kind: .placeholder))

        XCTAssertEqual(client.text, "n")
        XCTAssertEqual(controller.state.currentComposition, "n")
    }

    func testReturnWithCompositionCommitsRaw() {
        _ = controller.handle(.insertKey("n"))
        _ = controller.handle(.insertKey("i"))
        _ = controller.handle(.insertReturn)

        XCTAssertEqual(client.text, "ni")
        XCTAssertEqual(controller.state.currentComposition, "")
    }

    func testToggleInputModeResetsEngineSession() {
        _ = controller.handle(.insertKey("n"))
        _ = controller.handle(.insertKey("i"))
        _ = controller.handle(.toggleInputMode)

        XCTAssertEqual(client.text, "ni")
        XCTAssertEqual(engine.sessionResetCount, 1)
        XCTAssertEqual(controller.state.currentComposition, "")
        XCTAssertEqual(controller.state.inputMode, .english)
    }

    func testTogglePageFromLettersResetsEngineSession() {
        _ = controller.handle(.insertKey("n"))
        _ = controller.handle(.togglePage)

        XCTAssertEqual(client.text, "n")
        XCTAssertEqual(engine.sessionResetCount, 1)
        XCTAssertEqual(controller.state.currentComposition, "")
        XCTAssertEqual(controller.state.currentPage, .numbers)
    }

    func testIsComposingTracksState() {
        XCTAssertFalse(engine.isComposing())
        _ = controller.handle(.insertKey("n"))
        XCTAssertTrue(engine.isComposing())
        _ = controller.handle(.insertSpace)
        XCTAssertFalse(engine.isComposing())
    }

    func testLastRimeOutputUpdatedAfterEachKey() {
        _ = controller.handle(.insertKey("n"))
        XCTAssertEqual(controller.state.lastRimeOutput?.composition?.preeditText, "n")
        XCTAssertEqual(controller.state.lastRimeOutput?.candidates.count, 0)

        _ = controller.handle(.insertKey("i"))
        XCTAssertEqual(controller.state.lastRimeOutput?.composition?.preeditText, "ni")
        XCTAssertEqual(controller.state.lastRimeOutput?.candidates.count, 3)
        XCTAssertEqual(controller.state.lastRimeOutput?.highlightedIndex, 0)
    }

    func testLastRimeOutputClearedAfterSelect() {
        _ = controller.handle(.insertKey("n"))
        _ = controller.handle(.insertKey("i"))
        _ = controller.handle(.insertSpace)

        XCTAssertNil(controller.state.lastRimeOutput?.composition)
        XCTAssertEqual(controller.state.lastRimeOutput?.candidates.count, 0)
        XCTAssertEqual(controller.state.lastRimeOutput?.committedText, "你")
    }

    func testProcessKeyWithEmptyEngineOutput() {
        _ = controller.handle(.insertKey("z"))
        _ = controller.handle(.insertKey("z"))
        _ = controller.handle(.insertKey("z"))
        let effects = controller.handle(.insertKey("z"))
        XCTAssertEqual(controller.state.currentComposition, "zzzz")
        XCTAssertTrue(effects.contains(.compositionChanged))
    }

    func testFastTypingStateConsistency() {
        for character in "nihao" {
            _ = controller.handle(.insertKey(String(character)))
        }
        XCTAssertEqual(controller.state.currentComposition, "nihao")
        XCTAssertNotNil(controller.state.lastRimeOutput)
        let candidates = controller.state.lastRimeOutput?.candidates ?? []
        XCTAssertGreaterThan(candidates.count, 0)
    }

    func testInlinePreeditAppendsWithoutFullRewrite() {
        for character in "nihao" {
            _ = controller.handle(.insertKey(String(character)))
        }

        XCTAssertEqual(client.text, "nihao")
        XCTAssertEqual(client.deletedCount, 0)
        XCTAssertEqual(controller.state.insertedPreeditText, "nihao")
        XCTAssertEqual(controller.state.insertedPreeditCount, 5)
    }

    func testDuplicateCandidateTextSelectsFirstMatch() {
        _ = controller.handle(.insertKey("n"))
        _ = controller.handle(.insertKey("i"))
        _ = controller.handle(.insertCandidate("你", kind: .candidate))
        XCTAssertEqual(client.text, "你")
    }

    func testInsertCandidateWithNilLastRimeOutput() {
        controller.state.lastRimeOutput = nil
        _ = controller.handle(.insertCandidate("测试", kind: .candidate))
        XCTAssertEqual(client.text, "测试")
        XCTAssertEqual(controller.state.currentComposition, "")
    }
}
