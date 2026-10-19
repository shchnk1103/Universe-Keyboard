import Foundation
import Synchronization
import XCTest

@testable import KeyboardCore

// Controlled engine instrumentation, not a natural UIKit/RIME reproducer.
final class CandidateAuthorityProbe: Sendable {
    struct Facts: Sendable {
        var selections = 0
        var windows = 0
        var outputs: [String: ResponsiveRimeSnapshot] = [:]
    }
    let entered = DispatchSemaphore(value: 0)
    let release = DispatchSemaphore(value: 0)
    let delivered = DispatchSemaphore(value: 0)
    let blockProcess: Bool
    let blockReset: Bool
    private let facts = Mutex(Facts())

    init(blockProcess: Bool = false, blockReset: Bool = false) {
        self.blockProcess = blockProcess
        self.blockReset = blockReset
    }
    func selected() { facts.withLock { $0.selections += 1 } }
    func readWindow() { facts.withLock { $0.windows += 1 } }
    func completed(_ value: ResponsiveRimeSnapshot) {
        facts.withLock { $0.outputs[value.actionID] = value }
        delivered.signal()
    }
    func snapshot() -> Facts { facts.withLock { $0 } }
    func waitFor(_ actionID: String) -> ResponsiveRimeSnapshot? {
        let deadline = DispatchTime.now() + 2
        while true {
            if let value = snapshot().outputs[actionID] { return value }
            if delivered.wait(timeout: deadline) != .success { return nil }
        }
    }
}

struct CandidateAuthorityBootstrap: ThreadAffineRimeEngineBootstrap {
    let probe: CandidateAuthorityProbe
    func makeEngineOnOwnerThread() -> any RimeEngine { CandidateAuthorityEngine(probe: probe) }
}

private final class CandidateAuthorityEngine: RimeEngine {
    private let engine = FakeRimeEngine(dictionary: ["n": ["你", "呢", "泥"], "ni": ["你", "妮"]])
    private let probe: CandidateAuthorityProbe
    init(probe: CandidateAuthorityProbe) { self.probe = probe }
    var runtimeSelection: RimeRuntimeSelection? { engine.runtimeSelection }
    var onRuntimeSelectionChanged: ((RimeRuntimeSelection) -> Void)? {
        get { engine.onRuntimeSelectionChanged }
        set { engine.onRuntimeSelectionChanged = newValue }
    }
    func processKey(_ key: String) -> RimeOutput {
        if key == "x", probe.blockProcess {
            probe.entered.signal()
            probe.release.wait()
        }
        return engine.processKey(key)
    }
    func selectCandidate(at index: Int) -> RimeOutput {
        probe.selected()
        return engine.selectCandidate(at: index)
    }
    func selectCandidate(globalIndex index: Int) -> RimeOutput {
        probe.selected()
        return engine.selectCandidate(globalIndex: index)
    }
    func candidateWindow(from globalIndex: Int, limit: Int) -> RimeCandidateWindow {
        probe.readWindow()
        return engine.candidateWindow(from: globalIndex, limit: limit)
    }
    func deleteBackward() -> RimeOutput { engine.deleteBackward() }
    func replaceInput(_ input: String) -> RimeOutput { engine.replaceInput(input) }
    func resetSession() {
        engine.resetSession()
        if probe.blockReset {
            // The engine has already changed; acceptance epoch has not advanced yet.
            probe.entered.signal()
            probe.release.wait()
        }
    }
    func recoverSession() { engine.recoverSession() }
    func suspendForVisibilityChange() { engine.suspendForVisibilityChange() }
    func resumeAfterVisibilityChange() { engine.resumeAfterVisibilityChange() }
    func isComposing() -> Bool { engine.isComposing() }
    func pageUp() -> RimeOutput { engine.pageUp() }
    func pageDown() -> RimeOutput { engine.pageDown() }
}

