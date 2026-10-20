import KeyboardCore
import UIKit

/// Flow layout 默认会把同一行的 item 间距拉大到填满宽度。
/// 候选展开面板需要像文字流一样从左到右紧凑排列，所以这里固定为左对齐。
private final class LeftAlignedCandidateFlowLayout: UICollectionViewFlowLayout {
    /// 右上角收起按钮只占用第一行的尾部区域，不能让所有行都空出一整列。
    var firstRowTrailingReservedWidth: CGFloat = 0

    private var cachedAttributes: [UICollectionViewLayoutAttributes] = []
    private var cachedAttributesByIndexPath: [IndexPath: UICollectionViewLayoutAttributes] = [:]
    private var cachedContentSize: CGSize = .zero

    override var collectionViewContentSize: CGSize {
        cachedContentSize
    }

    override func prepare() {
        super.prepare()
        guard let collectionView else {
            cachedAttributes = []
            cachedAttributesByIndexPath = [:]
            cachedContentSize = .zero
            return
        }

        var nextX = sectionInset.left
        var nextY = sectionInset.top
        var rowHeight: CGFloat = 0
        var rowIndex = 0
        let fullRowMaxX = collectionView.bounds.width - sectionInset.right
        let firstRowMaxX = max(sectionInset.left, fullRowMaxX - firstRowTrailingReservedWidth)
        var preparedAttributes: [UICollectionViewLayoutAttributes] = []

        for section in 0..<collectionView.numberOfSections {
            for item in 0..<collectionView.numberOfItems(inSection: section) {
                let indexPath = IndexPath(item: item, section: section)
                guard
                    let sourceAttribute = super.layoutAttributesForItem(at: indexPath)?
                        .copy() as? UICollectionViewLayoutAttributes
                else { continue }

                let originalSize = sourceAttribute.frame.size
                var rowMaxX = rowIndex == 0 ? firstRowMaxX : fullRowMaxX
                if nextX > sectionInset.left, nextX + originalSize.width > rowMaxX {
                    rowIndex += 1
                    nextX = sectionInset.left
                    // First-row cells stay 42pt; only the next row clears the 46pt action zone.
                    nextY +=
                        max(
                            rowHeight,
                            rowIndex == 1 ? KeyboardDesignTokens.CandidateBar.totalHeight - sectionInset.top : 0)
                        + minimumLineSpacing
                    rowHeight = 0
                    rowMaxX = fullRowMaxX
                }
                var size = originalSize
                size.width = min(size.width, max(44, rowMaxX - sectionInset.left))

                sourceAttribute.frame = CGRect(origin: CGPoint(x: nextX, y: nextY), size: size)
                preparedAttributes.append(sourceAttribute)
                nextX += size.width + minimumInteritemSpacing
                rowHeight = max(rowHeight, size.height)
            }
        }

        cachedAttributes = preparedAttributes
        // UIKit 正常情况下每个 IndexPath 只有一份属性；逐项赋值仍能在异常重复时
        // 安全采用最后一份，而不是让仅用于性能的缓存触发崩溃。
        var attributesByIndexPath: [IndexPath: UICollectionViewLayoutAttributes] = [:]
        attributesByIndexPath.reserveCapacity(preparedAttributes.count)
        for attribute in preparedAttributes {
            attributesByIndexPath[attribute.indexPath] = attribute
        }
        cachedAttributesByIndexPath = attributesByIndexPath
        cachedContentSize = CGSize(
            width: collectionView.bounds.width,
            height: nextY + rowHeight + sectionInset.bottom
        )
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        cachedAttributes.filter { $0.frame.intersects(rect) }
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        cachedAttributesByIndexPath[indexPath]
    }

    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        guard let collectionView else { return true }
        return abs(collectionView.bounds.width - newBounds.width) > .ulpOfOne
    }
}

