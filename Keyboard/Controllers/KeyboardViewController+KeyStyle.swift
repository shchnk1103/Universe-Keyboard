import UIKit

extension KeyboardViewController {
    var keyboardBackgroundColor: UIColor {
        UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(red: 30 / 255, green: 30 / 255, blue: 32 / 255, alpha: 1)
                : UIColor(red: 209 / 255, green: 209 / 255, blue: 214 / 255, alpha: 1)
        }
    }

    var characterKeyColor: UIColor {
        UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(red: 62 / 255, green: 62 / 255, blue: 64 / 255, alpha: 1)
                : .white
        }
    }

    var functionKeyColor: UIColor {
        UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(red: 44 / 255, green: 44 / 255, blue: 46 / 255, alpha: 1)
                : UIColor(red: 174 / 255, green: 174 / 255, blue: 178 / 255, alpha: 1)
        }
    }

    var highlightedKeyColor: UIColor {
        UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(red: 92 / 255, green: 92 / 255, blue: 96 / 255, alpha: 1)
                : UIColor(red: 235 / 255, green: 235 / 255, blue: 237 / 255, alpha: 1)
        }
    }

    /// Records style on keyboard-owned buttons so touch feedback can restore it safely under Swift 6.
    func applyKeyStyle(_ style: KeyVisualStyle, to button: UIButton) {
        (button as? KeyboardKeyButton)?.visualStyle = style

        button.layer.cornerRadius = keyCornerRadius
        button.layer.cornerCurve = .continuous
        button.layer.masksToBounds = false
        button.layer.borderWidth = 0.33
        button.layer.borderColor = UIColor.separator.withAlphaComponent(0.3).cgColor
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = (style == .character || style == .space) ? 0.18 : 0
        button.layer.shadowRadius = 0
        button.layer.shadowOffset = CGSize(width: 0, height: 1)
        button.setTitleColor(.label, for: .normal)
        button.tintColor = .label

        switch style {
        case .character:
            button.backgroundColor = characterKeyColor
            button.titleLabel?.font = .systemFont(ofSize: 20, weight: .regular)
        case .function:
            button.backgroundColor = functionKeyColor
            button.titleLabel?.font = .systemFont(ofSize: functionKeySymbolPointSize, weight: .regular)
        case .space:
            button.backgroundColor = characterKeyColor
            button.titleLabel?.font = .systemFont(ofSize: 15, weight: .regular)
        case .returnKey:
            button.backgroundColor = functionKeyColor
            button.titleLabel?.font = .systemFont(ofSize: 16, weight: .regular)
        case .active:
            button.backgroundColor = .label
            button.setTitleColor(.systemBackground, for: .normal)
            button.tintColor = .systemBackground
            button.titleLabel?.font = .systemFont(ofSize: functionKeySymbolPointSize, weight: .semibold)
        }
    }

    func keyStyle(for button: UIButton) -> KeyVisualStyle? {
        (button as? KeyboardKeyButton)?.visualStyle
    }

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
