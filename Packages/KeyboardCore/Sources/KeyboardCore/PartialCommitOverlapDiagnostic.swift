import Foundation

/// PF054-DIAG-001: content-free diagnostic emitted at the two `finalText`
/// splice points (finish / preserve). Carries booleans and character counts
/// only — never input text, pinyin or candidate strings.
public struct PartialCommitOverlapDiagnostic: Equatable, Sendable {
    /// Which splice point produced the observation.
    public enum Path: String, Sendable {
        /// `finishNormalCandidateSelection`.
        case finish
        /// `applyRimeOutputPreservingPartialCommit`.
        case preserve
    }

    public let path: Path
    /// Whether `committedText.hasPrefix(confirmedText)` held (no splice needed).
    public let committedHasPrefix: Bool
    public let confirmedLen: Int
    public let committedLen: Int
    /// Max common length of the `confirmedText` suffix and the `committedText` prefix.
    public let overlapLen: Int

    public init(
        path: Path,
        committedHasPrefix: Bool,
        confirmedLen: Int,
        committedLen: Int,
        overlapLen: Int
    ) {
        self.path = path
        self.committedHasPrefix = committedHasPrefix
        self.confirmedLen = confirmedLen
        self.committedLen = committedLen
        self.overlapLen = overlapLen
    }
}