@MainActor
final class CandidateWindowAuthorityTests: XCTestCase {
    private func makeOwner(_ probe: CandidateAuthorityProbe) -> ThreadAffineRimeSpikeOwner {
        ThreadAffineRimeSpikeOwner(bootstrap: CandidateAuthorityBootstrap(probe: probe)) {
            probe.completed($0.snapshot)
        }
    }
    private func seed(
        _ owner: ThreadAffineRimeSpikeOwner, probe: CandidateAuthorityProbe, actionID: String = "seed"
    ) throws -> RimeOutputOrigin {
        let receipt = try XCTUnwrap(owner.accept(.processKey("n"), actionID: actionID))
        let snapshot = try XCTUnwrap(probe.waitFor(actionID))
        XCTAssertEqual(snapshot.sessionEpoch, receipt.sessionEpoch)
        XCTAssertEqual(snapshot.revision, receipt.revision)
        // A queued owner control runs only after the producing work has settled.
        _ = owner.candidateWindow(from: 0, limit: 1)
        return try XCTUnwrap(snapshot.output.candidateOrigin)
    }
    private func read(_ owner: ThreadAffineRimeSpikeOwner, origin: RimeOutputOrigin) throws -> RimeBoundCandidateWindow
    {
        guard case .available(let value) = owner.readCandidateWindow(origin: origin, from: 0, limit: 2) else {
            XCTFail("Expected available bound native page")
            throw NSError(domain: "CandidateWindowAuthorityTests", code: 1)
        }
        return value
    }
    private func prepared(_ window: RimeBoundCandidateWindow) -> RimeCandidatePresentationPage {
        RimeCandidatePresentationPage(
            items: window.window.candidates.map {
                CandidateItem.rimeCandidate(
                    $0, page: 0, indexOnPage: 0, globalIndex: $0.globalIndex,
                    candidateOrigin: window.permit.origin
                )
            },
            nextIndex: window.window.nextIndex, hasMore: window.window.hasMoreCandidates
        )
    }

    func testStableWindowCommitsOnlyOnceAndDoesNotReadEngineDuringConsumption() throws {
        let probe = CandidateAuthorityProbe()
        let owner = makeOwner(probe)
        defer { owner.shutdown(); XCTAssertTrue(owner.waitUntilStopped()) }
        let origin = try seed(owner, probe: probe)
        let window = try read(owner, origin: origin)
        let page = prepared(window)
        let store = RimeCandidatePresentationStore()
        let reads = probe.snapshot().windows
        XCTAssertEqual(owner.consumeCandidateWindow(window, prepared: page, into: store), .accepted)
        XCTAssertEqual(store.page, page)
        XCTAssertEqual(owner.consumeCandidateWindow(window, prepared: page, into: store), .rejected(.stale))
        XCTAssertEqual(probe.snapshot().windows, reads)
    }

    func testDequeuedExecutingWorkRejectsOldPageAlthoughQueueDepthIsZero() throws {
        let probe = CandidateAuthorityProbe(blockProcess: true)
        let owner = makeOwner(probe)
        defer { probe.release.signal(); owner.shutdown(); XCTAssertTrue(owner.waitUntilStopped()) }
        let origin = try seed(owner, probe: probe)
        let window = try read(owner, origin: origin)
        let store = RimeCandidatePresentationStore()
        let old = store.page
        XCTAssertNotNil(owner.accept(.processKey("x"), actionID: "blocked"))
        XCTAssertEqual(probe.entered.wait(timeout: .now() + 2), .success)
        XCTAssertEqual(owner.diagnostics().pendingWorkDepth, 0)
        let reads = probe.snapshot().windows
        XCTAssertEqual(owner.readCandidateWindow(origin: origin, from: 0, limit: 2), .rejected(.busy))
        XCTAssertEqual(owner.consumeCandidateWindow(window, prepared: prepared(window), into: store), .rejected(.busy))
        XCTAssertEqual(store.page, old)
        XCTAssertEqual(probe.snapshot().windows, reads)
    }

