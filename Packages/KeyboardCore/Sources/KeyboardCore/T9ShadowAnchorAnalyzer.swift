#if DEBUG
import Foundation

/// Why the current snapshot can or cannot produce an observation-only anchor proposal.
///
/// These reasons describe evidence completeness. They never authorize a product
/// state transition; Stage 1 is intentionally read-only.
public enum T9ShadowAnchorStatus: String, Equatable, Sendable {
    case proposalReady
    case inactiveComposition
    case staleSnapshot
    case invalidSourceDigits
    case noCandidates
    case nonInitialCandidatePage
    case candidateSetIncomplete
    case incompletePathEvidence
    case noCompatiblePaths
    case noClosedCommonPrefix
}

/// Content-free Stage 1 observation for a single T9 composition snapshot.
///
/// The payload deliberately contains counts and revision identities only. Raw
/// digits, pinyin paths, candidate text and user-dictionary contents never leave
/// the analyzer.
public struct T9ShadowAnchorObservation: Equatable, Sendable {
    public let status: T9ShadowAnchorStatus
    public let rawInputGeneration: UInt64
    public let provenanceRevision: UInt64
    public let candidateCount: Int
    public let compatibleCandidateCount: Int
    public let uniqueCompatiblePathCount: Int
    public let rejectedCandidateCount: Int
    public let observedCommonSyllableCount: Int
    public let closedCommonSyllableCount: Int
    public let anchorSlotCount: Int
    public let unresolvedSlotCount: Int
    public let evidenceComplete: Bool

    public var isProposalReady: Bool {
        status == .proposalReady
    }
}

