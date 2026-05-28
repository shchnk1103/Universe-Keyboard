import KeyboardCore
import UIKit

extension KeyboardViewController {
    @objc func toggleShift() {
        playKeyClick()
        playHaptic()
        let effects = controller.handle(.toggleShift)
        syncUI(with: effects)
    }

    @objc func toggleKeyboardPage() {
        playKeyClick()
        playHaptic()
        let effects = controller.handle(.togglePage)
        syncUI(with: effects)
    }

    @objc func toggleInputMode() {
        playKeyClick()
        playHaptic()
        var effects = controller.handle(.toggleInputMode)

        if controller.state.inputMode == .english {
            let context = textDocumentProxy.documentContextBeforeInput
            let autoCapEffect = controller.applyAutoCapitalization(contextBeforeInput: context)
            effects.formUnion(autoCapEffect)
        }

        syncUI(with: effects)
    }

    @objc func candidatePageUp() {
        playKeyClick()
        playHaptic()
        let effects = controller.handle(.candidatePageUp)
        syncUI(with: effects)
    }

    @objc func candidatePageDown() {
        playKeyClick()
        playHaptic()
        let effects = controller.handle(.candidatePageDown)
        syncUI(with: effects)
    }

    @objc func insertSpace() {
        playKeyClick()
        playHaptic()
        let effects = controller.handle(.insertSpace)
        syncUI(with: effects)
    }

    @objc func insertReturn() {
        playKeyClick()
        playHaptic()
        let effects = controller.handle(.insertReturn)
        syncUI(with: effects)
    }
}
