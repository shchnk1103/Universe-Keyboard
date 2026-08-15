import Foundation

/// 九键待确认标点（ADR 0029）。
///
/// 这是 KeyboardCore 自己的 ephemeral 状态，不是 RIME composition，
/// 也不是 ADR 0017 continuation。它描述一段已经出现在 host 上、
/// 但仍可被同键轮换或候选点选替换的文本。
public struct PendingPunctuationState: Equatable, Sendable {
    /// Product 冻结的同键轮换窗。
    public static let cycleWindow: TimeInterval = 1.0

    /// 同键轮换集合，顺序即键面 `，。？！`。
    public static let cycleMarks = ["，", "。", "？", "！"]

    /// V1 候选 token。`……` 是一个 token；成对符号拆开。
    public static let catalogTokens = [
        "。", "？", "！", "……", "～", "#", "：", "、", "；",
        "“", "”", "‘", "’", "（", "）", "@",
    ]

    /// 当前待确认、已出现在 host 上的整段文本。
    public var text: String
    /// 光标左侧、属于这段 pending 的文本。
    public var beforeCursor: String
    /// 光标右侧、属于这段 pending 的文本（成对补全的 closer）。
    public var afterCursor: String
    /// Core 是否仍拥有刚才写下的 host 跨度。失权后不得再动刀。
    public var ownsHostSpan: Bool
    /// 四键轮换下标；仅当 `text` 恰好是四键之一时有值。
    public var cycleIndex: Int?
    /// 最近一次同键点击。
    public var lastSameKeyTap: Date
    /// 下一次同键是否允许轮换。候选点选后必须为 false。
    public var cycleArmed: Bool

    public init(
        text: String,
        beforeCursor: String,
        afterCursor: String = "",
        ownsHostSpan: Bool = true,
        cycleIndex: Int? = nil,
        lastSameKeyTap: Date,
        cycleArmed: Bool
    ) {
        self.text = text
        self.beforeCursor = beforeCursor
        self.afterCursor = afterCursor
        self.ownsHostSpan = ownsHostSpan
        self.cycleIndex = cycleIndex
        self.lastSameKeyTap = lastSameKeyTap
        self.cycleArmed = cycleArmed
    }

    /// ADR 不变量：整段文本必须等于光标两侧拼接。
    public var matchesSplitInvariant: Bool {
        text == beforeCursor + afterCursor
    }

    public var canMutateHost: Bool {
        ownsHostSpan && matchesSplitInvariant && !text.isEmpty
    }

    public func isCycleEligible(now: Date) -> Bool {
        cycleArmed
            && canMutateHost
            && cycleIndex != nil
            && now.timeIntervalSince(lastSameKeyTap) <= Self.cycleWindow
    }

    public static func cycleIndex(for text: String) -> Int? {
        cycleMarks.firstIndex(of: text)
    }

    public static func compactTitles(excluding pendingText: String) -> [String] {
        catalogTokens.filter { $0 != pendingText }
    }
}

extension PendingPunctuationState {
    /// 与符号页同一张 opener → closer 表。表上没有的 token 不成对。
    public static func pairedCloser(for opener: String) -> String? {
        [
            "（": "）",
            "(": ")",
            "“": "”",
            "【": "】",
            "[": "]",
            "｛": "｝",
            "{": "}",
            "《": "》",
            "<": ">",
        ][opener]
    }
}

/// 九键标点键的 chrome 合同。UI 只引用这里的文案，不在 Extension 里复制轮换算术。
public enum T9CommonPunctuationChrome {
    public static let keyTitle = "，。？！"
    public static let accessibilityLabel = "常用标点"
}
