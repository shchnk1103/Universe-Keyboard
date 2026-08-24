public struct KeyboardEffect: OptionSet, Equatable, Sendable {
    public let rawValue: UInt16

    public init(rawValue: UInt16) {
        self.rawValue = rawValue
    }

    public static let compositionChanged = KeyboardEffect(rawValue: 1 << 0)
    public static let shiftStateChanged = KeyboardEffect(rawValue: 1 << 1)
    public static let pageChanged = KeyboardEffect(rawValue: 1 << 2)
    public static let inputModeChanged = KeyboardEffect(rawValue: 1 << 3)
    public static let keyboardTypeChanged = KeyboardEffect(rawValue: 1 << 4)
    public static let continuationChanged = KeyboardEffect(rawValue: 1 << 5)
    /// Precise T9 pinyin path compact list or selection changed (ADR 0020).
    public static let t9PinyinPathsChanged = KeyboardEffect(rawValue: 1 << 6)
    /// 九键待确认标点列表或载荷变化（ADR 0029）。不得复用 continuationChanged。
    public static let pendingPunctuationChanged = KeyboardEffect(rawValue: 1 << 7)
    /// 待确认颜表情列表或载荷变化（ADR 0030）。不得复用标点或 continuation 位。
    public static let pendingKaomojiChanged = KeyboardEffect(rawValue: 1 << 8)

    /// 候选栏 / 本地 pending chrome 需要按 Core 快照重建。
    public var refreshesCandidatePresentation: Bool {
        contains(.compositionChanged)
            || contains(.continuationChanged)
            || contains(.pendingPunctuationChanged)
            || contains(.pendingKaomojiChanged)
    }
}
