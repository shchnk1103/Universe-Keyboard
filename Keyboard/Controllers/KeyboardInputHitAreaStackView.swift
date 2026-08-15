import KeyboardCore
import UIKit

/// A persistent, invisible UIControl for the part of one touch cell that lies
/// outside the visible key. The real button remains responsible for rendering,
/// accessibility, targets and gestures on its face; this control only forwards
/// gap taps through that same button's existing target-action wiring.
private final class KeyboardTouchCellControl: UIControl {
    weak var sourceButton: KeyboardKeyButton?
    private var visualFrameInBounds = CGRect.zero
    private var didLeaveTouchCell = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        // Keyboard extensions have historically dropped touches on fully clear
        // gap surfaces. Match the candidate-bar precedent: this backing is
        // visually imperceptible but remains a stable UIKit event surface.
        backgroundColor = UIColor.systemGray.withAlphaComponent(0.001)
        isOpaque = false
        isAccessibilityElement = false
        isExclusiveTouch = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(sourceButton: KeyboardKeyButton, visualFrameInCanvas: CGRect) {
        self.sourceButton = sourceButton
        visualFrameInBounds = convert(visualFrameInCanvas, from: superview)
    }

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        guard let sourceButton,
            sourceButton.isEnabled,
            sourceButton.isUserInteractionEnabled,
            !sourceButton.isHidden,
            sourceButton.alpha > 0.01
        else {
            return false
        }

        // The visible face must keep its native UIButton path so long press,
        // cursor movement and other gestures remain unchanged.
        return bounds.contains(point) && !visualFrameInBounds.contains(point)
    }

    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        guard super.beginTracking(touch, with: event), let sourceButton else {
            return false
        }
        didLeaveTouchCell = false
        sourceButton.sendActions(for: .touchDown)
        #if DEBUG
            sourceButton.trackingEventHandler?(sourceButton, .began)
        #endif
        return true
    }

    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        guard let sourceButton else { return false }
        let remainsInside = bounds.contains(touch.location(in: self))
        if !remainsInside, !didLeaveTouchCell {
            didLeaveTouchCell = true
            sourceButton.sendActions(for: .touchDragExit)
        }
        return super.continueTracking(touch, with: event)
    }

    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        if let sourceButton {
            let endedInside =
                !didLeaveTouchCell
                && touch.map { bounds.contains($0.location(in: self)) } == true
            sourceButton.sendActions(for: endedInside ? .touchUpInside : .touchUpOutside)
            #if DEBUG
                sourceButton.trackingEventHandler?(
                    sourceButton,
                    endedInside ? .endedInside : .endedOutside
                )
            #endif
        }
        super.endTracking(touch, with: event)
    }

    override func cancelTracking(with event: UIEvent?) {
        if let sourceButton {
            sourceButton.sendActions(for: .touchCancel)
            #if DEBUG
                sourceButton.trackingEventHandler?(sourceButton, .cancelled)
            #endif
        }
        super.cancelTracking(with: event)
    }
}

/// Sibling of the visual stack that owns only gap interaction. Returning nil
/// over a visible key lets UIKit continue to the original UIButton underneath.
private final class KeyboardTouchRoutingCanvas: UIView {
    private var controls: [KeyboardTouchCellControl] = []

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        isOpaque = false
        isAccessibilityElement = false
        accessibilityElementsHidden = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func render(items: [(button: KeyboardKeyButton, touch: CGRect, visual: CGRect)]) {
        while controls.count < items.count {
            let control = KeyboardTouchCellControl()
            addSubview(control)
            controls.append(control)
        }
        while controls.count > items.count {
            controls.removeLast().removeFromSuperview()
        }

        for (control, item) in zip(controls, items) {
            control.frame = item.touch
            control.configure(
                sourceButton: item.button,
                visualFrameInCanvas: item.visual
            )
        }
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard isUserInteractionEnabled, !isHidden, alpha > 0.01 else { return nil }
        for control in controls.reversed() {
            let localPoint = control.convert(point, from: self)
            if let hit = control.hitTest(localPoint, with: event) {
                return hit
            }
        }
        // Never make the transparent canvas itself a hit target.
        return nil
    }
}

