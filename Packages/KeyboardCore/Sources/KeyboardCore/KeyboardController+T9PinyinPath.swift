import Foundation

extension KeyboardController {
    /// Read a bounded window of precise pinyin paths from Rime candidates.
    /// UIKit must not parse comments itself. Issued keys are registered under the
    /// current provenance revision (same raw snapshot).
    public func t9PinyinPathWindow(
        from globalIndex: Int = 0,
        limit: Int = T9PinyinPathExtractor.panelWindowLimit
    ) -> T9PinyinPathWindow {
        let generation = state.t9PinyinPathState.rawInputGeneration
        let provenance = state.t9PinyinPathState.provenanceRevision
        let raw = state.lastRimeOutput?.rawInput
        guard usesT9InputSemantics,
              T9CompositionCommitPolicy.isActiveT9Composition(
                usesT9InputSemantics: usesT9InputSemantics,
                rawInput: raw
              ),
              let engine = rimeEngine
        else {
            return T9PinyinPathWindow(
                rawInputGeneration: generation,
                provenanceRevision: provenance
            )
        }

        let safeLimit = max(1, limit)
        let window = engine.candidateWindow(from: max(0, globalIndex), limit: safeLimit)
        var accumulator = T9PinyinPathWindow(
            paths: [],
            nextGlobalIndex: window.startIndex,
            hasMoreCandidates: window.hasMoreCandidates,
            rawInputGeneration: generation,
            provenanceRevision: provenance
        )
        if let extended = T9PinyinPathExtractor.extendWindow(
            accumulator,
            with: window.candidates,
            rawInput: raw,
            nextIndex: window.nextIndex,
            hasMoreCandidates: window.hasMoreCandidates,
            expectedGeneration: generation
        ) {
            accumulator = T9PinyinPathWindow(
                paths: extended.paths,
                nextGlobalIndex: extended.nextGlobalIndex,
                hasMoreCandidates: extended.hasMoreCandidates,
                rawInputGeneration: generation,
                provenanceRevision: provenance
            )
        }

        if globalIndex <= 0, let pageCandidates = state.lastRimeOutput?.candidates, !pageCandidates.isEmpty {
            let pagePaths = T9PinyinPathExtractor.paths(from: pageCandidates, rawInput: raw)
            var seen = Set(pagePaths.map(\.replacementRawInput))
            var merged = pagePaths
            for path in accumulator.paths where seen.insert(path.replacementRawInput).inserted {
                merged.append(path)
            }
            accumulator = T9PinyinPathWindow(
                paths: merged,
                nextGlobalIndex: accumulator.nextGlobalIndex,
                hasMoreCandidates: accumulator.hasMoreCandidates,
                rawInputGeneration: generation,
                provenanceRevision: provenance
            )
        }

        registerIssuedPaths(
            accumulator.paths,
            generation: generation,
            provenanceRevision: provenance,
            discoveryNextIndex: accumulator.nextGlobalIndex,
            discoveryMayHaveMore: accumulator.hasMoreCandidates
        )
        return accumulator
    }

    public func t9PinyinPathAvailability() -> T9PinyinPathAvailability {
        let raw = state.lastRimeOutput?.rawInput
        guard usesT9InputSemantics,
              T9CompositionCommitPolicy.isActiveT9Composition(
                usesT9InputSemantics: usesT9InputSemantics,
                rawInput: raw
              )
        else {
            return .noComposition
        }
        if state.t9PinyinPathState.hasIssuedPaths
            || !state.t9PinyinPathState.compactPaths.isEmpty
        {
            return .pathsAvailable
        }
        if state.t9PinyinPathState.discoveryMayHaveMore {
            return .discoveryPending
        }
        if state.t9PinyinPathState.rawInputGeneration > 0 {
            return .exhaustedNoPaths
        }
        return .discoveryPending
    }

    public func hasSelectableT9PinyinPaths() -> Bool {
        t9PinyinPathAvailability().allowsSelectPinyinControl
    }

    func handleCycleT9PinyinPath() -> KeyboardEffect {
        let paths = state.t9PinyinPathState.compactPaths
        guard !paths.isEmpty else { return [] }

        let nextIndex: Int
        if let selected = state.t9PinyinPathState.selectedPath,
           let selectedIndex = paths.firstIndex(of: selected)
        {
            nextIndex = paths.index(after: selectedIndex) == paths.endIndex
                ? paths.startIndex
                : paths.index(after: selectedIndex)
        } else {
            nextIndex = paths.startIndex
        }
        // 选拼音: first/next/wrap only — never confirm/advance a segment.
        return handleSelectT9PinyinPath(paths[nextIndex], autoAdvance: false)
    }

    func handleSelectT9PinyinPath(_ path: T9PinyinPath) -> KeyboardEffect {
        // Direct path-bar tap: selecting a choice is a real confirmation.
        handleSelectT9PinyinPath(path, autoAdvance: true)
    }

