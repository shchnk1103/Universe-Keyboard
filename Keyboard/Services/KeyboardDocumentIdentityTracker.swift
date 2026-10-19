import Foundation

/// Tracks host identity in memory. An unavailable sample must not erase the
/// last valid baseline, or a later host change would look like first binding.
struct KeyboardDocumentIdentityTracker {
    enum Observation: Equatable {
        case unavailable
        case initial
        case unchanged
        case changed
    }

    private(set) var identifier: UUID?

    mutating func observe(_ current: UUID?) -> Observation {
        guard let current else { return .unavailable }
        defer { identifier = current }
        guard let previous = identifier else { return .initial }
        return previous == current ? .unchanged : .changed
    }
}
