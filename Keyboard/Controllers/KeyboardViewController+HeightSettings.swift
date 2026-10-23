import KeyboardCore
import UIKit

/// 来自当前扩展窗口；screenHeight 是界面方向下的整屏 pt 高，不是键盘自身高度。
struct KeyboardHeightGeometry: Equatable {
    let screenHeight: Double
    let isLandscape: Bool
}

/// 弱引用避免保留已被移除的行/面板；更新时仍使用各自原来的系数和间距。
struct KeyboardRowHeightConstraint {
    weak var constraint: NSLayoutConstraint?
    let rows: CGFloat
    let extraHeight: CGFloat
}

extension KeyboardViewController {
    static var defaultKeyboardHeightWithoutPath: CGFloat {
        CGFloat(KeyboardHeightSettings.defaultRowHeight) * 4 + 74
    }

    func prepareKeyboardHeightForAppearance() {
        isKeyboardHeightManaged = true
        if keyboardHeightNeedsRead {
            keyboardHeightSettings = KeyboardHeightSettings(savedRowHeight: keyboardRowHeightSource())
            keyboardHeightNeedsRead = false
            keyboardAcceptedHeight = nil
            keyboardHeightGeometry = nil
            view.alpha = 0
        }
        _ = resolveKeyboardRowHeight(pathHeight: presentedT9PinyinPathBarHeight)
    }

    func currentKeyboardHeightGeometry() -> KeyboardHeightGeometry? {
        if let source = keyboardHeightGeometrySource { return source() }
        guard let scene = view.window?.windowScene else { return nil }
        let orientation: UIInterfaceOrientation
        if #available(iOS 26.0, *) {
            orientation = scene.effectiveGeometry.interfaceOrientation
        } else {
            orientation = scene.interfaceOrientation
        }
        guard orientation.isPortrait || orientation.isLandscape else { return nil }
        let size = scene.screen.bounds.size
        // 整屏边长按界面方向归一化，不能用键盘宽高比或物理设备方向推断。
        let height = orientation.isLandscape ? min(size.width, size.height) : max(size.width, size.height)
        guard height.isFinite, height > 0 else { return nil }
        return KeyboardHeightGeometry(screenHeight: Double(height), isLandscape: orientation.isLandscape)
    }

    @discardableResult
    func resolveKeyboardRowHeight(pathHeight: CGFloat) -> Bool {
        guard let geometry = currentKeyboardHeightGeometry() else {
            deferKeyboardHeightLayout(reason: "waitingForWindowScene")
            return false
        }
        if keyboardHeightGeometry != geometry {
            keyboardHeightGeometry = geometry
            keyboardAcceptedHeight = nil
        }
        let fixedHeight =
            keyboardContentTopInset + candidateBarHeight + keySpacing * 2
            + keyboardGroupSpacing + keyboardContentBottomInset + pathHeight
        do {
            let settings = keyboardHeightAdjustmentSession?.previewSettings ?? keyboardHeightSettings
            let desired = try settings.effectiveRowHeight(
                orientation: geometry.isLandscape ? .landscape : .portrait,
                screenHeight: geometry.screenHeight, fixedHeight: Double(fixedHeight))
            keyboardUncompressedHeight = fixedHeight + CGFloat(desired) * 4
            var effective = CGFloat(desired)
            if let accepted = keyboardAcceptedHeight {
                let available = ((accepted - fixedHeight) / 4).rounded(.down)
                guard available >= CGFloat(KeyboardHeightSettings.minimumRowHeight) else {
                    deferKeyboardHeightLayout(reason: "hostBudgetBelowMinimum")
                    return false
                }
                effective = min(effective, available)
            }
            keyHeight = effective
            keyboardHeightConstraints.removeAll { $0.constraint == nil }
            for entry in keyboardHeightConstraints {
                let height = effective * entry.rows + entry.extraHeight
                if entry.constraint?.constant != height { entry.constraint?.constant = height }
            }
            recordKeyboardHeightStatus("ready")
            return true
        } catch {
            deferKeyboardHeightLayout(reason: "invalidOrInsufficientGeometry")
            return false
        }
    }

    /// 几何尚不可用时既不请求默认高度，也不展示旧宿主留下的行高。
    private func deferKeyboardHeightLayout(reason: String) {
        view.alpha = 0
        keyboardHeightConstraint?.isActive = false
        recordKeyboardHeightStatus(reason)
    }

    private func recordKeyboardHeightStatus(_ status: String) {
        guard keyboardHeightStatus != status else { return }
        keyboardHeightStatus = status
        Logger.shared.debug("keyboardHeight: \(status)", category: .display)
    }

    func synchronizeKeyboardHeightLayout() {
        // 未经 bootstrap/显式准备的布局不能因缺少 scene 被转换成隐藏状态。
        guard isKeyboardHeightManaged, !isUpdatingKeyboardHeight else { return }
        isUpdatingKeyboardHeight = true
        defer { isUpdatingKeyboardHeight = false }
        // 只有可见的真实窗口才把实际输入容器高度当作宿主预算；测试可单独注入预算。
        if view.window != nil, hostLifecycleRecoveryGate.phase == .visible,
            let requested = keyboardUncompressedHeight, view.bounds.height > 0
        {
            keyboardAcceptedHeight = view.bounds.height < requested ? view.bounds.height : nil
        }
        guard resolveKeyboardRowHeight(pathHeight: presentedT9PinyinPathBarHeight) else { return }
        installPreferredKeyboardHeight()
        installKeyboardUIIfNeeded()
        if isKeyboardUIInstalled { view.alpha = 1 }
    }
}
