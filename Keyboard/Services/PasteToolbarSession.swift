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
    enum Preview: Equatable { case notRead, reading, ready(ClipboardPreviewResult), unavailable, hidden }
    private(set) var preview: Preview = .notRead
    private(set) var inquiryOpen = false
    private(set) var deniedThisAppearance = false
    /// Content already returned while a metadata decision is still open. Not a display.
    private(set) var retainedPreviewModel: ClipboardPreviewResult?
    private(set) var hiddenVersion: Int?
    private var previewSuspended = false
    private var previewGate: ClipboardPreviewGate?
    private var metadataGate: ClipboardPreviewGate?
    private var previewDeadline: UInt64 = 0
    private var slotsExpired = false
    private var decisionSealed = false
    private var nextRequestID: UInt64 = 1
    private var activeRequestID: UInt64 = 0
    private var contentFact: PasteDisplayFacts.Content = .pending
    private var metadataFact: PasteDisplayFacts.Metadata = .notRequested
    private var finalFact: PasteDisplayFacts.FinalVersion = .notNeeded
    private var finalRequested = false
    var previewReader: any ClipboardPreviewReading = ClipboardPreviewReader()
    var metadataReader: any ClipboardMetadataReading = SystemClipboardMetadataReader()
    /// Defaults to the production constant. Tests set true; production code must not.
    var emptyDetectionEnabled = ClipboardEmptyDetection.emptyDetectionProbesPassed
    var probeSwitchEnabled: () -> Bool = { true }
    var probeFullAccess: () -> Bool = { true }
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
            if slotsExpired || (previewDeadline > 0 && DispatchTime.now().uptimeNanoseconds >= previewDeadline) {
                discardPreview()
                onPresentationChanged()
            } else if emptyDetectionEnabled {
                evaluateEmptyDetection()
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
        slotsExpired = false
        decisionSealed = false
        previewDeadline = DispatchTime.now().uptimeNanoseconds + 500_000_000
        let gate = ClipboardPreviewGate(deadline: previewDeadline)
        previewGate = gate
        let requestGeneration = generation
        let requestID = nextRequestID
        nextRequestID += 1
        activeRequestID = requestID
        if emptyDetectionEnabled {
            let metadataGate = ClipboardPreviewGate(deadline: previewDeadline)
            self.metadataGate = metadataGate
            adopt(gate)
            adopt(metadataGate)
            contentFact = .pending
            metadataFact = .pending
            finalFact = .pending
            finalRequested = false
            retainedPreviewModel = nil
            hiddenVersion = nil
            ClipboardMetadataWorker.shared.submitCounts(reader: metadataReader, gate: metadataGate) {
                [weak self] sample in
                Task { @MainActor [weak self] in
                    self?.acceptMetadata(
                        sample, gate: metadataGate, generation: requestGeneration, requestID: requestID)
                }
            }
        }
        ClipboardPreviewWorker.shared.submit(reader: previewReader, gate: gate) { [weak self, gate] result in
            Task { @MainActor [weak self] in
                guard let self, self.previewGate === gate, self.generation == requestGeneration,
                    self.activeRequestID == requestID
                else { return }
                if result == .denied && DispatchTime.now().uptimeNanoseconds < self.previewDeadline {
                    self.deniedThisAppearance = true
                }
                if self.emptyDetectionEnabled {
                    self.acceptContent(result, generation: requestGeneration, requestID: requestID)
                    return
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
            guard let self, self.previewGate === gate, self.generation == requestGeneration,
                self.activeRequestID == requestID
            else { return }
            self.previewGate?.cancel()
            self.metadataGate?.cancel()
            if self.previewSuspended {
                self.slotsExpired = true
                return
            }
            if self.emptyDetectionEnabled {
                self.slotsExpired = true
                self.evaluateEmptyDetection()
            } else {
                self.discardPreview()
                self.onPresentationChanged()
            }
        }
    }

    /// Observed clipboard version after a hide. Unknown or different revokes the hide without rereading.
    func noteClipboardVersion(_ version: Int?) {
        guard case .hidden = preview else { return }
        guard version == hiddenVersion, version != nil else {
            hiddenVersion = nil
            preview = .unavailable
            if !previewSuspended { inquiryOpen = false }
            onPresentationChanged()
            return
        }
    }

    private func adopt(_ gate: ClipboardPreviewGate) {
        gate.adopt(
            token: activeRequestID, generation: generation, enabled: probeSwitchEnabled(),
            fullAccess: probeFullAccess(), eligible: isEligible())
    }

    private func acceptContent(_ result: ClipboardPreviewResult, generation: UInt64, requestID: UInt64) {
        guard !decisionSealed, self.generation == generation, activeRequestID == requestID else { return }
        if previewSuspended {
            discardPreview()
            onPresentationChanged()
            return
        }
        guard DispatchTime.now().uptimeNanoseconds < previewDeadline else { return }
        retainedPreviewModel = result
        switch result {
        case .denied: contentFact = .denied
        case .unavailable: contentFact = .blank
        case .text, .oversized: contentFact = .text
        }
        evaluateEmptyDetection()
    }

    private func acceptMetadata(
        _ sample: ClipboardCountSample, gate: ClipboardPreviewGate, generation: UInt64, requestID: UInt64
    ) {
        guard metadataGate === gate, !decisionSealed, self.generation == generation, activeRequestID == requestID
        else { return }
        if previewSuspended {
            discardPreview()
            onPresentationChanged()
            return
        }
        guard DispatchTime.now().uptimeNanoseconds < previewDeadline else { return }
        if sample.itemCount == 0 && sample.changeCountBefore == sample.changeCountAfter {
            metadataFact = .empty(version: sample.changeCountAfter)
        } else if sample.changeCountBefore == sample.changeCountAfter {
            metadataFact = .nonempty
        } else {
            metadataFact = .unavailable
        }
        evaluateEmptyDetection()
    }

    private func evaluateEmptyDetection() {
        guard emptyDetectionEnabled, !decisionSealed, !previewSuspended else { return }
        if slotsExpired || DispatchTime.now().uptimeNanoseconds >= previewDeadline {
            if contentFact == .pending { contentFact = .timedOut }
            if metadataFact == .pending { metadataFact = .timedOut }
            if case .empty = metadataFact, finalFact == .pending { finalFact = .timedOut }
        }
        if case .empty = metadataFact, finalFact == .pending, !slotsExpired,
            DispatchTime.now().uptimeNanoseconds < previewDeadline
        {
            requestFinalVersion()
        }
        let facts = PasteDisplayFacts(
            probesPassed: true, enabled: probeSwitchEnabled(), fullAccess: probeFullAccess(),
            generationCurrent: true, suspended: previewSuspended, eligible: isEligible(),
            armed: presentation == .armed, content: contentFact, metadata: metadataFact, finalVersion: finalFact)
        switch PasteDisplayPlanner.decide(facts) {
        case .wait: return
        case .omit:
            seal(.unavailable, version: nil)
        case .fallback:
            seal(.unavailable, version: nil)
        case .preview:
            if let retainedPreviewModel { seal(.ready(retainedPreviewModel), version: nil) }
        case .hidden:
            let version = metadataVersion
            seal(.hidden, version: version)
        }
    }

    private var metadataVersion: Int? {
        if case .empty(let version) = metadataFact { return version }
        return nil
    }

    private func requestFinalVersion() {
        guard !finalRequested, let metadataGate else { return }
        finalRequested = true
        let requestGeneration = generation
        let requestID = activeRequestID
        ClipboardMetadataWorker.shared.submitChangeCount(reader: metadataReader, gate: metadataGate) {
            [weak self] version in
            Task { @MainActor [weak self] in
                guard let self, !self.decisionSealed, self.generation == requestGeneration,
                    self.activeRequestID == requestID
                else { return }
                if self.previewSuspended {
                    self.discardPreview()
                    self.onPresentationChanged()
                    return
                }
                guard DispatchTime.now().uptimeNanoseconds < self.previewDeadline else {
                    self.finalFact = .timedOut
                    self.evaluateEmptyDetection()
                    return
                }
                guard case .empty(let evidence) = self.metadataFact else {
                    self.finalFact = .incomparable
                    self.evaluateEmptyDetection()
                    return
                }
                self.finalFact = version == evidence ? .equal : .mismatch
                self.evaluateEmptyDetection()
            }
        }
    }

    private func seal(_ preview: Preview, version: Int?) {
        decisionSealed = true
        previewGate?.cancel()
        metadataGate?.cancel()
        previewGate = nil
        metadataGate = nil
        hiddenVersion = version
        self.preview = preview
        if preview != .hidden { retainedPreviewModel = nil }
        if !previewSuspended { inquiryOpen = false }
        onPresentationChanged()
    }

    func didInstallPreview() {
        if !previewSuspended { inquiryOpen = false }
    }

    func discardPreview() {
        decisionSealed = true
        previewGate?.cancel()
        metadataGate?.cancel()
        previewGate = nil
        metadataGate = nil
        preview = .unavailable
        retainedPreviewModel = nil
        hiddenVersion = nil
        if !previewSuspended { inquiryOpen = false }
    }

    func resetPreview() {
        previewGate?.cancel()
        metadataGate?.cancel()
        previewGate = nil
        metadataGate = nil
        preview = .notRead
        inquiryOpen = false
        previewSuspended = false
        previewDeadline = 0
        slotsExpired = false
        decisionSealed = false
        retainedPreviewModel = nil
        hiddenVersion = nil
        contentFact = .pending
        metadataFact = .notRequested
        finalFact = .notNeeded
        finalRequested = false
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
