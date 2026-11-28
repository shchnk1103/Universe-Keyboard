extension KeyboardController {
    /// Host-facing composition string. Under T9, never fall back to raw digits —
    /// those live in `currentComposition` / `rawInput` for engine recovery only.
    var activeCompositionDisplayText: String {
        if let partial = state.partialCommit {
            return partial.displayText
        }
        if let output = state.lastRimeOutput,
            T9CompositionCommitPolicy.isActiveT9Composition(
                usesT9InputSemantics: usesT9InputSemantics,
                rawInput: output.rawInput
            )
        {
            return t9VisiblePreedit(for: output)
        }
        if !state.insertedPreeditText.isEmpty {
            return state.insertedPreeditText
        }
        return state.currentComposition
    }

    /// Host-visible T9 preedit using provisional Path when it fully covers focus slots.
    ///
    /// `confirmedSpelling` (RC-2): when a candidate selection just confirmed a
    /// segment, librime may keep the full raw and the comment projection then
    /// repeats the selected spelling (e.g. `nihao` after 你). The visible
    /// remainder starts at the first unresolved syllable, so the confirmed
    /// spelling prefix is stripped from the projection.
    func t9VisiblePreedit(for output: RimeOutput, confirmedSpelling: String? = nil) -> String {
        let pathState = state.t9PinyinPathState
        let provisional =
            pathState.selectedPath == nil
            ? (pathState.compactPaths.first { $0.id == pathState.provisionalPathID }
                ?? pathState.compactPaths.first)
            : nil
        var candidates = output.candidates
        if let spelling = confirmedSpelling, !spelling.isEmpty {
            candidates = candidates.map { candidate in
                guard let comment = candidate.comment,
                    let validated = T9PreeditResolver.validatedSource(comment),
                    validated.hasPrefix(spelling)
                else { return candidate }
                return RimeCandidate(
                    text: candidate.text,
                    comment: String(validated.dropFirst(spelling.count)),
                    globalIndex: candidate.globalIndex
                )
            }
        }
        let projected = T9PreeditResolver.visiblePreedit(
            rawInput: output.rawInput,
            candidates: candidates,
            highlightedIndex: output.highlightedIndex,
            provisionalPathDisplay: provisional?.displayText,
            provisionalConsumedSlots: provisional?.consumedSlotCount
        )
        // Letter-explicit fallbacks (refined raw `qing'wei`) also replay the
        // confirmed spelling when librime retains the full identity.
        if let spelling = confirmedSpelling, !spelling.isEmpty, projected.hasPrefix(spelling) {
            return String(projected.dropFirst(spelling.count))
        }
        return projected
    }

    /// Snapshot of what the host is currently showing for checkpoint restore.
    private var hostVisiblePreeditSnapshot: String {
        if !state.insertedPreeditText.isEmpty {
            return state.insertedPreeditText
        }
        return activeCompositionDisplayText
    }

    /// Applies a normal RIME candidate selection while keeping any remaining raw input active.
    func applyNormalCandidateSelection(
        candidate: String,
        result: RimeOutput,
        previousOutput: RimeOutput
    ) {
        advanceCompositionRevision()
        let previousConfirmedText = state.partialCommit?.confirmedText ?? ""
        let previousRawInput = previousOutput.rawInput
        let previousPreeditText = previousOutput.composition?.preeditText
        // Prefer host marked text / T9 comment preedit — never T9 raw digits.
        let previousDisplayText = hostVisiblePreeditSnapshot

        guard let rimeRawInput = result.rawInput,
            !rimeRawInput.isEmpty,
            let rimePreeditText = result.composition?.preeditText,
            !rimePreeditText.isEmpty,
            let previousRawInput,
            !previousRawInput.isEmpty,
            let previousPreeditText,
            !previousPreeditText.isEmpty
        else {
            finishNormalCandidateSelection(candidate: candidate, result: result)
            return
        }

        // librime may keep a selected segment inside its composition without emitting
        // committedText until the whole session is finished. The tapped candidate is
        // therefore the stable confirmed segment for a partial selection.
        let committedText = result.committedText ?? candidate
        let confirmedText = previousConfirmedText + committedText
        // Path Bar digit identity must survive a nested Chinese partial that
        // shortens live raw to a pure-digit suffix (e.g. qiu'53 → 5 after 球).
        // Capture before install: hard path refresh would otherwise forget
        // confirmed syllables and collapse source to the bare remainder digit.
        let preservedSegmentSource = state.t9PinyinPathState.segmentSourceDigits
        let preservedPathConfirmed = state.t9PinyinPathState.confirmedSegmentValues
        let preservedFocus = state.t9PinyinPathState.focusedSegmentIndex
        let checkpoint = PartialCommitCheckpoint(
            previousConfirmedText: previousConfirmedText,
            previousRawInput: previousRawInput,
            previousPreeditText: previousPreeditText,
            previousDisplayText: previousDisplayText,
            previousSegmentSourceDigits: preservedSegmentSource,
            previousConfirmedSegmentValues: preservedPathConfirmed,
            previousFocusedSegmentIndex: preservedFocus
        )
        let previousRawForTrace = previousRawInput
        // RC-2 basis: how many raw slots the confirmed segment consumed and the
        // spelling it confirmed (tapped candidate comment, else the Path ledger
        // prefix covered by the candidate's CJK step count).
        let confirmedSlotBasis = confirmedSegmentConsumption(
            committedText: committedText,
            previousOutput: previousOutput,
            preservedPathConfirmed: preservedPathConfirmed
        )
        // Candidate selection starts a new presentation revision. Presentation
        // state (chips, soft-select, retention) must not leak into the installer,
        // but the Path **ledger identity** (RC-1) is re-seeded below instead of
        // wiped: wiping `segmentSourceDigits` / `confirmedSegmentValues` forced
        // the installer's Path refresh to rebuild raw-only at slot 0 (residual
        // selected syllables) and defeated the one-pass `nestedRemainderSource`
        // peel. A genuinely nested shortened tail is still restored once below,
        // after the new output has been installed.
        state.t9PinyinPathState.compactPaths = []
        state.t9PinyinPathState.selectedPath = nil
        state.t9PinyinPathState.issuedReplacementKeys = []
        state.t9PinyinPathState.retainedChoiceSourceRawInput = nil
        state.t9PinyinPathState.segmentSourceDigits = preservedSegmentSource
        state.t9PinyinPathState.focusedSegmentIndex = preservedFocus
        state.t9PinyinPathState.confirmedSegmentValues = preservedPathConfirmed
        installPartialCommitPresentation(
            confirmedText: confirmedText,
            output: result,
            checkpoint: checkpoint,
            source: .rime,
            confirmedSlotLetters: confirmedSlotBasis.slotLetters,
            confirmedSpelling: confirmedSlotBasis.spelling
        )
        let restored = restoreSegmentedPathIdentityAfterNestedPartial(
            preservedSegmentSource: preservedSegmentSource,
            preservedPathConfirmed: preservedPathConfirmed,
            committedCandidate: committedText
        )
        #if DEBUG
            // Phase 0 only: structural identity after partial — no host document text.
            // Note encodes whether pure-digit restore succeeded and whether unconsumed
            // path syllables still lack a slot-rebase model (B root cause class).
            gate5TraceComposition(
                event: .partialCommit,
                previousRaw: previousRawForTrace,
                note: "restore=\(restored) preservedConfCount=\(preservedPathConfirmed.count) "
                    + "livePureDigits=\(result.rawInput?.allSatisfy(\.isNumber) ?? false) "
                    + "slotRebaseMissing=\(!restored && !preservedPathConfirmed.isEmpty)"
            )
        #endif
    }

    /// Slot consumption of the just-confirmed segment (RC-2 peel basis).
    ///
    /// Priority: the tapped candidate's comment spelling (its letter count is
    /// the raw slots the segment consumed); otherwise the user Path ledger
    /// prefix covered by the candidate's CJK step count via
    /// `T9CompositionIdentity.pathLedgerPeelCount`. Both stay nil/0 when no
    /// evidence exists — the peel then fails closed to the engine fallbacks.
    private func confirmedSegmentConsumption(
        committedText: String,
        previousOutput: RimeOutput,
        preservedPathConfirmed: [String]
    ) -> (slotLetters: Int, spelling: String?) {
        let tapped = previousOutput.candidates.first { $0.text == committedText }
        let tappedSpelling = tapped?.comment.flatMap { T9PreeditResolver.validatedSource($0) }
        if let tappedSpelling,
            T9PinyinPathExtractor.asciiLetterCount(in: tappedSpelling) > 0
        {
            return (T9PinyinPathExtractor.asciiLetterCount(in: tappedSpelling), tappedSpelling)
        }
        let peelK = T9CompositionIdentity.pathLedgerPeelCount(
            candidateText: committedText,
            remainingUserPathSyllables: preservedPathConfirmed.count
        )
        guard peelK > 0 else { return (0, nil) }
        let ledgerPrefix = Array(preservedPathConfirmed.prefix(peelK))
        return (
            T9PinyinPathExtractor.letterCount(ofSyllables: ledgerPrefix),
            ledgerPrefix.joined()
        )
    }

    /// RC-2: peel the confirmed segment's slots off a retained full raw.
    ///
    /// librime often keeps the whole pre-selection digit run after a partial
    /// selection. The engine preedit tail (letter form) is authoritative for
    /// how many slots remain; otherwise the confirmed segment's slot count is
    /// peeled from the front. Returns nil when the raw was already shortened or
    /// no consumption evidence exists — callers then fall back to the engine
    /// remainder heuristics.
    private func peeledRemainingRawAfterConfirmedSlots(
        previousRaw: String?,
        resultRaw: String,
        confirmedSlotLetters: Int,
        engineTail: String?
    ) -> String? {
        let previousDigits = T9PinyinPathExtractor.pureDigitRaw(previousRaw)
        guard !previousDigits.isEmpty else { return nil }
        // Only peel a retained (unchanged) full digit run; shortened raws are
        // already the engine's own remainder.
        guard T9PinyinPathExtractor.pureDigitRaw(resultRaw) == previousDigits else {
            return nil
        }
        if let engineTail,
            let validatedTail = T9PreeditResolver.validatedSource(engineTail)
        {
            let tailLetters = T9PinyinPathExtractor.asciiLetterCount(in: validatedTail)
            if tailLetters > 0, tailLetters < previousDigits.count {
                return String(previousDigits.suffix(tailLetters))
            }
        }
        if confirmedSlotLetters > 0, confirmedSlotLetters < previousDigits.count {
            return String(previousDigits.dropFirst(confirmedSlotLetters))
        }
        return nil
    }

    /// Re-attach progressive path identity after nested partial.
    ///
    /// Residual-B Path-ledger **cursor** (product SoT): when the user already
    /// Path-selected syllables, peel **K** leading stack syllables where
    /// `K = min(CJK count, stack length)`. Digit slots follow those syllables.
    /// Path Bar then focuses the next stack syllable with **soft-select** when the
    /// user had selected it; unselected tail (`wo…`) has no forged selection.
    ///
    /// Prefer ledger cursor over engine shortened-remainder realign whenever a
    /// non-empty user Path stack and K > 0 exist (same principle for 请 / 请喂 / …).
    @discardableResult
    func restoreSegmentedPathIdentityAfterNestedPartial(
        preservedSegmentSource: String?,
        preservedPathConfirmed: [String],
        committedCandidate: String = ""
    ) -> Bool {
        guard usesT9InputSemantics,
            let preserved = preservedSegmentSource,
            !preserved.isEmpty,
            preserved.allSatisfy(\.isNumber),
            let liveRaw = state.lastRimeOutput?.rawInput,
            !liveRaw.isEmpty
        else { return false }

        // Pure-digit path still requires prior confirmed syllables (nested peel).
        // Mixed path may rebuild confirmed from remaining letter segments.
        guard !preservedPathConfirmed.isEmpty || !liveRaw.allSatisfy(\.isNumber) else {
            return false
        }

        // Path-ledger cursor (residual-B): peel K user-stack syllables and soft-select
        // the next user-chosen slot. Do **not** steal nested single-syllable partials
        // that shorten a pure-digit tail under one confirmed anchor (e.g. qiu'53 → 球 → 5
        // must keep `qiu` via afterPartialCommit). Trigger only when:
        // - user Path stack has 2+ syllables (progressive phrase), or
        // - engine raw is unchanged-raw (device B morphology).
        // RC-3: a stack of any size still gets the cursor treatment below as a
        // fallback once `afterPartialCommit` fails (single user-selected
        // syllable + shortened raw previously fell through to a raw-only slot-0
        // rebuild).
        let peelK = T9CompositionIdentity.pathLedgerPeelCount(
            candidateText: committedCandidate,
            remainingUserPathSyllables: preservedPathConfirmed.count
        )
        let usePathLedgerCursor =
            peelK > 0
            && (preservedPathConfirmed.count >= 2
                || isUnchangedRawEncoding(liveRaw, previousSource: preserved))
        if usePathLedgerCursor,
            let identity = T9CompositionIdentity.afterPathLedgerPeel(
                previousSource: preserved,
                previousConfirmed: preservedPathConfirmed,
                peelSyllableCount: peelK
            )
        {
            installPathLedgerCursorState(identity)
            _ = resyncRimeAfterPathLedgerCursor(identity: identity)
            refreshPartialCommitRemainingAfterPathLedgerPeel(identity: identity)
            return true
        }

        // Engine shortened remainder — β unique suffix / nested pure-digit peel.
        if let identity = T9CompositionIdentity.afterPartialCommit(
            previousSource: preserved,
            previousConfirmed: preservedPathConfirmed,
            remainingRaw: liveRaw
        ) {
            installIdentityAsPathState(identity)
            return true
        }

        // RC-3 (relaxed gate): any non-empty user Path stack — including a
        // single user-selected syllable with a shortened raw (live digits equal
        // the unresolved tail) — gets the ledger cursor once the strict gate
        // and `afterPartialCommit` both failed.
        if peelK > 0,
            let identity = T9CompositionIdentity.afterPathLedgerPeel(
                previousSource: preserved,
                previousConfirmed: preservedPathConfirmed,
                peelSyllableCount: peelK
            )
        {
            installPathLedgerCursorState(identity)
            _ = resyncRimeAfterPathLedgerCursor(identity: identity)
            refreshPartialCommitRemainingAfterPathLedgerPeel(identity: identity)
            return true
        }

        // RC-3 fail-closed: when all identity paths nil out **for a candidate
        // selection that consumed stack syllables** (peelK > 0), the Path bar
        // must not fall through to a raw-only slot-0 rebuild (residual selected
        // syllables). Rebuild from the preserved ledger instead — confirmed
        // syllables stay confirmed and focus starts after them — but only when
        // the live raw still matches the ledger (unchanged encoding, or the
        // live digit run equals the unresolved tail after the confirmed stack).
        // With peelK == 0 nothing was consumed and the live output already owns
        // the new focus (whole-tail refresh), so restore must stay off.
        if peelK > 0, !preservedPathConfirmed.isEmpty {
            let confirmedLetters = T9PinyinPathExtractor.letterCount(
                ofSyllables: preservedPathConfirmed
            )
            let tailAligned: Bool = {
                guard confirmedLetters > 0, confirmedLetters < preserved.count else {
                    return false
                }
                let unresolvedTail = String(preserved.dropFirst(confirmedLetters))
                let liveDigits = T9PinyinPathExtractor.pureDigitRaw(liveRaw)
                return !unresolvedTail.isEmpty
                    && !liveDigits.isEmpty
                    && liveDigits == unresolvedTail
            }()
            guard confirmedLetters > 0,
                tailAligned || isUnchangedRawEncoding(liveRaw, previousSource: preserved)
            else { return false }
            installIdentityAsPathState(
                T9CompositionIdentity(
                    sourceDigits: preserved,
                    confirmedSyllables: preservedPathConfirmed,
                    focusedSegmentIndex: preservedPathConfirmed.count
                )
            )
            return true
        }

        return false
    }

    /// True when live raw still encodes the full pre-selection digit ledger.
    private func isUnchangedRawEncoding(_ liveRaw: String, previousSource: String) -> Bool {
        if liveRaw == previousSource { return true }
        if liveRaw.allSatisfy(\.isNumber) { return liveRaw == previousSource }
        guard let encoded = T9CompositionIdentity.digitEncoding(ofMixedRaw: liveRaw) else {
            return false
        }
        return encoded == previousSource
    }

    /// Path-ledger cursor presentation: soft-select next user-stack syllable, or
    /// unselected tail when the user Path stack is exhausted.
    ///
    /// `confirmedSegmentValues` keeps the full remaining user stack for the next
    /// peel (ledger), while Path Bar options are rebuilt for the **focus slot only**.
    /// Soft-select is restored from a syllable the user already Path-selected —
    /// never auto-forged for unselected tails like `wo`.
    func installPathLedgerCursorState(_ identity: T9CompositionIdentity) {
        let stack = identity.confirmedSyllables
        let source = identity.sourceDigits
        var pathState = state.t9PinyinPathState
        pathState.segmentSourceDigits = source
        pathState.confirmedSegmentValues = stack
        pathState.lockedLetterPrefix = nil
        pathState.retainedChoiceSourceRawInput = nil
        pathState.discoveryNextIndex = 0
        pathState.discoveryMayHaveMore = false

        if let focusSyllable = stack.first {
            let n = T9PinyinPathExtractor.asciiLetterCount(in: focusSyllable)
            guard n > 0, n <= source.count else {
                installIdentityAsPathState(identity)
                return
            }
            let focusDigits = String(source.prefix(n))
            let hints = T9PinyinLocalPathCatalog.commentSyllableHints(
                from: state.lastRimeOutput?.candidates ?? [],
                confirmedSyllables: []
            )
            let paths = T9PinyinLocalPathCatalog.pathsForFocus(
                focusDigits: focusDigits,
                lockedLetterPrefix: nil,
                commentSyllableHints: hints,
                confirmedSyllables: [],
                sourceDigits: source,
                compositionRevision: state.compositionRevision
            )
            pathState.focusedSegmentIndex = 0
            pathState.compactPaths = paths
            pathState.issuedReplacementKeys = Set(paths.map(\.replacementRawInput))
            pathState.issuedPathIDs = Set(paths.map(\.id))
            // Restore user soft-select only for a path they previously chose.
            let match = paths.first {
                $0.displayText.lowercased() == focusSyllable.lowercased()
            }
            pathState.selectedPath = match
            pathState.provisionalPathID = match == nil ? paths.first?.id : nil
            state.t9PinyinPathState = pathState
            return
        }

        // User Path stack empty → unselected remainder (e.g. wo…); no soft-select.
        installIdentityAsPathState(
            T9CompositionIdentity(
                sourceDigits: source,
                confirmedSyllables: [],
                focusedSegmentIndex: 0
            )
        )
    }

    /// Resync RIME to remaining Path-ledger identity without wiping soft-select.
    @discardableResult
    private func resyncRimeAfterPathLedgerCursor(identity: T9CompositionIdentity) -> Bool {
        guard let engine = rimeEngine else { return false }
        let raw = identity.replacementRawInput
        guard !raw.isEmpty else { return false }
        let output = engine.replaceInput(raw)
        state.lastRimeOutput = output
        state.currentComposition = raw
        // Re-install cursor so Path Bar focus/soft-select survives replaceInput.
        installPathLedgerCursorState(identity)
        return true
    }

    /// After Path-ledger peel, keep PartialCommit remaining aligned with Core identity.
    /// Host must never see internal T9 digits; prefer live T9 projection, else letters.
    private func refreshPartialCommitRemainingAfterPathLedgerPeel(
        identity: T9CompositionIdentity
    ) {
        guard let partial = state.partialCommit else { return }
        let remainingRaw = state.lastRimeOutput?.rawInput ?? identity.replacementRawInput
        let hostTail: String
        if let output = state.lastRimeOutput {
            let projected = t9VisiblePreedit(for: output)
            if projected.isEmpty {
                hostTail = identity.confirmedSyllables.joined()
            } else if projected.unicodeScalars.contains(where: T9PinyinPathExtractor.isASCIIDigit) {
                let letters = String(
                    projected.unicodeScalars.filter(T9PinyinPathExtractor.isASCIILetter)
                )
                hostTail =
                    letters.isEmpty
                    ? identity.confirmedSyllables.joined()
                    : letters
            } else {
                hostTail = projected
            }
        } else {
            hostTail = identity.confirmedSyllables.joined()
        }
        state.partialCommit = PartialCommitState(
            confirmedText: partial.confirmedText,
            remainingRawInput: remainingRaw,
            remainingPreeditText: hostTail,
            displayText: partial.confirmedText + hostTail,
            checkpoint: partial.checkpoint,
            source: partial.source
        )
        updateInlinePreedit(
            partial.confirmedText + hostTail,
            source: .compositionProjection
        )
    }

    /// Install pure identity into path state and rebuild catalog focus Paths.
    ///
    /// Human 2026-07-23: when confirmed syllables fill the entire source (no trailing
    /// digits), Path bar must still show alternatives for the **last** syllable
    /// (e.g. only `qing` left → qing/pin/…). Empty `remainingDigits` previously
    /// produced `compactPaths = []` and the Path bar vanished.
    func installIdentityAsPathState(_ identity: T9CompositionIdentity) {
        let plan = identity.focusPathPlan()
        let hints = T9PinyinLocalPathCatalog.commentSyllableHints(
            from: state.lastRimeOutput?.candidates ?? [],
            confirmedSyllables: plan.pathConfirmedSyllables
        )
        let paths: [T9PinyinPath]
        if plan.focusDigits.isEmpty {
            paths = []
        } else {
            paths = T9PinyinLocalPathCatalog.pathsForFocus(
                focusDigits: plan.focusDigits,
                lockedLetterPrefix: nil,
                commentSyllableHints: hints,
                confirmedSyllables: plan.pathConfirmedSyllables,
                sourceDigits: identity.sourceDigits,
                compositionRevision: state.compositionRevision
            )
        }

        var pathState = state.t9PinyinPathState
        pathState.segmentSourceDigits = identity.sourceDigits
        // Keep full syllable ledger for the next identity peel; Path catalog only
        // uses `plan.pathConfirmedSyllables` (may drop last when re-focusing it).
        pathState.confirmedSegmentValues = identity.confirmedSyllables
        pathState.focusedSegmentIndex = plan.focusedSegmentIndex
        pathState.selectedPath = nil
        pathState.retainedChoiceSourceRawInput = nil
        pathState.lockedLetterPrefix = nil
        pathState.compactPaths = paths
        pathState.issuedReplacementKeys = Set(paths.map(\.replacementRawInput))
        pathState.issuedPathIDs = Set(paths.map(\.id))
        // Never auto-select a path after identity install (Human: qi auto-selected).
        pathState.provisionalPathID = paths.first?.id
        pathState.discoveryNextIndex = 0
        pathState.discoveryMayHaveMore = false
        state.t9PinyinPathState = pathState
    }

    /// Applies a RIME output while preserving a confirmed prefix during the active session.
    func applyRimeOutputPreservingPartialCommit(_ output: RimeOutput) {
        // Every ordered engine-output branch (Delete, partial restore, Path
        // recovery and auto-anchor rollback) shares this completion boundary.
        // Refreshing here prevents a branch that clears L1 before applying its
        // output from leaving the previous stable prefix behind.
        defer { captureResponsiveStablePreeditIfReady() }
        advanceCompositionRevision()
        // Rem-3 D3: any dual-gate engine apply into Core state clears L1 ledger
        // (ordered Delete / L2 presentation both flow here).
        alignResponsiveProvisionalAfterOrderedEngineApply()
        if let committedText = output.committedText,
            !engineCommitIsHostSafe(committedText)
        {
            failClosedUnexpectedEngineCommit()
            return
        }
        guard let partialCommit = state.partialCommit else {
            applyRimeOutputWithoutPartialCommit(output)
            return
        }

        if let committedText = output.committedText, !committedText.isEmpty {
            let finalText = PartialCommitTextMerge.mergedText(
                confirmed: partialCommit.confirmedText,
                committed: committedText)
            commitInlinePreedit(as: finalText, source: .engineCommit)
            emitPartialCommitOverlapDiagnostic(
                path: .preserve,
                confirmedText: partialCommit.confirmedText,
                committedText: committedText
            )
            state.currentComposition = ""
            state.lastRimeOutput = output
            state.partialCommit = nil
            clearTypoCorrectionSuggestions()
            _ = clearT9PinyinPathStateReturningEffect()
            return
        }

        guard let rimeRawInput = output.rawInput,
            let rimePreeditText = output.composition?.preeditText,
            !rimeRawInput.isEmpty,
            !rimePreeditText.isEmpty
        else {
            let confirmedText = partialCommit.confirmedText
            commitInlinePreedit(as: confirmedText)
            state.currentComposition = ""
            state.lastRimeOutput = output
            state.partialCommit = nil
            clearTypoCorrectionSuggestions()
            _ = clearT9PinyinPathStateReturningEffect()
            return
        }

        installPartialCommitPresentation(
            confirmedText: partialCommit.confirmedText,
            output: output,
            checkpoint: nil,
            source: partialCommit.source
        )
    }

    /// Applies a high-confidence typo correction as a partial commit.
    ///
    /// The original input is kept only as the Delete restore target. Continued
    /// composition runs through a clean RIME session rebuilt from correctedInput.
    func applyTypoCorrectionPartialCommit(_ correction: TypoCorrectionCommit) -> Bool {
        guard isTypoCorrectionPartialCommitEnabled,
            state.partialCommit == nil,
            isEligibleTypoPartialCommit(correction),
            activeInputMatchesCorrectionOriginal(correction),
            let engine = rimeEngine,
            let previousPreeditText = state.currentComposition.nonEmpty
        else {
            return false
        }

        let previousDisplayText = hostVisiblePreeditSnapshot
        guard let correctedOutput = rebuildRimeOutput(for: correction.correctedInput, using: engine),
            let candidateIndex = correctedOutput.candidates.firstIndex(where: { $0.text == correction.committedText })
        else {
            return false
        }

        let result = engine.selectCandidate(at: candidateIndex)
        guard let rimeRawInput = result.rawInput,
            !rimeRawInput.isEmpty,
            let rimePreeditText = result.composition?.preeditText,
            !rimePreeditText.isEmpty
        else {
            return false
        }

        let confirmedText = correction.committedText
        let displayText = partialDisplayText(confirmedText: confirmedText, rimePreeditText: rimePreeditText)
        let remainingPreeditText = partialRemainingPreeditText(
            confirmedText: confirmedText,
            displayText: displayText
        )
        guard !remainingPreeditText.isEmpty else { return false }

        state.lastRimeOutput = result
        state.currentComposition = remainingPreeditText
        state.partialCommit = PartialCommitState(
            confirmedText: confirmedText,
            remainingRawInput: rimeRawInput,
            remainingPreeditText: remainingPreeditText,
            displayText: displayText,
            checkpoint: PartialCommitCheckpoint(
                previousRawInput: correction.originalInput,
                previousPreeditText: previousPreeditText,
                previousDisplayText: previousDisplayText
            ),
            source: .typoCorrection
        )
        updateInlinePreedit(displayText, source: .compositionProjection)
        clearTypoCorrectionSuggestions()
        return true
    }

    /// Restores the state before the latest normal candidate partial commit.
    func restorePartialCommitCheckpoint(using engine: RimeEngine) -> Bool {
        guard let partialCommit = state.partialCommit,
            let checkpoint = partialCommit.checkpoint
        else {
            return false
        }

        let restoreRawInput = rawInputForCheckpointRestore(checkpoint)
        guard let output = rebuildRimeOutput(for: restoreRawInput, using: engine) else {
            state.partialCommit = PartialCommitState(
                confirmedText: partialCommit.confirmedText,
                remainingRawInput: partialCommit.remainingRawInput,
                remainingPreeditText: partialCommit.remainingPreeditText,
                displayText: partialCommit.displayText,
                checkpoint: nil,
                source: partialCommit.source
            )
            beginPartialCommitFailureRecovery()
            return true
        }

        clearTypoCorrectionSuggestions()

        // Top-level undo of the first partial: drop partial state and re-apply the
        // rebuilt composition through the normal T9 display path (comment-preferred,
        // never host-visible raw digits) and refresh the path bar.
        if checkpoint.previousConfirmedText.isEmpty {
            state.partialCommit = nil
            applyRimeOutput(output)
            // β-limited: re-install pre-partial Path identity when captured.
            if let source = checkpoint.previousSegmentSourceDigits,
                !source.isEmpty,
                source.allSatisfy(\.isNumber)
            {
                installIdentityAsPathState(
                    T9CompositionIdentity(
                        sourceDigits: source,
                        confirmedSyllables: checkpoint.previousConfirmedSegmentValues,
                        focusedSegmentIndex: checkpoint.previousFocusedSegmentIndex
                    )
                )
                // Letter-refined resync only when Path had confirmed syllables.
                // Pure-digit whole composition (no Path confirm) must keep digit raw
                // from `applyRimeOutput` (regression: 6442692 → ni42692).
                if !checkpoint.previousConfirmedSegmentValues.isEmpty {
                    _ = resyncRimeCompositionFromT9Identity()
                }
            }
            // If rebuilt output has no usable comments, fall back to the host
            // snapshot captured at partial time (already non-digit when captured
            // via hostVisiblePreeditSnapshot).
            if T9CompositionCommitPolicy.isActiveT9Composition(
                usesT9InputSemantics: usesT9InputSemantics,
                rawInput: output.rawInput
            ) {
                let visible = T9PreeditResolver.visiblePreedit(
                    rawInput: output.rawInput,
                    candidates: output.candidates,
                    highlightedIndex: output.highlightedIndex
                )
                if isDigitOnlyPreeditTail(visible),
                    !checkpoint.previousDisplayText.isEmpty,
                    !isDigitOnlyPreeditTail(checkpoint.previousDisplayText)
                {
                    updateInlinePreedit(
                        checkpoint.previousDisplayText,
                        source: .compositionProjection
                    )
                }
            }
            return true
        }

        // Nested partial: restore outer confirmed Chinese + remaining composition.
        installPartialCommitPresentation(
            confirmedText: checkpoint.previousConfirmedText,
            output: output,
            checkpoint: nil,
            source: partialCommit.source
        )
        // Delete is an undo of the nested candidate selection. Restore the exact
        // pre-selection host snapshot whenever it is safe; do not let rebuilt
        // RIME preedit (`qiu5`, another prediction, etc.) overwrite that user-
        // visible fact. Raw/session identity remains the rebuilt internal state.
        if !checkpoint.previousDisplayText.isEmpty,
            !containsInternalT9Digit(checkpoint.previousDisplayText)
        {
            state.partialCommit = PartialCommitState(
                confirmedText: checkpoint.previousConfirmedText,
                remainingRawInput: state.partialCommit?.remainingRawInput
                    ?? output.rawInput
                    ?? restoreRawInput,
                remainingPreeditText: partialRemainingPreeditText(
                    confirmedText: checkpoint.previousConfirmedText,
                    displayText: checkpoint.previousDisplayText
                ),
                displayText: checkpoint.previousDisplayText,
                checkpoint: nil,
                source: partialCommit.source
            )
            updateInlinePreedit(
                checkpoint.previousDisplayText,
                source: .compositionProjection
            )
        }
        return true
    }

    private func rawInputForCheckpointRestore(_ checkpoint: PartialCommitCheckpoint) -> String {
        guard !checkpoint.previousConfirmedText.isEmpty else {
            return checkpoint.previousRawInput
        }

        // Under T9, an explicit letter/apostrophe raw such as `qiu'53` is already
        // the authoritative branch selected by the user. Reusing it preserves the
        // syllable boundary and avoids rebuilding from visible `qiule` as a new,
        // ambiguously segmented composition. Do not apply this to 26-key letter
        // raws: librime may keep the whole original string (e.g. fangzidouhuizheng)
        // after an earlier segment is confirmed, and Delete must rebuild only the
        // editable suffix after that stable Chinese prefix.
        if usesT9InputSemantics,
            checkpoint.previousRawInput.unicodeScalars.contains(
                where: T9PinyinPathExtractor.isASCIILetter
            )
        {
            return checkpoint.previousRawInput
        }

        // Pure-digit T9 identity, or any 26-key letter raw that still covers the
        // whole pre-selection string: peel to the host-visible remaining suffix.
        let remainingDisplayText = partialRemainingPreeditText(
            confirmedText: checkpoint.previousConfirmedText,
            displayText: checkpoint.previousDisplayText
        )
        let editableRawInput = remainingDisplayText.filter { !$0.isWhitespace }
        return editableRawInput.isEmpty ? checkpoint.previousRawInput : editableRawInput
    }

    /// Commits the complete active display without losing a previously confirmed prefix.
    func finishActiveCompositionAsDisplayText() {
        // Rem-3: never host-commit structure-only L1 placeholders.
        if isResponsiveProvisionalAhead
            || state.currentComposition.contains(ResponsiveProvisionalComposition.placeholderScalar)
        {
            abandonResponsiveProvisionalL1WithoutHostCommit()
            clearTypoCorrectionSuggestions()
            return
        }
        let preferred = activeCompositionDisplayText
        let displayText =
            isSafeCompositionFinalizationText(preferred)
            ? preferred
            : state.insertedPreeditText
        guard isSafeCompositionFinalizationText(displayText) else { return }
        guard !displayText.isEmpty else { return }
        commitInlinePreedit(as: displayText)
        state.currentComposition = ""
        state.lastRimeOutput = nil
        state.partialCommit = nil
        clearTypoCorrectionSuggestions()
        _ = clearT9PinyinPathStateReturningEffect()
    }

    /// Commits Return as the user's raw input when RIME exposes a segmented
    /// display preedit such as "ni h". Partial Commit keeps its visible display
    /// because it may already contain confirmed Chinese text.
    func finishActiveCompositionAsRawInput(
        source: CommittedTextSource = .compositionFinalization
    ) {
        // Rem-3: never host-commit structure-only L1 placeholders.
        if isResponsiveProvisionalAhead
            || state.currentComposition.contains(ResponsiveProvisionalComposition.placeholderScalar)
        {
            abandonResponsiveProvisionalL1WithoutHostCommit()
            clearTypoCorrectionSuggestions()
            return
        }
        let preferred =
            state.partialCommit?.displayText
            ?? state.lastRimeOutput?.rawInput
            ?? state.currentComposition
        let commitText =
            isSafeCompositionFinalizationText(preferred)
            ? preferred
            : state.insertedPreeditText
        guard isSafeCompositionFinalizationText(commitText) else { return }
        guard !commitText.isEmpty else {
            return
        }
        commitInlinePreedit(as: commitText, source: source)
        state.currentComposition = ""
        state.lastRimeOutput = nil
        state.partialCommit = nil
        clearTypoCorrectionSuggestions()
        _ = clearT9PinyinPathStateReturningEffect()
    }

    private func isSafeCompositionFinalizationText(_ text: String) -> Bool {
        if !compositionProjectionContainsInternalDigit(text) {
            return true
        }
        // Ordinary 26-key input may already display literal digits. Only finalize
        // that same visible spelling; a runtime change must not expose old T9 raw.
        guard !usesT9InputSemantics else { return false }
        let visible = state.insertedPreeditText.filter { !$0.isWhitespace }
        return !visible.isEmpty && text.filter { !$0.isWhitespace } == visible
    }

    var hasActiveCompositionForSymbolInput: Bool {
        !state.currentComposition.isEmpty || (rimeEngine?.isComposing() ?? false)
    }

    func handleSymbolPageTextInput(
        _ text: String,
        updatesEnglishAutoCap: Bool = false
    ) -> KeyboardEffect? {
        guard state.currentPage == .numbers || state.currentPage == .symbols else { return nil }

        if shouldUseChineseCompositionSeparator(text) {
            var effects = handleInsertKey(text)
            effects.formUnion(returnToLettersAfterSymbolInput())
            return effects
        }

        var effects: KeyboardEffect = []

        // PB-013：标点回弹续接触发。m1——触发键按最终上屏文本归一：
        // 成对补全（含组合态收尾补右半）时以 `text + closing` 为键，
        // 未补全时以按键文本本身为键。武装必须先于宿主提交，使同一次
        // 提交的 refreshContinuation 因续接态活跃而跳过（二选一），
        // 标点不污染联想 context。触发限定中文模式 + 回弹集合 + 内置目录命中；
        // 非触发符号保持既有行为（含既有联想 context 刷新）不变。
        if state.inputMode == .chinese,
            isPostCommitContinuationEnabled,
            Self.chineseOneShotSymbols.contains(text)
        {
            let punctuationAppendedText = text + (pairedClosingSymbol(for: text) ?? "")
            if PunctuationContinuationCatalog.candidates(forTrigger: punctuationAppendedText) != nil {
                armPunctuationContinuationIfTriggers(appendedText: punctuationAppendedText)
            }
        }

        if hasActiveCompositionForSymbolInput {
            let closingSymbol = pairedClosingSymbol(for: text)
            let appendedText = text + (closingSymbol ?? "")
            let cursorOffsetFromAppendedTextStart = closingSymbol == nil ? appendedText.count : text.count
            finishActiveCompositionForSymbolInput(
                appending: appendedText,
                cursorOffsetFromAppendedTextStart: cursorOffsetFromAppendedTextStart
            )
            effects.insert(.compositionChanged)
        } else if let closingSymbol = pairedClosingSymbol(for: text) {
            insertText(text + closingSymbol, source: .directText)
            adjustTextPosition(byCharacterOffset: -closingSymbol.count)
        } else {
            insertText(text, source: .directText)
        }

        // Symbol-page commits can refresh or clear post-commit continuation state.
        // Surface that state change even when the page itself remains unchanged.
        effects.insert(.continuationChanged)

        effects.formUnion(consumeSingleUseShiftIfNeeded())
        if updatesEnglishAutoCap,
            state.inputMode == .english,
            AddressLikeKeyboardType(keyboardType: state.activeKeyboardType) == nil,
            AutoCapitalizationRules.isSentenceTerminator(text)
        {
            state.shiftState = .singleUse
            effects.insert(.shiftStateChanged)
        }

        if shouldReturnToLettersAfterSymbolInput(text) {
            effects.formUnion(returnToLettersAfterSymbolInput())
        }

        return effects
    }

    func returnToLettersAfterSymbolInput() -> KeyboardEffect {
        guard state.currentPage == .numbers || state.currentPage == .symbols else { return [] }
        state.currentPage = .letters
        return .pageChanged
    }

    func shouldUseChineseCompositionSeparator(_ text: String) -> Bool {
        state.inputMode == .chinese
            && isChineseCompositionSeparator(text)
            && hasActiveCompositionForSymbolInput
    }

    func isChineseCompositionSeparator(_ text: String) -> Bool {
        text == "‘"
    }

    private func shouldReturnToLettersAfterSymbolInput(_ text: String) -> Bool {
        switch state.inputMode {
        case .chinese:
            Self.chineseOneShotSymbols.contains(text)
        case .english:
            Self.englishOneShotSymbols.contains(text)
        }
    }

    /// Chinese one-shot symbols are intentionally exact: ASCII "." is not a Chinese-mode sentence terminator here.
    private static let chineseOneShotSymbols: Set<String> = [
        "；", "（", "）", "@", "“", "”", "。", "，", "、", "？", "！", "【", "】",
        "｛", "｝", "#", "%", "^", "*", "+", "=", "_", "\\", "｜", "《", "》",
        "&", "·",
    ]

    /// English keeps half-width punctuation semantics; "." returns to letters as the English period.
    private static let englishOneShotSymbols: Set<String> = [
        ";", "(", ")", "@", "“", "”", ".", ",", "?", "!", "[", "]", "{", "}",
        "#", "%", "^", "*", "+", "=", "_", "\\", "|", "<", ">", "&",
    ]

    private static let pairedClosingSymbols: [String: String] = [
        "（": "）",
        "(": ")",
        "“": "”",
        "【": "】",
        "[": "]",
        "｛": "｝",
        "{": "}",
        "《": "》",
        "<": ">",
    ]

    private func pairedClosingSymbol(for text: String) -> String? {
        guard isPairedSymbolCompletionEnabled else { return nil }
        return Self.pairedClosingSymbols[text]
    }

    private func finishActiveCompositionForSymbolInput(
        appending appendedText: String,
        cursorOffsetFromAppendedTextStart: Int
    ) {
        let shouldClearCandidateState = state.partialCommit?.source == .numberSuffix
        let commitText = commitFirstCandidateForSymbolInput()
        let finalText = commitText + appendedText
        let selectedOffset = commitText.count + cursorOffsetFromAppendedTextStart
        commitInlinePreedit(
            as: finalText,
            selectedOffset: selectedOffset,
            source: .directText
        )
        state.currentComposition = ""
        if shouldClearCandidateState {
            state.lastRimeOutput = nil
        }
        state.partialCommit = nil
        clearTypoCorrectionSuggestions()
        rimeEngine?.resetSession()
    }

    /// Symbol-triggered commit should behave like confirming the first candidate,
    /// while still replacing the marked range atomically so the following paired
    /// symbol can place the cursor inside the pair.
    private func commitFirstCandidateForSymbolInput() -> String {
        if state.partialCommit?.source == .numberSuffix {
            return state.lastRimeOutput?.candidates.first?.text ?? activeCompositionDisplayText
        }

        if let engine = rimeEngine, engine.isComposing() {
            let result = engine.selectCandidate(at: 0)
            let confirmedPrefix = state.partialCommit?.confirmedText ?? ""
            let priorCandidate = state.lastRimeOutput?.candidates.first?.text
            let semanticSelection =
                priorCandidate
                ?? result.committedText.flatMap { committed in
                    compositionProjectionContainsInternalDigit(committed) ? nil : committed
                }
            let projectedFallback = [
                result.composition?.preeditText,
                state.insertedPreeditText,
                activeCompositionDisplayText,
            ].compactMap { $0 }.first {
                !$0.isEmpty && !compositionProjectionContainsInternalDigit($0)
            }
            let selectedText = semanticSelection ?? projectedFallback ?? confirmedPrefix
            let commitText =
                selectedText.hasPrefix(confirmedPrefix)
                ? selectedText
                : confirmedPrefix + selectedText
            state.lastRimeOutput = RimeOutput(
                composition: nil,
                candidates: [],
                committedText: commitText,
                hasMorePages: false
            )
            return commitText
        }

        let commitText = activeCompositionDisplayText
        // A lost engine session can leave Core's last page visible. This fallback
        // still commits the composition, so its old candidates must lose authority.
        state.lastRimeOutput = RimeOutput(
            composition: nil,
            candidates: [],
            committedText: commitText,
            hasMorePages: false
        )
        return commitText
    }

    /// PF054: observe a `finalText` splice with content-free metrics. The
    /// `finalText` computation itself is untouched; this only reports lengths
    /// and the suffix/prefix overlap to the host-supplied sink.
    func emitPartialCommitOverlapDiagnostic(
        path: PartialCommitOverlapDiagnostic.Path,
        confirmedText: String,
        committedText: String
    ) {
        guard let sink = onPartialCommitOverlap else { return }
        let hasPrefix = committedText.hasPrefix(confirmedText)
        let confirmed = Array(confirmedText)
        let committed = Array(committedText)
        // Max k such that the confirmed suffix of length k equals the committed
        // prefix of length k — the duplicated-content length when splicing.
        var overlap = 0
        if !confirmed.isEmpty, !committed.isEmpty {
            for k in 1...min(confirmed.count, committed.count) {
                if confirmed[(confirmed.count - k)...].elementsEqual(committed[..<k]) {
                    overlap = k
                }
            }
        }
        sink(
            PartialCommitOverlapDiagnostic(
                path: path,
                committedHasPrefix: hasPrefix,
                confirmedLen: confirmed.count,
                committedLen: committed.count,
                overlapLen: overlap
            )
        )
    }

    private func finishNormalCandidateSelection(candidate: String, result: RimeOutput) {
        let confirmedPrefix = state.partialCommit?.confirmedText ?? ""
        let committedText = result.committedText ?? candidate
        let finalText = PartialCommitTextMerge.mergedText(
            confirmed: confirmedPrefix,
            committed: committedText)
        commitInlinePreedit(as: finalText, source: .candidate)
        emitPartialCommitOverlapDiagnostic(
            path: .finish,
            confirmedText: confirmedPrefix,
            committedText: committedText
        )
        state.currentComposition = ""
        state.lastRimeOutput = result
        state.partialCommit = nil
        clearTypoCorrectionSuggestions()
        _ = clearT9PinyinPathStateReturningEffect()
    }

    private func applyRimeOutputWithoutPartialCommit(_ output: RimeOutput) {
        state.lastRimeOutput = output
        let raw = output.rawInput ?? ""
        if T9CompositionCommitPolicy.isActiveT9Composition(
            usesT9InputSemantics: usesT9InputSemantics,
            rawInput: raw
        ) {
            // Keep composition state on raw input for delete/recovery; show comment-preferring preedit.
            state.currentComposition = raw
            if let commit = output.committedText {
                commitInlinePreedit(as: commit, source: .engineCommit)
                state.currentComposition = ""
                clearTypoCorrectionSuggestions()
                _ = clearT9PinyinPathStateReturningEffect()
            } else {
                // Path snapshot first so provisional Path can own host projection
                // when it fully covers the current focus slots (ADR 0023).
                #if DEBUG || T9_AUTO_ANCHOR_DEVICE_PREFLIGHT
                    _ = HotPathSegmentTiming.measure(.pathLocal) {
                        applyT9PinyinPathStateFromNewRimeOutput()
                    }
                    HotPathSegmentTiming.measure(.preedit) {
                        let visible = t9VisiblePreedit(for: output)
                        updateInlinePreedit(visible, source: .compositionProjection)
                    }
                #else
                    _ = applyT9PinyinPathStateFromNewRimeOutput()
                    let visible = t9VisiblePreedit(for: output)
                    updateInlinePreedit(visible, source: .compositionProjection)
                #endif
                clearTypoCorrectionSuggestions()
            }
            return
        }

        state.currentComposition = output.composition?.preeditText ?? ""
        if let commit = output.committedText {
            commitInlinePreedit(as: commit, source: .engineCommit)
            state.currentComposition = ""
            clearTypoCorrectionSuggestions()
            _ = clearT9PinyinPathStateReturningEffect()
        } else {
            updateInlinePreedit(
                state.currentComposition,
                source: .compositionProjection
            )
            refreshTypoCorrectionSuggestions()
            _ = clearT9PinyinPathStateReturningEffect()
        }
    }

    private func partialDisplayText(confirmedText: String, rimePreeditText: String) -> String {
        rimePreeditText.hasPrefix(confirmedText)
            ? rimePreeditText
            : confirmedText + rimePreeditText
    }

    private func partialRemainingPreeditText(confirmedText: String, displayText: String) -> String {
        guard displayText.hasPrefix(confirmedText) else { return displayText }
        return String(displayText.dropFirst(confirmedText.count))
    }

    /// Installs partial-commit presentation and path provenance from a live RIME output.
    ///
    /// Under T9, remaining **display** prefers candidate comments (`ya`), never raw
    /// digits (`92`), while `remainingRawInput` / `currentComposition` keep the raw
    /// identity for delete/recovery. Path bar is hard-refreshed from the remaining raw.
    private func installPartialCommitPresentation(
        confirmedText: String,
        output: RimeOutput,
        checkpoint: PartialCommitCheckpoint?,
        source: PartialCommitSource,
        confirmedSlotLetters: Int = 0,
        confirmedSpelling: String? = nil
    ) {
        guard let rimeRawInput = output.rawInput, !rimeRawInput.isEmpty,
            let rimePreeditText = output.composition?.preeditText, !rimePreeditText.isEmpty
        else {
            return
        }

        // A partial selection starts a user-owned remainder composition. Drop
        // all rollback data from the previous automatic anchor, while retaining
        // a data-free rejected phase so undoing the partial cannot grant a
        // second automatic attempt in the original composition.
        if state.t9ReversibleAutoAnchorState.phase != .idle {
            state.t9ReversibleAutoAnchorState = T9ReversibleAutoAnchorState(
                phase: .rejected
            )
        }

        let isT9Remaining = T9CompositionCommitPolicy.isActiveT9Composition(
            usesT9InputSemantics: usesT9InputSemantics,
            rawInput: rimeRawInput
        )

        let remainingPreeditText: String
        let displayText: String
        let compositionTracker: String
        var internalRemainingRaw: String?
        // Previous raw may still be the full pre-selection digit run (librime often
        // retains it). Prefer remainingRaw already stored under an active partial.
        let previousRawForRemainder =
            state.partialCommit?.remainingRawInput ?? state.lastRimeOutput?.rawInput

        let remainingRawInput: String
        if isT9Remaining {
            // RC-2: derive the peel basis from engine-authoritative facts
            // first — never from the comment projection over the retained full
            // raw, which repeats the confirmed spelling and makes the peel a
            // no-op. A non-prefixed preedit (no confirmed CJK prefix) carries
            // no slot identity, so its digits are not adopted as remaining raw.
            let prefixMatched = rimePreeditText.hasPrefix(confirmedText)
            let rimeTailAfterConfirmed =
                prefixMatched
                ? String(rimePreeditText.dropFirst(confirmedText.count))
                : ""
            if prefixMatched {
                internalRemainingRaw = T9PinyinPathExtractor.internalDigitIdentity(
                    fromPreedit: rimeTailAfterConfirmed
                )
            }
            // Comment projection with the confirmed spelling stripped (RC-2
            // display), before the peel below.
            let commentPreferred = t9VisiblePreedit(
                for: output,
                confirmedSpelling: confirmedSpelling
            )
            // Unproven engine tails are not a reliable remaining-slot source.
            remainingPreeditText = commentPreferred
            displayText = confirmedText + commentPreferred
            // Peel confirmed digit slots when librime keeps the full raw (e.g. 6442692
            // after 你好 → remaining 92 for ya). Path bar must not see leading 6 → m/n/o.
            if let internalRemainingRaw, !internalRemainingRaw.isEmpty {
                // A selected segment may leave librime's full anchored raw in
                // place while preedit exposes a digit-only editable tail. That
                // tail is the new composition identity; keeping the full raw
                // would prevent the new `wo...` Path revision from rebuilding.
                remainingRawInput = internalRemainingRaw
            } else if rimeRawInput.unicodeScalars.contains(
                where: T9PinyinPathExtractor.isASCIILetter
            ) {
                // A refined raw (`shu'53`, `qiu'53`) already encodes the user's
                // Path Bar branch. Never replace it with the older pure-digit
                // identity merely because both still cover the same slot count.
                remainingRawInput = rimeRawInput
            } else if let peeled = peeledRemainingRawAfterConfirmedSlots(
                previousRaw: previousRawForRemainder,
                resultRaw: rimeRawInput,
                confirmedSlotLetters: confirmedSlotLetters,
                engineTail: prefixMatched ? rimeTailAfterConfirmed : nil
            ) {
                remainingRawInput = peeled
            } else {
                remainingRawInput =
                    T9PinyinPathExtractor.remainingT9RawAfterPartialCommit(
                        previousRaw: previousRawForRemainder,
                        resultRaw: internalRemainingRaw ?? rimeRawInput,
                        remainingDisplayPreedit: remainingPreeditText
                    ) ?? rimeRawInput
            }
            compositionTracker = remainingRawInput
        } else {
            displayText = partialDisplayText(
                confirmedText: confirmedText,
                rimePreeditText: rimePreeditText
            )
            remainingPreeditText = partialRemainingPreeditText(
                confirmedText: confirmedText,
                displayText: displayText
            )
            remainingRawInput = rimeRawInput
            compositionTracker = remainingPreeditText
        }

        // Path discovery uses candidates from live output, but digit identity for the
        // path bar must be the remaining raw (may differ from librime full raw).
        let pathAlignedOutput: RimeOutput
        if isT9Remaining,
            remainingRawInput != rimeRawInput
        {
            pathAlignedOutput = RimeOutput(
                rawInput: remainingRawInput,
                composition: RimeComposition(
                    preeditText: remainingPreeditText,
                    cursorPosition: remainingPreeditText.count
                ),
                candidates: output.candidates,
                committedText: output.committedText,
                hasMorePages: output.hasMorePages,
                highlightedIndex: output.highlightedIndex,
                candidatePageNumber: output.candidatePageNumber,
                candidateOrigin: output.candidateOrigin
            )
        } else {
            pathAlignedOutput = output
        }

        state.lastRimeOutput = pathAlignedOutput
        state.currentComposition = compositionTracker

        var finalRemainingPreedit = remainingPreeditText
        var finalDisplay = displayText
        if isT9Remaining {
            // Path state must land before host projection so provisional Paths
            // for the remaining focus are available in the same revision.
            _ = applyT9PinyinPathStateFromNewRimeOutput()
            let projected = t9VisiblePreedit(
                for: pathAlignedOutput,
                confirmedSpelling: confirmedSpelling
            )
            finalRemainingPreedit = projected
            finalDisplay = confirmedText + projected
        } else {
            _ = clearT9PinyinPathStateReturningEffect()
        }

        state.partialCommit = PartialCommitState(
            confirmedText: confirmedText,
            remainingRawInput: remainingRawInput,
            remainingPreeditText: finalRemainingPreedit,
            displayText: finalDisplay,
            checkpoint: checkpoint,
            source: source
        )
        updateInlinePreedit(finalDisplay, source: .compositionProjection)
        clearTypoCorrectionSuggestions()
    }

    private func isDigitOnlyPreeditTail(_ text: String) -> Bool {
        T9PinyinPathExtractor.internalDigitIdentity(fromPreedit: text) != nil
    }

    private func containsInternalT9Digit(_ text: String) -> Bool {
        text.unicodeScalars.contains(where: T9PinyinPathExtractor.isASCIIDigit)
    }

    func advanceCompositionRevision() {
        state.compositionRevision &+= 1
        // Reserve zero for the initial/no-composition state after overflow.
        if state.compositionRevision == 0 {
            state.compositionRevision = 1
        }
    }

    private func engineCommitIsHostSafe(_ committedText: String) -> Bool {
        if state.partialCommit?.source == .numberSuffix {
            return true
        }
        let confirmedPrefix = state.partialCommit?.confirmedText ?? ""
        let finalText =
            committedText.hasPrefix(confirmedPrefix)
            ? committedText
            : confirmedPrefix + committedText
        if !compositionProjectionContainsInternalDigit(finalText) {
            return true
        }
        // A digit-bearing string is semantic only when it was actually offered
        // as a candidate in the preceding live snapshot.
        return state.lastRimeOutput?.candidates.contains(where: { candidate in
            candidate.text == committedText
                || candidate.text == finalText
                || confirmedPrefix + candidate.text == finalText
        }) == true
    }

    private func failClosedUnexpectedEngineCommit() {
        clearInlinePreedit()
        state.currentComposition = ""
        // Reject candidate and paging authority together with the unsafe commit.
        state.lastRimeOutput = nil
        state.partialCommit = nil
        rimeEngine?.resetSession()
        clearTypoCorrectionSuggestions()
        _ = clearT9PinyinPathStateReturningEffect()
        Logger.shared.warning(
            "engine commit rejected: candidate-less internal digit projection",
            category: .display
        )
    }

    private func isEligibleTypoPartialCommit(_ correction: TypoCorrectionCommit) -> Bool {
        guard correction.edits.count == 1,
            correction.originalInput.count == correction.correctedInput.count,
            correction.originalInput != correction.correctedInput,
            let edit = correction.edits.first,
            edit.kind == .substitution
        else {
            return false
        }

        let originalLetters = Array(correction.originalInput)
        let correctedLetters = Array(correction.correctedInput)
        guard originalLetters.indices.contains(edit.index),
            correctedLetters.indices.contains(edit.index)
        else {
            return false
        }

        return originalLetters[edit.index] == edit.original
            && correctedLetters[edit.index] == edit.replacement
    }

    private func activeInputMatchesCorrectionOriginal(_ correction: TypoCorrectionCommit) -> Bool {
        if state.lastRimeOutput?.rawInput == correction.originalInput {
            return true
        }
        return state.currentComposition.filter { !$0.isWhitespace } == correction.originalInput
    }

    private func rebuildRimeOutput(for rawInput: String, using engine: RimeEngine) -> RimeOutput? {
        engine.resetSession()
        var output = RimeOutput()
        for character in rawInput {
            output = engine.processKey(String(character))
            if output.composition == nil,
                output.committedText == nil,
                !engine.isComposing()
            {
                engine.resetSession()
                return nil
            }
        }
        guard output.rawInput == rawInput, output.composition?.preeditText != nil else {
            engine.resetSession()
            return nil
        }
        return output
    }
}

extension String {
    fileprivate var nonEmpty: String? {
        isEmpty ? nil : self
    }
}

extension KeyboardController {
    /// 九键数字页直出。有组词时先按 `handleInsertDirectText` 的展示文本规则提交并 resetSession，
    /// 然后只插入字面量。不调用 `handleSymbolPageTextInput`，页保持 `.numbers`。
    func handleInsertT9NumberPadText(_ text: String) -> KeyboardEffect {
        var effects: KeyboardEffect = []
        if isResponsiveProvisionalAhead
            || state.currentComposition.contains(ResponsiveProvisionalComposition.placeholderScalar)
        {
            abandonResponsiveProvisionalL1WithoutHostCommit()
            rimeEngine?.resetSession()
            effects.insert(.compositionChanged)
        } else if !state.currentComposition.isEmpty {
            finishActiveCompositionAsDisplayText()
            rimeEngine?.resetSession()
            effects.insert(.compositionChanged)
        }
        insertText(text, source: .directText)
        effects.insert(.continuationChanged)
        return effects
    }
}
