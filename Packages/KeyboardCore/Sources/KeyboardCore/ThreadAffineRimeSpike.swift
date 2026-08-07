import Foundation
import Synchronization

// MARK: - R4-Owner bootstrap (D1)

/// Sendable construction recipe transferred to the dedicated owner thread.
///
/// R4-Owner freezes this as a **bootstrap**: conforming values must carry only
/// configuration / recipe data. They must not store a live non-Sendable engine.
/// The only engine instance is returned when the owner thread invokes this method.
public protocol ThreadAffineRimeEngineBootstrap: Sendable {
    func makeEngineOnOwnerThread() -> any RimeEngine
}

/// Spike-era name retained as a typealias so existing tests keep compiling.
public typealias ThreadAffineRimeSpikeEngineFactory = ThreadAffineRimeEngineBootstrap

/// Tunables for the thread-affine owner (R4-Owner D3).
///
/// `maxPendingWorkDepth` is a testable bound, not a Product-locked jetsam SLO.
public struct ThreadAffineRimeOwnerConfiguration: Sendable, Equatable {
    public var maxPendingWorkDepth: Int
    /// Lifecycle-only owner construction timeout. It is never used while
    /// accepting a key; a timeout must produce an explicit not-ready result.
    public var ownerReadyTimeoutNanoseconds: UInt64

    public init(
        maxPendingWorkDepth: Int = 64,
        ownerReadyTimeoutNanoseconds: UInt64 = 2_000_000_000
    ) {
        precondition(maxPendingWorkDepth > 0, "maxPendingWorkDepth must be positive")
        precondition(
            ownerReadyTimeoutNanoseconds > 0,
            "ownerReadyTimeoutNanoseconds must be positive"
        )
        self.maxPendingWorkDepth = maxPendingWorkDepth
        self.ownerReadyTimeoutNanoseconds = ownerReadyTimeoutNanoseconds
    }

    public static let `default` = ThreadAffineRimeOwnerConfiguration()
}

/// Content-free owner diagnostics (R4-Owner).
public struct ThreadAffineRimeOwnerDiagnostics: Sendable, Equatable {
    public var pendingWorkDepth: Int
    public var rejectedAtBoundCount: Int
    public var skippedStaleEpochCount: Int
    public var abandonedAtStopCount: Int
    public var deliveredCount: Int
    public var isDeliveryTerminal: Bool
    /// Live acceptance epoch (bumped on visibility abandon / advanceSessionEpoch).
    public var sessionEpoch: UInt64
    /// Native session identity captured on the owner thread.
    ///
    /// This is diagnostic-only value data. MainActor callers must never reach
    /// across isolation to the live RIME engine to obtain it.
    public var diagnosticSessionSnapshot: RimeSessionDiagnosticSnapshot?
    /// Immutable realized runtime selection captured on the owner thread.
    public var runtimeSelection: RimeRuntimeSelection?

    public init(
        pendingWorkDepth: Int = 0,
        rejectedAtBoundCount: Int = 0,
        skippedStaleEpochCount: Int = 0,
        abandonedAtStopCount: Int = 0,
        deliveredCount: Int = 0,
        isDeliveryTerminal: Bool = false,
        sessionEpoch: UInt64 = 1,
        diagnosticSessionSnapshot: RimeSessionDiagnosticSnapshot? = nil,
        runtimeSelection: RimeRuntimeSelection? = nil
    ) {
        self.pendingWorkDepth = pendingWorkDepth
        self.rejectedAtBoundCount = rejectedAtBoundCount
        self.skippedStaleEpochCount = skippedStaleEpochCount
        self.abandonedAtStopCount = abandonedAtStopCount
        self.deliveredCount = deliveredCount
        self.isDeliveryTerminal = isDeliveryTerminal
        self.sessionEpoch = sessionEpoch
        self.diagnosticSessionSnapshot = diagnosticSessionSnapshot
        self.runtimeSelection = runtimeSelection
    }
}

/// Immutable fence issued for an explicit active-canary kill.
///
/// The fence closes acceptance before exposing `acceptedThroughRevision`, so a
/// caller can drain precisely the work that was already accepted. Visibility
/// teardown deliberately does not use this type: ADR 0002 permits its distinct
/// abandonment terminal.
public struct ThreadAffineRimeActiveKillFence: Sendable, Equatable {
    public let sessionEpoch: UInt64
    public let acceptedThroughRevision: UInt64

    public init(sessionEpoch: UInt64, acceptedThroughRevision: UInt64) {
        self.sessionEpoch = sessionEpoch
        self.acceptedThroughRevision = acceptedThroughRevision
    }
}

