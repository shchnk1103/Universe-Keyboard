import Foundation

// MARK: - Work items

/// Ordered session work accepted by the responsive pipeline.
///
/// R1 is a **single-threaded** accept/drain state machine for tests and design
/// validation. It is not a production concurrent owner. R2 must place real
/// librime session APIs behind an `actor` or single-consumer serial executor
/// (see ADR 0025 isolation plan). Production `KeyboardController` and
/// `RimeEngineImpl` remain on the synchronous path until a later
/// Product-authorized gate wires a default-off path.
public enum ResponsiveRimeWork: Equatable, Sendable {
    case processKey(String)
    case deleteBackward
    case selectCandidate(pageIndex: Int, boundEpoch: UInt64, boundRevision: UInt64)
    case selectCandidateGlobal(index: Int, boundEpoch: UInt64, boundRevision: UInt64)
    /// Path refine / `replaceInput`. Optional bound epoch/revision fail closed when stale.
    case replaceInput(String, boundEpoch: UInt64?, boundRevision: UInt64?)
    case resetSession
    case recoverSession
    case pageUp
    case pageDown
}

/// Immediate receipt returned when the pipeline accepts work without waiting for RIME.
public struct ResponsiveRimeAcceptReceipt: Equatable, Sendable {
    /// Content-free action identity supplied by the caller (never raw key text).
    public let actionID: String
    public let sessionEpoch: UInt64
    public let revision: UInt64
    public let pendingDepthAfterAccept: Int
    /// Always false for `accept`: RIME is never executed on the accept path.
    public let executedSynchronously: Bool

    public init(
        actionID: String,
        sessionEpoch: UInt64,
        revision: UInt64,
        pendingDepthAfterAccept: Int,
        executedSynchronously: Bool
    ) {
        self.actionID = actionID
        self.sessionEpoch = sessionEpoch
        self.revision = revision
        self.pendingDepthAfterAccept = pendingDepthAfterAccept
        self.executedSynchronously = executedSynchronously
    }
}

/// Atomically publishable UI snapshot derived from one engine generation.
public struct ResponsiveRimeSnapshot: Equatable, Sendable {
    public let sessionEpoch: UInt64
    public let revision: UInt64
    public let actionID: String
    public let output: RimeOutput

    public init(
        sessionEpoch: UInt64,
        revision: UInt64,
        actionID: String,
        output: RimeOutput
    ) {
        self.sessionEpoch = sessionEpoch
        self.revision = revision
        self.actionID = actionID
        self.output = output
    }
}

public enum ResponsiveRimePublishPolicy: Equatable, Sendable {
    /// Publish every successful engine result.
    case everyResult
    /// Publish only the latest settled snapshot under burst input.
    /// Intermediate engine calls still run in order; catch-up publish runs when
    /// the queue drains or when only skipped work remains after applied results.
    case latestOnly
}

public enum ResponsiveRimeSelectionDecision: Equatable, Sendable {
    case accepted
    case rejectedStaleSnapshot
    case rejectedEpochMismatch
}

/// Content-free diagnostics for R1 matrices (fixture ID / counts / timings only).
public struct ResponsiveRimeDiagnostics: Equatable, Sendable {
    public var fixtureID: String
    public var sessionEpoch: UInt64
    public var headRevision: UInt64
    public var lastAppliedRevision: UInt64
    public var lastPublishedRevision: UInt64
    public var pendingDepth: Int
    public var maxPendingDepth: Int
    public var discardedStaleResultCount: Int
    public var discardedStaleSelectionCount: Int
    public var coalescedSkipCount: Int
    public var acceptedActionCount: Int
    public var executedActionCount: Int
    public var publishedSnapshotCount: Int
    /// Cumulative nanoseconds spent inside clock+engine during drain.
    public var engineWaitNanoseconds: UInt64

    public init(fixtureID: String = "T9RESP-FIX-001") {
        self.fixtureID = fixtureID
        self.sessionEpoch = 0
        self.headRevision = 0
        self.lastAppliedRevision = 0
        self.lastPublishedRevision = 0
        self.pendingDepth = 0
        self.maxPendingDepth = 0
        self.discardedStaleResultCount = 0
        self.discardedStaleSelectionCount = 0
        self.coalescedSkipCount = 0
        self.acceptedActionCount = 0
        self.executedActionCount = 0
        self.publishedSnapshotCount = 0
        self.engineWaitNanoseconds = 0
    }
}

/// Injected pre-execution wait used to simulate slow librime without touching
/// production `RimeEngineImpl`.
public protocol ResponsiveRimeExecutionClock: AnyObject {
    func waitBeforeEngineCall()
}

