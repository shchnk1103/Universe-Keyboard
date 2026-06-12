extension KeyboardController {
    var activeCompositionDisplayText: String {
        state.partialCommit?.displayText ?? state.currentComposition
    }

    /// Applies a normal RIME candidate selection while keeping any remaining raw input active.
    func applyNormalCandidateSelection(
        candidate: String,
        result: RimeOutput,
        previousOutput: RimeOutput
    ) {
        let previousConfirmedText = state.partialCommit?.confirmedText ?? ""
        let previousRawInput = previousOutput.rawInput
        let previousPreeditText = previousOutput.composition?.preeditText
        let previousDisplayText = activeCompositionDisplayText

        guard let rimeRawInput = result.rawInput,
            !rimeRawInput.isEmpty,
            let rimePreeditText = result.composition?.preeditText,
            !rimePreeditText.isEmpty,
            let previousRawInput,
            !previousRawInput.isEmpty,
            let previousPreeditText,
            !previousPreeditText.isEmpty
        else {
            finishNormalCandidateSelection(candidate: candidate, result: result)
            return
        }

        // librime may keep a selected segment inside its composition without emitting
        // committedText until the whole session is finished. The tapped candidate is
        // therefore the stable confirmed segment for a partial selection.
        let committedText = result.committedText ?? candidate
        let confirmedText = previousConfirmedText + committedText
        let displayText = partialDisplayText(confirmedText: confirmedText, rimePreeditText: rimePreeditText)
        let remainingPreeditText = partialRemainingPreeditText(
            confirmedText: confirmedText,
            displayText: displayText
        )
        let checkpoint = PartialCommitCheckpoint(
            previousConfirmedText: previousConfirmedText,
            previousRawInput: previousRawInput,
            previousPreeditText: previousPreeditText,
            previousDisplayText: previousDisplayText
        )

        state.lastRimeOutput = result
        state.currentComposition = remainingPreeditText
        state.partialCommit = PartialCommitState(
            confirmedText: confirmedText,
            remainingRawInput: rimeRawInput,
            remainingPreeditText: remainingPreeditText,
            displayText: displayText,
            checkpoint: checkpoint
        )
        updateInlinePreedit(displayText)
        clearTypoCorrectionSuggestions()
    }

    /// Applies a RIME output while preserving a confirmed prefix during the active session.
    func applyRimeOutputPreservingPartialCommit(_ output: RimeOutput) {
        guard let partialCommit = state.partialCommit else {
            applyRimeOutputWithoutPartialCommit(output)
            return
        }

        if let committedText = output.committedText, !committedText.isEmpty {
            let finalText = committedText.hasPrefix(partialCommit.confirmedText)
                ? committedText
                : partialCommit.confirmedText + committedText
            commitInlinePreedit(as: finalText)
            state.currentComposition = ""
            state.lastRimeOutput = output
            state.partialCommit = nil
            clearTypoCorrectionSuggestions()
            return
        }

        guard let rimeRawInput = output.rawInput,
            let rimePreeditText = output.composition?.preeditText,
            !rimeRawInput.isEmpty,
            !rimePreeditText.isEmpty
        else {
            let confirmedText = partialCommit.confirmedText
            commitInlinePreedit(as: confirmedText)
            state.currentComposition = ""
            state.lastRimeOutput = output
            state.partialCommit = nil
            clearTypoCorrectionSuggestions()
            return
        }

        let displayText = partialDisplayText(
            confirmedText: partialCommit.confirmedText,
            rimePreeditText: rimePreeditText
        )
        let remainingPreeditText = partialRemainingPreeditText(
            confirmedText: partialCommit.confirmedText,
            displayText: displayText
        )
        state.lastRimeOutput = output
        state.currentComposition = remainingPreeditText
        state.partialCommit = PartialCommitState(
            confirmedText: partialCommit.confirmedText,
            remainingRawInput: rimeRawInput,
            remainingPreeditText: remainingPreeditText,
            displayText: displayText,
            checkpoint: nil,
            source: partialCommit.source
        )
        updateInlinePreedit(displayText)
        clearTypoCorrectionSuggestions()
    }

    /// Applies a high-confidence typo correction as a partial commit.
    ///
    /// The original input is kept only as the Delete restore target. Continued
    /// composition runs through a clean RIME session rebuilt from correctedInput.
    func applyTypoCorrectionPartialCommit(_ correction: TypoCorrectionCommit) -> Bool {
        guard isTypoCorrectionPartialCommitEnabled,
            state.partialCommit == nil,
            isEligibleTypoPartialCommit(correction),
            activeInputMatchesCorrectionOriginal(correction),
            let engine = rimeEngine,
            let previousPreeditText = state.currentComposition.nonEmpty
        else {
            return false
        }

        let previousDisplayText = activeCompositionDisplayText
        guard let correctedOutput = rebuildRimeOutput(for: correction.correctedInput, using: engine),
            let candidateIndex = correctedOutput.candidates.firstIndex(where: { $0.text == correction.committedText })
        else {
            return false
        }

        let result = engine.selectCandidate(at: candidateIndex)
        guard let rimeRawInput = result.rawInput,
            !rimeRawInput.isEmpty,
            let rimePreeditText = result.composition?.preeditText,
            !rimePreeditText.isEmpty
        else {
            return false
        }

        let confirmedText = correction.committedText
        let displayText = partialDisplayText(confirmedText: confirmedText, rimePreeditText: rimePreeditText)
        let remainingPreeditText = partialRemainingPreeditText(
            confirmedText: confirmedText,
            displayText: displayText
        )
        guard !remainingPreeditText.isEmpty else { return false }

        state.lastRimeOutput = result
        state.currentComposition = remainingPreeditText
        state.partialCommit = PartialCommitState(
            confirmedText: confirmedText,
            remainingRawInput: rimeRawInput,
            remainingPreeditText: remainingPreeditText,
            displayText: displayText,
            checkpoint: PartialCommitCheckpoint(
                previousRawInput: correction.originalInput,
                previousPreeditText: previousPreeditText,
                previousDisplayText: previousDisplayText
            ),
            source: .typoCorrection
        )
        updateInlinePreedit(displayText)
        clearTypoCorrectionSuggestions()
        return true
    }

    /// Restores the state before the latest normal candidate partial commit.
    func restorePartialCommitCheckpoint(using engine: RimeEngine) -> Bool {
        guard let partialCommit = state.partialCommit,
            let checkpoint = partialCommit.checkpoint
        else {
            return false
        }

        guard let output = rebuildRimeOutput(for: checkpoint.previousRawInput, using: engine) else {
            state.partialCommit = PartialCommitState(
                confirmedText: partialCommit.confirmedText,
                remainingRawInput: partialCommit.remainingRawInput,
                remainingPreeditText: partialCommit.remainingPreeditText,
                displayText: partialCommit.displayText,
                checkpoint: nil,
                source: partialCommit.source
            )
            return true
        }

        state.lastRimeOutput = output
        state.currentComposition = output.composition?.preeditText ?? checkpoint.previousPreeditText
        updateInlinePreedit(checkpoint.previousDisplayText)
        if checkpoint.previousConfirmedText.isEmpty {
            state.partialCommit = nil
        } else {
            state.partialCommit = PartialCommitState(
                confirmedText: checkpoint.previousConfirmedText,
                remainingRawInput: checkpoint.previousRawInput,
                remainingPreeditText: state.currentComposition,
                displayText: checkpoint.previousDisplayText,
                checkpoint: nil,
                source: partialCommit.source
            )
        }
        clearTypoCorrectionSuggestions()
        return true
    }

    /// Commits the complete active display without losing a previously confirmed prefix.
    func finishActiveCompositionAsDisplayText() {
        let displayText = activeCompositionDisplayText
        guard !displayText.isEmpty else { return }
        commitInlinePreedit(as: displayText)
        state.currentComposition = ""
        state.lastRimeOutput = nil
        state.partialCommit = nil
        clearTypoCorrectionSuggestions()
    }

    private func finishNormalCandidateSelection(candidate: String, result: RimeOutput) {
        let confirmedPrefix = state.partialCommit?.confirmedText ?? ""
        let committedText = result.committedText ?? candidate
        let finalText = committedText.hasPrefix(confirmedPrefix)
            ? committedText
            : confirmedPrefix + committedText
        commitInlinePreedit(as: finalText)
        state.currentComposition = ""
        state.lastRimeOutput = result
        state.partialCommit = nil
        clearTypoCorrectionSuggestions()
    }

    private func applyRimeOutputWithoutPartialCommit(_ output: RimeOutput) {
        state.lastRimeOutput = output
        state.currentComposition = output.composition?.preeditText ?? ""
        if let commit = output.committedText {
            commitInlinePreedit(as: commit)
            state.currentComposition = ""
            clearTypoCorrectionSuggestions()
        } else {
            updateInlinePreedit(state.currentComposition)
            refreshTypoCorrectionSuggestions()
        }
    }

    private func partialDisplayText(confirmedText: String, rimePreeditText: String) -> String {
        rimePreeditText.hasPrefix(confirmedText)
            ? rimePreeditText
            : confirmedText + rimePreeditText
    }

    private func partialRemainingPreeditText(confirmedText: String, displayText: String) -> String {
        guard displayText.hasPrefix(confirmedText) else { return displayText }
        return String(displayText.dropFirst(confirmedText.count))
    }

    private func isEligibleTypoPartialCommit(_ correction: TypoCorrectionCommit) -> Bool {
        guard correction.edits.count == 1,
            correction.originalInput.count == correction.correctedInput.count,
            correction.originalInput != correction.correctedInput,
            let edit = correction.edits.first,
            edit.kind == .substitution
        else {
            return false
        }

        let originalLetters = Array(correction.originalInput)
        let correctedLetters = Array(correction.correctedInput)
        guard originalLetters.indices.contains(edit.index),
            correctedLetters.indices.contains(edit.index)
        else {
            return false
        }

        return originalLetters[edit.index] == edit.original
            && correctedLetters[edit.index] == edit.replacement
    }

    private func activeInputMatchesCorrectionOriginal(_ correction: TypoCorrectionCommit) -> Bool {
        if state.lastRimeOutput?.rawInput == correction.originalInput {
            return true
        }
        return state.currentComposition.filter { !$0.isWhitespace } == correction.originalInput
    }

    private func rebuildRimeOutput(for rawInput: String, using engine: RimeEngine) -> RimeOutput? {
        engine.resetSession()
        var output = RimeOutput()
        for character in rawInput {
            output = engine.processKey(String(character))
            if output.composition == nil,
                output.committedText == nil,
                !engine.isComposing()
            {
                engine.resetSession()
                return nil
            }
        }
        guard output.rawInput == rawInput, output.composition?.preeditText != nil else {
            engine.resetSession()
            return nil
        }
        return output
    }
}

extension String {
    fileprivate var nonEmpty: String? {
        isEmpty ? nil : self
    }
}
