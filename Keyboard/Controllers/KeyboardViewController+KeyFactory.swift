//
//  KeyboardViewController+KeyFactory.swift
//  Keyboard
//
//  按键按钮的创建工厂方法。
//
//  关键设计决策：
//
//  1. KeyboardKeyButton（UIButton 子类）— 扩大触控区域
//     Apple 人机界面指南（HIG）建议触控目标不小于 44×44pt。
//     按键视觉间距仍由 UIStackView.spacing 保持；真实触控由
//     KeyboardInputHitAreaStackView 按相邻按键中线切分（26 键与九键同一规则；
//     九键只按左右列切网）。KeyboardKeyButton 的 expandedTouchOutsets
//     对齐该触摸单元，使缝里转发的触摸在抬手时仍算 touchUpInside。
//
import KeyboardCore
import UIKit

extension KeyboardViewController {

    /// PB-017 PR-2：为 26 键字符键挂接双拼副标（独立右下角子 `UILabel`）。
    ///
    /// 仅当 26 键槽位激活方案为双拼（`cachedShuangpinLegendTable != nil`）且
    /// `cachedShuangpinSublegendEnabled` 为真、该键存在非空副标时显示；九宫格
    /// 与非双拼方案整键隐藏。副标 9pt regular、`.secondaryLabel` 色，右下角
    /// 悬浮（与主标题最小间距 2pt），不参与无障碍朗读（a11y 由 label 拼接承
    /// 担），不改 `CharacterKeyStyle` 与 17pt 主标题管线、不突破 45pt 冻结键高。
    /// 方案/开关变化走 `reloadKeyboard()` 重建键帽（既有路径）。
    static let shuangpinSublegendTag = 0x53504C47  // 'SPLG'

