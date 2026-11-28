extension KeyboardController {
    func handleInsertKey(_ key: String) -> KeyboardEffect {
        // EN-AUTOSPACE-IMMEDIATE-001：附着标点智能回删仅适用于 `.insertKey`
        // 命中冻结附着标点集合（r3 §2.3）；旧「待补空格」延迟语义废除，
        // 直接透传原键。其余任何输入一律先撤销回删资格（清态）。
        if state.englishTrailingSpaceMark != nil {
            if let effects = replaceOwnedTrailingSpaceWithAttachedPunctuation(key) {
                return effects
            }
            state.englishTrailingSpaceMark = nil
        }
        guard shouldHandleAsChineseCompositionKey(key) else {
            guard let effects = handleSymbolPageTextInput(key, updatesEnglishAutoCap: true) else {
                insertText(key, source: .key)
                var effects = consumeSingleUseShiftIfNeeded()
                effects.formUnion(noteEnglishKeyInput(key))
                if state.inputMode == .english,
                    AddressLikeKeyboardType(keyboardType: state.activeKeyboardType) == nil,
                    AutoCapitalizationRules.isSentenceTerminator(key)
                {
                    state.shiftState = .singleUse
                    effects.insert(.shiftStateChanged)
                }
                return effects
            }
            return effects
        }
        // ZH26-CAPSLOCK-FIX-001: in Chinese mode Caps Lock acts as a
        // temporary English passthrough, consistent with the iOS system
        // keyboard. luna_pinyin's alphabet has no uppercase, so feeding a
        // capital into RIME would bounce through fallback paths instead.
        // Commit any active composition first so the grouped text survives,
        // then insert the uppercase letter directly. Caps Lock itself is
        // never consumed (consumeSingleUseShiftIfNeeded only touches
        // .singleUse), and .singleUse / .chinese9 keep their existing
        // composition behavior untouched.
        if state.shiftState == .capsLock, Self.isSingleASCIILetter(key) {
            // Detect an active composition BEFORE finalization clears app-side state.
            let hasActiveComposition =
                !state.currentComposition.isEmpty
                || state.lastRimeOutput != nil
                || state.partialCommit != nil
                || rimeEngine?.isComposing() == true
            finishActiveCompositionAsDisplayText()
            insertText(key.uppercased(), source: .key)
            guard hasActiveComposition else { return [] }
            // On-device follow-up (ZH26-CAPSLOCK-RESET-FIX-001): finalization only
            // clears controller state; the librime session is still composing the
            // old pinyin. Without an explicit reset the stale raw input resurfaces
            // after Caps Lock is released ("nihao" + "a" revives as "nihaoa").
            rimeEngine?.resetSession()
            return .compositionChanged
        }
        let rimeKey = rimeInputKey(for: key)
        guard let engine = rimeEngine else {
            return effectsAfterChineseCompositionKey(appendFallbackCompositionKey(rimeKey), originalKey: key)
        }

        if let effects = handleNumberSuffixInputIfNeeded(rimeKey) {
            return effectsAfterChineseCompositionKey(effects, originalKey: key)
        }

        let previousRawForTrace = state.lastRimeOutput?.rawInput
        if rejectAcceptedT9AutoAnchorIdentityMismatchIfNeeded(
            rimeKey,
            liveRawInput: previousRawForTrace,
            using: engine
        ) {
            var effects = consumeSingleUseShiftIfNeeded()
                .union(.compositionChanged)
            effects.insert(.t9PinyinPathsChanged)
            return effectsAfterChineseCompositionKey(effects, originalKey: key)
        }

        // Rebuild composition when returning from a host that reset the live RIME session.
        if shouldRestoreRimeComposition,
            !state.currentComposition.isEmpty,
            !engine.isComposing()
        {
            if rejectMissingAcceptedT9AutoAnchorSessionIfNeeded(
                using: engine
            ) {
                var effects = consumeSingleUseShiftIfNeeded()
                    .union(.compositionChanged)
                effects.insert(.t9PinyinPathsChanged)
                return effectsAfterChineseCompositionKey(
                    effects,
                    originalKey: key
                )
            }
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

        let previousT9PathState = state.t9PinyinPathState

        // R2 gate (layout-universal for Chinese RIME): accept printable
        // composition keys without waiting for librime. Applies to 26-key and
        // T9 when the gate is on. T9-only L1 provisional dots are armed later
        // only under `usesT9InputSemantics` + dual-gate. Gate default is off.
        // All other session APIs still enter the same pipeline via
        // `ResponsiveRimeEngineBridge`.
        if isResponsiveRimePipelineEnabled {
            if responsiveRimeCoordinator == nil, threadAffineRimeCoordinator == nil {
                rebuildResponsiveRimeCoordinatorIfNeeded()
            }
            // R4-Wire: thread-affine dual gate (accept without MainActor librime).
            if let affine = threadAffineRimeCoordinator {
                if let replacementInput = replacementRawInputForSymbolPageContinuation(appending: rimeKey) {
                    let snapshot = affine.performOrderedNow(
                        .replaceInput(replacementInput, boundEpoch: nil, boundRevision: nil)
                    )
                    applyResponsivePublishedSnapshot(snapshot)
                    var effects = consumeSingleUseShiftIfNeeded().union(.compositionChanged)
                    if usesT9InputSemantics {
                        effects.insert(.t9PinyinPathsChanged)
                    }
                    return effectsAfterChineseCompositionKey(effects, originalKey: key)
                }
                enqueueResponsiveKeyApplyContext(
                    rimeKey: rimeKey,
                    previousT9PathState: previousT9PathState,
                    previousRawForTrace: previousRawForTrace
                )
                affine.scheduleProcessKey(rimeKey)
                recordResponsiveAcceptMetrics(from: affine.lastAcceptReceipt)
                // Rem-3-Polish: arm L1 ledger + deferred visual (no immediate
                // composition/Path effects — avoids per-key chrome thrash).
                applyResponsiveProvisionalL1IfEligible(rimeKey: rimeKey)
                // Delivery channel publishes asynchronously — no MainActor drain loop.
                let effects = consumeSingleUseShiftIfNeeded()
                return effectsAfterChineseCompositionKey(effects, originalKey: key)
            }
            if let coordinator = responsiveRimeCoordinator {
                if let replacementInput = replacementRawInputForSymbolPageContinuation(appending: rimeKey) {
                    // Symbol continuation must stay ordered with pending keys;
                    // drain the full queue (may wait) so Path/delete cannot race.
                    let snapshot = coordinator.performOrderedNow(
                        .replaceInput(replacementInput, boundEpoch: nil, boundRevision: nil)
                    )
                    applyResponsivePublishedSnapshot(snapshot)
                    var effects = consumeSingleUseShiftIfNeeded().union(.compositionChanged)
                    if usesT9InputSemantics {
                        effects.insert(.t9PinyinPathsChanged)
                    }
                    return effectsAfterChineseCompositionKey(effects, originalKey: key)
                }
                // Deferred processKey: accept now; drain on later MainActor turns
                // so handle returns before librime. Context enables R3 Path /
                // auto-anchor parity when the snapshot is applied.
                enqueueResponsiveKeyApplyContext(
                    rimeKey: rimeKey,
                    previousT9PathState: previousT9PathState,
                    previousRawForTrace: previousRawForTrace
                )
                coordinator.scheduleProcessKey(rimeKey)
                recordResponsiveAcceptMetrics(from: coordinator.lastAcceptReceipt)
                scheduleResponsivePipelineDrain(coordinator)
                let effects = consumeSingleUseShiftIfNeeded()
                return effectsAfterChineseCompositionKey(effects, originalKey: key)
            }
        }

        let output: RimeOutput
        if let replacementInput = replacementRawInputForSymbolPageContinuation(appending: rimeKey) {
            #if DEBUG || T9_AUTO_ANCHOR_DEVICE_PREFLIGHT
                output = HotPathSegmentTiming.measure(.rime) {
                    engine.replaceInput(replacementInput)
                }
            #else
                output = engine.replaceInput(replacementInput)
            #endif
        } else {
            #if DEBUG || T9_AUTO_ANCHOR_DEVICE_PREFLIGHT
                output = HotPathSegmentTiming.measure(.rime) {
                    engine.processKey(rimeKey)
                }
            #else
                output = engine.processKey(rimeKey)
            #endif
        }
        #if DEBUG || T9_AUTO_ANCHOR_DEVICE_PREFLIGHT
            HotPathSegmentTiming.noteEngineOutput(output)
        #endif
        if rejectUnusableAcceptedT9AutoAnchorDigitIfNeeded(
            rimeKey,
            previousLedger: state.t9ReversibleAutoAnchorState,
            output: output,
            using: engine
        ) {
            var effects = consumeSingleUseShiftIfNeeded()
                .union(.compositionChanged)
            effects.insert(.t9PinyinPathsChanged)
            return effectsAfterChineseCompositionKey(effects, originalKey: key)
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
        let retainedFocusedSegment: Bool
        if output.committedText == nil,
            rimeKey.count == 1,
            let digit = rimeKey.first
        {
            #if DEBUG || T9_AUTO_ANCHOR_DEVICE_PREFLIGHT
                retainedFocusedSegment = HotPathSegmentTiming.measure(.pathLocal) {
                    retainFocusedT9SegmentAfterAppendingDigit(
                        previous: previousT9PathState,
                        digit: digit
                    )
                }
            #else
                retainedFocusedSegment = retainFocusedT9SegmentAfterAppendingDigit(
                    previous: previousT9PathState,
                    digit: digit
                )
            #endif
        } else {
            retainedFocusedSegment = false
        }
        advanceAcceptedT9AutoAnchorDigit(
            rimeKey,
            previousLiveRawInput: previousRawForTrace,
            output: output
        )
        let autoAnchorOutcome = attemptReversibleT9AutoAnchorIfNeeded(using: engine)
        #if DEBUG
            if usesT9InputSemantics, rimeKey.count == 1, rimeKey.first?.isNumber == true {
                gate5TraceComposition(
                    event: .digitAppend,
                    previousRaw: previousRawForTrace,
                    note: "digitAppend=true retainFocus=\(retainedFocusedSegment) "
                        + "autoAnchor=\(autoAnchorOutcome.status.rawValue)"
                )
            }
        #endif
        var effects = consumeSingleUseShiftIfNeeded().union(.compositionChanged)
        if retainedFocusedSegment || autoAnchorOutcome.status != .notEligible {
            effects.insert(.t9PinyinPathsChanged)
        }
        if rimeKey.count == 1, rimeKey.allSatisfy({ "23456789".contains($0) }) {
            captureT9UnconfirmedDigitInterpretation()
        }
        return effectsAfterChineseCompositionKey(effects, originalKey: key)
    }

    static func isSingleASCIILetter(_ key: String) -> Bool {
        guard key.count == 1, let scalar = key.unicodeScalars.first else { return false }
        return (65...90).contains(scalar.value) || (97...122).contains(scalar.value)
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
        updateInlinePreedit(rawInput, source: .explicitNumberSuffix)
        clearTypoCorrectionSuggestions()
    }

    func appendNumberSuffix(_ key: String) {
        guard let partialCommit = state.partialCommit, partialCommit.source == .numberSuffix else { return }
        let rawInput = partialCommit.remainingRawInput + key
        state.partialCommit = numberSuffixPartialCommit(prefix: partialCommit.confirmedText, rawInput: rawInput)
        state.currentComposition = rawInput
        state.lastRimeOutput = numberSuffixRimeOutput(prefix: partialCommit.confirmedText, rawInput: rawInput)
        updateInlinePreedit(rawInput, source: .explicitNumberSuffix)
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
        clearT9UnconfirmedDeleteHistory()
        state.currentComposition += fallbackInputText(for: key)
        if let partialCommit = state.partialCommit {
            let remainingDisplayText: String
            if T9CompositionCommitPolicy.isActiveT9Composition(
                usesT9InputSemantics: usesT9InputSemantics,
                rawInput: state.currentComposition
            ) {
                // A missing/rejected session must not turn internal T9 digits into
                // host text. Preserve the last safe remainder until RIME recovers;
                // explicit refined letters may still remain visible.
                let explicitLetters = T9PreeditResolver.visiblePreedit(
                    rawInput: state.currentComposition,
                    candidates: [],
                    highlightedIndex: nil
                )
                remainingDisplayText =
                    explicitLetters.isEmpty
                    ? partialCommit.remainingPreeditText
                    : explicitLetters
            } else {
                remainingDisplayText = state.currentComposition
            }
            let displayText = partialCommit.confirmedText + remainingDisplayText
            state.partialCommit = PartialCommitState(
                confirmedText: partialCommit.confirmedText,
                remainingRawInput: partialCommit.remainingRawInput + fallbackInputText(for: key),
                remainingPreeditText: remainingDisplayText,
                displayText: displayText,
                checkpoint: nil,
                source: partialCommit.source
            )
            updateInlinePreedit(displayText, source: .compositionProjection)
            clearTypoCorrectionSuggestions()
        } else if T9CompositionCommitPolicy.isActiveT9Composition(
            usesT9InputSemantics: usesT9InputSemantics,
            rawInput: state.currentComposition
        ) {
            // Fallback composition under T9 still tracks raw digits internally.
            let visible = T9PreeditResolver.visiblePreedit(
                rawInput: state.currentComposition,
                candidates: state.lastRimeOutput?.candidates ?? [],
                highlightedIndex: state.lastRimeOutput?.highlightedIndex
            )
            // Prefer non-digit visible; if only digits available, keep prior host text.
            if !visible.isEmpty,
                !visible.unicodeScalars.allSatisfy(T9PinyinPathExtractor.isASCIIDigit)
            {
                updateInlinePreedit(visible, source: .compositionProjection)
            }
            clearTypoCorrectionSuggestions()
        } else {
            updateInlinePreedit(
                state.currentComposition,
                source: .compositionProjection
            )
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
        clearT9UnconfirmedDeleteHistory()
        if rebuildSession {
            engine.recoverSession()
            // In-place recovery may fail-close T9 → 26-key; sync controller policy immediately.
            applyRealizedSelectionFromEngine()
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

        // These local candidates do not retain the native candidate index space;
        // the reconstructed output intentionally has no candidateOrigin.
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

    /// EN-AUTOSPACE-IMMEDIATE-001 智能回删（r3 §2.2）：附着标点键命中冻结
    /// 集合时，若尾随空格标记武装且回删归属成立（同一文档、光标紧邻刚插入
    /// 空格），先 `deleteBackward()` 再插入标点（"Word " + "." → "Word."）。
    ///
    /// 归属核验在执行时刻进行：宿主前缀必须以标记记录的完整事务内容结尾。
    /// 上下文未知（读取 nil）、光标或文档已变化、所有权失效 → 返回 nil，
    /// 不删除任何宿主字符，调用方清态后按普通写入直插标点（"Word ." 退化
    /// 可接受）；严禁盲目删除其他字符。
    ///
    /// `deleteBackward()` 返回 Void：不同宿主的删除是否实际生效无法确认
    /// （红测 `testDeleteBackwardHostDifferenceWhenDeleteIsNoOp` 记录该限制
    /// —— no-op 宿主上结果为 "Word .."）。仅在归属成立（宿主前缀可读且
    /// 匹配，即光标前确有本状态机写入的字符）时才发出这一次回删。
    private func replaceOwnedTrailingSpaceWithAttachedPunctuation(
        _ key: String
    ) -> KeyboardEffect? {
        guard key.unicodeScalars.count == 1,
            let scalar = key.unicodeScalars.first,
            EnglishAutospace.attachedPunctuationScalars.contains(scalar),
            englishCandidateAutospaceEnabled,
            !EnglishAutospace.isDisabled(for: state.activeKeyboardType),
            state.inputMode == .english,
            state.currentPage == .letters,
            let mark = state.englishTrailingSpaceMark
        else { return nil }

        guard let before = documentContextBeforeInput?(),
            before.unicodeScalars.count >= mark.committedTransactionText.unicodeScalars.count,
            before.unicodeScalars.suffix(mark.committedTransactionText.unicodeScalars.count)
                .elementsEqual(mark.committedTransactionText.unicodeScalars)
        else {
            // 归属不成立：撤销回删资格，不删宿主字符（降级直插）。
            return nil
        }

        // 归属成立：清候选后回删刚插入的空格，再插入标点。
        var effects = clearEnglishCandidates()
        state.englishTrailingSpaceMark = nil
        textClient?.deleteBackward()
        insertText(key, source: .key)
        effects.formUnion(consumeSingleUseShiftIfNeeded())
        if state.inputMode == .english,
            AddressLikeKeyboardType(keyboardType: state.activeKeyboardType) == nil,
            AutoCapitalizationRules.isSentenceTerminator(key)
        {
            state.shiftState = .singleUse
            effects.insert(.shiftStateChanged)
        }
        return effects
    }
}

// MARK: - PB-016 PR-2: fail-closed quick-menu option replay (r3 §5.2)

public extension KeyboardController {
    /// Replays the live composition after a confirmed quick-menu option write.
    ///
    /// Gate-on owners replay inside `setOption` handling
    /// (`ResponsiveRimePipeline.swift`, `ThreadAffineRimeSpike.swift`); the
    /// fail-closed direct-held engine has no owner to do it, so the quick-menu
    /// controller path calls this instead: a same-epoch `replaceInput`
    /// publishes a fresh output snapshot for the current composition without
    /// any session lifecycle change. No-op while no composition is active.
    func replayCompositionAfterQuickMenuOptionChange() -> KeyboardEffect {
        guard let rawInput = state.lastRimeOutput?.rawInput, !rawInput.isEmpty, let engine = rimeEngine
        else { return [] }
        let output = engine.replaceInput(rawInput)
        applyRimeOutput(output)
        return .compositionChanged
    }
}
