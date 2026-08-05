import Foundation

@MainActor
public final class KeyboardController {

    // MARK: - Public properties

    public internal(set) var state: KeyboardState
    public var textClient: TextInputClient?
    public let candidateProvider: CandidateProvider
    public let continuationSuggestionProvider: any ContinuationSuggestionProviding
    public var typoCorrectionCandidateQuery: TypoCorrectionCandidateQuerying
    public var rimeEngine: RimeEngine?

    public var currentDate: () -> Date = { Date() }
    public var isTypoCorrectionPartialCommitEnabled = false
    public var typoCorrectionExperimentalEdits: TypoCorrectionExperimentalEdits = []
    public var typoCorrectionLearningSnapshot: TypoCorrectionLearningSnapshot = .empty
    public var onTypoCorrectionSelected: ((TypoCorrectionCommit) -> Void)?
    /// Called synchronously with ephemeral final text. Consumers must convert
    /// it to content-free aggregates before returning and must not persist it.
    public var onCommittedText: ((CommittedTextEvent) -> Void)?
    public var isPairedSymbolCompletionEnabled = true
    public internal(set) var isPostCommitContinuationEnabled = true
    /// Derived from the same `RimeRuntimeSelection` used for schema + layout.
    /// Digit shape alone never enables T9 policies.
    public var usesT9InputSemantics = false
    /// Stage 2 prototype gate. Production callers must opt in explicitly.
    public var isReversibleT9AutoAnchorEnabled = false
    /// S2.1 cumulative-extension gate. Keeping this separate preserves the
    /// existing one-anchor A1 arm when the base prototype is enabled.
    public var isRollingT9AutoAnchorEnabled = false
    /// S2.2 third cumulative-extension gate. Requires rolling; keeps B2 as the
    /// two-attempt comparator when this flag stays off.
    public var isTripleRollingT9AutoAnchorEnabled = false
    /// S2.3 earlier first-anchor gate. Orthogonal to rolling/triple; only lowers
    /// the attempt-1 source-digit floor (18 → 12) while retaining two syllables.
    public var isEarlierFirstT9AutoAnchorEnabled = false
    /// R2 responsive pipeline gate. **Default off** — Release matches ADR 0004
    /// MainActor-synchronous `rimeEngine` calls. When enabled, printable Chinese
    /// composition keys are accepted without waiting for librime; results publish
    /// asynchronously via `SerialRimeSessionOwner` + dual revision watermarks.
    /// All other session APIs enter the same pipeline through
    /// `ResponsiveRimeEngineBridge` (no dual-entry).
    public var isResponsiveRimePipelineEnabled = false
    /// R4-Wire: when true **with** responsive gate and a bootstrap, session work
    /// runs on the thread-affine owner. Default remains false.
        public var isThreadAffineRimeOwnerEnabled = false
    /// Sendable config-only bootstrap for thread-affine mode (required when
    /// `isThreadAffineRimeOwnerEnabled` is true for off-main ownership).
        public var threadAffineEngineBootstrap: AnyThreadAffineRimeEngineBootstrap?
    /// Active only while `isResponsiveRimePipelineEnabled` is true (MainActor R2 path).
    public internal(set) var responsiveRimeCoordinator: ResponsiveRimeSessionCoordinator?
    /// Active when dual-gate thread-affine mode is installed.
        public internal(set) var threadAffineRimeCoordinator: ThreadAffineRimeSessionCoordinator?
    /// Invoked on MainActor after a deferred responsive snapshot is applied so
    /// Extension UI can `syncUI` (Arch/Quality P1 — publish→presentation bridge).
    public var onResponsivePresentationNeeded: ((KeyboardEffect) -> Void)?
    #if T9_RESPONSIVE_CANARY_INTERNAL
    /// Content-free terminal stream for the internal canary validator.
    public var onResponsiveCanaryPresentationTerminal:
        ((ResponsiveRimeCanaryPresentationTerminal) -> Void)?
    public var onResponsiveCanaryRuntimeSelection:
        ((RimeRuntimeSelection) -> Void)?
    /// Synchronous UI acknowledgement used only by the internal canary. `true`
    /// means the Extension completed `syncUI` before the closure returned.
    public var onResponsiveCanaryPresentationNeeded: ((KeyboardEffect) -> Bool)?
    private var responsiveCanaryPresentationFenced = false
    private var pendingResponsiveCanaryVisibleSnapshot: (
        snapshot: ResponsiveRimeSnapshot,
        canarySessionInstance: UInt64
    )?
    public private(set) var lastResponsiveCanaryVisibilityTeardown:
        ThreadAffineRimeVisibilityTeardownResult?
    private var isResponsiveCanaryOwnerInstalled = false
    private var currentResponsiveCanarySessionInstance: UInt64 = 0
    private var responsiveCanarySessionIdentities:
        [UInt64: (runID: String, modeGeneration: UInt64)] = [:]
    private var responsiveCanaryPreterminatedPresentations: Set<String> = []
    #endif
    #if DEBUG
    /// Content-free hook for controlled preflight evidence. Release builds do
    /// not expose or execute this diagnostic callback.
    public var onReversibleT9AutoAnchorOutcome:
        ((T9ReversibleAutoAnchorOutcome) -> Void)?
    #endif
    var shouldRestoreRimeComposition = false
    var shouldRebuildSessionDuringRestore = false
    /// FIFO contexts for deferred processKey post-processing (R3 parity).
    var responsiveKeyApplyContexts: [ResponsiveKeyApplyContext] = []
    /// R5-Rem-2: dual-gate latest-only presentation buffer.
    private var dualGatePendingPresentationSnapshot: ResponsiveRimeSnapshot?
    /// True when the buffered revision completed with accepted work behind it.
    /// Such a revision must wait for its successor publication rather than
    /// becoming visible merely because the mailbox is now empty.
    private var dualGatePendingPresentationHasKnownSuccessor = false
    #if T9_RESPONSIVE_CANARY_INTERNAL
    private var dualGatePendingCanarySessionInstance: UInt64 = 0
    #endif
    private var dualGatePresentationCoalesceScheduled = false
    /// R5-Rem Arch P1-1: bumped on abandon/reset/rebuild so deferred coalesce
    /// Tasks fail closed and cannot paint after presentation authority dies.
    private var responsivePresentationGeneration: UInt64 = 0
    private var lastPresentedSessionEpoch: UInt64 = 0
    private var lastPresentedRevision: UInt64 = 0
    /// Rem-3: dual-gate visual-shadow L1 ledger (MainActor).
    private var provisionalCompositionMirror = ResponsiveProvisionalCompositionMirror()
    /// Rem-3-Polish: cancels deferred L1 visual paints when L2/abandon wins first.
    private var provisionalVisualPaintGeneration: UInt64 = 0
    /// Rem-3-Polish: MainActor-owned delay; tests may lower. Default 48ms.
    public var provisionalVisualPaintDelayNanoseconds: UInt64 =
        ResponsiveProvisionalComposition.defaultVisualPaintDelayNanoseconds
    private let feltMetrics = ResponsiveRimeFeltMetricsTracker.shared

