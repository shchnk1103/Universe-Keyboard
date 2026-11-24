import Foundation

public struct AutoCapitalizationRules {

    public static let sentenceTerminators: Set<Character> = [
        ".", "!", "?", "。", "！", "？",
    ]

    public static func isSentenceTerminator(_ text: String) -> Bool {
        text.count == 1 && sentenceTerminators.contains(text.first!)
    }

    public static func shouldAutoCapitalize(contextBeforeInput: String?) -> Bool {
        guard let context = contextBeforeInput else { return true }
        if context.isEmpty { return true }
        let trimmed = context.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let lastChar = trimmed.last else { return true }
        // `.` 仅当其后至少有一个空白时才句首大写；紧贴前词保持小写（google. / google.com）。
        // trim 后以 `.` 结尾即 `.` 后无空白（否则已被空白截断），故看原文最后一个字符。
        if lastChar == "." {
            return context.last != "."
        }
        return sentenceTerminators.contains(lastChar)
    }
}
