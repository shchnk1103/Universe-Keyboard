import KeyboardCore
import UIKit

/// Horizontal Path collection that can accept the 44 pt expanded item frames
/// and remap iOS 26 scroll-edge chrome back onto the owning cell.
private final class T9PinyinPathBarCollectionView: UICollectionView {
    var expandedItemIndexPath: ((CGPoint) -> IndexPath?)?

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        super.point(inside: point, with: event) || expandedItemIndexPath?(point) != nil
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if let indexPath = expandedItemIndexPath?(point),
            let cell = cellForItem(at: indexPath)
        {
            let cellPoint = convert(point, to: cell)
            return cell.hitTest(cellPoint, with: event) ?? cell
        }
        return super.hitTest(point, with: event)
    }
}

/// Fixed-height precise pinyin path bar above the Chinese candidate bar (ADR 0020/0023).
/// Horizontal collection shows the full Core-issued focus Path set (no prefix(5) truncation).
///
/// Presentation mirrors the candidate bar: transparent scroll container, plain `UILabel`
/// cells, and an explicit selected pill — avoiding `UIButton.Configuration` material
/// compositing that washed the entire Path strip on iOS 26 keyboard chrome.
final class T9PinyinPathBarView: UIView, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    private let collectionView: T9PinyinPathBarCollectionView
    /// Non-interactive empty-state education; never a Path option (ADR 0023).
    private let idleHintLabel = UILabel()
    private let separator = UIView()
    private let height: CGFloat
    private weak var target: AnyObject?
    private let selectAction: Selector
    private let itemTapRecognizer = UITapGestureRecognizer()

    private var paths: [T9PinyinPath] = []
    private var selectedPath: T9PinyinPath?
    private var boundCompositionRevision: UInt64 = 0
    private var shouldScrollToStartOnNextReload = false
    private var selectedPathIDToReveal: String?
    private var lastDeliveredPathID: String?
    private var lastDeliveredAt: CFTimeInterval = 0
    #if DEBUG
        private var expandedHitOverlay: DebugKeyTouchRangeOverlayView?
        private var hitProbeLabel: UILabel?
        private var restoresClipsToBounds = true
    #endif

    init(height: CGFloat, target: AnyObject?, selectAction: Selector) {
        self.height = height
        self.target = target
        self.selectAction = selectAction

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4)
        collectionView = T9PinyinPathBarCollectionView(frame: .zero, collectionViewLayout: layout)

        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear
        isOpaque = false
        clipsToBounds = true

        collectionView.translatesAutoresizingMaskIntoConstraints = false
        CandidateScrollViewStyle.apply(to: collectionView)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.alwaysBounceHorizontal = true
        // Same delivery contract as the candidate bar: do not wait to see if
        // this press is a pan before the cell can become the hit target.
        collectionView.delaysContentTouches = false
        collectionView.canCancelContentTouches = true
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(
            T9PinyinPathBarCell.self,
            forCellWithReuseIdentifier: T9PinyinPathBarCell.reuseID
        )
        collectionView.accessibilityIdentifier = "t9PinyinPathBar"
        collectionView.expandedItemIndexPath = { [weak self] point in
            self?.indexPathForExpandedItem(at: point)
        }
        addSubview(collectionView)
        installItemTapGesture()

        idleHintLabel.translatesAutoresizingMaskIntoConstraints = false
        idleHintLabel.backgroundColor = .clear
        idleHintLabel.isOpaque = false
        idleHintLabel.numberOfLines = 1
        idleHintLabel.lineBreakMode = .byTruncatingTail
        idleHintLabel.textAlignment = .left
        // Secondary chrome — must not look like a tappable Path chip.
        idleHintLabel.font = .systemFont(ofSize: 14, weight: .regular)
        idleHintLabel.textColor = .secondaryLabel
        idleHintLabel.isUserInteractionEnabled = false
        idleHintLabel.isHidden = true
        idleHintLabel.isAccessibilityElement = true
        idleHintLabel.accessibilityTraits = .staticText
        idleHintLabel.accessibilityIdentifier = "t9PinyinPathIdleHint"
        addSubview(idleHintLabel)

        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.backgroundColor = UIColor.separator.withAlphaComponent(0.45)
        separator.isOpaque = false
        addSubview(separator)

        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: height),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -1),
            idleHintLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            idleHintLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -12),
            idleHintLabel.centerYAnchor.constraint(equalTo: collectionView.centerYAnchor),
            separator.leadingAnchor.constraint(equalTo: leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: trailingAnchor),
            separator.bottomAnchor.constraint(equalTo: bottomAnchor),
            separator.heightAnchor.constraint(
                equalToConstant: 1.0 / max(traitCollection.displayScale, 1)
            ),
        ])
        isAccessibilityElement = false
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Publish Core paths for one composition revision.
    /// - Parameters:
    ///   - compositionRevision: when this changes, scroll resets to the first item.
    ///   - selected: currently selected path (complete or prefix).
    ///   - idleHintText: empty-state education only; ignored when `paths` is non-empty.
    ///     Not a Path option — static secondary label, no selection plumbing.
    func setPaths(
        _ paths: [T9PinyinPath],
        selected: T9PinyinPath?,
        compositionRevision: UInt64,
        idleHintText: String? = nil
    ) {
        let revisionChanged = compositionRevision != boundCompositionRevision
        if revisionChanged {
            boundCompositionRevision = compositionRevision
            shouldScrollToStartOnNextReload = true
            selectedPathIDToReveal = nil
        } else if let selected, selected.id != selectedPath?.id {
            selectedPathIDToReveal = selected.id
        }

        self.paths = paths
        self.selectedPath = selected
        applyIdleHint(pathsEmpty: paths.isEmpty, text: idleHintText)
        separator.isHidden = paths.isEmpty && idleHintText == nil
        collectionView.reloadData()
        collectionView.layoutIfNeeded()

        if shouldScrollToStartOnNextReload, !paths.isEmpty {
            shouldScrollToStartOnNextReload = false
            let index = IndexPath(item: 0, section: 0)
            collectionView.scrollToItem(at: index, at: .left, animated: false)
        } else if let id = selectedPathIDToReveal,
            let index = paths.firstIndex(where: { $0.id == id })
        {
            selectedPathIDToReveal = nil
            collectionView.scrollToItem(
                at: IndexPath(item: index, section: 0),
                at: .centeredHorizontally,
                animated: true
            )
        }
    }

    private func applyIdleHint(pathsEmpty: Bool, text: String?) {
        let show = pathsEmpty && text != nil && !(text?.isEmpty ?? true)
        idleHintLabel.text = show ? text : nil
        idleHintLabel.accessibilityLabel = show ? text : nil
        idleHintLabel.isHidden = !show
        // Hide the empty collection while the hint is up so bounce/scroll chrome
        // does not compete with secondary education text.
        collectionView.isHidden = show
        collectionView.isUserInteractionEnabled = !show
    }

    private func installItemTapGesture() {
        itemTapRecognizer.addTarget(self, action: #selector(handleItemTap(_:)))
        itemTapRecognizer.cancelsTouchesInView = false
        collectionView.addGestureRecognizer(itemTapRecognizer)
    }

    @objc private func handleItemTap(_ recognizer: UITapGestureRecognizer) {
        guard recognizer.state == .ended else { return }
        let point = recognizer.location(in: collectionView)
        guard let indexPath = indexPathForExpandedItem(at: point) else { return }
        deliverSelection(at: indexPath, source: "itemTap")
    }

    private func visibleItemFrames() -> [CGRect] {
        (0..<paths.count).map { item in
            collectionView.layoutAttributesForItem(at: IndexPath(item: item, section: 0))?.frame
                ?? .null
        }
    }

    private func indexPathForExpandedItem(at collectionPoint: CGPoint) -> IndexPath? {
        guard
            let item = ChromeTouchHitGeometry.pathBarItemIndex(
                at: collectionPoint,
                itemFrames: visibleItemFrames()
            )
        else { return nil }
        return IndexPath(item: item, section: 0)
    }

    private func deliverSelection(at indexPath: IndexPath, source: String) {
        guard paths.indices.contains(indexPath.item) else { return }
        let path = paths[indexPath.item]
        let now = CACurrentMediaTime()
        if lastDeliveredPathID == path.id, now - lastDeliveredAt < 0.35 {
            return
        }
        lastDeliveredPathID = path.id
        lastDeliveredAt = now

        logPathTouch(source: source, index: indexPath.item, delivered: true)

        let proxy = T9PinyinPathButton(type: .system)
        proxy.bind(path: path)
        if let target {
            _ = target.perform(selectAction, with: proxy)
        }
    }

    private func logPathTouch(source: String, index: Int?, delivered: Bool) {
        guard Logger.isLiveCategoryEnabled(.display) else { return }
        let indexText = index.map(String.init) ?? "nil"
        Logger.shared.info(
            "path.touch source=\(source) idx=\(indexText) delivered=\(delivered)",
            category: .display
        )
    }

    // MARK: - UICollectionView

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        paths.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell =
            collectionView.dequeueReusableCell(
                withReuseIdentifier: T9PinyinPathBarCell.reuseID,
                for: indexPath
            ) as! T9PinyinPathBarCell
        let path = paths[indexPath.item]
        let selected = selectedPath.map { $0.id == path.id || $0 == path } ?? false
        cell.configure(path: path, selected: selected)
        return cell
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let path = paths[indexPath.item]
        let font = UIFont.systemFont(ofSize: T9PinyinPathBarCell.titlePointSize, weight: .regular)
        let textWidth = (path.displayText as NSString).size(withAttributes: [.font: font]).width
        let horizontalInset = T9PinyinPathBarCell.horizontalInset(selected: false) * 2
        let width = max(44, ceil(textWidth) + horizontalInset)
        // Visual row stays `height` (34pt); hit-testing is expanded in `point(inside:)`.
        return CGSize(width: width, height: max(0, height - 1))
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        deliverSelection(at: indexPath, source: "didSelect")
    }

    /// Expand the vertical hit target toward the 44pt accessibility minimum without
    /// changing the fixed 34pt Path Bar reservation used by keyboard chrome.
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        ChromeTouchHitGeometry.pathBarExpandedHitBounds(barBounds: bounds).contains(point)
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard isUserInteractionEnabled, !isHidden, alpha > 0.01 else { return nil }
        guard ChromeTouchHitGeometry.pathBarExpandedHitBounds(barBounds: bounds).contains(point)
        else { return nil }

        if !collectionView.isHidden {
            let collectionPoint = collectionView.convert(point, from: self)
            if let indexPath = indexPathForExpandedItem(at: collectionPoint),
                let cell = collectionView.cellForItem(at: indexPath)
            {
                recordHitProbe(point: point, indexPath: indexPath, hit: "cell")
                let cellPoint = cell.convert(point, from: self)
                return cell.hitTest(cellPoint, with: event) ?? cell
            }
        }

        recordHitProbe(point: point, indexPath: nil, hit: "bar")
        return super.hitTest(point, with: event) ?? self
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        #if DEBUG
            refreshDebugHitboxOverlay()
        #endif
    }

    #if DEBUG
        func refreshDebugHitboxOverlay() {
            for case let cell as T9PinyinPathBarCell in collectionView.visibleCells {
                cell.refreshDebugHitboxOverlay()
            }

            let showing = DebugHitboxOverlayPresentation.isShowing
            if showing {
                if clipsToBounds {
                    restoresClipsToBounds = true
                    clipsToBounds = false
                }
            } else if restoresClipsToBounds {
                clipsToBounds = true
            }

            guard showing else {
                expandedHitOverlay?.isHidden = true
                hitProbeLabel?.isHidden = true
                return
            }

            let overlay = expandedHitOverlay ?? DebugKeyTouchRangeOverlayView()
            if expandedHitOverlay == nil {
                addSubview(overlay)
                expandedHitOverlay = overlay
            }
            overlay.isHidden = false
            overlay.apply(
                touchFrame: ChromeTouchHitGeometry.pathBarExpandedHitBounds(barBounds: bounds),
                visualFrame: bounds,
                in: self
            )
            sendSubviewToBack(overlay)
        }

        private func recordHitProbe(point: CGPoint, indexPath: IndexPath?, hit: String) {
            guard DebugHitboxOverlayPresentation.isShowing else { return }
            let band = DiagnosticEvent.CandidateTouchBand.classify(
                y: point.y,
                height: bounds.height
            )
            let indexText = indexPath.map { String($0.item) } ?? "nil"
            refreshHitProbeLabel(
                text: "path hit=\(hit) idx=\(indexText) band=\(band.rawValue) y=\(Int(point.y))"
            )
        }

        private func refreshHitProbeLabel(text: String) {
            let label = hitProbeLabel ?? UILabel()
            if hitProbeLabel == nil {
                label.font = .monospacedDigitSystemFont(ofSize: 8, weight: .medium)
                label.textColor = .systemYellow
                label.backgroundColor = UIColor.black.withAlphaComponent(0.72)
                label.numberOfLines = 1
                label.adjustsFontSizeToFitWidth = true
                label.minimumScaleFactor = 0.5
                label.isUserInteractionEnabled = false
                addSubview(label)
                hitProbeLabel = label
            }
            label.isHidden = false
            label.text = text
            label.frame = CGRect(x: 4, y: max(2, bounds.height - 14), width: min(bounds.width - 8, 240), height: 12)
            bringSubviewToFront(label)
        }
    #else
        private func recordHitProbe(point: CGPoint, indexPath: IndexPath?, hit: String) {
            _ = point
            _ = indexPath
            _ = hit
        }
    #endif
}

