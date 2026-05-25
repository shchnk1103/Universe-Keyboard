//
//  KeyboardViewController+KeyFactory.swift
//  Keyboard
//
//  按键按钮的创建工厂方法 + 视觉样式系统。
//
//  关键设计决策：
//
//  1. KeyboardKeyButton（UIButton 子类）— 扩大触控区域
//     Apple 人机界面指南（HIG）建议触控目标不小于 44×44pt。
//     但键盘按键间的实际间距只有 6pt，而 UIKit 默认的 hit testing
//     只在按钮的 bounds 内响应。我们覆盖 point(inside:with:) 方法，
//     将触控区域向四周扩展 touchSlop=10pt，减少了"按到按键缝隙"的情况。
//
//  2. KeyVisualStyle 枚举 — 统一的视觉样式管理
//     替代在布局代码中分散设置 backgroundColor/font/shadow 等属性。
//     applyKeyStyle(_:to:) 一次性设置所有视觉属性，确保一致性。
//     使用 objc_setAssociatedObject 将样式绑定到按钮实例上，
//     以便在 restoreKeyAppearance 时可以查询按钮的原始样式。
//
//  3. 不使用 UIView.animate 进行触控反馈
//     原因在 +Gestures.swift 中已详细说明：直接设置属性是瞬时生效的，
//     避免了 Core Animation 事务的 1 帧（~16ms）延迟。
//

import ObjectiveC
import UIKit

// MARK: === 关联对象 Key ===

/// 用于 objc_setAssociatedObject / objc_getAssociatedObject 的 key。
/// 将 KeyVisualStyle.rawValue 字符串存储在按钮实例上，
/// 使 restoreKeyAppearance 能查询按钮的正常状态颜色。
private var keyVisualStyleAssociationKey: UInt8 = 0

// MARK: === 扩展触控区域的按钮 ===

/// 自定义 UIButton 子类，将触控区域向四周扩展 10pt。
///
/// Apple HIG 建议所有可交互元素的最小触控目标为 44×44pt。
/// 标准键盘按键宽度约 32pt（iPhone 上 10 个按键 + 9 个 6pt 间距 / 375pt），
/// 间距只有 6pt。如果不扩展触控区域，用户很容易按到按键之间的缝隙。
///
/// 覆盖 point(inside:with:) 方法，让按钮也响应对 bounds 外但在
/// 扩展容差（touchSlop=10pt）内的触摸，有效填补了按键间的缝隙。
private final class KeyboardKeyButton: UIButton {

    /// 触控区域向外扩展的容差值（点）
    var touchSlop: CGFloat = 10

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        // 首先检查按钮基本状态：禁用、隐藏、或完全透明时不响应
        guard isEnabled, !isHidden, alpha > 0.01 else {
            return false
        }
        // insetBy 使用负值来扩展判定区域
        return bounds.insetBy(dx: -touchSlop, dy: -touchSlop).contains(point)
    }
}

// MARK: === 按键视觉样式 ===

/// 键盘按键的五种视觉样式。
///
/// 每种样式定义了一套完整的视觉属性（背景色、字体大小、阴影等），
/// 通过 applyKeyStyle(_:to:) 方法应用到按钮上。
enum KeyVisualStyle: String {
    /// 字符键（Q-P, A-L, Z-M）：白色背景（浅色）/ 深灰背景（深色）
    case character
    /// 功能键（Shift, 删除, 123, 地球, 中/英）：灰色背景
    case function
    /// 空格键：与字符键相同背景色，但使用更小的字体（15pt）
    case space
    /// 回车键：灰色背景，较粗字体
    case returnKey
    /// 激活状态键（Caps Lock 激活）：深色背景 + 白色文字
    case active
}

