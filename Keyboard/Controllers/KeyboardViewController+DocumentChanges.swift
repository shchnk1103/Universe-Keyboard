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
        var effects = controller.handle(
            .keyboardTypeChanged(KeyboardType.from(uiKeyboardType: proxy.keyboardType))
        )
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
