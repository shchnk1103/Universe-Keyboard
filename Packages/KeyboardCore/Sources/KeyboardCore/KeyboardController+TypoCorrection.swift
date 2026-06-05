extension KeyboardController {
    func refreshTypoCorrectionSuggestions() {
        guard state.currentPage == .letters,
            state.inputMode == .chinese,
            state.partialCommit == nil,
            !state.currentComposition.isEmpty
        else {
            state.typoCorrection = nil
            return
        }

        let normalCandidates: [RimeCandidate]
        if let output = state.lastRimeOutput {
            normalCandidates = output.candidates
        } else {
            normalCandidates = candidateProvider.candidates(for: state.currentComposition)
                .map { RimeCandidate(text: $0) }
        }

        // librime may expose segmented preedit text such as "ni h a p" or "ni hap".
        // Typo correction operates on the user's key sequence, so ignore display-only whitespace.
        let correctionInput = normalizedTypoCorrectionInput(state.currentComposition)
        let generated = TypoCorrectionEngine().suggestions(for: correctionInput)
        var resolved: [TypoCorrectionSuggestion] = []
        var seenCandidateTexts: Set<String> = []

        for suggestion in generated {
            let candidates = candidateProvider.candidates(for: suggestion.correctedInput)
                .filter { seenCandidateTexts.insert($0).inserted }
                .prefix(3)
                .map { RimeCandidate(text: $0) }
            guard !candidates.isEmpty else { continue }

            resolved.append(
                TypoCorrectionSuggestion(
                    originalInput: suggestion.originalInput,
                    correctedInput: suggestion.correctedInput,
                    edits: suggestion.edits,
                    candidates: Array(candidates)
                )
            )

            // 控制候选栏密度和输入热路径开销。
            if resolved.count >= 2 { break }
        }

        if let firstNormalCandidate = normalCandidates.first {
            resolved = resolved.compactMap { suggestion in
                let candidates = suggestion.candidates.filter { candidate in
                    let commit = TypoCorrectionCommit(
                        committedText: candidate.text,
                        originalInput: suggestion.originalInput,
                        correctedInput: suggestion.correctedInput,
                        edits: suggestion.edits
                    )
                    return TypoCorrectionCandidateRanker.shouldPromoteCorrection(
                        title: candidate.text,
                        correction: commit,
                        over: firstNormalCandidate.text
                    )
                }
                guard !candidates.isEmpty else { return nil }
                return TypoCorrectionSuggestion(
                    originalInput: suggestion.originalInput,
                    correctedInput: suggestion.correctedInput,
                    edits: suggestion.edits,
                    candidates: candidates
                )
            }
        }

        state.typoCorrection = resolved.isEmpty
            ? nil
            : TypoCorrectionState(originalInput: correctionInput, suggestions: resolved)
    }

    func clearTypoCorrectionSuggestions() {
        state.typoCorrection = nil
    }

    private func normalizedTypoCorrectionInput(_ input: String) -> String {
        input.filter { !$0.isWhitespace }
    }
}
