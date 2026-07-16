import XCTest

@testable import KeyboardCore

/// V1.3 的合成代表集只用于防止已审查场景回退。
/// 它不是来自真实用户的数据，也不能证明真实世界覆盖率或接受率。
final class ContinuationQualityBenchmarkTests: XCTestCase {
    func testCuratedRepresentativeCasesKeepRelevantSuggestionInTopThree() {
        let summary = evaluate(Self.representativeCases)

        XCTAssertEqual(summary.coveredCount, Self.representativeCases.count)
        XCTAssertEqual(summary.relevantTopThreeCount, Self.representativeCases.count)
        XCTAssertEqual(summary.categoriesCovered, Set(ContinuationQualityCategory.allCases))
        XCTAssertEqual(Self.representativeCases.count, 60)

        let caseCounts = Dictionary(grouping: Self.representativeCases, by: \.category)
            .mapValues(\.count)
        for category in ContinuationQualityCategory.allCases {
            XCTAssertEqual(caseCounts[category], 4, category.rawValue)
        }
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

    func testReviewedNaturalnessCasesKeepPreferredSuggestionFirst() {
        let provider = BundledContinuationSuggestionProvider.shared

        for naturalnessCase in Self.naturalnessCases {
            XCTAssertEqual(
                provider.suggestions(for: naturalnessCase.context, limit: 8).first,
                naturalnessCase.expectedFirst,
                naturalnessCase.id
            )
        }

        XCTAssertEqual(
            Set(Self.naturalnessCases.map(\.category)),
            Set(ContinuationQualityCategory.allCases)
        )
        XCTAssertEqual(Self.naturalnessCases.count, ContinuationQualityCategory.allCases.count)
    }

    func testAmbiguousSingleCharacterSuffixesStaySuppressed() {
        let provider = BundledContinuationSuggestionProvider.shared
        let ambiguousContexts = [
            "刚要吃",
            "正在喝",
            "只有我",
            "问问你",
            "关于他",
            "关于她",
            "还算好",
            "去买",
        ]

        for context in ambiguousContexts {
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
        .init("meal-004", .meal, "今天早餐", ["吃了吗", "吃什么"]),
        .init("schedule-001", .schedule, "今天晚上", ["有空吗", "吃什么"]),
        .init("schedule-002", .schedule, "那就明天", ["见", "上午"]),
        .init("schedule-003", .schedule, "这个周末", ["有空吗", "一起去"]),
        .init("schedule-004", .schedule, "安排在后天", ["见", "有空吗"]),
        .init("greeting-001", .greeting, "你好", ["呀", "，"]),
        .init("greeting-002", .greeting, "请问", ["一下", "你知道"]),
        .init("greeting-003", .greeting, "真的辛苦了", ["！", "，"]),
        .init("greeting-004", .greeting, "真的好久不见", ["！", "最近好吗"]),
        .init("acknowledgement-001", .acknowledgement, "已经收到", ["，", "谢谢"]),
        .init("acknowledgement-002", .acknowledgement, "好的", ["，", "谢谢"]),
        .init("acknowledgement-003", .acknowledgement, "没关系", ["的", "，"]),
        .init("acknowledgement-004", .acknowledgement, "我明白了", ["，", "谢谢"]),
        .init("work-001", .work, "我想", ["问一下", "知道"]),
        .init("work-003", .work, "麻烦你", ["看一下", "帮我"]),
        .init("work-004", .work, "会议", ["开始了", "时间"]),
        .init("work-005", .work, "任务完成", ["了", "了吗"]),
        .init("travel-001", .travel, "刚刚我到了", ["，", "在门口"]),
        .init("travel-002", .travel, "还在路上", ["了", "，"]),
        .init("travel-003", .travel, "已经快到了", ["，", "等我一下"]),
        .init("travel-004", .travel, "我在地铁", ["到了吗", "上"]),
        .init("care-001", .care, "一定注意安全", ["！", "，"]),
        .init("care-002", .care, "最近身体", ["怎么样", "还好吗"]),
        .init("care-003", .care, "记得早点", ["休息", "睡"]),
        .init("care-004", .care, "今天有点头疼", ["吗", "就休息一下"]),
        .init("logistics-001", .logistics, "你的快递", ["到了", "到了吗"]),
        .init("logistics-002", .logistics, "刚点的外卖", ["到了", "到了吗"]),
        .init("logistics-003", .logistics, "这个包裹", ["到了", "收到了吗"]),
        .init("logistics-004", .logistics, "这次退款", ["成功了", "到账了吗"]),
        .init("question-001", .question, "现在怎么办", ["？", "呢"]),
        .init("question-002", .question, "你要不要", ["一起", "去"]),
        .init("question-003", .question, "结果怎么样", ["了", "？"]),
        .init("question-004", .question, "明天可以吗", ["？", "，"]),
        .init("emotion-001", .emotion, "太好了", ["！", "，"]),
        .init("emotion-002", .emotion, "祝你", ["开心", "顺利"]),
        .init("emotion-003", .emotion, "不要一个人难过", ["吗", "就说出来"]),
        .init("emotion-004", .emotion, "你真的太棒了", ["！", "，"]),
        .init("family-001", .family, "我爸妈", ["在家", "都好"]),
        .init("family-002", .family, "今天家里", ["有人吗", "都好"]),
        .init("family-003", .family, "可爱的宝宝", ["睡了", "醒了"]),
        .init("family-004", .family, "问问奶奶", ["身体好吗", "在家"]),
        .init("shopping-001", .shopping, "最近想买", ["什么", "这个"]),
        .init("shopping-002", .shopping, "去超市", ["买东西", "见"]),
        .init("shopping-003", .shopping, "现在有货", ["吗", "的话通知我"]),
        .init("shopping-004", .shopping, "这个尺码", ["合适吗", "是多少"]),
        .init("study-001", .study, "今天的作业", ["写完了吗", "交了吗"]),
        .init("study-002", .study, "准备考试", ["加油", "结束了吗"]),
        .init("study-003", .study, "我到学校", ["见", "门口"]),
        .init("study-004", .study, "去图书馆", ["见", "学习"]),
        .init("entertainment-001", .entertainment, "这部电影", ["好看吗", "什么时候开始"]),
        .init("entertainment-002", .entertainment, "晚上玩游戏", ["吗", "一起吗"]),
        .init("entertainment-003", .entertainment, "演出的门票", ["买了吗", "多少钱"]),
        .init("entertainment-004", .entertainment, "终于放假", ["了", "了吗"]),
        .init("weather-001", .weather, "外面下雨", ["了", "了吗"]),
        .init("weather-002", .weather, "今天天冷", ["了", "多穿点"]),
        .init("weather-003", .weather, "最近降温", ["了", "注意保暖"]),
        .init("weather-004", .weather, "看看天气预报", ["说明天下雨", "准吗"]),
    ]

    /// 每类只锁定一个人工审查过的首选项，避免把整个资源误写成
    /// “唯一正确答案”清单，同时比 Top-3 门禁更早发现生硬首候选。
    private static let naturalnessCases: [ContinuationNaturalnessCase] = [
        .init("natural-meal", .meal, "今天早餐", "吃了吗"),
        .init("natural-schedule", .schedule, "这个周末", "有空吗"),
        .init("natural-greeting", .greeting, "真的好久不见", "！"),
        .init("natural-acknowledgement", .acknowledgement, "我明白了", "，"),
        .init("natural-work", .work, "任务完成", "了"),
        .init("natural-travel", .travel, "我在地铁", "上"),
        .init("natural-care", .care, "今天有点头疼", "，要多休息"),
        .init("natural-logistics", .logistics, "这个包裹", "到了"),
        .init("natural-question", .question, "明天可以吗", "？"),
        .init("natural-emotion", .emotion, "不要一个人难过", "，有我在"),
        .init("natural-family", .family, "我爸妈", "在家"),
        .init("natural-shopping", .shopping, "现在有货", "吗"),
        .init("natural-study", .study, "准备考试", "了吗"),
        .init("natural-entertainment", .entertainment, "晚上玩游戏", "吗"),
        .init("natural-weather", .weather, "看看天气预报", "，明天可能下雨"),
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
    case family
    case shopping
    case study
    case entertainment
    case weather
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

private struct ContinuationNaturalnessCase {
    let id: String
    let category: ContinuationQualityCategory
    let context: String
    let expectedFirst: String

    init(
        _ id: String,
        _ category: ContinuationQualityCategory,
        _ context: String,
        _ expectedFirst: String
    ) {
        self.id = id
        self.category = category
        self.context = context
        self.expectedFirst = expectedFirst
    }
}
