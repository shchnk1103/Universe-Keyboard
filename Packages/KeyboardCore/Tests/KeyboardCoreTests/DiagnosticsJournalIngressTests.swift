import Foundation
import Synchronization
import XCTest

@testable import KeyboardCore

final class DiagnosticsJournalIngressTests: XCTestCase {
    func testFailureReasonsRemainContentFreeAndDoNotTreatEveryWriteFailureAsDiskFull() {
        XCTAssertEqual(
            DiagnosticsJournalIngress.diagnosticReason(for: DiagnosticsJournalError.lockBusy),
            .lockBusy
        )
        XCTAssertEqual(
            DiagnosticsJournalIngress.diagnosticReason(for: DiagnosticsJournalError.diskFull),
            .diskFull
        )
        XCTAssertEqual(
            DiagnosticsJournalIngress.diagnosticReason(for: DiagnosticsJournalError.ioFailure),
            .ioFailure
        )
        XCTAssertEqual(
            DiagnosticsJournalIngress.diagnosticReason(for: DiagnosticsJournalError.writeFailed),
            .ioFailure
        )
    }

    func testIngressIsBoundedAndWritesOnUtilityFlush() async throws {
        let rootURL = makeTemporaryDirectory()
        defer { cleanupJournalRoot(rootURL) }
        let processID = UUID()
        let ingress = DiagnosticsJournalIngress(
            origin: .mainApp,
            processInstanceID: processID,
            isMainAppWriter: true,
            rootURL: { rootURL },
            isCategoryEnabled: { _ in true },
            flushDelay: 5
        )

        for sequence in 0..<(DiagnosticsJournalIngress.maximumPendingEventCount + 1) {
            ingress.record(makeEvent(sequence: UInt64(sequence), processInstanceID: processID))
        }
        ingress.requestFlush()

        let events = try await waitForJournal(ingress: ingress, at: rootURL)
        XCTAssertEqual(events.count, DiagnosticsJournalIngress.maximumPendingEventCount)
        let expectedSequences = Array(0..<UInt64(DiagnosticsJournalIngress.maximumPendingEventCount))
        XCTAssertEqual(events.map(\.localSequence), expectedSequences)
    }

    func testQueueFullCanDropQueryMeasurementWithoutChangingItsMeaning() async throws {
        let rootURL = makeTemporaryDirectory()
        defer { cleanupJournalRoot(rootURL) }
        let processID = UUID()
        let ingress = DiagnosticsJournalIngress(
            origin: .mainApp,
            processInstanceID: processID,
            isMainAppWriter: true,
            rootURL: { rootURL },
            isCategoryEnabled: { _ in true },
            flushDelay: 5
        )

        for sequence in 0..<DiagnosticsJournalIngress.maximumPendingEventCount {
            ingress.record(makeEvent(sequence: UInt64(sequence), processInstanceID: processID))
        }
        ingress.record(
            makeQueryMeasurementEvent(
                sequence: UInt64(DiagnosticsJournalIngress.maximumPendingEventCount),
                origin: .mainApp,
                processInstanceID: processID
            ))
        ingress.requestFlush()

        let events = try await waitForJournal(ingress: ingress, at: rootURL)
        XCTAssertEqual(events.count, DiagnosticsJournalIngress.maximumPendingEventCount)
        XCTAssertFalse(events.contains { $0.code == .typoRecallQueryMeasured })
    }

    func testSuspendCanDropQueryMeasurementBeforeJournalWrite() async throws {
        let rootURL = makeTemporaryDirectory()
        defer { cleanupJournalRoot(rootURL) }
        try FileManager.default.removeItem(at: rootURL)
        let processID = UUID()
        let ingress = DiagnosticsJournalIngress(
            origin: .keyboardExtension,
            processInstanceID: processID,
            isMainAppWriter: false,
            rootURL: { rootURL },
            isCategoryEnabled: { _ in true },
            flushDelay: 0.1
        )

        ingress.record(
            makeQueryMeasurementEvent(
                sequence: 1,
                origin: .keyboardExtension,
                processInstanceID: processID
            ))
        ingress.suspendForExtensionLifecycle()
        try await Task.sleep(for: .milliseconds(250))
        XCTAssertFalse(FileManager.default.fileExists(atPath: rootURL.path))
    }

    func testDisabledCategoryIsNotWritten() async throws {
        let rootURL = makeTemporaryDirectory()
        defer { cleanupJournalRoot(rootURL) }
        try FileManager.default.removeItem(at: rootURL)
        let processID = UUID()
        let ingress = DiagnosticsJournalIngress(
            origin: .mainApp,
            processInstanceID: processID,
            isMainAppWriter: true,
            rootURL: { rootURL },
            isCategoryEnabled: { _ in false },
            flushDelay: 0
        )

        ingress.record(makeEvent(sequence: 1, processInstanceID: processID))
        ingress.requestFlush()
        try await Task.sleep(for: .milliseconds(100))

        XCTAssertFalse(FileManager.default.fileExists(atPath: rootURL.path))
    }

