import XCTest

@testable import KeyboardCore

final class KeyTouchCellLayoutTests: XCTestCase {
    func testGapMidpointBelongsToOneTouchCell() {
        let left = CGRect(x: 0, y: 0, width: 40, height: 45)
        let right = CGRect(x: 50, y: 0, width: 40, height: 45)
        let cells = KeyTouchCellLayout.makeCells(
            visualFrames: [left, right],
            containerBounds: CGRect(x: 0, y: 0, width: 90, height: 45)
        )

        XCTAssertEqual(cells.count, 2)
        XCTAssertEqual(cells[0].visualFrame, left)
        XCTAssertEqual(cells[1].visualFrame, right)
        XCTAssertEqual(cells[0].touchFrame.maxX, 45, accuracy: 0.001)
        XCTAssertEqual(cells[1].touchFrame.minX, 45, accuracy: 0.001)

        let gapPoint = CGPoint(x: 45, y: 22)
        XCTAssertEqual(
            KeyTouchCellLayout.hitIndex(at: gapPoint, cells: cells, defaultVisualHitIndex: nil),
            1
        )
        XCTAssertTrue(cells[1].touchFrame.contains(gapPoint))
    }

    func testOverlayRectsAreTheHitTestSnapshotNotASecondLayout() {
        let frames = [
            CGRect(x: 7, y: 40, width: 36, height: 45),
            CGRect(x: 49, y: 40, width: 36, height: 45),
            CGRect(x: 91, y: 40, width: 36, height: 45),
            CGRect(x: 7, y: 93, width: 46, height: 45),
            CGRect(x: 59, y: 93, width: 200, height: 45),
        ]
        let snapshot = KeyTouchCellLayout.makeCells(
            visualFrames: frames,
            containerBounds: CGRect(x: 0, y: 0, width: 320, height: 160)
        )
        // Overlay must paint this array's touchFrame values, not a rebuilt set.
        let displayedTouchFrames = snapshot.map(\.touchFrame)
        XCTAssertEqual(displayedTouchFrames, snapshot.map(\.touchFrame))

        for (index, cell) in snapshot.enumerated() {
            let insideTouch = CGPoint(x: cell.touchFrame.midX, y: cell.touchFrame.midY)
            XCTAssertEqual(
                KeyTouchCellLayout.hitIndex(
                    at: insideTouch,
                    cells: snapshot,
                    defaultVisualHitIndex: nil
                ),
                index
            )
        }
    }

    func testVisualKeyStillWinsWhenPointIsInsideItsBounds() {
        let left = CGRect(x: 10, y: 0, width: 40, height: 45)
        let right = CGRect(x: 56, y: 0, width: 40, height: 45)
        let cells = KeyTouchCellLayout.makeCells(
            visualFrames: [left, right],
            containerBounds: CGRect(x: 0, y: 0, width: 106, height: 45)
        )
        let pointInsideLeft = CGPoint(x: 20, y: 20)
        XCTAssertEqual(
            KeyTouchCellLayout.hitIndex(
                at: pointInsideLeft,
                cells: cells,
                defaultVisualHitIndex: 0
            ),
            0
        )
    }

    func testPathBarExpandedHitBoundsMatchesPointInsideContract() {
        let bar = CGRect(x: 0, y: 0, width: 320, height: 34)
        let expanded = ChromeTouchHitGeometry.pathBarExpandedHitBounds(barBounds: bar)
        XCTAssertEqual(expanded.minY, -5, accuracy: 0.001)
        XCTAssertEqual(expanded.height, 44, accuracy: 0.001)
        XCTAssertTrue(expanded.contains(CGPoint(x: 10, y: -4)))
        XCTAssertFalse(bar.contains(CGPoint(x: 10, y: -4)))
    }

    func testPathBarItemIndexUsesExpandedCellFrames() {
        let cells = [
            CGRect(x: 4, y: 0, width: 40, height: 33),
            CGRect(x: 44, y: 0, width: 40, height: 33),
        ]
        XCTAssertEqual(
            ChromeTouchHitGeometry.pathBarItemIndex(
                at: CGPoint(x: 20, y: -5),
                itemFrames: cells
            ),
            0
        )
        XCTAssertEqual(
            ChromeTouchHitGeometry.pathBarItemIndex(
                at: CGPoint(x: 60, y: 36),
                itemFrames: cells
            ),
            1
        )
        XCTAssertNil(
            ChromeTouchHitGeometry.pathBarItemIndex(
                at: CGPoint(x: 200, y: 10),
                itemFrames: cells
            )
        )
    }

