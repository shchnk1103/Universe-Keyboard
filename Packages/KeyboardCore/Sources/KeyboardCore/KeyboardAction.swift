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
}