    /// Rem-3: true while L1 progressive length is ahead of settled engine paint.
    public var isResponsiveProvisionalAhead: Bool {
        provisionalCompositionMirror.isProvisionalAhead
    }

    /// Rem-3 test/debug: current L1 watermark (0 when inactive).
    public var responsiveProvisionalWatermark: UInt64 {
        provisionalCompositionMirror.watermark
    }

    /// Rem-3 test/debug: current L1 slot count.
    public var responsiveProvisionalSlotCount: Int {
        provisionalCompositionMirror.slotCount
    }

    /// Context captured when a responsive processKey is accepted (before drain).
    struct ResponsiveKeyApplyContext {
        let rimeKey: String
        let previousT9PathState: T9PinyinPathState
        let previousRawForTrace: String?
        /// Pipeline epoch at accept time; dropped if epoch advances without apply.
        let sessionEpoch: UInt64
    }

    /// Underlying engine when a responsive bridge is installed (R3 chrome).
    /// Thread-affine mode has no MainActor-held live session; returns nil there.
    public var underlyingRimeEngine: RimeEngine? {
        if let bridge = rimeEngine as? ResponsiveRimeEngineBridge {
            return bridge.underlyingEngine
        }
        if rimeEngine is ThreadAffineRimeEngineBridge {
            return nil
        }
        return rimeEngine
    }

    // MARK: - Init

    public init(
        state: KeyboardState = KeyboardState(),
        candidateProvider: CandidateProvider = FakeCandidateProvider(),
        continuationSuggestionProvider: any ContinuationSuggestionProviding = BundledContinuationSuggestionProvider.shared
    ) {
        self.state = state
        self.candidateProvider = candidateProvider
        self.continuationSuggestionProvider = continuationSuggestionProvider
        self.typoCorrectionCandidateQuery = CandidateProviderTypoCorrectionQuery(
            candidateProvider: candidateProvider
        )
    }

    /// 启用基于 CandidateProvider 的 RIME 适配器引擎。
    /// 在真正的 librime 就绪之前，此方法将现有的 FakeCandidateProvider 包装为 RimeEngine，
    /// 使键盘通过新架构运行，但行为与当前完全一致。
    public func enableDefaultRimeEngine() {
        rimeEngine = CandidateProviderRimeAdapter(candidateProvider: candidateProvider)
        typoCorrectionCandidateQuery = CandidateProviderTypoCorrectionQuery(
            candidateProvider: candidateProvider
        )
        rebuildResponsiveRimeCoordinatorIfNeeded()
    }

    /// Install or clear the R2 / R4-Wire coordinator + engine bridge when gates
    /// or engine/bootstrap change. Safe to call repeatedly; default gates leave
    /// coordinators `nil`.
    public func rebuildResponsiveRimeCoordinatorIfNeeded(
        publishPolicy: ResponsiveRimePublishPolicy = .latestOnly,
        clock: ResponsiveRimeExecutionClock = NoopResponsiveRimeClock()
    ) {
        #if T9_RESPONSIVE_CANARY_INTERNAL
        // Once installed, only the unique canary lifecycle/kill paths may tear
        // down the owner. Legacy flag rebuilds must not create a second mode
        // evaluator or invoke abandonment-style shutdown during an active kill.
        guard !isResponsiveCanaryOwnerInstalled else { return }
        #endif
        // Tear down prior thread-affine owner before switching modes.
        if let threadAffine = threadAffineRimeCoordinator {
            threadAffine.shutdown()
            threadAffineRimeCoordinator = nil
        }

        // Unwrap any previous bridge so we never nest bridges.
        let underlying: RimeEngine? = {
            if let bridge = rimeEngine as? ResponsiveRimeEngineBridge {
                return bridge.underlyingEngine
            }
            if rimeEngine is ThreadAffineRimeEngineBridge {
                return nil
            }
            return rimeEngine
        }()

        guard isResponsiveRimePipelineEnabled else {
            let wasBridge =
                rimeEngine is ResponsiveRimeEngineBridge
                || rimeEngine is ThreadAffineRimeEngineBridge
            if wasBridge {
                rimeEngine = underlying
            }
            responsiveRimeCoordinator = nil
            responsiveKeyApplyContexts.removeAll()
            return
        }

        // R4-Wire dual gate: bootstrap-only off-main owner when requested.
        if isThreadAffineRimeOwnerEnabled,
           let bootstrap = threadAffineEngineBootstrap
        {
            responsiveRimeCoordinator = nil
            let coordinator = ThreadAffineRimeSessionCoordinator(
                bootstrap: bootstrap,
                fixtureID: "T9RESP-R4W"
            )
            #if T9_RESPONSIVE_CANARY_INTERNAL
            coordinator.setCanaryPublishHandler { [weak self] publication in
                self?.applyResponsivePublishedSnapshot(
                    publication.snapshot,
                    ownerPendingDepthAtPublish:
                        publication.pendingWorkDepthAfterCompletion,
                    canarySessionInstance: publication.canarySessionInstance
                )
            }
            #else
            coordinator.setPublicationHandler { [weak self] publication in
                self?.applyResponsivePublishedSnapshot(
                    publication.snapshot,
                    ownerPendingDepthAtPublish:
                        publication.pendingWorkDepthAfterCompletion
                )
            }
            #endif
            threadAffineRimeCoordinator = coordinator
            responsiveKeyApplyContexts.removeAll()
            dualGatePendingPresentationSnapshot = nil
            dualGatePendingPresentationHasKnownSuccessor = false
            dualGatePresentationCoalesceScheduled = false
            rimeEngine = ThreadAffineRimeEngineBridge(coordinator: coordinator)
            #if T9_RESPONSIVE_CANARY_INTERNAL
            responsiveCanaryPresentationFenced = false
            pendingResponsiveCanaryVisibleSnapshot = nil
            lastResponsiveCanaryVisibilityTeardown = nil
            responsiveCanaryPreterminatedPresentations.removeAll(keepingCapacity: true)
            #endif
            return
        }

        // Fail closed for threadAffine without bootstrap: MainActor R2 path if engine exists.
        guard let underlying else {
            responsiveRimeCoordinator = nil
            responsiveKeyApplyContexts.removeAll()
            return
        }

        let coordinator = ResponsiveRimeSessionCoordinator(
            engine: underlying,
            // R5-Rem-2: honor latestOnly for UI publish coalesce. Engine still
            // applies every enqueued action; R3 contexts bind to applied head
            // (last matching context), not every intermediate paint.
            publishPolicy: publishPolicy,
            fixtureID: "T9RESP-R2",
            clock: clock
        )
        coordinator.setPublishHandler { [weak self] snapshot in
            self?.applyResponsivePublishedSnapshot(snapshot)
        }
        responsiveRimeCoordinator = coordinator
        threadAffineRimeCoordinator = nil
        responsiveKeyApplyContexts.removeAll()
        dualGatePendingPresentationSnapshot = nil
        dualGatePendingPresentationHasKnownSuccessor = false
        dualGatePresentationCoalesceScheduled = false
        // All session call sites go through the bridge → single serial pipeline.
        rimeEngine = ResponsiveRimeEngineBridge(
            underlyingEngine: underlying,
            coordinator: coordinator
        )
    }

