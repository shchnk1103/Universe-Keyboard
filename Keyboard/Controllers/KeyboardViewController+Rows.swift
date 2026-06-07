import KeyboardCore
import UIKit

extension KeyboardViewController {
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
