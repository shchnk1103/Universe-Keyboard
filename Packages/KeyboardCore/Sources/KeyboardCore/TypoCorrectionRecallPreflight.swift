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

struct TypoCorrectionRecallPreflightOperation: Hashable, Sendable {
    let compositionRevision: UInt64
    let sessionEpoch: UInt64
    /// 仅在内存中递增，用来区分恰好复用了 revision/epoch 的新一轮操作。
    /// 它不是用户输入，也不应写入常规诊断。
    let ordinal: UInt64

    init(compositionRevision: UInt64, sessionEpoch: UInt64, ordinal: UInt64 = 0) {
        self.compositionRevision = compositionRevision
        self.sessionEpoch = sessionEpoch
        self.ordinal = ordinal
    }
}

/// Stable identity for one corrected-input group within a preflight operation.
/// The ledger never needs the raw input to deduplicate accepted groups.
struct TypoCorrectionRecallPreflightGroupID: Hashable, Sendable {
    private let operation: TypoCorrectionRecallPreflightOperation?
    private let ordinal: UInt64

    /// 保留给纯 Core 测试与调用方手动构造不透明标识；生产映射应使用
    /// `TypoCorrectionRecallPreflightGroupRegistry`，从而带上 operation 边界。
    init(_ rawValue: UInt64) {
        operation = nil
        ordinal = rawValue
    }

    fileprivate init(operation: TypoCorrectionRecallPreflightOperation, ordinal: UInt64) {
        self.operation = operation
        self.ordinal = ordinal
    }
}

/// Preflight-only selection caps. Selection and sidecar attempts deliberately
/// remain different values: a future scheduler may abstain before querying a
/// selected group, but it may never exceed either bound.
struct TypoCorrectionRecallPreflightSelectionBudget: Equatable, Sendable {
    let maximumSelectedGroups: Int
    let maxQueryAttempts: Int

    static let substitutionOnly = TypoCorrectionRecallPreflightSelectionBudget(
        maximumSelectedGroups: 8,
        maxQueryAttempts: 8
    )

    init(maximumSelectedGroups: Int, maxQueryAttempts: Int) {
        precondition(maximumSelectedGroups > 0)
        precondition(maxQueryAttempts > 0)
        self.maximumSelectedGroups = maximumSelectedGroups
        self.maxQueryAttempts = maxQueryAttempts
    }

    func executionBudget(
        candidateLimit: Int = 3,
        maximumResolvedGroups: Int = 4
    ) -> TypoCorrectionRecallPreflightExecutionBudget {
        TypoCorrectionRecallPreflightExecutionBudget(
            maximumBatchSize: maximumSelectedGroups,
            candidateLimit: candidateLimit,
            maximumResolvedGroups: maximumResolvedGroups,
            maxQueryAttempts: maxQueryAttempts
        )
    }
}

/// Operation-private normalization and opaque identity allocation.
///
/// The dictionary contains corrected inputs only while a preflight operation
/// exists. Its caller passes GroupID to accounting; no caller needs to expose
/// the input when recording counters or deciding whether publication is safe.
struct TypoCorrectionRecallPreflightGroupRegistry: Sendable {
    let operation: TypoCorrectionRecallPreflightOperation

    private var groupIDsByNormalizedInput: [String: TypoCorrectionRecallPreflightGroupID] = [:]
    private var nextOrdinal: UInt64 = 0

    init(operation: TypoCorrectionRecallPreflightOperation) {
        self.operation = operation
    }

    mutating func groupID(
        for correctedInput: String,
        in operation: TypoCorrectionRecallPreflightOperation
    ) -> TypoCorrectionRecallPreflightGroupID? {
        guard operation == self.operation else { return nil }
        let normalized = correctedInput.lowercased().filter { !$0.isWhitespace }
        guard !normalized.isEmpty else { return nil }

        if let existing = groupIDsByNormalizedInput[normalized] {
            return existing
        }

        nextOrdinal += 1
        let groupID = TypoCorrectionRecallPreflightGroupID(
            operation: operation,
            ordinal: nextOrdinal
        )
        groupIDsByNormalizedInput[normalized] = groupID
        return groupID
    }
}

