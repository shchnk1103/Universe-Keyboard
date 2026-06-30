#if DEBUG
import Foundation

@testable import KeyboardCore

/// Serializable evidence assembled from a correlated Debug-only execution trace.
/// Fixture declarations and execution facts remain separate by construction.
struct BenchmarkEvidenceSnapshot: Codable, Equatable, Sendable {
    static let registryVersion = "1.0.0"
    static let registryCommit = "49b000bcbb3a90d04f00dd803981a24a25b70e28"

    let registryIdentity: RegistryIdentity
    let fixtureMetadata: FixtureMetadata
    let environmentMetadata: EnvironmentMetadata
    let executionFacts: ExecutionFacts
    let evidenceStatus: EvidenceStatus

    struct RegistryIdentity: Codable, Equatable, Sendable {
        let registryVersion: String
        let registryCommit: String
        let canonicalCaseID: String
    }

    struct FixtureMetadata: Codable, Equatable, Sendable {
        let inputProvenance: InputProvenance
        let normalInput: String
        let correctedInput: String?
        let correctedProviderCandidates: [String]
        let requestedFlags: Flags
        let expectedTargetCandidate: String?
    }

    enum InputProvenance: String, Codable, Equatable, Sendable {
        case syntheticFixture
    }

    struct EnvironmentMetadata: Codable, Equatable, Sendable {
        let runID: String
        let invocationID: String
        let captureTime: SourcedValue
        let buildCommit: SourcedValue
        let buildConfiguration: SourcedValue
        let buildTarget: SourcedValue
        let schemaIdentifier: SourcedValue
        let schemaArtifactVersion: SourcedValue
        let environmentManifestDigest: SourcedValue
        let deploymentState: SourcedValue
        let sessionState: SourcedValue
    }

    struct SourcedValue: Codable, Equatable, Sendable {
        let value: String?
        let source: MetadataSource

        fileprivate init(value: String?, source: MetadataSource) {
            self.value = value
            self.source = source
        }
    }

    enum MetadataSource: String, Codable, Equatable, Sendable {
        case buildGenerated
        case verifiedEnvironmentManifest
        case runtimeObservation
        case unavailable
    }

    struct Flags: Codable, Equatable, Sendable {
        let insertionEnabled: Bool
        let transpositionEnabled: Bool
        let typoPartialCommitEnabled: Bool
    }

    struct ExecutionFacts: Codable, Equatable, Sendable {
        let effectiveFlags: Availability<Flags>
        let suppressionDecision: Availability<DecisionFact<SuppressionDecision>>
        let learningDecision: Availability<DecisionFact<LearningDecision>>
        let preDedupeSources: Availability<[CandidateFact]>
        let dedupeDecisions: Availability<[DedupeDecision]>
        let finalCandidates: Availability<[CandidateFact]>
        let finalPosition: Availability<Int?>
        let representedSource: Availability<RepresentedSource?>
        let traceEventCount: Int
        let traceDroppedEventCount: Int
    }

    enum Availability<Value: Codable & Equatable & Sendable>: Codable, Equatable, Sendable {
        case observed(Value)
        case unavailable(reason: String)
    }

    struct DecisionFact<Value: Codable & Equatable & Sendable>: Codable, Equatable, Sendable {
        let subject: DecisionSubject
        let decision: Value
    }

    struct DecisionSubject: Codable, Equatable, Sendable {
        let correlationID: String
        let candidateTitle: String?
    }

    enum SuppressionDecision: String, Codable, Equatable, Sendable {
        case notApplicable
        case notSuppressed
        case suppressedNormalTopMatchesCorrectedBest
    }

    enum LearningDecision: Codable, Equatable, Sendable {
        case ineligible
        case noRecord
        case nearFront(selectionCount: Int)
        case topPromotion(selectionCount: Int)
        case blockedByPrefix(selectionCount: Int)
        case notPromoted(selectionCount: Int)
        case notEvaluatedDueSuppression
    }

    struct CandidateFact: Codable, Equatable, Sendable {
        let title: String
        let subject: DecisionSubject?
        let representedSource: RepresentedSource
        let originSet: [RepresentedSource]
    }