    #if T9_RESPONSIVE_CANARY_INTERNAL
    /// Removes only an already positively terminated canary owner. This method
    /// never creates the baseline; the unique mode coordinator must grant that
    /// permit first and the Extension bootstrap performs the later creation.
    public func clearResponsiveCanaryAfterPositiveShutdown() {
        precondition(
            threadAffineRimeCoordinator?.isOwnerReady != true,
            "live canary owner cannot be cleared without positive shutdown"
        )
        threadAffineRimeCoordinator = nil
        responsiveRimeCoordinator = nil
        if rimeEngine is ThreadAffineRimeEngineBridge {
            rimeEngine = nil
        }
        isThreadAffineRimeOwnerEnabled = false
        isResponsiveRimePipelineEnabled = false
        threadAffineEngineBootstrap = nil
        responsiveKeyApplyContexts.removeAll()
        dualGatePendingPresentationSnapshot = nil
        dualGatePendingPresentationHasKnownSuccessor = false
        dualGatePresentationCoalesceScheduled = false
        responsivePresentationGeneration &+= 1
        responsiveCanaryPresentationFenced = true
        responsiveCanaryPreterminatedPresentations.removeAll(keepingCapacity: true)
        pendingResponsiveCanaryVisibleSnapshot = nil
        currentResponsiveCanarySessionInstance = 0
        responsiveCanarySessionIdentities.removeAll(keepingCapacity: true)
        isResponsiveCanaryOwnerInstalled = false
    }

    public func markResponsiveCanaryOwnerInstalled(
        runID: String,
        modeGeneration: UInt64,
        sessionInstance: UInt64
    ) {
        precondition(threadAffineRimeCoordinator?.isOwnerReady == true)
        threadAffineRimeCoordinator?.setCanarySessionInstance(sessionInstance)
        currentResponsiveCanarySessionInstance = sessionInstance
        responsiveCanarySessionIdentities[sessionInstance] = (runID, modeGeneration)
        isResponsiveCanaryOwnerInstalled = true
    }

    public func activateResponsiveCanarySessionInstance(
        runID: String,
        modeGeneration: UInt64,
        sessionInstance: UInt64
    ) {
        precondition(threadAffineRimeCoordinator?.isOwnerReady == true)
        threadAffineRimeCoordinator?.setCanarySessionInstance(sessionInstance)
        currentResponsiveCanarySessionInstance = sessionInstance
        responsiveCanarySessionIdentities[sessionInstance] = (runID, modeGeneration)
    }

    /// Fences presentation before the owner drain begins. Owner completions may
    /// still arrive, but they receive stale/fenced terminals and cannot mutate
    /// UI or host text.
    public func beginResponsiveCanaryPresentationFence() {
        responsiveCanaryPresentationFenced = true
        responsivePresentationGeneration &+= 1
        finalizeResponsiveCanaryFencedPresentations()
        dualGatePendingPresentationSnapshot = nil
        dualGatePendingPresentationHasKnownSuccessor = false
        dualGatePresentationCoalesceScheduled = false
        pendingResponsiveCanaryVisibleSnapshot = nil
    }

    public func resumeResponsiveCanaryPresentationAfterOwnerReady() {
        guard threadAffineRimeCoordinator?.isOwnerReady == true else { return }
        responsiveCanaryPresentationFenced = false
        pendingResponsiveCanaryVisibleSnapshot = nil
        lastResponsiveCanaryVisibilityTeardown = nil
    }

    /// Converts every owner-delivered but not yet MainActor-terminal PUBLISH
    /// into a stale terminal before an owner pointer or pipeline flag is cleared.
    public func finalizeResponsiveCanaryFencedPresentations() {
        guard let affine = threadAffineRimeCoordinator else { return }
        for identity in affine.pendingPresentationIdentities {
            let key = "\(identity.canarySessionInstance):"
                + "\(identity.sessionEpoch):\(identity.revision)"
            guard responsiveCanaryPreterminatedPresentations.insert(key).inserted else {
                continue
            }
            emitResponsiveCanaryTerminal(
                sessionEpoch: identity.sessionEpoch,
                revision: identity.revision,
                canarySessionInstance: identity.canarySessionInstance,
                completion: .staleAfterFence,
                visibility: .notVisibleFencedBeforeVisible,
                paint: .failedFencedBeforeVisible
            )
        }
    }
    #endif

