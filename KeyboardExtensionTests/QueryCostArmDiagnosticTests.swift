#if DEBUG && KEYBOARD_QUERY_COST_PROBE
    import Foundation
    import KeyboardCore
    import XCTest

    nonisolated final class QueryCostArmDiagnosticTests: XCTestCase {
        @MainActor func testProviderDiagnosticV2RetainsKindEpochAndFacadeIn128Bytes() throws {
            let eligibility = QueryCostArmDiagnostic.Eligibility.sample(
                elapsedIdle: true, touchIdle: { true }, callbacksIdle: { true })
            let facade = QueryCostMemoryProbe.FacadeScope(
                kind: .threadAffineProvider,
                facadeOrdinal: 8, lifetimeOrdinal: 7, schema: .lunaPinyin)
            let scope = QueryCostMemoryProbe.Scope(coordinatorOrdinal: 1, facade: facade, fullAccess: true)
            let snapshot = QueryCostArmDiagnostic(result: .armed, eligibility: eligibility, scope: scope)
            XCTAssertEqual(snapshot.encoded.count, 128)
            XCTAssertEqual(snapshot.words[1], 2)
            XCTAssertEqual(snapshot.words[10], 7)
            XCTAssertEqual(snapshot.words[14], 2)
            XCTAssertEqual(snapshot.words[15], 8)
            XCTAssertEqual(try XCTUnwrap(QueryCostArmDiagnostic.decode(snapshot.encoded)).words, snapshot.words)
            for (index, value) in [(1, UInt64(1)), (10, 0), (14, 0), (14, 3), (15, 0)] {
                var words = snapshot.words
                words[index] = value
                let bytes = words.map { $0.littleEndian }.withUnsafeBytes { Data($0) }
                XCTAssertNil(QueryCostArmDiagnostic.decode(bytes))
            }
        }
        @MainActor func testUnsupportedRouteDiagnosticRemainsReadableButCannotClaimArmed() {
            let eligibility = QueryCostArmDiagnostic.Eligibility.sample(
                elapsedIdle: true, touchIdle: { true }, callbacksIdle: { true })
            let scope = QueryCostMemoryProbe.Scope(
                coordinatorOrdinal: 1,
                facade: .unavailable(kind: .unsupportedResponsive, facadeOrdinal: 8), fullAccess: true)
            let rejected = QueryCostArmDiagnostic(result: .rejected, eligibility: eligibility, scope: scope)
            XCTAssertEqual(rejected.words[14], 3)
            XCTAssertNotNil(QueryCostArmDiagnostic.decode(rejected.encoded))
            let falseArmed = QueryCostArmDiagnostic(result: .armed, eligibility: eligibility, scope: scope)
            XCTAssertNil(QueryCostArmDiagnostic.decode(falseArmed.encoded))
        }
        @MainActor func testElapsedFailureSkipsAllLaterChecks() {
            let value = QueryCostArmDiagnostic.Eligibility.sample(
                elapsedIdle: false,
                touchIdle: {
                    XCTFail("touch must be skipped"); return true
                },
                callbacksIdle: {
                    XCTFail("callbacks must be skipped"); return true
                })
            XCTAssertFalse(value.isEligible)
            XCTAssertEqual(value.elapsed, .failed)
            XCTAssertEqual(value.touch, .skipped)
            XCTAssertEqual(value.callbacks, .skipped)
        }
        @MainActor func testTouchFailureSkipsCallbacksAndReadsTouchOnce() {
            var reads = 0
            let value = QueryCostArmDiagnostic.Eligibility.sample(
                elapsedIdle: true,
                touchIdle: {
                    reads += 1; return false
                },
                callbacksIdle: {
                    XCTFail("callbacks must be skipped"); return true
                })
            XCTAssertEqual(reads, 1)
            XCTAssertFalse(value.isEligible)
            XCTAssertEqual(value.touch, .failed)
            XCTAssertEqual(value.callbacks, .skipped)
        }
        @MainActor func testCallbackResultReadsEachCheckOnceInOriginalOrder() {
            for callbackResult in [false, true] {
                var order: [String] = []
                let value = QueryCostArmDiagnostic.Eligibility.sample(
                    elapsedIdle: true,
                    touchIdle: {
                        order.append("touch"); return true
                    },
                    callbacksIdle: {
                        order.append("callbacks"); return callbackResult
                    })
                XCTAssertEqual(order, ["touch", "callbacks"])
                XCTAssertEqual(value.isEligible, callbackResult)
                XCTAssertEqual(value.callbacks, callbackResult ? .passed : .failed)
            }
        }
        @MainActor func testEveryArmResultPreservesExactScopeAnd128ByteWire() {
            let scope = QueryCostMemoryProbe.Scope(
                runID: UUID(uuidString: "01020304-0506-0708-090A-0B0C0D0E0F10")!,
                coordinatorOrdinal: 41,
                facade: QueryCostMemoryProbe.FacadeScope(
                    kind: .nativeCorrectionSession, facadeOrdinal: 1, lifetimeOrdinal: 42, schema: .lunaPinyin),
                fullAccess: true)
            let eligibility = QueryCostArmDiagnostic.Eligibility.sample(
                elapsedIdle: true, touchIdle: { true }, callbacksIdle: { true })
            let results: [QueryCostMemoryProbe.ArmResult] = [.armed, .rejected, .alreadyAttempted]
            for (index, result) in results.enumerated() {
                let snapshot = QueryCostArmDiagnostic(result: result, eligibility: eligibility, scope: scope)
                XCTAssertEqual(snapshot.encoded.count, 128)
                XCTAssertEqual(snapshot.words.count, 16)
                XCTAssertEqual(snapshot.words[3], UInt64(index + 1))
                XCTAssertEqual(Array(snapshot.words[7...11]), [2, 2, 41, 42, 1])
                XCTAssertEqual(snapshot.words[12], 0x0807_0605_0403_0201)
                XCTAssertEqual(snapshot.words[13], 0x100F_0E0D_0C0B_0A09)
                XCTAssertEqual(QueryCostArmDiagnostic.decode(snapshot.encoded)?.words, snapshot.words)
            }
        }
        @MainActor func testRejectedUnknownScopeStillHasDiagnosticWithoutArmingProductionProbe() {
            let eligibility = QueryCostArmDiagnostic.Eligibility.sample(
                elapsedIdle: false,
                touchIdle: {
                    XCTFail(); return true
                },
                callbacksIdle: {
                    XCTFail(); return true
                })
            let scope = QueryCostMemoryProbe.Scope(
                coordinatorOrdinal: 0,
                facade: QueryCostMemoryProbe.FacadeScope(
                    kind: .nativeCorrectionSession, facadeOrdinal: 1, lifetimeOrdinal: 0, schema: .unknown),
                fullAccess: false)
            let snapshot = QueryCostArmDiagnostic(result: .rejected, eligibility: eligibility, scope: scope)
            XCTAssertEqual(Array(snapshot.words[3...11]), [2, 1, 0, 0, 1, 1, 0, 0, 0])
            XCTAssertNotNil(QueryCostArmDiagnostic.decode(snapshot.encoded))
        }
        @MainActor func testDecoderRejectsWrongLengthProtocolCodesAndShortCircuitContradictions() {
            let eligibility = QueryCostArmDiagnostic.Eligibility.sample(
                elapsedIdle: true, touchIdle: { true }, callbacksIdle: { true })
            let scope = QueryCostMemoryProbe.Scope(
                coordinatorOrdinal: 1,
                facade: QueryCostMemoryProbe.FacadeScope(
                    kind: .nativeCorrectionSession, facadeOrdinal: 1, lifetimeOrdinal: 1, schema: .lunaPinyin),
                fullAccess: true)
            let snapshot = QueryCostArmDiagnostic(result: .armed, eligibility: eligibility, scope: scope)
            for (index, value) in [
                (0, UInt64(0)), (1, 1), (2, 15), (3, 0), (3, 4), (4, 0), (5, 3), (6, 0),
                (7, 1), (8, 0), (11, 2), (14, 4), (15, 0),
            ] {
                var words = snapshot.words
                words[index] = value
                let bytes = words.map { $0.littleEndian }.withUnsafeBytes { Data($0) }
                XCTAssertNil(QueryCostArmDiagnostic.decode(bytes), "invalid word \(index)")
            }
            XCTAssertNil(QueryCostArmDiagnostic.decode(Data(snapshot.encoded.dropLast())))
            XCTAssertNil(QueryCostArmDiagnostic.decode(snapshot.encoded + Data([0])))
        }
    }
#endif
