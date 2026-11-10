import KeyboardCore
import UIKit

/// One main-actor operation owns each provider result. Invalidated results are never replayed.
@MainActor
final class PasteToolbarSession {
    enum State: Equatable { case idle, loading, invalid }
    /// 一次显示内的粘贴条资格。和加载状态分开：失败不消耗，成功或第一次计入输入才消耗。
    enum Presentation: Equatable { case armed, consumedByInput, consumedByPaste }
    private(set) var state: State = .idle
    private(set) var presentation: Presentation = .armed
    /// 每次真正重新武装（出现，或仅有 resign 的切回）加一。B1 不拿它去读剪贴板。
    private(set) var generation: UInt64 = 0
    /// 询问已结束的 resign 记下，等 becomeActive 按结果 Y 重置。出现会清掉它，避免结果 X 再重置一次。
    private(set) var pendingReturn = false
    private(set) var activeOperationID: UInt64?
    private var nextOperationID: UInt64 = 1
    private(set) var pasteFailureVisible = false
    var isEligible: () -> Bool = { false }
    var commit: (String) -> PasteCommitResult = { _ in .rejectedNoClient }
    var onPresentationChanged: () -> Void = {}

    /// 新的一次出现。B1 不创建读取字段，只重新武装显示。
    func noteAppearance() {
        presentation = .armed
        generation += 1
        pendingReturn = false
    }

    /// B1 没有「询问未结束」。resign 一律记成待返回。
    func noteHostResign() {
        pendingReturn = true
    }

    /// 没有 resign 时不动。有 pendingReturn 时按结果 Y 重新武装。
    func noteHostBecomeActive() {
        guard pendingReturn else { return }
        presentation = .armed
        generation += 1
        pendingReturn = false
    }

    /// 第一次计入的输入。已经消耗过的不再改原因。
    func noteCountedInput() {
        guard presentation == .armed else { return }
        presentation = .consumedByInput
    }

    func begin() -> UInt64? {
        // armed 不放进 isEligible：加载中的完成仍看候选栏是否空闲。
        // 新的一次粘贴则必须还在 armed，否则成功后的同一次显示不能再 begin。
        guard presentation == .armed else { return nil }
        guard isEligible() else { invalidate(); return nil }
        let id = nextOperationID
        nextOperationID += 1
        activeOperationID = id
        state = .loading
        pasteFailureVisible = false
        onPresentationChanged()
        return id
    }

    func complete(_ text: String?, operationID: UInt64) {
        guard activeOperationID == operationID, state == .loading else { return }
        guard isEligible() else { invalidate(); return }
        guard let text, !text.isEmpty, text.utf16.count <= 8_000 else {
            finish(operationID, failed: true)
            return
        }
        // Keep loading through insertText: UIKit can synchronously reenter textDidChange.
        let result = commit(text)
        finish(operationID, failed: result != .inserted)
    }

    private func finish(_ id: UInt64, failed: Bool) {
        guard activeOperationID == id else { return }
        activeOperationID = nil
        state = .idle
        pasteFailureVisible = failed
        if !failed { presentation = .consumedByPaste }
        onPresentationChanged()
    }

    func invalidate(operationID: UInt64) {
        guard activeOperationID == operationID else { return }
        invalidate()
    }

    func invalidate() {
        activeOperationID = nil
        state = .invalid
        state = .idle
    }

    func clearFailure() { pasteFailureVisible = false }
}

/// 哪些动作算「第一次输入」。分类表在 r1 附录 C；这里只覆盖会进 KeyboardAction 的那些。
func pastePresentationCounts(_ action: KeyboardAction) -> Bool {
    switch action {
    case .insertKey, .insertCandidate, .insertCorrectionCandidate, .insertDirectText, .insertEmoji,
        .insertSpace, .insertReturn, .deleteBackward, .selectT9PinyinPath, .cycleT9PinyinPath,
        .pressT9CommonPunctuation, .pressKaomoji:
        return true
    case .toggleShift, .togglePage, .toggleInputMode, .candidatePageUp, .candidatePageDown,
        .keyboardTypeChanged:
        return false
    }
}
