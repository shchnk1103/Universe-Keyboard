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

        Logger.shared.info("viewDidLoad, keyboardType=\(keyboardType)", category: .general)
        prepareRimeSession()

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
        observeSettingsChanges()
        hapticGenerator.prepare()
        modeEnterHapticGenerator.prepare()
    }

    func handleKeyboardDidAppear() {
        let isReturningToExistingKeyboard = hasViewAppeared
        hasViewAppeared = true
        refreshCachedSettings(source: "viewDidAppear")

        if isReturningToExistingKeyboard {
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

    private func prepareRimeSession() {
        guard let (sharedDir, userDir) = RimeConfigManager.runtimeDirectories() else {
            controller.enableDefaultRimeEngine()
            Logger.shared.warning(
                "RIME runtime data is unavailable; finish deployment in the main app before typing",
                category: .engine
            )
            return
        }

        Logger.shared.info("App Group available, creating RimeEngineImpl", category: .engine)
        controller.rimeEngine = RimeEngineImpl(sharedDataDir: sharedDir, userDataDir: userDir)
        Logger.shared.info("RIME session prepared for keyboard input", category: .engine)
    }

}
