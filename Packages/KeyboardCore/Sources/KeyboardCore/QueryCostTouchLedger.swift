#if DEBUG && KEYBOARD_QUERY_COST_PROBE
    /// Finite, content-free touch state shared by the UIKit observer and synthetic tests.
    /// Identities live only until retirement; they never enter the exported probe wire.
    public struct QueryCostTouchLedger {
        public static let capacity = 16
        private var identities: [ObjectIdentifier?] = Array(repeating: nil, count: QueryCostTouchLedger.capacity)
        public private(set) var hasUnknownState = false
        public var isIdle: Bool { !hasUnknownState && activeCount == 0 }
        public var activeCount: Int { identities.reduce(0) { $0 + ($1 == nil ? 0 : 1) } }
        public init() {}

        public static func shouldObserve(isOwnControl: Bool) -> Bool { !isOwnControl }

        public mutating func begin(_ identity: ObjectIdentifier, isOwnControl: Bool) {
            guard Self.shouldObserve(isOwnControl: isOwnControl) else { return }
            guard !identities.contains(where: { $0 == identity }),
                let slot = identities.firstIndex(where: { $0 == nil })
            else {
                hasUnknownState = true
                return
            }
            identities[slot] = identity
        }

        /// UIKit end and cancellation share the same retirement transition.
        public mutating func retire(_ identity: ObjectIdentifier) {
            guard let slot = identities.firstIndex(where: { $0 == identity }) else {
                hasUnknownState = true
                return
            }
            identities[slot] = nil
        }

        /// An unexpected reset with live identities cannot establish a safe idle state.
        /// Keep identities for eventual retirement and keep uncertainty sticky forever.
        public mutating func reset() {
            if activeCount != 0 { hasUnknownState = true }
        }
    }
#endif
