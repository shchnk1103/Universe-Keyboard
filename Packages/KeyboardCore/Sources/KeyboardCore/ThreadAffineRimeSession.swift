import Foundation
import Synchronization

// MARK: - Notifications

extension Notification.Name {
    /// Content-free: `object` is `ResponsiveRimeSnapshot`.
    static let threadAffineRimeSnapshotPublished = Notification.Name(
        "com.universekeyboard.threadAffineRimeSnapshotPublished"
    )
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
    private struct State: Sendable {
        var lastPublished: ResponsiveRimeSnapshot?
        var completedPublishCount: Int = 0
        var publishSuppressed: Bool = false
        /// Revisions that have been delivered (exact-match wait).
        var deliveredRevisions: Set<UInt64> = []
    }

    private let state = Mutex(State())

    func handle(_ result: ThreadAffineRimeSpikeResult) {
        let snapshot = result.snapshot
        let suppressed = state.withLock { state -> Bool in
            state.lastPublished = snapshot
            state.completedPublishCount &+= 1
            state.deliveredRevisions.insert(snapshot.revision)
            return state.publishSuppressed
        }
        if !suppressed {
            NotificationCenter.default.post(
                name: .threadAffineRimeSnapshotPublished,
                object: snapshot
            )
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

// MARK: - Coordinator

/// R4-Wire coordinator: schedule on MainActor, execute on thread-affine owner.
///
/// Call only from the keyboard MainActor. Snapshot publish is delivered via
/// `Notification.Name.threadAffineRimeSnapshotPublished` (and optional handler).
public final class ThreadAffineRimeSessionCoordinator {
    public typealias PublishHandler = (ResponsiveRimeSnapshot?) -> Void

    private let bootstrap: AnyThreadAffineRimeEngineBootstrap
    private let configuration: ThreadAffineRimeOwnerConfiguration
    private let sink = ThreadAffineDeliverySink()
    private var owner: ThreadAffineRimeSpikeOwner?
    private var actionSequence: UInt64 = 0
    private var publishHandler: PublishHandler?
    private var observer: NSObjectProtocol?
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
        observer = NotificationCenter.default.addObserver(
            forName: .threadAffineRimeSnapshotPublished,
            object: nil,
            queue: .main
        ) { [weak self] note in
            guard let snapshot = note.object as? ResponsiveRimeSnapshot else { return }
            self?.publishHandler?(snapshot)
        }
        startOwner()
    }

    deinit {
        if let observer {
            NotificationCenter.default.removeObserver(observer)
        }
        owner?.shutdown()
    }

    public var lastPublished: ResponsiveRimeSnapshot? { sink.lastPublished() }
    public var completedPublishCount: Int { sink.completedPublishCount() }
    public var diagnostics: ThreadAffineRimeOwnerDiagnostics {
        owner?.diagnostics() ?? ThreadAffineRimeOwnerDiagnostics()
    }

    public var hasPendingWork: Bool {
        (owner?.diagnostics().pendingWorkDepth ?? 0) > 0
    }

    public func setPublishHandler(_ handler: PublishHandler?) {
        publishHandler = handler
    }

    public func scheduleProcessKey(_ key: String) {
        actionSequence &+= 1
        let actionID = "pk-\(actionSequence)"
        lastScheduledActionID = actionID
        lastAcceptReceipt = owner?.accept(.processKey(key), actionID: actionID)
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
        _ = owner?.advanceSessionEpoch()
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

    public func suspendForVisibilityChange() {
        flushPending()
        owner?.shutdown()
        _ = owner?.waitUntilStopped(timeout: .now() + 2)
        owner = nil
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
    }

    private func startOwner() {
        let sink = self.sink
        owner = ThreadAffineRimeSpikeOwner(
            bootstrap: bootstrap,
            configuration: configuration,
            resultHandler: { result in
                sink.handle(result)
            }
        )
    }
}

// MARK: - Bridge

/// `RimeEngine` facade for thread-affine mode: all mutations enter the owner.
/// Call only from the keyboard MainActor (same expectation as
/// `ResponsiveRimeEngineBridge`).
public final class ThreadAffineRimeEngineBridge: RimeEngine {
    private let coordinator: ThreadAffineRimeSessionCoordinator
    public let chromeEngineHint: RimeEngine?

    public init(
        coordinator: ThreadAffineRimeSessionCoordinator,
        chromeEngineHint: RimeEngine? = nil
    ) {
        self.coordinator = coordinator
        self.chromeEngineHint = chromeEngineHint
    }

    public var runtimeSelection: RimeRuntimeSelection? {
        chromeEngineHint?.runtimeSelection
    }

    public var diagnosticSessionSnapshot: RimeSessionDiagnosticSnapshot? {
        chromeEngineHint?.diagnosticSessionSnapshot
    }

    public var onRuntimeSelectionChanged: ((RimeRuntimeSelection) -> Void)? {
        get { chromeEngineHint?.onRuntimeSelectionChanged }
        set { chromeEngineHint?.onRuntimeSelectionChanged = newValue }
    }

    public func processKey(_ key: String) -> RimeOutput {
        output(from: coordinator.performOrderedNow(.processKey(key)))
    }

    public func selectCandidate(at index: Int) -> RimeOutput {
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
        if let chromeEngineHint {
            return chromeEngineHint.candidateWindow(from: globalIndex, limit: limit)
        }
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
        output(from: coordinator.performOrderedNow(.deleteBackward))
    }

    public func replaceInput(_ input: String) -> RimeOutput {
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
