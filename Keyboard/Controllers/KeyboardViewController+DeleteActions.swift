import KeyboardCore
import UIKit

extension KeyboardViewController {
    // MARK: === 删除（含长按自动重复）===

    @objc func deleteKeyTouchDown(_ sender: UIButton) {
        keyTouchDown(sender)
        performDeleteBackward(emitFeedback: false)
        deleteRepeatController.begin { [weak self] in
            self?.performDeleteBackward()
        }
    }

    @objc func deleteKeyTouchUpInside(_ sender: UIButton) {
        deleteRepeatController.stop()
        keyPressFeedbackEmittedButtonIDs.remove(ObjectIdentifier(sender))
        restoreKeyAppearance(sender)
    }

    @objc func deleteKeyTouchUpOutside(_ sender: UIButton) {
        deleteRepeatController.stop()
        keyPressFeedbackEmittedButtonIDs.remove(ObjectIdentifier(sender))
        restoreKeyAppearance(sender)
    }

    func performDeleteBackward(emitFeedback: Bool = true) {
        if emitFeedback {
            emitKeyPressFeedback()
        }
        var effects = controller.handle(.deleteBackward)

        let context = textDocumentProxy.documentContextBeforeInput
        let autoCapEffect = controller.applyAutoCapitalization(contextBeforeInput: context)
        effects.formUnion(autoCapEffect)

        syncUI(with: effects)
    }
}
