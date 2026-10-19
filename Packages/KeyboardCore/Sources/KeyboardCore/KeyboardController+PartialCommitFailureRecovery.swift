import Foundation

extension KeyboardController {
    struct PartialCommitFailureRecovery {
        enum Phase { case blockedRemainder, needsFreshSession, freshFailed }
        var phase: Phase = .blockedRemainder
        let ownerID: UUID
        var editingGeneration: UInt64
        var hostBindingValid = true
        var ownerWasSuspended = false
        var resumeRequested = false
    }

    public var isPartialCommitFailureRecoveryPending: Bool { partialCommitFailureRecovery != nil }

    /// Presentation and Core share this gate; R174 keeps its own trigger/state.
    public var isCompositionInputRecoveryPending: Bool {
        isPartialCommitFailureRecoveryPending || isT9InputRecoveryPending
    }

    public var compositionInputRecoveryMessage: String? {
        guard let recovery = partialCommitFailureRecovery else { return t9InputRecoveryMessage }
        switch recovery.phase {
        case .blockedRemainder: return "输入恢复失败，按删除取消未确认拼音后重新输入"
        case .needsFreshSession: return "未确认拼音已取消，请重新输入"
        case .freshFailed: return "输入暂不可用，请切换键盘后重试"
        }
    }

    /// This is entered only by the failed affine checkpoint-rebuild branch.
    /// Keep the marked span, but remove every source of candidate authority.
    func beginPartialCommitFailureRecovery() {
        guard let coordinator = threadAffineRimeCoordinator,
            rimeEngine is ThreadAffineRimeEngineBridge
        else { return }
        partialCommitFailureRecovery = PartialCommitFailureRecovery(
            ownerID: coordinator.instanceIdentity, editingGeneration: t9RetypeEditingGeneration)
        invalidateCheckpointCandidateAuthority()
    }

    private func invalidateCheckpointCandidateAuthority() {
        state.lastRimeOutput = nil
        clearTypoCorrectionSuggestions()
        clearT9PinyinPathState()
        clearResponsiveKeyApplyContexts()
        advanceCompositionRevision()
    }

    /// A rebind to nil or an external edit cannot authorize writes through the
    /// next adapter. Forget old host spans without touching either document.
    func fencePartialCommitFailureRecovery() {
        guard var recovery = partialCommitFailureRecovery else { return }
        recovery.phase = .freshFailed
        recovery.hostBindingValid = false
        recovery.editingGeneration = t9RetypeEditingGeneration
        partialCommitFailureRecovery = recovery
        state.currentComposition = ""
        state.partialCommit = nil
        state.insertedPreeditText = ""
        state.insertedPreeditCount = 0
        state.pendingPunctuation = nil
        state.pendingKaomoji = nil
        state.continuation = ContinuationState()
        invalidateCheckpointCandidateAuthority()
    }

    func noteCheckpointOwnerSuspended(_ positive: Bool) {
        if positive { partialCommitFailureRecovery?.ownerWasSuspended = true }
    }

    func noteCheckpointOwnerResumeRequested() {
        guard partialCommitFailureRecovery?.ownerWasSuspended == true else { return }
        partialCommitFailureRecovery?.resumeRequested = true
        releaseCheckpointRecoveryAfterReadyResume()
    }

    private func releaseCheckpointRecoveryAfterReadyResume() {
        guard let recovery = partialCommitFailureRecovery, recovery.resumeRequested,
            let coordinator = threadAffineRimeCoordinator, coordinator.isOwnerReady,
            coordinator.diagnosticSessionSnapshot?.isValid == true, coordinator.runtimeSelection != nil
        else { return }
        // Positive teardown removed the old owner before this resume created a
        // new one. Readiness alone on an existing failed owner is insufficient.
        partialCommitFailureRecovery = nil
    }

    private var checkpointHostBindingIsCurrent: Bool {
        guard let recovery = partialCommitFailureRecovery, recovery.hostBindingValid,
            textClient != nil, let coordinator = threadAffineRimeCoordinator
        else { return false }
        return recovery.ownerID == coordinator.instanceIdentity
            && recovery.editingGeneration == t9RetypeEditingGeneration
    }

    private func cancelFailedCheckpointRemainder() {
        guard partialCommitFailureRecovery?.phase == .blockedRemainder else { return }
        guard checkpointHostBindingIsCurrent else {
            fencePartialCommitFailureRecovery()
            return
        }
        let prefix = state.partialCommit?.confirmedText ?? ""
        if let partial = state.partialCommit {
            state.partialCommit = PartialCommitState(
                confirmedText: prefix, remainingRawInput: "", remainingPreeditText: "",
                displayText: prefix, checkpoint: nil, source: partial.source)
        }
        state.currentComposition = ""
        partialCommitFailureRecovery?.phase = .needsFreshSession
        invalidateCheckpointCandidateAuthority()
        updateInlinePreedit(prefix, source: .compositionProjection)
    }