/// Root stack for the key area.
///
/// Visual keys intentionally leave breathing room. Their touch cells do not:
/// neighboring gaps are divided at the midpoint so fast typing can use the
/// complete key region. Hit testing, UIControl tracking, and the Debug overlay
/// all consume the same immutable snapshot.
final class KeyboardInputHitAreaStackView: UIStackView {
    private var keyTouchSnapshot: [(button: KeyboardKeyButton, cell: KeyTouchCell)] = []
    private var snapshotPath = "flat"
    private weak var touchRoutingCanvas: KeyboardTouchRoutingCanvas?

    #if DEBUG
        private var showsRealTouchRangeOverlay = false
        private var lastTouchProbeDigest = ""
    #endif

    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = true
    }

    required init(coder: NSCoder) {
        super.init(coder: coder)
        isUserInteractionEnabled = true
    }

    /// Rebuilds geometry after the view controller reports that every nested
    /// stack has completed layout. Calling this from the root stack's own
    /// `layoutSubviews` is too early for the deeper nine-key hierarchy.
    func refreshKeyTouchGeometry() {
        let keys = allKeyboardKeys()
        guard !keys.isEmpty else {
            invalidateKeyTouchGeometry()
            return
        }

        let identified: [KeyTouchIdentifiedCell]
        if let host = firstNineKeyHost(in: self), !host.isHidden {
            guard let structured = makeNineKeyCells(host: host, keys: keys) else {
                rejectInvalidSnapshot(currentKeys: keys, path: "t9")
                return
            }
            identified = structured
            snapshotPath = "t9"
        } else {
            let visuals = keys.enumerated().map { index, button in
                KeyTouchIdentifiedVisual(
                    id: index,
                    frame: button.convert(button.bounds, to: self)
                )
            }
            guard visuals.allSatisfy({ isValidFrame($0.frame) }) else {
                rejectInvalidSnapshot(currentKeys: keys, path: "flat")
                return
            }
            identified = KeyTouchCellLayout.makeIdentifiedCells(
                visuals: visuals,
                containerBounds: bounds
            )
            snapshotPath = "flat"
        }

        guard identified.count == keys.count,
            identified.allSatisfy({ isValidCell($0.cell) })
        else {
            rejectInvalidSnapshot(currentKeys: keys, path: snapshotPath)
            return
        }

        let buttonsByID = Dictionary(
            uniqueKeysWithValues: keys.enumerated().map { ($0.offset, $0.element) }
        )
        let snapshot = identified.compactMap { item -> (KeyboardKeyButton, KeyTouchCell)? in
            guard let button = buttonsByID[item.id] else { return nil }
            return (button, item.cell)
        }
        guard snapshot.count == keys.count else {
            rejectInvalidSnapshot(currentKeys: keys, path: snapshotPath)
            return
        }

        keyTouchSnapshot = snapshot
        applySnapshotToButtons(currentKeys: keys)
        refreshTouchRoutingCanvas()
        #if DEBUG
            emitTouchProbeIfNeeded()
            refreshKeyTouchOverlays()
        #endif
    }

    /// Clears references before a keyboard page replaces its buttons.
    func invalidateKeyTouchGeometry() {
        for item in keyTouchSnapshot {
            item.button.expandedTouchOutsets = .zero
            item.button.localTouchBounds = nil
        }
        keyTouchSnapshot = []
        touchRoutingCanvas?.removeFromSuperview()
        #if DEBUG
            emitTouchProbeIfNeeded()
            refreshKeyTouchOverlays()
        #endif
    }

    private func makeNineKeyCells(
        host: T9NineKeyChromeHost,
        keys: [KeyboardKeyButton]
    ) -> [KeyTouchIdentifiedCell]? {
        guard !host.touchColumns.isEmpty else { return nil }
        let idByButton = Dictionary(
            uniqueKeysWithValues: keys.enumerated().map {
                (ObjectIdentifier($0.element), $0.offset)
            }
        )

        let columns = host.touchColumns.compactMap {
            column -> (bounds: CGRect, rows: [[KeyTouchIdentifiedVisual]])? in
            let columnBounds = column.container.convert(column.container.bounds, to: self)
            guard isValidFrame(columnBounds) else { return nil }

            let rows = column.rows.compactMap { row -> [KeyTouchIdentifiedVisual]? in
                let visuals = row.compactMap { button -> KeyTouchIdentifiedVisual? in
                    guard isHitEligible(button),
                        let id = idByButton[ObjectIdentifier(button)]
                    else {
                        return nil
                    }
                    let frame = button.convert(button.bounds, to: self)
                    guard isValidFrame(frame) else { return nil }
                    return KeyTouchIdentifiedVisual(id: id, frame: frame)
                }
                return visuals.isEmpty ? nil : visuals
            }
            return rows.isEmpty ? nil : (bounds: columnBounds, rows: rows)
        }
        guard columns.count == host.touchColumns.count else { return nil }
        return KeyTouchCellLayout.makeIdentifiedStructuredCells(columns: columns)
    }

    /// A failed refresh may be a transient UIKit pass. Preserve a snapshot only
    /// when it still references exactly the current buttons; never publish an
    /// empty/partial snapshot that silently shrinks touch targets to key faces.
    private func rejectInvalidSnapshot(
        currentKeys: [KeyboardKeyButton],
        path: String
    ) {
        let currentIDs = Set(currentKeys.map(ObjectIdentifier.init))
        let snapshotIDs = Set(keyTouchSnapshot.map { ObjectIdentifier($0.button) })
        if currentIDs != snapshotIDs {
            invalidateKeyTouchGeometry()
        }
        #if DEBUG
            let line = "TOUCHPROBE path=\(path) rejected=1 k=\(keyTouchSnapshot.count)"
            DebugHitboxOverlayPresentation.publishProbeLine(line)
            Logger.shared.debug(line, category: .display)
        #endif
    }

    private func applySnapshotToButtons(currentKeys: [KeyboardKeyButton]) {
        var seen = Set<ObjectIdentifier>()
        for item in keyTouchSnapshot {
            seen.insert(ObjectIdentifier(item.button))
            let touchInButton = item.button.convert(item.cell.touchFrame, from: self)
            let insets = KeyTouchCellLayout.insets(
                visualBounds: item.button.bounds,
                touchBounds: touchInButton
            )
            item.button.expandedTouchOutsets = UIEdgeInsets(
                top: insets.top,
                left: insets.left,
                bottom: insets.bottom,
                right: insets.right
            )
            item.button.localTouchBounds = touchInButton
        }
        for button in currentKeys where !seen.contains(ObjectIdentifier(button)) {
            button.expandedTouchOutsets = .zero
            button.localTouchBounds = nil
        }
    }

    /// Keeps the event-receiving surface independent from Debug paint. The
    /// canvas is recreated only with keyboard pages, never with overlay state.
    private func refreshTouchRoutingCanvas() {
        guard let surface = superview else { return }
        let canvas: KeyboardTouchRoutingCanvas
        if let touchRoutingCanvas {
            canvas = touchRoutingCanvas
        } else {
            canvas = KeyboardTouchRoutingCanvas()
            surface.insertSubview(canvas, aboveSubview: self)
            touchRoutingCanvas = canvas
        }

        canvas.frame = convert(bounds, to: surface)
        canvas.render(
            items: keyTouchSnapshot.map { item in
                (
                    button: item.button,
                    touch: canvas.convert(item.cell.touchFrame, from: self),
                    visual: canvas.convert(item.cell.visualFrame, from: self)
                )
            }
        )
    }

    private func firstNineKeyHost(in view: UIView) -> T9NineKeyChromeHost? {
        if let host = view as? T9NineKeyChromeHost {
            return host
        }
        for subview in view.subviews {
            if let host = firstNineKeyHost(in: subview) {
                return host
            }
        }
        return nil
    }

    private func allKeyboardKeys() -> [KeyboardKeyButton] {
        var result: [KeyboardKeyButton] = []
        collectKeyboardKeys(in: self, into: &result)
        return result
    }

    private func collectKeyboardKeys(
        in view: UIView,
        into result: inout [KeyboardKeyButton]
    ) {
        for subview in view.subviews {
            if let button = subview as? KeyboardKeyButton, isHitEligible(button) {
                result.append(button)
                continue
            }
            collectKeyboardKeys(in: subview, into: &result)
        }
    }

    private func isHitEligible(_ button: KeyboardKeyButton) -> Bool {
        button.isUserInteractionEnabled && !button.isHidden && button.alpha > 0.01
    }

    private func isValidFrame(_ frame: CGRect) -> Bool {
        !frame.isNull && !frame.isInfinite && frame.width > 0 && frame.height > 0
            && frame.minX.isFinite && frame.minY.isFinite
            && frame.maxX.isFinite && frame.maxY.isFinite
    }

    private func isValidCell(_ cell: KeyTouchCell) -> Bool {
        isValidFrame(cell.visualFrame) && isValidFrame(cell.touchFrame)
    }

    #if DEBUG
        func setShowsRealTouchRangeOverlay(_ shows: Bool) {
            showsRealTouchRangeOverlay = shows
            emitTouchProbeIfNeeded()
            refreshKeyTouchOverlays()
        }

        private func refreshKeyTouchOverlays() {
            guard let surface = superview else { return }
            if !showsRealTouchRangeOverlay {
                surface.viewWithTag(Self.touchRangeOverlayHostTag)?.removeFromSuperview()
                return
            }

            let canvas: DebugKeyTouchRangeOverlayCanvas
            if let existing = surface.viewWithTag(Self.touchRangeOverlayHostTag)
                as? DebugKeyTouchRangeOverlayCanvas
            {
                canvas = existing
            } else {
                canvas = DebugKeyTouchRangeOverlayCanvas()
                canvas.tag = Self.touchRangeOverlayHostTag
                surface.addSubview(canvas)
            }
            canvas.frame = convert(bounds, to: surface)
            canvas.render(
                items: keyTouchSnapshot.map { item in
                    (
                        touch: canvas.convert(item.cell.touchFrame, from: self),
                        visual: canvas.convert(item.cell.visualFrame, from: self)
                    )
                }
            )
            canvas.setProbeDigest(lastTouchProbeDigest)
            surface.bringSubviewToFront(canvas)
        }

        private func emitTouchProbeIfNeeded() {
            let cells = keyTouchSnapshot.map(\.cell)
            let faceSized = cells.filter { cell in
                abs(cell.touchFrame.width - cell.visualFrame.width) <= 6
                    && abs(cell.touchFrame.height - cell.visualFrame.height) <= 6
            }.count
            let maxVisualHeight = cells.map(\.visualFrame.height).max() ?? 0
            let maxTouchHeight = cells.map(\.touchFrame.height).max() ?? 0
            let digest =
                "TOUCHPROBE path=\(snapshotPath) ov=\(showsRealTouchRangeOverlay ? 1 : 0) "
                + "k=\(cells.count) face=\(faceSized) fill=\(cells.count - faceSized) "
                + "maxVH=\(Int(maxVisualHeight.rounded())) maxTH=\(Int(maxTouchHeight.rounded()))"
            guard digest != lastTouchProbeDigest else { return }
            lastTouchProbeDigest = digest
            DebugHitboxOverlayPresentation.publishProbeLine(digest)
            Logger.shared.debug(digest, category: .display)
        }

        private static let touchRangeOverlayHostTag = 8_260_014
    #endif
}
