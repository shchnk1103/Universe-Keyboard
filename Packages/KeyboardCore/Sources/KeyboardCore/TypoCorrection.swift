import Foundation

/// 拼音误触纠错的纯逻辑引擎。
///
/// 当前只处理低风险的单点误触：一处相邻按键替换，或末尾重复字符删除。
/// 引擎只生成候选输入，真正是否展示仍要经过 RIME/候选 provider 验证。
public struct TypoCorrectionEngine: Sendable {
    public init() {}

    public func suggestions(for input: String) -> [TypoCorrectionSuggestion] {
        let letters = Array(input.lowercased())
        guard letters.count >= 2 else { return [] }

        var suggestions: [TypoCorrectionSuggestion] = []
        if let deletion = repeatedFinalDeletionSuggestion(for: letters) {
            suggestions.append(deletion)
        }

        suggestions.append(contentsOf: adjacentSubstitutionSuggestions(for: letters))

        return Array(suggestions.prefix(Self.maximumSuggestions))
    }

    private func adjacentSubstitutionSuggestions(for letters: [Character]) -> [TypoCorrectionSuggestion] {
        guard letters.count >= Self.substitutionMinimumLength else { return [] }

        let editIndices = prioritizedSubstitutionIndices(for: letters)
        var suggestions: [TypoCorrectionSuggestion] = []
        var seenCorrectedInputs: Set<String> = []

        for editIndex in editIndices {
            let original = letters[editIndex]
            guard let replacements = TypoCorrectionKeyboard.nearbyKeys[original] else { continue }

            for replacement in replacements {
                guard TypoCorrectionKeyboard.isSafeReplacement(
                    original,
                    replacement,
                    at: editIndex,
                    lastIndex: letters.count - 1
                ) else { continue }

                var corrected = letters
                corrected[editIndex] = replacement
                let correctedInput = String(corrected)
                guard seenCorrectedInputs.insert(correctedInput).inserted else { continue }

                suggestions.append(
                    TypoCorrectionSuggestion(
                        originalInput: String(letters),
                        correctedInput: correctedInput,
                        edits: [
                            TypoCorrectionEdit(
                                index: editIndex,
                                original: original,
                                replacement: replacement,
                                kind: .substitution
                            )
                        ],
                        candidates: []
                    )
                )

                if suggestions.count >= Self.maximumSuggestions {
                    return suggestions
                }
            }
        }

        return suggestions
    }

    private func prioritizedSubstitutionIndices(for letters: [Character]) -> [Int] {
        guard !letters.isEmpty else { return [] }

        let lastIndex = letters.count - 1
        var indices = [lastIndex]
        if lastIndex > 0 {
            indices.append(0)
        }
        if letters.count > 2 {
            indices.append(contentsOf: 1..<lastIndex)
        }
        var seen: Set<Int> = []
        return indices.filter { seen.insert($0).inserted }
    }

    private static let substitutionMinimumLength = 5
    private static let repeatedFinalDeletionMinimumLength = 5
    private static let maximumSuggestions = 16

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
}

enum TypoCorrectionKeyboard {
    static let nearbyKeys: [Character: [Character]] = [
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

    static func isNearby(_ original: Character, _ replacement: Character) -> Bool {
        nearbyKeys[original]?.contains(replacement) == true
    }

    static func isSafeReplacement(
        _ original: Character,
        _ replacement: Character,
        at index: Int,
        lastIndex: Int
    ) -> Bool {
        guard isNearby(original, replacement) else { return false }
        guard index != lastIndex else { return true }
        return isVowel(original) == isVowel(replacement)
    }

    private static func isVowel(_ character: Character) -> Bool {
        ["a", "e", "i", "o", "u", "v"].contains(character)
    }
}

public enum TypoCorrectionConfidenceTier: Equatable, Sendable {
    case high
    case medium
    case low
    case rejected
}

public enum TypoCorrectionRejectReason: Equatable, Sendable {
    case inputTooShort
    case unsupportedEdit
    case unsafeReplacement
    case noCorrectedCandidates
    case normalCandidateAlreadyMatches
    case candidateTextTooLong
}

public struct TypoCorrectionAssessment: Equatable, Sendable {
    public let score: Int
    public let confidence: TypoCorrectionConfidenceTier
    public let isDisplayEligible: Bool
    public let isPromotionEligible: Bool
    public let rejectReason: TypoCorrectionRejectReason?

