import Foundation
import Synchronization
import UIKit
import XCTest

#if DEBUG
    @testable import KeyboardCore
#else
    import KeyboardCore
#endif

@MainActor
final class KeyboardWakeDiagnosticProducerTests: XCTestCase {
    func testV6ProducerAndAdapterWriteFiniteMarkersAroundProxyCalls() async throws {
        let rootURL = makeTemporaryDirectory()
        defer { cleanupJournalRoot(rootURL) }
        let runtime = try await makeRuntime(rootURL: rootURL, writerVersion: .v6)
        let appearanceID = UUID(uuidString: "00000000-0000-0000-0000-000000000101")!
        let context = KeyboardWakeDiagnosticContext(
            appearanceID: appearanceID,
            isHighFidelityActive: true,
            expiration: Date().addingTimeInterval(3_600)
        )

        XCTAssertFalse(
            KeyboardWakeDiagnosticProducer.recordKeyboardLifecycle(
                .hostDidBecomeActive,
                journal: runtime,
                context: context
            )
        )
        XCTAssertTrue(
            KeyboardWakeDiagnosticProducer.recordKeyboardLifecycle(
                .viewWillAppear,
                journal: runtime,
                context: context
            )
        )
        XCTAssertTrue(
            KeyboardWakeDiagnosticProducer.recordKeyboardLifecycle(
                .viewDidAppear,
                journal: runtime,
                context: context
            )
        )
        XCTAssertTrue(
            KeyboardWakeDiagnosticProducer.recordKeyboardLifecycle(
                .viewWillDisappear,
                journal: runtime,
                context: context
            )
        )
        XCTAssertTrue(
            KeyboardWakeDiagnosticProducer.recordKeyboardLifecycle(
                .hostWillResignActive,
                journal: runtime,
                context: context
            )
        )
        XCTAssertTrue(
            KeyboardWakeDiagnosticProducer.recordRimeResumeStarted(
                journal: runtime,
                context: context
            )
        )

        let proxy = FakeTextDocumentProxy()
        var callOrder: [String] = []
        proxy.onOperation = { callOrder.append($0) }
        let adapter = UITextDocumentProxyAdapter(
            proxy: proxy,
            diagnosticsJournal: runtime,
            diagnosticContext: { context },
            diagnosticMarkerObserver: { operation, phase in
                callOrder.append("marker:\(operation.rawValue):\(phase.rawValue)")
            }
        )

        adapter.insertText("fixture")
        adapter.setMarkedText("a😀中", selectedRange: 1..<2)
        adapter.unmarkText()

        XCTAssertEqual(
            callOrder,
            [
                "marker:insert_text:entered",
                "proxy.insertText",
                "marker:insert_text:returned",
                "marker:set_marked_text:entered",
                "proxy.setMarkedText",
                "marker:set_marked_text:returned",
                "marker:unmark_text:entered",
                "proxy.unmarkText",
                "marker:unmark_text:returned",
            ]
        )
        XCTAssertEqual(
            proxy.calls,
            [
                .insertText("fixture"),
                .setMarkedText("a😀中", location: 1, length: 2),
                .unmarkText,
            ]
        )

        let snapshot = try await waitForSnapshot(
            runtime: runtime,
            at: rootURL,
            expectedEventCount: 11,
            expectedV6EventCount: 11
        )
        XCTAssertTrue(snapshot.completeness.isComplete)

        let events = snapshot.events.sorted { $0.localSequence < $1.localSequence }
        XCTAssertEqual(events.count, 11)
        XCTAssertEqual(events.map(\.localSequence), Array(UInt64(1)...UInt64(11)))
        XCTAssertEqual(
            events.map(\.code),
            [
                .keyboardLifecyclePhaseChanged,
                .keyboardLifecyclePhaseChanged,
                .keyboardLifecyclePhaseChanged,
                .keyboardLifecyclePhaseChanged,
                .rimeResumePhaseChanged,
                .textProxyOperationPhaseChanged,
                .textProxyOperationPhaseChanged,
                .textProxyOperationPhaseChanged,
                .textProxyOperationPhaseChanged,
                .textProxyOperationPhaseChanged,
                .textProxyOperationPhaseChanged,
            ]
        )

        XCTAssertEqual(
            events.compactMap { $0.keyboardLifecyclePayload?.phase },
            [.viewWillAppear, .viewDidAppear, .viewWillDisappear, .hostWillResignActive]
        )
        XCTAssertEqual(
            events.compactMap { $0.rimeResumePayload?.phase },
            [.started]
        )
        XCTAssertEqual(
            events.compactMap { $0.textProxyPayload }.map {
                "\($0.operation.rawValue):\($0.phase.rawValue)"
            },
            [
                "insert_text:entered",
                "insert_text:returned",
                "set_marked_text:entered",
                "set_marked_text:returned",
                "unmark_text:entered",
                "unmark_text:returned",
            ]
        )
        XCTAssertTrue(
            events.allSatisfy {
                $0.schemaVersion == 6
                    && $0.origin == .keyboardExtension
                    && $0.appearanceID == appearanceID
                    && $0.actionSequence == nil
                    && $0.fields.isEmpty
            })
        XCTAssertTrue(
            events.filter { $0.code == .rimeResumePhaseChanged }.allSatisfy {
                $0.category == .engine && $0.level == .debug
            })
        XCTAssertTrue(
            events.filter { $0.code != .rimeResumePhaseChanged }.allSatisfy {
                $0.category == .display && $0.level == .debug
            })
        XCTAssertEqual(proxy.markedText, "a😀中")
        XCTAssertEqual(proxy.markedSelectedRange, NSRange(location: 1, length: 2))
    }

