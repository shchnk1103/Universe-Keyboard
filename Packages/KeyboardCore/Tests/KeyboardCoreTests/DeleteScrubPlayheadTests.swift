import XCTest

@testable import KeyboardCore

final class DeleteScrubPlayheadTests: XCTestCase {
    func testLockRequiresTenPoints() {
        let playhead = DeleteScrubPlayhead(originX: 100)
        XCTAssertFalse(playhead.isHorizontallyLocked(at: 91))
        XCTAssertTrue(playhead.isHorizontallyLocked(at: 90))
        XCTAssertTrue(playhead.isLeftwardLocked(at: 90))
        XCTAssertFalse(playhead.isLeftwardLocked(at: 110))
    }

    func testLeftwardDisplacementMapsToUnitsNotSpeed() {
        var playhead = DeleteScrubPlayhead(originX: 100)
        XCTAssertEqual(playhead.targetUnits(at: 95), 0)
        XCTAssertEqual(playhead.targetUnits(at: 90), 1)
        XCTAssertEqual(playhead.targetUnits(at: 80), 2)
        XCTAssertEqual(playhead.targetUnits(at: 120), 0)
        playhead.setAppliedUnits(2)
        XCTAssertEqual(playhead.appliedUnits, 2)
    }

    func testLedgerCapBoundsTargetUnits() {
        let playhead = DeleteScrubPlayhead(originX: 10_000)
        XCTAssertEqual(
            playhead.targetUnits(at: 0),
            DeleteScrubPlayhead.ledgerCap
        )
    }
}