/// Positive-only shutdown evidence for an explicit active-canary kill.
///
/// A false member is not a partial success: callers must retain the owner and
/// remain fenced. In particular, timeout never grants baseline takeover.
public struct ThreadAffineRimeOwnerShutdownResult: Sendable, Equatable {
    public let acceptedThrough: ThreadAffineRimeActiveKillFence
    public let acceptedBacklogDrained: Bool
    public let ownerDestroyed: Bool
    public let mailboxTerminal: Bool
    public let deliveryDrained: Bool

    public init(
        acceptedThrough: ThreadAffineRimeActiveKillFence,
        acceptedBacklogDrained: Bool,
        ownerDestroyed: Bool,
        mailboxTerminal: Bool,
        deliveryDrained: Bool
    ) {
        self.acceptedThrough = acceptedThrough
        self.acceptedBacklogDrained = acceptedBacklogDrained
        self.ownerDestroyed = ownerDestroyed
        self.mailboxTerminal = mailboxTerminal
        self.deliveryDrained = deliveryDrained
    }

    public var isPositive: Bool {
        acceptedBacklogDrained && ownerDestroyed && mailboxTerminal && deliveryDrained
    }
}

/// Content-free terminal assigned to work accepted before visibility teardown.
///
/// A visibility boundary may abandon queued work under ADR 0002, but it must
/// preserve one auditable terminal for every accepted revision it abandons.
public enum ThreadAffineRimeAcceptedRevisionTerminal: String, Sendable, Equatable {
    case abandonedVisibility
}

/// One content-free terminal receipt for an accepted, unexecuted revision.
///
/// The receipt intentionally contains routing identity only. It never carries
/// the queued key, composition, candidates, or a `RimeOutput` snapshot.
public struct ThreadAffineRimeVisibilityAbandonmentReceipt: Sendable, Equatable {
    public let sessionEpoch: UInt64
    public let revision: UInt64
    public let actionID: String
    public let terminal: ThreadAffineRimeAcceptedRevisionTerminal

    public init(
        sessionEpoch: UInt64,
        revision: UInt64,
        actionID: String,
        terminal: ThreadAffineRimeAcceptedRevisionTerminal = .abandonedVisibility
    ) {
        self.sessionEpoch = sessionEpoch
        self.revision = revision
        self.actionID = actionID
        self.terminal = terminal
    }
}

/// Visibility-teardown evidence exposed by the coordinator.
///
/// `abandonedReceipts` is deliberately per revision rather than an aggregate
/// count. A non-positive result retains the owner so a caller cannot treat a
/// timeout as completed visibility destruction.
public struct ThreadAffineRimeVisibilityTeardownResult: Sendable, Equatable {
    public let abandonedReceipts: [ThreadAffineRimeVisibilityAbandonmentReceipt]
    public let ownerDestroyed: Bool
    public let mailboxTerminal: Bool
    public let deliveryDrained: Bool

    public init(
        abandonedReceipts: [ThreadAffineRimeVisibilityAbandonmentReceipt],
        ownerDestroyed: Bool,
        mailboxTerminal: Bool,
        deliveryDrained: Bool
    ) {
        self.abandonedReceipts = abandonedReceipts
        self.ownerDestroyed = ownerDestroyed
        self.mailboxTerminal = mailboxTerminal
        self.deliveryDrained = deliveryDrained
    }

    public var isPositive: Bool {
        ownerDestroyed && mailboxTerminal && deliveryDrained
    }
}

/// R4-Wire: full session work surface (same enum as the responsive pipeline).
///
/// Spike/R4-Owner historically only exercised `processKey`. R4-Wire expands the
/// owner to the complete `ResponsiveRimeWork` set so controller bridging cannot
/// dual-enter a MainActor-held engine.
public typealias ThreadAffineRimeSpikeWork = ResponsiveRimeWork

/// Result delivered from the dedicated RIME owner thread.
///
/// The diagnostic booleans are content-free. They prove only the isolation
/// shape; they do not prove real librime compatibility.
public struct ThreadAffineRimeSpikeResult: Equatable, Sendable {
    public let snapshot: ResponsiveRimeSnapshot
    public let engineCreatedOffMainThread: Bool
    public let engineCallStayedOnCreationThread: Bool
    /// Content-free backlog depth sampled when this revision completed.
    /// MainActor presentation may run after the owner has already drained more
    /// work, so it must not reconstruct this historical fact from live state.
    public let pendingWorkDepthAfterCompletion: Int
    /// Native session identity captured on the owner thread for this result.
    public let diagnosticSessionSnapshot: RimeSessionDiagnosticSnapshot?
    public let runtimeSelection: RimeRuntimeSelection?

