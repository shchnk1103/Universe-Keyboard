import Foundation
import Synchronization
import XCTest

@testable import KeyboardCore

final class DiagnosticsJournalRuntimeTests: XCTestCase {
    func testResumeWritesContentFreeSuspendedDropHealthEvent() async throws {
        let rootURL = makeTemporaryDirectory()
        defer { cleanupJournalRoot(rootURL) }
        let rootWriter = DiagnosticsJournalWriter(
            rootURL: rootURL,
            origin: .mainApp,
            isMainAppWriter: true
        )
        try await rootWriter.prepareRootIfOwnedByMainApp()

        let runtime = DiagnosticsJournalRuntime(
            origin: .keyboardExtension,
            isMainAppWriter: false,
            rootURL: { rootURL },
            isCategoryEnabled: { _ in true },
            flushDelay: 5
        )
        runtime.suspendForExtensionLifecycle()
        runtime.record(code: .presentationAppeared, category: .display)
        runtime.resumeForExtensionLifecycle()
        runtime.requestFlush()

        let snapshot = try await waitForEvent(runtime: runtime, at: rootURL)
        XCTAssertEqual(snapshot.events.map(\.code), [.journalResumed])
        XCTAssertTrue(
            snapshot.events[0].fields.contains(.count(.droppedEventCount, 1))
        )
        XCTAssertTrue(snapshot.events[0].fields.contains(.reason(.suspended)))
    }

    func testSchemeDeliveryPayloadUsesSameBoundedAsynchronousIngress() async throws {
        let rootURL = makeTemporaryDirectory()
        defer { cleanupJournalRoot(rootURL) }
        let writer = DiagnosticsJournalWriter(
            rootURL: rootURL,
            origin: .mainApp,
            isMainAppWriter: true
        )
        try await writer.prepareRootIfOwnedByMainApp()
        let runtime = DiagnosticsJournalRuntime(
            origin: .mainApp,
            isMainAppWriter: true,
            rootURL: { rootURL },
            isCategoryEnabled: { _ in true },
            flushDelay: 5
        )
        let context = DiagnosticEvent.SchemeDeliveryContext(
            operationID: UUID(),
            artifact: .wanxiang1759CNB9BFCGitHub73F8,
            stagedIdentity: .wanxiang1759Plan1Post1
        )

        let payload = DiagnosticEvent.SchemeDeliveryPayload.terminal(
            .init(context: context, result: .completed)
        )
        XCTAssertEqual(payload.code, .schemeDeliveryTerminal)
        runtime.recordSchemeDelivery(payload)
        runtime.requestFlush()

        let snapshot = try await waitForEvent(runtime: runtime, at: rootURL)
        XCTAssertEqual(snapshot.events.map(\.code), [.schemeDeliveryTerminal])
        XCTAssertEqual(
            snapshot.events.first?.schemeDeliveryPayload,
            .terminal(.init(context: context, result: .completed))
        )
    }

    func testRimeSyncPayloadUsesSameBoundedAsynchronousIngress() async throws {
        let rootURL = makeTemporaryDirectory()
        defer { cleanupJournalRoot(rootURL) }
        let writer = DiagnosticsJournalWriter(
            rootURL: rootURL,
            origin: .mainApp,
            isMainAppWriter: true
        )
        try await writer.prepareRootIfOwnedByMainApp()
        let runtime = DiagnosticsJournalRuntime(
            origin: .mainApp,
            isMainAppWriter: true,
            rootURL: { rootURL },
            isCategoryEnabled: { _ in true },
            flushDelay: 5
        )
        let context = DiagnosticEvent.RimeSyncContext(
            operationID: UUID(),
            source: .backgroundAutomatic
        )
        let payload = DiagnosticEvent.RimeSyncPayload.terminal(
            .init(context: context, result: .completed)
        )

        runtime.recordRimeSync(payload)
        runtime.requestFlush()

        let snapshot = try await waitForEvent(runtime: runtime, at: rootURL)
        XCTAssertEqual(snapshot.events.map(\.code), [.rimeSyncTerminal])
        XCTAssertEqual(snapshot.events.first?.rimeSyncPayload, payload)
    }

