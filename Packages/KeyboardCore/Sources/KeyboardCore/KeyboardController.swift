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
            coordinator.setPublishHandler { [weak self] snapshot in
                self?.applyResponsivePublishedSnapshot(snapshot)
            }
            threadAffineRimeCoordinator = coordinator
            responsiveKeyApplyContexts.removeAll()
            rimeEngine = ThreadAffineRimeEngineBridge(coordinator: coordinator)
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
            // everyResult keeps one publish callback per processNext so R3
            // post-processing contexts stay 1:1 with drained keys.
            publishPolicy: publishPolicy == .latestOnly ? .everyResult : publishPolicy,
            fixtureID: "T9RESP-R2",
            clock: clock
        )
        coordinator.setPublishHandler { [weak self] snapshot in
            self?.applyResponsivePublishedSnapshot(snapshot)
        }
        responsiveRimeCoordinator = coordinator
        threadAffineRimeCoordinator = nil
        responsiveKeyApplyContexts.removeAll()
        // All session call sites go through the bridge → single serial pipeline.
        rimeEngine = ResponsiveRimeEngineBridge(
            underlyingEngine: underlying,
            coordinator: coordinator
        )
    }

    /// Apply a published responsive snapshot on MainActor and run gate-off-parity
    /// Path / auto-anchor post-processing when a key context is available (R3).
    ///
    /// R3 P1 fixes:
    /// - Only consume FIFO context for deferred `pk-*` processKey publishes.
    /// - Drop contexts whose epoch no longer matches the snapshot.
    /// - Post-process mutations use **underlying** engine (not Bridge) so
    ///   Path/auto-anchor cannot re-enter `performOrderedNow` and steal contexts.
    func applyResponsivePublishedSnapshot(_ snapshot: ResponsiveRimeSnapshot?) {
        guard isResponsiveRimePipelineEnabled, let snapshot else { return }

        // R5-Preflight: content-free publish marker (no raw input / candidates).
        if isThreadAffineRimeOwnerEnabled {
            Logger.shared.performance(
                ResponsiveRimePreflight.publishMarkerLine(
                    epoch: snapshot.sessionEpoch,
                    revision: snapshot.revision
                )
            )
        }

        // Drop contexts invalidated by epoch barriers (abandon / reset / recover).
        while let head = responsiveKeyApplyContexts.first,
              head.sessionEpoch != snapshot.sessionEpoch
        {
            responsiveKeyApplyContexts.removeFirst()
        }

        // Nested Bridge publishes (ord-*) must not consume processKey contexts.
        let ctx: ResponsiveKeyApplyContext?
        if snapshot.actionID.hasPrefix("pk-"),
           let head = responsiveKeyApplyContexts.first,
           head.sessionEpoch == snapshot.sessionEpoch
        {
            ctx = responsiveKeyApplyContexts.removeFirst()
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
        var effects: KeyboardEffect = [.compositionChanged]
        if pathChanged {
            effects.insert(.t9PinyinPathsChanged)
        }
        onResponsivePresentationNeeded?(effects)
    }

    func clearResponsiveKeyApplyContexts() {
        responsiveKeyApplyContexts.removeAll(keepingCapacity: true)
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
            affine.suspendForVisibilityChange()
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
