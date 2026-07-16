import Foundation

/// Builds the visible T9 preedit string from raw digits and candidate comments.
///
/// Display may fall back to raw digits. Host commit paths must never use raw digits as commit text
/// (see `T9CompositionCommitPolicy`).
public enum T9PreeditResolver {
    public static func visiblePreedit(
        rawInput: String?,
        candidates: [RimeCandidate],
        highlightedIndex: Int?
    ) -> String {
        let raw = rawInput ?? ""
        if let comment = preferredComment(candidates: candidates, highlightedIndex: highlightedIndex),
           !comment.isEmpty
        {
            return comment
        }
        return raw
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
    /// Digit-shaped raw input alone does **not** enable T9 policy.
    /// Callers must pass `usesT9InputSemantics` from the same `RimeRuntimeSelection`
    /// that chose the effective schema and layout.
    public static func isActiveT9DigitComposition(
        usesT9InputSemantics: Bool,
        rawInput: String?
    ) -> Bool {
        guard usesT9InputSemantics else { return false }
        return isDigitOnlyComposition(rawInput: rawInput)
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
        guard isActiveT9DigitComposition(usesT9InputSemantics: usesT9InputSemantics, rawInput: rawInput) else {
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
        guard isActiveT9DigitComposition(usesT9InputSemantics: usesT9InputSemantics, rawInput: rawInput) else {
            return .notT9Composition
        }
        if let text = preferredCandidateText(candidates: candidates, highlightedIndex: highlightedIndex) {
            return .commitCandidate(text)
        }
        // Unconditional under T9: never commit raw digits.
        return .keepComposition
    }

    /// Language switch or automatic English while composition may be T9.
    public static func languageSwitchAction(
        usesT9InputSemantics: Bool,
        rawInput: String?
    ) -> T9CompositionCommitAction {
        guard isActiveT9DigitComposition(usesT9InputSemantics: usesT9InputSemantics, rawInput: rawInput) else {
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
