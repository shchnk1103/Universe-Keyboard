import Foundation

/// Internal pure identity for T9 digit slots + confirmed Path syllables.
///
/// Gate 5 Phase 1 **β-limited** (PD-…-GATE5-PHASE1-BETA):
/// - Append/Delete operate only on `sourceDigits`.
/// - Partial can realign only when remaining raw is a **strict unique suffix** of
///   the pre-selection source (shortened remainder).
/// - Unchanged / non-suffix remaining → **fail-closed** (no slot guessing).
///
/// Forbidden as inputs: candidate text length, comment, preedit display, ranking,
/// `sel_*`, caret, commit-preview length.
struct T9CompositionIdentity: Equatable, Sendable {
    var sourceDigits: String
    var confirmedSyllables: [String]
    /// Index into confirmedSyllables for current focus (0…count).
    var focusedSegmentIndex: Int

    init(
        sourceDigits: String,
        confirmedSyllables: [String] = [],
        focusedSegmentIndex: Int? = nil
    ) {
        self.sourceDigits = sourceDigits
        self.confirmedSyllables = confirmedSyllables
        let maxFocus = confirmedSyllables.count
        if let focusedSegmentIndex {
            self.focusedSegmentIndex = min(max(0, focusedSegmentIndex), maxFocus)
        } else {
            self.focusedSegmentIndex = maxFocus
        }
    }

    static func from(pathState: T9PinyinPathState) -> T9CompositionIdentity? {
        guard let source = pathState.segmentSourceDigits,
              !source.isEmpty,
              source.allSatisfy(\.isNumber)
        else { return nil }
        return T9CompositionIdentity(
            sourceDigits: source,
            confirmedSyllables: pathState.confirmedSegmentValues,
            focusedSegmentIndex: pathState.focusedSegmentIndex
        )
    }

    var confirmedLetterCount: Int {
        T9PinyinPathExtractor.letterCount(ofSyllables: confirmedSyllables)
    }

    /// Digits after confirmed syllables (current focus tail).
    var remainingDigits: String {
        let letters = confirmedLetterCount
        guard letters < sourceDigits.count else { return "" }
        return String(sourceDigits.dropFirst(letters))
    }

    /// RIME `replaceInput` raw owned by Core identity (not host display).
    var replacementRawInput: String {
        if confirmedSyllables.isEmpty {
            return sourceDigits
        }
        let rem = remainingDigits
        if rem.isEmpty {
            return confirmedSyllables.joined(separator: "'")
        }
        return confirmedSyllables.joined(separator: "'") + "'" + rem
    }

    /// How Path bar should rebuild for this identity.
    ///
    /// When there is no trailing digit tail, re-focus the **last** confirmed
    /// syllable so the bar does not go empty (Human: path vanished at sole `qing`).
    struct FocusPathPlan: Equatable, Sendable {
        var focusDigits: String
        /// Confirmed prefix **before** the focused syllable (may drop the last
        /// confirmed when re-focusing it).
        var pathConfirmedSyllables: [String]
        var focusedSegmentIndex: Int
        /// When re-focusing last confirmed, that syllable label (for resync).
        var refocusedSyllable: String?
    }

    func focusPathPlan() -> FocusPathPlan {
        let rem = remainingDigits
        if !rem.isEmpty {
            return FocusPathPlan(
                focusDigits: rem,
                pathConfirmedSyllables: confirmedSyllables,
                focusedSegmentIndex: confirmedSyllables.count,
                refocusedSyllable: nil
            )
        }
        if let last = confirmedSyllables.last {
            let n = T9PinyinPathExtractor.asciiLetterCount(in: last)
            let focus = n > 0 && n <= sourceDigits.count
                ? String(sourceDigits.suffix(n))
                : sourceDigits
            let prefix = Array(confirmedSyllables.dropLast())
            return FocusPathPlan(
                focusDigits: focus,
                pathConfirmedSyllables: prefix,
                focusedSegmentIndex: prefix.count,
                refocusedSyllable: last
            )
        }
        return FocusPathPlan(
            focusDigits: sourceDigits,
            pathConfirmedSyllables: [],
            focusedSegmentIndex: 0,
            refocusedSyllable: nil
        )
    }

