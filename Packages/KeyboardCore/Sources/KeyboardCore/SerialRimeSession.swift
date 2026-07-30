import Foundation

/// R2 serial session owner + MainActor coordinator + `RimeEngine` bridge.
///
/// ## Isolation (ADR 0025 §10 — practical R2)
///
/// Swift 6 region isolation cannot move a non-Sendable `RimeEngine` onto a
/// background actor without `@unchecked Sendable`. R2 therefore uses a
/// **single-consumer MainActor owner**:
/// - When the responsive gate is on, **all** session mutations enter the same
///   `ResponsiveRimePipeline` via `ResponsiveRimeEngineBridge` (no sync bypass).
/// - `scheduleProcessKey` returns before `processNext` (deferred MainActor turn).
/// - `performOrderedNow` drains the **entire** pending queue so Delete/Path/select
///   cannot overtake unprocessed keys.
/// - Default gate remains off → ADR 0004 sync path unchanged.
///
/// Residual: long `process_key` still occupies MainActor during drain turns.
/// Call only from the keyboard MainActor. Not annotated `@MainActor` so it can
/// back a nonisolated `RimeEngine` bridge conformance without isolation mismatch.
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

    public var pendingDepth: Int { pipeline.diagnostics.pendingDepth }

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

    /// Lifecycle / read helpers after the pipeline queue is drained.
    public func isComposing() -> Bool { engine.isComposing() }
    public func runtimeSelection() -> RimeRuntimeSelection? { engine.runtimeSelection }
    public func diagnosticSessionSnapshot() -> RimeSessionDiagnosticSnapshot? {
        engine.diagnosticSessionSnapshot
    }
    public func setOnRuntimeSelectionChanged(_ handler: ((RimeRuntimeSelection) -> Void)?) {
        engine.onRuntimeSelectionChanged = handler
    }
    public func suspendForVisibilityChange() { engine.suspendForVisibilityChange() }
    public func resumeAfterVisibilityChange() { engine.resumeAfterVisibilityChange() }
}

/// Coordinator: deferred serial drain + ordered sync mutations.
/// Call only from the keyboard MainActor (same as `KeyboardController`).
public final class ResponsiveRimeSessionCoordinator {
    private let owner: SerialRimeSessionOwner
    private var actionSequence: UInt64 = 0
    private var isDraining = false
    private var drainGeneration: UInt64 = 0
    /// Shared publish sink so multi-accept shares one UI bridge (not per-call drops).
    private var publishHandler: ((ResponsiveRimeSnapshot?) -> Void)?

    public let fixtureID: String
    public private(set) var lastScheduledActionID: String?
    public private(set) var lastAcceptReceipt: ResponsiveRimeAcceptReceipt?
    /// Counts successful `processNext` returns that produced a published snapshot
    /// advance (or attempted publish path).
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
    public var hasPendingWork: Bool { owner.pendingDepth > 0 }
    public var diagnostics: ResponsiveRimeDiagnostics { owner.diagnostics }

    /// Install/replace the single UI publish bridge used by deferred drain.
    public func setPublishHandler(_ handler: ((ResponsiveRimeSnapshot?) -> Void)?) {
        publishHandler = handler
    }

    /// Accept processKey immediately without running the engine.
    /// Caller schedules `drainOneStep` / `flushPending` after yielding.
    public func scheduleProcessKey(_ key: String) {
        actionSequence &+= 1
        let actionID = "pk-\(actionSequence)"
        lastScheduledActionID = actionID
        let receipt = owner.accept(.processKey(key), actionID: actionID)
        lastAcceptReceipt = receipt
    }

    /// Process one pending item and invoke the publish handler.
    @discardableResult
    public func drainOneStep() -> Bool {
        guard owner.processNext() else { return false }
        completedPublishCount += 1
        publishHandler?(owner.lastPublished)
        return true
    }

    /// Ordered work: enqueue then **drain the entire queue** so later mutations
    /// cannot race ahead of pending processKey items (Arch P1-1).
    @discardableResult
    public func performOrderedNow(_ work: ResponsiveRimeWork) -> ResponsiveRimeSnapshot? {
        actionSequence &+= 1
        let actionID = "ord-\(actionSequence)"
        _ = owner.accept(work, actionID: actionID)
        flushPending()
        return owner.lastPublished
    }

    /// Drain any pending work without enqueueing (e.g. before lifecycle ops).
    public func flushPending() {
        while drainOneStep() {}
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

    public func suspendForVisibilityChange() {
        flushPending()
        owner.suspendForVisibilityChange()
    }

    public func resumeAfterVisibilityChange() {
        flushPending()
        owner.resumeAfterVisibilityChange()
    }
}

/// `RimeEngine` facade: when installed as `controller.rimeEngine` under the
/// responsive gate, **every** protocol method enters the coordinator pipeline
/// (Arch P1-1 — no dual-entry to the raw engine).
///
/// Installed only from `KeyboardController` on the main actor; not thread-safe
/// for concurrent use.
public final class ResponsiveRimeEngineBridge: RimeEngine {
    public let underlyingEngine: RimeEngine
    private let coordinator: ResponsiveRimeSessionCoordinator

    public init(underlyingEngine: RimeEngine, coordinator: ResponsiveRimeSessionCoordinator) {
        self.underlyingEngine = underlyingEngine
        self.coordinator = coordinator
    }

    public var runtimeSelection: RimeRuntimeSelection? {
        coordinator.sessionOwner.runtimeSelection()
    }

    public var diagnosticSessionSnapshot: RimeSessionDiagnosticSnapshot? {
        coordinator.sessionOwner.diagnosticSessionSnapshot()
    }

    public var onRuntimeSelectionChanged: ((RimeRuntimeSelection) -> Void)? {
        get { underlyingEngine.onRuntimeSelectionChanged }
        set { coordinator.sessionOwner.setOnRuntimeSelectionChanged(newValue) }
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
        // Read-only: flush mutations first so the window matches applied state.
        coordinator.flushPending()
        return underlyingEngine.candidateWindow(from: globalIndex, limit: limit)
    }

    public func deleteBackward() -> RimeOutput {
        output(from: coordinator.performOrderedNow(.deleteBackward))
    }

    public func replaceInput(_ input: String) -> RimeOutput {
        // Path refine without explicit binding uses unbound replace (pipeline
        // allows optional bounds). Callers that need fail-closed should pass
        // bound work via coordinator; bridge uses last published when present.
        if let published = coordinator.sessionOwner.lastPublished {
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
        coordinator.hasPendingWork || coordinator.sessionOwner.isComposing()
    }

    public func pageUp() -> RimeOutput {
        output(from: coordinator.performOrderedNow(.pageUp))
    }

    public func pageDown() -> RimeOutput {
        output(from: coordinator.performOrderedNow(.pageDown))
    }

    private func bindingIdentity() -> (epoch: UInt64, revision: UInt64) {
        if let published = coordinator.sessionOwner.lastPublished {
            return (published.sessionEpoch, published.revision)
        }
        // Fail closed: impossible binding so selection is rejected.
        return (0, 0)
    }

    private func output(from snapshot: ResponsiveRimeSnapshot?) -> RimeOutput {
        snapshot?.output
            ?? RimeOutput(composition: nil, candidates: [], highlightedIndex: -1)
    }
}
