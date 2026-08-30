import Synchronization
import XCTest

@testable import Universe_Keyboard

final class RimeAutomaticSyncPolicyTests: XCTestCase {
    @MainActor
    func testLaunchHandlerQueueMatchesMainActorIsolation() {
        XCTAssertIdentical(RimeAutomaticSyncScheduler.launchHandlerQueue, DispatchQueue.main)
    }

    func testLifecycleCompletesOnlyOnceAfterSuccessfulOperation() {
        let lifecycle = RimeAutomaticSyncTaskLifecycle()

        XCTAssertEqual(lifecycle.claimOperationCompletion(operationSucceeded: true), .succeeded)
        XCTAssertNil(lifecycle.claimOperationCompletion(operationSucceeded: false))
        XCTAssertFalse(lifecycle.claimExpiration())
    }

    func testLifecycleReportsExpirationAsFailureAndCompletesOnlyOnce() {
        let lifecycle = RimeAutomaticSyncTaskLifecycle()

        XCTAssertTrue(lifecycle.claimExpiration())
        XCTAssertFalse(lifecycle.claimExpiration())
        XCTAssertNil(lifecycle.claimOperationCompletion(operationSucceeded: true))
        XCTAssertNil(lifecycle.claimOperationCompletion(operationSucceeded: false))
    }

    func testConcurrentExpirationAndOperationReturnHaveExactlyOneTerminalOwner() {
        for _ in 0..<200 {
            let lifecycle = RimeAutomaticSyncTaskLifecycle()
            let claims = Mutex(0)

            DispatchQueue.concurrentPerform(iterations: 2) { index in
                let didClaim: Bool
                if index == 0 {
                    didClaim = lifecycle.claimExpiration()
                } else {
                    didClaim = lifecycle.claimOperationCompletion(operationSucceeded: true) != nil
                }
                if didClaim {
                    claims.withLock { $0 += 1 }
                }
            }

            XCTAssertEqual(claims.withLock { $0 }, 1)
        }
    }

    @MainActor
    func testExpirationSeamCompletesImmediatelyAndSuppressesLateSuccess() async {
        let lifecycle = RimeAutomaticSyncTaskLifecycle()
        var cancellationCount = 0
        var taskCompletions: [Bool] = []
        var notificationCount = 0
        var rescheduleCount = 0

        XCTAssertTrue(
            RimeAutomaticSyncScheduler.expireOperation(
                lifecycle: lifecycle,
                cancel: { cancellationCount += 1 },
                completeTask: { taskCompletions.append($0) }
            )
        )
        let lateOperationDidFinish = await RimeAutomaticSyncScheduler.finishOperation(
            result: .completed(Date()),
            lifecycle: lifecycle,
            notifyCompletion: { notificationCount += 1 },
            reschedule: { rescheduleCount += 1 },
            completeTask: { taskCompletions.append($0) }
        )
        XCTAssertFalse(lateOperationDidFinish)

        XCTAssertEqual(cancellationCount, 1)
        XCTAssertEqual(taskCompletions, [false])
        XCTAssertEqual(notificationCount, 0)
        XCTAssertEqual(rescheduleCount, 0)
    }

    @MainActor
    func testSuccessfulOperationSeamCompletesAndNotifiesOnlyOnce() async {
        let lifecycle = RimeAutomaticSyncTaskLifecycle()
        var taskCompletions: [Bool] = []
        var notificationCount = 0
        var rescheduleCount = 0

        let firstOperationDidFinish = await RimeAutomaticSyncScheduler.finishOperation(
            result: .completed(Date()),
            lifecycle: lifecycle,
            notifyCompletion: { notificationCount += 1 },
            reschedule: { rescheduleCount += 1 },
            completeTask: { taskCompletions.append($0) }
        )
        let repeatedOperationDidFinish = await RimeAutomaticSyncScheduler.finishOperation(
            result: .completed(Date()),
            lifecycle: lifecycle,
            notifyCompletion: { notificationCount += 1 },
            reschedule: { rescheduleCount += 1 },
            completeTask: { taskCompletions.append($0) }
        )
        XCTAssertTrue(firstOperationDidFinish)
        XCTAssertFalse(repeatedOperationDidFinish)

        XCTAssertEqual(taskCompletions, [true])
        XCTAssertEqual(notificationCount, 1)
        XCTAssertEqual(rescheduleCount, 1)
    }

    @MainActor
    func testSuccessfulSkipCompletesTaskWithoutCompletionNotification() async {
        let lifecycle = RimeAutomaticSyncTaskLifecycle()
        var taskCompletions: [Bool] = []
        var notificationCount = 0

        let didFinish = await RimeAutomaticSyncScheduler.finishOperation(
            result: .skipped(.coolingDown),
            lifecycle: lifecycle,
            notifyCompletion: { notificationCount += 1 },
            reschedule: {},
            completeTask: { taskCompletions.append($0) }
        )

        XCTAssertTrue(didFinish)
        XCTAssertEqual(taskCompletions, [true])
        XCTAssertEqual(notificationCount, 0)
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