    func testClosedExpiredAndV5GatesDoNotChangeProxyBehavior() async throws {
        let v6RootURL = makeTemporaryDirectory()
        defer { cleanupJournalRoot(v6RootURL) }
        let v6Runtime = try await makeRuntime(rootURL: v6RootURL, writerVersion: .v6)
        let appearanceID = UUID(uuidString: "00000000-0000-0000-0000-000000000102")
        let now = Date()
        let closedContext = KeyboardWakeDiagnosticContext(
            appearanceID: appearanceID,
            isHighFidelityActive: false,
            expiration: now.addingTimeInterval(3_600)
        )
        let expiredContext = KeyboardWakeDiagnosticContext(
            appearanceID: appearanceID,
            isHighFidelityActive: true,
            expiration: .distantPast
        )
        let boundaryContext = KeyboardWakeDiagnosticContext(
            appearanceID: appearanceID,
            isHighFidelityActive: true,
            expiration: now
        )

        assertWakeMarkersRejected(runtime: v6Runtime, context: closedContext, now: now)
        assertWakeMarkersRejected(runtime: v6Runtime, context: expiredContext, now: now)
        assertWakeMarkersRejected(runtime: v6Runtime, context: boundaryContext, now: now)

        let closedProxy = FakeTextDocumentProxy()
        let expiredProxy = FakeTextDocumentProxy()
        let closedAdapter = UITextDocumentProxyAdapter(
            proxy: closedProxy,
            diagnosticsJournal: v6Runtime,
            diagnosticContext: { closedContext }
        )
        let expiredAdapter = UITextDocumentProxyAdapter(
            proxy: expiredProxy,
            diagnosticsJournal: v6Runtime,
            diagnosticContext: { expiredContext }
        )
        closedAdapter.insertText("closed")
        closedAdapter.setMarkedText("x", selectedRange: 0..<1)
        closedAdapter.unmarkText()
        expiredAdapter.insertText("expired")
        expiredAdapter.setMarkedText("y", selectedRange: 0..<1)
        expiredAdapter.unmarkText()

        XCTAssertEqual(
            closedProxy.calls,
            [
                .insertText("closed"),
                .setMarkedText("x", location: 0, length: 1),
                .unmarkText,
            ]
        )
        XCTAssertEqual(
            expiredProxy.calls,
            [
                .insertText("expired"),
                .setMarkedText("y", location: 0, length: 1),
                .unmarkText,
            ]
        )
        v6Runtime.record(code: .presentationAppeared, category: .display)
        let v6Snapshot = try await waitForSnapshot(
            runtime: v6Runtime,
            at: v6RootURL,
            expectedEventCount: 1,
            expectedV6EventCount: 1
        )
        XCTAssertTrue(v6Snapshot.completeness.isComplete)
        XCTAssertEqual(v6Snapshot.events.map(\.code), [.presentationAppeared])
        XCTAssertEqual(v6Snapshot.events.map(\.schemaVersion), [6])

        let v5RootURL = makeTemporaryDirectory()
        defer { cleanupJournalRoot(v5RootURL) }
        let v5Runtime = try await makeRuntime(rootURL: v5RootURL, writerVersion: .v5)
        let openContext = KeyboardWakeDiagnosticContext(
            appearanceID: appearanceID,
            isHighFidelityActive: true,
            expiration: Date().addingTimeInterval(3_600)
        )
        assertWakeMarkersRejected(runtime: v5Runtime, context: openContext, now: Date())

        let v5Proxy = FakeTextDocumentProxy()
        let v5Adapter = UITextDocumentProxyAdapter(
            proxy: v5Proxy,
            diagnosticsJournal: v5Runtime,
            diagnosticContext: { openContext }
        )
        v5Adapter.insertText("v5")
        v5Adapter.setMarkedText("z", selectedRange: 0..<1)
        v5Adapter.unmarkText()

        XCTAssertEqual(
            v5Proxy.calls,
            [
                .insertText("v5"),
                .setMarkedText("z", location: 0, length: 1),
                .unmarkText,
            ]
        )
        v5Runtime.record(code: .presentationAppeared, category: .display)
        v5Runtime.requestFlush()
        let v5Snapshot = try await waitForSnapshot(at: v5RootURL, expectedEventCount: 1, expectedV6EventCount: 0)
        XCTAssertTrue(v5Snapshot.completeness.isComplete)
        XCTAssertEqual(v5Snapshot.events.map(\.code), [.presentationAppeared])
        XCTAssertEqual(v5Snapshot.events.map(\.schemaVersion), [5])
    }

