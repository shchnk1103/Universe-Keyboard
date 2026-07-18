import KeyboardCore
import UIKit

/// Compact path button that holds a Core-provided path reference (not accessibility metadata).
final class T9PinyinPathButton: UIButton {
    /// Path already validated by KeyboardCore; never synthesize on the UI side.
    private(set) var path: T9PinyinPath?

    func configure(path: T9PinyinPath, selected: Bool) {
        self.path = path
        var config = UIButton.Configuration.plain()
        config.title = path.displayText
        config.baseForegroundColor = .label
        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = .systemFont(ofSize: 16, weight: .regular)
            return outgoing
        }
        configuration = config
        backgroundColor = .clear
        accessibilityLabel = "拼音 \(path.displayText)"
        accessibilityTraits = selected ? [.button, .selected] : .button
        // Stable UI identity only — not a business payload.
        accessibilityIdentifier = "t9PinyinPathButton"
        // Do not put replacementRawInput in accessibilityValue.
        accessibilityValue = selected ? "已选中" : nil
    }
}

/// Fixed-height precise pinyin path bar above the Chinese candidate bar (ADR 0020).
/// Transparent background, plain labels, no candidate pills.
final class T9PinyinPathBarView: UIView {
    private let stack = UIStackView()
    private let separator = UIView()
    private let height: CGFloat
    private weak var target: AnyObject?
    private let selectAction: Selector

    init(height: CGFloat, target: AnyObject?, selectAction: Selector) {
        self.height = height
        self.target = target
        self.selectAction = selectAction
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear

        stack.axis = .horizontal
        stack.alignment = .fill
        stack.distribution = .fill
        stack.spacing = 0
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)

        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.backgroundColor = UIColor.separator.withAlphaComponent(0.45)
        addSubview(separator)

        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: height),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4),
            stack.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -4),
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -1),
            separator.leadingAnchor.constraint(equalTo: leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: trailingAnchor),
            separator.bottomAnchor.constraint(equalTo: bottomAnchor),
            separator.heightAnchor.constraint(equalToConstant: 1.0 / max(traitCollection.displayScale, 1)),
        ])
        accessibilityIdentifier = "t9PinyinPathBar"
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setPaths(_ paths: [T9PinyinPath], selected: T9PinyinPath?) {
        stack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for path in paths.prefix(T9PinyinPathExtractor.compactLimit) {
            let button = T9PinyinPathButton(type: .system)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.configure(path: path, selected: path == selected)
            let minWidth = button.widthAnchor.constraint(greaterThanOrEqualToConstant: 44)
            minWidth.priority = .defaultHigh
            minWidth.isActive = true
            button.addTarget(target, action: selectAction, for: .touchUpInside)
            stack.addArrangedSubview(button)
        }
        isAccessibilityElement = false
        separator.isHidden = paths.isEmpty
    }
}
