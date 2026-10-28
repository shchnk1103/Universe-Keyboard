import Foundation
import SwiftUI
import XCTest

@testable import KeyboardCore
@testable import Universe_Keyboard

final class DiagnosticsAppLifecycleTests: XCTestCase {
    func testScenePhasesControlBothServiceRuntimesWithoutWaitingForWriter() async {
        let lifecycle = DiagnosticsProcessLifecycle()
        let started = expectation(description: "writer started")
        let writer = LifecycleBlockedWriter(started: started)
        defer { Task { await writer.release() } }
        let first = makeRuntime()
        let second = makeRuntime()
        first.installBatchWriterFactoryForTesting { _ in writer }
        let schema = SchemaDeliveryDiagnostics(runtime: first, lifecycle: lifecycle)
        let sync = RimeSyncDiagnostics(runtime: second, lifecycle: lifecycle)
        withExtendedLifetime((schema, sync)) {
            first.record(code: .journalStarted, category: .general)
            second.record(code: .journalStarted, category: .general)
            XCTAssertEqual(first.testingFlushSnapshotForTesting().accepted, 0)
            XCTAssertEqual(second.testingFlushSnapshotForTesting().accepted, 0)
        }

        DiagnosticsAppLifecycle.apply(.active, to: lifecycle)
        let firstBaseline = first.testingFlushSnapshotForTesting().accepted
        let secondBaseline = second.testingFlushSnapshotForTesting().accepted
        first.record(code: .journalStarted, category: .general)
        first.requestFlush()
        await fulfillment(of: [started], timeout: 5)
        DiagnosticsAppLifecycle.apply(.inactive, to: lifecycle)
        first.record(code: .journalStarted, category: .general)
        second.record(code: .journalStarted, category: .general)
        XCTAssertEqual(first.testingFlushSnapshotForTesting().accepted, firstBaseline + 1)
        XCTAssertEqual(second.testingFlushSnapshotForTesting().accepted, secondBaseline)
        DiagnosticsAppLifecycle.apply(.background, to: lifecycle)
        await writer.release()
        await first.flushAndWaitForTesting()
        DiagnosticsAppLifecycle.apply(.active, to: lifecycle)
        DiagnosticsAppLifecycle.apply(.inactive, to: lifecycle)
        DiagnosticsAppLifecycle.apply(.active, to: lifecycle)
        first.record(code: .journalStarted, category: .general)
        second.record(code: .journalStarted, category: .general)
        XCTAssertGreaterThanOrEqual(first.testingFlushSnapshotForTesting().accepted, firstBaseline + 2)
        XCTAssertGreaterThanOrEqual(second.testingFlushSnapshotForTesting().accepted, secondBaseline + 1)
    }

    private func makeRuntime() -> DiagnosticsJournalRuntime {
        DiagnosticsJournalRuntime(
            origin: .mainApp, isMainAppWriter: true,
            rootURL: { URL(fileURLWithPath: "/unused-lifecycle-test") },
            isCategoryEnabled: { _ in true }, flushDelay: 60
        )
    }
}

private actor LifecycleBlockedWriter: DiagnosticsJournalBatchWriting {
    private let started: XCTestExpectation
    private var waiter: CheckedContinuation<Void, Never>?
    private var released = false

    init(started: XCTestExpectation) { self.started = started }
    func prepareRootIfOwnedByMainApp() async throws {}
    func rotateIdentityAfterReclaim() async {}
    func append(_ events: [DiagnosticEvent], isWritePermitted: @escaping @Sendable () -> Bool) async throws {
        await withCheckedContinuation { continuation in
            if released {
                continuation.resume()
            } else {
                waiter = continuation
                started.fulfill()
            }
        }
        guard isWritePermitted() else { throw DiagnosticsJournalError.lifecycleCancelled }
    }
    func release() {
        released = true
        waiter?.resume()
        waiter = nil
    }
}
