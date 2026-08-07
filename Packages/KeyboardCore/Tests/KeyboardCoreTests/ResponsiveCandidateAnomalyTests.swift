import XCTest
@testable import KeyboardCore

/// RESPONSIVE-CANDIDATE-ANOMALY-001: select double-commit + ThreadAffine paging window.
@MainActor
final class ResponsiveCandidateAnomalyTests: XCTestCase {

    // MARK: - A1: host commit once on select

    /// MainActor R2 bridge: select must not host-commit via publish *and* Core.
    func testMainActorResponsiveSelectCandidateCommitsHostTextOnce() {
        let engine = FakeRimeEngine(dictionary: [
            "n": ["你"],
            "ni": ["你", "呢", "尼"],
        ])
        let client = FakeTextInputClient()
        let controller = KeyboardController()
        controller.textClient = client
        controller.rimeEngine = engine
        controller.usesT9InputSemantics = false
        controller.isResponsiveRimePipelineEnabled = true
        controller.rebuildResponsiveRimeCoordinatorIfNeeded()
        XCTAssertTrue(controller.rimeEngine is ResponsiveRimeEngineBridge)

        _ = controller.handle(.insertKey("n"))
        _ = controller.handle(.insertKey("i"))
        controller.responsiveRimeCoordinator?.flushPending()
        XCTAssertEqual(engine.sessionComposition, "ni")

        _ = controller.handle(
            .insertCandidate(
                "你",
                kind: .candidate,
                selectionReference: CandidateSelectionReference(
                    page: 0,
                    indexOnPage: 0,
                    globalIndex: 0
                )
            )
        )
        // Drain any residual MainActor publish tasks that would re-apply.
        let settle = expectation(description: "settle")
        DispatchQueue.main.async { settle.fulfill() }
        wait(for: [settle], timeout: 1)

        XCTAssertEqual(client.text, "你", "select must commit host text exactly once")
        XCTAssertEqual(client.markedText, "")
        XCTAssertEqual(controller.state.currentComposition, "")
    }

    /// Space path must remain single-commit (control: does not call selectCandidate).
    func testMainActorResponsiveSpaceCommitsHostTextOnce() {
        let engine = FakeRimeEngine(dictionary: [
            "n": ["你"],
            "ni": ["你", "呢"],
        ])
        let client = FakeTextInputClient()
        let controller = KeyboardController()
        controller.textClient = client
        controller.rimeEngine = engine
        controller.usesT9InputSemantics = false
        controller.isResponsiveRimePipelineEnabled = true
        controller.rebuildResponsiveRimeCoordinatorIfNeeded()

        _ = controller.handle(.insertKey("n"))
        _ = controller.handle(.insertKey("i"))
        controller.responsiveRimeCoordinator?.flushPending()

        _ = controller.handle(.insertSpace)
        let settle = expectation(description: "settle")
        DispatchQueue.main.async { settle.fulfill() }
        wait(for: [settle], timeout: 1)

        XCTAssertEqual(client.text, "你")
        XCTAssertEqual(client.markedText, "")
    }

    /// Dual-gate ThreadAffine: select returns + Core apply only once (publish suppressed).
    func testThreadAffineSelectCandidateCommitsHostTextOnce() async {
        let client = FakeTextInputClient()
        let controller = KeyboardController()
        controller.textClient = client
        controller.usesT9InputSemantics = false
        controller.isResponsiveRimePipelineEnabled = true
        controller.isThreadAffineRimeOwnerEnabled = true
        controller.threadAffineEngineBootstrap = AnyThreadAffineRimeEngineBootstrap(
            DictionaryBootstrap(dictionary: [
                "n": ["你"],
                "ni": ["你", "呢", "尼"],
            ])
        )
        let presented = expectation(description: "keys presented")
        presented.expectedFulfillmentCount = 2
        controller.onResponsivePresentationNeeded = { _ in
            presented.fulfill()
        }
        controller.rebuildResponsiveRimeCoordinatorIfNeeded()
        XCTAssertTrue(controller.rimeEngine is ThreadAffineRimeEngineBridge)

        _ = controller.handle(.insertKey("n"))
        _ = controller.handle(.insertKey("i"))
        await fulfillment(of: [presented], timeout: 2)
        // Let any deferred presentation tasks land.
        await Task.yield()
        await Task.yield()

        _ = controller.handle(
            .insertCandidate(
                "你",
                kind: .candidate,
                selectionReference: CandidateSelectionReference(
                    page: 0,
                    indexOnPage: 0,
                    globalIndex: 0
                )
            )
        )
        // Give a suppressed-or-late publish a chance to double-insert if buggy.
        try? await Task.sleep(nanoseconds: 80_000_000)
        await Task.yield()

        XCTAssertEqual(client.text, "你", "ThreadAffine select must not double-insert")
        XCTAssertEqual(client.markedText, "")
        XCTAssertEqual(controller.state.currentComposition, "")

        controller.suspendRimeForVisibilityChange()
    }

    // MARK: - B: candidateWindow beyond first page

    func testThreadAffineCandidateWindowReadsPastFirstPage() {
        let pageSize = 12
        let firstPage = (0..<pageSize).map { "c" + String($0) }
        let fullWindow: [RimeCandidate] = (0..<40).map { index in
            RimeCandidate(text: "c" + String(index), globalIndex: index)
        }

        let coordinator = ThreadAffineRimeSessionCoordinator(
            bootstrap: AnyThreadAffineRimeEngineBootstrap(
                PagedBootstrap(firstPageTexts: firstPage, fullWindow: fullWindow)
            ),
            fixtureID: "T9RESP-CAND-001"
        )
        let bridge = ThreadAffineRimeEngineBridge(coordinator: coordinator)

        _ = bridge.processKey("n")
        _ = bridge.processKey("i")
        coordinator.flushPending()

        let first = bridge.candidateWindow(from: 0, limit: pageSize)
        XCTAssertEqual(first.candidates.count, pageSize)
        XCTAssertTrue(first.hasMoreCandidates, "owner engine must report more beyond page 1")

        let second = bridge.candidateWindow(from: pageSize, limit: 16)
        XCTAssertFalse(
            second.candidates.isEmpty,
            "must not stall at page_size by slicing lastPublished only"
        )
        XCTAssertEqual(second.startIndex, pageSize)
        XCTAssertGreaterThanOrEqual(second.candidates.count, 1)
        XCTAssertEqual(second.candidates.first?.text, "c" + String(pageSize))

        coordinator.shutdown()
    }

    // MARK: - Bootstraps

    private struct DictionaryBootstrap: ThreadAffineRimeEngineBootstrap {
        let dictionary: [String: [String]]

        func makeEngineOnOwnerThread() -> any RimeEngine {
            FakeRimeEngine(dictionary: dictionary)
        }
    }

    /// First-page processKey output is short; candidateWindow exposes a longer list.
    private struct PagedBootstrap: ThreadAffineRimeEngineBootstrap {
        let firstPageTexts: [String]
        let fullWindow: [RimeCandidate]

        func makeEngineOnOwnerThread() -> any RimeEngine {
            let engine = FakeRimeEngine(dictionary: [
                "n": Array(firstPageTexts.prefix(3)),
                "ni": firstPageTexts,
            ])
            engine.candidateWindowOverrides["ni"] = fullWindow
            engine.candidateWindowOverrides["n"] = Array(fullWindow.prefix(3))
            return engine
        }
    }
}
