import UIKit

extension KeyboardViewController {
    /// 构建当前分类的离线颜表情目录。面板不保存最近使用或个人偏好。
    func makeKaomojiPanel() -> UIStackView {
        let container = UIStackView()
        container.axis = .vertical
        container.spacing = keySpacing
        container.distribution = .fill

        let categoryRow = UIStackView()
        categoryRow.axis = .horizontal
        categoryRow.spacing = keyHorizontalSpacing
        categoryRow.distribution = .fillEqually

        let backButton = makeKeyButton(title: "返回", action: #selector(dismissKaomojiPanel(_:)))
        applyKeyStyle(.function, to: backButton)
        backButton.accessibilityLabel = "返回键盘"
        backButton.accessibilityHint = "关闭颜表情目录。"
        categoryRow.addArrangedSubview(backButton)

        for (index, category) in KaomojiDataSource.categories.enumerated() {
            let button = makeKeyButton(title: category.name, action: #selector(selectKaomojiCategory(_:)))
            button.tag = index
            applyKeyStyle(index == selectedKaomojiCategoryIndex ? .space : .function, to: button)
            button.titleLabel?.font = .preferredFont(forTextStyle: .footnote)
            button.titleLabel?.adjustsFontForContentSizeCategory = true
            button.titleLabel?.adjustsFontSizeToFitWidth = true
            button.titleLabel?.minimumScaleFactor = 0.7
            button.accessibilityLabel = "颜表情分类，\(category.name)"
            button.accessibilityValue = index == selectedKaomojiCategoryIndex ? "已选中" : "未选中"
            button.accessibilityHint = "显示\(category.name)颜表情。"
            categoryRow.addArrangedSubview(button)
        }

        container.addArrangedSubview(categoryRow)
        preferredRowHeightConstraint(for: categoryRow, height: 32).isActive = true

        let entries = KaomojiDataSource.categories[selectedKaomojiCategoryIndex].entries
        let columns = 4
        let rows = 3
        for rowIndex in 0..<rows {
            let row = UIStackView()
            row.axis = .horizontal
            row.spacing = keyHorizontalSpacing
            row.distribution = .fillEqually

            for columnIndex in 0..<columns {
                let index = rowIndex * columns + columnIndex
                if index < entries.count {
                    row.addArrangedSubview(makeKaomojiButton(entries[index]))
                } else {
                    row.addArrangedSubview(UIView())
                }
            }

            preferredRowHeightConstraint(for: row, height: keyHeight).isActive = true
            container.addArrangedSubview(row)
        }

        return container
    }

    @objc private func selectKaomojiCategory(_ sender: UIButton) {
        guard KaomojiDataSource.categories.indices.contains(sender.tag) else { return }
        emitKeyPressFeedbackIfNeeded(for: sender)
        selectedKaomojiCategoryIndex = sender.tag
        reloadKeyboardContent()
    }

    private func makeKaomojiButton(_ kaomoji: String) -> UIButton {
        let button = makeKeyButton(title: kaomoji, action: #selector(insertDirectText(_:)))
        applyKeyStyle(.character, to: button)
        button.titleLabel?.font = .preferredFont(forTextStyle: .title3)
        button.titleLabel?.adjustsFontForContentSizeCategory = true
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.minimumScaleFactor = 0.45
        button.accessibilityLabel = "插入颜表情 \(kaomoji)"
        button.accessibilityHint = "插入到当前光标位置。"
        return button
    }
}