    /// - Parameter autoAdvance: `true` for direct path taps (select ⇒ confirm and
    ///   advance when remaining digits exist). `false` for **选拼音** cycling, which
    ///   only moves the tentative selection within the current focus.
    private func handleSelectT9PinyinPath(
        _ path: T9PinyinPath,
        autoAdvance: Bool
    ) -> KeyboardEffect {
        guard usesT9InputSemantics,
              let engine = rimeEngine,
              let previous = state.lastRimeOutput,
              let previousRaw = previous.rawInput,
              T9CompositionCommitPolicy.isActiveT9Composition(
                usesT9InputSemantics: usesT9InputSemantics,
                rawInput: previousRaw
              )
        else {
            return []
        }

        // Already tentative (e.g. after 选拼音): a direct tap confirms/advances.
        if autoAdvance,
           path == state.t9PinyinPathState.selectedPath,
           isFocusedSegmentChoice(path, in: state.t9PinyinPathState),
           canConfirmAndAdvance(path, in: state.t9PinyinPathState)
        {
            return confirmFocusedT9SegmentAndAdvance()
        }

        let generation = state.t9PinyinPathState.rawInputGeneration
        let provenance = state.t9PinyinPathState.provenanceRevision
        guard generation > 0, provenance > 0 else { return [] }
        guard state.t9PinyinPathState.issuedReplacementKeys.contains(path.replacementRawInput) else {
            return []
        }
        let isCurrentFocusedChoice = isFocusedSegmentChoice(
            path,
            in: state.t9PinyinPathState
        )
        if !isCurrentFocusedChoice {
            // Flat paths still require position compatibility. Focused choices
            // already carry a Core-issued full replacement (`m4`, `n'g`, etc.)
            // and are validated transactionally against exact live RIME output.
            let compatibilityRaw = state.t9PinyinPathState.retainedChoiceSourceRawInput
                ?? previousRaw
            guard T9PinyinPathExtractor.isCompatible(
                path: path,
                withRawInput: compatibilityRaw
            ) else {
                return []
            }
        }

        let previousMarked = state.insertedPreeditText
        let previousComposition = state.currentComposition
        let previousPathState = state.t9PinyinPathState

        let result = engine.replaceInput(path.replacementRawInput)

        if isExactSuccessfulT9Refinement(result: result, requestedPath: path) {
            let retainsSingleDigitChoices = previousPathState.retainedChoiceSourceRawInput != nil
                && previousPathState.compactPaths.contains(path)
            let retainsSegmentFocus = isFocusedSegmentChoice(path, in: previousPathState)
            // Raw usually changes → hard provenance rebuild via refresh.
            applyRimeOutput(augmentRimeOutputIfNeeded(result))
            if retainsSegmentFocus {
                restoreSegmentFocusSnapshot(previousPathState, selectedPath: path)
            } else if retainsSingleDigitChoices {
                restoreRetainedChoiceSnapshot(previousPathState, selectedPath: path)
            } else if state.t9PinyinPathState.issuedReplacementKeys.contains(path.replacementRawInput) {
                state.t9PinyinPathState.selectedPath = path
            }
            applySelectedT9PinyinPathDisplay(path)

            // Direct tap: one press both selects and confirms when more digits remain.
            if autoAdvance,
               let selected = state.t9PinyinPathState.selectedPath,
               isFocusedSegmentChoice(selected, in: state.t9PinyinPathState),
               canConfirmAndAdvance(selected, in: state.t9PinyinPathState)
            {
                let advanceEffects = confirmFocusedT9SegmentAndAdvance()
                if !advanceEffects.isEmpty {
                    return advanceEffects
                }
            }

            return .compositionChanged.union(.t9PinyinPathsChanged)
        }

        return rollbackT9PinyinRefinement(
            engine: engine,
            previous: previous,
            previousRaw: previousRaw,
            previousMarked: previousMarked,
            previousComposition: previousComposition,
            previousPathState: previousPathState
        )
    }

    func clearT9PinyinPathState() {
        state.t9PinyinPathState = .empty
    }

    @discardableResult
    func clearT9PinyinPathStateReturningEffect() -> KeyboardEffect {
        let had = !state.t9PinyinPathState.compactPaths.isEmpty
            || state.t9PinyinPathState.selectedPath != nil
            || state.t9PinyinPathState.rawInputGeneration != 0
            || state.t9PinyinPathState.provenanceRevision != 0
            || state.t9PinyinPathState.trackedRawInput != nil
            || state.t9PinyinPathState.retainedChoiceSourceRawInput != nil
            || state.t9PinyinPathState.segmentSourceDigits != nil
            || state.t9PinyinPathState.focusedSegmentIndex != nil
            || !state.t9PinyinPathState.confirmedSegmentValues.isEmpty
            || !state.t9PinyinPathState.issuedReplacementKeys.isEmpty
            || state.t9PinyinPathState.discoveryMayHaveMore
        clearT9PinyinPathState()
        return had ? .t9PinyinPathsChanged : []
    }

    /// Apply path provenance after a **new** RimeOutput has been installed into state.
    ///
    /// Always opens a new `provenanceRevision` and rebuilds issued keys only from the
    /// live page/hot-path scan. Soft retention of expanded-window keys is not allowed
    /// here — even when raw identity is unchanged — because candidates/comments may
    /// have changed under the same raw (e.g. partial selection, engine re-rank).
    @discardableResult
    func applyT9PinyinPathStateFromNewRimeOutput() -> Bool {
        refreshT9PinyinPathState(forceNewProvenance: true)
    }

