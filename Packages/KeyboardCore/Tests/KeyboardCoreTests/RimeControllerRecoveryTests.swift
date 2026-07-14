import XCTest

@testable import KeyboardCore

final class RimeControllerRecoveryTests: RimeControllerTestSupport {
    func testFallbackWhenEngineIsNil() {
        controller.rimeEngine = nil

        _ = controller.handle(.insertKey("n"))
        XCTAssertNil(controller.state.lastRimeOutput)
        XCTAssertEqual(controller.state.currentComposition, "n")

        _ = controller.handle(.insertKey("i"))
        XCTAssertEqual(controller.state.currentComposition, "ni")

        _ = controller.handle(.insertSpace)
        XCTAssertEqual(client.text, "你")
        XCTAssertEqual(controller.state.currentComposition, "")
    }

    func testFallbackDeleteWhenEngineIsNil() {
        controller.rimeEngine = nil
        _ = controller.handle(.insertKey("n"))
        _ = controller.handle(.insertKey("i"))
        _ = controller.handle(.deleteBackward)
        XCTAssertEqual(controller.state.currentComposition, "n")
    }

    func testDeleteBackwardWhenProxyIsEmpty() {
        client.text = ""
        _ = controller.handle(.deleteBackward)
        XCTAssertEqual(client.text, "")
    }

    func testRejectedEngineKeyRetriesInRimeAndPreservesCandidates() {
        engine.processKeysToDrop = 2

        _ = controller.handle(.insertKey("n"))
        XCTAssertEqual(client.text, "n")
        XCTAssertNil(controller.state.lastRimeOutput)
        XCTAssertFalse(engine.isComposing())

        _ = controller.handle(.insertKey("i"))

        XCTAssertEqual(client.text, "ni")
        XCTAssertEqual(controller.state.currentComposition, "ni")
        XCTAssertEqual(controller.state.lastRimeOutput?.candidates.map(\.text), ["你", "呢", "尼"])
        XCTAssertTrue(engine.isComposing())
        _ = controller.handle(.insertSpace)
        XCTAssertEqual(client.text, "你")
        XCTAssertEqual(controller.state.currentComposition, "")
    }

    func testSessionResetDuringCompositionRestoresExistingTextAndCandidates() {
        _ = controller.handle(.insertKey("n"))
        controller.resetRimeSessionForVisibilityChange()
        XCTAssertEqual(engine.sessionRecoveryCount, 0)
        _ = controller.handle(.insertKey("i"))

        XCTAssertEqual(engine.sessionRecoveryCount, 0)
        XCTAssertEqual(client.text, "ni")
        XCTAssertEqual(controller.state.currentComposition, "ni")
        XCTAssertEqual(controller.state.lastRimeOutput?.candidates.map(\.text), ["你", "呢", "尼"])
        XCTAssertTrue(engine.isComposing())
    }

    func testInvalidSessionAfterVisibilityChangeRecoversRuntimeAndCandidates() {
        _ = controller.handle(.insertKey("n"))
        controller.resetRimeSessionForVisibilityChange()
        engine.processKeysToDrop = 1

        _ = controller.handle(.insertKey("i"))

        XCTAssertEqual(engine.sessionRecoveryCount, 1)
        XCTAssertEqual(client.text, "ni")
        XCTAssertEqual(controller.state.currentComposition, "ni")
        XCTAssertEqual(controller.state.lastRimeOutput?.candidates.map(\.text), ["你", "呢", "尼"])
        XCTAssertTrue(engine.isComposing())
    }

