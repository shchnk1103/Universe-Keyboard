import Foundation

/// Path bar empty-state education. Retired after Path UX already teaches
/// tap-to-advance; the idle copy is no longer shown.
public enum T9IdlePathHintPolicy: Sendable {
    /// Historical copy. Kept so existing call sites compile; `shouldShow` is always false.
    public static let displayText = "点选拼音可加快输入"

    /// Always `false`. Path bar idle education was removed after the Path flow
    /// itself was optimized; do not reintroduce mid-type banners here.
    public static func shouldShow(
        isNineKeyChineseLettersSurface: Bool,
        usesT9InputSemantics: Bool,
        rawInput: String?,
        segmentSourceDigits: String?,
        pathCount: Int
    ) -> Bool {
        _ = (
            isNineKeyChineseLettersSurface, usesT9InputSemantics, rawInput,
            segmentSourceDigits, pathCount
        )
        return false
    }
}