    /// Soft same-snapshot refresh of the **already stored** RimeOutput (UI / window re-scan).
    ///
    /// Does not bump `provenanceRevision` when raw is unchanged; keeps expanded-window
    /// issued keys still compatible with current raw, then unions live page/hot-path.
    /// Callers that just installed a new RimeOutput must use
    /// `applyT9PinyinPathStateFromNewRimeOutput()` instead.
    @discardableResult
    func refreshT9PinyinPathStateForSameSnapshot() -> Bool {
        refreshT9PinyinPathState(forceNewProvenance: false)
    }

    /// Rebuild compact paths + provenance from the latest Rime output.
    /// - Parameter forceNewProvenance: when true (new RimeOutput / rollback / page rebuild),
    ///   bump `provenanceRevision` and rebuild issued keys only from live scans — do not
    ///   keep expanded-window keys from a previous comment snapshot. When false and raw is
    ///   unchanged, soft-refresh keeps same-snapshot expanded issuances only.
    @discardableResult
    func refreshT9PinyinPathState(forceNewProvenance: Bool = false) -> Bool {
        let raw = state.lastRimeOutput?.rawInput
        guard usesT9InputSemantics,
              T9CompositionCommitPolicy.isActiveT9Composition(
                usesT9InputSemantics: usesT9InputSemantics,
                rawInput: raw
              ),
              let output = state.lastRimeOutput
        else {
            let had = !state.t9PinyinPathState.compactPaths.isEmpty
                || state.t9PinyinPathState.selectedPath != nil
                || state.t9PinyinPathState.rawInputGeneration != 0
                || state.t9PinyinPathState.provenanceRevision != 0
                || state.t9PinyinPathState.retainedChoiceSourceRawInput != nil
                || state.t9PinyinPathState.segmentSourceDigits != nil
                || state.t9PinyinPathState.focusedSegmentIndex != nil
                || !state.t9PinyinPathState.confirmedSegmentValues.isEmpty
                || !state.t9PinyinPathState.issuedReplacementKeys.isEmpty
            clearT9PinyinPathState()
            return had
        }

        let previousGeneration = state.t9PinyinPathState.rawInputGeneration
        let previousProvenance = state.t9PinyinPathState.provenanceRevision
        let previousTracked = state.t9PinyinPathState.trackedRawInput
        let previousIssued = state.t9PinyinPathState.issuedReplacementKeys
        let normalizedRaw = T9PinyinPathExtractor.normalizeRawIdentity(raw)
        let rawChanged = previousGeneration == 0 || previousTracked != normalizedRaw
        let hardProvenance = forceNewProvenance || rawChanged

        let generation: UInt64
        if previousGeneration == 0 {
            generation = 1
        } else if rawChanged {
            generation = previousGeneration &+ 1
        } else {
            generation = previousGeneration
        }

        let provenance: UInt64
        if previousProvenance == 0 || hardProvenance {
            provenance = previousProvenance == 0 ? 1 : previousProvenance &+ 1
        } else {
            provenance = previousProvenance
        }

        // Hard rebuild: issued only from live scan (new comment authority).
        // Soft same-snapshot: keep previously issued keys still compatible with current raw,
        // then union live page/hot-path (expanded windows stay authorized within snapshot).
        var issued: Set<String>
        if hardProvenance {
            issued = []
        } else {
            issued = Set(
                previousIssued.filter { key in
                    let path = T9PinyinPath(displayText: key, replacementRawInput: key)
                    return T9PinyinPathExtractor.isCompatible(path: path, withRawInput: raw)
                }
            )
        }

        let deterministicPaths = T9PinyinPathExtractor.deterministicSingleDigitPaths(rawInput: raw)
        let pureDigits = normalizedRaw.allSatisfy { $0.isASCII && $0.isNumber }
            ? normalizedRaw
            : ""
        let firstGroupLetters = pureDigits.first.map(T9PinyinPathExtractor.keyLetters(forDigit:)) ?? []
        let isWholeMultiDigit = pureDigits.count > 1 && !firstGroupLetters.isEmpty

        // Amendment B: whole multi-digit compact bar is progressive first-syllable
        // choices + first key-group letters. Multi-syllable whole comments
        // (e.g. "ni xian zai") must never occupy a single compact label.
        var paths: [T9PinyinPath] = []
        var discoveryNext = 0
        var discoveryMayHaveMore = false

        if !deterministicPaths.isEmpty {
            paths = deterministicPaths
            discoveryMayHaveMore = false
        } else if isWholeMultiDigit {
            // Native-style compact order: first-syllable options first (wa/ya/za…),
            // then fill with first-key letters (w/x/y/z) up to compactLimit.
            // Do not reserve all letter slots first — that used to drop `ya` when
            // only one syllable slot remained after four WXYZ letters.
            let firstGroupPaths = T9PinyinPathExtractor.firstKeyGroupPaths(sourceDigits: pureDigits)
            var evidence = output.candidates
            if let engine = rimeEngine {
                let window = engine.candidateWindow(
                    from: 0,
                    limit: T9PinyinPathExtractor.hotPathWindowLimit
                )
                evidence.append(contentsOf: window.candidates)
                discoveryNext = window.nextIndex
                discoveryMayHaveMore = window.hasMoreCandidates
            }
            var syllablePaths = T9PinyinPathExtractor.progressiveSyllablePaths(
                from: evidence,
                sourceDigits: pureDigits,
                confirmedSyllables: [],
                limit: T9PinyinPathExtractor.compactLimit
            )
            let rank = Dictionary(
                uniqueKeysWithValues: firstGroupLetters.enumerated().map { index, letter in
                    (letter, index)
                }
            )
            syllablePaths.sort { lhs, rhs in
                let left = lhs.displayText.first.flatMap { rank[$0] } ?? Int.max
                let right = rhs.displayText.first.flatMap { rank[$0] } ?? Int.max
                return left < right
            }
            var merged: [T9PinyinPath] = []
            var seenDisplays = Set<String>()
            for path in syllablePaths + firstGroupPaths {
                guard merged.count < T9PinyinPathExtractor.compactLimit else { break }
                guard seenDisplays.insert(path.displayText).inserted else { continue }
                merged.append(path)
            }
            paths = merged
        } else {
            // Non pure multi-digit: still comment-derived, but single-syllable
            // labels only (never "ni xian zai" as one compact cell).
            paths = T9PinyinPathExtractor.paths(
                from: output.candidates,
                rawInput: raw,
                limit: T9PinyinPathExtractor.compactLimit
            ).filter { !$0.displayText.contains(" ") }
            discoveryMayHaveMore = true
            if let engine = rimeEngine {
                let window = engine.candidateWindow(
                    from: 0,
                    limit: T9PinyinPathExtractor.hotPathWindowLimit
                )
                let more = T9PinyinPathExtractor.paths(from: window.candidates, rawInput: raw)
                    .filter { !$0.displayText.contains(" ") }
                var seen = Set(paths.map(\.replacementRawInput))
                for path in more {
                    if seen.insert(path.replacementRawInput).inserted,
                       paths.count < T9PinyinPathExtractor.compactLimit
                    {
                        paths.append(path)
                    }
                }
                discoveryNext = window.nextIndex
                discoveryMayHaveMore = window.hasMoreCandidates
            }
        }

        for path in paths {
            issued.insert(path.replacementRawInput)
        }
        if !paths.isEmpty, discoveryMayHaveMore {
            discoveryMayHaveMore = discoveryMayHaveMore || discoveryNext > 0
        }

        let previousSelected = state.t9PinyinPathState.selectedPath
        let selected = previousSelected.flatMap { selected in
            issued.contains(selected.replacementRawInput)
                ? (paths.first { $0.replacementRawInput == selected.replacementRawInput } ?? selected)
                : nil
        }

        let newState = T9PinyinPathState(
            compactPaths: paths,
            selectedPath: selected,
            rawInputGeneration: generation,
            provenanceRevision: provenance,
            trackedRawInput: normalizedRaw,
            issuedReplacementKeys: issued,
            discoveryNextIndex: discoveryNext,
            discoveryMayHaveMore: discoveryMayHaveMore,
            retainedChoiceSourceRawInput: deterministicPaths.isEmpty ? nil : normalizedRaw,
            segmentSourceDigits: pureDigits.isEmpty ? nil : pureDigits,
            focusedSegmentIndex: pureDigits.isEmpty ? nil : 0,
            confirmedSegmentValues: []
        )
        let changed = newState.compactPaths != state.t9PinyinPathState.compactPaths
            || newState.selectedPath != state.t9PinyinPathState.selectedPath
            || newState.rawInputGeneration != previousGeneration
            || newState.provenanceRevision != previousProvenance
            || newState.issuedReplacementKeys != state.t9PinyinPathState.issuedReplacementKeys
            || newState.discoveryMayHaveMore != state.t9PinyinPathState.discoveryMayHaveMore
            || newState.retainedChoiceSourceRawInput
                != state.t9PinyinPathState.retainedChoiceSourceRawInput
            || newState.segmentSourceDigits != state.t9PinyinPathState.segmentSourceDigits
            || newState.focusedSegmentIndex != state.t9PinyinPathState.focusedSegmentIndex
            || newState.confirmedSegmentValues != state.t9PinyinPathState.confirmedSegmentValues
        state.t9PinyinPathState = newState
        return changed
    }

