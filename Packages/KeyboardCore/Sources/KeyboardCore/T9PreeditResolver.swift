import Foundation

/// Builds the visible T9 preedit string from raw digits and candidate comments.
///
/// Candidate comments are the preferred user-facing spelling. When comments are
/// unavailable, preserve only letters the user has already made explicit through
/// path refinement; unresolved T9 digits remain internal engine identity.
public enum T9PreeditResolver {
    public static func visiblePreedit(
        rawInput: String?,
        candidates: [RimeCandidate],
        highlightedIndex: Int?
    ) -> String {
        let raw = rawInput ?? ""
        if let comment = preferredComment(candidates: candidates, highlightedIndex: highlightedIndex),
           !comment.isEmpty,
           !comment.unicodeScalars.contains(where: T9PinyinPathExtractor.isASCIIDigit)
        {
            return projectCommentToEnteredSlots(comment, rawInput: raw)
        }
        return String(
            raw.unicodeScalars.filter(T9PinyinPathExtractor.isASCIILetter)
        )
    }

    public static func preferredComment(
        candidates: [RimeCandidate],
        highlightedIndex: Int?
    ) -> String? {
        if let highlightedIndex,
           candidates.indices.contains(highlightedIndex),
           let comment = candidates[highlightedIndex].comment,
           !comment.isEmpty
        {
            return comment
        }
        if let first = candidates.first?.comment, !first.isEmpty {
            return first
        }
        return nil
    }

    /// RIME may predict more letters than the number of T9 slots the user has
    /// entered (`8 -> ta`). Keep that prediction internal and reveal at most one
    /// visible ASCII letter per explicit letter/digit slot (`8 -> t`, `86 -> to`).
    private static func projectCommentToEnteredSlots(
        _ comment: String,
        rawInput: String
    ) -> String {
        let slotLimit = rawInput.unicodeScalars.reduce(into: 0) { count, scalar in
            if T9PinyinPathExtractor.isASCIILetter(scalar)
                || T9PinyinPathExtractor.isASCIIDigit(scalar)
            {
                count += 1
            }
        }
        guard slotLimit > 0 else { return "" }

        let commentLetterCount = comment.unicodeScalars.reduce(into: 0) { count, scalar in
            if T9PinyinPathExtractor.isASCIILetter(scalar) { count += 1 }
        }
        guard commentLetterCount > slotLimit else { return comment }

        var visibleScalars: [Unicode.Scalar] = []
        var visibleLetterCount = 0
        for scalar in comment.unicodeScalars {
            if T9PinyinPathExtractor.isASCIILetter(scalar) {
                guard visibleLetterCount < slotLimit else { break }
                visibleScalars.append(scalar)
                visibleLetterCount += 1
            } else if T9PinyinPathExtractor.isASCIISeparator(scalar),
                      visibleLetterCount > 0,
                      visibleLetterCount < slotLimit
            {
                visibleScalars.append(scalar)
            }
        }
        return String(String.UnicodeScalarView(visibleScalars))
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

/// Host-commit decisions while a T9 composition is active.
public enum T9CompositionCommitAction: Sendable, Equatable {
    /// Commit highlighted or first candidate text.
    case commitCandidate(String)
    /// Keep composition; do not write host text.
    case keepComposition
    /// Abandon composition without host commit (language / auto-English switch).
    case abandonComposition
    /// Insert newline (only when not composing under T9 semantics).
    case insertNewline
    /// Insert space (non-T9 or not composing).
    case insertSpace
    /// Defer to non-T9 composition handling.
    case notT9Composition
}

public enum T9CompositionCommitPolicy {
    /// Valid T9 raw input alone does **not** enable T9 policy without semantics.
    /// Callers must pass `usesT9InputSemantics` from the same `RimeRuntimeSelection`
    /// that chose the effective schema and layout.
    ///
    /// After ADR 0020, “active T9 composition” includes pure digits, pure letters,
    /// and letter/digit/separator mixes produced by precise path refinement.
    public static func isActiveT9Composition(
        usesT9InputSemantics: Bool,
        rawInput: String?
    ) -> Bool {
        guard usesT9InputSemantics else { return false }
        return T9PinyinPathExtractor.isValidT9RawInput(rawInput)
    }

    /// Historical name retained for call sites; same as `isActiveT9Composition`.
    public static func isActiveT9DigitComposition(
        usesT9InputSemantics: Bool,
        rawInput: String?
    ) -> Bool {
        isActiveT9Composition(usesT9InputSemantics: usesT9InputSemantics, rawInput: rawInput)
    }

    public static func isDigitOnlyComposition(rawInput: String?) -> Bool {
        guard let rawInput, !rawInput.isEmpty else { return false }
        return rawInput.unicodeScalars.allSatisfy { CharacterSet.decimalDigits.contains($0) }
    }

    /// Space while composition may be T9.
    public static func spaceAction(
        usesT9InputSemantics: Bool,
        rawInput: String?,
        candidates: [RimeCandidate],
        highlightedIndex: Int?
    ) -> T9CompositionCommitAction {
        guard isActiveT9Composition(usesT9InputSemantics: usesT9InputSemantics, rawInput: rawInput) else {
            return .notT9Composition
        }
        if let text = preferredCandidateText(candidates: candidates, highlightedIndex: highlightedIndex) {
            return .commitCandidate(text)
        }
        return .keepComposition
    }

    /// Return while composition may be T9.
    public static func returnAction(
        usesT9InputSemantics: Bool,
        rawInput: String?,
        candidates: [RimeCandidate],
        highlightedIndex: Int?
    ) -> T9CompositionCommitAction {
        guard isActiveT9Composition(usesT9InputSemantics: usesT9InputSemantics, rawInput: rawInput) else {
            return .notT9Composition
        }
        if let text = preferredCandidateText(candidates: candidates, highlightedIndex: highlightedIndex) {
            return .commitCandidate(text)
        }
        // Unconditional under T9: never commit raw input (digits, letters, or mixed).
        return .keepComposition
    }

    /// Language switch or automatic English while composition may be T9.
    public static func languageSwitchAction(
        usesT9InputSemantics: Bool,
        rawInput: String?
    ) -> T9CompositionCommitAction {
        guard isActiveT9Composition(usesT9InputSemantics: usesT9InputSemantics, rawInput: rawInput) else {
            return .notT9Composition
        }
        return .abandonComposition
    }

    private static func preferredCandidateText(
        candidates: [RimeCandidate],
        highlightedIndex: Int?
    ) -> String? {
        if let highlightedIndex,
           candidates.indices.contains(highlightedIndex)
        {
            let text = candidates[highlightedIndex].text
            if !text.isEmpty { return text }
        }
        let first = candidates.first?.text
        if let first, !first.isEmpty { return first }
        return nil
    }
}
