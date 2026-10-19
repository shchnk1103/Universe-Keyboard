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

    private struct OrderedWaiter: Sendable {
        let token: UUID
        var snapshot: ResponsiveRimeSnapshot?
    }

    private struct State: Sendable {
        var lastPublished: ResponsiveRimeSnapshot?
        var completedPublishCount: Int = 0
        var publishSuppressed: Bool = false
        /// Only active calls retain their own completion; no historical cache.
        var orderedWaiters: [String: OrderedWaiter] = [:]
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
            if var waiter = state.orderedWaiters[snapshot.actionID], waiter.snapshot == nil {
                waiter.snapshot = snapshot
                state.orderedWaiters[snapshot.actionID] = waiter
            }
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
            $0.orderedWaiters.removeAll()
        }
    }

    /// Lifecycle receipts keep their original identity for ordered completion,
    /// but must not become the editable binding for the newly created session.
    func invalidateLifecyclePublication(_ receipt: ResponsiveRimeAcceptReceipt) {
        state.withLock {
            guard let published = $0.lastPublished,
                published.actionID == receipt.actionID,
                published.sessionEpoch == receipt.sessionEpoch,
                published.revision == receipt.revision
            else { return }
            $0.lastPublished = nil
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

    func registerOrderedWaiter(actionID: String) -> UUID {
        let token = UUID()
        state.withLock { $0.orderedWaiters[actionID] = OrderedWaiter(token: token) }
        return token
    }

    func removeOrderedWaiter(actionID: String, token: UUID) {
        state.withLock {
            // Cleanup of an old call must not remove a later registration.
            guard $0.orderedWaiters[actionID]?.token == token else { return }
            $0.orderedWaiters.removeValue(forKey: actionID)
        }
    }

    func cancelOrderedWaiters() {
        state.withLock { $0.orderedWaiters.removeAll() }
    }

    func waitForReceipt(
        _ receipt: ResponsiveRimeAcceptReceipt,
        token: UUID,
        timeout: DispatchTime
    ) -> ResponsiveRimeSnapshot? {
        while DispatchTime.now() < timeout {
            let completion = state.withLock { state -> (active: Bool, snapshot: ResponsiveRimeSnapshot?) in
                guard let waiter = state.orderedWaiters[receipt.actionID],
                    waiter.token == token
                else { return (false, nil) }
                guard let snapshot = waiter.snapshot,
                    snapshot.actionID == receipt.actionID,
                    snapshot.sessionEpoch == receipt.sessionEpoch,
                    snapshot.revision == receipt.revision
                else { return (true, nil) }
                return (true, snapshot)
            }
            if !completion.active { return nil }
            if let snapshot = completion.snapshot { return snapshot }
            Thread.sleep(forTimeInterval: 0.001)
        }
        // A timeout is not delivery. Deferred cleanup makes late results inert.
        return nil
    }

}

// MARK: - MainActor publish router

/// Routes owner-thread snapshot notifications to MainActor handlers without
/// capturing non-Sendable coordinator instances inside `@Sendable` Notification
/// closures (Swift 6 / CI `warnings-as-errors`).
@MainActor
private enum ThreadAffinePublishRouter {
    private static var handlers: [UUID: (ThreadAffineRimePublishedSnapshot) -> Void] = [:]

    static func setHandler(
        _ id: UUID,
        _ handler: ((ThreadAffineRimePublishedSnapshot) -> Void)?
    ) {
        if let handler {
            handlers[id] = handler
        } else {
            handlers.removeValue(forKey: id)
        }
    }

    #if DEBUG
        static func hasHandler(_ id: UUID) -> Bool { handlers[id] != nil }
    #endif

    static func deliver(_ id: UUID, publication: ThreadAffineRimePublishedSnapshot) {
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
    #if DEBUG
        public let wakeProbeCoordinatorOrdinal = KeyboardWakeOwnerProbe.shared.nextCoordinatorOrdinal()
        /// Presence is read only on the same MainActor call path as scheduling.
        /// Readiness and epoch defaults do not distinguish an absent owner.
        public var wakeProbeOwnerPresent: Bool { owner != nil }
    #endif
    private var actionSequence: UInt64 = 0
    private var publishHandler: PublishHandler?
    private var publicationHandler: PublicationHandler?
    private var observer: NSObjectProtocol?
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
    /// Independent generation identity survives delayed delivery and cleanup.
    /// An object address can be reused after deinit, allowing retired work to
    /// unregister or deliver into a newly created coordinator at that address.
    private let routerID = UUID()
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
        let routeID = routerID
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
        sink.cancelOrderedWaiters()
        owner?.shutdown()
        let routeID = routerID
        Task { @MainActor in
            ThreadAffinePublishRouter.setHandler(routeID, nil)
        }
    }

    #if DEBUG
        internal var publishRouteIdentityForTesting: UUID { routerID }
        @MainActor internal var isPublishRouteRegisteredForTesting: Bool {
            ThreadAffinePublishRouter.hasHandler(routerID)
        }
    #endif

    internal var instanceIdentity: UUID { routerID }

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
    /// This is deliberately a non-blocking observation: first-frame UIKit
    /// presentation must not wait for librime session creation.
    public var isOwnerReady: Bool { owner?.isReady == true }

    public var hasPendingWork: Bool {
        (owner?.diagnostics().pendingWorkDepth ?? 0) > 0
    }

    #if T9_RESPONSIVE_CANARY_INTERNAL
        public var pendingPresentationIdentities:
            [(
                canarySessionInstance: UInt64,
                sessionEpoch: UInt64,
                revision: UInt64
            )]
        {
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
        let routeID = routerID
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
        let routeID = routerID
        ThreadAffinePublishRouter.setHandler(routeID, handler)
    }

    #if T9_RESPONSIVE_CANARY_INTERNAL
        /// Canary-only handler preserves the complete delivery identity.
        @MainActor
        public func setCanaryPublishHandler(_ handler: CanaryPublishHandler?) {
            let routeID = routerID
            ThreadAffinePublishRouter.setHandler(routeID, handler)
        }
    #endif

    public func scheduleProcessKey(_ key: String) {
        actionSequence &+= 1
        let actionID = "pk-\(actionSequence)"
        lastScheduledActionID = actionID
        #if DEBUG
            let wakeOwnerPresent = owner != nil
        #endif
        lastAcceptReceipt = owner?.accept(.processKey(key), actionID: actionID)
        #if DEBUG
            KeyboardWakeOwnerProbe.shared.record(
                stage: .schedule,
                coordinatorOrdinal: wakeProbeCoordinatorOrdinal,
                ownerPresent: wakeOwnerPresent,
                receiptPresent: lastAcceptReceipt != nil,
                epoch: lastAcceptReceipt?.sessionEpoch ?? lifecycleEpoch,
                revision: lastAcceptReceipt?.revision ?? 0
            )
        #endif
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
        activeKillFence = nil
        return result
    }

    /// - Parameter actionIDPrefix: Use `sel` for candidate select so MainActor
    ///   presentation can fail-closed on host `committedText` (Core owns apply).
    @discardableResult
    public func performOrderedNow(
        _ work: ResponsiveRimeWork,
        actionIDPrefix: String = "ord",
        candidateOrigin: RimeOutputOrigin? = nil
    ) -> ResponsiveRimeSnapshot? {
        actionSequence &+= 1
        let actionID = "\(actionIDPrefix)-\(actionSequence)"
        // Register before accept: the owner can complete before accept returns.
        let token = sink.registerOrderedWaiter(actionID: actionID)
        defer { sink.removeOrderedWaiter(actionID: actionID, token: token) }
        guard let receipt = owner?.accept(work, actionID: actionID, candidateOrigin: candidateOrigin) else {
            return nil
        }
        lastAcceptReceipt = receipt
        let snapshot = sink.waitForReceipt(receipt, token: token, timeout: .now() + 5)
        if snapshot != nil {
            switch work {
            case .resetSession, .recoverSession:
                sink.invalidateLifecyclePublication(receipt)
            default:
                break
            }
        }
        return snapshot
    }

    public func flushPending() {
        let deadline = DispatchTime.now() + 5
        while DispatchTime.now() < deadline {
            if (owner?.diagnostics().pendingWorkDepth ?? 0) == 0 { break }
            Thread.sleep(forTimeInterval: 0.002)
        }
    }

    /// Owner-thread live `candidateWindow` (RESPONSIVE-CANDIDATE-ANOMALY-001 B).
    /// Call after `flushPending` so the window matches applied composition.
    public func candidateWindow(
        from globalIndex: Int,
        limit: Int,
        timeout: DispatchTime = .now() + 5
    ) -> RimeCandidateWindow {
        guard let owner else {
            return RimeCandidateWindow(
                candidates: [],
                startIndex: max(0, globalIndex),
                nextIndex: max(0, globalIndex),
                hasMoreCandidates: false
            )
        }
        let snapshot = owner.candidateWindow(
            from: globalIndex,
            limit: limit,
            timeout: timeout
        )
        guard snapshot.sessionEpoch == owner.diagnostics().sessionEpoch else {
            return RimeCandidateWindow(
                candidates: [],
                startIndex: max(0, globalIndex),
                nextIndex: max(0, globalIndex),
                hasMoreCandidates: false
            )
        }
        return snapshot.window
    }

    public func readCandidateWindow(
        origin: RimeOutputOrigin, from: Int, limit: Int
    ) -> RimeCandidateWindowReadResult {
        owner?.readCandidateWindow(origin: origin, from: from, limit: limit) ?? .rejected(.unavailable)
    }

    @MainActor
    public func consumeCandidateWindow(
        _ window: RimeBoundCandidateWindow, prepared: RimeCandidatePresentationPage,
        into store: RimeCandidatePresentationStore
    ) -> RimeCandidateConsumptionDecision {
        owner?.consumeCandidateWindow(window, prepared: prepared, into: store) ?? .rejected(.unavailable)
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
        guard let owner else {
            #if DEBUG
                KeyboardWakeOwnerProbe.shared.record(
                    stage: .teardown, coordinatorOrdinal: wakeProbeCoordinatorOrdinal, ownerPresent: false,
                    epoch: lifecycleEpoch)
            #endif
            return nil
        }
        let result = owner.abandonForVisibilityAndShutdown(timeout: timeout)
        guard result.isPositive else {
            #if DEBUG
                KeyboardWakeOwnerProbe.shared.record(
                    stage: .teardown, coordinatorOrdinal: wakeProbeCoordinatorOrdinal, ownerPresent: true,
                    teardownResult: .failed, epoch: lifecycleEpoch)
            #endif
            return result
        }

        self.owner = nil
        activeKillFence = nil
        #if DEBUG
            KeyboardWakeOwnerProbe.shared.record(
                stage: .teardown, coordinatorOrdinal: wakeProbeCoordinatorOrdinal, ownerPresent: false,
                teardownResult: .completed, epoch: lifecycleEpoch)
        #endif
        return result
    }

    public func resumeAfterVisibilityChange() {
        #if DEBUG
            KeyboardWakeOwnerProbe.shared.record(
                stage: .resumeBegin, coordinatorOrdinal: wakeProbeCoordinatorOrdinal, ownerPresent: owner != nil,
                epoch: lifecycleEpoch)
        #endif
        if owner == nil {
            startOwner()
        }
        #if DEBUG
            KeyboardWakeOwnerProbe.shared.record(
                stage: .resumeEnd, coordinatorOrdinal: wakeProbeCoordinatorOrdinal, ownerPresent: owner != nil,
                epoch: lifecycleEpoch)
        #endif
    }

    public func shutdown() {
        sink.cancelOrderedWaiters()
        owner?.shutdown()
        _ = owner?.waitUntilStopped(timeout: .now() + 2)
        _ = owner?.waitUntilDeliveryDrained(timeout: .now() + 2)
        owner = nil
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
        // A fresh owner starts at epoch 1. Advance its acceptance counter
        // before publishing the owner reference, so a first key accepted while
        // librime is still booting is stamped with the current lifecycle epoch.
        // The control-lane resets then run before queued work on the owner.
        if lifecycleEpoch > 1 {
            for _ in 1..<lifecycleEpoch {
                _ = newOwner.advanceSessionEpoch()
            }
        }
        owner = newOwner
        #if DEBUG
            KeyboardWakeOwnerProbe.shared.record(
                stage: .replacement, coordinatorOrdinal: wakeProbeCoordinatorOrdinal, ownerPresent: true,
                epoch: lifecycleEpoch)
        #endif
    }
}

// MARK: - Bridge

/// `RimeEngine` facade for thread-affine mode: all mutations enter the owner.
/// Call only from the keyboard MainActor (same expectation as
/// `ResponsiveRimeEngineBridge`).
public final class ThreadAffineRimeEngineBridge: RimeEngine, RimeCandidateAuthorityProviding {
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
        // RESPONSIVE-CANDIDATE-ANOMALY-001 A1: Core owns host apply after select.
        return coordinator.withPublishHandlerSuppressed {
            output(
                from: coordinator.performOrderedNow(
                    .selectCandidate(
                        pageIndex: index,
                        boundEpoch: bound.epoch,
                        boundRevision: bound.revision
                    ),
                    actionIDPrefix: "sel"
                )
            )
        }
    }

    public func selectCandidate(globalIndex index: Int) -> RimeOutput {
        coordinator.flushPending()
        let bound = bindingIdentity()
        return coordinator.withPublishHandlerSuppressed {
            output(
                from: coordinator.performOrderedNow(
                    .selectCandidateGlobal(
                        index: index,
                        boundEpoch: bound.epoch,
                        boundRevision: bound.revision
                    ),
                    actionIDPrefix: "sel"
                )
            )
        }
    }

    public func candidateWindow(from globalIndex: Int, limit: Int) -> RimeCandidateWindow {
        // RESPONSIVE-CANDIDATE-ANOMALY-001 B: read on the live owner engine after
        // draining mutations. Never slice first-page lastPublished candidates
        // (that caps the bar at page_size and kills loadMore).
        coordinator.flushPending()
        return coordinator.candidateWindow(from: globalIndex, limit: limit)
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

    public func readCandidateWindow(
        origin: RimeOutputOrigin, from: Int, limit: Int
    ) -> RimeCandidateWindowReadResult {
        // No extra flush or mutation: unsettled work rejects this read explicitly.
        coordinator.readCandidateWindow(origin: origin, from: from, limit: limit)
    }

    @MainActor
    public func consumeCandidateWindow(
        _ window: RimeBoundCandidateWindow, prepared: RimeCandidatePresentationPage,
        into store: RimeCandidatePresentationStore
    ) -> RimeCandidateConsumptionDecision {
        coordinator.consumeCandidateWindow(window, prepared: prepared, into: store)
    }

    public func selectCandidate(
        origin: RimeOutputOrigin, pageIndex: Int, globalIndex: Int?
    ) -> RimeBoundCandidateSelectionResult {
        let work: ResponsiveRimeWork =
            globalIndex.map {
                .selectCandidateGlobal(index: $0, boundEpoch: origin.sessionEpoch, boundRevision: origin.revision)
            } ?? .selectCandidate(pageIndex: pageIndex, boundEpoch: origin.sessionEpoch, boundRevision: origin.revision)
        return coordinator.withPublishHandlerSuppressed {
            guard
                let snapshot = coordinator.performOrderedNow(
                    work, actionIDPrefix: "sel", candidateOrigin: origin
                )
            else { return .rejected(.unavailable) }
            return .applied(snapshot.output)
        }
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
