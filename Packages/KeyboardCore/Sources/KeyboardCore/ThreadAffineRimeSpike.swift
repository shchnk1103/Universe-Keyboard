import Foundation
import Synchronization

/// Sendable construction recipe transferred to the dedicated owner thread.
///
/// Conforming value types must not store a live non-Sendable engine. The only
/// engine instance is returned when the owner thread invokes this method.
@available(macOS 15.0, *)
public protocol ThreadAffineRimeSpikeEngineFactory: Sendable {
    func makeEngineOnOwnerThread() -> any RimeEngine
}

/// Intentionally narrow P1-3 proof surface.
///
/// Delete, candidate/Path selection, paging and recovery remain R4 production
/// integration work. Exposing them here without the complete R3 binding and
/// lifecycle contract would overstate what this Spike proves.
@available(macOS 15.0, *)
public enum ThreadAffineRimeSpikeWork: Equatable, Sendable {
    case processKey(String)
}

/// P1-3 Spike result delivered from the dedicated RIME owner thread.
///
/// The diagnostic booleans are content-free. They prove only the isolation
/// shape of this Spike; they do not prove real librime compatibility.
@available(macOS 15.0, *)
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

/// MainActor-side version gate for snapshots returned by the P1-3 Spike owner.
///
/// UIKit, marked text, candidates and Path state remain outside this type. A
/// future production integration would apply the accepted value snapshot to
/// those MainActor-owned surfaces as one transaction.
@MainActor
@available(macOS 15.0, *)
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

@available(macOS 15.0, *)
private struct ThreadAffineRimeSpikeEnvelope: Sendable {
    let work: ThreadAffineRimeSpikeWork
    let actionID: String
    let sessionEpoch: UInt64
    let revision: UInt64
}

@available(macOS 15.0, *)
private enum ThreadAffineRimeSpikeCommand: Sendable {
    case work(ThreadAffineRimeSpikeEnvelope)
    case advanceEpoch(UInt64)
    case stop
}

/// Sendable mailbox shared by MainActor producers and one dedicated consumer.
///
/// It contains only Sendable descriptors. The non-Sendable `RimeEngine` is
/// deliberately absent and exists solely as a local variable in the consumer
/// thread closure.
@available(macOS 15.0, *)
private final class ThreadAffineRimeSpikeMailbox: Sendable {
    private struct State: Sendable {
        var commands: [ThreadAffineRimeSpikeCommand] = []
    }

    private let state = Mutex(State())
    private let wakeSignal = DispatchSemaphore(value: 0)
    private let stoppedSignal = DispatchSemaphore(value: 0)

    func enqueue(_ command: ThreadAffineRimeSpikeCommand) -> Int {
        let depth = state.withLock { state in
            state.commands.append(command)
            return state.commands.count
        }
        wakeSignal.signal()
        return depth
    }

    func next() -> ThreadAffineRimeSpikeCommand {
        while true {
            if let command = state.withLock({ state -> ThreadAffineRimeSpikeCommand? in
                guard !state.commands.isEmpty else { return nil }
                return state.commands.removeFirst()
            }) {
                return command
            }
            wakeSignal.wait()
        }
    }

    func signalStopped() {
        stoppedSignal.signal()
    }

    func waitUntilStopped(timeout: DispatchTime) -> Bool {
        stoppedSignal.wait(timeout: timeout) == .success
    }
}

/// Default-off P1-3 proof: a thread-affine, single-consumer RIME owner.
///
/// Safety boundary:
/// - `engineFactory` crosses to the owner as a Sendable factory, but the
///   resulting non-Sendable engine does not. It is created, used and released
///   inside one dedicated `Thread` closure.
/// - MainActor submits only Sendable work descriptors.
/// - The owner returns only immutable Sendable snapshots.
/// - This type is not wired into `KeyboardController`, the Extension, Release
///   defaults or real `RimeEngineImpl`.
@available(macOS 15.0, *)
public final class ThreadAffineRimeSpikeOwner: Sendable {
    public typealias BeforeEngineCall = @Sendable () -> Void
    public typealias ResultHandler = @MainActor @Sendable (ThreadAffineRimeSpikeResult) -> Void

    private struct AcceptanceState: Sendable {
        var sessionEpoch: UInt64 = 1
        var nextRevision: UInt64 = 1
        var stopped = false
    }

    private let acceptanceState = Mutex(AcceptanceState())
    private let mailbox: ThreadAffineRimeSpikeMailbox