    func testCandidateExpandHitFrameClipsToBarAndKeepsButtonShape() {
        let button = CGRect(x: 260, y: 9, width: 56, height: 56)
        let bar = CGRect(x: 0, y: 0, width: 320, height: 48)
        let hit = ChromeTouchHitGeometry.candidateExpandButtonHitFrame(
            buttonFrame: button,
            topOutset: 10,
            leftOutset: 16,
            bottomOutset: 12,
            rightOutset: 12,
            barBounds: bar
        )
        XCTAssertEqual(hit.minX, 244, accuracy: 0.001)
        XCTAssertEqual(hit.maxX, 320, accuracy: 0.001)
        XCTAssertEqual(hit.minY, 0, accuracy: 0.001)
        XCTAssertEqual(hit.maxY, 48, accuracy: 0.001)
        XCTAssertLessThan(hit.width, 84)
    }

    func testStructuredNineKeyReturnStaysInRightColumn() throws {
        let leftBounds = CGRect(x: 0, y: 40, width: 240, height: 200)
        let rightBounds = CGRect(x: 246, y: 40, width: 60, height: 200)
        let selected = CGRect(x: 120, y: 180, width: 110, height: 45)
        let returnKey = CGRect(x: 248, y: 130, width: 56, height: 98)
        let cells = KeyTouchCellLayout.makeStructuredCells(
            columns: [
                KeyTouchLayoutColumn(bounds: leftBounds, rows: [[selected]]),
                KeyTouchLayoutColumn(bounds: rightBounds, rows: [[returnKey]]),
            ]
        )
        let returnCell = try XCTUnwrap(cells.first { $0.visualFrame == returnKey })
        let selectedCell = try XCTUnwrap(cells.first { $0.visualFrame == selected })
        XCTAssertEqual(returnCell.touchFrame.minX, 243, accuracy: 0.001)
        XCTAssertEqual(returnCell.touchFrame.maxX, 306, accuracy: 0.001)
        XCTAssertLessThan(returnCell.touchFrame.width, 80)
        XCTAssertFalse(
            returnCell.touchFrame.contains(CGPoint(x: selected.midX, y: selected.midY))
        )
        XCTAssertTrue(
            selectedCell.touchFrame.contains(CGPoint(x: selected.midX, y: selected.midY))
        )
    }

    func testStructuredNineKeyDoesNotMergeTallReturnIntoLeftPadRow() throws {
        let leftBounds = CGRect(x: 0, y: 0, width: 240, height: 200)
        let rightBounds = CGRect(x: 246, y: 0, width: 60, height: 200)
        let wxyz = CGRect(x: 180, y: 90, width: 55, height: 45)
        let returnKey = CGRect(x: 248, y: 90, width: 56, height: 98)
        let flat = KeyTouchCellLayout.makeCells(
            visualFrames: [wxyz, returnKey],
            containerBounds: CGRect(x: 0, y: 0, width: 306, height: 200)
        )
        let structured = KeyTouchCellLayout.makeStructuredCells(
            columns: [
                KeyTouchLayoutColumn(bounds: leftBounds, rows: [[wxyz]]),
                KeyTouchLayoutColumn(bounds: rightBounds, rows: [[returnKey]]),
            ]
        )
        let flatReturn = try XCTUnwrap(flat.first { $0.visualFrame == returnKey }?.touchFrame)
        let structuredReturn = try XCTUnwrap(
            structured.first { $0.visualFrame == returnKey }?.touchFrame
        )
        XCTAssertLessThan(flatReturn.minX, rightBounds.minX)
        XCTAssertEqual(structuredReturn.minX, 243, accuracy: 0.001)
        XCTAssertEqual(structuredReturn.width, 63, accuracy: 0.001)
    }

