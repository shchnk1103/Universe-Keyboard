import Foundation

public struct AutoCapitalizationRules {

    public static let sentenceTerminators: Set<Character> = [
        ".", "!", "?", "。", "！", "？"
    ]

    public static func isSentenceTerminator(_ text: String) -> Bool {
        text.count == 1 && sentenceTerminators.contains(text.first!)
    }

    public static func shouldAutoCapitalize(contextBeforeInput: String?) -> Bool {
        guard let context = contextBeforeInput else { return true }
        if context.isEmpty { return true }
        let trimmed = context.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let lastChar = trimmed.last else { return true }
        return sentenceTerminators.contains(lastChar)
    }
}
