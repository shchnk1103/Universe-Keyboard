import UIKit

/// Delete-key-only overlay. Not a reuse of `KeyPopupView`.
final class DeleteTrashBubbleView: UIView {
    static let preferredHeight: CGFloat = 32
    static let minimumHeight: CGFloat = 12
    static let gapAboveKey: CGFloat = 6
    static let topInset: CGFloat = 2
    static let width: CGFloat = 36

    private let symbolView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        isOpaque = false
        backgroundColor = UIColor.secondarySystemBackground.withAlphaComponent(0.94)
        layer.cornerRadius = 8
        layer.cornerCurve = .continuous
        layer.borderWidth = 1 / UIScreen.main.scale
        layer.borderColor = UIColor.separator.cgColor
        isAccessibilityElement = true
        accessibilityLabel = "删除光标前文字"
        accessibilityTraits = .button

        let image = UIImage(systemName: "trash")?.withRenderingMode(.alwaysTemplate)
        symbolView.image = image
        symbolView.tintColor = .label
        symbolView.contentMode = .scaleAspectFit
        symbolView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(symbolView)

        NSLayoutConstraint.activate([
            symbolView.centerXAnchor.constraint(equalTo: centerXAnchor),
            symbolView.centerYAnchor.constraint(equalTo: centerYAnchor),
            symbolView.widthAnchor.constraint(lessThanOrEqualTo: widthAnchor, constant: -10),
            symbolView.heightAnchor.constraint(lessThanOrEqualTo: heightAnchor, constant: -8),
        ])
        symbolView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(
            pointSize: 15,
            weight: .regular
        )
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var intrinsicContentSize: CGSize {
        CGSize(width: 36, height: 28)
    }
}
