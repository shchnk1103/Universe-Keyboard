//
//  KeyboardViewController+Display.swift
//  Keyboard
//
//  显示相关的计算属性和按钮状态刷新方法。
//
//  所有按钮标题计算属性都定义在此扩展中，遵循单一职责：
//  逻辑（KeyboardController）→ 标题计算（此文件）→ 按钮构建（+Layout）→ 动作（+Actions）。
//

import UIKit
import KeyboardCore

// MARK: === 显示计算属性 ===

extension KeyboardViewController {

    /// 输入模式切换键标题："中" 或 "英"。
    /// 显示当前激活的输入模式，让用户知道按下后会切换到哪种模式。
    var inputModeButtonTitle: String {
        controller.state.inputMode == .chinese ? "中" : "英"
    }

    /// 是否显示邮箱快捷键（@ 和 .）。
    /// 仅在字母页 + keyboardType == .emailAddress 时显示。
    ///
    /// Apple 文档：对于 .emailAddress 类型的键盘，应提供 @ 和 . 快捷输入。
    var shouldShowEmailShortcutKeys: Bool {
        controller.state.currentPage == .letters
            && controller.state.activeKeyboardType == .emailAddress
    }

    /// 是否显示 URL 快捷键（/ 和 .com）。
    /// 仅在字母页 + keyboardType 为 .URL 或 .webSearch 时显示。
    ///
    /// Apple 文档：对于 URL 和 webSearch 键盘类型，应提供 / 和域名后缀快捷输入。
    var shouldShowURLShortcutKeys: Bool {
        controller.state.currentPage == .letters
            && (controller.state.activeKeyboardType == .URL
                || controller.state.activeKeyboardType == .webSearch)
    }

    /// 页面切换键标题：letters 页显示 "123"，numbers 页显示 "#+="，symbols 页显示 "ABC"。
    /// 模拟原生 iOS 键盘的切换按钮行为。
    var pageSwitchTitle: String {
        switch controller.state.currentPage {
        case .letters: return "123"
        case .numbers: return "#+="
        case .symbols: return "😊"
        case .emoji:   return "ABC"
        }
    }

    /// 空格键标题。中文模式显示 "拼音"，英文模式显示 "English"。
    /// 非字母页（数字/符号）显示 "space"，因为此时空格键功能简化。
    ///
    /// 模仿原生 iOS 键盘：中文键盘空格键上显示 "拼音" 以表示当前输入语言。
    var spaceButtonTitle: String {
        let state = controller.state
        if state.currentPage != .letters { return "space" }
        switch state.inputMode {
        case .chinese: return "拼音"
        case .english: return "English"
        }
    }

    /// 回车键标题，根据宿主 App 的 returnKeyType 动态变化。
    ///
    /// Apple 文档：使用 textDocumentProxy.returnKeyType 来匹配宿主 App 的期望。
    /// 原生 iOS 支持的类型和我们映射的标题：
    ///   .go → "go", .google → "google", .join → "join",
    ///   .next → "next", .route → "route", .search → "search",
    ///   .send → "send", .yahoo → "yahoo", .done → "done",
    ///   .emergencyCall → "SOS", .continue → "continue",
    ///   其他 → "return"
    var returnKeyTitle: String {
        switch textDocumentProxy.returnKeyType {
        case .go:             return "go"
        case .google:         return "google"
        case .join:           return "join"
        case .next:           return "next"
        case .route:          return "route"
        case .search:         return "search"
        case .send:           return "send"
        case .yahoo:          return "yahoo"
        case .done:           return "done"
        case .emergencyCall:  return "SOS"
        case .continue:       return "continue"
        default:              return "return"
        }
    }

    /// 当前 Shift 是否处于激活状态（singleUse 或 capsLock）。
    /// 用于决定字母键显示大写还是小写。
    var isShiftActive: Bool {
        let shift = controller.state.shiftState
        return shift == .singleUse || shift == .capsLock
    }

    /// Shift 键图标：Caps Lock 时显示 "⇪"（带锁），其他情况显示 "⇧"。
    var shiftButtonTitle: String {
        controller.state.shiftState == .capsLock ? "⇪" : "⇧"
    }
}

// MARK: === 按钮状态刷新 ===

extension KeyboardViewController {

