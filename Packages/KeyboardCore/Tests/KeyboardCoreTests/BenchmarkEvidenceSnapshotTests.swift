#if DEBUG
import XCTest

@testable import KeyboardCore

@MainActor
final class BenchmarkEvidenceSnapshotTests: XCTestCase {
    func testSnapshotConsumesCorrelatedExecutionFactsAndKeepsSourcesSeparate() throws {
        let captured = captureControllerPath(
            invocationID: "invocation-stable",
            input: "nihap",
            dictionary: [
                "nihap": ["你好安排", "拟好安排"],
                "nihao": ["你好"],
            ]
        )
        let snapshot = BenchmarkEvidenceSnapshotBuilder.capture(
            fixture: fixture(
                caseID: "TC-CASE-STB-016",
                normalInput: "nihap",
                correctedInput: "nihao",
                target: "你好"
            ),
            environment: unavailableEnvironment(runID: "run-stable"),
            trace: captured.capture
        )

        XCTAssertEqual(snapshot.registryIdentity.registryVersion, "1.0.0")
        XCTAssertEqual(snapshot.registryIdentity.registryCommit, "49b000bcbb3a90d04f00dd803981a24a25b70e28")
        XCTAssertEqual(snapshot.registryIdentity.canonicalCaseID, "TC-CASE-STB-016")
        XCTAssertEqual(snapshot.fixtureMetadata.inputProvenance, .syntheticFixture)
        XCTAssertEqual(snapshot.fixtureMetadata.normalInput, "nihap")
        XCTAssertEqual(snapshot.environmentMetadata.buildCommit.source, .unavailable)
        XCTAssertEqual(snapshot.environmentMetadata.schemaIdentifier.source, .unavailable)
        XCTAssertEqual(snapshot.environmentMetadata.invocationID, "invocation-stable")
        XCTAssertEqual(snapshot.executionFacts.finalPosition, .observed(0))
        XCTAssertEqual(snapshot.executionFacts.representedSource, .observed(.typoCorrection))
        assertSuppression(snapshot, equals: .notSuppressed, candidateTitle: "你好")
        assertLearning(snapshot, equals: .top(finalPosition: 0), candidateTitle: "你好")
        assertEnvironmentBlocked(snapshot)

        let encoded = try JSONEncoder().encode(snapshot)
        XCTAssertEqual(
            try JSONDecoder().decode(BenchmarkEvidenceSnapshot.self, from: encoded),
            snapshot
        )
    }

    func testSnapshotReadsLearningDecisionFromFinalRankerPosition() {
        let correction = insertionCorrection(title: "你好")
        let learningSnapshot = TypoCorrectionLearningSnapshot(records: [
            .init(
                key: try! XCTUnwrap(TypoCorrectionLearningKey(correction: correction)),
                selectionCount: 3,
                lastSelectedAt: Date(timeIntervalSince1970: 1)
            )
        ])
        let controller = KeyboardController()
        controller.textClient = FakeTextInputClient()
        controller.rimeEngine = FakeRimeEngine(dictionary: [
            "niho": ["你或"],
            "nihao": ["你好"],
        ])
        controller.typoCorrectionExperimentalEdits = [.insertion]
        controller.typoCorrectionLearningSnapshot = learningSnapshot

        type("nih", into: controller)
        let traced = TypoCorrectionDecisionTrace.withSyntheticInvocation(id: "invocation-learning") {
            type("o", into: controller)
            return mergeCurrentCandidates(from: controller)
        }
        let snapshot = BenchmarkEvidenceSnapshotBuilder.capture(
            fixture: fixture(
                caseID: "TC-CASE-LRN-008",
                normalInput: "niho",
                correctedInput: "nihao",
                target: "你好",
                requestedFlags: .init(
                    insertionEnabled: true,
                    transpositionEnabled: false,
                    typoPartialCommitEnabled: false
                )
            ),
            environment: unavailableEnvironment(runID: "run-learning"),
            trace: traced.capture
        )

        assertLearning(snapshot, equals: .top(finalPosition: 0), candidateTitle: "你好")
        XCTAssertEqual(snapshot.executionFacts.effectiveFlags, .observed(.init(
            insertionEnabled: true,
            transpositionEnabled: false,
            typoPartialCommitEnabled: false
        )))
        XCTAssertEqual(snapshot.executionFacts.finalPosition, .observed(0))
        assertEnvironmentBlocked(snapshot)
        let mergeSequence = traced.capture.events.first {
            if case .merge = $0.kind { return true }
            return false
        }?.sequence
        let learningSequence = traced.capture.events.first {
            if case .learning = $0.kind { return true }
            return false
        }?.sequence
        XCTAssertNotNil(mergeSequence)
        XCTAssertNotNil(learningSequence)
        XCTAssertGreaterThan(learningSequence!, mergeSequence!)
    }