    /// Apply a published responsive snapshot on MainActor and run gate-off-parity
    /// Path / auto-anchor post-processing when a key context is available (R3).
    ///
    /// R5-Rem-2:
    /// - Dual-gate: coalesce UI paints to latest under owner backlog (O2).
    /// - Contexts: under latestOnly, keep the **last** matching pk context so
    ///   multi-key drain does not require `.everyResult` UI publishes.
    /// - Engine FIFO is unchanged (all session actions still execute).
    func applyResponsivePublishedSnapshot(
        _ snapshot: ResponsiveRimeSnapshot?,
        coalesced: Bool = false,
        ownerPendingDepthAtPublish: Int? = nil,
        canarySessionInstance: UInt64 = 0
    ) {
        guard let snapshot else { return }

        #if T9_RESPONSIVE_CANARY_INTERNAL
        let terminalKey = "\(canarySessionInstance):"
            + "\(snapshot.sessionEpoch):\(snapshot.revision)"
        if responsiveCanaryPreterminatedPresentations.remove(terminalKey) != nil {
            return
        }
        #endif
        guard isResponsiveRimePipelineEnabled else { return }

        #if T9_RESPONSIVE_CANARY_INTERNAL
        if responsiveCanaryPresentationFenced {
            emitResponsiveCanaryTerminal(
                for: snapshot,
                canarySessionInstance: canarySessionInstance,
                completion: .staleAfterFence,
                visibility: .notVisibleFencedBeforeVisible,
                paint: .failedFencedBeforeVisible
            )
            return
        }
        // Reads only the owner-published immutable selection snapshot.
        applyRealizedSelectionFromEngine()
        if let selection = rimeEngine?.runtimeSelection {
            onResponsiveCanaryRuntimeSelection?(selection)
        }
        #endif

        // P2-D1: owner completion is recorded before any latest-only UI
        // coalescing. A missing UI paint must not be mistaken for missing
        // engine work, and the marker remains bound to the accepted revision.
        if isThreadAffineRimeOwnerEnabled,
           let ownerCompletion = feltMetrics.recordOwnerCompletion(
               epoch: snapshot.sessionEpoch,
               revision: snapshot.revision
           )
        {
            recordResponsiveFeltMarker(ownerCompletion)
        }

        // Dual-gate: prefer latest-only presentation while owner still has work.
        if isThreadAffineRimeOwnerEnabled, !coalesced {
            let livePendingDepth =
                threadAffineRimeCoordinator?.diagnostics.pendingWorkDepth ?? 0
            let pendingDepth = max(
                ownerPendingDepthAtPublish ?? 0,
                livePendingDepth
            )
            if pendingDepth >= ResponsiveRimeFeltMetrics.presentationCoalescePendingThreshold
                || dualGatePresentationCoalesceScheduled
                || dualGatePendingPresentationSnapshot != nil
            {
                #if T9_RESPONSIVE_CANARY_INTERNAL
                if let absorbed = dualGatePendingPresentationSnapshot,
                   absorbed.revision != snapshot.revision
                {
                    emitResponsiveCanaryTerminal(
                        for: absorbed,
                        canarySessionInstance: dualGatePendingCanarySessionInstance,
                        completion: .published,
                        visibility: .notVisibleCoalesced(
                            absorbedRevisionRange: absorbed.revision...absorbed.revision,
                            replacementRevision: snapshot.revision
                        ),
                        paint: .coalesced(
                            absorbedRevisionRange: absorbed.revision...absorbed.revision,
                            replacementRevision: snapshot.revision
                        )
                    )
                }
                #endif
                dualGatePendingPresentationSnapshot = snapshot
                dualGatePendingPresentationHasKnownSuccessor = pendingDepth > 0
                #if T9_RESPONSIVE_CANARY_INTERNAL
                dualGatePendingCanarySessionInstance = canarySessionInstance
                #endif
                scheduleDualGateCoalescedPresentation()
                return
            }
        }

        performResponsivePresentationApply(
            snapshot,
            coalesced: coalesced,
            canarySessionInstance: canarySessionInstance
        )
    }

    /// Flush latest dual-gate snapshot after backlog drains (MainActor).
    private func scheduleDualGateCoalescedPresentation() {
        guard !dualGatePresentationCoalesceScheduled else { return }
        dualGatePresentationCoalesceScheduled = true
        let generationAtSchedule = responsivePresentationGeneration
        Task { @MainActor [weak self] in
            guard let self else { return }
            // Yield so a burst of deliveries can collapse to one latest snapshot.
            var spins = 0
            while spins < 64 {
                await Task.yield()
                spins += 1
                // Abandon / rebuild invalidated this presentation generation.
                if self.responsivePresentationGeneration != generationAtSchedule {
                    self.dualGatePresentationCoalesceScheduled = false
                    return
                }
                let depth = self.threadAffineRimeCoordinator?.diagnostics.pendingWorkDepth ?? 0
                if depth == 0 { break }
            }
            self.dualGatePresentationCoalesceScheduled = false
            guard self.responsivePresentationGeneration == generationAtSchedule else { return }
            guard let latest = self.dualGatePendingPresentationSnapshot else { return }
            #if T9_RESPONSIVE_CANARY_INTERNAL
            let latestCanarySessionInstance = self.dualGatePendingCanarySessionInstance
            #endif
            let hasKnownSuccessor =
                self.dualGatePendingPresentationHasKnownSuccessor
            self.dualGatePendingPresentationSnapshot = nil
            self.dualGatePendingPresentationHasKnownSuccessor = false
            // A successor publication owns the replacement decision. Waiting
            // is state-driven; no timer or MainActor/owner backpressure is
            // required, and lifecycle generation changes still clear the buffer.
            if hasKnownSuccessor {
                self.dualGatePendingPresentationSnapshot = latest
                self.dualGatePendingPresentationHasKnownSuccessor = true
                #if T9_RESPONSIVE_CANARY_INTERNAL
                self.dualGatePendingCanarySessionInstance = latestCanarySessionInstance
                #endif
                return
            }
            // If more work arrived, re-buffer and reschedule.
            let depth = self.threadAffineRimeCoordinator?.diagnostics.pendingWorkDepth ?? 0
            if depth >= ResponsiveRimeFeltMetrics.presentationCoalescePendingThreshold {
                guard self.responsivePresentationGeneration == generationAtSchedule else { return }
                self.dualGatePendingPresentationSnapshot = latest
                self.dualGatePendingPresentationHasKnownSuccessor = true
                #if T9_RESPONSIVE_CANARY_INTERNAL
                self.dualGatePendingCanarySessionInstance = latestCanarySessionInstance
                #endif
                self.scheduleDualGateCoalescedPresentation()
                return
            }
            #if T9_RESPONSIVE_CANARY_INTERNAL
            self.performResponsivePresentationApply(
                latest,
                coalesced: true,
                expectedGeneration: generationAtSchedule,
                canarySessionInstance: latestCanarySessionInstance
            )
            #else
            self.performResponsivePresentationApply(
                latest,
                coalesced: true,
                expectedGeneration: generationAtSchedule
            )
            #endif
        }
    }

    /// Live session epoch for responsive presentation gating (nil if gate-off).
    private func liveResponsiveSessionEpoch() -> UInt64? {
        if isThreadAffineRimeOwnerEnabled, let affine = threadAffineRimeCoordinator {
            return affine.diagnostics.sessionEpoch
        }
        if let main = responsiveRimeCoordinator {
            return main.diagnostics.sessionEpoch
        }
        return nil
    }

    /// True when this snapshot may still update visible composition authority.
    private func isLivePresentationSnapshot(
        _ snapshot: ResponsiveRimeSnapshot,
        expectedGeneration: UInt64?
    ) -> Bool {
        if let expectedGeneration, expectedGeneration != responsivePresentationGeneration {
            return false
        }
        if let liveEpoch = liveResponsiveSessionEpoch(),
           snapshot.sessionEpoch != liveEpoch
        {
            return false
        }
        // Rem-3: while L1 is ahead, allow L2 with revision >= watermark floor
        // (equal OK so engine replaces structure-only L1 at the same rev).
        if provisionalCompositionMirror.isProvisionalAhead,
           snapshot.sessionEpoch == provisionalCompositionMirror.sessionEpoch
        {
            let floor = max(lastPresentedRevision, provisionalCompositionMirror.watermark)
            return snapshot.revision >= floor
        }
        // Never paint an older-or-equal revision over a newer one in the same epoch.
        if snapshot.sessionEpoch == lastPresentedSessionEpoch,
           snapshot.revision <= lastPresentedRevision
        {
            return false
        }
        return true
    }

