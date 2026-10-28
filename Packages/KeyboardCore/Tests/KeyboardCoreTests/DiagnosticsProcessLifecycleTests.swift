import Foundation
import Synchronization
import XCTest

@testable import KeyboardCore

final class DiagnosticsProcessLifecycleTests: XCTestCase {
    func testIngressIgnoresOlderAndRepeatedGenerations() {
        let id = UUID()
        let ingress = DiagnosticsJournalIngress(
            origin: .mainApp, processInstanceID: id, isMainAppWriter: false,
            rootURL: { nil }, isCategoryEnabled: { _ in true }, flushDelay: 60
        )
        let event = DiagnosticEvent(
            utcTimestamp: Date(), monotonicNanoseconds: 1, origin: .mainApp,
            processInstanceID: id, localSequence: 1, code: .journalStarted, level: .info, category: .general
        )
        _ = ingress.applyProcessLifecycle(active: false, generation: 0)
        ingress.record(event)
        XCTAssertEqual(ingress.testingSnapshotForTesting().accepted, 0)
        _ = ingress.applyProcessLifecycle(active: true, generation: 2)
        _ = ingress.applyProcessLifecycle(active: false, generation: 1)
        _ = ingress.applyProcessLifecycle(active: false, generation: 2)
        ingress.record(event)
        XCTAssertEqual(ingress.testingSnapshotForTesting().accepted, 1)
    }

    func testCallbacksCanReenterCoordinator() {
        let lifecycle = DiagnosticsProcessLifecycle()
        let member = LifecycleFake { active in
            if active { lifecycle.setActive(false) }
        }
        lifecycle.registerMember(member)
        lifecycle.setActive(true)
        XCTAssertEqual(member.snapshot().active, false)
        XCTAssertEqual(member.snapshot().generation, 2)
    }

    func testConcurrentRegistrationAndChangesConverge() {
        let lifecycle = DiagnosticsProcessLifecycle()
        let members = (0..<100).map { _ in LifecycleFake { _ in } }
        DispatchQueue.concurrentPerform(iterations: 200) { index in
            if index < members.count {
                lifecycle.registerMember(members[index])
            } else {
                lifecycle.setActive(index.isMultiple(of: 2))
            }
        }
        lifecycle.setActive(false)
        XCTAssertTrue(members.allSatisfy { !$0.snapshot().active })
    }

    func testGenerationExhaustionStaysClosed() {
        let lifecycle = DiagnosticsProcessLifecycle()
        lifecycle.testingSetGeneration(UInt64.max - 1)
        let member = LifecycleFake { _ in }
        lifecycle.registerMember(member)
        lifecycle.setActive(true)
        lifecycle.setActive(true)
        XCTAssertEqual(member.snapshot().generation, UInt64.max)
        XCTAssertFalse(member.snapshot().active)
    }
}

private final class LifecycleFake: DiagnosticsLifecycleMember {
    private struct State: Sendable {
        var active = false
        var generation: UInt64?
    }
    private let state = Mutex(State())
    private let callback: @Sendable (Bool) -> Void

    init(callback: @escaping @Sendable (Bool) -> Void) { self.callback = callback }

    func applyProcessLifecycle(active: Bool, generation: UInt64) {
        let applied = state.withLock { state in
            if let previous = state.generation, generation <= previous { return false }
            state.active = active
            state.generation = generation
            return true
        }
        if applied { callback(active) }
    }

    func snapshot() -> (active: Bool, generation: UInt64?) {
        state.withLock { ($0.active, $0.generation) }
    }
}
