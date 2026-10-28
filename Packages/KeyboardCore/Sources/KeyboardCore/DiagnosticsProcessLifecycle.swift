import Synchronization

internal protocol DiagnosticsLifecycleMember: AnyObject, Sendable {
    func applyProcessLifecycle(active: Bool, generation: UInt64)
}

extension DiagnosticsJournalRuntime: DiagnosticsLifecycleMember {}

/// Coordinates only typed journal runtimes in this process. Members are called after unlocking.
public final class DiagnosticsProcessLifecycle: Sendable {
    private struct Member: Sendable {
        weak var runtime: (any DiagnosticsLifecycleMember)?
    }

    private struct State: Sendable {
        var isActive = false
        var generation: UInt64 = 0
        var members: [Member] = []
    }

    private let state = Mutex(State())

    public init() {}

    #if DEBUG
        internal func testingSetGeneration(_ generation: UInt64) {
            state.withLock { $0.generation = generation }
        }
    #endif

    public func register(_ runtime: DiagnosticsJournalRuntime) {
        registerMember(runtime)
    }

    internal func registerMember(_ runtime: any DiagnosticsLifecycleMember) {
        let snapshot = state.withLock { state in
            state.members.removeAll { $0.runtime == nil }
            state.members.append(Member(runtime: runtime))
            return (state.isActive, state.generation)
        }
        runtime.applyProcessLifecycle(active: snapshot.0, generation: snapshot.1)
    }

    public func setActive(_ active: Bool) {
        let update = state.withLock { state -> (Bool, UInt64, [any DiagnosticsLifecycleMember])? in
            guard state.generation < UInt64.max, state.isActive != active else { return nil }
            state.generation += 1
            // The last generation is reserved for a permanent closed state.
            state.isActive = state.generation == UInt64.max ? false : active
            state.members.removeAll { $0.runtime == nil }
            return (state.isActive, state.generation, state.members.compactMap(\.runtime))
        }
        guard let (active, generation, members) = update else { return }
        for member in members {
            member.applyProcessLifecycle(active: active, generation: generation)
        }
    }
}