    public init(
        snapshot: ResponsiveRimeSnapshot,
        engineCreatedOffMainThread: Bool,
        engineCallStayedOnCreationThread: Bool,
        pendingWorkDepthAfterCompletion: Int = 0,
        diagnosticSessionSnapshot: RimeSessionDiagnosticSnapshot? = nil,
        runtimeSelection: RimeRuntimeSelection? = nil
    ) {
        self.snapshot = snapshot
        self.engineCreatedOffMainThread = engineCreatedOffMainThread
        self.engineCallStayedOnCreationThread = engineCallStayedOnCreationThread
        self.pendingWorkDepthAfterCompletion = pendingWorkDepthAfterCompletion
        self.diagnosticSessionSnapshot = diagnosticSessionSnapshot
        self.runtimeSelection = runtimeSelection
    }
}

/// MainActor-side version gate for snapshots returned by the owner.
///
/// UIKit, marked text, candidates and Path state remain outside this type. A
/// future production integration would apply the accepted value snapshot to
/// those MainActor-owned surfaces as one transaction.
@MainActor
public final class ThreadAffineRimeSpikeApplyGate {
    public private(set) var sessionEpoch: UInt64
    public private(set) var lastAppliedRevision: UInt64 = 0
    public private(set) var discardedResultCount: Int = 0
    public private(set) var appliedSnapshots: [ResponsiveRimeSnapshot] = []

    public init(sessionEpoch: UInt64 = 1) {
        self.sessionEpoch = sessionEpoch
    }

    /// Move presentation authority to a new session epoch immediately.
    ///
    /// Results already executing on the owner thread may still arrive, but
    /// `apply(_:)` rejects them before any UI/marked-text mutation.
    public func advanceSessionEpoch(to epoch: UInt64) {
        guard epoch > sessionEpoch else { return }
        sessionEpoch = epoch
        lastAppliedRevision = 0
        appliedSnapshots.removeAll(keepingCapacity: true)
    }

    @discardableResult
    public func apply(_ result: ThreadAffineRimeSpikeResult) -> Bool {
        let snapshot = result.snapshot
        guard snapshot.sessionEpoch == sessionEpoch,
              snapshot.revision > lastAppliedRevision
        else {
            discardedResultCount += 1
            return false
        }

        lastAppliedRevision = snapshot.revision
        appliedSnapshots.append(snapshot)
        return true
    }
}

// MARK: - Internal envelopes

private struct ThreadAffineRimeSpikeEnvelope: Sendable {
    let work: ThreadAffineRimeSpikeWork
    let actionID: String
    let sessionEpoch: UInt64
    let revision: UInt64
}

/// Sync reply for owner-thread read-only candidate window queries.
///
/// Read path must not advance session revision or publish a composition snapshot.
private final class ThreadAffineCandidateWindowReply: Sendable {
    private struct State: Sendable {
        var window: RimeCandidateWindow?
        var fulfilled = false
    }

    private let state = Mutex(State())
    private let signal = DispatchSemaphore(value: 0)

    func fulfill(_ window: RimeCandidateWindow) {
        state.withLock {
            $0.window = window
            $0.fulfilled = true
        }
        signal.signal()
    }

    func wait(timeout: DispatchTime) -> RimeCandidateWindow? {
        if let ready = state.withLock({ $0.fulfilled ? $0.window : nil }) {
            return ready
        }
        _ = signal.wait(timeout: timeout)
        return state.withLock { $0.window }
    }
}

private enum ThreadAffineRimeControlCommand: Sendable {
    case advanceEpoch(UInt64)
    case stop
    /// Read-only; does not mutate composition or revision.
    case candidateWindow(from: Int, limit: Int, reply: ThreadAffineCandidateWindowReply)
}

private enum ThreadAffineRimeOwnerCommand: Sendable {
    case work(ThreadAffineRimeSpikeEnvelope)
    case control(ThreadAffineRimeControlCommand)
}

// MARK: - Dual-lane mailbox (D3)

/// Sendable dual-lane mailbox: control priority + bounded work FIFO.
///
/// Contains only Sendable descriptors. The non-Sendable `RimeEngine` is
/// deliberately absent and exists solely as a local variable in the consumer
/// thread closure.
private final class ThreadAffineRimeSpikeMailbox: Sendable {
    private struct State: Sendable {
        var work: [ThreadAffineRimeSpikeEnvelope] = []
        var control: [ThreadAffineRimeControlCommand] = []
        var isTerminal = false
    }

    private let state = Mutex(State())
    private let wakeSignal = DispatchSemaphore(value: 0)
    private let stoppedSignal = DispatchSemaphore(value: 0)
    private let maxPendingWorkDepth: Int

    init(maxPendingWorkDepth: Int) {
        self.maxPendingWorkDepth = maxPendingWorkDepth
    }

    var pendingWorkDepth: Int {
        state.withLock { $0.work.count }
    }

    /// Enqueue process-key work. Returns new work depth, or `nil` when at bound.
    func tryEnqueueWork(_ envelope: ThreadAffineRimeSpikeEnvelope) -> Int? {
        let depth = state.withLock { state -> Int? in
            guard state.work.count < maxPendingWorkDepth else { return nil }
            state.work.append(envelope)
            return state.work.count
        }
        if depth != nil {
            wakeSignal.signal()
        }
        return depth
    }

