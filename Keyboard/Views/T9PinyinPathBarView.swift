import KeyboardCore
import UIKit

/// Fixed-height precise pinyin path bar above the Chinese candidate bar (ADR 0020/0023).
/// Horizontal collection shows the full Core-issued focus Path set (no prefix(5) truncation).
final class T9PinyinPathBarView: UIView, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    private let collectionView: UICollectionView
    private let separator = UIView()
    private let height: CGFloat
    private weak var target: AnyObject?
    private let selectAction: Selector

    private var paths: [T9PinyinPath] = []
    private var selectedPath: T9PinyinPath?
    private var boundCompositionRevision: UInt64 = 0
    private var shouldScrollToStartOnNextReload = false
    private var selectedPathIDToReveal: String?

    init(height: CGFloat, target: AnyObject?, selectAction: Selector) {
        self.height = height
        self.target = target
        self.selectAction = selectAction

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4)
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)

        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear
        clipsToBounds = true

        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.alwaysBounceHorizontal = true
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(
            T9PinyinPathBarCell.self,
            forCellWithReuseIdentifier: T9PinyinPathBarCell.reuseID
        )
        collectionView.accessibilityIdentifier = "t9PinyinPathBar"
        addSubview(collectionView)

        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.backgroundColor = UIColor.separator.withAlphaComponent(0.45)
        addSubview(separator)

        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: height),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -1),
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
    func setPaths(
        _ paths: [T9PinyinPath],
        selected: T9PinyinPath?,
        compositionRevision: UInt64
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
        separator.isHidden = paths.isEmpty
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

    // MARK: - UICollectionView

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        paths.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
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
        let font = UIFont.systemFont(ofSize: 16, weight: .regular)
        let textWidth = (path.displayText as NSString).size(withAttributes: [.font: font]).width
        let width = max(44, ceil(textWidth) + 20)
        // Visual row stays `height` (34pt); hit-testing is expanded in `point(inside:)`.
        return CGSize(width: width, height: max(0, height - 1))
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let path = paths[indexPath.item]
        // Reuse the existing button selector contract via a lightweight proxy button.
        let proxy = T9PinyinPathButton(type: .system)
        proxy.configure(path: path, selected: true)
        // `selectAction` is a non-optional stored Selector; only `target` is weak/optional.
        if let target {
            _ = target.perform(selectAction, with: proxy)
        }
    }

    /// Expand the vertical hit target toward the 44pt accessibility minimum without
    /// changing the fixed 34pt Path Bar reservation used by keyboard chrome.
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let verticalPad = max(0, (44 - bounds.height) / 2)
        let expanded = bounds.insetBy(dx: 0, dy: -verticalPad)
        return expanded.contains(point)
    }
}

/// Compact path button retained for selector-based selection plumbing.
final class T9PinyinPathButton: UIButton {
    private(set) var path: T9PinyinPath?

    func configure(path: T9PinyinPath, selected: Bool) {
        self.path = path
        var config = UIButton.Configuration.plain()
        config.title = path.displayText
        config.titleLineBreakMode = .byTruncatingTail
        config.titleAlignment = .center
        config.contentInsets = NSDirectionalEdgeInsets(
            top: 0,
            leading: selected ? 8 : 10,
            bottom: 0,
            trailing: selected ? 8 : 10
        )
        if selected {
            config.background.backgroundColor = .label
            config.background.cornerRadius = 8
        }
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = .systemFont(ofSize: 16, weight: .regular)
            outgoing.foregroundColor = selected ? .systemBackground : .label
            return outgoing
        }
        configuration = config
        accessibilityLabel = Self.accessibilityLabel(for: path, selected: selected)
        accessibilityTraits = selected ? [.button, .selected] : .button
        accessibilityIdentifier = "t9PinyinPathButton"
        accessibilityValue = selected ? "已选中" : nil
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

final class T9PinyinPathBarCell: UICollectionViewCell {
    static let reuseID = "T9PinyinPathBarCell"
    private let button = T9PinyinPathButton(type: .system)
    private(set) var path: T9PinyinPath?

    override init(frame: CGRect) {
        super.init(frame: frame)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isUserInteractionEnabled = false
        contentView.addSubview(button)
        NSLayoutConstraint.activate([
            button.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            button.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            button.topAnchor.constraint(equalTo: contentView.topAnchor),
            button.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
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

    func configure(path: T9PinyinPath, selected: Bool) {
        self.path = path
        button.configure(path: path, selected: selected)
        accessibilityLabel = T9PinyinPathButton.accessibilityLabel(for: path, selected: selected)
        accessibilityTraits = selected ? [.button, .selected] : .button
        accessibilityValue = selected ? "已选中" : nil
        accessibilityIdentifier = "t9PinyinPathButton"
    }
}
