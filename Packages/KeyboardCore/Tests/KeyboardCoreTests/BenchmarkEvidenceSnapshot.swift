import Foundation

@testable import KeyboardCore

/// Test-only structured observation of the existing typo-correction candidate path.
///
/// This capability lives in `KeyboardCoreTests`, so it is not linked into the
/// KeyboardCore product or any Release application target. It records product-path
/// inputs and outputs; it does not implement candidate resolution rules.
struct BenchmarkEvidenceSnapshot: Codable, Equatable, Sendable {
    static let registryVersion = "1.0.0"
    static let registryCommit = "49b000bcbb3a90d04f00dd803981a24a25b70e28"

    let identity: Identity
    let configuration: Configuration
    let inputs: Inputs
    let candidates: Candidates

    struct Identity: Codable, Equatable, Sendable {
        let registryVersion: String
        let registryCommit: String
        let canonicalCaseID: String
        let build: Build
        let schema: Schema
        let flags: Flags
    }

    struct Build: Codable, Equatable, Sendable {
        let commit: String
        let configuration: String
        let target: String
    }

    struct Schema: Codable, Equatable, Sendable {
        let identifier: String
        let artifactVersion: String
    }

    struct Flags: Codable, Equatable, Sendable {
        let insertionEnabled: Bool
        let transpositionEnabled: Bool
        let typoPartialCommitEnabled: Bool
    }

    struct Configuration: Codable, Equatable, Sendable {
        let learningState: String
        let deploymentState: String
        let sessionState: String
    }

    struct Inputs: Codable, Equatable, Sendable {
        let provenance: InputProvenance
        let normalInput: String
        let correctedInput: String?
    }

    enum InputProvenance: String, Codable, Equatable, Sendable {
        case syntheticFixture
    }

    struct Candidates: Codable, Equatable, Sendable {
        let normalCandidates: [String]
        let correctedCandidates: [String]
        let preDedupeSources: [CandidateSource]
        let dedupeDecisions: [DedupeDecision]
        let learningDecision: LearningDecision
        let suppressionDecision: SuppressionDecision
        let finalCandidates: [FinalCandidate]
        let finalPosition: Int?
        let representedSource: RepresentedSource?
    }

    struct CandidateSource: Codable, Equatable, Sendable {
        let title: String
        let origin: CandidateOrigin
    }

    enum CandidateOrigin: String, Codable, Equatable, Hashable, Sendable {
        case normalRime
        case typoCorrection
    }

    struct DedupeDecision: Codable, Equatable, Sendable {
        let title: String
        let originSet: [CandidateOrigin]
        let representedSource: RepresentedSource
        let removedDuplicateCount: Int
    }

    struct FinalCandidate: Codable, Equatable, Sendable {
        let title: String
        let representedSource: RepresentedSource
        let originSet: [CandidateOrigin]
    }

    enum RepresentedSource: String, Codable, Equatable, Sendable {
        case normalRime
        case typoCorrection
    }

    enum SuppressionDecision: String, Codable, Equatable, Sendable {
        case notApplicable
        case notSuppressed
        case suppressedNormalTopMatchesCorrectedBest
    }

    enum LearningDecision: Codable, Equatable, Sendable {
        case notApplicable
        case noRecord
        case nearFront(selectionCount: Int)
        case topPromotion(selectionCount: Int)
        case blockedByPrefix(selectionCount: Int)
        case blockedByAssessment
        case blockedBySatisfaction(selectionCount: Int)
    }
}

/// Synthetic input is explicit so an archived snapshot cannot silently claim that
/// arbitrary user text was collected by this test capability.
struct SyntheticBenchmarkInput: Equatable, Sendable {
    let normalInput: String
    let correctedInput: String?
}

enum BenchmarkEvidenceSnapshotBuilder {
    struct Observation: Sendable {
        let canonicalCaseID: String
        let build: BenchmarkEvidenceSnapshot.Build
        let schema: BenchmarkEvidenceSnapshot.Schema
        let flags: BenchmarkEvidenceSnapshot.Flags
        let configuration: BenchmarkEvidenceSnapshot.Configuration
        let input: SyntheticBenchmarkInput
        let normalItems: [CandidateItem]
        /// Correction items remaining after the current product suppression path.
        let resolvedCorrectionItems: [CandidateItem]
        /// Provider candidates observed before product filtering and suppression.
        let correctedCandidates: [String]
        let learningSnapshot: TypoCorrectionLearningSnapshot
        let learningDecision: BenchmarkEvidenceSnapshot.LearningDecision
        let suppressionDecision: BenchmarkEvidenceSnapshot.SuppressionDecision
        let targetCandidate: String?
    }