    func enqueueControl(_ command: ThreadAffineRimeControlCommand) {
        state.withLock { $0.control.append(command) }
        wakeSignal.signal()
    }

    /// Prefer control lane, then work lane.
    func next() -> ThreadAffineRimeOwnerCommand {
        while true {
            if let command = state.withLock({ state -> ThreadAffineRimeOwnerCommand? in
                if !state.control.isEmpty {
                    return .control(state.control.removeFirst())
                }
                if !state.work.isEmpty {
                    return .work(state.work.removeFirst())
                }
                return nil
            }) {
                return command
            }
            wakeSignal.wait()
        }
    }

    /// Drop queued work for epochs other than `currentEpoch` (stale barrier).
    func purgeWork(notMatchingEpoch currentEpoch: UInt64) -> Int {
        state.withLock { state in
            let before = state.work.count
            state.work.removeAll { $0.sessionEpoch != currentEpoch }
            return before - state.work.count
        }
    }

    /// Removes and returns every unexecuted FIFO envelope. Callers are
    /// responsible for recording the terminal for each returned revision.
    func abandonAllWork() -> [ThreadAffineRimeSpikeEnvelope] {
        state.withLock { state in
            let abandoned = state.work
            state.work.removeAll(keepingCapacity: false)
            return abandoned
        }
    }

    func signalStopped() {
        let shouldSignal = state.withLock { state -> Bool in
            guard !state.isTerminal else { return false }
            state.isTerminal = true
            return true
        }
        if shouldSignal {
            stoppedSignal.signal()
        }
    }

    func waitUntilStopped(timeout: DispatchTime) -> Bool {
        if state.withLock({ $0.isTerminal }) {
            return true
        }
        return stoppedSignal.wait(timeout: timeout) == .success
    }
}

// MARK: - Ordered delivery channel (D2)

/// Ordered delivery on the **owner thread** (FIFO with the owner loop).
///
/// Handlers run synchronously when results are produced so `lastPublished` /
/// waiters update without requiring a MainActor pump (avoids R4-Wire P1 deadlock
/// when MainActor `performOrderedNow` waits for delivery). UI hops (if any) are
/// the handler's responsibility (e.g. NotificationCenter main queue).
private final class ThreadAffineRimeDeliveryChannel: Sendable {
    typealias Handler = @Sendable (ThreadAffineRimeSpikeResult) -> Void

    private struct State: Sendable {
        var terminal = false
        var deliveredCount = 0
    }

    private let state = Mutex(State())
    private let drainedSignal = DispatchSemaphore(value: 0)
    private let handler: Handler

    init(handler: @escaping Handler) {
        self.handler = handler
    }

    var deliveredCount: Int {
        state.withLock { $0.deliveredCount }
    }

    var isTerminal: Bool {
        state.withLock { $0.terminal }
    }

    func enqueue(_ result: ThreadAffineRimeSpikeResult) {
        // Synchronous on owner thread: preserves FIFO and unblocks waiters.
        handler(result)
        state.withLock { $0.deliveredCount &+= 1 }
    }

    /// Owner loop finished (engine local lifetime has ended).
    func markOwnerLoopExited() {
        let shouldSignal = state.withLock { state -> Bool in
            if state.terminal { return false }
            state.terminal = true
            return true
        }
        if shouldSignal {
            drainedSignal.signal()
        }
    }

    func waitUntilDrained(timeout: DispatchTime) -> Bool {
        if state.withLock({ $0.terminal }) {
            return true
        }
        return drainedSignal.wait(timeout: timeout) == .success
    }
}

/// Owner destruction is distinct from mailbox and delivery terminals. The
/// owner thread marks it only after `runOwnerLoop` has returned, so the local
/// non-Sendable engine is no longer reachable on that thread.
private final class ThreadAffineRimeOwnerDestructionSignal: Sendable {
    private let state = Mutex(false)
    private let signal = DispatchSemaphore(value: 0)

    func markDestroyed() {
        let shouldSignal = state.withLock { destroyed -> Bool in
            guard !destroyed else { return false }
            destroyed = true
            return true
        }
        if shouldSignal {
            signal.signal()
        }
    }

    func wait(timeout: DispatchTime) -> Bool {
        if state.withLock({ $0 }) {
            return true
        }
        return signal.wait(timeout: timeout) == .success
    }
}

// MARK: - Owner

