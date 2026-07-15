extension KeyboardController {
    func refreshTypoCorrectionSuggestions(includingContextual: Bool = false) {
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
        let singleEditSuggestions = TypoCorrectionEngine(
            experimentalEdits: typoCorrectionExperimentalEdits
        ).suggestions(for: correctionInput)
        let contextualSuggestions = includingContextual
            ? ContextualTypoCorrectionHypothesisEngine().hypotheses(for: correctionInput)
            : []
        let generated = contextualSuggestions + singleEditSuggestions
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
            let candidates = typoCorrectionCandidateQuery
                .correctionCandidates(for: suggestion.correctedInput, limit: 3)
                .filter { seenCandidateTexts.insert($0.text).inserted }
            guard !candidates.isEmpty else { continue }

            resolved.append(
                TypoCorrectionSuggestion(
                    originalInput: suggestion.originalInput,
                    correctedInput: suggestion.correctedInput,
                    edits: suggestion.edits,
                    candidates: Array(candidates)
                )
            )

            // 多错误恢复必须与普通按键路径共用严格查询预算。
            if resolved.count >= 4 { break }
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

    /// 在 UI 层确认用户停止连续输入后调用。若输入已变化则直接丢弃，
    /// 从而不让过期的异步工作覆盖当前 composition 的候选栏。
    @discardableResult
    public func refreshContextualTypoCorrectionSuggestions(
        for expectedComposition: String
    ) -> Bool {
        guard normalizedTypoCorrectionInput(state.currentComposition)
            == normalizedTypoCorrectionInput(expectedComposition)
        else { return false }

        refreshTypoCorrectionSuggestions(includingContextual: true)
        return true
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
