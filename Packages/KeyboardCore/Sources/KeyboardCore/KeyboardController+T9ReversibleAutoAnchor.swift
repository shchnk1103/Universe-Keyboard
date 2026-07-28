extension KeyboardController {
    /// Applies at most one automatic anchor transaction for the current T9
    /// composition. The caller must already have installed the key's RIME output.
    func attemptReversibleT9AutoAnchorIfNeeded(
        using engine: RimeEngine
    ) -> T9ReversibleAutoAnchorOutcome {
        guard isReversibleT9AutoAnchorEnabled,
              usesT9InputSemantics,
              state.t9ReversibleAutoAnchorState.phase == .idle,
              state.partialCommit == nil,
              state.t9PinyinPathState.selectedPath == nil,
              state.t9PinyinPathState.confirmedSegmentValues.isEmpty,
              let output = state.lastRimeOutput
        else {
            return .notEligible
        }

        let sourceDigits =
            state.t9PinyinPathState.segmentSourceDigits
            ?? T9PinyinPathExtractor.pureDigitRaw(output.rawInput)
        guard let proposal = T9ReversibleAutoAnchorPolicy.proposal(
            sourceDigits: sourceDigits,
            output: output
        ) else {
            return .notEligible
        }
        let userPathSnapshot = state.t9PinyinPathState

        // Mark the composition before crossing the RIME boundary. Any rejection
        // still consumes its single automatic attempt.
        state.t9ReversibleAutoAnchorState = T9ReversibleAutoAnchorState(
            phase: .rejected,
            sourceDigits: proposal.sourceDigits
        )

        let refined: RimeOutput
        #if DEBUG || T9_AUTO_ANCHOR_DEVICE_PREFLIGHT
        refined = HotPathSegmentTiming.measure(.rime) {
            engine.replaceInput(proposal.replacementRawInput)
        }
        #else
        refined = engine.replaceInput(proposal.replacementRawInput)
        #endif
        #if DEBUG || T9_AUTO_ANCHOR_DEVICE_PREFLIGHT
        HotPathSegmentTiming.noteEngineOutput(refined)
        #endif
        let validation = T9ReversibleAutoAnchorPolicy.validate(
            proposal: proposal,
            result: refined
        )

        if validation.isAccepted {
            applyRimeOutput(augmentRimeOutputIfNeeded(refined))
            restoreUnconfirmedT9PathSnapshotAfterAutomaticAnchor(
                userPathSnapshot,
                sourceDigits: proposal.sourceDigits
            )
            state.t9ReversibleAutoAnchorState = T9ReversibleAutoAnchorState(
                phase: .accepted,
                sourceDigits: proposal.sourceDigits,
                replacementRawInput: proposal.replacementRawInput,
                anchoredSlotCount: proposal.anchoredSlotCount
            )
            let outcome = T9ReversibleAutoAnchorOutcome(
                status: .accepted,
                baselineCandidateCount: proposal.baselineCandidateTexts.count,
                resultingCandidateCount: validation.resultingCandidateCount,
                overlappingCandidateCount: validation.overlappingCandidateCount,
                anchoredSlotCount: proposal.anchoredSlotCount,
                unresolvedSlotCount: proposal.unresolvedSlotCount
            )
            logReversibleT9AutoAnchor(outcome)
            return outcome
        }

        let restored: RimeOutput
        #if DEBUG || T9_AUTO_ANCHOR_DEVICE_PREFLIGHT
        restored = HotPathSegmentTiming.measure(.rime) {
            engine.replaceInput(proposal.sourceDigits)
        }
        #else
        restored = engine.replaceInput(proposal.sourceDigits)
        #endif
        #if DEBUG || T9_AUTO_ANCHOR_DEVICE_PREFLIGHT
        HotPathSegmentTiming.noteEngineOutput(restored)
        #endif
        if isUsableRestoredT9AutoAnchorOutput(
            restored,
            expectedSourceDigits: proposal.sourceDigits
        ) {
            applyRimeOutput(augmentRimeOutputIfNeeded(restored))
            state.t9ReversibleAutoAnchorState = T9ReversibleAutoAnchorState(
                phase: .rejected,
                sourceDigits: proposal.sourceDigits
            )
            let outcome = T9ReversibleAutoAnchorOutcome(
                status: .rejectedAndRestored,
                baselineCandidateCount: proposal.baselineCandidateTexts.count,
                resultingCandidateCount: validation.resultingCandidateCount,
                overlappingCandidateCount: validation.overlappingCandidateCount,
                anchoredSlotCount: proposal.anchoredSlotCount,
                unresolvedSlotCount: proposal.unresolvedSlotCount
            )
            logReversibleT9AutoAnchor(outcome)
            return outcome
        }

        // A failed rollback means the session no longer has a trustworthy raw
        // identity. Clear the composition rather than expose digits or guessed
        // spelling to the host.
        engine.resetSession()
        state.currentComposition = ""
        state.lastRimeOutput = nil
        state.partialCommit = nil
        updateInlinePreedit("", source: .compositionProjection)
        clearTypoCorrectionSuggestions()
        clearT9PinyinPathState()
        state.t9ReversibleAutoAnchorState = T9ReversibleAutoAnchorState(
            phase: .rejected,
            sourceDigits: proposal.sourceDigits
        )
        let outcome = T9ReversibleAutoAnchorOutcome(
            status: .restoreFailed,
            baselineCandidateCount: proposal.baselineCandidateTexts.count,
            resultingCandidateCount: validation.resultingCandidateCount,
            overlappingCandidateCount: validation.overlappingCandidateCount,
            anchoredSlotCount: proposal.anchoredSlotCount,
            unresolvedSlotCount: proposal.unresolvedSlotCount
        )
        logReversibleT9AutoAnchor(outcome)
        return outcome
    }

    /// Keeps the rollback ledger aligned with digits typed after an accepted
    /// anchor. Call only after RIME accepted the appended digit.
    func recordAcceptedT9AutoAnchorDigit(
        _ input: String,
        liveRawInput: String?
    ) {
        guard state.t9ReversibleAutoAnchorState.phase == .accepted,
              input.count == 1,
              input.first.map({ ("2"..."9").contains($0) }) == true
        else {
            return
        }
        state.t9ReversibleAutoAnchorState.sourceDigits += input
        if let liveRawInput, !liveRawInput.isEmpty {
            state.t9ReversibleAutoAnchorState.replacementRawInput = liveRawInput
        } else {
            state.t9ReversibleAutoAnchorState.replacementRawInput += input
        }
    }

    enum T9AutoAnchorDeleteRollback {
        case notNeeded
        case restored
        case failed
    }

    /// Delete is user-owned. Restore the full accumulated digit identity before
    /// normal deletion so the automatic prefix never becomes irreversible.
    func rollbackAcceptedT9AutoAnchorForDelete(
        using engine: RimeEngine
    ) -> T9AutoAnchorDeleteRollback {
        guard state.t9ReversibleAutoAnchorState.phase == .accepted else {
            return .notNeeded
        }
        let sourceDigits = state.t9ReversibleAutoAnchorState.sourceDigits
        guard !sourceDigits.isEmpty else {
            state.t9ReversibleAutoAnchorState = .empty
            return .failed
        }

        let restored = engine.replaceInput(sourceDigits)
        guard isUsableRestoredT9AutoAnchorOutput(
            restored,
            expectedSourceDigits: sourceDigits
        ) else {
            engine.resetSession()
            state.currentComposition = ""
            state.lastRimeOutput = nil
            state.partialCommit = nil
            updateInlinePreedit("", source: .compositionProjection)
            clearTypoCorrectionSuggestions()
            clearT9PinyinPathState()
            state.t9ReversibleAutoAnchorState = .empty
            return .failed
        }

        applyRimeOutput(augmentRimeOutputIfNeeded(restored))
        // Rejected prevents a second automatic attempt after the user edit.
        state.t9ReversibleAutoAnchorState = T9ReversibleAutoAnchorState(
            phase: .rejected,
            sourceDigits: sourceDigits
        )
        return .restored
    }

    private func isUsableRestoredT9AutoAnchorOutput(
        _ output: RimeOutput,
        expectedSourceDigits: String
    ) -> Bool {
        output.committedText == nil
            && output.composition?.preeditText.isEmpty == false
            && T9PinyinPathExtractor.pureDigitRaw(output.rawInput)
                == expectedSourceDigits
    }

    /// Mixed raw contains automatic syllable boundaries, not user-confirmed
    /// Path choices. Restore the pre-transaction snapshot against the new
    /// revision so the Path UI stays selectable without adopting that prefix.
    private func restoreUnconfirmedT9PathSnapshotAfterAutomaticAnchor(
        _ snapshot: T9PinyinPathState,
        sourceDigits: String
    ) {
        var restored = snapshot
        restored.compactPaths = restampPaths(snapshot.compactPaths)
        restored.selectedPath = nil
        restored.compositionRevision = state.compositionRevision
        restored.trackedRawInput = sourceDigits
        restored.issuedReplacementKeys = Set(
            restored.compactPaths.map(\.replacementRawInput)
        )
        restored.issuedPathIDs = Set(restored.compactPaths.map(\.id))
        restored.segmentSourceDigits = sourceDigits
        restored.focusedSegmentIndex = sourceDigits.isEmpty ? nil : 0
        restored.confirmedSegmentValues = []
        restored.provisionalPathID = restored.compactPaths.first?.id
        state.t9PinyinPathState = restored
    }

    private func logReversibleT9AutoAnchor(
        _ outcome: T9ReversibleAutoAnchorOutcome
    ) {
        #if DEBUG
        onReversibleT9AutoAnchorOutcome?(outcome)
        #endif
        #if DEBUG || T9_AUTO_ANCHOR_DEVICE_PREFLIGHT
        let record =
            "T9AUTO status=\(outcome.status.rawValue) "
                + "baseline=\(outcome.baselineCandidateCount) "
                + "result=\(outcome.resultingCandidateCount) "
                + "overlap=\(outcome.overlappingCandidateCount) "
                + "anchorSlots=\(outcome.anchoredSlotCount) "
                + "unresolvedSlots=\(outcome.unresolvedSlotCount)"
        #if T9_AUTO_ANCHOR_DEVICE_PREFLIGHT
        Logger.shared.devicePreflightPerformance(record, level: .debug)
        #else
        Logger.shared.debug(record, category: .performance)
        #endif
        #endif
    }
}
