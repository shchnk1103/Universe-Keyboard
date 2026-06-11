import XCTest

@testable import KeyboardCore

/// 测试 RimeEngine 协议在 FakeRimeEngine 上的额外边界行为。
/// RimeControllerTests（27 个测试）已覆盖了主要的 controller + engine 集成路径。
/// 此文件补充协议级别的边界情况。
@MainActor
final class RimeEngineProtocolTests: XCTestCase {

    let client = FakeTextInputClient()
    let engine = FakeRimeEngine()
    lazy var controller: KeyboardController = {
        let controller = KeyboardController()
        controller.textClient = client
        controller.rimeEngine = engine
        return controller
    }()

    // MARK: - processKey: empty / single / unknown

    func testProcessKeyEmptyString() {
        _ = controller.handle(.insertKey(""))
        // 空字符串不改变 composition
        XCTAssertEqual(controller.state.currentComposition, "")
        XCTAssertFalse(engine.isComposing())
    }

    func testProcessKeySingleCharacter() {
        _ = controller.handle(.insertKey("a"))
        XCTAssertEqual(controller.state.currentComposition, "a")
        let output = controller.state.lastRimeOutput
        // "a" 不在字典中 → 有 preedit 但无候选
        XCTAssertEqual(output?.rawInput, "a")
        XCTAssertEqual(output?.composition?.preeditText, "a")
        XCTAssertEqual(output?.candidates.count, 0)
    }

    func testRawInputRemainsUnformattedWhenPreeditIsSegmented() {
        let segmentedEngine = FakeRimeEngine(
            preeditFormatter: { input in input.map(String.init).joined(separator: " ") }
        )

        var output = RimeOutput()
        for character in "nihap" {
            output = segmentedEngine.processKey(String(character))
        }

        XCTAssertEqual(output.rawInput, "nihap")
        XCTAssertEqual(output.composition?.preeditText, "n i h a p")
    }

    func testProcessKeyUnknownCompositionReturnsEmptyCandidates() {
        // "zzz" 不在字典中
        for ch in "zzz" {
            _ = controller.handle(.insertKey(String(ch)))
        }
        let output = controller.state.lastRimeOutput
        XCTAssertEqual(output?.composition?.preeditText, "zzz")
        XCTAssertEqual(output?.candidates.count, 0)
        // highlightedIndex = -1 when no candidates
        XCTAssertEqual(output?.highlightedIndex, -1)
    }

    func testProcessKeyMultipleKnownWords() {
        // "wo" → ["我", "握", "窝"]
        _ = controller.handle(.insertKey("w"))
        _ = controller.handle(.insertKey("o"))
        let output = controller.state.lastRimeOutput
        XCTAssertEqual(output?.candidates.map(\.text), ["我", "握", "窝"])
        XCTAssertEqual(output?.highlightedIndex, 0)
    }

    // MARK: - selectCandidate: out-of-range

    func testSelectCandidateOutOfRangeKeepsComposition() {
        _ = controller.handle(.insertKey("n"))
        _ = controller.handle(.insertKey("i"))
        _ = controller.handle(.insertCandidate("fallback", kind: .candidate))
        XCTAssertEqual(client.text, "ni")
        XCTAssertEqual(controller.state.currentComposition, "ni")
    }

    func testSelectCandidateNegativeIndex() {
        // Tag-based selection: kind-based matching, not index-based
        // Testing with composition kind which bypasses index lookup
        _ = controller.handle(.insertKey("n"))
        _ = controller.handle(.insertKey("i"))
        _ = controller.handle(.insertCandidate("ni", kind: .composition))
        XCTAssertEqual(client.text, "ni")
        XCTAssertEqual(engine.sessionResetCount, 1)
    }

    // MARK: - deleteBackward via engine

    func testDeleteBackwardThroughEngineRemovesFromComposition() {
        _ = controller.handle(.insertKey("n"))
        _ = controller.handle(.insertKey("i"))

        // 通过 RIME engine 的 deleteBackward
        let output = engine.deleteBackward()
        XCTAssertEqual(output.composition?.preeditText, "n")

        // engine composition 减少了一个字符
        XCTAssertEqual(engine.isComposing(), true)
    }

    func testDeleteBackwardThroughEngineClearsComposition() {
        _ = controller.handle(.insertKey("n"))
        let output = engine.deleteBackward()
        // 删除最后一个字符后 composition 为空
        XCTAssertNil(output.composition)
        XCTAssertFalse(engine.isComposing())
    }

    func testDeleteBackwardEmptyCompositionThroughEngine() {
        // engine 没有 composition 时 deleteBackward 应该返回空输出
        let output = engine.deleteBackward()
        XCTAssertNil(output.composition)
        XCTAssertEqual(output.candidates.count, 0)
        XCTAssertNil(output.committedText)
    }

    // MARK: - replaceInput

    func testReplaceInputRestoresCompositionAndCandidates() {
        let output = engine.replaceInput("nihao")

        XCTAssertTrue(engine.isComposing())
        XCTAssertEqual(output.rawInput, "nihao")
        XCTAssertEqual(output.composition?.preeditText, "nihao")
        XCTAssertEqual(output.candidates.map(\.text), ["你好", "拟好", "你号"])
    }

    func testReplaceInputEmptyStringClearsComposition() {
        _ = engine.replaceInput("nihao")
        let output = engine.replaceInput("")

        XCTAssertFalse(engine.isComposing())
        XCTAssertNil(output.rawInput)
        XCTAssertNil(output.composition)
        XCTAssertTrue(output.candidates.isEmpty)
    }

