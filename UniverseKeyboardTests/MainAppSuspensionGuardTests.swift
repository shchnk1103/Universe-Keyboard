import KeyboardCore
import Synchronization
import UIKit
import XCTest

@testable import Universe_Keyboard

@MainActor
final class MainAppSuspensionGuardTests: XCTestCase {
    func testTokensEndIndependentlyAndExpiryMarksCancelledOnce() {
        let controller = GuardTaskController()
        let guardObject = MainAppSuspensionGuard(controller: controller)
        let first = guardObject.begin(reason: "one")
        let second = guardObject.begin(reason: "two")
        guardObject.end(try! XCTUnwrap(first))
        guardObject.end(try! XCTUnwrap(first))
        XCTAssertEqual(controller.endedIdentifiers, [1])
        XCTAssertFalse(guardObject.isCancelled(try! XCTUnwrap(second)))
        controller.fireExpiration(identifier: 2)
        controller.fireExpiration(identifier: 2)
        XCTAssertEqual(controller.endedIdentifiers, [1, 2])
        XCTAssertTrue(guardObject.isCancelled(try! XCTUnwrap(second)))
        XCTAssertFalse(guardObject.isCancelled(try! XCTUnwrap(first)))
    }

    func testBeginFailureReturnsNil() {
        let controller = GuardTaskController()
        controller.failNext = true
        let guardObject = MainAppSuspensionGuard(controller: controller)
        XCTAssertNil(guardObject.begin(reason: "missing"))
        XCTAssertEqual(controller.endedIdentifiers, [])
    }

    func testOldTokenCannotEndTheNewToken() {
        let controller = GuardTaskController()
        let guardObject = MainAppSuspensionGuard(controller: controller)
        let old = guardObject.begin(reason: "old")
        let fresh = guardObject.begin(reason: "new")
        guardObject.end(try! XCTUnwrap(old))
        XCTAssertEqual(controller.endedIdentifiers, [1])
        XCTAssertFalse(guardObject.isCancelled(try! XCTUnwrap(fresh)))
        guardObject.end(try! XCTUnwrap(fresh))
        XCTAssertEqual(controller.endedIdentifiers, [1, 2])
    }

    func testInactiveActiveInactiveEndsOnlyItsOwnToken() async {
        let controller = GuardTaskController()
        MainAppSuspensionGuard.shared.installControllerForTesting(controller)
        let lifecycle = DiagnosticsProcessLifecycle()
        DiagnosticsAppLifecycle.apply(.inactive, to: lifecycle)
        DiagnosticsAppLifecycle.apply(.active, to: lifecycle)
        DiagnosticsAppLifecycle.apply(.inactive, to: lifecycle)
        try? await Task.sleep(nanoseconds: 200_000_000)
        XCTAssertEqual(controller.reasons, ["journal-drain", "journal-drain"])
        XCTAssertEqual(controller.endedIdentifiers.count, 2)
        XCTAssertEqual(Set(controller.endedIdentifiers), Set(controller.issuedIdentifiers))
    }

    func testQueuedReclaimDoesNotStartAfterBackground() async {
        let foreground = Mutex(false)
        let started = Mutex(0)
        let scheduler = DiagnosticsJournalRetentionScheduler(
            policy: DiagnosticsJournalRetentionScheduler.Policy(minimumInterval: 15 * 60),
            reclaim: { _ in
                started.withLock { $0 += 1 }
            },
            isForegroundActive: { foreground.withLock { $0 } }
        )
        let rootURL = FileManager.default.temporaryDirectory.appendingPathComponent(
            "pf057-retention-\(UUID().uuidString)", isDirectory: true)
        let queued = await scheduler.requestReclaim(rootURL: rootURL)
        XCTAssertTrue(queued)
        try? await Task.sleep(nanoseconds: 200_000_000)
        XCTAssertEqual(started.withLock { $0 }, 0)
        foreground.withLock { $0 = true }
        let afterForeground = await scheduler.requestReclaim(rootURL: rootURL)
        XCTAssertTrue(afterForeground)
        try? await Task.sleep(nanoseconds: 200_000_000)
        XCTAssertEqual(started.withLock { $0 }, 1)
    }
}

@MainActor
private final class GuardTaskController: MainAppBackgroundTaskControlling {
    var failNext = false
    private(set) var reasons: [String] = []
    private(set) var issuedIdentifiers: [Int] = []
    private(set) var endedIdentifiers: [Int] = []
    private var handlers: [Int: () -> Void] = [:]
    private var nextID = 1

    func beginTask(name: String, expirationHandler: @escaping () -> Void) -> Int {
        reasons.append(name)
        if failNext {
            failNext = false
            return UIBackgroundTaskIdentifier.invalid.rawValue
        }
        let identifier = nextID
        nextID += 1
        issuedIdentifiers.append(identifier)
        handlers[identifier] = expirationHandler
        return identifier
    }

    func endTask(_ identifier: Int) {
        endedIdentifiers.append(identifier)
        handlers[identifier] = nil
    }

    func fireExpiration(identifier: Int) {
        handlers[identifier]?()
    }
}