    // MARK: - Events

    func appendingDigit(_ digit: Character) -> T9CompositionIdentity? {
        guard digit.isASCII, digit.isNumber else { return nil }
        var next = self
        next.sourceDigits.append(digit)
        return next
    }

    func deletingLastDigit() -> T9CompositionIdentity? {
        guard sourceDigits.count > 1 else { return nil }
        var next = self
        next.sourceDigits.removeLast()
        // Drop trailing confirmed/focus syllables that no longer fit the shortened source.
        while T9PinyinPathExtractor.letterCount(ofSyllables: next.confirmedSyllables)
            > next.sourceDigits.count
        {
            guard !next.confirmedSyllables.isEmpty else { break }
            next.confirmedSyllables.removeLast()
        }
        next.focusedSegmentIndex = next.confirmedSyllables.count
        return next
    }

    /// Align identity after nested partial when remaining raw is engine-shortened.
    ///
    /// - Pure-digit remainder that is a **strict prefix or equal** of the unresolved
    ///   tail after previous confirmed syllables → keep those confirmed, adopt remainder.
    /// - Mixed/apostrophe remainder whose T9 encoding is a **unique strict suffix**
    ///   of `sourceDigits` → adopt that suffix as source and letter segments as confirmed.
    /// - Remaining encoding equals full previous source (unchanged-raw B class) → nil
    ///   (fail-closed; caller must not invent consumption).
    static func afterPartialCommit(
        previousSource: String,
        previousConfirmed: [String],
        remainingRaw: String
    ) -> T9CompositionIdentity? {
        guard previousSource.allSatisfy(\.isNumber), !previousSource.isEmpty else { return nil }
        let remaining = remainingRaw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !remaining.isEmpty else { return nil }

        if remaining.allSatisfy(\.isNumber) {
            return alignPureDigitRemainder(
                previousSource: previousSource,
                previousConfirmed: previousConfirmed,
                liveDigits: remaining
            )
        }

        return alignMixedRemainder(
            previousSource: previousSource,
            remainingRaw: remaining
        )
    }

    // MARK: - Private alignment

    private static func alignPureDigitRemainder(
        previousSource: String,
        previousConfirmed: [String],
        liveDigits: String
    ) -> T9CompositionIdentity? {
        let confirmedLetters = T9PinyinPathExtractor.letterCount(ofSyllables: previousConfirmed)
        guard confirmedLetters > 0, confirmedLetters < previousSource.count else {
            // No confirmed path syllables: live remainder must be unique suffix of source.
            guard previousSource.hasSuffix(liveDigits), liveDigits.count < previousSource.count
            else { return nil }
            return T9CompositionIdentity(
                sourceDigits: liveDigits,
                confirmedSyllables: [],
                focusedSegmentIndex: 0
            )
        }

        let unresolvedTail = String(previousSource.dropFirst(confirmedLetters))
        guard !unresolvedTail.isEmpty else { return nil }

        // Equal tail: full-phrase partial (A) leaves the whole unresolved digit tail.
        // Do not re-install a "stale confirmed" snapshot here — return nil so the
        // normal remaining-raw Path refresh owns the new focus (wo…). Nested peel
        // only applies when live remainder is *strictly shorter* than the tail.
        if liveDigits == unresolvedTail {
            return nil
        }

        // Strict shorter remainder of unresolved tail (nested digit peel).
        guard liveDigits.count < unresolvedTail.count,
              unresolvedTail.hasPrefix(liveDigits) || unresolvedTail.hasSuffix(liveDigits)
        else { return nil }

        let alignedSource = String(previousSource.prefix(confirmedLetters)) + liveDigits
        return T9CompositionIdentity(
            sourceDigits: alignedSource,
            confirmedSyllables: previousConfirmed,
            focusedSegmentIndex: previousConfirmed.count
        )
    }

