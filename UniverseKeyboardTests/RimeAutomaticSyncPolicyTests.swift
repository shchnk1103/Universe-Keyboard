import RimeBridge
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

    func testProcessGateGrantsExactlyOneConcurrentLease() {
        for _ in 0..<200 {
            let gate = RimeSyncProcessGate()
            let claimCount = Mutex(0)
            let winningLease = Mutex<RimeSyncProcessGate.Lease?>(nil)

            DispatchQueue.concurrentPerform(iterations: 2) { index in
                let source: RimeSyncProcessGate.Source =
                    index == 0 ? .foregroundAutomatic : .backgroundAutomatic
                guard let lease = gate.claim(source: source) else { return }
                claimCount.withLock { $0 += 1 }
                winningLease.withLock { $0 = lease }
            }

            XCTAssertEqual(claimCount.withLock { $0 }, 1)
            let lease = winningLease.withLock { $0 }
            XCTAssertNotNil(lease)
            if let lease {
                XCTAssertTrue(gate.release(lease))
            }
        }
    }

    func testProcessGateRejectsAStaleLeaseRelease() throws {
        let gate = RimeSyncProcessGate()
        let firstLease = try XCTUnwrap(gate.claim(source: .foregroundAutomatic))
        XCTAssertTrue(gate.release(firstLease))

        let secondLease = try XCTUnwrap(gate.claim(source: .backgroundAutomatic))
        XCTAssertFalse(gate.release(firstLease))
        XCTAssertEqual(gate.activeSource, .backgroundAutomatic)
        XCTAssertTrue(gate.release(secondLease))
        XCTAssertNil(gate.activeSource)
    }

    @MainActor
    func testOccupiedProcessGateSuppressesForegroundAndManualSyncNotifications() async throws {
        let suiteName = "RimeSyncForegroundProcessGate-\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
        let processGate = RimeSyncProcessGate()
        let backgroundLease = try XCTUnwrap(processGate.claim(source: .backgroundAutomatic))
        defer {
            processGate.release(backgroundLease)
            defaults.removePersistentDomain(forName: suiteName)
        }
        defaults.set(RimeSyncProvider.localFolder.rawValue, forKey: RimeSyncStorageKey.provider)
        defaults.set(Data([0x01]), forKey: RimeSyncStorageKey.folderBookmark)
        defaults.set(true, forKey: RimeSyncStorageKey.automaticSyncEnabled)
        defaults.set(true, forKey: RimeSyncStorageKey.automaticPrivateSettingsEnabled)

        let notifications = RecordingRimeSyncNotificationService()
        let model = RimeSyncViewModel(
            rimeStore: RimeSettingsStore(),
            defaults: defaults,
            notificationService: notifications,
            processGate: processGate,
            keyboardActivityDefaults: defaults
        )

        await model.synchronizeIfNeeded(minimumInterval: 0)
        await model.synchronizeAllNow()

        XCTAssertTrue(notifications.events.isEmpty)
        XCTAssertNil(defaults.object(forKey: RimeSyncStorageKey.lastForegroundPrivateAttempt))
        XCTAssertEqual(processGate.activeSource, .backgroundAutomatic)
    }

    @MainActor
    func testOccupiedProcessGateDefersBackgroundSyncWithoutPublishingNotifications() async throws {
        let suiteName = "RimeSyncBackgroundProcessGate-\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
        let processGate = RimeSyncProcessGate()
        let foregroundLease = try XCTUnwrap(processGate.claim(source: .foregroundAutomatic))
        defer {
            processGate.release(foregroundLease)
            defaults.removePersistentDomain(forName: suiteName)
        }
        let lastAttempt = Date().addingTimeInterval(-2 * RimeAutomaticSyncCadence.daily.interval)
        defaults.set(RimeSyncProvider.localFolder.rawValue, forKey: RimeSyncStorageKey.provider)
        defaults.set(Data([0x01]), forKey: RimeSyncStorageKey.folderBookmark)
        defaults.set(Date(), forKey: RimeSyncStorageKey.standardRimeLastSuccess)
        defaults.set(true, forKey: RimeSyncStorageKey.automaticSyncEnabled)
        defaults.set(true, forKey: RimeSyncStorageKey.automaticStandardRimeDataEnabled)
        defaults.set(true, forKey: RimeSyncStorageKey.automaticPrivateSettingsEnabled)
        defaults.set(lastAttempt, forKey: RimeSyncStorageKey.lastAutomaticAttempt)

        let notifications = RecordingRimeSyncNotificationService()
        let model = RimeSyncViewModel(
            rimeStore: RimeSettingsStore(),
            defaults: defaults,
            notificationService: notifications,
            processGate: processGate,
            keyboardActivityDefaults: defaults
        )
        let startedAt = Date()

        let result = await model.synchronizeAutomatically()

        XCTAssertEqual(result, .skipped(.alreadyRunning))
        XCTAssertTrue(notifications.events.isEmpty)
        XCTAssertEqual(
            defaults.object(forKey: RimeSyncStorageKey.lastAutomaticAttempt) as? Date,
            lastAttempt
        )
        let retryNotBefore = try XCTUnwrap(
            defaults.object(forKey: RimeSyncStorageKey.automaticRetryNotBefore) as? Date
        )
        XCTAssertGreaterThanOrEqual(
            retryNotBefore,
            startedAt.addingTimeInterval(RimeAutomaticSyncPolicy.processBusyRetryInterval)
        )
        XCTAssertLessThan(
            retryNotBefore,
            Date().addingTimeInterval(RimeAutomaticSyncPolicy.processBusyRetryInterval + 1)
        )
        XCTAssertEqual(processGate.activeSource, .foregroundAutomatic)
    }

    @MainActor
    func testBackgroundOwnerSuppressesConcurrentBackgroundAutomaticEntry() async throws {
        let ownerSuiteName = "RimeSyncBackgroundOwner-\(UUID().uuidString)"
        let contenderSuiteName = "RimeSyncBackgroundContender-\(UUID().uuidString)"
        let ownerDefaults = try XCTUnwrap(UserDefaults(suiteName: ownerSuiteName))
        let contenderDefaults = try XCTUnwrap(UserDefaults(suiteName: contenderSuiteName))
        let syncDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(
            at: syncDirectory,
            withIntermediateDirectories: true
        )
        defer {
            ownerDefaults.removePersistentDomain(forName: ownerSuiteName)
            contenderDefaults.removePersistentDomain(forName: contenderSuiteName)
            try? FileManager.default.removeItem(at: syncDirectory)
        }

        let bookmark = try syncDirectory.bookmarkData(
            options: [],
            includingResourceValuesForKeys: nil,
            relativeTo: nil
        )
        configureAutomaticSyncDefaults(ownerDefaults, bookmark: bookmark)
        configureAutomaticSyncDefaults(contenderDefaults, bookmark: bookmark)

        let processGate = RimeSyncProcessGate()
        let standardService = BlockingRimeStandardSyncService()
        let requestFactory: @MainActor @Sendable () async throws -> RimeStandardSyncRequest = {
            RimeStandardSyncRequest(
                sharedDataURL: syncDirectory,
                userDataURL: syncDirectory,
                syncDirectoryURL: syncDirectory,
                installationID: "test-device"
            )
        }
        let ownerNotifications = RecordingRimeSyncNotificationService()
        let contenderNotifications = RecordingRimeSyncNotificationService()
        let ownerModel = RimeSyncViewModel(
            rimeStore: RimeSettingsStore(),
            defaults: ownerDefaults,
            standardRimeSyncService: standardService,
            standardRimeSyncRequestFactory: requestFactory,
            notificationService: ownerNotifications,
            processGate: processGate,
            keyboardActivityDefaults: ownerDefaults
        )
        let contenderModel = RimeSyncViewModel(
            rimeStore: RimeSettingsStore(),
            defaults: contenderDefaults,
            standardRimeSyncService: standardService,
            standardRimeSyncRequestFactory: requestFactory,
            notificationService: contenderNotifications,
            processGate: processGate,
            keyboardActivityDefaults: contenderDefaults
        )

        let ownerTask = Task { @MainActor in
            await ownerModel.synchronizeAutomatically()
        }
        let standardServiceDidStart = await waitUntilStandardServiceStarts(standardService)
        XCTAssertTrue(standardServiceDidStart)
        XCTAssertEqual(processGate.activeSource, .backgroundAutomatic)

        let contenderResult = await contenderModel.synchronizeAutomatically()

        XCTAssertEqual(contenderResult, .skipped(.alreadyRunning))
        XCTAssertTrue(contenderNotifications.events.isEmpty)
        let inFlightSnapshot = await standardService.snapshot()
        XCTAssertEqual(inFlightSnapshot.callCount, 1)
        XCTAssertEqual(inFlightSnapshot.maximumConcurrentCalls, 1)

        ownerTask.cancel()
        await standardService.releaseAll()
        let ownerResult = await ownerTask.value
        XCTAssertEqual(ownerResult, .skipped(.cancelled))
        XCTAssertNil(processGate.activeSource)
        XCTAssertEqual(
            ownerNotifications.events,
            [
                .phaseStarted(
                    mode: .automatic,
                    scope: .standardRimeData,
                    completedScopes: [],
                    pendingScopes: []
                ),
                .failed(
                    mode: .automatic,
                    failedScope: .standardRimeData,
                    completedScopes: [],
                    pendingScopes: []
                ),
            ]
        )
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

    @MainActor
    func testProcessBusySkipCompletesAndReschedulesExactlyOnceWithoutNotification() async {
        let lifecycle = RimeAutomaticSyncTaskLifecycle()
        var taskCompletions: [Bool] = []
        var notificationCount = 0
        var rescheduleCount = 0

        let firstDidFinish = await RimeAutomaticSyncScheduler.finishOperation(
            result: .skipped(.alreadyRunning),
            lifecycle: lifecycle,
            notifyCompletion: { notificationCount += 1 },
            reschedule: { rescheduleCount += 1 },
            completeTask: { taskCompletions.append($0) }
        )
        let repeatedDidFinish = await RimeAutomaticSyncScheduler.finishOperation(
            result: .skipped(.alreadyRunning),
            lifecycle: lifecycle,
            notifyCompletion: { notificationCount += 1 },
            reschedule: { rescheduleCount += 1 },
            completeTask: { taskCompletions.append($0) }
        )

        XCTAssertTrue(firstDidFinish)
        XCTAssertFalse(repeatedDidFinish)
        XCTAssertEqual(taskCompletions, [true])
        XCTAssertEqual(notificationCount, 0)
        XCTAssertEqual(rescheduleCount, 1)
    }

    @MainActor
    func testFailedOperationSeamCompletesAsFailureWithoutNotification() async {
        let lifecycle = RimeAutomaticSyncTaskLifecycle()
        var taskCompletions: [Bool] = []
        var notificationCount = 0
        var rescheduleCount = 0

        let didFinish = await RimeAutomaticSyncScheduler.finishOperation(
            result: .failed,
            lifecycle: lifecycle,
            notifyCompletion: { notificationCount += 1 },
            reschedule: { rescheduleCount += 1 },
            completeTask: { taskCompletions.append($0) }
        )

        XCTAssertTrue(didFinish)
        XCTAssertEqual(taskCompletions, [false])
        XCTAssertEqual(notificationCount, 0)
        XCTAssertEqual(rescheduleCount, 1)
        XCTAssertFalse(lifecycle.claimExpiration())
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

    func testRetryFloorSchedulesWhenLastAutomaticAttemptIsMissing() {
        let now = Date(timeIntervalSince1970: 1_000)
        let retryNotBefore = Date(timeIntervalSince1970: 2_000)

        XCTAssertEqual(
            RimeAutomaticSyncPolicy.nextEligibleDate(
                lastAutomaticAttempt: nil,
                cadence: .daily,
                retryNotBefore: retryNotBefore,
                now: now
            ),
            retryNotBefore
        )
    }

    func testMissingAttemptAndRetryFloorDoesNotSchedule() {
        XCTAssertNil(
            RimeAutomaticSyncPolicy.nextEligibleDate(
                lastAutomaticAttempt: nil,
                cadence: .daily,
                retryNotBefore: nil,
                now: Date(timeIntervalSince1970: 1_000)
            )
        )
    }
}

@MainActor
private final class RecordingRimeSyncNotificationService: AppNotificationNotifying {
    private(set) var events: [RimeSyncNotificationEvent] = []

    func notify(_ event: RimeSyncNotificationEvent) async {
        events.append(event)
    }
}

private actor BlockingRimeStandardSyncService: RimeStandardSyncing {
    struct Snapshot: Sendable {
        let callCount: Int
        let maximumConcurrentCalls: Int
    }

    private var callCount = 0
    private var concurrentCalls = 0
    private var maximumConcurrentCalls = 0
    private var operationContinuations: [CheckedContinuation<Void, Never>] = []

    func synchronize(_ request: RimeStandardSyncRequest) async throws {
        _ = request
        callCount += 1
        concurrentCalls += 1
        maximumConcurrentCalls = max(maximumConcurrentCalls, concurrentCalls)
        await withCheckedContinuation { continuation in
            operationContinuations.append(continuation)
        }
        concurrentCalls -= 1
    }

    func releaseAll() {
        let continuations = operationContinuations
        operationContinuations.removeAll()
        continuations.forEach { $0.resume() }
    }

    func snapshot() -> Snapshot {
        Snapshot(
            callCount: callCount,
            maximumConcurrentCalls: maximumConcurrentCalls
        )
    }
}

@MainActor
private func configureAutomaticSyncDefaults(_ defaults: UserDefaults, bookmark: Data) {
    defaults.set(RimeSyncProvider.localFolder.rawValue, forKey: RimeSyncStorageKey.provider)
    defaults.set(bookmark, forKey: RimeSyncStorageKey.folderBookmark)
    defaults.set(Date(), forKey: RimeSyncStorageKey.standardRimeLastSuccess)
    defaults.set(true, forKey: RimeSyncStorageKey.automaticSyncEnabled)
    defaults.set(true, forKey: RimeSyncStorageKey.automaticStandardRimeDataEnabled)
    defaults.set(false, forKey: RimeSyncStorageKey.automaticPrivateSettingsEnabled)
    defaults.set(
        Date().addingTimeInterval(-2 * RimeAutomaticSyncCadence.daily.interval),
        forKey: RimeSyncStorageKey.lastAutomaticAttempt
    )
}

private func waitUntilStandardServiceStarts(
    _ service: BlockingRimeStandardSyncService,
    timeout: Duration = .seconds(5)
) async -> Bool {
    let clock = ContinuousClock()
    let deadline = clock.now.advanced(by: timeout)
    while clock.now < deadline {
        if await service.snapshot().callCount > 0 { return true }
        try? await Task.sleep(for: .milliseconds(10))
    }
    return false
}