    private func performResponsivePresentationApply(
        _ snapshot: ResponsiveRimeSnapshot,
        coalesced: Bool,
        expectedGeneration: UInt64? = nil,
        canarySessionInstance: UInt64 = 0
    ) {
        // Arch P1-1: fail closed if abandon/reset superseded this paint.
        guard isLivePresentationSnapshot(snapshot, expectedGeneration: expectedGeneration) else {
            #if T9_RESPONSIVE_CANARY_INTERNAL
            if responsiveCanaryPresentationFenced {
                emitResponsiveCanaryTerminal(
                    for: snapshot,
                    canarySessionInstance: canarySessionInstance,
                    completion: .staleAfterFence,
                    visibility: .notVisibleFencedBeforeVisible,
                    paint: .failedFencedBeforeVisible
                )
            } else {
                let replacement = max(lastPresentedRevision, snapshot.revision)
                emitResponsiveCanaryTerminal(
                    for: snapshot,
                    canarySessionInstance: canarySessionInstance,
                    completion: .published,
                    visibility: .notVisibleCoalesced(
                        absorbedRevisionRange: snapshot.revision...snapshot.revision,
                        replacementRevision: replacement
                    ),
                    paint: .coalesced(
                        absorbedRevisionRange: snapshot.revision...snapshot.revision,
                        replacementRevision: replacement
                    )
                )
            }
            #endif
            return
        }

        let pendingAfter: Int
        if isThreadAffineRimeOwnerEnabled {
            pendingAfter = threadAffineRimeCoordinator?.diagnostics.pendingWorkDepth ?? 0
        } else {
            pendingAfter = responsiveRimeCoordinator?.diagnostics.pendingDepth ?? 0
        }

        // Content-free felt metrics (Rem-1).
        let metrics = feltMetrics.recordPresentation(
            revision: snapshot.revision,
            pendingAfter: pendingAfter,
            coalesced: coalesced
        )
        recordResponsiveFeltMarker(metrics.presentationLine)
        if let burst = metrics.burstLine {
            recordResponsiveFeltMarker(burst)
        }
        if let visible = feltMetrics.recordVisible(
            revision: snapshot.revision,
            source: .engine
        ) {
            recordResponsiveFeltMarker(visible)
        }

        // Re-check after metrics (abandon can race on MainActor between awaits).
        guard isLivePresentationSnapshot(snapshot, expectedGeneration: expectedGeneration) else {
            return
        }
        // Rem-3 / Polish: L2 wins — cancel deferred L1 visual and clear ledger.
        cancelDeferredProvisionalVisualPaint()
        if provisionalCompositionMirror.isProvisionalAhead
            || provisionalCompositionMirror.isActive
        {
            provisionalCompositionMirror.alignToEngineApply(
                epoch: snapshot.sessionEpoch,
                revision: snapshot.revision
            )
        }
        lastPresentedSessionEpoch = snapshot.sessionEpoch
        lastPresentedRevision = snapshot.revision
        #if T9_RESPONSIVE_CANARY_INTERNAL
        pendingResponsiveCanaryVisibleSnapshot = (
            snapshot: snapshot,
            canarySessionInstance: canarySessionInstance
        )
        #endif

        // Drop contexts invalidated by epoch barriers (abandon / reset / recover).
        while let head = responsiveKeyApplyContexts.first,
              head.sessionEpoch != snapshot.sessionEpoch
        {
            responsiveKeyApplyContexts.removeFirst()
        }

        // Nested Bridge publishes (ord-*) must not consume processKey contexts.
        // Under latestOnly / dual-gate coalesce, one paint may cover N keys —
        // keep only the last matching pk context (applied head).
        let ctx: ResponsiveKeyApplyContext?
        if snapshot.actionID.hasPrefix("pk-") {
            var last: ResponsiveKeyApplyContext?
            while let head = responsiveKeyApplyContexts.first,
                  head.sessionEpoch == snapshot.sessionEpoch
            {
                last = responsiveKeyApplyContexts.removeFirst()
            }
            ctx = last
        } else {
            ctx = nil
        }

        let output = augmentRimeOutputIfNeeded(snapshot.output)
        // Prefer underlying session for post-process (already applied processKey).
        // Thread-affine mode has no MainActor live engine — presentation-only path.
        let engineForPostProcess = underlyingRimeEngine
        guard let engineForPostProcess else {
            applyRimeOutput(output)
            if usesT9InputSemantics {
                _ = refreshT9PinyinPathState(forceNewProvenance: false)
            }
            notifyResponsivePresentation(pathChanged: usesT9InputSemantics)
            return
        }

        // Temporarily expose underlying as `rimeEngine` so Path resync helpers that
        // read `self.rimeEngine` do not re-enter the Bridge pipeline (Arch P1-2).
        // Also suppress publish handler if any Bridge path is still hit.
        let bridge = rimeEngine as? ResponsiveRimeEngineBridge
        let runPostProcess = { [self] in
            if bridge != nil {
                rimeEngine = engineForPostProcess
            }
            defer {
                if let bridge {
                    rimeEngine = bridge
                }
            }

            if let ctx,
               rejectUnusableAcceptedT9AutoAnchorDigitIfNeeded(
                   ctx.rimeKey,
                   previousLedger: state.t9ReversibleAutoAnchorState,
                   output: output,
                   using: engineForPostProcess
               )
            {
                notifyResponsivePresentation(pathChanged: true)
                return
            }

            if output.composition == nil,
               output.committedText == nil,
               !engineForPostProcess.isComposing(),
               let ctx
            {
                let intendedComposition =
                    state.currentComposition + fallbackInputText(for: ctx.rimeKey)
                if restoreRimeComposition(
                    intendedComposition,
                    using: engineForPostProcess,
                    rebuildSession: true
                ) {
                    notifyResponsivePresentation(pathChanged: true)
                    return
                }
                shouldRestoreRimeComposition = true
                shouldRebuildSessionDuringRestore = true
                state.lastRimeOutput = nil
                notifyResponsivePresentation(pathChanged: true)
                return
            }

            applyRimeOutput(output)
            var pathChanged = usesT9InputSemantics
            if let ctx {
                var retainedFocusedSegment = false
                if output.committedText == nil,
                   ctx.rimeKey.count == 1,
                   let digit = ctx.rimeKey.first
                {
                    retainedFocusedSegment = retainFocusedT9SegmentAfterAppendingDigit(
                        previous: ctx.previousT9PathState,
                        digit: digit
                    )
                }
                advanceAcceptedT9AutoAnchorDigit(
                    ctx.rimeKey,
                    previousLiveRawInput: ctx.previousRawForTrace,
                    output: output
                )
                let autoAnchorOutcome = attemptReversibleT9AutoAnchorIfNeeded(
                    using: engineForPostProcess
                )
                if retainedFocusedSegment || autoAnchorOutcome.status != .notEligible {
                    pathChanged = true
                } else if usesT9InputSemantics {
                    _ = refreshT9PinyinPathState(forceNewProvenance: false)
                    pathChanged = true
                }
            } else if usesT9InputSemantics {
                _ = refreshT9PinyinPathState(forceNewProvenance: false)
            }
            notifyResponsivePresentation(pathChanged: pathChanged)
        }

        if let coordinator = responsiveRimeCoordinator {
            coordinator.withPublishHandlerSuppressed(runPostProcess)
        } else {
            runPostProcess()
        }
    }

