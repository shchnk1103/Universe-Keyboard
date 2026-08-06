import Foundation
import Synchronization

// MARK: - Notifications

extension Notification.Name {
    /// Content-free: `object` is `ThreadAffineRimePublishedSnapshot`.
    static let threadAffineRimeSnapshotPublished = Notification.Name(
        "com.universekeyboard.threadAffineRimeSnapshotPublished"
    )
}

/// Immutable delivery envelope. The canary session instance prevents a late
/// notification from an old owner being mistaken for a new owner's same-numbered
/// epoch/revision after a visibility cycle.
public struct ThreadAffineRimePublishedSnapshot: Sendable {
    public let snapshot: ResponsiveRimeSnapshot
    public let canarySessionInstance: UInt64
    public let pendingWorkDepthAfterCompletion: Int

    public init(
        snapshot: ResponsiveRimeSnapshot,
        canarySessionInstance: UInt64,
        pendingWorkDepthAfterCompletion: Int = 0
    ) {
        self.snapshot = snapshot
        self.canarySessionInstance = canarySessionInstance
        self.pendingWorkDepthAfterCompletion = pendingWorkDepthAfterCompletion
    }
}

// MARK: - Type-erased bootstrap

/// Sendable type eraser for controller-held thread-affine bootstraps.
public struct AnyThreadAffineRimeEngineBootstrap: ThreadAffineRimeEngineBootstrap {
    private let _make: @Sendable () -> any RimeEngine

    public init<B: ThreadAffineRimeEngineBootstrap>(_ base: B) {
        _make = { base.makeEngineOnOwnerThread() }
    }

    public init(makeEngineOnOwnerThread: @escaping @Sendable () -> any RimeEngine) {
        _make = makeEngineOnOwnerThread
    }

    public func makeEngineOnOwnerThread() -> any RimeEngine {
        _make()
    }
}

// MARK: - Sendable delivery sink

private final class ThreadAffineDeliverySink: Sendable {
    struct PresentationIdentity: Hashable, Sendable {
        let canarySessionInstance: UInt64
        let sessionEpoch: UInt64
        let revision: UInt64
    }

    private struct State: Sendable {
        var lastPublished: ResponsiveRimeSnapshot?
        var completedPublishCount: Int = 0
        var publishSuppressed: Bool = false
        /// Revisions that have been delivered (exact-match wait).
        var deliveredRevisions: Set<UInt64> = []
        #if T9_RESPONSIVE_CANARY_INTERNAL
        var canarySessionInstance: UInt64 = 0
        var pendingPresentation: Set<PresentationIdentity> = []
        #endif
    }

    private let state = Mutex(State())

    func handle(_ result: ThreadAffineRimeSpikeResult) {
        let snapshot = result.snapshot
        let delivery = state.withLock { state -> (suppressed: Bool, sessionInstance: UInt64) in
            state.lastPublished = snapshot
            state.completedPublishCount &+= 1
            state.deliveredRevisions.insert(snapshot.revision)
            let suppressed = state.publishSuppressed
            #if T9_RESPONSIVE_CANARY_INTERNAL
            if !suppressed {
                state.pendingPresentation.insert(
                    PresentationIdentity(
                        canarySessionInstance: state.canarySessionInstance,
                        sessionEpoch: snapshot.sessionEpoch,
                        revision: snapshot.revision
                    )
                )
            }
            return (suppressed, state.canarySessionInstance)
            #else
            return (suppressed, 0)
            #endif
        }
        if !delivery.suppressed {
            #if T9_RESPONSIVE_CANARY_INTERNAL
            NotificationCenter.default.post(
                name: .threadAffineRimeSnapshotPublished,
                object: ThreadAffineRimePublishedSnapshot(
                    snapshot: snapshot,
                    canarySessionInstance: delivery.sessionInstance,
                    pendingWorkDepthAfterCompletion:
                        result.pendingWorkDepthAfterCompletion
                )
            )
            #else
            NotificationCenter.default.post(
                name: .threadAffineRimeSnapshotPublished,
                object: ThreadAffineRimePublishedSnapshot(
                    snapshot: snapshot,
                    canarySessionInstance: 0,
                    pendingWorkDepthAfterCompletion:
                        result.pendingWorkDepthAfterCompletion
                )
            )
            #endif
        }
    }

