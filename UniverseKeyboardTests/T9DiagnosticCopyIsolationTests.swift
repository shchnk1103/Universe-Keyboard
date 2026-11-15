import Foundation
import KeyboardCore
import XCTest

@testable import Universe_Keyboard

/// 009 S1c J9: T9 diagnostic lines follow the ordinary filter/search/copy path and never
/// leak into the release evidence export.
@MainActor
final class T9DiagnosticCopyIsolationTests: XCTestCase {
    private struct EmptySource: DiagnosticsLogSource {
        func loadLogText() async -> String? { nil }
        func clearLog() async -> DiagnosticsLogClearResult { .cleared }
    }

    private func t9Line(sequence: UInt64) -> String {
        let payload = DiagnosticEvent.T9Payload(
            cycle: T9CycleDiagnostic(
                sequence: sequence, terminal: .succeeded, candidateBand: .nonzero,
                preeditShape: .segmented, usable: .yes, exact: .yes, priorDrops: 3))
        let event = DiagnosticEvent.makeV7T9Event(
            payload: payload, code: .t9CycleResult, utcTimestamp: Date(), monotonicNanoseconds: 1,
            origin: .keyboardExtension, processInstanceID: UUID(), localSequence: sequence)!
        return DiagnosticsEventDisplayFormatter.line(event)
    }

    func testT9LinesSelectSearchAndCopyLikeOrdinaryLines() {
        let line = t9Line(sequence: 7)
        XCTAssertTrue(line.contains("t9.cycle_result"))
        XCTAssertTrue(line.contains("admission_sequence=7"))
        XCTAssertTrue(line.contains("prior_drops=3"))
        let other = "[12:00:00.000] [INFO] [DISP] presentation.appeared"
        let store = DiagnosticsStore(logSource: EmptySource())
        store.lines = [other, line]
        store.searchQuery = "t9.cycle_result"
        XCTAssertEqual(store.filteredLines, [line])
        XCTAssertTrue(store.canExportCurrentSelection)
        XCTAssertEqual(store.exportText, line)
        store.searchQuery = ""
        XCTAssertEqual(store.filteredLines.count, 2)
    }

    func testReleaseEvidenceExportNeverContainsT9CodesOrAutoInjectedLog() {
        let model = ReleaseEvidenceSessionModel(
            storage: ReleaseEvidenceFileStore(fileURL: nil), bundle: .main, deviceModel: "Test",
            osVersion: "Test")
        let run = ReleaseEvidenceRun(
            createdAt: Date(), updatedAt: Date(), lane: .dailyBeta, profile: .delta,
            appVersion: "1.0", appBuild: "1", deviceModel: "Test", osVersion: "Test",
            candidateID: "Build-1",
            steps: [ReleaseEvidenceStep(scope: .candidateIdentity, outcome: .pass)])
        model.runs = [run]
        model.selectedRunID = run.id
        let text = model.exportText
        XCTAssertFalse(text.isEmpty)
        XCTAssertFalse(text.contains("t9.cycle_result"))
        XCTAssertFalse(text.contains("t9.delete_path"))
    }
}
