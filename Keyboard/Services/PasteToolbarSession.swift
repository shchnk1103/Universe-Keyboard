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
    enum Preview: Equatable {
        case notRead, reading, ready(ClipboardPreviewResult), unavailable
        /// PB-013 Level 0 命中：changeCount 已被处理过（粘贴/关闭），本次出现零整读、不安装预览。
        /// 与 .unavailable 的语义边界：.suppressed 表示「有意不再显示」，工具栏保持隐藏但会话仍 armed；
        /// .unavailable 表示「读取尝试失败/被丢弃」。
        case suppressed
    }
    private(set) var preview: Preview = .notRead
    private(set) var inquiryOpen = false
    private(set) var deniedThisAppearance = false
    private(set) var previewWasShown = false
    private struct PendingRead {
        let result: ClipboardPreviewResult
        let before: Int?
        let after: Int?
        let returned: UInt64
        let normalDeadline: UInt64
        let hardDeadline: UInt64
        let permitsLate: Bool
        let generation: UInt64
        let requestID: UInt64
        let gate: ClipboardPreviewGate
    }
    private var suspendedRead: PendingRead?
    private var previewSuspended = false
    private var previewGate: ClipboardPreviewGate?
    private var previewDeadline: UInt64 = 0
    private var nextRequestID: UInt64 = 1
    private var activeRequestID: UInt64 = 0
    static let latePreviewEnabled = false
    static let latePreviewWindow: UInt64 = 10_000_000_000
    var latePreviewEnabled = PasteToolbarSession.latePreviewEnabled
    var monotonicNow: @Sendable () -> UInt64 = { DispatchTime.now().uptimeNanoseconds }
    var previewReader: any ClipboardPreviewReading = ClipboardPreviewReader()
    /// PB-013 静态去重开关。真机 O5 实测（2026-11-24，iOS 27.2.1）：读取 changeCount 本身亦触发
    /// 系统「已粘贴」横幅，故默认关闭并启用降级方案 B：跳过 probe，每进程一次整读 + 内存缓存复用
    /// （SuppressStore 抑制逻辑不变）。置 true 仅保留 probe 路径的注入覆盖测试。
    var probeEnabled = false
    /// probe 自带 200ms 超时窗；超时 fail-open 降级为整读，整读重起自己的 500ms 正常窗。
    nonisolated static let probeTimeout: UInt64 = 200_000_000
    var probeSwitchEnabled: () -> Bool = { true }
    var probeFullAccess: () -> Bool = { true }
    var isEligible: () -> Bool = { false }
    var commit: (String) -> PasteCommitResult = { _ in .rejectedNoClient }
    var onPresentationChanged: () -> Void = {}
    /// PB-013 Level 1 进程内结果缓存：含全文、仅内存、不落盘，进程死亡即消失，
    /// 不随 resetPreview（单次显示语义）清理。命名边界：持久抑制在 PastePreviewSuppressStore。
    private var lastReadChangeCount: Int?
    private var lastReadResult: ClipboardPreviewResult?
    /// PB-013 Level 0 持久抑制注入点（App Group 默认由 KeyboardViewController 装配）。
    var suppressStore: any PastePreviewSuppressStoring = PastePreviewSuppressStore(defaults: nil)

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
            let now = monotonicNow()
            let expired = latePreviewEnabled ? now >= previewDeadline : now > previewDeadline
            if previewDeadline > 0 && expired {
                discardPreview()
                onPresentationChanged()
            } else if let pending = suspendedRead {
                suspendedRead = nil
                acceptRead(pending, resumed: true)
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
            // PB-013 Level 0：粘贴成功后抑制当前 changeCount（after 缓存缺失时补采样一次），
            // 此后同 changeCount 的任何出现都命中 Level 0，不再显示预览。
            let suppressedCount = lastReadChangeCount ?? previewReader.changeCount()
            if let suppressedCount { suppressStore.suppress(suppressedCount, reason: .pasted) }
        }
        onPresentationChanged()
    }

    /// 关闭按钮动作：预览真正展示过时写 closed 抑制（首次计数输入不抑制——noteCountedInput 不写 store），
    /// 然后收栏并通知刷新。未展示过时只收栏，不写抑制。
    func closePreview() {
        if previewWasShown {
            let suppressedCount = lastReadChangeCount ?? previewReader.changeCount()
            if let suppressedCount { suppressStore.suppress(suppressedCount, reason: .closed) }
        }
        discardPreview()
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

    /// 五道门（含 `probeSwitchEnabled && probeFullAccess`）先于一切访问：开关或完全访问关闭时
    /// 连 changeCount 采样都不发生，零访问不变量（PB-013）。
    func startPreviewIfNeeded() {
        guard preview == .notRead, presentation == .armed, isEligible(),
            probeSwitchEnabled(), probeFullAccess()
        else { return }
        // late 预览实验路径保持旧 before/after 采样语义，跳过 probe；方案 B 走整读 + 缓存复用。
        if probeEnabled && !latePreviewEnabled {
            startProbePhase()
        } else if !latePreviewEnabled, let cachedCount = lastReadChangeCount,
            let cachedResult = lastReadResult, Self.isCacheableResult(cachedResult)
        {
            // 方案 B（probeEnabled = false）：无 probe。同 changeCount 的出现直接复用/抑制，零 pasteboard 访问。
            if cachedCount == suppressStore.suppressedCount() {
                preview = .suppressed
            } else {
                preview = .ready(cachedResult)
            }
            inquiryOpen = false
            onPresentationChanged()
        } else {
            startFullReadPhase(origin: monotonicNow())
        }
    }

    /// PB-013 probe 阶段：仅采样一次 changeCount（200ms 超时窗），据此走 Level 0/1/2 分支。
    private func startProbePhase() {
        preview = .reading
        inquiryOpen = true
        let clock = monotonicNow
        let issued = clock()
        let gate = ClipboardPreviewGate(deadline: issued + Self.probeTimeout, now: clock)
        previewGate = gate
        previewDeadline = issued + Self.probeTimeout
        let requestGeneration = generation
        let requestID = nextRequestID
        nextRequestID += 1
        activeRequestID = requestID
        adopt(gate)
        ClipboardPreviewWorker.shared.submitProbe(reader: previewReader, gate: gate, now: clock) {
            [weak self, gate] count, _ in
            Task { @MainActor [weak self, gate] in
                guard let self else { return }
                guard self.previewGate === gate, self.generation == requestGeneration,
                    self.activeRequestID == requestID
                else { return }
                if self.previewSuspended {
                    // 询问挂起期间到达的 probe 结果一律丢弃，不写缓存、不降级整读。
                    self.discardPreview()
                    self.onPresentationChanged()
                    return
                }
                if let count {
                    // Level 0：持久抑制命中——零整读、零显示，工具栏保持隐藏。
                    if count == self.suppressStore.suppressedCount() {
                        gate.cancel()
                        self.previewGate = nil
                        self.preview = .suppressed
                        self.inquiryOpen = false
                        self.onPresentationChanged()
                        return
                    }
                    // Level 1：进程内复用命中——零整读、零系统横幅，直接采用缓存结果。
                    if count == self.lastReadChangeCount, let cached = self.lastReadResult,
                        Self.isCacheableResult(cached)
                    {
                        gate.cancel()
                        self.previewGate = nil
                        self.preview = .ready(cached)
                        self.inquiryOpen = false
                        self.onPresentationChanged()
                        return
                    }
                }
                // Level 2：probe 为 nil（协议默认实现）或版本变化——降级整读（硬窗仍锚定 probe 起点）。
                self.startFullReadPhase(origin: issued)
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + .nanoseconds(Int(Self.probeTimeout))) {
            [weak self, gate] in
            guard let self, self.previewGate === gate, self.generation == requestGeneration,
                self.activeRequestID == requestID, self.preview == .reading
            else { return }
            // probe 200ms 超时：整读重起自己的 500ms 正常窗（不从 probe 起点继续计时），
            // 10s 硬窗仍锚定 probe 起点。
            gate.cancel()
            self.startFullReadPhase(origin: issued)
        }
    }

    /// PB-013 整读阶段（Level 2 及无 probe 路径）。sampleVersions 恒 true：
    /// 每次整读多两次 changeCount 采样（probe 1 次 + before/after 各 1 次，共 3 次），
    /// 量级可忽略但属行为变化，勿改回（单测 testPB013FullReadAlwaysSamplesBeforeAndAfter 防回退）。
    /// `origin` 是本次出现的读取窗起点（probe 起点或无 probe 时的整读起点）：500ms 正常窗从整读
    /// 重新起算（probe 超时 fail-open 语义），10s 硬窗仍锚定 origin，保证「过期排队会话永不重读」。
    private func startFullReadPhase(origin: UInt64) {
        guard presentation == .armed, isEligible(), probeSwitchEnabled(), probeFullAccess() else {
            discardPreview()
            onPresentationChanged()
            return
        }
        let issued = monotonicNow()
        let normalDeadline = issued + 500_000_000
        let hardDeadline = origin + Self.latePreviewWindow
        let permitsLate = latePreviewEnabled
        preview = .reading
        inquiryOpen = true
        previewDeadline = permitsLate ? hardDeadline : normalDeadline
        let clock = monotonicNow
        let gate = ClipboardPreviewGate(deadline: hardDeadline, now: clock)
        previewGate = gate
        let requestGeneration = generation
        let requestID = nextRequestID
        nextRequestID += 1
        activeRequestID = requestID
        adopt(gate)
        ClipboardPreviewWorker.shared.submitVersioned(
            reader: previewReader, gate: gate, sampleVersions: true, now: clock
        ) {
            [weak self, gate] result, before, after, returned in
            Task { @MainActor [weak self] in
                guard let self else { return }
                let pending = PendingRead(
                    result: result, before: before, after: after, returned: returned,
                    normalDeadline: normalDeadline, hardDeadline: hardDeadline, permitsLate: permitsLate,
                    generation: requestGeneration, requestID: requestID, gate: gate)
                guard self.previewGate === gate, self.generation == requestGeneration,
                    self.activeRequestID == requestID
                else { return }
                if result == .denied { self.deniedThisAppearance = true }
                if self.previewSuspended {
                    self.suspendedRead = pending
                } else {
                    self.acceptRead(pending)
                }
            }
        }
        let delay: DispatchTimeInterval = permitsLate ? .seconds(10) : .milliseconds(500)
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self, gate] in
            guard let self, self.previewGate === gate, self.generation == requestGeneration,
                self.activeRequestID == requestID
            else { return }
            if !permitsLate && !gate.expireNormalIfPending(deadline: normalDeadline) { return }
            self.discardPreview()
            self.onPresentationChanged()
        }
    }

    private func acceptRead(_ pending: PendingRead, resumed: Bool = false) {
        guard previewGate === pending.gate, generation == pending.generation,
            activeRequestID == pending.requestID
        else { return }
        let now = monotonicNow()
        let late = pending.returned > pending.normalDeadline || (resumed && now > pending.normalDeadline)
        guard pending.returned < pending.hardDeadline, now < pending.hardDeadline,
            !previewSuspended, presentation == .armed, isEligible(), probeSwitchEnabled(), probeFullAccess(),
            !late || (pending.permitsLate && pending.before != nil && pending.before == pending.after)
        else {
            discardPreview()
            onPresentationChanged()
            return
        }
        pending.gate.cancel()
        previewGate = nil
        preview = pending.result == .unavailable || pending.result == .denied ? .unavailable : .ready(pending.result)
        if preview == .unavailable { inquiryOpen = false }
        // PB-013：仅成功结果且 before==after 且非 nil 采样时更新进程内缓存；
        // .denied/.unavailable/nil 采样/超时/迟到不一致一律不缓存（nil 版本样本永不入缓存）。
        if Self.isCacheableResult(pending.result), let before = pending.before, before == pending.after {
            lastReadChangeCount = before
            lastReadResult = pending.result
            // PB-013 Level 0（方案 B 整读补口）：本进程缓存为空（如跨进程粘贴/关闭残留）时，
            // probe 与缓存路径都拦不住整读；稳定样本 changeCount 命中持久抑制则不展示——
            // 改置 .suppressed，与 probe 路径 Level 0 语义一致。复用本次整读已采样的 before，
            // 零额外粘贴板读取；结果已入进程内缓存，同进程后续出现走方案 B 缓存路径零读取命中
            // （抑制检查先于缓存复用，见 startPreviewIfNeeded）。
            if before == suppressStore.suppressedCount() {
                preview = .suppressed
                inquiryOpen = false
            }
        }
        onPresentationChanged()
    }

    private static func isCacheableResult(_ result: ClipboardPreviewResult) -> Bool {
        switch result {
        case .text, .oversized: return true
        case .unavailable, .denied: return false
        }
    }

    private func adopt(_ gate: ClipboardPreviewGate) {
        gate.adopt(
            token: activeRequestID, generation: generation, enabled: probeSwitchEnabled(),
            fullAccess: probeFullAccess(), eligible: isEligible())
    }

    func didInstallPreview() {
        previewWasShown = true
        if !previewSuspended { inquiryOpen = false }
    }

    func discardPreview() {
        suspendedRead = nil
        previewGate?.cancel()
        previewGate = nil
        preview = .unavailable
        if !previewSuspended { inquiryOpen = false }
    }

    func resetPreview() {
        previewWasShown = false
        suspendedRead = nil
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
    case .insertKey, .insertCandidate, .insertCorrectionCandidate, .insertDirectText, .insertT9NumberPadText,
        .insertEmoji,
        .insertSpace, .insertReturn, .deleteBackward, .selectT9PinyinPath, .cycleT9PinyinPath,
        .pressT9CommonPunctuation, .pressKaomoji:
        return true
    case .toggleShift, .togglePage, .toggleInputMode, .candidatePageUp, .candidatePageDown,
        .keyboardTypeChanged:
        return false
    }
}

/// 只有用户主动的非计数动作才会清除正在读取的预览。宿主自动发出的键盘类型回调不清除。
func pasteDiscardsReadingPreview(_ action: KeyboardAction) -> Bool {
    switch action {
    case .toggleShift, .togglePage, .toggleInputMode, .candidatePageUp, .candidatePageDown:
        return true
    case .keyboardTypeChanged:
        return false
    case .insertKey, .insertCandidate, .insertCorrectionCandidate, .insertDirectText, .insertT9NumberPadText,
        .insertEmoji,
        .insertSpace, .insertReturn, .deleteBackward, .selectT9PinyinPath, .cycleT9PinyinPath,
        .pressT9CommonPunctuation, .pressKaomoji:
        return false
    }
}
