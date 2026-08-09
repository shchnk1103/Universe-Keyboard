import KeyboardCore
import RimeBridge
import UIKit

extension KeyboardViewController {
    /// Configures only lightweight session work required before the keyboard can accept input.
    func bootstrapKeyboard() {
        let startupTime = CACurrentMediaTime()

        // Request a compact keyboard height while keeping the system-provided outer container.
        view.isOpaque = false
        view.backgroundColor = .clear
        installPreferredKeyboardHeight()

        let keyboardType = KeyboardType.from(uiKeyboardType: textDocumentProxy.keyboardType)
        controller = KeyboardController(state: KeyboardState(activeKeyboardType: keyboardType))
        // R2: when the responsive gate is on, deferred snapshot apply must re-enter UI.
        // Gate defaults off — this bridge is inert until Product enables the gate.
        controller.onResponsivePresentationNeeded = { [weak self] effects in
            guard let self else { return }
            self.syncUI(with: effects)
            #if DEBUG && T9_P3_D1_LIFECYCLE_HARNESS
            self.p3d1LifecycleAppliedCount &+= 1
            self.p3d1RecordLifecycleMarker("PUBLISH", reason: "ownerApply")
            #endif
        }
        #if T9_RESPONSIVE_CANARY_INTERNAL
        controller.onResponsiveCanaryPresentationNeeded = { [weak self] effects in
            guard let self else { return false }
            self.syncUI(with: effects)
            return true
        }
        controller.onResponsiveCanaryPresentationTerminal = { [weak self] terminal in
            guard let self else { return }
            if !self.responsiveCanaryModeCoordinator.recordPresentationTerminal(terminal) {
                if case .visibilityEnding = self.responsiveCanaryModeCoordinator.state {
                    // Do not mutate the mode state until the visibility path has
                    // unconditionally destroyed the still-live owner.
                    self.responsiveCanaryVisibilityContractFailure = true
                } else {
                    self.terminateActiveCanary(reason: "presentationContractFailure")
                }
            }
        }
        controller.onResponsiveCanaryRuntimeSelection = { [weak self] selection in
            self?.applyRealizedRuntimeSelection(selection)
        }
        #endif
        #if T9_AUTO_ANCHOR_DEVICE_PREFLIGHT_ENABLED && !T9_AUTO_ANCHOR_DEVICE_PREFLIGHT
        #error("T9_AUTO_ANCHOR_DEVICE_PREFLIGHT_ENABLED requires T9_AUTO_ANCHOR_DEVICE_PREFLIGHT")
        #endif
        #if T9_AUTO_ANCHOR_ROLLING_PREFLIGHT_ENABLED && !T9_AUTO_ANCHOR_DEVICE_PREFLIGHT_ENABLED
        #error("T9_AUTO_ANCHOR_ROLLING_PREFLIGHT_ENABLED requires the A1 preflight gate")
        #endif
        #if T9_AUTO_ANCHOR_TRIPLE_ROLLING_PREFLIGHT_ENABLED && !T9_AUTO_ANCHOR_ROLLING_PREFLIGHT_ENABLED
        #error("T9_AUTO_ANCHOR_TRIPLE_ROLLING_PREFLIGHT_ENABLED requires the B2 rolling preflight gate")
        #endif
        #if T9_AUTO_ANCHOR_EARLIER_FIRST_PREFLIGHT_ENABLED && !T9_AUTO_ANCHOR_DEVICE_PREFLIGHT_ENABLED
        #error("T9_AUTO_ANCHOR_EARLIER_FIRST_PREFLIGHT_ENABLED requires the A1 preflight gate")
        #endif
        #if DEBUG
        // ADR 0024 Stage 2: explicit diagnostic gate. Release keeps the
        // controller capability off until Product/Architecture/Quality review.
        controller.isReversibleT9AutoAnchorEnabled = true
        #elseif T9_AUTO_ANCHOR_DEVICE_PREFLIGHT_ENABLED
        // S6-A internal B arm only. This condition is injected by the reviewed
        // command line and must never appear in project/archive defaults.
        controller.isReversibleT9AutoAnchorEnabled = true
        #endif
        #if T9_AUTO_ANCHOR_ROLLING_PREFLIGHT_ENABLED
        // S2.1 internal B2 arm only. Ordinary Debug/A1 and Release stay on the
        // established one-anchor behavior unless this explicit flag is added.
        controller.isRollingT9AutoAnchorEnabled = true
        #endif
        #if T9_AUTO_ANCHOR_TRIPLE_ROLLING_PREFLIGHT_ENABLED
        // S2.2 internal B3 arm only. Nested on B2; never a project default.
        controller.isTripleRollingT9AutoAnchorEnabled = true
        #endif
        #if T9_AUTO_ANCHOR_EARLIER_FIRST_PREFLIGHT_ENABLED
        // S2.3 internal earlier-first arm only. Orthogonal to rolling/triple;
        // requires A1; never a project default.
        controller.isEarlierFirstT9AutoAnchorEnabled = true
        #endif
        #if T9_RESPONSIVE_CANARY_INTERNAL
        // CANARY-001 v1 excludes reversible auto-anchor before any live RIME
        // access, even when the internal artifact also uses a Debug configuration.
        controller.isReversibleT9AutoAnchorEnabled = false
        controller.isRollingT9AutoAnchorEnabled = false
        controller.isTripleRollingT9AutoAnchorEnabled = false
        controller.isEarlierFirstT9AutoAnchorEnabled = false
        #endif
        #if T9_AUTO_ANCHOR_DEVICE_PREFLIGHT
        if !consumeFreshPreparedDevicePreflightRunIfAvailable() {
            recordDevicePreflightMarker(
                runToken: devicePreflightRunToken ?? "invalid"
            )
        }
        #endif
        controller.textClient = UITextDocumentProxyAdapter(proxy: textDocumentProxy)
        controller.onTypoCorrectionSelected = { [weak self] correction in
            guard let self else { return }
            self.controller.typoCorrectionLearningSnapshot = self.typoCorrectionLearningStore.recordSelection(correction)
        }
        controller.onCommittedText = { [weak self] event in
            guard let self, self.cachedTypingIntelligenceEnabled else { return }
            let delta = TypingStatisticsClassifier.classify(event.text)
            self.typingStatisticsWriter.record(
                delta,
                source: event.source,
                at: Date(),
                resetEpoch: self.cachedTypingIntelligenceResetEpoch
            )
        }

        Logger.shared.info("viewDidLoad, keyboardType=\(keyboardType)", category: .general)
        prepareRimeRuntimeAvailability()
        observeExtensionHostLifecycle()
        #if T9_RESPONSIVE_CANARY_INTERNAL
        observeResponsiveCanaryKillSwitch()
        #endif

        Logger.shared.performance(
            "viewDidLoad complete",
            durationMs: (CACurrentMediaTime() - startupTime) * 1000
        )
        Logger.shared.requestFlush()

        if controller.state.inputMode == .english {
            _ = controller.applyAutoCapitalization(
                contextBeforeInput: textDocumentProxy.documentContextBeforeInput
            )
        }

        refreshCachedSettings(source: "viewDidLoad")

        #if DEBUG && T9_P3_D1_LIFECYCLE_HARNESS
        p3d1RecordLifecycleMarker("LOAD")
        #endif
    }