// MARK: === 工厂方法 ===

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
        // 无障碍：VoiceOver 朗读按键标签
        button.accessibilityLabel = title
        // 标记为键盘按键，让 VoiceOver 以"按键"角色朗读
        button.accessibilityTraits = .keyboardKey
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

    // MARK: === 颜色属性 ===

    /// 键盘背景色（动态跟随系统浅色/深色模式）。
    ///
    /// 使用 UIColor(dynamicProvider:) 闭包提供动态颜色：
    ///   - 浅色模式：中性亮灰，匹配原生 iOS 键盘
    ///   - 深色模式：中性深灰黑，匹配原生 iOS 键盘深色外观
    var keyboardBackgroundColor: UIColor {
        UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(red: 30 / 255, green: 30 / 255, blue: 32 / 255, alpha: 1)
                : UIColor(red: 209 / 255, green: 209 / 255, blue: 214 / 255, alpha: 1)
        }
    }

    /// 字符键背景色。
    /// 浅色模式：白色（与原生键盘一致）
    /// 深色模式：深灰
    var characterKeyColor: UIColor {
        UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(red: 62 / 255, green: 62 / 255, blue: 64 / 255, alpha: 1)
                : UIColor.white
        }
    }

    /// 功能键背景色（Shift、删除、123、地球、中/英等）。
    /// 浅色模式：中性灰
    /// 深色模式：深灰
    var functionKeyColor: UIColor {
        UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(red: 44 / 255, green: 44 / 255, blue: 46 / 255, alpha: 1)
                : UIColor(red: 174 / 255, green: 174 / 255, blue: 178 / 255, alpha: 1)
        }
    }

    /// 按键被按下时的高亮背景色。
    /// 浅色模式：浅灰（R:235 G:236 B:239）
    /// 深色模式：中灰（R:116 G:117 B:121）
    var highlightedKeyColor: UIColor {
        UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(red: 92 / 255, green: 92 / 255, blue: 96 / 255, alpha: 1)
                : UIColor(red: 235 / 255, green: 235 / 255, blue: 237 / 255, alpha: 1)
        }
    }

    // MARK: === 样式应用 ===

    /// 将指定的 KeyVisualStyle 应用到按钮上。
    ///
    /// 此方法做三件事：
    ///   1. 通过 objc_setAssociatedObject 将样式记录到按钮实例上
    ///      （用于 restoreKeyAppearance 时查询原始样式）
    ///   2. 设置按钮的图层属性（圆角、阴影）
    ///   3. 设置按钮的视觉属性（背景色、字体、文字颜色）
    ///
    /// 关于关联对象（Associated Object）：
    ///   Objective-C Runtime 的特性，允许在运行时将任意值绑定到对象实例。
    ///   因为在 Swift extension 中不能添加 stored property，
    ///   关联对象是实现"给 UIButton 添加 style 属性"的标准做法。
    ///
    /// - Parameters:
    ///   - style: 要应用的视觉样式
    ///   - button: 目标按钮
    func applyKeyStyle(_ style: KeyVisualStyle, to button: UIButton) {
        // 步骤 1：存储样式到关联对象（key: &keyVisualStyleAssociationKey）
        objc_setAssociatedObject(
            button,
            &keyVisualStyleAssociationKey,
            style.rawValue,
            .OBJC_ASSOCIATION_RETAIN_NONATOMIC  // retain: 持有值; nonatomic: 非线程安全（性能更好）
        )

        // 步骤 2：图层属性
        button.layer.cornerRadius = keyCornerRadius
        button.layer.cornerCurve = .continuous     // 连续曲线 > 标准圆角（iOS 原生外观）
        button.layer.masksToBounds = false          // false 允许阴影显示在按钮外

        // 微妙边框（0.33pt），模仿原生 iOS 按键的立体感
        // 原生键盘的每个键都有极细的分隔线，提供视觉深度
        button.layer.borderWidth = 0.33
        button.layer.borderColor = UIColor.separator.withAlphaComponent(0.3).cgColor

        // 字符键和空格键有微妙的底部阴影（模拟按键凸起感）
        // 功能键（灰色）不需要阴影 — 它们看起来是"嵌在"键盘里的
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = (style == .character || style == .space) ? 0.18 : 0
        button.layer.shadowRadius = 0               // 0 = 硬阴影（锐利边缘）
        button.layer.shadowOffset = CGSize(width: 0, height: 1)  // 向下偏移 1pt

        // 默认文字颜色
        button.setTitleColor(.label, for: .normal)
        button.tintColor = .label

        // 步骤 3：样式特定的属性
        switch style {
        case .character:
            button.backgroundColor = characterKeyColor
            button.titleLabel?.font = .systemFont(ofSize: 20, weight: .regular)
        case .function:
            button.backgroundColor = functionKeyColor
            button.titleLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        case .space:
            button.backgroundColor = characterKeyColor
            button.titleLabel?.font = .systemFont(ofSize: 15, weight: .regular)
        case .returnKey:
            button.backgroundColor = functionKeyColor
            button.titleLabel?.font = .systemFont(ofSize: 16, weight: .regular)
        case .active:
            // Caps Lock 激活状态：反转颜色
            button.backgroundColor = .label           // 深色背景
            button.setTitleColor(.systemBackground, for: .normal) // 浅色文字
            button.tintColor = .systemBackground
            button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        }
    }

    /// 从关联对象中读取按钮的 KeyVisualStyle。
    /// 如果关联对象读取失败（可能因为从未设置），返回 nil。
    func keyStyle(for button: UIButton) -> KeyVisualStyle? {
        guard let rawValue = objc_getAssociatedObject(button, &keyVisualStyleAssociationKey) as? String else {
            return nil
        }
        return KeyVisualStyle(rawValue: rawValue)
    }

    /// 根据 KeyVisualStyle 返回对应的背景色。
    /// 用于 restoreKeyAppearance 还原按键外观。
    func backgroundForStyle(_ style: KeyVisualStyle) -> UIColor {
        switch style {
        case .character, .space:
            return characterKeyColor
        case .function, .returnKey:
            return functionKeyColor
        case .active:
            return .label
        }
    }
}
