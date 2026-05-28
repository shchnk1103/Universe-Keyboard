import XCTest

@testable import KeyboardCore

@MainActor
final class CompositionTests: XCTestCase {

    let client = FakeTextInputClient()
    lazy var controller: KeyboardController = {
        let controller = KeyboardController()
        controller.textClient = client
        return controller
    }()

    // MARK: - Chinese mode collects letters

    func testChineseModeCollectsLetters() {
        _ = controller.handle(.insertKey("n"))
        XCTAssertEqual(controller.state.currentComposition, "n")
        XCTAssertEqual(client.text, "n")  // inline preedit: 拼音显示在输入框中

        _ = controller.handle(.insertKey("i"))
        XCTAssertEqual(controller.state.currentComposition, "ni")
        XCTAssertEqual(client.text, "ni")  // inline preedit 更新
    }

    func testChineseModeLowercasesInput() {
        _ = controller.handle(.insertKey("N"))
        XCTAssertEqual(controller.state.currentComposition, "n")
        XCTAssertEqual(client.text, "n")  // inline preedit
    }

    func testChineseModeShiftActiveEntersComposition() {
        // 中文模式 + 手动大写 → 首字母保留大小写进入拼音组合
        controller.state.shiftState = .singleUse
        _ = controller.handle(.insertKey("N"))
        XCTAssertEqual(controller.state.currentComposition, "N")
        XCTAssertEqual(client.text, "N")  // inline preedit
        XCTAssertEqual(controller.state.shiftState, .off)
    }

    func testChineseModeShiftActiveThenLowercaseContinuesComposition() {
        // 单次大写消耗后，后续字母小写继续拼音组合
        controller.state.shiftState = .singleUse
        _ = controller.handle(.insertKey("N"))
        _ = controller.handle(.insertKey("i"))
        XCTAssertEqual(controller.state.currentComposition, "Ni")
        XCTAssertEqual(client.text, "Ni")  // inline preedit
    }

    func testCapitalizedCompositionDoesNotMatchCandidates() {
        // 大写拼音不匹配中文候选，空格退回原始拼音上屏
        controller.state.shiftState = .singleUse
        _ = controller.handle(.insertKey("N"))
        _ = controller.handle(.insertKey("i"))
        _ = controller.handle(.insertSpace)
        // "Ni" 匹配不到中文 → 回退到原始拼音
        XCTAssertEqual(client.text, "Ni")
    }

    func testCapitalizedCompositionEnterCommitsAsIs() {
        controller.state.shiftState = .singleUse
        _ = controller.handle(.insertKey("N"))
        _ = controller.handle(.insertKey("i"))
        _ = controller.handle(.insertReturn)
        XCTAssertEqual(client.text, "Ni")
    }

    func testDeleteCapitalizedAndRetypeLowercaseMatchesChinese() {
        // 误触大写 → 删除 → 重新输入小写 → 正常匹配中文
        controller.state.shiftState = .singleUse
        _ = controller.handle(.insertKey("N"))
        _ = controller.handle(.insertKey("i"))
        XCTAssertEqual(controller.state.currentComposition, "Ni")

        // 用户发现误触，删除 "Ni"
        _ = controller.handle(.deleteBackward)
        _ = controller.handle(.deleteBackward)
        XCTAssertEqual(controller.state.currentComposition, "")

        // 重新输入小写 "ni"
        _ = controller.handle(.insertKey("n"))
        _ = controller.handle(.insertKey("i"))
        XCTAssertEqual(controller.state.currentComposition, "ni")

        // 空格选候选
        _ = controller.handle(.insertSpace)
        XCTAssertEqual(client.text, "你")
    }

    // MARK: - English mode inserts directly

    func testEnglishModeInsertsDirectly() {
        controller.state.inputMode = .english
        _ = controller.handle(.insertKey("h"))
        XCTAssertEqual(client.text, "h")
        XCTAssertEqual(controller.state.currentComposition, "")
    }

    func testEnglishModePeriodTriggersAutoCap() {
        controller.state.inputMode = .english
        _ = controller.handle(.insertKey("."))
        XCTAssertEqual(controller.state.shiftState, .singleUse)
    }

