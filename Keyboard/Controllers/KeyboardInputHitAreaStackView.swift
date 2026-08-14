import KeyboardCore
import UIKit

/// Root stack for the key area.
///
/// Hit testing is done in each key's own bounds: expand `button.bounds` by
/// half of the parent stack spacing (the same midline rule as 26-key). That
/// never consults a converted column-tall frame, so JKL cannot collapse onto ABC.
final class KeyboardInputHitAreaStackView: UIStackView {
    #if DEBUG
        private var showsRealTouchRangeOverlay = false
    #endif

    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = true
    }

    required init(coder: NSCoder) {
        super.init(coder: coder)
        isUserInteractionEnabled = true
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        refreshKeyTouchOutsets()
        #if DEBUG
            refreshKeyTouchOverlays()
        #endif
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard isUserInteractionEnabled, !isHidden, alpha > 0.01,
            self.point(inside: point, with: event)
        else {
            return nil
        }

        if let key = keyContainingTouch(at: point) {
            return key
        }
        return super.hitTest(point, with: event)
    }

    /// Point is converted into each key. The winner is the local touch box that
    /// contains it — visual face or midline slop, same test.
    private func keyContainingTouch(at pointInSelf: CGPoint) -> KeyboardKeyButton? {
        let keys = allKeyboardKeys()
        var best: (button: KeyboardKeyButton, area: CGFloat, distance: CGFloat)?
        for button in keys {
            let point = button.convert(pointInSelf, from: self)
            let insets = touchInsets(for: button)
            let box = KeyTouchCellLayout.localTouchBounds(
                visualBounds: button.bounds,
                insets: insets
            )
            guard box.contains(point) else { continue }
            let area = box.width * box.height
            let distance = Self.distance(from: point, to: button.bounds)
            if let current = best {
                if distance < current.distance - 0.5 {
                    best = (button, area, distance)
                } else if abs(distance - current.distance) <= 0.5, area < current.area {
                    best = (button, area, distance)
                }
            } else {
                best = (button, area, distance)
            }
        }
        return best?.button
    }

    private func touchInsets(
        for button: KeyboardKeyButton
    ) -> (top: CGFloat, left: CGFloat, bottom: CGFloat, right: CGFloat) {
        guard let parent = button.superview as? UIStackView else {
            return (4, 4, 4, 4)
        }

        if parent.axis == .horizontal {
            let peers = parent.arrangedSubviews.compactMap { $0 as? KeyboardKeyButton }
                .sorted { $0.frame.minX < $1.frame.minX }
            let index = peers.firstIndex(where: { $0 === button })
            let isFirst = index == peers.startIndex
            let isLast = index == peers.indices.last
            let leadingGap: CGFloat
            let trailingGap: CGFloat
            if index != nil {
                leadingGap =
                    isFirst
                    ? max(0, button.frame.minX - parent.bounds.minX)
                    : parent.spacing
                trailingGap =
                    isLast
                    ? max(0, parent.bounds.maxX - button.frame.maxX)
                    : parent.spacing
            } else {
                leadingGap = parent.spacing
                trailingGap = parent.spacing
            }

            var topGap: CGFloat = 0
            var bottomGap: CGFloat = 0
            if let column = parent.superview as? UIStackView, column.axis == .vertical {
                let keyRows = column.arrangedSubviews.filter { row in
                    !row.isHidden && containsKeyboardKey(row)
                }
                if let rowIndex = keyRows.firstIndex(of: parent) {
                    if rowIndex > keyRows.startIndex {
                        topGap = spacing(
                            after: keyRows[keyRows.index(before: rowIndex)],
                            in: column
                        )
                    }
                    if rowIndex < keyRows.index(before: keyRows.endIndex) {
                        bottomGap = spacing(after: parent, in: column)
                    }
                }
            }
            return KeyTouchCellLayout.localTouchInsets(
                leadingGap: leadingGap,
                trailingGap: trailingGap,
                topGap: topGap,
                bottomGap: bottomGap,
                isFirstInRow: isFirst,
                isLastInRow: isLast
            )
        }

        let peers = parent.arrangedSubviews.compactMap { $0 as? KeyboardKeyButton }
            .sorted { $0.frame.minY < $1.frame.minY }
        let index = peers.firstIndex(where: { $0 === button })
        let isFirst = index == peers.startIndex
        let isLast = index == peers.indices.last
        var topGap: CGFloat = 0
        var bottomGap: CGFloat = 0
        if let index {
            if !isFirst {
                topGap = spacing(after: peers[peers.index(before: index)], in: parent)
            }
            if !isLast {
                bottomGap = spacing(after: button, in: parent)
            }
        }
        return KeyTouchCellLayout.localTouchInsets(
            leadingGap: max(0, button.frame.minX - parent.bounds.minX),
            trailingGap: max(0, parent.bounds.maxX - button.frame.maxX),
            topGap: topGap,
            bottomGap: bottomGap,
            isFirstInRow: true,
            isLastInRow: true
        )
    }

    private func spacing(after view: UIView, in stack: UIStackView) -> CGFloat {
        let custom = stack.customSpacing(after: view)
        if custom == UIStackView.spacingUseDefault {
            return stack.spacing
        }
        return custom
    }

    private func refreshKeyTouchOutsets() {
        for button in allKeyboardKeys() {
            let insets = touchInsets(for: button)
            button.expandedTouchOutsets = UIEdgeInsets(
                top: insets.top,
                left: insets.left,
                bottom: insets.bottom,
                right: insets.right
            )
        }
    }

    private func containsKeyboardKey(_ view: UIView) -> Bool {
        if view is KeyboardKeyButton { return true }
        if let stack = view as? UIStackView {
            return stack.arrangedSubviews.contains(where: containsKeyboardKey)
        }
        return view.subviews.contains(where: containsKeyboardKey)
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
            if let button = subview as? KeyboardKeyButton,
                button.isUserInteractionEnabled,
                !button.isHidden,
                button.alpha > 0.01
            {
                result.append(button)
                continue
            }
            collectKeyboardKeys(in: subview, into: &result)
        }
    }

    private static func distance(from point: CGPoint, to rect: CGRect) -> CGFloat {
        if rect.contains(point) { return 0 }
        let dx = max(rect.minX - point.x, 0, point.x - rect.maxX)
        let dy = max(rect.minY - point.y, 0, point.y - rect.maxY)
        return hypot(dx, dy)
    }

    #if DEBUG
        func setShowsRealTouchRangeOverlay(_ shows: Bool) {
            showsRealTouchRangeOverlay = shows
            if window != nil {
                refreshKeyTouchOverlays()
            } else {
                setNeedsLayout()
            }
        }

        private func refreshKeyTouchOverlays() {
            viewWithTag(Self.touchRangeOverlayHostTag)?.removeFromSuperview()
            superview?.viewWithTag(Self.touchRangeOverlayHostTag)?.removeFromSuperview()
            for button in allKeyboardKeys() {
                let insets = touchInsets(for: button)
                let touch = KeyTouchCellLayout.localTouchBounds(
                    visualBounds: button.bounds,
                    insets: insets
                )
                button.applyDebugHitboxOverlay(
                    showing: showsRealTouchRangeOverlay,
                    touchFrameInButton: touch
                )
            }
        }

        private static let touchRangeOverlayHostTag = 8_260_014
    #endif
}