    func handleKeyboardDidAppear() {
        #if DEBUG
        recordKeyboardVisualDiagnostic("HANDLE_DID_APPEAR_BEGIN")
        #endif
        let isReturningToExistingKeyboard = hasViewAppeared
        hasViewAppeared = true

        if isReturningToExistingKeyboard {
            // 首次显示沿用 viewDidLoad 刚生成的快照；只有真正返回时才重新读取共享设置。
            refreshCachedSettings(source: "viewDidAppear")
            let effects = cleanupTransientKeyboardState(
                reason: "viewDidAppear",
                abandonsComposition: true
            )
            if !effects.isEmpty, isKeyboardUIInstalled {
                syncUI(with: effects)
            }
            #if DEBUG
            recordKeyboardVisualDiagnostic("HANDLE_DID_APPEAR_RETURN_CLEAN", effects: effects)
            #endif
            Logger.shared.info(
                "viewDidAppear: stale input and press state cleared after keyboard return",
                category: .engine
            )

            #if DEBUG && T9_P3_D1_LIFECYCLE_HARNESS
            p3d1RecordLifecycleMarker(
                "RETURN_CLEAN",
                reason: "viewDidAppear",
                cleared: true
            )
            #endif
        }

        Logger.shared.debug("viewDidAppear: bounds=\(view.bounds)", category: .display)
        #if DEBUG
        recordKeyboardVisualDiagnostic("HANDLE_DID_APPEAR_END")
        #endif
    }

    @discardableResult
    func cleanupTransientKeyboardState(
        reason: String,
        abandonsComposition: Bool
    ) -> KeyboardEffect {
        #if DEBUG
        recordKeyboardVisualDiagnostic("CLEANUP_BEGIN_\(reason)")
        #endif
        deleteRepeatController.stop()
        dismissVariantPopup(animated: false)
        if isCandidateExpanded {
            isCandidateExpanded = false
            dismissExpandedCandidatePanel(animated: false)
        }
        resetAllKeyPressVisualState()
        resetCandidatePresentationState()

        let effects = abandonsComposition
            ? controller.abandonCompositionForVisibilityChange()
            : KeyboardEffect()

        Logger.shared.debug(
            "\(reason): transient keyboard state cleared, abandonComposition=\(abandonsComposition)",
            category: .display
        )
        #if DEBUG
        recordKeyboardVisualDiagnostic("CLEANUP_END_\(reason)", effects: effects)
        #endif

        #if DEBUG && T9_P3_D1_LIFECYCLE_HARNESS
        p3d1RecordLifecycleMarker(
            "CLEAR",
            reason: reason,
            cleared: abandonsComposition
        )
        #endif
        return effects
    }

    func resetCandidatePresentationState() {
        accumulatedCandidates = []
        hasMoreCandidates = false
        isLoadingMoreCandidates = false
        candidatePageDepth = 0
        nextCandidateGlobalIndex = 0
        candidateSnapshotRawInput = nil
        candidateSnapshotGeneration += 1
        candidatePrefetchMode = .bar
        isCandidateScrollInteracting = false
        deferredCandidatePrefetchMode = nil
        candidatePrefetchRequestSerial += 1
        candidateCellSizeCache.removeAll(keepingCapacity: true)
    }

