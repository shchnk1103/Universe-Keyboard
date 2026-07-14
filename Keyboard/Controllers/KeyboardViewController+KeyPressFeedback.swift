import KeyboardCore
import UIKit

extension KeyboardViewController {
    /// Records touch timing and responds synchronously so rapid typing receives immediate feedback.
    @objc func keyTouchDown(_ sender: UIButton) {
        let identifier = ObjectIdentifier(sender)
#if DEBUG
        keyTouchDownTimes[identifier] = CACurrentMediaTime()
#endif
        keyPressFeedbackEmittedButtonIDs.insert(identifier)

#if DEBUG
        Logger.shared.performance("keyDown registered")
#endif

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

    func resetAllKeyPressVisualState() {
        keyTouchDownTimes.removeAll()
        keyPressFeedbackEmittedButtonIDs.removeAll()
        restoreButtons(in: view)
    }

    private func restoreButtons(in root: UIView?) {
        guard let root else { return }
        if let button = root as? UIButton {
            UIView.performWithoutAnimation {
                button.transform = .identity
                if button === shiftButton {
                    updateShiftButtonAppearance()
                } else if let style = keyStyle(for: button) {
                    button.backgroundColor = backgroundForStyle(style)
                }
            }
        }

        for subview in root.subviews {
            restoreButtons(in: subview)
        }
    }
}
