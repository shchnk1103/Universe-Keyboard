import Foundation

public enum TypoCorrectionBenchmarkCategory: Equatable, Sendable {
    case supported
    case unsupported
    case dangerous
    case normalInput
}

public enum TypoCorrectionBenchmarkExpectedOutcome: Equatable, Sendable {
    case corrected
    case notCorrected
}

public enum TypoCorrectionBenchmarkActualOutcome: Equatable, Sendable {
    case corrected
    case notCorrected
    case falsePositive
    case dangerousCorrection
}

public struct TypoCorrectionBenchmarkCase: Identifiable, Equatable, Sendable {
    public let input: String
    public let category: TypoCorrectionBenchmarkCategory
    public let expectedCorrectedInput: String?
    public let expectedCandidate: String?
    public let expectedOutcome: TypoCorrectionBenchmarkExpectedOutcome
    public let shouldPromote: Bool
    public let note: String

    public var id: String { input }

    public init(
        input: String,
        category: TypoCorrectionBenchmarkCategory,
        expectedCorrectedInput: String? = nil,
        expectedCandidate: String? = nil,
        expectedOutcome: TypoCorrectionBenchmarkExpectedOutcome,
        shouldPromote: Bool = false,
        note: String
    ) {
        self.input = input
        self.category = category
        self.expectedCorrectedInput = expectedCorrectedInput
        self.expectedCandidate = expectedCandidate
        self.expectedOutcome = expectedOutcome
        self.shouldPromote = shouldPromote
        self.note = note
    }
}

public struct TypoCorrectionBenchmarkResult: Identifiable, Equatable, Sendable {
    public let testCase: TypoCorrectionBenchmarkCase
    public let actualCorrectedInput: String?
    public let actualCandidate: String?
    public let actualOutcome: TypoCorrectionBenchmarkActualOutcome
    public let assessment: TypoCorrectionAssessment?
    public let didPromote: Bool

    public var id: String { testCase.id }

    public var passed: Bool {
        switch testCase.expectedOutcome {
        case .corrected:
            return actualOutcome == .corrected
                && actualCorrectedInput == testCase.expectedCorrectedInput
                && actualCandidate == testCase.expectedCandidate
                && didPromote == testCase.shouldPromote
        case .notCorrected:
            return actualOutcome == .notCorrected
        }
    }
}

public struct TypoCorrectionBenchmarkSummary: Equatable, Sendable {
    public let results: [TypoCorrectionBenchmarkResult]

    public var totalCount: Int { results.count }
    public var passedCount: Int { results.filter(\.passed).count }
    public var falsePositiveCount: Int { results.filter { $0.actualOutcome == .falsePositive }.count }
    public var dangerousCorrectionCount: Int {
        results.filter { $0.actualOutcome == .dangerousCorrection }.count
    }

    public var passRate: Double {
        guard totalCount > 0 else { return 1 }
        return Double(passedCount) / Double(totalCount)
    }
}

public struct TypoCorrectionBenchmarkEvaluator {
    private let engine: TypoCorrectionEngine
    private let candidateProvider: CandidateProvider

    public init(
        engine: TypoCorrectionEngine = TypoCorrectionEngine(),
        candidateProvider: CandidateProvider = FakeCandidateProvider()
    ) {
        self.engine = engine
        self.candidateProvider = candidateProvider
    }

    public func evaluate(
        _ cases: [TypoCorrectionBenchmarkCase] = TypoCorrectionBenchmarkEvaluator.defaultCases
    ) -> TypoCorrectionBenchmarkSummary {
        TypoCorrectionBenchmarkSummary(results: cases.map(evaluate))
    }

    public func evaluate(_ testCase: TypoCorrectionBenchmarkCase) -> TypoCorrectionBenchmarkResult {
        let normalCandidates = candidateProvider.candidates(for: testCase.input)
        let suggestion = resolvedSuggestion(for: testCase.input, normalCandidates: normalCandidates)
        let firstCandidate = suggestion?.candidates.first?.text
        let assessment = firstCandidate.flatMap { candidate in
            suggestion.map {
                TypoCorrectionAssessment.evaluate(
                    title: candidate,
                    suggestion: $0,
                    firstNormalCandidate: normalCandidates.first
                )
            }
        }
        let didPromote = promoted(
            candidate: firstCandidate,
            suggestion: suggestion,
            normalCandidates: normalCandidates
        )

        return TypoCorrectionBenchmarkResult(
            testCase: testCase,
            actualCorrectedInput: suggestion?.correctedInput,
            actualCandidate: firstCandidate,
            actualOutcome: actualOutcome(
                for: testCase,
                suggestion: suggestion,
                normalCandidates: normalCandidates
            ),
            assessment: assessment,
            didPromote: didPromote
        )
    }

