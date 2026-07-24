import Foundation

/// Empty-state Path bar usage hint for Chinese nine-key (Lane A latency education).
///
/// Product contract:
/// - Visible only when nine-key Chinese letters surface is idle (no composition).
/// - Hide immediately once composition or Path options exist.
/// - Never a Path option, never mid-type after N digits.
public enum T9IdlePathHintPolicy: Sendable {
    /// Short action-oriented copy for the Path bar empty state.
    public static let displayText = "点选拼音可加快输入"

    /// Whether the non-interactive idle hint may appear on the Path bar.
    ///
    /// - Parameters:
    ///   - isNineKeyChineseLettersSurface: Path bar is reserved (Chinese + letters + nine-key ready).
    ///   - usesT9InputSemantics: Same flag as `T9CompositionCommitPolicy` callers.
    ///   - rawInput: Live RIME / tracked raw; any valid T9 raw means composition is active.
    ///   - segmentSourceDigits: Path ledger digits; non-empty means composition still owned.
    ///   - pathCount: Visible Path options for the current snapshot.
    public static func shouldShow(
        isNineKeyChineseLettersSurface: Bool,
        usesT9InputSemantics: Bool,
        rawInput: String?,
        segmentSourceDigits: String?,
        pathCount: Int
    ) -> Bool {
        guard isNineKeyChineseLettersSurface else { return false }
        guard pathCount == 0 else { return false }
        if T9CompositionCommitPolicy.isActiveT9Composition(
            usesT9InputSemantics: usesT9InputSemantics,
            rawInput: rawInput
        ) {
            return false
        }
        if let segmentSourceDigits, !segmentSourceDigits.isEmpty {
            return false
        }
        return true
    }
}
