import KeyboardCore
import UIKit

extension KeyboardViewController {
    func synchronizeAfterTextChange() {
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

        if isCandidateExpanded {
            isCandidateExpanded = false
            dismissExpandedCandidatePanel(animated: false)
        }
    }
}
