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
            state.currentPage = .numbers
        case .numbers:
            state.currentPage = .symbols
        case .symbols:
            state.currentPage = .emoji
        case .emoji:
            state.currentPage = .letters
        }
        effects.insert(.pageChanged)
        // ADR 0020: clear when leaving letters; rebuild from live Rime when returning to letters
        // with an active T9 composition (do not wait for a future key).
        if state.currentPage == .letters {
            effects.formUnion(rebuildT9PinyinPathStateIfComposing())
        } else {
            effects.formUnion(clearT9PinyinPathStateReturningEffect())
        }
        return effects
    }

    func handleToggleInputMode() -> KeyboardEffect {
        var effects: KeyboardEffect = []
        // m2: 会话内的手动选择优先于快照恢复；恢复写入不经本入口，不会误记。
        if state.addressLikeSession != nil {
            state.addressLikeSession?.manualSelection = true
        }
        let raw = state.lastRimeOutput?.rawInput ?? state.currentComposition
        switch T9CompositionCommitPolicy.languageSwitchAction(
            usesT9InputSemantics: usesT9InputSemantics,
            rawInput: raw
        ) {
        case .abandonComposition:
            // ADR 0018: never commit raw T9 digits on language switch.
            abandonResponsiveProvisionalL1WithoutHostCommit()
            clearInlinePreedit()
            state.currentComposition = ""
            state.lastRimeOutput = nil
            state.partialCommit = nil
            rimeEngine?.resetSession()
            clearTypoCorrectionSuggestions()
            effects.insert(.compositionChanged)
            effects.formUnion(clearT9PinyinPathStateReturningEffect())
        default:
            if isResponsiveProvisionalAhead
                || state.currentComposition.contains(ResponsiveProvisionalComposition.placeholderScalar)
            {
                abandonResponsiveProvisionalL1WithoutHostCommit()
                rimeEngine?.resetSession()
                effects.insert(.compositionChanged)
                effects.formUnion(clearT9PinyinPathStateReturningEffect())
            } else if let engine = rimeEngine, engine.isComposing() {
                finishActiveCompositionAsDisplayText()
                engine.resetSession()
                effects.insert(.compositionChanged)
                effects.formUnion(clearT9PinyinPathStateReturningEffect())
            } else if !state.currentComposition.isEmpty {
                finishActiveCompositionAsDisplayText()
                effects.insert(.compositionChanged)
                effects.formUnion(clearT9PinyinPathStateReturningEffect())
            }
        }

        let switchingToChinese = state.inputMode == .english
        state.inputMode = switchingToChinese ? .chinese : .english
        effects.insert(.inputModeChanged)
        if !switchingToChinese {
            effects.formUnion(clearContinuation())
        }
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
        let previousType = state.activeKeyboardType
        state.activeKeyboardType = type
        var effects: KeyboardEffect = .keyboardTypeChanged

        let enteringAddressLike = AddressLikeKeyboardType(keyboardType: type)
        let leavingAddressLike = AddressLikeKeyboardType(keyboardType: previousType)

        if enteringAddressLike != nil {
            if previousType == .URL || previousType == .webSearch || previousType == .emailAddress {
                // 三类互切：保留同一快照与手动选择，不再重复快照或重置模式。
                // 快照被 m1 路径清理过时重建为“当前模式”会话，不误判为首次进入。
                if let session = state.addressLikeSession {
                    if !session.manualSelection {
                        state.inputMode = .english
                        effects.insert(.inputModeChanged)
                    }
                } else {
                    state.addressLikeSession = AddressLikeSessionState(
                        originalMode: state.inputMode,
                        manualSelection: false
                    )
                }
            } else {
                // 首次从非 addressLike 进入：快照原模式，沿用 T9 composition 收束规则切英文。
                state.addressLikeSession = AddressLikeSessionState(originalMode: state.inputMode)
                applyAddressLikeEntryCompositionPolicy(effects: &effects)
                state.inputMode = .english
                effects.insert(.inputModeChanged)
            }
            effects.formUnion(clearContinuation())
            Logger.shared.debug(
                "Input mode auto-switched to English for keyboard type \(type)",
                category: .general
            )
            return effects
        }

        if leavingAddressLike != nil {
            // 离开至普通字段：恢复原模式并清快照（m2：恢复写入不记为手动选择）。
            if let session = state.addressLikeSession, !session.manualSelection {
                state.inputMode = session.originalMode
                effects.insert(.inputModeChanged)
            }
            state.addressLikeSession = nil
        }
        return effects
    }

    /// 首次进入 addressLike 时的 T9 composition 收束，与既有语言切换双分支一致（ADR 0018）。
    private func applyAddressLikeEntryCompositionPolicy(effects: inout KeyboardEffect) {
        let raw = state.lastRimeOutput?.rawInput ?? state.currentComposition
        switch T9CompositionCommitPolicy.languageSwitchAction(
            usesT9InputSemantics: usesT9InputSemantics,
            rawInput: raw
        ) {
        case .abandonComposition:
            clearInlinePreedit()
            state.currentComposition = ""
            state.lastRimeOutput = nil
            state.partialCommit = nil
            rimeEngine?.resetSession()
            clearTypoCorrectionSuggestions()
            effects.insert(.compositionChanged)
            effects.formUnion(clearT9PinyinPathStateReturningEffect())
        default:
            if !state.currentComposition.isEmpty {
                finishActiveCompositionAsDisplayText()
                effects.insert(.compositionChanged)
                effects.formUnion(clearT9PinyinPathStateReturningEffect())
            }
        }
    }

    /// m1 收口：宿主/文档切换等无法证明同一字段的路径调用，丢弃临时快照；
    /// 已生效的输入模式保持不变（fail-safe），不回写恢复值。
    public func clearAddressLikeSessionSnapshot() {
        state.addressLikeSession = nil
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
        // addressLike（.URL/.webSearch/.emailAddress）下无论中/英均禁用自动大写；
        // 显式用户 Shift / Caps Lock 保持可用且不被自动状态覆盖（guard 已挡）。
        guard AddressLikeKeyboardType(keyboardType: state.activeKeyboardType) == nil else { return [] }
        guard shouldAutoCapitalize(contextBeforeInput: contextBeforeInput) else { return [] }
        state.shiftState = .singleUse
        return .shiftStateChanged
    }
}
