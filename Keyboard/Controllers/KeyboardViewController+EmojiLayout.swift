import KeyboardCore
import UIKit

extension KeyboardViewController {
    // MARK: === Emoji 页面 ===

    func makeEmojiPage() -> UIStackView {
        let container = UIStackView()
        container.axis = .vertical
        container.spacing = 2
        container.distribution = .fill

        let categoryRow = UIStackView()
        categoryRow.axis = .horizontal
        categoryRow.spacing = 2
        categoryRow.distribution = .fillEqually

        for category in EmojiDataSource.categories {
            let label = UIButton(type: .system)
            label.setTitle(category.name, for: .normal)
            label.titleLabel?.font = .systemFont(ofSize: 12, weight: .medium)
            label.setTitleColor(.secondaryLabel, for: .normal)
            label.backgroundColor = characterKeyColor
            label.layer.cornerRadius = 4
            categoryRow.addArrangedSubview(label)
        }

        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.bounces = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        let emojiGrid = UIStackView()
        emojiGrid.axis = .vertical
        emojiGrid.spacing = 2
        emojiGrid.distribution = .fillEqually
        emojiGrid.translatesAutoresizingMaskIntoConstraints = false

        let initialEmojis = EmojiDataSource.categories.first?.emojis ?? []
        let columns = 8
        let maxRows = 4
        let visibleCount = columns * maxRows
        let displayEmojis = Array(initialEmojis.prefix(visibleCount))

        for rowIndex in 0..<maxRows {
            let rowStack = UIStackView()
            rowStack.axis = .horizontal
            rowStack.spacing = 2
            rowStack.distribution = .fillEqually

            for columnIndex in 0..<columns {
                let index = rowIndex * columns + columnIndex
                if index < displayEmojis.count {
                    let emoji = displayEmojis[index]
                    rowStack.addArrangedSubview(makeEmojiButton(emoji: emoji))
                } else {
                    rowStack.addArrangedSubview(UIView())
                }
            }
            emojiGrid.addArrangedSubview(rowStack)
        }

        scrollView.addSubview(emojiGrid)
        container.addArrangedSubview(categoryRow)
        container.addArrangedSubview(scrollView)

        NSLayoutConstraint.activate([
            categoryRow.heightAnchor.constraint(equalToConstant: 24),
            emojiGrid.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            emojiGrid.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            emojiGrid.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            emojiGrid.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            emojiGrid.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            preferredRowHeightConstraint(for: emojiGrid, height: keyHeight * 3 + keySpacing * 2),
        ])

        return container
    }

    private func makeEmojiButton(emoji: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(emoji, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 24)
        button.backgroundColor = characterKeyColor
        button.layer.cornerRadius = 6
        button.layer.cornerCurve = .continuous
        button.addTarget(self, action: #selector(insertEmoji(_:)), for: .touchUpInside)
        return button
    }
}
