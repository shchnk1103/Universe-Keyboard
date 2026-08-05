import XCTest
@testable import KeyboardCore

final class ResponsiveRimeFeltMetricsTests: XCTestCase {

    func testMarkerLinesAreContentFree() {
        let accept = ResponsiveRimeFeltMetrics.acceptMarkerLine(
            revision: 3,
            epoch: 1,
            pending: 2
        )
        XCTAssertTrue(accept.contains("T9RESP marker=ACCEPT"))
        XCTAssertTrue(accept.contains("rev=3"))
        XCTAssertTrue(accept.contains("pending=2"))
        XCTAssertFalse(accept.contains("ni"))
        XCTAssertFalse(accept.contains("你"))

        let visible = ResponsiveRimeFeltMetrics.visibleMarkerLine(
            lagMs: 12,
            revision: 3,
            source: .engine
        )
        XCTAssertTrue(visible.contains("VISIBLE"))
        XCTAssertTrue(visible.contains("lagMs=12"))
        XCTAssertTrue(visible.contains("source=engine"))

        let paint = ResponsiveRimeFeltMetrics.presentationLagMarkerLine(
            lagMs: 40,
            revision: 5,
            pendingAfter: 0,
            coalesced: true
        )
        XCTAssertTrue(paint.contains("PAINT schema=v1"))
        XCTAssertTrue(paint.contains("lagMs=40"))
        XCTAssertTrue(paint.contains("coalesced=1"))

        let burst = ResponsiveRimeFeltMetrics.burstMarkerLine(count: 4, windowMs: 50)
        XCTAssertTrue(burst.contains("BURST schema=v1"))
        XCTAssertTrue(burst.contains("count=4"))
    }

    func testLagMillisecondsClampsAndScales() {
        XCTAssertEqual(
            ResponsiveRimeFeltMetrics.lagMilliseconds(fromAcceptUptime: 1_000_000, nowNs: 3_000_000),
            2
        )
        XCTAssertEqual(
            ResponsiveRimeFeltMetrics.lagMilliseconds(fromAcceptUptime: 5, nowNs: 1),
            0
        )
    }

    @MainActor
    func testTrackerAcceptVisiblePublishAndBurst() {
        let tracker = ResponsiveRimeFeltMetricsTracker()
        tracker.reset()
        let t0: UInt64 = 1_000_000_000
        _ = tracker.recordAccept(revision: 1, epoch: 1, pending: 1, uptimeNs: t0)
        _ = tracker.recordAccept(revision: 2, epoch: 1, pending: 2, uptimeNs: t0 + 1_000_000)
        let visible = tracker.recordVisible(
            revision: 2,
            source: .engine,
            uptimeNs: t0 + 10_000_000
        )
        XCTAssertNotNil(visible)
        XCTAssertTrue(visible!.contains("lagMs=9") || visible!.contains("lagMs=10"))

        let ownerCompletion = tracker.recordOwnerCompletion(epoch: 1, revision: 1)
        XCTAssertTrue(ownerCompletion?.contains("PUBLISH schema=v1") == true)
        XCTAssertTrue(ownerCompletion?.contains("epoch=1 rev=1") == true)
        XCTAssertNil(
            tracker.recordOwnerCompletion(epoch: 1, revision: 1),
            "duplicate delivery must not emit a second owner-completion marker"
        )

        var burstSeen = false
        for i in 0..<3 {
            let result = tracker.recordPresentation(
                revision: UInt64(i + 1),
                pendingAfter: 0,
                coalesced: i > 0,
                uptimeNs: t0 + UInt64(i) * 1_000_000
            )
            XCTAssertTrue(result.presentationLine.contains("PAINT schema=v1"))
            if result.burstLine != nil { burstSeen = true }
        }
        XCTAssertTrue(burstSeen, "three paints inside 50ms window should emit BURST")
    }

    @MainActor
    func testOwnerCompletionRequiresMatchingAcceptedEpoch() {
        let tracker = ResponsiveRimeFeltMetricsTracker()
        tracker.reset()
        _ = tracker.recordAccept(revision: 7, epoch: 2, pending: 1, uptimeNs: 1_000_000_000)

        XCTAssertNil(tracker.recordOwnerCompletion(epoch: 1, revision: 7))
        XCTAssertNotNil(tracker.recordOwnerCompletion(epoch: 2, revision: 7))
    }

    @MainActor
    func testOwnerCompletionAllowsRevisionReuseAfterEpochChange() {
        let tracker = ResponsiveRimeFeltMetricsTracker()
        tracker.reset()
        _ = tracker.recordAccept(revision: 7, epoch: 1, pending: 1, uptimeNs: 1_000_000_000)
        XCTAssertNotNil(tracker.recordOwnerCompletion(epoch: 1, revision: 7))

        // A rebuilt session can restart its revision counter. The new epoch
        // must not inherit the old epoch's de-duplication state.
        _ = tracker.recordAccept(revision: 7, epoch: 2, pending: 1, uptimeNs: 2_000_000_000)
        XCTAssertNil(
            tracker.recordOwnerCompletion(epoch: 1, revision: 7),
            "late completion from the previous epoch must be ignored"
        )
        XCTAssertNotNil(tracker.recordOwnerCompletion(epoch: 2, revision: 7))
    }
}
