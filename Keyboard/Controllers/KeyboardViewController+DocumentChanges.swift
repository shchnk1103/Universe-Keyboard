import KeyboardCore
import UIKit

extension KeyboardViewController {
    func synchronizeAfterTextChange() {
        // `UIInputViewController` may deliver `textDidChange` before `viewDidLoad`,
        // especially when the controller supplies a custom `UIInputView`. At that
        // point the KeyboardCore controller does not exist yet. Bootstrap reads the
        // current keyboard type and capitalization context, so this early callback
        // can be safely ignored instead of forcing view loading from an XPC callback.
        guard isViewLoaded, controller != nil else {
            #if DEBUG
                Logger.shared.debug(
                    "textDidChange ignored before keyboard bootstrap",
                    category: .general
                )
            #endif
            return
        }

        let proxy = textDocumentProxy
        let observation = documentIdentityTracker.observe(KeyboardReadDocumentIdentifier(proxy))
        // An unavailable sample cannot establish a new baseline or authorize a
        // rebind. Keep the last valid identity for the next host callback.
        guard observation != .unavailable else { return }
        let documentDidChange = observation == .changed
        var effects: KeyboardEffect = []

        if documentDidChange {
            // UIKit already points at the new document. Unbind before clearing
            // composition so the old marked text is never cleared in the new host.
            controller.textClient = nil
            effects.formUnion(controller.abandonCompositionForVisibilityChange())
        }

        // Rebind on each host callback in case UIKit has supplied a new proxy.
        // Rebinding must preserve the same content-free diagnostic gates as Bootstrap.
        controller.textClient = UITextDocumentProxyAdapter(
            proxy: proxy,
            diagnosticsJournal: diagnosticsJournal,
            diagnosticContext: { [weak self] in
                self?.wakeDiagnosticContext ?? .disabled
            }
        )
        effects.formUnion(
            controller.handle(
                .keyboardTypeChanged(KeyboardType.from(uiKeyboardType: proxy.keyboardType))
            ))
        if !documentDidChange, !controller.isPerformingOwnedHostMutation {
            effects.formUnion(controller.noteExternalDocumentChange())
        }
        effects.formUnion(
            controller.applyAutoCapitalization(contextBeforeInput: proxy.documentContextBeforeInput)
        )

        // UIKit may report document changes before the visible keyboard hierarchy is installed.
        guard isKeyboardUIInstalled else { return }

        nextKeyboardButton?.setTitleColor(proxy.keyboardAppearance == .dark ? .white : .black, for: [])
        updateReturnKeyAppearance()

        guard !effects.isEmpty else { return }
        syncUI(with: effects)
    }

    func releaseRecoverableResourcesAfterMemoryWarning() {
        Logger.shared.warning("didReceiveMemoryWarning: releasing caches", category: .general)
        keyTouchDownTimes.removeAll()
        keyPressFeedbackEmittedButtonIDs.removeAll()
        candidateCellSizeCache.removeAll()

        if isCandidateExpanded {
            isCandidateExpanded = false
            dismissExpandedCandidatePanel(animated: false)
        }
    }
}
