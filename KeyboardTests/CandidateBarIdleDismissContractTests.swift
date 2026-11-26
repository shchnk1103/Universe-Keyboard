import XCTest

final class CandidateBarIdleDismissContractTests: XCTestCase {
    func testTrailingButtonWiresDismissAndKeepsExpand() throws {
        let bar = try sourceFile("Keyboard/Controllers/KeyboardViewController+CandidateBar.swift")
        let panel = try sourceFile(
            "Keyboard/Controllers/KeyboardViewController+ExpandedCandidatePanel.swift"
        )
        let view = try sourceFile("Keyboard/Views/CandidateBar/CandidateBarView.swift")

        XCTAssertTrue(bar.contains("handleCandidateBarTrailingButton"))
        XCTAssertTrue(bar.contains("dismissKeyboard()"))
        XCTAssertTrue(bar.contains("expandsCandidateBarPanel"))
        XCTAssertTrue(bar.contains("allowsSwipeToExpand = canExpand"))
        XCTAssertFalse(bar.contains("candidateExpandButtonWidthConstraint?.constant = 56"))
        XCTAssertTrue(panel.contains("关闭键盘"))
        XCTAssertTrue(panel.contains("button.configuration = nil"))
        XCTAssertTrue(view.contains("var allowsSwipeToExpand"))
        XCTAssertTrue(view.contains("guard allowsSwipeToExpand else { return false }"))
        XCTAssertFalse(view.contains("chevron.down.circle"))
        XCTAssertTrue(view.contains("chevron.down"))
        XCTAssertTrue(view.contains("candidateActionSeparator"))
        XCTAssertTrue(view.contains("alwaysTemplate"))
        XCTAssertTrue(view.contains("CandidateBarExpandButton(type: .custom)"))
        XCTAssertFalse(view.contains("UIButton.Configuration"))
        XCTAssertFalse(view.contains("keyboard.chevron.compact.down"))
    }

    /// PB-021-NUMPAD-SWIPE-EXPAND-001：`allowsSwipeToExpand` 与尾按钮 `canExpand`
    /// 口径必须完全一致（数字快捷栏重建后仍可下滑展开；无候选且非快捷栏仍为 false）。
    func testSwipeToExpandFlagMatchesTrailingButtonCanExpandContract() throws {
        let bar = try sourceFile("Keyboard/Controllers/KeyboardViewController+CandidateBar.swift")

        // 三处（尾按钮、fillCandidateBar、syncT9NumberPadShortcutStrip early-return）
        // 统一经同一计算属性取口径，杜绝表达式漂移。
        XCTAssertTrue(bar.contains("var canExpandCandidateBar"), "缺少统一口径计算属性")
        let usages = bar.components(separatedBy: "canExpandCandidateBar").count - 1
        XCTAssertGreaterThanOrEqual(usages, 4, "口径属性应被尾按钮与旗标路径共同引用")

        // 口径定义：有可展开候选，或数字快捷栏激活；空闲非快捷栏态为 false。
        XCTAssertTrue(bar.contains("presentedCandidates.contains { $0.kind.expandsCandidateBarPanel }"))
        XCTAssertTrue(bar.contains("|| isT9NumberPadShortcutStripActive"))

        // 重建路径把旗标落到新建 bar；翻转分支落到传入 bar。
        XCTAssertTrue(
            bar.contains(
                "fillCandidateBar(keepScrollPosition: Bool = false, on targetBar: CandidateBarView? = nil)"))
        XCTAssertTrue(
            bar.contains("fillCandidateBar(on: view)"),
            "makeCandidateBar 应把旗标落到新建 bar 上")
        XCTAssertTrue(
            bar.contains("fillCandidateBar(on: bar)"),
            "syncT9NumberPadShortcutStrip 翻转分支应把旗标落到传入 bar 上")

        // 尾按钮与 fillCandidateBar 经同一口径绑定 canExpand。
        let canExpandBindings = bar.components(separatedBy: "let canExpand = canExpandCandidateBar").count - 1
        XCTAssertGreaterThanOrEqual(canExpandBindings, 2)

        // early-return 且 show == true 时补齐旗标（12 空格缩进锚点，区分 fillCandidateBar 本地绑定）。
        XCTAssertTrue(
            bar.contains("bar.allowsSwipeToExpand = canExpandCandidateBar\n            }"),
            "syncT9NumberPadShortcutStrip early-return 且 show == true 时应补齐旗标")
    }

    private func sourceFile(_ relativePath: String) throws -> String {
        let testsDirectory = URL(fileURLWithPath: #filePath).deletingLastPathComponent()
        let repositoryRoot = testsDirectory.deletingLastPathComponent()
        return try String(contentsOf: repositoryRoot.appendingPathComponent(relativePath), encoding: .utf8)
    }
}
