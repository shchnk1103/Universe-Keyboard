import KeyboardCore
import UIKit

extension KeyboardViewController {
    /// Adds semantic VoiceOver metadata without coupling accessibility text to visible key glyphs.
    func configureKeyAccessibility(_ button: UIButton, title: String, action: Selector) {
        button.accessibilityTraits = .keyboardKey
        button.accessibilityHint = nil
        button.accessibilityValue = nil

        switch action {
        case #selector(deleteKeyTouchUpInside(_:)):
            button.accessibilityLabel = "删除"
            button.accessibilityHint = "删除光标前的字符。按住可连续删除。"

        case #selector(toggleShift(_:)):
            button.accessibilityLabel = "大写"
            button.accessibilityHint = "切换单次大写或大写锁定。"
            button.accessibilityValue = shiftAccessibilityValue
            button.addTarget(
                self,
                action: #selector(refreshShiftAccessibilityValue(_:)),
                for: .touchUpInside
            )

        case #selector(handleInputModeList(from:with:)):
            button.accessibilityLabel = "切换键盘"
            button.accessibilityHint = "按住以选择其他键盘。"

        case #selector(toggleKeyboardPage(_:)):
            button.accessibilityLabel = "键盘页面"
            button.accessibilityValue = keyboardPageAccessibilityValue(for: title)
            button.accessibilityHint = "切换到\(keyboardPageAccessibilityValue(for: title))。"

        case #selector(toggleInputMode(_:)):
            button.accessibilityLabel = "输入语言"
            button.accessibilityValue = inputModeAccessibilityValue(for: title)
            button.accessibilityHint = "切换中文与英文输入。"

        case #selector(insertSpace(_:)):
            button.accessibilityLabel = "空格"
            button.accessibilityValue = spaceAccessibilityValue(for: title)
            button.accessibilityHint = "插入空格。左右滑动可移动光标。"

        case #selector(insertReturn(_:)):
            button.accessibilityLabel = returnKeyAccessibilityLabel(for: title)
            button.accessibilityHint = "执行\(returnKeyAccessibilityLabel(for: title))。"

        default:
            button.accessibilityLabel = title
        }
    }

    @objc private func refreshShiftAccessibilityValue(_ sender: UIButton) {
        sender.accessibilityValue = shiftAccessibilityValue
    }

    private var shiftAccessibilityValue: String {
        switch controller.state.shiftState {
        case .off:
            return "关闭"
        case .singleUse:
            return "单次大写"
        case .capsLock:
            return "大写锁定"
        }
    }

    private func keyboardPageAccessibilityValue(for title: String) -> String {
        switch title {
        case "123":
            return "数字键盘"
        case "#+=":
            return "符号键盘"
        case "😊":
            return "表情键盘"
        case "ABC":
            return "字母键盘"
        default:
            return title
        }
    }

    private func inputModeAccessibilityValue(for title: String) -> String {
        switch title {
        case "中":
            return "中文"
        case "英":
            return "英文"
        default:
            return title
        }
    }

    private func spaceAccessibilityValue(for title: String) -> String? {
        switch title {
        case "拼音":
            return "拼音输入"
        case "English":
            return "英文输入"
        case "选定":
            return "选定首个候选词"
        default:
            return nil
        }
    }

    func returnKeyAccessibilityLabel(for title: String) -> String {
        switch title {
        case "go":
            return "前往"
        case "google", "search":
            return "搜索"
        case "join":
            return "加入"
        case "next":
            return "下一项"
        case "route":
            return "路线"
        case "send":
            return "发送"
        case "yahoo":
            return "雅虎搜索"
        case "done":
            return "完成"
        case "SOS":
            return "紧急呼叫"
        case "continue":
            return "继续"
        default:
            return "回车"
        }
    }
}
