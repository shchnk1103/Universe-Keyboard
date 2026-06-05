extension KeyboardController {
    func handleInsertDirectText(_ text: String) -> KeyboardEffect {
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
        if let engine = rimeEngine, engine.isComposing(),
            let firstCandidate = state.lastRimeOutput?.candidates.first?.text
        {
            // Preserve the first page selection even if later pages were prefetched for display.
            deleteInlinePreedit()
            insertText((state.partialCommit?.confirmedText ?? "") + firstCandidate)
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
            deleteInlinePreedit()
            insertText(first)
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
            finishActiveCompositionAsDisplayText()
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
        if let engine = rimeEngine, engine.isComposing() {
            let result = engine.deleteBackward()
            applyRimeOutputPreservingPartialCommit(result)
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

    func insertText(_ text: String) {
        textClient?.insertText(text)
    }

    /// Updates inline preedit by only deleting and inserting the changed suffix.
    func updateInlinePreedit(_ text: String) {
        let previous = state.insertedPreeditText
        guard previous != text else { return }

        let commonPrefix = commonPrefixCount(with: previous, text)
        let deleteCount = previous.count - commonPrefix
        if deleteCount > 0 {
            for _ in 0..<deleteCount {
                textClient?.deleteBackward()
            }
        }

        let insertion = String(text.dropFirst(commonPrefix))
        if !insertion.isEmpty {
            insertText(insertion)
        }

        state.insertedPreeditText = text
        state.insertedPreeditCount = text.count
    }

    func deleteInlinePreedit() {
        guard state.insertedPreeditCount > 0 else { return }
        for _ in 0..<state.insertedPreeditCount {
            textClient?.deleteBackward()
        }
        state.insertedPreeditText = ""
        state.insertedPreeditCount = 0
    }

    private func commonPrefixCount(with lhs: String, _ rhs: String) -> Int {
        var count = 0
        var leftIndex = lhs.startIndex
        var rightIndex = rhs.startIndex
        while leftIndex < lhs.endIndex, rightIndex < rhs.endIndex {
            guard lhs[leftIndex] == rhs[rightIndex] else { break }
            count += 1
            leftIndex = lhs.index(after: leftIndex)
            rightIndex = rhs.index(after: rightIndex)
        }
        return count
    }
}
