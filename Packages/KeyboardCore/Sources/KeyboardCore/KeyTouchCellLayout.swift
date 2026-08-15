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

/// A visual key plus a stable id so snapshot consumers never pair by `CGRect ==`.
public struct KeyTouchIdentifiedVisual: Equatable, Sendable {
    public let id: Int
    public let frame: CGRect

    public init(id: Int, frame: CGRect) {
        self.id = id
        self.frame = frame
    }
}

/// Snapshot row: the same `id` that entered the builder, plus the fill cell.
public struct KeyTouchIdentifiedCell: Equatable, Sendable {
    public let id: Int
    public let cell: KeyTouchCell

    public init(id: Int, cell: KeyTouchCell) {
        self.id = id
        self.cell = cell
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
    /// right column and DEF cannot inherit MNO / WXYZ / space gutters. The gap
    /// between neighboring column containers is split at its midpoint.
    public static func makeStructuredCells(columns: [KeyTouchLayoutColumn]) -> [KeyTouchCell] {
        let touchBounds = midlineFilledColumnBounds(columns.map(\.bounds))
        return columns.enumerated().flatMap { index, column in
            makeCells(rows: column.rows, containerBounds: touchBounds[index])
        }
    }

    /// Fills `containerBounds` by splitting sibling gaps at their midlines.
    /// First / last row keep their visual top / bottom so the candidate bar
    /// keeps the strip above the keys.
    public static func makeCells(
        rows: [[CGRect]],
        containerBounds: CGRect
    ) -> [KeyTouchCell] {
        makeIdentifiedCells(
            rows: rows.map { row in row.map { KeyTouchIdentifiedVisual(id: 0, frame: $0) } },
            containerBounds: containerBounds
        ).map(\.cell)
    }

    /// 26-key / numbers / symbols: group by midY, keep caller ids.
    public static func makeIdentifiedCells(
        visuals: [KeyTouchIdentifiedVisual],
        containerBounds: CGRect
    ) -> [KeyTouchIdentifiedCell] {
        makeIdentifiedCells(
            rows: groupedIdentifiedRows(from: visuals),
            containerBounds: containerBounds
        )
    }

    /// Nine-key: each column is filled independently so return stays in the
    /// right column. Caller must pass real rows, not a flattened column, and
    /// columns in visual left-to-right order.
    public static func makeIdentifiedStructuredCells(
        columns: [(bounds: CGRect, rows: [[KeyTouchIdentifiedVisual]])]
    ) -> [KeyTouchIdentifiedCell] {
        let touchBounds = midlineFilledColumnBounds(columns.map(\.bounds))
        return columns.enumerated().flatMap { index, column in
            makeIdentifiedCells(rows: column.rows, containerBounds: touchBounds[index])
        }
    }

    public static func makeIdentifiedCells(
        rows: [[KeyTouchIdentifiedVisual]],
        containerBounds: CGRect
    ) -> [KeyTouchIdentifiedCell] {
        guard !rows.isEmpty else { return [] }

        var cells: [KeyTouchIdentifiedCell] = []
        for rowIndex in rows.indices {
            let row = rows[rowIndex]
            guard !row.isEmpty else { continue }
            let rowMinY = row.map(\.frame.minY).min() ?? containerBounds.minY
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
                let visual = row[keyIndex].frame
                let left: CGFloat
                if keyIndex == row.startIndex {
                    left = containerBounds.minX
                } else {
                    left = (row[keyIndex - 1].frame.maxX + visual.minX) / 2
                }

                let right: CGFloat
                if keyIndex == row.index(before: row.endIndex) {
                    right = containerBounds.maxX
                } else {
                    right = (visual.maxX + row[keyIndex + 1].frame.minX) / 2
                }

                let touchFrame = CGRect(
                    x: left,
                    y: top,
                    width: max(0, right - left),
                    height: max(0, bottom - top)
                )
                cells.append(
                    KeyTouchIdentifiedCell(
                        id: row[keyIndex].id,
                        cell: KeyTouchCell(visualFrame: visual, touchFrame: touchFrame)
                    )
                )
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

    /// Converts the published snapshot into UIControl outsets. The snapshot,
    /// not a second gap calculation, remains the source of truth.
    public static func insets(
        visualBounds: CGRect,
        touchBounds: CGRect
    ) -> (top: CGFloat, left: CGFloat, bottom: CGFloat, right: CGFloat) {
        (
            top: max(0, visualBounds.minY - touchBounds.minY),
            left: max(0, visualBounds.minX - touchBounds.minX),
            bottom: max(0, touchBounds.maxY - visualBounds.maxY),
            right: max(0, touchBounds.maxX - visualBounds.maxX)
        )
    }

    public static func groupedRows(from visualFrames: [CGRect]) -> [[CGRect]] {
        groupedRows(from: visualFrames, midYTolerance: nil)
    }

    public static func hitIdentifiedIndex(
        at point: CGPoint,
        cells: [KeyTouchIdentifiedCell],
        defaultVisualHitIndex: Int?
    ) -> Int? {
        hitIndex(
            at: point,
            cells: cells.map(\.cell),
            defaultVisualHitIndex: defaultVisualHitIndex
        )
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

    /// Column containers intentionally keep their visual spacing. Touch
    /// containers meet at the spacing midpoint so the host has no dead strip.
    private static func midlineFilledColumnBounds(_ bounds: [CGRect]) -> [CGRect] {
        bounds.indices.map { index in
            let current = bounds[index]
            let left =
                index == bounds.startIndex
                ? current.minX
                : (bounds[bounds.index(before: index)].maxX + current.minX) / 2
            let right =
                index == bounds.index(before: bounds.endIndex)
                ? current.maxX
                : (current.maxX + bounds[bounds.index(after: index)].minX) / 2
            return CGRect(
                x: left,
                y: current.minY,
                width: max(0, right - left),
                height: current.height
            )
        }
    }

    private static func groupedIdentifiedRows(
        from visuals: [KeyTouchIdentifiedVisual]
    ) -> [[KeyTouchIdentifiedVisual]] {
        let sorted = visuals.sorted {
            if abs($0.frame.midY - $1.frame.midY) > 1 {
                return $0.frame.midY < $1.frame.midY
            }
            return $0.frame.minX < $1.frame.minX
        }

        var rows: [[KeyTouchIdentifiedVisual]] = []
        for item in sorted {
            if let lastRow = rows.indices.last,
                let rowMidY = averageMidY(for: rows[lastRow].map(\.frame)),
                abs(item.frame.midY - rowMidY) <= max(8, item.frame.height * 0.5)
            {
                rows[lastRow].append(item)
            } else {
                rows.append([item])
            }
        }

        return rows.map { row in
            row.sorted { $0.frame.minX < $1.frame.minX }
        }
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
