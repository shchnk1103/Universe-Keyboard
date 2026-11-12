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
    /// 每次真正重新武装（出现，或仅有 resign 的切回）加一。读取回调用它判别旧代。
    private(set) var generation: UInt64 = 0
    /// 询问已结束的 resign 记下，等 becomeActive 按结果 Y 重置。出现会清掉它，避免结果 X 再重置一次。
    private(set) var pendingReturn = false
    private(set) var activeOperationID: UInt64?
    private var nextOperationID: UInt64 = 1
    private(set) var pasteFailureVisible = false
    enum Preview: Equatable { case notRead, reading, ready(ClipboardPreviewResult), unavailable }
    private(set) var preview: Preview = .notRead
    private(set) var inquiryOpen = false
    private(set) var deniedThisAppearance = false
    private var previewSuspended = false
    private var previewGate: ClipboardPreviewGate?
    private var previewDeadline: UInt64 = 0
    var previewReader: any ClipboardPreviewReading = ClipboardPreviewReader()
    var isEligible: () -> Bool = { false }
    var commit: (String) -> PasteCommitResult = { _ in .rejectedNoClient }
    var onPresentationChanged: () -> Void = {}

    /// 新的一次出现重新武装显示与读取资格。
    func noteAppearance() {
        resetPreview()
        deniedThisAppearance = false
        presentation = .armed
        generation += 1
        pendingReturn = false
    }

    /// 询问未结束时保留当前代；普通 resign 等待返回后重新武装。
    func noteHostResign() {
        if inquiryOpen {
            previewSuspended = true
            pendingReturn = false
        } else {
            resetPreview()
            pendingReturn = true
        }
    }

    /// 没有 resign 时不动。有 pendingReturn 时按结果 Y 重新武装。
    func noteHostBecomeActive() {
        if previewSuspended {
            previewSuspended = false
            if DispatchTime.now().uptimeNanoseconds >= previewDeadline {
                discardPreview()
            }
            return
        }
        guard pendingReturn else { return }
        resetPreview()
        if deniedThisAppearance { preview = .unavailable }
        presentation = .armed
        generation += 1
        pendingReturn = false
    }

    /// 第一次计入的输入。已经消耗过的不再改原因。
    func noteCountedInput() {
        guard presentation == .armed else { return }
        presentation = .consumedByInput
        discardPreview()
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
        if !failed {
            presentation = .consumedByPaste
            discardPreview()
        }
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

    func startPreviewIfNeeded() {
        guard preview == .notRead, presentation == .armed, isEligible() else { return }
        preview = .reading
        inquiryOpen = true
        previewDeadline = DispatchTime.now().uptimeNanoseconds + 500_000_000
        let gate = ClipboardPreviewGate(deadline: previewDeadline)
        previewGate = gate
        let requestGeneration = generation
        ClipboardPreviewWorker.shared.submit(reader: previewReader, gate: gate) { [weak self, gate] result in
            Task { @MainActor [weak self] in
                guard let self, self.previewGate === gate, self.generation == requestGeneration else { return }
                if result == .denied && DispatchTime.now().uptimeNanoseconds < self.previewDeadline {
                    self.deniedThisAppearance = true
                }
                guard !self.previewSuspended, self.presentation == .armed, self.isEligible(),
                    DispatchTime.now().uptimeNanoseconds < self.previewDeadline
                else {
                    self.discardPreview()
                    self.onPresentationChanged()
                    return
                }
                gate.cancel()
                self.previewGate = nil
                self.preview = result == .unavailable || result == .denied ? .unavailable : .ready(result)
                self.onPresentationChanged()
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) { [weak self, gate] in
            guard let self, self.previewGate === gate, self.generation == requestGeneration else { return }
            self.discardPreview()
            self.onPresentationChanged()
        }
    }

    func didInstallPreview() {
        if !previewSuspended { inquiryOpen = false }
    }

    func discardPreview() {
        previewGate?.cancel()
        previewGate = nil
        preview = .unavailable
        if !previewSuspended { inquiryOpen = false }
    }

    func resetPreview() {
        previewGate?.cancel()
        previewGate = nil
        preview = .notRead
        inquiryOpen = false
        previewSuspended = false
        previewDeadline = 0
    }

    func failOversizedPreview() {
        guard presentation == .armed, isEligible() else { return }
        pasteFailureVisible = true
        onPresentationChanged()
    }
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
