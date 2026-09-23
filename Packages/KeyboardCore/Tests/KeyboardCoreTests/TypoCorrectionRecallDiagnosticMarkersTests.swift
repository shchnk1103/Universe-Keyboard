import XCTest

@testable import KeyboardCore

final class TypoCorrectionRecallDiagnosticMarkersTests: XCTestCase {
    func testCompositionFingerprintIsStableAndContentFree() {
        let a = TypoCorrectionRecallDiagnosticMarkers.compositionFingerprint("nihaoshijie")
        let b = TypoCorrectionRecallDiagnosticMarkers.compositionFingerprint("nihaoshijie")
        let c = TypoCorrectionRecallDiagnosticMarkers.compositionFingerprint("nihaoshijiE")
        XCTAssertEqual(a, b)
        XCTAssertNotEqual(a, c)
        XCTAssertGreaterThanOrEqual(a, 0)
    }

    func testFenceFieldsUseOnlyAllowlistedCountMetrics() throws {
        let fields = TypoCorrectionRecallDiagnosticMarkers.fenceFields(
            recallEpoch: 7,
            compositionRevision: 8,
            operationOrdinal: 9,
            normalizedComposition: "abcdefghi"
        )
        XCTAssertEqual(fields.count, 5)

        let event = DiagnosticEvent(
            utcTimestamp: .now,
            monotonicNanoseconds: 1,
            origin: .keyboardExtension,
            processInstanceID: UUID(),
            localSequence: 1,
            code: .typoRecallEpochBumped,
            level: .info,
            category: .performance,
            fields: fields
        )
        let object = try JSONSerialization.jsonObject(with: JSONEncoder().encode(event))
            as? [String: Any]
        let encodedFields = try XCTUnwrap(object?["fields"] as? [[String: Any]])
        let names = Set(encodedFields.compactMap { $0["name"] as? String })
        XCTAssertEqual(
            names,
            [
                "recall_epoch",
                "composition_revision",
                "operation_ordinal",
                "composition_length",
                "composition_fingerprint",
            ]
        )
        XCTAssertEqual(
            encodedFields.first { $0["name"] as? String == "composition_length" }?[
                "integerValue"
            ] as? Int,
            9
        )
        let text = try XCTUnwrap(String(data: JSONEncoder().encode(event), encoding: .utf8))
        XCTAssertFalse(text.contains("abcdefghi"))
    }

    func testSchemaVersionIsFourAfterTypoRecallVocabulary() {
        XCTAssertEqual(DiagnosticEvent.schemaVersion, 4)
        XCTAssertTrue(
            DiagnosticEvent.Code.allCases.map(\.rawValue).contains("typo_recall.fence_discarded")
        )
    }
}
