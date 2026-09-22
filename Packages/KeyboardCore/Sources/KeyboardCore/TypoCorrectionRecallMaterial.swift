import Foundation

/// Pinned production values for this runtime-integration slice.
public enum TypoCorrectionRecallRuntimeBudget {
    public static let selectedGroups = 8
    public static let maxQueryAttempts = 8
    public static let candidateLimit = 3
    public static let acceptedDisplayResults = 4

    static let selection = TypoCorrectionRecallPreflightSelectionBudget(
        maximumSelectedGroups: selectedGroups,
        maxQueryAttempts: maxQueryAttempts
    )

    static let execution = TypoCorrectionRecallPreflightExecutionBudget(
        maximumBatchSize: selectedGroups,
        candidateLimit: candidateLimit,
        maximumResolvedGroups: acceptedDisplayResults,
        maxQueryAttempts: maxQueryAttempts
    )
}

public struct TypoCorrectionRecallFenceSnapshot: Equatable {
    public var recallEpoch: UInt64
    public var compositionRevision: UInt64
    public var operationOrdinal: UInt64
    public var normalizedComposition: String
    public var page: KeyboardPage
    public var inputMode: InputMode
    public var routeLocalOwnerEpoch: UInt64?

    public init(
        recallEpoch: UInt64,
        compositionRevision: UInt64,
        operationOrdinal: UInt64,
        normalizedComposition: String,
        page: KeyboardPage,
        inputMode: InputMode,
        routeLocalOwnerEpoch: UInt64?
    ) {
        self.recallEpoch = recallEpoch
        self.compositionRevision = compositionRevision
        self.operationOrdinal = operationOrdinal
        self.normalizedComposition = normalizedComposition
        self.page = page
        self.inputMode = inputMode
        self.routeLocalOwnerEpoch = routeLocalOwnerEpoch
    }
}

public struct TypoCorrectionRecallMaterial: Equatable {
    public var token: TypoCorrectionRecallFenceSnapshot
    public var originalInput: String
    public var stageOne: [TypoCorrectionSuggestion]
    public var stageTwo: [TypoCorrectionSuggestion]

    public init(
        token: TypoCorrectionRecallFenceSnapshot,
        originalInput: String,
        stageOne: [TypoCorrectionSuggestion],
        stageTwo: [TypoCorrectionSuggestion]
    ) {
        self.token = token
        self.originalInput = originalInput
        self.stageOne = stageOne
        self.stageTwo = stageTwo
    }

    public var joined: [TypoCorrectionSuggestion] {
        var seen = Set<String>()
        var result: [TypoCorrectionSuggestion] = []
        for suggestion in stageOne + stageTwo {
            let key = suggestion.correctedInput.lowercased()
            guard seen.insert(key).inserted else { continue }
            result.append(suggestion)
        }
        return result
    }
}

public enum TypoCorrectionRecallDriveEvent: Equatable {
    case query(TypoCorrectionSuggestion)
    case waitForYield
    case assessCoverage([TypoCorrectionSuggestion])
    case readyToApply(TypoCorrectionRecallMaterial)
    case discarded
}

func typoCorrectionRecallHasCoverageDeficit(
    acceptedDisplayCount: Int,
    unaccountedSelectedGroupCount: Int,
    remainingQueryAttempts: Int
) -> Bool {
    acceptedDisplayCount == 0
        && unaccountedSelectedGroupCount > 0
        && remainingQueryAttempts > 0
}

/// Value-level scheduler for one recall operation. UIKit owns RunLoop turns;
/// this type never calls RIME or writes `state.typoCorrection`.
public struct TypoCorrectionRecallDriver {
    public private(set) var token: TypoCorrectionRecallFenceSnapshot
    private var registry: TypoCorrectionRecallPreflightGroupRegistry
    private var stageOneQueue: [TypoCorrectionSuggestion]
    private var stageTwoQueue: [TypoCorrectionSuggestion]
    private var stageTwoLedger: TypoCorrectionRecallPreflightLedger
    private var stageOneResolved = 0
    private var awaitingYield = false
    private var startedStageTwo = false
    private var awaitingCoverageDecision = false
    private var stageOne: [TypoCorrectionSuggestion] = []
    private var stageTwo: [TypoCorrectionSuggestion] = []
    private var inFlight: TypoCorrectionSuggestion?
    private var accountedInputs: Set<String> = []

    public init(
        token: TypoCorrectionRecallFenceSnapshot,
        stageOneHypotheses: [TypoCorrectionSuggestion]
    ) {
        self.token = token
        let operation = TypoCorrectionRecallPreflightOperation(
            compositionRevision: token.compositionRevision,
            sessionEpoch: token.recallEpoch,
            ordinal: token.operationOrdinal
        )
        registry = TypoCorrectionRecallPreflightGroupRegistry(operation: operation)
        stageOneQueue = Self.uniqueHypotheses(stageOneHypotheses)
        stageTwoQueue = []
        stageTwoLedger = TypoCorrectionRecallPreflightLedger(
            operation: operation,
            budget: TypoCorrectionRecallRuntimeBudget.execution
        )
        _ = stageTwoLedger.beginBatch(for: operation)
    }