    private func notifyResponsivePresentation(pathChanged: Bool) {
        // Amendment B: retain only the latest host-visible L2 marked text as a
        // visual shadow prefix. L1 itself never calls this bridge, so stale
        // Candidate/Path chrome remains stable while Core guards interactions.
        captureResponsiveStablePreeditIfReady()
        var effects: KeyboardEffect = [.compositionChanged]
        if pathChanged {
            effects.insert(.t9PinyinPathsChanged)
        }
        #if T9_RESPONSIVE_CANARY_INTERNAL
        // The callback's synchronous Bool is the bounded completion point. It
        // may return true only after the Extension completes syncUI.
        let paintCompleted = onResponsiveCanaryPresentationNeeded?(effects) == true
        if let pending = pendingResponsiveCanaryVisibleSnapshot {
            pendingResponsiveCanaryVisibleSnapshot = nil
            emitResponsiveCanaryTerminal(
                for: pending.snapshot,
                canarySessionInstance: pending.canarySessionInstance,
                completion: .published,
                visibility: .visible(presentationRevision: pending.snapshot.revision),
                paint: paintCompleted
                    ? .painted
                    : .failedVisible(reason: .uiSynchronizationFailed)
            )
        }
        #else
        onResponsivePresentationNeeded?(effects)
        #endif
    }

    #if T9_RESPONSIVE_CANARY_INTERNAL
    private func emitResponsiveCanaryTerminal(
        for snapshot: ResponsiveRimeSnapshot,
        canarySessionInstance: UInt64? = nil,
        completion: ResponsiveRimeCanaryPublishCompletion,
        visibility: ResponsiveRimeCanaryVisibilityDisposition,
        paint: ResponsiveRimeCanaryPaintTerminal
    ) {
        emitResponsiveCanaryTerminal(
            sessionEpoch: snapshot.sessionEpoch,
            revision: snapshot.revision,
            canarySessionInstance: canarySessionInstance,
            completion: completion,
            visibility: visibility,
            paint: paint
        )
    }

    private func emitResponsiveCanaryTerminal(
        sessionEpoch: UInt64,
        revision: UInt64,
        canarySessionInstance: UInt64? = nil,
        completion: ResponsiveRimeCanaryPublishCompletion,
        visibility: ResponsiveRimeCanaryVisibilityDisposition,
        paint: ResponsiveRimeCanaryPaintTerminal
    ) {
        let resolvedSessionInstance = canarySessionInstance
            ?? currentResponsiveCanarySessionInstance
        let sessionIdentity = responsiveCanarySessionIdentities[resolvedSessionInstance]
        onResponsiveCanaryPresentationTerminal?(
            ResponsiveRimeCanaryPresentationTerminal(
                runID: sessionIdentity?.runID ?? "",
                modeGeneration: sessionIdentity?.modeGeneration ?? 0,
                canarySessionInstance: resolvedSessionInstance,
                sessionEpoch: sessionEpoch,
                revision: revision,
                completion: completion,
                visibility: visibility,
                paint: paint
            )
        )
        threadAffineRimeCoordinator?.acknowledgePresentationTerminal(
            canarySessionInstance: resolvedSessionInstance,
            sessionEpoch: sessionEpoch,
            revision: revision
        )
    }
    #endif

    /// Keep the latest safe host marked text as the L1 visual-shadow prefix.
    ///
    /// The helper is intentionally MainActor-owned and only observes the host
    /// projection. Engine-output completion, marked-text updates and ordered
    /// actions all use this same boundary so no Delete/restore sub-path can
    /// leave an older prefix behind for the next provisional key.
    func captureResponsiveStablePreeditIfReady() {
        guard isResponsiveRimePipelineEnabled,
              isThreadAffineRimeOwnerEnabled,
              !provisionalCompositionMirror.isProvisionalAhead
        else {
            return
        }
        provisionalCompositionMirror.setStablePreedit(state.insertedPreeditText)
    }

    func clearResponsiveKeyApplyContexts() {
        responsiveKeyApplyContexts.removeAll(keepingCapacity: true)
        dualGatePendingPresentationSnapshot = nil
        dualGatePendingPresentationHasKnownSuccessor = false
        dualGatePresentationCoalesceScheduled = false
        // Invalidate in-flight dual-gate coalesce Tasks and stale presentation.
        responsivePresentationGeneration &+= 1
        lastPresentedSessionEpoch = 0
        lastPresentedRevision = 0
        cancelDeferredProvisionalVisualPaint()
        provisionalCompositionMirror.clear()
        feltMetrics.reset()
    }

    /// Rem-3: fail closed for selection / Path / 选定 while L1 is ahead of L2.
    func rejectIfResponsiveProvisionalAhead(
        _ site: StaticString = #function
    ) -> Bool {
        guard provisionalCompositionMirror.isProvisionalAhead else { return false }
        Logger.shared.performance(
            "T9RESP marker=L1_FAIL_CLOSED site=\(site) "
                + "fixture=\(ResponsiveRimeFeltMetrics.fixtureID)"
        )
        return true
    }

    /// Rem-3 Layer Rule 3: drop L1 without ever committing `·` to the host.
    func abandonResponsiveProvisionalL1WithoutHostCommit() {
        guard provisionalCompositionMirror.isProvisionalAhead
            || provisionalCompositionMirror.isActive
            || state.currentComposition.contains(ResponsiveProvisionalComposition.placeholderScalar)
        else {
            return
        }
        cancelDeferredProvisionalVisualPaint()
        provisionalCompositionMirror.clear()
        state.currentComposition = ""
        state.lastRimeOutput = nil
        state.partialCommit = nil
        if usesT9InputSemantics {
            clearT9PinyinPathState()
        }
        updateInlinePreedit("", source: .compositionProjection)
    }