/// Pure, bounded shadow analysis over the RIME output already returned for a key.
///
/// This type performs no RIME calls and owns no mutable state. A future automatic
/// anchor must use a separately authorized authority source; candidate comments
/// are observation evidence only.
public enum T9ShadowAnchorAnalyzer {
    public static func analyze(
        sourceDigits: String?,
        output: RimeOutput?,
        rawInputGeneration: UInt64,
        provenanceRevision: UInt64
    ) -> T9ShadowAnchorObservation {
        guard let output else {
            return emptyObservation(
                status: .inactiveComposition,
                rawInputGeneration: rawInputGeneration,
                provenanceRevision: provenanceRevision
            )
        }

        guard rawInputGeneration > 0, provenanceRevision > 0 else {
            return emptyObservation(
                status: .staleSnapshot,
                rawInputGeneration: rawInputGeneration,
                provenanceRevision: provenanceRevision,
                candidateCount: output.candidates.count
            )
        }

        guard let sourceDigits,
              !sourceDigits.isEmpty,
              sourceDigits.allSatisfy(isT9Digit)
        else {
            return emptyObservation(
                status: .invalidSourceDigits,
                rawInputGeneration: rawInputGeneration,
                provenanceRevision: provenanceRevision,
                candidateCount: output.candidates.count
            )
        }

        guard !output.candidates.isEmpty else {
            return emptyObservation(
                status: .noCandidates,
                rawInputGeneration: rawInputGeneration,
                provenanceRevision: provenanceRevision,
                unresolvedSlotCount: sourceDigits.count
            )
        }

        var compatibleCandidateCount = 0
        var rejectedCandidateCount = 0
        var uniquePaths: [[String]] = []
        var seenPaths = Set<String>()

        for candidate in output.candidates {
            guard let path = T9PinyinPathExtractor.path(fromComment: candidate.comment),
                  T9PinyinPathExtractor.isCompatible(path: path, withRawInput: sourceDigits)
            else {
                rejectedCandidateCount += 1
                continue
            }

            let segments = path.replacementRawInput
                .split(separator: "'", omittingEmptySubsequences: true)
                .map(String.init)
            guard !segments.isEmpty else {
                rejectedCandidateCount += 1
                continue
            }

            compatibleCandidateCount += 1
            if seenPaths.insert(path.replacementRawInput).inserted {
                uniquePaths.append(segments)
            }
        }

        let common = commonSyllablePrefix(of: uniquePaths)
        let minimumPathLength = uniquePaths.map(\.count).min() ?? 0
        // A common syllable is closed only when every observed Path continues
        // into at least one later segment. The extendable tail stays unresolved.
        let closedCount = min(common.count, max(0, minimumPathLength - 1))
        let anchorSlots = T9PinyinPathExtractor.letterCount(
            ofSyllables: Array(common.prefix(closedCount))
        )
        let unresolvedSlots = max(0, sourceDigits.count - anchorSlots)
        let evidenceComplete =
            output.candidatePageNumber == 0
            && !output.hasMorePages
            && rejectedCandidateCount == 0
            && compatibleCandidateCount == output.candidates.count
            && !uniquePaths.isEmpty

        let status: T9ShadowAnchorStatus
        if output.candidatePageNumber != 0 {
            status = .nonInitialCandidatePage
        } else if output.hasMorePages {
            status = .candidateSetIncomplete
        } else if rejectedCandidateCount > 0 {
            status = .incompletePathEvidence
        } else if uniquePaths.isEmpty {
            status = .noCompatiblePaths
        } else if closedCount == 0 {
            status = .noClosedCommonPrefix
        } else {
            status = .proposalReady
        }

        return T9ShadowAnchorObservation(
            status: status,
            rawInputGeneration: rawInputGeneration,
            provenanceRevision: provenanceRevision,
            candidateCount: output.candidates.count,
            compatibleCandidateCount: compatibleCandidateCount,
            uniqueCompatiblePathCount: uniquePaths.count,
            rejectedCandidateCount: rejectedCandidateCount,
            observedCommonSyllableCount: common.count,
            closedCommonSyllableCount: closedCount,
            anchorSlotCount: anchorSlots,
            unresolvedSlotCount: unresolvedSlots,
            evidenceComplete: evidenceComplete
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

    private static func isT9Digit(_ character: Character) -> Bool {
        switch character {
        case "2"..."9":
            return true
        default:
            return false
        }
    }

    private static func emptyObservation(
        status: T9ShadowAnchorStatus,
        rawInputGeneration: UInt64,
        provenanceRevision: UInt64,
        candidateCount: Int = 0,
        unresolvedSlotCount: Int = 0
    ) -> T9ShadowAnchorObservation {
        T9ShadowAnchorObservation(
            status: status,
            rawInputGeneration: rawInputGeneration,
            provenanceRevision: provenanceRevision,
            candidateCount: candidateCount,
            compatibleCandidateCount: 0,
            uniqueCompatiblePathCount: 0,
            rejectedCandidateCount: 0,
            observedCommonSyllableCount: 0,
            closedCommonSyllableCount: 0,
            anchorSlotCount: 0,
            unresolvedSlotCount: unresolvedSlotCount,
            evidenceComplete: false
        )
    }
}

extension KeyboardController {
    /// Returns an observation without changing KeyboardState or invoking RIME.
    public func t9ShadowAnchorObservation() -> T9ShadowAnchorObservation {
        guard usesT9InputSemantics else {
            return T9ShadowAnchorAnalyzer.analyze(
                sourceDigits: nil,
                output: nil,
                rawInputGeneration: 0,
                provenanceRevision: 0
            )
        }

        let pathState = state.t9PinyinPathState
        let sourceDigits =
            pathState.segmentSourceDigits
            ?? T9PinyinPathExtractor.pureDigitRaw(state.lastRimeOutput?.rawInput)
        return T9ShadowAnchorAnalyzer.analyze(
            sourceDigits: sourceDigits,
            output: state.lastRimeOutput,
            rawInputGeneration: pathState.rawInputGeneration,
            provenanceRevision: pathState.provenanceRevision
        )
    }
}
#endif