/// Selection plumbing only — not used for on-screen Path rendering.
/// `handleT9PinyinPathButton` still receives this type and reads `path`.
final class T9PinyinPathButton: UIButton {
    private(set) var path: T9PinyinPath?

    func bind(path: T9PinyinPath) {
        self.path = path
    }

    static func accessibilityLabel(for path: T9PinyinPath, selected: Bool) -> String {
        let kindText: String
        switch path.kind {
        case .completeSyllable:
            kindText = "完整音节"
        case .letterPrefix:
            kindText = "拼写前缀"
        }
        var label = "拼音 \(path.displayText)，\(kindText)"
        if selected { label += "，已选中" }
        return label
    }
}

/// Plain-label Path chip. Selected state uses an explicit inverted pill (same language as
/// preferred candidate), without `UIButton.Configuration` material compositing.
final class T9PinyinPathBarCell: UICollectionViewCell {
    static let reuseID = "T9PinyinPathBarCell"
    static let titlePointSize: CGFloat = 16
    private static let highlightCornerRadius: CGFloat = 8

    private let titleLabel = UILabel()
    private let highlightedBackgroundView = UIView()
    private var titleLeadingConstraint: NSLayoutConstraint!
    private var titleTrailingConstraint: NSLayoutConstraint!
    private(set) var path: T9PinyinPath?
    #if DEBUG
        private var debugHitboxOverlay: DebugKeyTouchRangeOverlayView?
    #endif