    func lastPublished() -> ResponsiveRimeSnapshot? {
        state.withLock { $0.lastPublished }
    }

    func completedPublishCount() -> Int {
        state.withLock { $0.completedPublishCount }
    }

    func setPublishSuppressed(_ value: Bool) {
        state.withLock { $0.publishSuppressed = value }
    }

    func clearLastPublished() {
        state.withLock {
            $0.lastPublished = nil
            $0.deliveredRevisions.removeAll(keepingCapacity: true)
        }
    }

    #if T9_RESPONSIVE_CANARY_INTERNAL
    func setCanarySessionInstance(_ value: UInt64) {
        state.withLock { $0.canarySessionInstance = value }
    }

    func pendingPresentationIdentities() -> [PresentationIdentity] {
        state.withLock { Array($0.pendingPresentation) }
    }

    func acknowledgePresentation(
        canarySessionInstance: UInt64,
        sessionEpoch: UInt64,
        revision: UInt64
    ) {
        _ = state.withLock {
            $0.pendingPresentation.remove(
                PresentationIdentity(
                    canarySessionInstance: canarySessionInstance,
                    sessionEpoch: sessionEpoch,
                    revision: revision
                )
            )
        }
    }
    #endif

    func waitForRevision(_ revision: UInt64, timeout: DispatchTime) -> ResponsiveRimeSnapshot? {
        while DispatchTime.now() < timeout {
            let hit = state.withLock { state -> ResponsiveRimeSnapshot? in
                guard state.deliveredRevisions.contains(revision) else { return nil }
                // Prefer exact revision snapshot when it is still the latest;
                // otherwise return latest (caller primarily needs completion).
                if let published = state.lastPublished, published.revision == revision {
                    return published
                }
                return state.lastPublished
            }
            if let hit { return hit }
            Thread.sleep(forTimeInterval: 0.001)
        }
        return lastPublished()
    }
}

// MARK: - MainActor publish router

/// Routes owner-thread snapshot notifications to MainActor handlers without
/// capturing non-Sendable coordinator instances inside `@Sendable` Notification
/// closures (Swift 6 / CI `warnings-as-errors`).
@MainActor
private enum ThreadAffinePublishRouter {
    private static var handlers:
        [ObjectIdentifier: (ThreadAffineRimePublishedSnapshot) -> Void] = [:]

    static func setHandler(
        _ id: ObjectIdentifier,
        _ handler: ((ThreadAffineRimePublishedSnapshot) -> Void)?
    ) {
        if let handler {
            handlers[id] = handler
        } else {
            handlers.removeValue(forKey: id)
        }
    }

    static func deliver(_ id: ObjectIdentifier, publication: ThreadAffineRimePublishedSnapshot) {
        handlers[id]?(publication)
    }
}

// MARK: - Coordinator

/// R4-Wire coordinator: schedule on MainActor, execute on thread-affine owner.
///
/// Call only from the keyboard MainActor. Snapshot publish is delivered via
/// `Notification.Name.threadAffineRimeSnapshotPublished` (and optional handler).
public final class ThreadAffineRimeSessionCoordinator {
    public typealias PublishHandler = (ResponsiveRimeSnapshot?) -> Void
    public typealias PublicationHandler = (ThreadAffineRimePublishedSnapshot) -> Void
    #if T9_RESPONSIVE_CANARY_INTERNAL
    public typealias CanaryPublishHandler = (ThreadAffineRimePublishedSnapshot) -> Void
    #endif

    private let bootstrap: AnyThreadAffineRimeEngineBootstrap
    private let configuration: ThreadAffineRimeOwnerConfiguration
    private let sink = ThreadAffineDeliverySink()
    private var owner: ThreadAffineRimeSpikeOwner?
    private var actionSequence: UInt64 = 0
    private var publishHandler: PublishHandler?
    private var publicationHandler: PublicationHandler?
    private var observer: NSObjectProtocol?
    private(set) var ownerReady = false
    /// Non-nil only after an explicit active-canary kill fenced new acceptance.
    /// A timeout deliberately retains this fence and the owner reference.
    private var activeKillFence: ThreadAffineRimeActiveKillFence?
    /// Lifecycle epoch owned by the coordinator, not by one replaceable owner.
    ///
    /// Visibility teardown destroys the dedicated owner thread. Keeping this
    /// watermark outside the owner prevents a newly created owner (whose local
    /// counter starts at 1) from accepting a late snapshot from the previous
    /// lifecycle as if it belonged to the new session.
    private var lifecycleEpoch: UInt64 = 1
    /// Retained token whose `ObjectIdentifier` is Sendable and stable for routing.
    private let routerToken = NSObject()
    public private(set) var lastAcceptReceipt: ResponsiveRimeAcceptReceipt?
    public private(set) var lastScheduledActionID: String?
    public let fixtureID: String

