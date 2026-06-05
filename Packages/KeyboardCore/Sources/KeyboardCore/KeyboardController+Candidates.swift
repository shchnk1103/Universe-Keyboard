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
                let index = candidateIndex(
                    for: candidate,
                    selectionReference: selectionReference,
                    output: output
                )
            {
                let result = engine.selectCandidate(at: index)
                applyNormalCandidateSelection(candidate: candidate, result: result, previousOutput: output)
            } else {
                // Candidates from cached later pages cannot leave stale engine composition behind.
                deleteInlinePreedit()
                insertText((state.partialCommit?.confirmedText ?? "") + candidate)
                state.currentComposition = ""
                state.lastRimeOutput = nil
                state.partialCommit = nil
                rimeEngine?.resetSession()
                clearTypoCorrectionSuggestions()
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
}