    func testStructuredNineKeyColumnGapIsSplitAtMidpoint() throws {
        let leftKey = KeyTouchIdentifiedVisual(
            id: 4,
            frame: CGRect(x: 180, y: 0, width: 55, height: 45)
        )
        let rightKey = KeyTouchIdentifiedVisual(
            id: 5,
            frame: CGRect(x: 248, y: 0, width: 56, height: 45)
        )
        let cells = KeyTouchCellLayout.makeIdentifiedStructuredCells(
            columns: [
                (bounds: CGRect(x: 0, y: 0, width: 240, height: 45), rows: [[leftKey]]),
                (bounds: CGRect(x: 246, y: 0, width: 60, height: 45), rows: [[rightKey]]),
            ]
        )
        let leftCell = try XCTUnwrap(cells.first { $0.id == 4 })
        let rightCell = try XCTUnwrap(cells.first { $0.id == 5 })

        XCTAssertEqual(leftCell.cell.touchFrame.maxX, 243, accuracy: 0.001)
        XCTAssertEqual(rightCell.cell.touchFrame.minX, 243, accuracy: 0.001)
        XCTAssertEqual(
            KeyTouchCellLayout.hitIdentifiedIndex(
                at: CGPoint(x: 242, y: 22),
                cells: cells,
                defaultVisualHitIndex: nil
            ).map { cells[$0].id },
            4
        )
        XCTAssertEqual(
            KeyTouchCellLayout.hitIdentifiedIndex(
                at: CGPoint(x: 244, y: 22),
                cells: cells,
                defaultVisualHitIndex: nil
            ).map { cells[$0].id },
            5
        )
    }

    func testSmallerVisualWinsWhenAColumnTallCellAlsoContainsThePoint() {
        let abc = KeyTouchCell(
            visualFrame: CGRect(x: 120, y: 0, width: 55, height: 200),
            touchFrame: CGRect(x: 120, y: 0, width: 55, height: 200)
        )
        let jkl = KeyTouchCell(
            visualFrame: CGRect(x: 120, y: 53, width: 55, height: 45),
            touchFrame: CGRect(x: 120, y: 49, width: 55, height: 53)
        )
        let point = CGPoint(x: 147, y: 75)
        XCTAssertEqual(
            KeyTouchCellLayout.hitIndex(at: point, cells: [abc, jkl], defaultVisualHitIndex: 0),
            1
        )
    }

    func testNineKeyEachPadKeyKeepsItsOwnRowCell() throws {
        let column = CGRect(x: 0, y: 0, width: 240, height: 200)
        let abc = CGRect(x: 120, y: 0, width: 55, height: 45)
        let jkl = CGRect(x: 120, y: 53, width: 55, height: 45)
        let tuv = CGRect(x: 120, y: 106, width: 55, height: 45)
        let space = CGRect(x: 80, y: 155, width: 150, height: 45)
        let cells = KeyTouchCellLayout.makeStructuredCells(
            columns: [
                KeyTouchLayoutColumn(
                    bounds: column,
                    rows: [[abc], [jkl], [tuv], [space]]
                )
            ]
        )
        let abcCell = try XCTUnwrap(cells.first { $0.visualFrame == abc })
        let jklCell = try XCTUnwrap(cells.first { $0.visualFrame == jkl })
        XCTAssertLessThan(abcCell.touchFrame.maxY, jkl.minY + 1)
        XCTAssertGreaterThan(jklCell.touchFrame.minY, abc.maxY - 1)
        XCTAssertFalse(abcCell.touchFrame.contains(CGPoint(x: jkl.midX, y: jkl.midY)))
        XCTAssertEqual(
            KeyTouchCellLayout.hitIndex(
                at: CGPoint(x: jkl.midX, y: jkl.midY),
                cells: cells,
                defaultVisualHitIndex: nil
            ),
            cells.firstIndex { $0.visualFrame == jkl }
        )
    }

