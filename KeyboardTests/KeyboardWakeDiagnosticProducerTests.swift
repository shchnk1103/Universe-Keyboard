import Foundation
import KeyboardCore
import UIKit
import XCTest

@MainActor
final class KeyboardWakeDiagnosticProducerTests: XCTestCase {
    func testV6ProducerAndAdapterWriteFiniteMarkersAroundProxyCalls() async throws {
        let rootURL = makeTemporaryDirectory()
        defer { try? FileManager.default.removeItem(at: rootURL) }
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

        runtime.requestFlush()
        let snapshot = try await waitForSnapshot(at: rootURL, expectedEventCount: 11, expectedV6EventCount: 11)
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
        defer { try? FileManager.default.removeItem(at: v6RootURL) }
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
        v6Runtime.requestFlush()
        let v6Snapshot = try await waitForSnapshot(at: v6RootURL, expectedEventCount: 1, expectedV6EventCount: 1)
        XCTAssertTrue(v6Snapshot.completeness.isComplete)
        XCTAssertEqual(v6Snapshot.events.map(\.code), [.presentationAppeared])
        XCTAssertEqual(v6Snapshot.events.map(\.schemaVersion), [6])

        let v5RootURL = makeTemporaryDirectory()
        defer { try? FileManager.default.removeItem(at: v5RootURL) }
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
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("KeyboardWakeDiagnosticProducerTests-\(UUID().uuidString)")
        try! FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        return directory
    }

    private func waitForSnapshot(
        at rootURL: URL,
        expectedEventCount: Int,
        expectedV6EventCount: Int
    ) async throws -> DiagnosticsJournalSnapshot {
        let reader = DiagnosticsJournalReader(rootURL: rootURL)
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
