import XCTest

@testable import Universe_Keyboard

final class RimeAutomaticSyncPolicyTests: XCTestCase {
    func testDailyCadenceIsDueAfterOneDay() {
        let start = Date(timeIntervalSince1970: 1_000)

        XCTAssertFalse(
            RimeAutomaticSyncPolicy.isDue(
                lastAutomaticAttempt: start,
                cadence: .daily,
                now: start.addingTimeInterval(.init(23 * 60 * 60))
            )
        )
        XCTAssertTrue(
            RimeAutomaticSyncPolicy.isDue(
                lastAutomaticAttempt: start,
                cadence: .daily,
                now: start.addingTimeInterval(.init(24 * 60 * 60))
            )
        )
    }

    func testWeeklyCadenceIsDueAfterSevenDays() {
        let start = Date(timeIntervalSince1970: 1_000)

        XCTAssertFalse(
            RimeAutomaticSyncPolicy.isDue(
                lastAutomaticAttempt: start,
                cadence: .weekly,
                now: start.addingTimeInterval(.init(6 * 24 * 60 * 60))
            )
        )
        XCTAssertTrue(
            RimeAutomaticSyncPolicy.isDue(
                lastAutomaticAttempt: start,
                cadence: .weekly,
                now: start.addingTimeInterval(.init(7 * 24 * 60 * 60))
            )
        )
    }

    func testFirstAutomaticSyncHasNoCooldown() {
        XCTAssertTrue(
            RimeAutomaticSyncPolicy.isDue(
                lastAutomaticAttempt: nil,
                cadence: .weekly
            )
        )
    }

    func testNextEligibleDateUsesChosenCadence() {
        let start = Date(timeIntervalSince1970: 1_000)

        XCTAssertEqual(
            RimeAutomaticSyncPolicy.nextEligibleDate(
                lastAutomaticAttempt: start,
                cadence: .weekly
            ),
            start.addingTimeInterval(.init(7 * 24 * 60 * 60))
        )
    }
}
