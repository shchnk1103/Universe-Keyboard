extension KeyboardController {
    func handleInsertDirectText(_ text: String) -> KeyboardEffect {
        if let effects = handleSymbolPageTextInput(text) {
            return effects
        }
        var effects: KeyboardEffect = []
        if !state.currentComposition.isEmpty {
            finishActiveCompositionAsDisplayText()
            rimeEngine?.resetSession()
            effects.insert(.compositionChanged)
        }
        insertText(text)
        return effects
    }

    func handleInsertSpace() -> KeyboardEffect {
        if let partialCommit = state.partialCommit,
           partialCommit.source == .numberSuffix,
           let firstCandidate = state.lastRimeOutput?.candidates.first?.text
        {
            commitInlinePreedit(as: firstCandidate)
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

        if let engine = rimeEngine, engine.isComposing(),
            let firstCandidate = state.lastRimeOutput?.candidates.first?.text
        {
            // Preserve the first page selection even if later pages were prefetched for display.
            commitInlinePreedit(as: (state.partialCommit?.confirmedText ?? "") + firstCandidate)
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
        if !state.currentComposition.isEmpty {
            let first = candidateProvider.candidates(for: state.currentComposition).first ?? state.currentComposition
            commitInlinePreedit(as: first)
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
            insertText(" ")
            return []
        }

        let now = currentDate()
        let isDoubleSpace = state.lastSpaceTapTime.map { now.timeIntervalSince($0) < 0.45 } ?? false
        state.lastSpaceTapTime = now

        if isDoubleSpace {
            textClient?.deleteBackward()
            insertText(". ")
            state.lastSpaceTapTime = nil
        } else {
            insertText(" ")
        }
        return []
    }

    func handleInsertReturn() -> KeyboardEffect {
        if !state.currentComposition.isEmpty {
            finishActiveCompositionAsRawInput()
            rimeEngine?.resetSession()
            return .compositionChanged
        }
        insertText("\n")
        return []
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
        return []
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

    func insertText(_ text: String) {
        textClient?.insertText(text)
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

    func commitInlinePreedit(as text: String, selectedOffset: Int? = nil) {
        // When commitText matches current preedit content, use insertText
        // to replace the current marked range. setMarkedText + unmarkText
        // does not reliably clear composing underline when content is unchanged.

        if text == state.insertedPreeditText, !text.isEmpty {
            insertText(text)
            state.insertedPreeditText = ""
            state.insertedPreeditCount = 0
            return
        }
        guard state.insertedPreeditCount > 0 else {
            insertText(text)
            return
        }
        if text.isEmpty {
            clearInlinePreedit()
        } else {
            let offset = min(max(0, selectedOffset ?? text.count), text.count)
            textClient?.setMarkedText(text, selectedRange: offset..<offset)
            textClient?.unmarkText()
        }
        state.insertedPreeditText = ""
        state.insertedPreeditCount = 0
    }

    private func clearInlinePreedit() {
        textClient?.setMarkedText("", selectedRange: 0..<0)
    }
}
