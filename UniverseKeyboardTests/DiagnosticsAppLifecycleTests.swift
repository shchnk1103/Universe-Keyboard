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
        let secondWriter = LifecycleBlockedWriter(started: nil)
        defer { Task { await writer.release() } }
        await secondWriter.release()
        let first = makeRuntime()
        let second = makeRuntime()
        first.installBatchWriterFactoryForTesting { _ in writer }
        second.installBatchWriterFactoryForTesting { _ in secondWriter }
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
        let cancellationBaseline = first.testingFlushSnapshotForTesting().lifecycleCancelled
        first.record(code: .journalStarted, category: .general)
        let inFlightTicket = first.testingFlushSnapshotForTesting().queuedTickets.last!
        first.requestFlush()
        await fulfillment(of: [started], timeout: 5)
        let beforeClose = first.testingFlushSnapshotForTesting()
        let pendingTickets = Set(beforeClose.queuedTickets + beforeClose.inFlightTickets)
        XCTAssertTrue(beforeClose.inFlightTickets.contains(inFlightTicket))
        DiagnosticsAppLifecycle.apply(.inactive, to: lifecycle)
        let cancelled = first.testingFlushSnapshotForTesting()
        XCTAssertEqual(cancelled.ticketOutcomes[inFlightTicket], .droppedByLifecycle)
        XCTAssertEqual(cancelled.lifecycleCancelled, cancellationBaseline + pendingTickets.count)
        first.record(code: .journalStarted, category: .general)
        second.record(code: .journalStarted, category: .general)
        XCTAssertEqual(first.testingFlushSnapshotForTesting().accepted, firstBaseline + 1)
        XCTAssertEqual(second.testingFlushSnapshotForTesting().accepted, secondBaseline)
        DiagnosticsAppLifecycle.apply(.background, to: lifecycle)
        await writer.release()
        await first.flushAndWaitForTesting()
        let cancelledWrites = await writer.writtenEvents
        XCTAssertTrue(cancelledWrites.isEmpty)
        DiagnosticsAppLifecycle.apply(.active, to: lifecycle)
        DiagnosticsAppLifecycle.apply(.inactive, to: lifecycle)
        DiagnosticsAppLifecycle.apply(.active, to: lifecycle)
        first.record(code: .journalStarted, category: .general)
        second.record(code: .journalStarted, category: .general)
        XCTAssertGreaterThanOrEqual(first.testingFlushSnapshotForTesting().accepted, firstBaseline + 2)
        XCTAssertGreaterThanOrEqual(second.testingFlushSnapshotForTesting().accepted, secondBaseline + 1)
        await first.flushAndWaitForTesting()
        await second.flushAndWaitForTesting()
        let firstWrites = await writer.writtenEvents
        let secondWrites = await secondWriter.writtenEvents
        XCTAssertEqual(firstWrites.filter { $0.code == .journalStarted }.count, 1)
        XCTAssertEqual(secondWrites.filter { $0.code == .journalStarted }.count, 1)
        XCTAssertEqual(first.testingFlushSnapshotForTesting().ticketOutcomes[inFlightTicket], .droppedByLifecycle)
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
    private let started: XCTestExpectation?
    private var waiter: CheckedContinuation<Void, Never>?
    private var released = false
    private(set) var writtenEvents: [DiagnosticEvent] = []

    init(started: XCTestExpectation?) { self.started = started }
    func prepareRootIfOwnedByMainApp() async throws {}
    func rotateIdentityAfterReclaim() async {}
    func append(_ events: [DiagnosticEvent], isWritePermitted: @escaping @Sendable () -> Bool) async throws {
        await withCheckedContinuation { continuation in
            if released {
                continuation.resume()
            } else {
                waiter = continuation
                started?.fulfill()
            }
        }
        guard isWritePermitted() else { throw DiagnosticsJournalError.lifecycleCancelled }
        writtenEvents.append(contentsOf: events)
    }
    func release() {
        released = true
        waiter?.resume()
        waiter = nil
    }
}
