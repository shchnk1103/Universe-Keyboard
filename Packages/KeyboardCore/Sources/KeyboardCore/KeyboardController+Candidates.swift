extension KeyboardController {
    func handleInsertCandidate(
        _ candidate: String,
        kind: CandidateKind,
        selectionReference: CandidateSelectionReference? = nil
    ) -> KeyboardEffect {
        switch kind {
        case .placeholder, .correctionCandidate:
            return []
        case .continuationCandidate:
            guard isPostCommitContinuationEnabled,
                  state.continuation.suggestions.contains(candidate)
            else {
                return []
            }
            insertText(candidate, source: .candidate)
            return .continuationChanged
        case .composition:
            finishActiveCompositionAsDisplayText()
            rimeEngine?.resetSession()
            state.lastRimeOutput = nil
            state.partialCommit = nil
            clearTypoCorrectionSuggestions()
            // Path state cleared inside finishActiveCompositionAsDisplayText.
            return .compositionChanged.union(.t9PinyinPathsChanged)
        case .candidate:
            if state.partialCommit?.source == .numberSuffix {
                commitInlinePreedit(as: candidate, source: .candidate)
                state.currentComposition = ""
                state.lastRimeOutput = RimeOutput(
                    composition: nil,
                    candidates: [],
                    committedText: candidate,
                    hasMorePages: false
                )
                state.partialCommit = nil
                rimeEngine?.resetSession()
                clearTypoCorrectionSuggestions()
                let pathEffect = clearT9PinyinPathStateReturningEffect()
                return .compositionChanged.union(pathEffect)
            }

            if let engine = rimeEngine, let output = state.lastRimeOutput,
                let index = candidateIndex(for: candidate, selectionReference: selectionReference, output: output)
                    ?? selectionReference?.globalIndex
            {
                let result: RimeOutput
                if let globalIndex = selectionReference?.globalIndex {
                    result = engine.selectCandidate(globalIndex: globalIndex)
                } else {
                    result = engine.selectCandidate(at: index)
                }
                guard selectionResultChanged(result, from: output) else {
                    Logger.shared.warning(
                        "candidate selection ignored: unchanged RIME output index=\(index) global=\(selectionReference?.globalIndex.map(String.init) ?? "nil")",
                        category: .engine
                    )
                    return .compositionChanged
                }
                applyNormalCandidateSelection(candidate: candidate, result: result, previousOutput: output)
                // Final commit clears path state inside finishNormalCandidateSelection;
                // partial selection installs a new RimeOutput — hard provenance even if raw
                // identity is unchanged (comments/candidates may have narrowed).
                let pathEffect: KeyboardEffect =
                    state.lastRimeOutput?.rawInput == nil || (state.lastRimeOutput?.rawInput?.isEmpty ?? true)
                    ? clearT9PinyinPathStateReturningEffect()
                    : (applyT9PinyinPathStateFromNewRimeOutput() ? .t9PinyinPathsChanged : [])
                return .compositionChanged.union(pathEffect)
            } else {
                if rimeEngine == nil || state.lastRimeOutput == nil {
                    commitFallbackCandidate(candidate)
                    let pathEffect = clearT9PinyinPathStateReturningEffect()
                    return .compositionChanged.union(pathEffect)
                } else {
                    Logger.shared.warning(
                        "candidate selection ignored: no live RIME reference candidateLength=\(candidate.count)",
                        category: .engine
                    )
                }
            }
        }
        return .compositionChanged
    }

    func handleInsertCorrectionCandidate(_ correction: TypoCorrectionCommit) -> KeyboardEffect {
        if TypoCorrectionLearningKey(correction: correction) != nil {
            onTypoCorrectionSelected?(correction)
        }

        if applyTypoCorrectionPartialCommit(correction) {
            return .compositionChanged
        }

        commitInlinePreedit(as: correction.committedText, source: .correction)
        state.currentComposition = ""
        state.lastRimeOutput = nil
        state.partialCommit = nil
        clearTypoCorrectionSuggestions()
        let pathEffect = clearT9PinyinPathStateReturningEffect()
        rimeEngine?.resetSession()
        return .compositionChanged.union(pathEffect)
    }

    func handleCandidatePageUp() -> KeyboardEffect {
        guard let engine = rimeEngine else { return [] }
        let output = engine.pageUp()
        if state.partialCommit != nil {
            state.lastRimeOutput = output
            return .compositionChanged
        }
        state.lastRimeOutput = output
        state.currentComposition = output.composition?.preeditText ?? ""
        if let commit = output.committedText {
            insertText(commit, source: .engineCommit)
        }
        return .compositionChanged
    }

    func handleCandidatePageDown() -> KeyboardEffect {
        guard let engine = rimeEngine else { return [] }
        let output = engine.pageDown()
        if state.partialCommit != nil {
            state.lastRimeOutput = output
            return .compositionChanged
        }
        state.lastRimeOutput = output
        state.currentComposition = output.composition?.preeditText ?? ""
        if let commit = output.committedText {
            insertText(commit, source: .engineCommit)
        }
        return .compositionChanged
    }

    private func candidateIndex(
        for candidate: String,
        selectionReference: CandidateSelectionReference?,
        output: RimeOutput
    ) -> Int? {
        if let selectionReference,
            selectionReference.page == output.candidatePageNumber,
            output.candidates.indices.contains(selectionReference.indexOnPage)
        {
            return selectionReference.indexOnPage
        }
        return output.candidates.firstIndex(where: { $0.text == candidate })
    }

    private func selectionResultChanged(_ result: RimeOutput, from previous: RimeOutput) -> Bool {
        if result.committedText != nil { return true }
        if result.rawInput != previous.rawInput { return true }
        if result.composition != previous.composition { return true }
        if result.candidates != previous.candidates { return true }
        if result.hasMorePages != previous.hasMorePages { return true }
        if result.highlightedIndex != previous.highlightedIndex { return true }
        if result.candidatePageNumber != previous.candidatePageNumber { return true }
        return false
    }

    private func commitFallbackCandidate(_ candidate: String) {
        commitInlinePreedit(
            as: (state.partialCommit?.confirmedText ?? "") + candidate,
            source: .candidate
        )
        state.currentComposition = ""
        state.lastRimeOutput = nil
        state.partialCommit = nil
        rimeEngine?.resetSession()
        clearTypoCorrectionSuggestions()
    }
}
