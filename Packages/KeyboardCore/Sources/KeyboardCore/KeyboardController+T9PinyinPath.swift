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

    func handleSelectT9PinyinPath(_ path: T9PinyinPath) -> KeyboardEffect {
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

        let generation = state.t9PinyinPathState.rawInputGeneration
        let provenance = state.t9PinyinPathState.provenanceRevision
        guard generation > 0, provenance > 0 else { return [] }
        guard state.t9PinyinPathState.issuedReplacementKeys.contains(path.replacementRawInput) else {
            return []
        }
        guard T9PinyinPathExtractor.isCompatible(path: path, withRawInput: previousRaw) else {
            return []
        }

        let previousMarked = state.insertedPreeditText
        let previousComposition = state.currentComposition
        let previousPathState = state.t9PinyinPathState

        let result = engine.replaceInput(path.replacementRawInput)

        if isExactSuccessfulT9Refinement(result: result, requestedPath: path) {
            // Raw usually changes → hard provenance rebuild via refresh.
            applyRimeOutput(augmentRimeOutputIfNeeded(result))
            if state.t9PinyinPathState.issuedReplacementKeys.contains(path.replacementRawInput) {
                state.t9PinyinPathState.selectedPath = path
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

        var paths = T9PinyinPathExtractor.paths(
            from: output.candidates,
            rawInput: raw,
            limit: T9PinyinPathExtractor.compactLimit
        )
        for path in paths {
            issued.insert(path.replacementRawInput)
        }

        var discoveryNext = 0
        var discoveryMayHaveMore = true
        if let engine = rimeEngine {
            let window = engine.candidateWindow(
                from: 0,
                limit: T9PinyinPathExtractor.hotPathWindowLimit
            )
            let more = T9PinyinPathExtractor.paths(from: window.candidates, rawInput: raw)
            var seen = Set(paths.map(\.replacementRawInput))
            for path in more {
                issued.insert(path.replacementRawInput)
                if seen.insert(path.replacementRawInput).inserted,
                   paths.count < T9PinyinPathExtractor.compactLimit
                {
                    paths.append(path)
                }
            }
            discoveryNext = window.nextIndex
            discoveryMayHaveMore = window.hasMoreCandidates
            if !issued.isEmpty {
                discoveryMayHaveMore = window.hasMoreCandidates || discoveryNext > 0
            }
        } else {
            discoveryMayHaveMore = false
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
            discoveryMayHaveMore: discoveryMayHaveMore
        )
        let changed = newState.compactPaths != state.t9PinyinPathState.compactPaths
            || newState.selectedPath != state.t9PinyinPathState.selectedPath
            || newState.rawInputGeneration != previousGeneration
            || newState.provenanceRevision != previousProvenance
            || newState.issuedReplacementKeys != state.t9PinyinPathState.issuedReplacementKeys
            || newState.discoveryMayHaveMore != state.t9PinyinPathState.discoveryMayHaveMore
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
            let raw = restored.rawInput ?? ""
            state.currentComposition = raw
            let visible = T9PreeditResolver.visiblePreedit(
                rawInput: raw,
                candidates: restored.candidates,
                highlightedIndex: restored.highlightedIndex
            )
            updateInlinePreedit(visible)
            clearTypoCorrectionSuggestions()
            _ = refreshT9PinyinPathState(forceNewProvenance: true)
            if let previousSelected,
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
        _ = previousMarked
        _ = previousComposition
        return .compositionChanged.union(pathEffect)
    }
}