    func testNineKeyColumnGapGoesToVerticalNeighborsNotDEF() throws {
        let leftBounds = CGRect(x: 0, y: 0, width: 240, height: 200)
        let def = CGRect(x: 180, y: 0, width: 55, height: 45)
        let mno = CGRect(x: 180, y: 53, width: 55, height: 45)
        let wxyz = CGRect(x: 180, y: 106, width: 55, height: 45)
        let space = CGRect(x: 80, y: 161, width: 150, height: 45)
        let cells = KeyTouchCellLayout.makeStructuredCells(
            columns: [
                KeyTouchLayoutColumn(
                    bounds: leftBounds,
                    rows: [[def], [mno], [wxyz], [space]]
                )
            ]
        )
        let defCell = try XCTUnwrap(cells.first { $0.visualFrame == def })
        let mnoCell = try XCTUnwrap(cells.first { $0.visualFrame == mno })
        let wxyzCell = try XCTUnwrap(cells.first { $0.visualFrame == wxyz })
        let spaceCell = try XCTUnwrap(cells.first { $0.visualFrame == space })

        let betweenMNOAndWXYZ = CGPoint(x: 207, y: 102)
        XCTAssertFalse(defCell.touchFrame.contains(betweenMNOAndWXYZ))
        let mnoWxyzHit = KeyTouchCellLayout.hitIndex(
            at: betweenMNOAndWXYZ,
            cells: cells,
            defaultVisualHitIndex: nil
        )
        XCTAssertTrue(
            mnoWxyzHit == cells.firstIndex { $0.visualFrame == mno }
                || mnoWxyzHit == cells.firstIndex { $0.visualFrame == wxyz }
        )

        let betweenWXYZAndSpace = CGPoint(x: 207, y: 156)
        XCTAssertFalse(defCell.touchFrame.contains(betweenWXYZAndSpace))
        let wxyzSpaceHit = KeyTouchCellLayout.hitIndex(
            at: betweenWXYZAndSpace,
            cells: cells,
            defaultVisualHitIndex: nil
        )
        XCTAssertTrue(
            wxyzSpaceHit == cells.firstIndex { $0.visualFrame == wxyz }
                || wxyzSpaceHit == cells.firstIndex { $0.visualFrame == space }
        )
        XCTAssertEqual(wxyzCell.touchFrame.maxY, 156, accuracy: 0.001)
        XCTAssertEqual(spaceCell.touchFrame.minY, 156, accuracy: 0.001)
        XCTAssertEqual(mnoCell.touchFrame.maxY, wxyzCell.touchFrame.minY, accuracy: 0.001)
    }

    func testNineKeyLoneSpaceFillsItsColumnLike26Key() throws {
        let bounds = CGRect(x: 0, y: 0, width: 240, height: 45)
        let space = CGRect(x: 80, y: 0, width: 110, height: 45)
        let cells = KeyTouchCellLayout.makeStructuredCells(
            columns: [KeyTouchLayoutColumn(bounds: bounds, rows: [[space]])]
        )
        let spaceCell = try XCTUnwrap(cells.first { $0.visualFrame == space })
        XCTAssertEqual(spaceCell.touchFrame.minX, 0, accuracy: 0.001)
        XCTAssertEqual(spaceCell.touchFrame.maxX, 240, accuracy: 0.001)
    }

    func testNineKeySmallSiblingGapStillBelongsToANeighbor() {
        let left = CGRect(x: 0, y: 0, width: 55, height: 45)
        let right = CGRect(x: 61, y: 0, width: 55, height: 45)
        let cells = KeyTouchCellLayout.makeStructuredCells(
            columns: [
                KeyTouchLayoutColumn(
                    bounds: CGRect(x: 0, y: 0, width: 120, height: 45),
                    rows: [[left, right]]
                )
            ]
        )
        let gapPoint = CGPoint(x: 58, y: 22)
        let hit = KeyTouchCellLayout.hitIndex(at: gapPoint, cells: cells, defaultVisualHitIndex: nil)
        XCTAssertNotNil(hit)
        XCTAssertTrue(cells.contains { $0.touchFrame.contains(gapPoint) })
    }

    func testOverlappingTouchCellsPreferNearestVisual() {
        let near = KeyTouchCell(
            visualFrame: CGRect(x: 40, y: 0, width: 40, height: 40),
            touchFrame: CGRect(x: 0, y: 0, width: 120, height: 40)
        )
        let far = KeyTouchCell(
            visualFrame: CGRect(x: 200, y: 0, width: 40, height: 40),
            touchFrame: CGRect(x: 0, y: 0, width: 240, height: 40)
        )
        let point = CGPoint(x: 50, y: 20)
        XCTAssertEqual(
            KeyTouchCellLayout.hitIndex(at: point, cells: [far, near], defaultVisualHitIndex: nil),
            1
        )
    }

    func testTwentySixKeyInsetHomeRowFillsContainerSides() throws {
        let container = CGRect(x: 0, y: 0, width: 360, height: 260)
        let a = CGRect(x: 18, y: 100, width: 32, height: 40)
        let l = CGRect(x: 310, y: 100, width: 32, height: 40)
        let cells = KeyTouchCellLayout.makeCells(
            visualFrames: [a, l],
            containerBounds: container
        )
        let aCell = try XCTUnwrap(cells.first { $0.visualFrame == a })
        let lCell = try XCTUnwrap(cells.first { $0.visualFrame == l })
        XCTAssertEqual(aCell.touchFrame.minX, 0, accuracy: 0.001)
        XCTAssertEqual(lCell.touchFrame.maxX, 360, accuracy: 0.001)
        XCTAssertEqual(
            KeyTouchCellLayout.hitIndex(
                at: CGPoint(x: 8, y: 120),
                cells: cells,
                defaultVisualHitIndex: nil
            ),
            cells.firstIndex { $0.visualFrame == a }
        )
    }

