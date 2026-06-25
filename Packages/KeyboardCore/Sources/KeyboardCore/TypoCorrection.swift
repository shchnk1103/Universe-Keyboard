import Foundation

/// 拼音误触纠错的纯逻辑引擎。
///
/// 当前只处理低风险的单点误触：一处相邻按键替换，或末尾重复字符删除。
/// 引擎只生成候选输入，真正是否展示仍要经过 RIME/候选 provider 验证。
public struct TypoCorrectionEngine: Sendable {
    private let experimentalEdits: TypoCorrectionExperimentalEdits

    public init(experimentalEdits: TypoCorrectionExperimentalEdits = []) {
        self.experimentalEdits = experimentalEdits
    }

    public func suggestions(for input: String) -> [TypoCorrectionSuggestion] {
        let letters = Array(input.lowercased())
        guard letters.count >= 2 else { return [] }

        var suggestions: [TypoCorrectionSuggestion] = []
        if let deletion = repeatedFinalDeletionSuggestion(for: letters) {
            suggestions.append(deletion)
        }

        if experimentalEdits.contains(.transposition) {
            suggestions.append(contentsOf: transpositionSuggestions(for: letters))
        }
        if experimentalEdits.contains(.insertion) {
            suggestions.append(contentsOf: insertionSuggestions(for: letters))
        }
        suggestions.append(contentsOf: adjacentSubstitutionSuggestions(for: letters))

        return Array(suggestions.prefix(Self.maximumSuggestions))
    }

