import Foundation

/// Test copy of the extension's in-memory identity tracker.
/// KeyboardTests does not link the Keyboard extension, so this file keeps the
/// nil-baseline contract executable without importing extension internals.
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
