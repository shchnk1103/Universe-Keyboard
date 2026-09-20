import XCTest

@testable import KeyboardCore

@MainActor
final class TypoCorrectionRecallPreflightTests: XCTestCase {
    private let canonicalInput = "wimenjintianquhongyuan"
    private let canonicalTarget = "womenjintianqugongyuan"

    func testDefaultPreflightPlanIsFailClosedToSubstitutions() {
        let plan = ContextualTypoCorrectionSearchPlan(input: canonicalInput)

        XCTAssertTrue(
            plan.hypotheses.allSatisfy { suggestion in
                suggestion.edits.allSatisfy { $0.kind == .substitution }
            })
        XCTAssertTrue(plan.hypotheses.contains { $0.correctedInput == canonicalTarget })
    }

    func testSubstitutionOnlyPolicyExcludesOtherEditKinds() {
        let plan = ContextualTypoCorrectionSearchPlan(
            input: canonicalInput,
            budget: .progressiveRecallPreflight,
            editPolicy: .substitutionOnly
        )

        XCTAssertFalse(plan.hypotheses.isEmpty)
        XCTAssertTrue(
            plan.hypotheses.allSatisfy { suggestion in
                suggestion.edits.count == 2
                    && suggestion.edits.allSatisfy { $0.kind == .substitution }
            })
        XCTAssertTrue(
            plan.hypotheses.contains { $0.correctedInput == canonicalTarget },
            "substitution-only preflight must still reach the canonical two-edit target"
        )
    }

    func testCanonicalTargetRecordsFrontierAndMinimumExpansionThreshold() {
        let firstLayerBudgets = [12, 16, 24, 32, 40, 48, 60]
        let observations = firstLayerBudgets.map { firstLayerStates in
            let suggestions = ContextualTypoCorrectionHypothesisEngine(
                budget: ContextualTypoCorrectionSearchBudget(
                    maximumFirstLayerStates: firstLayerStates,
                    maximumHypotheses: 64
                ),
                editPolicy: .substitutionOnly
            ).hypotheses(for: canonicalInput)
            let rank = suggestions.firstIndex { $0.correctedInput == canonicalTarget }
                .map { $0 + 1 }
            return (firstLayerStates, rank)
        }

        let minimumExpansion = observations.first { $0.1 != nil }?.0
        print("RECALL_PREFLIGHT_FRONTIER observations=\(observations)")

        XCTAssertNotNil(minimumExpansion)
        XCTAssertGreaterThan(minimumExpansion ?? 0, 12)
        XCTAssertEqual(
            observations.last?.1,
            55,
            "the expanded substitution-only rank must remain an observed fact"
        )

        let productionVisible = ContextualTypoCorrectionHypothesisEngine(
            budget: .productionV2,
            editPolicy: .substitutionOnly
        ).hypotheses(for: canonicalInput)
        XCTAssertFalse(productionVisible.contains { $0.correctedInput == canonicalTarget })
    }

    func testPreflightBatchesUseSeparateGenerationAndQueryCounters() {
        let operation = TypoCorrectionRecallPreflightOperation(
            compositionRevision: 4,
            sessionEpoch: 2
        )
        var ledger = TypoCorrectionRecallPreflightLedger(operation: operation)

        ledger.recordGenerated(64)
        XCTAssertTrue(ledger.beginBatch(for: operation))
        XCTAssertTrue(ledger.beginQuery(for: operation))
        XCTAssertTrue(
            ledger.finishQuery(
                for: operation,
                groupID: TypoCorrectionRecallPreflightGroupID(1),
                candidateCount: 3
            )
        )
        XCTAssertTrue(ledger.beginQuery(for: operation))
        XCTAssertFalse(
            ledger.finishQuery(
                for: operation,
                groupID: TypoCorrectionRecallPreflightGroupID(2),
                candidateCount: 0
            )
        )
        XCTAssertTrue(ledger.finishBatch(for: operation))

        XCTAssertEqual(ledger.counters.nGenerated, 64)
        XCTAssertEqual(ledger.counters.nQueryAttempts, 2)
        XCTAssertEqual(ledger.counters.nResolvedGroups, 1)
        XCTAssertEqual(ledger.counters.nCandidatesReturned, 3)
    }

