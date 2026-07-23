import Foundation

extension KeyboardController {
    /// ADR 0023: expanded-panel compatibility surface that **only** re-exports the
    /// current catalog Path snapshot. It must not call `candidateWindow`, parse
    /// comments into new Path authority, or issue comment-only replacements.
    public func t9PinyinPathWindow(
        from globalIndex: Int = 0,
        limit: Int = T9PinyinPathExtractor.panelWindowLimit
    ) -> T9PinyinPathWindow {
        let generation = state.t9PinyinPathState.rawInputGeneration
        let provenance = state.t9PinyinPathState.provenanceRevision
        let compositionRevision = state.compositionRevision
        let catalogPaths = state.t9PinyinPathState.compactPaths
        let safeLimit = max(0, limit)
        let start = max(0, globalIndex)
        let end = min(catalogPaths.count, start + safeLimit)
        let slice = start < end ? Array(catalogPaths[start..<end]) : []
        // Never register additional keys — issuance already happened when the
        // catalog snapshot was published.
        return T9PinyinPathWindow(
            paths: slice,
            nextGlobalIndex: end,
            hasMoreCandidates: false,
            compositionRevision: compositionRevision,
            rawInputGeneration: generation,
            provenanceRevision: provenance
        )
    }

    /// Coherent T9 presentation for the current composition revision.
    public func t9CompositionPresentationSnapshot() -> T9CompositionPresentationSnapshot {
        let pathState = state.t9PinyinPathState
        let source = pathState.segmentSourceDigits ?? ""
        let confirmedLetters = T9PinyinPathExtractor.letterCount(
            ofSyllables: pathState.confirmedSegmentValues
        )
        let visible: String
        if let partial = state.partialCommit {
            visible = partial.displayText
        } else if let output = state.lastRimeOutput,
                  T9CompositionCommitPolicy.isActiveT9Composition(
                    usesT9InputSemantics: usesT9InputSemantics,
                    rawInput: output.rawInput
                  )
        {
            visible = t9VisiblePreedit(for: output)
        } else {
            visible = state.insertedPreeditText
        }
        let output = state.lastRimeOutput
        return T9CompositionPresentationSnapshot(
            revision: state.compositionRevision,
            sourceDigits: source,
            rimeRawInput: output?.rawInput ?? pathState.trackedRawInput,
            focusSlotStart: confirmedLetters,
            focusSlotEnd: source.isEmpty ? 0 : source.count,
            confirmedSyllables: pathState.confirmedSegmentValues,
            lockedLetterPrefix: pathState.lockedLetterPrefix,
            provisionalPathID: pathState.provisionalPathID,
            selectedPathID: pathState.selectedPath?.id,
            paths: pathState.compactPaths,
            candidates: output?.candidates ?? [],
            visiblePreedit: visible,
            candidatePageNumber: output?.candidatePageNumber ?? 0,
            hasMorePages: output?.hasMorePages ?? false,
            compositionPreedit: output?.composition?.preeditText ?? ""
        )
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
        let previousRaw = state.lastRimeOutput?.rawInput
        let effects = handleSelectT9PinyinPath(path, autoAdvance: true)
        #if DEBUG
        if !effects.isEmpty {
            gate5TraceComposition(
                event: .pathSelect,
                previousRaw: previousRaw,
                note: "selectedKind=\(path.kind) selectedLength=\(path.displayText.count)"
            )
        }
        #endif
        return effects
    }

    /// - Parameter autoAdvance: `true` for direct path taps (select ⇒ confirm and
    ///   advance when remaining digits exist for **complete** syllables).
    ///   Letter prefixes never auto-advance. `false` for **选拼音** cycling.
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

        // Stale revision / unauthorized path — fail closed.
        let generation = state.t9PinyinPathState.rawInputGeneration
        let provenance = state.t9PinyinPathState.provenanceRevision
        guard generation > 0, provenance > 0 else { return [] }
        // Authorization is issuance-only. Compatibility alone must never accept a
        // path Core did not publish for this revision.
        let authorized =
            state.t9PinyinPathState.issuedPathIDs.contains(path.id)
            || state.t9PinyinPathState.issuedReplacementKeys.contains(path.replacementRawInput)
        guard authorized else { return [] }
        // Stale-revision fail-closed: UI must re-read the current snapshot after
        // every composition revision. Zero means "legacy unstamped test path" and
        // is accepted only when the replacement key is currently issued.
        if path.compositionRevision != 0,
           path.compositionRevision != state.compositionRevision
        {
            return []
        }

        // Already selected path: second direct tap confirms/advances when allowed.
        if autoAdvance,
           path == state.t9PinyinPathState.selectedPath,
           isFocusedSegmentChoice(path, in: state.t9PinyinPathState),
           canConfirmAndAdvance(path, in: state.t9PinyinPathState)
        {
            return confirmFocusedT9SegmentAndAdvance(
                selected: path,
                from: state.t9PinyinPathState
            )
        }

        let isCurrentFocusedChoice = isFocusedSegmentChoice(
            path,
            in: state.t9PinyinPathState
        )
        if !isCurrentFocusedChoice {
            let compatibilityRaw = state.t9PinyinPathState.retainedChoiceSourceRawInput
                ?? previousRaw
            guard T9PinyinPathExtractor.isCompatible(
                path: path,
                withRawInput: compatibilityRaw
            ) else {
                return []
            }
        }

        // Direct path tap advances when remaining slots exist (complete syllables,
        // or single-digit letter choices in progressive segment mode).
        if autoAdvance,
           isCurrentFocusedChoice,
           canConfirmAndAdvance(path, in: state.t9PinyinPathState)
        {
            return confirmFocusedT9SegmentAndAdvance(
                selected: path,
                from: state.t9PinyinPathState
            )
        }

        let previousMarked = state.insertedPreeditText
        let previousVisibleRemainder = state.partialCommit?.remainingPreeditText
            ?? previousMarked
        let previousComposition = state.currentComposition
        let previousPathState = state.t9PinyinPathState

        let result = engine.replaceInput(path.replacementRawInput)