    @discardableResult
    func rebuildT9PinyinPathStateIfComposing() -> KeyboardEffect {
        guard usesT9InputSemantics,
              state.currentPage == .letters,
              T9CompositionCommitPolicy.isActiveT9Composition(
                usesT9InputSemantics: usesT9InputSemantics,
                rawInput: state.lastRimeOutput?.rawInput
              )
        else {
            return clearT9PinyinPathStateReturningEffect()
        }
        // Page return: new live presentation snapshot.
        let changed = refreshT9PinyinPathState(forceNewProvenance: true)
        return changed || state.t9PinyinPathState.hasIssuedPaths || state.t9PinyinPathState.discoveryMayHaveMore
            ? .t9PinyinPathsChanged
            : []
    }

    // MARK: - Provenance registration

    private func registerIssuedPaths(
        _ paths: [T9PinyinPath],
        generation: UInt64,
        provenanceRevision: UInt64,
        discoveryNextIndex: Int,
        discoveryMayHaveMore: Bool
    ) {
        guard generation > 0,
              provenanceRevision > 0,
              generation == state.t9PinyinPathState.rawInputGeneration,
              provenanceRevision == state.t9PinyinPathState.provenanceRevision
        else { return }
        for path in paths {
            state.t9PinyinPathState.issuedReplacementKeys.insert(path.replacementRawInput)
        }
        if discoveryNextIndex > state.t9PinyinPathState.discoveryNextIndex {
            state.t9PinyinPathState.discoveryNextIndex = discoveryNextIndex
        }
        state.t9PinyinPathState.discoveryMayHaveMore = discoveryMayHaveMore
    }

