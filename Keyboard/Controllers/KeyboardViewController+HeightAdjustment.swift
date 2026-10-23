import KeyboardCore
import UIKit

extension KeyboardViewController {
    var isKeyboardHeightAdjusting: Bool { keyboardHeightAdjustmentSession != nil }

    /// 跟随宿主文档回调观察标记；已消费标记在退出后仍保持消费状态。
    func synchronizeKeyboardHeightAdjustment(before: String?, after: String?, documentIdentifier: UUID?) {
        let token = KeyboardHeightAdjustmentMarker.token(before: before, after: after)
        if let session = keyboardHeightAdjustmentSession {
            guard documentIdentifier == session.documentIdentifier else {
                finishKeyboardHeightAdjustment(.hostChanged)
                return
            }
            guard token == session.token else {
                finishKeyboardHeightAdjustment(.pageLeft)
                return
            }
            return
        }
        guard keyboardHeightAdjustmentAcceptsMarkers, let token, let documentIdentifier,
            isKeyboardUIInstalled, keyboardHeightStatus == "ready",
            keyboardHeightAdjustmentTokenConsumer(token)
        else { return }
        keyboardHeightAdjustmentSession = KeyboardHeightAdjustmentSession(
            token: token, documentIdentifier: documentIdentifier,
            originalSettings: keyboardHeightSettings,
            previewSettings: KeyboardHeightSettings(savedRowHeight: Int(keyHeight)))

        // 先收束正在追踪的手势，避免定时连删或长按提交穿透新遮罩。
        endDeleteGestureSession(restoreAppearance: true, reason: .cancelled)
        dismissVariantPopup(animated: false)
        endSpaceCursorMovementForHeightAdjustment()
        resetAllKeyPressVisualState()
        if isCandidateExpanded {
            isCandidateExpanded = false
            dismissExpandedCandidatePanel(animated: false)
        }
        if isPinyinPathExpanded { dismissPinyinPathExpandedPanel(animated: false) }

        let overlay = KeyboardHeightAdjustmentOverlay()
        overlay.slider.addTarget(self, action: #selector(changeKeyboardHeightPreview(_:)), for: .valueChanged)
        overlay.resetButton.addTarget(self, action: #selector(resetKeyboardHeightPreview), for: .touchUpInside)
        overlay.cancelButton.addTarget(self, action: #selector(cancelKeyboardHeightAdjustment), for: .touchUpInside)
        overlay.confirmButton.addTarget(self, action: #selector(confirmKeyboardHeightAdjustment), for: .touchUpInside)
        overlay.nextKeyboardButton.addTarget(
            self, action: #selector(switchKeyboardDuringHeightAdjustment), for: .touchUpInside)
        overlay.onEscape = { [weak self] in self?.cancelKeyboardHeightAdjustment() }
        keyboardHeightAdjustmentOverlay = overlay
        view.addSubview(overlay)
        layoutKeyboardHeightAdjustmentOverlay()
        Logger.shared.debug("keyboardHeightAdjustment: entered", category: .display)
        UIAccessibility.post(notification: .layoutChanged, argument: overlay.slider)
    }

    /// 使用 P1 的封顶模型，再叠加 P2 实授预算；拖动手柄不能越过可显示范围。
    func keyboardHeightAdjustmentMaximum() -> Int? {
        guard let geometry = currentKeyboardHeightGeometry() else { return nil }
        let fixedHeight =
            keyboardContentTopInset + candidateBarHeight + keySpacing * 2
            + keyboardGroupSpacing + keyboardContentBottomInset + presentedT9PinyinPathBarHeight
        guard
            var maximum = try? KeyboardHeightSettings(savedRowHeight: Int.max).effectiveRowHeight(
                orientation: geometry.isLandscape ? .landscape : .portrait,
                screenHeight: geometry.screenHeight, fixedHeight: Double(fixedHeight))
        else { return nil }
        if let accepted = keyboardAcceptedHeight {
            let available = ((accepted - fixedHeight) / 4).rounded(.down)
            guard available >= CGFloat(KeyboardHeightSettings.minimumRowHeight) else { return nil }
            if available < CGFloat(maximum) { maximum = Int(available) }
        }
        return maximum
    }

    @objc func changeKeyboardHeightPreview(_ sender: UISlider) {
        previewKeyboardRowHeight(Double(sender.value))
    }

    func previewKeyboardRowHeight(_ value: Double) {
        guard value.isFinite, var session = keyboardHeightAdjustmentSession,
            let maximum = keyboardHeightAdjustmentMaximum()
        else { return }
        let bounded = min(Double(maximum), max(Double(KeyboardHeightSettings.minimumRowHeight), value.rounded()))
        session.previewSettings.save(rowHeight: Int(bounded))
        session.resetsSavedValue = false
        keyboardHeightAdjustmentSession = session
        synchronizeKeyboardHeightLayout()
        layoutKeyboardHeightAdjustmentOverlay()
    }

    @objc func resetKeyboardHeightPreview() {
        guard var session = keyboardHeightAdjustmentSession else { return }
        session.previewSettings.reset()
        session.resetsSavedValue = true
        keyboardHeightAdjustmentSession = session
        synchronizeKeyboardHeightLayout()
        layoutKeyboardHeightAdjustmentOverlay()
    }

    @objc func cancelKeyboardHeightAdjustment() {
        finishKeyboardHeightAdjustment(.cancelled)
        dismissKeyboard()
    }

    @objc func confirmKeyboardHeightAdjustment() {
        // 重新核对 P2 几何，不能在不可显示状态保存遗留的有效值。
        guard isKeyboardHeightAdjusting,
            resolveKeyboardRowHeight(pathHeight: presentedT9PinyinPathBarHeight)
        else { return }
        finishKeyboardHeightAdjustment(.confirmed)
        dismissKeyboard()
    }

    @objc func switchKeyboardDuringHeightAdjustment() {
        finishKeyboardHeightAdjustment(.keyboardSwitched)
        advanceToNextInputMode()
    }

    func finishKeyboardHeightAdjustment(_ reason: KeyboardHeightAdjustmentExit) {
        guard let session = keyboardHeightAdjustmentSession else { return }
        keyboardHeightAdjustmentSession = nil
        if reason == .confirmed {
            let saved = session.resetsSavedValue ? nil : Int(keyHeight)
            keyboardRowHeightSink(saved)
            keyboardHeightSettings = KeyboardHeightSettings(savedRowHeight: saved)
        } else {
            keyboardHeightSettings = session.originalSettings
        }
        keyboardHeightAdjustmentOverlay?.removeFromSuperview()
        keyboardHeightAdjustmentOverlay = nil
        keyboardSurfaceView?.isUserInteractionEnabled = true
        keyboardSurfaceView?.accessibilityElementsHidden = false
        synchronizeKeyboardHeightLayout()
        Logger.shared.debug("keyboardHeightAdjustment: \(reason.rawValue)", category: .display)
    }

    func layoutKeyboardHeightAdjustmentOverlay() {
        guard let overlay = keyboardHeightAdjustmentOverlay else { return }
        keyboardSurfaceView?.isUserInteractionEnabled = false
        keyboardSurfaceView?.accessibilityElementsHidden = true
        overlay.frame = view.bounds
        // 触区 canvas 可在布局中重建；最后提升遮罩，不能依赖初次 addSubview 顺序。
        view.bringSubviewToFront(overlay)
        if let maximum = keyboardHeightAdjustmentMaximum() {
            overlay.update(rowHeight: Int(keyHeight), maximum: maximum)
        }
    }
}