    private static func alignMixedRemainder(
        previousSource: String,
        remainingRaw: String
    ) -> T9CompositionIdentity? {
        guard let encoded = encodeMixedRawToDigits(remainingRaw) else { return nil }

        // Unchanged-raw class: remaining still encodes the full pre-selection source.
        if encoded == previousSource {
            return nil
        }

        // Must be unique strict suffix of previous source.
        guard previousSource.hasSuffix(encoded),
              encoded.count < previousSource.count
        else { return nil }

        // Suffix uniqueness: no earlier occurrence that could also be a suffix align.
        // (hasSuffix already picks the terminal alignment; require no second full match.)
        let occurrences = previousSource.indicesOf(substring: encoded)
        guard occurrences.count == 1 else { return nil }

        let letterSegments = letterSegments(fromMixedRaw: remainingRaw)
        // Every letter segment must be catalog-legal and match the corresponding slice.
        var cursor = 0
        var confirmed: [String] = []
        for segment in letterSegments {
            let need = T9PinyinPathExtractor.asciiLetterCount(in: segment)
            guard need > 0, cursor + need <= encoded.count else { return nil }
            let slice = String(encoded[encoded.index(encoded.startIndex, offsetBy: cursor)..<encoded.index(encoded.startIndex, offsetBy: cursor + need)])
            let catalog = T9PinyinSyllableCatalog.completeSyllables(matchingDigits: slice)
            guard catalog.contains(segment.lowercased()) || segment.count == 1 else { return nil }
            // Single-letter prefixes are allowed only if they match key group; keep complete only for confirmed.
            if segment.count > 1 {
                confirmed.append(segment.lowercased())
            }
            cursor += need
        }

        return T9CompositionIdentity(
            sourceDigits: encoded,
            confirmedSyllables: confirmed,
            focusedSegmentIndex: confirmed.count
        )
    }

    /// Encode apostrophe/letter/digit mixed raw into a pure digit signature.
    private static func encodeMixedRawToDigits(_ raw: String) -> String? {
        var digits = ""
        var letterRun = ""
        func flushLetters() -> Bool {
            guard !letterRun.isEmpty else { return true }
            let lower = letterRun.lowercased()
            let sig = t9DigitSignature(forLetters: lower)
            guard !sig.isEmpty, sig.count == lower.count else { return false }
            digits += sig
            letterRun = ""
            return true
        }

        for ch in raw {
            if ch == "'" || ch == " " {
                guard flushLetters() else { return nil }
                continue
            }
            if ch.isNumber {
                guard flushLetters() else { return nil }
                digits.append(ch)
                continue
            }
            if ch.isLetter {
                letterRun.append(ch)
                continue
            }
            return nil
        }
        guard flushLetters() else { return nil }
        return digits.isEmpty ? nil : digits
    }

    private static func letterSegments(fromMixedRaw raw: String) -> [String] {
        raw.split(whereSeparator: { $0 == "'" || $0 == " " || $0.isNumber })
            .map { String($0).lowercased() }
            .filter { !$0.isEmpty && $0.allSatisfy(\.isLetter) }
    }

    private static func t9DigitSignature(forLetters letters: String) -> String {
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
            guard let d = map[ch] else { return "" }
            out.append(d)
        }
        return out
    }
}

private extension String {
    func indicesOf(substring: String) -> [String.Index] {
        guard !substring.isEmpty, substring.count <= count else { return [] }
        var result: [String.Index] = []
        var search = startIndex
        while search <= index(endIndex, offsetBy: -substring.count) {
            if self[search...].hasPrefix(substring) {
                result.append(search)
            }
            search = index(after: search)
        }
        return result
    }
}
