import Foundation

extension KeyboardController {
    /// Applies at most one automatic anchor transaction for the current T9
    /// composition. The caller must already have installed the key's RIME output.
    func attemptReversibleT9AutoAnchorIfNeeded(
        using engine: RimeEngine
    ) -> T9ReversibleAutoAnchorOutcome {
        guard isReversibleT9AutoAnchorEnabled,
              usesT9InputSemantics,
              state.partialCommit == nil,
              state.t9PinyinPathState.selectedPath == nil,
              state.t9PinyinPathState.confirmedSegmentValues.isEmpty,
              let output = state.lastRimeOutput
        else {
            return .notEligible
        }

        let priorLedger = state.t9ReversibleAutoAnchorState
        let attemptIndex: Int
        let proposal: T9ReversibleAutoAnchorPolicy.Proposal
        let rollbackRawInput: String
        let previousAnchoredSyllableCount: Int
        let previousAnchoredSlotCount: Int

        switch priorLedger.phase {
        case .idle:
            let sourceDigits =
                state.t9PinyinPathState.segmentSourceDigits
                ?? T9PinyinPathExtractor.pureDigitRaw(output.rawInput)
            // S2.3: earlier-first only changes attempt-1 configuration floors.
            let attempt1Configuration: T9ReversibleAutoAnchorPolicy.Configuration =
                isEarlierFirstT9AutoAnchorEnabled
                ? .experimentalEarlierFirst
                : .experimental
            guard let initialProposal = T9ReversibleAutoAnchorPolicy.proposal(
                sourceDigits: sourceDigits,
                output: output,
                configuration: attempt1Configuration
            ) else {
                return .notEligible
            }
            attemptIndex = 1
            proposal = initialProposal
            rollbackRawInput = initialProposal.sourceDigits
            previousAnchoredSyllableCount = 0
            previousAnchoredSlotCount = 0

        case .accepted:
            let maxAutomaticAttempts =
                isTripleRollingT9AutoAnchorEnabled
                ? 3
                : (isRollingT9AutoAnchorEnabled ? 2 : 1)
            guard isRollingT9AutoAnchorEnabled,
                  priorLedger.automaticApplyAttemptCount >= 1,
                  priorLedger.automaticApplyAttemptCount < maxAutomaticAttempts,
                  priorLedger.sourceDigits.count
                    > priorLedger.lastAttemptSourceDigitCount,
                  output.rawInput == priorLedger.replacementRawInput,
                  let extensionProposal =
                    T9ReversibleAutoAnchorPolicy.cumulativeExtensionProposal(
                        sourceDigits: priorLedger.sourceDigits,
                        output: output,
                        existingReplacementRawInput:
                            priorLedger.replacementRawInput,
                        existingAnchoredSyllableCount:
                            priorLedger.anchoredSyllableCount,
                        existingAnchoredSlotCount:
                            priorLedger.anchoredSlotCount
                    )
            else {
                return .notEligible
            }
            // Attempt 2 is S2.1; attempt 3 is S2.2 triple-rolling only.
            attemptIndex = priorLedger.automaticApplyAttemptCount + 1
            proposal = extensionProposal
            rollbackRawInput = priorLedger.replacementRawInput
            previousAnchoredSyllableCount = priorLedger.anchoredSyllableCount
            previousAnchoredSlotCount = priorLedger.anchoredSlotCount

        case .rejected:
            return .notEligible
        }
        let userPathSnapshot = state.t9PinyinPathState

        // Consume the bounded attempt before crossing RIME. A rejected
        // extension may restore the prior accepted mixed raw, but never its
        // attempt budget.
        if attemptIndex == 1 {
            state.t9ReversibleAutoAnchorState = T9ReversibleAutoAnchorState(
                phase: .rejected,
                sourceDigits: proposal.sourceDigits,
                automaticApplyAttemptCount: 1,
                lastAttemptSourceDigitCount: proposal.sourceDigits.count
            )
        } else {
            var consumedLedger = priorLedger
            consumedLedger.automaticApplyAttemptCount = attemptIndex
            consumedLedger.lastAttemptSourceDigitCount = proposal.sourceDigits.count
            state.t9ReversibleAutoAnchorState = consumedLedger
        }

        let applyStartedAt = ProcessInfo.processInfo.systemUptime
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
        let applyDurationMilliseconds =
            (ProcessInfo.processInfo.systemUptime - applyStartedAt) * 1_000
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
                replacementRawInput:
                    refined.rawInput ?? proposal.replacementRawInput,
                anchoredSyllableCount: proposal.anchoredSyllables.count,
                anchoredSlotCount: proposal.anchoredSlotCount,
                automaticApplyAttemptCount: attemptIndex,
                lastAttemptSourceDigitCount: proposal.sourceDigits.count
            )
            let outcome = T9ReversibleAutoAnchorOutcome(
                status: .accepted,
                baselineCandidateCount: proposal.baselineCandidateTexts.count,
                resultingCandidateCount: validation.resultingCandidateCount,
                overlappingCandidateCount: validation.overlappingCandidateCount,
                attemptIndex: attemptIndex,
                anchoredSyllableCount: proposal.anchoredSyllables.count,
                newlyAnchoredSyllableCount:
                    proposal.anchoredSyllables.count
                    - previousAnchoredSyllableCount,
                newlyAnchoredSlotCount:
                    proposal.anchoredSlotCount - previousAnchoredSlotCount,
                anchoredSlotCount: proposal.anchoredSlotCount,
                unresolvedSlotCount: proposal.unresolvedSlotCount,
                applyDurationMilliseconds: applyDurationMilliseconds,
                restoreDurationMilliseconds: 0
            )
            logReversibleT9AutoAnchor(outcome)
            return outcome
        }

        let restoreStartedAt = ProcessInfo.processInfo.systemUptime
        let restored: RimeOutput
        #if DEBUG || T9_AUTO_ANCHOR_DEVICE_PREFLIGHT
        restored = HotPathSegmentTiming.measure(.rime) {
            engine.replaceInput(rollbackRawInput)
        }
        #else
        restored = engine.replaceInput(rollbackRawInput)
        #endif
        #if DEBUG || T9_AUTO_ANCHOR_DEVICE_PREFLIGHT
        HotPathSegmentTiming.noteEngineOutput(restored)
        #endif
        let restoreDurationMilliseconds =
            (ProcessInfo.processInfo.systemUptime - restoreStartedAt) * 1_000
        let restoreSucceeded =
            attemptIndex == 1
            ? isUsableRestoredT9AutoAnchorOutput(
                restored,
                expectedSourceDigits: proposal.sourceDigits
            )
            : isUsableRestoredMixedT9AutoAnchorOutput(
                restored,
                expectedRawInput: rollbackRawInput
            )
        if restoreSucceeded {
            applyRimeOutput(augmentRimeOutputIfNeeded(restored))
            if attemptIndex == 1 {
                state.t9ReversibleAutoAnchorState = T9ReversibleAutoAnchorState(
                    phase: .rejected,
                    sourceDigits: proposal.sourceDigits,
                    automaticApplyAttemptCount: 1,
                    lastAttemptSourceDigitCount: proposal.sourceDigits.count
                )
            } else {
                // Keep the prior accepted mixed identity; mark budget exhausted
                // at the rejected attempt index (2 or 3).
                var restoredLedger = priorLedger
                restoredLedger.automaticApplyAttemptCount = attemptIndex
                restoredLedger.lastAttemptSourceDigitCount =
                    proposal.sourceDigits.count
                state.t9ReversibleAutoAnchorState = restoredLedger
                restoreUnconfirmedT9PathSnapshotAfterAutomaticAnchor(
                    userPathSnapshot,
                    sourceDigits: proposal.sourceDigits
                )
            }
            let outcome = T9ReversibleAutoAnchorOutcome(
                status: .rejectedAndRestored,
                baselineCandidateCount: proposal.baselineCandidateTexts.count,
                resultingCandidateCount: validation.resultingCandidateCount,
                overlappingCandidateCount: validation.overlappingCandidateCount,
                attemptIndex: attemptIndex,
                anchoredSyllableCount: proposal.anchoredSyllables.count,
                newlyAnchoredSyllableCount:
                    proposal.anchoredSyllables.count
                    - previousAnchoredSyllableCount,
                newlyAnchoredSlotCount:
                    proposal.anchoredSlotCount - previousAnchoredSlotCount,
                anchoredSlotCount: proposal.anchoredSlotCount,
                unresolvedSlotCount: proposal.unresolvedSlotCount,
                applyDurationMilliseconds: applyDurationMilliseconds,
                restoreDurationMilliseconds: restoreDurationMilliseconds
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
            automaticApplyAttemptCount: attemptIndex,
            lastAttemptSourceDigitCount: proposal.sourceDigits.count
        )
        let outcome = T9ReversibleAutoAnchorOutcome(
            status: .restoreFailed,
            baselineCandidateCount: proposal.baselineCandidateTexts.count,
            resultingCandidateCount: validation.resultingCandidateCount,
            overlappingCandidateCount: validation.overlappingCandidateCount,
            attemptIndex: attemptIndex,
            anchoredSyllableCount: proposal.anchoredSyllables.count,
            newlyAnchoredSyllableCount:
                proposal.anchoredSyllables.count
                - previousAnchoredSyllableCount,
            newlyAnchoredSlotCount:
                proposal.anchoredSlotCount - previousAnchoredSlotCount,
            anchoredSlotCount: proposal.anchoredSlotCount,
            unresolvedSlotCount: proposal.unresolvedSlotCount,
            applyDurationMilliseconds: applyDurationMilliseconds,
            restoreDurationMilliseconds: restoreDurationMilliseconds
        )
        logReversibleT9AutoAnchor(outcome)
        return outcome
    }

    /// Verifies the accepted mixed-raw identity before a new digit reaches
    /// RIME. A mismatch is terminal for this composition and adds no replace.
    func rejectAcceptedT9AutoAnchorIdentityMismatchIfNeeded(
        _ input: String,
        liveRawInput: String?,
        using engine: RimeEngine
    ) -> Bool {
        let ledger = state.t9ReversibleAutoAnchorState
        guard ledger.phase == .accepted,
              input.count == 1,
              input.first.map({ ("2"..."9").contains($0) }) == true
        else {
            return false
        }
        // `processKey` may lazily create a native session. Verify health here
        // so an orphan digit can never become the new accepted mixed identity.
        if liveRawInput == ledger.replacementRawInput,
            engine.isComposing()
        {
            return false
        }

        abandonAcceptedT9AutoAnchorComposition(
            ledger: ledger,
            using: engine
        )
        return true
    }

    /// The generic host-interruption recovery path may replay input. An
    /// accepted mixed ledger instead fails closed on the existing session.
    func rejectMissingAcceptedT9AutoAnchorSessionIfNeeded(
        using engine: RimeEngine
    ) -> Bool {
        let ledger = state.t9ReversibleAutoAnchorState
        guard ledger.phase == .accepted else { return false }
        abandonAcceptedT9AutoAnchorComposition(
            ledger: ledger,
            using: engine
        )
        return true
    }

    /// A failed/non-committing digit cannot enter the generic recovery/replay
    /// path while an accepted mixed ledger is authoritative.
    func rejectUnusableAcceptedT9AutoAnchorDigitIfNeeded(
        _ input: String,
        previousLedger: T9ReversibleAutoAnchorState,
        output: RimeOutput,
        using engine: RimeEngine
    ) -> Bool {
        guard previousLedger.phase == .accepted,
              input.count == 1,
              input.first.map({ ("2"..."9").contains($0) }) == true,
              output.committedText == nil,
              output.composition?.preeditText.isEmpty != false
                || output.rawInput?.isEmpty != false
        else {
            return false
        }

        abandonAcceptedT9AutoAnchorComposition(
            ledger: previousLedger,
            using: engine
        )
        return true
    }

    /// Atomically advances both digit authority and exact mixed-raw identity
    /// after RIME accepted a later non-committing T9 digit.
    func advanceAcceptedT9AutoAnchorDigit(
        _ input: String,
        previousLiveRawInput: String?,
        output: RimeOutput
    ) {
        let ledger = state.t9ReversibleAutoAnchorState
        guard ledger.phase == .accepted,
              input.count == 1,
              input.first.map({ ("2"..."9").contains($0) }) == true,
              previousLiveRawInput == ledger.replacementRawInput,
              output.committedText == nil,
              output.composition?.preeditText.isEmpty == false,
              let liveRawInput = output.rawInput,
              !liveRawInput.isEmpty
        else {
            return
        }

        var advancedLedger = ledger
        advancedLedger.sourceDigits += input
        advancedLedger.replacementRawInput = liveRawInput
        state.t9ReversibleAutoAnchorState = advancedLedger
    }

    private func abandonAcceptedT9AutoAnchorComposition(
        ledger: T9ReversibleAutoAnchorState,
        using engine: RimeEngine
    ) {
        engine.resetSession()
        state.currentComposition = ""
        state.lastRimeOutput = nil
        state.partialCommit = nil
        updateInlinePreedit("", source: .compositionProjection)
        clearTypoCorrectionSuggestions()
        clearT9PinyinPathState()
        state.t9ReversibleAutoAnchorState = T9ReversibleAutoAnchorState(
            phase: .rejected,
            automaticApplyAttemptCount: ledger.automaticApplyAttemptCount,
            lastAttemptSourceDigitCount: ledger.lastAttemptSourceDigitCount
        )
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

    private func isUsableRestoredMixedT9AutoAnchorOutput(
        _ output: RimeOutput,
        expectedRawInput: String
    ) -> Bool {
        output.committedText == nil
            && output.composition?.preeditText.isEmpty == false
            && output.rawInput == expectedRawInput
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
        #if T9_AUTO_ANCHOR_DEVICE_PREFLIGHT
        let recordPrefix: String
        if let context = HotPathSegmentTiming.devicePreflightContext {
            recordPrefix =
                "T9AUTO run=\(context.token) action=\(context.action) "
                + "event=\(context.event) "
        } else {
            recordPrefix = "T9AUTO run=invalid action=0 event=0 "
        }
        #else
        let recordPrefix = "T9AUTO "
        #endif
        let record =
            recordPrefix + "status=\(outcome.status.rawValue) "
                + "baseline=\(outcome.baselineCandidateCount) "
                + "result=\(outcome.resultingCandidateCount) "
                + "overlap=\(outcome.overlappingCandidateCount) "
                + "attempt=\(outcome.attemptIndex) "
                + "anchorSyllables=\(outcome.anchoredSyllableCount) "
                + "newSyllables=\(outcome.newlyAnchoredSyllableCount) "
                + "newSlots=\(outcome.newlyAnchoredSlotCount) "
                + "anchorSlots=\(outcome.anchoredSlotCount) "
                + "unresolvedSlots=\(outcome.unresolvedSlotCount) "
                + "applyMs=\(outcome.applyDurationMilliseconds) "
                + "restoreMs=\(outcome.restoreDurationMilliseconds)"
        #if T9_AUTO_ANCHOR_DEVICE_PREFLIGHT
        Logger.shared.devicePreflightPerformance(record, level: .debug)
        #else
        Logger.shared.debug(record, category: .performance)
        #endif
        #endif
    }
}
