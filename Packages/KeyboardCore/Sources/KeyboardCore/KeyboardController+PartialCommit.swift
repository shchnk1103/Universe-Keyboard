extension KeyboardController {
    /// Host-facing composition string. Under T9, never fall back to raw digits —
    /// those live in `currentComposition` / `rawInput` for engine recovery only.
    var activeCompositionDisplayText: String {
        if let partial = state.partialCommit {
            return partial.displayText
        }
        if let output = state.lastRimeOutput,
           T9CompositionCommitPolicy.isActiveT9Composition(
            usesT9InputSemantics: usesT9InputSemantics,
            rawInput: output.rawInput
           )
        {
            return t9VisiblePreedit(for: output)
        }
        if !state.insertedPreeditText.isEmpty {
            return state.insertedPreeditText
        }
        return state.currentComposition
    }

    /// Host-visible T9 preedit using provisional Path when it fully covers focus slots.
    func t9VisiblePreedit(for output: RimeOutput) -> String {
        let provisional = state.t9PinyinPathState.selectedPath == nil
            ? state.t9PinyinPathState.compactPaths.first
            : nil
        return T9PreeditResolver.visiblePreedit(
            rawInput: output.rawInput,
            candidates: output.candidates,
            highlightedIndex: output.highlightedIndex,
            provisionalPathDisplay: provisional?.displayText,
            provisionalConsumedSlots: provisional?.consumedSlotCount
        )
    }

    /// Snapshot of what the host is currently showing for checkpoint restore.
    private var hostVisiblePreeditSnapshot: String {
        if !state.insertedPreeditText.isEmpty {
            return state.insertedPreeditText
        }
        return activeCompositionDisplayText
    }

    /// Applies a normal RIME candidate selection while keeping any remaining raw input active.
    func applyNormalCandidateSelection(
        candidate: String,
        result: RimeOutput,
        previousOutput: RimeOutput
    ) {
        advanceCompositionRevision()
        let previousConfirmedText = state.partialCommit?.confirmedText ?? ""
        let previousRawInput = previousOutput.rawInput
        let previousPreeditText = previousOutput.composition?.preeditText
        // Prefer host marked text / T9 comment preedit — never T9 raw digits.
        let previousDisplayText = hostVisiblePreeditSnapshot

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
        // Path Bar digit identity must survive a nested Chinese partial that
        // shortens live raw to a pure-digit suffix (e.g. qiu'53 → 5 after 球).
        // Capture before install: hard path refresh would otherwise forget
        // confirmed syllables and collapse source to the bare remainder digit.
        let preservedSegmentSource = state.t9PinyinPathState.segmentSourceDigits
        let preservedPathConfirmed = state.t9PinyinPathState.confirmedSegmentValues
        let preservedFocus = state.t9PinyinPathState.focusedSegmentIndex
        let checkpoint = PartialCommitCheckpoint(
            previousConfirmedText: previousConfirmedText,
            previousRawInput: previousRawInput,
            previousPreeditText: previousPreeditText,
            previousDisplayText: previousDisplayText,
            previousSegmentSourceDigits: preservedSegmentSource,
            previousConfirmedSegmentValues: preservedPathConfirmed,
            previousFocusedSegmentIndex: preservedFocus
        )
        let previousRawForTrace = previousRawInput
        // Candidate selection starts a new presentation revision. Prevent the
        // output installer from treating the old segmented snapshot as the
        // current remainder; a genuinely nested shortened tail is restored once
        // below, after the new output has been installed.
        state.t9PinyinPathState.compactPaths = []
        state.t9PinyinPathState.selectedPath = nil
        state.t9PinyinPathState.issuedReplacementKeys = []
        state.t9PinyinPathState.retainedChoiceSourceRawInput = nil
        state.t9PinyinPathState.segmentSourceDigits = nil
        state.t9PinyinPathState.focusedSegmentIndex = nil
        state.t9PinyinPathState.confirmedSegmentValues = []
        installPartialCommitPresentation(
            confirmedText: confirmedText,
            output: result,
            checkpoint: checkpoint,
            source: .rime
        )
        let restored = restoreSegmentedPathIdentityAfterNestedPartial(
            preservedSegmentSource: preservedSegmentSource,
            preservedPathConfirmed: preservedPathConfirmed,
            committedCandidate: committedText
        )
        #if DEBUG
        // Phase 0 only: structural identity after partial — no host document text.
        // Note encodes whether pure-digit restore succeeded and whether unconsumed
        // path syllables still lack a slot-rebase model (B root cause class).
        gate5TraceComposition(
            event: .partialCommit,
            previousRaw: previousRawForTrace,
            note: "restore=\(restored) preservedConfCount=\(preservedPathConfirmed.count) "
                + "livePureDigits=\(result.rawInput?.allSatisfy(\.isNumber) ?? false) "
                + "slotRebaseMissing=\(!restored && !preservedPathConfirmed.isEmpty)"
        )
        #endif
    }

    /// Re-attach progressive path identity when nested partial leaves a **shortened**
    /// remainder that uniquely encodes a suffix of the pre-selection source.
    ///
    /// Residual-B: when engine raw is **unchanged** but Path already has confirmed
    /// syllables, peel the leading Path syllable for a **single-character** candidate
    /// using Path ledger only (not 汉字数 / sel_* / comment).
    @discardableResult
    func restoreSegmentedPathIdentityAfterNestedPartial(
        preservedSegmentSource: String?,
        preservedPathConfirmed: [String],
        committedCandidate: String = ""
    ) -> Bool {
        guard usesT9InputSemantics,
              let preserved = preservedSegmentSource,
              !preserved.isEmpty,
              preserved.allSatisfy(\.isNumber),
              let liveRaw = state.lastRimeOutput?.rawInput,
              !liveRaw.isEmpty
        else { return false }

        // Pure-digit path still requires prior confirmed syllables (nested peel).
        // Mixed path may rebuild confirmed from remaining letter segments.
        guard !preservedPathConfirmed.isEmpty || !liveRaw.allSatisfy(\.isNumber) else {
            return false
        }

        if let identity = T9CompositionIdentity.afterPartialCommit(
            previousSource: preserved,
            previousConfirmed: preservedPathConfirmed,
            remainingRaw: liveRaw
        ) {
            installIdentityAsPathState(identity)
            return true
        }

        // Unchanged-raw B: Path-ledger peel (single CJK character only).
        guard isSingleCJKCharacter(committedCandidate),
              !preservedPathConfirmed.isEmpty,
              isUnchangedRawEncoding(liveRaw, previousSource: preserved)
        else {
            return false
        }

        guard let identity = T9CompositionIdentity.afterPathLedgerPeel(
            previousSource: preserved,
            previousConfirmed: preservedPathConfirmed,
            peelSyllableCount: 1
        ) else {
            return false
        }

        installIdentityAsPathState(identity)
        // Drive RIME onto remaining Path form so candidates/host match Path focus.
        _ = resyncRimeCompositionFromT9Identity()
        refreshPartialCommitRemainingAfterPathLedgerPeel(identity: identity)
        return true
    }

    /// True when live raw still encodes the full pre-selection digit ledger.
    private func isUnchangedRawEncoding(_ liveRaw: String, previousSource: String) -> Bool {
        if liveRaw == previousSource { return true }
        if liveRaw.allSatisfy(\.isNumber) { return liveRaw == previousSource }
        guard let encoded = T9CompositionIdentity.digitEncoding(ofMixedRaw: liveRaw) else {
            return false
        }
        return encoded == previousSource
    }

    private func isSingleCJKCharacter(_ text: String) -> Bool {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return false }
        // One extended grapheme cluster; must contain a CJK unified ideograph.
        guard trimmed.count == 1, let scalar = trimmed.unicodeScalars.first else { return false }
        return (0x4E00...0x9FFF).contains(scalar.value)
            || (0x3400...0x4DBF).contains(scalar.value)
    }

    /// After Path-ledger peel, keep PartialCommit remaining aligned with Core identity.
    /// Host must never see internal T9 digits; prefer live T9 projection, else letters.
    private func refreshPartialCommitRemainingAfterPathLedgerPeel(
        identity: T9CompositionIdentity
    ) {
        guard let partial = state.partialCommit else { return }
        let remainingRaw = state.lastRimeOutput?.rawInput ?? identity.replacementRawInput
        let hostTail: String
        if let output = state.lastRimeOutput {
            let projected = t9VisiblePreedit(for: output)
            if projected.isEmpty {
                hostTail = identity.confirmedSyllables.joined()
            } else if projected.unicodeScalars.contains(where: T9PinyinPathExtractor.isASCIIDigit) {
                let letters = String(
                    projected.unicodeScalars.filter(T9PinyinPathExtractor.isASCIILetter)
                )
                hostTail = letters.isEmpty
                    ? identity.confirmedSyllables.joined()
                    : letters
            } else {
                hostTail = projected
            }
        } else {
            hostTail = identity.confirmedSyllables.joined()
        }
        state.partialCommit = PartialCommitState(
            confirmedText: partial.confirmedText,
            remainingRawInput: remainingRaw,
            remainingPreeditText: hostTail,
            displayText: partial.confirmedText + hostTail,
            checkpoint: partial.checkpoint,
            source: partial.source
        )
        updateInlinePreedit(
            partial.confirmedText + hostTail,
            source: .compositionProjection
        )
    }

    /// Install pure identity into path state and rebuild catalog focus Paths.
    ///
    /// Human 2026-07-23: when confirmed syllables fill the entire source (no trailing
    /// digits), Path bar must still show alternatives for the **last** syllable
    /// (e.g. only `qing` left → qing/pin/…). Empty `remainingDigits` previously
    /// produced `compactPaths = []` and the Path bar vanished.
    func installIdentityAsPathState(_ identity: T9CompositionIdentity) {
        let plan = identity.focusPathPlan()
        let hints = T9PinyinLocalPathCatalog.commentSyllableHints(
            from: state.lastRimeOutput?.candidates ?? [],
            confirmedSyllables: plan.pathConfirmedSyllables
        )
        let paths: [T9PinyinPath]
        if plan.focusDigits.isEmpty {
            paths = []
        } else {
            paths = T9PinyinLocalPathCatalog.pathsForFocus(
                focusDigits: plan.focusDigits,
                lockedLetterPrefix: nil,
                commentSyllableHints: hints,
                confirmedSyllables: plan.pathConfirmedSyllables,
                sourceDigits: identity.sourceDigits,
                compositionRevision: state.compositionRevision
            )
        }

        var pathState = state.t9PinyinPathState
        pathState.segmentSourceDigits = identity.sourceDigits
        // Keep full syllable ledger for the next identity peel; Path catalog only
        // uses `plan.pathConfirmedSyllables` (may drop last when re-focusing it).
        pathState.confirmedSegmentValues = identity.confirmedSyllables
        pathState.focusedSegmentIndex = plan.focusedSegmentIndex
        pathState.selectedPath = nil
        pathState.retainedChoiceSourceRawInput = nil
        pathState.lockedLetterPrefix = nil
        pathState.compactPaths = paths
        pathState.issuedReplacementKeys = Set(paths.map(\.replacementRawInput))
        pathState.issuedPathIDs = Set(paths.map(\.id))
        // Never auto-select a path after identity install (Human: qi auto-selected).
        pathState.provisionalPathID = paths.first?.id
        pathState.discoveryNextIndex = 0
        pathState.discoveryMayHaveMore = false
        state.t9PinyinPathState = pathState
    }

    /// Applies a RIME output while preserving a confirmed prefix during the active session.
    func applyRimeOutputPreservingPartialCommit(_ output: RimeOutput) {
        advanceCompositionRevision()
        if let committedText = output.committedText,
           !engineCommitIsHostSafe(committedText)
        {
            failClosedUnexpectedEngineCommit(output)
            return
        }
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

        let previousDisplayText = hostVisiblePreeditSnapshot
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
        updateInlinePreedit(displayText, source: .compositionProjection)
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

        clearTypoCorrectionSuggestions()

        // Top-level undo of the first partial: drop partial state and re-apply the
        // rebuilt composition through the normal T9 display path (comment-preferred,
        // never host-visible raw digits) and refresh the path bar.
        if checkpoint.previousConfirmedText.isEmpty {
            state.partialCommit = nil
            applyRimeOutput(output)
            // β-limited: re-install pre-partial Path identity when captured.
            if let source = checkpoint.previousSegmentSourceDigits,
               !source.isEmpty,
               source.allSatisfy(\.isNumber)
            {
                installIdentityAsPathState(
                    T9CompositionIdentity(
                        sourceDigits: source,
                        confirmedSyllables: checkpoint.previousConfirmedSegmentValues,
                        focusedSegmentIndex: checkpoint.previousFocusedSegmentIndex
                    )
                )
                // Letter-refined resync only when Path had confirmed syllables.
                // Pure-digit whole composition (no Path confirm) must keep digit raw
                // from `applyRimeOutput` (regression: 6442692 → ni42692).
                if !checkpoint.previousConfirmedSegmentValues.isEmpty {
                    _ = resyncRimeCompositionFromT9Identity()
                }
            }
            // If rebuilt output has no usable comments, fall back to the host
            // snapshot captured at partial time (already non-digit when captured
            // via hostVisiblePreeditSnapshot).
            if T9CompositionCommitPolicy.isActiveT9Composition(
                usesT9InputSemantics: usesT9InputSemantics,
                rawInput: output.rawInput
            ) {
                let visible = T9PreeditResolver.visiblePreedit(
                    rawInput: output.rawInput,
                    candidates: output.candidates,
                    highlightedIndex: output.highlightedIndex
                )
                if isDigitOnlyPreeditTail(visible),
                   !checkpoint.previousDisplayText.isEmpty,
                   !isDigitOnlyPreeditTail(checkpoint.previousDisplayText)
                {
                    updateInlinePreedit(
                        checkpoint.previousDisplayText,
                        source: .compositionProjection
                    )
                }
            }
            return true
        }

        // Nested partial: restore outer confirmed Chinese + remaining composition.
        installPartialCommitPresentation(
            confirmedText: checkpoint.previousConfirmedText,
            output: output,
            checkpoint: nil,
            source: partialCommit.source
        )
        // Delete is an undo of the nested candidate selection. Restore the exact
        // pre-selection host snapshot whenever it is safe; do not let rebuilt
        // RIME preedit (`qiu5`, another prediction, etc.) overwrite that user-
        // visible fact. Raw/session identity remains the rebuilt internal state.
        if !checkpoint.previousDisplayText.isEmpty,
           !containsInternalT9Digit(checkpoint.previousDisplayText)
        {
            state.partialCommit = PartialCommitState(
                confirmedText: checkpoint.previousConfirmedText,
                remainingRawInput: state.partialCommit?.remainingRawInput
                    ?? output.rawInput
                    ?? restoreRawInput,
                remainingPreeditText: partialRemainingPreeditText(
                    confirmedText: checkpoint.previousConfirmedText,
                    displayText: checkpoint.previousDisplayText
                ),
                displayText: checkpoint.previousDisplayText,
                checkpoint: nil,
                source: partialCommit.source
            )
            updateInlinePreedit(
                checkpoint.previousDisplayText,
                source: .compositionProjection
            )
        }
        return true
    }

    private func rawInputForCheckpointRestore(_ checkpoint: PartialCommitCheckpoint) -> String {
        guard !checkpoint.previousConfirmedText.isEmpty else {
            return checkpoint.previousRawInput
        }

        // Under T9, an explicit letter/apostrophe raw such as `qiu'53` is already
        // the authoritative branch selected by the user. Reusing it preserves the
        // syllable boundary and avoids rebuilding from visible `qiule` as a new,
        // ambiguously segmented composition. Do not apply this to 26-key letter
        // raws: librime may keep the whole original string (e.g. fangzidouhuizheng)
        // after an earlier segment is confirmed, and Delete must rebuild only the
        // editable suffix after that stable Chinese prefix.
        if usesT9InputSemantics,
           checkpoint.previousRawInput.unicodeScalars.contains(
            where: T9PinyinPathExtractor.isASCIILetter
           )
        {
            return checkpoint.previousRawInput
        }

        // Pure-digit T9 identity, or any 26-key letter raw that still covers the
        // whole pre-selection string: peel to the host-visible remaining suffix.
        let remainingDisplayText = partialRemainingPreeditText(
            confirmedText: checkpoint.previousConfirmedText,
            displayText: checkpoint.previousDisplayText
        )
        let editableRawInput = remainingDisplayText.filter { !$0.isWhitespace }
        return editableRawInput.isEmpty ? checkpoint.previousRawInput : editableRawInput
    }

    /// Commits the complete active display without losing a previously confirmed prefix.
    func finishActiveCompositionAsDisplayText() {
        let preferred = activeCompositionDisplayText
        let displayText = compositionProjectionContainsInternalDigit(preferred)
            ? state.insertedPreeditText
            : preferred
        guard !compositionProjectionContainsInternalDigit(displayText) else { return }
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
        let preferred = state.partialCommit?.displayText
            ?? state.lastRimeOutput?.rawInput
            ?? state.currentComposition
        let commitText = compositionProjectionContainsInternalDigit(preferred)
            ? state.insertedPreeditText
            : preferred
        guard !compositionProjectionContainsInternalDigit(commitText) else { return }
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
            let priorCandidate = state.lastRimeOutput?.candidates.first?.text
            let semanticSelection = priorCandidate ?? result.committedText.flatMap { committed in
                compositionProjectionContainsInternalDigit(committed) ? nil : committed
            }
            let projectedFallback = [
                result.composition?.preeditText,
                state.insertedPreeditText,
                activeCompositionDisplayText,
            ].compactMap { $0 }.first {
                !$0.isEmpty && !compositionProjectionContainsInternalDigit($0)
            }
            let selectedText = semanticSelection ?? projectedFallback ?? confirmedPrefix
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
                // Path snapshot first so provisional Path can own host projection
                // when it fully covers the current focus slots (ADR 0023).
                _ = applyT9PinyinPathStateFromNewRimeOutput()
                let visible = t9VisiblePreedit(for: output)
                updateInlinePreedit(visible, source: .compositionProjection)
                clearTypoCorrectionSuggestions()
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
            updateInlinePreedit(
                state.currentComposition,
                source: .compositionProjection
            )
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
        var internalRemainingRaw: String?

        // Previous raw may still be the full pre-selection digit run (librime often
        // retains it). Prefer remainingRaw already stored under an active partial.
        let previousRawForRemainder =
            state.partialCommit?.remainingRawInput ?? state.lastRimeOutput?.rawInput

        let remainingRawInput: String
        if isT9Remaining {
            // Install provisional paths against remaining raw before projecting.
            // Path refresh may have run already; recompute display from current state.
            let commentPreferred = t9VisiblePreedit(for: output)
            if rimePreeditText.hasPrefix(confirmedText) {
                let rimeTail = String(rimePreeditText.dropFirst(confirmedText.count))
                internalRemainingRaw = T9PinyinPathExtractor.internalDigitIdentity(
                    fromPreedit: rimeTail
                )
                // Digit/separator-only RIME tails are internal raw, not user-facing text.
                if rimeTail.isEmpty || internalRemainingRaw != nil {
                    remainingPreeditText = commentPreferred
                    displayText = confirmedText + commentPreferred
                } else {
                    remainingPreeditText = rimeTail
                    displayText = rimePreeditText
                }
            } else if let digitIdentity = T9PinyinPathExtractor.internalDigitIdentity(
                fromPreedit: rimePreeditText
            ) {
                internalRemainingRaw = digitIdentity
                remainingPreeditText = commentPreferred
                displayText = confirmedText + commentPreferred
            } else if containsInternalT9Digit(rimePreeditText) {
                // A letter+digit mix such as `qiu5` is still internal raw. Prefer
                // the sanitized candidate projection; if unavailable, expose no
                // suffix rather than leaking even one digit to marked text.
                remainingPreeditText = commentPreferred
                displayText = confirmedText + commentPreferred
            } else {
                // Letter-only preedit (e.g. after path refine) is safe to show.
                remainingPreeditText = rimePreeditText
                displayText = confirmedText + rimePreeditText
            }
            // Peel confirmed digit slots when librime keeps the full raw (e.g. 6442692
            // after 你好 → remaining 92 for ya). Path bar must not see leading 6 → m/n/o.
            if let internalRemainingRaw, !internalRemainingRaw.isEmpty {
                // A selected segment may leave librime's full anchored raw in
                // place while preedit exposes a digit-only editable tail. That
                // tail is the new composition identity; keeping the full raw
                // would prevent the new `wo...` Path revision from rebuilding.
                remainingRawInput = internalRemainingRaw
            } else if rimeRawInput.unicodeScalars.contains(
                where: T9PinyinPathExtractor.isASCIILetter
            ) {
                // A refined raw (`shu'53`, `qiu'53`) already encodes the user's
                // Path Bar branch. Never replace it with the older pure-digit
                // identity merely because both still cover the same slot count.
                remainingRawInput = rimeRawInput
            } else {
                remainingRawInput = T9PinyinPathExtractor.remainingT9RawAfterPartialCommit(
                    previousRaw: previousRawForRemainder,
                    resultRaw: internalRemainingRaw ?? rimeRawInput,
                    remainingDisplayPreedit: remainingPreeditText
                ) ?? rimeRawInput
            }
            compositionTracker = remainingRawInput
        } else {
            displayText = partialDisplayText(
                confirmedText: confirmedText,
                rimePreeditText: rimePreeditText
            )
            remainingPreeditText = partialRemainingPreeditText(
                confirmedText: confirmedText,
                displayText: displayText
            )
            remainingRawInput = rimeRawInput
            compositionTracker = remainingPreeditText
        }

        // Path discovery uses candidates from live output, but digit identity for the
        // path bar must be the remaining raw (may differ from librime full raw).
        let pathAlignedOutput: RimeOutput
        if isT9Remaining,
           remainingRawInput != rimeRawInput
        {
            pathAlignedOutput = RimeOutput(
                rawInput: remainingRawInput,
                composition: RimeComposition(
                    preeditText: remainingPreeditText,
                    cursorPosition: remainingPreeditText.count
                ),
                candidates: output.candidates,
                committedText: output.committedText,
                hasMorePages: output.hasMorePages,
                highlightedIndex: output.highlightedIndex,
                candidatePageNumber: output.candidatePageNumber
            )
        } else {
            pathAlignedOutput = output
        }

        state.lastRimeOutput = pathAlignedOutput
        state.currentComposition = compositionTracker

        var finalRemainingPreedit = remainingPreeditText
        var finalDisplay = displayText
        if isT9Remaining {
            // Path state must land before host projection so provisional Paths
            // for the remaining focus are available in the same revision.
            _ = applyT9PinyinPathStateFromNewRimeOutput()
            let projected = t9VisiblePreedit(for: pathAlignedOutput)
            if !projected.isEmpty,
               !projected.unicodeScalars.contains(where: T9PinyinPathExtractor.isASCIIDigit)
            {
                finalRemainingPreedit = projected
                finalDisplay = confirmedText + projected
            }
        } else {
            _ = clearT9PinyinPathStateReturningEffect()
        }

        state.partialCommit = PartialCommitState(
            confirmedText: confirmedText,
            remainingRawInput: remainingRawInput,
            remainingPreeditText: finalRemainingPreedit,
            displayText: finalDisplay,
            checkpoint: checkpoint,
            source: source
        )
        updateInlinePreedit(finalDisplay, source: .compositionProjection)
        clearTypoCorrectionSuggestions()
    }

    private func isDigitOnlyPreeditTail(_ text: String) -> Bool {
        T9PinyinPathExtractor.internalDigitIdentity(fromPreedit: text) != nil
    }

    private func containsInternalT9Digit(_ text: String) -> Bool {
        text.unicodeScalars.contains(where: T9PinyinPathExtractor.isASCIIDigit)
    }

    func advanceCompositionRevision() {
        state.compositionRevision &+= 1
        // Reserve zero for the initial/no-composition state after overflow.
        if state.compositionRevision == 0 {
            state.compositionRevision = 1
        }
    }

    private func engineCommitIsHostSafe(_ committedText: String) -> Bool {
        if state.partialCommit?.source == .numberSuffix {
            return true
        }
        let confirmedPrefix = state.partialCommit?.confirmedText ?? ""
        let finalText = committedText.hasPrefix(confirmedPrefix)
            ? committedText
            : confirmedPrefix + committedText
        if !compositionProjectionContainsInternalDigit(finalText) {
            return true
        }
        // A digit-bearing string is semantic only when it was actually offered
        // as a candidate in the preceding live snapshot.
        return state.lastRimeOutput?.candidates.contains(where: { candidate in
            candidate.text == committedText
                || candidate.text == finalText
                || confirmedPrefix + candidate.text == finalText
        }) == true
    }

    private func failClosedUnexpectedEngineCommit(_ output: RimeOutput) {
        clearInlinePreedit()
        state.currentComposition = ""
        state.lastRimeOutput = output
        state.partialCommit = nil
        rimeEngine?.resetSession()
        clearTypoCorrectionSuggestions()
        _ = clearT9PinyinPathStateReturningEffect()
        Logger.shared.warning(
            "engine commit rejected: candidate-less internal digit projection",
            category: .display
        )
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