    public init<Factory: ThreadAffineRimeSpikeEngineFactory>(
        engineFactory: Factory,
        beforeEngineCall: @escaping BeforeEngineCall = {},
        resultHandler: @escaping ResultHandler
    ) {
        let mailbox = ThreadAffineRimeSpikeMailbox()
        self.mailbox = mailbox

        let thread = Thread {
            Self.runOwnerLoop(
                engineFactory: engineFactory,
                mailbox: mailbox,
                beforeEngineCall: beforeEngineCall,
                resultHandler: resultHandler
            )
            // `runOwnerLoop` owns the engine as a local variable. Reaching this
            // line means that local lifetime has ended on the owner thread.
            mailbox.signalStopped()
        }
        thread.name = "com.universekeyboard.rime.p1-3-spike"
        thread.qualityOfService = .userInteractive
        thread.start()
    }

    /// MainActor hot-path entry. This method only allocates a revision and
    /// submits a Sendable descriptor; it never calls the engine.
    @MainActor
    @discardableResult
    public func accept(
        _ work: ThreadAffineRimeSpikeWork,
        actionID: String
    ) -> ResponsiveRimeAcceptReceipt? {
        let accepted = acceptanceState.withLock {
            state -> (epoch: UInt64, revision: UInt64)? in
            guard !state.stopped else { return nil }
            let accepted = (state.sessionEpoch, state.nextRevision)
            state.nextRevision &+= 1
            return accepted
        }
        guard let accepted else { return nil }

        let depth = mailbox.enqueue(
            .work(
                ThreadAffineRimeSpikeEnvelope(
                    work: work,
                    actionID: actionID,
                    sessionEpoch: accepted.epoch,
                    revision: accepted.revision
                )
            )
        )
        return ResponsiveRimeAcceptReceipt(
            actionID: actionID,
            sessionEpoch: accepted.epoch,
            revision: accepted.revision,
            pendingDepthAfterAccept: depth,
            executedSynchronously: false
        )
    }

    /// Ordered epoch barrier. Old results are rejected by the MainActor gate;
    /// the owner resets its local engine before executing new-epoch work.
    @MainActor
    @discardableResult
    public func advanceSessionEpoch() -> UInt64? {
        let epoch = acceptanceState.withLock { state -> UInt64? in
            guard !state.stopped else { return nil }
            state.sessionEpoch &+= 1
            state.nextRevision = 1
            return state.sessionEpoch
        }
        guard let epoch else { return nil }
        _ = mailbox.enqueue(.advanceEpoch(epoch))
        return epoch
    }

    /// Test/Spike lifecycle endpoint. Production wiring would need an explicit
    /// Extension visibility/process-lifecycle owner before adoption.
    @MainActor
    public func shutdown() {
        let shouldStop = acceptanceState.withLock { state in
            guard !state.stopped else { return false }
            state.stopped = true
            return true
        }
        if shouldStop {
            _ = mailbox.enqueue(.stop)
        }
    }

    /// Bounded test barrier; never intended for the key-input hot path.
    public func waitUntilStopped(timeout: DispatchTime = .now() + 2) -> Bool {
        mailbox.waitUntilStopped(timeout: timeout)
    }

    private static func runOwnerLoop<Factory: ThreadAffineRimeSpikeEngineFactory>(
        engineFactory: Factory,
        mailbox: ThreadAffineRimeSpikeMailbox,
        beforeEngineCall: BeforeEngineCall,
        resultHandler: @escaping ResultHandler
    ) {
        // The live engine is born here and never becomes shared state.
        let engine = engineFactory.makeEngineOnOwnerThread()
        let creationThreadIdentity = ObjectIdentifier(Thread.current)
        let engineCreatedOffMainThread = !Thread.isMainThread
        var ownerEpoch: UInt64 = 1

        while true {
            switch mailbox.next() {
            case .work(let envelope):
                // Work from an invalidated epoch is intentionally not
                // executed against the reset/new owner session.
                guard envelope.sessionEpoch == ownerEpoch else { continue }

                beforeEngineCall()
                let output = execute(envelope.work, engine: engine)
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

                Task { @MainActor in
                    resultHandler(result)
                }

            case .advanceEpoch(let epoch):
                engine.resetSession()
                ownerEpoch = epoch

            case .stop:
                return
            }
        }
    }

    private static func execute(_ work: ThreadAffineRimeSpikeWork, engine: RimeEngine) -> RimeOutput {
        switch work {
        case .processKey(let key):
            return engine.processKey(key)
        }
    }
}
