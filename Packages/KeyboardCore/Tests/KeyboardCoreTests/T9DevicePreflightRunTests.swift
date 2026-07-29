#if T9_AUTO_ANCHOR_DEVICE_PREFLIGHT
import Foundation
import XCTest
@testable import KeyboardCore

final class T9DevicePreflightRunTests: XCTestCase {
    func testCanonicalTokenAndEnvelopeRoundTrip() {
        let token = T9DevicePreflightRun.makeToken()

        XCTAssertTrue(T9DevicePreflightRun.isCanonicalToken(token))
        XCTAssertEqual(token.count, 36)

        for state in [
            T9DevicePreflightRun.State.prepared,
            .consumed,
        ] {
            let envelope = T9DevicePreflightRun.Envelope(
                state: state,
                token: token
            )
            XCTAssertEqual(
                T9DevicePreflightRun.Envelope(
                    serialized: envelope.serialized
                ),
                envelope
            )
        }
    }

    func testEnvelopeFailsClosedForMalformedTokenVersionAndState() {
        let token = "S6A-0123456789ABCDEF0123456789ABCDEF"

        XCTAssertFalse(T9DevicePreflightRun.isCanonicalToken(""))
        XCTAssertFalse(T9DevicePreflightRun.isCanonicalToken(token.lowercased()))
        XCTAssertFalse(T9DevicePreflightRun.isCanonicalToken(token + "0"))
        XCTAssertFalse(
            T9DevicePreflightRun.isCanonicalToken(
                "S6A-１２３４５６７８９０ABCDEF0123456789ABCDEF"
            )
        )
        XCTAssertNil(T9DevicePreflightRun.Envelope(serialized: "v2|prepared|\(token)"))
        XCTAssertNil(T9DevicePreflightRun.Envelope(serialized: "v1|unknown|\(token)"))
        XCTAssertNil(T9DevicePreflightRun.Envelope(serialized: "v1|consumed|bad"))
        XCTAssertNil(T9DevicePreflightRun.Envelope(serialized: "v1|prepared|\(token)|extra"))
    }

    func testEnvelopeLifecycleAndCrashResidueReplacement() throws {
        let token = "S6A-0123456789ABCDEF0123456789ABCDEF"
        let replacement = "S6A-FEDCBA9876543210FEDCBA9876543210"
        let residue = T9DevicePreflightRun.Envelope(
            state: .consumed,
            token: token
        )

        XCTAssertNil(T9DevicePreflightRun.makePreparedEnvelope(
            token: token,
            existingSerializedEnvelope: residue.serialized,
            retainedEvidence: "",
            currentMatrixTokens: []
        ))
        let prepared = try XCTUnwrap(
            T9DevicePreflightRun.makePreparedEnvelope(
                token: replacement,
                existingSerializedEnvelope: residue.serialized,
                retainedEvidence: "",
                currentMatrixTokens: []
            )
        )
        XCTAssertEqual(prepared.state, .prepared)
        XCTAssertEqual(prepared.token, replacement)

        let consumption = try XCTUnwrap(
            T9DevicePreflightRun.consumePreparedEnvelope(
                serialized: prepared.serialized
            )
        )
        XCTAssertEqual(consumption.token, replacement)
        XCTAssertEqual(consumption.consumedEnvelope.state, .consumed)
        XCTAssertNil(T9DevicePreflightRun.consumePreparedEnvelope(
            serialized: consumption.consumedEnvelope.serialized
        ))
        XCTAssertTrue(T9DevicePreflightRun.canRemoveConsumedEnvelope(
            serialized: consumption.consumedEnvelope.serialized,
            token: replacement
        ))
        XCTAssertFalse(T9DevicePreflightRun.canRemoveConsumedEnvelope(
            serialized: consumption.consumedEnvelope.serialized,
            token: token
        ))
        XCTAssertFalse(T9DevicePreflightRun.canRemoveConsumedEnvelope(
            serialized: prepared.serialized,
            token: replacement
        ))
    }

    func testReusedExtensionConsumesOnlyFreshPreparedToken() throws {
        let currentToken = "S6A-0123456789ABCDEF0123456789ABCDEF"
        let nextToken = "S6A-FEDCBA9876543210FEDCBA9876543210"
        let prepared = T9DevicePreflightRun.Envelope(
            state: .prepared,
            token: nextToken
        )

        XCTAssertEqual(
            T9DevicePreflightRun.consumeFreshPreparedEnvelope(
                serialized: prepared.serialized,
                currentToken: currentToken
            )?.token,
            nextToken
        )
        XCTAssertNil(
            T9DevicePreflightRun.consumeFreshPreparedEnvelope(
                serialized: prepared.serialized,
                currentToken: nextToken
            )
        )
        XCTAssertNil(
            T9DevicePreflightRun.consumeFreshPreparedEnvelope(
                serialized: T9DevicePreflightRun.Envelope(
                    state: .consumed,
                    token: nextToken
                ).serialized,
                currentToken: currentToken
            )
        )
    }