    // MARK: - Transaction helpers

    /// Reinstall the deterministic sibling choices after live RIME raw changes.
    /// Generation/provenance/tracked raw stay sourced from the newly applied output;
    /// only the authorized choice origin and presentation survive the transaction.
    private func restoreRetainedChoiceSnapshot(
        _ snapshot: T9PinyinPathState,
        selectedPath: T9PinyinPath?
    ) {
        guard snapshot.retainedChoiceSourceRawInput != nil else { return }
        state.t9PinyinPathState.compactPaths = snapshot.compactPaths
        state.t9PinyinPathState.selectedPath = selectedPath
        state.t9PinyinPathState.issuedReplacementKeys = Set(
            snapshot.compactPaths.map(\.replacementRawInput)
        )
        state.t9PinyinPathState.discoveryNextIndex = 0
        state.t9PinyinPathState.discoveryMayHaveMore = false
        state.t9PinyinPathState.retainedChoiceSourceRawInput =
            snapshot.retainedChoiceSourceRawInput
        state.t9PinyinPathState.segmentSourceDigits = snapshot.segmentSourceDigits
        state.t9PinyinPathState.focusedSegmentIndex = snapshot.focusedSegmentIndex
        state.t9PinyinPathState.confirmedSegmentValues = snapshot.confirmedSegmentValues
    }

    /// Preserve the focused key group while its full replacement raw changes.
    /// Whole-composition paths are intentionally dropped once a segment choice
    /// becomes tentative; only sibling choices for the current focus remain.
    private func restoreSegmentFocusSnapshot(
        _ snapshot: T9PinyinPathState,
        selectedPath: T9PinyinPath?
    ) {
        let choices = focusedSegmentChoices(from: snapshot)
        guard !choices.isEmpty else { return }
        state.t9PinyinPathState.compactPaths = choices
        state.t9PinyinPathState.selectedPath = selectedPath.flatMap { selected in
            choices.first { $0.displayText == selected.displayText }
        }
        state.t9PinyinPathState.issuedReplacementKeys = Set(
            choices.map(\.replacementRawInput)
        )
        state.t9PinyinPathState.discoveryNextIndex = 0
        state.t9PinyinPathState.discoveryMayHaveMore = false
        state.t9PinyinPathState.retainedChoiceSourceRawInput =
            snapshot.retainedChoiceSourceRawInput
        state.t9PinyinPathState.segmentSourceDigits = snapshot.segmentSourceDigits
        state.t9PinyinPathState.focusedSegmentIndex = snapshot.focusedSegmentIndex
        state.t9PinyinPathState.confirmedSegmentValues = snapshot.confirmedSegmentValues
    }

    /// Called after a selected segment receives another nine-key digit. The live
    /// output has already been installed; this method only rebuilds the Core-owned
    /// focused snapshot against the extended original digit sequence.
    @discardableResult
    func retainFocusedT9SegmentAfterAppendingDigit(
        previous snapshot: T9PinyinPathState,
        digit: Character
    ) -> Bool {
        guard digit.isASCII, digit.isNumber,
              let source = snapshot.segmentSourceDigits,
              snapshot.focusedSegmentIndex != nil,
              let selected = snapshot.selectedPath,
              isFocusedSegmentChoice(selected, in: snapshot)
        else { return false }

        var extended = snapshot
        extended.segmentSourceDigits = source + String(digit)
        extended.retainedChoiceSourceRawInput = nil
        let previouslyAuthorizedValues = Set(snapshot.compactPaths.map(\.displayText))
        extended.compactPaths = canonicalFocusedSegmentChoices(from: extended).filter {
            previouslyAuthorizedValues.contains($0.displayText)
        }
        extended.issuedReplacementKeys = Set(extended.compactPaths.map(\.replacementRawInput))
        guard let remappedSelection = extended.compactPaths.first(where: {
            $0.displayText == selected.displayText
        }) else { return false }

        restoreSegmentFocusSnapshot(extended, selectedPath: remappedSelection)
        return true
    }