    struct DedupeDecision: Codable, Equatable, Sendable {
        let title: String
        let originSet: [RepresentedSource]
        let representedSource: RepresentedSource
        let removedDuplicateCount: Int
    }

    enum RepresentedSource: String, Codable, Equatable, Sendable {
        case normalRime
        case typoCorrection
    }

    enum EvidenceStatus: Codable, Equatable, Sendable {
        case ready
        case blocked(reasons: [String])
    }
}

struct BenchmarkEvidenceFixture: Equatable, Sendable {
    let canonicalCaseID: String
    let normalInput: String
    let correctedInput: String?
    let correctedProviderCandidates: [String]
    let requestedFlags: BenchmarkEvidenceSnapshot.Flags
    let expectedTargetCandidate: String?
}

struct BenchmarkEnvironmentBinding: Equatable, Sendable {
    fileprivate let runID: String
    fileprivate let captureTime: BenchmarkEvidenceSnapshot.SourcedValue
    fileprivate let buildCommit: BenchmarkEvidenceSnapshot.SourcedValue
    fileprivate let buildConfiguration: BenchmarkEvidenceSnapshot.SourcedValue
    fileprivate let buildTarget: BenchmarkEvidenceSnapshot.SourcedValue
    fileprivate let schemaIdentifier: BenchmarkEvidenceSnapshot.SourcedValue
    fileprivate let schemaArtifactVersion: BenchmarkEvidenceSnapshot.SourcedValue
    fileprivate let environmentManifestDigest: BenchmarkEvidenceSnapshot.SourcedValue
    fileprivate let deploymentState: BenchmarkEvidenceSnapshot.SourcedValue
    fileprivate let sessionState: BenchmarkEvidenceSnapshot.SourcedValue

    fileprivate init(
        runID: String,
        captureTime: BenchmarkEvidenceSnapshot.SourcedValue,
        buildCommit: BenchmarkEvidenceSnapshot.SourcedValue,
        buildConfiguration: BenchmarkEvidenceSnapshot.SourcedValue,
        buildTarget: BenchmarkEvidenceSnapshot.SourcedValue,
        schemaIdentifier: BenchmarkEvidenceSnapshot.SourcedValue,
        schemaArtifactVersion: BenchmarkEvidenceSnapshot.SourcedValue,
        environmentManifestDigest: BenchmarkEvidenceSnapshot.SourcedValue,
        deploymentState: BenchmarkEvidenceSnapshot.SourcedValue,
        sessionState: BenchmarkEvidenceSnapshot.SourcedValue
    ) {
        self.runID = runID
        self.captureTime = captureTime
        self.buildCommit = buildCommit
        self.buildConfiguration = buildConfiguration
        self.buildTarget = buildTarget
        self.schemaIdentifier = schemaIdentifier
        self.schemaArtifactVersion = schemaArtifactVersion
        self.environmentManifestDigest = environmentManifestDigest
        self.deploymentState = deploymentState
        self.sessionState = sessionState
    }
}

/// The only environment constructor currently available. Trusted adapters must be
/// added next to this factory when real build/runtime/manifest sources exist.
enum BenchmarkEnvironmentBindingFactory {
    static func unavailable(runID: String) -> BenchmarkEnvironmentBinding {
        let unavailable = BenchmarkEvidenceSnapshot.SourcedValue(value: nil, source: .unavailable)
        return BenchmarkEnvironmentBinding(
            runID: runID,
            captureTime: unavailable,
            buildCommit: unavailable,
            buildConfiguration: unavailable,
            buildTarget: unavailable,
            schemaIdentifier: unavailable,
            schemaArtifactVersion: unavailable,
            environmentManifestDigest: unavailable,
            deploymentState: unavailable,
            sessionState: unavailable
        )
    }

    /// Fixture strings are deliberately discarded and cannot acquire a trusted source label.
    static func rejectingFixtureDeclarations(
        runID: String,
        declarations: [String: String]
    ) -> BenchmarkEnvironmentBinding {
        _ = declarations
        return unavailable(runID: runID)
    }
}

