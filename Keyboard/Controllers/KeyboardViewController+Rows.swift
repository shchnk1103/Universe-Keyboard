import KeyboardCore
import UIKit

/// Nine-key pad plus the semantic rows used by touch geometry.
///
/// The layout factory already knows which keys form each row and column. Keep
/// that knowledge here instead of asking the hit tester to reverse-engineer a
/// nested `UIStackView` tree from transient frames.
final class T9NineKeyChromeHost: UIStackView {
    struct TouchColumn {
        let container: UIStackView
        let rows: [[KeyboardKeyButton]]
    }

    private(set) var touchColumns: [TouchColumn] = []

    func configureTouchColumns(_ columns: [TouchColumn]) {
        touchColumns = columns
    }
}

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
        preferredRowHeightConstraint(for: row).isActive = true
        return row
    }

    /// Full Chinese nine-key chrome as one host view.
    ///
    /// Layout (closer to system 九宫格):
    /// ```
    /// [123] [，。？！] [ABC] [DEF] | [ ⌫ ]
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

        let punctuationButton = makeKeyButton(
            title: T9CommonPunctuationChrome.keyTitle, action: #selector(insertT9CommonPunctuation(_:)))
        applyKeyStyle(.character, to: punctuationButton)
        punctuationButton.titleLabel?.adjustsFontSizeToFitWidth = true
        punctuationButton.titleLabel?.minimumScaleFactor = 0.55
        punctuationButton.accessibilityLabel = T9CommonPunctuationChrome.accessibilityLabel

        let symbolsButton = makeKeyButton(title: "#+=", action: #selector(switchToSymbolsPage(_:)))
        applyKeyStyle(.function, to: symbolsButton)

        let kaomojiButton = makeKeyButton(
            title: KaomojiChrome.keyTitle, action: #selector(insertKaomoji(_:)))
        applyKeyStyle(.function, to: kaomojiButton)
        kaomojiButton.titleLabel?.font = .systemFont(ofSize: functionKeyTitlePointSize, weight: .medium)
        kaomojiButton.titleLabel?.adjustsFontSizeToFitWidth = true
        kaomojiButton.titleLabel?.minimumScaleFactor = 0.55
        kaomojiButton.accessibilityLabel = KaomojiChrome.accessibilityLabel
        kaomojiButton.accessibilityHint = KaomojiChrome.accessibilityHint

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
        preferredRowHeightConstraint(for: deleteButton).isActive = true
        preferredRowHeightConstraint(for: kaomojiButton).isActive = true
        preferredRowHeightConstraint(for: returnButton, rows: 2, extraHeight: keyboardGroupSpacing).isActive = true

        let rightStack = UIStackView(arrangedSubviews: [deleteButton, kaomojiButton, returnButton])
        rightStack.axis = .vertical
        rightStack.spacing = keySpacing
        rightStack.distribution = .fill
        rightStack.setCustomSpacing(keySpacing, after: kaomojiButton)

        let host = T9NineKeyChromeHost(arrangedSubviews: [leftStack, rightStack])
        host.axis = .horizontal
        host.spacing = keyHorizontalSpacing
        host.distribution = .fill
        host.alignment = .fill

        // One-of-five column width: right ≈ 1/4 of the left four-column pad.
        rightStack.setContentHuggingPriority(.required, for: .horizontal)
        rightStack.setContentCompressionResistancePriority(.required, for: .horizontal)
        NSLayoutConstraint.activate([
            rightStack.widthAnchor.constraint(equalTo: leftStack.widthAnchor, multiplier: 0.25)
        ])
        host.configureTouchColumns([
            .init(
                container: leftStack,
                rows: [row1, row2, row3, bottom].map { row in
                    row.arrangedSubviews.compactMap { $0 as? KeyboardKeyButton }
                }
            ),
            .init(
                container: rightStack,
                rows: [[deleteButton], [kaomojiButton], [returnButton]].compactMap { row in
                    let keys = row.compactMap { $0 as? KeyboardKeyButton }
                    return keys.isEmpty ? nil : keys
                }
            ),
        ])

        preferredRowHeightConstraint(
            for: host, rows: 4, extraHeight: keySpacing * 2 + keyboardGroupSpacing
        ).isActive = true

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
        // The live state refresh supplies first/next wording and current value.
        selectPinyinButton.accessibilityHint = "选择拼音"
        t9SelectPinyinButton = selectPinyinButton
        updateSelectPinyinButtonAvailability()

        let spaceButton = makeKeyButton(
            title: spaceButtonTitle,
            action: #selector(insertSpace(_:))
        )
        t9SpaceButton = spaceButton
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
            preferredRowHeightConstraint(for: row),
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

    /// Chinese nine-key numbers page. Five equal columns: left 1 + middle 3 + right 1.
    /// Right column width is one quarter of the left zone, matching the letter pad.
    /// Rows are equal height and use only `keySpacing` (no `keyboardGroupSpacing`).
    func makeT9NumbersChrome() -> [UIView] {
        func padButton(_ key: T9NumberPadLayout.Key) -> KeyboardKeyButton {
            if case .delete = key.tap {
                guard let button = makeDeleteButton() as? KeyboardKeyButton else {
                    preconditionFailure("delete button must be a KeyboardKeyButton")
                }
                return button
            }
            let selector: Selector
            var identifier: String?
            let title: String
            switch key.tap {
            case .literal(let text):
                selector = #selector(insertT9NumberPadLiteral(_:))
                identifier = text
                title = text == " " ? spaceButtonTitle : key.title
            case .symbolsPage:
                selector = #selector(switchToSymbolsPage(_:))
                title = key.title
            case .lettersPage:
                selector = #selector(switchToLettersPage(_:))
                title = key.title
            case .delete:
                selector = #selector(deleteKeyTouchUpInside(_:forEvent:))
                title = ""
            case .insertReturn:
                selector = #selector(insertReturn(_:))
                title = ""
            }
            guard let button = makeKeyButton(title: title, action: selector) as? KeyboardKeyButton else {
                preconditionFailure("key button must be a KeyboardKeyButton")
            }
            if let identifier {
                button.accessibilityIdentifier = identifier
            }
            switch key.tap {
            case .literal(" "):
                applyKeyStyle(.space, to: button)
                if key.installsSpaceCursorLongPress {
                    let press = UILongPressGestureRecognizer(
                        target: self, action: #selector(handleSpaceCursorLongPress(_:)))
                    button.addGestureRecognizer(press)
                }
            case .insertReturn:
                applyKeyStyle(.returnKey, to: button)
                returnButton = button
                updateReturnKeyAppearance()
                preferredRowHeightConstraint(for: button, rows: 2, extraHeight: keySpacing).isActive = true
            case .symbolsPage, .lettersPage, .literal("@"), .literal("+"), .literal("-"):
                applyKeyStyle(.function, to: button)
            default:
                break
            }
            return button
        }

        let leftKeys = T9NumberPadLayout.columns[0].map { row -> [KeyboardKeyButton] in
            let buttons = row.map { padButton($0) }
            for button in buttons where button !== returnButton {
                preferredRowHeightConstraint(for: button).isActive = true
            }
            return buttons
        }
        let leftStack = UIStackView(arrangedSubviews: leftKeys.map { $0[0] })
        leftStack.axis = .vertical
        leftStack.spacing = keySpacing
        leftStack.distribution = .fill

        var middleRows: [[KeyboardKeyButton]] = []
        let midStack = UIStackView()
        midStack.axis = .vertical
        midStack.spacing = keySpacing
        midStack.distribution = .fill
        for rowKeys in T9NumberPadLayout.columns[1] {
            let buttons = rowKeys.map { padButton($0) }
            let row = UIStackView(arrangedSubviews: buttons)
            row.axis = .horizontal
            row.spacing = keyHorizontalSpacing
            row.distribution = .fillEqually
            preferredRowHeightConstraint(for: row).isActive = true
            midStack.addArrangedSubview(row)
            middleRows.append(buttons)
        }

        let rightKeys = T9NumberPadLayout.columns[2].map { row -> [KeyboardKeyButton] in
            row.map { padButton($0) }
        }
        for button in rightKeys.flatMap({ $0 }) where button !== returnButton {
            preferredRowHeightConstraint(for: button).isActive = true
        }
        let rightStack = UIStackView(arrangedSubviews: rightKeys.map { $0[0] })
        rightStack.axis = .vertical
        rightStack.spacing = keySpacing
        rightStack.distribution = .fill

        let leftZone = UIStackView(arrangedSubviews: [leftStack, midStack])
        leftZone.axis = .horizontal
        leftZone.spacing = keyHorizontalSpacing
        leftZone.distribution = .fill
        leftZone.alignment = .fill

        let host = T9NineKeyChromeHost(arrangedSubviews: [leftZone, rightStack])
        host.axis = .horizontal
        host.spacing = keyHorizontalSpacing
        host.distribution = .fill
        host.alignment = .fill
        rightStack.setContentHuggingPriority(.required, for: .horizontal)
        rightStack.setContentCompressionResistancePriority(.required, for: .horizontal)
        NSLayoutConstraint.activate([
            midStack.widthAnchor.constraint(equalTo: leftStack.widthAnchor, multiplier: 3),
            rightStack.widthAnchor.constraint(equalTo: leftZone.widthAnchor, multiplier: 0.25),
        ])
        host.configureTouchColumns([
            .init(container: leftStack, rows: leftKeys),
            .init(container: midStack, rows: middleRows),
            .init(container: rightStack, rows: rightKeys),
        ])
        preferredRowHeightConstraint(for: host, rows: 4, extraHeight: keySpacing * 3).isActive = true
        return [host]
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
            (button as? KeyboardKeyButton)?.isOrdinaryRolloverParticipant = true
            button.accessibilityIdentifier = key
            letterButtons.append(button)
            applyShuangpinSublegend(to: button, key: key)

            if KeyPopupView.hasVariants(for: key) {
                let longPress = UILongPressGestureRecognizer(
                    target: self,
                    action: #selector(handleKeyLongPress(_:))
                )
                longPress.minimumPressDuration = 0.3
                longPress.delegate = ordinaryLongPressDelegate
                button.addGestureRecognizer(longPress)
                if let keyButton = button as? KeyboardKeyButton {
                    keyButton.supportsOrdinaryLongPressVariants = true
                    keyButton.ordinaryLongPressTarget = self
                    keyButton.ordinaryLongPressAction = #selector(handleKeyLongPress(_:))
                    keyButton.ordinaryLongPressDelegate = ordinaryLongPressDelegate
                }
            }

            row.addArrangedSubview(button)
        }

        preferredRowHeightConstraint(for: row).isActive = true
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
            let button = makeKeyButton(title: key, action: action)
            if action == #selector(insertKey(_:)) {
                (button as? KeyboardKeyButton)?.isOrdinaryRolloverParticipant = true
            }
            row.addArrangedSubview(button)
        }

        preferredRowHeightConstraint(for: row).isActive = true
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
            preferredRowHeightConstraint(for: row),
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
            preferredRowHeightConstraint(for: row),
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
            preferredRowHeightConstraint(for: row),
            numbersPageButton.widthAnchor.constraint(equalToConstant: primaryFunctionKeyWidth),
            deleteButton.widthAnchor.constraint(equalToConstant: primaryFunctionKeyWidth),
        ])

        return row
    }

    /// 中文二级符号页中间字符区。`^_^` 与九键共用 `.pressKaomoji`。
    private func makeChineseSymbolsPunctuationRow() -> UIStackView {
        let row = UIStackView()
        row.axis = .horizontal
        row.spacing = keyHorizontalSpacing
        row.distribution = .fillEqually

        for key in ["…", "，", KaomojiChrome.keyTitle, "？", "！", "‘"] {
            let action: Selector =
                key == KaomojiChrome.keyTitle
                ? #selector(insertKaomoji(_:))
                : #selector(insertKey(_:))
            let button = makeKeyButton(title: key, action: action)
            if action == #selector(insertKey(_:)) {
                (button as? KeyboardKeyButton)?.isOrdinaryRolloverParticipant = true
            }
            row.addArrangedSubview(button)
        }

        preferredRowHeightConstraint(for: row).isActive = true
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
            preferredRowHeightConstraint(for: row),
            shiftButton.widthAnchor.constraint(equalToConstant: primaryFunctionKeyWidth),
            deleteButton.widthAnchor.constraint(equalToConstant: primaryFunctionKeyWidth),
        ])

        updateShiftButtonAppearance()
        return row
    }
}
