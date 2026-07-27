import Foundation

/// One-composition ownership for the experimental reversible T9 anchor.
///
/// The ledger is process-local and never persisted. `sourceDigits` remains the
/// rollback authority after RIME starts consuming a mixed letter/digit raw.
public struct T9ReversibleAutoAnchorState: Equatable, Sendable {
    public enum Phase: String, Equatable, Sendable {
        case idle
        case accepted
        case rejected
    }

    public var phase: Phase
    public var sourceDigits: String
    public var replacementRawInput: String
    public var anchoredSlotCount: Int

    public init(
        phase: Phase = .idle,
        sourceDigits: String = "",
        replacementRawInput: String = "",
        anchoredSlotCount: Int = 0
    ) {
        self.phase = phase
        self.sourceDigits = sourceDigits
        self.replacementRawInput = replacementRawInput
        self.anchoredSlotCount = anchoredSlotCount
    }

    public static let empty = T9ReversibleAutoAnchorState()
}

/// Content-free transaction result used by Debug diagnostics and tests.
public struct T9ReversibleAutoAnchorOutcome: Equatable, Sendable {
    public enum Status: String, Equatable, Sendable {
        case notEligible
        case accepted
        case rejectedAndRestored
        case restoreFailed
    }

    public let status: Status
    public let baselineCandidateCount: Int
    public let resultingCandidateCount: Int
    public let overlappingCandidateCount: Int
    public let anchoredSlotCount: Int
    public let unresolvedSlotCount: Int

    public static let notEligible = T9ReversibleAutoAnchorOutcome(
        status: .notEligible,
        baselineCandidateCount: 0,
        resultingCandidateCount: 0,
        overlappingCandidateCount: 0,
        anchoredSlotCount: 0,
        unresolvedSlotCount: 0
    )
}

/// Pure proposal and validation policy for the explicitly gated S2 prototype.
///
/// This policy deliberately treats first-page agreement as a reversible
/// preference, not complete Path authority. Safety comes from preserving the
/// original digit ledger, validating candidate conservation and rolling back.
public enum T9ReversibleAutoAnchorPolicy {
    public struct Configuration: Equatable, Sendable {
        public var minimumSourceDigitCount: Int
        public var evidenceCandidateLimit: Int
        public var minimumCompatibleCandidateCount: Int
        public var minimumClosedSyllableCount: Int
        public var minimumAnchoredSlotCount: Int
        public var minimumUnresolvedSlotCount: Int
        /// Integer percentage in `0...100`.
        public var minimumCandidateOverlapPercent: Int

        public init(
            minimumSourceDigitCount: Int = 18,
            evidenceCandidateLimit: Int = 5,
            minimumCompatibleCandidateCount: Int = 1,
            minimumClosedSyllableCount: Int = 2,
            minimumAnchoredSlotCount: Int = 6,
            minimumUnresolvedSlotCount: Int = 4,
            minimumCandidateOverlapPercent: Int = 60
        ) {
            self.minimumSourceDigitCount = max(1, minimumSourceDigitCount)
            self.evidenceCandidateLimit = max(1, evidenceCandidateLimit)
            self.minimumCompatibleCandidateCount = max(
                1,
                minimumCompatibleCandidateCount
            )
            self.minimumClosedSyllableCount = max(1, minimumClosedSyllableCount)
            self.minimumAnchoredSlotCount = max(1, minimumAnchoredSlotCount)
            self.minimumUnresolvedSlotCount = max(1, minimumUnresolvedSlotCount)
            self.minimumCandidateOverlapPercent = min(
                100,
                max(0, minimumCandidateOverlapPercent)
            )
        }

        public static let experimental = Configuration()
    }

    public struct Proposal: Equatable, Sendable {
        public let sourceDigits: String
        public let replacementRawInput: String
        public let anchoredSyllables: [String]
        public let anchoredSlotCount: Int
        public let unresolvedSlotCount: Int
        /// Ephemeral same-transaction evidence. Never log or persist.
        let baselineCandidateTexts: [String]
    }

    public struct Validation: Equatable, Sendable {
        public let isAccepted: Bool
        public let resultingCandidateCount: Int
        public let overlappingCandidateCount: Int
    }

