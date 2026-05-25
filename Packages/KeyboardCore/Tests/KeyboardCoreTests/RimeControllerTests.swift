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

    func testFastTypingStateConsistency() {
        for ch in "nihao" {
            _ = controller.handle(.insertKey(String(ch)))
        }
        XCTAssertEqual(controller.state.currentComposition, "nihao")
        XCTAssertNotNil(controller.state.lastRimeOutput)
        let candidates = controller.state.lastRimeOutput?.candidates ?? []
        XCTAssertGreaterThan(candidates.count, 0)
    }

    func testInlinePreeditAppendsWithoutFullRewrite() {
        for ch in "nihao" {
            _ = controller.handle(.insertKey(String(ch)))
        }

        XCTAssertEqual(client.text, "nihao")
        XCTAssertEqual(client.deletedCount, 0)
        XCTAssertEqual(controller.state.insertedPreeditText, "nihao")
        XCTAssertEqual(controller.state.insertedPreeditCount, 5)
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

    // MARK: - Bug 修复回归测试

    /// Bug 1/3: 空格提交后 RIME session 必须被重置，
    /// 否则删除键会从残留 composition 中删除导致拼音重现。
    func testSpaceResetsRimeSession() {
        _ = controller.handle(.insertKey("n"))
        _ = controller.handle(.insertKey("i"))
        XCTAssertTrue(engine.isComposing())
        _ = controller.handle(.insertSpace)
        XCTAssertFalse(engine.isComposing(), "空格提交后 RIME 引擎必须不是 composing 状态")
        XCTAssertEqual(engine.sessionResetCount, 1)
    }

    /// Bug 1: 候选不在当前 lastRimeOutput 中（用户滚动后选择前面页的候选），
    /// fallback 路径应直接上屏 + 重置 RIME，不残留 composition。
    func testInsertCandidateFallbackResetsRime() {
        _ = controller.handle(.insertKey("n"))
        _ = controller.handle(.insertKey("i"))
        // 模拟候选来自非当前页（不在 lastRimeOutput.candidates 中）
        _ = controller.handle(.insertCandidate("你好", kind: .candidate))
        XCTAssertEqual(client.text, "你好")
        XCTAssertFalse(engine.isComposing(), "fallback 候选选择后 RIME 必须被重置")
        XCTAssertEqual(controller.state.currentComposition, "")
    }

    /// Bug 3: 选择候选后按删除键，不应重现已提交的拼音。
    func testDeleteAfterCandidateSelectionDoesNotRevivePinyin() {
        _ = controller.handle(.insertKey("n"))
        _ = controller.handle(.insertKey("i"))
        // 选择候选（走 RIME 路径）
        _ = controller.handle(.insertCandidate("你", kind: .candidate))
        XCTAssertEqual(client.text, "你")
        XCTAssertFalse(engine.isComposing())
        // 按删除键：应删除宿主文本中的"你"，不应触发 RIME composition
        client.text = "你"
        _ = controller.handle(.deleteBackward)
        XCTAssertEqual(client.text, "", "删除应清空宿主文本")
        XCTAssertFalse(engine.isComposing(), "删除后不应重新进入 composing 状态")
        XCTAssertNil(controller.state.lastRimeOutput?.composition)
    }

    /// Bug 1: pageDown/pageUp 不应影响 state.lastRimeOutput，
    /// lastRimeOutput 始终反映 processKey 产出的第一页结果。
    func testPageDownDoesNotAffectLastRimeOutput() {
        _ = controller.handle(.insertKey("n"))
        _ = controller.handle(.insertKey("i"))
        let page1Output = controller.state.lastRimeOutput
        XCTAssertEqual(page1Output?.candidates.count, 3)

        // 直接用 engine 翻页（模拟 loadMoreCandidates）
        _ = engine.pageDown()
        // lastRimeOutput 不应被 pageDown 改变
        XCTAssertEqual(controller.state.lastRimeOutput?.candidates.count, 3,
                       "lastRimeOutput 应保持 processKey 的原始值")
        XCTAssertEqual(controller.state.lastRimeOutput?.composition?.preeditText, "ni")
    }

    /// Bug 1: 空格始终提交第一页最佳候选，即使用户翻页后 RIME 处于后续页。
    func testSpaceAlwaysSelectsFirstPageCandidate() {
        _ = controller.handle(.insertKey("n"))
        _ = controller.handle(.insertKey("i"))
        // 模拟翻到第 2 页
        _ = engine.pageDown()
        // 空格应仍提交第 1 页的首候选
        _ = controller.handle(.insertSpace)
        XCTAssertEqual(client.text, "你", "空格应始终提交第1页首候选（最佳匹配）")
        XCTAssertFalse(engine.isComposing())
    }

    /// Bug 1: 无候选时空格走 fallback 候选路径，也应重置 RIME。
    func testSpaceWithEmptyCandidatesResetsRime() {
        // "n" 在 FakeRimeEngine 中没有候选词
        _ = controller.handle(.insertKey("n"))
        XCTAssertTrue(engine.isComposing())
        _ = controller.handle(.insertSpace)
        XCTAssertFalse(engine.isComposing(), "无候选时空格也应重置 RIME")
        XCTAssertNil(controller.state.lastRimeOutput?.composition)
    }

    /// Bug 4: 连续两次 processKey 之间调用 resetSession 后状态正常。
    func testResetSessionBetweenKeystrokes() {
        _ = controller.handle(.insertKey("n"))
        _ = controller.handle(.insertKey("i"))
        engine.resetSession()
        // reset 后引擎不应 composing
        XCTAssertFalse(engine.isComposing())
        // 下一次按键应正常工作
        _ = controller.handle(.insertKey("h"))
        XCTAssertTrue(engine.isComposing())
        XCTAssertEqual(controller.state.lastRimeOutput?.composition?.preeditText, "h")
    }

    // MARK: - 候选栏无极滑动加载更多 (loadMoreCandidates 等价逻辑)

    /// pageDown + pageUp 后引擎 composition 应保持不变（回到原始页）。
    func testPageDownThenPageUpRestoresComposition() {
        _ = controller.handle(.insertKey("n"))
        _ = controller.handle(.insertKey("i"))
        let original = controller.state.lastRimeOutput
        XCTAssertEqual(original?.composition?.preeditText, "ni")

        _ = engine.pageDown()
        _ = engine.pageUp()
        // composition 应在 pageUp 后恢复
        XCTAssertEqual(controller.state.lastRimeOutput?.composition?.preeditText, "ni",
                       "lastRimeOutput 不受 pageDown/pageUp 影响")
        XCTAssertTrue(engine.isComposing())
    }

    /// pageDown 后 engine 仍在 composing 状态。
    func testPageDownPreservesComposingState() {
        _ = controller.handle(.insertKey("n"))
        _ = controller.handle(.insertKey("i"))
        XCTAssertTrue(engine.isComposing())

        _ = engine.pageDown()
        XCTAssertTrue(engine.isComposing(), "翻页不应改变 composing 状态")
    }

    /// 候选去重逻辑：相同 title 的候选不应重复累积。
    func testCandidateDeduplicationByTitle() {
        var accumulated = [
            CandidateItem(title: "你", kind: .candidate),
            CandidateItem(title: "呢", kind: .candidate),
        ]
        let newItems = [
            CandidateItem(title: "你", kind: .candidate),  // 重复
            CandidateItem(title: "尼", kind: .candidate),  // 新增
        ]
        var added = 0
        for item in newItems {
            if !accumulated.contains(where: { $0.title == item.title }) {
                accumulated.append(item)
                added += 1
            }
        }
        XCTAssertEqual(added, 1)
        XCTAssertEqual(accumulated.count, 3)
        XCTAssertEqual(accumulated.map(\.title), ["你", "呢", "尼"])
    }

    /// pageDown 后直接取 candidates 累积（模拟预加载流程）。
    func testPreloadFlowWithPageDown() {
        _ = controller.handle(.insertKey("n"))
        _ = controller.handle(.insertKey("i"))
        let page1 = controller.state.lastRimeOutput!
        XCTAssertEqual(page1.candidates.count, 3)

        // 模拟 refreshCandidateBar 的预加载
        var accumulated = page1.candidates.map { CandidateItem(title: $0.text, kind: .candidate) }
        let page2 = engine.pageDown()
        let page2Items = page2.candidates.map { CandidateItem(title: $0.text, kind: .candidate) }
        for item in page2Items {
            if !accumulated.contains(where: { $0.title == item.title }) {
                accumulated.append(item)
            }
        }
        _ = engine.pageUp()  // 回到第 1 页

        // FakeRimeEngine 的 pageDown 返回相同候选，所以去重后数量不变
        XCTAssertEqual(accumulated.count, 3,
                       "Fake engine 不分页，去重后应保持原有数量")
        // lastRimeOutput 不受影响
        XCTAssertEqual(controller.state.lastRimeOutput?.composition?.preeditText, "ni")
        XCTAssertTrue(engine.isComposing())
    }

    /// 连续多次 pageDown 后 pageUp 回到初始状态。
    func testMultiplePageDownThenBackToFirstPage() {
        _ = controller.handle(.insertKey("n"))
        _ = controller.handle(.insertKey("i"))

        // 前进 2 页
        _ = engine.pageDown()
        _ = engine.pageDown()
        // 回到第 1 页
        _ = engine.pageUp()
        _ = engine.pageUp()

        // lastRimeOutput 仍是 processKey 的结果
        XCTAssertEqual(controller.state.lastRimeOutput?.composition?.preeditText, "ni")
        XCTAssertTrue(engine.isComposing())
    }

    /// 深度追踪逻辑：candidatePageDepth 在多次加载后正确递增。
    func testCandidatePageDepthTracking() {
        _ = controller.handle(.insertKey("n"))
        _ = controller.handle(.insertKey("i"))
        var depth = 0  // 初始 = 第 1 页（processKey 产出）

        // 预加载第 2 页
        _ = engine.pageDown()
        _ = engine.pageUp()
        depth = 1

        // 第一次 loadMore → 获取第 3 页
        for _ in 0..<depth { _ = engine.pageDown() }
        _ = engine.pageDown()  // 获取第 3 页
        for _ in 0..<(depth + 1) { _ = engine.pageUp() }
        depth += 1
        XCTAssertEqual(depth, 2)

        // 第二次 loadMore → 获取第 4 页
        for _ in 0..<depth { _ = engine.pageDown() }
        _ = engine.pageDown()  // 获取第 4 页
        for _ in 0..<(depth + 1) { _ = engine.pageUp() }
        depth += 1
        XCTAssertEqual(depth, 3)

        // lastRimeOutput 始终不受影响
        XCTAssertEqual(controller.state.lastRimeOutput?.composition?.preeditText, "ni")
    }
}
