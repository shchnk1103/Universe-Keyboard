//
//  KeyboardViewController+Gestures.swift
//  Keyboard
//
//  长按变体字符弹出面板。
//
//  Apple 文档参考：
//  - UILongPressGestureRecognizer: 用于检测按键长按
//  - UIButton.cancelTracking: 取消按钮的默认 touch 追踪
//
import KeyboardCore
import UIKit

extension KeyboardViewController {

    /// 长按字母键手势的状态机处理。
    ///
    /// UILongPressGestureRecognizer 状态流转：
    ///   .began → .changed → .changed → ... → .ended（正常完成）
    ///   .began → .cancelled（系统中断，如来电）
    ///   .began → .failed（手势识别失败）
    ///
    /// 我们的处理：
    ///   .began: 取消按钮的默认 touchUpInside 追踪 → 显示变体弹出面板
    ///   .changed: 手指在面板上移动 → 更新高亮的变体字符
    ///   .ended: 手指离开 → 提交当前高亮的变体
    ///   .cancelled/.failed: 手势失败 → 关闭面板
    @objc func handleKeyLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard let button = gesture.view as? UIButton else { return }

        switch gesture.state {
        case .began:
            // 取消按钮的默认追踪，防止松开时触发 insertKey
            button.cancelTracking(with: nil)
            showVariantPopup(on: button)

        case .changed:
            // 手指滑动时更新高亮的变体字符
            updateVariantPopup(gesture: gesture)

        case .ended:
            // 手指离开时提交选中的变体
            commitVariantPopup(gesture: gesture)

        case .cancelled, .failed:
            // 手势被取消 — 关闭面板，恢复按键外观
            dismissVariantPopup()

        default:
            break
        }
    }

    /// 显示变体字符弹出面板。
    ///
    /// 弹出面板定位在按键上方，水平居中（若靠近屏幕边缘则自动调整）。
    /// 面板背景为系统灰色，白色文字，圆角 + 阴影。
    ///
    /// 动画：淡入 + 从 85% 放大到 100%（0.12s），制造"弹出"感。
    private func showVariantPopup(on button: UIButton) {
        guard let key = button.accessibilityIdentifier else { return }
        let uppercase = isShiftActive
        guard let variants = KeyPopupView.variants(for: key, uppercase: uppercase) else { return }

        // 如果已有旧的面板，先立即移除（无动画）
        dismissVariantPopup(animated: false)

        let keyFrame = button.convert(button.bounds, to: view)
        let popup = KeyPopupView(variants: variants, keyFrame: keyFrame, in: view.bounds)
        variantPopupView = popup
        longPressedButton = button

        view.addSubview(popup)

        // 弹出动画（尊重 Reduce Motion 设置）
        if !UIAccessibility.isReduceMotionEnabled {
            popup.alpha = 0
            popup.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
            UIView.animate(withDuration: 0.12) {
                popup.alpha = 1
                popup.transform = .identity
            }
        }

        // 按键本身保持高亮状态
        button.backgroundColor = highlightedKeyColor
    }

    /// 根据手指位置更新面板中高亮的变体字符。
    /// 手指在哪个变体标签上，哪个标签就变为蓝色加粗。
    private func updateVariantPopup(gesture: UILongPressGestureRecognizer) {
        guard let popup = variantPopupView else { return }
        let point = gesture.location(in: view)
        popup.selectVariant(at: point)
    }

    /// 提交变体选择。
    ///
    /// 手指在面板范围内松开（扩展 16pt 容差）→ 插入选中的变体字符。
    /// 手指滑到面板外部松开 → 取消，不插入任何字符。
    private func commitVariantPopup(gesture: UILongPressGestureRecognizer) {
        guard let popup = variantPopupView else { return }

        let point = gesture.location(in: view)
        // 扩展判定区域 16pt，让手指不必完全精确在面板内
        let expandedFrame = popup.frame.insetBy(dx: -16, dy: -16)

        if expandedFrame.contains(point) {
            let variant = popup.currentVariant
            dismissVariantPopup()
            emitKeyPressFeedback()
            // 插入变体字符（如 à、ç、ñ 等）
            let effects = controller.handle(.insertKey(variant))
            syncUI(with: effects)
        } else {
            // 手指在面板外松开 → 取消选择
            dismissVariantPopup()
        }
    }

    /// 关闭变体字符弹出面板。
    ///
    /// 动画（animated=true）：淡出 + 缩小到 85%（0.1s），动画完成后从视图层级移除。
    /// 立即（animated=false）：直接 removeFromSuperview，用于新面板创建前的快速清理。
    private func dismissVariantPopup(animated: Bool = true) {
        // 恢复长按按钮的原始外观
        if let longPressedButton {
            restoreKeyAppearance(longPressedButton)
        }
        longPressedButton = nil

        guard let popup = variantPopupView else { return }
        variantPopupView = nil  // 立即清除引用，防止重复操作

        guard animated else {
            popup.removeFromSuperview()
            return
        }

        if UIAccessibility.isReduceMotionEnabled {
            popup.removeFromSuperview()
            return
        }

        // 关闭动画：淡出 + 缩小
        UIView.animate(
            withDuration: 0.1,
            animations: {
                popup.alpha = 0
                popup.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
            },
            completion: { _ in
                popup.removeFromSuperview()
            }
        )
    }
}
