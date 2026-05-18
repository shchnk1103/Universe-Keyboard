import XCTest
@testable import KeyboardCore

/// 验证 KeyboardController 在 rimeEngine 设置后走 RIME 路径，所有行为与原有路径一致。
final class RimeControllerTests: XCTestCase {

    var controller: KeyboardController!
    var client: FakeTextInputClient!
    var engine: FakeRimeEngine!

    override func setUp() {
        super.setUp()
        client = FakeTextInputClient()
        engine = FakeRimeEngine()
        controller = KeyboardController()
        controller.textClient = client
        controller.rimeEngine = engine
    }

    // MARK: - processKey

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
        // 切换到英文模式，按键应直接上屏而不是走 engine
        controller.state.inputMode = .english
        _ = controller.handle(.insertKey("h"))
        XCTAssertEqual(client.text, "h")
        XCTAssertFalse(engine.isComposing())
    }

    // MARK: - deleteBackward

    func testDeleteBackwardRemovesFromComposition() {
        _ = controller.handle(.insertKey("n"))
        _ = controller.handle(.insertKey("i"))
        _ = controller.handle(.deleteBackward)
        XCTAssertEqual(controller.state.lastRimeOutput?.composition?.preeditText, "n")
        XCTAssertEqual(controller.state.currentComposition, "n")
    }

    func testDeleteBackwardClearsCompositionThenHitsProxy() {
        _ = controller.handle(.insertKey("n"))
        _ = controller.handle(.deleteBackward) // clears "n"
        XCTAssertEqual(controller.state.currentComposition, "")
        XCTAssertFalse(engine.isComposing())

        // proxy 需要有内容才能删除
        // (inline preedit 的 deleteBackward 已在上面消耗了 1 次)
        client.insertText("x")
        _ = controller.handle(.deleteBackward) // now hits proxy
        XCTAssertEqual(client.deletedCount, 2)
    }

    func testDeleteBackwardEmptySkipsEngine() {
        // 确保 proxy 有内容可以删除
        client.insertText("x")
        _ = controller.handle(.deleteBackward)
        XCTAssertEqual(client.deletedCount, 1)
        XCTAssertFalse(engine.isComposing())
    }

    // MARK: - selectCandidate via space

    func testSpaceWithCompositionSelectsFirstCandidate() {
        _ = controller.handle(.insertKey("n"))
        _ = controller.handle(.insertKey("i"))
        _ = controller.handle(.insertSpace)

        XCTAssertEqual(client.text, "你")
        XCTAssertEqual(controller.state.currentComposition, "")
        XCTAssertNil(controller.state.lastRimeOutput?.composition)
    }

    func testSpaceWithUnknownCompositionCommitsRaw() {
        // "zzz" is not in the dictionary
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

    // MARK: - selectCandidate via insertCandidate action

    func testInsertCandidateSelectsByTitle() {
        _ = controller.handle(.insertKey("n"))
        _ = controller.handle(.insertKey("i"))
        // 选第二个候选 "呢"
        _ = controller.handle(.insertCandidate("呢", kind: .candidate))

        XCTAssertEqual(client.text, "呢")
        XCTAssertEqual(controller.state.currentComposition, "")
    }

    func testInsertCandidateCompositionKindCommitsRawAndResets() {
        _ = controller.handle(.insertKey("n"))
        _ = controller.handle(.insertKey("i"))
        _ = controller.handle(.insertCandidate("ni", kind: .composition))

        XCTAssertEqual(client.text, "ni")
        // engine session should be reset
        XCTAssertEqual(engine.sessionResetCount, 1)
        XCTAssertEqual(controller.state.currentComposition, "")
    }

    func testInsertCandidatePlaceholderDoesNothing() {
        _ = controller.handle(.insertKey("n"))
        _ = controller.handle(.insertCandidate("placeholder text", kind: .placeholder))

        XCTAssertEqual(client.text, "n")  // inline preedit
        XCTAssertEqual(controller.state.currentComposition, "n")
    }

    // MARK: - return key

    func testReturnWithCompositionCommitsRaw() {
        _ = controller.handle(.insertKey("n"))
        _ = controller.handle(.insertKey("i"))
        _ = controller.handle(.insertReturn)

        XCTAssertEqual(client.text, "ni")
        XCTAssertEqual(controller.state.currentComposition, "")
    }

    // MARK: - toggle input mode

    func testToggleInputModeResetsEngineSession() {
        _ = controller.handle(.insertKey("n"))
        _ = controller.handle(.insertKey("i"))
        _ = controller.handle(.toggleInputMode)

        XCTAssertEqual(client.text, "ni")    // composition committed
        XCTAssertEqual(engine.sessionResetCount, 1)
        XCTAssertEqual(controller.state.currentComposition, "")
        XCTAssertEqual(controller.state.inputMode, .english)
    }

    // MARK: - toggle page

    func testTogglePageFromLettersResetsEngineSession() {
        _ = controller.handle(.insertKey("n"))
        _ = controller.handle(.togglePage)

        XCTAssertEqual(client.text, "n")     // composition committed
        XCTAssertEqual(engine.sessionResetCount, 1)
        XCTAssertEqual(controller.state.currentComposition, "")
        XCTAssertEqual(controller.state.currentPage, .numbers)
    }

    // MARK: - isComposing

    func testIsComposingTracksState() {
        XCTAssertFalse(engine.isComposing())
        _ = controller.handle(.insertKey("n"))
        XCTAssertTrue(engine.isComposing())
        _ = controller.handle(.insertSpace)
        XCTAssertFalse(engine.isComposing())
    }

    // MARK: - lastRimeOutput evolved over insertions

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

    // MARK: - fallback: nil engine uses manual path

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

    // MARK: - Edge cases

    func testDeleteBackwardWhenProxyIsEmpty() {
        client.text = ""
        _ = controller.handle(.deleteBackward)
        XCTAssertEqual(client.text, "")
        // 无 composition 且 proxy 为空时，delete 应为 no-op
    }

    func testProcessKeyWithEmptyEngineOutput() {
        // 用不存在的组合测试空输出场景
        _ = controller.handle(.insertKey("z"))
        _ = controller.handle(.insertKey("z"))
        _ = controller.handle(.insertKey("z"))
        let effects = controller.handle(.insertKey("z"))
        // engine 无匹配候选时仍应有 composition
        XCTAssertEqual(controller.state.currentComposition, "zzzz")
        XCTAssertTrue(effects.contains(.compositionChanged))
    }

    func testFastTypingStateConsistency() {
        for ch in "nihao" {
            _ = controller.handle(.insertKey(String(ch)))
        }
        XCTAssertEqual(controller.state.currentComposition, "nihao")
        XCTAssertNotNil(controller.state.lastRimeOutput)
        let candidates = controller.state.lastRimeOutput?.candidates ?? []
        XCTAssertGreaterThan(candidates.count, 0)
    }

    func testEngineNilToNonNilTransition() {
        controller.rimeEngine = nil
        _ = controller.handle(.insertKey("h"))
        _ = controller.handle(.insertKey("i"))
        XCTAssertEqual(controller.state.currentComposition, "hi")
        // 切换到 rime engine
        controller.rimeEngine = engine
        _ = controller.handle(.insertKey("n"))
        // rime engine 从头开始（之前手动输入的不进入 engine 状态）
        XCTAssertEqual(engine.sessionResetCount, 0)
    }

    func testDuplicateCandidateTextSelectsFirstMatch() {
        // 当前架构按文本匹配候选；验证行为一致性
        _ = controller.handle(.insertKey("n"))
        _ = controller.handle(.insertKey("i"))
        _ = controller.handle(.insertCandidate("你", kind: .candidate))
        XCTAssertEqual(client.text, "你")
    }

    func testInsertCandidateWithNilLastRimeOutput() {
        controller.state.lastRimeOutput = nil
        _ = controller.handle(.insertCandidate("测试", kind: .candidate))
        // 回退路径：直接上屏文本
        XCTAssertEqual(client.text, "测试")
        XCTAssertEqual(controller.state.currentComposition, "")
    }
}