        if isExactSuccessfulT9Refinement(result: result, requestedPath: path) {
            // Prefix-lock only when the *current focus* still has multiple digits
            // (e.g. `28` → `b`). A single remaining focus digit after prior
            // confirmations (`n` + `4` → `g`) is a segment choice, not a lock.
            let remainingFocusDigits: Int = {
                guard let source = previousPathState.segmentSourceDigits else { return 0 }
                let confirmedLetters = T9PinyinPathExtractor.letterCount(
                    ofSyllables: previousPathState.confirmedSegmentValues
                )
                return max(0, source.count - confirmedLetters)
            }()
            let isMultiDigitPrefixLock =
                path.kind == .letterPrefix && remainingFocusDigits > 1

            // Multi-digit letter prefixes lock the focus spelling (e.g. `28` → `b`).
            // Single-digit m/n/o cycling keeps the full retained sibling set.
            if isMultiDigitPrefixLock {
                var transition = previousPathState
                transition.lockedLetterPrefix = path.displayText
                transition.selectedPath = path
                state.t9PinyinPathState = transition
            } else {
                var transition = previousPathState
                transition.lockedLetterPrefix = nil
                state.t9PinyinPathState = transition
            }

            let retainsSingleDigitChoices = previousPathState.retainedChoiceSourceRawInput != nil
                && previousPathState.compactPaths.contains {
                    $0.displayText == path.displayText
                }
            let retainsSegmentFocus = isFocusedSegmentChoice(path, in: previousPathState)

            applyRimeOutput(augmentRimeOutputIfNeeded(result))

            if isMultiDigitPrefixLock {
                // Prefix selection never advances; rebuild with lock + selected prefix.
                state.t9PinyinPathState.lockedLetterPrefix = path.displayText
                state.t9PinyinPathState.segmentSourceDigits =
                    previousPathState.segmentSourceDigits
                state.t9PinyinPathState.focusedSegmentIndex =
                    previousPathState.focusedSegmentIndex
                state.t9PinyinPathState.confirmedSegmentValues =
                    previousPathState.confirmedSegmentValues
                if let source = state.t9PinyinPathState.segmentSourceDigits {
                    let built = buildProgressiveCompactPaths(
                        sourceDigits: source,
                        confirmedSyllables: state.t9PinyinPathState.confirmedSegmentValues,
                        evidence: state.lastRimeOutput?.candidates ?? [],
                        preferredSelected: path,
                        lockedLetterPrefix: path.displayText
                    )
                    state.t9PinyinPathState.compactPaths = built.paths
                    state.t9PinyinPathState.selectedPath = built.paths.first {
                        $0.kind == .letterPrefix && $0.displayText == path.displayText
                    } ?? path
                    state.t9PinyinPathState.issuedReplacementKeys = Set(
                        built.paths.map(\.replacementRawInput)
                    )
                    state.t9PinyinPathState.issuedPathIDs = Set(built.paths.map(\.id))
                    state.t9PinyinPathState.discoveryMayHaveMore = false
                    state.t9PinyinPathState.provisionalPathID = nil
                }
            } else if retainsSingleDigitChoices {
                restoreRetainedChoiceSnapshot(previousPathState, selectedPath: path)
                state.t9PinyinPathState.lockedLetterPrefix = nil
            } else if retainsSegmentFocus {
                restoreSegmentFocusSnapshot(previousPathState, selectedPath: path)
                state.t9PinyinPathState.lockedLetterPrefix = nil
            } else if state.t9PinyinPathState.issuedReplacementKeys.contains(
                path.replacementRawInput
            ) {
                state.t9PinyinPathState.selectedPath = path
                state.t9PinyinPathState.lockedLetterPrefix = nil
            }

            applySelectedT9PinyinPathDisplay(
                path,
                preservingVisibleRemainder: previousVisibleRemainder
            )

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
        state.t9PinyinPathState = T9PinyinPathState(
            // Empty Path state still belongs to the current composition. Its
            // zero provenance invalidates any panel issued from a live snapshot
            // while keeping repeated clears idempotent.
            compositionRevision: state.compositionRevision
        )
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
            || !state.t9PinyinPathState.issuedPathIDs.isEmpty
            || state.t9PinyinPathState.lockedLetterPrefix != nil
            || state.t9PinyinPathState.provisionalPathID != nil
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
        let previousLockedPrefix = state.t9PinyinPathState.lockedLetterPrefix
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
                  pureDigits.count < unresolvedTail.count,
                  (unresolvedTail.hasPrefix(pureDigits)
                    || unresolvedTail.hasSuffix(pureDigits))
            else { return nil }
            return String(prev.prefix(confirmedLetters)) + pureDigits
        }()

        // Amendment B: whole multi-digit compact bar is progressive first-syllable
        // choices + first key-group letters. Multi-syllable whole comments
        // (e.g. "ni xian zai") must never occupy a single compact label.
        var paths: [T9PinyinPath] = []
        var discoveryNext = 0
        // ADR 0023: Path completeness is local-catalog only; newState always
        // publishes discoveryMayHaveMore=false (no unused local write under -Werror).
        var segmentSourceDigits: String? = pureDigits.isEmpty ? nil : pureDigits
        var focusedSegmentIndex: Int? = pureDigits.isEmpty ? nil : 0
        var confirmedSegmentValues: [String] = []
        var retainedChoiceSourceRawInput: String? = deterministicPaths.isEmpty ? nil : normalizedRaw
        var selectedPath: T9PinyinPath?
        var lockedLetterPrefix: String? = previousLockedPrefix
        // Drop a locked prefix when the raw identity no longer starts with it.
        if let locked = lockedLetterPrefix {
            let letterIdentity = normalizedRaw.filter {
                T9PinyinPathExtractor.isASCIILetter(
                    $0.unicodeScalars.first ?? Unicode.Scalar(0)!
                )
            }
            // Safer: check first letter slot of raw.
            let firstLetter = normalizedRaw.unicodeScalars.first {
                T9PinyinPathExtractor.isASCIILetter($0)
            }.map { Character(T9PinyinPathExtractor.lowercaseASCIILetter($0)) }
            if firstLetter.map(String.init) != locked {
                // Still allow lock when pure digits remain and user just chose prefix
                // (raw may still be digits until replaceInput lands). Keep lock only
                // when raw is pure digits or begins with the locked letter.
                let pure = T9PinyinPathExtractor.pureDigitRaw(normalizedRaw)
                if pure.isEmpty {
                    lockedLetterPrefix = nil
                }
            }
            _ = letterIdentity
        }

        if let nestedSource = nestedRemainderSource {
            lockedLetterPrefix = nil
            let built = buildProgressiveCompactPaths(
                sourceDigits: nestedSource,
                confirmedSyllables: previousConfirmed,
                evidence: output.candidates,
                preferredSelected: nil,
                lockedLetterPrefix: nil
            )
            paths = built.paths
            discoveryNext = built.discoveryNext
            segmentSourceDigits = nestedSource
            focusedSegmentIndex = previousConfirmed.count
            confirmedSegmentValues = previousConfirmed
            selectedPath = nil
            retainedChoiceSourceRawInput = previousRetained
        } else if !deterministicPaths.isEmpty {
            // Single-digit focus: local catalog with key-group order preserved.
            let built = buildProgressiveCompactPaths(
                sourceDigits: pureDigits.isEmpty ? normalizedRaw : pureDigits,
                confirmedSyllables: [],
                evidence: output.candidates,
                preferredSelected: previousSelected,
                lockedLetterPrefix: lockedLetterPrefix
            )
            paths = built.paths.isEmpty ? deterministicPaths : built.paths
            selectedPath = previousSelected.flatMap { selected in
                paths.first { $0.displayText == selected.displayText }
            }
            retainedChoiceSourceRawInput = pureDigits.count == 1 ? normalizedRaw : nil
            segmentSourceDigits = pureDigits.isEmpty ? nil : pureDigits
            focusedSegmentIndex = pureDigits.isEmpty ? nil : 0
        } else if isWholeMultiDigit,
                  !previousConfirmed.isEmpty,
                  let prev = previousSegmentSource,
                  !prev.isEmpty
        {
            // Human C / device: after typo Delete, RIME may re-emit a long pure-digit
            // re-segmentation that is *not* the Core ledger. Never wipe confirmed Path
            // identity from that untrusted resegment. Prefer pureDigits only when it is
            // clearly prev / prev±1 digit; otherwise keep `prev` (append is applied by
            // retainFocused after this refresh).
            let ledger: String
            if pureDigits == prev
                || (pureDigits.hasPrefix(prev) && pureDigits.count == prev.count + 1)
                || (prev.hasPrefix(pureDigits) && prev.count == pureDigits.count + 1)
            {
                ledger = pureDigits
            } else {
                ledger = prev
            }
            let built = buildProgressiveCompactPaths(
                sourceDigits: ledger,
                confirmedSyllables: previousConfirmed,
                evidence: output.candidates,
                preferredSelected: nil,
                lockedLetterPrefix: nil
            )
            paths = built.paths
            discoveryNext = built.discoveryNext
            segmentSourceDigits = ledger
            focusedSegmentIndex = previousConfirmed.count
            confirmedSegmentValues = previousConfirmed
            selectedPath = nil
            retainedChoiceSourceRawInput = previousRetained
            lockedLetterPrefix = nil
        } else if isWholeMultiDigit {
            let built = buildProgressiveCompactPaths(
                sourceDigits: pureDigits,
                confirmedSyllables: [],
                evidence: output.candidates,
                preferredSelected: previousSelected,
                lockedLetterPrefix: lockedLetterPrefix
            )
            paths = built.paths
            discoveryNext = built.discoveryNext
            selectedPath = built.selectedPath
            // Keep locked prefix only while raw still matches the prefix constraint.
            if let locked = lockedLetterPrefix,
               let first = normalizedRaw.unicodeScalars.first(where: {
                   T9PinyinPathExtractor.isASCIILetter($0)
               })
            {
                let letter = Character(T9PinyinPathExtractor.lowercaseASCIILetter(first))
                if String(letter) != locked {
                    lockedLetterPrefix = nil
                }
            }
        } else if let preserved = rebuildSegmentedPathsForMixedRaw(
            raw: normalizedRaw,
            output: output,
            previousSegmentSource: previousSegmentSource,
            previousConfirmed: previousConfirmed,
            previousCompact: previousCompact,
            previousSelected: previousSelected,
            lockedLetterPrefix: lockedLetterPrefix
        ) {
            // Mixed refined raw (`qiu'53` / `b8`) must not collapse the Path
            // Bar to a single comment-derived label. Reuse the digit identity
            // that still owns the progressive focus (e.g. 74853 after 偷偷买).
            paths = preserved.paths
            discoveryNext = preserved.discoveryNext
            segmentSourceDigits = preserved.segmentSourceDigits
            focusedSegmentIndex = preserved.focusedSegmentIndex
            confirmedSegmentValues = preserved.confirmedSegmentValues
            selectedPath = preserved.selectedPath
            retainedChoiceSourceRawInput = previousRetained
            lockedLetterPrefix = preserved.lockedLetterPrefix
        } else {
            // Fallback: derive digit focus identity if possible; else letter-only catalog.
            let focusDigits = pureDigits.isEmpty
                ? T9PinyinPathExtractor.pureDigitRaw(previousSegmentSource)
                : pureDigits
            if !focusDigits.isEmpty {
                let confirmed = previousConfirmed
                let built = buildProgressiveCompactPaths(
                    sourceDigits: previousSegmentSource ?? focusDigits,
                    confirmedSyllables: confirmed,
                    evidence: output.candidates,
                    preferredSelected: previousSelected,
                    lockedLetterPrefix: lockedLetterPrefix
                )
                paths = built.paths
                discoveryNext = 0
                segmentSourceDigits = previousSegmentSource ?? focusDigits
                focusedSegmentIndex = confirmed.count
                confirmedSegmentValues = confirmed
                selectedPath = built.selectedPath
            } else {
                paths = []
                selectedPath = nil
                lockedLetterPrefix = nil
            }
        }

