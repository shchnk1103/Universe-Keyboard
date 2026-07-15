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
    }

    func handleKeyboardDidAppear() {
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
            Logger.shared.info(
                "viewDidAppear: stale input and press state cleared after keyboard return",
                category: .engine
            )
        }

        Logger.shared.debug("viewDidAppear: bounds=\(view.bounds)", category: .display)
    }

    @discardableResult
    func cleanupTransientKeyboardState(
        reason: String,
        abandonsComposition: Bool
    ) -> KeyboardEffect {
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

    /// 只有键盘已经实际呈现后，才允许 librime 打开用户词典和创建 session。
    /// 若系统在预创建后直接挂起，前面的回退引擎不持有文件锁，因此可安全终止。
    func activateRimeRuntimeAfterKeyboardPresentation() {
        guard !hasActivatedVisibleRimeRuntime,
              let directories = pendingRimeRuntimeDirectories
        else { return }

        Logger.shared.info("Keyboard visible; creating RimeEngineImpl", category: .engine)
        let engine = RimeEngineImpl(
            sharedDataDir: directories.sharedDataDir,
            userDataDir: directories.userDataDir
        )
        controller.rimeEngine = engine
        controller.typoCorrectionCandidateQuery = engine
        hasActivatedVisibleRimeRuntime = true
        Logger.shared.info("RIME session prepared for visible keyboard input", category: .engine)
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
        suspendKeyboardRuntime(reason: "extensionHostWillResignActive", updateUI: false)
    }

}
