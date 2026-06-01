import KeyboardCore
import UIKit

extension KeyboardViewController {
    func updateExpandButtonAppearance() {
        guard let button = candidateExpandButton else { return }
        let transform = isCandidateExpanded ? CGAffineTransform(rotationAngle: .pi) : .identity
        var config = button.configuration
        config?.baseForegroundColor = isCandidateExpanded ? .label : .secondaryLabel
        button.configuration = config
        if UIAccessibility.isReduceMotionEnabled {
            button.imageView?.transform = transform
        } else {
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut) {
                button.imageView?.transform = transform
            }
        }
    }

    func presentExpandedCandidatePanel() {
        candidateExpandedPanel?.removeFromSuperview()
        let panel = makeExpandedCandidatePanel()
        panel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(panel)
        NSLayoutConstraint.activate([
            panel.leadingAnchor.constraint(equalTo: rootStack.leadingAnchor),
            panel.trailingAnchor.constraint(equalTo: rootStack.trailingAnchor),
            panel.topAnchor.constraint(equalTo: rootStack.topAnchor),
            panel.bottomAnchor.constraint(equalTo: rootStack.bottomAnchor),
        ])
        candidateExpandedPanel = panel
        rootStack.isUserInteractionEnabled = false
        guard !UIAccessibility.isReduceMotionEnabled else {
            rootStack.alpha = 0
            return
        }
        panel.alpha = 0
        panel.transform = CGAffineTransform(translationX: 0, y: 8)
        UIView.animate(withDuration: 0.18, delay: 0, options: [.curveEaseOut, .beginFromCurrentState]) {
            panel.alpha = 1
            panel.transform = .identity
            self.rootStack.alpha = 0
        }
    }

    func dismissExpandedCandidatePanel(animated: Bool) {
        guard let panel = candidateExpandedPanel else {
            rootStack.alpha = 1
            rootStack.isUserInteractionEnabled = true
            expandedPanelScrollView = nil
            expandedCandidateCollectionView = nil
            return
        }
        let completion: (Bool) -> Void = { _ in
            panel.removeFromSuperview()
            self.candidateExpandedPanel = nil
            self.expandedPanelScrollView = nil
            self.expandedCandidateCollectionView = nil
            self.rootStack.isUserInteractionEnabled = true
        }
        guard animated, !UIAccessibility.isReduceMotionEnabled else {
            rootStack.alpha = 1
            completion(true)
            return
        }
        UIView.animate(withDuration: 0.16, delay: 0, options: [.curveEaseIn, .beginFromCurrentState]) {
            panel.alpha = 0
            panel.transform = CGAffineTransform(translationX: 0, y: 6)
            self.rootStack.alpha = 1
        } completion: { finished in
            completion(finished)
        }
    }

    func makeExpandedCandidatePanel(with precomputedItems: [CandidateItem]? = nil) -> UIView {
        let container = UIView()
        container.backgroundColor = keyboardBackgroundColor
        container.clipsToBounds = true
        let candidates = (precomputedItems ?? candidateItems()).filter { $0.kind != .placeholder }
        let collapseButtonSize: CGFloat = 44
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 4
        layout.minimumInteritemSpacing = 4
        layout.sectionInset = UIEdgeInsets(top: 5, left: 8, bottom: 8, right: collapseButtonSize + 8)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.alwaysBounceVertical = hasMoreCandidates
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(
            CandidateCollectionCell.self, forCellWithReuseIdentifier: CandidateCollectionCell.expandedReuseIdentifier)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        expandedCandidateCollectionView = collectionView
        expandedPanelScrollView = collectionView
        container.addSubview(collectionView)

        var config = UIButton.Configuration.plain()
        config.contentInsets = .zero
        config.image = UIImage(
            systemName: "chevron.up", withConfiguration: UIImage.SymbolConfiguration(pointSize: 12, weight: .medium))
        config.baseForegroundColor = .label
        let collapseButton = UIButton(configuration: config, primaryAction: nil)
        collapseButton.translatesAutoresizingMaskIntoConstraints = false
        collapseButton.addTarget(self, action: #selector(toggleCandidateExpand), for: .touchUpInside)
        collapseButton.accessibilityLabel = "收起候选面板"
        collapseButton.accessibilityHint = "双击以返回键盘"
        container.addSubview(collapseButton)
        NSLayoutConstraint.activate([
            collapseButton.topAnchor.constraint(equalTo: container.topAnchor, constant: 2),
            collapseButton.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -4),
            collapseButton.widthAnchor.constraint(equalToConstant: collapseButtonSize),
            collapseButton.heightAnchor.constraint(equalToConstant: collapseButtonSize),
            collectionView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: container.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: container.bottomAnchor),
        ])
        Logger.shared.info(
            "expandedPanel: \(candidates.count) candidates in incremental collection", category: .display)
        return container
    }

    func refreshExpandedPanel() {
        guard isCandidateExpanded, let collectionView = expandedCandidateCollectionView else { return }
        collectionView.reloadData()
        collectionView.alwaysBounceVertical = hasMoreCandidates
    }

    func appendToExpandedCandidatePanel() {
        guard isCandidateExpanded, let collectionView = expandedCandidateCollectionView else { return }
        let currentOffset = collectionView.contentOffset
        collectionView.reloadData()
        collectionView.layoutIfNeeded()
        let maxOffset = max(0, collectionView.contentSize.height - collectionView.bounds.height)
        collectionView.contentOffset.y = min(currentOffset.y, maxOffset)
        collectionView.alwaysBounceVertical = hasMoreCandidates
    }

    func commitExpandedCandidate(_ item: CandidateItem) {
        emitKeyPressFeedback()
        let effects = controller.handle(.insertCandidate(item.title, kind: item.kind))
        isCandidateExpanded = false
        updateExpandButtonAppearance()
        dismissExpandedCandidatePanel(animated: true)
        syncUI(with: effects)
    }
}