    private func assertWakeMarkersRejected(
        runtime: DiagnosticsJournalRuntime,
        context: KeyboardWakeDiagnosticContext,
        now: Date
    ) {
        for phase in [
            DiagnosticEvent.KeyboardLifecyclePhase.viewWillAppear,
            .viewDidAppear,
            .viewWillDisappear,
            .hostWillResignActive,
        ] {
            XCTAssertFalse(
                KeyboardWakeDiagnosticProducer.recordKeyboardLifecycle(
                    phase,
                    journal: runtime,
                    context: context,
                    now: now
                )
            )
        }
        XCTAssertFalse(
            KeyboardWakeDiagnosticProducer.recordRimeResumeStarted(
                journal: runtime,
                context: context,
                now: now
            )
        )
    }

    private func makeRuntime(
        rootURL: URL,
        writerVersion: DiagnosticsJournalWriterVersion
    ) async throws -> DiagnosticsJournalRuntime {
        let rootWriter = DiagnosticsJournalWriter(
            rootURL: rootURL,
            origin: .mainApp,
            processInstanceID: UUID(),
            isMainAppWriter: true
        )
        try await rootWriter.prepareRootIfOwnedByMainApp()
        return DiagnosticsJournalRuntime(
            origin: .keyboardExtension,
            isMainAppWriter: false,
            rootURL: { rootURL },
            isCategoryEnabled: { _ in true },
            writerVersion: writerVersion,
            flushDelay: 30
        )
    }

    private func makeTemporaryDirectory() -> URL {
        let directory = journalTemporaryBase()
            .appendingPathComponent("KeyboardWakeDiagnosticProducerTests-\(UUID().uuidString)")
        try! FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        return directory
    }