    /// `viewDidLoad` 可能只是系统的预创建阶段，而非真正展示键盘。
    /// 此处只解析只读路径并安装内存回退引擎，绝不打开 librime 用户词典。
    private func prepareRimeRuntimeAvailability() {
        guard let (sharedDir, userDir) = RimeConfigManager.runtimeDirectories() else {
            controller.enableDefaultRimeEngine()
            Logger.shared.warning(
                "RIME runtime data is unavailable; finish deployment in the main app before typing",
                category: .engine
            )
            return
        }

        pendingRimeRuntimeDirectories = (sharedDir, userDir)
        controller.enableDefaultRimeEngine()
        Logger.shared.info(
            "App Group available; deferring librime startup until keyboard is visible",
            category: .engine
        )
    }

    /// 只有键盘已经跨过首帧提交后，才允许 librime 打开用户词典和创建 session。
    /// 若系统在预创建后直接挂起，前面的回退引擎不持有文件锁，因此可安全终止。
    func activateRimeRuntimeAfterKeyboardPresentation() {
        guard !hasActivatedVisibleRimeRuntime,
              pendingRimeRuntimeDirectories != nil,
              rimeFirstFrameDisplayLink == nil
        else { return }

        rimeFirstFrameGateTickCount = 0
        rimeFirstFrameGateStartTime = CACurrentMediaTime()
        let target = KeyboardFirstFrameDisplayLinkTarget(controller: self)
        let displayLink = CADisplayLink(
            target: target,
            selector: #selector(KeyboardFirstFrameDisplayLinkTarget.displayLinkDidFire(_:))
        )
        // 两个节拍让 UIKit 先提交并跨过首个可见刷新；不使用固定延迟，
        // 因而可随 60/120Hz 与系统节能帧率自然调整。
        displayLink.add(to: .main, forMode: .common)
        rimeFirstFrameDisplayLinkTarget = target
        rimeFirstFrameDisplayLink = displayLink
        Logger.shared.info(
            "RIME first-frame gate armed displayTicks=2",
            category: .performance
        )
    }

    /// 由弱代理持有的 display link 在 MainActor 回调。
    /// 第二个节拍才允许创建 owner，避免 librime 首次打开词典与键盘首帧竞争资源。
    func handleRimeFirstFrameDisplayLinkTick() {
        guard rimeFirstFrameDisplayLink != nil else { return }
        rimeFirstFrameGateTickCount += 1
        guard rimeFirstFrameGateTickCount >= 2 else { return }

        let elapsedMilliseconds = (CACurrentMediaTime() - rimeFirstFrameGateStartTime) * 1_000
        cancelRimeFirstFrameGate()
        Logger.shared.info(
            "RIME first-frame gate passed displayTicks=2 elapsedMs="
                + String(format: "%.1f", elapsedMilliseconds),
            category: .performance
        )
        startRimeRuntimeAfterFirstFrame()
    }

    /// A visibility exit can precede the next display tick. Cancelling here is
    /// required so a hidden/precreated extension never opens the user database.
    func cancelRimeFirstFrameGate() {
        rimeFirstFrameDisplayLink?.invalidate()
        rimeFirstFrameDisplayLink = nil
        rimeFirstFrameDisplayLinkTarget = nil
        rimeFirstFrameGateTickCount = 0
        rimeFirstFrameGateStartTime = 0
    }

    private func startRimeRuntimeAfterFirstFrame() {
        #if DEBUG && T9_P3_D1_LIFECYCLE_HARNESS
        if installP3D1LifecycleHarnessIfArmed() {
            hasActivatedVisibleRimeRuntime = true
            return
        }
        #endif

        guard !hasActivatedVisibleRimeRuntime,
              let directories = pendingRimeRuntimeDirectories
        else { return }

        // Product Gate default-on (dual-gate) with fail-closed fallback to sync.
        // Canary-internal builds keep their own arming path.
        if installResponsiveDualGatePreflightIfArmed(directories: directories) {
            hasActivatedVisibleRimeRuntime = true
            return
        }

        Logger.shared.info("Keyboard visible; creating RimeEngineImpl", category: .engine)
        let engine = RimeEngineImpl(
            sharedDataDir: directories.sharedDataDir,
            userDataDir: directories.userDataDir
        )
        // Immediate propagation for in-place recovery / resume fail-closed (not only view lifecycle).
        engine.onRuntimeSelectionChanged = { [weak self] selection in
            self?.applyRealizedRuntimeSelection(selection)
        }
        controller.rimeEngine = engine
        controller.typoCorrectionCandidateQuery = engine
        // Rebuild bridge if responsive gate is ever enabled before/after engine install.
        controller.rebuildResponsiveRimeCoordinatorIfNeeded()
        applyRealizedRuntimeSelection(from: engine)
        hasActivatedVisibleRimeRuntime = true
        #if DEBUG || T9_AUTO_ANCHOR_DEVICE_PREFLIGHT
        // Content-free path marker. Explicit device preflight uses the
        // mandatory channel; ordinary Debug keeps the existing engine logger.
        recordResponsivePreflightMarker(
            ResponsiveRimePreflight.pathMarkerLine(
                path: controller.isResponsiveRimePipelineEnabled
                    ? .mainActorResponsive
                    : .sync,
                dualGateRequested: false,
                dualGateActive: false,
                runToken: responsivePreflightRunToken
            )
        )
        #endif
        Logger.shared.info("RIME session prepared for visible keyboard input", category: .engine)
    }

