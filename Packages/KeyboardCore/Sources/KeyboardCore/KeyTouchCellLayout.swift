import CoreGraphics
import Foundation

/// One key's visual bounds plus the touch cell that `KeyboardInputHitAreaStackView`
/// uses for hit testing. Overlay drawing must copy `touchFrame` from this snapshot.
public struct KeyTouchCell: Equatable, Sendable {
    public let visualFrame: CGRect
    public let touchFrame: CGRect

    public init(visualFrame: CGRect, touchFrame: CGRect) {
        self.visualFrame = visualFrame
        self.touchFrame = touchFrame
    }
}

/// One column of already-grouped rows in a shared coordinate space.
/// Nine-key uses a left pad column and a right function column so a lone
/// return key cannot expand to the full keyboard width.
public struct KeyTouchLayoutColumn: Equatable, Sendable {
    public let bounds: CGRect
    public let rows: [[CGRect]]

    public init(bounds: CGRect, rows: [[CGRect]]) {
        self.bounds = bounds
        self.rows = rows
    }
}

/// Shared key-touch layout for 26-key and nine-key.
///
/// One rule: split every visual gap at the neighboring midline so touch cells
/// fill the container. 26-key discovers rows by midY; nine-key passes columns
/// that already know their rows. Overlay and `hitTest` must reuse this snapshot.
public enum KeyTouchCellLayout {
    /// 26-key: group frames by midY, then fill midpoints inside `containerBounds`.
    public static func makeCells(
        visualFrames: [CGRect],
        containerBounds: CGRect
    ) -> [KeyTouchCell] {
        makeCells(rows: groupedRows(from: visualFrames), containerBounds: containerBounds)
    }

    /// Nine-key: each column is filled independently so return stays in the
    /// right column and DEF cannot inherit MNO / WXYZ / space gutters.
    public static func makeStructuredCells(columns: [KeyTouchLayoutColumn]) -> [KeyTouchCell] {
        columns.flatMap { column in
            makeCells(rows: column.rows, containerBounds: column.bounds)
        }
    }

    /// Fills `containerBounds` by splitting sibling gaps at their midlines.
    /// First / last row keep their visual top / bottom so the candidate bar
    /// keeps the strip above the keys.
    public static func makeCells(
        rows: [[CGRect]],
        containerBounds: CGRect
    ) -> [KeyTouchCell] {
        guard !rows.isEmpty else { return [] }

        var cells: [KeyTouchCell] = []
        for rowIndex in rows.indices {
            let row = rows[rowIndex]
            guard !row.isEmpty else { continue }
            let rowMinY = row.map(\.minY).min() ?? containerBounds.minY
            let rowMaxY = row.map(\.maxY).max() ?? rowMinY

            let top: CGFloat
            if rowIndex == rows.startIndex {
                top = rowMinY
            } else {
                let previousMaxY = rows[rowIndex - 1].map(\.maxY).max() ?? rowMinY
                top = (previousMaxY + rowMinY) / 2
            }

            let bottom: CGFloat
            if rowIndex == rows.index(before: rows.endIndex) {
                bottom = rowMaxY
            } else {
                let nextMinY = rows[rowIndex + 1].map(\.minY).min() ?? rowMaxY
                bottom = (rowMaxY + nextMinY) / 2
            }

            for keyIndex in row.indices {
                let visual = row[keyIndex]
                let left: CGFloat
                if keyIndex == row.startIndex {
                    left = containerBounds.minX
                } else {
                    left = (row[keyIndex - 1].maxX + visual.minX) / 2
                }

                let right: CGFloat
                if keyIndex == row.index(before: row.endIndex) {
                    right = containerBounds.maxX
                } else {
                    right = (visual.maxX + row[keyIndex + 1].minX) / 2
                }

                let touchFrame = CGRect(
                    x: left,
                    y: top,
                    width: max(0, right - left),
                    height: max(0, bottom - top)
                )
                cells.append(KeyTouchCell(visualFrame: visual, touchFrame: touchFrame))
            }
        }
        return cells
    }

