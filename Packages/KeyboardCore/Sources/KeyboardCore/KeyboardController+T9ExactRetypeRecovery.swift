import Foundation

extension KeyboardController {
    struct T9RetypeDeleteObservation {
        let source: String
        let origin: T9ExactRetypeRecovery.Interpretation?
        let namespace: T9ExactRetypeRecovery.Namespace
    }

    enum T9RetypePresentationOutcome { case ordinary, installed, frozen }

    public var t9InputRecoveryMessage: String? {
        switch t9ExactRetypeRecovery.notice {
        case .waitingForEdit: return "输入恢复中，可继续输入或按删除重试"
        case .failed: return "输入恢复失败，按删除取消本段后重试"
        case .needsFreshSession: return "当前拼音已取消，请重新输入"
        case nil: return nil
        }
    }

    public var isT9InputRecoveryPending: Bool { t9ExactRetypeRecovery.isSessionUntrusted }

    var t9RetypeNamespace: T9ExactRetypeRecovery.Namespace? {
        guard textClient != nil, let coordinator = threadAffineRimeCoordinator else { return nil }
        return .init(
            ownerID: coordinator.instanceIdentity, sessionEpoch: coordinator.diagnostics.sessionEpoch,
            editingGeneration: t9RetypeEditingGeneration)
    }

    private var canUseExactRetypeHistory: Bool {
        isT9ExactRetypeRecoveryEnabled && usesT9InputSemantics && isResponsiveRimePipelineEnabled
            && isThreadAffineRimeOwnerEnabled && state.inputMode == .chinese && state.currentPage == .letters
            && textClient != nil && state.partialCommit == nil && state.pendingPunctuation == nil
            && state.pendingKaomoji == nil && state.t9PinyinPathState.selectedPath == nil
            && state.t9PinyinPathState.confirmedSegmentValues.isEmpty
            && state.t9PinyinPathState.lockedLetterPrefix == nil
            && state.t9ReversibleAutoAnchorState.phase == .idle
            && !shouldRestoreRimeComposition && !shouldRebuildSessionDuringRestore
            && !t9ExactRetypeRecovery.isSessionUntrusted
            && threadAffineRimeCoordinator?.isOwnerReady == true
            && threadAffineRimeCoordinator?.hasPendingWork == false
            && threadAffineRimeCoordinator?.runtimeSelection?.usesT9InputSemantics == true
    }

    func prepareExactRetypeHistory(for action: KeyboardAction) -> T9RetypeDeleteObservation? {
        switch action {
        case .insertKey(let key):
            if key.count != 1 || !T9ExactRetypeRecovery.Interpretation.areDigits(key) {
                t9ExactRetypeRecovery.clearHistory()
            }
        case .deleteBackward:
            guard canUseExactRetypeHistory, let ns = t9RetypeNamespace,
                let source = state.t9PinyinPathState.segmentSourceDigits,
                let output = state.lastRimeOutput, output.committedText == nil,
                let published = threadAffineRimeCoordinator?.lastPublished,
                published.sessionEpoch == ns.sessionEpoch, published.output == output,
                let raw = output.rawInput,
                T9CompositionIdentity.digitEncoding(ofMixedRaw: raw) == source
            else { t9ExactRetypeRecovery.clearHistory(); return nil }
            let origin = T9ExactRetypeRecovery.Interpretation(
                sourceDigits: source, adoptedComment: output.candidates.first?.comment,
                visiblePreedit: state.insertedPreeditText)
            return .init(source: source, origin: origin, namespace: ns)
        default:
            t9ExactRetypeRecovery.clearHistory()
        }
        return nil
    }

    func completeExactRetypeDelete(_ observation: T9RetypeDeleteObservation?) {
        guard let observation else { return }
        guard canUseExactRetypeHistory, let source = state.t9PinyinPathState.segmentSourceDigits,
            t9RetypeNamespace == observation.namespace, state.lastRimeOutput?.committedText == nil
        else { t9ExactRetypeRecovery.clearHistory(); return }
        t9ExactRetypeRecovery.didDelete(
            from: observation.source, to: source, original: observation.origin, namespace: observation.namespace)
    }

