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

        if isReturningToExistingKeyboard, controller.rimeEngine != nil {
            controller.resetRimeSessionForVisibilityChange()
            accumulatedCandidates = []
            hasMoreCandidates = false
            candidatePageDepth = 0
            Logger.shared.info(
                "viewDidAppear: RIME composition cleared after keyboard return",
                category: .engine
            )
        }

        Logger.shared.debug("viewDidAppear: bounds=\(view.bounds)", category: .display)
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

        var testOutput = controller.rimeEngine!.processKey("n")
        Logger.shared.info(
            "healthCheck step=1 preeditLength=\(testOutput.composition?.preeditText.count ?? 0), "
                + "candidates: \(testOutput.candidates.count)",
            category: .engine
        )
        testOutput = controller.rimeEngine!.processKey("i")
        Logger.shared.info(
            "healthCheck step=2 preeditLength=\(testOutput.composition?.preeditText.count ?? 0), "
                + "candidates: \(testOutput.candidates.count)",
            category: .engine
        )
        controller.rimeEngine!.resetSession()

        if testOutput.candidates.isEmpty {
            Logger.shared.warning(
                "No candidates on first check; deploy schema from the main app before typing",
                category: .engine
            )
        } else {
            Logger.shared.info(
                "RIME ready, candidates: \(testOutput.candidates.count)",
                category: .engine
            )
        }
    }

}