    func testTwentySixKeyNestedLetterRowGetsVerticalAndFunctionGaps() throws {
        // Mirrors makeLetterThirdRow: Shift | nested z…m | Delete, with an
        // inset home row above and a bottom row below. Parent-stack-only
        // insets would give z a 0 vertical gap and no share of the 10 pt
        // Shift/z spacing.
        let container = CGRect(x: 0, y: 0, width: 360, height: 260)
        let a = CGRect(x: 18, y: 50, width: 32, height: 40)
        let shift = CGRect(x: 0, y: 100, width: 46, height: 40)
        let z = CGRect(x: 56, y: 100, width: 30, height: 40)
        let m = CGRect(x: 254, y: 100, width: 30, height: 40)
        let delete = CGRect(x: 300, y: 100, width: 60, height: 40)
        let space = CGRect(x: 80, y: 160, width: 200, height: 40)
        let cells = KeyTouchCellLayout.makeCells(
            visualFrames: [a, shift, z, m, delete, space],
            containerBounds: container
        )
        let zCell = try XCTUnwrap(cells.first { $0.visualFrame == z })
        let mCell = try XCTUnwrap(cells.first { $0.visualFrame == m })
        let shiftCell = try XCTUnwrap(cells.first { $0.visualFrame == shift })
        let deleteCell = try XCTUnwrap(cells.first { $0.visualFrame == delete })

        XCTAssertEqual(zCell.touchFrame.minY, 95, accuracy: 0.001)
        XCTAssertEqual(zCell.touchFrame.maxY, 150, accuracy: 0.001)
        XCTAssertEqual(zCell.touchFrame.minX, 51, accuracy: 0.001)
        XCTAssertEqual(shiftCell.touchFrame.maxX, 51, accuracy: 0.001)
        XCTAssertEqual(mCell.touchFrame.maxX, 292, accuracy: 0.001)
        XCTAssertEqual(deleteCell.touchFrame.minX, 292, accuracy: 0.001)

        XCTAssertEqual(
            KeyTouchCellLayout.hitIndex(
                at: CGPoint(x: 71, y: 95),
                cells: cells,
                defaultVisualHitIndex: nil
            ),
            cells.firstIndex { $0.visualFrame == z }
        )
        XCTAssertEqual(
            KeyTouchCellLayout.hitIndex(
                at: CGPoint(x: 71, y: 148),
                cells: cells,
                defaultVisualHitIndex: nil
            ),
            cells.firstIndex { $0.visualFrame == z }
        )
    }

    func testSnapshotInsetsMatchTouchFrameSoOverlayCannotInventASecondBox() {
        let visual = CGRect(x: 0, y: 0, width: 32, height: 40)
        let touch = CGRect(x: -18, y: -5, width: 53, height: 50)
        let insets = KeyTouchCellLayout.insets(visualBounds: visual, touchBounds: touch)
        XCTAssertEqual(insets.left, 18, accuracy: 0.001)
        XCTAssertEqual(insets.top, 5, accuracy: 0.001)
        XCTAssertEqual(insets.right, 3, accuracy: 0.001)
        XCTAssertEqual(insets.bottom, 5, accuracy: 0.001)
        XCTAssertEqual(visual.minX - insets.left, touch.minX, accuracy: 0.001)
        XCTAssertEqual(visual.minY - insets.top, touch.minY, accuracy: 0.001)
        XCTAssertEqual(visual.maxX + insets.right, touch.maxX, accuracy: 0.001)
        XCTAssertEqual(visual.maxY + insets.bottom, touch.maxY, accuracy: 0.001)
    }

