import UIKit

/// Root stack view for the keyboard input area.
///
/// Visual key gaps are intentionally preserved by the row `UIStackView` spacing.
/// Hit testing, however, behaves like the candidate bar fix: the invisible touch
/// cells are continuous and split the gaps at the midpoint between neighboring keys.
final class KeyboardInputHitAreaStackView: UIStackView {
    private typealias KeyFrame = (button: KeyboardKeyButton, frame: CGRect)
    private typealias KeyTouchCell = (button: KeyboardKeyButton, touchFrame: CGRect)

    private var touchCellBackingViews: [UIView] = []
    private var cachedKeyTouchCells: [KeyTouchCell] = []
    private var cachedKeyRegionMinY = CGFloat.greatestFiniteMagnitude
    private var hasValidKeyTouchCellSnapshot = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureTouchBacking()
    }

    required init(coder: NSCoder) {
        super.init(coder: coder)
        configureTouchBacking()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        rebuildKeyTouchCellSnapshot()
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard isUserInteractionEnabled, !isHidden, alpha > 0.01,
            self.point(inside: point, with: event)
        else {
            return nil
        }

        // UIKit normally lays out the hierarchy before dispatching touches. Keep a
        // one-time fallback for unusual early hit tests without recomputing the key
        // tree on every touch event.
        if !hasValidKeyTouchCellSnapshot {
            rebuildKeyTouchCellSnapshot()
        }

        let defaultHit = super.hitTest(point, with: event)
        if let key = defaultHit as? KeyboardKeyButton,
            key.convert(key.bounds, to: self).contains(point)
        {
            return key
        }

        // Candidate bar owns its own bottom hit extension. Do not let key hit testing
        // steal the candidate-to-key gap or any candidate-bar gesture.
        guard point.y >= cachedKeyRegionMinY else {
            return defaultHit
        }

        return cachedKeyTouchCells.first { $0.touchFrame.contains(point) }?.button ?? defaultHit
    }

    private func configureTouchBacking() {
        isUserInteractionEnabled = true
    }

    private func updateTouchCellBackingViews(using touchCells: [KeyTouchCell]) {
        while touchCellBackingViews.count < touchCells.count {
            let view = UIView()
            view.isUserInteractionEnabled = false
            addSubview(view)
            touchCellBackingViews.append(view)
        }

        for index in touchCellBackingViews.indices {
            let cellView = touchCellBackingViews[index]
            if index < touchCells.count {
                cellView.isHidden = false
                cellView.frame = touchCells[index].touchFrame
                applyBackingStyle(to: cellView)
                bringSubviewToFront(cellView)
            } else {
                cellView.isHidden = true
                cellView.frame = .zero
                cellView.layer.borderWidth = 0
                cellView.layer.borderColor = nil
            }
        }
    }

    private func applyBackingStyle(to view: UIView) {
        // 和候选栏 cell 的修复保持一致：在 iOS Keyboard Extension 中，
        // 完全透明的间隙有时不会稳定进入 hit-test 链路。保留极低 alpha
        // backing 作为连续触控表面，但不改变视觉效果。
        view.backgroundColor = UIColor.systemGray.withAlphaComponent(0.001)
        view.layer.borderWidth = 0
        view.layer.borderColor = nil
    }

    private func updateKeyTouchOutsets(using touchCells: [KeyTouchCell]) {
        for cell in touchCells {
            let frame = cell.button.convert(cell.button.bounds, to: self)
            cell.button.expandedTouchOutsets = UIEdgeInsets(
                top: max(0, frame.minY - cell.touchFrame.minY),
                left: max(0, frame.minX - cell.touchFrame.minX),
                bottom: max(0, cell.touchFrame.maxY - frame.maxY),
                right: max(0, cell.touchFrame.maxX - frame.maxX)
            )
        }
    }

    /// Rebuilds all layout-derived touch geometry once, then lets hit testing use
    /// the immutable snapshot until UIKit performs the next layout pass.
    private func rebuildKeyTouchCellSnapshot() {
        let touchCells = keyTouchCells()
        cachedKeyTouchCells = touchCells
        cachedKeyRegionMinY = touchCells.map(\.touchFrame.minY).min() ?? .greatestFiniteMagnitude
        hasValidKeyTouchCellSnapshot = true

        updateKeyTouchOutsets(using: touchCells)
        updateTouchCellBackingViews(using: touchCells)
    }

    private func keyTouchCells() -> [KeyTouchCell] {
        let rows = keyRows()
        guard !rows.isEmpty else { return [] }

        var cells: [KeyTouchCell] = []
        for rowIndex in rows.indices {
            let row = rows[rowIndex]
            let rowMinY = row.map(\.frame.minY).min() ?? bounds.minY
            let rowMaxY = row.map(\.frame.maxY).max() ?? rowMinY
            let top: CGFloat
            if rowIndex == rows.startIndex {
                top = rowMinY
            } else {
                let previousMaxY = rows[rowIndex - 1].map(\.frame.maxY).max() ?? rowMinY
                top = (previousMaxY + rowMinY) / 2
            }

            let bottom: CGFloat
            if rowIndex == rows.index(before: rows.endIndex) {
                bottom = rowMaxY
            } else {
                let nextMinY = rows[rowIndex + 1].map(\.frame.minY).min() ?? rowMaxY
                bottom = (rowMaxY + nextMinY) / 2
            }

            for keyIndex in row.indices {
                let key = row[keyIndex]
                let left: CGFloat
                if keyIndex == row.startIndex {
                    left = bounds.minX
                } else {
                    let previous = row[keyIndex - 1]
                    left = (previous.frame.maxX + key.frame.minX) / 2
                }

                let right: CGFloat
                if keyIndex == row.index(before: row.endIndex) {
                    right = bounds.maxX
                } else {
                    let next = row[keyIndex + 1]
                    right = (key.frame.maxX + next.frame.minX) / 2
                }

                let touchFrame = CGRect(
                    x: left,
                    y: top,
                    width: max(0, right - left),
                    height: max(0, bottom - top)
                )
                cells.append((button: key.button, touchFrame: touchFrame))
            }
        }
        return cells
    }

    private func keyRows() -> [[KeyFrame]] {
        let sortedKeys = keyboardKeyFrames()
            .sorted {
                if abs($0.frame.midY - $1.frame.midY) > 1 {
                    return $0.frame.midY < $1.frame.midY
                }
                return $0.frame.minX < $1.frame.minX
            }

        var rows: [[KeyFrame]] = []
        for key in sortedKeys {
            if let lastRow = rows.indices.last,
                let rowMidY = averageMidY(for: rows[lastRow]),
                abs(key.frame.midY - rowMidY) <= max(8, key.frame.height * 0.5)
            {
                rows[lastRow].append(key)
            } else {
                rows.append([key])
            }
        }

        return rows.map { row in
            row.sorted { $0.frame.minX < $1.frame.minX }
        }
    }

    private func averageMidY(for row: [KeyFrame]) -> CGFloat? {
        guard !row.isEmpty else { return nil }
        return row.reduce(CGFloat(0)) { $0 + $1.frame.midY } / CGFloat(row.count)
    }

    private func keyboardKeyFrames() -> [KeyFrame] {
        var result: [KeyFrame] = []
        collectKeyboardKeys(in: self, into: &result)
        return result
    }

    private func collectKeyboardKeys(
        in view: UIView,
        into result: inout [KeyFrame]
    ) {
        for subview in view.subviews {
            if let button = subview as? KeyboardKeyButton,
                button.isUserInteractionEnabled,
                !button.isHidden,
                button.alpha > 0.01
            {
                result.append((button: button, frame: button.convert(button.bounds, to: self)))
                continue
            }
            collectKeyboardKeys(in: subview, into: &result)
        }
    }
}