    public init(
        bootstrap: AnyThreadAffineRimeEngineBootstrap,
        configuration: ThreadAffineRimeOwnerConfiguration = .default,
        fixtureID: String = "T9RESP-R4W"
    ) {
        self.bootstrap = bootstrap
        self.configuration = configuration
        self.fixtureID = fixtureID
        // Capture only Sendable values in the @Sendable notification body.
        let routeID = ObjectIdentifier(routerToken)
        observer = NotificationCenter.default.addObserver(
            forName: .threadAffineRimeSnapshotPublished,
            object: nil,
            // Keep owner delivery non-blocking. The handler below performs the
            // sole MainActor hop; targeting `.main` here would synchronously
            // deadlock an active-kill drain that is waiting on the MainActor.
            queue: nil
        ) { note in
            let publication: ThreadAffineRimePublishedSnapshot
            if let wrapped = note.object as? ThreadAffineRimePublishedSnapshot {
                publication = wrapped
            } else if let snapshot = note.object as? ResponsiveRimeSnapshot {
                // Compatibility for focused tests and the ordinary build.
                publication = ThreadAffineRimePublishedSnapshot(
                    snapshot: snapshot,
                    canarySessionInstance: 0
                )
            } else {
                return
            }
            Task { @MainActor in
                ThreadAffinePublishRouter.deliver(routeID, publication: publication)
            }
        }
        startOwner()
    }

    deinit {
        if let observer {
            NotificationCenter.default.removeObserver(observer)
        }
        owner?.shutdown()
        let routeID = ObjectIdentifier(routerToken)
        Task { @MainActor in
            ThreadAffinePublishRouter.setHandler(routeID, nil)
        }
    }

    public var lastPublished: ResponsiveRimeSnapshot? { sink.lastPublished() }
    public var completedPublishCount: Int { sink.completedPublishCount() }
    public var diagnostics: ThreadAffineRimeOwnerDiagnostics {
        guard let owner else {
            // The owner is intentionally absent during visibility teardown.
            // Keep the coordinator-owned epoch visible in that gap so a late
            // snapshot from the stopped owner cannot pass the MainActor gate
            // before the replacement owner is ready.
            return ThreadAffineRimeOwnerDiagnostics(sessionEpoch: lifecycleEpoch)
        }

        var diagnostics = owner.diagnostics()
        // The owner normally catches up in `startOwner()`. The max also makes
        // the read safe if a lifecycle callback observes the replacement
        // thread between construction and its epoch replay.
        diagnostics.sessionEpoch = max(diagnostics.sessionEpoch, lifecycleEpoch)
        return diagnostics
    }

    /// Native session identity captured by the owner thread. This is a value
    /// snapshot; the MainActor never reaches into the live engine.
    public var diagnosticSessionSnapshot: RimeSessionDiagnosticSnapshot? {
        owner?.diagnostics().diagnosticSessionSnapshot
    }

    public var runtimeSelection: RimeRuntimeSelection? {
        owner?.diagnostics().runtimeSelection
    }

    /// Lifecycle readiness captured after owner-thread engine construction.
    /// This is not a key-path wait and is deliberately separate from the
    /// native session snapshot, which may be unavailable for a fake engine.
    public var isOwnerReady: Bool { ownerReady }

    public var hasPendingWork: Bool {
        (owner?.diagnostics().pendingWorkDepth ?? 0) > 0
    }

    #if T9_RESPONSIVE_CANARY_INTERNAL
    public var pendingPresentationIdentities: [(
        canarySessionInstance: UInt64,
        sessionEpoch: UInt64,
        revision: UInt64
    )] {
        sink.pendingPresentationIdentities().map {
            (
                canarySessionInstance: $0.canarySessionInstance,
                sessionEpoch: $0.sessionEpoch,
                revision: $0.revision
            )
        }
    }

    public func setCanarySessionInstance(_ value: UInt64) {
        sink.setCanarySessionInstance(value)
    }