    func testQueryAttemptLimitIsIndependentFromResolvedGroupLimit() {
        let operation = TypoCorrectionRecallPreflightOperation(
            compositionRevision: 1,
            sessionEpoch: 1
        )
        var ledger = TypoCorrectionRecallPreflightLedger(
            operation: operation,
            budget: .init(
                maximumBatchSize: 8,
                candidateLimit: 3,
                maximumResolvedGroups: 4,
                maxQueryAttempts: 8
            )
        )

        XCTAssertTrue(ledger.beginBatch(for: operation))
        for index in 0..<8 {
            XCTAssertTrue(ledger.beginQuery(for: operation))
            XCTAssertFalse(
                ledger.finishQuery(
                    for: operation,
                    groupID: TypoCorrectionRecallPreflightGroupID(UInt64(index)),
                    candidateCount: 0
                )
            )
        }

        XCTAssertFalse(ledger.beginQuery(for: operation))
        XCTAssertTrue(ledger.finishBatch(for: operation))
        XCTAssertFalse(ledger.beginBatch(for: operation))
        XCTAssertEqual(ledger.counters.nQueryAttempts, 8)
        XCTAssertEqual(ledger.counters.nResolvedGroups, 0)
        XCTAssertEqual(ledger.termination, .queryAttemptLimitReached)
    }

    func testCancellationAfterQueryDiscardsResultAndBlocksPublish() {
        let operation = TypoCorrectionRecallPreflightOperation(
            compositionRevision: 7,
            sessionEpoch: 3
        )
        var ledger = TypoCorrectionRecallPreflightLedger(operation: operation)

        XCTAssertTrue(ledger.beginBatch(for: operation))
        XCTAssertTrue(ledger.beginQuery(for: operation))
        ledger.cancel()

        XCTAssertFalse(
            ledger.finishQuery(
                for: operation,
                groupID: TypoCorrectionRecallPreflightGroupID(1),
                candidateCount: 3
            )
        )
        XCTAssertEqual(ledger.counters.nQueryAttempts, 1)
        XCTAssertEqual(ledger.counters.nResolvedGroups, 0)
        XCTAssertEqual(ledger.counters.nCandidatesReturned, 3)
        XCTAssertFalse(ledger.canPublish(for: operation))
        XCTAssertEqual(ledger.termination, .cancelled)
    }

    func testCancellationBeforeBatchPreventsAnyQueryAttempt() {
        let operation = TypoCorrectionRecallPreflightOperation(
            compositionRevision: 7,
            sessionEpoch: 3
        )
        var ledger = TypoCorrectionRecallPreflightLedger(operation: operation)

        ledger.cancel()

        XCTAssertFalse(ledger.beginBatch(for: operation))
        XCTAssertEqual(ledger.counters.nQueryAttempts, 0)
        XCTAssertFalse(ledger.canPublish(for: operation))
    }