    /// Runs before the endpoint digit's host apply. No invalid result is painted.
    func presentExactRetypeIfNeeded(
        snapshot: ResponsiveRimeSnapshot, previous: T9PinyinPathState, key: String
    ) -> T9RetypePresentationOutcome {
        guard canUseExactRetypeHistory, let ns = t9RetypeNamespace,
            let source = previous.segmentSourceDigits, key.count == 1,
            T9ExactRetypeRecovery.Interpretation.areDigits(key),
            snapshot.output.committedText == nil,
            let raw = snapshot.output.rawInput,
            T9CompositionIdentity.digitEncoding(ofMixedRaw: raw) == source + key,
            let coordinator = threadAffineRimeCoordinator,
            coordinator.lastPublished?.actionID == snapshot.actionID
        else { t9ExactRetypeRecovery.clearHistory(); return .ordinary }
        let digits = source + key
        guard
            let request = t9ExactRetypeRecovery.didInsertDigit(
                key, from: source, to: digits, namespace: ns)
        else { return .ordinary }
        // Mixed-raw reconciliation belongs to normal input and its own budget.
        guard raw == digits, let engine = rimeEngine else { return .ordinary }
        let restored = coordinator.withPublishHandlerSuppressed {
            engine.replaceInput(request.interpretation.spelling)
        }
        if T9ExactRetypeRecovery.acceptsSoftOutput(restored, for: request),
            let verified = verifiedRetypeSnapshot(output: restored, namespace: ns)
        {
            // The endpoint digit has not been painted yet. Letter raw cannot
            // reconstruct the new slot ledger from the previous four-slot Path.
            // Install only the verified source metadata, with no host/engine work,
            // before the new snapshot rebuilds candidates and unconfirmed Paths.
            installIdentityAsPathState(T9CompositionIdentity(sourceDigits: digits))
            applyResponsivePublishedSnapshot(verified)
            return .installed
        }
        var terminal = restored.committedText != nil
        if !terminal {
            let rollback = coordinator.withPublishHandlerSuppressed { engine.replaceInput(digits) }
            terminal = rollback.committedText != nil
            if rollback.rawInput == digits, rollback.composition?.preeditText.isEmpty == false,
                !terminal, let verified = verifiedRetypeSnapshot(output: rollback, namespace: ns)
            {
                applyResponsivePublishedSnapshot(verified)
                return .installed
            }
        }
        // Preserve this verified endpoint output, not the preceding key's source.
        t9ExactRetypeRecovery.freeze(verifiedDigits: digits, namespace: ns, terminal: terminal)
        return .frozen
    }

    private func verifiedRetypeSnapshot(
        output: RimeOutput, namespace: T9ExactRetypeRecovery.Namespace, requiresT9: Bool = true
    ) -> ResponsiveRimeSnapshot? {
        guard t9RetypeNamespace == namespace, let coordinator = threadAffineRimeCoordinator,
            !coordinator.hasPendingWork, coordinator.diagnosticSessionSnapshot?.isValid == true,
            coordinator.runtimeSelection?.usesT9InputSemantics == requiresT9,
            let snapshot = coordinator.lastPublished, let receipt = coordinator.lastAcceptReceipt,
            snapshot.output == output, snapshot.actionID == receipt.actionID,
            snapshot.sessionEpoch == receipt.sessionEpoch, snapshot.revision == receipt.revision
        else { return nil }
        return snapshot
    }