/// Thread-affine, single-consumer RIME owner (Spike-P1-3 + R4-Owner contract).
///
/// Safety boundary:
/// - Bootstrap crosses as a Sendable recipe; the resulting non-Sendable engine
///   is created, used and released inside one dedicated `Thread` closure.
/// - MainActor submits only Sendable work descriptors.
/// - Results re-enter MainActor only through one ordered delivery channel.
/// - Work mailbox is bounded (refuse-at-bound); control lane is priority.
/// - Not wired into `KeyboardController`, the Extension, Release defaults or
///   real `RimeEngineImpl` production paths.
public final class ThreadAffineRimeSpikeOwner: Sendable {
    public typealias ResultHandler = @Sendable (ThreadAffineRimeSpikeResult) -> Void

    private struct AcceptanceState: Sendable {
        var sessionEpoch: UInt64 = 1
        var nextRevision: UInt64 = 1
        var stopped = false
        var activeKillFence: ThreadAffineRimeActiveKillFence?
        var lastSettledRevision: UInt64 = 0
        var rejectedAtBoundCount = 0
        var skippedStaleEpochCount = 0
        var abandonedAtStopCount = 0
        var visibilityAbandonmentReceipts: [ThreadAffineRimeVisibilityAbandonmentReceipt] = []
        var diagnosticSessionSnapshot: RimeSessionDiagnosticSnapshot?
        var runtimeSelection: RimeRuntimeSelection?
    }

    /// Owner-loop counters shared without moving a noncopyable Mutex parameter.
    private final class SharedCounters: Sendable {
        private let state = Mutex(AcceptanceState())

        func withAcceptance<T>(_ body: (inout AcceptanceState) -> T) -> T {
            state.withLock { state in
                body(&state)
            }
        }
    }

    private let counters = SharedCounters()
    private let mailbox: ThreadAffineRimeSpikeMailbox
    private let delivery: ThreadAffineRimeDeliveryChannel
    private let configuration: ThreadAffineRimeOwnerConfiguration
    private let readySignal = DispatchSemaphore(value: 0)
    private let settledSignal = DispatchSemaphore(value: 0)
    private let destructionSignal = ThreadAffineRimeOwnerDestructionSignal()

    public init<Bootstrap: ThreadAffineRimeEngineBootstrap>(
        engineFactory: Bootstrap,
        configuration: ThreadAffineRimeOwnerConfiguration = .default,
        resultHandler: @escaping ResultHandler
    ) {
        self.configuration = configuration
        let mailbox = ThreadAffineRimeSpikeMailbox(
            maxPendingWorkDepth: configuration.maxPendingWorkDepth
        )
        let delivery = ThreadAffineRimeDeliveryChannel(handler: resultHandler)
        self.mailbox = mailbox
        self.delivery = delivery
        let counters = self.counters
        let readySignal = self.readySignal
        let settledSignal = self.settledSignal
        let destructionSignal = self.destructionSignal

        let thread = Thread {
            Self.runOwnerLoop(
                bootstrap: engineFactory,
                mailbox: mailbox,
                delivery: delivery,
                counters: counters,
                readySignal: readySignal,
                settledSignal: settledSignal
            )
            // Local engine lifetime has ended on the owner thread.
            destructionSignal.markDestroyed()
            mailbox.signalStopped()
            delivery.markOwnerLoopExited()
        }
        thread.name = "com.universekeyboard.rime.thread-affine-owner"
        // userInitiated (not userInteractive): owner often blocks on librime /
        // semaphores that run at Default QoS; UI-class QoS caused Thread
        // Performance Checker priority-inversion warnings under R4-B.
        thread.qualityOfService = QualityOfService.userInitiated
        thread.start()
    }

    /// R4-Owner preferred entry: config-only bootstrap naming.
    public convenience init<Bootstrap: ThreadAffineRimeEngineBootstrap>(
        bootstrap: Bootstrap,
        configuration: ThreadAffineRimeOwnerConfiguration = .default,
        resultHandler: @escaping ResultHandler
    ) {
        self.init(
            engineFactory: bootstrap,
            configuration: configuration,
            resultHandler: resultHandler
        )
    }

    deinit {
        // Explicit lifecycle shutdown remains required for a future Extension
        // integration. This non-blocking fallback prevents a forgotten handle
        // from orphaning its thread and thread-local engine forever.
        requestStop()
    }

    /// Read-only candidate window on the owner thread after mutations are drained.
    /// Does not allocate a revision or publish a composition snapshot.
    public func candidateWindow(
        from globalIndex: Int,
        limit: Int,
        timeout: DispatchTime = .now() + 5
    ) -> RimeCandidateWindow {
        let reply = ThreadAffineCandidateWindowReply()
        mailbox.enqueueControl(
            .candidateWindow(from: globalIndex, limit: limit, reply: reply)
        )
        return reply.wait(timeout: timeout)
            ?? RimeCandidateWindow(
                candidates: [],
                startIndex: max(0, globalIndex),
                nextIndex: max(0, globalIndex),
                hasMoreCandidates: false
            )
    }