public final class NoopResponsiveRimeClock: ResponsiveRimeExecutionClock {
    public init() {}
    public func waitBeforeEngineCall() {}
}

/// Sleeps a fixed duration before each engine call (test / experiment only).
public final class SleepingResponsiveRimeClock: ResponsiveRimeExecutionClock {
    public let milliseconds: UInt64

    public init(milliseconds: UInt64) {
        self.milliseconds = milliseconds
    }

    public func waitBeforeEngineCall() {
        guard milliseconds > 0 else { return }
        Thread.sleep(forTimeInterval: Double(milliseconds) / 1_000.0)
    }
}

// MARK: - Pipeline

/// Ordered accept → serial execute → versioned publish state machine (R1).
///
/// Threading contract (R1):
/// - Call `accept` / `drain` / `processNext` / `bumpSessionEpoch` from **one**
///   thread only. This type does not enforce isolation.
/// - R2 production must not share an instance across MainActor and a background
///   queue without an actor/serial-executor redesign.
///
/// Revision contract:
/// - `lastAppliedRevision`: highest revision whose engine side-effects ran.
/// - `lastPublishedRevision`: highest revision shown as a UI snapshot.
/// - Selection/Path bindings require both: bound revision is still the applied
///   engine head **and** matches the last published snapshot the user could see.
public final class ResponsiveRimePipeline {
    private struct PendingItem {
        let actionID: String
        let sessionEpoch: UInt64
        let revision: UInt64
        let work: ResponsiveRimeWork
    }

    private enum ExecuteOutcome {
        case skippedStaleBinding
        /// Engine ran; `advancesEpoch` for reset/recover lifecycle work.
        case engineOutput(RimeOutput, advancesEpoch: Bool)
    }

    private let engine: RimeEngine
    private let clock: ResponsiveRimeExecutionClock
    public var publishPolicy: ResponsiveRimePublishPolicy

    private var sessionEpoch: UInt64 = 1
    private var nextRevision: UInt64 = 1
    private var headRevision: UInt64 = 0
    private var lastAppliedRevision: UInt64 = 0
    private var lastPublishedRevision: UInt64 = 0
    private var pending: [PendingItem] = []

    /// Last engine-applied snapshot (may be ahead of `lastPublished` under coalesce).
    public private(set) var lastApplied: ResponsiveRimeSnapshot?
    public private(set) var lastPublished: ResponsiveRimeSnapshot?
    public private(set) var publishedHistory: [ResponsiveRimeSnapshot] = []
    public private(set) var acceptedActionIDs: [String] = []
    public private(set) var executedActionIDs: [String] = []
    public private(set) var diagnostics: ResponsiveRimeDiagnostics

    public init(
        engine: RimeEngine,
        clock: ResponsiveRimeExecutionClock = NoopResponsiveRimeClock(),
        publishPolicy: ResponsiveRimePublishPolicy = .everyResult,
        fixtureID: String = "T9RESP-FIX-001"
    ) {
        self.engine = engine
        self.clock = clock
        self.publishPolicy = publishPolicy
        self.diagnostics = ResponsiveRimeDiagnostics(fixtureID: fixtureID)
        self.diagnostics.sessionEpoch = sessionEpoch
    }

    /// Immediate entry: enqueues ordered work and returns without calling RIME.
    @discardableResult
    public func accept(_ work: ResponsiveRimeWork, actionID: String) -> ResponsiveRimeAcceptReceipt {
        let revision = nextRevision
        nextRevision &+= 1
        headRevision = revision
        let item = PendingItem(
            actionID: actionID,
            sessionEpoch: sessionEpoch,
            revision: revision,
            work: work
        )
        pending.append(item)
        acceptedActionIDs.append(actionID)

        diagnostics.acceptedActionCount = acceptedActionIDs.count
        diagnostics.headRevision = headRevision
        diagnostics.sessionEpoch = sessionEpoch
        diagnostics.pendingDepth = pending.count
        diagnostics.maxPendingDepth = max(diagnostics.maxPendingDepth, pending.count)

        return ResponsiveRimeAcceptReceipt(
            actionID: actionID,
            sessionEpoch: sessionEpoch,
            revision: revision,
            pendingDepthAfterAccept: pending.count,
            executedSynchronously: false
        )
    }

    /// Process up to `limit` pending items serially. `nil` drains the whole queue.
    @discardableResult
    public func drain(limit: Int? = nil) -> Int {
        var processed = 0
        let maxCount = limit ?? Int.max
        while processed < maxCount, processNext() {
            processed += 1
        }
        return processed
    }