    /// Reverse the most recent pending digit/focus transition after RIME has
    /// already deleted one raw unit. This keeps the prior focused choice exact
    /// instead of rebuilding a flat path snapshot from candidate comments.
    @discardableResult
    func restoreFocusedT9SegmentAfterDeletion(
        previous snapshot: T9PinyinPathState
    ) -> Bool {
        guard let source = snapshot.segmentSourceDigits,
              source.count > 1,
              snapshot.focusedSegmentIndex != nil
        else { return false }

        var restored = snapshot
        let shortenedSource = String(source.dropLast())
        restored.segmentSourceDigits = shortenedSource
        var confirmed = snapshot.confirmedSegmentValues
        var selectedValue = snapshot.selectedPath?.displayText

        func lettersBudget() -> Int {
            T9PinyinPathExtractor.letterCount(ofSyllables: confirmed)
                + (selectedValue.map { T9PinyinPathExtractor.asciiLetterCount(in: $0) } ?? 0)
        }

        // Drop trailing focus/confirmed syllables that no longer fit the shortened
        // digit sequence (syllables may consume multiple digits).
        while lettersBudget() > shortenedSource.count {
            if selectedValue != nil {
                selectedValue = nil
                continue
            }
            guard let prior = confirmed.popLast() else { return false }
            selectedValue = prior
        }

        restored.confirmedSegmentValues = confirmed
        restored.focusedSegmentIndex = confirmed.count
        restored.retainedChoiceSourceRawInput = nil

        // Prefer remapping previously authorized labels; if the focus emptied,
        // fall back to first-key-group letters for multi-digit whole mode.
        var remapped = canonicalFocusedSegmentChoices(from: restored)
        if remapped.isEmpty, confirmed.isEmpty, shortenedSource.count > 1 {
            remapped = T9PinyinPathExtractor.firstKeyGroupPaths(sourceDigits: shortenedSource)
        } else if remapped.isEmpty, confirmed.isEmpty, shortenedSource.count == 1 {
            remapped = T9PinyinPathExtractor.deterministicSingleDigitPaths(
                rawInput: shortenedSource
            )
        }
        restored.compactPaths = remapped
        restored.issuedReplacementKeys = Set(remapped.map(\.replacementRawInput))

        guard let selectedValue,
              let selected = remapped.first(where: { $0.displayText == selectedValue })
        else {
            // Deletion may clear selection while keeping sibling choices visible.
            guard !remapped.isEmpty else { return false }
            restoreSegmentFocusSnapshot(restored, selectedPath: nil)
            return true
        }

        restoreSegmentFocusSnapshot(restored, selectedPath: selected)
        applySelectedT9PinyinPathDisplay(selected)
        return true
    }

    private func canConfirmAndAdvance(
        _ path: T9PinyinPath,
        in snapshot: T9PinyinPathState
    ) -> Bool {
        guard let source = snapshot.segmentSourceDigits else { return false }
        return T9PinyinPathExtractor.canAdvanceAfterConfirming(
            selectedDisplay: path.displayText,
            confirmedSyllables: snapshot.confirmedSegmentValues,
            sourceDigits: source
        )
    }

