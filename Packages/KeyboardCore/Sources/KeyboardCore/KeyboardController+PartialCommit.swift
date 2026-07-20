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
        let checkpoint = PartialCommitCheckpoint(
            previousConfirmedText: previousConfirmedText,
            previousRawInput: previousRawInput,
            previousPreeditText: previousPreeditText,
            previousDisplayText: previousDisplayText
        )
        installPartialCommitPresentation(
            confirmedText: confirmedText,
            output: result,
            checkpoint: checkpoint,
            source: .rime
        )
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
            commitInlinePreedit(as: finalText, source: .engineCommit)
            state.currentComposition = ""
            state.lastRimeOutput = output
            state.partialCommit = nil
            clearTypoCorrectionSuggestions()
            _ = clearT9PinyinPathStateReturningEffect()
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
            _ = clearT9PinyinPathStateReturningEffect()
            return
        }

        installPartialCommitPresentation(
            confirmedText: partialCommit.confirmedText,
            output: output,
            checkpoint: nil,
            source: partialCommit.source
        )
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

        let restoreRawInput = rawInputForCheckpointRestore(checkpoint)
        guard let output = rebuildRimeOutput(for: restoreRawInput, using: engine) else {
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
                remainingRawInput: output.rawInput ?? restoreRawInput,
                remainingPreeditText: state.currentComposition,
                displayText: checkpoint.previousDisplayText,
                checkpoint: nil,
                source: partialCommit.source
            )
        }
        clearTypoCorrectionSuggestions()
        return true
    }

    private func rawInputForCheckpointRestore(_ checkpoint: PartialCommitCheckpoint) -> String {
        guard !checkpoint.previousConfirmedText.isEmpty else {
            return checkpoint.previousRawInput
        }

        // Real librime may keep rawInput as the whole original string after a
        // selected segment. Once an earlier segment is already confirmed, Delete
        // should rebuild only the editable suffix after that stable prefix.
        let remainingDisplayText = partialRemainingPreeditText(
            confirmedText: checkpoint.previousConfirmedText,
            displayText: checkpoint.previousDisplayText
        )
        let editableRawInput = remainingDisplayText.filter { !$0.isWhitespace }
        return editableRawInput.isEmpty ? checkpoint.previousRawInput : editableRawInput
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
        _ = clearT9PinyinPathStateReturningEffect()
    }

    /// Commits Return as the user's raw input when RIME exposes a segmented
    /// display preedit such as "ni h". Partial Commit keeps its visible display
    /// because it may already contain confirmed Chinese text.
    func finishActiveCompositionAsRawInput(
        source: CommittedTextSource = .compositionFinalization
    ) {
        let commitText = state.partialCommit?.displayText
            ?? state.lastRimeOutput?.rawInput
            ?? state.currentComposition
        guard !commitText.isEmpty else {
            return
        }
        commitInlinePreedit(as: commitText, source: source)
        state.currentComposition = ""
        state.lastRimeOutput = nil
        state.partialCommit = nil
        clearTypoCorrectionSuggestions()
        _ = clearT9PinyinPathStateReturningEffect()
    }

    var hasActiveCompositionForSymbolInput: Bool {
        !state.currentComposition.isEmpty || (rimeEngine?.isComposing() ?? false)
    }

    func handleSymbolPageTextInput(
        _ text: String,
        updatesEnglishAutoCap: Bool = false
    ) -> KeyboardEffect? {
        guard state.currentPage == .numbers || state.currentPage == .symbols else { return nil }

        if shouldUseChineseCompositionSeparator(text) {
            var effects = handleInsertKey(text)
            effects.formUnion(returnToLettersAfterSymbolInput())
            return effects
        }

        var effects: KeyboardEffect = []

        if hasActiveCompositionForSymbolInput {
            let closingSymbol = pairedClosingSymbol(for: text)
            let appendedText = text + (closingSymbol ?? "")
            let cursorOffsetFromAppendedTextStart = closingSymbol == nil ? appendedText.count : text.count
            finishActiveCompositionForSymbolInput(
                appending: appendedText,
                cursorOffsetFromAppendedTextStart: cursorOffsetFromAppendedTextStart
            )
            effects.insert(.compositionChanged)
        } else if let closingSymbol = pairedClosingSymbol(for: text) {
            insertText(text + closingSymbol, source: .directText)
            adjustTextPosition(byCharacterOffset: -closingSymbol.count)
        } else {
            insertText(text, source: .directText)
        }

        // Symbol-page commits can refresh or clear post-commit continuation state.
        // Surface that state change even when the page itself remains unchanged.
        effects.insert(.continuationChanged)

        effects.formUnion(consumeSingleUseShiftIfNeeded())
        if updatesEnglishAutoCap,
            state.inputMode == .english,
            AutoCapitalizationRules.isSentenceTerminator(text)
        {
            state.shiftState = .singleUse
            effects.insert(.shiftStateChanged)
        }

        if shouldReturnToLettersAfterSymbolInput(text) {
            effects.formUnion(returnToLettersAfterSymbolInput())
        }

        return effects
    }

    func returnToLettersAfterSymbolInput() -> KeyboardEffect {
        guard state.currentPage == .numbers || state.currentPage == .symbols else { return [] }
        state.currentPage = .letters
        return .pageChanged
    }

    func shouldUseChineseCompositionSeparator(_ text: String) -> Bool {
        state.inputMode == .chinese
            && isChineseCompositionSeparator(text)
            && hasActiveCompositionForSymbolInput
    }

    func isChineseCompositionSeparator(_ text: String) -> Bool {
        text == "‘"
    }

    private func shouldReturnToLettersAfterSymbolInput(_ text: String) -> Bool {
        switch state.inputMode {
        case .chinese:
            Self.chineseOneShotSymbols.contains(text)
        case .english:
            Self.englishOneShotSymbols.contains(text)
        }
    }

    /// Chinese one-shot symbols are intentionally exact: ASCII "." is not a Chinese-mode sentence terminator here.
    private static let chineseOneShotSymbols: Set<String> = [
        "；", "（", "）", "@", "“", "”", "。", "，", "、", "？", "！", "【", "】",
        "｛", "｝", "#", "%", "^", "*", "+", "=", "_", "\\", "｜", "《", "》",
        "&", "·",
    ]

    /// English keeps half-width punctuation semantics; "." returns to letters as the English period.
    private static let englishOneShotSymbols: Set<String> = [
        ";", "(", ")", "@", "“", "”", ".", ",", "?", "!", "[", "]", "{", "}",
        "#", "%", "^", "*", "+", "=", "_", "\\", "|", "<", ">", "&",
    ]

    private static let pairedClosingSymbols: [String: String] = [
        "（": "）",
        "(": ")",
        "“": "”",
        "【": "】",
        "[": "]",
        "｛": "｝",
        "{": "}",
        "《": "》",
        "<": ">",
    ]

    private func pairedClosingSymbol(for text: String) -> String? {
        guard isPairedSymbolCompletionEnabled else { return nil }
        return Self.pairedClosingSymbols[text]
    }

    private func finishActiveCompositionForSymbolInput(
        appending appendedText: String,
        cursorOffsetFromAppendedTextStart: Int
    ) {
        let shouldClearCandidateState = state.partialCommit?.source == .numberSuffix
        let commitText = commitFirstCandidateForSymbolInput()
        let finalText = commitText + appendedText
        let selectedOffset = commitText.count + cursorOffsetFromAppendedTextStart
        commitInlinePreedit(
            as: finalText,
            selectedOffset: selectedOffset,
            source: .directText
        )
        state.currentComposition = ""
        if shouldClearCandidateState {
            state.lastRimeOutput = nil
        }
        state.partialCommit = nil
        clearTypoCorrectionSuggestions()
        rimeEngine?.resetSession()
    }

    /// Symbol-triggered commit should behave like confirming the first candidate,
    /// while still replacing the marked range atomically so the following paired
    /// symbol can place the cursor inside the pair.
    private func commitFirstCandidateForSymbolInput() -> String {
        if state.partialCommit?.source == .numberSuffix {
            return state.lastRimeOutput?.candidates.first?.text ?? activeCompositionDisplayText
        }

        if let engine = rimeEngine, engine.isComposing() {
            let result = engine.selectCandidate(at: 0)
            let confirmedPrefix = state.partialCommit?.confirmedText ?? ""
            let selectedText = result.committedText
                ?? state.lastRimeOutput?.candidates.first?.text
                ?? result.composition?.preeditText
                ?? state.lastRimeOutput?.rawInput
                ?? state.currentComposition
            let commitText = selectedText.hasPrefix(confirmedPrefix)
                ? selectedText
                : confirmedPrefix + selectedText
            state.lastRimeOutput = RimeOutput(
                composition: nil,
                candidates: [],
                committedText: commitText,
                hasMorePages: false
            )
            return commitText
        }

        return activeCompositionDisplayText
    }

    private func finishNormalCandidateSelection(candidate: String, result: RimeOutput) {
        let confirmedPrefix = state.partialCommit?.confirmedText ?? ""
        let committedText = result.committedText ?? candidate
        let finalText = committedText.hasPrefix(confirmedPrefix)
            ? committedText
            : confirmedPrefix + committedText
        commitInlinePreedit(as: finalText, source: .candidate)
        state.currentComposition = ""
        state.lastRimeOutput = result
        state.partialCommit = nil
        clearTypoCorrectionSuggestions()
        _ = clearT9PinyinPathStateReturningEffect()
    }

    private func applyRimeOutputWithoutPartialCommit(_ output: RimeOutput) {
        state.lastRimeOutput = output
        let raw = output.rawInput ?? ""
        if T9CompositionCommitPolicy.isActiveT9Composition(
            usesT9InputSemantics: usesT9InputSemantics,
            rawInput: raw
        ) {
            // Keep composition state on raw input for delete/recovery; show comment-preferring preedit.
            state.currentComposition = raw
            if let commit = output.committedText {
                commitInlinePreedit(as: commit, source: .engineCommit)
                state.currentComposition = ""
                clearTypoCorrectionSuggestions()
                _ = clearT9PinyinPathStateReturningEffect()
            } else {
                let visible = T9PreeditResolver.visiblePreedit(
                    rawInput: raw,
                    candidates: output.candidates,
                    highlightedIndex: output.highlightedIndex
                )
                updateInlinePreedit(visible)
                clearTypoCorrectionSuggestions()
                // New RimeOutput always hard-opens path provenance (same raw may still
                // change candidates/comments). Soft refresh is only for same-snapshot re-scan.
                _ = applyT9PinyinPathStateFromNewRimeOutput()
            }
            return
        }

        state.currentComposition = output.composition?.preeditText ?? ""
        if let commit = output.committedText {
            commitInlinePreedit(as: commit, source: .engineCommit)
            state.currentComposition = ""
            clearTypoCorrectionSuggestions()
            _ = clearT9PinyinPathStateReturningEffect()
        } else {
            updateInlinePreedit(state.currentComposition)
            refreshTypoCorrectionSuggestions()
            _ = clearT9PinyinPathStateReturningEffect()
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

    /// Installs partial-commit presentation and path provenance from a live RIME output.
    ///
    /// Under T9, remaining **display** prefers candidate comments (`ya`), never raw
    /// digits (`92`), while `remainingRawInput` / `currentComposition` keep the raw
    /// identity for delete/recovery. Path bar is hard-refreshed from the remaining raw.
    private func installPartialCommitPresentation(
        confirmedText: String,
        output: RimeOutput,
        checkpoint: PartialCommitCheckpoint?,
        source: PartialCommitSource
    ) {
        guard let rimeRawInput = output.rawInput, !rimeRawInput.isEmpty,
              let rimePreeditText = output.composition?.preeditText, !rimePreeditText.isEmpty
        else {
            return
        }

        let isT9Remaining = T9CompositionCommitPolicy.isActiveT9Composition(
            usesT9InputSemantics: usesT9InputSemantics,
            rawInput: rimeRawInput
        )

        let remainingPreeditText: String
        let displayText: String
        let compositionTracker: String

        if isT9Remaining {
            let commentPreferred = T9PreeditResolver.visiblePreedit(
                rawInput: rimeRawInput,
                candidates: output.candidates,
                highlightedIndex: output.highlightedIndex
            )
            if rimePreeditText.hasPrefix(confirmedText) {
                let rimeTail = String(rimePreeditText.dropFirst(confirmedText.count))
                // Digit-only RIME tails are not user-facing under T9 (KEYBOARD_LAYOUT).
                if rimeTail.isEmpty || isDigitOnlyPreeditTail(rimeTail) {
                    remainingPreeditText = commentPreferred
                    displayText = confirmedText + commentPreferred
                } else {
                    remainingPreeditText = rimeTail
                    displayText = rimePreeditText
                }
            } else if isDigitOnlyPreeditTail(rimePreeditText) {
                remainingPreeditText = commentPreferred
                displayText = confirmedText + commentPreferred
            } else {
                // Letter/mixed preedit (e.g. after path refine): keep RIME display tail.
                remainingPreeditText = rimePreeditText
                displayText = confirmedText + rimePreeditText
            }
            // T9 composition tracker is raw, matching non-partial T9 apply path.
            compositionTracker = rimeRawInput
        } else {
            displayText = partialDisplayText(
                confirmedText: confirmedText,
                rimePreeditText: rimePreeditText
            )
            remainingPreeditText = partialRemainingPreeditText(
                confirmedText: confirmedText,
                displayText: displayText
            )
            compositionTracker = remainingPreeditText
        }

        state.lastRimeOutput = output
        state.currentComposition = compositionTracker
        state.partialCommit = PartialCommitState(
            confirmedText: confirmedText,
            remainingRawInput: rimeRawInput,
            remainingPreeditText: remainingPreeditText,
            displayText: displayText,
            checkpoint: checkpoint,
            source: source
        )
        updateInlinePreedit(displayText)
        clearTypoCorrectionSuggestions()

        if isT9Remaining {
            _ = applyT9PinyinPathStateFromNewRimeOutput()
        } else {
            _ = clearT9PinyinPathStateReturningEffect()
        }
    }

    private func isDigitOnlyPreeditTail(_ text: String) -> Bool {
        !text.isEmpty
            && text.unicodeScalars.allSatisfy(T9PinyinPathExtractor.isASCIIDigit)
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
