import UIKit

// MARK: - Space Key Cursor Control

extension KeyboardViewController {
    /// Handles the trackpad-like cursor gesture on the space key.
    ///
    /// The space key is created in `makeBottomRow` with two behaviors:
    /// tapping inserts a normal space, while a long-press converts the keyboard into a trackpad,
    /// moving the insertion point horizontally inside the host app's active text field.
    @objc func handleSpaceCursorLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard let spaceButton = gesture.view as? UIButton else { return }

        switch gesture.state {
        case .began:
            isCursorMovementModeActive = true
            spaceCursorLastLocationX = gesture.location(in: spaceButton).x
            setCursorMovementModeUI(active: true, exceptionView: spaceButton)
            // Restoring the key appearance removes the default pressed state color
            restoreKeyAppearance(spaceButton)

        case .changed:
            guard let lastX = spaceCursorLastLocationX else { return }
            let currentX = gesture.location(in: spaceButton).x
            let diff = currentX - lastX
            // A 10-point threshold keeps small finger jitter from moving the cursor too aggressively.
            let offset = Int(diff / 10)
            
            if offset != 0 {
                textDocumentProxy.adjustTextPosition(byCharacterOffset: offset)
                // Compensate the last location by the exact movement distance we just applied
                spaceCursorLastLocationX = lastX + CGFloat(offset * 10)
            }

        case .ended, .cancelled:
            isCursorMovementModeActive = false
            spaceCursorLastLocationX = nil
            setCursorMovementModeUI(active: false, exceptionView: spaceButton)
            restoreKeyAppearance(spaceButton)

        default:
            break
        }
    }

    private func setCursorMovementModeUI(active: Bool, exceptionView: UIView) {
        func updateButtons(in view: UIView) {
            for subview in view.subviews {
                if let button = subview as? UIButton, button != exceptionView {
                    button.isUserInteractionEnabled = !active
                    // Apply a subtle disabled visual state to keys during cursor movement mode.
                    let targetAlpha: CGFloat = active ? 0.3 : 1.0
                    button.titleLabel?.alpha = targetAlpha
                    button.imageView?.alpha = targetAlpha
                } else if let stack = subview as? UIStackView {
                    updateButtons(in: stack)
                }
            }
        }
        if let root = rootStack {
            updateButtons(in: root)
        }
    }
}