    func testRuntimeRoutePayloadUsesSameBoundedAsynchronousIngress() async throws {
        let rootURL = makeTemporaryDirectory()
        defer { cleanupJournalRoot(rootURL) }
        let writer = DiagnosticsJournalWriter(rootURL: rootURL, origin: .mainApp, isMainAppWriter: true)
        try await writer.prepareRootIfOwnedByMainApp()
        let runtime = DiagnosticsJournalRuntime(
            origin: .mainApp, isMainAppWriter: true, rootURL: { rootURL },
            isCategoryEnabled: { _ in true }, flushDelay: 5
        )
        let payload = DiagnosticEvent.RuntimeRoutePhaseEvent(
            operationID: UUID(), phase: .fallbackDeploy, result: .succeeded,
            schema: .lunaPinyin, layout: .twentySixKey, state: .ready,
            elapsedMilliseconds: 37
        )
        runtime.recordRuntimeRoute(payload)
        runtime.requestFlush()

        let snapshot = try await waitForEvent(runtime: runtime, at: rootURL)
        XCTAssertEqual(snapshot.events.map(\.code), [.runtimeRoutePhaseChanged])
        XCTAssertEqual(snapshot.events.first?.runtimeRoutePayload, payload)
    }

    func testTypoRecallQueryMeasurementUsesTheExistingBoundedAsyncIngress() async throws {
        let rootURL = makeTemporaryDirectory()
        defer { cleanupJournalRoot(rootURL) }
        let writer = DiagnosticsJournalWriter(
            rootURL: rootURL,
            origin: .mainApp,
            isMainAppWriter: true
        )
        try await writer.prepareRootIfOwnedByMainApp()
        let runtime = DiagnosticsJournalRuntime(
            origin: .keyboardExtension,
            isMainAppWriter: false,
            rootURL: { rootURL },
            isCategoryEnabled: { _ in true },
            flushDelay: 5
        )
        let payload = DiagnosticEvent.TypoRecallQueryPayload(
            operationOrdinal: 3,
            stage: .stageTwo,
            readiness: .ready,
            resultState: .candidatesReturned,
            returnedCandidateBucket: .zero,
            disposition: .discardedAfterFacade,
            facadeElapsedMicroseconds: 7,
            durationState: .measured
        )

        runtime.record(
            code: .typoRecallQueryMeasured,
            category: .performance,
            fields: [.typoRecallQuery(payload)]
        )
        runtime.requestFlush()

        let snapshot = try await waitForEvent(runtime: runtime, at: rootURL)
        XCTAssertEqual(snapshot.events.map(\.code), [.typoRecallQueryMeasured])
        XCTAssertEqual(snapshot.events.first?.fields, [.typoRecallQuery(payload)])
    }

    private func makeTemporaryDirectory() -> URL {
        let directory = journalTemporaryBase().appendingPathComponent(UUID().uuidString)
        try! FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        return directory
    }

    private func waitForEvent(
        runtime: DiagnosticsJournalRuntime,
        at rootURL: URL
    ) async throws -> DiagnosticsJournalSnapshot {
        let reader = DiagnosticsJournalReader(rootURL: rootURL)
        #if DEBUG
            // 原来的 helper 会吞掉读取错误再轮询。这里改为直接抛出，失败不会被藏掉。
            let started = DispatchTime.now()
            return try await flushBarrierValue(milliseconds: 1000, rootURL: rootURL) { stage in
                await runtime.flushAndWaitForTesting()
                stage.markBarrierReturned()
                stage.markReadStarted()
                let snapshot = try await reader.latest()
                if snapshot.events.isEmpty {
                    throw JournalObservationMismatch(
                        stage: "read-after-barrier",
                        barrierReturned: true,
                        elapsedMilliseconds: flushBarrierElapsedMilliseconds(since: started),
                        eventCount: 0
                    )
                }
                return snapshot
            }
        #else
            for _ in 0..<50 {
                if let snapshot = try? await reader.latest(), !snapshot.events.isEmpty {
                    return snapshot
                }
                try await Task.sleep(for: .milliseconds(20))
            }
            XCTFail("Timed out waiting for journal health event")
            return DiagnosticsJournalSnapshot(generation: 0, events: [])
        #endif
    }

    func testFlushBarrierTimeoutReportsActualBarrierStageWithoutWaiting() async throws {
        try await proveFlushBarrierTimeoutReportsBarrierStage()
    }

    func testFlushBarrierTimeoutDuringReadReportsReadStage() async throws {
        try await proveFlushBarrierTimeoutReportsReadStage()
    }
}

private struct FlushBarrierBudgetExceeded: Error, CustomStringConvertible {
    let stage: String
    let barrierReturned: Bool
    let readStarted: Bool
    let elapsedMilliseconds: Int
    let retainedDirectory: String?