/// A single selected group remains purely in memory until a future scheduler
/// decides whether it may start a sidecar query. This type does not publish or
/// carry candidate results.
struct TypoCorrectionRecallPreflightSelectedGroup: Sendable {
    let groupID: TypoCorrectionRecallPreflightGroupID
    let suggestion: TypoCorrectionSuggestion
}

/// Deterministic, substitution-only structural coverage selector.
///
/// It intentionally sorts by edit geometry rather than the hypothesis engine's
/// global rank: wider edit spans cover independent touch regions first, then
/// nearer keyboard-neighbor pairs, then a stable structural tie-break. This is
/// a local preflight policy, not a semantic scorer or a production ranking.
struct TypoCorrectionRecallPreflightCoverageSelector: Sendable {
    let budget: TypoCorrectionRecallPreflightSelectionBudget

    init(budget: TypoCorrectionRecallPreflightSelectionBudget = .substitutionOnly) {
        self.budget = budget
    }

    func select(
        from hypotheses: [TypoCorrectionSuggestion],
        registry: inout TypoCorrectionRecallPreflightGroupRegistry
    ) -> [TypoCorrectionRecallPreflightSelectedGroup] {
        let ordered = hypotheses.compactMap { suggestion -> RankedSuggestion? in
            guard let signature = StructuralSignature(suggestion: suggestion) else { return nil }
            return RankedSuggestion(suggestion: suggestion, signature: signature)
        }
        .sorted(by: RankedSuggestion.isPreferred)

        var selected: [TypoCorrectionRecallPreflightSelectedGroup] = []
        var seenGroupIDs = Set<TypoCorrectionRecallPreflightGroupID>()
        for ranked in ordered {
            guard selected.count < budget.maximumSelectedGroups else { break }
            guard
                let groupID = registry.groupID(
                    for: ranked.suggestion.correctedInput,
                    in: registry.operation
                ),
                seenGroupIDs.insert(groupID).inserted
            else { continue }

            selected.append(
                TypoCorrectionRecallPreflightSelectedGroup(
                    groupID: groupID,
                    suggestion: ranked.suggestion
                )
            )
        }
        return selected
    }

    private struct StructuralSignature: Sendable {
        let minimumIndex: Int
        let maximumIndex: Int
        let editSpan: Int
        let replacementOrderSum: Int
        let correctedInput: String

        init?(suggestion: TypoCorrectionSuggestion) {
            let edits = suggestion.edits.sorted { $0.index < $1.index }
            guard edits.count == 2, edits.allSatisfy({ $0.kind == .substitution }) else {
                return nil
            }

            let replacementOrders = edits.compactMap { edit in
                TypoCorrectionKeyboard.nearbyKeys[edit.original]?.firstIndex(of: edit.replacement)
            }
            guard replacementOrders.count == edits.count else { return nil }

            minimumIndex = edits[0].index
            maximumIndex = edits[1].index
            editSpan = maximumIndex - minimumIndex
            replacementOrderSum = replacementOrders.reduce(0, +)
            correctedInput = suggestion.correctedInput
        }
    }

    private struct RankedSuggestion: Sendable {
        let suggestion: TypoCorrectionSuggestion
        let signature: StructuralSignature

        static func isPreferred(_ lhs: RankedSuggestion, _ rhs: RankedSuggestion) -> Bool {
            if lhs.signature.editSpan != rhs.signature.editSpan {
                return lhs.signature.editSpan > rhs.signature.editSpan
            }
            if lhs.signature.replacementOrderSum != rhs.signature.replacementOrderSum {
                return lhs.signature.replacementOrderSum < rhs.signature.replacementOrderSum
            }
            if lhs.signature.minimumIndex != rhs.signature.minimumIndex {
                return lhs.signature.minimumIndex < rhs.signature.minimumIndex
            }
            if lhs.signature.maximumIndex != rhs.signature.maximumIndex {
                return lhs.signature.maximumIndex < rhs.signature.maximumIndex
            }
            return lhs.signature.correctedInput < rhs.signature.correctedInput
        }
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
