//
//  KeyboardViewController+KeyFactory.swift
//  Keyboard
//
//  按键按钮创建工厂方法。
//

import ObjectiveC
import UIKit

private var keyVisualStyleAssociationKey: UInt8 = 0

private final class KeyboardKeyButton: UIButton {
    var touchSlop: CGFloat = 10

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        guard isEnabled, !isHidden, alpha > 0.01 else {
            return false
        }
        return bounds.insetBy(dx: -touchSlop, dy: -touchSlop).contains(point)
    }
}

enum KeyVisualStyle: String {
    case character
    case function
    case space
    case returnKey
    case active
}

extension KeyboardViewController {

    func makeKeyButton(title: String, action: Selector) -> UIButton {
        let button = KeyboardKeyButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .regular)
        applyKeyStyle(.character, to: button)
        button.addTarget(self, action: action, for: .touchUpInside)
        button.addTarget(self, action: #selector(keyTouchDown(_:)), for: .touchDown)
        button.addTarget(self, action: #selector(keyTouchUp(_:)), for: [.touchUpInside, .touchUpOutside, .touchDragExit, .touchCancel])
        return button
    }

    func makeDeleteButton() -> UIButton {
        let button = makeKeyButton(title: "⌫", action: #selector(deleteKeyTouchUpInside(_:)))

        button.removeTarget(self, action: #selector(deleteKeyTouchUpInside(_:)), for: .touchUpInside)
        button.removeTarget(self, action: #selector(keyTouchDown(_:)), for: .touchDown)
        button.removeTarget(self, action: #selector(keyTouchUp(_:)), for: [.touchUpInside, .touchUpOutside, .touchDragExit, .touchCancel])

        button.addTarget(self, action: #selector(deleteKeyTouchDown(_:)), for: .touchDown)
        button.addTarget(self, action: #selector(deleteKeyTouchUpInside(_:)), for: .touchUpInside)
        button.addTarget(self, action: #selector(deleteKeyTouchUpOutside(_:)), for: [.touchUpOutside, .touchDragExit])

        applyKeyStyle(.function, to: button)
        return button
    }

    func displayTitle(for key: String) -> String {
        isShiftActive ? key.uppercased() : key.lowercased()
    }

    var keyboardBackgroundColor: UIColor {
        UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(red: 44 / 255, green: 45 / 255, blue: 48 / 255, alpha: 1)
                : UIColor(red: 207 / 255, green: 210 / 255, blue: 216 / 255, alpha: 1)
        }
    }

    var characterKeyColor: UIColor {
        UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(red: 92 / 255, green: 93 / 255, blue: 96 / 255, alpha: 1)
                : UIColor.white
        }
    }

    var functionKeyColor: UIColor {
        UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(red: 65 / 255, green: 66 / 255, blue: 70 / 255, alpha: 1)
                : UIColor(red: 174 / 255, green: 180 / 255, blue: 188 / 255, alpha: 1)
        }
    }

    var highlightedKeyColor: UIColor {
        UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(red: 116 / 255, green: 117 / 255, blue: 121 / 255, alpha: 1)
                : UIColor(red: 235 / 255, green: 236 / 255, blue: 239 / 255, alpha: 1)
        }
    }

    func applyKeyStyle(_ style: KeyVisualStyle, to button: UIButton) {
        objc_setAssociatedObject(
            button,
            &keyVisualStyleAssociationKey,
            style.rawValue,
            .OBJC_ASSOCIATION_RETAIN_NONATOMIC
        )
        button.layer.cornerRadius = keyCornerRadius
        button.layer.cornerCurve = .continuous
        button.layer.masksToBounds = false
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = style == .character || style == .space ? 0.18 : 0
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
            button.titleLabel?.font = .systemFont(ofSize: 17, weight: .regular)
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
            button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        }
    }

    func keyStyle(for button: UIButton) -> KeyVisualStyle? {
        guard let rawValue = objc_getAssociatedObject(button, &keyVisualStyleAssociationKey) as? String else {
            return nil
        }
        return KeyVisualStyle(rawValue: rawValue)
    }
}
