import UIKit

/// Delete-key-only overlay. Not a reuse of `KeyPopupView`.
final class DeleteTrashBubbleView: UIView {
    static let preferredHeight: CGFloat = 32
    static let minimumHeight: CGFloat = 12
    static let gapAboveKey: CGFloat = 6
    static let topInset: CGFloat = 2
    static let width: CGFloat = 36

    private let materialView = UIVisualEffectView()
    private let symbolView = UIImageView()
    private var fingerInside = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        isOpaque = false
        backgroundColor = .clear
        isAccessibilityElement = true
        accessibilityLabel = "删除光标前文字"
        accessibilityTraits = .button

        materialView.isUserInteractionEnabled = false
        materialView.clipsToBounds = true
        materialView.layer.cornerCurve = .continuous
        materialView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(materialView)

        let image = UIImage(systemName: "trash")?.withRenderingMode(.alwaysTemplate)
        symbolView.image = image
        symbolView.tintColor = .label
        symbolView.contentMode = .scaleAspectFit
        symbolView.translatesAutoresizingMaskIntoConstraints = false
        materialView.contentView.addSubview(symbolView)

        NSLayoutConstraint.activate([
            symbolView.centerXAnchor.constraint(equalTo: materialView.contentView.centerXAnchor),
            symbolView.centerYAnchor.constraint(equalTo: materialView.contentView.centerYAnchor),
            symbolView.widthAnchor.constraint(lessThanOrEqualTo: materialView.contentView.widthAnchor, constant: -10),
            symbolView.heightAnchor.constraint(lessThanOrEqualTo: materialView.contentView.heightAnchor, constant: -8),
        ])
        symbolView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(
            pointSize: 15,
            weight: .regular
        )
        applyChrome(armed: false)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        materialView.frame = bounds
        let radius = min(8, bounds.height / 2)
        materialView.layer.cornerRadius = radius
    }

    /// Finger is over the bubble, so lifting will clear text before the cursor.
    func setFingerInside(_ inside: Bool) {
        guard inside != fingerInside else { return }
        fingerInside = inside
        accessibilityValue = inside ? "松手清空光标前文字" : nil
        UIView.animate(withDuration: 0.12) {
            self.applyChrome(armed: inside)
        }
    }

    override var intrinsicContentSize: CGSize {
        CGSize(width: 36, height: 28)
    }

    private func applyChrome(armed: Bool) {
        let reduceTransparency = UIAccessibility.isReduceTransparencyEnabled
        if #available(iOS 26.0, *), !reduceTransparency {
            let glass = UIGlassEffect(style: .regular)
            glass.tintColor = armed ? UIColor.systemRed.withAlphaComponent(0.42) : nil
            materialView.effect = glass
            materialView.backgroundColor = .clear
            materialView.layer.borderWidth = 0
        } else if reduceTransparency {
            materialView.effect = nil
            materialView.backgroundColor =
                armed
                ? UIColor.systemRed.withAlphaComponent(0.28)
                : UIColor.secondarySystemBackground
            materialView.layer.borderWidth = 1 / UIScreen.main.scale
            materialView.layer.borderColor = UIColor.separator.cgColor
        } else {
            let style: UIBlurEffect.Style =
                traitCollection.userInterfaceStyle == .dark
                ? .systemUltraThinMaterialDark
                : .systemUltraThinMaterialLight
            materialView.effect = UIBlurEffect(style: style)
            materialView.backgroundColor =
                armed ? UIColor.systemRed.withAlphaComponent(0.22) : .clear
            materialView.layer.borderWidth = 1 / UIScreen.main.scale
            materialView.layer.borderColor = UIColor.separator.cgColor
        }
        symbolView.tintColor = armed ? .systemRed : .label
    }
}
