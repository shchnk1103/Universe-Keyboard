import XCTest

@testable import KeyboardCore

final class DiagnosticEventTests: XCTestCase {
    func testRoundTripPreservesOnlyTypedContentFreeFields() throws {
        let appearanceID = UUID()
        let event = DiagnosticEvent(
            utcTimestamp: Date(timeIntervalSince1970: 1_723_123_456),
            monotonicNanoseconds: 123_456,
            origin: .keyboardExtension,
            processInstanceID: UUID(),
            localSequence: 42,
            appearanceID: appearanceID,
            actionSequence: 7,
            code: .candidateVisibilityChanged,
            level: .info,
            category: .display,
            fields: [
                .count(.candidateCount, 3),
                .count(.visibleCandidateCellCount, 2),
                .count(.candidateTouchBand, DiagnosticEvent.CandidateTouchBand.upper.rawValue),
                .flag(.isCandidateBarVisible, true),
                .flag(.didHitCandidateCell, true),
                .reason(.generationChanged),
            ]
        )

        let encoded = try JSONEncoder().encode(event)
        let decoded = try JSONDecoder().decode(DiagnosticEvent.self, from: encoded)

        XCTAssertEqual(decoded, event)
        XCTAssertEqual(decoded.appearanceID, appearanceID)
    }

    func testFieldEncodingDoesNotProvideFreeTextPayload() throws {
        let event = DiagnosticEvent(
            utcTimestamp: .now,
            monotonicNanoseconds: 1,
            origin: .mainApp,
            processInstanceID: UUID(),
            localSequence: 1,
            code: .journalDropped,
            level: .warning,
            category: .performance,
            fields: [.reason(.queueFull), .count(.droppedEventCount, 1)]
        )

        let object = try JSONSerialization.jsonObject(with: JSONEncoder().encode(event)) as? [String: Any]
        let fields = try XCTUnwrap(object?["fields"] as? [[String: Any]])

        let encodedKeys = Set(fields.flatMap { $0.keys })
        XCTAssertEqual(encodedKeys, ["type", "name", "integerValue", "reason"])
        XCTAssertFalse(encodedKeys.contains("message"))
        XCTAssertFalse(encodedKeys.contains("text"))
    }

    func testCandidateTouchBandUsesOnlyCoarseVerticalBuckets() {
        XCTAssertEqual(DiagnosticEvent.CandidateTouchBand.classify(y: 0, height: 30), .upper)
        XCTAssertEqual(DiagnosticEvent.CandidateTouchBand.classify(y: 9, height: 30), .upper)
        XCTAssertEqual(DiagnosticEvent.CandidateTouchBand.classify(y: 10, height: 30), .middle)
        XCTAssertEqual(DiagnosticEvent.CandidateTouchBand.classify(y: 19, height: 30), .middle)
        XCTAssertEqual(DiagnosticEvent.CandidateTouchBand.classify(y: 20, height: 30), .lower)
        XCTAssertEqual(DiagnosticEvent.CandidateTouchBand.classify(y: 30, height: 30), .lower)
    }

    func testSchemeDeliveryPayloadRoundTripKeepsFiniteIntegrityFields() throws {
        let context = DiagnosticEvent.SchemeDeliveryContext(
            operationID: UUID(),
            artifact: .wanxiang1759CNB9BFCGitHub73F8,
            stagedIdentity: .wanxiang1759Plan1Post1
        )
        let payload = DiagnosticEvent.SchemeDeliveryPayload.integrityFailed(
            .init(
                context: context,
                attempt: try XCTUnwrap(.init(1)),
                source: .cnb,
                host: .cnbAsset,
                observation: .archiveDigest(
                    expected: try XCTUnwrap(.init(rawValue: "0123456789abcdef")),
                    actual: try XCTUnwrap(.init(rawValue: "fedcba9876543210"))
                )
            )
        )
        let event = DiagnosticEvent(
            utcTimestamp: .now,
            monotonicNanoseconds: 1,
            origin: .mainApp,
            processInstanceID: UUID(),
            localSequence: 1,
            code: .schemeDeliveryIntegrityFailed,
            level: .warning,
            category: .deployment,
            schemeDeliveryPayload: payload
        )

        XCTAssertEqual(
            try JSONDecoder().decode(DiagnosticEvent.self, from: JSONEncoder().encode(event)),
            event
        )
    }