    /// Run before punctuation acceptance, history preparation or any host work.
    func interceptPartialCommitFailureAction(_ action: KeyboardAction) -> KeyboardEffect? {
        releaseCheckpointRecoveryAfterReadyResume()
        guard partialCommitFailureRecovery != nil else { return nil }
        let refresh: KeyboardEffect = [.compositionChanged, .t9PinyinPathsChanged]
        switch action {
        case .toggleShift:
            return handleToggleShift()
        case .deleteBackward:
            cancelFailedCheckpointRemainder()
            return refresh
        case .togglePage, .toggleInputMode, .keyboardTypeChanged:
            cancelFailedCheckpointRemainder()
            // Changing chrome must not consult a failed engine or implicitly
            // submit the confirmed marked prefix. Only these scalar fields move.
            switch action {
            case .togglePage:
                switch state.currentPage {
                case .letters: state.currentPage = .numbers
                case .numbers: state.currentPage = .symbols
                case .symbols: state.currentPage = .emoji
                case .emoji: state.currentPage = .letters
                }
                return refresh.union(.pageChanged).union(resetShiftState())
            case .toggleInputMode:
                state.inputMode = state.inputMode == .chinese ? .english : .chinese
                state.currentPage = .letters
                state.shiftState = .off
                state.lastShiftTapTime = nil
                return refresh.union([.inputModeChanged, .pageChanged, .shiftStateChanged])
            case .keyboardTypeChanged(let type):
                guard type != state.activeKeyboardType else { return refresh }
                state.activeKeyboardType = type
                if type == .emailAddress || type == .URL || type == .webSearch {
                    state.inputMode = .english
                    return refresh.union([.keyboardTypeChanged, .inputModeChanged])
                }
                return refresh.union(.keyboardTypeChanged)
            default: return refresh
            }
        case .insertKey(let key):
            if state.inputMode == .chinese && state.currentPage == .letters {
                guard partialCommitFailureRecovery?.phase == .needsFreshSession,
                    key.count == 1,
                    key.unicodeScalars.allSatisfy({ $0.isASCII && CharacterSet.alphanumerics.contains($0) }),
                    !usesT9InputSemantics || "23456789".contains(key)
                else { return refresh }
                recoverCheckpointForNewKey(rimeInputKey(for: key))
                return refresh
            }
            return insertOutsideFailedChineseSession(key, refresh: refresh)
        case .insertDirectText(let text), .insertEmoji(let text):
            guard state.inputMode != .chinese || state.currentPage != .letters else { return refresh }
            return insertOutsideFailedChineseSession(text, refresh: refresh)
        case .insertSpace:
            guard state.inputMode != .chinese || state.currentPage != .letters else { return refresh }
            return insertOutsideFailedChineseSession(" ", refresh: refresh)
        case .insertReturn:
            guard state.inputMode != .chinese || state.currentPage != .letters else { return refresh }
            return insertOutsideFailedChineseSession("\n", refresh: refresh)
        default:
            return refresh
        }
    }

    private func insertOutsideFailedChineseSession(_ text: String, refresh: KeyboardEffect) -> KeyboardEffect {
        guard partialCommitFailureRecovery?.phase != .blockedRemainder, checkpointHostBindingIsCurrent else {
            return refresh
        }
        let prefix = state.partialCommit?.confirmedText ?? ""
        commitInlinePreedit(as: prefix + text, source: .directText)
        state.partialCommit = nil
        return refresh.union(.continuationChanged)
    }

    private func recoverCheckpointForNewKey(_ key: String) {
        guard checkpointHostBindingIsCurrent, let coordinator = threadAffineRimeCoordinator else { return }
        // Spend the single attempt before entering the engine. Failure, missing
        // delivery or a changed schema cannot grant another try on the next key.
        partialCommitFailureRecovery?.phase = .freshFailed
        let requiresT9 = usesT9InputSemantics
        let fresh = coordinator.withPublishHandlerSuppressed { () -> ResponsiveRimeSnapshot? in
            guard let recovered = coordinator.performOrderedNow(.recoverSession),
                checkpointHostBindingIsCurrent, matchesCheckpointReceipt(recovered, coordinator: coordinator),
                coordinator.diagnostics.sessionEpoch == recovered.sessionEpoch + 1,
                coordinator.diagnosticSessionSnapshot?.isValid == true,
                coordinator.runtimeSelection?.usesT9InputSemantics == requiresT9
            else { return nil }
            guard
                let replacement = coordinator.performOrderedNow(
                    .replaceInput(key, boundEpoch: nil, boundRevision: nil)),
                checkpointHostBindingIsCurrent, matchesCheckpointReceipt(replacement, coordinator: coordinator),
                replacement.sessionEpoch == coordinator.diagnostics.sessionEpoch,
                coordinator.lastPublished == replacement,
                coordinator.diagnosticSessionSnapshot?.isValid == true,
                coordinator.runtimeSelection?.usesT9InputSemantics == requiresT9,
                replacement.output.rawInput == key, replacement.output.committedText == nil,
                replacement.output.composition?.preeditText.isEmpty == false
            else { return nil }
            if requiresT9 {
                let visible = T9PreeditResolver.visiblePreedit(
                    rawInput: replacement.output.rawInput, candidates: replacement.output.candidates,
                    highlightedIndex: replacement.output.highlightedIndex)
                guard !visible.isEmpty, !visible.unicodeScalars.contains(where: T9PinyinPathExtractor.isASCIIDigit)
                else { return nil }
            }
            return replacement
        }
        applyRealizedSelectionFromEngine()
        guard let fresh else { return }
        partialCommitFailureRecovery = nil
        applyResponsivePublishedSnapshot(fresh)
    }

    private func matchesCheckpointReceipt(
        _ snapshot: ResponsiveRimeSnapshot, coordinator: ThreadAffineRimeSessionCoordinator
    ) -> Bool {
        guard let receipt = coordinator.lastAcceptReceipt else { return false }
        return snapshot.actionID == receipt.actionID && snapshot.sessionEpoch == receipt.sessionEpoch
            && snapshot.revision == receipt.revision
    }
}