/// 收起按钮使用与普通候选栏相同的操作区，命中不侵占相邻候选。
/// 父容器和 UIButton tracking 使用同一边界。
private final class ExpandedCandidateCollapseButton: UIButton {
    var hitOutsets = UIEdgeInsets.zero

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        guard isUserInteractionEnabled, !isHidden, alpha > 0.01 else { return false }
        return expandedHitBounds.contains(point)
    }

    var expandedHitBounds: CGRect {
        bounds.inset(
            by: UIEdgeInsets(
                top: -hitOutsets.top,
                left: -hitOutsets.left,
                bottom: -hitOutsets.bottom,
                right: -hitOutsets.right
            )
        )
    }
}

/// 展开面板里 collectionView 填满整个区域，右上角收起按钮需要明确的命中优先级。
final class ExpandedCandidatePanelContainerView: UIView {
    fileprivate weak var collapseButton: ExpandedCandidateCollapseButton?
    private var lastHitTestDiagnosticLogTime: CFTimeInterval = 0
    #if DEBUG
        private var collapseHitboxOverlay: DebugKeyTouchRangeOverlayView?
    #endif

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        #if DEBUG
            refreshDebugHitboxOverlay()
        #endif
    }

    #if DEBUG
        func refreshDebugHitboxOverlay() {
            for case let cell as CandidateCollectionCell
                in (subviews.compactMap { $0 as? CandidateCollectionView }.first?.visibleCells ?? [])
            {
                cell.refreshDebugHitboxOverlay()
            }
            guard DebugHitboxOverlayPresentation.isShowing, let button = collapseButton, !button.isHidden else {
                collapseHitboxOverlay?.isHidden = true
                return
            }
            let overlay = collapseHitboxOverlay ?? DebugKeyTouchRangeOverlayView()
            if collapseHitboxOverlay == nil {
                addSubview(overlay)
                collapseHitboxOverlay = overlay
            }
            overlay.isHidden = false
            overlay.apply(
                touchFrame: collapseButtonHitFrame,
                visualFrame: button.frame,
                in: self
            )
            bringSubviewToFront(button)
            bringSubviewToFront(overlay)
        }
    #endif

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return super.point(inside: point, with: event) || collapseButtonHitFrame.contains(point)
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard isUserInteractionEnabled, !isHidden, alpha > 0.01 else { return nil }
        if let button = collapseButton,
            button.isUserInteractionEnabled,
            !button.isHidden,
            button.alpha > 0.01
        {
            let buttonPoint = button.convert(point, from: self)
            if button.expandedHitBounds.contains(buttonPoint) {
                let result = button.hitTest(buttonPoint, with: event) ?? button
                logHitTest(point: point, result: result, reason: "collapseButton")
                return result
            }
        }
        let result = super.hitTest(point, with: event)
        logHitTest(point: point, result: result, reason: "super")
        return result
    }

    private var collapseButtonHitFrame: CGRect {
        guard let button = collapseButton, !button.isHidden else { return .null }
        let outsets = button.hitOutsets
        return button.frame.inset(
            by: UIEdgeInsets(
                top: -outsets.top,
                left: -outsets.left,
                bottom: -outsets.bottom,
                right: -outsets.right
            )
        )
    }

    private func logHitTest(point: CGPoint, result: UIView?, reason: String) {
        guard CandidateTouchDiagnostics.isEnabled else { return }
        let now = CACurrentMediaTime()
        guard now - lastHitTestDiagnosticLogTime >= CandidateTouchDiagnostics.minimumLogInterval else { return }
        lastHitTestDiagnosticLogTime = now
        Logger.shared.debug(
            "candidateTouch expandedPanel hitTest point=\(CandidateTouchDiagnostics.pointDescription(point)) "
                + "hit=\(CandidateTouchDiagnostics.viewName(result)) reason=\(reason) "
                + "collapseFrame=\(collapseButton.map { frameDescription($0.frame) } ?? "nil") "
                + "collapseHitFrame=\(frameDescription(collapseButtonHitFrame))",
            category: .display
        )
    }

    private func frameDescription(_ frame: CGRect) -> String {
        "(\(Int(frame.minX)),\(Int(frame.minY)),\(Int(frame.width)),\(Int(frame.height)))"
    }
}