    private func adjacentSubstitutionSuggestions(for letters: [Character]) -> [TypoCorrectionSuggestion] {
        guard letters.count >= Self.substitutionMinimumLength else { return [] }

        let editDescriptors = prioritizedSubstitutionEditDescriptors(for: letters)
        var suggestions: [TypoCorrectionSuggestion] = []
        var seenCorrectedInputs: Set<String> = []

        for descriptor in editDescriptors {
            var corrected = letters
            corrected[descriptor.index] = descriptor.replacement
            let correctedInput = String(corrected)
            guard seenCorrectedInputs.insert(correctedInput).inserted else { continue }

            suggestions.append(
                TypoCorrectionSuggestion(
                    originalInput: String(letters),
                    correctedInput: correctedInput,
                    edits: [
                        TypoCorrectionEdit(
                            index: descriptor.index,
                            original: descriptor.original,
                            replacement: descriptor.replacement,
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

        return suggestions
    }

    private func prioritizedSubstitutionEditDescriptors(for letters: [Character]) -> [SubstitutionEditDescriptor] {
        guard !letters.isEmpty else { return [] }

        let lastIndex = letters.count - 1
        var descriptors: [SubstitutionEditDescriptor] = []

        for editIndex in letters.indices {
            let original = letters[editIndex]
            guard let replacements = TypoCorrectionKeyboard.nearbyKeys[original] else { continue }

            for (replacementOrder, replacement) in replacements.enumerated() {
                guard TypoCorrectionKeyboard.isSafeReplacement(
                    original,
                    replacement,
                    at: editIndex,
                    lastIndex: lastIndex
                ) else { continue }

                descriptors.append(
                    SubstitutionEditDescriptor(
                        index: editIndex,
                        original: original,
                        replacement: replacement,
                        indexPriority: substitutionIndexPriority(editIndex, lastIndex: lastIndex),
                        replacementOrder: replacementOrder
                    )
                )
            }
        }

        return descriptors.sorted { lhs, rhs in
            if lhs.indexPriority != rhs.indexPriority {
                return lhs.indexPriority < rhs.indexPriority
            }
            if lhs.replacementOrder != rhs.replacementOrder {
                return lhs.replacementOrder < rhs.replacementOrder
            }
            return lhs.index < rhs.index
        }
    }

    private func substitutionIndexPriority(_ index: Int, lastIndex: Int) -> Int {
        if index == lastIndex { return 0 }
        if index == 0 { return 1 }

        // 长拼音里常见误触可能发生在后半段。中间位置从右向左验证，
        // 让 `zhonghuo -> zhongguo` 这类安全同类替换进入有限 lookup window。
        return 2 + (lastIndex - index)
    }

    private static let substitutionMinimumLength = 5
    private static let insertionMinimumLength = 4
    private static let transpositionMinimumLength = 5
    private static let repeatedFinalDeletionMinimumLength = 5
    private static let maximumSuggestions = 16
    private static let conservativeInsertionCharacters: [Character] = ["a", "e", "i", "o", "u"]

    private struct SubstitutionEditDescriptor {
        let index: Int
        let original: Character
        let replacement: Character
        let indexPriority: Int
        let replacementOrder: Int
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

    private func insertionSuggestions(for letters: [Character]) -> [TypoCorrectionSuggestion] {
        guard letters.count >= Self.insertionMinimumLength else { return [] }

        let originalInput = String(letters)
        let insertionRange = max(0, letters.count - 1)...letters.count
        return insertionRange.flatMap { insertionIndex in
            Self.conservativeInsertionCharacters.map { inserted in
                var corrected = letters
                corrected.insert(inserted, at: insertionIndex)
                return TypoCorrectionSuggestion(
                    originalInput: originalInput,
                    correctedInput: String(corrected),
                    edits: [
                        TypoCorrectionEdit(
                            index: insertionIndex,
                            original: inserted,
                            replacement: inserted,
                            kind: .insertion,
                            inserted: inserted
                        )
                    ],
                    candidates: []
                )
            }
        }
    }

    private func transpositionSuggestions(for letters: [Character]) -> [TypoCorrectionSuggestion] {
        guard letters.count >= Self.transpositionMinimumLength else { return [] }

        let originalInput = String(letters)
        return letters.indices.dropLast().compactMap { firstIndex in
            let secondIndex = firstIndex + 1
            guard letters[firstIndex] != letters[secondIndex] else { return nil }

            var corrected = letters
            corrected.swapAt(firstIndex, secondIndex)
            return TypoCorrectionSuggestion(
                originalInput: originalInput,
                correctedInput: String(corrected),
                edits: [
                    TypoCorrectionEdit(
                        index: firstIndex,
                        original: letters[firstIndex],
                        replacement: letters[secondIndex],
                        kind: .transposition,
                        secondIndex: secondIndex
                    )
                ],
                candidates: []
            )
        }
    }
}

public struct TypoCorrectionExperimentalEdits: OptionSet, Sendable {
    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    public static let insertion = TypoCorrectionExperimentalEdits(rawValue: 1 << 0)
    public static let transposition = TypoCorrectionExperimentalEdits(rawValue: 1 << 1)
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

public enum TypoCorrectionAssessmentReason: Equatable, Sendable {
    case finalAdjacentSubstitution
    case initialAdjacentSubstitution
    case middleSafeSubstitution
    case repeatedFinalDeletion
    case conservativeInsertion
    case adjacentTransposition
}

public struct TypoCorrectionAssessment: Equatable, Sendable {
    public let score: Int
    public let confidence: TypoCorrectionConfidenceTier
    public let isDisplayEligible: Bool
    public let isPromotionEligible: Bool
    public let rejectReason: TypoCorrectionRejectReason?
    public let reasonSummary: TypoCorrectionAssessmentReason?

    public init(
        score: Int,
        confidence: TypoCorrectionConfidenceTier,
        isDisplayEligible: Bool,
        isPromotionEligible: Bool,
        rejectReason: TypoCorrectionRejectReason?,
        reasonSummary: TypoCorrectionAssessmentReason? = nil
    ) {
        self.score = score
        self.confidence = confidence
        self.isDisplayEligible = isDisplayEligible
        self.isPromotionEligible = isPromotionEligible
        self.rejectReason = rejectReason
        self.reasonSummary = reasonSummary
    }

    public static func rejected(_ reason: TypoCorrectionRejectReason) -> TypoCorrectionAssessment {
        TypoCorrectionAssessment(
            score: 0,
            confidence: .rejected,
            isDisplayEligible: false,
            isPromotionEligible: false,
            rejectReason: reason,
            reasonSummary: nil
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
        guard edits.count == 1,
            originalInput != correctedInput,
            let edit = edits.first
        else {
            return .rejected(.unsupportedEdit)
        }

        switch edit.kind {
        case .substitution:
            guard originalInput.count >= TypoCorrectionEngine.safeSubstitutionMinimumLength else {
                return .rejected(.inputTooShort)
            }
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
        case .insertion:
            return insertionAssessment(
                edit: edit,
                originalInput: originalInput,
                correctedInput: correctedInput
            )
        case .transposition:
            return transpositionAssessment(
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
        let reason: TypoCorrectionAssessmentReason
        if isFinalEdit {
            reason = .finalAdjacentSubstitution
        } else if edit.index == 0 {
            reason = .initialAdjacentSubstitution
        } else {
            reason = .middleSafeSubstitution
        }

        return TypoCorrectionAssessment(
            score: isFinalEdit ? 90 : 75,
            confidence: .high,
            isDisplayEligible: true,
            isPromotionEligible: isFinalEdit,
            rejectReason: nil,
            reasonSummary: reason
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
            rejectReason: nil,
            reasonSummary: .repeatedFinalDeletion
        )
    }

    private static func insertionAssessment(
        edit: TypoCorrectionEdit,
        originalInput: String,
        correctedInput: String
    ) -> TypoCorrectionAssessment {
        let originalLetters = Array(originalInput)
        let correctedLetters = Array(correctedInput)
        guard originalLetters.count + 1 == correctedLetters.count,
            let inserted = edit.inserted,
            correctedLetters.indices.contains(edit.index),
            correctedLetters[edit.index] == inserted
        else {
            return .rejected(.unsupportedEdit)
        }

        var reconstructed = correctedLetters
        reconstructed.remove(at: edit.index)
        guard reconstructed == originalLetters else {
            return .rejected(.unsupportedEdit)
        }
        guard edit.index >= originalLetters.count - 1 else {
            return .rejected(.unsupportedEdit)
        }

        return TypoCorrectionAssessment(
            score: 45,
            confidence: .low,
            isDisplayEligible: true,
            isPromotionEligible: false,
            rejectReason: nil,
            reasonSummary: .conservativeInsertion
        )
    }

    private static func transpositionAssessment(
        edit: TypoCorrectionEdit,
        originalInput: String,
        correctedInput: String
    ) -> TypoCorrectionAssessment {
        let originalLetters = Array(originalInput)
        let correctedLetters = Array(correctedInput)
        guard originalLetters.count == correctedLetters.count,
            let secondIndex = edit.secondIndex,
            secondIndex == edit.index + 1,
            originalLetters.indices.contains(edit.index),
            originalLetters.indices.contains(secondIndex),
            originalLetters[edit.index] == edit.original,
            originalLetters[secondIndex] == edit.replacement
        else {
            return .rejected(.unsupportedEdit)
        }

        var reconstructed = originalLetters
        reconstructed.swapAt(edit.index, secondIndex)
        guard reconstructed == correctedLetters else {
            return .rejected(.unsupportedEdit)
        }

        return TypoCorrectionAssessment(
            score: 45,
            confidence: .low,
            isDisplayEligible: true,
            isPromotionEligible: false,
            rejectReason: nil,
            reasonSummary: .adjacentTransposition
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
    case insertion
    case transposition
}

public struct TypoCorrectionEdit: Equatable, Sendable {
    public let index: Int
    public let original: Character
    /// Substitution replacement. For deletion, insertion, and transposition edits this is
    /// a compatibility value; exact semantics are represented by `kind` and optional fields.
    public let replacement: Character
    public let kind: TypoCorrectionEditKind
    public let inserted: Character?
    public let secondIndex: Int?

    public init(
        index: Int,
        original: Character,
        replacement: Character,
        kind: TypoCorrectionEditKind = .substitution,
        inserted: Character? = nil,
        secondIndex: Int? = nil
    ) {
        self.index = index
        self.original = original
        self.replacement = replacement
        self.kind = kind
        self.inserted = inserted
        self.secondIndex = secondIndex
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
