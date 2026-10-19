import Foundation
import XCTest

@testable import KeyboardCore

@MainActor
final class CandidateWindowBindingControllerTests: XCTestCase {
    private func makeBridge(_ probe: CandidateAuthorityProbe) -> (
        ThreadAffineRimeSessionCoordinator, ThreadAffineRimeEngineBridge
    ) {
        let coordinator = ThreadAffineRimeSessionCoordinator(
            bootstrap: .init(CandidateAuthorityBootstrap(probe: probe)))
        return (coordinator, ThreadAffineRimeEngineBridge(coordinator: coordinator))
    }

    func testOrderedOutputOriginSurvivesCoreApplyAndT9SnapshotButNotLocalAugmentation() throws {
        let probe = CandidateAuthorityProbe()
        let (coordinator, bridge) = makeBridge(probe)
        defer { coordinator.shutdown() }
        let output = bridge.processKey("n")
        let origin = try XCTUnwrap(output.candidateOrigin)
        let controller = KeyboardController()
        controller.usesT9InputSemantics = true
        controller.applyRimeOutput(output)
        XCTAssertEqual(controller.state.lastRimeOutput?.candidateOrigin, origin)
        XCTAssertEqual(controller.t9CompositionPresentationSnapshot().candidateOrigin, origin)
        // Copy policy test only: this input is deliberately synthetic, not a bug reproducer.
        let localInput = RimeOutput(
            rawInput: "ni2", composition: .init(preeditText: "ni2", cursorPosition: 3),
            candidateOrigin: origin)
        let local = controller.augmentRimeOutputIfNeeded(localInput)
        XCTAssertFalse(local.candidates.isEmpty, "Fixture must actually exercise local augmentation")
        XCTAssertNil(local.candidateOrigin)
    }

    func testCurrentBoundCandidateSelectsUsingItsOriginalNativeIdentity() throws {
        let probe = CandidateAuthorityProbe()
        let (coordinator, bridge) = makeBridge(probe)
        defer { coordinator.shutdown() }
        let output = bridge.processKey("n")
        _ = bridge.candidateWindow(from: 0, limit: 1)
        let origin = try XCTUnwrap(output.candidateOrigin)
        let controller = KeyboardController()
        let host = FakeTextInputClient()
        controller.textClient = host
        controller.rimeEngine = bridge
        controller.applyRimeOutput(output)
        _ = controller.handle(
            .insertCandidate(
                "你", kind: .candidate,
                selectionReference: .init(page: 0, indexOnPage: 0, globalIndex: 0, candidateOrigin: origin)))
        XCTAssertEqual(probe.snapshot().selections, 1)
        XCTAssertEqual(host.text, "你")
    }

    func testStaleBoundItemCannotSelectNewHeadOrFallBackAfterEngineLoss() throws {
        let probe = CandidateAuthorityProbe()
        let (coordinator, bridge) = makeBridge(probe)
        defer { coordinator.shutdown() }
        let first = bridge.processKey("n")
        let origin = try XCTUnwrap(first.candidateOrigin)
        let second = bridge.processKey("i")
        let controller = KeyboardController()
        let host = FakeTextInputClient()
        controller.textClient = host
        controller.rimeEngine = bridge
        // Keep Core on the original displayed page while the native owner has
        // moved on: this must reach the provider rejection, not only Core's guard.
        controller.applyRimeOutput(first)
        XCTAssertEqual(controller.state.lastRimeOutput?.candidateOrigin, origin)
        XCTAssertNotEqual(second.candidateOrigin, origin)
        var commits: [String] = []
        controller.onCommittedText = { commits.append($0.text) }
        let action = KeyboardAction.insertCandidate(
            "你", kind: .candidate,
            selectionReference: .init(page: 0, indexOnPage: 0, globalIndex: 0, candidateOrigin: origin))
        _ = controller.handle(action)
        XCTAssertEqual(probe.snapshot().selections, 0)
        XCTAssertTrue(commits.isEmpty)
        controller.rimeEngine = nil
        controller.state.lastRimeOutput = nil
        _ = controller.handle(action)
        XCTAssertTrue(commits.isEmpty)
        XCTAssertEqual(probe.snapshot().selections, 0)
    }

    func testUnboundLocalFallbackRetainsExistingCommitContract() {
        let controller = KeyboardController()
        let host = FakeTextInputClient()
        controller.textClient = host
        _ = controller.handle(.insertCandidate("本地", kind: .candidate))
        XCTAssertEqual(host.text, "本地")
    }

    func testSyntheticIndexOnNativePageDoesNotCallNativeSelect() throws {
        let probe = CandidateAuthorityProbe()
        let (coordinator, bridge) = makeBridge(probe)
        defer { coordinator.shutdown() }
        let output = bridge.processKey("n")
        XCTAssertNotNil(output.candidateOrigin)
        let controller = KeyboardController()
        let host = FakeTextInputClient()
        controller.textClient = host
        controller.rimeEngine = bridge
        controller.applyRimeOutput(output)
        _ = controller.handle(
            .insertCandidate(
                "你", kind: .candidate,
                selectionReference: .init(page: 0, indexOnPage: 0, globalIndex: 0)))
        XCTAssertEqual(probe.snapshot().selections, 0)
        XCTAssertEqual(host.text, host.markedText)
    }

    func testLocalAugmentationStillCommitsWithoutNativeSelect() throws {
        let probe = CandidateAuthorityProbe()
        let (coordinator, bridge) = makeBridge(probe)
        defer { coordinator.shutdown() }
        _ = bridge.processKey("n")
        let controller = KeyboardController()
        let host = FakeTextInputClient()
        controller.textClient = host
        controller.rimeEngine = bridge
        let local = controller.augmentRimeOutputIfNeeded(
            RimeOutput(
                rawInput: "ni2",
                composition: .init(preeditText: "ni2", cursorPosition: 3),
                candidates: []))
        XCTAssertNil(local.candidateOrigin)
        XCTAssertFalse(local.candidates.isEmpty)
        controller.applyRimeOutput(local)
        _ = controller.handle(
            .insertCandidate(
                local.candidates[0].text, kind: .candidate,
                selectionReference: .init(page: 0, indexOnPage: 0, globalIndex: 0)))
        XCTAssertEqual(probe.snapshot().selections, 0)
        XCTAssertFalse(host.text.isEmpty)
    }
}
