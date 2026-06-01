import KeyboardCore
import UIKit

extension KeyboardViewController {
    /// Records touch timing and responds synchronously so rapid typing receives immediate feedback.
    @objc func keyTouchDown(_ sender: UIButton) {
        let identifier = ObjectIdentifier(sender)
        keyTouchDownTimes[identifier] = CACurrentMediaTime()
        keyPressFeedbackEmittedButtonIDs.insert(identifier)

        Logger.shared.performance("keyDown registered")

        sender.backgroundColor = highlightedKeyColor
        sender.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)
        emitKeyPressFeedback()
    }

    @objc func keyTouchUp(_ sender: UIButton) {
        keyPressFeedbackEmittedButtonIDs.remove(ObjectIdentifier(sender))
        restoreKeyAppearance(sender)
    }

    func restoreKeyAppearance(_ sender: UIButton) {
        let restore = {
            sender.transform = .identity

            if sender === self.shiftButton {
                self.updateShiftButtonAppearance()
                return
            }

            guard let style = self.keyStyle(for: sender) else {
                sender.backgroundColor = self.characterKeyColor
                return
            }
            sender.backgroundColor = self.backgroundForStyle(style)
        }

        guard !UIAccessibility.isReduceMotionEnabled else {
            restore()
            return
        }

        UIView.animate(
            withDuration: 0.25,
            delay: 0,
            usingSpringWithDamping: 0.6,
            initialSpringVelocity: 0,
            options: [.allowUserInteraction, .beginFromCurrentState],
            animations: restore,
            completion: nil
        )
    }
}
