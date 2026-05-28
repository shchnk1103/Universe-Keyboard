import UIKit

/// The horizontal candidate bar container.
///
/// The fixed height and expand-button width are part of the keyboard presentation
/// baseline: changing them can reintroduce keyboard resize/flicker regressions.
@MainActor
final class CandidateBarView: UIView {
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
        layout.sectionInset = UIEdgeInsets(top: 3, left: 4, bottom: 3, right: 8)

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        expandButton = Self.makeExpandButton(target: interactionTarget, action: expandAction)
        expandButtonWidthConstraint = expandButton.widthAnchor.constraint(equalToConstant: 44)

        super.init(frame: .zero)

        self.backgroundColor = backgroundColor
        layer.cornerRadius = 0
        clipsToBounds = true

        configureCollectionView()
        addSubview(collectionView)
        addSubview(expandButton)
        addSeparator()

        NSLayoutConstraint.activate([
            expandButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -3),
            expandButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            expandButtonWidthConstraint,
            expandButton.heightAnchor.constraint(equalToConstant: height),

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

    private func configureCollectionView() {
        collectionView.backgroundColor = .clear
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

    private func addSeparator() {
        let separator = UIView()
        separator.backgroundColor = UIColor.separator.withAlphaComponent(0.22)
        separator.translatesAutoresizingMaskIntoConstraints = false
        addSubview(separator)
        NSLayoutConstraint.activate([
            separator.leadingAnchor.constraint(equalTo: leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: trailingAnchor),
            separator.bottomAnchor.constraint(equalTo: bottomAnchor),
            separator.heightAnchor.constraint(equalToConstant: 0.5),
        ])
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