extension KeyboardViewController {
    func updateExpandButtonAppearance(canExpand: Bool? = nil) {
        guard let button = candidateExpandButton else { return }
        let expands =
            canExpand
            ?? presentedCandidates.contains { $0.kind.expandsCandidateBarPanel }
            || isCandidateExpanded
        (candidateBar as? CandidateBarView)?.setCanExpandCandidates(expands)
        button.configuration = nil
        button.backgroundColor = UIColor.systemGray.withAlphaComponent(0.001)
        button.tintColor = isCandidateExpanded ? .label : .secondaryLabel
        button.setImage(CandidateBarView.trailingChromeImage(expanding: expands), for: .normal)
        if expands {
            button.accessibilityLabel = isCandidateExpanded ? "收起候选词" : "展开更多候选词"
            button.accessibilityHint = isCandidateExpanded ? "双击以收起完整候选列表" : "双击以查看完整候选列表"
        } else {
            button.accessibilityLabel = "关闭键盘"
            button.accessibilityHint = "双击以收起键盘"
        }
        let transform = (expands && isCandidateExpanded) ? CGAffineTransform(rotationAngle: .pi) : .identity
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
            panel.leadingAnchor.constraint(equalTo: keyboardSurfaceView.leadingAnchor),
            panel.trailingAnchor.constraint(equalTo: keyboardSurfaceView.trailingAnchor),
            panel.topAnchor.constraint(equalTo: candidateBar.topAnchor),
            panel.bottomAnchor.constraint(equalTo: rootStack.bottomAnchor),
        ])
        candidateExpandedPanel = panel
        rootStack.isUserInteractionEnabled = false
        guard !UIAccessibility.isReduceMotionEnabled else {
            rootStack.isHidden = true
            return
        }
        panel.alpha = 0
        panel.transform = CGAffineTransform(translationX: 0, y: 8)
        UIView.animate(withDuration: 0.18, delay: 0, options: [.curveEaseOut, .beginFromCurrentState]) {
            panel.alpha = 1
            panel.transform = .identity
            self.rootStack.isHidden = true
        }
    }

    func dismissExpandedCandidatePanel(animated: Bool) {
        guard let panel = candidateExpandedPanel else {
            rootStack.isHidden = false
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
            rootStack.isHidden = false
            completion(true)
            return
        }
        UIView.animate(withDuration: 0.16, delay: 0, options: [.curveEaseIn, .beginFromCurrentState]) {
            panel.alpha = 0
            panel.transform = CGAffineTransform(translationX: 0, y: 6)
            self.rootStack.isHidden = false
        } completion: { finished in
            completion(finished)
        }
    }

    func makeExpandedCandidatePanel(with precomputedItems: [CandidateItem]? = nil) -> UIView {
        let container = ExpandedCandidatePanelContainerView()
        container.backgroundColor = .clear
        container.clipsToBounds = false
        let candidates = precomputedItems ?? candidateItems()
        let collapseButtonWidth = KeyboardDesignTokens.CandidateBar.actionZoneWidth
        let collapseButtonHeight = KeyboardDesignTokens.CandidateBar.totalHeight
        let layout = LeftAlignedCandidateFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        // 真实 cell 连续铺满；2pt 视觉内缩由 CandidateCollectionCell 负责。
        layout.sectionInset = UIEdgeInsets(top: 3, left: 8, bottom: 6, right: 8)
        layout.firstRowTrailingReservedWidth = collapseButtonWidth + 8
        let collectionView = CandidateCollectionView(frame: .zero, collectionViewLayout: layout)
        CandidateScrollViewStyle.apply(to: collectionView)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.delaysContentTouches = false
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
            systemName: "chevron.up",
            withConfiguration: UIImage.SymbolConfiguration(
                pointSize: KeyboardDesignTokens.CandidateBar.actionSymbolSize, weight: .medium))
        config.baseForegroundColor = .label
        let collapseButton = ExpandedCandidateCollapseButton(configuration: config, primaryAction: nil)
        collapseButton.translatesAutoresizingMaskIntoConstraints = false
        // 与横向展开按钮一致：极低 alpha 的 backing 不改变视觉，但能稳定承接操作区触摸。
        collapseButton.backgroundColor = UIColor.systemGray.withAlphaComponent(0.001)
        collapseButton.addTarget(self, action: #selector(toggleCandidateExpand), for: .touchUpInside)
        collapseButton.accessibilityLabel = "收起候选面板"
        collapseButton.accessibilityHint = "双击以返回键盘"
        container.addSubview(collapseButton)
        container.collapseButton = collapseButton
        container.bringSubviewToFront(collapseButton)
        NSLayoutConstraint.activate([
            collapseButton.topAnchor.constraint(equalTo: container.topAnchor, constant: 0),
            collapseButton.trailingAnchor.constraint(
                equalTo: container.trailingAnchor, constant: 0),
            collapseButton.widthAnchor.constraint(equalToConstant: collapseButtonWidth),
            collapseButton.heightAnchor.constraint(equalToConstant: collapseButtonHeight),
            collectionView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: container.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: container.bottomAnchor),
        ])
        #if DEBUG
            Logger.shared.info(
                "expandedPanel: \(candidates.count) candidates in incremental collection", category: .display)
        #endif
        return container
    }

    func refreshExpandedPanel() {
        guard isCandidateExpanded, let collectionView = expandedCandidateCollectionView else { return }
        collectionView.reloadData()
        collectionView.alwaysBounceVertical = hasMoreCandidates
    }

    func appendToExpandedCandidatePanel(insertedCount: Int? = nil) {
        guard isCandidateExpanded, let collectionView = expandedCandidateCollectionView else { return }
        guard let insertedCount, insertedCount > 0 else {
            refreshExpandedPanel()
            return
        }

        let currentCount = collectionView.numberOfItems(inSection: 0)
        let visibleCount = presentedCandidates.count
        let expectedOldCount = max(0, visibleCount - insertedCount)
        guard currentCount == expectedOldCount else {
            refreshExpandedPanel()
            return
        }

        let indexPaths = (expectedOldCount..<(expectedOldCount + insertedCount)).map {
            IndexPath(item: $0, section: 0)
        }
        let currentOffset = collectionView.contentOffset
        let generation = candidateSnapshotGeneration
        UIView.performWithoutAnimation {
            collectionView.performBatchUpdates {
                collectionView.insertItems(at: indexPaths)
            } completion: { _ in
                guard self.candidateSnapshotGeneration == generation,
                    collectionView === self.expandedCandidateCollectionView
                else { return }
                let maxOffset = max(0, collectionView.contentSize.height - collectionView.bounds.height)
                collectionView.contentOffset.y = min(currentOffset.y, maxOffset)
                collectionView.alwaysBounceVertical = self.hasMoreCandidates
            }
        }
    }

    func commitExpandedCandidate(_ item: CandidateItem) {
        guard !controller.isCompositionInputRecoveryPending else { return }
        if let origin = item.selectionReference?.candidateOrigin {
            guard controller.state.lastRimeOutput?.candidateOrigin == origin else { return }
        }
        emitFeedback(for: .commit)
        let effects: KeyboardEffect
        if let correction = item.correction {
            effects = controller.handle(.insertCorrectionCandidate(correction))
        } else {
            effects = controller.handle(
                .insertCandidate(
                    item.title,
                    kind: item.kind,
                    selectionReference: item.selectionReference
                )
            )
        }
        isCandidateExpanded = false
        candidatePrefetchMode = .bar
        deferredCandidatePrefetchMode = nil
        candidatePrefetchRequestSerial += 1
        updateExpandButtonAppearance()
        dismissExpandedCandidatePanel(animated: true)
        syncUI(with: effects)
    }
}
