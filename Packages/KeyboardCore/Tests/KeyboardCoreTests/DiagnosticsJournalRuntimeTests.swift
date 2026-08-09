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