    func testSuppressionTraceReportsRankingNotEvaluated() {
        let controller = KeyboardController()
        controller.textClient = FakeTextInputClient()
        controller.rimeEngine = FakeRimeEngine(dictionary: [
            "nihoa": ["你好", "你花"],
            "nihao": ["你好", "拟好", "你号"],
        ])
        controller.typoCorrectionExperimentalEdits = [.transposition]

        type("niho", into: controller)
        let traced = TypoCorrectionDecisionTrace.withSyntheticInvocation(id: "invocation-suppressed") {
            type("a", into: controller)
            return mergeCurrentCandidates(from: controller)
        }
        let snapshot = BenchmarkEvidenceSnapshotBuilder.capture(
            fixture: fixture(
                caseID: "TC-CASE-EXP-005",
                normalInput: "nihoa",
                correctedInput: "nihao",
                target: "你好",
                requestedFlags: .init(
                    insertionEnabled: false,
                    transpositionEnabled: true,
                    typoPartialCommitEnabled: false
                )
            ),
            environment: unavailableEnvironment(runID: "run-suppressed"),
            trace: traced.capture
        )

        assertSuppression(
            snapshot,
            equals: .suppressedNormalTopMatchesCorrectedBest,
            candidateTitle: "你好"
        )
        assertLearning(snapshot, equals: .notEvaluatedDueSuppression, candidateTitle: "你好")
        XCTAssertEqual(snapshot.executionFacts.representedSource, .observed(.normalRime))
        assertEnvironmentBlocked(snapshot)
    }

    func testMergeTraceProvidesDedupeProvenanceWithoutChangingCandidates() {
        let captured = captureControllerPath(
            invocationID: "invocation-dedupe",
            input: "nihap",
            dictionary: [
                "nihap": ["你好安排", "你好"],
                "nihao": ["你好"],
            ]
        )
        let snapshot = BenchmarkEvidenceSnapshotBuilder.capture(
            fixture: fixture(
                caseID: "TC-CASE-INT-004",
                normalInput: "nihap",
                correctedInput: "nihao",
                target: "你好"
            ),
            environment: unavailableEnvironment(runID: "run-dedupe"),
            trace: captured.capture
        )

        guard case let .observed(decisions) = snapshot.executionFacts.dedupeDecisions,
            let decision = decisions.first(where: { $0.title == "你好" })
        else {
            return XCTFail("Expected observed dedupe provenance")
        }
        XCTAssertEqual(decision.originSet, [.normalRime, .typoCorrection])
        XCTAssertEqual(decision.representedSource, .typoCorrection)
        XCTAssertEqual(decision.removedDuplicateCount, 1)
        guard case let .observed(finalCandidates) = snapshot.executionFacts.finalCandidates else {
            return XCTFail("Expected final candidates from the merge event")
        }
        XCTAssertEqual(finalCandidates.map(\.title), captured.result.map(\.title))
        XCTAssertEqual(finalCandidates.first, .init(
            title: "你好",
            subject: finalCandidates.first?.subject,
            representedSource: .typoCorrection,
            originSet: [.normalRime, .typoCorrection]
        ))
    }

    func testMissingExecutionEventsFailClosedWithoutFixtureSubstitution() {
        let emptyTrace = TypoCorrectionDecisionTrace.withSyntheticInvocation(id: "invocation-empty") {
            "no product decision executed"
        }.capture
        let snapshot = BenchmarkEvidenceSnapshotBuilder.capture(
            fixture: fixture(
                caseID: "TC-CASE-LRN-008",
                normalInput: "niho",
                correctedInput: "nihao",
                target: "你好",
                requestedFlags: .init(
                    insertionEnabled: true,
                    transpositionEnabled: false,
                    typoPartialCommitEnabled: false
                )
            ),
            environment: unavailableEnvironment(runID: "run-empty"),
            trace: emptyTrace
        )

        guard case let .blocked(reasons) = snapshot.evidenceStatus else {
            return XCTFail("Missing events must block evidence")
        }
        XCTAssertTrue(reasons.contains("missing effective-flags execution event"))
        XCTAssertTrue(reasons.contains("missing suppression execution event"))
        XCTAssertTrue(reasons.contains("missing learning execution event"))
        XCTAssertTrue(reasons.contains("missing merge execution event"))
        XCTAssertEqual(snapshot.executionFacts.learningDecision, .unavailable(
            reason: "learning execution fact unavailable"
        ))
        XCTAssertEqual(snapshot.fixtureMetadata.requestedFlags.insertionEnabled, true)
    }

