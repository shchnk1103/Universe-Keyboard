import Foundation
import XCTest

@testable import Universe_Keyboard

final class DiagnosticsJournalRetentionSchedulerTests: XCTestCase {
    func testSchedulerCoalescesRequestsInsideMinimumInterval() async {
        let recorder = ReclaimRecorder()
        let scheduler = DiagnosticsJournalRetentionScheduler(
            policy: .init(minimumInterval: 60),
            reclaim: { _ in await recorder.recordRun() }
        )
        let rootURL = URL(fileURLWithPath: "/diagnostics-test-root", isDirectory: true)
        let start = Date(timeIntervalSince1970: 1_000)

        let firstStarted = await scheduler.requestReclaim(rootURL: rootURL, now: start)
        await recorder.waitForRunCount(1)
        let duplicateStarted = await scheduler.requestReclaim(
            rootURL: rootURL,
            now: start.addingTimeInterval(30)
        )
        let laterStarted = await requestUntilAccepted(
            scheduler: scheduler,
            rootURL: rootURL,
            now: start.addingTimeInterval(60)
        )

        XCTAssertTrue(firstStarted)
        XCTAssertFalse(duplicateStarted)
        XCTAssertTrue(laterStarted)
        if laterStarted {
            await recorder.waitForRunCount(2)
            let runCount = await recorder.runCount
            XCTAssertEqual(runCount, 2)
        }
    }

    func testSchedulerReturnsBeforeRunningReclaimAndCoalescesConcurrentRequests() async {
        let gate = ReclaimGate()
        let scheduler = DiagnosticsJournalRetentionScheduler(
            policy: .init(minimumInterval: 60),
            reclaim: { _ in await gate.beginAndWait() }
        )
        let rootURL = URL(fileURLWithPath: "/diagnostics-test-root", isDirectory: true)
        let start = Date(timeIntervalSince1970: 1_000)

        let firstStarted = await scheduler.requestReclaim(rootURL: rootURL, now: start)
        await gate.waitUntilStarted(run: 1)
        let duplicateStarted = await scheduler.requestReclaim(
            rootURL: rootURL,
            now: start.addingTimeInterval(61)
        )

        XCTAssertTrue(firstStarted)
        XCTAssertFalse(duplicateStarted)

        await gate.release()
        await gate.waitUntilFinished(run: 1)
        let laterStarted = await requestUntilAccepted(
            scheduler: scheduler,
            rootURL: rootURL,
            now: start.addingTimeInterval(61)
        )
        XCTAssertTrue(laterStarted)
        if laterStarted {
            await gate.waitUntilStarted(run: 2)
            await gate.release()
            await gate.waitUntilFinished(run: 2)
        }
    }

    private func requestUntilAccepted(
        scheduler: DiagnosticsJournalRetentionScheduler,
        rootURL: URL,
        now: Date
    ) async -> Bool {
        let clock = ContinuousClock()
        let deadline = clock.now.advanced(by: .seconds(1))

        while clock.now < deadline {
            if await scheduler.requestReclaim(rootURL: rootURL, now: now) {
                return true
            }
            // 等待调度器在自己的 actor 上完成状态复位，避免用固定 yield 次数
            // 假设执行器会在特定轮次内获得运行机会。
            try? await Task.sleep(for: .milliseconds(1))
        }
        return false
    }
}

private actor ReclaimRecorder {
    private(set) var runCount = 0

    func recordRun() {
        runCount += 1
    }

    func waitForRunCount(_ expected: Int) async {
        while runCount < expected {
            await Task.yield()
        }
    }
}

private actor ReclaimGate {
    private var startedRunCount = 0
    private var finishedRunCount = 0
    private var continuation: CheckedContinuation<Void, Never>?

    func beginAndWait() async {
        startedRunCount += 1
        await withCheckedContinuation { continuation in
            self.continuation = continuation
        }
        finishedRunCount += 1
    }

    func waitUntilStarted(run expected: Int) async {
        while startedRunCount < expected {
            await Task.yield()
        }
    }

    func waitUntilFinished(run expected: Int) async {
        while finishedRunCount < expected {
            await Task.yield()
        }
    }

    func release() {
        continuation?.resume()
        continuation = nil
    }
}
