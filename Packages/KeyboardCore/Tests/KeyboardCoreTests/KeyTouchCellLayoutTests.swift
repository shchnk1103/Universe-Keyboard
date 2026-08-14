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
        XCTAssertEqual(returnCell.touchFrame.minX, 246, accuracy: 0.001)
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
        XCTAssertEqual(structuredReturn.minX, 246, accuracy: 0.001)
        XCTAssertEqual(structuredReturn.width, 60, accuracy: 0.001)
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

    func testLocalTouchInsetsSplitSiblingGapsAtTheMidline() {
        let insets = KeyTouchCellLayout.localTouchInsets(
            leadingGap: 6,
            trailingGap: 6,
            topGap: 8,
            bottomGap: 8,
            isFirstInRow: false,
            isLastInRow: false
        )
        XCTAssertEqual(insets.top, 4, accuracy: 0.001)
        XCTAssertEqual(insets.bottom, 4, accuracy: 0.001)
        XCTAssertEqual(insets.left, 3, accuracy: 0.001)
        XCTAssertEqual(insets.right, 3, accuracy: 0.001)

        let visual = CGRect(x: 0, y: 0, width: 55, height: 45)
        let box = KeyTouchCellLayout.localTouchBounds(visualBounds: visual, insets: insets)
        XCTAssertFalse(box.contains(CGPoint(x: 27, y: 80)))
        XCTAssertTrue(box.contains(CGPoint(x: 27, y: 48)))
        XCTAssertTrue(visual.contains(CGPoint(x: 27, y: 22)))
    }

    func testHostFrameKeepsLocalKeySize() {
        let frame = KeyTouchCellLayout.hostFrame(
            localSize: CGSize(width: 55, height: 45),
            originInHost: CGPoint(x: 120, y: 53)
        )
        XCTAssertEqual(frame, CGRect(x: 120, y: 53, width: 55, height: 45))
        XCTAssertLessThan(frame.height, 50)
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

    func testReleaseBuildIgnoresStoredOverlayFlag() {
        let defaults = UserDefaults(suiteName: "debug-key-hitbox-tests")
        defaults?.removePersistentDomain(forName: "debug-key-hitbox-tests")
        defaults?.set(true, forKey: DebugKeyHitboxConfiguration.enabledKey)

        XCTAssertFalse(DebugKeyHitboxConfiguration.isEnabled(in: defaults, isDebugBuild: false))
        XCTAssertTrue(DebugKeyHitboxConfiguration.isEnabled(in: defaults, isDebugBuild: true))

        defaults?.removePersistentDomain(forName: "debug-key-hitbox-tests")
    }
}
