#if DEBUG && KEYBOARD_QUERY_COST_PROBE
    import Foundation
    import KeyboardCore
    import XCTest
    import os

    nonisolated final class TypoCorrectionQueryCostProbeIntegrationTests: XCTestCase {
        func testOrdinaryPublicProbeAccessAlwaysReturnsTheSameProductionObject() {
            // This file deliberately uses ordinary import, not testable construction.
            XCTAssertTrue(QueryCostMemoryProbe.shared === QueryCostMemoryProbe.shared)
        }
        @MainActor func testFacadeIdentityIsStablePerInstalledOwnerAndChangesOnReplacement() {
            let query = ScopeOnlyQuery()
            let first = InstalledTypoCorrectionSidecarOwner(query: query)
            let second = InstalledTypoCorrectionSidecarOwner(query: query)
            let ordinal = first.queryCostFacadeOrdinal
            XCTAssertNotEqual(ordinal, 0)
            XCTAssertEqual(first.queryCostFacadeOrdinal, ordinal)
            XCTAssertNotEqual(second.queryCostFacadeOrdinal, ordinal)
            XCTAssertFalse(first.queryCostUsesCandidateProvider)
            XCTAssertEqual(query.invocations, 0)
            XCTAssertEqual(query.scopeReads, 0)
        }
        @MainActor func testProviderKindObservationDoesNotPretendToExposeNativeCorrectionSession() {
            let query = CandidateProviderTypoCorrectionQuery(candidateProvider: FakeCandidateProvider())
            let owner = InstalledTypoCorrectionSidecarOwner(query: query, route: .threadAffine)
            XCTAssertTrue(owner.queryCostUsesCandidateProvider)
            XCTAssertNotEqual(owner.queryCostFacadeOrdinal, 0)
            XCTAssertNil(owner.existingCorrectionQueryDebugScope())
        }
        @MainActor func testScopeObservationUsesInstalledFacadeAndNeverQueries() {
            let query = ScopeOnlyQuery()
            let owner = InstalledTypoCorrectionSidecarOwner(query: query)
            XCTAssertEqual(owner.existingCorrectionQueryDebugScope(), query.scope)
            XCTAssertEqual(owner.existingCorrectionQueryDebugScope(), query.scope)
            XCTAssertEqual(query.invocations, 0)
            XCTAssertFalse(owner.isTypoCorrectionRecallActive)
        }
        @MainActor func testUnsupportedOwnerRoutesStayUnknownWithoutUnwrappingOrFallback() {
            let query = ScopeOnlyQuery()
            for route in [TypoCorrectionSidecarRoute.mainActorResponsive, .threadAffine] {
                let owner = InstalledTypoCorrectionSidecarOwner(query: query, route: route)
                XCTAssertNil(owner.existingCorrectionQueryDebugScope())
            }
            XCTAssertEqual(query.invocations, 0)
            XCTAssertEqual(query.scopeReads, 0)
        }
        #if KEYBOARD_QUERY_COST_PROBE_TESTING
            @MainActor func testClockAnchorsEmitTwoPairsWithOneNumericIdentity() {
                let harness = ClockAnchorHarness()
                let anchor = harness.makeAnchor()
                XCTAssertEqual(anchor.emitNext(eligible: true), .firstEmitted)
                XCTAssertEqual(anchor.state, .firstEmitted)
                XCTAssertEqual(anchor.emitNext(eligible: true), .secondEmitted)
                XCTAssertEqual(anchor.state, .consumed)
                XCTAssertEqual(
                    harness.steps, ["clock", "anchor", "clock", "witness", "clock", "anchor", "clock", "witness"])
                XCTAssertEqual(harness.events.map(\.ordinal), [1, 1, 2, 2])
                XCTAssertEqual(harness.events.map(\.uptimeNanoseconds), [100, 101, 200, 201])
                XCTAssertEqual(harness.events.map(\.id.rawValue), [11, 11, 12, 12])
                XCTAssertTrue(harness.events.allSatisfy { $0.nonceHi == 41 && $0.nonceLo == 42 })
                XCTAssertEqual(anchor.emitNext(eligible: true), .invalid)
                XCTAssertEqual(anchor.state, .invalid)
                XCTAssertEqual(harness.events.count, 4)
            }

            @MainActor func testClockAnchorEligibilityFailureConsumesTheOpportunity() {
                let harness = ClockAnchorHarness()
                let anchor = harness.makeAnchor()
                XCTAssertEqual(anchor.emitNext(eligible: false), .invalid)
                XCTAssertEqual(anchor.emitNext(eligible: true), .invalid)
                XCTAssertTrue(harness.events.isEmpty)
                XCTAssertEqual(harness.idIndex, 0)
                XCTAssertEqual(harness.clockIndex, 0)
            }

            @MainActor func testClockAnchorDisabledObserverCannotBeRetried() {
                let harness = ClockAnchorHarness()
                harness.enabled = false
                let anchor = harness.makeAnchor()
                XCTAssertEqual(anchor.emitNext(eligible: true), .invalid)
                harness.enabled = true
                XCTAssertEqual(anchor.emitNext(eligible: true), .invalid)
                XCTAssertTrue(harness.events.isEmpty)
                XCTAssertEqual(harness.idIndex, 0)
            }

            @MainActor func testClockAnchorRejectsReservedAndDuplicateIDs() {
                for reserved in [OSSignpostID.null, .invalid, .exclusive] {
                    let harness = ClockAnchorHarness()
                    harness.ids = [reserved]
                    let anchor = harness.makeAnchor()
                    XCTAssertEqual(anchor.emitNext(eligible: true), .invalid)
                    XCTAssertEqual(anchor.emitNext(eligible: true), .invalid)
                    XCTAssertTrue(harness.events.isEmpty)
                    XCTAssertEqual(harness.clockIndex, 0)
                }
                let harness = ClockAnchorHarness()
                harness.ids = [OSSignpostID(11), OSSignpostID(11)]
                let anchor = harness.makeAnchor()
                XCTAssertEqual(anchor.emitNext(eligible: true), .firstEmitted)
                XCTAssertEqual(anchor.emitNext(eligible: true), .invalid)
                XCTAssertEqual(harness.events.count, 2)
                XCTAssertEqual(harness.clockIndex, 2)
            }

            @MainActor func testClockAnchorBackwardBracketStaysPartialAndInvalid() {
                let harness = ClockAnchorHarness()
                harness.times = [100, 99]
                let anchor = harness.makeAnchor()
                XCTAssertEqual(anchor.emitNext(eligible: true), .invalid)
                XCTAssertEqual(anchor.emitNext(eligible: true), .invalid)
                XCTAssertEqual(harness.events.count, 1)
                XCTAssertEqual(harness.events.first?.kind, .anchor)
                XCTAssertEqual(anchor.state, .invalid)
            }

            @MainActor func testClockAnchorSecondWindowMustFollowTheFirstUpperBound() {
                let harness = ClockAnchorHarness()
                harness.times = [100, 101, 101]
                let anchor = harness.makeAnchor()
                XCTAssertEqual(anchor.emitNext(eligible: true), .firstEmitted)
                XCTAssertEqual(anchor.emitNext(eligible: true), .invalid)
                XCTAssertEqual(harness.events.count, 2)
                XCTAssertEqual(anchor.state, .invalid)
            }

            @MainActor func testClockAnchorEmitterInvalidationCannotRestoreSuccess() {
                let harness = ClockAnchorHarness()
                let anchor = harness.makeAnchor()
                harness.onDependency = { [weak anchor] step in
                    if step == "anchor" { anchor?.invalidate() }
                }
                XCTAssertEqual(anchor.emitNext(eligible: true), .invalid)
                XCTAssertEqual(anchor.state, .invalid)
                XCTAssertEqual(harness.events.map(\.kind), [.anchor])
                XCTAssertEqual(harness.clockIndex, 1)
                XCTAssertEqual(anchor.emitNext(eligible: true), .invalid)
                XCTAssertEqual(harness.events.count, 1)
            }

            @MainActor func testClockAnchorEmitterReentryCancelsTheOuterAttempt() {
                let harness = ClockAnchorHarness()
                let anchor = harness.makeAnchor()
                var nestedResult: QueryCostClockAnchor.Result?
                harness.onDependency = { [weak anchor] step in
                    if step == "anchor" { nestedResult = anchor?.emitNext(eligible: true) }
                }
                XCTAssertEqual(anchor.emitNext(eligible: true), .invalid)
                XCTAssertEqual(nestedResult, .invalid)
                XCTAssertEqual(anchor.state, .invalid)
                XCTAssertEqual(harness.events.map(\.kind), [.anchor])
                XCTAssertEqual(harness.clockIndex, 1)
                XCTAssertEqual(anchor.emitNext(eligible: true), .invalid)
                XCTAssertEqual(harness.events.count, 1)
            }

            @MainActor func testClockAnchorInvalidationStopsAtEveryDependencyBoundary() {
                let boundaries = ["enabled", "id", "before", "anchor", "after", "witness"]
                // Check cancellation while emitting either ordinal, including after witness.
                for emitFirstAnchor in [false, true] {
                    for boundary in boundaries {
                        let harness = ClockAnchorHarness()
                        let anchor = harness.makeAnchor()
                        if emitFirstAnchor {
                            XCTAssertEqual(anchor.emitNext(eligible: true), .firstEmitted)
                        }
                        harness.onDependency = { [weak anchor] step in
                            if step == boundary { anchor?.invalidate() }
                        }
                        XCTAssertEqual(anchor.emitNext(eligible: true), .invalid)
                        XCTAssertEqual(anchor.state, .invalid)
                        let prefix: [QueryCostClockAnchor.EventKind] =
                            emitFirstAnchor ? [.anchor, .witness] : []
                        let tail: [QueryCostClockAnchor.EventKind]
                        switch boundary {
                        case "anchor", "after": tail = [.anchor]
                        case "witness": tail = [.anchor, .witness]
                        default: tail = []
                        }
                        XCTAssertEqual(harness.events.map(\.kind), prefix + tail, boundary)
                        let count = harness.events.count
                        let clockCount = harness.clockIndex
                        XCTAssertEqual(anchor.emitNext(eligible: true), .invalid)
                        XCTAssertEqual(harness.events.count, count)
                        XCTAssertEqual(harness.clockIndex, clockCount)
                    }
                }
            }

            @MainActor func testClockAnchorLifecycleInvalidationHasNoEmissionOrReset() {
                let harness = ClockAnchorHarness()
                let anchor = harness.makeAnchor()
                XCTAssertEqual(anchor.emitNext(eligible: true), .firstEmitted)
                anchor.invalidate()
                XCTAssertEqual(anchor.emitNext(eligible: true), .invalid)
                XCTAssertEqual(harness.events.count, 2)
                XCTAssertEqual(anchor.state, .invalid)
            }
        #endif
    }

    #if KEYBOARD_QUERY_COST_PROBE_TESTING
        @MainActor
        private final class ClockAnchorHarness {
            var enabled = true
            var ids = [OSSignpostID(11), OSSignpostID(12)]
            var times: [UInt64] = [100, 101, 200, 201]
            private(set) var idIndex = 0
            private(set) var clockIndex = 0
            private(set) var events: [QueryCostClockAnchor.Event] = []
            private(set) var steps: [String] = []
            var onDependency: ((String) -> Void)?

            func makeAnchor() -> QueryCostClockAnchor {
                QueryCostClockAnchor(
                    testingNonceHi: 41, nonceLo: 42,
                    isEnabled: {
                        self.onDependency?("enabled")
                        return self.enabled
                    },
                    makeID: {
                        let id = self.ids[self.idIndex]
                        self.idIndex += 1
                        self.onDependency?("id")
                        return id
                    },
                    clock: {
                        self.steps.append("clock")
                        let time = self.times[self.clockIndex]
                        let step = self.clockIndex.isMultiple(of: 2) ? "before" : "after"
                        self.clockIndex += 1
                        self.onDependency?(step)
                        return time
                    },
                    emit: { event in
                        self.steps.append(event.kind == .anchor ? "anchor" : "witness")
                        self.events.append(event)
                        self.onDependency?(event.kind == .anchor ? "anchor" : "witness")
                    })
            }
        }
    #endif

    private final class ScopeOnlyQuery: TypoCorrectionCandidateQuerying, TypoCorrectionQueryDebugScoping {
        let scope = TypoCorrectionQueryDebugScope(sessionOrdinal: 17, schema: .lunaPinyin)
        private(set) var invocations = 0
        @MainActor private(set) var scopeReads = 0
        @MainActor func existingCorrectionQueryDebugScope() -> TypoCorrectionQueryDebugScope? {
            scopeReads += 1
            return scope
        }
        func correctionCandidates(for input: String, limit: Int) -> [RimeCandidate] {
            invocations += 1
            return []
        }
    }
#endif