    func testRequestedFlagsCannotOverrideObservedEffectiveFlags() {
        let captured = captureControllerPath(
            invocationID: "invocation-flags",
            input: "nihap",
            dictionary: [
                "nihap": ["你好安排"],
                "nihao": ["你好"],
            ]
        )
        let requestedFlags = BenchmarkEvidenceSnapshot.Flags(
            insertionEnabled: true,
            transpositionEnabled: true,
            typoPartialCommitEnabled: true
        )
        let snapshot = BenchmarkEvidenceSnapshotBuilder.capture(
            fixture: fixture(
                caseID: "TC-CASE-STB-016",
                normalInput: "nihap",
                correctedInput: "nihao",
                target: "你好",
                requestedFlags: requestedFlags
            ),
            environment: unavailableEnvironment(runID: "run-flags"),
            trace: captured.capture
        )

        XCTAssertEqual(snapshot.fixtureMetadata.requestedFlags, requestedFlags)
        XCTAssertEqual(snapshot.executionFacts.effectiveFlags, .observed(.init(
            insertionEnabled: false,
            transpositionEnabled: false,
            typoPartialCommitEnabled: false
        )))
        assertEnvironmentBlocked(snapshot)
    }

    func testFixtureEnvironmentDeclarationsCannotAcquireTrustedSources() {
        let captured = captureControllerPath(
            invocationID: "invocation-environment",
            input: "nihap",
            dictionary: [
                "nihap": ["你好安排"],
                "nihao": ["你好"],
            ]
        )
        let environment = BenchmarkEnvironmentBindingFactory.rejectingFixtureDeclarations(
            runID: "run-environment",
            declarations: [
                "buildCommit": "fixture-pretends-build-generated",
                "schema": "fixture-pretends-verified",
                "session": "fixture-pretends-runtime-observed",
            ]
        )

        let snapshot = BenchmarkEvidenceSnapshotBuilder.capture(
            fixture: fixture(
                caseID: "TC-CASE-STB-016",
                normalInput: "nihap",
                correctedInput: "nihao",
                target: "你好"
            ),
            environment: environment,
            trace: captured.capture
        )

        assertEnvironmentBlocked(snapshot)
        XCTAssertEqual(snapshot.environmentMetadata.buildCommit.source, .unavailable)
        XCTAssertEqual(snapshot.environmentMetadata.schemaIdentifier.source, .unavailable)
        XCTAssertEqual(snapshot.environmentMetadata.sessionState.source, .unavailable)
        XCTAssertNil(snapshot.environmentMetadata.buildCommit.value)
    }