    /// Rem-3: ordered engine apply (Delete / performOrderedNow) must clear L1 ledger.
    func alignResponsiveProvisionalAfterOrderedEngineApply() {
        guard isResponsiveRimePipelineEnabled, isThreadAffineRimeOwnerEnabled else {
            return
        }
        cancelDeferredProvisionalVisualPaint()
        provisionalCompositionMirror.clearPending()
        // Ordered actions (notably Delete) return a fresh host snapshot before
        // the bridge's publish callback necessarily reaches MainActor. Capture
        // the current safe snapshot after clearing the pending ledger; the
        // engine-output completion boundary below will refresh it again after
        // the branch has installed its new marked text.
        captureResponsiveStablePreeditIfReady()
    }

    private func cancelDeferredProvisionalVisualPaint() {
        provisionalVisualPaintGeneration &+= 1
    }

    /// Rem-3: after dual-gate processKey accept, arm L1 ledger + deferred visual.
    ///
    /// Rem-3-Polish: do **not** paint dots/chrome immediately. Fast engine
    /// results replace the streak before the delay and skip empty→full thrash.
    func applyResponsiveProvisionalL1IfEligible(rimeKey: String) {
        // Dual-gate only (thread-affine owner + responsive gate).
        guard isResponsiveRimePipelineEnabled, isThreadAffineRimeOwnerEnabled else {
            logL1Skip(.noDual)
            return
        }
        guard usesT9InputSemantics else {
            logL1Skip(.nonT9)
            return
        }
        guard ResponsiveProvisionalComposition.isT9DigitKey(rimeKey) else {
            logL1Skip(.nonT9)
            return
        }
        let receipt = threadAffineRimeCoordinator?.lastAcceptReceipt
        guard let receipt else {
            logL1Skip(.emptyLedger)
            return
        }
        if let skip = provisionalCompositionMirror.appendT9DigitAccept(
            revision: receipt.revision,
            epoch: receipt.sessionEpoch
        ) {
            logL1Skip(skip)
            return
        }
        guard let presentation = provisionalCompositionMirror.makePresentation() else {
            logL1Skip(.emptyLedger)
            return
        }
        // Raise presentation floor so older L2 cannot roll back L1 (ledger ahead).
        if lastPresentedSessionEpoch == presentation.sessionEpoch {
            lastPresentedRevision = max(lastPresentedRevision, presentation.watermark)
        } else if lastPresentedSessionEpoch == 0
            || presentation.sessionEpoch != lastPresentedSessionEpoch
        {
            lastPresentedSessionEpoch = presentation.sessionEpoch
            lastPresentedRevision = presentation.watermark
        }
        scheduleDeferredProvisionalVisualPaint(presentation)
    }

    /// Delayed L1 visual: only runs if still provisionalAhead after the delay.
    private func scheduleDeferredProvisionalVisualPaint(
        _ presentation: ResponsiveProvisionalPresentation
    ) {
        provisionalVisualPaintGeneration &+= 1
        let generation = provisionalVisualPaintGeneration
        let delay = provisionalVisualPaintDelayNanoseconds
        Task { @MainActor [weak self] in
            if delay > 0 {
                try? await Task.sleep(nanoseconds: delay)
            } else {
                await Task.yield()
            }
            guard let self else { return }
            guard generation == self.provisionalVisualPaintGeneration else { return }
            guard self.provisionalCompositionMirror.isProvisionalAhead else { return }
            // Only paint if ledger still covers at least this watermark streak head.
            guard self.provisionalCompositionMirror.sessionEpoch == presentation.sessionEpoch,
                  self.provisionalCompositionMirror.watermark >= presentation.watermark
            else {
                return
            }
            // Re-read current presentation (more accepts may have extended ·×N).
            guard let live = self.provisionalCompositionMirror.makePresentation() else {
                return
            }
            self.applyProvisionalL1Visual(live)
        }
    }

    /// Apply the visual shadow preedit only — never touch candidate/Path chrome.
    ///
    /// Rem-3-Polish-2 (device feedback): do **not** call
    /// `onResponsivePresentationNeeded` here — Extension `syncUI` would
    /// `refreshCandidateBar` / Path on every L1 tick (empty or re-layout flash).
    /// Host marked text is updated directly; last L2 candidate/Path stay until
    /// engine L2 paint. Selection remains fail-closed while ahead.
    private func applyProvisionalL1Visual(_ presentation: ResponsiveProvisionalPresentation) {
        // `currentComposition` remains the engine/raw recovery state under T9;
        // the visual shadow belongs to `insertedPreeditText`/host marked text.
        updateInlinePreedit(presentation.preedit, source: .compositionProjection)

        if let visible = feltMetrics.recordVisible(
            revision: presentation.watermark,
            source: .provisional
        ) {
            recordResponsiveFeltMarker(visible)
        }
    }

    private func logL1Skip(_ reason: ResponsiveProvisionalL1SkipReason) {
        // Avoid spam on non-dual / non-T9 paths: only log when dual-gate is live.
        guard isResponsiveRimePipelineEnabled, isThreadAffineRimeOwnerEnabled else {
            return
        }
        if reason == .nonT9, !usesT9InputSemantics {
            return
        }
        Logger.shared.performance(ResponsiveRimeFeltMetrics.l1SkipMarkerLine(reason: reason))
    }

    func enqueueResponsiveKeyApplyContext(
        rimeKey: String,
        previousT9PathState: T9PinyinPathState,
        previousRawForTrace: String?
    ) {
        let epoch: UInt64
        if let main = responsiveRimeCoordinator {
            epoch = main.diagnostics.sessionEpoch
        } else if let published = threadAffineRimeCoordinator?.lastPublished {
            epoch = published.sessionEpoch
        } else if let receipt = threadAffineRimeCoordinator?.lastAcceptReceipt {
            epoch = receipt.sessionEpoch
        } else {
            epoch = 1
        }
        responsiveKeyApplyContexts.append(
            ResponsiveKeyApplyContext(
                rimeKey: rimeKey,
                previousT9PathState: previousT9PathState,
                previousRawForTrace: previousRawForTrace,
                sessionEpoch: epoch
            )
        )
    }

    /// Rem-1: record ACCEPT marker after responsive key accept.
    func recordResponsiveAcceptMetrics(from receipt: ResponsiveRimeAcceptReceipt?) {
        guard let receipt else { return }
        let line = feltMetrics.recordAccept(
            revision: receipt.revision,
            epoch: receipt.sessionEpoch,
            pending: receipt.pendingDepthAfterAccept
        )
        recordResponsiveFeltMarker(line)
    }

    /// Keep all explicit preflight felt markers on the mandatory content-free
    /// channel. Ordinary builds retain the regular diagnostic category filter.
    private func recordResponsiveFeltMarker(_ line: String) {
        #if T9_AUTO_ANCHOR_DEVICE_PREFLIGHT
        Logger.shared.devicePreflightPerformance(line)
        #else
        Logger.shared.performance(line)
        #endif
    }

    /// R4-Wire helper — nil when dual-gate path is inactive or OS-unavailable.
        func threadAffineCoordinatorIfAvailable() -> ThreadAffineRimeSessionCoordinator? {
        threadAffineRimeCoordinator
    }

