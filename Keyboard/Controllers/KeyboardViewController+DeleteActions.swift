import KeyboardCore
import UIKit

extension KeyboardViewController {
    // MARK: === 删除（含长按自动重复）===

    @objc func deleteKeyTouchDown(_ sender: UIButton) {
        resetDeleteRepeatFeedback()
        keyTouchDown(sender)
        performDeleteBackward(shouldEmitFeedback: false)
        deleteRepeatController.begin { [weak self] in
            self?.performDeleteBackward()
        }
    }

    @objc func deleteKeyTouchUpInside(_ sender: UIButton) {
        deleteRepeatController.stop()
        resetDeleteRepeatFeedback()
        keyPressFeedbackEmittedButtonIDs.remove(ObjectIdentifier(sender))
        restoreKeyAppearance(sender)
    }

    @objc func deleteKeyTouchUpOutside(_ sender: UIButton) {
        deleteRepeatController.stop()
        resetDeleteRepeatFeedback()
        keyPressFeedbackEmittedButtonIDs.remove(ObjectIdentifier(sender))
        restoreKeyAppearance(sender)
    }

    func performDeleteBackward(shouldEmitFeedback: Bool = true) {
        let deletedSomething = canDeleteBeforeCurrentAction()
        var effects = controller.handle(.deleteBackward)

        let context = textDocumentProxy.documentContextBeforeInput
        let autoCapEffect = controller.applyAutoCapitalization(contextBeforeInput: context)
        effects.formUnion(autoCapEffect)

        syncUI(with: effects)

        guard shouldEmitFeedback, deletedSomething else {
            return
        }

        deleteRepeatEffectiveFeedbackCount += 1
        playRepeatFeedback(effectiveDeleteCount: deleteRepeatEffectiveFeedbackCount)
    }

    private func canDeleteBeforeCurrentAction() -> Bool {
        if !controller.state.currentComposition.isEmpty {
            return true
        }

        if controller.state.insertedPreeditCount > 0 {
            return true
        }

        return !(textDocumentProxy.documentContextBeforeInput?.isEmpty ?? true)
    }

    private func resetDeleteRepeatFeedback() {
        deleteRepeatEffectiveFeedbackCount = 0
    }
}
