import XCTest

@testable import Universe_Keyboard

final class RimeAutomaticSyncPolicyTests: XCTestCase {
    @MainActor
    func testLaunchHandlerQueueMatchesMainActorIsolation() {
        XCTAssertIdentical(RimeAutomaticSyncScheduler.launchHandlerQueue, DispatchQueue.main)
    }

    @MainActor
    func testLifecycleCompletesOnlyOnceAfterSuccessfulOperation() {
        let lifecycle = RimeAutomaticSyncTaskLifecycle()
        var completions: [Bool] = []

        XCTAssertTrue(
            lifecycle.finish(operationSucceeded: true) { completions.append($0) }
        )
        XCTAssertFalse(
            lifecycle.finish(operationSucceeded: false) { completions.append($0) }
        )
        XCTAssertFalse(
            lifecycle.requestExpiration(cancel: { XCTFail("Completed work must not be cancelled") })
        )
        XCTAssertEqual(completions, [true])
    }

    @MainActor
    func testLifecycleReportsExpirationAsFailureAndCompletesOnlyOnce() {
        let lifecycle = RimeAutomaticSyncTaskLifecycle()
        var cancellationCount = 0
        var completions: [Bool] = []

        XCTAssertTrue(lifecycle.requestExpiration(cancel: { cancellationCount += 1 }))
        XCTAssertFalse(lifecycle.requestExpiration(cancel: { cancellationCount += 1 }))
        XCTAssertTrue(
            lifecycle.finish(operationSucceeded: true) { completions.append($0) }
        )
        XCTAssertFalse(
            lifecycle.finish(operationSucceeded: false) { completions.append($0) }
        )

        XCTAssertEqual(cancellationCount, 1)
        XCTAssertEqual(completions, [false])
    }

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

    func testKeyboardActiveRetryDefersAnOtherwisePastEligibleDate() {
        let lastAttempt = Date(timeIntervalSince1970: 1_000)
        let retryNotBefore = Date(timeIntervalSince1970: 10_000)

        XCTAssertEqual(
            RimeAutomaticSyncPolicy.nextEligibleDate(
                lastAutomaticAttempt: lastAttempt,
                cadence: .daily,
                retryNotBefore: retryNotBefore
            ),
            lastAttempt.addingTimeInterval(RimeAutomaticSyncCadence.daily.interval)
        )

        let pastAttempt = retryNotBefore.addingTimeInterval(
            -RimeAutomaticSyncCadence.daily.interval - 1
        )
        XCTAssertEqual(
            RimeAutomaticSyncPolicy.nextEligibleDate(
                lastAutomaticAttempt: pastAttempt,
                cadence: .daily,
                retryNotBefore: retryNotBefore
            ),
            retryNotBefore
        )
    }
}
