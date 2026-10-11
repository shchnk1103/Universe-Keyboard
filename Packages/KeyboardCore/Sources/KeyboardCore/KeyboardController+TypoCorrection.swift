extension KeyboardController {
    func refreshTypoCorrectionSuggestions(includingContextual: Bool = false) {
        if (typoCorrectionCandidateQuery as? TypoCorrectionSidecarOwner)?
            .isTypoCorrectionRecallActive == true
        {
            return
        }
        guard isEligibleForTypoCorrectionRefresh else {
            state.typoCorrection = nil
            return
        }

        let correctionInput = normalizedTypoCorrectionInput(state.currentComposition)
        let generated = typoCorrectionStageOneHypotheses(
            for: correctionInput,
            includingContextual: includingContextual
        )
        var resolved: [TypoCorrectionSuggestion] = []
        var seenCandidateTexts: Set<String> = []

        for suggestion in generated {
            let candidates =
                typoCorrectionCandidateQuery
                .correctionCandidates(
                    for: suggestion.correctedInput,
                    limit: TypoCorrectionRecallRuntimeBudget.candidateLimit
                )
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

            if resolved.count >= TypoCorrectionRecallRuntimeBudget.acceptedDisplayResults {
                break
            }
        }

        applyRankedTypoCorrection(resolved, originalInput: correctionInput)
    }

    func clearTypoCorrectionSuggestions() {
        (typoCorrectionCandidateQuery as? TypoCorrectionSidecarOwner)?
            .recallInvalidation?
            .invalidateTypoCorrectionRecall()
        state.typoCorrection = nil
    }

    /// 在 UI 层确认用户停止连续输入后调用。若输入已变化则直接丢弃。
    @discardableResult
    public func refreshContextualTypoCorrectionSuggestions(
        for expectedComposition: String
    ) -> Bool {
        guard
            normalizedTypoCorrectionInput(state.currentComposition)
                == normalizedTypoCorrectionInput(expectedComposition)
        else { return false }

        refreshTypoCorrectionSuggestions(includingContextual: true)
        return true
    }

    public func typoCorrectionStageOneHypotheses(
        for correctionInput: String,
        includingContextual: Bool
    ) -> [TypoCorrectionSuggestion] {
        let singleEditSuggestions = TypoCorrectionEngine(
            experimentalEdits: typoCorrectionExperimentalEdits
        ).suggestions(for: correctionInput)
        let contextualSuggestions =
            includingContextual
            ? ContextualTypoCorrectionHypothesisEngine().hypotheses(for: correctionInput)
            : []
        return contextualSuggestions + singleEditSuggestions
    }

    public func acceptedDisplayCount(
        for resolved: [TypoCorrectionSuggestion]
    ) -> Int {
        rankedDisplaySuggestions(from: resolved).count
    }

    @discardableResult
    public func applyTypoCorrectionRecallMaterial(
        _ material: TypoCorrectionRecallMaterial
    ) -> Bool {
        guard !material.joined.isEmpty else { return false }
        guard isEligibleForTypoCorrectionRefresh else { return false }
        let correctionInput = normalizedTypoCorrectionInput(state.currentComposition)
        guard correctionInput == material.originalInput else { return false }

        let before = state.typoCorrection
        applyRankedTypoCorrection(material.joined, originalInput: correctionInput)
        return state.typoCorrection != before
    }

    private var isEligibleForTypoCorrectionRefresh: Bool {
        guard state.currentPage == .letters,
            state.inputMode == .chinese,
            state.partialCommit == nil,
            !state.currentComposition.isEmpty
        else { return false }

        let rawForTypo = state.lastRimeOutput?.rawInput ?? state.currentComposition
        return !T9CompositionCommitPolicy.isActiveT9DigitComposition(
            usesT9InputSemantics: usesT9InputSemantics,
            rawInput: rawForTypo
        )
    }

    private func applyRankedTypoCorrection(
        _ resolved: [TypoCorrectionSuggestion],
        originalInput: String
    ) {
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
        let ranked = rankedDisplaySuggestions(from: resolved)
        state.typoCorrection =
            ranked.isEmpty
            ? nil
            : TypoCorrectionState(originalInput: originalInput, suggestions: ranked)
    }

    private func currentNormalTypoCandidates() -> [RimeCandidate] {
        if let output = state.lastRimeOutput {
            return output.candidates
        }
        return candidateProvider.candidates(for: state.currentComposition)
            .map { RimeCandidate(text: $0) }
    }

    private func rankedDisplaySuggestions(
        from resolved: [TypoCorrectionSuggestion]
    ) -> [TypoCorrectionSuggestion] {
        let normalCandidates = currentNormalTypoCandidates()
        guard let firstNormalCandidate = normalCandidates.first else {
            #if DEBUG
                traceSuppression(.notApplicable, suggestion: nil)
            #endif
            return resolved
        }

        return resolved.compactMap { suggestion in
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
    }

    public func normalizedTypoCorrectionInput(_ input: String) -> String {
        input.filter { !$0.isWhitespace }
    }

    #if DEBUG
        private func traceSuppression(
            _ decision: TypoCorrectionDecisionTrace.Suppression,
            suggestion: TypoCorrectionSuggestion?,
            rankingWasSuppressed: Bool = false
        ) {
            guard TypoCorrectionDecisionTrace.isCapturing else { return }
            let subject =
                suggestion.map { typoTraceSubject(for: $0) }
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
