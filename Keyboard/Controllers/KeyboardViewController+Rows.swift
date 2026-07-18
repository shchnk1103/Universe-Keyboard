import KeyboardCore
import UIKit

extension KeyboardViewController {
    // MARK: === T9 九键（原生九宫格节奏）===

    /// Builds one equal-width five-column nine-key row (native 九宫格 rhythm).
    func makeT9GridRow(_ views: [UIView]) -> UIStackView {
        let row = UIStackView()
        row.axis = .horizontal
        row.spacing = keyHorizontalSpacing
        row.distribution = .fillEqually
        for view in views {
            row.addArrangedSubview(view)
        }
        preferredRowHeightConstraint(for: row, height: keyHeight).isActive = true
        return row
    }

    /// Full Chinese nine-key chrome as one host view.
    ///
    /// Layout (closer to system 九宫格):
    /// ```
    /// [123] [,?!] [ABC] [DEF] | [ ⌫ ]
    /// [#+=] [GHI] [JKL] [MNO] | [^_^ 颜表情]
    /// [中]  [PQRS][TUV][WXYZ] | ┌────┐
    /// [😊] [选拼音] [ 拼音 ]  | │ret │  ← return spans bottom two rows
    ///                         | └────┘
    /// ```
    /// Bottom row uses the same 4-column width rhythm as the letter pad
    /// (`emoji` and `选拼音` each one column; space spans two).
    /// RIME still receives digits 2–9 via letter-key identity (ADR 0018).
    func makeT9NineKeyChrome() -> [UIView] {
        let numbersButton = makeKeyButton(title: "123", action: #selector(switchToNumbersPage(_:)))
        applyKeyStyle(.function, to: numbersButton)

        let punctuationButton = makeKeyButton(title: ",?!", action: #selector(insertT9CommonPunctuation(_:)))
        applyKeyStyle(.character, to: punctuationButton)
        punctuationButton.titleLabel?.adjustsFontSizeToFitWidth = true
        punctuationButton.titleLabel?.minimumScaleFactor = 0.55
        punctuationButton.accessibilityLabel = "常用标点"

        let symbolsButton = makeKeyButton(title: "#+=", action: #selector(switchToSymbolsPage(_:)))
        applyKeyStyle(.function, to: symbolsButton)

        // Native-style 颜表情 entry (right middle). Product content still placeholder.
        let kaomojiButton = makeKeyButton(title: "^_^", action: #selector(showKaomojiCandidatesPlaceholder(_:)))
        applyKeyStyle(.function, to: kaomojiButton)
        kaomojiButton.titleLabel?.font = .systemFont(ofSize: functionKeyTitlePointSize, weight: .medium)
        kaomojiButton.titleLabel?.adjustsFontSizeToFitWidth = true
        kaomojiButton.titleLabel?.minimumScaleFactor = 0.55
        kaomojiButton.accessibilityLabel = "颜表情"
        kaomojiButton.accessibilityHint = "打开颜表情入口（占位）。"

        let inputModeButton = makeKeyButton(
            title: inputModeButtonTitle,
            action: #selector(toggleInputMode(_:))
        )
        applyKeyStyle(.function, to: inputModeButton)

        let deleteButton = makeDeleteButton()

        returnButton = makeKeyButton(
            title: "",
            action: #selector(insertReturn(_:))
        )
        applyKeyStyle(.returnKey, to: returnButton)
        updateReturnKeyAppearance()

        // Left main pad: 4 equal columns × 3 letter rows + bottom utility row.
        let row1 = makeT9GridRow([
            numbersButton,
            punctuationButton,
            makeT9KeyButton(digit: "2", letters: "ABC"),
            makeT9KeyButton(digit: "3", letters: "DEF"),
        ])
        let row2 = makeT9GridRow([
            symbolsButton,
            makeT9KeyButton(digit: "4", letters: "GHI"),
            makeT9KeyButton(digit: "5", letters: "JKL"),
            makeT9KeyButton(digit: "6", letters: "MNO"),
        ])
        let row3 = makeT9GridRow([
            inputModeButton,
            makeT9KeyButton(digit: "7", letters: "PQRS"),
            makeT9KeyButton(digit: "8", letters: "TUV"),
            makeT9KeyButton(digit: "9", letters: "WXYZ"),
        ])
        let bottom = makeT9BottomRow()

        let leftStack = UIStackView(arrangedSubviews: [row1, row2, row3, bottom])
        leftStack.axis = .vertical
        leftStack.spacing = keySpacing
        leftStack.distribution = .fill
        leftStack.setCustomSpacing(keyboardGroupSpacing, after: row3)

        // Right function column: delete + 颜表情 + tall return spanning row3+bottom.
        let returnHeight = keyHeight * 2 + keyboardGroupSpacing
        preferredRowHeightConstraint(for: deleteButton, height: keyHeight).isActive = true
        preferredRowHeightConstraint(for: kaomojiButton, height: keyHeight).isActive = true
        preferredRowHeightConstraint(for: returnButton, height: returnHeight).isActive = true

        let rightStack = UIStackView(arrangedSubviews: [deleteButton, kaomojiButton, returnButton])
        rightStack.axis = .vertical
        rightStack.spacing = keySpacing
        rightStack.distribution = .fill
        rightStack.setCustomSpacing(keySpacing, after: kaomojiButton)

        let host = UIStackView(arrangedSubviews: [leftStack, rightStack])
        host.axis = .horizontal
        host.spacing = keyHorizontalSpacing
        host.distribution = .fill
        host.alignment = .fill

        // One-of-five column width: right ≈ 1/4 of the left four-column pad.
        rightStack.setContentHuggingPriority(.required, for: .horizontal)
        rightStack.setContentCompressionResistancePriority(.required, for: .horizontal)
        NSLayoutConstraint.activate([
            rightStack.widthAnchor.constraint(equalTo: leftStack.widthAnchor, multiplier: 0.25),
        ])

        let totalHeight =
            keyHeight * 4
            + keySpacing * 2
            + keyboardGroupSpacing
        preferredRowHeightConstraint(for: host, height: totalHeight).isActive = true

        return [host]
    }

    /// Nine-key bottom row aligned to the left pad’s 4 equal columns:
    /// `[emoji | 选拼音 | space(span 2)]`.
    ///
    /// Globe is still created for `needsInputModeSwitchKey` (system may hide it).
    /// When visible it sits as an extra leading control without fixed 46pt chrome width.
    /// Delete/return live in the right column (return is double-height).
    func makeT9BottomRow() -> UIStackView {
        let row = UIStackView()
        row.axis = .horizontal
        row.spacing = keyHorizontalSpacing
        row.distribution = .fill
        row.alignment = .fill

        // Required by UIInputViewController when the system asks for a switch key.
        nextKeyboardButton = makeKeyButton(
            title: "",
            action: #selector(handleInputModeList(from:with:))
        )
        applyFunctionKeySymbol("globe", to: nextKeyboardButton)
        applyKeyStyle(.function, to: nextKeyboardButton)
        nextKeyboardButton.tintColor = .label
        // Keep in hierarchy for the system; stack collapses space while hidden.
        nextKeyboardButton.isHidden = !needsInputModeSwitchKey

        let emojiButton = makeKeyButton(
            title: "😊",
            action: #selector(switchToEmojiPage(_:))
        )
        configureEmojiSwitchButton(emojiButton)
        applyKeyStyle(.function, to: emojiButton)
        emojiButton.tintColor = .label

        let selectPinyinButton = makeKeyButton(
            title: "选拼音",
            action: #selector(t9SelectPinyin(_:))
        )
        applyKeyStyle(.function, to: selectPinyinButton)
        selectPinyinButton.titleLabel?.adjustsFontSizeToFitWidth = true
        selectPinyinButton.titleLabel?.minimumScaleFactor = 0.45
        selectPinyinButton.accessibilityLabel = "选拼音"
        selectPinyinButton.accessibilityHint = "打开完整拼音路径列表"
        t9SelectPinyinButton = selectPinyinButton
        updateSelectPinyinButtonAvailability()

        let spaceButton = makeKeyButton(
            title: spaceButtonTitle,
            action: #selector(insertSpace(_:))
        )
        applyKeyStyle(.space, to: spaceButton)
        let spaceLongPress = UILongPressGestureRecognizer(
            target: self,
            action: #selector(handleSpaceCursorLongPress(_:))
        )
        spaceButton.addGestureRecognizer(spaceLongPress)

        row.addArrangedSubview(nextKeyboardButton)
        row.addArrangedSubview(emojiButton)
        row.addArrangedSubview(selectPinyinButton)
        row.addArrangedSubview(spaceButton)

        // Match left pad columns: emoji = 选拼音 = 1 col; space = 2 cols + inner gap.
        // (4w + 3s = full width of the left pad when globe is hidden.)
        emojiButton.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        selectPinyinButton.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        spaceButton.setContentHuggingPriority(.defaultLow, for: .horizontal)
        emojiButton.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        selectPinyinButton.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        spaceButton.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        NSLayoutConstraint.activate([
            preferredRowHeightConstraint(for: row, height: keyHeight),
            emojiButton.widthAnchor.constraint(equalTo: selectPinyinButton.widthAnchor),
            spaceButton.widthAnchor.constraint(
                equalTo: emojiButton.widthAnchor,
                multiplier: 2,
                constant: keyHorizontalSpacing
            ),
            // When globe is visible, keep it one column wide like emoji.
            nextKeyboardButton.widthAnchor.constraint(equalTo: emojiButton.widthAnchor),
        ])
        return row
    }

    // MARK: === 字母行 ===

    /// 构建一排字母键按钮。
    /// - Parameters:
    ///   - keys: 按键标题数组（小写形式，displayTitle(for:) 会根据 Shift 状态转换）
    ///   - horizontalInset: 水平内缩距离（第二行使用 18pt 模拟原生键盘的错位布局）
    /// - Returns: 包含字母键的水平 UIStackView
    func makeLetterRow(_ keys: [String], horizontalInset: CGFloat = 0) -> UIStackView {
        let row = UIStackView()
        row.axis = .horizontal
        row.spacing = keyHorizontalSpacing
        row.distribution = .fillEqually
        row.isLayoutMarginsRelativeArrangement = horizontalInset > 0
        row.layoutMargins = UIEdgeInsets(top: 0, left: horizontalInset, bottom: 0, right: horizontalInset)

        for key in keys {
            let button = makeKeyButton(
                title: displayTitle(for: key),
                action: #selector(insertKey(_:))
            )
            button.accessibilityIdentifier = key
            letterButtons.append(button)

            if KeyPopupView.hasVariants(for: key) {
                let longPress = UILongPressGestureRecognizer(
                    target: self,
                    action: #selector(handleKeyLongPress(_:))
                )
                longPress.minimumPressDuration = 0.3
                button.addGestureRecognizer(longPress)
            }

            row.addArrangedSubview(button)
        }

        preferredRowHeightConstraint(for: row, height: keyHeight).isActive = true
        return row
    }

    // MARK: === 文本行（数字/符号）===

    func makeTextRow(_ keys: [String], actionOverrides: [String: Selector] = [:]) -> UIStackView {
        let row = UIStackView()
        row.axis = .horizontal
        row.spacing = keyHorizontalSpacing
        row.distribution = .fillEqually

        for key in keys {
            let action = actionOverrides[key] ?? #selector(insertKey(_:))
            row.addArrangedSubview(
                makeKeyButton(title: key, action: action)
            )
        }

        preferredRowHeightConstraint(for: row, height: keyHeight).isActive = true
        return row
    }

    /// 中文数字页第三行：左侧进入符号页，右侧删除，中间保留常用中文标点。
    ///
    /// 结构对应字母页第三行的功能键 + 字符区 + 删除键，而不是普通等宽文本行。
    func makeChineseNumbersThirdRow() -> UIStackView {
        let row = UIStackView()
        row.axis = .horizontal
        row.spacing = thirdRowFunctionSpacing
        row.distribution = .fill

        let symbolPageButton = makeKeyButton(
            title: "#+=",
            action: #selector(toggleKeyboardPage(_:))
        )
        let punctuationRow = makeTextRow(["。", "，", "、", "？", "！", "."])
        let deleteButton = makeDeleteButton()

        applyKeyStyle(.function, to: symbolPageButton)

        row.addArrangedSubview(symbolPageButton)
        row.addArrangedSubview(punctuationRow)
        row.addArrangedSubview(deleteButton)

        NSLayoutConstraint.activate([
            preferredRowHeightConstraint(for: row, height: keyHeight),
            symbolPageButton.widthAnchor.constraint(equalToConstant: primaryFunctionKeyWidth),
            deleteButton.widthAnchor.constraint(equalToConstant: primaryFunctionKeyWidth),
        ])

        return row
    }

    /// 英文数字页第三行：左侧进入二级符号页，右侧删除，中间是英文常用标点。
    func makeEnglishNumbersThirdRow() -> UIStackView {
        makeFunctionWrappedTextRow(
            leadingTitle: "#+=",
            leadingAction: #selector(toggleKeyboardPage(_:)),
            textKeys: [".", ",", "?", "!", "’"]
        )
    }

    /// 英文二级符号页第三行：左侧回到 123 页，右侧删除，中间复用英文常用标点。
    func makeEnglishSymbolsThirdRow() -> UIStackView {
        makeFunctionWrappedTextRow(
            leadingTitle: "123",
            leadingAction: #selector(switchToNumbersPage(_:)),
            textKeys: [".", ",", "?", "!", "’"]
        )
    }

    /// 构建「左功能键 + 等宽字符区 + 删除键」的第三行。
    private func makeFunctionWrappedTextRow(
        leadingTitle: String,
        leadingAction: Selector,
        textKeys: [String]
    ) -> UIStackView {
        let row = UIStackView()
        row.axis = .horizontal
        row.spacing = thirdRowFunctionSpacing
        row.distribution = .fill

        let leadingButton = makeKeyButton(
            title: leadingTitle,
            action: leadingAction
        )
        let textRow = makeTextRow(textKeys)
        let deleteButton = makeDeleteButton()

        applyKeyStyle(.function, to: leadingButton)

        row.addArrangedSubview(leadingButton)
        row.addArrangedSubview(textRow)
        row.addArrangedSubview(deleteButton)

        NSLayoutConstraint.activate([
            preferredRowHeightConstraint(for: row, height: keyHeight),
            leadingButton.widthAnchor.constraint(equalToConstant: primaryFunctionKeyWidth),
            deleteButton.widthAnchor.constraint(equalToConstant: primaryFunctionKeyWidth),
        ])

        return row
    }

    /// 中文二级符号页第三行：左侧回到 123 页，右侧删除，中间是常用标点。
    func makeChineseSymbolsThirdRow() -> UIStackView {
        let row = UIStackView()
        row.axis = .horizontal
        row.spacing = thirdRowFunctionSpacing
        row.distribution = .fill

        let numbersPageButton = makeKeyButton(
            title: "123",
            action: #selector(switchToNumbersPage(_:))
        )
        let punctuationRow = makeChineseSymbolsPunctuationRow()
        let deleteButton = makeDeleteButton()

        applyKeyStyle(.function, to: numbersPageButton)

        row.addArrangedSubview(numbersPageButton)
        row.addArrangedSubview(punctuationRow)
        row.addArrangedSubview(deleteButton)

        NSLayoutConstraint.activate([
            preferredRowHeightConstraint(for: row, height: keyHeight),
            numbersPageButton.widthAnchor.constraint(equalToConstant: primaryFunctionKeyWidth),
            deleteButton.widthAnchor.constraint(equalToConstant: primaryFunctionKeyWidth),
        ])

        return row
    }

    /// 中文二级符号页中间字符区。
    ///
    /// `^_^` 是未来颜表情候选入口；当前只展示入口，不提交文本或展开候选。
    private func makeChineseSymbolsPunctuationRow() -> UIStackView {
        let row = UIStackView()
        row.axis = .horizontal
        row.spacing = keyHorizontalSpacing
        row.distribution = .fillEqually

        for key in ["…", "，", "^_^", "？", "！", "‘"] {
            let action: Selector = key == "^_^"
                ? #selector(showKaomojiCandidatesPlaceholder(_:))
                : #selector(insertKey(_:))
            row.addArrangedSubview(makeKeyButton(title: key, action: action))
        }

        preferredRowHeightConstraint(for: row, height: keyHeight).isActive = true
        return row
    }

    // MARK: === 第三行（Shift + 字母 + 删除）===

    func makeLetterThirdRow() -> UIStackView {
        let row = UIStackView()
        row.axis = .horizontal
        row.spacing = thirdRowFunctionSpacing
        row.distribution = .fill

        shiftButton = makeKeyButton(title: shiftButtonTitle, action: #selector(toggleShift(_:)))
        let letterRow = makeLetterRow(["z", "x", "c", "v", "b", "n", "m"])
        let deleteButton = makeDeleteButton()
        applyKeyStyle(.function, to: shiftButton)

        row.addArrangedSubview(shiftButton)
        row.addArrangedSubview(letterRow)
        row.addArrangedSubview(deleteButton)

        NSLayoutConstraint.activate([
            preferredRowHeightConstraint(for: row, height: keyHeight),
            shiftButton.widthAnchor.constraint(equalToConstant: primaryFunctionKeyWidth),
            deleteButton.widthAnchor.constraint(equalToConstant: primaryFunctionKeyWidth),
        ])

        updateShiftButtonAppearance()
        return row
    }
}
