import UIKit

@MainActor
final class PastePreviewView: UIControl {
    private let titleLabel = UILabel()
    private let summaryLabel = UILabel()
    private let closeButton = UIButton(type: .system)
    var onCannotFit: (() -> Void)?
    /// PB-013 关闭按钮动作回调：由控制器写入 closed 抑制并收栏（不粘贴）。
    var onClose: (() -> Void)?

    init(summary: String, isLink: Bool) {
        super.init(frame: .zero)
        accessibilityIdentifier = "keyboard.paste.preview"
        isAccessibilityElement = true
        accessibilityTraits = .button
        accessibilityLabel = "粘贴，\(summary)"
        let image = UIImageView(image: UIImage(systemName: "doc.on.clipboard"))
        image.tintColor = KeyboardDesignTokens.CandidateActionAppearance.symbolColor
        image.contentMode = .center
        image.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 17)
        titleLabel.text = summary
        titleLabel.textColor = .label
        summaryLabel.text = isLink ? "点按粘贴链接" : "点按粘贴"
        updateFonts()
        summaryLabel.textColor = KeyboardDesignTokens.CandidateActionAppearance.symbolColor
        summaryLabel.lineBreakMode = .byTruncatingTail
        closeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        closeButton.tintColor = KeyboardDesignTokens.CandidateActionAppearance.symbolColor
        closeButton.accessibilityIdentifier = "keyboard.paste.preview.close"
        closeButton.accessibilityLabel = "关闭预览"
        closeButton.setPreferredSymbolConfiguration(
            UIImage.SymbolConfiguration(pointSize: 12, weight: .medium), forImageIn: .normal)
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        let stack = UIStackView(arrangedSubviews: [titleLabel, summaryLabel])
        stack.axis = .vertical
        stack.spacing = 0
        stack.isUserInteractionEnabled = false
        addSubview(image)
        addSubview(stack)
        addSubview(closeButton)
        image.translatesAutoresizingMaskIntoConstraints = false
        stack.translatesAutoresizingMaskIntoConstraints = false
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            image.leadingAnchor.constraint(equalTo: leadingAnchor),
            image.centerYAnchor.constraint(equalTo: centerYAnchor),
            image.widthAnchor.constraint(equalToConstant: 28),
            image.heightAnchor.constraint(equalToConstant: 28),
            stack.leadingAnchor.constraint(equalTo: image.trailingAnchor, constant: 8),
            stack.trailingAnchor.constraint(equalTo: closeButton.leadingAnchor, constant: -6),
            stack.centerYAnchor.constraint(equalTo: centerYAnchor),
            closeButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -2),
            closeButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            closeButton.widthAnchor.constraint(equalToConstant: 28),
            closeButton.heightAnchor.constraint(equalToConstant: 28),
        ])
        registerForTraitChanges([UITraitPreferredContentSizeCategory.self]) {
            (view: PastePreviewView, _: UITraitCollection) in
            view.updateFonts()
            if !view.fitsCandidateBar { view.onCannotFit?() }
        }
    }

    @objc private func closeTapped() { onClose?() }

    private func updateFonts() {
        titleLabel.font = UIFontMetrics(forTextStyle: .body).scaledFont(
            for: .systemFont(ofSize: 15, weight: .semibold), compatibleWith: traitCollection)
        summaryLabel.font = UIFontMetrics(forTextStyle: .caption1).scaledFont(
            for: .systemFont(ofSize: 12), compatibleWith: traitCollection)
    }

    var fitsCandidateBar: Bool {
        titleLabel.font.pointSize <= 18 && titleLabel.font.lineHeight + summaryLabel.font.lineHeight <= 46
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