enum BenchmarkEvidenceSnapshotBuilder {
    static func capture(
        fixture: BenchmarkEvidenceFixture,
        environment: BenchmarkEnvironmentBinding,
        trace: TypoCorrectionDecisionTrace.Capture
    ) -> BenchmarkEvidenceSnapshot {
        var blockers: [String] = []
        validateTrace(trace, blockers: &blockers)
        validateEnvironment(environment, blockers: &blockers)

        let flagsEvents = events(in: trace) { kind -> TypoCorrectionDecisionTrace.EffectiveFlags? in
            guard case let .effectiveFlags(flags) = kind else { return nil }
            return flags
        }
        let suppressionEvents = events(in: trace) {
            kind -> TypoCorrectionDecisionTrace.DecisionEvent<TypoCorrectionDecisionTrace.Suppression>? in
            guard case let .suppression(event) = kind else { return nil }
            return event
        }
        let learningEvents = events(in: trace) {
            kind -> TypoCorrectionDecisionTrace.DecisionEvent<TypoCorrectionDecisionTrace.LearningDecision>? in
            guard case let .learning(event) = kind else { return nil }
            return event
        }
        let mergeEvents = events(in: trace) { kind -> TypoCorrectionDecisionTrace.Merge? in
            guard case let .merge(merge) = kind else { return nil }
            return merge
        }
        if suppressionEvents.isEmpty {
            blockers.append("missing suppression execution event")
        }
        if learningEvents.isEmpty {
            blockers.append("missing learning execution event")
        }
        let flagsEvent = unique(
            flagsEvents,
            missing: "missing effective-flags execution event",
            ambiguous: "multiple effective-flags events for one invocation",
            blockers: &blockers
        )
        let mergeEvent = unique(
            mergeEvents,
            missing: "missing merge execution event",
            ambiguous: "multiple merge events for one invocation",
            blockers: &blockers
        )
        let subject = correlatedSubject(
            fixture: fixture,
            mergeEvent: mergeEvent,
            suppressionEvents: suppressionEvents,
            blockers: &blockers
        )
        let suppressionEvent = correlatedEvent(
            suppressionEvents,
            subject: subject,
            name: "suppression",
            blockers: &blockers
        )
        let learningEvent = correlatedEvent(
            learningEvents,
            subject: subject,
            name: "learning",
            blockers: &blockers
        )

        let effectiveFlags: BenchmarkEvidenceSnapshot.Availability<BenchmarkEvidenceSnapshot.Flags>
        if let flagsEvent {
            effectiveFlags = .observed(.init(
                insertionEnabled: flagsEvent.insertionEnabled,
                transpositionEnabled: flagsEvent.transpositionEnabled,
                typoPartialCommitEnabled: flagsEvent.typoPartialCommitEnabled
            ))
        } else {
            effectiveFlags = .unavailable(reason: "effective-flags execution fact unavailable")
        }

        let suppressionDecision: BenchmarkEvidenceSnapshot.Availability<
            BenchmarkEvidenceSnapshot.DecisionFact<BenchmarkEvidenceSnapshot.SuppressionDecision>
        >
        if let suppressionEvent {
            suppressionDecision = .observed(.init(
                subject: map(suppressionEvent.subject),
                decision: map(suppressionEvent.decision)
            ))
        } else {
            suppressionDecision = .unavailable(reason: "suppression execution fact unavailable")
        }

        let learningDecision: BenchmarkEvidenceSnapshot.Availability<
            BenchmarkEvidenceSnapshot.DecisionFact<BenchmarkEvidenceSnapshot.LearningDecision>
        >
        if let learningEvent {
            learningDecision = .observed(.init(
                subject: map(learningEvent.subject),
                decision: map(learningEvent.decision)
            ))
        } else {
            learningDecision = .unavailable(reason: "learning execution fact unavailable")
        }

        let preDedupeSources: BenchmarkEvidenceSnapshot.Availability<[BenchmarkEvidenceSnapshot.CandidateFact]>
        let dedupeDecisions: BenchmarkEvidenceSnapshot.Availability<[BenchmarkEvidenceSnapshot.DedupeDecision]>
        let finalCandidates: BenchmarkEvidenceSnapshot.Availability<[BenchmarkEvidenceSnapshot.CandidateFact]>
        let finalPosition: BenchmarkEvidenceSnapshot.Availability<Int?>
        let representedSource: BenchmarkEvidenceSnapshot.Availability<BenchmarkEvidenceSnapshot.RepresentedSource?>

        if let mergeEvent {
            if !mergeEvent.isComplete {
                blockers.append("merge trace payload exceeded bounded capacity")
            }
            let mappedFinal = mergeEvent.finalCandidates.map(map)
            preDedupeSources = .observed(mergeEvent.preDedupeSources.map(map))
            dedupeDecisions = .observed(mergeEvent.dedupeDecisions.map(map))
            finalCandidates = .observed(mappedFinal)
            let position = fixture.expectedTargetCandidate.flatMap { target in
                mappedFinal.firstIndex { $0.title == target }
            }
            finalPosition = .observed(position)
            representedSource = .observed(position.map { mappedFinal[$0].representedSource })
        } else {
            let reason = "merge execution fact unavailable"
            preDedupeSources = .unavailable(reason: reason)
            dedupeDecisions = .unavailable(reason: reason)
            finalCandidates = .unavailable(reason: reason)
            finalPosition = .unavailable(reason: reason)
            representedSource = .unavailable(reason: reason)
        }

        return BenchmarkEvidenceSnapshot(
            registryIdentity: .init(
                registryVersion: BenchmarkEvidenceSnapshot.registryVersion,
                registryCommit: BenchmarkEvidenceSnapshot.registryCommit,
                canonicalCaseID: fixture.canonicalCaseID
            ),
            fixtureMetadata: .init(
                inputProvenance: .syntheticFixture,
                normalInput: fixture.normalInput,
                correctedInput: fixture.correctedInput,
                correctedProviderCandidates: fixture.correctedProviderCandidates,
                requestedFlags: fixture.requestedFlags,
                expectedTargetCandidate: fixture.expectedTargetCandidate
            ),
            environmentMetadata: .init(
                runID: environment.runID,
                invocationID: trace.invocationID,
                captureTime: environment.captureTime,
                buildCommit: environment.buildCommit,
                buildConfiguration: environment.buildConfiguration,
                buildTarget: environment.buildTarget,
                schemaIdentifier: environment.schemaIdentifier,
                schemaArtifactVersion: environment.schemaArtifactVersion,
                environmentManifestDigest: environment.environmentManifestDigest,
                deploymentState: environment.deploymentState,
                sessionState: environment.sessionState
            ),
            executionFacts: .init(
                effectiveFlags: effectiveFlags,
                suppressionDecision: suppressionDecision,
                learningDecision: learningDecision,
                preDedupeSources: preDedupeSources,
                dedupeDecisions: dedupeDecisions,
                finalCandidates: finalCandidates,
                finalPosition: finalPosition,
                representedSource: representedSource,
                traceEventCount: trace.events.count,
                traceDroppedEventCount: trace.droppedEventCount
            ),
            evidenceStatus: blockers.isEmpty ? .ready : .blocked(reasons: blockers)
        )
    }

