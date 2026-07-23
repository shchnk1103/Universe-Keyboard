/// Partial Commit 的单步恢复快照。
///
/// 仅保留最近一次部分确认前的状态，用于下一次 Delete 恢复。
public struct PartialCommitCheckpoint: Equatable, Sendable {
    public let previousConfirmedText: String
    public let previousRawInput: String
    public let previousPreeditText: String
    public let previousDisplayText: String
    /// Gate 5 β-limited: pre-partial T9 digit identity (optional for legacy callers).
    public let previousSegmentSourceDigits: String?
    public let previousConfirmedSegmentValues: [String]
    public let previousFocusedSegmentIndex: Int?

    public init(
        previousConfirmedText: String = "",
        previousRawInput: String,
        previousPreeditText: String,
        previousDisplayText: String,
        previousSegmentSourceDigits: String? = nil,
        previousConfirmedSegmentValues: [String] = [],
        previousFocusedSegmentIndex: Int? = nil
    ) {
        self.previousConfirmedText = previousConfirmedText
        self.previousRawInput = previousRawInput
        self.previousPreeditText = previousPreeditText
        self.previousDisplayText = previousDisplayText
        self.previousSegmentSourceDigits = previousSegmentSourceDigits
        self.previousConfirmedSegmentValues = previousConfirmedSegmentValues
        self.previousFocusedSegmentIndex = previousFocusedSegmentIndex
    }
}

public enum PartialCommitSource: Equatable, Sendable {
    case rime
    case typoCorrection
    case numberSuffix
}

/// 当前 composition 中已确认文本与剩余输入的基础状态。
///
/// 已确认文本仍属于当前输入会话，displayText 是宿主文本框中的完整活动文本。
public struct PartialCommitState: Equatable, Sendable {
    public let confirmedText: String
    public let remainingRawInput: String
    public let remainingPreeditText: String
    public let displayText: String
    public let checkpoint: PartialCommitCheckpoint?
    public let source: PartialCommitSource

    public init(
        confirmedText: String,
        remainingRawInput: String,
        remainingPreeditText: String,
        displayText: String,
        checkpoint: PartialCommitCheckpoint? = nil,
        source: PartialCommitSource = .rime
    ) {
        self.confirmedText = confirmedText
        self.remainingRawInput = remainingRawInput
        self.remainingPreeditText = remainingPreeditText
        self.displayText = displayText
        self.checkpoint = checkpoint
        self.source = source
    }
}
