import KeyboardCore
import UIKit

extension KeyboardViewController {
    // MARK: === 底部功能行 ===

    /// Builds the keyboard's bottom row: globe, page switch, input-mode or shortcut keys,
    /// space, optional delete, and return.
    ///
    /// The exact set of keys changes with the host text field type. Email fields get `@` and `.`;
    /// URL fields get `/` and `.com`; normal text fields get the Chinese/English input-mode toggle.
    ///
    /// The space key is intentionally configured in this file with two behaviors:
    /// tapping inserts a space, while horizontal panning is handled by
    /// `handleSpaceCursorPan(_:)` to move the host text cursor.
    func makeBottomRow(pageSwitchTitle: String, includeDelete: Bool) -> UIStackView {
        let row = UIStackView()
        row.axis = .horizontal
        row.spacing = keyHorizontalSpacing
        row.distribution = .fill

        // These flags are derived from the current UIKeyboardType and decide whether the bottom row
        // should expose text-field-specific shortcut keys.
        let showEmail = shouldShowEmailShortcutKeys
        let showURL = shouldShowURLShortcutKeys

        // System-required input-mode switch key. iOS expects third-party keyboards to provide a way
        // to move to the next keyboard, so this uses `handleInputModeList(from:with:)` directly.
        nextKeyboardButton = makeKeyButton(
            title: "",
            action: #selector(handleInputModeList(from:with:))
        )
        nextKeyboardButton.setImage(UIImage(systemName: "globe"), for: .normal)
        nextKeyboardButton.setPreferredSymbolConfiguration(
            UIImage.SymbolConfiguration(pointSize: functionKeySymbolPointSize, weight: .regular),
            forImageIn: .normal
        )

        let pageSwitchButton = makeKeyButton(
            title: pageSwitchTitle,
            action: #selector(toggleKeyboardPage(_:))
        )
        if pageSwitchTitle == "😊" {
            configureEmojiSwitchButton(pageSwitchButton)
        }
        let spaceButton = makeKeyButton(
            title: spaceButtonTitle,
            action: #selector(insertSpace(_:))
        )
        returnButton = makeKeyButton(
            title: returnKeyTitle,
            action: #selector(insertReturn(_:))
        )

        applyKeyStyle(.function, to: nextKeyboardButton)
        applyKeyStyle(.function, to: pageSwitchButton)
        applyKeyStyle(.space, to: spaceButton)
        applyKeyStyle(.returnKey, to: returnButton)

        row.addArrangedSubview(nextKeyboardButton)
        row.addArrangedSubview(pageSwitchButton)

        // Fixed widths keep the utility keys stable while the space key absorbs remaining room.
        var constraints: [NSLayoutConstraint] = [
            preferredRowHeightConstraint(for: row, height: keyHeight),
            nextKeyboardButton.widthAnchor.constraint(equalToConstant: primaryFunctionKeyWidth),
            pageSwitchButton.widthAnchor.constraint(equalToConstant: primaryFunctionKeyWidth),
            returnButton.widthAnchor.constraint(equalToConstant: 78),
        ]

        // Leading-side shortcut slot, immediately before the space key.
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
                action: #selector(toggleInputMode(_:))
            )
            applyKeyStyle(.function, to: inputModeButton)
            row.addArrangedSubview(inputModeButton)
            constraints.append(inputModeButton.widthAnchor.constraint(equalToConstant: primaryFunctionKeyWidth))
        }

        // Add the trackpad-like cursor gesture to the space key. The tap action belongs to the
        // button itself, while the long-press gesture enters cursor movement mode.
        // UILongPressGestureRecognizer defaults to cancelsTouchesInView = true, which correctly
        // prevents the underlying touchUpInside (space insertion) once the long press is recognized.
        let spaceLongPress = UILongPressGestureRecognizer(target: self, action: #selector(handleSpaceCursorLongPress(_:)))
        spaceButton.addGestureRecognizer(spaceLongPress)
        row.addArrangedSubview(spaceButton)

        // Trailing-side shortcut slot, immediately after the space key.
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
            constraints.append(deleteButton.widthAnchor.constraint(equalToConstant: primaryFunctionKeyWidth))
        }

        row.addArrangedSubview(returnButton)
        NSLayoutConstraint.activate(constraints)
        return row
    }

    /// 数字/二级符号页底部功能行。
    ///
    /// 系统会在键盘外侧提供地球键和语音入口，这里只保留页内常用功能：
    /// 回到当前语言字母页、进入表情页、空格、动态 Return。
    func makeSymbolicBottomRow(languageTitle: String) -> UIStackView {
        let row = UIStackView()
        row.axis = .horizontal
        row.spacing = keyHorizontalSpacing
        row.distribution = .fill

        let languageButton = makeKeyButton(
            title: languageTitle,
            action: #selector(switchToLettersPage(_:))
        )
        let emojiButton = makeKeyButton(
            title: "😊",
            action: #selector(switchToEmojiPage(_:))
        )
        configureEmojiSwitchButton(emojiButton)
        let spaceButton = makeKeyButton(
            title: "space",
            action: #selector(insertSpace(_:))
        )
        returnButton = makeKeyButton(
            title: returnKeyTitle,
            action: #selector(insertReturn(_:))
        )

        applyKeyStyle(.function, to: languageButton)
        applyKeyStyle(.function, to: emojiButton)
        applyKeyStyle(.space, to: spaceButton)
        applyKeyStyle(.returnKey, to: returnButton)
        languageButton.titleLabel?.adjustsFontSizeToFitWidth = true
        languageButton.titleLabel?.minimumScaleFactor = 0.65

        let spaceLongPress = UILongPressGestureRecognizer(target: self, action: #selector(handleSpaceCursorLongPress(_:)))
        spaceButton.addGestureRecognizer(spaceLongPress)

        row.addArrangedSubview(languageButton)
        row.addArrangedSubview(emojiButton)
        row.addArrangedSubview(spaceButton)
        row.addArrangedSubview(returnButton)

        NSLayoutConstraint.activate([
            preferredRowHeightConstraint(for: row, height: keyHeight),
            languageButton.widthAnchor.constraint(equalToConstant: primaryFunctionKeyWidth),
            emojiButton.widthAnchor.constraint(equalToConstant: primaryFunctionKeyWidth),
            returnButton.widthAnchor.constraint(equalToConstant: 78),
        ])

        return row
    }

    /// 使用模板 SF Symbol 代替彩色 emoji 字形，使表情切换键跟随功能键文字颜色。
    func configureEmojiSwitchButton(_ button: UIButton) {
        let image = UIImage(systemName: "face.smiling")?.withRenderingMode(.alwaysTemplate)
        button.setTitle(nil, for: .normal)
        button.setImage(image, for: .normal)
        button.setPreferredSymbolConfiguration(
            UIImage.SymbolConfiguration(pointSize: functionKeySymbolPointSize, weight: .regular),
            forImageIn: .normal
        )
        button.accessibilityLabel = "表情键盘"
        button.accessibilityHint = "切换到表情键盘。"
    }
}