    private func confirmFocusedT9SegmentAndAdvance() -> KeyboardEffect {
        guard let engine = rimeEngine,
              let previousOutput = state.lastRimeOutput,
              let previousRaw = previousOutput.rawInput,
              let source = state.t9PinyinPathState.segmentSourceDigits,
              state.t9PinyinPathState.focusedSegmentIndex != nil,
              let selected = state.t9PinyinPathState.selectedPath,
              canConfirmAndAdvance(selected, in: state.t9PinyinPathState)
        else { return [] }

        let previousMarked = state.insertedPreeditText
        let previousComposition = state.currentComposition
        let previousPathState = state.t9PinyinPathState
        var confirmed = previousPathState.confirmedSegmentValues
        confirmed.append(selected.displayText)
        let nextFocus = confirmed.count
        let confirmedLetters = T9PinyinPathExtractor.letterCount(ofSyllables: confirmed)
        let remainingDigits = String(source.dropFirst(confirmedLetters))
        guard !remainingDigits.isEmpty else { return [] }

        // Gather live comment evidence under the current refined raw, then
        // restore exact previous raw after probes.
        var evidence = previousOutput.candidates
        let window = engine.candidateWindow(
            from: 0,
            limit: T9PinyinPathExtractor.hotPathWindowLimit
        )
        evidence.append(contentsOf: window.candidates)

        var authorized = T9PinyinPathExtractor.progressiveSyllablePaths(
            from: evidence,
            sourceDigits: source,
            confirmedSyllables: confirmed,
            limit: T9PinyinPathExtractor.compactLimit
        )

        // Live-probe each syllable path; only exact raw + usable composition survive.
        authorized = authorized.filter { path in
            let probe = engine.replaceInput(path.replacementRawInput)
            defer { _ = engine.replaceInput(previousRaw) }
            guard isExactSuccessfulT9Refinement(result: probe, requestedPath: path) else {
                return false
            }
            // Later focuses require the exact syllable in live comments.
            if nextFocus > 0 {
                let probeEvidence = probe.candidates + engine.candidateWindow(
                    from: 0,
                    limit: T9PinyinPathExtractor.hotPathWindowLimit
                ).candidates
                return T9PinyinPathExtractor.candidateCommentsAuthorizeExactSegment(
                    probeEvidence,
                    segmentIndex: nextFocus,
                    syllable: path.displayText
                )
                    || T9PinyinPathExtractor.candidateCommentsAuthorizeExactSegment(
                        evidence,
                        segmentIndex: nextFocus,
                        syllable: path.displayText
                    )
            }
            return true
        }

        // Fallback: single-letter key-group choices for the next remaining digit
        // when no multi-letter syllable is RIME-authorized (Amendment A letter path).
        if authorized.isEmpty, let nextDigit = remainingDigits.first {
            let prefix = confirmed.joined(separator: "'")
            let suffixDigits = String(remainingDigits.dropFirst())
            for letter in T9PinyinPathExtractor.keyLetters(forDigit: nextDigit) {
                let value = String(letter)
                let replacement = prefix + "'" + value + suffixDigits
                let requested = T9PinyinPath(displayText: value, replacementRawInput: replacement)
                let probe = engine.replaceInput(replacement)
                guard isExactSuccessfulT9Refinement(result: probe, requestedPath: requested)
                else { continue }
                let probeEvidence = probe.candidates + engine.candidateWindow(
                    from: 0,
                    limit: T9PinyinPathExtractor.hotPathWindowLimit
                ).candidates
                let authorizedByComment =
                    T9PinyinPathExtractor.candidateCommentsAuthorizeSegment(
                        probeEvidence,
                        segmentIndex: nextFocus,
                        startingWith: letter
                    )
                    || T9PinyinPathExtractor.candidateCommentsAuthorizeSegment(
                        evidence,
                        segmentIndex: nextFocus,
                        startingWith: letter
                    )
                _ = engine.replaceInput(previousRaw)
                guard authorizedByComment else { continue }
                authorized.append(requested)
                if authorized.count >= T9PinyinPathExtractor.compactLimit { break }
            }
            _ = engine.replaceInput(previousRaw)
        }

        let restored = engine.replaceInput(previousRaw)
        guard !authorized.isEmpty,
              isUsableT9SessionOutput(restored),
              T9PinyinPathExtractor.normalizeRawIdentity(restored.rawInput)
                == T9PinyinPathExtractor.normalizeRawIdentity(previousRaw)
        else {
            return rollbackT9PinyinRefinement(
                engine: engine,
                previous: previousOutput,
                previousRaw: previousRaw,
                previousMarked: previousMarked,
                previousComposition: previousComposition,
                previousPathState: previousPathState
            )
        }

        applyRimeOutput(augmentRimeOutputIfNeeded(restored))
        state.t9PinyinPathState.compactPaths = authorized
        state.t9PinyinPathState.selectedPath = nil
        state.t9PinyinPathState.issuedReplacementKeys = Set(authorized.map(\.replacementRawInput))
        state.t9PinyinPathState.discoveryNextIndex = 0
        state.t9PinyinPathState.discoveryMayHaveMore = false
        state.t9PinyinPathState.retainedChoiceSourceRawInput = nil
        state.t9PinyinPathState.segmentSourceDigits = source
        state.t9PinyinPathState.focusedSegmentIndex = nextFocus
        state.t9PinyinPathState.confirmedSegmentValues = confirmed
        return .compositionChanged.union(.t9PinyinPathsChanged)
    }

    private func isFocusedSegmentChoice(
        _ path: T9PinyinPath,
        in snapshot: T9PinyinPathState
    ) -> Bool {
        focusedSegmentChoices(from: snapshot).contains { choice in
            choice.displayText == path.displayText
                && choice.replacementRawInput == path.replacementRawInput
        }
    }

    /// Current focus choices are exactly the compact paths Core already issued.
    /// Syllable-level and single-letter choices share this set (Amendment B).
    private func focusedSegmentChoices(from snapshot: T9PinyinPathState) -> [T9PinyinPath] {
        guard snapshot.focusedSegmentIndex != nil,
              snapshot.segmentSourceDigits != nil
        else { return [] }
        return snapshot.compactPaths
    }

    /// Remap displayed focus labels onto the current digit sequence after append/delete.
    private func canonicalFocusedSegmentChoices(
        from snapshot: T9PinyinPathState
    ) -> [T9PinyinPath] {
        guard let source = snapshot.segmentSourceDigits,
              snapshot.focusedSegmentIndex != nil
        else { return [] }
        let confirmed = snapshot.confirmedSegmentValues
        var remapped: [T9PinyinPath] = []
        var seen = Set<String>()
        for path in snapshot.compactPaths {
            let display = path.displayText
            guard seen.insert(display).inserted else { continue }
            if let replacement = T9PinyinPathExtractor.replacementForProgressiveSyllable(
                displaySyllable: display,
                confirmedSyllables: confirmed,
                sourceDigits: source
            ) {
                remapped.append(
                    T9PinyinPath(displayText: display, replacementRawInput: replacement)
                )
                continue
            }
            // Single-letter fallback when syllable remap fails (digit identity only).
            guard display.count == 1,
                  let letter = display.first,
                  letter.isLetter
            else { continue }
            let confirmedLetters = T9PinyinPathExtractor.letterCount(ofSyllables: confirmed)
            guard confirmedLetters < source.count else { continue }
            let remaining = String(source.dropFirst(confirmedLetters))
            guard let digit = remaining.first,
                  T9PinyinPathExtractor.keyLetters(forDigit: digit).contains(letter)
            else { continue }
            let suffix = String(remaining.dropFirst())
            let prefix = confirmed.joined(separator: "'")
            let replacement = prefix.isEmpty ? display + suffix : prefix + "'" + display + suffix
            remapped.append(T9PinyinPath(displayText: display, replacementRawInput: replacement))
        }
        return remapped
    }

