//
//  KeyboardViewController+KeyFactory.swift
//  Keyboard
//
//  按键按钮创建工厂方法。
//

import UIKit

extension KeyboardViewController {

    func makeKeyButton(title: String, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .medium)
        // 原生键盘的按键是白色/浅色背景，与较暗的键盘底板形成层次对比
        button.backgroundColor = UIColor.systemBackground
        // iOS 26 风格的更大圆角，让按键看起来更柔和
        button.layer.cornerRadius = keyCornerRadius
        // 微妙的阴影增加按键的"浮起"感，接近原生键盘的层次效果
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.08
        button.layer.shadowRadius = 2
        button.layer.shadowOffset = CGSize(width: 0, height: 1)
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

        return button
    }

    func displayTitle(for key: String) -> String {
        isShiftActive ? key.uppercased() : key.lowercased()
    }
}
