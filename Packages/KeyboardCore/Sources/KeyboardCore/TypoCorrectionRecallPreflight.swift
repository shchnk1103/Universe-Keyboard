import Foundation

/// Defines which edit operations a recall preflight may generate.
///
/// Production contextual correction keeps the historical all-operation policy.
/// The first bounded preflight slice is substitution-only so that a second
/// stage cannot silently widen its safety contract while measuring recall.
struct TypoCorrectionEditPolicy: Equatable, Sendable {
    private let allowedKinds: [TypoCorrectionEditKind]

    static let all = TypoCorrectionEditPolicy(
        allowedKinds: [.substitution, .transposition, .deletion, .insertion]
    )

    static let substitutionOnly = TypoCorrectionEditPolicy(allowedKinds: [.substitution])

    init(allowedKinds: [TypoCorrectionEditKind]) {
        self.allowedKinds = allowedKinds
    }

    func allows(_ kind: TypoCorrectionEditKind) -> Bool {
        allowedKinds.contains(kind)
    }
}

/// Execution limits for a future sidecar scheduler.
///
/// This is a pure Core contract. It does not call RIME and is not referenced
/// by the production controller. The explicit eight-attempt cap is one
/// bounded preflight batch, not a production performance claim.
struct TypoCorrectionRecallPreflightExecutionBudget: Equatable, Sendable {
    let maximumBatchSize: Int
    let candidateLimit: Int
    let maximumResolvedGroups: Int
    let maxQueryAttempts: Int

    static let substitutionOnly = TypoCorrectionRecallPreflightExecutionBudget(
        maximumBatchSize: 8,
        candidateLimit: 3,
        maximumResolvedGroups: 4,
        maxQueryAttempts: 8
    )

    init(
        maximumBatchSize: Int,
        candidateLimit: Int,
        maximumResolvedGroups: Int,
        maxQueryAttempts: Int
    ) {
        precondition(maximumBatchSize > 0)
        precondition(candidateLimit > 0)
        precondition(maximumResolvedGroups > 0)
        precondition(maxQueryAttempts > 0)
        self.maximumBatchSize = maximumBatchSize
        self.candidateLimit = candidateLimit
        self.maximumResolvedGroups = maximumResolvedGroups
        self.maxQueryAttempts = maxQueryAttempts
    }
}

struct TypoCorrectionRecallPreflightOperation: Equatable, Sendable {
    let compositionRevision: UInt64
    let sessionEpoch: UInt64
}

/// Stable identity for one corrected-input group within a preflight operation.
/// The ledger never needs the raw input to deduplicate accepted groups.
struct TypoCorrectionRecallPreflightGroupID: Hashable, Sendable {
    let rawValue: UInt64

    init(_ rawValue: UInt64) {
        self.rawValue = rawValue
    }
}

struct TypoCorrectionRecallPreflightCounters: Equatable, Sendable {
    private(set) var nGenerated = 0
    private(set) var nQueryAttempts = 0
    private(set) var nResolvedGroups = 0
    private(set) var nCandidatesReturned = 0

    mutating func addGenerated(_ count: Int) {
        nGenerated += count
    }

    mutating func recordQueryAttempt() {
        nQueryAttempts += 1
    }

    mutating func addCandidatesReturned(_ count: Int) {
        nCandidatesReturned += count
    }

    mutating func recordResolvedGroup() {
        nResolvedGroups += 1
    }
}

enum TypoCorrectionRecallPreflightTermination: Equatable, Sendable {
    case running
    case cancelled
    case queryAttemptLimitReached
    case resolvedGroupLimitReached
    case contractViolation
}

/// A synchronous state machine for the future cancellable query scheduler.
///
/// The ledger makes the four counters and publish fences testable without a
/// RIME dependency. A stale result may still count as a started query and as
/// returned candidate data, but it cannot become a resolved group or publish.
struct TypoCorrectionRecallPreflightLedger: Sendable {
    let budget: TypoCorrectionRecallPreflightExecutionBudget
    let operation: TypoCorrectionRecallPreflightOperation

    private(set) var currentOperation: TypoCorrectionRecallPreflightOperation
    private(set) var counters = TypoCorrectionRecallPreflightCounters()
    private(set) var termination = TypoCorrectionRecallPreflightTermination.running