    func testIdentifiedSnapshotKeepsCallerIdsInsteadOfRectEquality() {
        let abc = KeyTouchIdentifiedVisual(
            id: 2,
            frame: CGRect(x: 120, y: 0, width: 55, height: 45)
        )
        let jkl = KeyTouchIdentifiedVisual(
            id: 5,
            frame: CGRect(x: 120, y: 53, width: 55, height: 45)
        )
        let cells = KeyTouchCellLayout.makeIdentifiedStructuredCells(
            columns: [
                (
                    bounds: CGRect(x: 0, y: 0, width: 240, height: 200),
                    rows: [[abc], [jkl]]
                )
            ]
        )
        XCTAssertEqual(cells.map(\.id), [2, 5])
        let jklPoint = CGPoint(x: 147, y: 75)
        let hit = KeyTouchCellLayout.hitIdentifiedIndex(
            at: jklPoint,
            cells: cells,
            defaultVisualHitIndex: nil
        )
        XCTAssertEqual(hit.flatMap { cells[$0].id }, 5)
        XCTAssertNotEqual(hit.flatMap { cells[$0].id }, 2)
    }

    func testIdentifiedNineKeyWXYZSpaceGapDoesNotBelongToDEF() {
        let def = KeyTouchIdentifiedVisual(
            id: 3,
            frame: CGRect(x: 180, y: 0, width: 55, height: 45)
        )
        let wxyz = KeyTouchIdentifiedVisual(
            id: 9,
            frame: CGRect(x: 180, y: 106, width: 55, height: 45)
        )
        let space = KeyTouchIdentifiedVisual(
            id: 10,
            frame: CGRect(x: 80, y: 161, width: 150, height: 45)
        )
        let cells = KeyTouchCellLayout.makeIdentifiedStructuredCells(
            columns: [
                (
                    bounds: CGRect(x: 0, y: 0, width: 240, height: 200),
                    rows: [[def], [wxyz], [space]]
                )
            ]
        )
        let gap = CGPoint(x: 207, y: 156)
        let hit = KeyTouchCellLayout.hitIdentifiedIndex(
            at: gap,
            cells: cells,
            defaultVisualHitIndex: nil
        )
        XCTAssertNotEqual(hit.flatMap { cells[$0].id }, 3)
        XCTAssertTrue(hit.flatMap { cells[$0].id } == 9 || hit.flatMap { cells[$0].id } == 10)
    }

    func testIdentifiedTwentySixKeyAndNestedThirdRowShareOneGrid() {
        let a = KeyTouchIdentifiedVisual(id: 11, frame: CGRect(x: 18, y: 50, width: 32, height: 40))
        let shift = KeyTouchIdentifiedVisual(id: 20, frame: CGRect(x: 0, y: 100, width: 46, height: 40))
        let z = KeyTouchIdentifiedVisual(id: 21, frame: CGRect(x: 56, y: 100, width: 30, height: 40))
        let delete = KeyTouchIdentifiedVisual(
            id: 22,
            frame: CGRect(x: 300, y: 100, width: 60, height: 40)
        )
        let space = KeyTouchIdentifiedVisual(
            id: 30,
            frame: CGRect(x: 80, y: 160, width: 200, height: 40)
        )
        let cells = KeyTouchCellLayout.makeIdentifiedCells(
            visuals: [a, shift, z, delete, space],
            containerBounds: CGRect(x: 0, y: 0, width: 360, height: 260)
        )
        XCTAssertEqual(Set(cells.map(\.id)), [11, 20, 21, 22, 30])
        let leftOfA = KeyTouchCellLayout.hitIdentifiedIndex(
            at: CGPoint(x: 8, y: 70),
            cells: cells,
            defaultVisualHitIndex: nil
        )
        XCTAssertEqual(leftOfA.flatMap { cells[$0].id }, 11)
        let aboveZ = KeyTouchCellLayout.hitIdentifiedIndex(
            at: CGPoint(x: 71, y: 95),
            cells: cells,
            defaultVisualHitIndex: nil
        )
        XCTAssertEqual(aboveZ.flatMap { cells[$0].id }, 21)
    }

    func testReleaseBuildIgnoresStoredOverlayFlag() {
        let defaults = UserDefaults(suiteName: "debug-key-hitbox-tests")
        defaults?.removePersistentDomain(forName: "debug-key-hitbox-tests")
        defaults?.set(true, forKey: DebugKeyHitboxConfiguration.enabledKey)

        XCTAssertFalse(DebugKeyHitboxConfiguration.isEnabled(in: defaults, isDebugBuild: false))
        XCTAssertTrue(DebugKeyHitboxConfiguration.isEnabled(in: defaults, isDebugBuild: true))

        defaults?.removePersistentDomain(forName: "debug-key-hitbox-tests")
    }
}
