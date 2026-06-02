extension KeyboardController {
    func refreshTypoCorrectionSuggestions() {
        guard state.currentPage == .letters,
            state.inputMode == .chinese,
            !state.currentComposition.isEmpty
        else {
            state.typoCorrection = nil
            return
        }

        // V0.1 只在正常候选为空时提供误触建议，避免覆盖 RIME 的原生排序。
        let normalCandidates: [RimeCandidate]
        if let output = state.lastRimeOutput {
            normalCandidates = output.candidates
        } else {
            normalCandidates = candidateProvider.candidates(for: state.currentComposition)
                .map { RimeCandidate(text: $0) }
        }
        guard normalCandidates.isEmpty else {
            state.typoCorrection = nil
            return
        }

        let generated = TypoCorrectionEngine().suggestions(for: state.currentComposition)
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

        state.typoCorrection = resolved.isEmpty
            ? nil
            : TypoCorrectionState(originalInput: state.currentComposition, suggestions: resolved)
    }

    func clearTypoCorrectionSuggestions() {
        state.typoCorrection = nil
    }
}
