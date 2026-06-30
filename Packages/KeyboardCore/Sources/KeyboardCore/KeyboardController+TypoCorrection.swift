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
        let generated = TypoCorrectionEngine(
            experimentalEdits: typoCorrectionExperimentalEdits
        ).suggestions(for: correctionInput)
        #if DEBUG
        TypoCorrectionDecisionTrace.record(
            .effectiveFlags(
                .init(
                    insertionEnabled: typoCorrectionExperimentalEdits.contains(.insertion),
                    transpositionEnabled: typoCorrectionExperimentalEdits.contains(.transposition),
                    typoPartialCommitEnabled: isTypoCorrectionPartialCommitEnabled
                )
            )
        )
        #endif
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
                // RIME 已经把纠正输入的最佳结果放在普通首位时，用户无需旁路纠错。
                // 整组丢弃可避免只剩下“次优纠错候选”的低价值噪声。
                guard suggestion.candidates.first?.text != firstNormalCandidate.text else {
                    #if DEBUG
                    traceSuppression(
                        .suppressedNormalTopMatchesCorrectedBest,
                        suggestion: suggestion,
                        rankingWasSuppressed: true
                    )
                    #endif
                    return nil
                }

                #if DEBUG
                traceSuppression(.notSuppressed, suggestion: suggestion)
                #endif

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
                    || TypoCorrectionConfidence.isHighConfidenceDisplayCandidate(
                        title: candidate.text,
                        suggestion: suggestion,
                        firstNormalCandidate: firstNormalCandidate.text
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
        } else {
            #if DEBUG
            traceSuppression(.notApplicable, suggestion: nil)
            #endif
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

    #if DEBUG
    private func traceSuppression(
        _ decision: TypoCorrectionDecisionTrace.Suppression,
        suggestion: TypoCorrectionSuggestion?,
        rankingWasSuppressed: Bool = false
    ) {
        guard TypoCorrectionDecisionTrace.isCapturing else { return }
        let subject = suggestion.map { typoTraceSubject(for: $0) }
            ?? TypoCorrectionDecisionTrace.invocationSubject
        TypoCorrectionDecisionTrace.record(
            .suppression(.init(subject: subject, decision: decision))
        )
        if rankingWasSuppressed {
            TypoCorrectionDecisionTrace.record(
                .learning(.init(subject: subject, decision: .notEvaluatedDueSuppression))
            )
        }
    }

    private func typoTraceSubject(
        for suggestion: TypoCorrectionSuggestion
    ) -> TypoCorrectionDecisionTrace.DecisionSubject {
        guard let candidate = suggestion.candidates.first else {
            return TypoCorrectionDecisionTrace.invocationSubject
        }
        return TypoCorrectionDecisionTrace.subject(
            for: TypoCorrectionCommit(
                committedText: candidate.text,
                originalInput: suggestion.originalInput,
                correctedInput: suggestion.correctedInput,
                edits: suggestion.edits
            )
        )
    }
    #endif
}