    func testRevisionAndEpochFenceRejectsStaleResult() {
        let oldOperation = TypoCorrectionRecallPreflightOperation(
            compositionRevision: 8,
            sessionEpoch: 4
        )
        let newOperation = TypoCorrectionRecallPreflightOperation(
            compositionRevision: 9,
            sessionEpoch: 4
        )
        var ledger = TypoCorrectionRecallPreflightLedger(operation: oldOperation)

        XCTAssertTrue(ledger.beginBatch(for: oldOperation))
        XCTAssertTrue(ledger.beginQuery(for: oldOperation))
        ledger.advanceCurrentOperation(to: newOperation)

        XCTAssertFalse(
            ledger.finishQuery(
                for: oldOperation,
                groupID: TypoCorrectionRecallPreflightGroupID(1),
                candidateCount: 2
            )
        )
        XCTAssertEqual(ledger.counters.nQueryAttempts, 1)
        XCTAssertEqual(ledger.counters.nResolvedGroups, 0)
        XCTAssertEqual(ledger.counters.nCandidatesReturned, 2)
        XCTAssertFalse(ledger.canPublish(for: oldOperation))
        XCTAssertFalse(ledger.finishBatch(for: oldOperation))
        XCTAssertTrue(ledger.beginBatch(for: newOperation))
        XCTAssertTrue(ledger.finishBatch(for: newOperation))
        XCTAssertTrue(ledger.canPublish(for: newOperation))
    }

    func testCandidateLimitViolationFailsClosed() {
        let operation = TypoCorrectionRecallPreflightOperation(
            compositionRevision: 1,
            sessionEpoch: 1
        )
        var ledger = TypoCorrectionRecallPreflightLedger(operation: operation)

        XCTAssertTrue(ledger.beginBatch(for: operation))
        XCTAssertTrue(ledger.beginQuery(for: operation))
        XCTAssertFalse(
            ledger.finishQuery(
                for: operation,
                groupID: TypoCorrectionRecallPreflightGroupID(1),
                candidateCount: 4
            )
        )
        XCTAssertEqual(ledger.counters.nCandidatesReturned, 4)
        XCTAssertEqual(ledger.termination, .contractViolation)
        XCTAssertFalse(ledger.canPublish(for: operation))
    }

    func testContextualMultiEditRemainsDisplayOnlyInPreflightContract() {
        let assessment = TypoCorrectionAssessment.evaluate(
            title: "我们今天去公园",
            originalInput: canonicalInput,
            correctedInput: canonicalTarget,
            edits: [
                TypoCorrectionEdit(index: 1, original: "i", replacement: "o"),
                TypoCorrectionEdit(index: 14, original: "h", replacement: "g"),
            ],
            firstNormalCandidate: "无关"
        )

        XCTAssertTrue(assessment.isDisplayEligible)
        XCTAssertFalse(assessment.isPromotionEligible)
    }

    func testResolvedGroupsDeduplicateStableGroupIdentity() {
        let operation = TypoCorrectionRecallPreflightOperation(
            compositionRevision: 1,
            sessionEpoch: 1
        )
        var ledger = TypoCorrectionRecallPreflightLedger(operation: operation)

        XCTAssertTrue(ledger.beginBatch(for: operation))
        XCTAssertTrue(ledger.beginQuery(for: operation))
        XCTAssertTrue(
            ledger.finishQuery(
                for: operation,
                groupID: TypoCorrectionRecallPreflightGroupID(7),
                candidateCount: 3
            )
        )
        XCTAssertTrue(ledger.beginQuery(for: operation))
        XCTAssertFalse(
            ledger.finishQuery(
                for: operation,
                groupID: TypoCorrectionRecallPreflightGroupID(7),
                candidateCount: 2
            )
        )
        XCTAssertTrue(ledger.beginQuery(for: operation))
        XCTAssertTrue(
            ledger.finishQuery(
                for: operation,
                groupID: TypoCorrectionRecallPreflightGroupID(8),
                candidateCount: 1
            )
        )
        XCTAssertTrue(ledger.finishBatch(for: operation))

        XCTAssertEqual(ledger.counters.nQueryAttempts, 3)
        XCTAssertEqual(ledger.counters.nResolvedGroups, 2)
        XCTAssertEqual(ledger.counters.nCandidatesReturned, 6)
    }

