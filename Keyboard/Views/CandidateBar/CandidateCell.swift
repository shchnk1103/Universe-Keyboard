import KeyboardCore
import UIKit

final class CandidateCollectionCell: UICollectionViewCell {
    static let barReuseIdentifier = "CandidateBarCell"
    static let expandedReuseIdentifier = "ExpandedCandidateCell"

    private enum VisualSpacing {
        static let horizontalGap: CGFloat = 4
        static let verticalGap: CGFloat = 4
    }

    /// cell bounds 是完整触控区；内部视觉层保持内缩，让候选看起来仍有间距。
    private let visualContentView = UIView()
    private let contentStackView = UIStackView()
    private let titleContainerView = UIView()
    private let highlightedBackgroundView = UIView()
    private let titleLabel = UILabel()
    private let correctionHintLabel = UILabel()
    private var visualLeadingConstraint: NSLayoutConstraint!
    private var visualTrailingConstraint: NSLayoutConstraint!
    private var visualTopConstraint: NSLayoutConstraint!
    private var visualBottomConstraint: NSLayoutConstraint!
    private var titleLeadingConstraint: NSLayoutConstraint!
    private var titleTrailingConstraint: NSLayoutConstraint!
    private var currentKind: CandidateKind = .candidate
    private var currentBaseColor: UIColor = .label
    private var usesPreferredStyle = false
    private var lastPointInsideDiagnosticLogTime: CFTimeInterval = 0
    private var lastHitTestDiagnosticLogTime: CFTimeInterval = 0

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
        contentView.layer.masksToBounds = false

        visualContentView.backgroundColor = .clear
        visualContentView.isOpaque = false
        visualContentView.isUserInteractionEnabled = false
        visualContentView.translatesAutoresizingMaskIntoConstraints = false

        contentStackView.axis = .horizontal
        contentStackView.alignment = .center
        contentStackView.spacing = 3
        contentStackView.isUserInteractionEnabled = false
        contentStackView.translatesAutoresizingMaskIntoConstraints = false

        titleContainerView.backgroundColor = .clear
        titleContainerView.isOpaque = false
        titleContainerView.isUserInteractionEnabled = false
        titleContainerView.translatesAutoresizingMaskIntoConstraints = false

        highlightedBackgroundView.backgroundColor = .clear
        highlightedBackgroundView.isOpaque = false
        highlightedBackgroundView.isUserInteractionEnabled = false
        highlightedBackgroundView.layer.cornerRadius = 8
        highlightedBackgroundView.layer.cornerCurve = .continuous
        highlightedBackgroundView.translatesAutoresizingMaskIntoConstraints = false

        titleLabel.backgroundColor = .clear
        titleLabel.isOpaque = false
        titleLabel.numberOfLines = 1
        titleLabel.lineBreakMode = .byTruncatingTail
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        correctionHintLabel.backgroundColor = .clear
        correctionHintLabel.isOpaque = false
        correctionHintLabel.numberOfLines = 1
        correctionHintLabel.lineBreakMode = .byTruncatingTail
        correctionHintLabel.textAlignment = .left
        correctionHintLabel.textColor = .secondaryLabel
        correctionHintLabel.translatesAutoresizingMaskIntoConstraints = false
        correctionHintLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        correctionHintLabel.setContentHuggingPriority(.required, for: .horizontal)

        contentView.addSubview(visualContentView)
        visualContentView.addSubview(contentStackView)
        contentStackView.addArrangedSubview(titleContainerView)
        contentStackView.addArrangedSubview(correctionHintLabel)
        titleContainerView.addSubview(highlightedBackgroundView)
        titleContainerView.addSubview(titleLabel)

