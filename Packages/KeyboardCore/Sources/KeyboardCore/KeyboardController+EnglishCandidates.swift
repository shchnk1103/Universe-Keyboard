extension KeyboardController {
    /// English letters-page typing feeds the prefix buffer. Non-ASCII-letter
    /// keys end the current word. Pure memory on the key path (no file IO).
    func noteEnglishKeyInput(_ key: String) -> KeyboardEffect {
        guard state.inputMode == .english, state.currentPage == .letters else { return [] }
        guard key.count == 1, let scalar = key.unicodeScalars.first,
            Self.isASCIILetter(scalar)
        else {
            return clearEnglishCandidates()
        }

        var english = state.englishCandidate
        guard english.prefix.unicodeScalars.count < EnglishCandidateState.maximumPrefixLength
        else { return [] }
        english.prefix.unicodeScalars.append(scalar)
        state.englishCandidate = english
        return refreshEnglishCandidates()
    }

    /// Re-queries the injected provider for the current prefix and stores the
    /// case-aligned suggestions bound to the provider's source version.
    func refreshEnglishCandidates() -> KeyboardEffect {
        guard let provider = englishCandidateProvider,
            !state.englishCandidate.prefix.isEmpty
        else {
            return clearEnglishCandidates()
        }

        var english = state.englishCandidate
        let words = provider.candidates(
            for: english.prefix.lowercased(),
            limit: EnglishCandidateState.maximumSuggestionCount
        )
        english.suggestions = words.map {
            EnglishCandidateCase.aligned(prefix: english.prefix, word: $0)
        }
        english.sourceVersion = provider.sourceVersion
        guard english != state.englishCandidate else { return [] }
        state.englishCandidate = english
        return .englishCandidatesChanged
    }

    /// Clears the prefix buffer and its suggestions (word finished, mode,
    /// page, host type or document changed). Any invalidation also recalls a
    /// deferred autospace (space/return/non-letter input, backward delete,
    /// mode/page/host-type switch, external edit). Returns an effect only
    /// when the visible state actually changed.
    @discardableResult
    func clearEnglishCandidates() -> KeyboardEffect {
        state.pendingEnglishAutospace = false
        guard !state.englishCandidate.isEmpty else { return [] }
        state.englishCandidate = EnglishCandidateState()
        return .englishCandidatesChanged
    }

    /// Drops the last typed character (English Delete) and refreshes.
    func dropLastEnglishPrefixCharacter() -> KeyboardEffect {
        guard state.inputMode == .english,
            state.englishCandidate.prefix.unicodeScalars.count > 0
        else {
            return clearEnglishCandidates()
        }

        var english = state.englishCandidate
        english.prefix.unicodeScalars.removeLast()
        state.englishCandidate = english
        return refreshEnglishCandidates()
    }

    /// Commits a confirmed English prefix candidate.
    ///
    /// Scope verification first (URL-MODE-ENGLISH contract): the typed prefix
    /// must still sit immediately before the caret; an unreadable left context
    /// counts as unknown scope and the commit is rejected without any host
    /// write. The typed prefix is then replaced by deleting it backward, and
    /// the candidate body plus at most one leading and one trailing ASCII
    /// space go out as one insertion transaction: a single atomic
    /// `insertText` — the spaces and the body are never separate inserts, so
    /// no split state with a written body and an unwritten space can exist.
    /// The left boundary is decided after the replacement at the same live
    /// read `spacedCommitText` uses inside `insertText`: `MixedScriptSpacing`
    /// owns the Han boundary (applied inside `insertText`), and the
    /// English-mode sentence-terminator rule
    /// (`EnglishAutospace.leadingSpaceAfterSentenceTerminator`) rides in the
    /// same transaction without ever doubling it. The trailing decision
    /// skips when either boundary already produced the leading space; at a
    /// known-empty right context the trailing space is deferred
    /// (`pendingEnglishAutospace`) to the next directly typed letter. The
    /// right neighbor is read exactly once through the unified
    /// `documentContextAfterInput` read point; `nil` stays conservative.
    /// No text is logged (ADR 0007).
    func commitEnglishCandidate(_ candidate: String) -> KeyboardEffect {
        // Fail closed (Quality F-01): without a host text proxy there is no
        // host to write to and no post-insert boundary to confirm, so the
        // transaction is rejected at the entry and the stale candidates are
        // dropped. Together with the left-prefix scope check below this
        // forms the provable commit boundary under UIKit's Void-returning
        // `UITextDocumentProxy.insertText(_:)`.
        guard textClient != nil else { return clearEnglishCandidates() }
        let prefix = state.englishCandidate.prefix
        let prefixLength = prefix.unicodeScalars.count

        if prefixLength > 0 {
            guard let before = documentContextBeforeInput?(),
                before.unicodeScalars.suffix(prefixLength)
                    .elementsEqual(prefix.unicodeScalars)
            else {
                // Scope moved or is unknown: stale candidates must neither
                // delete nor write, and the visible state is invalidated.
                return clearEnglishCandidates()
            }
            if let textClient {
                for _ in 0..<prefixLength {
                    textClient.deleteBackward()
                }
            }
        }

        let trailing: Bool
        var leading = false
        var deferTrailingSpaceToNextLetter = false
        if englishCandidateAutospaceEnabled,
            !EnglishAutospace.isDisabled(for: state.activeKeyboardType)
        {
            // Live left-neighbor read after the replacement — the same inputs
            // `spacedCommitText` sees in `insertText`.
            let before = documentContextBeforeInput?()
            leading =
                MixedScriptSpacing.leadingSpace(before: before, committing: candidate) == " "
                || (state.inputMode == .english
                    && EnglishAutospace.leadingSpaceAfterSentenceTerminator(
                        before: before,
                        committing: candidate
                    ))
            let after = documentContextAfterInput?()
            trailing = EnglishAutospace.trailingSpace(
                after: after,
                committing: candidate,
                leadingSpaceAdded: leading
            )
            // Known-empty right context (document end): the boundary toward
            // the next word is undecided at commit time, so the trailing
            // space is deferred — the design r1 「标记未补」 mark. The next
            // directly typed ASCII letter in English mode carries it; every
            // other input (punctuation, connector symbols, space, return) is
            // exempt and recalls it; a backward delete recalls it too.
            deferTrailingSpaceToNextLetter = (after == "")
        } else {
            trailing = false
        }

        // The English-mode sentence-terminator leading space rides in the
        // same single insertion transaction; `spacedCommitText` sees a
        // whitespace first scalar and never doubles it. `MixedScriptSpacing`
        // keeps owning the Han boundary inside `insertText`.
        insertText((leading ? " " : "") + candidate + (trailing ? " " : ""), source: .candidate)
        let effects = clearEnglishCandidates()
        if deferTrailingSpaceToNextLetter {
            state.pendingEnglishAutospace = true
            // 宿主对本事务的 textDidChange 回声即将异步到达（真机时序，
            // EN-AUTOSPACE-DEVICE-FIX-001）：置一次性抑制标志，回声不得
            // 撤回刚武装的 deferred autospace。
            suppressNextExternalChangeForCandidateEcho = true
        }
        return effects
    }

    /// Consumes a deferred trailing autospace for a directly inserted key.
    /// The next bare ASCII letter typed in English mode carries the deferred
    /// space (`Word` + `h` → `Word h`); every other input — punctuation,
    /// connector symbols, digits — is exempt and only recalls the pending
    /// state, so `Word` + `.` stays `Word.` (frozen design connector
    /// exemption). Never logs text (ADR 0007).
    func consumeEnglishAutospaceForDirectKey(_ key: String) -> String {
        guard state.pendingEnglishAutospace else { return key }
        state.pendingEnglishAutospace = false
        guard englishCandidateAutospaceEnabled,
            state.inputMode == .english,
            key.unicodeScalars.count == 1,
            let scalar = key.unicodeScalars.first,
            Self.isASCIILetter(scalar)
        else { return key }
        return " " + key
    }

    private static func isASCIILetter(_ scalar: Unicode.Scalar) -> Bool {
        (0x41...0x5A).contains(scalar.value) || (0x61...0x7A).contains(scalar.value)
    }
}
