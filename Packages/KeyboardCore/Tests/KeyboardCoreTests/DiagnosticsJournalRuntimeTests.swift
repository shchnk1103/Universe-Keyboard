import Foundation
import XCTest

@testable import KeyboardCore

final class DiagnosticsJournalRuntimeTests: XCTestCase {
    func testResumeWritesContentFreeSuspendedDropHealthEvent() async throws {
        let rootURL = makeTemporaryDirectory()
        defer { try? FileManager.default.removeItem(at: rootURL) }
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

        let snapshot = try await waitForEvent(at: rootURL)
        XCTAssertEqual(snapshot.events.map(\.code), [.journalResumed])
        XCTAssertTrue(
            snapshot.events[0].fields.contains(.count(.droppedEventCount, 1))
        )
        XCTAssertTrue(snapshot.events[0].fields.contains(.reason(.suspended)))
    }

    func testSchemeDeliveryPayloadUsesSameBoundedAsynchronousIngress() async throws {
        let rootURL = makeTemporaryDirectory()
        defer { try? FileManager.default.removeItem(at: rootURL) }
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

        let snapshot = try await waitForEvent(at: rootURL)
        XCTAssertEqual(snapshot.events.map(\.code), [.schemeDeliveryTerminal])
        XCTAssertEqual(
            snapshot.events.first?.schemeDeliveryPayload,
            .terminal(.init(context: context, result: .completed))
        )
    }

    private func makeTemporaryDirectory() -> URL {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try! FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        return directory
    }

    private func waitForEvent(at rootURL: URL) async throws -> DiagnosticsJournalSnapshot {
        let reader = DiagnosticsJournalReader(rootURL: rootURL)
        for _ in 0..<50 {
            if let snapshot = try? await reader.latest(), !snapshot.events.isEmpty {
                return snapshot
            }
            try await Task.sleep(for: .milliseconds(20))
        }
        XCTFail("Timed out waiting for journal health event")
        return DiagnosticsJournalSnapshot(generation: 0, events: [])
    }
}
