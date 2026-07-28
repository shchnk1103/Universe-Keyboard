#if T9_AUTO_ANCHOR_DEVICE_PREFLIGHT
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
            retainedEvidence: ""
        ))
        let prepared = try XCTUnwrap(
            T9DevicePreflightRun.makePreparedEnvelope(
                token: replacement,
                existingSerializedEnvelope: residue.serialized,
                retainedEvidence: ""
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

    func testPreparationRejectsEvidenceAndMatrixTokenReuse() {
        let token = "S6A-0123456789ABCDEF0123456789ABCDEF"

        XCTAssertNil(T9DevicePreflightRun.makePreparedEnvelope(
            token: token,
            existingSerializedEnvelope: nil,
            retainedEvidence: "T9SEG run=\(token) action=1"
        ))
        XCTAssertNil(T9DevicePreflightRun.makePreparedEnvelope(
            token: token,
            existingSerializedEnvelope: nil,
            retainedEvidence: "",
            currentMatrixTokens: [token]
        ))
        XCTAssertNil(T9DevicePreflightRun.consumePreparedEnvelope(
            serialized: "v2|prepared|\(token)"
        ))
    }
}
#endif
