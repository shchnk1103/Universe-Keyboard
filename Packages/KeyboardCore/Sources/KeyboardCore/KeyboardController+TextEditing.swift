extension KeyboardController {
    func handleInsertDirectText(
        _ text: String,
        source: CommittedTextSource = .directText
    ) -> KeyboardEffect {
        if let effects = handleSymbolPageTextInput(text) {
            return effects
        }
        var effects: KeyboardEffect = []
        if !state.currentComposition.isEmpty {
            finishActiveCompositionAsDisplayText()
            rimeEngine?.resetSession()
            effects.insert(.compositionChanged)
        }
        insertText(text, source: source)
        effects.insert(.continuationChanged)
        return effects
    }

    func handleInsertSpace() -> KeyboardEffect {
        if let partialCommit = state.partialCommit,
           partialCommit.source == .numberSuffix,
           let firstCandidate = state.lastRimeOutput?.candidates.first?.text
        {
            commitInlinePreedit(as: firstCandidate, source: .space)
            state.currentComposition = ""
            state.lastRimeOutput = RimeOutput(
                composition: nil,
                candidates: [],
                committedText: firstCandidate,
                hasMorePages: false
            )
            state.partialCommit = nil
            rimeEngine?.resetSession()
            clearTypoCorrectionSuggestions()
            state.lastSpaceTapTime = nil
            return .compositionChanged
        }

        if let engine = rimeEngine, engine.isComposing() {
            let output = state.lastRimeOutput
            let raw = output?.rawInput ?? state.currentComposition
            switch T9CompositionCommitPolicy.spaceAction(
                usesT9InputSemantics: usesT9InputSemantics,
                rawInput: raw,
                candidates: output?.candidates ?? [],
                highlightedIndex: output?.highlightedIndex
            ) {
            case .commitCandidate(let text):
                commitInlinePreedit(
                    as: (state.partialCommit?.confirmedText ?? "") + text,
                    source: .space
                )
                state.currentComposition = ""
                state.lastRimeOutput = RimeOutput(
                    composition: nil,
                    candidates: [],
                    committedText: text,
                    hasMorePages: false
                )
                state.partialCommit = nil
                engine.resetSession()
                clearTypoCorrectionSuggestions()
                let pathEffect = clearT9PinyinPathStateReturningEffect()
                state.lastSpaceTapTime = nil
                return .compositionChanged.union(pathEffect)
            case .keepComposition:
                state.lastSpaceTapTime = nil
                return []
            case .notT9Composition:
                if let firstCandidate = output?.candidates.first?.text {
                    // Preserve the first page selection even if later pages were prefetched for display.
                    commitInlinePreedit(
                        as: (state.partialCommit?.confirmedText ?? "") + firstCandidate,
                        source: .space
                    )
                    state.currentComposition = ""
                    state.lastRimeOutput = RimeOutput(
                        composition: nil,
                        candidates: [],
                        committedText: firstCandidate,
                        hasMorePages: false
                    )
                    state.partialCommit = nil
                    engine.resetSession()
                    clearTypoCorrectionSuggestions()
                    let pathEffect = clearT9PinyinPathStateReturningEffect()
                    state.lastSpaceTapTime = nil
                    return .compositionChanged.union(pathEffect)
                }
            default:
                break
            }
        }
        if !state.currentComposition.isEmpty {
            if T9CompositionCommitPolicy.isActiveT9DigitComposition(
                usesT9InputSemantics: usesT9InputSemantics,
                rawInput: state.currentComposition
            ) {
                // Never commit raw T9 digits via the non-engine composition path.
                state.lastSpaceTapTime = nil
                return []
            }
            let first = candidateProvider.candidates(for: state.currentComposition).first ?? state.currentComposition
            commitInlinePreedit(as: first, source: .space)
            state.currentComposition = ""
            state.lastRimeOutput = nil
            state.partialCommit = nil
            rimeEngine?.resetSession()
            clearTypoCorrectionSuggestions()
            let pathEffect = clearT9PinyinPathStateReturningEffect()
            state.lastSpaceTapTime = nil
            return .compositionChanged.union(pathEffect)
        }

        guard state.currentPage == .letters && state.inputMode == .english else {
            state.lastSpaceTapTime = nil
            insertText(" ", source: .space)
            return .continuationChanged
        }

        let now = currentDate()
        let isDoubleSpace = state.lastSpaceTapTime.map { now.timeIntervalSince($0) < 0.45 } ?? false
        state.lastSpaceTapTime = now

        if isDoubleSpace {
            textClient?.deleteBackward()
            insertText(". ", source: .space)
            state.lastSpaceTapTime = nil
        } else {
            insertText(" ", source: .space)
        }
        return .continuationChanged
    }

    func handleInsertReturn() -> KeyboardEffect {
        let raw = state.lastRimeOutput?.rawInput ?? state.currentComposition
        switch T9CompositionCommitPolicy.returnAction(
            usesT9InputSemantics: usesT9InputSemantics,
            rawInput: raw,
            candidates: state.lastRimeOutput?.candidates ?? [],
            highlightedIndex: state.lastRimeOutput?.highlightedIndex
        ) {
        case .commitCandidate(let text):
            commitInlinePreedit(as: text, source: .returnKey)
            state.currentComposition = ""
            state.lastRimeOutput = nil
            state.partialCommit = nil
            rimeEngine?.resetSession()
            clearTypoCorrectionSuggestions()
            let pathEffect = clearT9PinyinPathStateReturningEffect()
            return .compositionChanged.union(pathEffect)
        case .keepComposition:
            return []
        case .notT9Composition:
            break
        default:
            break
        }
        if !state.currentComposition.isEmpty {
            finishActiveCompositionAsRawInput(source: .returnKey)
            rimeEngine?.resetSession()
            let pathEffect = clearT9PinyinPathStateReturningEffect()
            return .compositionChanged.union(pathEffect)
        }
        insertText("\n", source: .returnKey)
        return .continuationChanged
    }

    func handleDeleteBackward() -> KeyboardEffect {
        if let engine = rimeEngine, restorePartialCommitCheckpoint(using: engine) {
            return .compositionChanged
        }
        if let effects = handleNumberSuffixDeleteIfNeeded() {
            return effects
        }
        if let engine = rimeEngine, engine.isComposing() {
            if let effects = handleConfirmedT9FocusDeleteIfNeeded(using: engine) {
                return effects
            }
            // Core-owned digit ledger delete when Path has confirmed syllables
            // (or multi-digit source). Must run before engine.deleteBackward so we
            // never get stuck when RIME refuses a shortened letter raw (qingweie).
            if let effects = handleT9CompositionIdentityDeleteIfNeeded(using: engine) {
                return effects
            }
            if let effects = handleVisibleT9PinyinDeleteIfNeeded(using: engine) {
                return effects
            }
            let previousT9PathState = state.t9PinyinPathState
            let previousRawForTrace = state.lastRimeOutput?.rawInput
            let result = engine.deleteBackward()
            applyRimeOutputPreservingPartialCommit(augmentRimeOutputIfNeeded(result))
            let restoredFocus = restoreFocusedT9SegmentAfterDeletion(
                previous: previousT9PathState
            )
            // Confirmed Path identity: force RIME back onto Core (anti fan-fan).
            // restoreFocused already resyncs when confirmed non-empty.
            if restoredFocus,
               state.t9PinyinPathState.confirmedSegmentValues.isEmpty == false,
               state.lastRimeOutput?.composition?.preeditText
                   .replacingOccurrences(of: " ", with: "")
                   .contains("fanfan") == true
            {
                _ = resyncRimeCompositionFromT9Identity()
            }
            // Human C: after Delete on a long unconfirmed composition, if RIME
            // left a letter-locked morphology (not pure digits), return to pure
            // digit input mode so retyping rediscovers Path like first entry.
            // Do not override short letter peels (`to`→`t`) owned by visible delete.
            if state.t9PinyinPathState.confirmedSegmentValues.isEmpty,
               let digits = state.t9PinyinPathState.segmentSourceDigits,
               digits.count > 3,
               digits.allSatisfy(\.isNumber)
            {
                var pathState = state.t9PinyinPathState
                pathState.selectedPath = nil
                pathState.lockedLetterPrefix = nil
                state.t9PinyinPathState = pathState
                let liveRaw = state.lastRimeOutput?.rawInput ?? ""
                let pureLive = !liveRaw.isEmpty && liveRaw.allSatisfy(\.isNumber)
                if !pureLive || liveRaw != digits {
                    _ = resyncRimeCompositionFromT9Identity()
                }
            } else if state.t9PinyinPathState.confirmedSegmentValues.isEmpty {
                // Still clear phantom selection after conf-empty Delete (Human: qi).
                var pathState = state.t9PinyinPathState
                pathState.selectedPath = nil
                state.t9PinyinPathState = pathState
            }
            #if DEBUG
            gate5TraceComposition(
                event: .deleteBackward,
                previousRaw: previousRawForTrace,
                note: "restoredFocus=\(restoredFocus)"
            )
            #endif
            return restoredFocus
                ? .compositionChanged.union(.t9PinyinPathsChanged)
                : .compositionChanged
        }
        if !state.currentComposition.isEmpty {
            state.currentComposition.removeLast()
            // T9 tracks raw digits in currentComposition — never push them to the host.
            if T9CompositionCommitPolicy.isActiveT9Composition(
                usesT9InputSemantics: usesT9InputSemantics,
                rawInput: state.currentComposition
            ) || T9CompositionCommitPolicy.isActiveT9Composition(
                usesT9InputSemantics: usesT9InputSemantics,
                rawInput: state.lastRimeOutput?.rawInput
            ) {
                if state.currentComposition.isEmpty {
                    clearInlinePreedit()
                    state.lastRimeOutput = nil
                    _ = clearT9PinyinPathStateReturningEffect()
                } else if let engine = rimeEngine,
                          restoreRimeComposition(
                            state.currentComposition,
                            using: engine,
                            rebuildSession: true
                          )
                {
                    return .compositionChanged
                } else {
                    // Fail closed: clear host underline rather than leak digits.
                    clearInlinePreedit()
                    state.lastRimeOutput = nil
                    state.currentComposition = ""
                    _ = clearT9PinyinPathStateReturningEffect()
                }
                clearTypoCorrectionSuggestions()
                return .compositionChanged
            }
            updateInlinePreedit(state.currentComposition, source: .compositionProjection)
            refreshTypoCorrectionSuggestions()
            return .compositionChanged
        }
        textClient?.deleteBackward()
        return clearContinuation()
    }

    /// After a nested candidate undo, an apostrophe-anchored raw keeps the
    /// confirmed Path Bar prefix on the left and the unresolved tail on the
    /// right (`qiu'53` / visible `qiule`). Delete follows last-entered input:
    /// remove the final unresolved slot (`3` / visible `e`) → `qiu'5` / `qiul`,
    /// not an earlier focus-head slot (`5` / `l`).
    private func handleConfirmedT9FocusDeleteIfNeeded(
        using engine: RimeEngine
    ) -> KeyboardEffect? {
        guard let partialCommit = state.partialCommit,
              partialCommit.checkpoint == nil,
              partialCommit.source != .numberSuffix,
              let rawInput = state.lastRimeOutput?.rawInput,
              T9CompositionCommitPolicy.isActiveT9Composition(
                usesT9InputSemantics: usesT9InputSemantics,
                rawInput: rawInput
              ),
              let boundary = rawInput.lastIndex(of: "'"),
              rawInput.index(after: boundary) < rawInput.endIndex
        else { return nil }

        let confirmedRaw = String(rawInput[..<boundary])
        guard confirmedRaw.unicodeScalars.contains(
            where: T9PinyinPathExtractor.isASCIILetter
        ) else { return nil }

        let unresolvedRaw = String(rawInput[rawInput.index(after: boundary)...])
        guard !unresolvedRaw.isEmpty else { return nil }
        let shortenedUnresolvedRaw = String(unresolvedRaw.dropLast())
        let shortenedRaw = shortenedUnresolvedRaw.isEmpty
            ? confirmedRaw
            : confirmedRaw + "'" + shortenedUnresolvedRaw

        var visibleLetters = Array(
            partialCommit.remainingPreeditText.unicodeScalars.filter(
                T9PinyinPathExtractor.isASCIILetter
            )
        )
        guard !visibleLetters.isEmpty else { return nil }
        // Last visible letter matches the last unresolved raw slot the user entered.
        visibleLetters.removeLast()
        let shortenedVisible = String(String.UnicodeScalarView(visibleLetters))

        let previousRaw = rawInput
        let output = engine.replaceInput(shortenedRaw)
        guard output.committedText == nil,
              output.composition?.preeditText.isEmpty == false,
              T9PinyinPathExtractor.normalizeRawIdentity(output.rawInput)
                == T9PinyinPathExtractor.normalizeRawIdentity(shortenedRaw)
        else {
            // Preserve the coherent pre-delete state when RIME rejects the
            // exact shortened raw. Return nil so identity/engine delete may run
            // — never return [] (would swallow Delete with no visible effect).
            _ = engine.replaceInput(previousRaw)
            return nil
        }

        let safeOutput = augmentRimeOutputIfNeeded(output)
        // Path rebuild uses the still-present segment digit identity plus the
        // shortened live trailing raw (`qiu'5`), so siblings/next-focus choices
        // are not collapsed to a single comment label.
        applyRimeOutputPreservingPartialCommit(safeOutput)
        state.lastRimeOutput = safeOutput
        state.currentComposition = shortenedRaw
        let displayText = partialCommit.confirmedText + shortenedVisible
        state.partialCommit = PartialCommitState(
            confirmedText: partialCommit.confirmedText,
            remainingRawInput: shortenedRaw,
            remainingPreeditText: shortenedVisible,
            displayText: displayText,
            checkpoint: nil,
            source: partialCommit.source
        )
        updateInlinePreedit(displayText, source: .compositionProjection)
        clearTypoCorrectionSuggestions()
        #if DEBUG
        gate5TraceComposition(
            event: .deleteBackward,
            previousRaw: previousRaw,
            note: "branch=confirmedFocus success=true"
        )
        #endif
        return .compositionChanged.union(.t9PinyinPathsChanged)
    }

    /// Native-style Delete follows the spelling the user can see, not an
    /// ambiguous shorter digit run that RIME may re-rank as another syllable.
    /// Explicit segmented choices and Partial Commit restore are handled by
    /// their existing state-machine paths before reaching this helper.
    private func handleVisibleT9PinyinDeleteIfNeeded(using engine: RimeEngine) -> KeyboardEffect? {
        guard state.partialCommit == nil,
              state.t9PinyinPathState.selectedPath == nil,
              state.t9PinyinPathState.confirmedSegmentValues.isEmpty,
              T9CompositionCommitPolicy.isActiveT9Composition(
                usesT9InputSemantics: usesT9InputSemantics,
                rawInput: state.lastRimeOutput?.rawInput
              ),
              let shortened = deletingLastVisibleT9Letter(from: state.insertedPreeditText)
        else { return nil }

        let previousRaw = state.lastRimeOutput?.rawInput ?? state.currentComposition
        if shortened.isEmpty {
            engine.resetSession()
            state.currentComposition = ""
            state.lastRimeOutput = nil
            state.partialCommit = nil
            updateInlinePreedit("", source: .compositionProjection)
            clearTypoCorrectionSuggestions()
            #if DEBUG
            gate5TraceComposition(
                event: .deleteBackward,
                previousRaw: previousRaw,
                note: "branch=visibleSpelling emptied=true"
            )
            #endif
            return .compositionChanged.union(clearT9PinyinPathStateReturningEffect())
        }

        let output = engine.replaceInput(shortened)
        guard output.committedText == nil,
              output.composition?.preeditText.isEmpty == false,
              T9PinyinPathExtractor.normalizeRawIdentity(output.rawInput)
                == T9PinyinPathExtractor.normalizeRawIdentity(shortened)
        else {
            // Let the existing engine Delete/rollback path handle rejection.
            let restored = engine.replaceInput(previousRaw)
            if restored.composition?.preeditText.isEmpty == false,
               T9PinyinPathExtractor.normalizeRawIdentity(restored.rawInput)
                == T9PinyinPathExtractor.normalizeRawIdentity(previousRaw)
            {
                return nil
            }

            // The live session is no longer trustworthy. Clear rather than
            // deleting from an unknown raw identity or exposing it to the host.
            engine.resetSession()
            state.currentComposition = ""
            state.lastRimeOutput = nil
            state.partialCommit = nil
            updateInlinePreedit("", source: .compositionProjection)
            clearTypoCorrectionSuggestions()
            #if DEBUG
            gate5TraceComposition(
                event: .deleteBackward,
                previousRaw: previousRaw,
                note: "branch=visibleSpelling rejected=true cleared=true"
            )
            #endif
            return .compositionChanged.union(clearT9PinyinPathStateReturningEffect())
        }

        applyRimeOutput(augmentRimeOutputIfNeeded(output))
        // Human: never leave a phantom selected chip after letter peel (qi).
        // Keep the exact shortened spelling — do not force pure-digit resync here
        // (would destroy `to`→`t` ownership owned by this branch).
        var pathState = state.t9PinyinPathState
        pathState.selectedPath = nil
        pathState.lockedLetterPrefix = nil
        state.t9PinyinPathState = pathState
        // Candidate comments may advertise a longer completion; Delete owns the
        // exact shortened spelling until the next explicit input/refinement.
        updateInlinePreedit(shortened, source: .compositionProjection)
        #if DEBUG
        gate5TraceComposition(
            event: .deleteBackward,
            previousRaw: previousRaw,
            note: "branch=visibleSpelling success=true"
        )
        #endif
        return .compositionChanged.union(.t9PinyinPathsChanged)
    }

    private func deletingLastVisibleT9Letter(from text: String) -> String? {
        guard !text.isEmpty else { return nil }
        var scalars = Array(text.unicodeScalars)
        guard scalars.allSatisfy({
            T9PinyinPathExtractor.isASCIILetter($0)
                || T9PinyinPathExtractor.isASCIISeparator($0)
        }) else { return nil }

        while scalars.last.map(T9PinyinPathExtractor.isASCIISeparator) == true {
            scalars.removeLast()
        }
        guard scalars.last.map(T9PinyinPathExtractor.isASCIILetter) == true else { return nil }
        scalars.removeLast()
        while scalars.last.map(T9PinyinPathExtractor.isASCIISeparator) == true {
            scalars.removeLast()
        }
        return String(String.UnicodeScalarView(scalars))
    }

    func handleNumberSuffixDeleteIfNeeded() -> KeyboardEffect? {
        guard let partialCommit = state.partialCommit,
              partialCommit.source == .numberSuffix
        else {
            return nil
        }

        let rawInput = String(partialCommit.remainingRawInput.dropLast())
        guard !rawInput.isEmpty else {
            clearInlinePreedit()
            state.currentComposition = ""
            state.lastRimeOutput = nil
            state.partialCommit = nil
            clearTypoCorrectionSuggestions()
            return .compositionChanged
        }

        guard splitLetterPrefixAndNumericSuffix(rawInput) != nil else {
            state.partialCommit = nil
            state.currentComposition = ""
            state.lastRimeOutput = nil
            if let engine = rimeEngine,
               restoreRimeComposition(rawInput, using: engine, rebuildSession: true)
            {
                return .compositionChanged
            }
            state.currentComposition = rawInput
            updateInlinePreedit(rawInput, source: .compositionProjection)
            refreshTypoCorrectionSuggestions()
            return .compositionChanged
        }

        state.partialCommit = numberSuffixPartialCommit(
            prefix: partialCommit.confirmedText,
            rawInput: rawInput
        )
        state.currentComposition = rawInput
        state.lastRimeOutput = numberSuffixRimeOutput(
            prefix: partialCommit.confirmedText,
            rawInput: rawInput
        )
        updateInlinePreedit(rawInput, source: .explicitNumberSuffix)
        clearTypoCorrectionSuggestions()
        return .compositionChanged
    }

    func insertText(
        _ text: String,
        source: CommittedTextSource = .compositionFinalization
    ) {
        guard !text.isEmpty, let textClient else { return }
        textClient.insertText(text)
        didCommitText(text, source: source)
    }

    func adjustTextPosition(byCharacterOffset offset: Int) {
        textClient?.adjustTextPosition(byCharacterOffset: offset)
    }

    /// Updates inline preedit as marked text so host text fields can display
    /// the active composition with the system's composing underline.
    enum HostPreeditSource {
        /// Composition projection derived from RIME/Core state. Internal digits
        /// are never valid host text, even if runtime selection just failed closed.
        case compositionProjection
        /// Numeric suffix explicitly entered by the user on the number page.
        case explicitNumberSuffix
    }

    func updateInlinePreedit(_ text: String, source: HostPreeditSource) {
        let previous = state.insertedPreeditText
        let safeText: String
        // Internal T9 digit invariant applies only under nine-key T9 semantics.
        // 26-key letter+digit compositions (e.g. `n20260619` on the numbers page)
        // are legitimate host preedit and must not be rejected.
        if source == .compositionProjection,
           usesT9InputSemantics,
           compositionProjectionContainsInternalDigit(text)
        {
            // This is the final host boundary. Preserve the prior safe spelling
            // (or clear) instead of allowing even a transient `qiu5` / raw digit
            // write that a later update might hide from final-state assertions.
            safeText = compositionProjectionContainsInternalDigit(previous)
                ? ""
                : previous
            Logger.shared.warning(
                "host preedit rejected: internal digit projection length=\(text.count)",
                category: .display
            )
        } else {
            safeText = text
        }
        guard previous != safeText else { return }

        if safeText.isEmpty {
            clearInlinePreedit()
        } else {
            textClient?.setMarkedText(
                safeText,
                selectedRange: safeText.count..<safeText.count
            )
        }

        state.insertedPreeditText = safeText
        state.insertedPreeditCount = safeText.count
    }

    /// Candidate-confirmed text may legitimately contain numbers (for example
    /// `3D打印`). Only the still-editable composition suffix is subject to the
    /// internal T9 digit invariant.
    func compositionProjectionContainsInternalDigit(_ text: String) -> Bool {
        let editableText: Substring
        if let confirmed = state.partialCommit?.confirmedText,
           !confirmed.isEmpty,
           text.hasPrefix(confirmed)
        {
            editableText = text.dropFirst(confirmed.count)
        } else {
            editableText = text[...]
        }
        return editableText.unicodeScalars.contains(
            where: T9PinyinPathExtractor.isASCIIDigit
        )
    }

    func deleteInlinePreedit() {
        guard state.insertedPreeditCount > 0 else { return }
        clearInlinePreedit()
        state.insertedPreeditText = ""
        state.insertedPreeditCount = 0
    }

    func commitInlinePreedit(
        as text: String,
        selectedOffset: Int? = nil,
        source: CommittedTextSource = .compositionFinalization
    ) {
        // When commitText matches current preedit content, use insertText
        // to replace the current marked range. setMarkedText + unmarkText
        // does not reliably clear composing underline when content is unchanged.

        if text == state.insertedPreeditText, !text.isEmpty {
            insertText(text, source: source)
            state.insertedPreeditText = ""
            state.insertedPreeditCount = 0
            return
        }
        guard state.insertedPreeditCount > 0 else {
            insertText(text, source: source)
            return
        }
        if text.isEmpty {
            clearInlinePreedit()
        } else {
            let offset = min(max(0, selectedOffset ?? text.count), text.count)
            if let textClient {
                textClient.setMarkedText(text, selectedRange: offset..<offset)
                textClient.unmarkText()
                didCommitText(text, source: source)
            }
        }
        state.insertedPreeditText = ""
        state.insertedPreeditCount = 0
    }

    func clearInlinePreedit() {
        textClient?.setMarkedText("", selectedRange: 0..<0)
    }
}