    /// Dual-gate arm for ordinary builds (Product Gate default-on) and legacy
    /// Debug/preflight arms. Returns `true` when dual-gate was installed.
    /// Fail-closed: install errors clear flags so the sync path can proceed.
    @discardableResult
    func installResponsiveDualGatePreflightIfArmed(
        directories: (sharedDataDir: String, userDataDir: String)
    ) -> Bool {
        #if T9_RESPONSIVE_CANARY_INTERNAL
        return installProductionShapedCanaryIfArmed(directories: directories)
        #else
        let compileFlagEnabled: Bool = {
            #if T9_RESPONSIVE_DEVICE_PREFLIGHT_ENABLED
            return true
            #else
            return false
            #endif
        }()
        #if DEBUG
        let isDebugBuild = true
        #else
        let isDebugBuild = false
        #endif
        let dualGateRequested = ResponsiveRimePreflight.shouldArmDualGate(
            defaults: sharedDefaults,
            isDebugBuild: isDebugBuild,
            compileFlagEnabled: compileFlagEnabled,
            productDefaultOn: ResponsiveRimePreflight.productGateReleaseDefaultOn
        )
        guard dualGateRequested else { return false }

        guard !directories.sharedDataDir.isEmpty, !directories.userDataDir.isEmpty else {
            recordResponsivePreflightMarker(
                ResponsiveRimePreflight.fallbackMarkerLine(
                    reason: "missing-runtime",
                    runToken: responsivePreflightRunToken
                ),
                level: .warning
            )
            return false
        }

        // Bootstrap-only: no MainActor live RimeEngineImpl session when dual-gate is active.
        controller.isResponsiveRimePipelineEnabled = true
        controller.isThreadAffineRimeOwnerEnabled = true
        controller.threadAffineEngineBootstrap = AnyThreadAffineRimeEngineBootstrap(
            ThreadAffineRimeEngineImplBootstrap(
                sharedDataDir: directories.sharedDataDir,
                userDataDir: directories.userDataDir,
                preferredSchemaID: nil
            )
        )
        // Preflight residual: typo sidecar uses provider adapter (not live librime session).
        controller.typoCorrectionCandidateQuery = CandidateProviderTypoCorrectionQuery(
            candidateProvider: controller.candidateProvider
        )
        controller.rebuildResponsiveRimeCoordinatorIfNeeded()

        let active = controller.threadAffineRimeCoordinator != nil
            && controller.rimeEngine is ThreadAffineRimeEngineBridge
        let ownerReady = controller.threadAffineRimeCoordinator?.isOwnerReady == true
        recordResponsivePreflightMarker(
            ResponsiveRimePreflight.pathMarkerLine(
                path: active ? .threadAffine : .fallbackMissingRuntime,
                dualGateRequested: true,
                dualGateActive: active,
                runToken: responsivePreflightRunToken
            )
        )
        guard active else {
            recordResponsivePreflightMarker(
                ResponsiveRimePreflight.fallbackMarkerLine(
                    reason: "rebuild-inactive",
                    runToken: responsivePreflightRunToken
                ),
                level: .warning
            )
            // Fail closed: tear down any partial dual-gate owner *before* the
            // caller creates a MainActor RimeEngineImpl (A-P1-01: at most one
            // live librime session entry in use).
            controller.isThreadAffineRimeOwnerEnabled = false
            controller.isResponsiveRimePipelineEnabled = false
            controller.threadAffineEngineBootstrap = nil
            controller.rebuildResponsiveRimeCoordinatorIfNeeded()
            return false
        }

        if ownerReady {
            recordResponsivePreflightMarker(
                ResponsiveRimePreflight.ownerReadinessMarkerLine(
                    runToken: responsivePreflightRunToken ?? "invalid",
                    isReady: true
                )
            )
        } else {
            Logger.shared.info(
                "RIME owner is bootstrapping asynchronously; keyboard presentation will not wait",
                category: .engine
            )
        }
        return true
        #endif
    }