    /// Consult before history preparation and punctuation acceptance/host effects.
    func interceptUntrustedT9Action(_ action: KeyboardAction) -> KeyboardEffect? {
        guard t9ExactRetypeRecovery.isSessionUntrusted else { return nil }
        if t9ExactRetypeRecovery.notice == .needsFreshSession, state.currentComposition.isEmpty,
            let ns = t9RetypeNamespace
        {
            // Explicit cancellation retains no old input. English/symbol entry
            // does not use RIME; the next T9 edit remains quarantined.
            t9ExactRetypeRecovery.didCancelSegment(namespace: ns)
            if state.inputMode != .chinese || state.currentPage != .letters { return nil }
        }
        let directive: T9ExactRetypeRecovery.Directive
        if t9ExactRetypeRecovery.notice == .needsFreshSession, state.currentComposition.isEmpty,
            !usesT9InputSemantics, case .insertKey(let key) = action
        {
            // A cancelled T9 failure may have realized a working 26-key fallback.
            // Restore only this new key; never send old digits to that schema.
            guard shouldHandleAsChineseCompositionKey(key) else { return nil }
            directive = t9ExactRetypeRecovery.planFreshNonT9Key(
                rimeInputKey(for: key), namespace: t9RetypeNamespace)
        } else {
            directive = t9ExactRetypeRecovery.plan(
                for: action, namespace: t9RetypeNamespace, currentKeyboardType: state.activeKeyboardType)
        }
        switch directive {
        case .normal, .shiftOnly: return nil
        case .block: return [.compositionChanged, .t9PinyinPathsChanged]
        case .abandonContext:
            abandonUntrustedRetypeWithoutHostWrite()
            return [.compositionChanged, .t9PinyinPathsChanged]
        case .cancelSegment:
            let effects = dropRemainingPreeditKeepingConfirmedPrefix()
            if let ns = t9RetypeNamespace { t9ExactRetypeRecovery.didCancelSegment(namespace: ns) }
            return effects
        case .cancelAndSwitch:
            var effects = dropRemainingPreeditKeepingConfirmedPrefix()
            switch action {
            case .toggleInputMode: effects.formUnion(handleToggleInputMode())
            case .togglePage: effects.formUnion(handleTogglePage())
            case .keyboardTypeChanged(let type): effects.formUnion(handleKeyboardTypeChanged(type))
            default: break
            }
            t9RetypeEditingGeneration &+= 1
            if let ns = t9RetypeNamespace { t9ExactRetypeRecovery.didCancelSegment(namespace: ns) }
            return effects
        case .recover(let request):
            guard let coordinator = threadAffineRimeCoordinator, let engine = rimeEngine else {
                return [.compositionChanged, .t9PinyinPathsChanged]
            }
            let output = coordinator.withPublishHandlerSuppressed {
                engine.recoverSession()
                applyRealizedSelectionFromEngine()
                guard coordinator.runtimeSelection?.usesT9InputSemantics == request.requiresT9Semantics else {
                    return RimeOutput()
                }
                return engine.replaceInput(request.targetRawInput)
            }
            let ns = t9RetypeNamespace ?? request.namespace
            // Validate delivery before releasing quarantine. A matching raw alone
            // cannot make a stale or undelivered snapshot eligible for host apply.
            let verified = verifiedRetypeSnapshot(
                output: output, namespace: ns, requiresT9: request.requiresT9Semantics)
            let accepted = t9ExactRetypeRecovery.completeRecovery(
                request, output: output, realizedNamespace: ns,
                sessionValid: verified != nil,
                usesT9Semantics: coordinator.runtimeSelection?.usesT9InputSemantics == true)
            if accepted, let verified { applyResponsivePublishedSnapshot(verified) }
            return [.compositionChanged, .t9PinyinPathsChanged]
        }
    }

    /// Unbind/foreign identity may not clear marked text through a new adapter.
    func abandonUntrustedRetypeWithoutHostWrite() {
        let wasUntrusted = t9ExactRetypeRecovery.isSessionUntrusted
        if wasUntrusted {
            threadAffineRimeCoordinator?.bumpSessionEpoch()
            clearResponsiveKeyApplyContexts()
            state.currentComposition = ""
            state.lastRimeOutput = nil
            state.partialCommit = nil
            state.insertedPreeditText = ""
            state.insertedPreeditCount = 0
            clearT9PinyinPathState()
        }
        t9RetypeEditingGeneration &+= 1
        if wasUntrusted {
            // An epoch fence alone is not native-session readiness. Keep the
            // next edit behind fresh recovery, even with no adapter bound yet.
            if let coordinator = threadAffineRimeCoordinator {
                t9ExactRetypeRecovery.didCancelSegment(
                    namespace: .init(
                        ownerID: coordinator.instanceIdentity,
                        sessionEpoch: coordinator.diagnostics.sessionEpoch,
                        editingGeneration: t9RetypeEditingGeneration))
            } else {
                t9ExactRetypeRecovery.discardRetainedComposition()
            }
        } else {
            t9ExactRetypeRecovery.abandonAfterSessionFence()
        }
    }

    func finishRetypeLifecycleFence() {
        let wasUntrusted = t9ExactRetypeRecovery.isSessionUntrusted
        t9ExactRetypeRecovery.clearHistory()
        t9RetypeEditingGeneration &+= 1
        fencePartialCommitFailureRecovery()
        if wasUntrusted, let ns = t9RetypeNamespace {
            t9ExactRetypeRecovery.didCancelSegment(namespace: ns)
        } else if wasUntrusted {
            t9ExactRetypeRecovery.discardRetainedComposition()
        } else {
            t9ExactRetypeRecovery.abandonAfterSessionFence()
        }
    }
}
