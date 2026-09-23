import Foundation

/// Content-free field builders for INT-003 typo-recall journal markers.
///
/// Keeps composition text out of the Diagnostics protocol: only length and a
/// FNV-1a 32-bit fingerprint are allowlisted (ADR 0027 / AUTH markers field-budget).
public enum TypoCorrectionRecallDiagnosticMarkers: Sendable {
    /// FNV-1a 32-bit over UTF-8 of `normalizedComposition`, returned as a non-negative Int.
    public static func compositionFingerprint(_ normalizedComposition: String) -> Int {
        var hash: UInt32 = 2_166_136_261
        for byte in normalizedComposition.utf8 {
            hash ^= UInt32(byte)
            hash = hash &* 16_777_619
        }
        return Int(hash)
    }

    /// Bounded allowlisted fields shared by typo_recall.* events.
    public static func fenceFields(
        recallEpoch: UInt64,
        compositionRevision: UInt64,
        operationOrdinal: UInt64,
        normalizedComposition: String
    ) -> [DiagnosticEvent.Field] {
        [
            .count(.recallEpoch, clampedInt(recallEpoch)),
            .count(.compositionRevision, clampedInt(compositionRevision)),
            .count(.operationOrdinal, clampedInt(operationOrdinal)),
            .count(.compositionLength, min(normalizedComposition.count, 10_000)),
            .count(.compositionFingerprint, compositionFingerprint(normalizedComposition)),
        ]
    }

    private static func clampedInt(_ value: UInt64) -> Int {
        Int(clamping: value)
    }
}
