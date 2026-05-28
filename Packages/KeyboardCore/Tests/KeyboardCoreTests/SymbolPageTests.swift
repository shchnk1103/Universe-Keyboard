import XCTest

@testable import KeyboardCore

/// 测试符号页和数字页在不同输入模式下的行为。
///
/// UI 层的内容（具体显示哪些字符）定义在 KeyboardViewController 中，
/// 这里测试底层状态机和 Key 分类逻辑的正确性。
@MainActor
final class SymbolPageTests: XCTestCase {

    let client = FakeTextInputClient()
    lazy var controller: KeyboardController = {
        let controller = KeyboardController()
        controller.textClient = client
        return controller
    }()

    // MARK: - KeyboardPage enumeration

    func testAllPagesExist() {
        // 验证 4 个页面都存在
        XCTAssertEqual(KeyboardPage.letters, .letters)
        XCTAssertEqual(KeyboardPage.numbers, .numbers)
        XCTAssertEqual(KeyboardPage.symbols, .symbols)
        XCTAssertEqual(KeyboardPage.emoji, .emoji)
    }

    func testPageEquality() {
        XCTAssertEqual(KeyboardPage.letters, KeyboardPage.letters)
        XCTAssertNotEqual(KeyboardPage.numbers, KeyboardPage.symbols)
        XCTAssertNotEqual(KeyboardPage.symbols, KeyboardPage.emoji)
    }

    // MARK: - Input mode transitions from different pages

    func testChineseToEnglishFromLettersPage() {
        controller.state.currentPage = .letters
        controller.state.inputMode = .chinese
        let effects = controller.handle(.toggleInputMode)
        XCTAssertEqual(controller.state.inputMode, .english)
        XCTAssertTrue(effects.contains(.inputModeChanged))
        // 从字母页切换不改变页码
        XCTAssertFalse(effects.contains(.pageChanged))
    }

    func testChineseToEnglishFromNumbersPage() {
        controller.state.currentPage = .numbers
        controller.state.inputMode = .chinese
        let effects = controller.handle(.toggleInputMode)
        XCTAssertEqual(controller.state.inputMode, .english)
        XCTAssertTrue(effects.contains(.inputModeChanged))
        // 从非字母页切换 → 回到字母页
        XCTAssertTrue(effects.contains(.pageChanged))
        XCTAssertEqual(controller.state.currentPage, .letters)
    }

    func testChineseToEnglishFromSymbolsPage() {
        controller.state.currentPage = .symbols
        controller.state.inputMode = .chinese
        let effects = controller.handle(.toggleInputMode)
        XCTAssertEqual(controller.state.inputMode, .english)
        XCTAssertTrue(effects.contains(.inputModeChanged))
        XCTAssertTrue(effects.contains(.pageChanged))
        XCTAssertEqual(controller.state.currentPage, .letters)
    }

    func testChineseToEnglishFromEmojiPage() {
        controller.state.currentPage = .emoji
        controller.state.inputMode = .chinese
        let effects = controller.handle(.toggleInputMode)
        XCTAssertEqual(controller.state.inputMode, .english)
        XCTAssertTrue(effects.contains(.inputModeChanged))
        XCTAssertTrue(effects.contains(.pageChanged))
        XCTAssertEqual(controller.state.currentPage, .letters)
    }

    func testEnglishToChineseFromSymbolsPage() {
        controller.state.currentPage = .symbols
        controller.state.inputMode = .english
        let effects = controller.handle(.toggleInputMode)
        XCTAssertEqual(controller.state.inputMode, .chinese)
        XCTAssertTrue(effects.contains(.inputModeChanged))
        XCTAssertTrue(effects.contains(.pageChanged))
        XCTAssertEqual(controller.state.currentPage, .letters)
    }

    // MARK: - Mode switch commits composition then resets page

    func testModeSwitchFromSymbolsCommitsComposition() {
        controller.state.currentPage = .symbols
        controller.state.inputMode = .chinese
        controller.state.currentComposition = "ni"
        let effects = controller.handle(.toggleInputMode)

        // 拼音组合被提交
        XCTAssertEqual(client.text, "ni")
        XCTAssertEqual(controller.state.currentComposition, "")
        // 页面回到字母
        XCTAssertEqual(controller.state.currentPage, .letters)
        // effect 应该包含 compositionChanged
        XCTAssertTrue(effects.contains(.compositionChanged))
    }

    func testModeSwitchFromEmojiCommitsComposition() {
        controller.state.currentPage = .emoji
        controller.state.inputMode = .chinese
        controller.state.currentComposition = "hao"
        let effects = controller.handle(.toggleInputMode)

        XCTAssertEqual(client.text, "hao")
        XCTAssertEqual(controller.state.currentComposition, "")
        XCTAssertEqual(controller.state.currentPage, .letters)
        XCTAssertTrue(effects.contains(.compositionChanged))
    }

    // MARK: - effect composition on page + mode change simultaneously

    func testToggleModeFromSymbolsReturnsBothEffects() {
        controller.state.currentPage = .symbols
        let effects = controller.handle(.toggleInputMode)
        // 应同时包含 inputModeChanged 和 pageChanged
        XCTAssertTrue(effects.contains(.inputModeChanged))
        XCTAssertTrue(effects.contains(.pageChanged))
    }

    // MARK: - RIME path: mode switch resets engine

    func testModeSwitchWithRimeEngineFromSymbols() {
        let engine = FakeRimeEngine()
        controller.rimeEngine = engine
        // 先在字母页建立 RIME composition
        controller.state.currentPage = .letters
        controller.state.inputMode = .chinese
        _ = controller.handle(.insertKey("n"))
        _ = controller.handle(.insertKey("i"))
        XCTAssertTrue(engine.isComposing())

        // 切换到符号页（composition 被提交，因为离开字母页时 commit 了）
        _ = controller.handle(.togglePage)  // → numbers
        _ = controller.handle(.togglePage)  // → symbols
        XCTAssertEqual(controller.state.currentPage, .symbols)
        // 从字母页切换走时 composition 已提交
        // 现在的 composition 为空

        // 在符号页切换输入模式 → 回到字母页
        _ = controller.handle(.toggleInputMode)
        XCTAssertEqual(controller.state.currentPage, .letters)
        XCTAssertEqual(controller.state.inputMode, .english)
    }

    // MARK: - KeyboardAction enumeration completeness

    func testAllKeyboardActionsDefined() {
        // 验证新增的 action case 被正确处理
        let actions: [KeyboardAction] = [
            .candidatePageUp,
            .candidatePageDown,
            .togglePage,
            .toggleInputMode,
        ]
        for action in actions {
            // 每个 action 都应该能被 handle 处理而不崩溃
            _ = controller.handle(action)
        }
    }

    func testCandidatePageActionsAreEquatable() {
        XCTAssertEqual(KeyboardAction.candidatePageUp, .candidatePageUp)
        XCTAssertEqual(KeyboardAction.candidatePageDown, .candidatePageDown)
        XCTAssertNotEqual(KeyboardAction.candidatePageUp, .candidatePageDown)
        XCTAssertNotEqual(KeyboardAction.candidatePageUp, .togglePage)
    }
}