    /// Hot-path entry (call from keyboard MainActor). Allocates a revision and
    /// enqueues a Sendable descriptor only; never calls the engine. Refuses when
    /// work bound is full.
    @discardableResult
    public func accept(
        _ work: ThreadAffineRimeSpikeWork,
        actionID: String
    ) -> ResponsiveRimeAcceptReceipt? {
        let accepted = counters.withAcceptance {
            state -> (epoch: UInt64, revision: UInt64, depth: Int)? in
            guard !state.stopped, state.activeKillFence == nil else { return nil }

            let revision = state.nextRevision
            let envelope = ThreadAffineRimeSpikeEnvelope(
                work: work,
                actionID: actionID,
                sessionEpoch: state.sessionEpoch,
                revision: revision
            )
            guard let depth = mailbox.tryEnqueueWork(envelope) else {
                state.rejectedAtBoundCount &+= 1
                return nil
            }
            state.nextRevision &+= 1
            return (state.sessionEpoch, revision, depth)
        }
        guard let accepted else { return nil }

        return ResponsiveRimeAcceptReceipt(
            actionID: actionID,
            sessionEpoch: accepted.epoch,
            revision: accepted.revision,
            pendingDepthAfterAccept: accepted.depth,
            executedSynchronously: false
        )
    }

    /// Fences new acceptance for an explicit kill while preserving every
    /// envelope already accepted before this call. The caller must subsequently
    /// use `drainAcceptedBacklogAndShutdown` rather than `shutdown()`.
    @discardableResult
    public func issueActiveKillFence() -> ThreadAffineRimeActiveKillFence? {
        counters.withAcceptance { state in
            guard !state.stopped, state.activeKillFence == nil else { return nil }
            let fence = ThreadAffineRimeActiveKillFence(
                sessionEpoch: state.sessionEpoch,
                acceptedThroughRevision: state.nextRevision &- 1
            )
            state.activeKillFence = fence
            return fence
        }
    }

    /// Drains the exact accepted prefix captured by an active-kill fence, then
    /// requests owner termination. A timeout leaves the owner intact and
    /// fenced; callers receive a non-positive result and must not take over the
    /// baseline session.
    public func drainAcceptedBacklogAndShutdown(
        after fence: ThreadAffineRimeActiveKillFence,
        timeout: DispatchTime
    ) -> ThreadAffineRimeOwnerShutdownResult {
        let ownsFence = counters.withAcceptance { state in
            state.activeKillFence == fence
        }
        guard ownsFence else {
            return ThreadAffineRimeOwnerShutdownResult(
                acceptedThrough: fence,
                acceptedBacklogDrained: false,
                ownerDestroyed: false,
                mailboxTerminal: false,
                deliveryDrained: false
            )
        }

        let acceptedBacklogDrained = waitUntilSettled(through: fence, timeout: timeout)
        guard acceptedBacklogDrained else {
            return ThreadAffineRimeOwnerShutdownResult(
                acceptedThrough: fence,
                acceptedBacklogDrained: false,
                ownerDestroyed: false,
                mailboxTerminal: false,
                deliveryDrained: false
            )
        }

        requestStop()
        let ownerDestroyed = destructionSignal.wait(timeout: timeout)
        let mailboxTerminal = mailbox.waitUntilStopped(timeout: timeout)
        let deliveryDrained = delivery.waitUntilDrained(timeout: timeout)
        return ThreadAffineRimeOwnerShutdownResult(
            acceptedThrough: fence,
            acceptedBacklogDrained: true,
            ownerDestroyed: ownerDestroyed,
            mailboxTerminal: mailboxTerminal,
            deliveryDrained: deliveryDrained
        )
    }

    /// Stops for a visibility lifecycle boundary and returns a content-free
    /// terminal for every accepted revision still queued when stop wins the
    /// control lane. This is intentionally separate from active kill, whose
    /// contract drains accepted work before requesting the same stop command.
    public func abandonForVisibilityAndShutdown(
        timeout: DispatchTime
    ) -> ThreadAffineRimeVisibilityTeardownResult {
        requestStop()
        let ownerDestroyed = destructionSignal.wait(timeout: timeout)
        let mailboxTerminal = mailbox.waitUntilStopped(timeout: timeout)
        let deliveryDrained = delivery.waitUntilDrained(timeout: timeout)
        let abandonedReceipts = counters.withAcceptance {
            $0.visibilityAbandonmentReceipts
        }
        return ThreadAffineRimeVisibilityTeardownResult(
            abandonedReceipts: abandonedReceipts,
            ownerDestroyed: ownerDestroyed,
            mailboxTerminal: mailboxTerminal,
            deliveryDrained: deliveryDrained
        )
    }

