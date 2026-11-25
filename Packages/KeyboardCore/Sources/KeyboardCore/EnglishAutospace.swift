import Foundation

/// Trailing-space decision after an English candidate commit.
///
/// Contract (arch Minor m1, aligned with `MixedScriptSpacing` and the
/// URL-MODE-ENGLISH design):
/// - Reads only the boundary scalars; `nil` right context is treated as an
///   unknown right neighbor and conservatively adds no space.
/// - An empty right context is the document end: no space.
/// - Whitespace, punctuation and connector symbols (`.` `@` `:` `#` `/` …)
///   ahead of the caret mean no space; a word-like neighbor (letter, digit,
///   Han) does get one.
/// - When `MixedScriptSpacing` already added the leading boundary space, the
///   trailing decision skips: one spacing decision per transaction.
/// The function never logs text (ADR 0007).
public enum EnglishAutospace {
    public static func trailingSpace(
        after: String?,
        committing: String,
        leadingSpaceAdded: Bool
    ) -> Bool {
        guard !leadingSpaceAdded else { return false }
        guard let last = committing.unicodeScalars.last,
            !last.properties.isWhitespace
        else { return false }
        guard let neighbor = after?.unicodeScalars.first else { return false }
        if neighbor.properties.isWhitespace { return false }
        return isWordLikeScalar(neighbor)
    }

    /// English-mode leading rule for a candidate committed right after a
    /// sentence terminator (`.` `!` `?` and the full-width CJK forms): the
    /// candidate starts a new sentence word and carries one ASCII space
    /// before it (`Word.` + `Hello` → `Word. Hello`; real-device bug report,
    /// EN-mode fix r1). Conservative elsewhere: an unknown read, a whitespace
    /// neighbor (space already typed), a whitespace commit head and a
    /// non-letter commit head (digits: versions, addresses) all return false.
    /// Tight domain-style text (`google.com`) is typed-letter traffic and
    /// never reaches this commit-time leading decision; only a tapped
    /// candidate right after a terminator gets the sentence space.
    public static func leadingSpaceAfterSentenceTerminator(
        before: String?,
        committing: String
    ) -> Bool {
        guard let neighbor = before?.unicodeScalars.last,
            let first = committing.unicodeScalars.first,
            !neighbor.properties.isWhitespace,
            !first.properties.isWhitespace
        else { return false }
        guard isASCIILetter(first) else { return false }
        return AutoCapitalizationRules.sentenceTerminators.contains(Character(neighbor))
    }

    /// URL / e-mail / web-search fields never receive candidate autospace.
    public static func isDisabled(for keyboardType: KeyboardType) -> Bool {
        keyboardType == .URL || keyboardType == .emailAddress || keyboardType == .webSearch
    }

    /// Stored values are honored only when they are true CF booleans
    /// (`CFGetTypeID == CFBooleanGetTypeID`). Missing keys, integers wrapped
    /// in NSNumber, and any other type all stay enabled. Without full access
    /// the switch is forced on and nothing is written back.
    public static func isEnabled(stored: Any?, hasFullAccess: Bool) -> Bool {
        if !hasFullAccess { return true }
        guard let stored,
            CFGetTypeID(stored as CFTypeRef) == CFBooleanGetTypeID()
        else { return true }
        return (stored as? NSNumber)?.boolValue ?? true
    }

    private static func isASCIILetter(_ scalar: Unicode.Scalar) -> Bool {
        (0x41...0x5A).contains(scalar.value) || (0x61...0x7A).contains(scalar.value)
    }

    private static func isWordLikeScalar(_ scalar: Unicode.Scalar) -> Bool {
        if (0x41...0x5A).contains(scalar.value) || (0x61...0x7A).contains(scalar.value) {
            return true
        }
        if (0x30...0x39).contains(scalar.value) { return true }
        return (0x3400...0x4DBF).contains(scalar.value)
            || (0x4E00...0x9FFF).contains(scalar.value)
    }
}
