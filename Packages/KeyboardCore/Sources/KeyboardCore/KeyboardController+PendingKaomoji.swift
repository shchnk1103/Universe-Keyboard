import Foundation

extension KeyboardController {
    // MARK: - ADR 0030 待确认颜表情

    func handlePressKaomoji() -> KeyboardEffect {
        if rejectIfResponsiveProvisionalAhead() {
            return []
        }

        if state.pendingKaomoji != nil {
            var effects = acceptPendingKaomoji(refreshContinuation: true)
            if state.pendingKaomoji != nil {
                return effects
            }
            effects.formUnion(insertFreshPendingKaomoji())
            return effects
        }

        if state.pendingPunctuation != nil {
            var effects = acceptPendingPunctuation(refreshContinuation: true)
            if state.pendingPunctuation != nil {
                return effects
            }
            effects.formUnion(insertFreshPendingKaomoji())
            return effects
        }

        var effects: KeyboardEffect = []
        if hasActiveCompositionBlockingPendingPunctuation {
            guard commitFirstCandidateForPendingKaomoji() else {
                return []
            }
            effects.formUnion([.compositionChanged, .t9PinyinPathsChanged, .pendingKaomojiChanged])
            return effects
        }

        effects.formUnion(insertFreshPendingKaomoji())
        return effects
    }

    @discardableResult
    private func commitFirstCandidateForPendingKaomoji() -> Bool {
        if isResponsiveProvisionalAhead
            || state.currentComposition.contains(ResponsiveProvisionalComposition.placeholderScalar)
        {
            return false
        }

        let confirmedPrefix = state.partialCommit?.confirmedText ?? ""
        let firstCandidate =
            state.lastRimeOutput?.candidates.first?.text
            ?? candidateProvider.candidates(for: state.currentComposition).first
        guard let firstCandidate, !firstCandidate.isEmpty else {
            return false
        }

        if let engine = rimeEngine, engine.isComposing() {
            _ = engine.selectCandidate(at: 0)
        }

        let committedText =
            firstCandidate.hasPrefix(confirmedPrefix)
            ? firstCandidate
            : confirmedPrefix + firstCandidate
        let pending = PendingKaomojiState.defaultPending
        commitInlinePreedit(as: committedText + pending, source: .directText)
        state.currentComposition = ""
        state.lastRimeOutput = nil
        state.partialCommit = nil
        clearTypoCorrectionSuggestions()
        rimeEngine?.resetSession()
        clearT9PinyinPathState()
        state.pendingKaomoji = PendingKaomojiState(
            text: pending,
            beforeCursor: pending,
            afterCursor: "",
            ownsHostSpan: true
        )
        return true
    }

    private func insertFreshPendingKaomoji() -> KeyboardEffect {
        insertOwnedKaomojiPayload(
            beforeCursor: PendingKaomojiState.defaultPending,
            afterCursor: ""
        )
    }

    func handleKaomojiCandidate(_ candidate: String) -> KeyboardEffect {
        guard let pending = state.pendingKaomoji, pending.canMutateHost else {
            return []
        }
        let isCatalogToken = PendingKaomojiState.catalogTokens.contains(candidate)
        let isCurrentPending = candidate == pending.text
        guard isCatalogToken || isCurrentPending else {
            return []
        }

        if isCurrentPending {
            return .pendingKaomojiChanged
        }

        return replacePendingKaomoji(with: candidate)
    }

    @discardableResult
    func acceptPendingKaomoji(refreshContinuation: Bool) -> KeyboardEffect {
        guard let pending = state.pendingKaomoji else { return [] }
        let leftover = pending.text
        state.pendingKaomoji = nil
        var effects: KeyboardEffect = [.pendingKaomojiChanged]
        if refreshContinuation {
            refreshContinuationAfterAcceptingPendingKaomoji(leftover)
            effects.insert(.continuationChanged)
        }
        return effects
    }

    func deleteOwnedPendingKaomojiIfNeeded() -> KeyboardEffect? {
        guard let pending = state.pendingKaomoji else { return nil }
        guard pending.canMutateHost else {
            state.pendingKaomoji = nil
            return .pendingKaomojiChanged
        }
        let removed = removeOwnedHostSpan(
            beforeCursor: pending.beforeCursor,
            afterCursor: pending.afterCursor
        )
        state.pendingKaomoji = nil
        var effects: KeyboardEffect = [.pendingKaomojiChanged]
        if !removed {
            effects.formUnion(acceptTornPendingKaomojiWithoutGuessing())
        }
        return effects
    }

    private func replacePendingKaomoji(with text: String) -> KeyboardEffect {
        guard let pending = state.pendingKaomoji, pending.canMutateHost else {
            return []
        }
        let removed = removeOwnedHostSpan(
            beforeCursor: pending.beforeCursor,
            afterCursor: pending.afterCursor
        )
        if !removed {
            state.pendingKaomoji = nil
            return .pendingKaomojiChanged
        }
        return insertOwnedKaomojiPayload(beforeCursor: text, afterCursor: "")
    }

    private func insertOwnedKaomojiPayload(
        beforeCursor: String,
        afterCursor: String
    ) -> KeyboardEffect {
        let text = beforeCursor + afterCursor
        performOwnedHostMutation {
            if !text.isEmpty {
                textClient?.insertText(text)
                onCommittedText?(CommittedTextEvent(text: text, source: .directText))
            }
            if !afterCursor.isEmpty {
                adjustTextPosition(byCharacterOffset: -afterCursor.count)
            }
        }
        state.pendingKaomoji = PendingKaomojiState(
            text: text,
            beforeCursor: beforeCursor,
            afterCursor: afterCursor,
            ownsHostSpan: true
        )
        return .pendingKaomojiChanged
    }

    private func acceptTornPendingKaomojiWithoutGuessing() -> KeyboardEffect {
        state.pendingKaomoji = nil
        return .pendingKaomojiChanged
    }

    private func refreshContinuationAfterAcceptingPendingKaomoji(_ leftover: String) {
        guard isPostCommitContinuationEnabled, state.inputMode == .chinese else {
            state.continuation = ContinuationState()
            return
        }
        refreshContinuation(afterCommitting: leftover)
    }

    public func pendingKaomojiCandidateItems(expanded: Bool) -> [CandidateItem] {
        guard let pending = state.pendingKaomoji else { return [] }
        let titles =
            expanded
            ? PendingKaomojiState.expandedTitles(including: pending.text)
            : PendingKaomojiState.compactTitles(including: pending.text)
        return titles.map { CandidateItem(title: $0, kind: .kaomojiCandidate) }
    }
}
