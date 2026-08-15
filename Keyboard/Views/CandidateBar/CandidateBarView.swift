import KeyboardCore
import UIKit

/// 展开按钮视觉上只显示 chevron，但真实命中范围略大。
/// iOS Keyboard Extension 中完全透明的区域可能不稳定，保留不可见 backing 来承接点击和下滑。
private final class CandidateBarExpandButton: UIButton {
    var hitOutsets = UIEdgeInsets(top: 10, left: 16, bottom: 12, right: 12)

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

#if DEBUG
    @MainActor
    protocol CandidateTouchDiagnosticSink: AnyObject {
        func recordCandidateTouchRouted(
            band: DiagnosticEvent.CandidateTouchBand,
            didHitCell: Bool
        )
        func recordCandidateGestureTerminal(didBegin: Bool, wasCancelled: Bool)
    }
#endif

/// The horizontal candidate bar container.
///
/// The fixed height and expand-button width are part of the keyboard presentation
/// baseline: changing them can reintroduce keyboard resize/flicker regressions.
/// Isolated from `CandidateBarView`'s `@MainActor` so optional delegate
/// methods actually bind. Putting them on the bar only "nearly matches".
private final class CandidateBarGestureBridge: NSObject, UIGestureRecognizerDelegate {
    weak var itemTap: UIGestureRecognizer?
    weak var swipeDown: UIGestureRecognizer?
    weak var horizontalFallback: UIGestureRecognizer?
    weak var collectionPan: UIGestureRecognizer?

    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        if gestureRecognizer === itemTap || otherGestureRecognizer === itemTap {
            return true
        }
        if gestureRecognizer === horizontalFallback || otherGestureRecognizer === horizontalFallback {
            return false
        }
        guard gestureRecognizer === swipeDown || otherGestureRecognizer === swipeDown else {
            return false
        }
        return gestureRecognizer === collectionPan || otherGestureRecognizer === collectionPan
    }

    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        if gestureRecognizer === itemTap,
            otherGestureRecognizer === swipeDown || otherGestureRecognizer === horizontalFallback
        {
            return false
        }
        return false
    }
}

@MainActor
final class CandidateBarView: UIView {
    private enum Layout {
        /// Keeps candidate text visually settled in the thinner bar.
        static let verticalTextInset: CGFloat = 0
        /// Hit area is intentionally larger than the visible chevron for reliable touch.
        static let expandButtonTouchSize: CGFloat = 56
        static let expandButtonVerticalAlignmentOffset: CGFloat = 9
    }

    let collectionView: CandidateCollectionView
    let expandButton: UIButton
    let expandButtonWidthConstraint: NSLayoutConstraint
    private weak var expandActionTarget: NSObject?
    private let expandAction: Selector
    private let itemTapRecognizer = UITapGestureRecognizer()
    private let gestureBridge = CandidateBarGestureBridge()
    private let candidateBarHeight: CGFloat
    private let bottomHitExtension: CGFloat
    private var swipeDownRecognizer: UIPanGestureRecognizer?
    private var horizontalFallbackRecognizer: UIPanGestureRecognizer?
    private var hasTriggeredSwipeDownExpand = false
    private var isSwipeDownTracking = false
    private var swipePreviewIndexPath: IndexPath?
    private var horizontalFallbackStartOffsetX: CGFloat = 0
    private var lastPointInsideDiagnosticLogTime: CFTimeInterval = 0
    private var lastHitTestDiagnosticLogTime: CFTimeInterval = 0
    private var lastFallbackPanDiagnosticLogTime: CFTimeInterval = 0
    #if DEBUG
        /// Passive observation only. The callback runs after UIKit has resolved the
        /// same hit view that would have been returned without diagnostics.
        private weak var diagnosticSink: CandidateTouchDiagnosticSink?
        private weak var lastStructuredTouch: UITouch?
        private var expandHitboxOverlay: DebugKeyTouchRangeOverlayView?
        private var hitProbeLabel: UILabel?
    #endif

