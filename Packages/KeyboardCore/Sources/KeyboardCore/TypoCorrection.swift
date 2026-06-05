import Foundation

/// 拼音误触纠错的纯逻辑引擎。
///
/// 当前只处理低风险的尾部误触：最后一个字符的一处相邻按键替换，或末尾
/// 重复字符删除。这样能覆盖小屏键盘最常见的尾部误触，同时避免在输入热路径里
/// 枚举过多组合。
public struct TypoCorrectionEngine: Sendable {
    public init() {}

    public func suggestions(for input: String) -> [TypoCorrectionSuggestion] {
        let letters = Array(input.lowercased())
        guard letters.count >= 2, let last = letters.last else { return [] }

        var suggestions: [TypoCorrectionSuggestion] = []
        if let deletion = repeatedFinalDeletionSuggestion(for: letters) {
            suggestions.append(deletion)
        }

        if let replacements = Self.nearbyKeys[last], !replacements.isEmpty {
            suggestions.append(contentsOf: trailingSubstitutionSuggestions(for: letters, replacements: replacements))
        }

        return suggestions
    }

    private func trailingSubstitutionSuggestions(
        for letters: [Character],
        replacements: [Character]
    ) -> [TypoCorrectionSuggestion] {
        let editIndex = letters.count - 1
        guard let last = letters.last else { return [] }

        return replacements.map { replacement in
            var corrected = letters
            corrected[editIndex] = replacement
            return TypoCorrectionSuggestion(
                originalInput: String(letters),
                correctedInput: String(corrected),
                edits: [
                    TypoCorrectionEdit(
                        index: editIndex,
                        original: last,
                        replacement: replacement,
                        kind: .substitution
                    )
                ],
                candidates: []
            )
        }
    }

    private func repeatedFinalDeletionSuggestion(for letters: [Character]) -> TypoCorrectionSuggestion? {
        guard letters.count >= Self.repeatedFinalDeletionMinimumLength,
            let last = letters.last,
            letters[letters.count - 2] == last
        else { return nil }

        let editIndex = letters.count - 1
        let corrected = letters.dropLast()
        return TypoCorrectionSuggestion(
            originalInput: String(letters),
            correctedInput: String(corrected),
            edits: [
                TypoCorrectionEdit(
                    index: editIndex,
                    original: last,
                    replacement: last,
                    kind: .deletion
                )
            ],
            candidates: []
        )
    }

    private static let repeatedFinalDeletionMinimumLength = 5

    private static let nearbyKeys: [Character: [Character]] = [
        "q": ["w", "a"],
        "w": ["q", "e", "a", "s"],
        "e": ["w", "r", "s", "d"],
        "r": ["e", "t", "d", "f"],
        "t": ["r", "y", "f", "g"],
        "y": ["t", "u", "g", "h"],
        "u": ["y", "i", "h", "j"],
        "i": ["u", "o", "j", "k"],
        "o": ["i", "p", "k", "l"],
        "p": ["o", "l"],
        "a": ["q", "w", "s", "z"],
        "s": ["a", "w", "e", "d", "z", "x"],
        "d": ["s", "e", "r", "f", "x", "c"],
        "f": ["d", "r", "t", "g", "c", "v"],
        "g": ["f", "t", "y", "h", "v", "b"],
        "h": ["g", "y", "u", "j", "b", "n"],
        "j": ["h", "u", "i", "k", "n", "m"],
        "k": ["j", "i", "o", "l", "m"],
        "l": ["k", "o", "p"],
        "z": ["a", "s", "x"],
        "x": ["z", "s", "d", "c"],
        "c": ["x", "d", "f", "v"],
        "v": ["c", "f", "g", "b"],
        "b": ["v", "g", "h", "n"],
        "n": ["b", "h", "j", "m"],
        "m": ["n", "j", "k"],
    ]
}

public struct TypoCorrectionState: Equatable, Sendable {
    public let originalInput: String
    public let suggestions: [TypoCorrectionSuggestion]

    public init(originalInput: String, suggestions: [TypoCorrectionSuggestion]) {
        self.originalInput = originalInput
        self.suggestions = suggestions
    }
}

public struct TypoCorrectionSuggestion: Equatable, Sendable {
    public let originalInput: String
    public let correctedInput: String
    public let edits: [TypoCorrectionEdit]
    public let candidates: [RimeCandidate]

