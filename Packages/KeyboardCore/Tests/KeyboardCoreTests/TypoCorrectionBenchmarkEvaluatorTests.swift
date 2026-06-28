import XCTest

@testable import KeyboardCore

final class TypoCorrectionBenchmarkEvaluatorTests: XCTestCase {
    func testDefaultBenchmarkSummaryPassesQualityGates() {
        let summary = TypoCorrectionBenchmarkEvaluator().evaluate()

        XCTAssertEqual(summary.passedCount, summary.totalCount)
        XCTAssertEqual(summary.falsePositiveCount, 0)
        XCTAssertEqual(summary.dangerousCorrectionCount, 0)
        XCTAssertTrue(summary.isReadyForDeviceValidation)
    }

    func testSupportedCaseReportsCorrectionAssessmentAndPromotionEligibility() {
        let evaluator = TypoCorrectionBenchmarkEvaluator()

        let trailing = evaluator.evaluate(.init(
            input: "nihap",
            category: .supported,
            expectedCorrectedInput: "nihao",
            expectedCandidate: "你好",
            expectedOutcome: .corrected,
            shouldPromote: true,
            note: "final substitution"
        ))
        let middle = evaluator.evaluate(.init(
            input: "zhonghuo",
            category: .supported,
            expectedCorrectedInput: "zhongguo",
            expectedCandidate: "中国",
            expectedOutcome: .corrected,
            note: "middle substitution"
        ))

        XCTAssertTrue(trailing.passed)
        XCTAssertEqual(trailing.assessment?.reasonSummary, .finalAdjacentSubstitution)
        XCTAssertTrue(trailing.didPromote)
        XCTAssertTrue(middle.passed)
        XCTAssertEqual(middle.assessment?.reasonSummary, .middleSafeSubstitution)
        XCTAssertFalse(middle.didPromote)
    }

    func testUnsupportedAndDangerousCasesRemainUncorrectedByDefault() {
        let evaluator = TypoCorrectionBenchmarkEvaluator()

        for input in ["niho", "nihoa", "nihso", "haop", "xianp"] {
            let result = evaluator.evaluate(.init(
                input: input,
                category: input == "haop" || input == "xianp" ? .dangerous : .unsupported,
                expectedOutcome: .notCorrected,
                note: "default-off boundary"
            ))

            XCTAssertTrue(result.passed, "\(input) should remain uncorrected by default")
            XCTAssertNil(result.actualCandidate)
        }
    }

    func testNormalInputsPreserveProviderCandidatesAndAvoidFalsePositive() {
        let evaluator = TypoCorrectionBenchmarkEvaluator()

        for input in ["nihao", "women", "jintian", "xiexie", "shijian", "zhongwen", "ceshi"] {
            let result = evaluator.evaluate(.init(
                input: input,
                category: .normalInput,
                expectedOutcome: .notCorrected,
                note: "normal input"
            ))

            XCTAssertTrue(result.passed, "\(input) should not become a correction")
            XCTAssertEqual(result.actualOutcome, .notCorrected)
        }
    }

    func testExperimentalInsertionIsDefaultOffAndFlagOnForNiho() {
        let flagOff = TypoCorrectionEngine().suggestions(for: "niho")
        let flagOn = TypoCorrectionEngine(experimentalEdits: [.insertion]).suggestions(for: "niho")

        XCTAssertFalse(flagOff.contains { $0.correctedInput == "nihao" })
        XCTAssertTrue(flagOn.contains { suggestion in
            suggestion.correctedInput == "nihao"
                && suggestion.edits == [
                    TypoCorrectionEdit(
                        index: 3,
                        original: "a",
                        replacement: "a",
                        kind: .insertion,
                        inserted: "a"
                    )
                ]
        })
    }

    func testExperimentalInsertionEvaluatorCanMeasureFlagOnCase() {
        let evaluator = TypoCorrectionBenchmarkEvaluator(
            engine: TypoCorrectionEngine(experimentalEdits: [.insertion])
        )

        let result = evaluator.evaluate(.init(
            input: "niho",
            category: .supported,
            expectedCorrectedInput: "nihao",
            expectedCandidate: "你好",
            expectedOutcome: .corrected,
            note: "experimental insertion"
        ))

        XCTAssertTrue(result.passed)
        XCTAssertEqual(result.assessment?.reasonSummary, .conservativeInsertion)
        XCTAssertFalse(result.didPromote)
    }

    func testExperimentalTranspositionIsDefaultOffAndFlagOnForNihoa() {
        let flagOff = TypoCorrectionEngine().suggestions(for: "nihoa")
        let flagOn = TypoCorrectionEngine(experimentalEdits: [.transposition]).suggestions(for: "nihoa")

        XCTAssertFalse(flagOff.contains { $0.correctedInput == "nihao" })
        XCTAssertTrue(flagOn.contains { suggestion in
            suggestion.correctedInput == "nihao"
                && suggestion.edits == [
                    TypoCorrectionEdit(
                        index: 3,
                        original: "o",
                        replacement: "a",
                        kind: .transposition,
                        secondIndex: 4
                    )
                ]
        })
    }