    init(
        height: CGFloat,
        bottomHitExtension: CGFloat,
        backgroundColor: UIColor,
        interactionTarget: Any?,
        expandAction: Selector
    ) {
        self.expandActionTarget = interactionTarget as? NSObject
        self.expandAction = expandAction
        self.candidateBarHeight = height
        self.bottomHitExtension = bottomHitExtension

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        // 候选之间不能留下真实 layout 空隙，否则手势会从 scroll view 的非 cell 区域启动。
        // 视觉间距由 cell 自身宽度承担，保证横滑和下滑都能命中候选列表。
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: Layout.verticalTextInset, left: 4, bottom: 0, right: 8)

        collectionView = CandidateCollectionView(frame: .zero, collectionViewLayout: layout)
        expandButton = Self.makeExpandButton(target: interactionTarget, action: expandAction)
        expandButtonWidthConstraint = expandButton.widthAnchor.constraint(equalToConstant: Layout.expandButtonTouchSize)

        super.init(frame: .zero)

        #if DEBUG
            diagnosticSink = interactionTarget as? CandidateTouchDiagnosticSink
            collectionView.onCandidateGestureTerminal = { [weak self] didBegin, wasCancelled in
                self?.diagnosticSink?.recordCandidateGestureTerminal(
                    didBegin: didBegin,
                    wasCancelled: wasCancelled
                )
            }
        #endif

        self.backgroundColor = backgroundColor
        isOpaque = false
        layer.cornerRadius = 0
        clipsToBounds = false

        configureCollectionView()
        addSubview(collectionView)
        addSubview(expandButton)
        gestureBridge.collectionPan = collectionView.panGestureRecognizer
        installItemTapGesture()
        installHorizontalFallbackGesture()
        installSwipeDownExpandGesture()