    var description: String {
        "stage=\(stage) barrierReturned=\(barrierReturned) readStarted=\(readStarted) elapsedMilliseconds=\(elapsedMilliseconds) eventCount=unavailable retainedDirectory=\(retainedDirectory ?? "none")"
    }
}
private struct JournalObservationMismatch: Error, CustomStringConvertible {
    let stage: String
    let barrierReturned: Bool
    let elapsedMilliseconds: Int
    let eventCount: Int
    var description: String {
        "stage=\(stage) barrierReturned=\(barrierReturned) elapsedMilliseconds=\(elapsedMilliseconds) eventCount=\(eventCount)"
    }
}

/// 调度余量只吸收 actor 跳转和机器负载，不改变调用方传入的截止预算。
/// body 在计时断言之后才被释放。helper 若仍等待 body，断言不会执行。
private let flushBarrierSchedulingSlackMilliseconds = 1000

private func flushBarrierElapsedMilliseconds(since start: DispatchTime) -> Int {
    Int((DispatchTime.now().uptimeNanoseconds - start.uptimeNanoseconds) / 1_000_000)
}

/// body 在返回前写下真实阶段。超时错误读这份状态，不写死屏障结果或预算。
private struct FlushBarrierStageState: Sendable {
    var barrierReturned = false
    var readStarted = false
}

private final class FlushBarrierStageBox: Sendable {
    private let state = Mutex(FlushBarrierStageState())

    func markBarrierReturned() {
        state.withLock { $0.barrierReturned = true }
    }

    func markReadStarted() {
        state.withLock { $0.readStarted = true }
    }

    func snapshot() -> (barrierReturned: Bool, readStarted: Bool) {
        state.withLock { ($0.barrierReturned, $0.readStarted) }
    }
}

private struct FlushBarrierStageReporter: Sendable {
    fileprivate let box: FlushBarrierStageBox

    func markBarrierReturned() {
        box.markBarrierReturned()
    }

    func markReadStarted() {
        box.markReadStarted()
    }
}

/// 墙钟截止不依赖 body 协作。结果槽先到先得。
/// 超时一方胜出后立即抛错返回，并取消 body，但不等待它结束。
/// 放弃的代价：失败路径上可能残留一个已取消、仍停在不可取消操作上的任务。
/// 这只发生在这次等待已经失败之后，不能挡住调用方。测试要在断言后释放自己的信号。
private actor FlushBarrierOneShot<T: Sendable> {
    private var continuation: CheckedContinuation<Result<T, Error>, Never>?
    private var value: Result<T, Error>?

    func store(_ continuation: CheckedContinuation<Result<T, Error>, Never>) {
        if let value {
            continuation.resume(returning: value)
        } else {
            self.continuation = continuation
        }
    }

    func finish(_ value: Result<T, Error>) {
        guard self.value == nil else { return }
        self.value = value
        continuation?.resume(returning: value)
        continuation = nil
    }
}

private func flushBarrierValue<T: Sendable>(
    milliseconds: Int,
    rootURL: URL? = nil,
    _ body: @escaping @Sendable (FlushBarrierStageReporter) async throws -> T
) async throws -> T {
    let started = DispatchTime.now()
    let stage = FlushBarrierStageBox()
    let reporter = FlushBarrierStageReporter(box: stage)
    let shot = FlushBarrierOneShot<T>()
    let bodyTask = Task {
        do {
            let value = try await body(reporter)
            await shot.finish(.success(value))
        } catch {
            await shot.finish(.failure(error))
        }
    }
    let sleepTask = Task {
        do {
            try await Task.sleep(for: .milliseconds(milliseconds))
        } catch {
            // 调用方已经拿到结果后会取消睡眠。被取消时不能再写一个超时。
            return
        }
        let snapshot = stage.snapshot()
        let failureStage: String
        if snapshot.readStarted {
            failureStage = "read-timeout"
        } else if snapshot.barrierReturned {
            failureStage = "post-barrier-timeout"
        } else {
            failureStage = "barrier-timeout"
        }
        await shot.finish(
            .failure(
                FlushBarrierBudgetExceeded(
                    stage: failureStage,
                    barrierReturned: snapshot.barrierReturned,
                    readStarted: snapshot.readStarted,
                    elapsedMilliseconds: flushBarrierElapsedMilliseconds(since: started),
                    retainedDirectory: rootURL?.path
                )
            )
        )
    }
    let outcome: Result<T, Error> = await withTaskCancellationHandler {
        await withCheckedContinuation { continuation in
            Task { await shot.store(continuation) }
        }
    } onCancel: {
        retainAbandonedJournalRoot(rootURL)
        bodyTask.cancel()
    }
    if case .failure(let error) = outcome, error is FlushBarrierBudgetExceeded {
        retainAbandonedJournalRoot(rootURL)
    }
    bodyTask.cancel()
    sleepTask.cancel()
    return try outcome.get()
}