    func testSourceSelectionPhaseCanPrecedeArchiveAttempt() throws {
        let context = DiagnosticEvent.SchemeDeliveryContext(
            operationID: UUID(),
            artifact: .rimeIceNightlyF60AA4F3,
            stagedIdentity: .rimeIceNightlyPlan1Post1
        )
        let event = DiagnosticEvent(
            utcTimestamp: .now,
            monotonicNanoseconds: 1,
            origin: .mainApp,
            processInstanceID: UUID(),
            localSequence: 1,
            code: .schemeDeliveryPhaseChanged,
            level: .info,
            category: .deployment,
            schemeDeliveryPayload: .phaseChanged(
                .init(
                    context: context,
                    attempt: nil,
                    source: .nju,
                    host: nil,
                    phase: .selecting,
                    result: .succeeded
                )
            )
        )

        XCTAssertEqual(
            try JSONDecoder().decode(DiagnosticEvent.self, from: JSONEncoder().encode(event)),
            event
        )
    }

    func testSchemeDeliveryDecoderRejectsNonAdvancingFallbackAttempt() throws {
        let context = DiagnosticEvent.SchemeDeliveryContext(
            operationID: UUID(),
            artifact: .wanxiang1759CNB9BFCGitHub73F8,
            stagedIdentity: .wanxiang1759Plan1Post1
        )
        let event = DiagnosticEvent(
            utcTimestamp: .now,
            monotonicNanoseconds: 1,
            origin: .mainApp,
            processInstanceID: UUID(),
            localSequence: 1,
            code: .schemeDeliveryFallback,
            level: .warning,
            category: .deployment,
            schemeDeliveryPayload: .fallback(
                .init(
                    context: context,
                    fromAttempt: try XCTUnwrap(.init(1)),
                    toAttempt: try XCTUnwrap(.init(2)),
                    from: .cnb,
                    to: .github,
                    fromHost: .cnbAsset,
                    toHost: nil,
                    reason: .archiveDigest
                )
            )
        )
        var object = try XCTUnwrap(
            JSONSerialization.jsonObject(with: JSONEncoder().encode(event)) as? [String: Any]
        )
        var payload = try XCTUnwrap(object["schemeDeliveryPayload"] as? [String: Any])
        var fallback = try XCTUnwrap(payload["fallback"] as? [String: Any])
        var fallbackValue = try XCTUnwrap(fallback["_0"] as? [String: Any])
        fallbackValue["toAttempt"] = 1
        fallback["_0"] = fallbackValue
        payload["fallback"] = fallback
        object["schemeDeliveryPayload"] = payload

        XCTAssertThrowsError(
            try JSONDecoder().decode(
                DiagnosticEvent.self,
                from: JSONSerialization.data(withJSONObject: object)
            )
        )
    }

    func testSchemeDeliveryDecoderRejectsCodePayloadMismatchAndInvalidDigestPrefix() throws {
        let context = DiagnosticEvent.SchemeDeliveryContext(
            operationID: UUID(),
            artifact: .rimeIceNightlyF60AA4F3,
            stagedIdentity: .rimeIceNightlyPlan1Post1
        )
        let event = DiagnosticEvent(
            utcTimestamp: .now,
            monotonicNanoseconds: 1,
            origin: .mainApp,
            processInstanceID: UUID(),
            localSequence: 1,
            code: .schemeDeliveryTerminal,
            level: .info,
            category: .deployment,
            schemeDeliveryPayload: .terminal(.init(context: context, result: .completed))
        )
        var object = try XCTUnwrap(
            JSONSerialization.jsonObject(with: JSONEncoder().encode(event)) as? [String: Any]
        )
        object["code"] = DiagnosticEvent.Code.schemeDeliveryFallback.rawValue
        XCTAssertThrowsError(
            try JSONDecoder().decode(
                DiagnosticEvent.self,
                from: JSONSerialization.data(withJSONObject: object)
            )
        )
        XCTAssertNil(DiagnosticEvent.DigestPrefix16(rawValue: "ABCDEF0123456789"))
        XCTAssertNil(DiagnosticEvent.DigestPrefix16(rawValue: "short"))
        XCTAssertNil(DiagnosticEvent.DigestPrefix16(fullDigest: "0123456789abcdef"))
        XCTAssertNil(DiagnosticEvent.DigestPrefix16(fullDigest: String(repeating: "g", count: 64)))
        XCTAssertNil(DiagnosticEvent.SchemeDeliveryAttempt(0))
        XCTAssertNil(DiagnosticEvent.SchemeDeliveryAttempt(9))
    }

