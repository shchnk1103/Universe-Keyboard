import XCTest

@testable import KeyboardCore

final class BenchmarkEvidenceSnapshotTests: XCTestCase {
    func testSnapshotContainsRegistryIdentityMetadataAndSyntheticInputs() throws {
        let snapshot = BenchmarkEvidenceSnapshotBuilder.capture(baseObservation())

        XCTAssertEqual(snapshot.identity.registryVersion, "1.0.0")
        XCTAssertEqual(snapshot.identity.registryCommit, "49b000bcbb3a90d04f00dd803981a24a25b70e28")
        XCTAssertEqual(snapshot.identity.canonicalCaseID, "TC-CASE-STB-016")
        XCTAssertEqual(snapshot.identity.build.commit, "fixture-build-commit")
        XCTAssertEqual(snapshot.identity.schema.identifier, "fixture-schema")
        XCTAssertEqual(snapshot.inputs.provenance, .syntheticFixture)
        XCTAssertEqual(snapshot.inputs.normalInput, "nihap")
        XCTAssertEqual(snapshot.inputs.correctedInput, "nihao")

        let encoded = try JSONEncoder().encode(snapshot)
        let decoded = try JSONDecoder().decode(BenchmarkEvidenceSnapshot.self, from: encoded)
        XCTAssertEqual(decoded, snapshot)
    }

    func testSnapshotReportsFinalPositionFromExistingProductMerge() {
        let observation = baseObservation()
        let directMerge = TypoCorrectionCandidateRanker.mergedCandidates(
            normalItems: observation.normalItems,
            correctionItems: observation.resolvedCorrectionItems,
            learningSnapshot: observation.learningSnapshot
        )

        let snapshot = BenchmarkEvidenceSnapshotBuilder.capture(observation)

        XCTAssertEqual(snapshot.candidates.finalCandidates.map(\.title), directMerge.map(\.title))
        XCTAssertEqual(snapshot.candidates.finalPosition, 0)
        XCTAssertEqual(snapshot.candidates.representedSource, .typoCorrection)
    }

    func testSnapshotMakesSuppressionDecisionVisible() {
        var observation = baseObservation()
        observation = .init(
            canonicalCaseID: "TC-CASE-EXP-005",
            build: observation.build,
            schema: observation.schema,
            flags: .init(
                insertionEnabled: false,
                transpositionEnabled: true,
                typoPartialCommitEnabled: false
            ),
            configuration: observation.configuration,
            input: .init(normalInput: "nihoa", correctedInput: "nihao"),
            normalItems: [CandidateItem(title: "你好", kind: .candidate)],
            resolvedCorrectionItems: [],
            correctedCandidates: ["你好", "拟好", "你号"],
            learningSnapshot: .empty,
            learningDecision: .blockedBySatisfaction(selectionCount: 0),
            suppressionDecision: .suppressedNormalTopMatchesCorrectedBest,
            targetCandidate: "你好"
        )

        let snapshot = BenchmarkEvidenceSnapshotBuilder.capture(observation)

        XCTAssertEqual(snapshot.candidates.suppressionDecision, .suppressedNormalTopMatchesCorrectedBest)
        XCTAssertEqual(snapshot.candidates.correctedCandidates, ["你好", "拟好", "你号"])
        XCTAssertEqual(snapshot.candidates.finalCandidates.map(\.title), ["你好"])
        XCTAssertEqual(snapshot.candidates.representedSource, .normalRime)
    }

    func testSnapshotMakesLearningTopPromotionVisibleWithoutChangingMerge() {
        let correction = insertionCorrection(title: "你好")
        let learningSnapshot = TypoCorrectionLearningSnapshot(records: [
            .init(
                key: try! XCTUnwrap(TypoCorrectionLearningKey(correction: correction)),
                selectionCount: 3,
                lastSelectedAt: Date(timeIntervalSince1970: 1)
            )
        ])
        var observation = baseObservation()
        observation = .init(
            canonicalCaseID: "TC-CASE-LRN-008",
            build: observation.build,
            schema: observation.schema,
            flags: .init(
                insertionEnabled: true,
                transpositionEnabled: false,
                typoPartialCommitEnabled: false
            ),
            configuration: .init(
                learningState: "three-explicit-selections",
                deploymentState: "fixture-deployed",
                sessionState: "fixture-active"
            ),
            input: .init(normalInput: "niho", correctedInput: "nihao"),
            normalItems: [CandidateItem(title: "你或", kind: .candidate)],
            resolvedCorrectionItems: [
                CandidateItem(title: "你好", kind: .correctionCandidate, correction: correction)
            ],
            correctedCandidates: ["你好"],
            learningSnapshot: learningSnapshot,
            learningDecision: .topPromotion(selectionCount: 3),
            suppressionDecision: .notSuppressed,
            targetCandidate: "你好"
        )

        let directMerge = TypoCorrectionCandidateRanker.mergedCandidates(
            normalItems: observation.normalItems,
            correctionItems: observation.resolvedCorrectionItems,
            learningSnapshot: learningSnapshot
        )
        let snapshot = BenchmarkEvidenceSnapshotBuilder.capture(observation)

        XCTAssertEqual(snapshot.candidates.learningDecision, .topPromotion(selectionCount: 3))
        XCTAssertEqual(snapshot.candidates.finalCandidates.map(\.title), directMerge.map(\.title))
        XCTAssertEqual(snapshot.candidates.finalPosition, 0)
    }

