import KeyboardCore
import UIKit

extension KeyboardViewController {
    @objc func toggleShift(_ sender: UIButton) {
        emitKeyPressFeedbackIfNeeded(for: sender)
        let effects = controller.handle(.toggleShift)
        syncUI(with: effects)
    }

    @objc func toggleKeyboardPage(_ sender: UIButton) {
        emitKeyPressFeedbackIfNeeded(for: sender)
        let effects = controller.handle(.togglePage)
        syncUI(with: effects)
    }

    @objc func toggleInputMode(_ sender: UIButton) {
        emitKeyPressFeedbackIfNeeded(for: sender)
        var effects = controller.handle(.toggleInputMode)

        if controller.state.inputMode == .english {
            let context = textDocumentProxy.documentContextBeforeInput
            let autoCapEffect = controller.applyAutoCapitalization(contextBeforeInput: context)
            effects.formUnion(autoCapEffect)
        }

        syncUI(with: effects)
    }

    @objc func candidatePageUp() {
        emitKeyPressFeedback()
        let effects = controller.handle(.candidatePageUp)
        syncUI(with: effects)
    }

    @objc func candidatePageDown() {
        emitKeyPressFeedback()
        let effects = controller.handle(.candidatePageDown)
        syncUI(with: effects)
    }

    @objc func insertSpace(_ sender: UIButton) {
        emitKeyPressFeedbackIfNeeded(for: sender)
        let effects = controller.handle(.insertSpace)
        syncUI(with: effects)
    }

    @objc func insertReturn(_ sender: UIButton) {
        emitKeyPressFeedbackIfNeeded(for: sender)
        let effects = controller.handle(.insertReturn)
        syncUI(with: effects)
    }
}
