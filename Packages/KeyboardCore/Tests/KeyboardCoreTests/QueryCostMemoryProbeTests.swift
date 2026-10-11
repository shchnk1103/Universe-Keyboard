#if DEBUG && KEYBOARD_QUERY_COST_PROBE
    import Foundation
    import Synchronization
    import XCTest
    @testable import KeyboardCore

    /// Only synthetic finite values. Creating a test instance does not reset the production singleton.
    enum QueryCostProbeTestFixture {
        static let session = QueryCostMemoryProbe.FacadeScope(
            kind: .nativeCorrectionSession, facadeOrdinal: 1, lifetimeOrdinal: 1, schema: .lunaPinyin)
        static func scope() -> QueryCostMemoryProbe.Scope {
            .init(coordinatorOrdinal: 1, facade: session, fullAccess: true)
        }
        static func payload(
            operation: UInt64 = 1, stage: TypoCorrectionRecallStage = .stageOne,
            readiness: TypoCorrectionQueryReadiness = .ready,
            result: TypoCorrectionQueryResultState = .candidatesReturned,
            bucket: DiagnosticEvent.TypoRecallCandidateBucket = .zero,
            disposition: DiagnosticEvent.TypoRecallQueryDisposition = .applied,
            elapsed: UInt32 = 7,
            duration: DiagnosticEvent.TypoRecallQueryDurationState = .measured
        ) -> DiagnosticEvent.TypoRecallQueryPayload {
            .init(
                operationOrdinal: operation, stage: stage, readiness: readiness, resultState: result,
                returnedCandidateBucket: bucket, disposition: disposition,
                facadeElapsedMicroseconds: elapsed, durationState: duration)
        }
        static func bytes(_ snapshot: QueryCostMemoryProbe.Snapshot) -> [UInt8] {
            snapshot.withUnsafeBytes { Array($0) }
        }
        static func bytes(words: [UInt64]) -> [UInt8] {
            words.flatMap { value in (0..<8).map { UInt8(truncatingIfNeeded: value >> ($0 * 8)) } }
        }
        static func armed(now: @escaping @Sendable () -> UInt64 = { 100 }) -> QueryCostMemoryProbe {
            let probe = QueryCostMemoryProbe.makeSyntheticForTesting(now: now)
            XCTAssertEqual(probe.arm(scope(), eligible: true), .armed)
            XCTAssertTrue(probe.beginSequence(ordinal: 1, fixture: 1, arm: 1, eligible: true))
            return probe
        }
        static func completeOne() throws -> QueryCostMemoryProbe.Snapshot {
            let probe = armed()
            probe.beginOperation(1)
            let reservation = probe.beginInvocation(operation: 1, stage: .stageOne, epoch: 2, revision: 3)
            probe.finishInvocation(reservation, payload: payload())
            probe.endOperation(1, terminal: .completed)
            XCTAssertTrue(probe.endSequence(eligible: true))
            return try XCTUnwrap(probe.freeze())
        }
    }

    nonisolated final class QueryCostMemoryProbeTests: XCTestCase {
        func testProviderScopeRequiresPublishedReadyValidLunaAndStableEpoch() throws {
            let valid = try XCTUnwrap(
                QueryCostMemoryProbe.FacadeScope.threadAffineProvider(
                    facadeOrdinal: 8, epochBefore: 7, epochAfter: 7, ownerReady: true,
                    nativeSessionValid: true, schema: .lunaPinyin))
            XCTAssertEqual(valid.kind, .threadAffineProvider)
            XCTAssertEqual(valid.lifetimeOrdinal, 7)
            XCTAssertEqual(valid.facadeOrdinal, 8)
            XCTAssertTrue(valid.isAdmissible)
            let cases: [(UInt64, UInt64, UInt64, Bool, Bool, TypoCorrectionQueryDebugScope.Schema)] = [
                (0, 7, 7, true, true, .lunaPinyin), (8, 0, 0, true, true, .lunaPinyin),
                (8, 7, 8, true, true, .lunaPinyin), (8, 7, 7, false, true, .lunaPinyin),
                (8, 7, 7, true, false, .lunaPinyin), (8, 7, 7, true, true, .unknown),
            ]
            for item in cases {
                XCTAssertNil(
                    QueryCostMemoryProbe.FacadeScope.threadAffineProvider(
                        facadeOrdinal: item.0, epochBefore: item.1, epochAfter: item.2,
                        ownerReady: item.3, nativeSessionValid: item.4, schema: item.5))
            }
        }
        func testProviderV2SnapshotLabelsEpochAndFacadeWithoutIncreasingBuffer() throws {
            let facade = QueryCostMemoryProbe.FacadeScope(
                kind: .threadAffineProvider,
                facadeOrdinal: 8, lifetimeOrdinal: 7, schema: .lunaPinyin)
            let probe = QueryCostMemoryProbe.makeSyntheticForTesting()
            XCTAssertEqual(
                probe.arm(
                    .init(coordinatorOrdinal: 1, facade: facade, fullAccess: true),
                    eligible: true), .armed)
            XCTAssertTrue(probe.beginSequence(ordinal: 1, fixture: 1, arm: 1, eligible: true))
            XCTAssertTrue(probe.endSequence(eligible: true))
            let snapshot = try XCTUnwrap(probe.freeze())
            XCTAssertEqual(snapshot.words[1], 2)
            XCTAssertEqual(snapshot.words[13], 7)
            XCTAssertEqual(snapshot.words[16], 2)
            XCTAssertEqual(snapshot.words[31], 8)
            XCTAssertEqual(QueryCostMemoryProbe.decode(QueryCostProbeTestFixture.bytes(snapshot)), snapshot)
            XCTAssertEqual(QueryCostMemoryProbe.maximumBytes, 655616)
        }
        func testEachFacadeIdentityComponentInvalidatesTheExistingRun() throws {
            let baseline = QueryCostMemoryProbe.FacadeScope(
                kind: .threadAffineProvider,
                facadeOrdinal: 8, lifetimeOrdinal: 7, schema: .lunaPinyin)
            let replacements: [QueryCostMemoryProbe.FacadeScope] = [
                .init(kind: .nativeCorrectionSession, facadeOrdinal: 8, lifetimeOrdinal: 7, schema: .lunaPinyin),
                .init(kind: .threadAffineProvider, facadeOrdinal: 9, lifetimeOrdinal: 7, schema: .lunaPinyin),
                .init(kind: .threadAffineProvider, facadeOrdinal: 8, lifetimeOrdinal: 8, schema: .lunaPinyin),
                .init(kind: .threadAffineProvider, facadeOrdinal: 8, lifetimeOrdinal: 7, schema: .unknown),
            ]
            for changed in replacements {
                let probe = QueryCostMemoryProbe.makeSyntheticForTesting()
                XCTAssertEqual(
                    probe.arm(
                        .init(coordinatorOrdinal: 1, facade: baseline, fullAccess: true),
                        eligible: true), .armed)
                probe.verifyScope(facade: changed, fullAccess: true)
                let snapshot = try XCTUnwrap(probe.freeze())
                XCTAssertTrue(snapshot.isIncomplete)
                XCTAssertNotEqual(snapshot.words[7] & QueryCostMemoryProbe.Reason.scopeChange.rawValue, 0)
            }
        }
        func testUnsupportedKindsAndMissingFacadeIdentityCannotArm() {
            for kind in [QueryCostMemoryProbe.ScopeKind.unavailable, .unsupportedResponsive] {
                let probe = QueryCostMemoryProbe.makeSyntheticForTesting()
                let facade = QueryCostMemoryProbe.FacadeScope(
                    kind: kind, facadeOrdinal: 8,
                    lifetimeOrdinal: 7, schema: .lunaPinyin)
                XCTAssertEqual(
                    probe.arm(
                        .init(coordinatorOrdinal: 1, facade: facade, fullAccess: true),
                        eligible: true), .rejected)
            }
            let probe = QueryCostMemoryProbe.makeSyntheticForTesting()
            let facade = QueryCostMemoryProbe.FacadeScope(
                kind: .threadAffineProvider, facadeOrdinal: 0,
                lifetimeOrdinal: 7, schema: .lunaPinyin)
            XCTAssertEqual(
                probe.arm(
                    .init(coordinatorOrdinal: 1, facade: facade, fullAccess: true),
                    eligible: true), .rejected)
        }
        func testSyntheticOwnershipNeverReplacesOrConsumesSharedProductionProbe() {
            let shared = QueryCostMemoryProbe.shared
            let status = shared.status
            let first = QueryCostMemoryProbe.makeSyntheticForTesting()
            let second = QueryCostMemoryProbe.makeSyntheticForTesting()
            XCTAssertTrue(shared === QueryCostMemoryProbe.shared)
            XCTAssertFalse(shared.isSyntheticForTesting)
            XCTAssertTrue(first.isSyntheticForTesting)
            XCTAssertTrue(second.isSyntheticForTesting)
            XCTAssertFalse(first === shared)
            XCTAssertFalse(first === second)
            XCTAssertEqual(first.arm(QueryCostProbeTestFixture.scope(), eligible: false), .rejected)
            XCTAssertEqual(first.arm(QueryCostProbeTestFixture.scope(), eligible: true), .alreadyAttempted)
            XCTAssertEqual(second.status, .disabled)
            XCTAssertEqual(shared.status, status)
        }
        func testNonadjacentTerminalCleanupRetainsFirstTerminalForEachOperation() throws {
            let probe = QueryCostProbeTestFixture.armed()
            probe.beginOperation(1)
            probe.endOperation(1, terminal: .cancelled)
            probe.beginOperation(2)
            probe.endOperation(2, terminal: .completed)
            probe.endOperation(1, terminal: .fenced)  // A outer cleanup follows B's terminal.
            XCTAssertTrue(probe.endSequence(eligible: true))
            let snapshot = try XCTUnwrap(probe.freeze())
            XCTAssertFalse(snapshot.isIncomplete)
            XCTAssertEqual(snapshot.words[23...25], [2, 2, 0])
            XCTAssertEqual(snapshot.words[4], 6)
            XCTAssertEqual(QueryCostMemoryProbe.decode(QueryCostProbeTestFixture.bytes(snapshot)), snapshot)
        }
        func testUnknownTerminalIsNotMistakenForAnEarlierCompletedOperation() throws {
            let probe = QueryCostProbeTestFixture.armed()
            probe.beginOperation(1)
            probe.endOperation(1, terminal: .completed)
            probe.endOperation(0, terminal: .completed)
            probe.endOperation(2, terminal: .completed)
            XCTAssertTrue(probe.endSequence(eligible: true))
            let snapshot = try XCTUnwrap(probe.freeze())
            XCTAssertTrue(snapshot.isIncomplete)
            XCTAssertEqual(snapshot.words[23...25], [1, 1, 0])
            XCTAssertNotEqual(snapshot.words[7] & QueryCostMemoryProbe.Reason.unmatched.rawValue, 0)
        }
        func testDisabledHasNoSnapshotAndNoAdmittedCalls() {
            let probe = QueryCostMemoryProbe.makeSyntheticForTesting()
            probe.beginOperation(1)
            XCTAssertNil(probe.beginInvocation(operation: 1, stage: .stageOne))
            probe.finishInvocation(nil, payload: QueryCostProbeTestFixture.payload())
            XCTAssertNil(probe.freeze())
            XCTAssertEqual(probe.status, .disabled)
        }
        func testRejectedArmIsTerminalIncludingIneligibleOrUnknownScope() {
            let cases: [(Bool, Bool, UInt64, QueryCostMemoryProbe.FacadeScope)] = [
                (false, true, 1, QueryCostProbeTestFixture.session),
                (true, false, 1, QueryCostProbeTestFixture.session),
                (true, true, 0, QueryCostProbeTestFixture.session),
                (
                    true, true, 1,
                    .init(kind: .nativeCorrectionSession, facadeOrdinal: 1, lifetimeOrdinal: 0, schema: .lunaPinyin)
                ),
                (
                    true, true, 1,
                    .init(kind: .nativeCorrectionSession, facadeOrdinal: 1, lifetimeOrdinal: 1, schema: .unknown)
                ),
            ]
            for item in cases {
                let probe = QueryCostMemoryProbe.makeSyntheticForTesting()
                let scope = QueryCostMemoryProbe.Scope(coordinatorOrdinal: item.2, facade: item.3, fullAccess: item.1)
                XCTAssertEqual(probe.arm(scope, eligible: item.0), .rejected)
                XCTAssertEqual(probe.arm(QueryCostProbeTestFixture.scope(), eligible: true), .alreadyAttempted)
                XCTAssertEqual(probe.status, .rejected)
                XCTAssertNil(probe.scope)
                XCTAssertNil(probe.freeze())
            }
        }
        func testCompleteRoundTripHasOneRecordPerInvocationAndExactBinding() throws {
            let snapshot = try QueryCostProbeTestFixture.completeOne()
            XCTAssertFalse(snapshot.isIncomplete)
            XCTAssertEqual(snapshot.words[4], 5)  // Two sequence records, two operation records, one query.
            XCTAssertEqual(snapshot.words[20...25], [1, 1, 0, 1, 1, 0])
            let offset = QueryCostMemoryProbe.headerWords + 2 * QueryCostMemoryProbe.recordWords
            XCTAssertEqual(
                Array(snapshot.words[offset..<(offset + 20)]),
                [5, 3, 100, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 7, 1, 0, 2, 2, 3, 0])
            let bytes = QueryCostProbeTestFixture.bytes(snapshot)
            XCTAssertEqual(bytes.count, 256 + 5 * 160)
            XCTAssertEqual(QueryCostMemoryProbe.decode(bytes), snapshot)
            XCTAssertEqual(Array(bytes.prefix(8)), [0x31, 0x45, 0x42, 0x4f, 0x52, 0x50, 0x43, 0x51])
        }
        func testEarlyResultsStagesAndCensoredDurationsRetainCallCount() throws {
            let payloads = [
                QueryCostProbeTestFixture.payload(
                    stage: .stageTwo, readiness: .unavailable,
                    result: .sidecarUnavailable, bucket: .notApplicable),
                QueryCostProbeTestFixture.payload(result: .contextUnavailable, bucket: .notApplicable),
                QueryCostProbeTestFixture.payload(readiness: .unknown, result: .emptyInput, bucket: .notApplicable),
                QueryCostProbeTestFixture.payload(readiness: .unknown, result: .zeroLimit, bucket: .notApplicable),
                QueryCostProbeTestFixture.payload(
                    readiness: .unknown, bucket: .oneToThree,
                    disposition: .discardedAfterFacade, elapsed: .max, duration: .saturated),
                QueryCostProbeTestFixture.payload(elapsed: 0, duration: .clockRegression),
            ]
            let probe = QueryCostProbeTestFixture.armed()
            probe.beginOperation(1)
            for payload in payloads {
                let reservation = probe.beginInvocation(operation: 1, stage: payload.stage)
                probe.finishInvocation(reservation, payload: payload)
            }
            probe.endOperation(1, terminal: .fenced)
            XCTAssertTrue(probe.endSequence(eligible: true))
            let snapshot = try XCTUnwrap(probe.freeze())
            XCTAssertFalse(snapshot.isIncomplete)
            XCTAssertEqual(snapshot.queryCount, 6)
            XCTAssertEqual(QueryCostMemoryProbe.decode(QueryCostProbeTestFixture.bytes(snapshot)), snapshot)
        }
        func testPreFacadeFenceHasTerminalAndNoSyntheticQuery() throws {
            let probe = QueryCostProbeTestFixture.armed()
            probe.beginOperation(1)
            probe.endOperation(1, terminal: .fenced)
            XCTAssertTrue(probe.endSequence(eligible: true))
            let snapshot = try XCTUnwrap(probe.freeze())
            XCTAssertEqual(snapshot.queryCount, 0)
            XCTAssertFalse(snapshot.isIncomplete)
            XCTAssertEqual(snapshot.words[4], 4)
        }
        func testPendingFreezeClosesAdmissionAndLaterFillCannotMutateBytes() throws {
            let probe = QueryCostProbeTestFixture.armed()
            probe.beginOperation(1)
            let reservation = probe.beginInvocation(operation: 1, stage: .stageOne)
            let snapshot = try XCTUnwrap(probe.freeze(callbacksQuiescent: false))
            let original = QueryCostProbeTestFixture.bytes(snapshot)
            XCTAssertTrue(snapshot.isIncomplete)
            XCTAssertEqual(snapshot.words[20...22], [1, 0, 1])
            XCTAssertNotEqual(snapshot.words[7] & QueryCostMemoryProbe.Reason.queryActive.rawValue, 0)
            probe.finishInvocation(reservation, payload: QueryCostProbeTestFixture.payload())
            probe.endOperation(1, terminal: .completed)
            XCTAssertNil(probe.beginInvocation(operation: 1, stage: .stageOne))
            XCTAssertEqual(probe.freeze(), snapshot)
            XCTAssertEqual(QueryCostMemoryProbe.decode(original), snapshot)
            XCTAssertEqual(probe.arm(QueryCostProbeTestFixture.scope(), eligible: true), .alreadyAttempted)
        }
        func testDuplicateUnknownAndForeignReservationsFailClosed() throws {
            let first = QueryCostProbeTestFixture.armed()
            let second = QueryCostProbeTestFixture.armed()
            first.beginOperation(1)
            second.beginOperation(1)
            let token = first.beginInvocation(operation: 1, stage: .stageOne)
            let own = second.beginInvocation(operation: 1, stage: .stageOne)
            second.finishInvocation(token, payload: QueryCostProbeTestFixture.payload())
            second.finishInvocation(own, payload: QueryCostProbeTestFixture.payload())
            second.finishInvocation(own, payload: QueryCostProbeTestFixture.payload())
            second.endOperation(1, terminal: .completed)
            second.beginOperation(1)  // An operation ordinal cannot be reused after completion.
            second.endOperation(99, terminal: .completed)
            XCTAssertTrue(second.endSequence(eligible: true))
            let snapshot = try XCTUnwrap(second.freeze())
            XCTAssertTrue(snapshot.isIncomplete)
            XCTAssertEqual(snapshot.queryCount, 1)
            XCTAssertNotEqual(snapshot.words[7] & QueryCostMemoryProbe.Reason.unmatched.rawValue, 0)
            XCTAssertEqual(QueryCostMemoryProbe.decode(QueryCostProbeTestFixture.bytes(snapshot)), snapshot)
        }
        func testSequenceRejectionCannotReattributeAnActiveOperation() throws {
            let probe = QueryCostProbeTestFixture.armed()
            probe.beginOperation(1)
            XCTAssertFalse(probe.endSequence(eligible: true))
            XCTAssertFalse(probe.beginSequence(ordinal: 2, fixture: 2, arm: 2, eligible: true))
            let token = probe.beginInvocation(operation: 1, stage: .stageTwo)
            probe.finishInvocation(token, payload: QueryCostProbeTestFixture.payload(stage: .stageTwo))
            probe.endOperation(1, terminal: .cancelled)
            XCTAssertTrue(probe.endSequence(eligible: true))
            let snapshot = try XCTUnwrap(probe.freeze())
            XCTAssertTrue(snapshot.isIncomplete)
            let queryOffset = 32 + 2 * 20
            XCTAssertEqual(Array(snapshot.words[(queryOffset + 3)...(queryOffset + 5)]), [1, 1, 1])
        }
        func testScopeChangeAndLifecycleEmitFiniteInvalidationOnlyOncePerReason() throws {
            let probe = QueryCostProbeTestFixture.armed()
            probe.verifyScope(facade: nil, fullAccess: true)
            probe.verifyScope(facade: nil, fullAccess: true)
            probe.invalidate(.lifecycle)
            XCTAssertTrue(probe.endSequence(eligible: true))
            let snapshot = try XCTUnwrap(probe.freeze())
            XCTAssertTrue(snapshot.isIncomplete)
            XCTAssertEqual(snapshot.words[4], 4)
            XCTAssertEqual(QueryCostMemoryProbe.decode(QueryCostProbeTestFixture.bytes(snapshot)), snapshot)
        }
        func testExpiryAndClockRegressionAreSticky() throws {
            let tick = Mutex<UInt64>(100)
            let probe = QueryCostProbeTestFixture.armed(now: { tick.withLock { $0 } })
            tick.withLock { $0 = 99 }
            probe.beginOperation(1)
            tick.withLock { $0 = 100 + QueryCostMemoryProbe.lifetimeNanoseconds }
            probe.endOperation(1, terminal: .completed)
            _ = probe.endSequence(eligible: true)
            let snapshot = try XCTUnwrap(probe.freeze())
            XCTAssertTrue(snapshot.isIncomplete)
            XCTAssertEqual(snapshot.words[30], 1)
            XCTAssertNotEqual(snapshot.words[7] & QueryCostMemoryProbe.Reason.expiry.rawValue, 0)
            XCTAssertEqual(QueryCostMemoryProbe.decode(QueryCostProbeTestFixture.bytes(snapshot)), snapshot)
        }
        func testCapacityNeverExpandsOrSilentlyClaimsComplete() throws {
            let probe = QueryCostProbeTestFixture.armed()
            probe.beginOperation(1)
            for _ in 0..<QueryCostMemoryProbe.capacity {
                let token = probe.beginInvocation(operation: 1, stage: .stageOne)
                probe.finishInvocation(token, payload: QueryCostProbeTestFixture.payload())
            }
            probe.endOperation(1, terminal: .completed)
            _ = probe.endSequence(eligible: true)
            let snapshot = try XCTUnwrap(probe.freeze())
            XCTAssertTrue(snapshot.isIncomplete)
            XCTAssertEqual(snapshot.words[4], 4096)
            XCTAssertEqual(QueryCostProbeTestFixture.bytes(snapshot).count, QueryCostMemoryProbe.maximumBytes)
            XCTAssertGreaterThan(snapshot.words[26], 0)
            XCTAssertNotEqual(snapshot.words[7] & QueryCostMemoryProbe.Reason.capacity.rawValue, 0)
            // Missing terminals and sequence ends remain explicitly incomplete lower-bound evidence.
            XCTAssertEqual(QueryCostMemoryProbe.decode(QueryCostProbeTestFixture.bytes(snapshot)), snapshot)
        }
        func testDecoderRejectsMalformedLengthReservedEnumsIdentityAndCounters() throws {
            let snapshot = try QueryCostProbeTestFixture.completeOne()
            let bytes = QueryCostProbeTestFixture.bytes(snapshot)
            XCTAssertNil(QueryCostMemoryProbe.decode(Array(bytes.dropLast())))
            XCTAssertNil(QueryCostMemoryProbe.decode(bytes + [0]))
            let query = 32 + 2 * 20
            let mutations: [(Int, UInt64)] = [
                (0, 0), (1, 1), (4, .max), (7, 4096), (12, 0), (13, 0),
                (14, 0), (15, 1), (21, 2), (22, 1), (31, 0), (query, 7), (query + 1, 99),
                (query + 3, 2), (query + 7, .max), (query + 8, 0), (query + 9, 2),
                (query + 10, 2), (query + 11, 0), (query + 12, 0),
                (query + 13, UInt64(UInt32.max) + 1), (query + 14, 2), (query + 16, 0), (query + 19, 1),
            ]
            for (offset, value) in mutations {
                var changed = snapshot.words
                changed[offset] = value
                XCTAssertNil(
                    QueryCostMemoryProbe.decode(QueryCostProbeTestFixture.bytes(words: changed)), "word \(offset)")
            }
        }
    }
#endif