    static func capture(_ observation: Observation) -> BenchmarkEvidenceSnapshot {
        // This is the same merge entry point used by the product candidate bar.
        let finalItems = TypoCorrectionCandidateRanker.mergedCandidates(
            normalItems: observation.normalItems,
            correctionItems: observation.resolvedCorrectionItems,
            learningSnapshot: observation.learningSnapshot
        )

        let preDedupeSources = sources(
            normalItems: observation.normalItems,
            correctionItems: observation.resolvedCorrectionItems
        )
        let originsByTitle = Dictionary(grouping: preDedupeSources, by: \.title)
            .mapValues { sources in
                orderedOrigins(Set(sources.map(\.origin)))
            }

        let finalCandidates = finalItems.map { item in
            BenchmarkEvidenceSnapshot.FinalCandidate(
                title: item.title,
                representedSource: representedSource(for: item),
                originSet: originsByTitle[item.title] ?? [origin(for: item)]
            )
        }
        let finalPosition = observation.targetCandidate.flatMap { target in
            finalItems.firstIndex { $0.title == target }
        }
        let representedSource = finalPosition.map { finalCandidates[$0].representedSource }

        return BenchmarkEvidenceSnapshot(
            identity: .init(
                registryVersion: BenchmarkEvidenceSnapshot.registryVersion,
                registryCommit: BenchmarkEvidenceSnapshot.registryCommit,
                canonicalCaseID: observation.canonicalCaseID,
                build: observation.build,
                schema: observation.schema,
                flags: observation.flags
            ),
            configuration: observation.configuration,
            inputs: .init(
                provenance: .syntheticFixture,
                normalInput: observation.input.normalInput,
                correctedInput: observation.input.correctedInput
            ),
            candidates: .init(
                normalCandidates: observation.normalItems.map(\.title),
                correctedCandidates: observation.correctedCandidates,
                preDedupeSources: preDedupeSources,
                dedupeDecisions: dedupeDecisions(
                    finalItems: finalItems,
                    sourcesByTitle: Dictionary(grouping: preDedupeSources, by: \.title)
                ),
                learningDecision: observation.learningDecision,
                suppressionDecision: observation.suppressionDecision,
                finalCandidates: finalCandidates,
                finalPosition: finalPosition,
                representedSource: representedSource
            )
        )
    }

    private static func sources(
        normalItems: [CandidateItem],
        correctionItems: [CandidateItem]
    ) -> [BenchmarkEvidenceSnapshot.CandidateSource] {
        normalItems.map {
            .init(title: $0.title, origin: origin(for: $0))
        } + correctionItems.map {
            .init(title: $0.title, origin: origin(for: $0))
        }
    }

    private static func dedupeDecisions(
        finalItems: [CandidateItem],
        sourcesByTitle: [String: [BenchmarkEvidenceSnapshot.CandidateSource]]
    ) -> [BenchmarkEvidenceSnapshot.DedupeDecision] {
        finalItems.compactMap { item in
            guard let sources = sourcesByTitle[item.title] else { return nil }
            let origins = orderedOrigins(Set(sources.map(\.origin)))
            return .init(
                title: item.title,
                originSet: origins,
                representedSource: representedSource(for: item),
                removedDuplicateCount: max(0, sources.count - 1)
            )
        }
    }

    private static func origin(for item: CandidateItem) -> BenchmarkEvidenceSnapshot.CandidateOrigin {
        item.kind == .correctionCandidate ? .typoCorrection : .normalRime
    }

    private static func representedSource(
        for item: CandidateItem
    ) -> BenchmarkEvidenceSnapshot.RepresentedSource {
        item.kind == .correctionCandidate ? .typoCorrection : .normalRime
    }

    private static func orderedOrigins(
        _ origins: Set<BenchmarkEvidenceSnapshot.CandidateOrigin>
    ) -> [BenchmarkEvidenceSnapshot.CandidateOrigin] {
        [.normalRime, .typoCorrection].filter(origins.contains)
    }
}