/// 不观察取消。用来证明截止不取决于 body 自己退出。
private actor UncancellableHold {
    private var continuation: CheckedContinuation<Void, Never>?
    private var released = false

    var isWaiting: Bool {
        continuation != nil
    }

    func wait() async {
        if released { return }
        await withCheckedContinuation { continuation in
            Task { self.store(continuation) }
        }
    }

    func release() {
        released = true
        continuation?.resume()
        continuation = nil
    }

    private func store(_ continuation: CheckedContinuation<Void, Never>) {
        if released {
            continuation.resume()
        } else {
            self.continuation = continuation
        }
    }
}

private func proveFlushBarrierTimeoutReportsBarrierStage() async throws {
    let hold = UncancellableHold()
    let started = DispatchTime.now()
    do {
        _ = try await flushBarrierValue(milliseconds: 1000) { _ in
            await hold.wait()
            return 0
        }
        XCTFail("an uncancellable barrier must fail inside the existing 1000ms budget")
    } catch let error as FlushBarrierBudgetExceeded {
        let wall = flushBarrierElapsedMilliseconds(since: started)
        XCTAssertEqual(error.stage, "barrier-timeout")
        XCTAssertFalse(error.barrierReturned)
        XCTAssertFalse(error.readStarted)
        XCTAssertGreaterThanOrEqual(error.elapsedMilliseconds, 1000)
        XCTAssertGreaterThanOrEqual(wall, 1000)
        XCTAssertLessThan(wall, 1000 + flushBarrierSchedulingSlackMilliseconds)
        XCTAssertGreaterThanOrEqual(wall, error.elapsedMilliseconds)
    } catch {
        XCTFail("unexpected error \(error)")
    }
    let waiting = await hold.isWaiting
    XCTAssertTrue(waiting)
    await hold.release()
}

private func proveFlushBarrierTimeoutReportsReadStage() async throws {
    let hold = UncancellableHold()
    let started = DispatchTime.now()
    do {
        _ = try await flushBarrierValue(milliseconds: 1000) { stage in
            stage.markBarrierReturned()
            stage.markReadStarted()
            await hold.wait()
            return 0
        }
        XCTFail("a read that ignores cancellation must fail inside the existing 1000ms budget")
    } catch let error as FlushBarrierBudgetExceeded {
        let wall = flushBarrierElapsedMilliseconds(since: started)
        XCTAssertEqual(error.stage, "read-timeout")
        XCTAssertTrue(error.barrierReturned)
        XCTAssertTrue(error.readStarted)
        XCTAssertGreaterThanOrEqual(error.elapsedMilliseconds, 1000)
        XCTAssertGreaterThanOrEqual(wall, 1000)
        XCTAssertLessThan(wall, 1000 + flushBarrierSchedulingSlackMilliseconds)
        XCTAssertGreaterThanOrEqual(wall, error.elapsedMilliseconds)
    } catch {
        XCTFail("unexpected error \(error)")
    }
    let waiting = await hold.isWaiting
    XCTAssertTrue(waiting)
    await hold.release()
}

/// 截止或取消后，未响应取消的 body 可能仍访问目录；保留目录供人工清理。
nonisolated private let abandonedJournalRoots = Mutex<Set<String>>([])

nonisolated private func retainAbandonedJournalRoot(_ root: URL?) {
    guard let root else { return }
    abandonedJournalRoots.withLock { _ = $0.insert(root.path) }
}

private func cleanupJournalRoot(_ root: URL) {
    if abandonedJournalRoots.withLock({ $0.contains(root.path) }) {
        print("保留可能仍在使用的测试目录：\(root.path)")
        return
    }
    guard FileManager.default.fileExists(atPath: root.path) else { return }
    do {
        try FileManager.default.removeItem(at: root)
    } catch {
        XCTFail("清理测试目录失败：\(root.path)，\(error)")
    }
}

/// 可由测试运行器指定夹具根目录；普通本地测试沿用系统临时目录。
nonisolated private func journalTemporaryBase() -> URL {
    if let path = ProcessInfo.processInfo.environment["DIAG_FLUSH_TEST_ROOT"], !path.isEmpty {
        return URL(fileURLWithPath: path, isDirectory: true)
    }
    return FileManager.default.temporaryDirectory
}
