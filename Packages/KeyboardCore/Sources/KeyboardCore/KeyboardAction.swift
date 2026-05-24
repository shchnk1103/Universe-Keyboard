/// 键盘所有可能的用户操作。
/// 这是 UI 层（ViewController）和业务逻辑层（KeyboardController）之间的"消息类型"。
/// UI 层负责把用户手势翻译成 KeyboardAction，然后发送给 controller.handle(_:)。
/// Controller 处理后返回 KeyboardEffect，告诉 UI 层该刷新什么。
public enum KeyboardAction: Equatable {
    case insertKey(String)
    /// 插入候选词/拼音组合。kind 参数决定行为：
    /// - .candidate: 上屏候选词并清除拼音
    /// - .composition: 提交原始拼音
    /// - .placeholder: 无操作（按钮已被禁用，这里是安全网）
    case insertCandidate(String, kind: CandidateKind)
    case insertDirectText(String)
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
}