    /// Process a single head item. Returns false when the queue is empty.
    @discardableResult
    public func processNext() -> Bool {
        guard !pending.isEmpty else { return false }
        let item = pending.removeFirst()
        diagnostics.pendingDepth = pending.count

        // Late work from a previous epoch.
        guard item.sessionEpoch == sessionEpoch else {
            diagnostics.discardedStaleResultCount += 1
            catchUpPublishIfNeeded()
            return true
        }

        // Fail closed on stale selection/Path binding before paying engine cost.
        if isBindingStale(item.work) {
            diagnostics.discardedStaleSelectionCount += 1
            catchUpPublishIfNeeded()
            return true
        }

        let started = DispatchTime.now().uptimeNanoseconds
        clock.waitBeforeEngineCall()
        let outcome = execute(item.work)
        let elapsed = DispatchTime.now().uptimeNanoseconds &- started
        diagnostics.engineWaitNanoseconds &+= elapsed

        switch outcome {
        case .skippedStaleBinding:
            diagnostics.discardedStaleSelectionCount += 1
            catchUpPublishIfNeeded()
            return true

        case .engineOutput(let output, let advancesEpoch):
            executedActionIDs.append(item.actionID)
            diagnostics.executedActionCount = executedActionIDs.count

            // Lifecycle work advances epoch after the engine call so remaining
            // same-epoch pending items fail closed (epoch mismatch).
            if advancesEpoch {
                let snapshot = ResponsiveRimeSnapshot(
                    sessionEpoch: item.sessionEpoch,
                    revision: item.revision,
                    actionID: item.actionID,
                    output: output
                )
                recordApplied(snapshot)
                publishIfEligible(snapshot)
                advanceEpochAfterLifecycleWork(clearPending: false)
                return true
            }

            let snapshot = ResponsiveRimeSnapshot(
                sessionEpoch: item.sessionEpoch,
                revision: item.revision,
                actionID: item.actionID,
                output: output
            )
            recordApplied(snapshot)
            publishIfEligible(snapshot)
            catchUpPublishIfNeeded()
            return true
        }
    }

    /// Invalidate in-flight work and bump epoch (visibility abandon / external barrier).
    public func bumpSessionEpoch(resetEngineSession: Bool = true) {
        advanceEpochAfterLifecycleWork(clearPending: true)
        if resetEngineSession {
            engine.resetSession()
        }
    }

    /// Fail-closed check for UI actions bound to a published snapshot.
    ///
    /// Requires:
    /// 1. matching `sessionEpoch`
    /// 2. bound revision equals **last published** (user-visible authority)
    /// 3. bound revision equals **last applied** (engine has not moved past it)
    ///
    /// Under `.latestOnly`, if the engine has applied newer keys that were not
    /// yet published, selections bound to the old published revision fail closed.
    public func validateSelection(
        boundEpoch: UInt64,
        boundRevision: UInt64
    ) -> ResponsiveRimeSelectionDecision {
        guard boundEpoch == sessionEpoch else {
            return .rejectedEpochMismatch
        }
        // Engine authority: selection is invalid once newer work has been applied.
        guard lastAppliedRevision == boundRevision else {
            return .rejectedStaleSnapshot
        }
        guard let published = lastPublished,
              published.revision == boundRevision,
              published.sessionEpoch == boundEpoch
        else {
            return .rejectedStaleSnapshot
        }
        return .accepted
    }

    /// Test/helper: attempt to force-publish a snapshot (must respect epoch/revision).
    @discardableResult
    public func tryApplyExternalSnapshot(_ snapshot: ResponsiveRimeSnapshot) -> Bool {
        let before = lastPublishedRevision
        publishIfEligible(snapshot)
        catchUpPublishIfNeeded()
        return lastPublishedRevision != before && lastPublished?.revision == snapshot.revision
    }

    // MARK: - Private

    private func isBindingStale(_ work: ResponsiveRimeWork) -> Bool {
        switch work {
        case .selectCandidate(_, let boundEpoch, let boundRevision),
             .selectCandidateGlobal(_, let boundEpoch, let boundRevision):
            return validateSelection(boundEpoch: boundEpoch, boundRevision: boundRevision) != .accepted
        case .replaceInput(_, let boundEpoch?, let boundRevision?):
            return validateSelection(boundEpoch: boundEpoch, boundRevision: boundRevision) != .accepted
        default:
            return false
        }
    }

