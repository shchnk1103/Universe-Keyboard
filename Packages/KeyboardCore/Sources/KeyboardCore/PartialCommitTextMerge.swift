import Foundation

/// Shared merge rule for partial-commit completion boundaries.
///
/// Both closing points (`finishNormalCandidateSelection` and
/// `applyRimeOutputPreservingPartialCommit`) route through this single rule so
/// a confirmed prefix and the following engine commit never get duplicated at
/// their seam: the largest overlap between the confirmed suffix and the
/// committed prefix is dropped before concatenation.
enum PartialCommitTextMerge {
    static func mergedText(confirmed: String, committed: String) -> String {
        if committed.hasPrefix(confirmed) {
            return committed
        }
        if confirmed.hasPrefix(committed) {
            return confirmed
        }
        guard !confirmed.isEmpty, !committed.isEmpty else {
            return confirmed + committed
        }
        let maxOverlap = min(confirmed.count, committed.count)
        var overlap = 0
        for k in 1...maxOverlap
        where String(confirmed.suffix(k)) == String(committed.prefix(k)) {
            overlap = k
        }
        return confirmed + String(committed.dropFirst(overlap))
    }
}
