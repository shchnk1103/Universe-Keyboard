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
    /// page, host type or document changed). Any invalidation also revokes
    /// the trailing-space delete-eligibility mark (同清同活 with the echo
    /// suppression bound to it). Returns an effect only when the visible
    /// state actually changed.
    @discardableResult
    func clearEnglishCandidates() -> KeyboardEffect {
        state.englishTrailingSpaceMark = nil
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
    /// same transaction without ever doubling it. Leading and trailing
    /// decisions are independent (EN-AUTOSPACE-IMMEDIATE-001 abolished the
    /// old `leadingSpaceAdded` suppression). When autospace is enabled and
    /// the host type is not disabled, the trailing space is written
    /// immediately in the same transaction whenever the right neighbor is
    /// unknown, the document end, or a non-whitespace non-attached
    /// punctuation scalar. On success `clearEnglishCandidates()` runs BEFORE
    /// the new 「已补尾随空格且拥有回删资格」 mark is armed, so the echo
    /// suppression bound to the mark (同清同活) can never observe stale
    /// candidates. No text is logged (ADR 0007).
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
        if englishCandidateAutospaceEnabled,
            !EnglishAutospace.isDisabled(for: state.activeKeyboardType)
        {
            // Live left-neighbor read after the replacement — the same inputs
            // `spacedCommitText` sees in `insertText`. Independent from the
            // trailing decision below.
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
                committing: candidate
            )
        } else {
            trailing = false
        }

        // The English-mode sentence-terminator leading space rides in the
        // same single insertion transaction; `spacedCommitText` sees a
        // whitespace first scalar and never doubles it. `MixedScriptSpacing`
        // keeps owning the Han boundary inside `insertText`. Leading and
        // trailing are concatenated in this one `insertText` (r3 §2.1).
        let transactionText = (leading ? " " : "") + candidate + (trailing ? " " : "")
        insertText(transactionText, source: .candidate)
        // 候选提交路径：先清候选（含旧标记撤销），再武装「已补尾随空格且
        // 拥有回删资格」状态。回声抑制随标记同清同活。
        let effects = clearEnglishCandidates()
        if trailing {
            state.englishTrailingSpaceMark = EnglishTrailingSpaceMark(
                committedTransactionText: transactionText
            )
        }
        return effects
    }

    private static func isASCIILetter(_ scalar: Unicode.Scalar) -> Bool {
        (0x41...0x5A).contains(scalar.value) || (0x61...0x7A).contains(scalar.value)
    }
}
