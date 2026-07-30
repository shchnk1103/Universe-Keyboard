import Foundation
import Synchronization
import XCTest
@testable import KeyboardCore

@available(macOS 15.0, *)
private struct SpikeFakeRimeEngineFactory: ThreadAffineRimeSpikeEngineFactory {
    func makeEngineOnOwnerThread() -> any RimeEngine {
        FakeRimeEngine()
    }
}

@available(macOS 15.0, *)
@MainActor
final class ThreadAffineRimeSpikeTests: XCTestCase {

    func testMainActorAcceptsWhileOwnerEngineCallIsBlocked() async {
        let engineEntered = DispatchSemaphore(value: 0)
        let releaseEngine = DispatchSemaphore(value: 0)
        let allResults = expectation(description: "all results")
        allResults.expectedFulfillmentCount = 4
        let gate = ThreadAffineRimeSpikeApplyGate()
        let engineCallCount = Mutex(0)

        let owner = ThreadAffineRimeSpikeOwner(
            engineFactory: SpikeFakeRimeEngineFactory(),
            beforeEngineCall: {
                let call = engineCallCount.withLock { count -> Int in
                    count += 1
                    return count
                }
                if call == 1 {
                    engineEntered.signal()
                    releaseEngine.wait()
                }
            },
            resultHandler: { result in
                _ = gate.apply(result)
                allResults.fulfill()
            }
        )

        XCTAssertNotNil(owner.accept(.processKey("n"), actionID: "k0"))
        XCTAssertEqual(engineEntered.wait(timeout: .now() + 1), .success)

        let blockedAt = DispatchTime.now().uptimeNanoseconds
        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + 0.18) {
            releaseEngine.signal()
        }
        let started = DispatchTime.now().uptimeNanoseconds
        for (index, key) in ["i", "h", "a"].enumerated() {
            let receipt = owner.accept(.processKey(key), actionID: "k\(index + 1)")
            XCTAssertNotNil(receipt)
            XCTAssertEqual(receipt?.executedSynchronously, false)
        }
        let elapsedMS =
            Double(DispatchTime.now().uptimeNanoseconds &- started) / 1_000_000
        XCTAssertLessThan(elapsedMS, 50, "MainActor accept must not wait on blocked engine")

        await fulfillment(of: [allResults], timeout: 2)
        let blockedMS =
            Double(DispatchTime.now().uptimeNanoseconds &- blockedAt) / 1_000_000
        XCTAssertGreaterThanOrEqual(blockedMS, 150, "proof must cover a 150ms+ owner stall")

