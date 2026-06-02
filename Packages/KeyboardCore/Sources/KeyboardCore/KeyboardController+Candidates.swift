extension KeyboardController {
    func handleInsertCandidate(_ candidate: String, kind: CandidateKind) -> KeyboardEffect {
        switch kind {
        case .placeholder, .correctionCandidate:
            return []
        case .composition:
            commitComposition()
            rimeEngine?.resetSession()
            state.lastRimeOutput = nil
            clearTypoCorrectionSuggestions()
        case .candidate:
            if let engine = rimeEngine,
                let output = state.lastRimeOutput,
                let index = output.candidates.firstIndex(where: { $0.text == candidate })
            {
                let result = engine.selectCandidate(at: index)
                state.lastRimeOutput = result
                state.currentComposition = result.composition?.preeditText ?? ""
                deleteInlinePreedit()
                if let commit = result.committedText {
                    insertText(commit)
                }
                clearTypoCorrectionSuggestions()
            } else {
                // Candidates from cached later pages cannot leave stale engine composition behind.
                deleteInlinePreedit()
                insertText(candidate)
                state.currentComposition = ""
                state.lastRimeOutput = nil
                rimeEngine?.resetSession()
                clearTypoCorrectionSuggestions()
            }
        }
        return .compositionChanged
    }

    func handleInsertCorrectionCandidate(_ correction: TypoCorrectionCommit) -> KeyboardEffect {
        deleteInlinePreedit()
        insertText(correction.committedText)
        state.currentComposition = ""
        state.lastRimeOutput = nil
        clearTypoCorrectionSuggestions()
        rimeEngine?.resetSession()
        return .compositionChanged
    }

    func handleCandidatePageUp() -> KeyboardEffect {
        guard let engine = rimeEngine else { return [] }
        let output = engine.pageUp()
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
        state.lastRimeOutput = output
        state.currentComposition = output.composition?.preeditText ?? ""
        if let commit = output.committedText {
            insertText(commit)
        }
        return .compositionChanged
    }
}
