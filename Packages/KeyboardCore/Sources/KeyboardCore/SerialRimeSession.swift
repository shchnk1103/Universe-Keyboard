import Foundation

/// R2 serial session owner + MainActor coordinator.
///
/// ## Isolation (ADR 0025 §10 — practical R2)
///
/// Swift 6 region isolation cannot move a non-Sendable `RimeEngine` (class /
/// ObjC librime bridge) onto a background `actor` without `@unchecked Sendable`
/// or equivalent shuttling — both forbidden by repository policy.
///
/// Therefore R2 uses a **single-consumer MainActor owner**:
/// - All engine + pipeline mutations run only on MainActor.
/// - `scheduleProcessKey` returns from `handle` **before** `processNext`
///   (drain is deferred via `DispatchQueue.main.async`), so accept is not
///   synchronous with librime for the caller of `handle`.
/// - Drain is strictly serial (`isDraining` + ordered pipeline queue).
/// - Default gate remains off → historical ADR 0004 sync path unchanged.
///
/// Residual (for R3/Architecture): long `process_key` still occupies MainActor
/// while a deferred drain item runs; true off-main librime requires a
/// thread-confined owner design that does not shuttle Sendable engine refs.
@MainActor
public final class SerialRimeSessionOwner {
    private let engine: RimeEngine
    private let pipeline: ResponsiveRimePipeline

    public init(
        engine: RimeEngine,
        publishPolicy: ResponsiveRimePublishPolicy = .latestOnly,
        fixtureID: String = "T9RESP-R2",
        clock: ResponsiveRimeExecutionClock = NoopResponsiveRimeClock()
    ) {
        self.engine = engine
        self.pipeline = ResponsiveRimePipeline(
            engine: engine,
            clock: clock,
            publishPolicy: publishPolicy,
            fixtureID: fixtureID
        )
    }

    public func accept(_ work: ResponsiveRimeWork, actionID: String) -> ResponsiveRimeAcceptReceipt {
        pipeline.accept(work, actionID: actionID)
    }

    @discardableResult
    public func processNext() -> Bool {
        pipeline.processNext()
    }

    public func drain(limit: Int? = nil) -> Int {
        pipeline.drain(limit: limit)
    }

    public func bumpSessionEpoch(resetEngineSession: Bool = true) {
        pipeline.bumpSessionEpoch(resetEngineSession: resetEngineSession)
    }

    public func validateSelection(
        boundEpoch: UInt64,
        boundRevision: UInt64
    ) -> ResponsiveRimeSelectionDecision {
        pipeline.validateSelection(boundEpoch: boundEpoch, boundRevision: boundRevision)
    }

    public var diagnostics: ResponsiveRimeDiagnostics { pipeline.diagnostics }
    public var lastPublished: ResponsiveRimeSnapshot? { pipeline.lastPublished }
    public var lastApplied: ResponsiveRimeSnapshot? { pipeline.lastApplied }

    // Direct session APIs — same owner (MainActor), for ordered non-pipeline call sites.
    public func processKey(_ key: String) -> RimeOutput { engine.processKey(key) }
    public func selectCandidate(at index: Int) -> RimeOutput { engine.selectCandidate(at: index) }
    public func selectCandidate(globalIndex index: Int) -> RimeOutput {
        engine.selectCandidate(globalIndex: index)
    }
    public func candidateWindow(from globalIndex: Int, limit: Int) -> RimeCandidateWindow {
        engine.candidateWindow(from: globalIndex, limit: limit)
    }
    public func deleteBackward() -> RimeOutput { engine.deleteBackward() }
    public func replaceInput(_ input: String) -> RimeOutput { engine.replaceInput(input) }
    public func resetSession() { engine.resetSession() }
    public func recoverSession() { engine.recoverSession() }
    public func suspendForVisibilityChange() { engine.suspendForVisibilityChange() }
    public func resumeAfterVisibilityChange() { engine.resumeAfterVisibilityChange() }
    public func isComposing() -> Bool { engine.isComposing() }
    public func pageUp() -> RimeOutput { engine.pageUp() }
    public func pageDown() -> RimeOutput { engine.pageDown() }
}

