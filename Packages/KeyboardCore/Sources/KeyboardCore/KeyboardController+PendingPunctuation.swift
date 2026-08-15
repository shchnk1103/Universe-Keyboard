import Foundation

extension KeyboardController {
    // MARK: - ADR 0029 九键待确认标点

    func acceptingPendingPunctuationIfNeeded(_ body: () -> KeyboardEffect) -> KeyboardEffect {
        acceptPendingPunctuation(refreshContinuation: true).union(body())
    }

    func performOwnedHostMutation(_ body: () -> Void) {
        ownedHostMutationDepth += 1
        ownedHostMutationGeneration += 1
        defer { ownedHostMutationDepth -= 1 }
        body()
    }

    /// 非本状态机引起的 document 变化：只接受+清状态，不回删。
    @discardableResult
    public func noteExternalDocumentChange() -> KeyboardEffect {
        guard !isPerformingOwnedHostMutation else { return [] }
        return acceptPendingPunctuation(refreshContinuation: false)
    }

    func handlePressT9CommonPunctuation() -> KeyboardEffect {
        if rejectIfResponsiveProvisionalAhead() {
            return []
        }

        let now = currentDate()
        if let pending = state.pendingPunctuation {
            if pending.isCycleEligible(now: now),
                let index = pending.cycleIndex
            {
                let nextIndex = (index + 1) % PendingPunctuationState.cycleMarks.count
                let nextMark = PendingPunctuationState.cycleMarks[nextIndex]
                return replacePendingPunctuation(
                    with: nextMark,
                    cycleArmed: true,
                    cycleIndex: nextIndex,
                    lastSameKeyTap: now
                )
            }

            var effects = acceptPendingPunctuation(refreshContinuation: true)
            if state.pendingPunctuation != nil {
                return effects
            }
            effects.formUnion(insertFreshPendingComma(now: now))
            return effects
        }

        var effects: KeyboardEffect = []
        if hasActiveCompositionBlockingPendingPunctuation {
            guard commitFirstCandidateForPendingPunctuation() else {
                return []
            }
            effects.formUnion([.compositionChanged, .t9PinyinPathsChanged, .pendingPunctuationChanged])
            return effects
        }

        effects.formUnion(insertFreshPendingComma(now: now))
        return effects
    }

    /// 组字中但没有可提交首选，或仍在 L1-ahead：不得进入 pending。
    private var hasActiveCompositionBlockingPendingPunctuation: Bool {
        if isResponsiveProvisionalAhead
            || state.currentComposition.contains(ResponsiveProvisionalComposition.placeholderScalar)
        {
            return true
        }
        if rimeEngine?.isComposing() == true {
            return true
        }
        if let output = state.lastRimeOutput, output.composition != nil {
            return true
        }
        return !state.currentComposition.isEmpty
    }

    @discardableResult
    private func commitFirstCandidateForPendingPunctuation() -> Bool {
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
        // 一次写入「你好，」。真机 unmark 后光标可能在词首，
        // 再单独 insertText("，") 会变成「，你好」。
        commitInlinePreedit(as: committedText + "，", source: .directText)
        state.currentComposition = ""
        state.lastRimeOutput = nil
        state.partialCommit = nil
        clearTypoCorrectionSuggestions()
        rimeEngine?.resetSession()
        clearT9PinyinPathState()
        state.pendingPunctuation = PendingPunctuationState(
            text: "，",
            beforeCursor: "，",
            afterCursor: "",
            ownsHostSpan: true,
            cycleIndex: 0,
            lastSameKeyTap: currentDate(),
            cycleArmed: true
        )
        return true
    }

    private func insertFreshPendingComma(now: Date) -> KeyboardEffect {
        insertOwnedPunctuationPayload(
            beforeCursor: "，",
            afterCursor: "",
            cycleArmed: true,
            cycleIndex: 0,
            lastSameKeyTap: now
        )
    }

    func handlePunctuationCandidate(_ candidate: String) -> KeyboardEffect {
        guard let pending = state.pendingPunctuation, pending.canMutateHost else {
            return []
        }
        let isCatalogToken = PendingPunctuationState.catalogTokens.contains(candidate)
        let isCurrentPending = candidate == pending.text
        guard isCatalogToken || isCurrentPending else {
            return []
        }

        let closer =
            isCatalogToken && isPairedSymbolCompletionEnabled
            ? PendingPunctuationState.pairedCloser(for: candidate)
            : nil
        return replacePendingPunctuation(
            with: candidate,
            closer: closer,
            cycleArmed: false,
            cycleIndex: PendingPunctuationState.cycleIndex(for: closer == nil ? candidate : candidate + (closer ?? "")),
            lastSameKeyTap: pending.lastSameKeyTap
        )
    }

