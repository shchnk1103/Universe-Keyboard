import Foundation
import KeyboardCore

struct TypoCorrectionBenchmarkModel {
    let summary: TypoCorrectionBenchmarkSummary

    init(evaluator: TypoCorrectionBenchmarkEvaluator = TypoCorrectionBenchmarkEvaluator()) {
        summary = evaluator.evaluate()
    }

    var passRateText: String {
        "\(summary.passedCount)/\(summary.totalCount)"
    }

    var statusText: String {
        if summary.falsePositiveCount == 0, summary.dangerousCorrectionCount == 0 {
            return "质量闸门通过"
        }
        return "需要复核"
    }

    var groupedResults: [TypoCorrectionBenchmarkGroup] {
        [
            group(title: "当前覆盖", category: .supported),
            group(title: "正常输入", category: .normalInput),
            group(title: "已知边界", category: .unsupported),
            group(title: "危险样例", category: .dangerous),
        ].filter { !$0.results.isEmpty }
    }

    private func group(
        title: String,
        category: TypoCorrectionBenchmarkCategory
    ) -> TypoCorrectionBenchmarkGroup {
        TypoCorrectionBenchmarkGroup(
            title: title,
            results: summary.results.filter { $0.testCase.category == category }
        )
    }
}

struct TypoCorrectionBenchmarkGroup: Identifiable {
    let title: String
    let results: [TypoCorrectionBenchmarkResult]

    var id: String { title }
}

extension TypoCorrectionBenchmarkResult {
    var displayActual: String {
        guard let actualCandidate, let actualCorrectedInput else {
            return "未纠错"
        }
        return "\(actualCorrectedInput) -> \(actualCandidate)"
    }

    var displayExpected: String {
        guard let expectedCandidate = testCase.expectedCandidate,
            let expectedCorrectedInput = testCase.expectedCorrectedInput
        else {
            return "不应纠错"
        }
        return "\(expectedCorrectedInput) -> \(expectedCandidate)"
    }

    var displayConfidence: String {
        switch assessment?.confidence {
        case .high: return "高"
        case .medium: return "中"
        case .low: return "低"
        case .rejected: return "拒绝"
        case nil: return "无"
        }
    }

    var displayPromotion: String {
        didPromote ? "可提升" : "不提升"
    }

    var displayReason: String {
        if let reason = assessment?.reasonSummary {
            return reason.displayText
        }
        if let rejectReason = assessment?.rejectReason {
            return rejectReason.displayText
        }
        return testCase.note
    }
}

private extension TypoCorrectionAssessmentReason {
    var displayText: String {
        switch self {
        case .finalAdjacentSubstitution: return "末尾邻键替换"
        case .initialAdjacentSubstitution: return "首字母邻键替换"
        case .middleSafeSubstitution: return "中间安全邻键替换"
        case .repeatedFinalDeletion: return "末尾重复字符删除"
        case .conservativeInsertion: return "保守漏字补全"
        case .adjacentTransposition: return "相邻字符转置"
        }
    }
}

private extension TypoCorrectionRejectReason {
    var displayText: String {
        switch self {
        case .inputTooShort: return "输入过短"
        case .unsupportedEdit: return "暂不支持的 edit"
        case .unsafeReplacement: return "替换风险过高"
        case .noCorrectedCandidates: return "纠正后无候选"
        case .normalCandidateAlreadyMatches: return "普通首候选已匹配"
        case .candidateTextTooLong: return "候选过长"
        }
    }
}