    func testPreparationRejectsEvidenceAndMatrixTokenReuse() {
        let token = "S6A-0123456789ABCDEF0123456789ABCDEF"

        XCTAssertNil(T9DevicePreflightRun.makePreparedEnvelope(
            token: token,
            existingSerializedEnvelope: nil,
            retainedEvidence: "T9SEG run=\(token) action=1",
            currentMatrixTokens: []
        ))
        XCTAssertNil(T9DevicePreflightRun.makePreparedEnvelope(
            token: token,
            existingSerializedEnvelope: nil,
            retainedEvidence: "",
            currentMatrixTokens: [token]
        ))
        XCTAssertNil(T9DevicePreflightRun.makePreparedEnvelope(
            token: token,
            existingSerializedEnvelope: "v2|prepared|\(token)",
            retainedEvidence: "",
            currentMatrixTokens: []
        ))
        XCTAssertNil(T9DevicePreflightRun.makePreparedEnvelope(
            token: token,
            existingSerializedEnvelope: "v1|unknown|\(token)",
            retainedEvidence: "",
            currentMatrixTokens: []
        ))
        XCTAssertNil(T9DevicePreflightRun.consumePreparedEnvelope(
            serialized: "v2|prepared|\(token)"
        ))
    }

    func testMatrixRegistryIsBoundedVersionedAndRejectsReuse() throws {
        let first = "S6A-0123456789ABCDEF0123456789ABCDEF"
        let second = "S6A-FEDCBA9876543210FEDCBA9876543210"
        let registry = try XCTUnwrap(
            T9DevicePreflightRun.MatrixRegistry().appending(first)
        )
        let updated = try XCTUnwrap(registry.appending(second))

        XCTAssertEqual(
            T9DevicePreflightRun.MatrixRegistry(
                serialized: updated.serialized
            ),
            updated
        )
        XCTAssertNil(updated.appending(first))
        XCTAssertNil(T9DevicePreflightRun.MatrixRegistry(
            serialized: "v2|\(first)"
        ))
        XCTAssertNil(T9DevicePreflightRun.MatrixRegistry(
            serialized: "v1|\(first),\(first)"
        ))
        XCTAssertNil(T9DevicePreflightRun.MatrixRegistry(
            serialized: "v1|bad"
        ))
        XCTAssertNil(T9DevicePreflightRun.MatrixRegistry(serialized: "v1|,"))
        XCTAssertNil(T9DevicePreflightRun.MatrixRegistry(
            serialized: "v1|,\(first)"
        ))
        XCTAssertNil(T9DevicePreflightRun.MatrixRegistry(
            serialized: "v1|\(first),"
        ))
        XCTAssertNil(T9DevicePreflightRun.MatrixRegistry(
            serialized: "v1|\(first),,\(second)"
        ))

        var fullRegistry = T9DevicePreflightRun.MatrixRegistry()
        for index in 0..<64 {
            let token = String(
                format: "S6A-%032llX",
                UInt64(index)
            )
            fullRegistry = try XCTUnwrap(fullRegistry.appending(token))
        }
        XCTAssertNil(fullRegistry.appending(
            "S6A-FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF"
        ))
    }

    func testStorageInspectionAndFinalizationFailClosed() {
        let token = "S6A-0123456789ABCDEF0123456789ABCDEF"
        let envelope = T9DevicePreflightRun.Envelope(
            state: .consumed,
            token: token
        )
        let registry = T9DevicePreflightRun.MatrixRegistry()

        XCTAssertEqual(
            T9DevicePreflightRun.inspectEnvelopeStorage(
                objectExists: false,
                serialized: nil
            ),
            .absent
        )
        XCTAssertEqual(
            T9DevicePreflightRun.inspectEnvelopeStorage(
                objectExists: true,
                serialized: nil
            ),
            .invalid
        )
        XCTAssertEqual(
            T9DevicePreflightRun.inspectEnvelopeStorage(
                objectExists: true,
                serialized: "malformed"
            ),
            .invalid
        )
        XCTAssertEqual(
            T9DevicePreflightRun.inspectEnvelopeStorage(
                objectExists: true,
                serialized: envelope.serialized
            ),
            .valid(envelope)
        )

        let absentEnvelope = T9DevicePreflightRun.EnvelopeStorageState.absent
        XCTAssertEqual(
            T9DevicePreflightRun.inspectMatrixRegistryStorage(
                objectExists: true,
                serialized: nil
            ),
            .invalid
        )
        XCTAssertEqual(
            T9DevicePreflightRun.inspectMatrixRegistryStorage(
                objectExists: true,
                serialized: "v1|,"
            ),
            .invalid
        )
        XCTAssertFalse(T9DevicePreflightRun.canFinalizeMatrix(
            envelopeStorage: .invalid,
            registryStorage: .valid(registry)
        ))
        XCTAssertFalse(T9DevicePreflightRun.canFinalizeMatrix(
            envelopeStorage: absentEnvelope,
            registryStorage: .invalid
        ))
        XCTAssertTrue(T9DevicePreflightRun.canFinalizeMatrix(
            envelopeStorage: absentEnvelope,
            registryStorage: .valid(registry)
        ))
        XCTAssertTrue(T9DevicePreflightRun.canFinalizeMatrix(
            envelopeStorage: absentEnvelope,
            registryStorage: .absent
        ))
        XCTAssertFalse(T9DevicePreflightRun.canRemoveConsumedEnvelope(
            serialized: nil,
            token: token
        ))
        XCTAssertFalse(T9DevicePreflightRun.canRemoveConsumedEnvelope(
            serialized: "malformed",
            token: token
        ))
    }
}
#endif
