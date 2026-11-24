import Foundation

/// PB-013 标点回弹后候选栏续接（PunctuationContinuation）。
///
/// 状态机语义见 `design-punct-continuation-r1.md` / `arch-punct-continuation-r1.md`：
/// - 触发：仅中文模式 letters 页、`isPostCommitContinuationEnabled` 且单标点回弹；
///   触发键按最终上屏文本归一（m1）。
/// - 展示优先级：pendingPunctuation / pendingKaomoji / RIME composition 之后、
///   普通中文联想之前（不混排）。
/// - 退出矩阵（m3）：字母/数字、退格、光标移动、模式/页面切换、键盘隐藏、
///   `noteExternalDocumentChange`、RIME/T9 组合开始、粘贴、其他候选类目点选。
/// - 零热路径 IO（ADR 0007）：集合为编译内置静态常量。
extension KeyboardController {
    /// 清空标点续接态（退出矩阵统一出口）。未武装时零状态变化、零效果。
    @discardableResult
    public func clearPunctuationContinuation() -> KeyboardEffect {
        guard state.punctuationContinuation != nil else { return [] }
        state.punctuationContinuation = nil
        return .continuationChanged
    }

    /// 符号页单标点提交路径的武装判定（m1：以最终上屏文本为触发键）。
    ///
    /// 必须先于宿主提交调用：武装后 `refreshContinuation(afterCommitting:)`
    /// 会因续接态活跃而跳过，同一次提交的标点不污染联想 context（二选一）。
    /// 调用方保证 `text` 属于一次性回弹集合（提交后回到 letters 页）。
    func armPunctuationContinuationIfTriggers(appendedText: String) {
        guard isPostCommitContinuationEnabled,
            state.inputMode == .chinese,
            let candidates = PunctuationContinuationCatalog.candidates(forTrigger: appendedText)
        else { return }
        state.punctuationContinuation = PunctuationContinuationState(
            trigger: appendedText,
            candidates: candidates
        )
    }
}
