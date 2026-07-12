extension KeyboardController {
    func handleInsertKey(_ key: String) -> KeyboardEffect {
        guard shouldHandleAsChineseCompositionKey(key) else {
            guard let effects = handleSymbolPageTextInput(key, updatesEnglishAutoCap: true) else {
                insertText(key, source: .key)
                var effects = consumeSingleUseShiftIfNeeded()
                if state.inputMode == .english && AutoCapitalizationRules.isSentenceTerminator(key) {
                    state.shiftState = .singleUse
                    effects.insert(.shiftStateChanged)
                }
                return effects
            }
            return effects
        }
        let rimeKey = rimeInputKey(for: key)
        guard let engine = rimeEngine else {
            return effectsAfterChineseCompositionKey(appendFallbackCompositionKey(rimeKey), originalKey: key)
        }

        if let effects = handleNumberSuffixInputIfNeeded(rimeKey) {
            return effectsAfterChineseCompositionKey(effects, originalKey: key)
        }

        // Rebuild composition when returning from a host that reset the live RIME session.
        if shouldRestoreRimeComposition,
            !state.currentComposition.isEmpty,
            !engine.isComposing()
        {
            let intendedComposition =
                (state.partialCommit?.remainingRawInput ?? state.currentComposition)
                + fallbackInputText(for: rimeKey)
            if restoreRimeComposition(
                intendedComposition,
                using: engine,
                rebuildSession: shouldRebuildSessionDuringRestore
            ) {
                Logger.shared.info("RIME composition restored after session interruption", category: .engine)
                let effects = consumeSingleUseShiftIfNeeded().union(.compositionChanged)
                return effectsAfterChineseCompositionKey(effects, originalKey: key)
            }
            if !shouldRebuildSessionDuringRestore,
                restoreRimeComposition(intendedComposition, using: engine, rebuildSession: true)
            {
                Logger.shared.info("RIME composition restored after runtime recreation", category: .engine)
                let effects = consumeSingleUseShiftIfNeeded().union(.compositionChanged)
                return effectsAfterChineseCompositionKey(effects, originalKey: key)
            }
            shouldRestoreRimeComposition = true
            shouldRebuildSessionDuringRestore = true
            state.lastRimeOutput = nil
            return effectsAfterChineseCompositionKey(appendFallbackCompositionKey(rimeKey), originalKey: key)
        }

        let output: RimeOutput
        if let replacementInput = replacementRawInputForSymbolPageContinuation(appending: rimeKey) {
            output = engine.replaceInput(replacementInput)
        } else {
            output = engine.processKey(rimeKey)
        }
        // A rejected printable key must remain visible and retryable rather than being lost.
        if output.composition == nil,
            output.committedText == nil,
            !engine.isComposing()
        {
            let intendedComposition = state.currentComposition + fallbackInputText(for: rimeKey)
            if restoreRimeComposition(intendedComposition, using: engine, rebuildSession: true) {
                Logger.shared.info("RIME recovered after ignored printable key", category: .engine)
                let effects = consumeSingleUseShiftIfNeeded().union(.compositionChanged)
                return effectsAfterChineseCompositionKey(effects, originalKey: key)
            }
            shouldRestoreRimeComposition = true
            shouldRebuildSessionDuringRestore = true
            state.lastRimeOutput = nil
            Logger.shared.warning(
                "RIME ignored printable key; fallback shown and recovery will retry",
                category: .engine
            )
            return effectsAfterChineseCompositionKey(appendFallbackCompositionKey(rimeKey), originalKey: key)
        }

        applyRimeOutput(augmentRimeOutputIfNeeded(output))
        let effects = consumeSingleUseShiftIfNeeded().union(.compositionChanged)
        return effectsAfterChineseCompositionKey(effects, originalKey: key)
    }

    func shouldHandleAsChineseCompositionKey(_ key: String) -> Bool {
        guard state.inputMode == .chinese else { return false }
        if state.currentPage == .letters { return true }
        if shouldContinueChineseCompositionFromSymbolPage(with: key) { return true }
        return isChineseCompositionSeparator(key) && hasActiveCompositionForSymbolInput
    }

    func shouldContinueChineseCompositionFromSymbolPage(with key: String) -> Bool {
        guard hasActiveCompositionForSymbolInput else { return false }
        guard state.currentPage == .numbers || state.currentPage == .symbols else { return false }
        if state.partialCommit?.source == .numberSuffix {
            return state.currentPage == .numbers && Self.isSingleASCIIDigit(key)
        }
        return Self.chineseCompositionContinuationCharacters.contains(key)
    }

    func replacementRawInputForSymbolPageContinuation(appending key: String) -> String? {
        guard shouldContinueChineseCompositionFromSymbolPage(with: key) else { return nil }
        guard !shouldStartNumberSuffixCommit(appending: key) else { return nil }
        let rawInput =
            state.lastRimeOutput?.rawInput
            ?? state.partialCommit?.remainingRawInput
            ?? state.currentComposition
        guard !rawInput.isEmpty else { return nil }
        return rawInput + key
    }

    func handleNumberSuffixInputIfNeeded(_ key: String) -> KeyboardEffect? {
        if state.partialCommit?.source == .numberSuffix {
            guard Self.isSingleASCIIDigit(key) else { return nil }
            appendNumberSuffix(key)
            return consumeSingleUseShiftIfNeeded().union(.compositionChanged)
        }

        guard shouldStartNumberSuffixCommit(appending: key) else { return nil }
        guard let output = state.lastRimeOutput,
              let prefix = output.candidates.first?.text,
              let rawPrefix = output.rawInput
        else {
            return nil
        }
        startNumberSuffix(prefix: prefix, rawPrefix: rawPrefix, suffix: key)
        rimeEngine?.resetSession()
        return consumeSingleUseShiftIfNeeded().union(.compositionChanged)
    }

    func shouldStartNumberSuffixCommit(appending key: String) -> Bool {
        guard Self.isSingleASCIIDigit(key) else { return false }
        guard state.currentPage == .numbers else { return false }
        guard state.partialCommit == nil else { return false }
        guard let output = state.lastRimeOutput,
              let rawInput = output.rawInput,
              Self.isPlainLowercasePinyinRawInput(rawInput),
              output.candidates.first != nil
        else {
            return false
        }
        return true
    }

    func startNumberSuffix(prefix: String, rawPrefix: String, suffix: String) {
        let rawInput = rawPrefix + suffix
        state.partialCommit = numberSuffixPartialCommit(prefix: prefix, rawInput: rawInput)
        state.currentComposition = rawInput
        state.lastRimeOutput = numberSuffixRimeOutput(prefix: prefix, rawInput: rawInput)
        updateInlinePreedit(rawInput)
        clearTypoCorrectionSuggestions()
    }

    func appendNumberSuffix(_ key: String) {
        guard let partialCommit = state.partialCommit, partialCommit.source == .numberSuffix else { return }
        let rawInput = partialCommit.remainingRawInput + key
        state.partialCommit = numberSuffixPartialCommit(prefix: partialCommit.confirmedText, rawInput: rawInput)
        state.currentComposition = rawInput
        state.lastRimeOutput = numberSuffixRimeOutput(prefix: partialCommit.confirmedText, rawInput: rawInput)
        updateInlinePreedit(rawInput)
        clearTypoCorrectionSuggestions()
    }

    func numberSuffixPartialCommit(prefix: String, rawInput: String) -> PartialCommitState {
        PartialCommitState(
            confirmedText: prefix,
            remainingRawInput: rawInput,
            remainingPreeditText: rawInput,
            displayText: rawInput,
            checkpoint: nil,
            source: .numberSuffix
        )
    }

    func numberSuffixRimeOutput(prefix: String, rawInput: String) -> RimeOutput {
        let suffix = splitLetterPrefixAndNumericSuffix(rawInput)?.suffix ?? ""
        let candidateText = prefix + suffix
        return RimeOutput(
            rawInput: rawInput,
            composition: RimeComposition(preeditText: rawInput, cursorPosition: rawInput.count),
            candidates: [RimeCandidate(text: candidateText)],
            highlightedIndex: 0
        )
    }

    func rimeInputKey(for key: String) -> String {
        isChineseCompositionSeparator(key) ? "'" : key
    }

    func effectsAfterChineseCompositionKey(_ effects: KeyboardEffect, originalKey: String) -> KeyboardEffect {
        guard isChineseCompositionSeparator(originalKey),
            state.currentPage == .numbers || state.currentPage == .symbols
        else {
            return effects
        }
        var combined = effects
        combined.formUnion(returnToLettersAfterSymbolInput())
        return combined
    }

    func appendFallbackCompositionKey(_ key: String) -> KeyboardEffect {
        state.currentComposition += fallbackInputText(for: key)
        if let partialCommit = state.partialCommit {
            let displayText = partialCommit.confirmedText + state.currentComposition
            state.partialCommit = PartialCommitState(
                confirmedText: partialCommit.confirmedText,
                remainingRawInput: partialCommit.remainingRawInput + fallbackInputText(for: key),
                remainingPreeditText: state.currentComposition,
                displayText: displayText,
                checkpoint: nil,
                source: partialCommit.source
            )
            updateInlinePreedit(displayText)
            clearTypoCorrectionSuggestions()
        } else {
            updateInlinePreedit(state.currentComposition)
            refreshTypoCorrectionSuggestions()
        }
        return consumeSingleUseShiftIfNeeded().union(.compositionChanged)
    }

    func fallbackInputText(for key: String) -> String {
        state.currentComposition.isEmpty && state.shiftState != .off ? key : key.lowercased()
    }

    func restoreRimeComposition(
        _ text: String,
        using engine: RimeEngine,
        rebuildSession: Bool = false
    ) -> Bool {
        if rebuildSession {
            engine.recoverSession()
        } else {
            engine.resetSession()
        }
        let output: RimeOutput
        if Self.shouldRestoreRawInputWithReplacement(text) {
            output = engine.replaceInput(text)
            guard output.composition != nil || output.committedText != nil || engine.isComposing() else {
                engine.resetSession()
                return false
            }
        } else {
            var replayedOutput = RimeOutput()
            for character in text {
                replayedOutput = engine.processKey(String(character))
                if replayedOutput.composition == nil,
                    replayedOutput.committedText == nil,
                    !engine.isComposing()
                {
                    engine.resetSession()
                    return false
                }
            }
            output = replayedOutput
        }
        applyRimeOutput(augmentRimeOutputIfNeeded(output))
        return true
    }

    func applyRimeOutput(_ output: RimeOutput) {
        shouldRestoreRimeComposition = false
        shouldRebuildSessionDuringRestore = false
        applyRimeOutputPreservingPartialCommit(output)
    }

    func augmentRimeOutputIfNeeded(_ output: RimeOutput) -> RimeOutput {
        guard output.committedText == nil, output.candidates.isEmpty else { return output }
        guard let rawInput = output.rawInput, let split = splitLetterPrefixAndNumericSuffix(rawInput) else {
            return output
        }

        let prefixCandidates = candidateProvider.candidates(for: split.prefix)
        guard !prefixCandidates.isEmpty else { return output }

        return RimeOutput(
            rawInput: output.rawInput,
            composition: output.composition,
            candidates: prefixCandidates.map { RimeCandidate(text: $0 + split.suffix) },
            committedText: output.committedText,
            hasMorePages: output.hasMorePages,
            highlightedIndex: output.highlightedIndex == -1 ? 0 : output.highlightedIndex,
            candidatePageNumber: output.candidatePageNumber
        )
    }

    func splitLetterPrefixAndNumericSuffix(_ rawInput: String) -> (prefix: String, suffix: String)? {
        let scalars = Array(rawInput.unicodeScalars)
        guard let firstDigitIndex = scalars.firstIndex(where: { Self.isASCIIDigit($0) }),
              firstDigitIndex > scalars.startIndex
        else {
            return nil
        }

        let prefixScalars = scalars[..<firstDigitIndex]
        let suffixScalars = scalars[firstDigitIndex..<scalars.endIndex]
        guard prefixScalars.allSatisfy({ Self.isASCIILowercaseLetter($0) }),
              suffixScalars.allSatisfy({ Self.isASCIIDigit($0) })
        else {
            return nil
        }

        return (String(String.UnicodeScalarView(prefixScalars)), String(String.UnicodeScalarView(suffixScalars)))
    }

    private static func isASCIIDigit(_ scalar: Unicode.Scalar) -> Bool {
        scalar.value >= 48 && scalar.value <= 57
    }

    private static func isASCIILowercaseLetter(_ scalar: Unicode.Scalar) -> Bool {
        scalar.value >= 97 && scalar.value <= 122
    }

    private static func isSingleASCIIDigit(_ text: String) -> Bool {
        guard text.count == 1, let scalar = text.unicodeScalars.first else { return false }
        return isASCIIDigit(scalar)
    }

    private static func isPlainLowercasePinyinRawInput(_ text: String) -> Bool {
        !text.isEmpty && text.unicodeScalars.allSatisfy { isASCIILowercaseLetter($0) }
    }

    private static func shouldRestoreRawInputWithReplacement(_ text: String) -> Bool {
        text.contains { character in
            chineseCompositionContinuationCharacters.contains(String(character))
        }
    }

    private static let chineseCompositionContinuationCharacters: Set<String> = Set(
        "0123456789.+-*/%".map(String.init)
    ).union(["－", "＋", "＊", "／", "％"])

    func commitComposition() {
        finishActiveCompositionAsDisplayText()
    }
}