    private func execute(_ work: ResponsiveRimeWork) -> ExecuteOutcome {
        switch work {
        case .processKey(let key):
            return .engineOutput(engine.processKey(key), advancesEpoch: false)

        case .deleteBackward:
            return .engineOutput(engine.deleteBackward(), advancesEpoch: false)

        case .selectCandidate(let pageIndex, let boundEpoch, let boundRevision):
            guard validateSelection(boundEpoch: boundEpoch, boundRevision: boundRevision) == .accepted else {
                return .skippedStaleBinding
            }
            return .engineOutput(engine.selectCandidate(at: pageIndex), advancesEpoch: false)

        case .selectCandidateGlobal(let index, let boundEpoch, let boundRevision):
            guard validateSelection(boundEpoch: boundEpoch, boundRevision: boundRevision) == .accepted else {
                return .skippedStaleBinding
            }
            return .engineOutput(engine.selectCandidate(globalIndex: index), advancesEpoch: false)

        case .replaceInput(let input, let boundEpoch, let boundRevision):
            if let boundEpoch, let boundRevision {
                guard validateSelection(boundEpoch: boundEpoch, boundRevision: boundRevision) == .accepted else {
                    return .skippedStaleBinding
                }
            }
            return .engineOutput(engine.replaceInput(input), advancesEpoch: false)

        case .resetSession:
            engine.resetSession()
            return .engineOutput(
                RimeOutput(composition: nil, candidates: [], highlightedIndex: -1),
                advancesEpoch: true
            )

        case .recoverSession:
            engine.recoverSession()
            return .engineOutput(
                RimeOutput(composition: nil, candidates: [], highlightedIndex: -1),
                advancesEpoch: true
            )

        case .pageUp:
            return .engineOutput(engine.pageUp(), advancesEpoch: false)

        case .pageDown:
            return .engineOutput(engine.pageDown(), advancesEpoch: false)
        }
    }

    private func recordApplied(_ snapshot: ResponsiveRimeSnapshot) {
        lastApplied = snapshot
        lastAppliedRevision = snapshot.revision
        diagnostics.lastAppliedRevision = lastAppliedRevision
    }

    private func publishIfEligible(_ snapshot: ResponsiveRimeSnapshot) {
        guard snapshot.sessionEpoch == sessionEpoch else {
            diagnostics.discardedStaleResultCount += 1
            return
        }
        // Never let an older revision overwrite a newer published one.
        if snapshot.revision <= lastPublishedRevision {
            diagnostics.discardedStaleResultCount += 1
            return
        }

        switch publishPolicy {
        case .everyResult:
            commitPublish(snapshot)
        case .latestOnly:
            // Publish when this completion is the current accepted head, or when
            // nothing remains pending (immediate settle for this burst).
            if snapshot.revision == headRevision || pending.isEmpty {
                commitPublish(snapshot)
            } else {
                diagnostics.coalescedSkipCount += 1
            }
        }
    }

    /// If the queue is empty (or only stale work was skipped) and applied has
    /// moved past published, publish the latest applied snapshot.
    private func catchUpPublishIfNeeded() {
        guard pending.isEmpty else { return }
        guard let applied = lastApplied,
              applied.sessionEpoch == sessionEpoch,
              applied.revision > lastPublishedRevision
        else {
            return
        }
        commitPublish(applied)
    }

    private func commitPublish(_ snapshot: ResponsiveRimeSnapshot) {
        guard snapshot.sessionEpoch == sessionEpoch else {
            diagnostics.discardedStaleResultCount += 1
            return
        }
        if snapshot.revision <= lastPublishedRevision {
            diagnostics.discardedStaleResultCount += 1
            return
        }
        lastPublished = snapshot
        lastPublishedRevision = snapshot.revision
        publishedHistory.append(snapshot)
        diagnostics.lastPublishedRevision = lastPublishedRevision
        diagnostics.publishedSnapshotCount = publishedHistory.count
    }

    /// Shared epoch advance for visibility barriers and enqueued reset/recover.
    ///
    /// - `clearPending: true` — external `bumpSessionEpoch` (visibility abandon).
    /// - `clearPending: false` — remaining enqueued items keep their captured
    ///   epoch and fail closed on the epoch guard when drained.
    private func advanceEpochAfterLifecycleWork(clearPending: Bool) {
        sessionEpoch &+= 1
        if clearPending {
            pending.removeAll(keepingCapacity: true)
        }
        nextRevision = 1
        headRevision = 0
        lastAppliedRevision = 0
        lastPublishedRevision = 0
        lastApplied = nil
        lastPublished = nil
        diagnostics.sessionEpoch = sessionEpoch
        diagnostics.headRevision = headRevision
        diagnostics.lastAppliedRevision = lastAppliedRevision
        diagnostics.lastPublishedRevision = lastPublishedRevision
        diagnostics.pendingDepth = pending.count
    }
}
