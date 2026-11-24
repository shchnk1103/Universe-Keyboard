import XCTest

@testable import KeyboardCore

/// PB-013 标点回弹后候选栏续接：触发、连打链、退出矩阵、互斥与效果语义。
@MainActor
final class PunctuationContinuationTests: XCTestCase {
    private let provider = BundledContinuationSuggestionProvider(entries: [
        ContinuationEntry(context: "吃", suggestions: ["了"]),
        ContinuationEntry(context: "吃了", suggestions: ["吗", "饭"]),
    ])

    private func makeController(client: FakeTextInputClient) -> KeyboardController {
        let controller = KeyboardController(continuationSuggestionProvider: provider)
        controller.textClient = client
        return controller
    }

    /// 前置：中文 letters 页、开关默认开。切到符号页提交标点触发回弹续接。
    private func commitSymbol(_ symbol: String, from controller: KeyboardController) -> KeyboardEffect {
        _ = controller.handle(.togglePage)  // letters -> numbers
        _ = controller.handle(.togglePage)  // numbers -> symbols
        return controller.handle(.insertKey(symbol))
    }

    // MARK: - 目录（内置静态集合，零 IO 纯内存查表）

    func testCatalogContainsHumanApprovedContinuationSets() {
        XCTAssertEqual(
            PunctuationContinuationCatalog.continuationSets["！"],
            ["？", "！", "……", "——", "”", "）"]
        )
        XCTAssertEqual(
            PunctuationContinuationCatalog.continuationSets["？"],
            ["！", "？", "……", "——", "”", "）"]
        )
        XCTAssertEqual(PunctuationContinuationCatalog.continuationSets["。"], ["”", "）", "……", "——"])
        XCTAssertEqual(PunctuationContinuationCatalog.continuationSets["，"], ["”", "……"])
        XCTAssertNil(PunctuationContinuationCatalog.candidates(forTrigger: "@"))
        XCTAssertNil(PunctuationContinuationCatalog.candidates(forTrigger: "（）"))
        XCTAssertNil(PunctuationContinuationCatalog.candidates(forTrigger: "……"))
        // 纯内存查表：同查询重复执行结果恒等，无文件/网络副作用。
        let first = PunctuationContinuationCatalog.candidates(forTrigger: "！")
        let second = PunctuationContinuationCatalog.candidates(forTrigger: "！")
        XCTAssertEqual(first, second)
    }

    // MARK: - 触发与默认续接集合

    func testOneShotChinesePunctuationArmsContinuationAndBouncesToLetters() {
        let client = FakeTextInputClient()
        let controller = makeController(client: client)

        let effects = commitSymbol("！", from: controller)

        XCTAssertEqual(client.text, "！")
        XCTAssertEqual(controller.state.currentPage, .letters)
        XCTAssertEqual(controller.state.punctuationContinuation?.trigger, "！")
        XCTAssertEqual(
            controller.state.punctuationContinuation?.candidates,
            ["？", "！", "……", "——", "”", "）"]
        )
        XCTAssertTrue(effects.contains(.continuationChanged))
    }

    func testNonCatalogSymbolDoesNotArmAndKeepsLegacyContextRefresh() {
        let client = FakeTextInputClient()
        let controller = makeController(client: client)
        _ = controller.handle(.insertDirectText("吃了"))

        let contextBefore = controller.state.continuation.context
        _ = commitSymbol("@", from: controller)

        XCTAssertNil(controller.state.punctuationContinuation)
        XCTAssertEqual(controller.state.continuation.context, contextBefore + "@")
    }

    func testPairedOpenBracketNormalizesByAppendedTextAndDoesNotArm() {
        let client = FakeTextInputClient()
        let controller = makeController(client: client)

        // （ 成对补全后最终上屏文本为 （），不在触发集合。
        _ = commitSymbol("（", from: controller)

        XCTAssertEqual(client.text, "（）")
        XCTAssertNil(controller.state.punctuationContinuation)
    }

    func testDisabledPostCommitContinuationNeverArms() {
        let client = FakeTextInputClient()
        let controller = makeController(client: client)
        _ = controller.setPostCommitContinuationEnabled(false)

        _ = commitSymbol("！", from: controller)

        XCTAssertNil(controller.state.punctuationContinuation)
    }

    func testEnglishModeNeverArms() {
        let client = FakeTextInputClient()
        let controller = makeController(client: client)
        _ = controller.handle(.toggleInputMode)  // english
        _ = controller.handle(.toggleInputMode)  // chinese（清空续接态）
        _ = controller.handle(.toggleInputMode)  // english again

        _ = controller.handle(.togglePage)
        _ = controller.handle(.togglePage)
        _ = controller.handle(.insertKey("!"))

        XCTAssertNil(controller.state.punctuationContinuation)
    }

    func testArmedContinuationSuppressesAssociationContextWrite() {
        let client = FakeTextInputClient()
        let controller = makeController(client: client)
        _ = controller.handle(.insertDirectText("吃了"))
        let contextBefore = controller.state.continuation.context

        _ = commitSymbol("！", from: controller)

        // m2/设计：续接态与 refreshContinuation 二选一，标点不污染联想 context。
        XCTAssertEqual(controller.state.continuation.context, contextBefore)
    }

    // MARK: - 候选栏优先级与连打链（Core 语义层）