    func testSchemeDeliveryDecoderRejectsGenericFieldsAndInvalidTerminalCombination() throws {
        let context = DiagnosticEvent.SchemeDeliveryContext(
            operationID: UUID(),
            artifact: .wanxiang1759CNB9BFCGitHub73F8,
            stagedIdentity: .wanxiang1759Plan1Post1
        )
        let event = DiagnosticEvent(
            utcTimestamp: .now,
            monotonicNanoseconds: 1,
            origin: .mainApp,
            processInstanceID: UUID(),
            localSequence: 1,
            code: .schemeDeliveryTerminal,
            level: .warning,
            category: .deployment,
            schemeDeliveryPayload: .terminal(
                .init(
                    context: context,
                    result: .failed,
                    installed: false,
                    deployed: false,
                    failure: .archiveDigest
                )
            )
        )
        var object = try XCTUnwrap(
            JSONSerialization.jsonObject(with: JSONEncoder().encode(event)) as? [String: Any]
        )
        object["fields"] = [
            [
                "type": "reason",
                "reason": "io_failure",
            ]
        ]
        XCTAssertThrowsError(
            try JSONDecoder().decode(
                DiagnosticEvent.self,
                from: JSONSerialization.data(withJSONObject: object)
            )
        )

        object["fields"] = []
        var payload = try XCTUnwrap(object["schemeDeliveryPayload"] as? [String: Any])
        var terminal = try XCTUnwrap(payload["terminal"] as? [String: Any])
        var terminalValue = try XCTUnwrap(terminal["_0"] as? [String: Any])
        terminalValue.removeValue(forKey: "failure")
        terminal["_0"] = terminalValue
        payload["terminal"] = terminal
        object["schemeDeliveryPayload"] = payload
        XCTAssertThrowsError(
            try JSONDecoder().decode(
                DiagnosticEvent.self,
                from: JSONSerialization.data(withJSONObject: object)
            )
        )
    }

    func testSchemeDeliveryDecoderRejectsInvalidPhaseFieldCombination() throws {
        let context = DiagnosticEvent.SchemeDeliveryContext(
            operationID: UUID(),
            artifact: .wanxiang1759CNB9BFCGitHub73F8,
            stagedIdentity: .wanxiang1759Plan1Post1
        )
        let valid = DiagnosticEvent(
            utcTimestamp: .now,
            monotonicNanoseconds: 1,
            origin: .mainApp,
            processInstanceID: UUID(),
            localSequence: 1,
            code: .schemeDeliveryPhaseChanged,
            level: .info,
            category: .deployment,
            schemeDeliveryPayload: .phaseChanged(
                .init(
                    context: context,
                    attempt: nil,
                    source: .cnb,
                    host: nil,
                    phase: .selecting,
                    result: .succeeded
                )
            )
        )
        var object = try XCTUnwrap(
            JSONSerialization.jsonObject(with: JSONEncoder().encode(valid)) as? [String: Any]
        )
        var payload = try XCTUnwrap(object["schemeDeliveryPayload"] as? [String: Any])
        var phase = try XCTUnwrap(payload["phaseChanged"] as? [String: Any])
        var phaseValue = try XCTUnwrap(phase["_0"] as? [String: Any])
        phaseValue["host"] = "cnb.cool"
        phase["_0"] = phaseValue
        payload["phaseChanged"] = phase
        object["schemeDeliveryPayload"] = payload
        XCTAssertThrowsError(
            try JSONDecoder().decode(
                DiagnosticEvent.self,
                from: JSONSerialization.data(withJSONObject: object)
            )
        )
    }
}