        visualLeadingConstraint = visualContentView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor)
        visualTrailingConstraint = visualContentView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        visualTopConstraint = visualContentView.topAnchor.constraint(equalTo: contentView.topAnchor)
        visualBottomConstraint = visualContentView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        titleLeadingConstraint = titleLabel.leadingAnchor.constraint(equalTo: titleContainerView.leadingAnchor, constant: 12)
        titleTrailingConstraint = titleLabel.trailingAnchor.constraint(equalTo: titleContainerView.trailingAnchor, constant: -12)

        NSLayoutConstraint.activate([
            visualLeadingConstraint,
            visualTrailingConstraint,
            visualTopConstraint,
            visualBottomConstraint,

            contentStackView.centerXAnchor.constraint(equalTo: visualContentView.centerXAnchor),
            contentStackView.centerYAnchor.constraint(equalTo: visualContentView.centerYAnchor),
            contentStackView.leadingAnchor.constraint(greaterThanOrEqualTo: visualContentView.leadingAnchor),
            contentStackView.trailingAnchor.constraint(lessThanOrEqualTo: visualContentView.trailingAnchor),

            highlightedBackgroundView.leadingAnchor.constraint(equalTo: titleContainerView.leadingAnchor),
            highlightedBackgroundView.trailingAnchor.constraint(equalTo: titleContainerView.trailingAnchor),
            highlightedBackgroundView.topAnchor.constraint(equalTo: titleContainerView.topAnchor),
            highlightedBackgroundView.bottomAnchor.constraint(equalTo: titleContainerView.bottomAnchor),

            titleLeadingConstraint,
            titleTrailingConstraint,
            titleLabel.topAnchor.constraint(equalTo: titleContainerView.topAnchor, constant: 4),
            titleLabel.bottomAnchor.constraint(equalTo: titleContainerView.bottomAnchor, constant: -4),
            titleLabel.centerYAnchor.constraint(equalTo: titleContainerView.centerYAnchor),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let result = super.point(inside: point, with: event)
        logTouch(
            "cell pointInside",
            point: point,
            lastLogTime: &lastPointInsideDiagnosticLogTime,
            extra: "inside=\(result)"
        )
        return result
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let result = super.hitTest(point, with: event)
        let contentPoint = contentView.convert(point, from: self)
        let visualPoint = visualContentView.convert(point, from: self)
        let contentInside = contentView.point(inside: contentPoint, with: event)
        let visualInside = visualContentView.point(inside: visualPoint, with: event)
        let indexPath = parentCollectionView?.indexPath(for: self)
        let panState = parentCollectionView?.panGestureRecognizer.state ?? .possible
        logTouch(
            "cell hitTest",
            point: point,
            lastLogTime: &lastHitTestDiagnosticLogTime,
            extra: "hit=\(CandidateTouchDiagnostics.viewName(result)) "
                + "index=\(indexPath.map { String($0.item) } ?? "nil") "
                + "contentInside=\(contentInside) visualInside=\(visualInside) "
                + "pan=\(CandidateTouchDiagnostics.gestureStateName(panState))"
        )
        return result
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        backgroundColor = .clear
        backgroundView = nil
        selectedBackgroundView = nil
        contentView.backgroundColor = .clear
        contentView.layer.borderWidth = 0
        contentView.layer.borderColor = nil
        highlightedBackgroundView.backgroundColor = .clear
        titleLabel.text = nil
        correctionHintLabel.text = nil
        correctionHintLabel.isHidden = true
        currentKind = .candidate
        currentBaseColor = .label
        usesPreferredStyle = false
        applyVisualSpacing(expanded: false)
        applyDiagnosticTouchFrameStyle()
    }

    func configure(with item: CandidateItem, preferred: Bool, expanded: Bool) {
        let color: UIColor = item.kind == .composition ? .secondaryLabel : .label
        let title = item.title
        let correctionHint = correctionHint(for: item)
        currentKind = item.kind
        currentBaseColor = color
        usesPreferredStyle = preferred
        applyVisualSpacing(expanded: expanded)
        applyDiagnosticTouchFrameStyle()
        configureTitle(
            title,
            correctionHint: correctionHint,
            kind: item.kind,
            color: color,
            bold: preferred,
            highlighted: preferred
        )
        accessibilityLabel = accessibilityLabel(for: item)
        accessibilityHint =
            item.kind == .composition
            ? "双击以提交原始拼音"
            : item.kind == .correctionCandidate
                ? "双击选择纠错候选词"
                : expanded ? "双击选择候选词并关闭面板" : "双击选择候选词"
    }

    func setSwipePreviewHighlighted(_ highlighted: Bool) {
        applyHighlightStyle(highlighted || usesPreferredStyle)
    }

    private func applyVisualSpacing(expanded: Bool) {
        let horizontalInset = VisualSpacing.horizontalGap / 2
        let verticalInset = expanded ? VisualSpacing.verticalGap / 2 : 0
        visualLeadingConstraint.constant = horizontalInset
        visualTrailingConstraint.constant = -horizontalInset
        visualTopConstraint.constant = verticalInset
        visualBottomConstraint.constant = -verticalInset
    }

    private func applyDiagnosticTouchFrameStyle() {
        // iOS Keyboard Extension / iOS 27 beta 下，完全 clear 的 cell 在视觉缝隙处
        // 可能无法稳定作为 pan 起点；保留不可见 backing，让完整 bounds 持续参与触控。
        // 候选 cell 不再随诊断开关显示红框，诊断只能改变日志，不能改变触控表面。
        contentView.backgroundColor = UIColor.systemGray.withAlphaComponent(0.001)
        contentView.layer.borderWidth = 0
        contentView.layer.borderColor = nil
    }

    private var parentCollectionView: UICollectionView? {
        var view: UIView? = superview
        while let current = view {
            if let collectionView = current as? UICollectionView {
                return collectionView
            }
            view = current.superview
        }
        return nil
    }

    private func logTouch(
        _ name: String,
        point: CGPoint,
        lastLogTime: inout CFTimeInterval,
        extra: String
    ) {
        guard CandidateTouchDiagnostics.isEnabled else { return }
        let now = CACurrentMediaTime()
        guard now - lastLogTime >= CandidateTouchDiagnostics.minimumLogInterval else { return }
        lastLogTime = now
        Logger.shared.debug(
            "candidateTouch \(name) point=\(CandidateTouchDiagnostics.pointDescription(point)) "
                + "bounds=\(Int(bounds.width))x\(Int(bounds.height)) \(extra)",
            category: .display
        )
    }

    private func configureTitle(
        _ title: String,
        correctionHint: String?,
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

        let hintFont = UIFont.systemFont(ofSize: 13, weight: .semibold)
        correctionHintLabel.font = UIFontMetrics(forTextStyle: .caption1).scaledFont(for: hintFont, maximumPointSize: 18)
        correctionHintLabel.text = correctionHint
        correctionHintLabel.textColor = .secondaryLabel
        correctionHintLabel.isHidden = correctionHint == nil

        titleLeadingConstraint.constant = highlighted ? 8 : 12
        titleTrailingConstraint.constant = highlighted ? -8 : -12
        applyHighlightStyle(highlighted)
    }

    private func applyHighlightStyle(_ highlighted: Bool) {
        titleLabel.textColor = highlighted
            ? Self.highlightedCandidateTextColor
            : (currentKind == .candidate ? Self.candidateTextColor : currentBaseColor)
        highlightedBackgroundView.backgroundColor = highlighted ? Self.highlightedCandidateBackgroundColor : .clear
    }

    private func correctionHint(for item: CandidateItem) -> String? {
        guard let correction = item.correction else { return nil }
        let summary = correction.edits.map { "\($0.original)→\($0.replacement)" }.joined(separator: " ")
        return summary.isEmpty ? nil : summary
    }

    private func accessibilityLabel(for item: CandidateItem) -> String {
        if let correction = item.correction {
            let summary = correction.edits.map { "\($0.original) 改为 \($0.replacement)" }.joined(separator: "，")
            return "纠错候选 \(item.title)，\(summary)"
        }
        return item.kind == .composition ? "提交拼音 \(item.title)" : item.title
    }
}