    /// 刷新所有字母键的标题（响应 Shift 状态变化）。
    ///
    /// 遍历 letterButtons 数组，对每个按钮：
    ///   1. 从 accessibilityIdentifier 读取原始键值（小写，如 "a"）
    ///   2. 根据 isShiftActive 决定显示大写或小写
    ///   3. 调用 setTitle 更新显示
    ///
    /// 为什么用 accessibilityIdentifier 而非 button.title：
    ///   accessibilityIdentifier 始终保存原始小写形式，不受 Shift 状态影响，
    ///   确保我们始终能读取到正确的原始键值。
    func refreshLetterButtons() {
        for button in letterButtons {
            guard let key = button.accessibilityIdentifier else { continue }
            button.setTitle(displayTitle(for: key), for: .normal)
        }
        updateShiftButtonAppearance()
    }

    /// 更新 Shift 键的外观。
    ///
    /// 三种 Shift 状态对应的视觉效果：
    ///   - .off（关闭）：functionKeyColor 背景（灰色功能键风格）
    ///   - .singleUse（一次性大写）：characterKeyColor 背景（白色字符键风格）
    ///     表示"下一个按键将是大写"。
    ///   - .capsLock（大写锁定）：active 风格，深色背景 + 白色文字。
    ///     模仿原生 iOS 键盘 — Caps Lock 激活时 Shift 键显示白色填充箭头。
    func updateShiftButtonAppearance() {
        guard let shiftButton else { return }
        shiftButton.setTitle(shiftButtonTitle, for: .normal)

        switch controller.state.shiftState {
        case .off:
            applyKeyStyle(.function, to: shiftButton)
        case .singleUse:
            // 普通按键外观 — 暗示"一次性使用后恢复"
            shiftButton.backgroundColor = characterKeyColor
            shiftButton.setTitleColor(.label, for: .normal)
            shiftButton.tintColor = .label
        case .capsLock:
            // 激活外观 — 深色背景白字
            applyKeyStyle(.active, to: shiftButton)
        }
    }

    /// 更新回车键的外观。
    ///
    /// 根据 Apple 文档的建议，匹配原生 iOS 键盘行为：
    ///   - 动作键（send/search/go/join/route/yahoo/google）：
    ///     有文本时 → 黑白反转背景（暗示"可以执行"）
    ///     无文本时 → functionKeyColor 背景（灰色，暗示"需要先输入"）
    ///   - 非动作键（return/next/done/emergencyCall/continue）：
    ///     始终使用 functionKeyColor 背景
    ///
    /// 调用时机：
    ///   - textDidChange：宿主 App 文本变化后
    ///   - reloadKeyboard：页面切换重建键盘后
    ///   - syncUI：每次通过 handle() 触发状态同步时
    func updateReturnKeyAppearance() {
        guard let returnButton else { return }

        // Visual: system-style return glyph (not host action text like "send").
        // Semantic action remains insertReturn; VoiceOver uses returnKeyType labels.
        applyFunctionKeySymbol("return", to: returnButton)
        returnButton.accessibilityLabel = returnKeyAccessibilityLabel(for: returnKeyTitle)
        returnButton.accessibilityHint = "执行\(returnKeyAccessibilityLabel(for: returnKeyTitle))。"

        let rt = textDocumentProxy.returnKeyType

        // 判断是否是"动作"类型的回车键（有强调高亮行为）
        let isActionKey: Bool = {
            switch rt {
            case .send, .search, .go, .join, .route, .yahoo, .google:
                return true
            default:
                return false
            }
        }()

        if isActionKey {
            // textDocumentProxy.hasText 检查宿主 App 输入框中是否有文本
            let hasText = textDocumentProxy.hasText
            if hasText {
                // 有文本时使用动态反转色：浅色模式黑底、深色模式白底。
                returnButton.backgroundColor = .label
                returnButton.setTitleColor(.systemBackground, for: .normal)
                returnButton.tintColor = .systemBackground
            } else {
                // 无文本时的灰色状态
                applyKeyStyle(.returnKey, to: returnButton)
                returnButton.tintColor = .label
            }
        } else {
            applyKeyStyle(.returnKey, to: returnButton)
            returnButton.tintColor = .label
        }
    }
}