/// MainActor coordinator: deferred serial drain so `handle` can return before librime.
@MainActor
public final class ResponsiveRimeSessionCoordinator {
    private let owner: SerialRimeSessionOwner
    private var actionSequence: UInt64 = 0
    private var isDraining = false
    private var drainGeneration: UInt64 = 0

    public let fixtureID: String
    public private(set) var lastScheduledActionID: String?
    public private(set) var lastAcceptReceipt: ResponsiveRimeAcceptReceipt?
    public private(set) var completedPublishCount: Int = 0

    public init(
        engine: RimeEngine,
        publishPolicy: ResponsiveRimePublishPolicy = .latestOnly,
        fixtureID: String = "T9RESP-R2",
        clock: ResponsiveRimeExecutionClock = NoopResponsiveRimeClock()
    ) {
        self.fixtureID = fixtureID
        self.owner = SerialRimeSessionOwner(
            engine: engine,
            publishPolicy: publishPolicy,
            fixtureID: fixtureID,
            clock: clock
        )
    }

    public var sessionOwner: SerialRimeSessionOwner { owner }

    /// Accept processKey immediately; drain on a later MainActor turn.
    public func scheduleProcessKey(
        _ key: String,
        onPublished: @escaping @MainActor (ResponsiveRimeSnapshot?) -> Void
    ) {
        actionSequence &+= 1
        let actionID = "pk-\(actionSequence)"
        lastScheduledActionID = actionID
        let receipt = owner.accept(.processKey(key), actionID: actionID)
        lastAcceptReceipt = receipt
        scheduleDrain(onPublished: onPublished)
    }

    /// Ordered work processed on the next drain turns (may wait if called via
    /// `performOrderedNow`). Prefer `schedule` for key path.
    @discardableResult
    public func performOrderedNow(_ work: ResponsiveRimeWork) -> ResponsiveRimeSnapshot? {
        actionSequence &+= 1
        let actionID = "ord-\(actionSequence)"
        _ = owner.accept(work, actionID: actionID)
        _ = owner.processNext()
        completedPublishCount += 1
        return owner.lastPublished
    }

    public func bumpSessionEpoch(resetEngineSession: Bool = true) {
        drainGeneration &+= 1
        isDraining = false
        owner.bumpSessionEpoch(resetEngineSession: resetEngineSession)
    }

    public func validateSelection(
        boundEpoch: UInt64,
        boundRevision: UInt64
    ) -> ResponsiveRimeSelectionDecision {
        owner.validateSelection(boundEpoch: boundEpoch, boundRevision: boundRevision)
    }

    public var diagnostics: ResponsiveRimeDiagnostics { owner.diagnostics }

    private func scheduleDrain(
        onPublished: @escaping @MainActor (ResponsiveRimeSnapshot?) -> Void
    ) {
        let generation = drainGeneration
        guard !isDraining else { return }
        isDraining = true
        // Defer so the current `handle` returns before librime runs.
        DispatchQueue.main.async { [weak self] in
            self?.drainLoop(generation: generation, onPublished: onPublished)
        }
    }

    private func drainLoop(
        generation: UInt64,
        onPublished: @escaping @MainActor (ResponsiveRimeSnapshot?) -> Void
    ) {
        guard generation == drainGeneration else {
            isDraining = false
            return
        }
        guard owner.processNext() else {
            isDraining = false
            return
        }
        completedPublishCount += 1
        onPublished(owner.lastPublished)
        // Continue draining remaining pending items on subsequent turns so
        // multiple rapid accepts stay ordered without one giant blocking burst
        // when clocks are no-ops; with sleeping clocks each turn still pays cost.
        if owner.diagnostics.pendingDepth > 0 {
            DispatchQueue.main.async { [weak self] in
                self?.drainLoop(generation: generation, onPublished: onPublished)
            }
        } else {
            isDraining = false
        }
    }
}
