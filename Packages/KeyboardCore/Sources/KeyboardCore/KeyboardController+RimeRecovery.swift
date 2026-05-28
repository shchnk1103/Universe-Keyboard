extension KeyboardController {
    func handleInsertKey(_ key: String) -> KeyboardEffect {
        guard state.currentPage == .letters && state.inputMode == .chinese else {
            insertText(key)
            var effects = consumeSingleUseShiftIfNeeded()
            if state.inputMode == .english && AutoCapitalizationRules.isSentenceTerminator(key) {
                state.shiftState = .singleUse
                effects.insert(.shiftStateChanged)
            }
            return effects
        }
        guard let engine = rimeEngine else {
            return appendFallbackCompositionKey(key)
        }

        // Rebuild composition when returning from a host that reset the live RIME session.
        if shouldRestoreRimeComposition,
            !state.currentComposition.isEmpty,
            !engine.isComposing()
        {
            let intendedComposition = state.currentComposition + fallbackInputText(for: key)
            if restoreRimeComposition(
                intendedComposition,
                using: engine,
                rebuildSession: shouldRebuildSessionDuringRestore
            ) {
                Logger.shared.info("RIME composition restored after session interruption", category: .engine)
                return consumeSingleUseShiftIfNeeded().union(.compositionChanged)
            }
            if !shouldRebuildSessionDuringRestore,
                restoreRimeComposition(intendedComposition, using: engine, rebuildSession: true)
            {
                Logger.shared.info("RIME composition restored after runtime recreation", category: .engine)
                return consumeSingleUseShiftIfNeeded().union(.compositionChanged)
            }
            shouldRestoreRimeComposition = true
            shouldRebuildSessionDuringRestore = true
            state.lastRimeOutput = nil
            return appendFallbackCompositionKey(key)
        }

        let output = engine.processKey(key)
        // A rejected printable key must remain visible and retryable rather than being lost.
        if output.composition == nil,
            output.committedText == nil,
            !engine.isComposing()
        {
            let intendedComposition = state.currentComposition + fallbackInputText(for: key)
            if restoreRimeComposition(intendedComposition, using: engine, rebuildSession: true) {
                Logger.shared.info("RIME recovered after ignored printable key", category: .engine)
                return consumeSingleUseShiftIfNeeded().union(.compositionChanged)
            }
            shouldRestoreRimeComposition = true
            shouldRebuildSessionDuringRestore = true
            state.lastRimeOutput = nil
            Logger.shared.warning(
                "RIME ignored printable key; fallback shown and recovery will retry",
                category: .engine
            )
            return appendFallbackCompositionKey(key)
        }

        applyRimeOutput(output)
        return consumeSingleUseShiftIfNeeded().union(.compositionChanged)
    }

    func appendFallbackCompositionKey(_ key: String) -> KeyboardEffect {
        state.currentComposition += fallbackInputText(for: key)
        updateInlinePreedit(state.currentComposition)
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
        var output = RimeOutput()
        for character in text {
            output = engine.processKey(String(character))
            if output.composition == nil,
                output.committedText == nil,
                !engine.isComposing()
            {
                engine.resetSession()
                return false
            }
        }
        applyRimeOutput(output)
        return true
    }

    func applyRimeOutput(_ output: RimeOutput) {
        shouldRestoreRimeComposition = false
        shouldRebuildSessionDuringRestore = false
        state.lastRimeOutput = output
        state.currentComposition = output.composition?.preeditText ?? ""
        updateInlinePreedit(state.currentComposition)
        if let commit = output.committedText {
            insertText(commit)
        }
    }

    func commitComposition() {
        guard !state.currentComposition.isEmpty else { return }
        deleteInlinePreedit()
        insertText(state.currentComposition)
        state.currentComposition = ""
    }
}
