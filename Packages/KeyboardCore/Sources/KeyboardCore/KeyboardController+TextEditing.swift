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
            if T9CompositionCommitPolicy.isT9DigitComposition(rawInput: raw) {
                switch T9CompositionCommitPolicy.spaceAction(
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
                    state.lastSpaceTapTime = nil
                    return .compositionChanged
                case .keepComposition:
                    state.lastSpaceTapTime = nil
                    return []
                default:
                    break
                }
            } else if let firstCandidate = output?.candidates.first?.text {
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
                state.lastSpaceTapTime = nil
                return .compositionChanged
            }
        }
        if !state.currentComposition.isEmpty {
            if T9CompositionCommitPolicy.isT9DigitComposition(rawInput: state.currentComposition) {
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
            state.lastSpaceTapTime = nil
            return .compositionChanged
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
        if T9CompositionCommitPolicy.isT9DigitComposition(rawInput: raw) {
            switch T9CompositionCommitPolicy.returnAction(
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
                return .compositionChanged
            case .keepComposition:
                return []
            default:
                break
            }
        }
        if !state.currentComposition.isEmpty {
            finishActiveCompositionAsRawInput(source: .returnKey)
            rimeEngine?.resetSession()
            return .compositionChanged
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
            let result = engine.deleteBackward()
            applyRimeOutputPreservingPartialCommit(augmentRimeOutputIfNeeded(result))
            return .compositionChanged
        }
        if !state.currentComposition.isEmpty {
            state.currentComposition.removeLast()
            updateInlinePreedit(state.currentComposition)
            refreshTypoCorrectionSuggestions()
            return .compositionChanged
        }
        textClient?.deleteBackward()
        return clearContinuation()
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
            updateInlinePreedit(rawInput)
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
        updateInlinePreedit(rawInput)
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
    func updateInlinePreedit(_ text: String) {
        let previous = state.insertedPreeditText
        guard previous != text else { return }

        if text.isEmpty {
            clearInlinePreedit()
        } else {
            textClient?.setMarkedText(text, selectedRange: text.count..<text.count)
        }

        state.insertedPreeditText = text
        state.insertedPreeditCount = text.count
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
