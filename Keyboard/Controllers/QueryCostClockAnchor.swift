#if DEBUG && KEYBOARD_QUERY_COST_PROBE
    import Dispatch
    import os

    /// Two idle control actions share a temporary identity with the observer trace.
    /// Emission is not delivery proof; clock alignment remains an offline validation.
    @MainActor
    final class QueryCostClockAnchor {
        enum State: Equatable {
            case fresh, firstEmitted, secondEmitted, consumed, invalid
        }
        enum Result: Equatable {
            case firstEmitted, secondEmitted, invalid
        }
        enum EventKind: Equatable {
            case anchor, witness
        }
        struct Event {
            let kind: EventKind
            let id: OSSignpostID
            let nonceHi: UInt64
            let nonceLo: UInt64
            let ordinal: UInt64
            let uptimeNanoseconds: UInt64
        }
        private struct Dependencies {
            let isEnabled: () -> Bool
            let makeID: () -> OSSignpostID
            let clock: () -> UInt64
            let emit: (Event) -> Void
        }

        private(set) var state: State = .fresh
        let nonceHi: UInt64
        let nonceLo: UInt64
        private let dependencies: Dependencies
        private var invalidated = false
        private var firstID: OSSignpostID?
        private var secondID: OSSignpostID?
        private var previousUpperBound: UInt64?

        convenience init() {
            let signposter = OSSignposter(
                subsystem: "com.DoubleShy0N.Universe-Keyboard.INT003.ClockAnchor",
                category: .pointsOfInterest)
            self.init(
                nonceHi: UInt64.random(in: UInt64.min...UInt64.max),
                nonceLo: UInt64.random(in: UInt64.min...UInt64.max),
                dependencies: Dependencies(
                    isEnabled: { signposter.isEnabled },
                    makeID: { signposter.makeSignpostID() },
                    clock: { DispatchTime.now().uptimeNanoseconds },
                    emit: { event in
                        switch event.kind {
                        case .anchor:
                            signposter.emitEvent(
                                "TC2ClockAnchor", id: event.id,
                                "nonceHi=\(event.nonceHi, privacy: .public) nonceLo=\(event.nonceLo, privacy: .public) anchorOrdinal=\(event.ordinal, privacy: .public) before=\(event.uptimeNanoseconds, privacy: .public)"
                            )
                        case .witness:
                            signposter.emitEvent(
                                "TC2ClockWitness", id: event.id,
                                "nonceHi=\(event.nonceHi, privacy: .public) nonceLo=\(event.nonceLo, privacy: .public) anchorOrdinal=\(event.ordinal, privacy: .public) after=\(event.uptimeNanoseconds, privacy: .public)"
                            )
                        }
                    }))
        }

        private init(nonceHi: UInt64, nonceLo: UInt64, dependencies: Dependencies) {
            self.nonceHi = nonceHi
            self.nonceLo = nonceLo
            self.dependencies = dependencies
        }

        #if KEYBOARD_QUERY_COST_PROBE_TESTING
            convenience init(
                testingNonceHi: UInt64, nonceLo: UInt64,
                isEnabled: @escaping () -> Bool,
                makeID: @escaping () -> OSSignpostID,
                clock: @escaping () -> UInt64,
                emit: @escaping (Event) -> Void
            ) {
                self.init(
                    nonceHi: testingNonceHi, nonceLo: nonceLo,
                    dependencies: Dependencies(isEnabled: isEnabled, makeID: makeID, clock: clock, emit: emit))
            }
        #endif

        func invalidate() {
            invalidated = true
            state = .invalid
        }

        private func rejectAttempt() -> Result {
            invalidate()
            return .invalid
        }

        @discardableResult
        func emitNext(eligible: Bool) -> Result {
            guard !invalidated else { return .invalid }
            let ordinal: UInt64
            switch state {
            case .fresh: ordinal = 1
            case .firstEmitted: ordinal = 2
            case .secondEmitted, .consumed, .invalid:
                return rejectAttempt()
            }
            // Reserve the opportunity before callbacks; nested requests invalidate it.
            // The separate sticky flag distinguishes cancellation from this reservation.
            state = .invalid
            guard eligible else { return rejectAttempt() }
            let enabled = dependencies.isEnabled()
            guard !invalidated, enabled else { return rejectAttempt() }
            let id = dependencies.makeID()
            guard !invalidated, id != .null, id != .invalid, id != .exclusive, id != firstID else {
                return rejectAttempt()
            }
            let before = dependencies.clock()
            guard !invalidated else { return rejectAttempt() }
            if let previousUpperBound, before <= previousUpperBound { return rejectAttempt() }
            dependencies.emit(
                Event(
                    kind: .anchor, id: id, nonceHi: nonceHi, nonceLo: nonceLo,
                    ordinal: ordinal, uptimeNanoseconds: before))
            guard !invalidated else { return rejectAttempt() }
            let after = dependencies.clock()
            guard !invalidated, after >= before else { return rejectAttempt() }
            dependencies.emit(
                Event(
                    kind: .witness, id: id, nonceHi: nonceHi, nonceLo: nonceLo,
                    ordinal: ordinal, uptimeNanoseconds: after))
            // A witness callback can cancel too: emitted data cannot restore success.
            guard !invalidated else { return rejectAttempt() }
            previousUpperBound = after
            if ordinal == 1 {
                firstID = id
                state = .firstEmitted
                return .firstEmitted
            }
            secondID = id
            state = .secondEmitted
            state = .consumed
            return .secondEmitted
        }
    }
#endif
