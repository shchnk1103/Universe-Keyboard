/// 键盘所有可能的用户操作。
/// 这是 UI 层（ViewController）和业务逻辑层（KeyboardController）之间的"消息类型"。
/// UI 层负责把用户手势翻译成 KeyboardAction，然后发送给 controller.handle(_:)。
/// Controller 处理后返回 KeyboardEffect，告诉 UI 层该刷新什么。
public enum KeyboardAction: Equatable {
    case insertKey(String)
    /// 插入候选词/拼音组合。kind 参数决定行为：
    /// - .candidate: 选择普通 RIME 候选；若 RIME 仍有剩余输入，则进入部分确认状态
    /// - .composition: 提交原始拼音
    /// - .placeholder: 无操作（按钮已被禁用，这里是安全网）
    case insertCandidate(
        String,
        kind: CandidateKind,
        selectionReference: CandidateSelectionReference? = nil
    )
    /// 插入误触纠错候选。当前真实 composition 保持原样展示到用户点选为止；
    /// 点选后直接提交纠错候选文本并清空 RIME session。
    case insertCorrectionCandidate(TypoCorrectionCommit)
    case insertDirectText(String)
    /// 九键数字页直出。不走符号页一次性回字母，也不送进 RIME。
    case insertT9NumberPadText(String)
    /// Emoji uses the same final-commit path as other direct text while
    /// retaining a content-free source category for aggregate statistics.
    case insertEmoji(String)
    case toggleShift
    case togglePage
    case toggleInputMode
    case insertSpace
    case insertReturn
    case deleteBackward
    case keyboardTypeChanged(KeyboardType)
    /// 候选栏翻页。RIME 路径发送 Page_Up / Page_Down 按键码；
    /// 回退路径调整候选页索引。
    case candidatePageUp
    case candidatePageDown
    /// Refine the current T9 composition to a precise pinyin path (no host commit).
    case selectT9PinyinPath(T9PinyinPath)
    /// Select the first/next displayed T9 pinyin path and wrap at the end (ADR 0021).
    case cycleT9PinyinPath
    /// 九键常用标点键：上屏待确认 `，`，或在 1.0s 窗内轮换 `，。？！`（ADR 0029）。
    case pressT9CommonPunctuation
    /// 九键 / 中文符号页 `^_^`：上屏待确认默认颜表情，或接受后再新开默认（ADR 0030）。
    case pressKaomoji
}

/// 九键中文数字页的纯布局表。UI 只按这张表建键，测试不依赖 UIKit 帧。
public enum T9NumberPadLayout: Sendable {
    /// 九宫格候选栏常用快捷符号（T9-NUMPAD-SHORTCUTS-EXPAND-001，高频前置；
    /// 不与数字主面板已有按键 `@` `+` `-` `.` 重复）。
    public static let shortcutSymbols: [String] = [
        "/", "%", ":", "×", "÷", "=", "#", "¥", "$", "~", "—", "(", ")", "℃", "±", "‰", "°", "、",
    ]

    public enum Tap: Equatable, Sendable {
        case literal(String)
        case symbolsPage
        case lettersPage
        case delete
        case insertReturn
    }

    public struct Key: Equatable, Sendable {
        public var title: String
        public var tap: Tap
        public var installsSpaceCursorLongPress: Bool

        public init(title: String, tap: Tap, installsSpaceCursorLongPress: Bool = false) {
            self.title = title
            self.tap = tap
            self.installsSpaceCursorLongPress = installsSpaceCursorLongPress
        }
    }

    public static func literal(_ text: String, title: String? = nil) -> Key {
        Key(title: title ?? text, tap: .literal(text))
    }

    /// 三列，行数 4 / 4 / 3。中列每行 3 键。return 只在右列末行。
    public static let columns: [[[Key]]] = [
        [
            [literal("@")],
            [literal("+")],
            [literal("-")],
            [Key(title: "#+=", tap: .symbolsPage)],
        ],
        [
            [literal("1"), literal("2"), literal("3")],
            [literal("4"), literal("5"), literal("6")],
            [literal("7"), literal("8"), literal("9")],
            [Key(title: "返回", tap: .lettersPage), literal("0"), literal(".")],
        ],
        [
            [Key(title: "⌫", tap: .delete)],
            [Key(title: "空格", tap: .literal(" "), installsSpaceCursorLongPress: true)],
            [Key(title: "return", tap: .insertReturn)],
        ],
    ]

    public static func showsShortcutBar(
        page: KeyboardPage,
        inputMode: InputMode,
        layout: KeyboardLayoutStyle,
        readinessMatched: Bool,
        composition: String,
        hasPendingPunctuation: Bool,
        hasPendingKaomoji: Bool
    ) -> Bool {
        page == .numbers && inputMode == .chinese && layout == .nineKey && readinessMatched
            && composition.isEmpty && !hasPendingPunctuation && !hasPendingKaomoji
    }
}
