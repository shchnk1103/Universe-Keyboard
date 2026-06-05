extension KeyboardController {
    func handleToggleShift() -> KeyboardEffect {
        let now = currentDate()
        let isDoubleTap = state.lastShiftTapTime.map { now.timeIntervalSince($0) < 0.35 } ?? false
        state.lastShiftTapTime = now
        if isDoubleTap && state.shiftState != .capsLock {
            state.shiftState = .capsLock
        } else {
            switch state.shiftState {
            case .off:
                state.shiftState = .singleUse
            case .singleUse, .capsLock:
                state.shiftState = .off
            }
        }
        return .shiftStateChanged
    }

    func handleTogglePage() -> KeyboardEffect {
        var effects: KeyboardEffect = []
        switch state.currentPage {
        case .letters:
            effects = resetShiftState()
            if let engine = rimeEngine, engine.isComposing() {
                finishActiveCompositionAsDisplayText()
                engine.resetSession()
                effects.insert(.compositionChanged)
            } else if !state.currentComposition.isEmpty {
                finishActiveCompositionAsDisplayText()
                effects.insert(.compositionChanged)
            }
            state.currentPage = .numbers
        case .numbers:
            state.currentPage = .symbols
        case .symbols:
            state.currentPage = .emoji
        case .emoji:
            state.currentPage = .letters
        }
        effects.insert(.pageChanged)
        return effects
    }

    func handleToggleInputMode() -> KeyboardEffect {
        var effects: KeyboardEffect = []
        if let engine = rimeEngine, engine.isComposing() {
            finishActiveCompositionAsDisplayText()
            engine.resetSession()
            effects.insert(.compositionChanged)
        } else if !state.currentComposition.isEmpty {
            finishActiveCompositionAsDisplayText()
            effects.insert(.compositionChanged)
        }

        let switchingToChinese = state.inputMode == .english
        state.inputMode = switchingToChinese ? .chinese : .english
        effects.insert(.inputModeChanged)
        Logger.shared.debug("Input mode switched to \(switchingToChinese ? "中文" : "英文")", category: .general)
        if state.currentPage != .letters {
            state.currentPage = .letters
            effects.insert(.pageChanged)
        }
        if switchingToChinese && state.shiftState != .off {
            state.shiftState = .off
            state.lastShiftTapTime = nil
            effects.insert(.shiftStateChanged)
        }
        return effects
    }

    func handleKeyboardTypeChanged(_ type: KeyboardType) -> KeyboardEffect {
        guard type != state.activeKeyboardType else { return [] }
        state.activeKeyboardType = type
        var effects: KeyboardEffect = .keyboardTypeChanged
        if type == .emailAddress || type == .URL || type == .webSearch {
            if !state.currentComposition.isEmpty {
                finishActiveCompositionAsDisplayText()
                effects.insert(.compositionChanged)
            }
            state.inputMode = .english
            effects.insert(.inputModeChanged)
            Logger.shared.debug("Input mode auto-switched to English for keyboard type \(type)", category: .general)
        }
        return effects
    }

    func consumeSingleUseShiftIfNeeded() -> KeyboardEffect {
        guard state.shiftState == .singleUse else { return [] }
        state.shiftState = .off
        state.lastShiftTapTime = nil
        return .shiftStateChanged
    }

    func resetShiftState() -> KeyboardEffect {
        let wasActive = state.shiftState != .off
        state.shiftState = .off
        state.lastShiftTapTime = nil
        return wasActive ? .shiftStateChanged : []
    }

    public func shouldAutoCapitalize(contextBeforeInput: String?) -> Bool {
        AutoCapitalizationRules.shouldAutoCapitalize(contextBeforeInput: contextBeforeInput)
    }

    @discardableResult
    public func applyAutoCapitalization(contextBeforeInput: String?) -> KeyboardEffect {
        guard state.inputMode == .english else { return [] }
        guard state.shiftState == .off else { return [] }
        guard shouldAutoCapitalize(contextBeforeInput: contextBeforeInput) else { return [] }
        state.shiftState = .singleUse
        return .shiftStateChanged
    }
}