    private static func validateTrace(
        _ trace: TypoCorrectionDecisionTrace.Capture,
        blockers: inout [String]
    ) {
        if trace.droppedEventCount > 0 {
            blockers.append("trace event capacity exceeded")
        }
        for (expectedSequence, event) in trace.events.enumerated() {
            if event.invocationID != trace.invocationID {
                blockers.append("trace correlation mismatch")
                break
            }
            if event.sequence != expectedSequence {
                blockers.append("trace sequence is not deterministic")
                break
            }
        }
    }

    private static func validateEnvironment(
        _ environment: BenchmarkEnvironmentBinding,
        blockers: inout [String]
    ) {
        let required = [
            environment.captureTime,
            environment.buildCommit,
            environment.buildConfiguration,
            environment.buildTarget,
            environment.schemaIdentifier,
            environment.schemaArtifactVersion,
            environment.environmentManifestDigest,
            environment.deploymentState,
            environment.sessionState,
        ]
        if required.contains(where: { $0.source == .unavailable || $0.value == nil }) {
            blockers.append("required environment metadata unavailable")
        }
    }

    private static func events<Value>(
        in trace: TypoCorrectionDecisionTrace.Capture,
        extract: (TypoCorrectionDecisionTrace.Kind) -> Value?
    ) -> [Value] {
        trace.events.compactMap { extract($0.kind) }
    }

