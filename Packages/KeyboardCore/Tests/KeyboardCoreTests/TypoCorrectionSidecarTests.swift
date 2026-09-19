import Foundation
import XCTest

@testable import KeyboardCore

/// Core-only lane test. It proves isolation and explicit diagnostics; it does
/// not stand in for the real RIME fixture or device acceptance evidence.
@MainActor
final class TypoCorrectionSidecarTests: XCTestCase {
    func testOwnerSidecarQueryDoesNotMutateLiveComposition() throws {
        let receiptID = UUID()
        let coordinator = ThreadAffineRimeSessionCoordinator(
            bootstrap: AnyThreadAffineRimeEngineBootstrap(
                SidecarFakeBootstrap(receiptID: receiptID)
            )
        )
        defer { coordinator.shutdown() }

        let first = try XCTUnwrap(coordinator.performOrderedNow(.processKey("n")))
        XCTAssertEqual(first.output.rawInput, "n")

        let candidates = coordinator.correctionCandidates(for: "ni", limit: 2)
        XCTAssertEqual(candidates.map(\.text), ["你", "呢"])

        let diagnostic = try XCTUnwrap(coordinator.lastTypoCorrectionQueryDiagnostic)
        XCTAssertEqual(diagnostic.route, .realRimeSidecar)
        XCTAssertEqual(diagnostic.schemaID, "rime_ice")
        XCTAssertEqual(diagnostic.provenanceReceiptID, receiptID)
        XCTAssertEqual(diagnostic.liveSessionIDBefore, 11)
        XCTAssertEqual(diagnostic.liveSessionIDAfter, 11)
        XCTAssertEqual(diagnostic.sidecarSessionIDAfter, 22)

        // If the sidecar had called set_input on the live session, this next
        // key would be appended to "ni" rather than the original "n".
        let afterSidecar = try XCTUnwrap(coordinator.performOrderedNow(.processKey("i")))
        XCTAssertEqual(afterSidecar.output.rawInput, "ni")
    }
}

private struct SidecarFakeBootstrap: ThreadAffineRimeEngineBootstrap {
    let receiptID: UUID

    func makeEngineOnOwnerThread() -> any RimeEngine {
        SidecarFakeRimeEngine(receiptID: receiptID)
    }
}

private final class SidecarFakeRimeEngine:
    RimeEngine,
    TypoCorrectionCandidateQuerying,
    TypoCorrectionQueryDiagnosticsProviding
{
    private let delegate = FakeRimeEngine(dictionary: ["ni": ["你", "呢"]])
    private let receiptID: UUID
    private(set) var lastTypoCorrectionQueryDiagnostic: TypoCorrectionQueryDiagnostic?

    init(receiptID: UUID) {
        self.receiptID = receiptID
    }

    func correctionCandidates(for input: String, limit: Int) -> [RimeCandidate] {
        let start = DispatchTime.now().uptimeNanoseconds
        let values = delegate.dictionary[input, default: []].prefix(max(0, limit))
        let candidates = values.map { RimeCandidate(text: $0) }
        let elapsed = DispatchTime.now().uptimeNanoseconds &- start
        lastTypoCorrectionQueryDiagnostic = TypoCorrectionQueryDiagnostic(
            sequence: 1,
            inputLength: input.utf8.count,
            limit: limit,
            resultCount: candidates.count,
            elapsedMilliseconds: Int(elapsed / 1_000_000),
            liveSessionIDBefore: 11,
            liveSessionIDAfter: 11,
            liveSessionValidBefore: true,
            liveSessionValidAfter: true,
            sidecarSessionIDBefore: nil,
            sidecarSessionIDAfter: 22,
            schemaID: "rime_ice",
            provenanceReceiptID: receiptID,
            outcome: .returned
        )
        return candidates
    }

    func processKey(_ key: String) -> RimeOutput { delegate.processKey(key) }
    func selectCandidate(at index: Int) -> RimeOutput { delegate.selectCandidate(at: index) }
    func selectCandidate(globalIndex index: Int) -> RimeOutput {
        delegate.selectCandidate(globalIndex: index)
    }
    func candidateWindow(from globalIndex: Int, limit: Int) -> RimeCandidateWindow {
        delegate.candidateWindow(from: globalIndex, limit: limit)
    }
    func deleteBackward() -> RimeOutput { delegate.deleteBackward() }
    func replaceInput(_ input: String) -> RimeOutput { delegate.replaceInput(input) }
    func resetSession() { delegate.resetSession() }
    func recoverSession() { delegate.recoverSession() }
    func suspendForVisibilityChange() { delegate.suspendForVisibilityChange() }
    func resumeAfterVisibilityChange() { delegate.resumeAfterVisibilityChange() }
    var runtimeSelection: RimeRuntimeSelection? { delegate.runtimeSelection }
    var diagnosticSessionSnapshot: RimeSessionDiagnosticSnapshot? {
        RimeSessionDiagnosticSnapshot(identity: 11, isValid: true)
    }
    var runtimeProvenanceReceiptID: UUID? { receiptID }
    var onRuntimeSelectionChanged: ((RimeRuntimeSelection) -> Void)? {
        get { delegate.onRuntimeSelectionChanged }
        set { delegate.onRuntimeSelectionChanged = newValue }
    }
    func isComposing() -> Bool { delegate.isComposing() }
    func pageUp() -> RimeOutput { delegate.pageUp() }
    func pageDown() -> RimeOutput { delegate.pageDown() }
}