    /// Shared winner for 26-key and nine-key: the touch cell that contains
    /// the point. Overlaps pick the nearest visual face (smaller face on a
    /// tie). Points above the key region stay with the default visual hit.
    public static func hitIndex(
        at point: CGPoint,
        cells: [KeyTouchCell],
        defaultVisualHitIndex: Int?
    ) -> Int? {
        let keyRegionMinY = cells.map(\.touchFrame.minY).min() ?? CGFloat.greatestFiniteMagnitude
        if point.y < keyRegionMinY {
            return defaultVisualHitIndex
        }

        let containing = cells.indices.filter { cells[$0].touchFrame.contains(point) }
        guard !containing.isEmpty else { return nil }
        if containing.count == 1 { return containing[0] }
        return containing.min { lhs, rhs in
            let left = cells[lhs].visualFrame
            let right = cells[rhs].visualFrame
            let leftDistance = distance(from: point, to: left)
            let rightDistance = distance(from: point, to: right)
            if leftDistance != rightDistance {
                return leftDistance < rightDistance
            }
            return area(left) < area(right)
        }
    }

    /// Places a key in host space using its on-screen origin and its real
    /// local size. `convert(bounds)` can inherit a stretched ancestor frame;
    /// this keeps ABC/JKL at key size so they do not share one column cell.
    public static func hostFrame(localSize: CGSize, originInHost: CGPoint) -> CGRect {
        CGRect(origin: originInHost, size: localSize)
    }

    /// Midline slop in the key's own bounds. Gaps come from stack `spacing`,
    /// not from converted ancestor frames, so a column cannot collapse onto ABC.
    public static func localTouchInsets(
        leadingGap: CGFloat,
        trailingGap: CGFloat,
        topGap: CGFloat,
        bottomGap: CGFloat,
        isFirstInRow: Bool,
        isLastInRow: Bool
    ) -> (top: CGFloat, left: CGFloat, bottom: CGFloat, right: CGFloat) {
        (
            top: max(0, topGap / 2),
            left: max(0, isFirstInRow ? leadingGap : leadingGap / 2),
            bottom: max(0, bottomGap / 2),
            right: max(0, isLastInRow ? trailingGap : trailingGap / 2)
        )
    }

    public static func localTouchBounds(
        visualBounds: CGRect,
        insets: (top: CGFloat, left: CGFloat, bottom: CGFloat, right: CGFloat)
    ) -> CGRect {
        CGRect(
            x: visualBounds.minX - insets.left,
            y: visualBounds.minY - insets.top,
            width: visualBounds.width + insets.left + insets.right,
            height: visualBounds.height + insets.top + insets.bottom
        )
    }

    public static func groupedRows(from visualFrames: [CGRect]) -> [[CGRect]] {
        groupedRows(from: visualFrames, midYTolerance: nil)
    }

    private static func area(_ rect: CGRect) -> CGFloat {
        rect.width * rect.height
    }

    private static func distance(from point: CGPoint, to rect: CGRect) -> CGFloat {
        if rect.contains(point) { return 0 }
        let dx = max(rect.minX - point.x, 0, point.x - rect.maxX)
        let dy = max(rect.minY - point.y, 0, point.y - rect.maxY)
        return hypot(dx, dy)
    }

    private static func groupedRows(
        from visualFrames: [CGRect],
        midYTolerance: CGFloat?
    ) -> [[CGRect]] {
        let sorted = visualFrames.sorted {
            if abs($0.midY - $1.midY) > 1 {
                return $0.midY < $1.midY
            }
            return $0.minX < $1.minX
        }

        var rows: [[CGRect]] = []
        for frame in sorted {
            if let lastRow = rows.indices.last,
                let rowMidY = averageMidY(for: rows[lastRow]),
                abs(frame.midY - rowMidY)
                    <= (midYTolerance ?? max(8, frame.height * 0.5))
            {
                rows[lastRow].append(frame)
            } else {
                rows.append([frame])
            }
        }

        return rows.map { row in
            row.sorted { $0.minX < $1.minX }
        }
    }

    private static func averageMidY(for row: [CGRect]) -> CGFloat? {
        guard !row.isEmpty else { return nil }
        return row.reduce(CGFloat(0)) { $0 + $1.midY } / CGFloat(row.count)
    }
}
