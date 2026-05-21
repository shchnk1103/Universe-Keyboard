//
//  KeyboardViewController+Layout.swift
//  Keyboard
//
//  键盘行布局：字母行、文本行、第三行、底部功能行。
//

import UIKit
import KeyboardCore

extension KeyboardViewController {

    func makeLetterRow(_ keys: [String], horizontalInset: CGFloat = 0) -> UIStackView {
        let row = UIStackView()
        row.axis = .horizontal
        row.spacing = keySpacing
        row.distribution = .fillEqually
        row.isLayoutMarginsRelativeArrangement = horizontalInset > 0
        row.layoutMargins = UIEdgeInsets(top: 0, left: horizontalInset, bottom: 0, right: horizontalInset)

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
        applyKeyStyle(.function, to: shiftButton)

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

        let showEmail = shouldShowEmailShortcutKeys
        let showURL = shouldShowURLShortcutKeys

        nextKeyboardButton = makeKeyButton(title: "", action: #selector(handleInputModeList(from:with:)))
        nextKeyboardButton.setImage(UIImage(systemName: "globe"), for: .normal)
        let pageSwitchButton = makeKeyButton(title: pageSwitchTitle, action: #selector(toggleKeyboardPage))
        let spaceButton = makeKeyButton(title: spaceButtonTitle, action: #selector(insertSpace))
        returnButton = makeKeyButton(title: returnKeyTitle, action: #selector(insertReturn))

        applyKeyStyle(.function, to: nextKeyboardButton)
        applyKeyStyle(.function, to: pageSwitchButton)
        applyKeyStyle(.space, to: spaceButton)
        applyKeyStyle(.returnKey, to: returnButton)

        row.addArrangedSubview(nextKeyboardButton)
        row.addArrangedSubview(pageSwitchButton)

        var constraints: [NSLayoutConstraint] = [
            row.heightAnchor.constraint(equalToConstant: keyHeight),
            nextKeyboardButton.widthAnchor.constraint(equalToConstant: 48),
            pageSwitchButton.widthAnchor.constraint(equalToConstant: 58),
            returnButton.widthAnchor.constraint(equalToConstant: 78)
        ]

        if showEmail {
            let atButton = makeKeyButton(title: "@", action: #selector(insertDirectText(_:)))
            applyKeyStyle(.function, to: atButton)
            row.addArrangedSubview(atButton)
            constraints.append(atButton.widthAnchor.constraint(equalToConstant: 40))
        } else if showURL {
            let slashButton = makeKeyButton(title: "/", action: #selector(insertDirectText(_:)))
            applyKeyStyle(.function, to: slashButton)
            row.addArrangedSubview(slashButton)
            constraints.append(slashButton.widthAnchor.constraint(equalToConstant: 40))
        } else {
            let inputModeButton = makeKeyButton(title: inputModeButtonTitle, action: #selector(toggleInputMode))
            applyKeyStyle(.function, to: inputModeButton)
            row.addArrangedSubview(inputModeButton)
            constraints.append(inputModeButton.widthAnchor.constraint(equalToConstant: 48))
        }

        row.addArrangedSubview(spaceButton)

        if showEmail {
            let dotButton = makeKeyButton(title: ".", action: #selector(insertDirectText(_:)))
            applyKeyStyle(.function, to: dotButton)
            row.addArrangedSubview(dotButton)
            constraints.append(dotButton.widthAnchor.constraint(equalToConstant: 40))
        } else if showURL {
            let dotComButton = makeKeyButton(title: ".com", action: #selector(insertDirectText(_:)))
            applyKeyStyle(.function, to: dotComButton)
            row.addArrangedSubview(dotComButton)
            constraints.append(dotComButton.widthAnchor.constraint(equalToConstant: 60))
        }

        if includeDelete {
            let deleteButton = makeDeleteButton()
            row.addArrangedSubview(deleteButton)
            constraints.append(deleteButton.widthAnchor.constraint(equalToConstant: 58))
        }

        row.addArrangedSubview(returnButton)

        NSLayoutConstraint.activate(constraints)

        return row
    }
}