    private var inFlightOperation: TypoCorrectionRecallPreflightOperation?
    private var openBatchOperation: TypoCorrectionRecallPreflightOperation?
    private var queriesInOpenBatch = 0
    private var resolvedGroupIDs = Set<TypoCorrectionRecallPreflightGroupID>()

    init(
        operation: TypoCorrectionRecallPreflightOperation,
        budget: TypoCorrectionRecallPreflightExecutionBudget = .substitutionOnly
    ) {
        self.budget = budget
        self.operation = operation
        currentOperation = operation
    }

    mutating func recordGenerated(_ count: Int) {
        guard count >= 0, termination != .contractViolation else { return }
        counters.addGenerated(count)
    }

    mutating func beginBatch(for operation: TypoCorrectionRecallPreflightOperation) -> Bool {
        guard permitsWork(for: operation), inFlightOperation == nil, openBatchOperation == nil else {
            return false
        }
        guard counters.nQueryAttempts < budget.maxQueryAttempts else {
            termination = .queryAttemptLimitReached
            return false
        }
        guard counters.nResolvedGroups < budget.maximumResolvedGroups else {
            termination = .resolvedGroupLimitReached
            return false
        }
        openBatchOperation = operation
        queriesInOpenBatch = 0
        return true
    }

    mutating func beginQuery(for operation: TypoCorrectionRecallPreflightOperation) -> Bool {
        guard openBatchOperation == operation, inFlightOperation == nil else { return false }
        guard permitsWork(for: operation) else { return false }
        guard counters.nQueryAttempts < budget.maxQueryAttempts else {
            termination = .queryAttemptLimitReached
            return false
        }
        guard queriesInOpenBatch < budget.maximumBatchSize else { return false }
        counters.recordQueryAttempt()
        queriesInOpenBatch += 1
        inFlightOperation = operation
        return true
    }

    /// Records the actual result of a started query.
    ///
    /// `succeeded == false` represents an empty/failed response and still
    /// preserves the query-attempt count. A stale result is counted as
    /// returned data but never accepted as a resolved group.
    @discardableResult
    mutating func finishQuery(
        for operation: TypoCorrectionRecallPreflightOperation,
        groupID: TypoCorrectionRecallPreflightGroupID,
        candidateCount: Int,
        succeeded: Bool = true
    ) -> Bool {
        guard inFlightOperation == operation else { return false }
        inFlightOperation = nil

        guard candidateCount >= 0 else {
            termination = .contractViolation
            return false
        }

        if succeeded {
            counters.addCandidatesReturned(candidateCount)
            guard candidateCount <= budget.candidateLimit else {
                termination = .contractViolation
                return false
            }
        }

        guard succeeded, candidateCount > 0, permitsWork(for: operation) else {
            return false
        }

        if resolvedGroupIDs.contains(groupID) {
            return false
        }

        guard counters.nResolvedGroups < budget.maximumResolvedGroups else {
            termination = .resolvedGroupLimitReached
            return false
        }
        resolvedGroupIDs.insert(groupID)
        counters.recordResolvedGroup()
        return true
    }

    @discardableResult
    mutating func finishBatch(for operation: TypoCorrectionRecallPreflightOperation) -> Bool {
        guard openBatchOperation == operation, inFlightOperation == nil else { return false }
        openBatchOperation = nil
        queriesInOpenBatch = 0
        return permitsWork(for: operation)
    }

    mutating func cancel() {
        termination = .cancelled
    }

    /// Invalidates the old composition while allowing a later operation to
    /// start after the old in-flight query has completed and been discarded.
    mutating func advanceCurrentOperation(
        to operation: TypoCorrectionRecallPreflightOperation
    ) {
        guard operation != currentOperation else { return }
        currentOperation = operation
        resolvedGroupIDs.removeAll()
    }

    func canPublish(
        for operation: TypoCorrectionRecallPreflightOperation
    ) -> Bool {
        operation == currentOperation
            && inFlightOperation == nil
            && openBatchOperation == nil
            && termination != .cancelled
            && termination != .contractViolation
    }

    private func permitsWork(
        for operation: TypoCorrectionRecallPreflightOperation
    ) -> Bool {
        operation == currentOperation
            && termination != .cancelled
            && termination != .contractViolation
    }
}