    public init(
        score: Int,
        confidence: TypoCorrectionConfidenceTier,
        isDisplayEligible: Bool,
        isPromotionEligible: Bool,
        rejectReason: TypoCorrectionRejectReason?
    ) {
        self.score = score
        self.confidence = confidence
        self.isDisplayEligible = isDisplayEligible
        self.isPromotionEligible = isPromotionEligible
        self.rejectReason = rejectReason
    }

    public static func rejected(_ reason: TypoCorrectionRejectReason) -> TypoCorrectionAssessment {
        TypoCorrectionAssessment(
            score: 0,
            confidence: .rejected,
            isDisplayEligible: false,
            isPromotionEligible: false,
            rejectReason: reason
        )
    }

    public static func evaluate(
        title: String,
        suggestion: TypoCorrectionSuggestion,
        firstNormalCandidate: String?
    ) -> TypoCorrectionAssessment {
        evaluate(
            title: title,
            originalInput: suggestion.originalInput,
            correctedInput: suggestion.correctedInput,
            edits: suggestion.edits,
            firstNormalCandidate: firstNormalCandidate
        )
    }

    public static func evaluate(
        title: String,
        correction: TypoCorrectionCommit,
        firstNormalCandidate: String?
    ) -> TypoCorrectionAssessment {
        evaluate(
            title: title,
            originalInput: correction.originalInput,
            correctedInput: correction.correctedInput,
            edits: correction.edits,
            firstNormalCandidate: firstNormalCandidate
        )
    }

    public static func evaluate(
        title: String,
        originalInput: String,
        correctedInput: String,
        edits: [TypoCorrectionEdit],
        firstNormalCandidate: String?
    ) -> TypoCorrectionAssessment {
        guard title.count >= 2 && title.count <= 4 else {
            return .rejected(.candidateTextTooLong)
        }
        guard firstNormalCandidate != title else {
            return .rejected(.normalCandidateAlreadyMatches)
        }
        guard originalInput.count >= TypoCorrectionEngine.safeSubstitutionMinimumLength else {
            return .rejected(.inputTooShort)
        }
        guard edits.count == 1,
            originalInput != correctedInput,
            let edit = edits.first
        else {
            return .rejected(.unsupportedEdit)
        }

        switch edit.kind {
        case .substitution:
            return substitutionAssessment(
                edit: edit,
                originalInput: originalInput,
                correctedInput: correctedInput
            )
        case .deletion:
            return deletionAssessment(
                edit: edit,
                originalInput: originalInput,
                correctedInput: correctedInput
            )
        }
    }

    private static func substitutionAssessment(
        edit: TypoCorrectionEdit,
        originalInput: String,
        correctedInput: String
    ) -> TypoCorrectionAssessment {
        let originalLetters = Array(originalInput)
        let correctedLetters = Array(correctedInput)
        guard originalLetters.count == correctedLetters.count,
            originalLetters.indices.contains(edit.index),
            correctedLetters.indices.contains(edit.index),
            originalLetters[edit.index] == edit.original,
            correctedLetters[edit.index] == edit.replacement
        else {
            return .rejected(.unsupportedEdit)
        }

        let lastIndex = originalLetters.count - 1
        guard TypoCorrectionKeyboard.isSafeReplacement(
            edit.original,
            edit.replacement,
            at: edit.index,
            lastIndex: lastIndex
        ) else {
            return .rejected(.unsafeReplacement)
        }

        let isFinalEdit = edit.index == lastIndex
        return TypoCorrectionAssessment(
            score: isFinalEdit ? 90 : 75,
            confidence: .high,
            isDisplayEligible: true,
            isPromotionEligible: isFinalEdit,
            rejectReason: nil
        )
    }

