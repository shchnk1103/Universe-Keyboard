#if DEBUG
import Foundation

/// Non-shipping, bounded execution trace for synthetic typo-correction evidence.
///
/// The active invocation is thread-local so decision points only perform synchronous
/// in-memory bookkeeping. Shipping Release builds do not compile this file's types
/// or observation calls.
enum TypoCorrectionDecisionTrace {
    static let maximumEventsPerInvocation = 64
    static let maximumSubjectsPerInvocation = 64
    static let maximumCandidatesPerMergeEvent = 64
    static let maximumCandidateTitleLength = 64
    private static let contextKey = "universe.keyboard.typo-decision-trace"

    struct Capture: Equatable, Sendable {
        let invocationID: String
        let events: [Event]
        let droppedEventCount: Int
    }

    struct Event: Equatable, Sendable {
        let invocationID: String
        let sequence: Int
        let kind: Kind
    }

    enum Kind: Equatable, Sendable {
        case effectiveFlags(EffectiveFlags)
        case suppression(DecisionEvent<Suppression>)
        case learning(DecisionEvent<LearningDecision>)
        case merge(Merge)
    }

    struct DecisionEvent<Value: Equatable & Sendable>: Equatable, Sendable {
        let subject: DecisionSubject
        let decision: Value
    }

    struct DecisionSubject: Equatable, Hashable, Sendable {
        let correlationID: String
        let candidateTitle: String?
    }

    struct EffectiveFlags: Equatable, Sendable {
        let insertionEnabled: Bool
        let transpositionEnabled: Bool
        let typoPartialCommitEnabled: Bool
    }

    enum Suppression: Equatable, Sendable {
        case notApplicable
        case notSuppressed
        case suppressedNormalTopMatchesCorrectedBest
    }

    enum LearningDecision: Equatable, Sendable {
        case top(finalPosition: Int)
        case nearFront(finalPosition: Int)
        case present(finalPosition: Int)
        case absent
        case notEvaluatedDueSuppression
    }

    struct Merge: Equatable, Sendable {
        let preDedupeSources: [CandidateFact]
        let finalCandidates: [CandidateFact]
        let dedupeDecisions: [DedupeDecision]
        let isComplete: Bool
    }

    struct CandidateFact: Equatable, Sendable {
        let title: String
        let subject: DecisionSubject?
        let representedSource: Source
        let originSet: [Source]
    }

    struct DedupeDecision: Equatable, Sendable {
        let title: String
        let originSet: [Source]
        let representedSource: Source
        let removedDuplicateCount: Int
    }

    enum Source: String, Equatable, Hashable, Sendable {
        case normalRime
        case typoCorrection
    }

    static func withSyntheticInvocation<Result>(
        id invocationID: String,
        _ operation: () throws -> Result
    ) rethrows -> (result: Result, capture: Capture) {
        precondition(currentContext == nil, "Nested typo decision trace invocations are not supported")
        let context = Context(invocationID: invocationID)
        Thread.current.threadDictionary[contextKey] = context
        defer { Thread.current.threadDictionary.removeObject(forKey: contextKey) }

        let result = try operation()
        return (
            result,
            Capture(
                invocationID: invocationID,
                events: context.events,
                droppedEventCount: context.droppedEventCount
            )
        )
    }

    static var isCapturing: Bool {
        currentContext != nil
    }

    static func record(_ kind: @autoclosure () -> Kind) {
        guard let context = currentContext else { return }
        context.append(kind())
    }

    static func subject(for correction: TypoCorrectionCommit) -> DecisionSubject {
        let editIdentity = correction.edits.map { edit in
            "\(edit.kind):\(edit.index):\(edit.secondIndex ?? -1)"
        }.joined(separator: ",")
        let material = [
            correction.originalInput,
            correction.correctedInput,
            correction.committedText,
            editIdentity,
        ].joined(separator: "|")
        guard let context = currentContext else { return invocationSubject }
        return context.subject(
            for: material,
            candidateTitle: boundedTitle(correction.committedText)
        )
    }

    static var invocationSubject: DecisionSubject {
        DecisionSubject(correlationID: "invocation", candidateTitle: nil)
    }

    private static var currentContext: Context? {
        Thread.current.threadDictionary[contextKey] as? Context
    }

    private static func boundedTitle(_ title: String) -> String {
        String(title.prefix(maximumCandidateTitleLength))
    }

    private final class Context: NSObject {
        let invocationID: String
        var events: [Event] = []
        var droppedEventCount = 0
        var subjectsByMaterial: [String: DecisionSubject] = [:]

        init(invocationID: String) {
            self.invocationID = invocationID
        }

        func append(_ kind: Kind) {
            guard events.count < maximumEventsPerInvocation else {
                droppedEventCount += 1
                return
            }
            events.append(
                Event(
                    invocationID: invocationID,
                    sequence: events.count,
                    kind: kind
                )
            )
        }

        func subject(for material: String, candidateTitle: String) -> DecisionSubject {
            if let existing = subjectsByMaterial[material] {
                return existing
            }
            guard subjectsByMaterial.count < maximumSubjectsPerInvocation else {
                droppedEventCount += 1
                return DecisionSubject(correlationID: "subject-overflow", candidateTitle: candidateTitle)
            }
            let subject = DecisionSubject(
                correlationID: "subject-\(subjectsByMaterial.count)",
                candidateTitle: candidateTitle
            )
            subjectsByMaterial[material] = subject
            return subject
        }
    }
}
#endif
