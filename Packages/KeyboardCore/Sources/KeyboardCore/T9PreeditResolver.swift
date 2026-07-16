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
    /// Insert newline (only when not composing).
    case insertNewline
    /// Insert space (only when not composing T9 digits without candidates handled above).
    case insertSpace
}

public enum T9CompositionCommitPolicy {
    public static func isT9DigitComposition(rawInput: String?) -> Bool {
        guard let rawInput, !rawInput.isEmpty else { return false }
        return rawInput.unicodeScalars.allSatisfy { CharacterSet.decimalDigits.contains($0) }
    }

    /// Space while T9 composition is active.
    public static func spaceAction(
        rawInput: String?,
        candidates: [RimeCandidate],
        highlightedIndex: Int?
    ) -> T9CompositionCommitAction {
        guard isT9DigitComposition(rawInput: rawInput) else {
            return .insertSpace
        }
        if let text = preferredCandidateText(candidates: candidates, highlightedIndex: highlightedIndex) {
            return .commitCandidate(text)
        }
        return .keepComposition
    }

    /// Return while T9 composition is active.
    public static func returnAction(
        rawInput: String?,
        candidates: [RimeCandidate],
        highlightedIndex: Int?
    ) -> T9CompositionCommitAction {
        guard isT9DigitComposition(rawInput: rawInput) else {
            return .insertNewline
        }
        if let text = preferredCandidateText(candidates: candidates, highlightedIndex: highlightedIndex) {
            return .commitCandidate(text)
        }
        // Unconditional: never commit raw digits.
        return .keepComposition
    }

    /// Language switch or automatic English while T9 composition is active.
    public static func languageSwitchAction(rawInput: String?) -> T9CompositionCommitAction {
        if isT9DigitComposition(rawInput: rawInput) {
            return .abandonComposition
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
