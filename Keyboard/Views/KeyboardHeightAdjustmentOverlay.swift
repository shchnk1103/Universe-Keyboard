import KeyboardCore
import UIKit

/// 覆盖整个输入面，空白处也截获触摸；控件与按键扩大触区没有共享命中路径。
final class KeyboardHeightAdjustmentOverlay: UIView {
    let slider = UISlider()
    let valueLabel = UILabel()
    let resetButton = UIButton(type: .system)
    let cancelButton = UIButton(type: .system)
    let confirmButton = UIButton(type: .system)
    let nextKeyboardButton = UIButton(type: .system)
    var onEscape: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.black.withAlphaComponent(0.35)
        accessibilityViewIsModal = true
        let panel = UIStackView()
        panel.axis = .vertical
        panel.spacing = 8
        panel.isLayoutMarginsRelativeArrangement = true
        panel.directionalLayoutMargins = .init(top: 12, leading: 16, bottom: 12, trailing: 16)
        panel.backgroundColor = .secondarySystemBackground
        panel.layer.cornerRadius = 12
        panel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(panel)

        valueLabel.font = .preferredFont(forTextStyle: .headline)
        valueLabel.textColor = .label
        valueLabel.textAlignment = .center
        panel.addArrangedSubview(valueLabel)
        slider.accessibilityLabel = "键盘行高"
        slider.accessibilityTraits.insert(.adjustable)
        slider.accessibilityIdentifier = "keyboardHeightSlider"
        slider.isContinuous = true
        slider.tintColor = .label
        slider.heightAnchor.constraint(greaterThanOrEqualToConstant: 44).isActive = true
        panel.addArrangedSubview(slider)

        let actions = UIStackView()
        actions.distribution = .fillEqually
        actions.spacing = 8
        for (button, title, identifier) in [
            (nextKeyboardButton, "", "keyboardHeightNextKeyboard"),
            (resetButton, "重置", "keyboardHeightReset"),
            (cancelButton, "取消", "keyboardHeightCancel"),
            (confirmButton, "确定", "keyboardHeightConfirm"),
        ] {
            button.setTitle(title, for: .normal)
            button.tintColor = .label
            button.accessibilityIdentifier = identifier
            button.titleLabel?.font = .preferredFont(forTextStyle: .body)
            button.heightAnchor.constraint(greaterThanOrEqualToConstant: 44).isActive = true
            actions.addArrangedSubview(button)
        }
        nextKeyboardButton.setImage(UIImage(systemName: "globe"), for: .normal)
        nextKeyboardButton.accessibilityLabel = "切换键盘"
        panel.addArrangedSubview(actions)
        let preferredWidth = panel.widthAnchor.constraint(equalTo: widthAnchor, constant: -24)
        preferredWidth.priority = .defaultHigh
        NSLayoutConstraint.activate([
            panel.centerXAnchor.constraint(equalTo: centerXAnchor),
            panel.centerYAnchor.constraint(equalTo: centerYAnchor),
            panel.widthAnchor.constraint(lessThanOrEqualToConstant: 360),
            panel.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 12),
            panel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -12),
            preferredWidth,
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func accessibilityPerformEscape() -> Bool {
        onEscape?()
        return true
    }

    func update(rowHeight: Int, maximum: Int) {
        slider.minimumValue = Float(KeyboardHeightSettings.minimumRowHeight)
        slider.maximumValue = Float(maximum)
        slider.value = Float(rowHeight)
        slider.accessibilityValue = "\(rowHeight) 点"
        valueLabel.text = "键盘行高 · \(rowHeight) 点"
    }
}
