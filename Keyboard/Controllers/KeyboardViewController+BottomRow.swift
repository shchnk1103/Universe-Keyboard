import KeyboardCore
import UIKit

extension KeyboardViewController {
    // MARK: === 底部功能行 ===

    func makeBottomRow(pageSwitchTitle: String, includeDelete: Bool) -> UIStackView {
        let row = UIStackView()
        row.axis = .horizontal
        row.spacing = keyHorizontalSpacing
        row.distribution = .fill

        let showEmail = shouldShowEmailShortcutKeys
        let showURL = shouldShowURLShortcutKeys

        nextKeyboardButton = makeKeyButton(
            title: "",
            action: #selector(handleInputModeList(from:with:))
        )
        nextKeyboardButton.setImage(UIImage(systemName: "globe"), for: .normal)

        let pageSwitchButton = makeKeyButton(
            title: pageSwitchTitle,
            action: #selector(toggleKeyboardPage)
        )
        let spaceButton = makeKeyButton(
            title: spaceButtonTitle,
            action: #selector(insertSpace)
        )
        returnButton = makeKeyButton(
            title: returnKeyTitle,
            action: #selector(insertReturn)
        )

        applyKeyStyle(.function, to: nextKeyboardButton)
        applyKeyStyle(.function, to: pageSwitchButton)
        applyKeyStyle(.space, to: spaceButton)
        applyKeyStyle(.returnKey, to: returnButton)

        row.addArrangedSubview(nextKeyboardButton)
        row.addArrangedSubview(pageSwitchButton)

        var constraints: [NSLayoutConstraint] = [
            preferredRowHeightConstraint(for: row, height: keyHeight),
            nextKeyboardButton.widthAnchor.constraint(equalToConstant: 48),
            pageSwitchButton.widthAnchor.constraint(equalToConstant: 58),
            returnButton.widthAnchor.constraint(equalToConstant: 78),
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
            let inputModeButton = makeKeyButton(
                title: inputModeButtonTitle,
                action: #selector(toggleInputMode)
            )
            applyKeyStyle(.function, to: inputModeButton)
            row.addArrangedSubview(inputModeButton)
            constraints.append(inputModeButton.widthAnchor.constraint(equalToConstant: 48))
        }

        let spacePan = UIPanGestureRecognizer(target: self, action: #selector(handleSpaceCursorPan(_:)))
        spacePan.cancelsTouchesInView = false
        spacePan.delaysTouchesBegan = false
        spaceButton.addGestureRecognizer(spacePan)
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
