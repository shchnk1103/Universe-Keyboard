import UIKit

/// The horizontal candidate bar container.
///
/// The fixed height and expand-button width are part of the keyboard presentation
/// baseline: changing them can reintroduce keyboard resize/flicker regressions.
@MainActor
final class CandidateBarView: UIView {
    private enum Layout {
        /// Keeps candidate text visually settled in the thinner bar.
        static let verticalTextInset: CGFloat = 0
        /// Hit area is intentionally larger than the visible chevron for reliable touch.
        static let expandButtonTouchSize: CGFloat = 56
        static let expandButtonHorizontalHitSlop: CGFloat = 10
    }

    let collectionView: UICollectionView
    let expandButton: UIButton
    let expandButtonWidthConstraint: NSLayoutConstraint

    init(
        height: CGFloat,
        backgroundColor: UIColor,
        interactionTarget: Any?,
        expandAction: Selector
    ) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 4
        layout.minimumInteritemSpacing = 4
        layout.sectionInset = UIEdgeInsets(top: Layout.verticalTextInset, left: 4, bottom: 0, right: 8)

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        expandButton = Self.makeExpandButton(target: interactionTarget, action: expandAction)
        expandButtonWidthConstraint = expandButton.widthAnchor.constraint(equalToConstant: Layout.expandButtonTouchSize)

        super.init(frame: .zero)

        self.backgroundColor = backgroundColor
        isOpaque = false
        layer.cornerRadius = 0
        clipsToBounds = true

        configureCollectionView()
        addSubview(collectionView)
        addSubview(expandButton)

        NSLayoutConstraint.activate([
            expandButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -3),
            expandButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            expandButtonWidthConstraint,
            expandButton.heightAnchor.constraint(equalToConstant: Layout.expandButtonTouchSize),

            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 2),
            collectionView.trailingAnchor.constraint(equalTo: expandButton.leadingAnchor, constant: -2),
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),

            heightAnchor.constraint(equalToConstant: height),
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        super.point(inside: point, with: event)
            || (!expandButton.isHidden && expandedButtonHitFrame.contains(point))
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if !expandButton.isHidden && expandedButtonHitFrame.contains(point) {
            return expandButton
        }
        return super.hitTest(point, with: event)
    }

    private var expandedButtonHitFrame: CGRect {
        expandButton.frame.insetBy(dx: -Layout.expandButtonHorizontalHitSlop, dy: 0)
    }

    private func configureCollectionView() {
        CandidateScrollViewStyle.apply(to: collectionView)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.bounces = true
        collectionView.alwaysBounceHorizontal = false
        collectionView.decelerationRate = .normal
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(
            CandidateCollectionCell.self,
            forCellWithReuseIdentifier: CandidateCollectionCell.barReuseIdentifier
        )
    }

    private static func makeExpandButton(target: Any?, action: Selector) -> UIButton {
        var config = UIButton.Configuration.plain()
        config.contentInsets = .zero
        config.image = UIImage(
            systemName: "chevron.down",
            withConfiguration: UIImage.SymbolConfiguration(pointSize: 12, weight: .medium)
        )
        config.baseForegroundColor = .secondaryLabel

        let button = UIButton(configuration: config, primaryAction: nil)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(target, action: action, for: .touchUpInside)
        button.accessibilityLabel = "展开更多候选词"
        button.accessibilityHint = "双击以查看完整候选列表"
        return button
    }
}