    /// Ordered epoch barrier. Stale work may be purged from the work lane;
    /// the owner resets its local engine before executing new-epoch work.
    @discardableResult
    public func advanceSessionEpoch() -> UInt64? {
        let epoch = counters.withAcceptance { state -> UInt64? in
            guard !state.stopped, state.activeKillFence == nil else { return nil }
            state.sessionEpoch &+= 1
            state.nextRevision = 1
            // Settled revisions are meaningful only within one epoch. Carrying
            // the prior high-water mark forward could let active kill mistake
            // new-epoch work for an already drained accepted prefix.
            state.lastSettledRevision = 0
            return state.sessionEpoch
        }
        guard let epoch else { return nil }
        let purged = mailbox.purgeWork(notMatchingEpoch: epoch)
        if purged > 0 {
            counters.withAcceptance { $0.skippedStaleEpochCount &+= purged }
        }
        mailbox.enqueueControl(.advanceEpoch(epoch))
        return epoch
    }

    /// Explicit lifecycle endpoint. Production wiring still needs Extension
    /// visibility/process ownership; deinit is only a safety net.
    public func shutdown() {
        requestStop()
    }

    public func diagnostics() -> ThreadAffineRimeOwnerDiagnostics {
        let snapshot = counters.withAcceptance { $0 }
        return ThreadAffineRimeOwnerDiagnostics(
            pendingWorkDepth: mailbox.pendingWorkDepth,
            rejectedAtBoundCount: snapshot.rejectedAtBoundCount,
            skippedStaleEpochCount: snapshot.skippedStaleEpochCount,
            abandonedAtStopCount: snapshot.abandonedAtStopCount,
            deliveredCount: delivery.deliveredCount,
            isDeliveryTerminal: delivery.isTerminal,
            sessionEpoch: snapshot.sessionEpoch,
            diagnosticSessionSnapshot: snapshot.diagnosticSessionSnapshot,
            runtimeSelection: snapshot.runtimeSelection
        )
    }

    /// Waits for owner-thread engine construction. This is a lifecycle barrier,
    /// never a key-input operation; it lets the first diagnostic key carry the
    /// native session snapshot without touching the engine from MainActor.
    @discardableResult
    public func waitUntilReady(timeout: DispatchTime = .now() + 2) -> Bool {
        readySignal.wait(timeout: timeout) == .success
    }

    private func requestStop() {
        let shouldStop = counters.withAcceptance { state in
            guard !state.stopped else { return false }
            state.stopped = true
            return true
        }
        if shouldStop {
            mailbox.enqueueControl(.stop)
        }
    }

    /// Bounded test barrier; never intended for the key-input hot path.
    public func waitUntilStopped(timeout: DispatchTime = .now() + 2) -> Bool {
        mailbox.waitUntilStopped(timeout: timeout)
    }

    /// Wait until ordered delivery reports terminal (owner exited + queue empty).
    public func waitUntilDeliveryDrained(timeout: DispatchTime = .now() + 2) -> Bool {
        delivery.waitUntilDrained(timeout: timeout)
    }

    private func waitUntilSettled(
        through fence: ThreadAffineRimeActiveKillFence,
        timeout: DispatchTime
    ) -> Bool {
        while DispatchTime.now() < timeout {
            let settled = counters.withAcceptance { state in
                state.sessionEpoch == fence.sessionEpoch
                    && state.lastSettledRevision >= fence.acceptedThroughRevision
            }
            if settled { return true }
            _ = settledSignal.wait(timeout: .now() + .milliseconds(1))
        }
        return counters.withAcceptance { state in
            state.sessionEpoch == fence.sessionEpoch
                && state.lastSettledRevision >= fence.acceptedThroughRevision
        }
    }

    private static func markSettled(
        _ envelope: ThreadAffineRimeSpikeEnvelope,
        counters: SharedCounters,
        settledSignal: DispatchSemaphore
    ) {
        counters.withAcceptance { state in
            guard state.sessionEpoch == envelope.sessionEpoch else { return }
            state.lastSettledRevision = max(state.lastSettledRevision, envelope.revision)
        }
        settledSignal.signal()
    }