    #if T9_RESPONSIVE_CANARY_INTERNAL
    /// Installs the real thread-affine owner only after the unique mode
    /// coordinator accepts one atomically parsed configuration snapshot.
    private func installProductionShapedCanaryIfArmed(
        directories: (sharedDataDir: String, userDataDir: String)
    ) -> Bool {
        let configuration = ResponsiveRimePreflight.canaryConfiguration(
            defaults: sharedDefaults,
            bootstrapAvailable:
                !directories.sharedDataDir.isEmpty && !directories.userDataDir.isEmpty
        )
        let nowUnixSeconds = Date().timeIntervalSince1970
        let decision = responsiveCanaryModeCoordinator.evaluateStartup(
            configuration,
            nowUnixSeconds: nowUnixSeconds
        )
        let receiptDecision: ResponsiveRimePreflight.CanaryConfigDecision = {
            switch decision {
            case .startCanary:
                return .startCanary
            case .useBaseline:
                return .baseline
            }
        }()
        recordResponsivePreflightMarker(
            ResponsiveRimePreflight.extensionConfigReceipt(
                phase: .startup,
                configuration: configuration,
                nowUnixSeconds: nowUnixSeconds,
                decision: receiptDecision
            ).markerLine
        )
        guard case .startCanary = decision else {
            responsiveCanaryExpiryTimer?.invalidate()
            responsiveCanaryExpiryTimer = nil
            responsiveCanaryConfigurationMonitor?.invalidate()
            responsiveCanaryConfigurationMonitor = nil
            responsiveCanaryRunID = ""
            return false
        }

        responsiveCanaryRunID = configuration.runID
        controller.isResponsiveRimePipelineEnabled = true
        controller.isThreadAffineRimeOwnerEnabled = true
        controller.threadAffineEngineBootstrap = AnyThreadAffineRimeEngineBootstrap(
            ThreadAffineRimeEngineImplBootstrap(
                sharedDataDir: directories.sharedDataDir,
                userDataDir: directories.userDataDir,
                preferredSchemaID: nil
            )
        )
        // CANARY-001 v1 forbids a second live typo-correction session.
        controller.typoCorrectionCandidateQuery = CandidateProviderTypoCorrectionQuery(
            candidateProvider: controller.candidateProvider
        )
        controller.rebuildResponsiveRimeCoordinatorIfNeeded()

        guard let affine = controller.threadAffineRimeCoordinator,
              affine.isOwnerReady
        else {
            return closeFailedCanaryStartup(permitBaselineAfterTeardown: true)
        }
        guard let sessionInstance = responsiveCanaryModeCoordinator.markCanaryReady() else {
            return closeFailedCanaryStartup(permitBaselineAfterTeardown: false)
        }
        controller.markResponsiveCanaryOwnerInstalled(
            runID: configuration.runID,
            modeGeneration: responsiveCanaryModeCoordinator.modeGeneration,
            sessionInstance: sessionInstance
        )
        controller.applyRealizedSelectionFromEngine()
        if let selection = controller.rimeEngine?.runtimeSelection {
            applyRealizedRuntimeSelection(selection)
        }
        scheduleResponsiveCanaryExpiry(at: configuration.expiresAtUnixSeconds)
        startResponsiveCanaryConfigurationMonitor()
        return true
    }

    /// Returns false only after positive teardown proves that baseline creation
    /// is safe. A non-positive result consumes the activation attempt and leaves
    /// the Extension fenced without creating a second live session.
    private func closeFailedCanaryStartup(
        permitBaselineAfterTeardown: Bool
    ) -> Bool {
        guard let affine = controller.threadAffineRimeCoordinator,
              let fence = affine.issueActiveKillFence(),
              let result = affine.drainActiveKillAndShutdown(after: fence),
              result.isPositive
        else {
            responsiveCanaryModeCoordinator.failClosed("startupTeardownIncomplete")
            return true
        }

        controller.clearResponsiveCanaryAfterPositiveShutdown()
        if permitBaselineAfterTeardown {
            responsiveCanaryModeCoordinator.markFailedStartupTeardownComplete()
        } else {
            responsiveCanaryModeCoordinator.failClosed("ownerReadyRejected")
        }
        responsiveCanaryRunID = ""
        responsiveCanaryExpiryTimer?.invalidate()
        responsiveCanaryExpiryTimer = nil
        responsiveCanaryConfigurationMonitor?.invalidate()
        responsiveCanaryConfigurationMonitor = nil
        return !permitBaselineAfterTeardown
    }