    public static func proposal(
        sourceDigits: String,
        output: RimeOutput,
        configuration: Configuration = .experimental
    ) -> Proposal? {
        guard sourceDigits.count >= configuration.minimumSourceDigitCount,
              sourceDigits.allSatisfy(isT9Digit),
              output.candidatePageNumber == 0,
              output.committedText == nil
        else {
            return nil
        }

        let evidence = Array(output.candidates.prefix(configuration.evidenceCandidateLimit))
        guard evidence.count >= configuration.minimumCompatibleCandidateCount else {
            return nil
        }

        var paths: [[String]] = []
        paths.reserveCapacity(evidence.count)
        for (index, candidate) in evidence.enumerated() {
            guard let path = T9PinyinPathExtractor.path(fromComment: candidate.comment),
                  T9PinyinPathExtractor.isCompatible(path: path, withRawInput: sourceDigits)
            else {
                // The visible first candidate is the preference authority for
                // S2. Lower-ranked candidates may describe other T9 identities;
                // they remain protected by post-replacement conservation.
                if index == 0 { return nil }
                continue
            }
            let segments = path.replacementRawInput
                .split(separator: "'", omittingEmptySubsequences: true)
                .map { $0.lowercased() }
            guard !segments.isEmpty else { return nil }
            paths.append(segments)
        }
        guard paths.count >= configuration.minimumCompatibleCandidateCount else {
            return nil
        }

        let common = commonSyllablePrefix(of: paths)
        let minimumPathLength = paths.map(\.count).min() ?? 0
        let closed = Array(common.prefix(max(0, minimumPathLength - 1)))
        guard closed.count >= configuration.minimumClosedSyllableCount else {
            return nil
        }

        var selected: [String] = []
        var anchoredSlots = 0
        for syllable in closed {
            let slotCount = T9PinyinPathExtractor.asciiLetterCount(in: syllable)
            guard slotCount > 0,
                  anchoredSlots + slotCount
                    <= sourceDigits.count - configuration.minimumUnresolvedSlotCount
            else {
                break
            }
            let start = sourceDigits.index(sourceDigits.startIndex, offsetBy: anchoredSlots)
            let end = sourceDigits.index(start, offsetBy: slotCount)
            let digitSlice = String(sourceDigits[start..<end])
            guard T9PinyinSyllableCatalog
                .completeSyllables(matchingDigits: digitSlice)
                .contains(syllable)
            else {
                return nil
            }
            selected.append(syllable)
            anchoredSlots += slotCount
        }

        guard selected.count >= configuration.minimumClosedSyllableCount,
              anchoredSlots >= configuration.minimumAnchoredSlotCount
        else {
            return nil
        }

        let trailingDigits = String(sourceDigits.dropFirst(anchoredSlots))
        guard trailingDigits.count >= configuration.minimumUnresolvedSlotCount else {
            return nil
        }
        let replacement = selected.joined(separator: "'") + "'" + trailingDigits
        return Proposal(
            sourceDigits: sourceDigits,
            replacementRawInput: replacement,
            anchoredSyllables: selected,
            anchoredSlotCount: anchoredSlots,
            unresolvedSlotCount: trailingDigits.count,
            baselineCandidateTexts: evidence.map(\.text)
        )
    }

    public static func validate(
        proposal: Proposal,
        result: RimeOutput,
        configuration: Configuration = .experimental
    ) -> Validation {
        let resulting = Array(result.candidates.prefix(configuration.evidenceCandidateLimit))
        let baseline = proposal.baselineCandidateTexts
        let baselineSet = Set(baseline)
        let overlap = Set(resulting.map(\.text)).intersection(baselineSet).count
        let requiredOverlap = requiredOverlapCount(
            baselineCount: baselineSet.count,
            percent: configuration.minimumCandidateOverlapPercent
        )
        let rawMatches =
            T9PinyinPathExtractor.normalizeRawIdentity(result.rawInput)
            == T9PinyinPathExtractor.normalizeRawIdentity(proposal.replacementRawInput)
        let firstCandidatePreserved =
            baseline.first != nil
            && resulting.first?.text == baseline.first

        return Validation(
            isAccepted:
                result.committedText == nil
                && result.composition?.preeditText.isEmpty == false
                && rawMatches
                && firstCandidatePreserved
                && overlap >= requiredOverlap,
            resultingCandidateCount: resulting.count,
            overlappingCandidateCount: overlap
        )
    }

    private static func commonSyllablePrefix(of paths: [[String]]) -> [String] {
        guard var prefix = paths.first else { return [] }
        for path in paths.dropFirst() {
            let sharedCount = zip(prefix, path).prefix { $0 == $1 }.count
            prefix = Array(prefix.prefix(sharedCount))
            if prefix.isEmpty { break }
        }
        return prefix
    }

    private static func requiredOverlapCount(
        baselineCount: Int,
        percent: Int
    ) -> Int {
        guard baselineCount > 0 else { return 1 }
        return max(1, (baselineCount * percent + 99) / 100)
    }

    private static func isT9Digit(_ character: Character) -> Bool {
        switch character {
        case "2"..."9":
            return true
        default:
            return false
        }
    }
}
