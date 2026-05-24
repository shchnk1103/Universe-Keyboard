//
//  KeyboardViewController+Gestures.swift
//  Keyboard
//
//  按键高亮反馈 + 长按变体字符弹出面板。
//
//  Apple 文档参考：
//  - UILongPressGestureRecognizer: 用于检测按键长按
//  - UIButton.cancelTracking: 取消按钮的默认 touch 追踪
//
//  触摸反馈设计原理：
//  原生 iOS 键盘在 touchDown 时立即改变按键外观（变暗 + 轻微缩放），
//  使用瞬时 transform + backgroundColor 而非 UIView.animate，
//  原因：Core Animation 动画事务会有 1 帧延迟，导致快速输入时反馈跟不上。
//

import UIKit
import KeyboardCore

// MARK: === 按键高亮 ===

extension KeyboardViewController {

    /// 按键按下时的视觉反馈（.touchDown 事件）。
    ///
    /// 设计决策 — touchDown 必须瞬时响应：
    ///   快速打字时（>10 次/秒），Core Animation 的 1 帧延迟（~16ms）
    ///   会导致反馈明显滞后。因此 touchDown 使用瞬时属性设置，
    ///   不用 UIView.animate。
    ///
    /// 同时记录 touchDown 时间戳，用于性能诊断。
    @objc func keyTouchDown(_ sender: UIButton) {
        let now = CACurrentMediaTime()
        keyTouchDownTimes[ObjectIdentifier(sender)] = now

        if Logger.shared.isEnabled {
            let title = sender.title(for: .normal) ?? sender.accessibilityIdentifier ?? "?"
            Logger.shared.performance("keyDown '\(title)'")
        }

        // 瞬时高亮：略暗的背景色 + 96% 缩放（模拟按下感）
        sender.backgroundColor = highlightedKeyColor
        sender.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)
    }

    /// 按键松开时的视觉恢复。
    @objc func keyTouchUp(_ sender: UIButton) {
        restoreKeyAppearance(sender)
    }

    /// 恢复按键的正常外观 — 使用弹性动画模拟原生 iOS 键盘的"弹回"效果。
    ///
    /// 弹性动画参数说明：
    ///   - duration: 0.25s — 足够短，不影响连续输入节奏
    ///   - delay: 0 — 立即开始
    ///   - dampingRatio: 0.6 — 轻微弹跳（0=最大弹跳, 1=无弹跳）
    ///   - initialSpringVelocity: 0 — 从静止开始
    ///
    /// 无障碍适配：若开启 Reduce Motion，跳过动画直接恢复。
    func restoreKeyAppearance(_ sender: UIButton) {
        // 尊重用户的 Reduce Motion 设置（Apple HIG 要求）
        let shouldAnimate = !UIAccessibility.isReduceMotionEnabled

        let restore = {
            sender.transform = .identity  // 恢复原始尺寸

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

        if shouldAnimate {
            // 使用 UIView 的弹性动画 API（iOS 7+），
            // 比 CASpringAnimation 更简洁且自动处理 completion
            UIView.animate(
                withDuration: 0.25,
                delay: 0,
                usingSpringWithDamping: 0.6,
                initialSpringVelocity: 0,
                options: [.allowUserInteraction, .beginFromCurrentState],
                animations: restore,
                completion: nil
            )
        } else {
            restore()
        }
    }
}

// MARK: === 空格键光标滑动 ===

extension KeyboardViewController {

    /// 空格键左右滑动 — 移动文本光标。
    ///
    /// 模仿原生 iOS 键盘的 Space Cursor 行为：
    ///   手指在空格键上左右滑动 → 光标跟随移动。
    ///   每 10pt 水平移动 = 1 个字符偏移。
    ///
    /// 使用 UITextDocumentProxy.adjustTextPosition(byCharacterOffset:) (iOS 15+)。
    @objc func handleSpaceCursorPan(_ gesture: UIPanGestureRecognizer) {
        guard let spaceButton = gesture.view else { return }

        switch gesture.state {
        case .changed:
            let translation = gesture.translation(in: spaceButton)
            // 每 10pt 水平滑动 = 移动 1 个字符
            let sensitivity: CGFloat = 10
            let offset = Int(translation.x / sensitivity)
            if offset != 0 {
                // 调整光标位置后重置手势基准点
                textDocumentProxy.adjustTextPosition(byCharacterOffset: offset)
                gesture.setTranslation(.zero, in: spaceButton)
            }

        case .ended, .cancelled:
            // 松手后恢复正常空格外观
            if let btn = spaceButton as? UIButton {
                restoreKeyAppearance(btn)
            }

        default:
            break
        }
    }
}

// MARK: === 长按变体字符 ===

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
            playKeyClick()
            playHaptic()
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