    func testSnapshotPreservesDedupeProvenance() {
        var observation = baseObservation()
        let correction = trailingCorrection(title: "你好")
        observation = .init(
            canonicalCaseID: "TC-CASE-INT-004",
            build: observation.build,
            schema: observation.schema,
            flags: observation.flags,
            configuration: observation.configuration,
            input: observation.input,
            normalItems: [
                CandidateItem(title: "你好安排", kind: .candidate),
                CandidateItem(title: "你好", kind: .candidate),
            ],
            resolvedCorrectionItems: [
                CandidateItem(title: "你好", kind: .correctionCandidate, correction: correction)
            ],
            correctedCandidates: ["你好"],
            learningSnapshot: .empty,
            learningDecision: .notApplicable,
            suppressionDecision: .notSuppressed,
            targetCandidate: "你好"
        )

        let snapshot = BenchmarkEvidenceSnapshotBuilder.capture(observation)
        let decision = snapshot.candidates.dedupeDecisions.first { $0.title == "你好" }

        XCTAssertEqual(decision?.originSet, [.normalRime, .typoCorrection])
        XCTAssertEqual(decision?.representedSource, .typoCorrection)
        XCTAssertEqual(decision?.removedDuplicateCount, 1)
        XCTAssertEqual(snapshot.candidates.finalCandidates.filter { $0.title == "你好" }.count, 1)
    }

    func testSnapshotCapabilityIsTestOnlyAndDoesNotMutateCandidateInputs() {
        let observation = baseObservation()
        let normalBefore = observation.normalItems
        let correctionBefore = observation.resolvedCorrectionItems

        _ = BenchmarkEvidenceSnapshotBuilder.capture(observation)

        XCTAssertEqual(observation.normalItems, normalBefore)
        XCTAssertEqual(observation.resolvedCorrectionItems, correctionBefore)
        // Both the capability and this assertion compile only in KeyboardCoreTests.
        XCTAssertEqual(BenchmarkEvidenceSnapshot.registryVersion, "1.0.0")
    }

    private func baseObservation() -> BenchmarkEvidenceSnapshotBuilder.Observation {
        let correction = trailingCorrection(title: "你好")
        return .init(
            canonicalCaseID: "TC-CASE-STB-016",
            build: .init(
                commit: "fixture-build-commit",
                configuration: "test",
                target: "KeyboardCoreTests"
            ),
            schema: .init(identifier: "fixture-schema", artifactVersion: "fixture-artifact"),
            flags: .init(
                insertionEnabled: false,
                transpositionEnabled: false,
                typoPartialCommitEnabled: false
            ),
            configuration: .init(
                learningState: "no-record",
                deploymentState: "fixture-deployed",
                sessionState: "fixture-active"
            ),
            input: .init(normalInput: "nihap", correctedInput: "nihao"),
            normalItems: [
                CandidateItem(title: "你好安排", kind: .candidate),
                CandidateItem(title: "拟好安排", kind: .candidate),
            ],
            resolvedCorrectionItems: [
                CandidateItem(title: "你好", kind: .correctionCandidate, correction: correction)
            ],
            correctedCandidates: ["你好"],
            learningSnapshot: .empty,
            learningDecision: .notApplicable,
            suppressionDecision: .notSuppressed,
            targetCandidate: "你好"
        )
    }

    private func trailingCorrection(title: String) -> TypoCorrectionCommit {
        TypoCorrectionCommit(
            committedText: title,
            originalInput: "nihap",
            correctedInput: "nihao",
            edits: [TypoCorrectionEdit(index: 4, original: "p", replacement: "o")]
        )
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