    func observeResponsiveCanaryKillSwitch() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(responsiveCanaryConfigurationDidChange),
            name: UserDefaults.didChangeNotification,
            object: sharedDefaults
        )
    }

    @objc private func responsiveCanaryConfigurationDidChange() {
        applyResponsiveCanaryKillSwitchIfNeeded()
    }

    private func scheduleResponsiveCanaryExpiry(at unixSeconds: TimeInterval) {
        responsiveCanaryExpiryTimer?.invalidate()
        let delay = max(0, unixSeconds - Date().timeIntervalSince1970)
        responsiveCanaryExpiryTimer = Timer.scheduledTimer(
            withTimeInterval: delay,
            repeats: false
        ) { [weak self] _ in
            Task { @MainActor in
                self?.applyResponsiveCanaryKillSwitchIfNeeded()
            }
        }
    }

    /// App Group defaults notifications are process-local. This bounded
    /// internal-artifact timer observes an external kill without adding shared
    /// defaults I/O to the input hot path.
    func startResponsiveCanaryConfigurationMonitor() {
        responsiveCanaryConfigurationMonitor?.invalidate()
        responsiveCanaryConfigurationMonitor = Timer.scheduledTimer(
            withTimeInterval: 1,
            repeats: true
        ) { [weak self] _ in
            Task { @MainActor in
                self?.applyResponsiveCanaryKillSwitchIfNeeded()
            }
        }
    }

    /// Re-evaluates a complete snapshot on configuration notification. Disable,
    /// expiry or malformed configuration is treated as an asserted kill while
    /// active; no caller reads one flag and chooses a mode independently.
    func applyResponsiveCanaryKillSwitchIfNeeded() {
        guard case .canaryActive = responsiveCanaryModeCoordinator.state,
              let directories = pendingRimeRuntimeDirectories
        else { return }

        let configuration = ResponsiveRimePreflight.canaryConfiguration(
            defaults: sharedDefaults,
            bootstrapAvailable:
                !directories.sharedDataDir.isEmpty && !directories.userDataDir.isEmpty
        )
        let nowUnixSeconds = Date().timeIntervalSince1970
        let shouldKill = ResponsiveRimePreflight.shouldTerminateActiveCanary(
            configuration: configuration,
            currentRunID: responsiveCanaryRunID,
            nowUnixSeconds: nowUnixSeconds
        )
        guard shouldKill else { return }
        recordResponsivePreflightMarker(
            ResponsiveRimePreflight.extensionConfigReceipt(
                phase: .kill,
                configuration: configuration,
                nowUnixSeconds: nowUnixSeconds,
                decision: .kill
            ).markerLine
        )
        terminateActiveCanary(reason: "configurationKill")
    }

    private func terminateActiveCanary(reason: String) {
        guard case .canaryActive = responsiveCanaryModeCoordinator.state,
              let affine = controller.threadAffineRimeCoordinator,
              let ownerFence = affine.issueActiveKillFence(),
              let transitionKey = responsiveCanaryModeCoordinator.beginActiveKill(
                  runID: responsiveCanaryRunID,
                  acceptedThroughRevision: ownerFence.acceptedThroughRevision
              )
        else {
            responsiveCanaryModeCoordinator.failClosed("\(reason)FenceUnavailable")
            return
        }

        controller.beginResponsiveCanaryPresentationFence()

        guard let result = affine.drainActiveKillAndShutdown(after: ownerFence),
              result.acceptedBacklogDrained
        else {
            responsiveCanaryModeCoordinator.failClosed("\(reason)DrainIncomplete")
            return
        }
        controller.finalizeResponsiveCanaryFencedPresentations()
        guard result.ownerDestroyed,
              !responsiveCanaryModeCoordinator.recordPositiveTerminal(
                  .ownerDestroyed,
                  key: transitionKey
              ),
              result.mailboxTerminal,
              !responsiveCanaryModeCoordinator.recordPositiveTerminal(
                  .mailboxTerminal,
                  key: transitionKey
              ),
              result.deliveryDrained,
              responsiveCanaryModeCoordinator.recordPositiveTerminal(
                  .deliveryDrained,
                  key: transitionKey
              ),
              responsiveCanaryModeCoordinator.permitsBaselineCreation
        else {
            responsiveCanaryModeCoordinator.failClosed("\(reason)TerminalIncomplete")
            return
        }

        controller.clearResponsiveCanaryAfterPositiveShutdown()
        responsiveCanaryRunID = ""
        responsiveCanaryExpiryTimer?.invalidate()
        responsiveCanaryExpiryTimer = nil
        responsiveCanaryConfigurationMonitor?.invalidate()
        responsiveCanaryConfigurationMonitor = nil
        hasActivatedVisibleRimeRuntime = false
        activateRimeRuntimeAfterKeyboardPresentation()
    }
    #endif

    /// Content-free PATH/READY/FALLBACK markers are mandatory only for an
    /// explicitly compiled device-preflight build. Ordinary Debug retains the
    /// existing engine-category logger and therefore no new default persistence
    /// side effect is introduced for users.
    private func recordResponsivePreflightMarker(
        _ message: String,
        level: Logger.Level = .info
    ) {
        #if T9_AUTO_ANCHOR_DEVICE_PREFLIGHT
        Logger.shared.devicePreflightPerformance(message, level: level)
        Logger.shared.requestFlush()
        #else
        switch level {
        case .debug:
            Logger.shared.debug(message, category: .engine)
        case .info:
            Logger.shared.info(message, category: .engine)
        case .warning:
            Logger.shared.warning(message, category: .engine)
        case .error:
            Logger.shared.error(message, category: .engine)
        }
        #endif
    }

    private var responsivePreflightRunToken: String? {
        #if T9_AUTO_ANCHOR_DEVICE_PREFLIGHT
        return devicePreflightRunToken ?? "invalid"
        #else
        return nil
        #endif
    }

    /// Align chrome + controller T9 semantics with the schema librime actually selected.
    func applyRealizedRuntimeSelection(from engine: RimeEngineImpl) {
        guard let realized = engine.runtimeSelection else { return }
        applyRealizedRuntimeSelection(realized)
    }

    /// Align chrome + controller with a published realized selection.
    /// Reloads the key grid when the realized layout diverges from provisional chrome.
    func applyRealizedRuntimeSelection(_ realized: RimeRuntimeSelection) {
        let previousLayout = cachedLayoutStyle
        let previousSemantics = controller.usesT9InputSemantics
        controller.usesT9InputSemantics = realized.usesT9InputSemantics
        let surface = realized.surface
        cachedT9ReadinessMatched = surface.t9ReadinessMatched
        cachedLayoutStyle = surface.layoutStyle
        Logger.shared.info(
            "Applied realized selection schema=\(realized.effectiveSchemaID) "
                + "layout=\(surface.layoutStyle.rawValue) usesT9=\(surface.usesT9InputSemantics)",
            category: .engine
        )
        let layoutChanged =
            previousLayout != cachedLayoutStyle || previousSemantics != controller.usesT9InputSemantics
        if layoutChanged, isKeyboardUIInstalled {
            reloadKeyboard()
        }
    }

    /// UIKit does not guarantee viewWillDisappear when the host replaces a keyboard
    /// controller. The extension-host notification is the last documented boundary
    /// before the process may be suspended, so runtime locks must be released here.
    func observeExtensionHostLifecycle() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(extensionHostWillResignActive),
            name: .NSExtensionHostWillResignActive,
            object: nil
        )
    }

    @objc private func extensionHostWillResignActive() {
        #if DEBUG
        recordKeyboardVisualDiagnostic("HOST_RESIGN_BEFORE")
        #endif
        #if DEBUG && T9_P3_D1_LIFECYCLE_HARNESS
        p3d1RecordLifecycleMarker("HOST_RESIGN_BEGIN", reason: "extensionHost")
        #endif
        suspendKeyboardRuntime(reason: "extensionHostWillResignActive", updateUI: false)
        #if DEBUG
        recordKeyboardVisualDiagnostic("HOST_RESIGN_AFTER")
        #endif
    }

}

