import UIKit
import KeyboardCore

// MARK: === UIKeyboardType → KeyboardType 映射 ===

extension KeyboardType {

    /// 将 UIKit 的 UIKeyboardType 转换为 KeyboardCore 的内部 KeyboardType。
    ///
    /// Apple 文档要求自定义键盘根据 host app 的 keyboardType 调整布局：
    /// "To present an appropriate keyboard layout, respond to the current
    ///  text input object's UIKeyboardType property."
    ///
    /// 我们的映射策略：
    ///   - .emailAddress → .emailAddress（显示 @ 和 . 快捷键）
    ///   - .URL, .webSearch → .URL / .webSearch（显示 / 和 .com 快捷键）
    ///   - 其他所有类型 → .default（标准字母键盘布局）
    ///
    /// 注意：某些 keyboardType（如 .numberPad, .phonePad）会触发系统键盘
    /// 而非自定义键盘，所以这里将它们映射为 .default 也没问题。
    ///
    /// @unknown default：处理未来 iOS 可能新增的键盘类型。
    static func from(uiKeyboardType type: UIKeyboardType?) -> KeyboardType {
        switch type {
        case .emailAddress:          return .emailAddress
        case .URL:                   return .URL
        case .webSearch:             return .webSearch
        case .default:               return .default
        case .none:                  return .default
        case .asciiCapable:          return .default
        case .numbersAndPunctuation: return .default
        case .numberPad:             return .default
        case .phonePad:              return .default
        case .namePhonePad:          return .default
        case .decimalPad:            return .default
        case .twitter:               return .default
        case .asciiCapableNumberPad: return .default
        @unknown default:            return .other
        }
    }
}
