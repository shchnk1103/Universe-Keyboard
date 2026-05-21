//
//  KeyboardViewController+Gestures.swift
//  Keyboard
//
//  按键高亮和长按变体字符弹出面板。
//

import UIKit
import KeyboardCore

// MARK: - 按键高亮

extension KeyboardViewController {

    @objc func keyTouchDown(_ sender: UIButton) {
        sender.backgroundColor = highlightedKeyColor
        UIView.animate(withDuration: 0.06) {
            sender.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)
        }
    }

    @objc func keyTouchUp(_ sender: UIButton) {
        restoreKeyAppearance(sender)
    }

    func restoreKeyAppearance(_ sender: UIButton) {
        UIView.animate(withDuration: 0.08) {
            sender.transform = .identity
        }

        if sender === shiftButton {
            updateShiftButtonAppearance()
            return
        }

        guard let style = keyStyle(for: sender) else {
            applyKeyStyle(.character, to: sender)
            return
        }

        applyKeyStyle(style, to: sender)
    }
}

// MARK: - 长按变体字符

extension KeyboardViewController {

    @objc func handleKeyLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard let button = gesture.view as? UIButton else { return }

        switch gesture.state {
        case .began:
            button.cancelTracking(with: nil)
            showVariantPopup(on: button)
        case .changed:
            updateVariantPopup(gesture: gesture)
        case .ended:
            commitVariantPopup(gesture: gesture)
        case .cancelled, .failed:
            dismissVariantPopup()
        default:
            break
        }
    }

    private func showVariantPopup(on button: UIButton) {
        guard let key = button.accessibilityIdentifier else { return }
        let uppercase = isShiftActive
        guard let variants = KeyPopupView.variants(for: key, uppercase: uppercase) else { return }

        dismissVariantPopup(animated: false)

        let keyFrame = button.convert(button.bounds, to: view)
        let popup = KeyPopupView(variants: variants, keyFrame: keyFrame, in: view.bounds)
        variantPopupView = popup
        longPressedButton = button

        view.addSubview(popup)

        popup.alpha = 0
        popup.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
        UIView.animate(withDuration: 0.12) {
            popup.alpha = 1
            popup.transform = .identity
        }

        button.backgroundColor = highlightedKeyColor
    }

    private func updateVariantPopup(gesture: UILongPressGestureRecognizer) {
        guard let popup = variantPopupView else { return }
        let point = gesture.location(in: view)
        popup.selectVariant(at: point)
    }

    private func commitVariantPopup(gesture: UILongPressGestureRecognizer) {
        guard let popup = variantPopupView else { return }

        let point = gesture.location(in: view)
        let expandedFrame = popup.frame.insetBy(dx: -16, dy: -16)

        if expandedFrame.contains(point) {
            let variant = popup.currentVariant
            dismissVariantPopup()
            playKeyClick()
            playHaptic()
            let effects = controller.handle(.insertKey(variant))
            syncUI(with: effects)
        } else {
            dismissVariantPopup()
        }
    }

    private func dismissVariantPopup(animated: Bool = true) {
        if let longPressedButton {
            restoreKeyAppearance(longPressedButton)
        }
        longPressedButton = nil

        guard let popup = variantPopupView else { return }
        variantPopupView = nil

        guard animated else {
            popup.removeFromSuperview()
            return
        }

        UIView.animate(withDuration: 0.1, animations: {
            popup.alpha = 0
            popup.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
        }, completion: { _ in
            popup.removeFromSuperview()
        })
    }
}
