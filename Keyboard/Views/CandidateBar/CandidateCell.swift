import KeyboardCore
import UIKit

final class CandidateCollectionCell: UICollectionViewCell {
    static let barReuseIdentifier = "CandidateBarCell"
    static let expandedReuseIdentifier = "ExpandedCandidateCell"

    private let button = UIButton(configuration: .plain())

    override init(frame: CGRect) {
        super.init(frame: frame)
        button.titleLabel?.numberOfLines = 1
        button.titleLabel?.lineBreakMode = .byTruncatingTail
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isUserInteractionEnabled = false
        contentView.addSubview(button)
        NSLayoutConstraint.activate([
            button.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            button.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            button.topAnchor.constraint(equalTo: contentView.topAnchor),
            button.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with item: CandidateItem, preferred: Bool, expanded: Bool) {
        let color: UIColor = item.kind == .composition ? .secondaryLabel : .label
        CandidateButtonFactory.configureCandidateButton(
            button,
            title: item.title,
            kind: item.kind,
            color: color,
            bold: preferred,
            highlighted: preferred
        )
        accessibilityLabel = item.kind == .composition ? "提交拼音 \(item.title)" : item.title
        accessibilityHint =
            item.kind == .composition
            ? "双击以提交原始拼音"
            : expanded ? "双击选择候选词并关闭面板" : "双击选择候选词"
    }
}
