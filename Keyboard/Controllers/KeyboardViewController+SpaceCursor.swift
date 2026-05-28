import UIKit

extension KeyboardViewController {
    /// Moves the insertion point by one character for every 10 points of horizontal travel.
    @objc func handleSpaceCursorPan(_ gesture: UIPanGestureRecognizer) {
        guard let spaceButton = gesture.view else { return }

        switch gesture.state {
        case .changed:
            let offset = Int(gesture.translation(in: spaceButton).x / 10)
            guard offset != 0 else { return }
            textDocumentProxy.adjustTextPosition(byCharacterOffset: offset)
            gesture.setTranslation(.zero, in: spaceButton)
        case .ended, .cancelled:
            if let button = spaceButton as? UIButton {
                restoreKeyAppearance(button)
            }
        default:
            break
        }
    }
}
