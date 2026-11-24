import Foundation

/// PB-013 标点回弹后候选栏续接状态。
/// 进程内存态：不写 App Group、不持久化，也不在 `resetPreview()` 等清理清单内。
public struct PunctuationContinuationState: Equatable, Sendable {
    /// 触发键。按最终上屏文本归一（m1）：成对符号补全与组合态收尾均以
    /// 实际追加进宿主的文本为键，调用方无须再分叉。
    public let trigger: String
    /// 常用中文续接标点候选，顺序即候选栏展示顺序。
    public let candidates: [String]

    public init(trigger: String, candidates: [String]) {
        self.trigger = trigger
        self.candidates = candidates
    }
}

/// PB-013 内置静态续接集合（Human 拍板的常用中文续接标点）。
/// 零热路径 IO（ADR 0007）：编译内置静态常量，热路径纯内存查表，
/// 无文件读取、无网络、无输入文本日志。
public enum PunctuationContinuationCatalog {
    /// 键为触发标点（最终上屏文本归一）；值为续接候选，顺序即展示顺序。
    public static let continuationSets: [String: [String]] = [
        "！": ["？", "！", "……", "——", "”", "）"],
        "？": ["！", "？", "……", "——", "”", "）"],
        "。": ["”", "）", "……", "——"],
        "，": ["”", "……"],
    ]

    /// 按触发键（最终上屏文本）查续接候选；未命中返回 nil。
    public static func candidates(forTrigger appendedText: String) -> [String]? {
        continuationSets[appendedText]
    }
}