    func testContinuationChainExclamationQuestionEllipsis() {
        let client = FakeTextInputClient()
        let controller = makeController(client: client)

        _ = commitSymbol("！", from: controller)

        let secondEffects = controller.handle(.insertCandidate("？", kind: .continuationCandidate))
        XCTAssertEqual(client.text, "！？")
        XCTAssertEqual(controller.state.punctuationContinuation?.trigger, "？")
        XCTAssertEqual(
            controller.state.punctuationContinuation?.candidates,
            ["！", "？", "……", "——", "”", "）"]
        )
        XCTAssertEqual(secondEffects, .continuationChanged)

        let thirdEffects = controller.handle(.insertCandidate("……", kind: .continuationCandidate))
        XCTAssertEqual(client.text, "！？……")
        // …… 不在触发集合：链尾上屏后退出续接态。
        XCTAssertNil(controller.state.punctuationContinuation)
        XCTAssertEqual(thirdEffects, .continuationChanged)
        // 连打全程标点不污染联想 context。
        XCTAssertEqual(controller.state.continuation.context, "")
    }

    func testContinuationClickIgnoresForeignCandidateWhileArmed() {
        let client = FakeTextInputClient()
        let controller = makeController(client: client)
        _ = commitSymbol("！", from: controller)

        let effects = controller.handle(.insertCandidate("吗", kind: .continuationCandidate))

        XCTAssertEqual(client.text, "！")
        XCTAssertEqual(controller.state.punctuationContinuation?.trigger, "！")
        XCTAssertTrue(effects.isEmpty)
    }

    // MARK: - 退出矩阵

    func testLetterKeyExitsContinuation() {
        let client = FakeTextInputClient()
        let controller = makeController(client: client)
        _ = commitSymbol("！", from: controller)

        _ = controller.handle(.insertKey("n"))

        XCTAssertNil(controller.state.punctuationContinuation)
    }

    func testDigitKeyExitsContinuation() {
        let client = FakeTextInputClient()
        let controller = makeController(client: client)
        _ = commitSymbol("！", from: controller)

        _ = controller.handle(.togglePage)  // letters -> numbers
        _ = controller.handle(.insertKey("5"))

        XCTAssertNil(controller.state.punctuationContinuation)
    }

    func testBackspaceExitsContinuation() {
        let client = FakeTextInputClient()
        let controller = makeController(client: client)
        _ = commitSymbol("！", from: controller)

        let effects = controller.handle(.deleteBackward)

        XCTAssertEqual(client.text, "")
        XCTAssertNil(controller.state.punctuationContinuation)
        XCTAssertTrue(effects.contains(.continuationChanged))
    }

    func testPageSwitchExitsContinuation() {
        let client = FakeTextInputClient()
        let controller = makeController(client: client)
        _ = commitSymbol("！", from: controller)

        _ = controller.handle(.togglePage)

        XCTAssertNil(controller.state.punctuationContinuation)
    }

    func testInputModeSwitchExitsContinuation() {
        let client = FakeTextInputClient()
        let controller = makeController(client: client)
        _ = commitSymbol("！", from: controller)

        _ = controller.handle(.toggleInputMode)

        XCTAssertNil(controller.state.punctuationContinuation)
    }

    func testKeyboardTypeChangeExitsContinuation() {
        let client = FakeTextInputClient()
        let controller = makeController(client: client)
        _ = commitSymbol("！", from: controller)

        _ = controller.handle(.keyboardTypeChanged(.emailAddress))

        XCTAssertNil(controller.state.punctuationContinuation)
    }

    func testExternalDocumentChangeExitsContinuation() {
        let client = FakeTextInputClient()
        let controller = makeController(client: client)
        _ = commitSymbol("！", from: controller)

        let effects = controller.noteExternalDocumentChange()

        XCTAssertNil(controller.state.punctuationContinuation)
        XCTAssertTrue(effects.contains(.continuationChanged))
    }

    func testT9CommonPunctuationExitsContinuationAndArmsPending() {
        let client = FakeTextInputClient()
        let controller = makeController(client: client)
        _ = commitSymbol("！", from: controller)

        _ = controller.handle(.pressT9CommonPunctuation)

        XCTAssertNil(controller.state.punctuationContinuation)
        XCTAssertNotNil(controller.state.pendingPunctuation)
    }

    func testPendingPunctuationSelectionExitsContinuation() {
        let client = FakeTextInputClient()
        let controller = makeController(client: client)
        _ = commitSymbol("！", from: controller)
        _ = controller.handle(.pressT9CommonPunctuation)

        // pendingPunctuation 点选路径（m3 其他候选类目）：续接态不得残留。
        // 注：pending 态武装本身已先行清空续接态，此处断言状态不残留。
        _ = controller.handle(.insertCandidate("，", kind: .punctuationCandidate))

        XCTAssertNil(controller.state.punctuationContinuation)
    }

    func testKaomojiSelectionExitsContinuation() {
        let client = FakeTextInputClient()
        let controller = makeController(client: client)
        _ = commitSymbol("！", from: controller)

        let effects = controller.handle(.insertCandidate("(⊙_⊙)", kind: .kaomojiCandidate))

        XCTAssertNil(controller.state.punctuationContinuation)
    }

    func testRimeCandidateSelectionExitsContinuation() {
        let client = FakeTextInputClient()
        let controller = makeController(client: client)
        _ = commitSymbol("！", from: controller)

        _ = controller.handle(.insertCandidate("字", kind: .candidate))

        XCTAssertNil(controller.state.punctuationContinuation)
    }

    func testDisablingPostCommitContinuationClearsArmedState() {
        let client = FakeTextInputClient()
        let controller = makeController(client: client)
        _ = commitSymbol("！", from: controller)
        XCTAssertEqual(controller.state.punctuationContinuation?.trigger, "！")

        let effects = controller.setPostCommitContinuationEnabled(false)

        XCTAssertNil(controller.state.punctuationContinuation)
        XCTAssertTrue(effects.contains(.continuationChanged))
    }
}