    private static func unique<Value>(
        _ values: [Value],
        missing: String,
        ambiguous: String,
        blockers: inout [String]
    ) -> Value? {
        guard !values.isEmpty else {
            blockers.append(missing)
            return nil
        }
        guard values.count == 1 else {
            blockers.append(ambiguous)
            return nil
        }
        return values[0]
    }

    private static func correlatedSubject(
        fixture: BenchmarkEvidenceFixture,
        mergeEvent: TypoCorrectionDecisionTrace.Merge?,
        suppressionEvents: [TypoCorrectionDecisionTrace.DecisionEvent<TypoCorrectionDecisionTrace.Suppression>],
        blockers: inout [String]
    ) -> TypoCorrectionDecisionTrace.DecisionSubject? {
        let target = fixture.expectedTargetCandidate
        let mergeSubjects = mergeEvent?.finalCandidates.compactMap { fact in
            fact.title == target ? fact.subject : nil
        } ?? []
        let suppressionSubjects = suppressionEvents.compactMap { event in
            event.subject.candidateTitle == target ? event.subject : nil
        }
        let subjects = Array(Set(mergeSubjects + suppressionSubjects))
        guard !subjects.isEmpty else {
            blockers.append("missing decision subject correlation")
            return nil
        }
        guard subjects.count == 1 else {
            blockers.append("ambiguous decision subject correlation")
            return nil
        }
        return subjects[0]
    }

    private static func correlatedEvent<Value>(
        _ events: [TypoCorrectionDecisionTrace.DecisionEvent<Value>],
        subject: TypoCorrectionDecisionTrace.DecisionSubject?,
        name: String,
        blockers: inout [String]
    ) -> TypoCorrectionDecisionTrace.DecisionEvent<Value>? {
        guard let subject else { return nil }
        let matches = events.filter { $0.subject == subject }
        return unique(
            matches,
            missing: "missing \(name) event for correlated subject",
            ambiguous: "multiple \(name) events for correlated subject",
            blockers: &blockers
        )
    }

    private static func map(
        _ value: TypoCorrectionDecisionTrace.Suppression
    ) -> BenchmarkEvidenceSnapshot.SuppressionDecision {
        switch value {
        case .notApplicable: .notApplicable
        case .notSuppressed: .notSuppressed
        case .suppressedNormalTopMatchesCorrectedBest: .suppressedNormalTopMatchesCorrectedBest
        }
    }

    private static func map(
        _ value: TypoCorrectionDecisionTrace.LearningDecision
    ) -> BenchmarkEvidenceSnapshot.LearningDecision {
        switch value {
        case .ineligible: .ineligible
        case .noRecord: .noRecord
        case let .nearFront(count): .nearFront(selectionCount: count)
        case let .topPromotion(count): .topPromotion(selectionCount: count)
        case let .blockedByPrefix(count): .blockedByPrefix(selectionCount: count)
        case let .notPromoted(count): .notPromoted(selectionCount: count)
        case .notEvaluatedDueSuppression: .notEvaluatedDueSuppression
        }
    }

    private static func map(
        _ fact: TypoCorrectionDecisionTrace.CandidateFact
    ) -> BenchmarkEvidenceSnapshot.CandidateFact {
        .init(
            title: fact.title,
            subject: fact.subject.map(map),
            representedSource: map(fact.representedSource),
            originSet: fact.originSet.map(map)
        )
    }

    private static func map(
        _ decision: TypoCorrectionDecisionTrace.DedupeDecision
    ) -> BenchmarkEvidenceSnapshot.DedupeDecision {
        .init(
            title: decision.title,
            originSet: decision.originSet.map(map),
            representedSource: map(decision.representedSource),
            removedDuplicateCount: decision.removedDuplicateCount
        )
    }

    private static func map(
        _ subject: TypoCorrectionDecisionTrace.DecisionSubject
    ) -> BenchmarkEvidenceSnapshot.DecisionSubject {
        .init(
            correlationID: subject.correlationID,
            candidateTitle: subject.candidateTitle
        )
    }

    private static func map(
        _ source: TypoCorrectionDecisionTrace.Source
    ) -> BenchmarkEvidenceSnapshot.RepresentedSource {
        switch source {
        case .normalRime: .normalRime
        case .typoCorrection: .typoCorrection
        }
    }
}
#endif