    func testInvalidMetadataSourceCannotDecodeAsTrustedSource() {
        let data = Data(#""fixtureDeclared""#.utf8)
        XCTAssertThrowsError(
            try JSONDecoder().decode(BenchmarkEvidenceSnapshot.MetadataSource.self, from: data)
        )
    }

    func testCollectorIsBoundedAndSequencesEventsDeterministically() {
        let trace = TypoCorrectionDecisionTrace.withSyntheticInvocation(id: "invocation-bounded") {
            for _ in 0..<(TypoCorrectionDecisionTrace.maximumEventsPerInvocation + 3) {
                TypoCorrectionDecisionTrace.record(
                    .suppression(
                        .init(
                            subject: TypoCorrectionDecisionTrace.invocationSubject,
                            decision: .notApplicable
                        )
                    )
                )
            }
        }.capture

        XCTAssertEqual(trace.events.count, TypoCorrectionDecisionTrace.maximumEventsPerInvocation)
        XCTAssertEqual(trace.droppedEventCount, 3)
        XCTAssertEqual(trace.events.map(\.sequence), Array(0..<TypoCorrectionDecisionTrace.maximumEventsPerInvocation))
        XCTAssertTrue(trace.events.allSatisfy { $0.invocationID == "invocation-bounded" })
    }

    func testOversizedMergeTraceFailsClosedWithoutChangingMergeResult() {
        let normalItems = (0...TypoCorrectionDecisionTrace.maximumCandidatesPerMergeEvent).map {
            CandidateItem(title: "候选\($0)", kind: .candidate)
        }
        let traced = TypoCorrectionDecisionTrace.withSyntheticInvocation(id: "invocation-large-merge") {
            TypoCorrectionCandidateRanker.mergedCandidates(
                normalItems: normalItems,
                correctionItems: []
            )
        }
        let snapshot = BenchmarkEvidenceSnapshotBuilder.capture(
            fixture: fixture(
                caseID: "TC-CASE-STB-015",
                normalInput: "synthetic",
                correctedInput: nil,
                target: nil
            ),
            environment: unavailableEnvironment(runID: "run-large-merge"),
            trace: traced.capture
        )

        XCTAssertEqual(traced.result, normalItems)
        guard case let .blocked(reasons) = snapshot.evidenceStatus else {
            return XCTFail("An incomplete merge trace must block evidence")
        }
        XCTAssertTrue(reasons.contains("merge trace payload exceeded bounded capacity"))
    }

    func testMultipleEligibleCorrectionsRecordOnlyActualNearFrontSubject() {
        let firstInsertion = insertionCorrection(title: "你好")
        let secondInsertion = insertionCorrection(title: "拟好")
        let learned = TypoCorrectionLearningSnapshot(records: [
            .init(
                key: try! XCTUnwrap(TypoCorrectionLearningKey(correction: firstInsertion)),
                selectionCount: 1,
                lastSelectedAt: Date(timeIntervalSince1970: 1)
            ),
            .init(
                key: try! XCTUnwrap(TypoCorrectionLearningKey(correction: secondInsertion)),
                selectionCount: 2,
                lastSelectedAt: Date(timeIntervalSince1970: 2)
            )
        ])
        let normal = [CandidateItem(title: "你或", kind: .candidate)]
        let corrections = [
            CandidateItem(title: "你好", kind: .correctionCandidate, correction: firstInsertion),
            CandidateItem(title: "拟好", kind: .correctionCandidate, correction: secondInsertion),
        ]

        let traced = TypoCorrectionDecisionTrace.withSyntheticInvocation(id: "invocation-learning-final") {
            TypoCorrectionCandidateRanker.mergedCandidates(
                normalItems: normal,
                correctionItems: corrections,
                learningSnapshot: learned
            )
        }
        let learningEvents = traced.capture.events.compactMap { event ->
            TypoCorrectionDecisionTrace.DecisionEvent<TypoCorrectionDecisionTrace.LearningDecision>? in
            guard case let .learning(decision) = event.kind else { return nil }
            return decision
        }

        XCTAssertEqual(learningEvents.filter {
            if case .nearFront = $0.decision { return true }
            return false
        }.count, 1)
        XCTAssertTrue(learningEvents.contains {
            $0.subject.candidateTitle == "拟好" && $0.decision == .nearFront(finalPosition: 1)
        })
        XCTAssertTrue(learningEvents.contains {
            $0.subject.candidateTitle == "你好" && $0.decision == .present(finalPosition: 2)
        })
        XCTAssertEqual(traced.result.first?.title, "你或")
        XCTAssertEqual(traced.result.map(\.title), ["你或", "拟好", "你好"])
    }

    func testLearningDecisionMatchesFinalPositionInsteadOfPrefixPredicate() {
        let correction = insertionCorrection(title: "你好")
        let learned = TypoCorrectionLearningSnapshot(records: [
            .init(
                key: try! XCTUnwrap(TypoCorrectionLearningKey(correction: correction)),
                selectionCount: 3,
                lastSelectedAt: Date(timeIntervalSince1970: 1)
            )
        ])
        let traced = TypoCorrectionDecisionTrace.withSyntheticInvocation(id: "invocation-prefix") {
            TypoCorrectionCandidateRanker.mergedCandidates(
                normalItems: [CandidateItem(title: "你好呀", kind: .candidate)],
                correctionItems: [
                    CandidateItem(title: "你好", kind: .correctionCandidate, correction: correction)
                ],
                learningSnapshot: learned
            )
        }
        let learningEvents = traced.capture.events.compactMap { event ->
            TypoCorrectionDecisionTrace.DecisionEvent<TypoCorrectionDecisionTrace.LearningDecision>? in
            guard case let .learning(decision) = event.kind else { return nil }
            return decision
        }

        XCTAssertEqual(traced.result.first?.title, "你好呀")
        XCTAssertEqual(learningEvents.count, 1)
        XCTAssertEqual(learningEvents.first?.decision, .nearFront(finalPosition: 1))
        XCTAssertEqual(traced.result.firstIndex(of: CandidateItem(
            title: "你好",
            kind: .correctionCandidate,
            correction: correction
        )), 1)
    }

    func testMultipleSuppressionEventsResolveByUniqueDecisionSubject() {
        let provider = DictionaryCandidateProvider(dictionary: [
            "nihao": ["你好"],
            "nihal": ["你哈了"],
        ])
        let controller = KeyboardController(candidateProvider: provider)
        controller.textClient = FakeTextInputClient()
        controller.rimeEngine = FakeRimeEngine(dictionary: ["nihap": ["你好"]])
        type("niha", into: controller)

        let traced = TypoCorrectionDecisionTrace.withSyntheticInvocation(id: "invocation-multiple") {
            type("p", into: controller)
            return mergeCurrentCandidates(from: controller)
        }
        let snapshot = BenchmarkEvidenceSnapshotBuilder.capture(
            fixture: fixture(
                caseID: "TC-CASE-STB-003",
                normalInput: "nihap",
                correctedInput: "nihao",
                target: "你好"
            ),
            environment: unavailableEnvironment(runID: "run-multiple"),
            trace: traced.capture
        )

        let suppressionEvents = traced.capture.events.filter {
            if case .suppression = $0.kind { return true }
            return false
        }
        XCTAssertEqual(suppressionEvents.count, 2)
        assertSuppression(
            snapshot,
            equals: .suppressedNormalTopMatchesCorrectedBest,
            candidateTitle: "你好"
        )
        XCTAssertFalse(blockReasons(snapshot).contains("ambiguous decision subject correlation"))
    }

    func testMissingInvocationCorrelationFailsClosed() {
        let subject = TypoCorrectionDecisionTrace.invocationSubject
        let malformed = TypoCorrectionDecisionTrace.Capture(
            invocationID: "expected-invocation",
            events: [
                .init(
                    invocationID: "wrong-invocation",
                    sequence: 0,
                    kind: .suppression(.init(subject: subject, decision: .notApplicable))
                )
            ],
            droppedEventCount: 0
        )
        let snapshot = BenchmarkEvidenceSnapshotBuilder.capture(
            fixture: fixture(
                caseID: "TC-CASE-STB-001",
                normalInput: "nihao",
                correctedInput: nil,
                target: nil
            ),
            environment: unavailableEnvironment(runID: "run-correlation"),
            trace: malformed
        )

        XCTAssertTrue(blockReasons(snapshot).contains("trace correlation mismatch"))
    }

    func testTraceObservationDoesNotChangeMergeOutput() {
        let correction = insertionCorrection(title: "你好")
        let normal = [CandidateItem(title: "你或", kind: .candidate)]
        let corrections = [
            CandidateItem(title: "你好", kind: .correctionCandidate, correction: correction)
        ]
        let withoutTrace = TypoCorrectionCandidateRanker.mergedCandidates(
            normalItems: normal,
            correctionItems: corrections
        )
        let withTrace = TypoCorrectionDecisionTrace.withSyntheticInvocation(id: "invocation-purity") {
            TypoCorrectionCandidateRanker.mergedCandidates(
                normalItems: normal,
                correctionItems: corrections
            )
        }.result

        XCTAssertEqual(withTrace, withoutTrace)
    }

    private func captureControllerPath(
        invocationID: String,
        input: String,
        dictionary: [String: [String]]
    ) -> (result: [CandidateItem], capture: TypoCorrectionDecisionTrace.Capture) {
        let controller = KeyboardController()
        controller.textClient = FakeTextInputClient()
        controller.rimeEngine = FakeRimeEngine(dictionary: dictionary)
        let prefix = String(input.dropLast())
        let finalCharacter = input.last.map(String.init) ?? ""
        type(prefix, into: controller)
        return TypoCorrectionDecisionTrace.withSyntheticInvocation(id: invocationID) {
            type(finalCharacter, into: controller)
            return mergeCurrentCandidates(from: controller)
        }
    }

    private func type(_ input: String, into controller: KeyboardController) {
        for character in input {
            _ = controller.handle(.insertKey(String(character)))
        }
    }

    private func mergeCurrentCandidates(from controller: KeyboardController) -> [CandidateItem] {
        let normalItems = (controller.state.lastRimeOutput?.candidates ?? []).map {
            CandidateItem(title: $0.text, kind: .candidate)
        }
        let correctionItems = (controller.state.typoCorrection?.suggestions ?? []).flatMap { suggestion in
            suggestion.candidates.map { candidate in
                CandidateItem(
                    title: candidate.text,
                    kind: .correctionCandidate,
                    correction: TypoCorrectionCommit(
                        committedText: candidate.text,
                        originalInput: suggestion.originalInput,
                        correctedInput: suggestion.correctedInput,
                        edits: suggestion.edits
                    )
                )
            }
        }
        return TypoCorrectionCandidateRanker.mergedCandidates(
            normalItems: normalItems,
            correctionItems: correctionItems,
            learningSnapshot: controller.typoCorrectionLearningSnapshot
        )
    }

    private func fixture(
        caseID: String,
        normalInput: String,
        correctedInput: String?,
        target: String?,
        requestedFlags: BenchmarkEvidenceSnapshot.Flags = .init(
            insertionEnabled: false,
            transpositionEnabled: false,
            typoPartialCommitEnabled: false
        )
    ) -> BenchmarkEvidenceFixture {
        .init(
            canonicalCaseID: caseID,
            normalInput: normalInput,
            correctedInput: correctedInput,
            correctedProviderCandidates: target.map { [$0] } ?? [],
            requestedFlags: requestedFlags,
            expectedTargetCandidate: target
        )
    }

    private func unavailableEnvironment(runID: String) -> BenchmarkEnvironmentBinding {
        BenchmarkEnvironmentBindingFactory.unavailable(runID: runID)
    }

    private func assertSuppression(
        _ snapshot: BenchmarkEvidenceSnapshot,
        equals expected: BenchmarkEvidenceSnapshot.SuppressionDecision,
        candidateTitle: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        guard case let .observed(fact) = snapshot.executionFacts.suppressionDecision else {
            return XCTFail("Expected observed suppression decision", file: file, line: line)
        }
        XCTAssertEqual(fact.decision, expected, file: file, line: line)
        XCTAssertEqual(fact.subject.candidateTitle, candidateTitle, file: file, line: line)
        XCTAssertFalse(fact.subject.correlationID.isEmpty, file: file, line: line)
    }

    private func assertLearning(
        _ snapshot: BenchmarkEvidenceSnapshot,
        equals expected: BenchmarkEvidenceSnapshot.LearningDecision,
        candidateTitle: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        guard case let .observed(fact) = snapshot.executionFacts.learningDecision else {
            return XCTFail("Expected observed learning decision", file: file, line: line)
        }
        XCTAssertEqual(fact.decision, expected, file: file, line: line)
        XCTAssertEqual(fact.subject.candidateTitle, candidateTitle, file: file, line: line)
        XCTAssertFalse(fact.subject.correlationID.isEmpty, file: file, line: line)
    }

    private func assertEnvironmentBlocked(
        _ snapshot: BenchmarkEvidenceSnapshot,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertTrue(
            blockReasons(snapshot).contains("required environment metadata unavailable"),
            file: file,
            line: line
        )
    }

    private func blockReasons(_ snapshot: BenchmarkEvidenceSnapshot) -> [String] {
        guard case let .blocked(reasons) = snapshot.evidenceStatus else { return [] }
        return reasons
    }

    private func insertionCorrection(title: String) -> TypoCorrectionCommit {
        TypoCorrectionCommit(
            committedText: title,
            originalInput: "niho",
            correctedInput: "nihao",
            edits: [
                TypoCorrectionEdit(
                    index: 3,
                    original: "a",
                    replacement: "a",
                    kind: .insertion,
                    inserted: "a"
                )
            ]
        )
    }
}

private final class DictionaryCandidateProvider: CandidateProvider {
    private let dictionary: [String: [String]]

    init(dictionary: [String: [String]]) {
        self.dictionary = dictionary
    }

    func candidates(for composition: String) -> [String] {
        dictionary[composition] ?? []
    }
}
#endif