    func testResetAfterOrderedTimeoutStillRejectsBeforeEpochAdvance() throws {
        let probe = CandidateAuthorityProbe(blockReset: true)
        let coordinator = ThreadAffineRimeSessionCoordinator(
            bootstrap: .init(CandidateAuthorityBootstrap(probe: probe)))
        let bridge = ThreadAffineRimeEngineBridge(coordinator: coordinator)
        defer { probe.release.signal(); coordinator.shutdown() }
        let output = bridge.processKey("n")
        _ = bridge.candidateWindow(from: 0, limit: 1)
        let origin = try XCTUnwrap(output.candidateOrigin)
        guard case .available(let window) = bridge.readCandidateWindow(origin: origin, from: 0, limit: 2) else {
            return XCTFail("Expected initial page")
        }
        let store = RimeCandidatePresentationStore()
        // Existing five-second ordered wait; a timeout must not clear ownership.
        XCTAssertNil(coordinator.performOrderedNow(.resetSession))
        XCTAssertEqual(probe.entered.wait(timeout: .now()), .success)
        XCTAssertEqual(coordinator.diagnostics.sessionEpoch, origin.sessionEpoch)
        XCTAssertEqual(bridge.consumeCandidateWindow(window, prepared: prepared(window), into: store), .rejected(.busy))
        XCTAssertTrue(store.page.items.isEmpty)
    }

    func testRepeatedEpochControlsAndPurgedWorkSettleBeforeNewPage() throws {
        let probe = CandidateAuthorityProbe(blockProcess: true)
        let owner = makeOwner(probe)
        defer { probe.release.signal(); owner.shutdown(); XCTAssertTrue(owner.waitUntilStopped()) }
        let origin = try seed(owner, probe: probe)
        XCTAssertNotNil(owner.accept(.processKey("x"), actionID: "blocked"))
        XCTAssertEqual(probe.entered.wait(timeout: .now() + 2), .success)
        XCTAssertNotNil(owner.accept(.processKey("i"), actionID: "purged"))
        XCTAssertNotNil(owner.advanceSessionEpoch())
        XCTAssertNotNil(owner.advanceSessionEpoch())
        XCTAssertEqual(owner.readCandidateWindow(origin: origin, from: 0, limit: 1), .rejected(.busy))
        probe.release.signal()
        XCTAssertNotNil(probe.waitFor("blocked"))
        _ = owner.candidateWindow(from: 0, limit: 1)
        let fresh = try seed(owner, probe: probe, actionID: "fresh")
        XCTAssertNotEqual(fresh.sessionEpoch, origin.sessionEpoch)
        XCTAssertEqual(try read(owner, origin: fresh).permit.origin, fresh)
    }

    func testSameEpochNewRevisionAndReplacementOwnerCannotReuseOldOrigin() throws {
        let probe = CandidateAuthorityProbe()
        let owner = makeOwner(probe)
        let otherProbe = CandidateAuthorityProbe()
        let other = makeOwner(otherProbe)
        defer {
            owner.shutdown(); other.shutdown(); XCTAssertTrue(owner.waitUntilStopped());
            XCTAssertTrue(other.waitUntilStopped())
        }
        let origin = try seed(owner, probe: probe)
        let replacement = try seed(other, probe: otherProbe)
        XCTAssertEqual(origin.sessionEpoch, replacement.sessionEpoch)
        XCTAssertEqual(origin.revision, replacement.revision)
        XCTAssertNotEqual(origin.ownerID, replacement.ownerID)
        XCTAssertEqual(other.readCandidateWindow(origin: origin, from: 0, limit: 1), .rejected(.stale))
        let next = try seed(owner, probe: probe, actionID: "next")
        XCTAssertEqual(next.sessionEpoch, origin.sessionEpoch)
        XCTAssertNotEqual(next.revision, origin.revision)
        XCTAssertEqual(owner.readCandidateWindow(origin: origin, from: 0, limit: 1), .rejected(.stale))
    }
}
