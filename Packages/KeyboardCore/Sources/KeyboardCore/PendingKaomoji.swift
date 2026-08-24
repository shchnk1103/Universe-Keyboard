import Foundation

/// 待确认颜表情（ADR 0030）。
///
/// 与 ADR 0029 标点 pending 平行：已出现在 host 上、仍可被候选点选替换。
/// 没有同键轮换窗；同键 `^_^` 是接受当前再新开默认 `^_^`。
public struct PendingKaomojiState: Equatable, Sendable {
    /// 键面 / 默认 pending。必须与九键和符号页 chrome 一致。
    public static let defaultPending = "^_^"

    /// 紧凑栏：包含当前 pending；`^_^` 永远第一。抄录表末两枚全角脸按 Product 表原样保留。
    public static let compactCatalog = [
        "^_^",
        "＾ω＾",
        "＾＾",
        "＾＿＾",
        "＾_＾",
        "＾_＾",
    ]

    /// 展开面板 V1 全表。`^_^` 在首位；截图中的近形重复按字面保留。
    public static let catalogTokens = [
        "^_^",
        "＾ω＾",
        "＾＾",
        "＾＿＾",
        "＾_＾",
        "＾_＾",
        "(＾＾)",
        "(＾＾)",
        "(＾-＾)",
        "(＾_＾)",
        "＾o＾",
        "(o＾＾o)",
        "(＾_＾)a",
        "(＾_＾)v",
        ":)",
        ":(",
        ":-)",
        "=)",
        "=(",
        ";-)",
        ":-|",
        ":-(",
        ":-D",
        ":D",
        ":-P",
        ":P",
        "囧＾-＾囧",
        "(`∨´)",
        "(。ì_í。)",
        "|-|",
        "(*＾＾*)",
        "(*＾_＾*)",
    ]

    public var text: String
    public var beforeCursor: String
    public var afterCursor: String
    public var ownsHostSpan: Bool

    public init(
        text: String,
        beforeCursor: String,
        afterCursor: String = "",
        ownsHostSpan: Bool = true
    ) {
        self.text = text
        self.beforeCursor = beforeCursor
        self.afterCursor = afterCursor
        self.ownsHostSpan = ownsHostSpan
    }

    public var matchesSplitInvariant: Bool {
        text == beforeCursor + afterCursor
    }

    public var canMutateHost: Bool {
        ownsHostSpan && matchesSplitInvariant && !text.isEmpty
    }

    /// 紧凑栏包含 pending；缺席时追加到表尾，不把 `^_^` 挤出首位。
    public static func compactTitles(including pendingText: String) -> [String] {
        var titles = compactCatalog
        if !titles.contains(pendingText) {
            titles.append(pendingText)
        }
        return titles
    }

    public static func expandedTitles(including pendingText: String) -> [String] {
        var titles = catalogTokens
        if !titles.contains(pendingText) {
            titles.append(pendingText)
        }
        return titles
    }
}

/// 颜表情键 chrome。UI 只引用这里的文案。
public enum KaomojiChrome {
    public static let keyTitle = "^_^"
    public static let accessibilityLabel = "颜表情"
    public static let accessibilityHint = "插入颜表情，可在候选栏更换。"
}