        NSLayoutConstraint.activate([
            expandButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -3),
            expandButton.centerYAnchor.constraint(
                equalTo: topAnchor,
                constant: height / 2 + Layout.expandButtonVerticalAlignmentOffset
            ),
            expandButtonWidthConstraint,
            expandButton.heightAnchor.constraint(equalToConstant: Layout.expandButtonTouchSize),

            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 2),
            collectionView.trailingAnchor.constraint(equalTo: expandButton.leadingAnchor, constant: -2),
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),

            heightAnchor.constraint(equalToConstant: height + bottomHitExtension),
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// True while a downward expand pan is recognized. Callers should skip
    /// `didSelect` so a swipe-to-expand does not also commit the cell.
    var shouldSuppressCandidateSelection: Bool {
        isSwipeDownTracking || hasTriggeredSwipeDownExpand
    }

    /// Direct tap delivery. UICollectionView's own selection tap waits for the
    /// bar's expand pan to fail and never fires for a stationary press.
    var onItemTap: ((IndexPath) -> Void)?

    override func layoutSubviews() {
        super.layoutSubviews()
        #if DEBUG
            refreshDebugHitboxOverlay()
        #endif
    }

    #if DEBUG
        func refreshDebugHitboxOverlay() {
            for case let cell as CandidateCollectionCell in collectionView.visibleCells {
                cell.refreshDebugHitboxOverlay()
            }
            guard DebugHitboxOverlayPresentation.isShowing else {
                expandHitboxOverlay?.isHidden = true
                hitProbeLabel?.isHidden = true
                return
            }
            if !expandButton.isHidden {
                let overlay = expandHitboxOverlay ?? DebugKeyTouchRangeOverlayView()
                if expandHitboxOverlay == nil {
                    addSubview(overlay)
                    expandHitboxOverlay = overlay
                }
                overlay.isHidden = false
                overlay.apply(
                    touchFrame: expandedButtonHitFrame,
                    visualFrame: expandButton.frame,
                    in: self
                )
                bringSubviewToFront(overlay)
            } else {
                expandHitboxOverlay?.isHidden = true
            }
            DebugHitboxOverlayPresentation.refreshProbeLabel = { [weak self] in
                self?.refreshHitProbeLabel(text: DebugHitboxOverlayPresentation.probeLine)
            }
            refreshHitProbeLabel(text: DebugHitboxOverlayPresentation.probeLine)
        }

        private func recordHitProbe(point: CGPoint, hitView: UIView?) {
            guard DebugHitboxOverlayPresentation.isShowing else { return }
            let collectionPoint = collectionView.convert(point, from: self)
            let index = collectionView.indexPathForItem(at: collectionPoint)
            let cell = index.flatMap { collectionView.cellForItem(at: $0) as? CandidateCollectionCell }
            let contentHeight = cell.map { Int($0.contentView.bounds.height) } ?? -1
            let cellHeight = cell.map { Int($0.bounds.height) } ?? -1
            let hitName = CandidateTouchDiagnostics.viewPath(hitView)
            let indexText = index.map { String($0.item) } ?? "nil"
            let inCell: String
            if let cell, let hitView {
                inCell = (hitView === cell || hitView.isDescendant(of: cell)) ? "inCell" : "chrome"
            } else {
                inCell = "noCell"
            }
            refreshHitProbeLabel(
                text:
                    "\(hitName) idx=\(indexText) \(inCell) cellH=\(cellHeight) contentH=\(contentHeight) y=\(Int(point.y))"
            )
        }

        private func refreshHitProbeLabel(text: String?) {
            guard DebugHitboxOverlayPresentation.isShowing else {
                hitProbeLabel?.isHidden = true
                return
            }
            let label = hitProbeLabel ?? UILabel()
            if hitProbeLabel == nil {
                label.font = .monospacedDigitSystemFont(ofSize: 8, weight: .medium)
                label.textColor = .systemYellow
                label.backgroundColor = UIColor.black.withAlphaComponent(0.72)
                label.numberOfLines = 2
                label.adjustsFontSizeToFitWidth = true
                label.minimumScaleFactor = 0.5
                label.isUserInteractionEnabled = false
                addSubview(label)
                hitProbeLabel = label
            }
            label.isHidden = false
            label.text = text ?? DebugHitboxOverlayPresentation.probeLine
            let width = min(bounds.width - 8, max(160, bounds.width - 8))
            label.frame = CGRect(x: 4, y: max(2, bounds.height - 30), width: width, height: 28)
            bringSubviewToFront(label)
        }
    #endif

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let result =
            bounds.contains(point)
            || (!expandButton.isHidden && expandedButtonHitFrame.contains(point))
        logTouch(
            "bar pointInside",
            point: point,
            lastLogTime: &lastPointInsideDiagnosticLogTime,
            extra: "inside=\(result)"
        )
        return result
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let superHit = super.hitTest(point, with: event)
        let result: UIView?
        let collectionPoint = collectionView.convert(point, from: self)
        let hitsCandidateItem =
            collectionView.frame.contains(point)
            && collectionView.indexPathForItem(at: collectionPoint) != nil
        if !hitsCandidateItem, !expandButton.isHidden, expandedButtonHitFrame.contains(point) {
            let buttonPoint = expandButton.convert(point, from: self)
            result = expandButton.hitTest(buttonPoint, with: event) ?? expandButton
        } else if bounds.contains(point), collectionView.frame.contains(point) {
            result = collectionView.hitTest(collectionPoint, with: event) ?? collectionView
        } else if bounds.contains(point) {
            result = self
        } else {
            result = nil
        }
        logTouch(
            "bar hitTest",
            point: point,
            lastLogTime: &lastHitTestDiagnosticLogTime,
            extra: "super=\(CandidateTouchDiagnostics.viewName(superHit)) "
                + "hit=\(CandidateTouchDiagnostics.viewName(result)) "
                + "collectionFrame=\(rectDescription(collectionView.frame)) "
                + "pan=\(CandidateTouchDiagnostics.gestureStateName(collectionView.panGestureRecognizer.state))"
        )
        #if DEBUG
            recordStructuredTouchIfNeeded(point: point, hitView: result, event: event)
            recordHitProbe(point: point, hitView: result)
        #endif
        return result
    }

    #if DEBUG
        private func recordStructuredTouchIfNeeded(point: CGPoint, hitView: UIView?, event: UIEvent?) {
            // Physical keyboard extensions may enter hit-testing before UIKit
            // exposes `.began`. Identity still deduplicates repeated hit-test
            // passes for the same single-finger operation.
            guard let touches = event?.allTouches,
                touches.count == 1,
                let touch = touches.first,
                touch.type == .direct
            else { return }
            guard touch !== lastStructuredTouch else { return }
            lastStructuredTouch = touch

            let band = DiagnosticEvent.CandidateTouchBand.classify(
                y: Double(point.y),
                height: Double(candidateBarHeight)
            )
            diagnosticSink?.recordCandidateTouchRouted(
                band: band,
                didHitCell: Self.hasCandidateCellAncestor(hitView)
            )
        }

        private static func hasCandidateCellAncestor(_ view: UIView?) -> Bool {
            var current = view
            while let candidate = current {
                if candidate is CandidateCollectionCell { return true }
                current = candidate.superview
            }
            return false
        }
    #endif

    private var expandedButtonHitFrame: CGRect {
        guard let button = expandButton as? CandidateBarExpandButton else { return expandButton.frame }
        let outsets = button.hitOutsets
        return ChromeTouchHitGeometry.candidateExpandButtonHitFrame(
            buttonFrame: button.frame,
            topOutset: outsets.top,
            leftOutset: outsets.left,
            bottomOutset: outsets.bottom,
            rightOutset: outsets.right,
            barBounds: bounds
        )
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

    private func rectDescription(_ rect: CGRect) -> String {
        "(\(Int(rect.minX)),\(Int(rect.minY)),\(Int(rect.width)),\(Int(rect.height)))"
    }

    private func configureCollectionView() {
        CandidateScrollViewStyle.apply(to: collectionView)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.bounces = true
        collectionView.alwaysBounceHorizontal = false
        collectionView.decelerationRate = .normal
        collectionView.delaysContentTouches = false
        collectionView.canCancelContentTouches = true
        collectionView.clipsToBounds = false
        collectionView.panGestureRecognizer.addTarget(self, action: #selector(handleCandidatePan(_:)))
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(
            CandidateCollectionCell.self,
            forCellWithReuseIdentifier: CandidateCollectionCell.barReuseIdentifier
        )
    }

    @objc private func handleCandidatePan(_ recognizer: UIPanGestureRecognizer) {
        guard recognizer.state == .began, collectionView.isDecelerating else { return }
        collectionView.setContentOffset(collectionView.contentOffset, animated: false)
    }

    private func installItemTapGesture() {
        itemTapRecognizer.addTarget(self, action: #selector(handleItemTap(_:)))
        itemTapRecognizer.cancelsTouchesInView = false
        itemTapRecognizer.delegate = gestureBridge
        gestureBridge.itemTap = itemTapRecognizer
        collectionView.addGestureRecognizer(itemTapRecognizer)
    }

    @objc private func handleItemTap(_ recognizer: UITapGestureRecognizer) {
        guard recognizer.state == .ended, !shouldSuppressCandidateSelection else { return }
        let point = recognizer.location(in: collectionView)
        guard let indexPath = collectionView.indexPathForItem(at: point) else { return }
        onItemTap?(indexPath)
    }

    private func installHorizontalFallbackGesture() {
        let recognizer = UIPanGestureRecognizer(target: self, action: #selector(handleHorizontalFallbackPan(_:)))
        recognizer.cancelsTouchesInView = true
        recognizer.delegate = gestureBridge
        horizontalFallbackRecognizer = recognizer
        gestureBridge.horizontalFallback = recognizer
        addGestureRecognizer(recognizer)
    }

    @objc private func handleHorizontalFallbackPan(_ recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            if collectionView.isDecelerating {
                collectionView.setContentOffset(collectionView.contentOffset, animated: false)
            }
            horizontalFallbackStartOffsetX = collectionView.contentOffset.x
            logHorizontalFallbackPan(recognizer, phase: "began")
        case .changed:
            let translation = recognizer.translation(in: self)
            let proposedX = horizontalFallbackStartOffsetX - translation.x
            collectionView.contentOffset.x = clampedHorizontalOffset(proposedX)
            logHorizontalFallbackPan(recognizer, phase: "changed")
        case .ended, .cancelled, .failed:
            logHorizontalFallbackPan(recognizer, phase: "ended")
            horizontalFallbackStartOffsetX = collectionView.contentOffset.x
        default:
            break
        }
    }

    private func clampedHorizontalOffset(_ proposedX: CGFloat) -> CGFloat {
        let maxOffset = max(0, collectionView.contentSize.width - collectionView.bounds.width)
        return min(max(0, proposedX), maxOffset)
    }

    private func logHorizontalFallbackPan(_ recognizer: UIPanGestureRecognizer, phase: String) {
        guard CandidateTouchDiagnostics.isEnabled else { return }
        let now = CACurrentMediaTime()
        guard
            phase != "changed" || now - lastFallbackPanDiagnosticLogTime >= CandidateTouchDiagnostics.minimumLogInterval
        else { return }
        lastFallbackPanDiagnosticLogTime = now
        let point = recognizer.location(in: self)
        let translation = recognizer.translation(in: self)
        let velocity = recognizer.velocity(in: self)
        Logger.shared.debug(
            "candidateTouch bar horizontalFallback \(phase) "
                + "point=\(CandidateTouchDiagnostics.pointDescription(point)) "
                + "translation=\(CandidateTouchDiagnostics.pointDescription(translation)) "
                + "velocity=\(CandidateTouchDiagnostics.pointDescription(velocity)) "
                + "offset=\(Int(collectionView.contentOffset.x))",
            category: .display
        )
    }

    private func installSwipeDownExpandGesture() {
        let recognizer = UIPanGestureRecognizer(target: self, action: #selector(handleSwipeDownExpand(_:)))
        // Do not cancel cell taps. A downward micro-movement used to begin this
        // pan, kill `didSelect`, and then fail the expand threshold.
        recognizer.cancelsTouchesInView = false
        recognizer.delegate = gestureBridge
        swipeDownRecognizer = recognizer
        gestureBridge.swipeDown = recognizer
        addGestureRecognizer(recognizer)
    }

    @objc private func handleSwipeDownExpand(_ recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            if collectionView.isDecelerating {
                collectionView.setContentOffset(collectionView.contentOffset, animated: false)
            }
            isSwipeDownTracking = true
            hasTriggeredSwipeDownExpand = false
            updateSwipePreviewHighlight(for: recognizer)
        case .changed:
            updateSwipePreviewHighlight(for: recognizer)
            triggerExpandIfSwipeDownThresholdPassed(recognizer)
        default:
            clearSwipePreviewHighlight()
            isSwipeDownTracking = false
            hasTriggeredSwipeDownExpand = false
        }
    }

    private func triggerExpandIfSwipeDownThresholdPassed(_ recognizer: UIPanGestureRecognizer) {
        guard !hasTriggeredSwipeDownExpand, !expandButton.isHidden else { return }
        let translation = recognizer.translation(in: self)
        let velocity = recognizer.velocity(in: self)
        let isIntentionalDownSwipe =
            translation.y > 18
            && velocity.y > 180
            && abs(translation.y) > abs(translation.x) * 1.2
        guard isIntentionalDownSwipe else { return }
        hasTriggeredSwipeDownExpand = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) { [weak self] in
            self?.clearSwipePreviewHighlight()
        }
        expandActionTarget?.perform(expandAction)
    }

    private func updateSwipePreviewHighlight(for recognizer: UIPanGestureRecognizer) {
        let point = recognizer.location(in: collectionView)
        setSwipePreviewIndexPath(collectionView.indexPathForItem(at: point))
    }

    private func setSwipePreviewIndexPath(_ indexPath: IndexPath?) {
        guard swipePreviewIndexPath != indexPath else { return }
        clearSwipePreviewHighlight()
        swipePreviewIndexPath = indexPath
        guard let indexPath,
            let cell = collectionView.cellForItem(at: indexPath) as? CandidateCollectionCell
        else { return }
        cell.setSwipePreviewHighlighted(true)
    }

    private func clearSwipePreviewHighlight() {
        guard let indexPath = swipePreviewIndexPath else { return }
        if let cell = collectionView.cellForItem(at: indexPath) as? CandidateCollectionCell {
            cell.setSwipePreviewHighlighted(false)
        }
        swipePreviewIndexPath = nil
    }

    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let pan = gestureRecognizer as? UIPanGestureRecognizer else { return true }
        let velocity = pan.velocity(in: self)
        if pan === swipeDownRecognizer {
            guard !expandButton.isHidden else { return false }
            return velocity.y > 0 && abs(velocity.y) > abs(velocity.x) * 1.15
        }
        if pan === horizontalFallbackRecognizer {
            guard collectionView.contentSize.width > collectionView.bounds.width else {
                logHorizontalFallbackDecision(pan, allowed: false, reason: "contentNotScrollable")
                return false
            }
            guard abs(velocity.x) > abs(velocity.y) * 1.1 else {
                logHorizontalFallbackDecision(pan, allowed: false, reason: "notHorizontal")
                return false
            }
            let point = pan.location(in: self)
            guard !expandedButtonHitFrame.contains(point) else {
                logHorizontalFallbackDecision(pan, allowed: false, reason: "expandButton")
                return false
            }
            let allowed = shouldStartHorizontalFallback(at: point)
            logHorizontalFallbackDecision(pan, allowed: allowed, reason: allowed ? "barBlank" : "cellOwnsPoint")
            return allowed
        }
        return true
    }

    private func shouldStartHorizontalFallback(at point: CGPoint) -> Bool {
        guard collectionView.frame.contains(point) else {
            return bounds.contains(point)
        }
        let collectionPoint = collectionView.convert(point, from: self)
        return collectionView.indexPathForItem(at: collectionPoint) == nil
    }

    private func logHorizontalFallbackDecision(
        _ recognizer: UIPanGestureRecognizer,
        allowed: Bool,
        reason: String
    ) {
        guard CandidateTouchDiagnostics.isEnabled else { return }
        let point = recognizer.location(in: self)
        let collectionPoint = collectionView.convert(point, from: self)
        let indexPath = collectionView.indexPathForItem(at: collectionPoint)
        Logger.shared.debug(
            "candidateTouch bar horizontalFallback shouldBegin allowed=\(allowed) "
                + "reason=\(reason) point=\(CandidateTouchDiagnostics.pointDescription(point)) "
                + "collectionPoint=\(CandidateTouchDiagnostics.pointDescription(collectionPoint)) "
                + "index=\(indexPath.map { String($0.item) } ?? "nil")",
            category: .display
        )
    }

    private static func makeExpandButton(target: Any?, action: Selector) -> UIButton {
        var config = UIButton.Configuration.plain()
        config.contentInsets = .zero
        config.image = UIImage(
            systemName: "chevron.down",
            withConfiguration: UIImage.SymbolConfiguration(pointSize: 12, weight: .medium)
        )
        config.baseForegroundColor = .secondaryLabel

        let button = CandidateBarExpandButton(configuration: config, primaryAction: nil)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.systemGray.withAlphaComponent(0.001)
        button.addTarget(target, action: action, for: .touchUpInside)
        button.accessibilityLabel = "展开更多候选词"
        button.accessibilityHint = "双击以查看完整候选列表"
        return button
    }
}