        XCTAssertEqual(gate.appliedSnapshots.map(\.actionID), ["k0", "k1", "k2", "k3"])
        XCTAssertEqual(gate.appliedSnapshots.last?.output.rawInput, "niha")
        owner.shutdown()
        XCTAssertTrue(owner.waitUntilStopped())
    }

    func testDedicatedOwnerPreservesOrderWithoutDropOrDuplicate() async {
        let keyCount = 12
        let allResults = expectation(description: "ordered results")
        allResults.expectedFulfillmentCount = keyCount
        let gate = ThreadAffineRimeSpikeApplyGate()
        var affinityFacts: [(offMain: Bool, sameThread: Bool)] = []

        let owner = ThreadAffineRimeSpikeOwner(
            engineFactory: SpikeFakeRimeEngineFactory(),
            resultHandler: { result in
                affinityFacts.append(
                    (result.engineCreatedOffMainThread, result.engineCallStayedOnCreationThread)
                )
                _ = gate.apply(result)
                allResults.fulfill()
            }
        )

        for index in 0..<keyCount {
            XCTAssertNotNil(
                owner.accept(.processKey("n"), actionID: "k\(index)")
            )
        }
        await fulfillment(of: [allResults], timeout: 2)

        XCTAssertEqual(
            gate.appliedSnapshots.map(\.revision),
            Array(1...UInt64(keyCount))
        )
        XCTAssertEqual(
            gate.appliedSnapshots.map(\.actionID),
            (0..<keyCount).map { "k\($0)" }
        )
        XCTAssertEqual(Set(gate.appliedSnapshots.map(\.actionID)).count, keyCount)
        XCTAssertTrue(affinityFacts.allSatisfy(\.offMain))
        XCTAssertTrue(affinityFacts.allSatisfy(\.sameThread))
        owner.shutdown()
        XCTAssertTrue(owner.waitUntilStopped())
    }

    func testOldEpochResultIsRejectedAndNewEpochRunsAfterResetBarrier() async throws {
        let firstEngineEntered = DispatchSemaphore(value: 0)
        let releaseFirstEngineCall = DispatchSemaphore(value: 0)
        let deliveries = expectation(description: "old and new delivered")
        deliveries.expectedFulfillmentCount = 2
        let gate = ThreadAffineRimeSpikeApplyGate()

        let callCount = Mutex(0)
        let owner = ThreadAffineRimeSpikeOwner(
            engineFactory: SpikeFakeRimeEngineFactory(),
            beforeEngineCall: {
                let call = callCount.withLock { count -> Int in
                    count += 1
                    return count
                }
                if call == 1 {
                    firstEngineEntered.signal()
                    releaseFirstEngineCall.wait()
                }
            },
            resultHandler: { result in
                _ = gate.apply(result)
                deliveries.fulfill()
            }
        )

        XCTAssertNotNil(owner.accept(.processKey("n"), actionID: "old"))
        XCTAssertEqual(firstEngineEntered.wait(timeout: .now() + 1), .success)

        let newEpoch = try XCTUnwrap(owner.advanceSessionEpoch())
        gate.advanceSessionEpoch(to: newEpoch)
        XCTAssertNotNil(owner.accept(.processKey("w"), actionID: "new"))
        releaseFirstEngineCall.signal()

        await fulfillment(of: [deliveries], timeout: 2)
        XCTAssertEqual(gate.discardedResultCount, 1)
        XCTAssertEqual(gate.appliedSnapshots.map(\.actionID), ["new"])
        XCTAssertEqual(gate.appliedSnapshots.last?.output.rawInput, "w")
        owner.shutdown()
        XCTAssertTrue(owner.waitUntilStopped())
    }

    func testApplyGateRejectsOlderRevisionDeliveredAfterNewerRevision() {
        let gate = ThreadAffineRimeSpikeApplyGate()
        let newer = makeResult(epoch: 1, revision: 2, actionID: "new")
        let older = makeResult(epoch: 1, revision: 1, actionID: "old")

        XCTAssertTrue(gate.apply(newer))
        XCTAssertFalse(gate.apply(older))
        XCTAssertEqual(gate.appliedSnapshots.map(\.actionID), ["new"])
        XCTAssertEqual(gate.discardedResultCount, 1)
    }

    func testSpikeIsNotWiredAndGateOffRemainsSynchronous() {
        let engine = FakeRimeEngine()
        let controller = KeyboardController()
        controller.textClient = FakeTextInputClient()
        controller.rimeEngine = engine

        XCTAssertFalse(controller.isResponsiveRimePipelineEnabled)
        _ = controller.handle(.insertKey("n"))

        XCTAssertEqual(engine.processKeyCallCount, 1)
        XCTAssertEqual(engine.sessionComposition, "n")
        XCTAssertNil(controller.responsiveRimeCoordinator)
    }

    private func makeResult(
        epoch: UInt64,
        revision: UInt64,
        actionID: String
    ) -> ThreadAffineRimeSpikeResult {
        ThreadAffineRimeSpikeResult(
            snapshot: ResponsiveRimeSnapshot(
                sessionEpoch: epoch,
                revision: revision,
                actionID: actionID,
                output: RimeOutput(rawInput: actionID)
            ),
            engineCreatedOffMainThread: true,
            engineCallStayedOnCreationThread: true
        )
    }
}
