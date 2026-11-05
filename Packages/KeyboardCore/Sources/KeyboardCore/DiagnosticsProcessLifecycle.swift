import Synchronization

public enum DiagnosticsAppendDrainOutcome: Sendable, Equatable {
    /// 已关闭新的 append 登记，且关闭时已登记的调用都已返回。
    /// 这只覆盖诊断日志 append，不表示其它 writer 锁已结束。
    case drained
    /// 保护取消或不可用。不得把该结果当成排空成功。
    case cancelledNotDrained
}

internal protocol DiagnosticsLifecycleMember: AnyObject, Sendable {
    func applyProcessLifecycle(active: Bool, generation: UInt64)
    func closeAppendAdmission()
    func drainAppends(
        cancellation: @escaping @Sendable () -> Bool
    ) async -> DiagnosticsAppendDrainOutcome
}

extension DiagnosticsLifecycleMember {
    func closeAppendAdmission() {}

    func drainAppends(
        cancellation: @escaping @Sendable () -> Bool
    ) async -> DiagnosticsAppendDrainOutcome {
        _ = cancellation()
        return .drained
    }
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

    public var isProcessActive: Bool {
        state.withLock { $0.isActive }
    }

    /// 与 `setActive(false)` 分开：调用方在同一同步段里先关活动标记，再关 append 登记。
    public func closeAppendAdmission() {
        let members = state.withLock { state -> [any DiagnosticsLifecycleMember] in
            state.members.removeAll { $0.runtime == nil }
            return state.members.compactMap(\.runtime)
        }
        for member in members {
            member.closeAppendAdmission()
        }
    }

    /// 关闭新的 append 登记并等待已登记调用返回。取消时返回 `.cancelledNotDrained`。
    public func suspendAndDrain(
        cancellation: @escaping @Sendable () -> Bool
    ) async -> DiagnosticsAppendDrainOutcome {
        closeAppendAdmission()
        return await waitForAppendDrain(cancellation: cancellation)
    }

    public func waitForAppendDrain(
        cancellation: @escaping @Sendable () -> Bool
    ) async -> DiagnosticsAppendDrainOutcome {
        let members = state.withLock { state -> [any DiagnosticsLifecycleMember] in
            state.members.removeAll { $0.runtime == nil }
            return state.members.compactMap(\.runtime)
        }
        var sawCancellation = cancellation()
        for member in members {
            let outcome = await member.drainAppends(cancellation: cancellation)
            if outcome == .cancelledNotDrained {
                sawCancellation = true
            }
        }
        if cancellation() { sawCancellation = true }
        return sawCancellation ? .cancelledNotDrained : .drained
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
