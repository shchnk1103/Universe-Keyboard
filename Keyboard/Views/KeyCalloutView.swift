import UIKit

/// Single-instance character key callout (PB-019 PR-1).
///
/// Reuse-pool semantics: the controller installs one instance when the keyboard
/// UI is installed and keeps it in the hierarchy (hidden) for its lifetime. The
/// press hot path only mutates `text` / `frame` / `isHidden` — no view
/// allocation, no attributed-string construction and no defaults reads.
///
/// Pure display layer: never intercepts touches (`isUserInteractionEnabled` is
/// false and `point(inside:with:)` always returns false) and never enters the
/// VoiceOver tree (`isAccessibilityElement` is false — the character is already
/// carried by the key's label).
final class KeyCalloutView: UIView {
    static let preferredHeight: CGFloat = 44
    static let gapAboveKey: CGFloat = 6
    static let edgeInset: CGFloat = 3
    static let cornerRadius: CGFloat = 9
    static let characterFontSize: CGFloat = 22

    // Test hooks (nil = follow the system accessibility settings).
    var reduceTransparencyOverride: Bool?
    var reduceMotionOverride: Bool?

    /// Whether the most recent `show` transition used the pop-in animation.
    /// False for rollover migration updates (already visible) and for the
    /// Reduce Motion direct-display branch.
    private(set) var lastTransitionAnimated = false

    private let materialView = UIVisualEffectView()
    private let characterLabel = UILabel()
    private let pointerLayer = CAShapeLayer()
    private var pointerOffset: CGFloat = 0
    private var appliedReduceTransparency: Bool?

    /// Button whose press currently owns the callout. Used for conditional
    /// dismissals so a migrated rollover callout survives the previous key's
    /// `clearHighlight`.
    weak var sourceButton: UIButton?

    var characterText: String? { characterLabel.text }
    var characterFont: UIFont? { characterLabel.font }
    var materialFillView: UIVisualEffectView { materialView }

    var isReduceTransparency: Bool {
        reduceTransparencyOverride ?? UIAccessibility.isReduceTransparencyEnabled
    }

    var isReduceMotion: Bool {
        reduceMotionOverride ?? UIAccessibility.isReduceMotionEnabled
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        isOpaque = false
        backgroundColor = .clear
        isUserInteractionEnabled = false
        isAccessibilityElement = false

        materialView.isUserInteractionEnabled = false
        materialView.clipsToBounds = true
        materialView.layer.cornerCurve = .continuous
        materialView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(materialView)

        characterLabel.textAlignment = .center
        characterLabel.font = .systemFont(ofSize: Self.characterFontSize, weight: .semibold)
        characterLabel.textColor = .label
        characterLabel.translatesAutoresizingMaskIntoConstraints = false
        materialView.contentView.addSubview(characterLabel)
        NSLayoutConstraint.activate([
            characterLabel.centerXAnchor.constraint(equalTo: materialView.contentView.centerXAnchor),
            characterLabel.centerYAnchor.constraint(equalTo: materialView.contentView.centerYAnchor),
        ])

        // Above the material layer so the arrow merges with the bubble edge.
        layer.addSublayer(pointerLayer)

        applyChromeIfNeeded()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        false
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        materialView.frame = bounds
        materialView.layer.cornerRadius = Self.cornerRadius
        let arrowWidth: CGFloat = 10
        let arrowHeight: CGFloat = 5
        let travelLimit = max(0, bounds.width / 2 - arrowWidth / 2 - 2)
        let offset = max(-travelLimit, min(travelLimit, pointerOffset))
        let midX = bounds.midX + offset
        let baseY = bounds.maxY
        let path = UIBezierPath()
        path.move(to: CGPoint(x: midX - arrowWidth / 2, y: baseY))
        path.addLine(to: CGPoint(x: midX + arrowWidth / 2, y: baseY))
        path.addLine(to: CGPoint(x: midX, y: baseY + arrowHeight))
        path.close()
        pointerLayer.path = path.cgPath
    }

    // MARK: - Geometry

    /// Bubble frame for a key: key-cap width × 44pt, bottom edge 6pt above the
    /// key top, horizontally clamped to 3pt from the container edges (top row
    /// Q/P style asymmetric clamping; the pointer arrow follows the offset).
    static func bubbleFrame(for keyFrame: CGRect, containerBounds: CGRect) -> CGRect {
        let width = keyFrame.width
        var originX = keyFrame.midX - width / 2
        originX = max(Self.edgeInset, min(originX, containerBounds.width - width - Self.edgeInset))
        let originY = keyFrame.minY - Self.preferredHeight - Self.gapAboveKey
        return CGRect(x: originX, y: originY, width: width, height: Self.preferredHeight)
    }

    /// Horizontal pointer-arrow offset so the arrow keeps pointing at the
    /// triggering key after the bubble is clamped.
    static func pointerOffset(for keyFrame: CGRect, bubbleFrame: CGRect) -> CGFloat {
        keyFrame.midX - bubbleFrame.midX
    }

    // MARK: - Show / dismiss

    /// Shows or migrates the callout. Hidden → shown uses the 0.12s fade +
    /// 0.85→1.0 pop (direct display under Reduce Motion); while already visible
    /// (rollover migration) text and frame update without animation.
    func show(character: String, keyFrame: CGRect, containerBounds: CGRect) {
        applyChromeIfNeeded()
        characterLabel.text = character
        frame = Self.bubbleFrame(for: keyFrame, containerBounds: containerBounds)
        pointerOffset = Self.pointerOffset(for: keyFrame, bubbleFrame: frame)
        setNeedsLayout()

        let shouldAnimate = isHidden && !isReduceMotion
        lastTransitionAnimated = shouldAnimate
        if shouldAnimate {
            alpha = 0
            transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
            UIView.animate(withDuration: 0.12) {
                self.alpha = 1
                self.transform = .identity
            }
        } else {
            alpha = 1
            transform = .identity
        }
        isHidden = false
    }

    /// Force-hide: unconditional, used by cleanup/force-dismiss paths.
    func dismiss() {
        isHidden = true
        sourceButton = nil
    }

    /// Conditional hide: only hides when the callout belongs to `button`, so a
    /// migrated rollover callout survives the previous key's clearHighlight.
    func dismissIfSource(_ button: UIButton) {
        guard sourceButton === button else { return }
        dismiss()
    }

    // MARK: - Chrome

    /// Re-applies chrome only when the Reduce Transparency state changed, so
    /// repeated shows on the hot path perform no effect allocation.
    func applyChromeIfNeeded() {
        let current = isReduceTransparency
        guard appliedReduceTransparency != current else { return }
        appliedReduceTransparency = current

        characterLabel.textColor = .label
        materialView.layer.borderWidth = 1 / UIScreen.main.scale
        materialView.layer.borderColor = UIColor.separator.cgColor
        let fill: UIColor
        if current {
            // Reduce Transparency: solid fill degradation.
            materialView.effect = nil
            materialView.backgroundColor = UIColor.secondarySystemGroupedBackground
            fill = UIColor.secondarySystemGroupedBackground
        } else {
            materialView.backgroundColor = .clear
            if #available(iOS 26.0, *) {
                materialView.effect = UIGlassEffect(style: .regular)
            } else {
                materialView.effect = UIBlurEffect(style: .systemUltraThinMaterial)
            }
            fill = UIColor.secondarySystemGroupedBackground
        }
        pointerLayer.fillColor = fill.cgColor
    }
}
