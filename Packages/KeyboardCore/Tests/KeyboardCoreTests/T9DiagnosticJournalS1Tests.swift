import XCTest

@testable import KeyboardCore

final class T9DiagnosticJournalS1Tests: XCTestCase {
    override func tearDown() {
        T9DiagnosticAdmission.shared.resetForTesting()
        super.tearDown()
    }

    func testV7ReaderRejectsUnknownWithoutEmptyFallback() {
        XCTAssertTrue(DiagnosticEvent.supportsReading(schemaVersion: 7))
        XCTAssertTrue(DiagnosticEvent.supportsReading(schemaVersion: 3))
        XCTAssertTrue(DiagnosticEvent.supportsReading(schemaVersion: 6))
        XCTAssertFalse(DiagnosticEvent.supportsReading(schemaVersion: 8))
        XCTAssertEqual(DiagnosticsJournalWriterVersion.pairedBuild, .v7)
    }

    func testAdmissionLockQueueAndWindow() {
        let admission = T9DiagnosticAdmission()
        admission.holdLockForTesting()
        let start = DispatchTime.now().uptimeNanoseconds
        XCTAssertFalse(admission.tryEnqueue(T9CycleDiagnostic(terminal: .notStarted), now: 1))
        XCTAssertLessThan(DispatchTime.now().uptimeNanoseconds - start, 1_000_000)
        XCTAssertEqual(admission.recordTouchCount, 0)
        XCTAssertTrue(admission.cycles().isEmpty)
        admission.releaseLockForTesting()
        var now: UInt64 = 0
        for index in 0..<256 {
            if index > 0, index.isMultiple(of: 20) { now &+= 10_000_000_001 }
            XCTAssertTrue(admission.tryEnqueue(T9CycleDiagnostic(terminal: .notStarted), now: now), "index \(index)")
        }
        XCTAssertFalse(admission.tryEnqueue(T9CycleDiagnostic(terminal: .notStarted), now: now))
        XCTAssertEqual(admission.cycles().count, 256)
        let kept = admission.cycles().count
        XCTAssertFalse(admission.tryEnqueue(T9CycleDiagnostic(terminal: .notStarted), now: 301))
        XCTAssertEqual(admission.cycles().count, kept)
    }

    func testCanaryStaysOutOfTypedExport() {
        let admission = T9DiagnosticAdmission()
        let canary = "CANARY'ninh"
        XCTAssertTrue(
            admission.tryEnqueue(
                T9CycleDiagnostic(
                    terminal: .succeeded, candidateBand: .nonzero,
                    preeditShape: T9CycleDiagnostic.Shape.shape(of: canary), usable: .yes, exact: .yes)))
        let text = admission.exportedText()
        XCTAssertFalse(text.contains(canary))
        XCTAssertTrue(text.contains("segmented"))
    }

    @MainActor
    func testCycleAndDirectTapAdmission() {
        let controller = KeyboardController()
        controller.usesT9InputSemantics = true
        controller.t9DiagnosticCaptureEnabled = true
        _ = controller.handleCycleT9PinyinPath()
        XCTAssertEqual(T9DiagnosticAdmission.shared.cycles().map(\.terminal), [.notStarted])
        T9DiagnosticAdmission.shared.resetForTesting()
        let path = T9PinyinPath(displayText: "ming", replacementRawInput: "ming")
        _ = controller.handleSelectT9PinyinPath(path)
        XCTAssertTrue(T9DiagnosticAdmission.shared.cycles().isEmpty)
    }
}
