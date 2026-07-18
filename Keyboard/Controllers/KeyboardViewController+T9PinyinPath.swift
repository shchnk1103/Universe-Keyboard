import KeyboardCore
import UIKit

extension KeyboardViewController {
    var shouldReserveT9PinyinPathBar: Bool {
        // `preferredKeyboardHeight` is queried during bootstrap before Core is installed.
        // The pre-controller surface is always the fail-closed 26-key layout.
        guard let controller else { return false }
        return controller.state.inputMode == .chinese
            && controller.state.currentPage == .letters
            && cachedLayoutStyle == .nineKey
            && cachedT9ReadinessMatched
    }

    func makeT9PinyinPathBar() -> UIView {
        let bar = T9PinyinPathBarView(
            height: t9PinyinPathBarHeight,
            target: self,
            selectAction: #selector(handleT9PinyinPathButton(_:))
        )
        t9PinyinPathBarView = bar
        refreshT9PinyinPathBar()
        return bar
    }

    func refreshT9PinyinPathBar() {
        guard let bar = t9PinyinPathBarView else { return }
        let state = controller.state.t9PinyinPathState
        bar.setPaths(state.compactPaths, selected: state.selectedPath)
        updateSelectPinyinButtonAvailability()
        if isPinyinPathExpanded {
            refreshPinyinPathExpandedPanel()
        }
    }

    func updateSelectPinyinButtonAvailability() {
        let availability = controller.t9PinyinPathAvailability()
        let enabled = availability.allowsSelectPinyinControl
        t9SelectPinyinButton?.isEnabled = enabled
        t9SelectPinyinButton?.alpha = enabled ? 1 : 0.45
        t9SelectPinyinButton?.accessibilityLabel = "选拼音"
        switch availability {
        case .pathsAvailable:
            t9SelectPinyinButton?.accessibilityHint = "打开完整拼音路径列表"
        case .discoveryPending:
            t9SelectPinyinButton?.accessibilityHint = "打开拼音路径列表并加载更多候选路径"
        case .exhaustedNoPaths:
            t9SelectPinyinButton?.accessibilityHint = "当前没有可选择的拼音路径"
        case .noComposition:
            t9SelectPinyinButton?.accessibilityHint = "请先输入九键拼音"
        }
        if enabled {
            t9SelectPinyinButton?.accessibilityTraits = .button
        } else {
            t9SelectPinyinButton?.accessibilityTraits = [.button, .notEnabled]
        }
    }

    @objc func handleT9PinyinPathButton(_ sender: UIButton) {
        emitKeyPressFeedbackIfNeeded(for: sender)
        guard let pathButton = sender as? T9PinyinPathButton,
              let path = pathButton.path
        else {
            return
        }
        // Fail closed: Core must have issued this path for the current generation.
        guard controller.state.t9PinyinPathState.issuedReplacementKeys
            .contains(path.replacementRawInput)
        else {
            return
        }

        dismissPinyinPathExpandedPanel(animated: true)
        let effects = controller.handle(.selectT9PinyinPath(path))
        syncUI(with: effects.union(.t9PinyinPathsChanged))
    }

    @objc func t9SelectPinyin(_ sender: UIButton) {
        emitKeyPressFeedbackIfNeeded(for: sender)
        let availability = controller.t9PinyinPathAvailability()
        guard availability.allowsSelectPinyinControl else {
            updateSelectPinyinButtonAvailability()
            return
        }

        if isPinyinPathExpanded {
            dismissPinyinPathExpandedPanel(animated: true)
            return
        }

        if isCandidateExpanded {
            isCandidateExpanded = false
            dismissExpandedCandidatePanel(animated: false)
            updateExpandButtonAppearance()
        }

        presentPinyinPathExpandedPanel()
    }

    func presentPinyinPathExpandedPanel() {
        isPinyinPathExpanded = true
        // Bind panel to provenance revision (comment/window authority), not raw-only generation.
        pinyinPathPanelGeneration = controller.state.t9PinyinPathState.provenanceRevision
        // First window + bounded auto-advance while empty and discovery pending
        // (sparse comments past hot-path peek must remain reachable).
        var window = controller.t9PinyinPathWindow(
            from: 0,
            limit: T9PinyinPathExtractor.panelWindowLimit
        )
        var guardrails = 0
        while window.paths.isEmpty,
              window.hasMoreCandidates,
              guardrails < 8
        {
            guardrails += 1
            let next = controller.t9PinyinPathWindow(
                from: window.nextGlobalIndex,
                limit: T9PinyinPathExtractor.panelWindowLimit
            )
            if next.nextGlobalIndex <= window.nextGlobalIndex, next.paths.isEmpty {
                break
            }
            window = next
            if !next.paths.isEmpty { break }
        }
        accumulatedPinyinPaths = window.paths
        pinyinPathNextGlobalIndex = window.nextGlobalIndex
        pinyinPathHasMore = window.hasMoreCandidates

        let panel = makePinyinPathExpandedPanel()
        rootStack.arrangedSubviews
            .filter { $0 !== candidateBar && $0 !== t9PinyinPathBarView }
            .forEach { $0.removeFromSuperview() }
        rootStack.addArrangedSubview(panel)
        pinyinPathExpandedPanel = panel
        updateSelectPinyinButtonAvailability()
        view.layoutIfNeeded()
    }