    static func horizontalInset(selected: Bool) -> CGFloat {
        selected ? 8 : 10
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
        clipsToBounds = false

        highlightedBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        highlightedBackgroundView.isUserInteractionEnabled = false
        highlightedBackgroundView.isOpaque = false
        highlightedBackgroundView.backgroundColor = .clear
        highlightedBackgroundView.layer.cornerRadius = Self.highlightCornerRadius
        highlightedBackgroundView.layer.cornerCurve = .continuous

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.backgroundColor = .clear
        titleLabel.isOpaque = false
        titleLabel.numberOfLines = 1
        titleLabel.lineBreakMode = .byTruncatingTail
        titleLabel.textAlignment = .center
        titleLabel.font = .systemFont(ofSize: Self.titlePointSize, weight: .regular)

        contentView.addSubview(highlightedBackgroundView)
        contentView.addSubview(titleLabel)

        titleLeadingConstraint = titleLabel.leadingAnchor.constraint(
            equalTo: contentView.leadingAnchor,
            constant: Self.horizontalInset(selected: false)
        )
        titleTrailingConstraint = titleLabel.trailingAnchor.constraint(
            equalTo: contentView.trailingAnchor,
            constant: -Self.horizontalInset(selected: false)
        )

        NSLayoutConstraint.activate([
            highlightedBackgroundView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            highlightedBackgroundView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            highlightedBackgroundView.topAnchor.constraint(equalTo: contentView.topAnchor),
            highlightedBackgroundView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            titleLeadingConstraint,
            titleTrailingConstraint,
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            contentView.widthAnchor.constraint(greaterThanOrEqualToConstant: 44),
            contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 32),
        ])
        isAccessibilityElement = true
        accessibilityTraits = .button
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        ChromeTouchHitGeometry.pathBarExpandedHitBounds(barBounds: bounds).contains(point)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        path = nil
        titleLabel.text = nil
        applySelectionStyle(selected: false)
        accessibilityLabel = nil
        accessibilityValue = nil
        accessibilityTraits = .button
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        #if DEBUG
            refreshDebugHitboxOverlay()
        #endif
    }

    #if DEBUG
        func refreshDebugHitboxOverlay() {
            guard DebugHitboxOverlayPresentation.isShowing else {
                debugHitboxOverlay?.isHidden = true
                return
            }
            let overlay = debugHitboxOverlay ?? DebugKeyTouchRangeOverlayView()
            if debugHitboxOverlay == nil {
                addSubview(overlay)
                debugHitboxOverlay = overlay
            }
            overlay.isHidden = false
            overlay.apply(
                touchFrame: ChromeTouchHitGeometry.pathBarExpandedHitBounds(barBounds: bounds),
                visualFrame: highlightedBackgroundView.convert(
                    highlightedBackgroundView.bounds,
                    to: self
                ),
                in: self
            )
            bringSubviewToFront(overlay)
        }
    #endif

    func configure(path: T9PinyinPath, selected: Bool) {
        self.path = path
        titleLabel.text = path.displayText
        applySelectionStyle(selected: selected)
        accessibilityLabel = T9PinyinPathButton.accessibilityLabel(for: path, selected: selected)
        accessibilityTraits = selected ? [.button, .selected] : .button
        accessibilityValue = selected ? "已选中" : nil
        accessibilityIdentifier = "t9PinyinPathButton"
    }

    private func applySelectionStyle(selected: Bool) {
        let inset = Self.horizontalInset(selected: selected)
        titleLeadingConstraint.constant = inset
        titleTrailingConstraint.constant = -inset
        if selected {
            // Inverted pill: same contrast language as preferred candidate highlight.
            highlightedBackgroundView.backgroundColor = .label
            titleLabel.textColor = .systemBackground
        } else {
            highlightedBackgroundView.backgroundColor = .clear
            titleLabel.textColor = .label
        }
    }
}