    private func waitForSnapshot(
        runtime: DiagnosticsJournalRuntime? = nil,
        at rootURL: URL,
        expectedEventCount: Int,
        expectedV6EventCount: Int
    ) async throws -> DiagnosticsJournalSnapshot {
        let reader = DiagnosticsJournalReader(rootURL: rootURL)
        #if DEBUG
            if let runtime {
                let started = DispatchTime.now()
                return try await flushBarrierValue(milliseconds: 2000, rootURL: rootURL) { stage in
                    let before = runtime.testingFlushSnapshotForTesting()
                    await runtime.flushAndWaitForTesting()
                    let after = runtime.testingFlushSnapshotForTesting()
                    print(
                        "R4_DIAG accepted=\(before.accepted) appended=\(after.appended) filtered=\(after.filtered) dropped=\(after.dropped) lifecycle=\(after.lifecycleCancelled)"
                    )
                    stage.markBarrierReturned()
                    stage.markReadStarted()
                    let snapshot = try await reader.latest()
                    print("R4_READ eventCount=\(snapshot.events.count)")
                    guard snapshot.events.count >= expectedEventCount,
                        snapshot.events.filter({ $0.schemaVersion == 6 }).count >= expectedV6EventCount
                    else {
                        let elapsed = Int(
                            (DispatchTime.now().uptimeNanoseconds - started.uptimeNanoseconds) / 1_000_000
                        )
                        throw JournalObservationMismatch(
                            stage: "read-after-barrier",
                            barrierReturned: true,
                            elapsedMilliseconds: elapsed,
                            eventCount: snapshot.events.count,
                            diagnostics:
                                "accepted=\(before.accepted) appended=\(after.appended) filtered=\(after.filtered) dropped=\(after.dropped) lifecycle=\(after.lifecycleCancelled)"
                        )
                    }
                    return snapshot
                }
            }
        #endif
        for _ in 0..<100 {
            if let snapshot = try? await reader.latest(),
                snapshot.events.count >= expectedEventCount,
                snapshot.events.filter({ $0.schemaVersion == 6 }).count >= expectedV6EventCount
            {
                return snapshot
            }
            try await Task.sleep(for: .milliseconds(20))
        }
        XCTFail("Timed out waiting for the expected diagnostic records")
        return try await reader.latest()
    }

    func testFlushBarrierTimeoutReportsActualBarrierStageWithoutWaiting() async throws {
        try await proveFlushBarrierTimeoutReportsBarrierStage()
    }

    func testFlushBarrierTimeoutDuringReadReportsReadStage() async throws {
        try await proveFlushBarrierTimeoutReportsReadStage()
    }
}

@MainActor
private final class FakeTextDocumentProxy: NSObject, UITextDocumentProxy {
    enum Call: Equatable {
        case insertText(String)
        case setMarkedText(String, location: Int, length: Int)
        case unmarkText
    }

    var documentContextBeforeInput: String?
    var documentContextAfterInput: String?
    var selectedText: String?
    var documentInputMode: UITextInputMode?
    let documentIdentifier = UUID()
    var hasText = false

    private(set) var calls: [Call] = []
    private(set) var markedText: String?
    private(set) var markedSelectedRange: NSRange?
    var onOperation: ((String) -> Void)?

    func insertText(_ text: String) {
        calls.append(.insertText(text))
        onOperation?("proxy.insertText")
    }

    func deleteBackward() {}

    func adjustTextPosition(byCharacterOffset offset: Int) {}

    func setMarkedText(_ markedText: String, selectedRange: NSRange) {
        calls.append(
            .setMarkedText(
                markedText,
                location: selectedRange.location,
                length: selectedRange.length
            )
        )
        self.markedText = markedText
        markedSelectedRange = selectedRange
        onOperation?("proxy.setMarkedText")
    }

    func unmarkText() {
        calls.append(.unmarkText)
        onOperation?("proxy.unmarkText")
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
    let diagnostics: String
    var description: String {
        "stage=\(stage) barrierReturned=\(barrierReturned) elapsedMilliseconds=\(elapsedMilliseconds) eventCount=\(eventCount) \(diagnostics); 正常完成只证明终结，取消不证明终结，reader 可见性不保证；快照非原子且非逐 ticket 或屏障上界，不能以总数相等推断覆盖；计数按首个终结原因归类，dropped 合并多种原因并非物理 I/O 审计；历史零条与合同相容但违反数量断言，根因 UNKNOWN"
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