#if DEBUG && T9_P3_D1_LIFECYCLE_HARNESS

// MARK: - P3-D1 T02/T03 controlled lifecycle seam

private nonisolated struct P3D1LifecycleHarnessBootstrap: ThreadAffineRimeEngineBootstrap, Sendable {
    let delayNanoseconds: UInt64
    let runID: String

    func makeEngineOnOwnerThread() -> any RimeEngine {
        P3D1LifecycleHarnessRimeEngine(
            delayNanoseconds: delayNanoseconds,
            runID: runID
        )
    }
}

/// A content-free engine used only by the host-driven lifecycle proof.
///
/// The fake intentionally has no candidate dictionary and never stores the key
/// text. It only keeps a slot count so the owner can be delayed and still return
/// a valid composition-shaped snapshot. This type is compiled only when the
/// explicit harness flag is supplied to xcodebuild.
private nonisolated final class P3D1LifecycleHarnessRimeEngine: RimeEngine {
    private let delayNanoseconds: UInt64
    private let runID: String
    private var compositionLength = 0

    init(delayNanoseconds: UInt64, runID: String) {
        self.delayNanoseconds = delayNanoseconds
        self.runID = runID
        Logger.shared.devicePreflightPerformance(
            "P3LIFE schema=v1 marker=OWNER_READY run=\(runID) "
                + "ownerThread=background engine=fake delayMs=150"
        )
        Logger.shared.requestFlush()
    }

    var runtimeSelection: RimeRuntimeSelection? { nil }

    var onRuntimeSelectionChanged: ((RimeRuntimeSelection) -> Void)?

    var diagnosticSessionSnapshot: RimeSessionDiagnosticSnapshot? {
        // Fixed, content-free identity: it proves that one owner instance was
        // used without exposing a real session pointer or user input.
        RimeSessionDiagnosticSnapshot(identity: 0x5033_D031, isValid: true)
    }

    func processKey(_ key: String) -> RimeOutput {
        _ = key
        Logger.shared.devicePreflightPerformance(
            "P3LIFE schema=v1 marker=OWNER_BEGIN run=\(runID) "
                + "ownerThread=background delayMs=150"
        )
        Logger.shared.requestFlush()
        Thread.sleep(forTimeInterval: TimeInterval(delayNanoseconds) / 1_000_000_000)
        compositionLength += 1
        let output = outputSnapshot()
        Logger.shared.devicePreflightPerformance(
            "P3LIFE schema=v1 marker=OWNER_END run=\(runID) "
                + "ownerThread=background delayMs=150 slots=\(compositionLength)"
        )
        Logger.shared.requestFlush()
        return output
    }

    func selectCandidate(at index: Int) -> RimeOutput {
        _ = index
        return outputSnapshot()
    }

    func selectCandidate(globalIndex index: Int) -> RimeOutput {
        _ = index
        return outputSnapshot()
    }

    func candidateWindow(from globalIndex: Int, limit: Int) -> RimeCandidateWindow {
        _ = limit
        return RimeCandidateWindow(
            candidates: [],
            startIndex: globalIndex,
            nextIndex: globalIndex,
            hasMoreCandidates: false
        )
    }

    func deleteBackward() -> RimeOutput {
        compositionLength = max(0, compositionLength - 1)
        return outputSnapshot()
    }

    func replaceInput(_ input: String) -> RimeOutput {
        compositionLength = input.isEmpty ? 0 : max(1, input.count)
        return outputSnapshot()
    }

    func resetSession() {
        compositionLength = 0
    }

    func recoverSession() {
        compositionLength = 0
    }

    func suspendForVisibilityChange() {
        compositionLength = 0
    }

    func resumeAfterVisibilityChange() {
        compositionLength = 0
    }

    func isComposing() -> Bool {
        compositionLength > 0
    }

    func pageUp() -> RimeOutput {
        outputSnapshot()
    }

    func pageDown() -> RimeOutput {
        outputSnapshot()
    }

    private func outputSnapshot() -> RimeOutput {
        guard compositionLength > 0 else {
            return RimeOutput(composition: nil, candidates: [], highlightedIndex: -1)
        }

        let placeholder = String(repeating: "·", count: compositionLength)
        return RimeOutput(
            rawInput: nil,
            composition: RimeComposition(
                preeditText: placeholder,
                cursorPosition: placeholder.utf8.count,
                length: placeholder.utf8.count
            ),
            candidates: [],
            highlightedIndex: -1
        )
    }
}