    public func acknowledgePresentationTerminal(
        canarySessionInstance: UInt64,
        sessionEpoch: UInt64,
        revision: UInt64
    ) {
        sink.acknowledgePresentation(
            canarySessionInstance: canarySessionInstance,
            sessionEpoch: sessionEpoch,
            revision: revision
        )
    }
    #endif

    /// Install UI publish sink. Call from the keyboard MainActor only
    /// (`KeyboardController.rebuildResponsiveRimeCoordinatorIfNeeded`).
    @MainActor
    public func setPublishHandler(_ handler: PublishHandler?) {
        publishHandler = handler
        let routeID = ObjectIdentifier(routerToken)
        if let handler {
            ThreadAffinePublishRouter.setHandler(routeID) { publication in
                handler(publication.snapshot)
            }
        } else {
            ThreadAffinePublishRouter.setHandler(routeID, nil)
        }
    }

    /// Full immutable publication used by production-shaped controller wiring.
    /// The legacy snapshot-only adapter above remains available to older tests.
    @MainActor
    public func setPublicationHandler(_ handler: PublicationHandler?) {
        publicationHandler = handler
        let routeID = ObjectIdentifier(routerToken)
        ThreadAffinePublishRouter.setHandler(routeID, handler)
    }

    #if T9_RESPONSIVE_CANARY_INTERNAL
    /// Canary-only handler preserves the complete delivery identity.
    @MainActor
    public func setCanaryPublishHandler(_ handler: CanaryPublishHandler?) {
        let routeID = ObjectIdentifier(routerToken)
        ThreadAffinePublishRouter.setHandler(routeID, handler)
    }
    #endif

    public func scheduleProcessKey(_ key: String) {
        actionSequence &+= 1
        let actionID = "pk-\(actionSequence)"
        lastScheduledActionID = actionID
        lastAcceptReceipt = owner?.accept(.processKey(key), actionID: actionID)
    }

    /// Starts an explicit active-canary kill. The returned fence rejects all
    /// later acceptance while preserving the FIFO backlog already accepted.
    @discardableResult
    public func issueActiveKillFence() -> ThreadAffineRimeActiveKillFence? {
        guard activeKillFence == nil, let fence = owner?.issueActiveKillFence() else {
            return nil
        }
        activeKillFence = fence
        return fence
    }

    /// Finishes an active kill only when the owner reports all positive
    /// terminals. On timeout or any incomplete terminal, the coordinator keeps
    /// both the owner reference and fence so a caller cannot infer safe baseline
    /// takeover from absence of a local pointer.
    @discardableResult
    public func drainActiveKillAndShutdown(
        after fence: ThreadAffineRimeActiveKillFence,
        timeout: DispatchTime = .now() + 2
    ) -> ThreadAffineRimeOwnerShutdownResult? {
        guard activeKillFence == fence, let owner else { return nil }
        let result = owner.drainAcceptedBacklogAndShutdown(after: fence, timeout: timeout)
        guard result.isPositive else { return result }

        self.owner = nil
        ownerReady = false
        activeKillFence = nil
        return result
    }

    @discardableResult
    public func performOrderedNow(_ work: ResponsiveRimeWork) -> ResponsiveRimeSnapshot? {
        actionSequence &+= 1
        let actionID = "ord-\(actionSequence)"
        guard let receipt = owner?.accept(work, actionID: actionID) else {
            return nil
        }
        lastAcceptReceipt = receipt
        return sink.waitForRevision(receipt.revision, timeout: .now() + 5)
    }

    public func flushPending() {
        let deadline = DispatchTime.now() + 5
        while DispatchTime.now() < deadline {
            if (owner?.diagnostics().pendingWorkDepth ?? 0) == 0 { break }
            Thread.sleep(forTimeInterval: 0.002)
        }
    }

    public func bumpSessionEpoch(resetEngineSession: Bool = true) {
        _ = resetEngineSession
        if let epoch = owner?.advanceSessionEpoch() {
            lifecycleEpoch = max(lifecycleEpoch, epoch)
        } else {
            lifecycleEpoch &+= 1
        }
        sink.clearLastPublished()
    }