    func testSuspendDiscardsDelayedTailWithoutCreatingJournal() async throws {
        let rootURL = makeTemporaryDirectory()
        defer { cleanupJournalRoot(rootURL) }
        try FileManager.default.removeItem(at: rootURL)
        let processID = UUID()
        let ingress = DiagnosticsJournalIngress(
            origin: .mainApp,
            processInstanceID: processID,
            isMainAppWriter: true,
            rootURL: { rootURL },
            isCategoryEnabled: { _ in true },
            flushDelay: 0.1
        )

        ingress.record(makeEvent(sequence: 1, processInstanceID: processID))
        ingress.suspendForExtensionLifecycle()
        try await Task.sleep(for: .milliseconds(250))

        XCTAssertFalse(FileManager.default.fileExists(atPath: rootURL.path))
    }

    func testSuspendedRecordsAreReportedThenNewVisibleEventsWrite() async throws {
        let rootURL = makeTemporaryDirectory()
        defer { cleanupJournalRoot(rootURL) }
        let processID = UUID()
        let ingress = DiagnosticsJournalIngress(
            origin: .mainApp,
            processInstanceID: processID,
            isMainAppWriter: true,
            rootURL: { rootURL },
            isCategoryEnabled: { _ in true },
            flushDelay: 5
        )

        ingress.suspendForExtensionLifecycle()
        ingress.record(makeEvent(sequence: 1, processInstanceID: processID))
        ingress.record(makeEvent(sequence: 2, processInstanceID: processID))
        XCTAssertEqual(ingress.resumeForExtensionLifecycle(), 2)
        ingress.record(makeEvent(sequence: 3, processInstanceID: processID))
        ingress.requestFlush()

        let events = try await waitForJournal(ingress: ingress, at: rootURL)
        XCTAssertEqual(events.map(\.localSequence), [3])
    }

    private func makeEvent(sequence: UInt64, processInstanceID: UUID) -> DiagnosticEvent {
        DiagnosticEvent(
            utcTimestamp: Date(),
            monotonicNanoseconds: sequence,
            origin: .mainApp,
            processInstanceID: processInstanceID,
            localSequence: sequence,
            code: .journalStarted,
            level: .info,
            category: .general
        )
    }

    private func makeQueryMeasurementEvent(
        sequence: UInt64,
        origin: DiagnosticEvent.Origin,
        processInstanceID: UUID
    ) -> DiagnosticEvent {
        DiagnosticEvent(
            utcTimestamp: Date(),
            monotonicNanoseconds: sequence,
            origin: origin,
            processInstanceID: processInstanceID,
            localSequence: sequence,
            code: .typoRecallQueryMeasured,
            level: .info,
            category: .performance,
            fields: [
                .typoRecallQuery(
                    .init(
                        operationOrdinal: 1,
                        stage: .stageOne,
                        readiness: .unknown,
                        resultState: .candidatesReturned,
                        returnedCandidateBucket: .zero,
                        disposition: .applied,
                        facadeElapsedMicroseconds: 0,
                        durationState: .measured
                    )
                )
            ]
        )
    }

    private func makeTemporaryDirectory() -> URL {
        let directory = journalTemporaryBase().appendingPathComponent(UUID().uuidString)
        try! FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        return directory
    }

    private func waitForJournal(ingress: DiagnosticsJournalIngress, at rootURL: URL) async throws -> [DiagnosticEvent] {
        let directory = rootURL.appendingPathComponent("g1/open")
        #if DEBUG
            // 目录检查和 readEvents 在同一次 1000ms 截止内。
            // 读取本身不可取消；截止方先返回，不等待它。
            let started = DispatchTime.now()
            return try await flushBarrierValue(milliseconds: 1000, rootURL: rootURL) { stage in
                await ingress.flushAndWaitForTesting()
                stage.markBarrierReturned()
                stage.markReadStarted()
                if !FileManager.default.fileExists(atPath: directory.path) {
                    throw JournalObservationMismatch(
                        stage: "directory-missing-after-barrier",
                        barrierReturned: true,
                        elapsedMilliseconds: flushBarrierElapsedMilliseconds(since: started),
                        eventCount: 0
                    )
                }
                let events = try readJournalEvents(at: rootURL)
                return events
            }
        #else
            for _ in 0..<50 {
                if FileManager.default.fileExists(atPath: directory.path) {
                    return try readJournalEvents(at: rootURL)
                }
                try await Task.sleep(for: .milliseconds(20))
            }
            XCTFail("Timed out waiting for journal output")
            return []
        #endif
    }

    func testFlushBarrierTimeoutReportsActualBarrierStageWithoutWaiting() async throws {
        try await proveFlushBarrierTimeoutReportsBarrierStage()
    }

    func testFlushBarrierTimeoutDuringReadReportsReadStage() async throws {
        try await proveFlushBarrierTimeoutReportsReadStage()
    }
}

private func readJournalEvents(at rootURL: URL) throws -> [DiagnosticEvent] {
    let file = try XCTUnwrap(
        FileManager.default.contentsOfDirectory(
            at: rootURL.appendingPathComponent("g1/open"),
            includingPropertiesForKeys: nil
        ).first
    )
    let lines = try XCTUnwrap(String(data: Data(contentsOf: file), encoding: .utf8))
        .split(separator: "\n")
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    return try lines.map { try decoder.decode(DiagnosticEvent.self, from: Data($0.utf8)) }
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
