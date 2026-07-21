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
        let previousVisibleRemainder = state.partialCommit?.remainingPreeditText
            ?? previousMarked
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
            applySelectedT9PinyinPathDisplay(
                path,
                preservingVisibleRemainder: previousVisibleRemainder
            )

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
        let previousSegmentSource = state.t9PinyinPathState.segmentSourceDigits
        let previousConfirmed = state.t9PinyinPathState.confirmedSegmentValues
        let previousSelected = state.t9PinyinPathState.selectedPath
        let previousCompact = state.t9PinyinPathState.compactPaths
        let previousRetained = state.t9PinyinPathState.retainedChoiceSourceRawInput
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
        let isWholeMultiDigit = pureDigits.count > 1
            && pureDigits.first.map { !T9PinyinPathExtractor.keyLetters(forDigit: $0).isEmpty } == true

        // Nested partial remainder: live raw is a pure-digit suffix of the still-
        // valid composition digit identity (e.g. after selecting 球, raw=`5` while
        // the path-refined identity is still `74853` with confirmed `qiu`). Keep
        // the longer identity so later undo/delete can rebuild first-focus
        // siblings for `748` instead of permanently forgetting them.
        let nestedRemainderSource: String? = {
            guard !pureDigits.isEmpty,
                  let prev = previousSegmentSource,
                  !previousConfirmed.isEmpty
            else { return nil }
            let confirmedLetters = T9PinyinPathExtractor.letterCount(
                ofSyllables: previousConfirmed
            )
            guard confirmedLetters > 0, confirmedLetters < prev.count else { return nil }
            // Live remainder must be a suffix of the unresolved digit tail after
            // confirmed syllables (e.g. confirmed `qiu` on `74853` → tail `53`,
            // nested remainder `5` after selecting 球).
            let unresolvedTail = String(prev.dropFirst(confirmedLetters))
            guard !unresolvedTail.isEmpty,
                  pureDigits.count <= unresolvedTail.count,
                  (unresolvedTail == pureDigits
                    || unresolvedTail.hasPrefix(pureDigits)
                    || unresolvedTail.hasSuffix(pureDigits))
            else { return nil }
            return String(prev.prefix(confirmedLetters)) + pureDigits
        }()

        // Amendment B: whole multi-digit compact bar is progressive first-syllable
        // choices + first key-group letters. Multi-syllable whole comments
        // (e.g. "ni xian zai") must never occupy a single compact label.
        var paths: [T9PinyinPath] = []
        var discoveryNext = 0
        var discoveryMayHaveMore = false
        var segmentSourceDigits: String? = pureDigits.isEmpty ? nil : pureDigits
        var focusedSegmentIndex: Int? = pureDigits.isEmpty ? nil : 0
        var confirmedSegmentValues: [String] = []
        var retainedChoiceSourceRawInput: String? = deterministicPaths.isEmpty ? nil : normalizedRaw
        var selectedPath: T9PinyinPath?

        if let nestedSource = nestedRemainderSource {
            let built = buildProgressiveCompactPaths(
                sourceDigits: nestedSource,
                confirmedSyllables: previousConfirmed,
                evidence: output.candidates,
                preferredSelected: nil
            )
            paths = built.paths
            discoveryNext = built.discoveryNext
            discoveryMayHaveMore = built.discoveryMayHaveMore
            segmentSourceDigits = nestedSource
            focusedSegmentIndex = previousConfirmed.count
            confirmedSegmentValues = previousConfirmed
            selectedPath = nil
            retainedChoiceSourceRawInput = previousRetained
        } else if !deterministicPaths.isEmpty {
            paths = deterministicPaths
            discoveryMayHaveMore = false
            selectedPath = previousSelected.flatMap { selected in
                paths.first { $0.displayText == selected.displayText }
            }
        } else if isWholeMultiDigit {
            let built = buildProgressiveCompactPaths(
                sourceDigits: pureDigits,
                confirmedSyllables: [],
                evidence: output.candidates,
                preferredSelected: previousSelected
            )
            paths = built.paths
            discoveryNext = built.discoveryNext
            discoveryMayHaveMore = built.discoveryMayHaveMore
            selectedPath = built.selectedPath
        } else if let preserved = rebuildSegmentedPathsForMixedRaw(
            raw: normalizedRaw,
            output: output,
            previousSegmentSource: previousSegmentSource,
            previousConfirmed: previousConfirmed,
            previousCompact: previousCompact,
            previousSelected: previousSelected
        ) {
            // Mixed refined raw (`qiu'53` / `qiu53`) must not collapse the Path
            // Bar to a single comment-derived label. Reuse the digit identity
            // that still owns the progressive focus (e.g. 74853 after 偷偷买).
            paths = preserved.paths
            discoveryNext = preserved.discoveryNext
            discoveryMayHaveMore = preserved.discoveryMayHaveMore
            segmentSourceDigits = preserved.segmentSourceDigits
            focusedSegmentIndex = preserved.focusedSegmentIndex
            confirmedSegmentValues = preserved.confirmedSegmentValues
            selectedPath = preserved.selectedPath
            retainedChoiceSourceRawInput = previousRetained
        } else {
            // Non pure multi-digit without a preserved segment source: still
            // comment-derived, but single-syllable labels only.
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
            selectedPath = previousSelected.flatMap { selected in
                issued.contains(selected.replacementRawInput)
                    ? (paths.first { $0.replacementRawInput == selected.replacementRawInput } ?? selected)
                    : paths.first { $0.displayText == selected.displayText }
            }
        }

        for path in paths {
            issued.insert(path.replacementRawInput)
        }
        if !paths.isEmpty, discoveryMayHaveMore {
            discoveryMayHaveMore = discoveryMayHaveMore || discoveryNext > 0
        }

        let newState = T9PinyinPathState(
            compactPaths: paths,
            selectedPath: selectedPath,
            rawInputGeneration: generation,
            provenanceRevision: provenance,
            trackedRawInput: normalizedRaw,
            issuedReplacementKeys: issued,
            discoveryNextIndex: discoveryNext,
            discoveryMayHaveMore: discoveryMayHaveMore,
            retainedChoiceSourceRawInput: retainedChoiceSourceRawInput,
            segmentSourceDigits: segmentSourceDigits,
            focusedSegmentIndex: focusedSegmentIndex,
            confirmedSegmentValues: confirmedSegmentValues
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

    /// Progressive compact paths for one focus: exact syllables first, then the
    /// current key-group letters, capped at `compactLimit`.
    private func buildProgressiveCompactPaths(
        sourceDigits: String,
        confirmedSyllables: [String],
        evidence seedEvidence: [RimeCandidate],
        preferredSelected: T9PinyinPath?
    ) -> (
        paths: [T9PinyinPath],
        discoveryNext: Int,
        discoveryMayHaveMore: Bool,
        selectedPath: T9PinyinPath?
    ) {
        let remainingDigits = String(
            sourceDigits.dropFirst(T9PinyinPathExtractor.letterCount(ofSyllables: confirmedSyllables))
        )
        guard !remainingDigits.isEmpty else {
            return ([], 0, false, nil)
        }

        var evidence = seedEvidence
        var discoveryNext = 0
        var discoveryMayHaveMore = false
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
            sourceDigits: sourceDigits,
            confirmedSyllables: confirmedSyllables,
            limit: T9PinyinPathExtractor.compactLimit
        )
        let firstGroupLetters = remainingDigits.first.map(T9PinyinPathExtractor.keyLetters(forDigit:)) ?? []
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

        let keyGroupPaths: [T9PinyinPath]
        if confirmedSyllables.isEmpty {
            keyGroupPaths = T9PinyinPathExtractor.firstKeyGroupPaths(sourceDigits: sourceDigits)
        } else if let digit = remainingDigits.first {
            let prefix = confirmedSyllables.joined(separator: "'")
            let suffix = String(remainingDigits.dropFirst())
            keyGroupPaths = T9PinyinPathExtractor.keyLetters(forDigit: digit).compactMap { letter in
                let value = String(letter)
                // Prefer exact syllables over redundant single-letter duplicates.
                if syllablePaths.contains(where: { $0.displayText.hasPrefix(value) }) {
                    return nil
                }
                let replacement = prefix + "'" + value + suffix
                return T9PinyinPath(displayText: value, replacementRawInput: replacement)
            }
        } else {
            keyGroupPaths = []
        }

        var merged: [T9PinyinPath] = []
        var seenDisplays = Set<String>()
        for path in syllablePaths + keyGroupPaths {
            guard merged.count < T9PinyinPathExtractor.compactLimit else { break }
            guard seenDisplays.insert(path.displayText).inserted else { continue }
            merged.append(path)
        }

        let selected = preferredSelected.flatMap { selected in
            merged.first { $0.displayText == selected.displayText }
        }
        return (merged, discoveryNext, discoveryMayHaveMore, selected)
    }

    /// When live raw is no longer pure digits (path refine / anchored confirm),
    /// rebuild compact choices from the still-valid digit identity instead of
    /// filtering multi-syllable comments down to a single `qiu` label.
    private func rebuildSegmentedPathsForMixedRaw(
        raw: String,
        output: RimeOutput,
        previousSegmentSource: String?,
        previousConfirmed: [String],
        previousCompact: [T9PinyinPath],
        previousSelected: T9PinyinPath?
    ) -> (
        paths: [T9PinyinPath],
        discoveryNext: Int,
        discoveryMayHaveMore: Bool,
        segmentSourceDigits: String,
        focusedSegmentIndex: Int,
        confirmedSegmentValues: [String],
        selectedPath: T9PinyinPath?
    )? {
        guard let previousSource = previousSegmentSource, !previousSource.isEmpty,
              previousSource.allSatisfy({ $0.isASCII && $0.isNumber })
        else { return nil }

        // Pure letter refined raw (e.g. `qiu` after deleting every trailing slot
        // from `qiu'53`). There is no unresolved next-focus digit left — the
        // Path Bar must show siblings for this syllable's own digit group
        // (`qiu / shu / p / q / r`), not a ghost `j/k/l` leftover from an
        // earlier trailing `5`.
        if raw.unicodeScalars.allSatisfy(T9PinyinPathExtractor.isASCIILetter),
           !raw.isEmpty
        {
            return rebuildLetterOnlySyllableFocusPaths(
                letterRaw: raw.lowercased(),
                previousSource: previousSource,
                evidence: output.candidates,
                previousSelected: previousSelected
            )
        }

        let anchored = T9PinyinPathExtractor.anchoredConfirmedSyllables(fromMixedRaw: raw)
        let confirmed: [String]
        let source: String
        if let anchored, !anchored.confirmed.isEmpty {
            confirmed = anchored.confirmed
            let confirmedLetters = T9PinyinPathExtractor.letterCount(ofSyllables: confirmed)
            guard confirmedLetters <= previousSource.count else { return nil }
            // Keep the digit slots that still map to the confirmed letters, but
            // replace the unresolved tail with the live trailing digits so a
            // Delete that shortens `qiu'53 → qiu'5` does not resurrect dropped slots.
            source = String(previousSource.prefix(confirmedLetters)) + anchored.trailingDigits
        } else {
            confirmed = previousConfirmed
            source = previousSource
        }

        let confirmedLetters = T9PinyinPathExtractor.letterCount(ofSyllables: confirmed)
        guard confirmedLetters <= source.count else { return nil }
        let remainingDigits = String(source.dropFirst(confirmedLetters))

        // Confirmed syllables already consume every live digit slot (no trailing
        // unresolved digits). Rebuild sibling choices for the last complete
        // syllable instead of publishing an empty / ghost next-focus bar.
        if remainingDigits.isEmpty {
            guard let lastSyllable = confirmed.last, !lastSyllable.isEmpty else { return nil }
            let syllableSource = String(previousSource.prefix(confirmedLetters))
            guard !syllableSource.isEmpty else { return nil }
            return rebuildLetterOnlySyllableFocusPaths(
                letterRaw: lastSyllable,
                previousSource: syllableSource,
                evidence: output.candidates,
                previousSelected: previousSelected
                    ?? T9PinyinPath(
                        displayText: lastSyllable,
                        replacementRawInput: lastSyllable
                    )
            )
        }

        // Prefer remapping the previously authorized sibling set when the user
        // is still on the same focus (no new confirmed boundary). That keeps
        // `qiu / shu / p / q / r` after selecting `qiu` when advance has not
        // moved focus yet.
        if confirmed == previousConfirmed, !previousCompact.isEmpty {
            let remappedSnapshot = T9PinyinPathState(
                compactPaths: previousCompact,
                selectedPath: previousSelected,
                segmentSourceDigits: source,
                focusedSegmentIndex: confirmed.count,
                confirmedSegmentValues: confirmed
            )
            let remapped = canonicalFocusedSegmentChoices(from: remappedSnapshot)
            if remapped.count > 1 || (remapped.count == 1 && previousCompact.count == 1) {
                let selected = previousSelected.flatMap { selected in
                    remapped.first { $0.displayText == selected.displayText }
                }
                return (
                    remapped,
                    0,
                    false,
                    source,
                    confirmed.count,
                    confirmed,
                    selected
                )
            }
        }

        let built = buildProgressiveCompactPaths(
            sourceDigits: source,
            confirmedSyllables: confirmed,
            evidence: output.candidates,
            preferredSelected: previousSelected
        )
        guard !built.paths.isEmpty else { return nil }
        return (
            built.paths,
            built.discoveryNext,
            built.discoveryMayHaveMore,
            source,
            confirmed.count,
            confirmed,
            built.selectedPath
        )
    }

    /// First-focus progressive choices for a letter-only refined syllable whose
    /// digit identity is the leading `letterRaw.count` slots of `previousSource`.
    private func rebuildLetterOnlySyllableFocusPaths(
        letterRaw: String,
        previousSource: String,
        evidence seedEvidence: [RimeCandidate],
        previousSelected: T9PinyinPath?
    ) -> (
        paths: [T9PinyinPath],
        discoveryNext: Int,
        discoveryMayHaveMore: Bool,
        segmentSourceDigits: String,
        focusedSegmentIndex: Int,
        confirmedSegmentValues: [String],
        selectedPath: T9PinyinPath?
    )? {
        let letterCount = T9PinyinPathExtractor.asciiLetterCount(in: letterRaw)
        guard letterCount > 0, letterCount <= previousSource.count else { return nil }
        let source = String(previousSource.prefix(letterCount))
        guard source.count == letterCount,
              source.allSatisfy({ $0.isASCII && $0.isNumber })
        else { return nil }

        // Letter-only sessions often lose multi-branch comments (`shu le` is gone
        // after refining to `qiu`). Briefly probe the pure digit identity for this
        // syllable group so the Path Bar regains the same surface as a standalone
        // input of those digits, then restore the letter raw.
        var evidence = seedEvidence
        if let engine = rimeEngine {
            let probe = engine.replaceInput(source)
            if probe.committedText == nil,
               probe.composition?.preeditText.isEmpty == false
            {
                evidence.append(contentsOf: probe.candidates)
                evidence.append(contentsOf: engine.candidateWindow(
                    from: 0,
                    limit: T9PinyinPathExtractor.hotPathWindowLimit
                ).candidates)
            }
            _ = engine.replaceInput(letterRaw)
        }

        let preferred = previousSelected
            ?? T9PinyinPath(displayText: letterRaw, replacementRawInput: letterRaw)
        let built = buildProgressiveCompactPaths(
            sourceDigits: source,
            confirmedSyllables: [],
            evidence: evidence,
            preferredSelected: preferred
        )
        guard !built.paths.isEmpty else { return nil }
        let selected = built.paths.first { $0.displayText == letterRaw }
            ?? built.selectedPath
        return (
            built.paths,
            built.discoveryNext,
            built.discoveryMayHaveMore,
            source,
            0,
            [],
            selected
        )
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
        let previousVisibleRemainder = state.partialCommit?.remainingPreeditText
            ?? previousMarked
        let previousComposition = state.currentComposition
        let previousPathState = state.t9PinyinPathState
        var confirmed = previousPathState.confirmedSegmentValues
        confirmed.append(selected.displayText)
        let nextFocus = confirmed.count
        let confirmedLetters = T9PinyinPathExtractor.letterCount(ofSyllables: confirmed)
        let remainingDigits = String(source.dropFirst(confirmedLetters))
        guard !remainingDigits.isEmpty else { return [] }

        // Preserve the bounded pre-anchor window as supplementary evidence.
        // It may contain a lower-ranked path such as `qiu le` that disappears
        // after the confirmed-prefix boundary reranks the live candidate page.
        // All consumers below still require confirmed-prefix inheritance, so
        // unrelated `tian ...` comments cannot authorize a later focus.
        var preAnchorEvidence: [RimeCandidate] = []
        if state.partialCommit != nil {
            preAnchorEvidence = previousOutput.candidates
            preAnchorEvidence.append(contentsOf: engine.candidateWindow(
                from: 0,
                limit: T9PinyinPathExtractor.panelWindowLimit
            ).candidates)
        }

        // Partial Commit must keep the live RIME session on the same syllable
        // branch the user explicitly confirmed. A mixed raw such as `qiu53`
        // can still be re-segmented by RIME as `tian le`; inserting the
        // apostrophe boundary (`qiu'53`) makes both candidates and marked text
        // inherit the confirmed prefix. If RIME cannot realize that boundary,
        // the whole transition rolls back instead of publishing split state.
        let baseRaw: String
        let baseOutput: RimeOutput
        if state.partialCommit != nil {
            let anchoredRaw = confirmed.joined(separator: "'") + "'" + remainingDigits
            let anchoredOutput = engine.replaceInput(anchoredRaw)
            let anchoredIdentity = T9PinyinPathExtractor.normalizeRawIdentity(anchoredOutput.rawInput)
            let requestedIdentity = T9PinyinPathExtractor.normalizeRawIdentity(anchoredRaw)
            guard isUsableT9SessionOutput(anchoredOutput),
                  anchoredIdentity == requestedIdentity,
                  T9PinyinPathExtractor.pathPreservingConfirmedPrefix(
                    from: anchoredOutput.candidates,
                    confirmedSyllables: confirmed
                  ) != nil
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
            baseRaw = anchoredRaw
            baseOutput = anchoredOutput
        } else {
            baseRaw = previousRaw
            baseOutput = previousOutput
        }

        // Gather live comment evidence under the current refined raw, then
        // restore the exact confirmed-prefix base raw after every probe.
        var evidence = baseOutput.candidates
        let window = engine.candidateWindow(
            from: 0,
            limit: T9PinyinPathExtractor.panelWindowLimit
        )
        evidence.append(contentsOf: window.candidates)
        evidence.append(contentsOf: preAnchorEvidence)

        var authorized = T9PinyinPathExtractor.progressiveSyllablePaths(
            from: evidence,
            sourceDigits: source,
            confirmedSyllables: confirmed,
            limit: T9PinyinPathExtractor.compactLimit
        )

        // Live-probe each syllable path; only exact raw + usable composition survive.
        authorized = authorized.filter { path in
            let probe = engine.replaceInput(path.replacementRawInput)
            defer { _ = engine.replaceInput(baseRaw) }
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
                    syllable: path.displayText,
                    confirmedSyllables: confirmed
                )
                    || T9PinyinPathExtractor.candidateCommentsAuthorizeExactSegment(
                        evidence,
                        segmentIndex: nextFocus,
                        syllable: path.displayText,
                        confirmedSyllables: confirmed
                    )
            }
            return true
        }

        // Amendment F: a sparse/reranked candidate window must not reduce the
        // Path Bar to one complete syllable plus raw key letters. Explore a
        // strictly bounded set of spellings for the unresolved digit prefix
        // and publish only spellings independently proven by the live session.
        // Example: `53` can retain both `ke` and `le` even when `le` is absent
        // from the current page, because `replaceInput("qiu'le")` and its
        // candidate comments authorize it under the confirmed `qiu` prefix.
        if authorized.count < T9PinyinPathExtractor.compactLimit {
            let spellings = T9PinyinPathExtractor.boundedCompleteSyllableSpellings(
                forDigits: remainingDigits
            )
            for spelling in spellings {
                guard authorized.count < T9PinyinPathExtractor.compactLimit else { break }
                guard !authorized.contains(where: { $0.displayText == spelling }) else { continue }
                guard let replacement = T9PinyinPathExtractor.replacementForProgressiveSyllable(
                    displaySyllable: spelling,
                    confirmedSyllables: confirmed,
                    sourceDigits: source
                ) else { continue }

                let requested = T9PinyinPath(
                    displayText: spelling,
                    replacementRawInput: replacement
                )
                let probe = engine.replaceInput(replacement)
                defer { _ = engine.replaceInput(baseRaw) }
                guard isExactSuccessfulT9Refinement(result: probe, requestedPath: requested)
                else { continue }

                let probeEvidence = probe.candidates + engine.candidateWindow(
                    from: 0,
                    limit: T9PinyinPathExtractor.hotPathWindowLimit
                ).candidates
                guard T9PinyinPathExtractor.candidateCommentsAuthorizeExactSegment(
                    probeEvidence,
                    segmentIndex: nextFocus,
                    syllable: spelling,
                    confirmedSyllables: confirmed
                ) else { continue }
                authorized.append(requested)
            }
        }

        // Amendment C: exact syllables remain preferred, but even one exact
        // syllable must not suppress other branches that live RIME can authorize.
        // Fill the remaining compact capacity with current-key-group branches.
        if authorized.count < T9PinyinPathExtractor.compactLimit,
           let nextDigit = remainingDigits.first
        {
            let prefix = confirmed.joined(separator: "'")
            let suffixDigits = String(remainingDigits.dropFirst())
            for letter in T9PinyinPathExtractor.keyLetters(forDigit: nextDigit) {
                let value = String(letter)
                // An exact syllable already gives the user a more precise branch
                // for this initial; avoid redundant `yi / y`-style choices.
                guard !authorized.contains(where: { $0.displayText.hasPrefix(value) })
                else { continue }

                let replacement = prefix + "'" + value + suffixDigits
                let requested = T9PinyinPath(displayText: value, replacementRawInput: replacement)
                let probe = engine.replaceInput(replacement)
                // Every probe is isolated. The final restore below remains the
                // transactional gate for publishing the newly issued choices.
                defer { _ = engine.replaceInput(baseRaw) }
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
                        startingWith: letter,
                        confirmedSyllables: confirmed
                    )
                    || T9PinyinPathExtractor.candidateCommentsAuthorizeSegment(
                        evidence,
                        segmentIndex: nextFocus,
                        startingWith: letter,
                        confirmedSyllables: confirmed
                    )
                guard authorizedByComment else { continue }
                authorized.append(requested)
                if authorized.count >= T9PinyinPathExtractor.compactLimit { break }
            }
        }

        let restored = engine.replaceInput(baseRaw)
        guard !authorized.isEmpty,
              isUsableT9SessionOutput(restored),
              T9PinyinPathExtractor.normalizeRawIdentity(restored.rawInput)
                == T9PinyinPathExtractor.normalizeRawIdentity(baseRaw)
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
        applyConfirmedT9PinyinPrefixDisplay(
            confirmed,
            preservingVisibleRemainder: previousVisibleRemainder
        )
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
    private func applySelectedT9PinyinPathDisplay(
        _ path: T9PinyinPath,
        preservingVisibleRemainder preservedRemainder: String? = nil
    ) {
        let explicitSegments = state.t9PinyinPathState.confirmedSegmentValues + [path.displayText]

        guard let partialCommit = state.partialCommit else {
            let visible = t9DisplayPreservingUnresolvedSuffix(
                explicitSegments: explicitSegments,
                previousVisibleRemainder: preservedRemainder ?? state.insertedPreeditText
            )
            updateInlinePreedit(visible)
            return
        }

        let remainingDisplay = t9DisplayPreservingUnresolvedSuffix(
            explicitSegments: explicitSegments,
            previousVisibleRemainder: preservedRemainder ?? partialCommit.remainingPreeditText
        )
        let displayText = partialCommit.confirmedText + remainingDisplay
        state.partialCommit = PartialCommitState(
            confirmedText: partialCommit.confirmedText,
            remainingRawInput: state.lastRimeOutput?.rawInput
                ?? partialCommit.remainingRawInput,
            remainingPreeditText: remainingDisplay,
            displayText: displayText,
            checkpoint: partialCommit.checkpoint,
            source: partialCommit.source
        )
        updateInlinePreedit(displayText)
    }

    /// Replace only the confirmed segment in marked text. The still-unresolved
    /// suffix belongs to keys the user already entered, so confirming `qiu` in
    /// `qiule` must keep `le` visible rather than truncating the composition or
    /// substituting RIME's newly ranked continuation (`ke`).
    private func applyConfirmedT9PinyinPrefixDisplay(
        _ confirmed: [String],
        preservingVisibleRemainder preservedRemainder: String? = nil
    ) {
        guard let partialCommit = state.partialCommit else {
            let visible = t9DisplayPreservingUnresolvedSuffix(
                explicitSegments: confirmed,
                previousVisibleRemainder: preservedRemainder ?? state.insertedPreeditText
            )
            updateInlinePreedit(visible)
            return
        }

        let remainingDisplay = t9DisplayPreservingUnresolvedSuffix(
            explicitSegments: confirmed,
            previousVisibleRemainder: preservedRemainder ?? partialCommit.remainingPreeditText
        )
        let displayText = partialCommit.confirmedText + remainingDisplay
        state.partialCommit = PartialCommitState(
            confirmedText: partialCommit.confirmedText,
            remainingRawInput: state.lastRimeOutput?.rawInput
                ?? partialCommit.remainingRawInput,
            remainingPreeditText: remainingDisplay,
            displayText: displayText,
            checkpoint: partialCommit.checkpoint,
            source: partialCommit.source
        )
        updateInlinePreedit(displayText)
    }

    /// Projects an explicit segment replacement onto the existing visible T9
    /// spelling. Only the unresolved trailing slots are copied; candidate
    /// predictions never become a new visible suffix here.
    private func t9DisplayPreservingUnresolvedSuffix(
        explicitSegments: [String],
        previousVisibleRemainder: String
    ) -> String {
        let explicitPrefix = explicitSegments.joined()
        guard let sourceDigits = state.t9PinyinPathState.segmentSourceDigits else {
            return explicitPrefix
        }

        let consumedSlots = T9PinyinPathExtractor.letterCount(ofSyllables: explicitSegments)
        let unresolvedSlots = max(0, sourceDigits.count - consumedSlots)
        guard unresolvedSlots > 0 else { return explicitPrefix }

        let previousLetters = previousVisibleRemainder.unicodeScalars.filter(
            T9PinyinPathExtractor.isASCIILetter
        )
        // A shorter display cannot identify which trailing slots are still
        // user-authored. Fail closed to the explicit prefix instead of taking
        // arbitrary letters from that prefix or exposing raw digits.
        guard previousLetters.count >= sourceDigits.count else { return explicitPrefix }

        let suffixScalars = Array(previousLetters.suffix(unresolvedSlots))
        return explicitPrefix + String(String.UnicodeScalarView(suffixScalars))
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
