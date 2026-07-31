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

    public init(maxPendingWorkDepth: Int = 64) {
        precondition(maxPendingWorkDepth > 0, "maxPendingWorkDepth must be positive")
        self.maxPendingWorkDepth = maxPendingWorkDepth
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

    public init(
        pendingWorkDepth: Int = 0,
        rejectedAtBoundCount: Int = 0,
        skippedStaleEpochCount: Int = 0,
        abandonedAtStopCount: Int = 0,
        deliveredCount: Int = 0,
        isDeliveryTerminal: Bool = false
    ) {
        self.pendingWorkDepth = pendingWorkDepth
        self.rejectedAtBoundCount = rejectedAtBoundCount
        self.skippedStaleEpochCount = skippedStaleEpochCount
        self.abandonedAtStopCount = abandonedAtStopCount
        self.deliveredCount = deliveredCount
        self.isDeliveryTerminal = isDeliveryTerminal
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

    public init(
        snapshot: ResponsiveRimeSnapshot,
        engineCreatedOffMainThread: Bool,
        engineCallStayedOnCreationThread: Bool
    ) {
        self.snapshot = snapshot
        self.engineCreatedOffMainThread = engineCreatedOffMainThread
        self.engineCallStayedOnCreationThread = engineCallStayedOnCreationThread
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

private enum ThreadAffineRimeControlCommand: Sendable {
    case advanceEpoch(UInt64)
    case stop
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

    func abandonAllWork() -> Int {
        state.withLock { state in
            let count = state.work.count
            state.work.removeAll(keepingCapacity: false)
            return count
        }
    }

    func signalStopped() {
        stoppedSignal.signal()
    }

    func waitUntilStopped(timeout: DispatchTime) -> Bool {
        stoppedSignal.wait(timeout: timeout) == .success
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
        var rejectedAtBoundCount = 0
        var skippedStaleEpochCount = 0
        var abandonedAtStopCount = 0
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

        let thread = Thread {
            Self.runOwnerLoop(
                bootstrap: engineFactory,
                mailbox: mailbox,
                delivery: delivery,
                counters: counters
            )
            // Local engine lifetime has ended on the owner thread.
            delivery.markOwnerLoopExited()
            mailbox.signalStopped()
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

    /// Hot-path entry (call from keyboard MainActor). Allocates a revision and
    /// enqueues a Sendable descriptor only; never calls the engine. Refuses when
    /// work bound is full.
    @discardableResult
    public func accept(
        _ work: ThreadAffineRimeSpikeWork,
        actionID: String
    ) -> ResponsiveRimeAcceptReceipt? {
        let stopped = counters.withAcceptance { $0.stopped }
        guard !stopped else { return nil }

        if mailbox.pendingWorkDepth >= configuration.maxPendingWorkDepth {
            counters.withAcceptance { $0.rejectedAtBoundCount &+= 1 }
            return nil
        }

        let accepted = counters.withAcceptance {
            state -> (epoch: UInt64, revision: UInt64)? in
            guard !state.stopped else { return nil }
            let accepted = (state.sessionEpoch, state.nextRevision)
            state.nextRevision &+= 1
            return accepted
        }
        guard let accepted else { return nil }

        let envelope = ThreadAffineRimeSpikeEnvelope(
            work: work,
            actionID: actionID,
            sessionEpoch: accepted.epoch,
            revision: accepted.revision
        )
        guard let depth = mailbox.tryEnqueueWork(envelope) else {
            // Fail closed without claiming execution. Roll back the just-issued
            // revision when it is still the head so refuse-at-bound cannot burn
            // monotonic IDs under a depth race.
            counters.withAcceptance { state in
                state.rejectedAtBoundCount &+= 1
                if state.nextRevision == accepted.revision &+ 1 {
                    state.nextRevision = accepted.revision
                }
            }
            return nil
        }

        return ResponsiveRimeAcceptReceipt(
            actionID: actionID,
            sessionEpoch: accepted.epoch,
            revision: accepted.revision,
            pendingDepthAfterAccept: depth,
            executedSynchronously: false
        )
    }

    /// Ordered epoch barrier. Stale work may be purged from the work lane;
    /// the owner resets its local engine before executing new-epoch work.
    @discardableResult
    public func advanceSessionEpoch() -> UInt64? {
        let epoch = counters.withAcceptance { state -> UInt64? in
            guard !state.stopped else { return nil }
            state.sessionEpoch &+= 1
            state.nextRevision = 1
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
            isDeliveryTerminal: delivery.isTerminal
        )
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

    private static func runOwnerLoop<Bootstrap: ThreadAffineRimeEngineBootstrap>(
        bootstrap: Bootstrap,
        mailbox: ThreadAffineRimeSpikeMailbox,
        delivery: ThreadAffineRimeDeliveryChannel,
        counters: SharedCounters
    ) {
        // The live engine is born here and never becomes shared state.
        let engine = bootstrap.makeEngineOnOwnerThread()
        let creationThreadIdentity = ObjectIdentifier(Thread.current)
        let engineCreatedOffMainThread = !Thread.isMainThread
        var ownerEpoch: UInt64 = 1
        var lastAppliedRevision: UInt64 = 0

        while true {
            switch mailbox.next() {
            case .work(let envelope):
                guard envelope.sessionEpoch == ownerEpoch else {
                    counters.withAcceptance { $0.skippedStaleEpochCount &+= 1 }
                    continue
                }

                guard let output = execute(
                    envelope.work,
                    engine: engine,
                    lastAppliedRevision: &lastAppliedRevision
                ) else {
                    counters.withAcceptance { $0.skippedStaleEpochCount &+= 1 }
                    continue
                }
                lastAppliedRevision = envelope.revision
                let result = ThreadAffineRimeSpikeResult(
                    snapshot: ResponsiveRimeSnapshot(
                        sessionEpoch: envelope.sessionEpoch,
                        revision: envelope.revision,
                        actionID: envelope.actionID,
                        output: output
                    ),
                    engineCreatedOffMainThread: engineCreatedOffMainThread,
                    engineCallStayedOnCreationThread:
                        ObjectIdentifier(Thread.current) == creationThreadIdentity
                )
                delivery.enqueue(result)

            case .control(.advanceEpoch(let epoch)):
                engine.resetSession()
                ownerEpoch = epoch
                lastAppliedRevision = 0
                let purged = mailbox.purgeWork(notMatchingEpoch: epoch)
                if purged > 0 {
                    counters.withAcceptance { $0.skippedStaleEpochCount &+= purged }
                }

            case .control(.stop):
                // Control priority: stop is not buried behind work. Remaining
                // work is abandoned as lifecycle teardown, not live-input drop.
                let abandoned = mailbox.abandonAllWork()
                if abandoned > 0 {
                    counters.withAcceptance { $0.abandonedAtStopCount &+= abandoned }
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