    public mutating func nextEvent(
        currentFence: TypoCorrectionRecallFenceSnapshot
    ) -> TypoCorrectionRecallDriveEvent {
        guard currentFence == token else { return .discarded }
        if awaitingYield {
            return .waitForYield
        }
        if awaitingCoverageDecision {
            return .assessCoverage(stageOne)
        }
        if let inFlight {
            return .query(inFlight)
        }
        if let next = takeNextStageOne() {
            inFlight = next
            return .query(next)
        }
        if !startedStageTwo {
            awaitingCoverageDecision = true
            return .assessCoverage(stageOne)
        }
        if let next = takeNextStageTwo() {
            inFlight = next
            return .query(next)
        }
        return finishApply()
    }

    public mutating func acknowledgeYield(currentFence: TypoCorrectionRecallFenceSnapshot) -> Bool {
        guard currentFence == token, awaitingYield else { return false }
        awaitingYield = false
        return true
    }

    public mutating func finishQuery(
        currentFence: TypoCorrectionRecallFenceSnapshot,
        candidates: [RimeCandidate]
    ) -> TypoCorrectionRecallDriveEvent {
        guard currentFence == token else { return .discarded }
        guard let suggestion = inFlight else { return .discarded }
        inFlight = nil

        let limited = Array(candidates.prefix(TypoCorrectionRecallRuntimeBudget.candidateLimit))
        let filled = TypoCorrectionSuggestion(
            originalInput: suggestion.originalInput,
            correctedInput: suggestion.correctedInput,
            edits: suggestion.edits,
            candidates: limited
        )
        accountedInputs.insert(normalizedInput(suggestion.correctedInput))

        if startedStageTwo {
            let operation = stageTwoLedger.operation
            let groupID =
                registry.groupID(for: suggestion.correctedInput, in: operation)
                ?? TypoCorrectionRecallPreflightGroupID(0)
            _ = stageTwoLedger.finishQuery(
                for: operation,
                groupID: groupID,
                candidateCount: limited.count,
                succeeded: !limited.isEmpty
            )
            if !limited.isEmpty {
                stageTwo.append(filled)
            }
        } else if !limited.isEmpty {
            stageOne.append(filled)
            stageOneResolved += 1
        }

        awaitingYield = true
        return .waitForYield
    }

    public mutating func completeCoverageAssessment(
        currentFence: TypoCorrectionRecallFenceSnapshot,
        acceptedDisplayCount: Int
    ) -> TypoCorrectionRecallDriveEvent {
        guard currentFence == token, awaitingCoverageDecision else { return .discarded }
        awaitingCoverageDecision = false
        startedStageTwo = true

        var selected = TypoCorrectionRecallPreflightCoverageSelector(
            budget: TypoCorrectionRecallRuntimeBudget.selection
        ).select(
            from: ContextualTypoCorrectionSearchPlan(input: token.normalizedComposition)
                .hypotheses,
            registry: &registry
        )
        selected.removeAll {
            accountedInputs.contains(normalizedInput($0.suggestion.correctedInput))
        }

        guard
            typoCorrectionRecallHasCoverageDeficit(
                acceptedDisplayCount: acceptedDisplayCount,
                unaccountedSelectedGroupCount: selected.count,
                remainingQueryAttempts: TypoCorrectionRecallRuntimeBudget.maxQueryAttempts
                    - stageTwoLedger.counters.nQueryAttempts
            )
        else { return finishApply() }

        stageTwoQueue = Array(
            selected.prefix(TypoCorrectionRecallRuntimeBudget.selectedGroups).map(\.suggestion)
        )
        return nextEvent(currentFence: currentFence)
    }

    private mutating func takeNextStageOne() -> TypoCorrectionSuggestion? {
        guard stageOneResolved < TypoCorrectionRecallRuntimeBudget.acceptedDisplayResults else {
            return nil
        }
        while !stageOneQueue.isEmpty {
            let next = stageOneQueue.removeFirst()
            let key = normalizedInput(next.correctedInput)
            guard !accountedInputs.contains(key) else { continue }
            return next
        }
        return nil
    }

    private mutating func takeNextStageTwo() -> TypoCorrectionSuggestion? {
        let operation = stageTwoLedger.operation
        while !stageTwoQueue.isEmpty {
            guard stageTwoLedger.beginQuery(for: operation) else { return nil }
            return stageTwoQueue.removeFirst()
        }
        return nil
    }

    private func finishApply() -> TypoCorrectionRecallDriveEvent {
        .readyToApply(
            TypoCorrectionRecallMaterial(
                token: token,
                originalInput: token.normalizedComposition,
                stageOne: stageOne,
                stageTwo: stageTwo
            )
        )
    }

    private func normalizedInput(_ input: String) -> String {
        input.lowercased().filter { !$0.isWhitespace }
    }

    private static func uniqueHypotheses(
        _ hypotheses: [TypoCorrectionSuggestion]
    ) -> [TypoCorrectionSuggestion] {
        var seen = Set<String>()
        return hypotheses.filter { suggestion in
            seen.insert(suggestion.correctedInput.lowercased().filter { !$0.isWhitespace })
                .inserted
        }
    }
}