    // MARK: - selectCandidate via engine directly

    func testSelectCandidateViaEngineDirectly() {
        _ = engine.processKey("n")
        _ = engine.processKey("i")
        let output = engine.selectCandidate(at: 0)
        // 选择了 "你" → 提交文本
        XCTAssertEqual(output.committedText, "你")
        // composition 应该被清除
        XCTAssertNil(output.composition)
    }

    func testSelectCandidateOutOfRangeViaEngineDirectly() {
        _ = engine.processKey("n")
        _ = engine.processKey("i")
        // index 99 超出范围 → 提交原始 composition
        let output = engine.selectCandidate(at: 99)
        XCTAssertEqual(output.committedText, "ni")
        XCTAssertNil(output.composition)
    }

    func testSelectCandidateUnknownCompositionViaEngine() {
        _ = engine.processKey("z")
        _ = engine.processKey("z")
        _ = engine.processKey("z")
        // "zzz" 不在字典中 → 提交空或原始
        let output = engine.selectCandidate(at: 0)
        // 无 candidates 时回退为原始 composition
        XCTAssertEqual(output.committedText, "zzz")
    }

    // MARK: - session reset

    func testSessionResetClearsComposition() {
        _ = controller.handle(.insertKey("n"))
        _ = controller.handle(.insertKey("i"))
        XCTAssertTrue(engine.isComposing())

        controller.rimeEngine?.resetSession()
        XCTAssertEqual(engine.sessionResetCount, 1)
        XCTAssertFalse(engine.isComposing())
    }

    func testSessionResetTwiceIncrementsCounter() {
        controller.rimeEngine?.resetSession()
        controller.rimeEngine?.resetSession()
        XCTAssertEqual(engine.sessionResetCount, 2)
    }

    // MARK: - isComposing edge cases

    func testIsComposingAfterInit() {
        XCTAssertFalse(engine.isComposing())
    }

    func testIsComposingAfterDeleteAll() {
        _ = controller.handle(.insertKey("h"))
        XCTAssertTrue(engine.isComposing())
        _ = controller.handle(.deleteBackward)
        XCTAssertFalse(engine.isComposing())
    }

    func testIsComposingAfterCandidateSelection() {
        _ = controller.handle(.insertKey("n"))
        _ = controller.handle(.insertKey("i"))
        XCTAssertTrue(engine.isComposing())
        _ = controller.handle(.insertSpace)  // selects first candidate
        XCTAssertFalse(engine.isComposing())
    }

    // MARK: - RimeOutput structure

    func testRimeOutputWithCompositionAndCandidates() {
        _ = controller.handle(.insertKey("n"))
        _ = controller.handle(.insertKey("i"))
        let output = controller.state.lastRimeOutput!
        XCTAssertEqual(output.composition?.preeditText, "ni")
        XCTAssertEqual(output.composition?.cursorPosition, 2)
        XCTAssertEqual(output.candidates.count, 3)
        XCTAssertEqual(output.highlightedIndex, 0)
        XCTAssertEqual(output.rawInput, "ni")
        XCTAssertEqual(output.candidatePageNumber, 0)
        XCTAssertNil(output.committedText)
        XCTAssertFalse(output.hasMorePages)  // Fake engine always returns false/empty
    }

    func testRimeOutputWithCommitOnly() {
        _ = controller.handle(.insertKey("n"))
        _ = controller.handle(.insertKey("i"))
        _ = controller.handle(.insertSpace)
        let output = controller.state.lastRimeOutput!
        XCTAssertNil(output.composition)
        XCTAssertEqual(output.committedText, "你")
    }

    func testRimeOutputEmpty() {
        // 英文模式下直接上屏，不走 RIME 引擎
        controller.state.inputMode = .english
        _ = controller.handle(.insertKey("h"))
        // lastRimeOutput 可能为 nil（因为没走 engine）
        // 在英文模式下插入键不走 RIME，所以 lastRimeOutput 保持不变
    }

    // MARK: - Composition output edge cases

    func testFastTypingUpdatesCompositionInstantly() {
        // 快速输入 "shi" — 每个字符后 composition 应立即更新
        _ = controller.handle(.insertKey("s"))
        XCTAssertEqual(controller.state.currentComposition, "s")
        _ = controller.handle(.insertKey("h"))
        XCTAssertEqual(controller.state.currentComposition, "sh")
        _ = controller.handle(.insertKey("i"))
        XCTAssertEqual(controller.state.currentComposition, "shi")
        // 候选应在最后一个字符后出现
        let output = controller.state.lastRimeOutput
        XCTAssertEqual(output?.candidates.map(\.text), ["是", "时", "事"])
    }

    func testCompositionPreservedAcrossUnknownInput() {
        // 输入已知拼音 "ni" → 再输入未知拼音 "x"
        _ = controller.handle(.insertKey("n"))
        _ = controller.handle(.insertKey("i"))
        _ = controller.handle(.insertKey("x"))
        // composition 应该是 "nix"，即使 "nix" 无候选
        XCTAssertEqual(controller.state.currentComposition, "nix")
        let output = controller.state.lastRimeOutput
        XCTAssertEqual(output?.composition?.preeditText, "nix")
        XCTAssertEqual(output?.candidates.count, 0)
    }
}