    func applyShuangpinSublegend(to button: UIButton, key: String) {
        button.viewWithTag(Self.shuangpinSublegendTag)?.removeFromSuperview()
        guard
            let legend = cachedShuangpinLegendTable?.sublegend(for: key),
            cachedShuangpinSublegendEnabled
        else {
            // 副标隐藏时还原默认 a11y label（与 configureKeyAccessibility 一致）。
            button.accessibilityLabel = displayTitle(for: key)
            return
        }
        let sublabel = UILabel()
        sublabel.tag = Self.shuangpinSublegendTag
        sublabel.text = legend
        sublabel.font = .systemFont(ofSize: 9, weight: .regular)
        sublabel.textColor = .secondaryLabel
        sublabel.textAlignment = .right
        sublabel.isAccessibilityElement = false
        sublabel.translatesAutoresizingMaskIntoConstraints = false
        button.addSubview(sublabel)
        NSLayoutConstraint.activate([
            sublabel.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: -3),
            sublabel.bottomAnchor.constraint(equalTo: button.bottomAnchor, constant: -2),
            // 与主标题（17pt，居中）的最小垂直间距 2pt：副标顶不低于中心线 +2pt。
            sublabel.topAnchor.constraint(greaterThanOrEqualTo: button.centerYAnchor, constant: 2),
            sublabel.widthAnchor.constraint(lessThanOrEqualTo: button.widthAnchor, constant: -6),
        ])
        button.accessibilityLabel = "\(key.uppercased())，双拼 \(legend)"
    }

    /// Creates a native-style T9 letter-group key.
    ///
    /// Visual primary label is the letter group (e.g. `ABC`); the RIME payload remains the
    /// digit identity in `accessibilityIdentifier` (e.g. `2`). `insertKey` prefers that
    /// identifier when `accessibilityValue == t9DigitAccessibilityValue`.
    func makeT9KeyButton(digit: String, letters: String) -> UIButton {
        let button = makeKeyButton(title: letters.isEmpty ? digit : letters, action: #selector(insertKey(_:)))
        (button as? KeyboardKeyButton)?.isOrdinaryRolloverParticipant = true
        button.accessibilityIdentifier = digit
        button.accessibilityValue = Self.t9DigitAccessibilityValue
        if letters.isEmpty {
            button.accessibilityLabel = "数字 \(digit)"
            applyKeyStyle(.character, to: button)
            return button
        }

        button.accessibilityLabel = "\(letters)，数字 \(digit)"
        #if T9_AUTO_ANCHOR_DEVICE_PREFLIGHT
            // Slot order follows the visible ABC…WXYZ construction order.
            devicePreflightT9LetterGroupButtons.append(button)
        #endif
        button.setTitle(
            characterKeyStyle.displayTitle(letters, layout: .chinese9, shifted: isShiftActive), for: .normal)
        button.titleLabel?.numberOfLines = 1
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.minimumScaleFactor = 0.7
        applyKeyStyle(.character, to: button)
        return button
    }

    /// Marker stored on T9 letter keys so `insertKey` sends the digit identity, not the label.
    static let t9DigitAccessibilityValue = "t9Digit"

    /// 创建标准按键按钮。
    ///
    /// 每个按钮绑定 4 个 target-action：
    ///   - .touchUpInside → 参数中传入的 action（insertKey/toggleShift 等）
    ///   - .touchDown → keyTouchDown（视觉反馈）
    ///   - .touchUpInside, .touchUpOutside, .touchDragExit, .touchCancel → keyTouchUp（恢复外观）
    ///
    /// 注意：touchUpInside 同时绑定了 action 和 keyTouchUp。
    /// 调用顺序由事件类型决定：touchDown 先于 touchUpInside，
    /// 但在同一个 UIControl 上，多个 action 的执行顺序由添加顺序决定。
    ///
    /// - Parameters:
    ///   - title: 按钮标题文本
    ///   - action: touchUpInside 时触发的业务方法
    /// - Returns: 配置完成的 KeyboardKeyButton
    func makeKeyButton(title: String, action: Selector) -> UIButton {
        // 使用 KeyboardKeyButton（自定义子类）而非标准 UIButton
        // 以获得扩展的触控区域
        let button = KeyboardKeyButton(type: .system)
        button.setTitle(title, for: .normal)
        if action == #selector(insertKey(_:)) {
            button.accessibilityIdentifier = title
            button.titleLabel?.numberOfLines = 1
            button.titleLabel?.adjustsFontSizeToFitWidth = true
            button.titleLabel?.minimumScaleFactor = 0.7
        }
        button.titleLabel?.font = .systemFont(ofSize: characterKeyTitlePointSize, weight: .regular)
        #if DEBUG
            button.trackingEventHandler = { [weak self] button, phase in
                self?.recordKeyboardTrackingDiagnostic(button: button, phase: phase)
            }
        #endif
        button.canBeginOrdinaryRolloverTouch = { [weak self] button in
            self?.canBeginOrdinaryRolloverTouch(for: button) ?? false
        }
        button.onOrdinaryRolloverTrackingEvent = { [weak self] button, event in
            self?.handleOrdinaryRolloverTrackingEvent(event, for: button)
        }
        // 默认应用字符键样式 — 调用方可以根据需要覆盖（如 applyKeyStyle(.function, to:)）
        applyKeyStyle(.character, to: button)

        // ── 绑定事件 ────────────────────────────────────────────
        // 1. 业务动作（touchUpInside — 手指在按钮内松开）
        button.addTarget(self, action: action, for: .touchUpInside)
        // 2. 按下反馈（touchDown — 手指触碰按钮瞬间）
        button.addTarget(self, action: #selector(keyTouchDown(_:)), for: .touchDown)
        // 3. 松开恢复（多种松开事件 — 手指离开、滑出、取消等）
        button.addTarget(
            self,
            action: #selector(keyTouchUp(_:)),
            for: [.touchUpInside, .touchUpOutside, .touchDragExit, .touchCancel]
        )
        configureKeyAccessibility(button, title: title, action: action)
        return button
    }

    /// Applies a template SF Symbol used by Delete / Return / Globe-style function keys.
    func applyFunctionKeySymbol(_ systemName: String, to button: UIButton) {
        button.setTitle(nil, for: .normal)
        button.setAttributedTitle(nil, for: .normal)
        let image = UIImage(systemName: systemName)?.withRenderingMode(.alwaysTemplate)
        button.setImage(image, for: .normal)
        button.setPreferredSymbolConfiguration(
            UIImage.SymbolConfiguration(pointSize: functionKeySymbolPointSize, weight: .regular),
            forImageIn: .normal
        )
    }

    /// 创建删除键按钮（按住会话：单击松手、水平擦除、长按重复）。
    ///
    /// 与普通按键的区别：
    ///   - touchDown 只建立会话和按下反馈，不删字
    ///   - 拖动（含 touchDragExit）更新会话，不结束按住
    ///   - touchUpInside / touchUpOutside 才结束会话
    ///   - 不绑定标准 keyTouchDown/keyTouchUp（避免冲突）
    func makeDeleteButton() -> UIButton {
        let lift = #selector(deleteKeyTouchUpInside(_:forEvent:))
        let button = makeKeyButton(title: "", action: lift)
        applyFunctionKeySymbol("delete.left", to: button)

        button.removeTarget(self, action: lift, for: .touchUpInside)
        button.removeTarget(self, action: #selector(keyTouchDown(_:)), for: .touchDown)
        button.removeTarget(
            self,
            action: #selector(keyTouchUp(_:)),
            for: [.touchUpInside, .touchUpOutside, .touchDragExit, .touchCancel]
        )

        button.addTarget(self, action: #selector(deleteKeyTouchDown(_:forEvent:)), for: .touchDown)
        button.addTarget(self, action: lift, for: .touchUpInside)
        button.addTarget(
            self,
            action: #selector(deleteKeyTouchUpOutside(_:forEvent:)),
            for: .touchUpOutside
        )
        button.addTarget(
            self,
            action: #selector(deleteKeyTouchDrag(_:forEvent:)),
            for: [.touchDragInside, .touchDragOutside, .touchDragExit]
        )
        button.addTarget(self, action: #selector(deleteKeyTouchCancel(_:)), for: .touchCancel)

        // 删除键使用功能键样式（灰色背景）
        applyKeyStyle(.function, to: button)
        // applyKeyStyle may reset title color; keep template symbol tint on the image.
        button.tintColor = .label
        return button
    }

    /// 根据当前 Shift 状态返回按键的显示标题（大写或小写）。
    /// - Parameter key: 原始按键值（小写，如 "a"）
    /// - Returns: Shift 开启时返回大写（"A"），否则返回小写（"a"）
    func displayTitle(for key: String) -> String {
        let layout: CharacterKeyStyle.Layout = controller.state.inputMode == .chinese ? .chinese26 : .english26
        return characterKeyStyle.displayTitle(key, layout: layout, shifted: isShiftActive)
    }
}
