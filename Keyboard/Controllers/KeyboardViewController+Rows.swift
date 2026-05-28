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

    func makeTextRow(_ keys: [String]) -> UIStackView {
        let row = UIStackView()
        row.axis = .horizontal
        row.spacing = keyHorizontalSpacing
        row.distribution = .fillEqually

        for key in keys {
            row.addArrangedSubview(
                makeKeyButton(title: key, action: #selector(insertKey(_:)))
            )
        }

        preferredRowHeightConstraint(for: row, height: keyHeight).isActive = true
        return row
    }

    // MARK: === 第三行（Shift + 字母 + 删除）===

    func makeLetterThirdRow() -> UIStackView {
        let row = UIStackView()
        row.axis = .horizontal
        row.spacing = keyHorizontalSpacing
        row.distribution = .fill

        shiftButton = makeKeyButton(title: shiftButtonTitle, action: #selector(toggleShift))
        let letterRow = makeLetterRow(["z", "x", "c", "v", "b", "n", "m"])
        let deleteButton = makeDeleteButton()
        applyKeyStyle(.function, to: shiftButton)

        row.addArrangedSubview(shiftButton)
        row.addArrangedSubview(letterRow)
        row.addArrangedSubview(deleteButton)

        NSLayoutConstraint.activate([
            preferredRowHeightConstraint(for: row, height: keyHeight),
            shiftButton.widthAnchor.constraint(equalToConstant: 58),
            deleteButton.widthAnchor.constraint(equalToConstant: 58),
        ])

        updateShiftButtonAppearance()
        return row
    }
}