        for path in paths {
            issued.insert(path.replacementRawInput)
        }
        let issuedIDs = Set(paths.map(\.id))
        let provisionalID = selectedPath == nil ? paths.first?.id : nil
        if selectedPath == nil,
           let locked = lockedLetterPrefix,
           let lockedPath = paths.first(where: {
               $0.kind == .letterPrefix && $0.displayText == locked
           })
        {
            selectedPath = lockedPath
        }

        let newState = T9PinyinPathState(
            compactPaths: paths,
            selectedPath: selectedPath,
            compositionRevision: state.compositionRevision,
            rawInputGeneration: generation,
            provenanceRevision: provenance,
            trackedRawInput: normalizedRaw,
            issuedReplacementKeys: issued,
            issuedPathIDs: issuedIDs,
            discoveryNextIndex: discoveryNext,
            discoveryMayHaveMore: false,
            retainedChoiceSourceRawInput: retainedChoiceSourceRawInput,
            segmentSourceDigits: segmentSourceDigits,
            focusedSegmentIndex: focusedSegmentIndex,
            confirmedSegmentValues: confirmedSegmentValues,
            lockedLetterPrefix: lockedLetterPrefix,
            provisionalPathID: provisionalID
        )
        let changed = newState.compactPaths != state.t9PinyinPathState.compactPaths
            || newState.selectedPath != state.t9PinyinPathState.selectedPath
            || newState.compositionRevision
                != state.t9PinyinPathState.compositionRevision
            || newState.rawInputGeneration != previousGeneration
            || newState.provenanceRevision != previousProvenance
            || newState.issuedReplacementKeys != state.t9PinyinPathState.issuedReplacementKeys
            || newState.issuedPathIDs != state.t9PinyinPathState.issuedPathIDs
            || newState.discoveryMayHaveMore != state.t9PinyinPathState.discoveryMayHaveMore
            || newState.retainedChoiceSourceRawInput
                != state.t9PinyinPathState.retainedChoiceSourceRawInput
            || newState.segmentSourceDigits != state.t9PinyinPathState.segmentSourceDigits
            || newState.focusedSegmentIndex != state.t9PinyinPathState.focusedSegmentIndex
            || newState.confirmedSegmentValues != state.t9PinyinPathState.confirmedSegmentValues
            || newState.lockedLetterPrefix != state.t9PinyinPathState.lockedLetterPrefix
            || newState.provisionalPathID != state.t9PinyinPathState.provisionalPathID
        state.t9PinyinPathState = newState
        return changed
    }

    /// Progressive paths for one focus from the local syllable catalog (ADR 0023).
    /// RIME candidates supply ranking hints only — never Path legality.
    /// No `candidateWindow` / spelling probe on this path.
    private func buildProgressiveCompactPaths(
        sourceDigits: String,
        confirmedSyllables: [String],
        evidence seedEvidence: [RimeCandidate],
        preferredSelected: T9PinyinPath?,
        lockedLetterPrefix: String? = nil
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

        let hints = T9PinyinLocalPathCatalog.commentSyllableHints(
            from: seedEvidence,
            confirmedSyllables: confirmedSyllables
        )
        let merged = T9PinyinLocalPathCatalog.pathsForFocus(
            focusDigits: remainingDigits,
            lockedLetterPrefix: lockedLetterPrefix,
            commentSyllableHints: hints,
            confirmedSyllables: confirmedSyllables,
            sourceDigits: sourceDigits,
            compositionRevision: state.compositionRevision
        )

        let selected = preferredSelected.flatMap { selected in
            merged.first {
                $0.displayText == selected.displayText && $0.kind == selected.kind
            } ?? merged.first { $0.displayText == selected.displayText }
        }
        // Path completeness is local-catalog only; never claim later candidate pages
        // as Path discovery authority.
        return (merged, 0, false, selected)
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
        previousSelected: T9PinyinPath?,
        lockedLetterPrefix: String?
    ) -> (
        paths: [T9PinyinPath],
        discoveryNext: Int,
        discoveryMayHaveMore: Bool,
        segmentSourceDigits: String,
        focusedSegmentIndex: Int,
        confirmedSegmentValues: [String],
        selectedPath: T9PinyinPath?,
        lockedLetterPrefix: String?
    )? {
        guard let previousSource = previousSegmentSource, !previousSource.isEmpty,
              previousSource.allSatisfy({ $0.isASCII && $0.isNumber })
        else { return nil }

        // Letter-prefix refine such as `b8` / `b'8`: keep focus, locked prefix.
        if let locked = lockedLetterPrefix,
           let first = raw.unicodeScalars.first(where: T9PinyinPathExtractor.isASCIILetter)
        {
            let letter = Character(T9PinyinPathExtractor.lowercaseASCIILetter(first))
            if String(letter) == locked {
                let confirmed = previousConfirmed
                let built = buildProgressiveCompactPaths(
                    sourceDigits: previousSource,
                    confirmedSyllables: confirmed,
                    evidence: output.candidates,
                    preferredSelected: previousSelected,
                    lockedLetterPrefix: locked
                )
                guard !built.paths.isEmpty else { return nil }
                let selected = built.paths.first {
                    $0.kind == .letterPrefix && $0.displayText == locked
                } ?? built.selectedPath
                return (
                    built.paths,
                    0,
                    false,
                    previousSource,
                    confirmed.count,
                    confirmed,
                    selected,
                    locked
                )
            }
        }

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
                previousCompact: previousCompact,
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
        // Never invent a preferred selection from `lastSyllable` — that auto-
        // highlights chips after Delete (Human: qi selected without user tap).
        if remainingDigits.isEmpty {
            guard let lastSyllable = confirmed.last, !lastSyllable.isEmpty else { return nil }
            let syllableSource = String(previousSource.prefix(confirmedLetters))
            guard !syllableSource.isEmpty else { return nil }
            return rebuildLetterOnlySyllableFocusPaths(
                letterRaw: lastSyllable,
                previousSource: syllableSource,
                evidence: output.candidates,
                previousCompact: previousCompact,
                previousSelected: previousSelected
            )
        }

        // Prefer remapping the previously authorized sibling set when the user
        // is still on the same focus (no new confirmed boundary). That keeps
        // `qiu / shu / p / q / r` after selecting `qiu` when advance has not
        // moved focus yet.
        if confirmed == previousConfirmed, !previousCompact.isEmpty, lockedLetterPrefix == nil {
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
                    selected,
                    nil
                )
            }
        }

        let built = buildProgressiveCompactPaths(
            sourceDigits: source,
            confirmedSyllables: confirmed,
            evidence: output.candidates,
            preferredSelected: previousSelected,
            lockedLetterPrefix: lockedLetterPrefix
        )
        guard !built.paths.isEmpty else { return nil }
        return (
            built.paths,
            built.discoveryNext,
            built.discoveryMayHaveMore,
            source,
            confirmed.count,
            confirmed,
            built.selectedPath,
            lockedLetterPrefix
        )
    }

    /// First-focus progressive choices for a letter-only refined syllable whose
    /// digit identity is the leading `letterRaw.count` slots of `previousSource`.
    ///
    /// Selection is preserved only when the user already had an explicit
    /// `previousSelected` that still maps onto the rebuilt set. Letter raw alone
    /// (e.g. engine/`replaceInput("qi")` after Delete) must **not** auto-select.
    private func rebuildLetterOnlySyllableFocusPaths(
        letterRaw: String,
        previousSource: String,
        evidence seedEvidence: [RimeCandidate],
        previousCompact: [T9PinyinPath],
        previousSelected: T9PinyinPath?
    ) -> (
        paths: [T9PinyinPath],
        discoveryNext: Int,
        discoveryMayHaveMore: Bool,
        segmentSourceDigits: String,
        focusedSegmentIndex: Int,
        confirmedSegmentValues: [String],
        selectedPath: T9PinyinPath?,
        lockedLetterPrefix: String?
    )? {
        let letterCount = T9PinyinPathExtractor.asciiLetterCount(in: letterRaw)
        guard letterCount > 0, letterCount <= previousSource.count else { return nil }
        let source = String(previousSource.prefix(letterCount))
        guard source.count == letterCount,
              source.allSatisfy({ $0.isASCII && $0.isNumber })
        else { return nil }

        let built = buildProgressiveCompactPaths(
            sourceDigits: source,
            confirmedSyllables: [],
            evidence: seedEvidence,
            preferredSelected: previousSelected,
            lockedLetterPrefix: nil
        )
        // The previous compact choices were already issued for this digit
        // identity. Reuse them as transition input instead of mutating the live
        // session back to pure digits and restoring it.
        let previousSnapshot = T9PinyinPathState(
            compactPaths: previousCompact,
            selectedPath: previousSelected,
            segmentSourceDigits: source,
            focusedSegmentIndex: 0
        )
        let remapped = canonicalFocusedSegmentChoices(from: previousSnapshot)
        var paths = built.paths
        var seen = Set(paths.map(\.displayText))
        for path in remapped {
            if seen.insert(path.displayText).inserted {
                paths.append(path)
            }
        }
        guard !paths.isEmpty else { return nil }
        // Only remap a user-owned selection. Do not treat engine letter raw as selected.
        let selected = previousSelected.flatMap { sel in
            paths.first { $0.displayText == sel.displayText && $0.kind == sel.kind }
                ?? paths.first { $0.displayText == sel.displayText }
        }
        return (
            paths,
            built.discoveryNext,
            built.discoveryMayHaveMore,
            source,
            0,
            [],
            selected,
            nil
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
        let restamped = restampPaths(snapshot.compactPaths)
        state.t9PinyinPathState.compactPaths = restamped
        state.t9PinyinPathState.selectedPath = selectedPath.flatMap { selected in
            restamped.first { $0.displayText == selected.displayText && $0.kind == selected.kind }
                ?? restamped.first { $0.displayText == selected.displayText }
        }
        state.t9PinyinPathState.issuedReplacementKeys = Set(
            restamped.map(\.replacementRawInput)
        )
        state.t9PinyinPathState.issuedPathIDs = Set(restamped.map(\.id))
        state.t9PinyinPathState.discoveryNextIndex = 0
        state.t9PinyinPathState.discoveryMayHaveMore = false
        state.t9PinyinPathState.retainedChoiceSourceRawInput =
            snapshot.retainedChoiceSourceRawInput
        state.t9PinyinPathState.segmentSourceDigits = snapshot.segmentSourceDigits
        state.t9PinyinPathState.focusedSegmentIndex = snapshot.focusedSegmentIndex
        state.t9PinyinPathState.confirmedSegmentValues = snapshot.confirmedSegmentValues
        state.t9PinyinPathState.lockedLetterPrefix = snapshot.lockedLetterPrefix
        state.t9PinyinPathState.provisionalPathID = state.t9PinyinPathState.selectedPath == nil
            ? restamped.first?.id
            : nil
        state.t9PinyinPathState.compositionRevision = state.compositionRevision
    }

    /// Preserve the focused key group while its full replacement raw changes.
    /// Whole-composition paths are intentionally dropped once a segment choice
    /// becomes tentative; only sibling choices for the current focus remain.
    private func restoreSegmentFocusSnapshot(
        _ snapshot: T9PinyinPathState,
        selectedPath: T9PinyinPath?
    ) {
        let choices = restampPaths(focusedSegmentChoices(from: snapshot))
        guard !choices.isEmpty else { return }
        state.t9PinyinPathState.compactPaths = choices
        state.t9PinyinPathState.selectedPath = selectedPath.flatMap { selected in
            choices.first { $0.displayText == selected.displayText && $0.kind == selected.kind }
                ?? choices.first { $0.displayText == selected.displayText }
        }
        state.t9PinyinPathState.issuedReplacementKeys = Set(
            choices.map(\.replacementRawInput)
        )
        state.t9PinyinPathState.issuedPathIDs = Set(choices.map(\.id))
        state.t9PinyinPathState.discoveryNextIndex = 0
        state.t9PinyinPathState.discoveryMayHaveMore = false
        state.t9PinyinPathState.retainedChoiceSourceRawInput =
            snapshot.retainedChoiceSourceRawInput
        state.t9PinyinPathState.segmentSourceDigits = snapshot.segmentSourceDigits
        state.t9PinyinPathState.focusedSegmentIndex = snapshot.focusedSegmentIndex
        state.t9PinyinPathState.confirmedSegmentValues = snapshot.confirmedSegmentValues
        state.t9PinyinPathState.lockedLetterPrefix = snapshot.lockedLetterPrefix
        state.t9PinyinPathState.provisionalPathID = state.t9PinyinPathState.selectedPath == nil
            ? choices.first?.id
            : nil
        state.t9PinyinPathState.compositionRevision = state.compositionRevision
    }

    /// Restamps path compositionRevision to the live controller revision so
    /// post-restore selections pass the Core stale-revision guard.
    private func restampPaths(_ paths: [T9PinyinPath]) -> [T9PinyinPath] {
        let revision = state.compositionRevision
        return paths.map { path in
            T9PinyinPath(
                kind: path.kind,
                consumedSlotCount: path.consumedSlotCount,
                displayText: path.displayText,
                replacementRawInput: path.replacementRawInput,
                compositionRevision: revision,
                focusSlotStart: path.focusSlotStart,
                focusSlotEnd: path.focusSlotEnd
            )
        }
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
              var identity = T9CompositionIdentity.from(pathState: snapshot),
              let appended = identity.appendingDigit(digit)
        else { return false }
        identity = appended

        // With a selected focused choice: keep it if still authorized on the extended source.
        if let selected = snapshot.selectedPath,
           isFocusedSegmentChoice(selected, in: snapshot)
        {
            var extended = snapshot
            extended.segmentSourceDigits = identity.sourceDigits
            extended.confirmedSegmentValues = identity.confirmedSyllables
            extended.focusedSegmentIndex = identity.focusedSegmentIndex
            extended.retainedChoiceSourceRawInput = nil
            let previouslyAuthorizedValues = Set(snapshot.compactPaths.map(\.displayText))
            extended.compactPaths = canonicalFocusedSegmentChoices(from: extended).filter {
                previouslyAuthorizedValues.contains($0.displayText)
            }
            extended.issuedReplacementKeys = Set(extended.compactPaths.map(\.replacementRawInput))
            guard let remappedSelection = extended.compactPaths.first(where: {
                $0.displayText == selected.displayText
            }) else {
                // Selected label invalid after append — still advance source identity.
                installIdentityAsPathState(identity)
                _ = resyncRimeCompositionFromT9Identity()
                return true
            }
            restoreSegmentFocusSnapshot(extended, selectedPath: remappedSelection)
            return true
        }

        // Confirmed Path: advance sourceDigits and rebuild focus from Core identity.
        if !snapshot.confirmedSegmentValues.isEmpty {
            installIdentityAsPathState(identity)
            _ = resyncRimeCompositionFromT9Identity()
            return true
        }

        // Human retest #5–#6 / provisional-only C: Core `sourceDigits` is Path ledger
        // SoT. processKey already advanced live raw — rebuild Path only. Do **not**
        // force letter-form resync on pure progressive digits (`64` → `ni`); that
        // rewrites progressive raw. When engine raw drifted to mixed/refined
        // (device: `qing wei fan fa` after Delete), re-drive pure digits and refresh
        // host so continue cannot leave fan-fan / ghost morphology on marked text.
        guard identity.confirmedSyllables.isEmpty,
              identity.sourceDigits.count > 1
        else { return false }
        installIdentityAsPathState(identity)
        let liveRaw = state.lastRimeOutput?.rawInput ?? ""
        let pureLive = !liveRaw.isEmpty && liveRaw.allSatisfy(\.isNumber)
        // Only re-drive RIME when the engine raw drifted off the Core digit ledger
        // (ghost-typo / mixed-raw recovery). Prefer pure digits, not first-path letter.
        if !pureLive || liveRaw != identity.sourceDigits {
            let preserved = state.t9PinyinPathState
            if let engine = rimeEngine {
                let digits = identity.sourceDigits
                let output = engine.replaceInput(digits)
                state.lastRimeOutput = output
                state.currentComposition = digits
                state.t9PinyinPathState = preserved
                refreshHostAfterProvisionalPureDigitLedgerResync(digits: digits, output: output)
            }
        }
        return true
    }

    /// Host preedit after provisional-only resync onto pure-digit Core ledger.
    ///
    /// Prefer progressive local-catalog letters (no comment resegmentation) so a
    /// mixed-raw typo morphology (`qing wei fan fan`) cannot stick on the host
    /// after Delete/continue. Fall back to safe t9VisiblePreedit when needed.
    private func refreshHostAfterProvisionalPureDigitLedgerResync(
        digits: String,
        output: RimeOutput
    ) {
        // Ignore engine comment hints here — they often carry the failed mixed
        // morphology that we just peeled off the digit ledger.
        let progressive = progressiveCatalogLetters(
            forRemainingDigits: digits,
            confirmedSyllables: [],
            sourceDigits: digits,
            useCommentHints: false
        )
        if !progressive.isEmpty,
           !progressive.unicodeScalars.contains(where: T9PinyinPathExtractor.isASCIIDigit)
        {
            updateInlinePreedit(progressive, source: .compositionProjection)
            return
        }
        let projected = t9VisiblePreedit(for: output)
        if !projected.isEmpty,
           !projected.unicodeScalars.contains(where: T9PinyinPathExtractor.isASCIIDigit)
        {
            updateInlinePreedit(projected, source: .compositionProjection)
        }
    }

    /// Delete one real digit slot from Core-owned T9 identity.
    ///
    /// Human Gate 2026-07-23: after Path selects `qing/wei`, Delete could stick at
    /// letter morphologies like `qingweie` when only `engine.deleteBackward` ran.
    /// Core peels `sourceDigits` first, then resyncs RIME.
    ///
    /// Human retest #5–#6: peel **any unconfirmed multi-digit** progressive
    /// composition (`sourceDigits.count > 1`), including short `da`→JKL→删→MNO,
    /// so Path ledger matches host/`dao` candidates. Single-digit stays elsewhere.
    func handleT9CompositionIdentityDeleteIfNeeded(
        using engine: RimeEngine
    ) -> KeyboardEffect? {
        guard usesT9InputSemantics,
              state.partialCommit == nil,
              var identity = T9CompositionIdentity.from(pathState: state.t9PinyinPathState),
              (!identity.confirmedSyllables.isEmpty || identity.sourceDigits.count > 1)
        else { return nil }

        let previousRaw = state.lastRimeOutput?.rawInput
        guard let deleted = identity.deletingLastDigit() else {
            engine.resetSession()
            state.currentComposition = ""
            state.lastRimeOutput = nil
            state.partialCommit = nil
            clearInlinePreedit()
            clearTypoCorrectionSuggestions()
            #if DEBUG
            gate5TraceComposition(
                event: .deleteBackward,
                previousRaw: previousRaw,
                note: "branch=identityDelete emptied=true"
            )
            #endif
            return .compositionChanged.union(clearT9PinyinPathStateReturningEffect())
        }

        identity = deleted
        let previousSelectedLabel = state.t9PinyinPathState.selectedPath?.displayText
            ?? {
                // Letter-only refined raw (e.g. `n` after cycling on key 6).
                guard let previousRaw,
                      previousRaw.unicodeScalars.allSatisfy(T9PinyinPathExtractor.isASCIILetter),
                      previousRaw.count == 1
                else { return nil as String? }
                return previousRaw.lowercased()
            }()

        // Never keep a stale selected Path chip after identity peel (Human: qing
        // appeared selected after deleting back to a single confirmed syllable)
        // unless we re-map it below for single-key letter cycling.
        installIdentityAsPathState(identity)
        var pathState = state.t9PinyinPathState
        pathState.selectedPath = nil
        state.t9PinyinPathState = pathState

        // Confirmed Path: full identity resync (letter-refined remaining as needed).
        // Unconfirmed short peel (≤3): letter-aware resync so `qin`/`qi` candidates
        // are not bare-digit 手/瘦; remap prior m/n/o selection when still issued.
        // Unconfirmed long peel (>3): pure-digit ledger only (ghost-typo recovery).
        if !identity.confirmedSyllables.isEmpty {
            _ = resyncRimeCompositionFromT9Identity()
        } else if identity.sourceDigits.count <= 3 {
            _ = resyncRimeCompositionFromT9Identity()
            if let label = previousSelectedLabel,
               let remapped = state.t9PinyinPathState.compactPaths.first(where: {
                   $0.displayText == label
               }),
               let engine = rimeEngine
            {
                var preserved = state.t9PinyinPathState
                preserved.selectedPath = remapped
                preserved.provisionalPathID = nil
                state.t9PinyinPathState = preserved
                let refined = engine.replaceInput(label)
                if refined.composition != nil,
                   (refined.rawInput == label || isUsableT9SessionOutput(refined))
                {
                    state.lastRimeOutput = refined
                    state.currentComposition = label
                    applySelectedT9PinyinPathDisplay(remapped)
                }
            }
        } else if let engine = rimeEngine {
            let digits = identity.sourceDigits
            let output = engine.replaceInput(digits)
            let preserved = state.t9PinyinPathState
            state.lastRimeOutput = output
            state.currentComposition = digits
            state.t9PinyinPathState = preserved
            refreshHostAfterProvisionalPureDigitLedgerResync(digits: digits, output: output)
        }
        clearTypoCorrectionSuggestions()
        #if DEBUG
        gate5TraceComposition(
            event: .deleteBackward,
            previousRaw: previousRaw,
            note: "branch=identityDelete success=true confCount=\(identity.confirmedSyllables.count)"
        )
        #endif
        return .compositionChanged.union(.t9PinyinPathsChanged)
    }

    /// Reverse the most recent pending digit/focus transition after RIME has
    /// already deleted one raw unit. Uses `T9CompositionIdentity` (β-limited)
    /// instead of letter-budget heuristics alone.
    @discardableResult
    func restoreFocusedT9SegmentAfterDeletion(
        previous snapshot: T9PinyinPathState
    ) -> Bool {
        guard var identity = T9CompositionIdentity.from(pathState: snapshot),
              let deleted = identity.deletingLastDigit()
        else { return false }

        identity = deleted
        var restored = snapshot
        restored.segmentSourceDigits = identity.sourceDigits
        restored.confirmedSegmentValues = identity.confirmedSyllables
        restored.focusedSegmentIndex = identity.focusedSegmentIndex
        restored.retainedChoiceSourceRawInput = nil
        let selectedValue = snapshot.selectedPath?.displayText

        // Prefer remapping previously authorized labels; if the focus emptied,
        // fall back to first-key-group letters for multi-digit whole mode.
        var remapped = canonicalFocusedSegmentChoices(from: restored)
        if remapped.isEmpty, identity.confirmedSyllables.isEmpty, identity.sourceDigits.count > 1 {
            remapped = T9PinyinPathExtractor.firstKeyGroupPaths(sourceDigits: identity.sourceDigits)
        } else if remapped.isEmpty, identity.confirmedSyllables.isEmpty, identity.sourceDigits.count == 1 {
            remapped = T9PinyinPathExtractor.deterministicSingleDigitPaths(
                rawInput: identity.sourceDigits
            )
        }
        restored.compactPaths = remapped
        restored.issuedReplacementKeys = Set(remapped.map(\.replacementRawInput))
        restored.issuedPathIDs = Set(remapped.map(\.id))
        restored.provisionalPathID = remapped.first?.id

        if let selectedValue,
           let selected = remapped.first(where: { $0.displayText == selectedValue })
        {
            restoreSegmentFocusSnapshot(restored, selectedPath: selected)
            applySelectedT9PinyinPathDisplay(selected)
            if !identity.confirmedSyllables.isEmpty {
                _ = resyncRimeCompositionFromT9Identity()
            }
        } else {
            guard !remapped.isEmpty || !identity.confirmedSyllables.isEmpty else { return false }
            restoreSegmentFocusSnapshot(restored, selectedPath: nil)
            // Re-sync RIME only when Path has confirmed syllables (Core is SoT).
            // Provisional-only multi-digit stays on engine output to avoid digit host leak.
            if !identity.confirmedSyllables.isEmpty {
                _ = resyncRimeCompositionFromT9Identity()
            }
        }
        return true
    }

    /// Rebuild librime composition from Core-owned digit + confirmed Path identity.
    /// Prevents host-visible fan-fan morphology after typo Delete when the engine
    /// returns a re-segmented pure-digit comment that disagrees with Path state.
    ///
    /// Human 2026-07-23: when peeling to pure digits only, prefer the provisional
    /// catalog letter raw (e.g. `qin`) over bare `746`, otherwise candidates become
    /// 手/瘦 (shou) while Path correctly lists qin/pin.
    @discardableResult
    func resyncRimeCompositionFromT9Identity() -> Bool {
        guard usesT9InputSemantics,
              let identity = T9CompositionIdentity.from(pathState: state.t9PinyinPathState),
              let engine = rimeEngine
        else { return false }

        // Rebuild Path first so provisional letter paths exist for RIME raw choice.
        installIdentityAsPathState(identity)
        var pathState = state.t9PinyinPathState
        pathState.selectedPath = nil
        pathState.lockedLetterPrefix = nil
        state.t9PinyinPathState = pathState

        let plan = identity.focusPathPlan()
        let raw: String
        if !plan.pathConfirmedSyllables.isEmpty {
            let rem = plan.focusDigits
            if rem.isEmpty {
                raw = plan.pathConfirmedSyllables.joined(separator: "'")
            } else if let refocus = plan.refocusedSyllable,
                      plan.focusDigits.count == T9PinyinPathExtractor.asciiLetterCount(in: refocus)
            {
                // Re-focusing last syllable: confirm prefix + letter form of last
                // when we have a catalog path; else prefix + digit tail.
                let focusLetter = state.t9PinyinPathState.compactPaths
                    .first(where: { $0.displayText == refocus })?
                    .displayText
                    ?? state.t9PinyinPathState.compactPaths.first?.displayText
                if let focusLetter,
                   !focusLetter.isEmpty,
                   focusLetter.unicodeScalars.allSatisfy(T9PinyinPathExtractor.isASCIILetter)
                {
                    raw = (plan.pathConfirmedSyllables + [focusLetter]).joined(separator: "'")
                } else {
                    raw = plan.pathConfirmedSyllables.joined(separator: "'") + "'" + rem
                }
            } else {
                // Human: remaining focus must match standalone short-composition
                // behavior (da + typo + Delete + o → dao). Letterize remaining only
                // when a **unique** complete covers the whole remaining run.
                raw = refinedConfirmedPlusRemainingRaw(
                    confirmed: plan.pathConfirmedSyllables,
                    remainingDigits: rem,
                    focusPaths: state.t9PinyinPathState.compactPaths
                )
            }
        } else if identity.sourceDigits.count <= 3 {
            // Short unconfirmed (qi / da / dao / to):
            // - **first** complete covering all slots → letter raw (`to`, sole `da`)
            // - no full complete → pure digits (Path stays on ledger length)
            // Ambiguous multi-complete on *confirmed+remaining* uses unique-only above.
            // Never use letterPrefix replacement like `t6` as the whole raw.
            raw = shortUnconfirmedResyncRaw(
                sourceDigits: identity.sourceDigits,
                focusPaths: state.t9PinyinPathState.compactPaths
            )
        } else {
            // Human C: after Delete, longer unconfirmed compositions return to pure
            // digit input mode so retyping matches first-entry Path discovery.
            // Letter-refined provisional raw (qing934…) can lock a wrong morphology
            // and discard the unresolved tail when the user continues typing.
            raw = identity.sourceDigits
        }
        guard !raw.isEmpty else { return false }
        let output = engine.replaceInput(raw)
        // Keep Path identity; do not let applyRimeOutput wipe conf via resegment.
        let preserved = state.t9PinyinPathState
        state.lastRimeOutput = output
        state.currentComposition = raw
        state.t9PinyinPathState = preserved

        let projected = t9VisiblePreedit(for: output)
        let hostText: String
        if !projected.isEmpty,
           !projected.unicodeScalars.contains(where: T9PinyinPathExtractor.isASCIIDigit)
        {
            hostText = projected
        } else {
            let labels = plan.pathConfirmedSyllables
            let focusLabel = plan.refocusedSyllable
                ?? state.t9PinyinPathState.compactPaths.first?.displayText
            if let focusLabel, !focusLabel.isEmpty {
                hostText = (labels + [focusLabel]).joined(separator: " ")
            } else if !labels.isEmpty {
                hostText = labels.joined(separator: " ")
            } else {
                hostText = projected
            }
        }
        if !hostText.isEmpty,
           !hostText.unicodeScalars.contains(where: T9PinyinPathExtractor.isASCIIDigit)
        {
            updateInlinePreedit(hostText, source: .compositionProjection)
        }
        return true
    }

    private func canConfirmAndAdvance(
        _ path: T9PinyinPath,
        in snapshot: T9PinyinPathState
    ) -> Bool {
        // PD-004 / ADR 0023: letter prefixes only lock spelling; they never
        // confirm or advance. Only catalog-legal complete syllables advance
        // (single-digit key groups classify via catalog membership).
        guard path.kind == .completeSyllable else { return false }
        guard let source = snapshot.segmentSourceDigits else { return false }
        return T9PinyinPathExtractor.canAdvanceAfterConfirming(
            selectedDisplay: path.displayText,
            confirmedSyllables: snapshot.confirmedSegmentValues,
            sourceDigits: source
        )
    }

    private func confirmFocusedT9SegmentAndAdvance(
        selected: T9PinyinPath,
        from previousPathState: T9PinyinPathState
    ) -> KeyboardEffect {
        guard let engine = rimeEngine,
              let previousOutput = state.lastRimeOutput,
              let previousRaw = previousOutput.rawInput,
              let source = previousPathState.segmentSourceDigits,
              previousPathState.focusedSegmentIndex != nil,
              canConfirmAndAdvance(selected, in: previousPathState)
        else { return [] }

        let previousMarked = state.insertedPreeditText
        let previousVisibleRemainder = state.partialCommit?.remainingPreeditText
            ?? previousMarked
        let previousComposition = state.currentComposition
        var confirmed = previousPathState.confirmedSegmentValues
        confirmed.append(selected.displayText)
        let nextFocus = confirmed.count
        let confirmedLetters = T9PinyinPathExtractor.letterCount(ofSyllables: confirmed)
        let remainingDigits = String(source.dropFirst(confirmedLetters))
        guard !remainingDigits.isEmpty else { return [] }

        // Confirming a segment changes the live raw at most once. A partial
        // composition receives an explicit apostrophe boundary (`qiu'53`);
        // otherwise the Core-issued replacement (`ni94` / `n'g5`) is already exact.
        // Remaining focus prefers letter form when a complete path covers it
        // (standalone da parity inside a multi-syllable sentence).
        let needsExplicitTrailingBoundary = state.partialCommit != nil
            || !previousPathState.confirmedSegmentValues.isEmpty
        let focusPathsForRemaining = T9PinyinLocalPathCatalog.pathsForFocus(
            focusDigits: remainingDigits,
            lockedLetterPrefix: nil,
            commentSyllableHints: T9PinyinLocalPathCatalog.commentSyllableHints(
                from: previousOutput.candidates,
                confirmedSyllables: confirmed
            ),
            confirmedSyllables: confirmed,
            sourceDigits: source,
            compositionRevision: state.compositionRevision
        )
        let boundaryRaw = refinedConfirmedPlusRemainingRaw(
            confirmed: confirmed,
            remainingDigits: remainingDigits,
            focusPaths: focusPathsForRemaining
        )
        let requestedRaw: String
        if needsExplicitTrailingBoundary {
            // Prefer a Core-issued replacement only when it already contains the
            // apostrophe boundary form (e.g. `n'g5`, `qing'wei'…`). Bare letter+digit
            // concatenations like `qiu53` must become `qiu'53` under partial commit
            // so the confirmed syllable stays anchored.
            if selected.replacementRawInput.contains("'"),
               selected.replacementRawInput.hasSuffix(remainingDigits)
            {
                requestedRaw = selected.replacementRawInput
            } else {
                requestedRaw = boundaryRaw
            }
        } else {
            requestedRaw = selected.replacementRawInput
        }
        let requestedPath = T9PinyinPath(
            displayText: selected.displayText,
            replacementRawInput: requestedRaw
        )
        let currentIdentity = T9PinyinPathExtractor.normalizeRawIdentity(previousRaw)
        let requestedIdentity = T9PinyinPathExtractor.normalizeRawIdentity(requestedRaw)
        let refinedOutput = currentIdentity == requestedIdentity
            ? previousOutput
            : engine.replaceInput(requestedRaw)
        guard isExactSuccessfulT9Refinement(
            result: refinedOutput,
            requestedPath: requestedPath
        )
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

        // Seed the new segment identity before installing the RIME output. The
        // output installer performs exactly one fixed-window discovery and
        // publishes candidates + paths from that same live revision.
        var transitionPathState = previousPathState
        // This action advances focus, so old sibling choices must not satisfy the
        // same-confirmed remap shortcut during output installation.
        transitionPathState.compactPaths = []
        transitionPathState.selectedPath = nil
        transitionPathState.issuedReplacementKeys = []
        transitionPathState.segmentSourceDigits = source
        transitionPathState.confirmedSegmentValues = confirmed
        transitionPathState.focusedSegmentIndex = nextFocus
        state.t9PinyinPathState = transitionPathState
        applyRimeOutput(augmentRimeOutputIfNeeded(refinedOutput))

        state.t9PinyinPathState.selectedPath = nil
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
    /// Preserves `kind` and restamps `compositionRevision` to the live revision.
    private func canonicalFocusedSegmentChoices(
        from snapshot: T9PinyinPathState
    ) -> [T9PinyinPath] {
        guard let source = snapshot.segmentSourceDigits,
              snapshot.focusedSegmentIndex != nil
        else { return [] }
        let confirmed = snapshot.confirmedSegmentValues
        let confirmedLetters = T9PinyinPathExtractor.letterCount(ofSyllables: confirmed)
        let revision = state.compositionRevision
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
                    T9PinyinPath(
                        kind: path.kind,
                        consumedSlotCount: path.consumedSlotCount,
                        displayText: display,
                        replacementRawInput: replacement,
                        compositionRevision: revision,
                        focusSlotStart: confirmedLetters,
                        focusSlotEnd: confirmedLetters + path.consumedSlotCount
                    )
                )
                continue
            }
            // Single-letter fallback when syllable remap fails (digit identity only).
            guard display.count == 1,
                  let letter = display.first,
                  letter.isLetter
            else { continue }
            guard confirmedLetters < source.count else { continue }
            let remaining = String(source.dropFirst(confirmedLetters))
            guard let digit = remaining.first,
                  T9PinyinPathExtractor.keyLetters(forDigit: digit).contains(letter)
            else { continue }
            let suffix = String(remaining.dropFirst())
            let prefix = confirmed.joined(separator: "'")
            let replacement = prefix.isEmpty ? display + suffix : prefix + "'" + display + suffix
            // Reclassify one-slot remaps from the catalog; multi-digit letter locks
            // keep letterPrefix. Never promote non-syllable letters to complete.
            let kind: T9PinyinPathKind
            if remaining.count == 1 {
                let completeSet = Set(
                    T9PinyinSyllableCatalog.completeSyllables(matchingDigits: String(remaining.prefix(1)))
                )
                kind = completeSet.contains(display) ? .completeSyllable : .letterPrefix
            } else {
                kind = path.kind == .completeSyllable && display.count > 1
                    ? .completeSyllable
                    : .letterPrefix
            }
            remapped.append(
                T9PinyinPath(
                    kind: kind,
                    consumedSlotCount: 1,
                    displayText: display,
                    replacementRawInput: replacement,
                    compositionRevision: revision,
                    focusSlotStart: confirmedLetters,
                    focusSlotEnd: confirmedLetters + 1
                )
            )
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
            updateInlinePreedit(visible, source: .compositionProjection)
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
        updateInlinePreedit(displayText, source: .compositionProjection)
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
            updateInlinePreedit(visible, source: .compositionProjection)
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
        updateInlinePreedit(displayText, source: .compositionProjection)
    }

    /// Projects an explicit segment replacement onto the existing visible T9
    /// spelling. Unresolved trailing slots are never silently discarded.
    ///
    /// Human C (2026-07-23):
    /// - Reject corrupted preedit tails that do not T9-encode to remaining digits
    ///   (`qingweiuil`).
    /// - Do **not** fail closed to bare `qingwei` when remaining digits still exist;
    ///   re-project the tail from RIME / catalog (Human retest #4).
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

        let remainingDigits = String(sourceDigits.dropFirst(consumedSlots))
        let previousLetters = previousVisibleRemainder.unicodeScalars.filter(
            T9PinyinPathExtractor.isASCIILetter
        )
        // Prefer a previous visible tail only when it still encodes the ledger.
        if previousLetters.count >= sourceDigits.count {
            let suffixScalars = Array(previousLetters.suffix(unresolvedSlots))
            let suffix = String(String.UnicodeScalarView(suffixScalars))
            if let encoded = t9DigitSignature(forLetters: suffix), encoded == remainingDigits {
                return explicitPrefix + suffix
            }
        }
        // Live RIME letter preedit when it fully encodes the source ledger.
        if let rimeLetters = state.lastRimeOutput.flatMap({ output -> String? in
            let letters = String(
                (output.composition?.preeditText ?? "")
                    .unicodeScalars
                    .filter(T9PinyinPathExtractor.isASCIILetter)
            )
            guard !letters.isEmpty,
                  let enc = t9DigitSignature(forLetters: letters),
                  enc == sourceDigits
            else { return nil }
            return letters
        }) {
            return rimeLetters
        }
        // RIME / comment projection for remaining slots only (drop confirmed segments).
        if let remLetters = projectRemainingDigitsToHostLetters(
            remainingDigits: remainingDigits,
            confirmedSyllables: explicitSegments,
            sourceDigits: sourceDigits
        ), !remLetters.isEmpty {
            return explicitPrefix + remLetters
        }
        // Last resort: progressive catalog letters for the remaining run (never digits,
        // never drop the tail to bare confirmed prefix).
        let catalogTail = progressiveCatalogLetters(
            forRemainingDigits: remainingDigits,
            confirmedSyllables: explicitSegments,
            sourceDigits: sourceDigits
        )
        return catalogTail.isEmpty ? explicitPrefix : explicitPrefix + catalogTail
    }

    /// RIME raw for confirmed Path + remaining focus (standalone remaining parity).
    ///
    /// **Full-cover policy: UNIQUE only** (differs from `shortUnconfirmedResyncRaw`).
    /// Letter-refine only when exactly one complete catalog path covers the **entire**
    /// remaining run (e.g. remaining `32` → `da`). Never partial-cover a long
    /// tail (`9698454` → `wo`+`98454`) — that invents segmentation and breaks
    /// multi-syllable continue (risk called out for sentence vs standalone).
    ///
    /// When zero or multiple completes cover the same short run, keep pure remaining
    /// digits so RIME/processKey can still form `dao` like a lone composition.
    private func refinedConfirmedPlusRemainingRaw(
        confirmed: [String],
        remainingDigits: String,
        focusPaths: [T9PinyinPath]
    ) -> String {
        let prefix = confirmed.joined(separator: "'")
        guard !remainingDigits.isEmpty else { return prefix }
        let fullCovers = focusPaths.filter {
            $0.kind == .completeSyllable
                && $0.consumedSlotCount == remainingDigits.count
                && !$0.displayText.isEmpty
                && $0.displayText.unicodeScalars.allSatisfy(T9PinyinPathExtractor.isASCIILetter)
        }
        // Unique full cover → letter form (standalone short-syllable parity).
        if fullCovers.count == 1, let only = fullCovers.first {
            return prefix + "'" + only.displayText
        }
        // Ambiguous or long remaining: pure digits after confirmed boundary.
        return prefix + "'" + remainingDigits
    }

    /// Short unconfirmed resync raw (1…3 digit ledger).
    ///
    /// **Full-cover policy: FIRST in catalog/comment order** (differs from
    /// `refinedConfirmedPlusRemainingRaw`'s unique-only rule). Still requires a
    /// complete syllable that covers **all** slots — never invents slots or
    /// changes `sourceDigits` length. Prefer letter form to avoid bare multi-digit
    /// raws that pollute candidates (746 → 手/瘦) while Path stays on the ledger.
    /// Never use letterPrefix replacements like `t6` as the whole raw.
    private func shortUnconfirmedResyncRaw(
        sourceDigits: String,
        focusPaths: [T9PinyinPath]
    ) -> String {
        if let fullCover = focusPaths.first(where: {
            $0.kind == .completeSyllable
                && $0.consumedSlotCount == sourceDigits.count
                && !$0.displayText.isEmpty
                && $0.displayText.unicodeScalars.allSatisfy(T9PinyinPathExtractor.isASCIILetter)
        }) {
            return fullCover.displayText
        }
        // No full complete (e.g. mid-syllable `32` with only prefixes): pure digits
        // keep Path discovery on the real ledger length.
        if sourceDigits.count > 1 {
            return sourceDigits
        }
        // Single digit: prefer a pure letter label, never `t6`-style replacement.
        if let letter = focusPaths.first(where: {
            $0.consumedSlotCount == 1
                && $0.displayText.unicodeScalars.allSatisfy(T9PinyinPathExtractor.isASCIILetter)
        }) {
            return letter.displayText
        }
        return sourceDigits
    }

    /// Project remaining digit slots to host letters via comment segments / preedit.
    private func projectRemainingDigitsToHostLetters(
        remainingDigits: String,
        confirmedSyllables: [String],
        sourceDigits: String
    ) -> String? {
        guard !remainingDigits.isEmpty, let output = state.lastRimeOutput else { return nil }
        // Full visible preedit that starts with confirmed letters and matches length.
        let projected = t9VisiblePreedit(for: output)
        let projectedLetters = String(
            projected.unicodeScalars.filter(T9PinyinPathExtractor.isASCIILetter)
        )
        let confJoined = confirmedSyllables.joined()
        if projectedLetters.hasPrefix(confJoined),
           projectedLetters.count == confJoined.count + remainingDigits.count
        {
            return String(projectedLetters.dropFirst(confJoined.count))
        }
        // Comment syllables after the confirmed count, projected to remaining slots.
        if let comment = T9PreeditResolver.preferredComment(
            candidates: output.candidates,
            highlightedIndex: output.highlightedIndex
        ) {
            let segments = comment
                .split(whereSeparator: { $0 == " " || $0 == "'" })
                .map { String($0).lowercased() }
                .filter { !$0.isEmpty && $0.unicodeScalars.allSatisfy(T9PinyinPathExtractor.isASCIILetter) }
            if segments.count > confirmedSyllables.count {
                let remComment = segments.dropFirst(confirmedSyllables.count).joined(separator: " ")
                let remProjected = T9PreeditResolver.projectCommentLetters(
                    remComment,
                    slotLimit: remainingDigits.count
                )
                if !remProjected.isEmpty,
                   let enc = t9DigitSignature(forLetters: remProjected),
                   enc == remainingDigits
                {
                    return remProjected
                }
                // Length-matched projection even when encoding differs slightly from
                // ideal (comment ranking); still better than dropping the tail.
                if remProjected.count == remainingDigits.count {
                    return remProjected
                }
            }
        }
        _ = sourceDigits
        return nil
    }

    /// Progressive local-catalog letters for an unresolved digit run (host only).
    private func progressiveCatalogLetters(
        forRemainingDigits remainingDigits: String,
        confirmedSyllables: [String],
        sourceDigits: String,
        useCommentHints: Bool = true
    ) -> String {
        guard !remainingDigits.isEmpty else { return "" }
        let hints: [String]
        if useCommentHints {
            hints = T9PinyinLocalPathCatalog.commentSyllableHints(
                from: state.lastRimeOutput?.candidates ?? [],
                confirmedSyllables: confirmedSyllables
            )
        } else {
            hints = []
        }
        let paths = T9PinyinLocalPathCatalog.pathsForFocus(
            focusDigits: remainingDigits,
            lockedLetterPrefix: nil,
            commentSyllableHints: hints,
            confirmedSyllables: confirmedSyllables,
            sourceDigits: sourceDigits,
            compositionRevision: state.compositionRevision
        )
        // Prefer complete syllable covering a prefix of remaining; recurse on rest.
        if let complete = paths.first(where: {
            $0.kind == .completeSyllable
                && $0.consumedSlotCount > 0
                && $0.consumedSlotCount <= remainingDigits.count
                && $0.displayText.unicodeScalars.allSatisfy(T9PinyinPathExtractor.isASCIILetter)
        }) {
            let used = complete.consumedSlotCount
            let rest = String(remainingDigits.dropFirst(used))
            if rest.isEmpty { return complete.displayText }
            return complete.displayText + progressiveCatalogLetters(
                forRemainingDigits: rest,
                confirmedSyllables: confirmedSyllables + [complete.displayText],
                sourceDigits: sourceDigits,
                useCommentHints: useCommentHints
            )
        }
        if let letter = paths.first(where: {
            $0.consumedSlotCount == 1
                && $0.displayText.unicodeScalars.allSatisfy(T9PinyinPathExtractor.isASCIILetter)
        }) {
            let rest = String(remainingDigits.dropFirst(1))
            if rest.isEmpty { return letter.displayText }
            return letter.displayText + progressiveCatalogLetters(
                forRemainingDigits: rest,
                confirmedSyllables: confirmedSyllables,
                sourceDigits: sourceDigits,
                useCommentHints: useCommentHints
            )
        }
        return ""
    }

    /// T9 digit signature for pure ASCII letters (a→2 … z→9). nil if non-letter.
    private func t9DigitSignature(forLetters letters: String) -> String? {
        let map: [Character: Character] = [
            "a": "2", "b": "2", "c": "2",
            "d": "3", "e": "3", "f": "3",
            "g": "4", "h": "4", "i": "4",
            "j": "5", "k": "5", "l": "5",
            "m": "6", "n": "6", "o": "6",
            "p": "7", "q": "7", "r": "7", "s": "7",
            "t": "8", "u": "8", "v": "8",
            "w": "9", "x": "9", "y": "9", "z": "9",
        ]
        var out = ""
        for ch in letters.lowercased() {
            guard let d = map[ch] else { return nil }
            out.append(d)
        }
        return out.isEmpty ? nil : out
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
            advanceCompositionRevision()
            let previousSelected = previousPathState.selectedPath
            state.lastRimeOutput = restored
            state.currentComposition = previousComposition
            // Rollback restores the exact host-visible marked text from before
            // the failed refinement, not a newly preferred candidate comment.
            updateInlinePreedit(previousMarked, source: .compositionProjection)
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
            advanceCompositionRevision()
            engine.resetSession()
            clearInlinePreedit()
            state.currentComposition = ""
            state.lastRimeOutput = nil
            state.partialCommit = nil
            clearTypoCorrectionSuggestions()
            let pathEffect = clearT9PinyinPathStateReturningEffect()
            return .compositionChanged.union(pathEffect)
        }

        advanceCompositionRevision()
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