    private static func deletionAssessment(
        edit: TypoCorrectionEdit,
        originalInput: String,
        correctedInput: String
    ) -> TypoCorrectionAssessment {
        let originalLetters = Array(originalInput)
        let correctedLetters = Array(correctedInput)
        guard originalLetters.count == correctedLetters.count + 1,
            originalLetters.indices.contains(edit.index),
            edit.index == originalLetters.count - 1,
            originalLetters[edit.index] == edit.original,
            originalLetters[edit.index] == edit.replacement,
            Array(originalLetters.dropLast()) == correctedLetters,
            originalLetters.count >= 2,
            originalLetters[originalLetters.count - 1] == originalLetters[originalLetters.count - 2]
        else {
            return .rejected(.unsupportedEdit)
        }

        return TypoCorrectionAssessment(
            score: 55,
            confidence: .medium,
            isDisplayEligible: true,
            isPromotionEligible: false,
            rejectReason: nil
        )
    }
}

extension TypoCorrectionEngine {
    static var safeSubstitutionMinimumLength: Int {
        substitutionMinimumLength
    }
}

enum TypoCorrectionConfidence {
    static func assessment(
        title: String,
        suggestion: TypoCorrectionSuggestion,
        firstNormalCandidate: String?
    ) -> TypoCorrectionAssessment {
        TypoCorrectionAssessment.evaluate(
            title: title,
            suggestion: suggestion,
            firstNormalCandidate: firstNormalCandidate
        )
    }

    static func assessment(
        _ correctionItem: CandidateItem,
        firstNormalCandidate: String?
    ) -> TypoCorrectionAssessment {
        guard correctionItem.kind == .correctionCandidate,
            let correction = correctionItem.correction
        else { return .rejected(.unsupportedEdit) }

        return TypoCorrectionAssessment.evaluate(
            title: correctionItem.title,
            correction: correction,
            firstNormalCandidate: firstNormalCandidate
        )
    }

    static func isHighConfidenceDisplayCandidate(
        title: String,
        suggestion: TypoCorrectionSuggestion,
        firstNormalCandidate: String?
    ) -> Bool {
        assessment(
            title: title,
            suggestion: suggestion,
            firstNormalCandidate: firstNormalCandidate
        ).isDisplayEligible
    }

    static func isHighConfidenceSubstitution(_ correctionItem: CandidateItem) -> Bool {
        let result = assessment(correctionItem, firstNormalCandidate: nil)
        return result.confidence == .high
            && correctionItem.correction?.edits.first?.kind == .substitution
    }
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
    /// 默认保持 RIME 原始排序；只有高置信单点邻键替换才进入前排。
    /// 末尾替换且纠错候选是普通首候选的更短前缀时，提升到最前面；
    /// 其他位置的邻键替换只插入到首个普通候选之后。
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
            return mergeWithoutTopPromotion(normalItems: normalItems, correctionItems: correctionItems)
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
        guard normalItem.kind == .candidate,
            correctionItem.correction != nil
        else { return false }

        let assessment = TypoCorrectionConfidence.assessment(
            correctionItem,
            firstNormalCandidate: normalItem.title
        )
        guard assessment.isPromotionEligible else { return false }

        return normalItem.title.hasPrefix(correctionItem.title)
            && normalItem.title.count > correctionItem.title.count
    }

    private static func mergeWithoutTopPromotion(
        normalItems: [CandidateItem],
        correctionItems: [CandidateItem]
    ) -> [CandidateItem] {
        guard let firstNormal = normalItems.first else {
            return correctionItems
        }

        let nearFrontCorrections = correctionItems.filter {
            guard $0.title != firstNormal.title else { return false }
            let assessment = TypoCorrectionConfidence.assessment(
                $0,
                firstNormalCandidate: firstNormal.title
            )
            return assessment.isDisplayEligible
                && !assessment.isPromotionEligible
                && assessment.confidence == .high
        }

        guard let nearFront = nearFrontCorrections.first else {
            let normalTitles = Set(normalItems.map(\.title))
            return normalItems + correctionItems.filter { !normalTitles.contains($0.title) }
        }

        let normalItemsWithoutDuplicate = normalItems.filter { $0.title != nearFront.title }
        let normalTitles = Set(normalItemsWithoutDuplicate.map(\.title)).union([nearFront.title])
        let remainingCorrections = correctionItems.filter {
            $0.title != nearFront.title && !normalTitles.contains($0.title)
        }

        return [normalItemsWithoutDuplicate[0], nearFront]
            + normalItemsWithoutDuplicate.dropFirst()
            + remainingCorrections
    }

}