    func testExperimentalTranspositionEvaluatorCanMeasureFlagOnCase() {
        let evaluator = TypoCorrectionBenchmarkEvaluator(
            engine: TypoCorrectionEngine(experimentalEdits: [.transposition])
        )

        let result = evaluator.evaluate(.init(
            input: "nihoa",
            category: .supported,
            expectedCorrectedInput: "nihao",
            expectedCandidate: "你好",
            expectedOutcome: .corrected,
            note: "experimental transposition"
        ))

        XCTAssertTrue(result.passed)
        XCTAssertEqual(result.assessment?.reasonSummary, .adjacentTransposition)
        XCTAssertFalse(result.didPromote)
    }

    func testExperimentalTranspositionCoversLongPinyinSwap() {
        let evaluator = TypoCorrectionBenchmarkEvaluator(
            engine: TypoCorrectionEngine(experimentalEdits: [.transposition])
        )

        let result = evaluator.evaluate(.init(
            input: "zohngguo",
            category: .supported,
            expectedCorrectedInput: "zhongguo",
            expectedCandidate: "中国",
            expectedOutcome: .corrected,
            note: "long-pinyin experimental transposition"
        ))

        XCTAssertTrue(result.passed)
        XCTAssertEqual(result.assessment?.reasonSummary, .adjacentTransposition)
        XCTAssertFalse(result.didPromote)
    }

    func testExperimentalTranspositionIsSuppressedWhenNormalTopAlreadyMatchesCorrectedBest() {
        let provider = BenchmarkDictionaryCandidateProvider(dictionary: [
            "nihoa": ["你好", "你花"],
            "nihao": ["你好", "拟好", "你号"],
        ])
        let evaluator = TypoCorrectionBenchmarkEvaluator(
            engine: TypoCorrectionEngine(experimentalEdits: [.transposition]),
            candidateProvider: provider
        )

        let result = evaluator.evaluate(.init(
            input: "nihoa",
            category: .normalInput,
            expectedOutcome: .notCorrected,
            note: "normal RIME already provides corrected best candidate"
        ))

        XCTAssertTrue(result.passed)
        XCTAssertNil(result.actualCandidate)
    }

    func testExperimentalAuditSummaryPassesFlagOnDeviceValidationGate() {
        let evaluator = TypoCorrectionBenchmarkEvaluator(
            engine: TypoCorrectionEngine(experimentalEdits: [.insertion, .transposition])
        )

        let summary = evaluator.evaluate(TypoCorrectionBenchmarkEvaluator.experimentalAuditCases)

        XCTAssertEqual(summary.passedCount, summary.totalCount)
        XCTAssertEqual(summary.targetCorrectionPassedCount, summary.targetCorrectionCount)
        XCTAssertEqual(summary.normalInputPassedCount, summary.normalInputCount)
        XCTAssertEqual(summary.falsePositiveCount, 0)
        XCTAssertEqual(summary.dangerousCorrectionCount, 0)
        XCTAssertTrue(summary.isReadyForDeviceValidation)
    }

    func testExperimentalInsertionAndTranspositionAssessmentsAreDisplayOnlyLowConfidence() {
        let insertion = TypoCorrectionAssessment.evaluate(
            title: "你好",
            originalInput: "niho",
            correctedInput: "nihao",
            edits: [
                TypoCorrectionEdit(index: 3, original: "a", replacement: "a", kind: .insertion, inserted: "a")
            ],
            firstNormalCandidate: nil
        )
        let transposition = TypoCorrectionAssessment.evaluate(
            title: "你好",
            originalInput: "nihoa",
            correctedInput: "nihao",
            edits: [
                TypoCorrectionEdit(index: 3, original: "o", replacement: "a", kind: .transposition, secondIndex: 4)
            ],
            firstNormalCandidate: nil
        )

        XCTAssertEqual(insertion.confidence, .low)
        XCTAssertEqual(insertion.reasonSummary, .conservativeInsertion)
        XCTAssertFalse(insertion.isPromotionEligible)
        XCTAssertEqual(transposition.confidence, .low)
        XCTAssertEqual(transposition.reasonSummary, .adjacentTransposition)
        XCTAssertFalse(transposition.isPromotionEligible)
    }

    func testExperimentalTranspositionAssessmentRejectsShortInput() {
        let assessment = TypoCorrectionAssessment.evaluate(
            title: "你好",
            originalInput: "ab",
            correctedInput: "ba",
            edits: [
                TypoCorrectionEdit(index: 0, original: "a", replacement: "b", kind: .transposition, secondIndex: 1)
            ],
            firstNormalCandidate: nil
        )

        XCTAssertEqual(assessment.rejectReason, .inputTooShort)
        XCTAssertFalse(assessment.isDisplayEligible)
    }
}

private final class BenchmarkDictionaryCandidateProvider: CandidateProvider {
    private let dictionary: [String: [String]]

    init(dictionary: [String: [String]]) {
        self.dictionary = dictionary
    }

    func candidates(for composition: String) -> [String] {
        dictionary[composition] ?? []
    }
}
