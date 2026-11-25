import Foundation

/// Trailing-space decision after an English candidate commit.
///
/// Contract (EN-AUTOSPACE-IMMEDIATE-001, r3 §2): the trailing decision is
/// independent of the leading decision — the old `leadingSpaceAdded`
/// suppression and the deferred 「待补空格」 semantics are abolished. When the
/// feature is enabled and the host type is not disabled, a candidate whose
/// last scalar is non-whitespace gets exactly one ASCII space appended in the
/// same `insertText` transaction whenever the right neighbor is unknown
/// (`nil`), the document end (`""`), or any non-whitespace scalar outside the
/// frozen attached-punctuation set. A whitespace or attached-punctuation
/// right neighbor gets no space. The function never logs text (ADR 0007).
public enum EnglishAutospace {
    /// 冻结的英文附着标点集合（r3 §2.1）：右邻命中这些字符时不补尾随空格
    /// （它们与词「附着」）。不含 `/`、`@`、`#`、引号及中文轮换标点
    /// （取代旧版排除 connector 的右侧规则）。
    public static let attachedPunctuation: Set<Character> = [
        ".", ",", "?", "!", ";", ":", ")", "]", "}",
    ]

    static let attachedPunctuationScalars: Set<Unicode.Scalar> = Set(
        attachedPunctuation.flatMap(\.unicodeScalars)
    )

    public static func trailingSpace(after: String?, committing: String) -> Bool {
        guard let last = committing.unicodeScalars.last,
            !last.properties.isWhitespace
        else { return false }
        // Unknown right neighbor (`nil`) and the document end (`""`) are the
        // undecided boundary toward the next word: the space is written
        // immediately in the same transaction (immediate trailing space).
        guard let neighbor = after?.unicodeScalars.first else { return true }
        if neighbor.properties.isWhitespace { return false }
        return !attachedPunctuationScalars.contains(neighbor)
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
}