    private func resolvedSuggestion(
        for input: String,
        normalCandidates: [String]
    ) -> TypoCorrectionSuggestion? {
        var seenCandidateTexts: Set<String> = []
        for suggestion in engine.suggestions(for: input) {
            let candidates = candidateProvider.candidates(for: suggestion.correctedInput)
                .filter { seenCandidateTexts.insert($0).inserted }
                .prefix(3)
                .map { RimeCandidate(text: $0) }
            guard let firstCandidate = candidates.first else { continue }

            let assessment = TypoCorrectionAssessment.evaluate(
                title: firstCandidate.text,
                suggestion: suggestion,
                firstNormalCandidate: normalCandidates.first
            )
            guard assessment.isDisplayEligible else { continue }

            return TypoCorrectionSuggestion(
                originalInput: suggestion.originalInput,
                correctedInput: suggestion.correctedInput,
                edits: suggestion.edits,
                candidates: Array(candidates)
            )
        }
        return nil
    }

    private func actualOutcome(
        for testCase: TypoCorrectionBenchmarkCase,
        suggestion: TypoCorrectionSuggestion?,
        normalCandidates: [String]
    ) -> TypoCorrectionBenchmarkActualOutcome {
        switch testCase.category {
        case .dangerous:
            return suggestion == nil ? .notCorrected : .dangerousCorrection
        case .normalInput:
            return suggestion == nil && !normalCandidates.isEmpty ? .notCorrected : .falsePositive
        case .supported:
            return suggestion == nil ? .notCorrected : .corrected
        case .unsupported:
            return suggestion == nil ? .notCorrected : .falsePositive
        }
    }

    private func promoted(
        candidate: String?,
        suggestion: TypoCorrectionSuggestion?,
        normalCandidates: [String]
    ) -> Bool {
        guard let candidate,
            let suggestion
        else { return false }

        return TypoCorrectionAssessment.evaluate(
            title: candidate,
            suggestion: suggestion,
            firstNormalCandidate: normalCandidates.first
        ).isPromotionEligible
    }
}

public extension TypoCorrectionBenchmarkEvaluator {
    static let defaultCases: [TypoCorrectionBenchmarkCase] = [
        .init(
            input: "nihap",
            category: .supported,
            expectedCorrectedInput: "nihao",
            expectedCandidate: "你好",
            expectedOutcome: .corrected,
            shouldPromote: true,
            note: "final adjacent-key substitution"
        ),
        .init(
            input: "bihao",
            category: .supported,
            expectedCorrectedInput: "nihao",
            expectedCandidate: "你好",
            expectedOutcome: .corrected,
            note: "initial adjacent-key substitution"
        ),
        .init(
            input: "nigao",
            category: .supported,
            expectedCorrectedInput: "nihao",
            expectedCandidate: "你好",
            expectedOutcome: .corrected,
            note: "middle adjacent-key substitution"
        ),
        .init(
            input: "zhonghuo",
            category: .supported,
            expectedCorrectedInput: "zhongguo",
            expectedCandidate: "中国",
            expectedOutcome: .corrected,
            note: "long-pinyin middle adjacent-key substitution"
        ),
        .init(
            input: "zhonggup",
            category: .supported,
            expectedCorrectedInput: "zhongguo",
            expectedCandidate: "中国",
            expectedOutcome: .corrected,
            shouldPromote: true,
            note: "long-pinyin final adjacent-key substitution"
        ),
        .init(
            input: "woainj",
            category: .supported,
            expectedCorrectedInput: "woaini",
            expectedCandidate: "我爱你",
            expectedOutcome: .corrected,
            shouldPromote: true,
            note: "phrase final adjacent-key substitution"
        ),
        .init(
            input: "nihaoo",
            category: .supported,
            expectedCorrectedInput: "nihao",
            expectedCandidate: "你好",
            expectedOutcome: .corrected,
            note: "repeated-final deletion"
        ),
        .init(input: "niho", category: .unsupported, expectedOutcome: .notCorrected, note: "omitted character"),
        .init(input: "nihoa", category: .unsupported, expectedOutcome: .notCorrected, note: "transposition"),
        .init(input: "nihso", category: .unsupported, expectedOutcome: .notCorrected, note: "unsafe middle replacement"),
        .init(input: "haop", category: .dangerous, expectedOutcome: .notCorrected, note: "ambiguous short input"),
        .init(input: "xianp", category: .dangerous, expectedOutcome: .notCorrected, note: "ambiguous input"),
        .init(input: "nihao", category: .normalInput, expectedOutcome: .notCorrected, note: "valid pinyin"),
        .init(input: "women", category: .normalInput, expectedOutcome: .notCorrected, note: "valid pinyin"),
        .init(input: "jintian", category: .normalInput, expectedOutcome: .notCorrected, note: "valid pinyin"),
        .init(input: "xiexie", category: .normalInput, expectedOutcome: .notCorrected, note: "valid pinyin"),
        .init(input: "shijian", category: .normalInput, expectedOutcome: .notCorrected, note: "valid pinyin"),
        .init(input: "zhongwen", category: .normalInput, expectedOutcome: .notCorrected, note: "valid pinyin"),
        .init(input: "ceshi", category: .normalInput, expectedOutcome: .notCorrected, note: "valid pinyin"),
    ]
}