    func testBatchLimitIsIndependentFromQueryAttemptLimit() {
        let operation = TypoCorrectionRecallPreflightOperation(
            compositionRevision: 1,
            sessionEpoch: 1
        )
        var ledger = TypoCorrectionRecallPreflightLedger(
            operation: operation,
            budget: .init(
                maximumBatchSize: 2,
                candidateLimit: 3,
                maximumResolvedGroups: 4,
                maxQueryAttempts: 8
            )
        )

        XCTAssertTrue(ledger.beginBatch(for: operation))
        for index in 0..<2 {
            XCTAssertTrue(ledger.beginQuery(for: operation))
            XCTAssertFalse(
                ledger.finishQuery(
                    for: operation,
                    groupID: TypoCorrectionRecallPreflightGroupID(UInt64(index)),
                    candidateCount: 0
                )
            )
        }
        XCTAssertFalse(ledger.beginQuery(for: operation))
        XCTAssertTrue(ledger.finishBatch(for: operation))

        XCTAssertTrue(ledger.beginBatch(for: operation))
        XCTAssertTrue(ledger.beginQuery(for: operation))
        XCTAssertFalse(
            ledger.finishQuery(
                for: operation,
                groupID: TypoCorrectionRecallPreflightGroupID(2),
                candidateCount: 0
            )
        )
        XCTAssertTrue(ledger.finishBatch(for: operation))
        XCTAssertEqual(ledger.counters.nQueryAttempts, 3)
        XCTAssertEqual(ledger.termination, .running)
    }

    func testResolvedGroupLimitIsIndependentFromQueryAttemptLimit() {
        let operation = TypoCorrectionRecallPreflightOperation(
            compositionRevision: 1,
            sessionEpoch: 1
        )
        var ledger = TypoCorrectionRecallPreflightLedger(
            operation: operation,
            budget: .init(
                maximumBatchSize: 8,
                candidateLimit: 3,
                maximumResolvedGroups: 1,
                maxQueryAttempts: 8
            )
        )

        XCTAssertTrue(ledger.beginBatch(for: operation))
        XCTAssertTrue(ledger.beginQuery(for: operation))
        XCTAssertTrue(
            ledger.finishQuery(
                for: operation,
                groupID: TypoCorrectionRecallPreflightGroupID(1),
                candidateCount: 1
            )
        )
        XCTAssertTrue(ledger.beginQuery(for: operation))
        XCTAssertFalse(
            ledger.finishQuery(
                for: operation,
                groupID: TypoCorrectionRecallPreflightGroupID(2),
                candidateCount: 1
            )
        )
        XCTAssertEqual(ledger.counters.nQueryAttempts, 2)
        XCTAssertEqual(ledger.counters.nResolvedGroups, 1)
        XCTAssertEqual(ledger.termination, .resolvedGroupLimitReached)
    }

    func testSessionEpochFenceRejectsStaleResultIndependently() {
        let oldOperation = TypoCorrectionRecallPreflightOperation(
            compositionRevision: 8,
            sessionEpoch: 4
        )
        let newOperation = TypoCorrectionRecallPreflightOperation(
            compositionRevision: 8,
            sessionEpoch: 5
        )
        var ledger = TypoCorrectionRecallPreflightLedger(operation: oldOperation)

        XCTAssertTrue(ledger.beginBatch(for: oldOperation))
        XCTAssertTrue(ledger.beginQuery(for: oldOperation))
        ledger.advanceCurrentOperation(to: newOperation)

        XCTAssertFalse(
            ledger.finishQuery(
                for: oldOperation,
                groupID: TypoCorrectionRecallPreflightGroupID(1),
                candidateCount: 2
            )
        )
        XCTAssertEqual(ledger.counters.nResolvedGroups, 0)
        XCTAssertFalse(ledger.canPublish(for: oldOperation))
        XCTAssertFalse(ledger.finishBatch(for: oldOperation))
        XCTAssertTrue(ledger.beginBatch(for: newOperation))
        XCTAssertTrue(ledger.finishBatch(for: newOperation))
        XCTAssertTrue(ledger.canPublish(for: newOperation))
    }
}
