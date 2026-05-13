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
        button.backgroundColor = UIColor.secondarySystemBackground
        button.layer.cornerRadius = 6
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
