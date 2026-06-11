extension KeyboardController {
    func handleInsertCandidate(
        _ candidate: String,
        kind: CandidateKind,
        selectionReference: CandidateSelectionReference? = nil
    ) -> KeyboardEffect {
        switch kind {
        case .placeholder, .correctionCandidate:
            return []
        case .composition:
            finishActiveCompositionAsDisplayText()
            rimeEngine?.resetSession()
            state.lastRimeOutput = nil
            state.partialCommit = nil
            clearTypoCorrectionSuggestions()
        case .candidate:
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
            } else {
                if rimeEngine == nil || state.lastRimeOutput == nil {
                    commitFallbackCandidate(candidate)
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
        if applyTypoCorrectionPartialCommit(correction) {
            return .compositionChanged
        }

        deleteInlinePreedit()
        insertText(correction.committedText)
        state.currentComposition = ""
        state.lastRimeOutput = nil
        state.partialCommit = nil
        clearTypoCorrectionSuggestions()
        rimeEngine?.resetSession()
        return .compositionChanged
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
            insertText(commit)
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
            insertText(commit)
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
        deleteInlinePreedit()
        insertText((state.partialCommit?.confirmedText ?? "") + candidate)
        state.currentComposition = ""
        state.lastRimeOutput = nil
        state.partialCommit = nil
        rimeEngine?.resetSession()
        clearTypoCorrectionSuggestions()
    }
}
