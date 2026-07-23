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

    /// True while nine-key T9 composition presentation must be atomic (ADR 0023).
    var shouldPublishAtomicT9Presentation: Bool {
        controller.usesT9InputSemantics
            && controller.state.inputMode == .chinese
            && controller.state.currentPage == .letters
            && cachedLayoutStyle == .nineKey
            && T9CompositionCommitPolicy.isActiveT9Composition(
                usesT9InputSemantics: true,
                rawInput: controller.state.lastRimeOutput?.rawInput
                    ?? controller.state.t9PinyinPathState.trackedRawInput
            )
    }

    /// Capture one Core snapshot and publish Path Bar + candidates together.
    func refreshT9PresentationFromCoreSnapshot() {
        let snapshot = controller.t9CompositionPresentationSnapshot()
        applyT9PresentationSnapshot(snapshot)
    }

    func applyT9PresentationSnapshot(_ snapshot: T9CompositionPresentationSnapshot) {
        // Path bar
        if let bar = t9PinyinPathBarView {
            let selected = snapshot.paths.first { $0.id == snapshot.selectedPathID }
            bar.setPaths(
                snapshot.paths,
                selected: selected,
                compositionRevision: snapshot.revision
            )
        }
        t9SpaceButton?.setTitle(spaceButtonTitle, for: .normal)
        if let t9SpaceButton {
            configureKeyAccessibility(
                t9SpaceButton,
                title: spaceButtonTitle,
                action: #selector(insertSpace(_:))
            )
        }
        // Candidate bar from the same snapshot candidates/revision
        if candidateCollectionView != nil {
            resetCandidateSnapshot(from: snapshot)
            fillCandidateBar()
            if candidateScrollView.contentOffset.x != 0 {
                candidateScrollView.setContentOffset(.zero, animated: false)
            }
            if isCandidateExpanded {
                refreshExpandedPanel()
            }
            if hasMoreCandidates {
                scheduleCandidatePrefetch(mode: candidatePrefetchMode)
            }
        }
        // Expanded path panel also binds the same revision paths
        if isPinyinPathExpanded {
            pinyinPathPanelGeneration = snapshot.revision
            pinyinPathPanelProvenanceRevision = controller.state.t9PinyinPathState.provenanceRevision
            accumulatedPinyinPaths = snapshot.paths
            pinyinPathNextGlobalIndex = snapshot.paths.count
            pinyinPathHasMore = false
            pinyinPathCollectionView?.reloadData()
        }
        updateSelectPinyinButtonAvailability()
    }

    func refreshT9PinyinPathBar() {
        // Prefer full atomic publish when T9 composition is active.
        if shouldPublishAtomicT9Presentation {
            refreshT9PresentationFromCoreSnapshot()
            return
        }
        guard let bar = t9PinyinPathBarView else { return }
        let snapshot = controller.t9CompositionPresentationSnapshot()
        let selected = snapshot.paths.first { $0.id == snapshot.selectedPathID }
        bar.setPaths(
            snapshot.paths,
            selected: selected,
            compositionRevision: snapshot.revision
        )
        t9SpaceButton?.setTitle(spaceButtonTitle, for: .normal)
        if let t9SpaceButton {
            configureKeyAccessibility(
                t9SpaceButton,
                title: spaceButtonTitle,
                action: #selector(insertSpace(_:))
            )
        }
        updateSelectPinyinButtonAvailability()
    }

    func updateSelectPinyinButtonAvailability() {
        let state = controller.state.t9PinyinPathState
        let enabled = !state.compactPaths.isEmpty
        t9SelectPinyinButton?.isEnabled = enabled
        t9SelectPinyinButton?.alpha = enabled ? 1 : 0.45
        t9SelectPinyinButton?.accessibilityLabel = "选拼音"

        if let selectedPath = state.selectedPath {
            t9SelectPinyinButton?.accessibilityValue = selectedPath.displayText
            t9SelectPinyinButton?.accessibilityHint = "选择下一个拼音"
        } else {
            t9SelectPinyinButton?.accessibilityValue = nil
            t9SelectPinyinButton?.accessibilityHint = enabled
                ? "选择第一个拼音"
                : "请先输入九键拼音"
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
        // Fail closed: Core must have issued this path for the current revision.
        let pathState = controller.state.t9PinyinPathState
        let authorized =
            pathState.issuedPathIDs.contains(path.id)
            || pathState.issuedReplacementKeys.contains(path.replacementRawInput)
            || pathState.compactPaths.contains {
                $0.displayText == path.displayText
                    && $0.replacementRawInput == path.replacementRawInput
            }
        guard authorized else { return }
        if path.compositionRevision != 0,
           path.compositionRevision != controller.state.compositionRevision
        {
            return
        }

        let effects = controller.handle(.selectT9PinyinPath(path))
        syncUI(with: effects.union(.t9PinyinPathsChanged))
    }

    @objc func t9SelectPinyin(_ sender: UIButton) {
        emitKeyPressFeedbackIfNeeded(for: sender)
        guard !controller.state.t9PinyinPathState.compactPaths.isEmpty else {
            updateSelectPinyinButtonAvailability()
            return
        }

        let effects = controller.handle(.cycleT9PinyinPath)
        syncUI(with: effects.union(.t9PinyinPathsChanged))
    }

    func presentPinyinPathExpandedPanel() {
        isPinyinPathExpanded = true
        // Bind the panel to the same Core composition revision as marked text,
        // candidates and compact paths.
        let pathState = controller.state.t9PinyinPathState
        pinyinPathPanelGeneration = pathState.compositionRevision
        pinyinPathPanelProvenanceRevision = pathState.provenanceRevision
        let window = controller.t9PinyinPathWindow(
            from: 0,
            limit: T9PinyinPathExtractor.panelWindowLimit
        )
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
        let pathState = controller.state.t9PinyinPathState
        let compositionRevision = pathState.compositionRevision
        let provenanceRevision = pathState.provenanceRevision
        if compositionRevision != pinyinPathPanelGeneration
            || provenanceRevision != pinyinPathPanelProvenanceRevision
        {
            // Either the composition or its live RIME provenance changed.
            pinyinPathPanelGeneration = compositionRevision
            pinyinPathPanelProvenanceRevision = provenanceRevision
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

    /// Composition-revision-guarded lazy paging for the full path panel.
    func loadMorePinyinPathsIfNeeded() {
        guard isPinyinPathExpanded, pinyinPathHasMore else { return }
        let pathState = controller.state.t9PinyinPathState
        let compositionRevision = pathState.compositionRevision
        let provenanceRevision = pathState.provenanceRevision
        guard compositionRevision == pinyinPathPanelGeneration,
              provenanceRevision == pinyinPathPanelProvenanceRevision
        else {
            refreshPinyinPathExpandedPanel()
            return
        }
        let startIndex = pinyinPathNextGlobalIndex
        let window = controller.t9PinyinPathWindow(
            from: startIndex,
            limit: T9PinyinPathExtractor.panelWindowLimit
        )
        guard window.compositionRevision == compositionRevision,
              window.provenanceRevision == provenanceRevision
        else {
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
