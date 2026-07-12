import Foundation

/// Describes the user action that caused text to become final in the host field.
/// It deliberately contains no candidate, composition, or host-application data.
public enum CommittedTextSource: String, Codable, CaseIterable, Sendable {
    case key
    case candidate
    case correction
    case space
    case returnKey
    case directText
    case emoji
    case compositionFinalization
    case engineCommit
}

/// Ephemeral observation emitted only after text has been committed to the host.
/// Consumers must classify `text` immediately and must never persist it.
public struct CommittedTextEvent: Equatable, Sendable {
    public let text: String
    public let source: CommittedTextSource

    public init(text: String, source: CommittedTextSource) {
        self.text = text
        self.source = source
    }
}
/// Content-free counters derived from one or more committed grapheme clusters.
public struct TypingStatisticsDelta: Codable, Equatable, Sendable {
    public var committedGraphemeCount = 0
    public var cjkCharacterCount = 0
    public var latinLetterCount = 0
    public var digitCount = 0
    public var punctuationCount = 0
    public var whitespaceCount = 0
    public var newlineCount = 0
    public var emojiCount = 0
    public var otherCount = 0

    public init() {}

    public static func += (lhs: inout Self, rhs: Self) {
        lhs.committedGraphemeCount += rhs.committedGraphemeCount
        lhs.cjkCharacterCount += rhs.cjkCharacterCount
        lhs.latinLetterCount += rhs.latinLetterCount
        lhs.digitCount += rhs.digitCount
        lhs.punctuationCount += rhs.punctuationCount
        lhs.whitespaceCount += rhs.whitespaceCount
        lhs.newlineCount += rhs.newlineCount
        lhs.emojiCount += rhs.emojiCount
        lhs.otherCount += rhs.otherCount
    }
}

public enum TypingStatisticsClassifier {
    public static func classify(_ text: String) -> TypingStatisticsDelta {
        var result = TypingStatisticsDelta()

        for character in text {
            result.committedGraphemeCount += 1

            if isNewline(character) {
                result.newlineCount += 1
            } else if isWhitespace(character) {
                result.whitespaceCount += 1
            } else if isEmoji(character) {
                result.emojiCount += 1
            } else if isDigit(character) {
                result.digitCount += 1
            } else if isCJK(character) {
                result.cjkCharacterCount += 1
            } else if isLatinLetter(character) {
                result.latinLetterCount += 1
            } else if isPunctuation(character) {
                result.punctuationCount += 1
            } else {
                result.otherCount += 1
            }
        }

        return result
    }

    private static func isNewline(_ character: Character) -> Bool {
        character.unicodeScalars.allSatisfy(CharacterSet.newlines.contains)
    }

    private static func isWhitespace(_ character: Character) -> Bool {
        character.unicodeScalars.allSatisfy(CharacterSet.whitespaces.contains)
    }

    private static func isDigit(_ character: Character) -> Bool {
        character.unicodeScalars.allSatisfy(CharacterSet.decimalDigits.contains)
    }

    private static func isPunctuation(_ character: Character) -> Bool {
        character.unicodeScalars.allSatisfy(CharacterSet.punctuationCharacters.contains)
    }

    private static func isEmoji(_ character: Character) -> Bool {
        let scalars = character.unicodeScalars
        if scalars.contains(where: { $0.properties.isEmojiPresentation }) {
            return true
        }
        // Keycaps, flags and joined sequences are emoji even when their first
        // scalar also has a text presentation (for example, "1️⃣").
        return scalars.count > 1 && scalars.contains(where: { $0.properties.isEmoji })
    }

    private static func isCJK(_ character: Character) -> Bool {
        character.unicodeScalars.contains { scalar in
            switch scalar.value {
            case 0x3400...0x4DBF, 0x4E00...0x9FFF, 0xF900...0xFAFF,
                 0x20000...0x2FA1F:
                true
            default:
                false
            }
        }
    }

    private static func isLatinLetter(_ character: Character) -> Bool {
        let scalars = character.unicodeScalars
        guard scalars.contains(where: CharacterSet.letters.contains) else { return false }
        return scalars.allSatisfy { scalar in
            CharacterSet.nonBaseCharacters.contains(scalar) || isLatinScalar(scalar.value)
        }
    }

    private static func isLatinScalar(_ value: UInt32) -> Bool {
        switch value {
        case 0x0041...0x005A, 0x0061...0x007A, 0x00C0...0x024F,
             0x1E00...0x1EFF:
            true
        default:
            false
        }
    }
}