    private static func runOwnerLoop<Bootstrap: ThreadAffineRimeEngineBootstrap>(
        bootstrap: Bootstrap,
        mailbox: ThreadAffineRimeSpikeMailbox,
        delivery: ThreadAffineRimeDeliveryChannel,
        counters: SharedCounters,
        readySignal: DispatchSemaphore,
        settledSignal: DispatchSemaphore
    ) {
        // The live engine is born here and never becomes shared state.
        let engine = bootstrap.makeEngineOnOwnerThread()
        let creationThreadIdentity = ObjectIdentifier(Thread.current)
        let engineCreatedOffMainThread = !Thread.isMainThread
        var ownerEpoch: UInt64 = 1
        var lastAppliedRevision: UInt64 = 0
        counters.withAcceptance {
            $0.diagnosticSessionSnapshot = engine.diagnosticSessionSnapshot
            $0.runtimeSelection = engine.runtimeSelection
        }
        readySignal.signal()

        while true {
            switch mailbox.next() {
            case .work(let envelope):
                guard envelope.sessionEpoch == ownerEpoch else {
                    counters.withAcceptance { $0.skippedStaleEpochCount &+= 1 }
                    markSettled(envelope, counters: counters, settledSignal: settledSignal)
                    continue
                }

                guard let output = execute(
                    envelope.work,
                    engine: engine,
                    lastAppliedRevision: &lastAppliedRevision
                ) else {
                    counters.withAcceptance { $0.skippedStaleEpochCount &+= 1 }
                    markSettled(envelope, counters: counters, settledSignal: settledSignal)
                    continue
                }
                lastAppliedRevision = envelope.revision
                let diagnosticSessionSnapshot = engine.diagnosticSessionSnapshot
                counters.withAcceptance {
                    $0.diagnosticSessionSnapshot = diagnosticSessionSnapshot
                    $0.runtimeSelection = engine.runtimeSelection
                }
                let result = ThreadAffineRimeSpikeResult(
                    snapshot: ResponsiveRimeSnapshot(
                        sessionEpoch: envelope.sessionEpoch,
                        revision: envelope.revision,
                        actionID: envelope.actionID,
                        output: output
                    ),
                    engineCreatedOffMainThread: engineCreatedOffMainThread,
                    engineCallStayedOnCreationThread:
                        ObjectIdentifier(Thread.current) == creationThreadIdentity,
                    pendingWorkDepthAfterCompletion: mailbox.pendingWorkDepth,
                    diagnosticSessionSnapshot: diagnosticSessionSnapshot,
                    runtimeSelection: engine.runtimeSelection
                )
                delivery.enqueue(result)
                markSettled(envelope, counters: counters, settledSignal: settledSignal)

            case .control(.advanceEpoch(let epoch)):
                engine.resetSession()
                counters.withAcceptance {
                    $0.diagnosticSessionSnapshot = engine.diagnosticSessionSnapshot
                    $0.runtimeSelection = engine.runtimeSelection
                }
                ownerEpoch = epoch
                lastAppliedRevision = 0
                let purged = mailbox.purgeWork(notMatchingEpoch: epoch)
                if purged > 0 {
                    counters.withAcceptance { $0.skippedStaleEpochCount &+= purged }
                }

            case .control(.candidateWindow(let from, let limit, let reply)):
                // Read-only: no revision bump, no snapshot delivery.
                reply.fulfill(engine.candidateWindow(from: from, limit: limit))

            case .control(.stop):
                // Control priority: stop is not buried behind work. Remaining
                // work receives one content-free visibility terminal rather
                // than disappearing behind an aggregate abandonment count.
                let abandoned = mailbox.abandonAllWork()
                if !abandoned.isEmpty {
                    for envelope in abandoned {
                        counters.withAcceptance { state in
                            state.abandonedAtStopCount &+= 1
                            state.visibilityAbandonmentReceipts.append(
                                ThreadAffineRimeVisibilityAbandonmentReceipt(
                                    sessionEpoch: envelope.sessionEpoch,
                                    revision: envelope.revision,
                                    actionID: envelope.actionID
                                )
                            )
                            guard state.sessionEpoch == envelope.sessionEpoch else { return }
                            state.lastSettledRevision = max(
                                state.lastSettledRevision,
                                envelope.revision
                            )
                        }
                        settledSignal.signal()
                    }
                }
                return
            }
        }
    }

    private static func execute(
        _ work: ThreadAffineRimeSpikeWork,
        engine: RimeEngine,
        lastAppliedRevision: inout UInt64
    ) -> RimeOutput? {
        switch work {
        case .processKey(let key):
            return engine.processKey(key)

        case .deleteBackward:
            return engine.deleteBackward()

        case .selectCandidate(let pageIndex, _, let boundRevision):
            guard boundRevision == lastAppliedRevision else { return nil }
            return engine.selectCandidate(at: pageIndex)

        case .selectCandidateGlobal(let index, _, let boundRevision):
            guard boundRevision == lastAppliedRevision else { return nil }
            return engine.selectCandidate(globalIndex: index)

        case .replaceInput(let input, _, let boundRevision):
            if let boundRevision {
                guard boundRevision == lastAppliedRevision else { return nil }
            }
            return engine.replaceInput(input)

        case .resetSession:
            engine.resetSession()
            lastAppliedRevision = 0
            return RimeOutput(composition: nil, candidates: [], highlightedIndex: -1)

        case .recoverSession:
            engine.recoverSession()
            lastAppliedRevision = 0
            return RimeOutput(composition: nil, candidates: [], highlightedIndex: -1)

        case .pageUp:
            return engine.pageUp()

        case .pageDown:
            return engine.pageDown()
        }
    }
}