    func testAbandonCompositionForVisibilityChangeClearsVisibleState() {
        _ = controller.handle(.insertKey("n"))
        _ = controller.handle(.insertKey("i"))

        XCTAssertEqual(client.markedText, "ni")
        XCTAssertEqual(controller.state.lastRimeOutput?.candidates.map(\.text), ["你", "呢", "尼"])

        let effects = controller.abandonCompositionForVisibilityChange()

        XCTAssertTrue(effects.contains(.compositionChanged))
        XCTAssertEqual(client.text, "")
        XCTAssertEqual(client.markedText, "")
        XCTAssertEqual(controller.state.currentComposition, "")
        XCTAssertNil(controller.state.lastRimeOutput)
        XCTAssertNil(controller.state.partialCommit)
        XCTAssertNil(controller.state.typoCorrection)
        XCTAssertFalse(engine.isComposing())
        XCTAssertEqual(engine.sessionResetCount, 1)
    }

    func testVisibilityLifecycleReleasesAndResumesRimeEngine() {
        _ = controller.handle(.insertKey("n"))
        _ = controller.abandonCompositionForVisibilityChange()

        controller.suspendRimeForVisibilityChange()
        controller.resumeRimeAfterVisibilityChange()

        XCTAssertEqual(engine.visibilitySuspendCount, 1)
        XCTAssertEqual(engine.visibilityResumeCount, 1)
        XCTAssertFalse(engine.isComposing())
        XCTAssertEqual(controller.state.currentComposition, "")
        XCTAssertNil(controller.state.lastRimeOutput)
    }

    func testEngineNilToNonNilTransition() {
        controller.rimeEngine = nil
        _ = controller.handle(.insertKey("h"))
        _ = controller.handle(.insertKey("i"))
        XCTAssertEqual(controller.state.currentComposition, "hi")
        controller.rimeEngine = engine
        _ = controller.handle(.insertKey("n"))
        XCTAssertEqual(engine.sessionResetCount, 0)
    }

    func testSpaceResetsRimeSession() {
        _ = controller.handle(.insertKey("n"))
        _ = controller.handle(.insertKey("i"))
        XCTAssertTrue(engine.isComposing())
        _ = controller.handle(.insertSpace)
        XCTAssertFalse(engine.isComposing(), "空格提交后 RIME 引擎必须不是 composing 状态")
        XCTAssertEqual(engine.sessionResetCount, 1)
    }

    func testStaleCandidateWithoutReferenceKeepsRimeComposition() {
        _ = controller.handle(.insertKey("n"))
        _ = controller.handle(.insertKey("i"))
        _ = controller.handle(.insertCandidate("你好", kind: .candidate))
        XCTAssertEqual(client.text, "ni")
        XCTAssertTrue(engine.isComposing(), "过期候选点击不能重置 RIME")
        XCTAssertEqual(controller.state.currentComposition, "ni")
    }

    func testDeleteAfterCandidateSelectionDoesNotRevivePinyin() {
        _ = controller.handle(.insertKey("n"))
        _ = controller.handle(.insertKey("i"))
        _ = controller.handle(.insertCandidate("你", kind: .candidate))
        XCTAssertEqual(client.text, "你")
        XCTAssertFalse(engine.isComposing())

        client.text = "你"
        _ = controller.handle(.deleteBackward)
        XCTAssertEqual(client.text, "", "删除应清空宿主文本")
        XCTAssertFalse(engine.isComposing(), "删除后不应重新进入 composing 状态")
        XCTAssertNil(controller.state.lastRimeOutput?.composition)
    }

    func testSpaceWithEmptyCandidatesResetsRime() {
        _ = controller.handle(.insertKey("n"))
        XCTAssertTrue(engine.isComposing())
        _ = controller.handle(.insertSpace)
        XCTAssertFalse(engine.isComposing(), "无候选时空格也应重置 RIME")
        XCTAssertNil(controller.state.lastRimeOutput?.composition)
    }

    func testResetSessionBetweenKeystrokes() {
        _ = controller.handle(.insertKey("n"))
        _ = controller.handle(.insertKey("i"))
        engine.resetSession()
        XCTAssertFalse(engine.isComposing())
        _ = controller.handle(.insertKey("h"))
        XCTAssertTrue(engine.isComposing())
        XCTAssertEqual(controller.state.lastRimeOutput?.composition?.preeditText, "h")
    }
}