    /// An explicit precise-path choice owns the visible marked-text spelling.
    /// Candidate comments may describe a longer syllable and must not overwrite
    /// the exact `m/n/o` path the user is cycling through.
    private func applySelectedT9PinyinPathDisplay(_ path: T9PinyinPath) {
        guard let partialCommit = state.partialCommit else {
            updateInlinePreedit(path.displayText)
            return
        }

        let displayText = partialCommit.confirmedText + path.displayText
        state.partialCommit = PartialCommitState(
            confirmedText: partialCommit.confirmedText,
            remainingRawInput: state.lastRimeOutput?.rawInput
                ?? partialCommit.remainingRawInput,
            remainingPreeditText: path.displayText,
            displayText: displayText,
            checkpoint: partialCommit.checkpoint,
            source: partialCommit.source
        )
        updateInlinePreedit(displayText)
    }

    private func isUsableT9SessionOutput(_ result: RimeOutput) -> Bool {
        if let committed = result.committedText, !committed.isEmpty {
            return false
        }
        guard let composition = result.composition, !composition.preeditText.isEmpty else {
            return false
        }
        guard let raw = result.rawInput, !raw.isEmpty else {
            return false
        }
        guard !result.candidates.isEmpty else {
            return false
        }
        return true
    }

    private func isExactSuccessfulT9Refinement(result: RimeOutput, requestedPath: T9PinyinPath) -> Bool {
        guard isUsableT9SessionOutput(result) else { return false }
        let refinedRaw = result.rawInput ?? ""
        let normalizedResult = T9PinyinPathExtractor.normalizeRawIdentity(refinedRaw)
        let normalizedPath = T9PinyinPathExtractor.normalizeRawIdentity(requestedPath.replacementRawInput)
        return !normalizedResult.isEmpty && normalizedResult == normalizedPath
    }

    private func rollbackT9PinyinRefinement(
        engine: RimeEngine,
        previous: RimeOutput,
        previousRaw: String,
        previousMarked: String,
        previousComposition: String,
        previousPathState: T9PinyinPathState
    ) -> KeyboardEffect {
        let restored = engine.replaceInput(previousRaw)
        let restoredIdentity = T9PinyinPathExtractor.normalizeRawIdentity(restored.rawInput)
        let previousIdentity = T9PinyinPathExtractor.normalizeRawIdentity(previousRaw)
        let rawMatches =
            !restoredIdentity.isEmpty
            && restoredIdentity == previousIdentity
            && (restored.committedText == nil || restored.committedText?.isEmpty == true)

        if rawMatches, isUsableT9SessionOutput(restored) {
            // Live RIME is sole authority; force new provenance snapshot (same raw allowed).
            let previousSelected = previousPathState.selectedPath
            state.lastRimeOutput = restored
            state.currentComposition = previousComposition
            // Rollback restores the exact host-visible marked text from before
            // the failed refinement, not a newly preferred candidate comment.
            updateInlinePreedit(previousMarked)
            clearTypoCorrectionSuggestions()
            _ = refreshT9PinyinPathState(forceNewProvenance: true)
            if previousPathState.retainedChoiceSourceRawInput != nil {
                restoreRetainedChoiceSnapshot(
                    previousPathState,
                    selectedPath: previousSelected
                )
            } else if let previousSelected,
               state.t9PinyinPathState.issuedReplacementKeys
                .contains(previousSelected.replacementRawInput)
            {
                if let live = state.t9PinyinPathState.compactPaths
                    .first(where: { $0.replacementRawInput == previousSelected.replacementRawInput })
                {
                    state.t9PinyinPathState.selectedPath = live
                } else {
                    state.t9PinyinPathState.selectedPath = previousSelected
                }
            } else {
                state.t9PinyinPathState.selectedPath = nil
            }
            return .compositionChanged.union(.t9PinyinPathsChanged)
        }

        if rawMatches, !isUsableT9SessionOutput(restored) {
            engine.resetSession()
            clearInlinePreedit()
            state.currentComposition = ""
            state.lastRimeOutput = nil
            state.partialCommit = nil
            clearTypoCorrectionSuggestions()
            let pathEffect = clearT9PinyinPathStateReturningEffect()
            return .compositionChanged.union(pathEffect)
        }

        engine.resetSession()
        clearInlinePreedit()
        state.currentComposition = ""
        state.lastRimeOutput = nil
        state.partialCommit = nil
        clearTypoCorrectionSuggestions()
        let pathEffect = clearT9PinyinPathStateReturningEffect()
        _ = previous
        return .compositionChanged.union(pathEffect)
    }
}