    func dismissPinyinPathExpandedPanel(animated: Bool) {
        guard isPinyinPathExpanded || pinyinPathExpandedPanel != nil else { return }
        isPinyinPathExpanded = false
        pinyinPathExpandedPanel?.removeFromSuperview()
        pinyinPathExpandedPanel = nil
        pinyinPathCollectionView = nil
        accumulatedPinyinPaths = []
        pinyinPathHasMore = false
        if hasViewAppeared {
            reloadKeyboardContent()
            refreshCandidateBar()
            refreshT9PinyinPathBar()
        }
    }

    func makePinyinPathExpandedPanel() -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = .secondarySystemBackground

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        layout.sectionInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 56)

        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.backgroundColor = .clear
        collection.dataSource = self
        collection.delegate = self
        collection.register(T9PinyinPathCell.self, forCellWithReuseIdentifier: T9PinyinPathCell.reuseID)
        collection.accessibilityIdentifier = "t9PinyinPathExpandedPanel"
        pinyinPathCollectionView = collection

        let close = UIButton(type: .system)
        close.translatesAutoresizingMaskIntoConstraints = false
        close.setImage(UIImage(systemName: "chevron.down"), for: .normal)
        close.accessibilityLabel = "关闭拼音路径"
        close.addTarget(self, action: #selector(closePinyinPathPanel(_:)), for: .touchUpInside)

        container.addSubview(collection)
        container.addSubview(close)
        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(
                greaterThanOrEqualToConstant: keyHeight * 4 + keySpacing * 3
            ),
            collection.topAnchor.constraint(equalTo: container.topAnchor),
            collection.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            collection.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            collection.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            close.topAnchor.constraint(equalTo: container.topAnchor, constant: 4),
            close.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -8),
            close.widthAnchor.constraint(equalToConstant: 44),
            close.heightAnchor.constraint(equalToConstant: 44),
        ])
        return container
    }

    @objc private func closePinyinPathPanel(_ sender: UIButton) {
        emitKeyPressFeedbackIfNeeded(for: sender)
        dismissPinyinPathExpandedPanel(animated: true)
    }

    func refreshPinyinPathExpandedPanel() {
        guard isPinyinPathExpanded else { return }
        let provenance = controller.state.t9PinyinPathState.provenanceRevision
        if provenance != pinyinPathPanelGeneration {
            // Provenance snapshot changed — rebuild accumulated paths from live windows.
            pinyinPathPanelGeneration = provenance
            let window = controller.t9PinyinPathWindow(
                from: 0,
                limit: T9PinyinPathExtractor.panelWindowLimit
            )
            accumulatedPinyinPaths = window.paths
            pinyinPathNextGlobalIndex = window.nextGlobalIndex
            pinyinPathHasMore = window.hasMoreCandidates
        }
        pinyinPathCollectionView?.reloadData()
    }

    /// Provenance-revision-guarded lazy paging for the full path panel.
    func loadMorePinyinPathsIfNeeded() {
        guard isPinyinPathExpanded, pinyinPathHasMore else { return }
        let provenance = controller.state.t9PinyinPathState.provenanceRevision
        guard provenance == pinyinPathPanelGeneration else {
            refreshPinyinPathExpandedPanel()
            return
        }
        let startIndex = pinyinPathNextGlobalIndex
        let window = controller.t9PinyinPathWindow(
            from: startIndex,
            limit: T9PinyinPathExtractor.panelWindowLimit
        )
        guard window.provenanceRevision == provenance else {
            refreshPinyinPathExpandedPanel()
            return
        }

        var seen = Set(accumulatedPinyinPaths.map(\.replacementRawInput))
        var appended: [T9PinyinPath] = []
        for path in window.paths where seen.insert(path.replacementRawInput).inserted {
            appended.append(path)
        }

        let indexAdvanced = window.nextGlobalIndex > startIndex
        if !indexAdvanced, appended.isEmpty {
            // Empty window without progress — stop paging.
            pinyinPathHasMore = false
            return
        }

        accumulatedPinyinPaths.append(contentsOf: appended)
        pinyinPathNextGlobalIndex = window.nextGlobalIndex
        pinyinPathHasMore = window.hasMoreCandidates
        if !appended.isEmpty {
            pinyinPathCollectionView?.reloadData()
        } else if !window.hasMoreCandidates {
            pinyinPathHasMore = false
        }
    }
}

// MARK: - Cell

final class T9PinyinPathCell: UICollectionViewCell {
    static let reuseID = "T9PinyinPathCell"
    private let label = UILabel()
    private(set) var path: T9PinyinPath?

    override init(frame: CGRect) {
        super.init(frame: frame)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = .label
        label.textAlignment = .center
        contentView.addSubview(label)
        contentView.backgroundColor = .clear
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 44),
            contentView.widthAnchor.constraint(greaterThanOrEqualToConstant: 44),
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(path: T9PinyinPath) {
        self.path = path
        label.text = path.displayText
        accessibilityLabel = "拼音 \(path.displayText)"
        accessibilityTraits = .button
    }
}
