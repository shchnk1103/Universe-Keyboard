import Foundation

/// PB-013 Level 0 抑制原因。只允许非内容枚举值，便于 Human 调整「哪些处理动作触发抑制」。
nonisolated enum PastePreviewSuppressReason: String, Sendable {
    case pasted
    case closed
}

/// 持久抑制存储抽象。实现只允许写入整数 changeCount 与原因枚举——
/// 绝不持久化剪贴板正文、摘要或任何内容派生物（含哈希）。
nonisolated protocol PastePreviewSuppressStoring: AnyObject {
    func suppressedCount() -> Int?
    func suppress(_ count: Int, reason: PastePreviewSuppressReason)
}

/// PB-013 Level 0 持久抑制（跨进程，App Group UserDefaults）。
/// 命名边界：本类是「持久抑制」；进程内结果缓存（lastReadChangeCount / lastReadResult）
/// 位于 PasteToolbarSession，仅内存、不落盘，两者互不替代。
/// changeCount 是粘贴板单调计数器，非内容、非派生文本；单键覆盖写入，陈旧值随新复制自然失效。
nonisolated final class PastePreviewSuppressStore: PastePreviewSuppressStoring {
    static let countKey = "paste_preview_suppressed_change_count"
    static let reasonKey = "paste_preview_suppressed_reason"

    private let defaults: UserDefaults?

    /// `defaults` 为 nil 时退化为 no-op（不读不写），由注入方决定真实 App Group suite。
    init(defaults: UserDefaults?) {
        self.defaults = defaults
    }

    func suppressedCount() -> Int? {
        // 非 Int 存值（例如手改的 plist）一律忽略，视为无抑制。
        defaults?.object(forKey: Self.countKey) as? Int
    }

    func suppress(_ count: Int, reason: PastePreviewSuppressReason) {
        defaults?.set(count, forKey: Self.countKey)
        defaults?.set(reason.rawValue, forKey: Self.reasonKey)
    }
}