    @discardableResult
    func acceptPendingPunctuation(refreshContinuation: Bool) -> KeyboardEffect {
        guard let pending = state.pendingPunctuation else { return [] }
        let leftover = pending.text
        state.pendingPunctuation = nil
        var effects: KeyboardEffect = [.pendingPunctuationChanged]
        if refreshContinuation {
            refreshContinuationAfterAcceptingPending(leftover)
            effects.insert(.continuationChanged)
        }
        return effects
    }

    func deleteOwnedPendingPunctuationIfNeeded() -> KeyboardEffect? {
        guard let pending = state.pendingPunctuation else { return nil }
        guard pending.canMutateHost else {
            state.pendingPunctuation = nil
            return .pendingPunctuationChanged
        }
        let removed = removeOwnedPendingSpan(pending)
        state.pendingPunctuation = nil
        var effects: KeyboardEffect = [.pendingPunctuationChanged]
        if !removed {
            effects.formUnion(acceptTornPendingWithoutGuessing())
        }
        return effects
    }

    private func replacePendingPunctuation(
        with opener: String,
        closer: String? = nil,
        cycleArmed: Bool,
        cycleIndex: Int?,
        lastSameKeyTap: Date
    ) -> KeyboardEffect {
        guard let pending = state.pendingPunctuation, pending.canMutateHost else {
            return []
        }
        let removed = removeOwnedPendingSpan(pending)
        if !removed {
            state.pendingPunctuation = nil
            return .pendingPunctuationChanged
        }
        return insertOwnedPunctuationPayload(
            beforeCursor: opener,
            afterCursor: closer ?? "",
            cycleArmed: cycleArmed,
            cycleIndex: cycleIndex,
            lastSameKeyTap: lastSameKeyTap
        )
    }

    private func insertOwnedPunctuationPayload(
        beforeCursor: String,
        afterCursor: String,
        cycleArmed: Bool,
        cycleIndex: Int?,
        lastSameKeyTap: Date
    ) -> KeyboardEffect {
        let text = beforeCursor + afterCursor
        performOwnedHostMutation {
            // 直接写 host，避免走 insertText 的 continuation 刷新边界。
            if !text.isEmpty {
                textClient?.insertText(text)
                onCommittedText?(CommittedTextEvent(text: text, source: .directText))
            }
            if !afterCursor.isEmpty {
                adjustTextPosition(byCharacterOffset: -afterCursor.count)
            }
        }
        state.pendingPunctuation = PendingPunctuationState(
            text: text,
            beforeCursor: beforeCursor,
            afterCursor: afterCursor,
            ownsHostSpan: true,
            cycleIndex: cycleIndex ?? PendingPunctuationState.cycleIndex(for: text),
            lastSameKeyTap: lastSameKeyTap,
            cycleArmed: cycleArmed
        )
        return .pendingPunctuationChanged
    }

    /// 拆下当前 pending 跨度。失败时不猜测 closer 是否还在，返回 false。
    private func removeOwnedPendingSpan(_ pending: PendingPunctuationState) -> Bool {
        let beforeCount = pending.beforeCursor.count
        let afterCount = pending.afterCursor.count
        var removed = true
        performOwnedHostMutation {
            if afterCount > 0 {
                adjustTextPosition(byCharacterOffset: afterCount)
                for _ in 0..<afterCount {
                    let beforeDelete = textClientHasCharactersBeforeCursor(minimum: 1)
                    textClient?.deleteBackward()
                    if !beforeDelete {
                        removed = false
                        break
                    }
                }
            }
            if removed {
                for _ in 0..<beforeCount {
                    let beforeDelete = textClientHasCharactersBeforeCursor(minimum: 1)
                    textClient?.deleteBackward()
                    if !beforeDelete {
                        removed = false
                        break
                    }
                }
            }
        }
        return removed
    }

    private func textClientHasCharactersBeforeCursor(minimum: Int) -> Bool {
        if let fake = textClient as? FakeTextInputClient {
            return fake.cursorOffset >= minimum
        }
        // 真实 host 不能读上下文对账（ADR 0007）。只要求客户端存在。
        return textClient != nil
    }

    private func acceptTornPendingWithoutGuessing() -> KeyboardEffect {
        state.pendingPunctuation = nil
        return .pendingPunctuationChanged
    }

    private func refreshContinuationAfterAcceptingPending(_ leftover: String) {
        guard isPostCommitContinuationEnabled, state.inputMode == .chinese else {
            state.continuation = ContinuationState()
            return
        }
        refreshContinuation(afterCommitting: leftover)
    }

    public func pendingPunctuationCandidateItems(expanded: Bool) -> [CandidateItem] {
        guard let pending = state.pendingPunctuation else { return [] }
        let titles: [String]
        if expanded {
            if PendingPunctuationState.catalogTokens.contains(pending.text) {
                titles = PendingPunctuationState.catalogTokens
            } else {
                titles = [pending.text] + PendingPunctuationState.catalogTokens
            }
        } else {
            titles = PendingPunctuationState.compactTitles(excluding: pending.text)
        }
        return titles.map { CandidateItem(title: $0, kind: .punctuationCandidate) }
    }
}