    public init(
        originalInput: String,
        correctedInput: String,
        edits: [TypoCorrectionEdit],
        candidates: [RimeCandidate]
    ) {
        self.originalInput = originalInput
        self.correctedInput = correctedInput
        self.edits = edits
        self.candidates = candidates
    }
}

public enum TypoCorrectionEditKind: Equatable, Sendable {
    case substitution
    case deletion
}

public struct TypoCorrectionEdit: Equatable, Sendable {
    public let index: Int
    public let original: Character
    /// Substitution replacement. For deletion edits this is a compatibility value and
    /// deletion semantics are represented by `kind`.
    public let replacement: Character
    public let kind: TypoCorrectionEditKind

    public init(
        index: Int,
        original: Character,
        replacement: Character,
        kind: TypoCorrectionEditKind = .substitution
    ) {
        self.index = index
        self.original = original
        self.replacement = replacement
        self.kind = kind
    }
}

public struct TypoCorrectionCommit: Equatable, Sendable {
    public let committedText: String
    public let originalInput: String
    public let correctedInput: String
    public let edits: [TypoCorrectionEdit]

    public init(
        committedText: String,
        originalInput: String,
        correctedInput: String,
        edits: [TypoCorrectionEdit]
    ) {
        self.committedText = committedText
        self.originalInput = originalInput
        self.correctedInput = correctedInput
        self.edits = edits
    }
}

public enum TypoCorrectionCandidateRanker {
    /// 合并普通候选和误触纠错候选。
    ///
    /// 默认保持 RIME 原始排序；只有一处末尾邻键替换、纠错候选是普通首候选的
    /// 更短前缀时，才把该纠错候选提升到最前面。
    public static func mergedCandidates(
        normalItems: [CandidateItem],
        correctionItems: [CandidateItem]
    ) -> [CandidateItem] {
        guard let firstNormal = normalItems.first else {
            return correctionItems + normalItems
        }

        var remainingCorrections = correctionItems
        guard let promotedIndex = remainingCorrections.firstIndex(where: {
            shouldPromote($0, over: firstNormal)
        }) else {
            let normalTitles = Set(normalItems.map(\.title))
            return normalItems + correctionItems.filter { !normalTitles.contains($0.title) }
        }

        let promoted = remainingCorrections.remove(at: promotedIndex)
        let normalItemsWithoutPromotedDuplicate = normalItems.filter { $0.title != promoted.title }
        let normalTitles = Set(normalItemsWithoutPromotedDuplicate.map(\.title)).union([promoted.title])
        let dedupedCorrections = remainingCorrections.filter { !normalTitles.contains($0.title) }
        return [promoted] + normalItemsWithoutPromotedDuplicate + dedupedCorrections
    }

    static func shouldPromoteCorrection(
        title: String,
        correction: TypoCorrectionCommit,
        over normalTitle: String
    ) -> Bool {
        shouldPromote(
            CandidateItem(title: title, kind: .correctionCandidate, correction: correction),
            over: CandidateItem(title: normalTitle, kind: .candidate)
        )
    }

    private static func shouldPromote(_ correctionItem: CandidateItem, over normalItem: CandidateItem) -> Bool {
        guard correctionItem.kind == .correctionCandidate,
            normalItem.kind == .candidate,
            let correction = correctionItem.correction
        else { return false }

        guard correction.edits.count == 1,
            correction.originalInput.count == correction.correctedInput.count,
            correction.originalInput != correction.correctedInput
        else { return false }

        guard let edit = correction.edits.first,
            edit.kind == .substitution,
            edit.index == correction.originalInput.count - 1
        else { return false }

        let originalLetters = Array(correction.originalInput)
        let correctedLetters = Array(correction.correctedInput)
        guard originalLetters.indices.contains(edit.index),
            correctedLetters.indices.contains(edit.index),
            originalLetters[edit.index] == edit.original,
            correctedLetters[edit.index] == edit.replacement
        else { return false }

        // V0.2 只提升短词/短语，避免把长句式纠错候选压过 RIME 排序。
        guard correctionItem.title.count >= 2,
            correctionItem.title.count <= 4
        else { return false }

        return normalItem.title.hasPrefix(correctionItem.title)
            && normalItem.title.count > correctionItem.title.count
    }
}