    func testEnglishModeExclamationTriggersAutoCap() {
        controller.state.inputMode = .english
        _ = controller.handle(.insertKey("!"))
        XCTAssertEqual(controller.state.shiftState, .singleUse)
    }

    func testEnglishModeQuestionTriggersAutoCap() {
        controller.state.inputMode = .english
        _ = controller.handle(.insertKey("?"))
        XCTAssertEqual(controller.state.shiftState, .singleUse)
    }

    func testEnglishModeLetterDoesNotTriggerAutoCap() {
        controller.state.inputMode = .english
        _ = controller.handle(.insertKey("h"))
        XCTAssertEqual(controller.state.shiftState, .off)
    }

    // MARK: - Numbers page inserts directly

    func testNumbersPageInsertsDirectly() {
        controller.state.currentPage = .numbers
        _ = controller.handle(.insertKey("1"))
        XCTAssertEqual(client.text, "1")
        XCTAssertEqual(controller.state.currentComposition, "")
    }

    // MARK: - Commit composition

    func testCommitComposition() {
        controller.state.currentComposition = "nihao"
        controller.commitComposition()
        XCTAssertEqual(client.text, "nihao")
        XCTAssertEqual(controller.state.currentComposition, "")
    }

    func testCommitCompositionEmptyIsNoOp() {
        controller.commitComposition()
        XCTAssertEqual(client.text, "")
    }

    // MARK: - Commit candidate

    func testCommitCandidate() {
        controller.state.currentComposition = "ni"
        _ = controller.handle(.insertCandidate("你", kind: .candidate))
        XCTAssertEqual(client.text, "你")
        XCTAssertEqual(controller.state.currentComposition, "")
    }

    func testTapCompositionStringCommitsRawPinyin() {
        controller.state.currentComposition = "ni"
        _ = controller.handle(.insertCandidate("ni", kind: .composition))
        XCTAssertEqual(client.text, "ni")
        XCTAssertEqual(controller.state.currentComposition, "")
    }

    func testTapPlaceholderDoesNothing() {
        controller.state.currentComposition = "ni"
        client.text = "existing"
        _ = controller.handle(.insertCandidate("...", kind: .placeholder))
        // Placeholder taps should not change anything
        XCTAssertEqual(client.text, "existing")
        XCTAssertEqual(controller.state.currentComposition, "ni")
    }

    // MARK: - Space selects first candidate

    func testSpaceWithCompositionSelectsFirstCandidate() {
        controller.state.currentComposition = "ni"
        _ = controller.handle(.insertSpace)
        XCTAssertEqual(client.text, "你")
        XCTAssertEqual(controller.state.currentComposition, "")
    }

    func testSpaceWithUnknownCompositionCommitsRaw() {
        controller.state.currentComposition = "xyz"
        _ = controller.handle(.insertSpace)
        XCTAssertEqual(client.text, "xyz")
        XCTAssertEqual(controller.state.currentComposition, "")
    }

    // MARK: - Edge cases

    func testCompositionWithSpecialChars() {
        // 数字和符号页的字符直接上屏
        _ = controller.handle(.togglePage)  // switch to numbers
        _ = controller.handle(.insertKey("1"))
        XCTAssertEqual(client.text, "1")
        XCTAssertEqual(controller.state.currentComposition, "")
    }

    func testCompositionMaxLength() {
        let longPinyin = String(repeating: "abcdefghij", count: 10)
        for ch in longPinyin {
            _ = controller.handle(.insertKey(String(ch)))
        }
        XCTAssertEqual(controller.state.currentComposition, longPinyin)
    }

    func testCompositionToggleDuringPreedit() {
        _ = controller.handle(.insertKey("n"))
        _ = controller.handle(.insertKey("i"))
        XCTAssertEqual(controller.state.currentComposition, "ni")
        _ = controller.handle(.toggleInputMode)
        XCTAssertEqual(controller.state.currentComposition, "")
        XCTAssertEqual(client.text, "ni")
    }
}
