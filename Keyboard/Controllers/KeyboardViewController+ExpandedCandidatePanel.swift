import KeyboardCore
import UIKit

/// Flow layout 默认会把同一行的 item 间距拉大到填满宽度。
/// 候选展开面板需要像文字流一样从左到右紧凑排列，所以这里固定为左对齐。
private final class LeftAlignedCandidateFlowLayout: UICollectionViewFlowLayout {
    /// 只为与操作区垂直相交的顶部行预留尾部，不能让所有行空出一整列。
    var firstRowTrailingReservedWidth: CGFloat = 0
    var reservedActionBottom: CGFloat = KeyboardDesignTokens.CandidateBar.totalHeight

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
                var rowMaxX = nextY < reservedActionBottom ? firstRowMaxX : fullRowMaxX
                if nextX > sectionInset.left, nextX + originalSize.width > rowMaxX {
                    nextX = sectionInset.left
                    nextY += rowHeight + minimumLineSpacing
                    rowHeight = 0
                    rowMaxX = nextY < reservedActionBottom ? firstRowMaxX : fullRowMaxX
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
    fileprivate var actionTopConstraint: NSLayoutConstraint?
    let revealViewport = UIView()
    weak var collectionView: UICollectionView?
    var readingPosition: CandidateReadingPosition?
    private(set) var isTransitioning = false
    private var revealedHeight: CGFloat?
    private var revealToken = UUID()
    private weak var coveredRoot: UIStackView?
    private var lastCoveredGeometry: CGRect?
    private var previousRootMask: CALayer?
    private let coveredMask = CAShapeLayer()
    private let actionMaterial = UIVisualEffectView(effect: nil)
    private let actionFill = UIView()
    private var actionFallbackColor: UIColor = .secondarySystemBackground
    private var coveredAccessibilityViews: [(UIView, Bool)] = []

    fileprivate func hideCoveredAccessibility(in root: UIStackView, keeping pathBar: UIView?) {
        coveredRoot = root
        previousRootMask = root.layer.mask
        coveredAccessibilityViews = root.arrangedSubviews.filter { $0 !== pathBar }.map {
            let previous = $0.accessibilityElementsHidden
            $0.accessibilityElementsHidden = true
            return ($0, previous)
        }
    }

    fileprivate func restoreCoveredAccessibility() {
        revealToken = UUID()
        isTransitioning = false
        revealViewport.layer.removeAllAnimations()
        coveredMask.removeAllAnimations()
        if coveredRoot?.layer.mask === coveredMask { coveredRoot?.layer.mask = previousRootMask }
        coveredRoot = nil
        previousRootMask = nil
        for (view, previous) in coveredAccessibilityViews { view.accessibilityElementsHidden = previous }
        coveredAccessibilityViews = []
    }
    private var lastHitTestDiagnosticLogTime: CFTimeInterval = 0
    #if DEBUG
        private var collapseHitboxOverlay: DebugKeyTouchRangeOverlayView?
    #endif

    override init(frame: CGRect) {
        super.init(frame: frame)
        revealViewport.clipsToBounds = true
        addSubview(revealViewport)
        NotificationCenter.default.addObserver(
            self, selector: #selector(refreshActionMaterial),
            name: UIAccessibility.reduceTransparencyStatusDidChangeNotification, object: nil)
    }

    override func willMove(toSuperview newSuperview: UIView?) {
        if newSuperview == nil { restoreCoveredAccessibility() }
        super.willMove(toSuperview: newSuperview)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        revealViewport.frame = CGRect(
            x: 0, y: 0, width: bounds.width, height: min(bounds.height, revealedHeight ?? bounds.height))
        synchronizeCoveredGeometry()
        #if DEBUG
            refreshDebugHitboxOverlay()
        #endif
    }

    #if DEBUG
        func refreshDebugHitboxOverlay() {
            for case let cell as CandidateCollectionCell
                in (collectionView?.visibleCells ?? [])
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
        if isTransitioning { return bounds.contains(point) ? self : nil }
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

    func actionFrame(in view: UIView) -> CGRect {
        guard let button = collapseButton else { return .null }
        return button.convert(button.bounds, to: view)
    }

    func recordUserScroll() { readingPosition?.userScrolled = true }

    @objc private func observeReadingDrag(_ pan: UIPanGestureRecognizer) {
        if pan.state == .began { recordUserScroll() }
    }

    fileprivate func observeUserScroll(in collection: UICollectionView) {
        collection.panGestureRecognizer.addTarget(self, action: #selector(observeReadingDrag(_:)))
    }

    fileprivate func installActionMaterial(fallbackColor: UIColor) {
        actionFallbackColor = fallbackColor
        guard let button = collapseButton else { return }
        let appearance = KeyboardDesignTokens.CandidateActionAppearance.self
        let insets = appearance.controlBackgroundInsets
        actionMaterial.layer.cornerRadius = appearance.controlCornerRadius
        actionMaterial.layer.cornerCurve = .continuous
        actionMaterial.clipsToBounds = true
        actionMaterial.translatesAutoresizingMaskIntoConstraints = false
        actionMaterial.isUserInteractionEnabled = false
        actionMaterial.accessibilityIdentifier = "expandedCandidateActionMaterial"
        insertSubview(actionMaterial, belowSubview: button)
        actionFill.translatesAutoresizingMaskIntoConstraints = false
        actionFill.isUserInteractionEnabled = false
        actionMaterial.contentView.addSubview(actionFill)
        NSLayoutConstraint.activate([
            actionMaterial.leadingAnchor.constraint(equalTo: button.leadingAnchor, constant: insets.left),
            actionMaterial.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: -insets.right),
            actionMaterial.topAnchor.constraint(equalTo: button.topAnchor, constant: insets.top),
            actionMaterial.bottomAnchor.constraint(equalTo: button.bottomAnchor, constant: -insets.bottom),
            actionFill.leadingAnchor.constraint(equalTo: actionMaterial.contentView.leadingAnchor),
            actionFill.trailingAnchor.constraint(equalTo: actionMaterial.contentView.trailingAnchor),
            actionFill.topAnchor.constraint(equalTo: actionMaterial.contentView.topAnchor),
            actionFill.bottomAnchor.constraint(equalTo: actionMaterial.contentView.bottomAnchor),
        ])
        refreshActionMaterial()
    }

    @objc private func refreshActionMaterial() {
        updateActionMaterial(reduceTransparency: UIAccessibility.isReduceTransparencyEnabled)
    }

    func updateActionMaterial(reduceTransparency: Bool) {
        actionMaterial.effect =
            reduceTransparency ? nil : UIBlurEffect(style: KeyboardDesignTokens.CandidateActionAppearance.materialStyle)
        actionFill.backgroundColor = actionFallbackColor.withAlphaComponent(
            reduceTransparency ? 1 : KeyboardDesignTokens.CandidateActionAppearance.tintOpacity)
    }

    /// Reveal candidates and cover keys using the same curve; neither root height nor cell frames animate.
    /// The mask belongs only to the content stack; its material-bearing compact bar is hidden throughout.
    /// The panel can move without resizing when the T9 row expands. Its own
    /// layout callback is insufficient; the Controller also calls this after root layout.
    func synchronizeCoveredGeometry() {
        guard let root = coveredRoot else { return }
        let geometry = convert(bounds, to: root)
        let changed = lastCoveredGeometry != geometry || coveredMask.frame != root.bounds
        guard !isTransitioning || changed else { return }
        if changed {
            // A path interpolated in the old root coordinates must not cover the new T9 row.
            coveredMask.removeAnimation(forKey: "candidate.reveal")
        }
        lastCoveredGeometry = geometry
        updateCoveredMask()
    }

    private func updateCoveredMask() {
        guard let root = coveredRoot else { return }
        let path = UIBezierPath()
        let top = convert(.zero, to: root).y
        if top > 0 { path.append(UIBezierPath(rect: CGRect(x: 0, y: 0, width: root.bounds.width, height: top))) }
        let bottomStart = top + min(bounds.height, revealedHeight ?? bounds.height)
        if bottomStart < root.bounds.height {
            path.append(
                UIBezierPath(
                    rect: CGRect(
                        x: 0, y: bottomStart, width: root.bounds.width, height: root.bounds.height - bottomStart)))
        } else {
            // Keep a degenerate bottom rectangle so interpolation has the same path structure.
            path.append(UIBezierPath(rect: CGRect(x: 0, y: root.bounds.height, width: root.bounds.width, height: 0)))
        }
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        coveredMask.frame = root.bounds
        coveredMask.path = path.cgPath
        root.layer.mask = coveredMask
        CATransaction.commit()
    }

    func setRevealedHeight(_ height: CGFloat) {
        revealedHeight = height
        revealViewport.frame = CGRect(x: 0, y: 0, width: bounds.width, height: min(bounds.height, height))
        updateCoveredMask()
    }

    func animateReveal(to height: CGFloat, duration: TimeInterval, completion: @escaping () -> Void) {
        let duration = UIAccessibility.isReduceMotionEnabled || !UIView.areAnimationsEnabled ? 0 : duration
        guard duration > 0 else { setRevealedHeight(height); completion(); return }
        #if DEBUG
            let qa001Animation = T9QA001DeviceTrace.shared.panelStart(self)
        #endif
        let token = UUID()
        revealToken = token
        isTransitioning = true
        collectionView?.isUserInteractionEnabled = false
        collapseButton?.isEnabled = false
        let previous = coveredMask.presentation()?.path ?? coveredMask.path
        UIView.animate(withDuration: duration, delay: 0, options: [.curveEaseOut, .beginFromCurrentState]) {
            self.setRevealedHeight(height)
        } completion: { [weak self] _ in
            #if DEBUG
                if let self {
                    T9QA001DeviceTrace.shared.panel(
                        self, stage: .panelEnd, tokenMatches: self.revealToken == token, origin: qa001Animation)
                }
            #endif
            guard let self, self.revealToken == token else { return }
            self.isTransitioning = false
            self.synchronizeCoveredGeometry()
            self.collectionView?.isUserInteractionEnabled = true
            self.collapseButton?.isEnabled = true
            if height >= self.bounds.height { self.revealedHeight = nil }
            completion()
            #if DEBUG
                T9QA001DeviceTrace.shared.panel(self, stage: .panelStable, origin: qa001Animation)
            #endif
        }
        let animation = CABasicAnimation(keyPath: "path")
        animation.fromValue = previous
        animation.toValue = coveredMask.path
        animation.duration = duration
        animation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        coveredMask.add(animation, forKey: "candidate.reveal")
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
        button.tintColor = KeyboardDesignTokens.CandidateActionAppearance.symbolColor
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
        (candidateExpandedPanel as? ExpandedCandidatePanelContainerView)?.restoreCoveredAccessibility()
        candidateExpandedPanel?.removeFromSuperview()
        candidateCollectionView?.layoutIfNeeded()
        let reading = CandidateReadingPosition(
            snapshot: currentCandidateReadingSnapshot,
            anchor: candidateCollectionView.flatMap {
                CandidateReadingAnchor.capture(in: $0, items: presentedCandidates, horizontal: true)
            },
            compactOffset: candidateCollectionView?.contentOffset ?? .zero)
        let panel = makeExpandedCandidatePanel()
        (panel as? ExpandedCandidatePanelContainerView)?.readingPosition = reading
        panel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(panel)
        NSLayoutConstraint.activate([
            panel.leadingAnchor.constraint(equalTo: keyboardSurfaceView.leadingAnchor),
            panel.trailingAnchor.constraint(equalTo: keyboardSurfaceView.trailingAnchor),
            panel.topAnchor.constraint(equalTo: candidateBar.topAnchor),
            panel.bottomAnchor.constraint(equalTo: rootStack.bottomAnchor),
        ])
        if let container = panel as? ExpandedCandidatePanelContainerView, let button = container.collapseButton {
            container.actionTopConstraint?.isActive = false
            container.actionTopConstraint = button.topAnchor.constraint(equalTo: candidateBar.topAnchor)
            container.actionTopConstraint?.isActive = true
            // Root stays visible for the path row; covered keys must remain absent from VoiceOver.
            container.hideCoveredAccessibility(in: rootStack, keeping: t9PinyinPathBarView)
        }
        candidateExpandedPanel = panel
        // The opaque panel covers the keys. Keep the real T9 path bar above it visible and
        // interactive; hiding the entire root would turn its fixed row into an empty strip.
        candidateBar.isHidden = true
        view.layoutIfNeeded()
        guard let container = panel as? ExpandedCandidatePanelContainerView,
            let collection = expandedCandidateCollectionView
        else { return }
        collection.layoutIfNeeded()
        if let anchor = reading.entryAnchor, anchor.isValid(in: presentedCandidates),
            let attributes = collection.layoutAttributesForItem(at: IndexPath(item: anchor.index, section: 0))
        {
            let action = container.actionFrame(in: collection)
            let sharesActionColumn = attributes.frame.maxX > action.minX
            let topPadding =
                sharesActionColumn
                ? KeyboardDesignTokens.CandidateBar.totalHeight
                : KeyboardDesignTokens.ExpandedCandidates.contentInsets.top
            let maxY = max(0, collection.contentSize.height - collection.bounds.height)
            collection.setContentOffset(
                CGPoint(x: 0, y: min(maxY, max(0, attributes.frame.minY - topPadding))), animated: false)
        }
        container.setRevealedHeight(KeyboardDesignTokens.CandidateBar.totalHeight)
        container.animateReveal(
            to: panel.bounds.height, duration: KeyboardDesignTokens.ExpandedCandidates.expandDuration
        ) {}
    }

    func dismissExpandedCandidatePanel(animated: Bool) {
        guard let panel = candidateExpandedPanel as? ExpandedCandidatePanelContainerView else {
            candidateBar?.isHidden = false
            expandedPanelScrollView = nil
            expandedCandidateCollectionView = nil
            return
        }
        restoreCompactReadingPosition(from: panel)
        let completion = { [weak self, weak panel] in
            guard let self, let panel, self.candidateExpandedPanel === panel else { return }
            panel.restoreCoveredAccessibility()
            panel.removeFromSuperview()
            self.candidateExpandedPanel = nil
            self.expandedPanelScrollView = nil
            self.expandedCandidateCollectionView = nil
            self.candidateBar?.isHidden = false
        }
        if animated {
            panel.animateReveal(
                to: KeyboardDesignTokens.CandidateBar.totalHeight,
                duration: KeyboardDesignTokens.ExpandedCandidates.collapseDuration, completion: completion)
        } else {
            completion()
        }
    }

    func makeExpandedCandidatePanel(with precomputedItems: [CandidateItem]? = nil) -> UIView {
        let container = ExpandedCandidatePanelContainerView()
        // Share the actual underlying keyboard surface. Covered keys are removed by the reveal mask,
        // so transparency does not expose key plates or introduce a second RGB background.
        container.backgroundColor = .clear
        // Clip only this overlay. Root input/keyboard-bottom touch geometry stays untouched.
        container.layer.cornerRadius = keyboardSurfaceMaskCornerRadius
        container.layer.cornerCurve = .continuous
        container.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        container.clipsToBounds = true
        let candidates = precomputedItems ?? candidateItems()
        let collapseButtonWidth = KeyboardDesignTokens.CandidateBar.actionZoneWidth
        let collapseButtonHeight = KeyboardDesignTokens.CandidateBar.totalHeight
        let layout = LeftAlignedCandidateFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = KeyboardDesignTokens.ExpandedCandidates.itemSpacing
        layout.minimumInteritemSpacing = KeyboardDesignTokens.ExpandedCandidates.itemSpacing
        // 真实 cell 连续铺满；2pt 视觉内缩由 CandidateCollectionCell 负责。
        layout.sectionInset = KeyboardDesignTokens.ExpandedCandidates.contentInsets
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
        container.revealViewport.addSubview(collectionView)
        container.collectionView = collectionView
        container.observeUserScroll(in: collectionView)

        // Use the exact compact symbol and unconfigured button rendering path. A half-turn
        // preserves its glyph bounds instead of relying on differently scaled up/down symbols.
        let collapseButton = ExpandedCandidateCollapseButton(type: .custom)
        collapseButton.setImage(CandidateBarView.trailingChromeImage(expanding: true), for: .normal)
        collapseButton.imageView?.transform = CGAffineTransform(rotationAngle: .pi)
        collapseButton.tintColor = KeyboardDesignTokens.CandidateActionAppearance.symbolColor
        collapseButton.translatesAutoresizingMaskIntoConstraints = false
        // 与横向展开按钮一致：极低 alpha 的 backing 不改变视觉，但能稳定承接操作区触摸。
        collapseButton.backgroundColor = UIColor.systemGray.withAlphaComponent(0.001)
        collapseButton.addTarget(self, action: #selector(toggleCandidateExpand), for: .touchUpInside)
        collapseButton.accessibilityLabel = "收起候选面板"
        collapseButton.accessibilityHint = "双击以返回键盘"
        container.addSubview(collapseButton)
        container.collapseButton = collapseButton
        container.installActionMaterial(fallbackColor: keyboardSurfaceMaterialTintColor)
        container.bringSubviewToFront(collapseButton)
        let actionTop = collapseButton.topAnchor.constraint(equalTo: container.topAnchor)
        container.actionTopConstraint = actionTop
        NSLayoutConstraint.activate([
            actionTop,
            collapseButton.trailingAnchor.constraint(
                equalTo: container.trailingAnchor, constant: 0),
            collapseButton.widthAnchor.constraint(equalToConstant: collapseButtonWidth),
            collapseButton.heightAnchor.constraint(equalToConstant: collapseButtonHeight),
            collectionView.leadingAnchor.constraint(equalTo: container.revealViewport.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: container.revealViewport.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: container.revealViewport.topAnchor),
            collectionView.heightAnchor.constraint(equalTo: container.heightAnchor),
        ])
        #if DEBUG
            Logger.shared.info(
                "expandedPanel: \(candidates.count) candidates in incremental collection", category: .display)
        #endif
        return container
    }

    func refreshExpandedPanel() {
        guard isCandidateExpanded, let collectionView = expandedCandidateCollectionView else { return }
        let position = (candidateExpandedPanel as? ExpandedCandidatePanelContainerView)?.readingPosition
        let snapshotChanged = position?.snapshot != currentCandidateReadingSnapshot
        if snapshotChanged { position?.reset(to: currentCandidateReadingSnapshot) }
        collectionView.reloadData()
        if snapshotChanged { collectionView.setContentOffset(.zero, animated: false) }
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
        guard !isKeyboardHeightAdjusting else { return }
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