extension KeyboardViewController {
    /// Installs the controlled owner without requiring deployed App Group RIME
    /// data. The explicit compile flag is the only arm; no UserDefaults or
    /// Release setting can activate this seam.
    @discardableResult
    func installP3D1LifecycleHarnessIfArmed() -> Bool {
        if let coordinator = controller.threadAffineRimeCoordinator {
            let ownerReady = coordinator.isOwnerReady
            p3d1RecordLifecycleMarker(
                ownerReady ? "VISIBLE_REUSE" : "VISIBLE_NOT_READY",
                reason: ownerReady ? "ownerAlreadyInstalled" : "ownerResumeFailed"
            )
            return ownerReady
        }

        controller.isResponsiveRimePipelineEnabled = true
        controller.isThreadAffineRimeOwnerEnabled = true
        controller.threadAffineEngineBootstrap = AnyThreadAffineRimeEngineBootstrap(
            P3D1LifecycleHarnessBootstrap(
                delayNanoseconds: 150_000_000,
                runID: p3d1LifecycleRunID
            )
        )
        controller.typoCorrectionCandidateQuery = CandidateProviderTypoCorrectionQuery(
            candidateProvider: controller.candidateProvider
        )
        controller.rebuildResponsiveRimeCoordinatorIfNeeded()

        let active = controller.threadAffineRimeCoordinator != nil
            && controller.rimeEngine is ThreadAffineRimeEngineBridge
        let ownerReady = controller.threadAffineRimeCoordinator?.isOwnerReady == true
        p3d1RecordLifecycleMarker(
            active && ownerReady ? "VISIBLE_READY" : "VISIBLE_NOT_READY",
            reason: active ? "fakeOwner" : "rebuildInactive"
        )
        return active && ownerReady
    }

    /// Emits only lifecycle counters and owner watermarks. It deliberately does
    /// not read composition, candidate, marked-text, or host-document content.
    func p3d1RecordLifecycleMarker(
        _ marker: String,
        reason: String = "none",
        cleared: Bool = false
    ) {
        p3d1LifecycleLastCleared = p3d1LifecycleLastCleared || cleared
        p3d1LifecycleLastReturnClean =
            p3d1LifecycleLastReturnClean || marker == "RETURN_CLEAN"
        let diagnostics = controller?.threadAffineRimeCoordinator?.diagnostics
        let coordinator = controller?.threadAffineRimeCoordinator
        let gate = controller?.isResponsiveRimePipelineEnabled == true
            && controller?.isThreadAffineRimeOwnerEnabled == true
        let revision = coordinator?.lastPublished?.revision
            ?? coordinator?.lastAcceptReceipt?.revision
            ?? 0
        let sanitizedReason = reason
            .replacingOccurrences(of: " ", with: "_")
            .replacingOccurrences(of: "=", with: "-")
        let line =
            "P3LIFE schema=v1 marker=\(marker) run=\(p3d1LifecycleRunID) "
            + "gate=\(gate ? 1 : 0) epoch=\(diagnostics?.sessionEpoch ?? 0) "
            + "rev=\(revision) pending=\(diagnostics?.pendingWorkDepth ?? 0) "
            + "accepted=\(coordinator?.lastAcceptReceipt?.revision ?? 0) "
            + "applied=\(p3d1LifecycleAppliedCount) "
            + "stale=\(diagnostics?.skippedStaleEpochCount ?? 0) "
            + "discard=\(diagnostics?.rejectedAtBoundCount ?? 0) "
            + "terminal=\(diagnostics?.isDeliveryTerminal == true ? 1 : 0) "
            + "ownerReady=\(coordinator?.isOwnerReady == true ? 1 : 0) "
            + "cleared=\(p3d1LifecycleLastCleared ? 1 : 0) "
            + "returnClean=\(p3d1LifecycleLastReturnClean ? 1 : 0) "
            + "reason=\(sanitizedReason)"
        p3d1LifecycleDiagnosticElement?.accessibilityValue = line
        Logger.shared.devicePreflightPerformance(line)
        Logger.shared.requestFlush()
    }

    /// A content-free accessibility handshake lets the host UI test validate
    /// that the installed appex really contains this harness. It is compiled
    /// only for the explicit DEBUG target flag and is never a Release surface.
    func p3d1InstallLifecycleAccessibilityElementIfNeeded() {
        guard p3d1LifecycleDiagnosticElement == nil,
              let keyboardSurfaceView
        else { return }

        let element = UIView(frame: .zero)
        element.translatesAutoresizingMaskIntoConstraints = false
        element.isAccessibilityElement = true
        element.accessibilityIdentifier = "P3D1LifecycleHarness"
        element.accessibilityLabel = "P3D1 lifecycle harness"
        element.isUserInteractionEnabled = false
        element.alpha = 0.01
        keyboardSurfaceView.addSubview(element)
        NSLayoutConstraint.activate([
            element.leadingAnchor.constraint(equalTo: keyboardSurfaceView.leadingAnchor),
            element.topAnchor.constraint(equalTo: keyboardSurfaceView.topAnchor),
            element.widthAnchor.constraint(equalToConstant: 1),
            element.heightAnchor.constraint(equalToConstant: 1),
        ])
        p3d1LifecycleDiagnosticElement = element
        p3d1RecordLifecycleMarker("SURFACE_READY", reason: "accessibilityHandshake")
    }
}

#endif