    public func validateSelection(
        boundEpoch: UInt64,
        boundRevision: UInt64
    ) -> ResponsiveRimeSelectionDecision {
        guard let published = sink.lastPublished() else {
            return .rejectedStaleSnapshot
        }
        if published.sessionEpoch != boundEpoch {
            return .rejectedEpochMismatch
        }
        if published.revision != boundRevision {
            return .rejectedStaleSnapshot
        }
        return .accepted
    }

    public func withPublishHandlerSuppressed<T>(_ body: () -> T) -> T {
        sink.setPublishSuppressed(true)
        defer { sink.setPublishSuppressed(false) }
        return body()
    }

    /// Stops immediately for a visibility boundary and exposes one terminal
    /// receipt per accepted revision that had not yet executed. This does not
    /// use the explicit active-kill drain path: ADR 0002 permits visibility to
    /// abandon queued work after recording those terminals.
    @discardableResult
    public func suspendForVisibilityChange(
        timeout: DispatchTime = .now() + 2
    ) -> ThreadAffineRimeVisibilityTeardownResult? {
        // Visibility keeps its existing ADR 0002 abandonment semantics. It is
        // intentionally distinct from explicit kill's FIFO drain API above.
        guard let owner else { return nil }
        let result = owner.abandonForVisibilityAndShutdown(timeout: timeout)
        guard result.isPositive else { return result }

        self.owner = nil
        ownerReady = false
        activeKillFence = nil
        return result
    }

    public func resumeAfterVisibilityChange() {
        if owner == nil {
            startOwner()
        }
    }

    public func shutdown() {
        owner?.shutdown()
        _ = owner?.waitUntilStopped(timeout: .now() + 2)
        _ = owner?.waitUntilDeliveryDrained(timeout: .now() + 2)
        owner = nil
        ownerReady = false
        activeKillFence = nil
    }

    private func startOwner() {
        let sink = self.sink
        let newOwner = ThreadAffineRimeSpikeOwner(
            bootstrap: bootstrap,
            configuration: configuration,
            resultHandler: { result in
                sink.handle(result)
            }
        )
        owner = newOwner
        // Owner construction is a lifecycle boundary. Waiting here ensures the
        // first key's diagnostic sample can read a native session snapshot while
        // keeping all engine access on the owner thread.
        let timeoutNanoseconds = min(
            configuration.ownerReadyTimeoutNanoseconds,
            UInt64(Int.max)
        )
        ownerReady = newOwner.waitUntilReady(
            timeout: .now() + .nanoseconds(Int(timeoutNanoseconds))
        )

        // A fresh owner starts its local epoch at 1. Replay the coordinator's
        // lifecycle barrier before accepting new work so queued notifications
        // from the previous owner cannot pass the MainActor epoch check.
        if lifecycleEpoch > 1 {
            for _ in 1..<lifecycleEpoch {
                _ = newOwner.advanceSessionEpoch()
            }
        }
    }
}

// MARK: - Bridge

/// `RimeEngine` facade for thread-affine mode: all mutations enter the owner.
/// Call only from the keyboard MainActor (same expectation as
/// `ResponsiveRimeEngineBridge`).
public final class ThreadAffineRimeEngineBridge: RimeEngine {
    private let coordinator: ThreadAffineRimeSessionCoordinator
    #if T9_RESPONSIVE_CANARY_INTERNAL
    private let chromeEngineHint: RimeEngine?
    #else
    public let chromeEngineHint: RimeEngine?
    #endif

    #if T9_RESPONSIVE_CANARY_INTERNAL
    public init(coordinator: ThreadAffineRimeSessionCoordinator) {
        self.coordinator = coordinator
        self.chromeEngineHint = nil
    }
    #else
    public init(
        coordinator: ThreadAffineRimeSessionCoordinator,
        chromeEngineHint: RimeEngine? = nil
    ) {
        self.coordinator = coordinator
        self.chromeEngineHint = chromeEngineHint
    }
    #endif

    public var runtimeSelection: RimeRuntimeSelection? {
        coordinator.runtimeSelection
    }

    public var diagnosticSessionSnapshot: RimeSessionDiagnosticSnapshot? {
        #if T9_RESPONSIVE_CANARY_INTERNAL
        return coordinator.diagnosticSessionSnapshot
        #else
        return coordinator.diagnosticSessionSnapshot ?? chromeEngineHint?.diagnosticSessionSnapshot
        #endif
    }

    /// Content-free lifecycle state for the explicit preflight readiness marker.
    public var isOwnerReady: Bool { coordinator.isOwnerReady }

