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
//     KeyboardInputHitAreaStackView 按相邻按键中线切分为连续触控单元。
//     KeyboardKeyButton 的 touchSlop 负责让这些转发触摸在 touch-up
//     和长按 tracking 阶段仍被视为有效。
//
import UIKit

extension KeyboardViewController {

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
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .regular)
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

    /// 创建删除键按钮（特殊处理：长按自动重复）。
    ///
    /// 与普通按键的区别：
    ///   - touchDown 绑定 deleteKeyTouchDown（含立即删除 + 计时器逻辑）
    ///   - touchUpInside 绑定 deleteKeyTouchUpInside（停止计时器）
    ///   - touchUpOutside/touchDragExit 绑定 deleteKeyTouchUpOutside（停止计时器）
    ///   - 不绑定标准 keyTouchDown/keyTouchUp（避免冲突）
    ///
    /// 需要先移除 makeKeyButton 添加的默认事件绑定，再重新绑定删除专用事件。
    func makeDeleteButton() -> UIButton {
        let button = makeKeyButton(
            title: "⌫",
            action: #selector(deleteKeyTouchUpInside(_:))
        )

        // ── 替换事件绑定 ─────────────────────────────────────────
        // 移除 makeKeyButton 添加的默认绑定
        button.removeTarget(self, action: #selector(deleteKeyTouchUpInside(_:)), for: .touchUpInside)
        button.removeTarget(self, action: #selector(keyTouchDown(_:)), for: .touchDown)
        button.removeTarget(
            self,
            action: #selector(keyTouchUp(_:)),
            for: [.touchUpInside, .touchUpOutside, .touchDragExit, .touchCancel]
        )

        // 添加删除专用事件绑定
        button.addTarget(self, action: #selector(deleteKeyTouchDown(_:)), for: .touchDown)
        button.addTarget(self, action: #selector(deleteKeyTouchUpInside(_:)), for: .touchUpInside)
        button.addTarget(
            self,
            action: #selector(deleteKeyTouchUpOutside(_:)),
            for: [.touchUpOutside, .touchDragExit]
        )

        // 删除键使用功能键样式（灰色背景）
        applyKeyStyle(.function, to: button)
        return button
    }

    /// 根据当前 Shift 状态返回按键的显示标题（大写或小写）。
    /// - Parameter key: 原始按键值（小写，如 "a"）
    /// - Returns: Shift 开启时返回大写（"A"），否则返回小写（"a"）
    func displayTitle(for key: String) -> String {
        isShiftActive ? key.uppercased() : key.lowercased()
    }
}
