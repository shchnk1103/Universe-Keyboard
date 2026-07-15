import XCTest

@testable import KeyboardCore

/// V1.1 的合成代表集只用于防止已审查场景回退。
/// 它不是来自真实用户的数据，也不能证明真实世界覆盖率或接受率。
final class ContinuationQualityBenchmarkTests: XCTestCase {
    func testCuratedRepresentativeCasesKeepRelevantSuggestionInTopThree() {
        let summary = evaluate(Self.representativeCases)

        XCTAssertEqual(summary.coveredCount, Self.representativeCases.count)
        XCTAssertEqual(summary.relevantTopThreeCount, Self.representativeCases.count)
        XCTAssertEqual(summary.categoriesCovered, Set(ContinuationQualityCategory.allCases))
    }

    func testUnknownSyntheticSuffixesDoNotFabricateFallbacks() {
        let provider = BundledContinuationSuggestionProvider.shared
        let unknownContexts = [
            "量子纠缠实验报告",
            "ZXCVBNM",
            "123456789",
            "一段不存在的结尾词",
        ]

        for context in unknownContexts {
            XCTAssertTrue(provider.suggestions(for: context, limit: 8).isEmpty, context)
        }
    }

    private func evaluate(_ cases: [ContinuationQualityCase]) -> ContinuationQualitySummary {
        let provider = BundledContinuationSuggestionProvider.shared
        var coveredCount = 0
        var relevantTopThreeCount = 0
        var categoriesCovered = Set<ContinuationQualityCategory>()

        for qualityCase in cases {
            let suggestions = provider.suggestions(for: qualityCase.context, limit: 8)
            if !suggestions.isEmpty {
                coveredCount += 1
                categoriesCovered.insert(qualityCase.category)
            }
            if !Set(suggestions.prefix(3)).isDisjoint(with: qualityCase.expectedTopThree) {
                relevantTopThreeCount += 1
            }
        }

        return ContinuationQualitySummary(
            coveredCount: coveredCount,
            relevantTopThreeCount: relevantTopThreeCount,
            categoriesCovered: categoriesCovered
        )
    }

    private static let representativeCases: [ContinuationQualityCase] = [
        .init("meal-001", .meal, "我们吃了", ["吗", "饭"]),
        .init("meal-002", .meal, "准备吃饭", ["了吗", "了"]),
        .init("meal-003", .meal, "今晚晚饭", ["吃什么", "一起吃"]),
        .init("schedule-001", .schedule, "今天晚上", ["有空吗", "吃什么"]),
        .init("schedule-002", .schedule, "那就明天", ["见", "上午"]),
        .init("schedule-003", .schedule, "这个周末", ["有空吗", "一起去"]),
        .init("greeting-001", .greeting, "你好", ["呀", "，"]),
        .init("greeting-002", .greeting, "请问", ["一下", "你知道"]),
        .init("greeting-003", .greeting, "真的辛苦了", ["！", "，"]),
        .init("acknowledgement-001", .acknowledgement, "已经收到", ["，", "谢谢"]),
        .init("acknowledgement-002", .acknowledgement, "好的", ["，", "谢谢"]),
        .init("acknowledgement-003", .acknowledgement, "没关系", ["的", "，"]),
        .init("work-001", .work, "我想", ["问一下", "知道"]),
        .init("work-002", .work, "我已经", ["到了", "收到了"]),
        .init("work-003", .work, "麻烦你", ["看一下", "帮我"]),
        .init("work-004", .work, "会议", ["开始了", "时间"]),
        .init("work-005", .work, "任务完成", ["了", "了吗"]),
        .init("travel-001", .travel, "刚刚我到了", ["，", "在门口"]),
        .init("travel-002", .travel, "还在路上", ["了", "，"]),
        .init("travel-003", .travel, "已经快到了", ["，", "等我一下"]),
        .init("care-001", .care, "一定注意安全", ["！", "，"]),
        .init("care-002", .care, "最近身体", ["怎么样", "还好吗"]),
        .init("care-003", .care, "记得早点", ["休息", "睡"]),
        .init("logistics-001", .logistics, "你的快递", ["到了", "到了吗"]),
        .init("logistics-002", .logistics, "刚点的外卖", ["到了", "到了吗"]),
        .init("question-001", .question, "现在怎么办", ["？", "呢"]),
        .init("question-002", .question, "你要不要", ["一起", "去"]),
        .init("question-003", .question, "结果怎么样", ["了", "？"]),
        .init("emotion-001", .emotion, "太好了", ["！", "，"]),
        .init("emotion-002", .emotion, "祝你", ["开心", "顺利"]),
    ]
}

private enum ContinuationQualityCategory: String, CaseIterable {
    case meal
    case schedule
    case greeting
    case acknowledgement
    case work
    case travel
    case care
    case logistics
    case question
    case emotion
}

private struct ContinuationQualityCase {
    let id: String
    let category: ContinuationQualityCategory
    let context: String
    let expectedTopThree: Set<String>

    init(
        _ id: String,
        _ category: ContinuationQualityCategory,
        _ context: String,
        _ expectedTopThree: Set<String>
    ) {
        self.id = id
        self.category = category
        self.context = context
        self.expectedTopThree = expectedTopThree
    }
}

private struct ContinuationQualitySummary {
    let coveredCount: Int
    let relevantTopThreeCount: Int
    let categoriesCovered: Set<ContinuationQualityCategory>
}