    /// Schedule deferred drain turns after `scheduleProcessKey` so `handle` can
    /// return before librime (MainActor cooperative yield between items).
    func scheduleResponsivePipelineDrain(_ coordinator: ResponsiveRimeSessionCoordinator) {
        Task { @MainActor [weak self] in
            // Yield once so the current `handle` stack unwinds first.
            await Task.yield()
            guard let self, self.isResponsiveRimePipelineEnabled else { return }
            while coordinator.drainOneStep() {
                // Yield between keys so multi-accept stays ordered without one
                // monolithic blocking burst when engine work is short.
                await Task.yield()
            }
            _ = self
        }
    }

    /// Reset RIME after the keyboard becomes visible again while preserving
    /// enough state to reconstruct an in-progress inline composition.
    public func resetRimeSessionForVisibilityChange() {
        guard rimeEngine != nil else { return }
        if isResponsiveRimePipelineEnabled, let affine = threadAffineRimeCoordinator {
            _ = affine.performOrderedNow(.resetSession)
            clearResponsiveKeyApplyContexts()
        } else if isResponsiveRimePipelineEnabled, let coordinator = responsiveRimeCoordinator {
            // Ordered reset through the same owner; epoch advances via reset work.
            _ = coordinator.performOrderedNow(.resetSession)
            clearResponsiveKeyApplyContexts()
        } else {
            rimeEngine?.resetSession()
        }
        shouldRestoreRimeComposition = !state.currentComposition.isEmpty
        shouldRebuildSessionDuringRestore = false
    }

    /// Drops unfinished input when the keyboard is hidden or shown again.
    ///
    /// Visibility changes are different from a transient RIME session loss:
    /// the user sees a newly presented keyboard, so stale composition and
    /// candidates must not remain visible from the previous host interaction.
    @discardableResult
    public func abandonCompositionForVisibilityChange() -> KeyboardEffect {
        let hadVisibleComposition =
            !state.currentComposition.isEmpty
            || state.lastRimeOutput != nil
            || state.partialCommit != nil
            || state.typoCorrection != nil
            || !state.continuation.isEmpty
            || state.insertedPreeditCount > 0
            || !state.insertedPreeditText.isEmpty

        if isResponsiveRimePipelineEnabled, let affine = threadAffineRimeCoordinator {
            affine.bumpSessionEpoch(resetEngineSession: true)
            clearResponsiveKeyApplyContexts()
        } else if isResponsiveRimePipelineEnabled, let coordinator = responsiveRimeCoordinator {
            coordinator.bumpSessionEpoch(resetEngineSession: true)
            // Arch R3 P1-1: epoch barrier must invalidate deferred apply contexts.
            clearResponsiveKeyApplyContexts()
        } else {
            rimeEngine?.resetSession()
        }
        shouldRestoreRimeComposition = false
        shouldRebuildSessionDuringRestore = false
        deleteInlinePreedit()
        state.currentComposition = ""
        state.lastRimeOutput = nil
        state.partialCommit = nil
        state.typoCorrection = nil
        state.continuation = ContinuationState()
        state.insertedPreeditText = ""
        state.insertedPreeditCount = 0
        let hadPinyinPaths = !state.t9PinyinPathState.compactPaths.isEmpty
            || state.t9PinyinPathState.selectedPath != nil
        clearT9PinyinPathState()

        var effects: KeyboardEffect = []
        if hadVisibleComposition {
            effects.formUnion([.compositionChanged, .continuationChanged])
        }
        if hadPinyinPaths {
            effects.insert(.t9PinyinPathsChanged)
        }
        return effects
    }

    /// 在扩展进入不可见状态前释放 RIME 的进程级资源。
    /// 必须由 UI 生命周期同步调用，不能推迟到不可预测的 `deinit`。
    public func suspendRimeForVisibilityChange() {
        if isResponsiveRimePipelineEnabled, let affine = threadAffineRimeCoordinator {
            #if T9_RESPONSIVE_CANARY_INTERNAL
            lastResponsiveCanaryVisibilityTeardown = affine.suspendForVisibilityChange()
            #else
            affine.suspendForVisibilityChange()
            #endif
        } else if isResponsiveRimePipelineEnabled, let coordinator = responsiveRimeCoordinator {
            coordinator.suspendForVisibilityChange()
        } else {
            rimeEngine?.suspendForVisibilityChange()
        }
    }

    /// 在扩展重新可见时恢复 RIME runtime 与 session。
    /// Also reapplies fail-closed / realized T9 semantics from the engine selection.
    public func resumeRimeAfterVisibilityChange() {
        if isResponsiveRimePipelineEnabled, let affine = threadAffineRimeCoordinator {
            affine.resumeAfterVisibilityChange()
        } else if isResponsiveRimePipelineEnabled, let coordinator = responsiveRimeCoordinator {
            coordinator.resumeAfterVisibilityChange()
        } else {
            rimeEngine?.resumeAfterVisibilityChange()
        }
        applyRealizedSelectionFromEngine()
    }

    /// Align `usesT9InputSemantics` with the engine's last published realized selection.
    /// Extension chrome still reloads via `onRuntimeSelectionChanged`.
    public func applyRealizedSelectionFromEngine() {
        guard let selection = rimeEngine?.runtimeSelection else { return }
        usesT9InputSemantics = selection.usesT9InputSemantics
    }

    // MARK: - Public entry point

    @discardableResult
    public func handle(_ action: KeyboardAction) -> KeyboardEffect {
        switch action {
        case .insertKey(let key):
            return handleInsertKey(key)
        case .insertCandidate(let candidate, let kind, let selectionReference):
            return handleInsertCandidate(
                candidate,
                kind: kind,
                selectionReference: selectionReference
            )
        case .insertCorrectionCandidate(let correction):
            return handleInsertCorrectionCandidate(correction)
        case .insertDirectText(let text):
            return handleInsertDirectText(text, source: .directText)
        case .insertEmoji(let emoji):
            return handleInsertDirectText(emoji, source: .emoji)
        case .toggleShift:
            return handleToggleShift()
        case .togglePage:
            return handleTogglePage()
        case .toggleInputMode:
            return handleToggleInputMode()
        case .insertSpace:
            return handleInsertSpace()
        case .insertReturn:
            return handleInsertReturn()
        case .deleteBackward:
            return handleDeleteBackward()
        case .keyboardTypeChanged(let type):
            return handleKeyboardTypeChanged(type)
        case .selectT9PinyinPath(let path):
            return handleSelectT9PinyinPath(path)
        case .cycleT9PinyinPath:
            return handleCycleT9PinyinPath()
        case .candidatePageUp:
            return handleCandidatePageUp()
        case .candidatePageDown:
            return handleCandidatePageDown()
        }
    }
}