    #if T9_RESPONSIVE_CANARY_INTERNAL
    public var onRuntimeSelectionChanged: ((RimeRuntimeSelection) -> Void)? {
        get { nil }
        set { _ = newValue }
    }
    #else
    public var onRuntimeSelectionChanged: ((RimeRuntimeSelection) -> Void)? {
        get { chromeEngineHint?.onRuntimeSelectionChanged }
        set { chromeEngineHint?.onRuntimeSelectionChanged = newValue }
    }
    #endif

    public func processKey(_ key: String) -> RimeOutput {
        output(from: coordinator.performOrderedNow(.processKey(key)))
    }

    public func selectCandidate(at index: Int) -> RimeOutput {
        coordinator.flushPending()
        let bound = bindingIdentity()
        return output(
            from: coordinator.performOrderedNow(
                .selectCandidate(
                    pageIndex: index,
                    boundEpoch: bound.epoch,
                    boundRevision: bound.revision
                )
            )
        )
    }

    public func selectCandidate(globalIndex index: Int) -> RimeOutput {
        coordinator.flushPending()
        let bound = bindingIdentity()
        return output(
            from: coordinator.performOrderedNow(
                .selectCandidateGlobal(
                    index: index,
                    boundEpoch: bound.epoch,
                    boundRevision: bound.revision
                )
            )
        )
    }

    public func candidateWindow(from globalIndex: Int, limit: Int) -> RimeCandidateWindow {
        coordinator.flushPending()
        #if !T9_RESPONSIVE_CANARY_INTERNAL
        if let chromeEngineHint {
            return chromeEngineHint.candidateWindow(from: globalIndex, limit: limit)
        }
        #endif
        let candidates = coordinator.lastPublished?.output.candidates ?? []
        let slice = Array(candidates.dropFirst(globalIndex).prefix(limit))
        let next = globalIndex + slice.count
        return RimeCandidateWindow(
            candidates: slice,
            startIndex: globalIndex,
            nextIndex: next,
            hasMoreCandidates: candidates.count > next
        )
    }

    public func deleteBackward() -> RimeOutput {
        // Match MainActor bridge: drain deferred processKey before Delete so
        // binding-sensitive follow-on work and host spelling stay aligned.
        coordinator.flushPending()
        return output(from: coordinator.performOrderedNow(.deleteBackward))
    }

    public func replaceInput(_ input: String) -> RimeOutput {
        // RESPONSIVE-DELETE-ANOMALY-001: capture publish binding only after
        // draining deferred keys (see ResponsiveRimeEngineBridge.replaceInput).
        coordinator.flushPending()
        if let published = coordinator.lastPublished {
            return output(
                from: coordinator.performOrderedNow(
                    .replaceInput(
                        input,
                        boundEpoch: published.sessionEpoch,
                        boundRevision: published.revision
                    )
                )
            )
        }
        return output(
            from: coordinator.performOrderedNow(
                .replaceInput(input, boundEpoch: nil, boundRevision: nil)
            )
        )
    }

    public func resetSession() {
        _ = coordinator.performOrderedNow(.resetSession)
    }

    public func recoverSession() {
        _ = coordinator.performOrderedNow(.recoverSession)
    }

    public func suspendForVisibilityChange() {
        coordinator.suspendForVisibilityChange()
    }

    public func resumeAfterVisibilityChange() {
        coordinator.resumeAfterVisibilityChange()
    }

    public func isComposing() -> Bool {
        coordinator.hasPendingWork
            || coordinator.lastPublished?.output.composition != nil
            || !(coordinator.lastPublished?.output.rawInput ?? "").isEmpty
    }

    public func pageUp() -> RimeOutput {
        output(from: coordinator.performOrderedNow(.pageUp))
    }

    public func pageDown() -> RimeOutput {
        output(from: coordinator.performOrderedNow(.pageDown))
    }

    private func bindingIdentity() -> (epoch: UInt64, revision: UInt64) {
        if let published = coordinator.lastPublished {
            return (published.sessionEpoch, published.revision)
        }
        return (0, 0)
    }

    private func output(from snapshot: ResponsiveRimeSnapshot?) -> RimeOutput {
        snapshot?.output
            ?? RimeOutput(composition: nil, candidates: [], highlightedIndex: -1)
    }
}
