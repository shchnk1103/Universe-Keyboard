import KeyboardCore
import UIKit

final class CandidateCollectionCell: UICollectionViewCell {
    static let barReuseIdentifier = "CandidateBarCell"
    static let expandedReuseIdentifier = "ExpandedCandidateCell"

    private let highlightedBackgroundView = UIView()
    private let titleLabel = UILabel()
    private var labelLeadingConstraint: NSLayoutConstraint!
    private var labelTrailingConstraint: NSLayoutConstraint!

    private static let candidateTextColor = UIColor { traits in
        traits.userInterfaceStyle == .dark ? .white : .black
    }

    private static let highlightedCandidateBackgroundColor = UIColor { traits in
        traits.userInterfaceStyle == .dark ? .white : .black
    }

    private static let highlightedCandidateTextColor = UIColor { traits in
        traits.userInterfaceStyle == .dark ? .black : .white
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        backgroundView = nil
        selectedBackgroundView = nil
        isOpaque = false
        contentView.backgroundColor = .clear
        contentView.isOpaque = false

        highlightedBackgroundView.backgroundColor = .clear
        highlightedBackgroundView.isOpaque = false
        highlightedBackgroundView.layer.cornerRadius = 8
        highlightedBackgroundView.layer.cornerCurve = .continuous
        highlightedBackgroundView.translatesAutoresizingMaskIntoConstraints = false

        titleLabel.backgroundColor = .clear
        titleLabel.isOpaque = false
        titleLabel.numberOfLines = 1
        titleLabel.lineBreakMode = .byTruncatingTail
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(highlightedBackgroundView)
        contentView.addSubview(titleLabel)

        labelLeadingConstraint = titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12)
        labelTrailingConstraint = titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12)

        NSLayoutConstraint.activate([
            highlightedBackgroundView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            highlightedBackgroundView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            highlightedBackgroundView.topAnchor.constraint(equalTo: contentView.topAnchor),
            highlightedBackgroundView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            labelLeadingConstraint,
            labelTrailingConstraint,
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            titleLabel.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor),
            titleLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        backgroundColor = .clear
        backgroundView = nil
        selectedBackgroundView = nil
        contentView.backgroundColor = .clear
        highlightedBackgroundView.backgroundColor = .clear
        titleLabel.text = nil
    }

    func configure(with item: CandidateItem, preferred: Bool, expanded: Bool) {
        let color: UIColor = item.kind == .composition ? .secondaryLabel : .label
        let title = displayTitle(for: item)
        configureTitle(title, kind: item.kind, color: color, bold: preferred, highlighted: preferred)
        accessibilityLabel = accessibilityLabel(for: item)
        accessibilityHint =
            item.kind == .composition
            ? "双击以提交原始拼音"
            : item.kind == .correctionCandidate
                ? "双击选择纠错候选词"
                : expanded ? "双击选择候选词并关闭面板" : "双击选择候选词"
    }

    private func configureTitle(
        _ title: String,
        kind: CandidateKind,
        color: UIColor,
        bold: Bool,
        highlighted: Bool
    ) {
        let fontSize: CGFloat = kind == .composition ? 15 : 17
        let weight: UIFont.Weight = bold ? .semibold : .regular
        let baseFont = UIFont.systemFont(ofSize: fontSize, weight: weight)
        titleLabel.font = UIFontMetrics(forTextStyle: .body).scaledFont(for: baseFont, maximumPointSize: 28)
        titleLabel.text = title
        titleLabel.textColor = highlighted
            ? Self.highlightedCandidateTextColor
            : (kind == .candidate ? Self.candidateTextColor : color)

        labelLeadingConstraint.constant = highlighted ? 8 : 12
        labelTrailingConstraint.constant = highlighted ? -8 : -12
        highlightedBackgroundView.backgroundColor = highlighted
            ? Self.highlightedCandidateBackgroundColor
            : .clear
    }

    private func displayTitle(for item: CandidateItem) -> String {
        guard let correction = item.correction else { return item.title }
        let summary = correction.edits.map { "\($0.original)→\($0.replacement)" }.joined(separator: " ")
        guard !summary.isEmpty else { return item.title }
        return "\(item.title)  \(summary)"
    }

    private func accessibilityLabel(for item: CandidateItem) -> String {
        if let correction = item.correction {
            let summary = correction.edits.map { "\($0.original) 改为 \($0.replacement)" }.joined(separator: "，")
            return "纠错候选 \(item.title)，\(summary)"
        }
        return item.kind == .composition ? "提交拼音 \(item.title)" : item.title
    }
}
