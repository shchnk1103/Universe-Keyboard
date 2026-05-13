//
//  KeyboardViewController+Layout.swift
//  Keyboard
//
//  键盘行布局：字母行、文本行、第三行、底部功能行。
//

import UIKit
import KeyboardCore

extension KeyboardViewController {

    func makeLetterRow(_ keys: [String]) -> UIStackView {
        let row = UIStackView()
        row.axis = .horizontal
        row.spacing = keySpacing
        row.distribution = .fillEqually

        for key in keys {
            let button = makeKeyButton(title: displayTitle(for: key), action: #selector(insertKey(_:)))
            button.accessibilityIdentifier = key
            letterButtons.append(button)

            if KeyPopupView.hasVariants(for: key) {
                let longPress = UILongPressGestureRecognizer(
                    target: self, action: #selector(handleKeyLongPress(_:)))
                longPress.minimumPressDuration = 0.3
                button.addGestureRecognizer(longPress)
            }

            row.addArrangedSubview(button)
        }

        row.heightAnchor.constraint(equalToConstant: keyHeight).isActive = true
        return row
    }

    func makeTextRow(_ keys: [String]) -> UIStackView {
        let row = UIStackView()
        row.axis = .horizontal
        row.spacing = keySpacing
        row.distribution = .fillEqually

        for key in keys {
            row.addArrangedSubview(makeKeyButton(title: key, action: #selector(insertKey(_:))))
        }

        row.heightAnchor.constraint(equalToConstant: keyHeight).isActive = true
        return row
    }

    func makeLetterThirdRow() -> UIStackView {
        let row = UIStackView()
        row.axis = .horizontal
        row.spacing = keySpacing
        row.distribution = .fill

        shiftButton = makeKeyButton(title: shiftButtonTitle, action: #selector(toggleShift))
        let letterRow = makeLetterRow(["z", "x", "c", "v", "b", "n", "m"])
        let deleteButton = makeDeleteButton()

        row.addArrangedSubview(shiftButton)
        row.addArrangedSubview(letterRow)
        row.addArrangedSubview(deleteButton)

        NSLayoutConstraint.activate([
            row.heightAnchor.constraint(equalToConstant: keyHeight),
            shiftButton.widthAnchor.constraint(equalToConstant: 58),
            deleteButton.widthAnchor.constraint(equalToConstant: 58)
        ])

        updateShiftButtonAppearance()
        return row
    }

    func makeBottomRow(pageSwitchTitle: String, includeDelete: Bool) -> UIStackView {
        let row = UIStackView()
        row.axis = .horizontal
        row.spacing = keySpacing
        row.distribution = .fill

        nextKeyboardButton = makeKeyButton(title: "", action: #selector(handleInputModeList(from:with:)))
        nextKeyboardButton.setImage(UIImage(systemName: "globe"), for: .normal)
        let pageSwitchButton = makeKeyButton(title: pageSwitchTitle, action: #selector(toggleKeyboardPage))
        let inputModeButton = makeKeyButton(title: inputModeButtonTitle, action: #selector(toggleInputMode))
        let atButton = makeKeyButton(title: "@", action: #selector(insertDirectText(_:)))
        let dotButton = makeKeyButton(title: ".", action: #selector(insertDirectText(_:)))
        let slashButton = makeKeyButton(title: "/", action: #selector(insertDirectText(_:)))
        let dotComButton = makeKeyButton(title: ".com", action: #selector(insertDirectText(_:)))
        let spaceButton = makeKeyButton(title: spaceButtonTitle, action: #selector(insertSpace))
        let deleteButton = makeDeleteButton()
        returnButton = makeKeyButton(title: returnKeyTitle, action: #selector(insertReturn))

        row.addArrangedSubview(nextKeyboardButton)
        row.addArrangedSubview(pageSwitchButton)

        if shouldShowEmailShortcutKeys {
            row.addArrangedSubview(atButton)
        } else if shouldShowURLShortcutKeys {
            row.addArrangedSubview(slashButton)
        } else {
            row.addArrangedSubview(inputModeButton)
        }

        row.addArrangedSubview(spaceButton)

        if shouldShowEmailShortcutKeys {
            row.addArrangedSubview(dotButton)
        } else if shouldShowURLShortcutKeys {
            row.addArrangedSubview(dotComButton)
        }

        if includeDelete {
            row.addArrangedSubview(deleteButton)
        }

        row.addArrangedSubview(returnButton)

        var constraints = [
            row.heightAnchor.constraint(equalToConstant: keyHeight),
            nextKeyboardButton.widthAnchor.constraint(equalToConstant: 48),
            pageSwitchButton.widthAnchor.constraint(equalToConstant: 58),
            returnButton.widthAnchor.constraint(equalToConstant: 78)
        ]

        if shouldShowEmailShortcutKeys {
            constraints.append(atButton.widthAnchor.constraint(equalToConstant: 40))
            constraints.append(dotButton.widthAnchor.constraint(equalToConstant: 40))
        } else if shouldShowURLShortcutKeys {
            constraints.append(slashButton.widthAnchor.constraint(equalToConstant: 40))
            constraints.append(dotComButton.widthAnchor.constraint(equalToConstant: 60))
        } else {
            constraints.append(inputModeButton.widthAnchor.constraint(equalToConstant: 48))
        }

        if includeDelete {
            constraints.append(deleteButton.widthAnchor.constraint(equalToConstant: 58))
        }

        NSLayoutConstraint.activate(constraints)

        return row
    }
}
