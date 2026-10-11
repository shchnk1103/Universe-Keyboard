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
        try assertV6ReaderPreserves(event)
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

    func testRimeSyncPayloadRoundTripUsesOnlyFiniteContentFreeFields() throws {
        let operationID = UUID()
        let context = DiagnosticEvent.RimeSyncContext(
            operationID: operationID,
            source: .backgroundAutomatic
        )
        let event = DiagnosticEvent(
            utcTimestamp: .now,
            monotonicNanoseconds: 2,
            origin: .mainApp,
            processInstanceID: UUID(),
            localSequence: 2,
            code: .rimeSyncTerminal,
            level: .error,
            category: .config,
            rimeSyncPayload: .terminal(
                .init(
                    context: context,
                    result: .failed,
                    phase: .standardRimeData,
                    failure: .standardSynchronizationFailed
                )
            )
        )

        let encoded = try JSONEncoder().encode(event)
        XCTAssertEqual(try JSONDecoder().decode(DiagnosticEvent.self, from: encoded), event)

        let text = try XCTUnwrap(String(data: encoded, encoding: .utf8))
        XCTAssertTrue(text.contains(operationID.uuidString))
        for forbiddenKey in ["message", "text", "path", "bookmark", "domain", "filename"] {
            XCTAssertFalse(text.contains("\"\(forbiddenKey)\""))
        }
        try assertV6ReaderPreserves(event)
    }

    func testRimeSyncKeychainFailureHasDistinctPersistedCode() throws {
        let failure = DiagnosticEvent.RimeSyncFailure.keychainAccessDenied
        let encoded = try JSONEncoder().encode(failure)

        XCTAssertEqual(String(decoding: encoded, as: UTF8.self), "\"keychain_access_denied\"")
        XCTAssertEqual(try JSONDecoder().decode(DiagnosticEvent.RimeSyncFailure.self, from: encoded), failure)
    }

    func testRimeSyncDecoderRejectsEmptyInvocationAndCodeMismatch() throws {
        let context = DiagnosticEvent.RimeSyncContext(
            operationID: UUID(),
            source: .foregroundAutomatic
        )
        let event = DiagnosticEvent(
            utcTimestamp: .now,
            monotonicNanoseconds: 3,
            origin: .mainApp,
            processInstanceID: UUID(),
            localSequence: 3,
            code: .rimeSyncInvoked,
            level: .info,
            category: .config,
            rimeSyncPayload: .invoked(
                .init(context: context, requestedPhases: [.privateSettings])
            )
        )
        var object = try XCTUnwrap(
            JSONSerialization.jsonObject(with: JSONEncoder().encode(event)) as? [String: Any]
        )
        var payload = try XCTUnwrap(object["rimeSyncPayload"] as? [String: Any])
        var invocation = try XCTUnwrap(payload["invoked"] as? [String: Any])
        var invocationValue = try XCTUnwrap(invocation["_0"] as? [String: Any])
        invocationValue["requestedPhases"] = []
        invocation["_0"] = invocationValue
        payload["invoked"] = invocation
        object["rimeSyncPayload"] = payload

        XCTAssertThrowsError(
            try JSONDecoder().decode(
                DiagnosticEvent.self,
                from: JSONSerialization.data(withJSONObject: object)
            )
        )

        object = try XCTUnwrap(
            JSONSerialization.jsonObject(with: JSONEncoder().encode(event)) as? [String: Any]
        )
        object["code"] = DiagnosticEvent.Code.rimeSyncSkipped.rawValue
        XCTAssertThrowsError(
            try JSONDecoder().decode(
                DiagnosticEvent.self,
                from: JSONSerialization.data(withJSONObject: object)
            )
        )
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
        try assertV6ReaderPreserves(event)
    }

    func testRuntimeRoutePayloadRoundTripsWithOnlyFiniteFields() throws {
        let payload = DiagnosticEvent.RuntimeRoutePhaseEvent(
            operationID: UUID(),
            phase: .fallbackDeploy,
            result: .succeeded,
            schema: .lunaPinyin,
            layout: .twentySixKey,
            state: .ready,
            elapsedMilliseconds: 37
        )
        let event = DiagnosticEvent(
            utcTimestamp: .now,
            monotonicNanoseconds: 1,
            origin: .mainApp,
            processInstanceID: UUID(),
            localSequence: 1,
            code: .runtimeRoutePhaseChanged,
            level: .info,
            category: .deployment,
            runtimeRoutePayload: payload
        )

        XCTAssertEqual(
            try JSONDecoder().decode(DiagnosticEvent.self, from: JSONEncoder().encode(event)),
            event
        )
        try assertV6ReaderPreserves(event)
    }

    func testSourceProbeFailureRoundTripsAndRejectsWrongPhase() throws {
        let context = DiagnosticEvent.SchemeDeliveryContext(
            operationID: UUID(), artifact: .rimeIce20260630675D23B0,
            stagedIdentity: .rimeIce20260630Plan1Post1
        )
        let phase = DiagnosticEvent.SchemeDeliveryPhaseEvent(
            context: context, attempt: nil, source: .nju, host: nil,
            phase: .selecting, result: .failed, probeFailure: .archiveSize
        )
        let payload = DiagnosticEvent.SchemeDeliveryPayload.phaseChanged(phase)
        XCTAssertTrue(payload.isValid)
        XCTAssertEqual(
            try JSONDecoder().decode(
                DiagnosticEvent.SchemeDeliveryPayload.self,
                from: JSONEncoder().encode(payload)), payload)
        XCTAssertFalse(
            DiagnosticEvent.SchemeDeliveryPayload.phaseChanged(
                .init(
                    context: context, attempt: .init(1), source: .nju, host: .nju,
                    phase: .downloading, result: .started, probeFailure: .archiveSize
                )
            ).isValid)
        XCTAssertFalse(
            DiagnosticEvent.SchemeDeliveryPayload.phaseChanged(
                .init(
                    context: context, attempt: nil, source: .nju, host: nil,
                    phase: .selecting, result: .failed
                )
            ).isValid)
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

    func testTypoRecallCodesRoundTripWithFenceFieldsOnly() throws {
        let fields = TypoCorrectionRecallDiagnosticMarkers.fenceFields(
            recallEpoch: 3,
            compositionRevision: 9,
            operationOrdinal: 2,
            normalizedComposition: "nihaoshijie"
        )
        let event = DiagnosticEvent(
            utcTimestamp: Date(timeIntervalSince1970: 1_800_000_000),
            monotonicNanoseconds: 99,
            origin: .keyboardExtension,
            processInstanceID: UUID(),
            localSequence: 11,
            appearanceID: UUID(),
            code: .typoRecallDebounceCancelled,
            level: .info,
            category: .performance,
            fields: fields
        )

        let decoded = try JSONDecoder().decode(
            DiagnosticEvent.self,
            from: JSONEncoder().encode(event)
        )
        XCTAssertEqual(decoded, event)
        XCTAssertEqual(decoded.schemaVersion, 5)
        XCTAssertEqual(decoded.code, .typoRecallDebounceCancelled)

        let text = try XCTUnwrap(String(data: JSONEncoder().encode(event), encoding: .utf8))
        XCTAssertFalse(text.contains("nihaoshijie"))
        for forbidden in ["message", "preedit", "composition_text", "correctedInput"] {
            XCTAssertFalse(text.contains("\"\(forbidden)\""))
        }
        try assertV6ReaderPreserves(event)
    }

    func testTypoRecallQueryOutcomeCarriesFiniteReason() throws {
        var fields = TypoCorrectionRecallDiagnosticMarkers.fenceFields(
            recallEpoch: 1,
            compositionRevision: 1,
            operationOrdinal: 1,
            normalizedComposition: "abcdefgh"
        )
        fields.append(.reason(.typoRecallQueryDiscarded))
        let event = DiagnosticEvent(
            utcTimestamp: .now,
            monotonicNanoseconds: 5,
            origin: .keyboardExtension,
            processInstanceID: UUID(),
            localSequence: 5,
            code: .typoRecallQueryOutcome,
            level: .info,
            category: .performance,
            fields: fields
        )
        XCTAssertEqual(
            try JSONDecoder().decode(DiagnosticEvent.self, from: JSONEncoder().encode(event)),
            event
        )
        XCTAssertEqual(DiagnosticEvent.Code.typoRecallQueryBegin.rawValue, "typo_recall.query_begin")
        XCTAssertEqual(
            DiagnosticEvent.Reason.typoRecallQuerySucceeded.rawValue,
            "typo_recall_query_succeeded"
        )
        try assertV6ReaderPreserves(event)
    }

    func testTypoRecallQueryMeasuredRoundTripsOneFiniteContentFreeField() throws {
        let event = measuredQueryEvent()
        let encoded = try JSONEncoder().encode(event)
        let decoded = try JSONDecoder().decode(DiagnosticEvent.self, from: encoded)
        XCTAssertEqual(decoded, event)
        XCTAssertEqual(decoded.schemaVersion, 5)

        let text = try XCTUnwrap(String(data: encoded, encoding: .utf8))
        for forbidden in [
            "wimenjintianquhongyuan",
            "我们今天去公园",
            "candidate-text",
            "compositionFingerprint",
            "composition_fingerprint",
            "host",
            "correctedInput",
        ] {
            XCTAssertFalse(text.contains(forbidden))
        }
        XCTAssertTrue(text.contains("stage_one"))
        XCTAssertTrue(text.contains("one_to_three"))
        XCTAssertTrue(text.contains("facadeElapsedMicroseconds"))
        try assertV6ReaderPreserves(event)
    }

    func testTypoRecallQueryMeasuredRejectsInvalidSchemaCodeAndFieldCardinality() throws {
        let object = try eventObject(measuredQueryEvent())
        let field = try XCTUnwrap((object["fields"] as? [[String: Any]])?.first)

        var invalid: [[String: Any]] = []

        var missing = object
        missing["fields"] = []
        invalid.append(missing)

        var duplicate = object
        duplicate["fields"] = [field, field]
        invalid.append(duplicate)

        var extra = object
        extra["fields"] = [field, ["type": "reason", "reason": "queue_full"]]
        invalid.append(extra)

        var wrongCode = object
        wrongCode["code"] = "candidate.visibility_changed"
        invalid.append(wrongCode)

        var schemaFour = object
        schemaFour["schemaVersion"] = 4
        invalid.append(schemaFour)

        var unknownSchema = object
        unknownSchema["schemaVersion"] = 7
        invalid.append(unknownSchema)

        var unknownCode = object
        unknownCode["code"] = "typo_recall.unknown"
        invalid.append(unknownCode)

        var unknownStage = object
        unknownStage["fields"] = [mutatingQueryField(field) { $0["stage"] = "stage_three" }]
        invalid.append(unknownStage)

        var mismatchedReadiness = object
        mismatchedReadiness["fields"] = [
            mutatingQueryField(field) { $0["readiness"] = "unavailable" }
        ]
        invalid.append(mismatchedReadiness)

        for candidate in invalid {
            XCTAssertThrowsError(try JSONDecoder().decode(DiagnosticEvent.self, from: jsonData(candidate)))
            if candidate["schemaVersion"] as? Int == 5 {
                var v6Candidate = candidate
                v6Candidate["schemaVersion"] = 6
                XCTAssertThrowsError(
                    try JSONDecoder().decode(DiagnosticEvent.self, from: jsonData(v6Candidate))
                )
            }
        }
    }

    func testOtherCodesCannotCarryTypoRecallTypedField() throws {
        let event = measuredQueryEvent()
        var object = try eventObject(event)
        object["code"] = "journal.dropped"
        XCTAssertThrowsError(try JSONDecoder().decode(DiagnosticEvent.self, from: jsonData(object)))
    }

    func testSchemaFourRimeSyncFixturesRemainReadableAcrossTheKnownEnumBoundary() throws {
        for failure in [
            DiagnosticEvent.RimeSyncFailure.accessDenied,
            .keychainAccessDenied,
        ] {
            let event = DiagnosticEvent(
                utcTimestamp: .now,
                monotonicNanoseconds: 11,
                origin: .mainApp,
                processInstanceID: UUID(),
                localSequence: 11,
                code: .rimeSyncTerminal,
                level: .error,
                category: .config,
                rimeSyncPayload: .terminal(
                    .init(
                        context: .init(operationID: UUID(), source: .foregroundAutomatic),
                        result: .failed,
                        phase: .standardRimeData,
                        failure: failure
                    )
                )
            )
            var fixture = try eventObject(event)
            fixture["schemaVersion"] = 4

            let decoded = try JSONDecoder().decode(DiagnosticEvent.self, from: jsonData(fixture))
            XCTAssertEqual(decoded.schemaVersion, 4)
            XCTAssertEqual(decoded.rimeSyncPayload, event.rimeSyncPayload)
            let roundTripped = try eventObject(decoded)
            XCTAssertEqual(roundTripped["schemaVersion"] as? Int, 4)
        }
    }

    func testV6ReaderAcceptsThreeMarkersAndExistingEventFamilies() throws {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let processID = "00000000-0000-0000-0000-000000000001"
        let base: [String: Any] = [
            "schemaVersion": 6,
            "utcTimestamp": "2024-08-08T12:24:16Z",
            "monotonicNanoseconds": 1,
            "origin": DiagnosticEvent.Origin.keyboardExtension.rawValue,
            "processInstanceID": processID,
            "localSequence": 1,
            "level": Logger.Level.debug.rawValue,
            "category": Logger.Category.display.rawValue,
            "fields": [],
        ]

        var lifecycle = base
        lifecycle["code"] = DiagnosticEvent.Code.keyboardLifecyclePhaseChanged.rawValue
        lifecycle["keyboardLifecyclePayload"] = ["phase": "view_did_appear"]

        var resume = base
        resume["code"] = DiagnosticEvent.Code.rimeResumePhaseChanged.rawValue
        resume["category"] = Logger.Category.engine.rawValue
        resume["rimeResumePayload"] = [
            "phase": "completed",
            "sessionEpoch": 7,
            "revision": 11,
        ]

        var textProxy = base
        textProxy["code"] = DiagnosticEvent.Code.textProxyOperationPhaseChanged.rawValue
        textProxy["textProxyPayload"] = ["operation": "insert_text", "phase": "entered"]

        var ordinaryEvent = base
        ordinaryEvent["origin"] = DiagnosticEvent.Origin.mainApp.rawValue
        ordinaryEvent["level"] = Logger.Level.info.rawValue
        ordinaryEvent["category"] = Logger.Category.general.rawValue
        ordinaryEvent["code"] = DiagnosticEvent.Code.journalStarted.rawValue

        var typoRecall = try eventObject(measuredQueryEvent())
        typoRecall["schemaVersion"] = 6
        typoRecall["utcTimestamp"] = "2024-08-08T12:24:16Z"

        let fixtures = [lifecycle, resume, textProxy, ordinaryEvent, typoRecall]
        let events = try fixtures.map { fixture -> DiagnosticEvent in
            let data = try jsonData(fixture)
            XCTAssertNil(DiagnosticEventWireValidator.rejectionReason(for: data))
            let decoded = try decoder.decode(DiagnosticEvent.self, from: data)
            XCTAssertFalse(decoded.isWritableV5, "No v6 record may enter the production v5 writer")
            XCTAssertEqual(try eventObject(decoded)["schemaVersion"] as? Int, 6)
            return decoded
        }

        XCTAssertEqual(events.map(\.schemaVersion), Array(repeating: 6, count: fixtures.count))
        XCTAssertEqual(
            events.first { $0.code == .keyboardLifecyclePhaseChanged }?.keyboardLifecyclePayload?.phase,
            .viewDidAppear
        )
        XCTAssertEqual(
            events.first { $0.code == .rimeResumePhaseChanged }?.rimeResumePayload?.phase,
            .completed
        )
        XCTAssertEqual(
            events.first { $0.code == .textProxyOperationPhaseChanged }?.textProxyPayload?.operation,
            .insertText
        )
        XCTAssertTrue(events.contains { $0.code == .typoRecallQueryMeasured })
        XCTAssertEqual(DiagnosticEvent.schemaVersion, 5, "Reader support must not change the production writer version")
    }

    func testV6WireValidatorRejectsUnknownMalformedAndMismatchedMarkers() throws {
        let valid: [String: Any] = [
            "schemaVersion": 6,
            "utcTimestamp": "2024-08-08T12:24:16Z",
            "monotonicNanoseconds": 1,
            "origin": DiagnosticEvent.Origin.keyboardExtension.rawValue,
            "processInstanceID": "00000000-0000-0000-0000-000000000001",
            "localSequence": 1,
            "code": DiagnosticEvent.Code.keyboardLifecyclePhaseChanged.rawValue,
            "level": Logger.Level.debug.rawValue,
            "category": Logger.Category.display.rawValue,
            "fields": [],
            "keyboardLifecyclePayload": ["phase": "view_did_appear"],
        ]
        XCTAssertNil(DiagnosticEventWireValidator.rejectionReason(for: try jsonData(valid)))

        var v4Marker = valid
        v4Marker["schemaVersion"] = 4
        XCTAssertNil(DiagnosticEventWireValidator.rejectionReason(for: try jsonData(v4Marker)))

        var v5Marker = valid
        v5Marker["schemaVersion"] = 5
        XCTAssertEqual(
            DiagnosticEventWireValidator.rejectionReason(for: try jsonData(v5Marker)),
            .invalidPayloadPairing,
            "The v5 writer's historical marker prohibition remains intact"
        )

        var unknownPayloadKey = valid
        unknownPayloadKey["keyboardLifecyclePayload"] = ["phase": "view_did_appear", "private": "fixture"]
        XCTAssertEqual(
            DiagnosticEventWireValidator.rejectionReason(for: try jsonData(unknownPayloadKey)),
            .unknownKey
        )

        var unknownPayloadValue = valid
        unknownPayloadValue["keyboardLifecyclePayload"] = ["phase": "host_became_active"]
        XCTAssertEqual(
            DiagnosticEventWireValidator.rejectionReason(for: try jsonData(unknownPayloadValue)),
            .unknownValue
        )

        var mismatchedCode = valid
        mismatchedCode["code"] = DiagnosticEvent.Code.textProxyOperationPhaseChanged.rawValue
        XCTAssertEqual(
            DiagnosticEventWireValidator.rejectionReason(for: try jsonData(mismatchedCode)),
            .invalidPayloadPairing
        )

        var malformedPayload = valid
        malformedPayload["keyboardLifecyclePayload"] = [:]
        XCTAssertEqual(
            DiagnosticEventWireValidator.rejectionReason(for: try jsonData(malformedPayload)),
            .malformedPayload
        )

        var unknownCode = valid
        unknownCode["code"] = "unrecognized.event.code"
        XCTAssertEqual(
            DiagnosticEventWireValidator.rejectionReason(for: try jsonData(unknownCode)),
            .unsupportedCode
        )

        var unsupportedVersion = valid
        unsupportedVersion["schemaVersion"] = 7
        XCTAssertEqual(
            DiagnosticEventWireValidator.rejectionReason(for: try jsonData(unsupportedVersion)),
            .unsupportedSchemaVersion
        )

        var nonIntegerVersion = valid
        nonIntegerVersion["schemaVersion"] = 6.5
        XCTAssertEqual(
            DiagnosticEventWireValidator.rejectionReason(for: try jsonData(nonIntegerVersion)),
            .unsupportedSchemaVersion
        )
    }

    func testReaderDecodesV3V4AndV5WithoutRelabelingLegacyRecords() throws {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let processID = "00000000-0000-0000-0000-000000000001"

        let v3 = try JSONSerialization.data(withJSONObject: [
            "schemaVersion": 3,
            "utcTimestamp": "2024-08-08T12:24:16Z",
            "monotonicNanoseconds": 1,
            "origin": DiagnosticEvent.Origin.mainApp.rawValue,
            "processInstanceID": processID,
            "localSequence": 1,
            "code": DiagnosticEvent.Code.journalStarted.rawValue,
            "level": Logger.Level.info.rawValue,
            "category": Logger.Category.general.rawValue,
            "fields": [],
        ])
        let v3Event = try decoder.decode(DiagnosticEvent.self, from: v3)
        XCTAssertEqual(v3Event.schemaVersion, 3)
        let reencodedV3 = try XCTUnwrap(
            JSONSerialization.jsonObject(with: encoder.encode(v3Event)) as? [String: Any]
        )
        XCTAssertEqual(reencodedV3["schemaVersion"] as? Int, 3)

        let v4 = try JSONSerialization.data(withJSONObject: [
            "schemaVersion": 4,
            "utcTimestamp": "2024-08-08T12:24:16Z",
            "monotonicNanoseconds": 2,
            "origin": DiagnosticEvent.Origin.keyboardExtension.rawValue,
            "processInstanceID": processID,
            "localSequence": 2,
            "code": DiagnosticEvent.Code.keyboardLifecyclePhaseChanged.rawValue,
            "level": Logger.Level.debug.rawValue,
            "category": Logger.Category.display.rawValue,
            "fields": [],
            "keyboardLifecyclePayload": ["phase": "view_did_appear"],
        ])
        let v4Event = try decoder.decode(DiagnosticEvent.self, from: v4)
        XCTAssertEqual(v4Event.schemaVersion, 4)
        XCTAssertEqual(v4Event.keyboardLifecyclePayload?.phase, .viewDidAppear)
        let reencodedV4 = try XCTUnwrap(
            JSONSerialization.jsonObject(with: encoder.encode(v4Event)) as? [String: Any]
        )
        XCTAssertEqual(reencodedV4["schemaVersion"] as? Int, 4)

        let v5Event = measuredQueryEvent()
        let v5Data = try encoder.encode(v5Event)
        XCTAssertEqual(try JSONDecoder().decode(DiagnosticEvent.self, from: v5Data), v5Event)
        XCTAssertEqual(v5Event.schemaVersion, 5)
        XCTAssertEqual(DiagnosticEvent.schemaVersion, 5)
    }

    func testWireValidatorRejectsUnknownRawKeysAcrossSupportedVersions() throws {
        for version in [3, 4, 5, 6] {
            var event: [String: Any] = [
                "schemaVersion": version,
                "utcTimestamp": "2024-08-08T12:24:16Z",
                "monotonicNanoseconds": 1,
                "origin": DiagnosticEvent.Origin.mainApp.rawValue,
                "processInstanceID": "00000000-0000-0000-0000-000000000001",
                "localSequence": 1,
                "code": DiagnosticEvent.Code.journalStarted.rawValue,
                "level": Logger.Level.info.rawValue,
                "category": Logger.Category.general.rawValue,
                "fields": [],
            ]
            event["unrecognizedKey"] = true
            let data = try JSONSerialization.data(withJSONObject: event)
            XCTAssertEqual(
                DiagnosticEventWireValidator.rejectionReason(for: data),
                .unknownKey,
                "schema v\(version) top-level key"
            )
        }

        let fieldEvent: [String: Any] = [
            "schemaVersion": 3,
            "utcTimestamp": "2024-08-08T12:24:16Z",
            "monotonicNanoseconds": 1,
            "origin": DiagnosticEvent.Origin.mainApp.rawValue,
            "processInstanceID": "00000000-0000-0000-0000-000000000001",
            "localSequence": 1,
            "code": DiagnosticEvent.Code.journalStarted.rawValue,
            "level": Logger.Level.info.rawValue,
            "category": Logger.Category.general.rawValue,
            "fields": [["type": "reason", "reason": "queue_full", "private": "fixture"]],
        ]
        let fieldData = try JSONSerialization.data(withJSONObject: fieldEvent)
        XCTAssertEqual(
            DiagnosticEventWireValidator.rejectionReason(for: fieldData),
            .unknownKey
        )

        var queryObject = try eventObject(measuredQueryEvent())
        var fields = try XCTUnwrap(queryObject["fields"] as? [[String: Any]])
        var queryField = try XCTUnwrap(fields.first)
        var payload = try XCTUnwrap(queryField["typoRecallQuery"] as? [String: Any])
        payload["private"] = "fixture"
        queryField["typoRecallQuery"] = payload
        fields[0] = queryField
        queryObject["fields"] = fields
        XCTAssertEqual(
            DiagnosticEventWireValidator.rejectionReason(for: try jsonData(queryObject)),
            .unknownKey
        )
    }

    func testWireValidatorRejectsUnknownMarkerKeysAndEnumValues() throws {
        var marker: [String: Any] = [
            "schemaVersion": 4,
            "utcTimestamp": "2024-08-08T12:24:16Z",
            "monotonicNanoseconds": 1,
            "origin": DiagnosticEvent.Origin.keyboardExtension.rawValue,
            "processInstanceID": "00000000-0000-0000-0000-000000000001",
            "localSequence": 1,
            "code": DiagnosticEvent.Code.keyboardLifecyclePhaseChanged.rawValue,
            "level": Logger.Level.debug.rawValue,
            "category": Logger.Category.display.rawValue,
            "fields": [],
            "keyboardLifecyclePayload": ["phase": "view_did_appear", "private": "fixture"],
        ]
        XCTAssertEqual(
            DiagnosticEventWireValidator.rejectionReason(for: try jsonData(marker)),
            .unknownKey
        )

        marker["keyboardLifecyclePayload"] = ["phase": "host_became_active"]
        XCTAssertEqual(
            DiagnosticEventWireValidator.rejectionReason(for: try jsonData(marker)),
            .unknownValue
        )

        marker["schemaVersion"] = 4
        marker["code"] = DiagnosticEvent.Code.typoRecallDebounceScheduled.rawValue
        marker.removeValue(forKey: "keyboardLifecyclePayload")
        XCTAssertEqual(
            DiagnosticEventWireValidator.rejectionReason(for: try jsonData(marker)),
            .unsupportedCode
        )
    }

    func testWireValidatorRejectsSchemaVersionMismatchesAndMalformedPayloads() throws {
        let base: [String: Any] = [
            "schemaVersion": 4,
            "utcTimestamp": "2024-08-08T12:24:16Z",
            "monotonicNanoseconds": 1,
            "origin": DiagnosticEvent.Origin.keyboardExtension.rawValue,
            "processInstanceID": "00000000-0000-0000-0000-000000000001",
            "localSequence": 1,
            "code": DiagnosticEvent.Code.keyboardLifecyclePhaseChanged.rawValue,
            "level": Logger.Level.debug.rawValue,
            "category": Logger.Category.display.rawValue,
            "fields": [],
            "keyboardLifecyclePayload": ["phase": "view_did_appear"],
        ]

        var v4CodeAsV3 = base
        v4CodeAsV3["schemaVersion"] = 3
        XCTAssertEqual(
            DiagnosticEventWireValidator.rejectionReason(
                for: try JSONSerialization.data(withJSONObject: v4CodeAsV3)
            ),
            .invalidPayloadPairing
        )

        var v4PayloadAsV5 = base
        v4PayloadAsV5["schemaVersion"] = 5
        XCTAssertEqual(
            DiagnosticEventWireValidator.rejectionReason(
                for: try JSONSerialization.data(withJSONObject: v4PayloadAsV5)
            ),
            .invalidPayloadPairing
        )

        var malformedPayload = base
        malformedPayload["keyboardLifecyclePayload"] = [:]
        XCTAssertEqual(
            DiagnosticEventWireValidator.rejectionReason(
                for: try JSONSerialization.data(withJSONObject: malformedPayload)
            ),
            .malformedPayload
        )

        var mismatchedPayload = base
        mismatchedPayload["code"] = DiagnosticEvent.Code.textProxyOperationPhaseChanged.rawValue
        XCTAssertEqual(
            DiagnosticEventWireValidator.rejectionReason(
                for: try JSONSerialization.data(withJSONObject: mismatchedPayload)
            ),
            .invalidPayloadPairing
        )

        var unsupportedVersion = base
        unsupportedVersion["schemaVersion"] = 7
        XCTAssertEqual(
            DiagnosticEventWireValidator.rejectionReason(
                for: try JSONSerialization.data(withJSONObject: unsupportedVersion)
            ),
            .unsupportedSchemaVersion
        )

        var nonIntegerVersion = base
        nonIntegerVersion["schemaVersion"] = 4.5
        XCTAssertEqual(
            DiagnosticEventWireValidator.rejectionReason(
                for: try JSONSerialization.data(withJSONObject: nonIntegerVersion)
            ),
            .unsupportedSchemaVersion
        )
    }

    private func assertV6ReaderPreserves(
        _ event: DiagnosticEvent,
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws {
        var fixture = try eventObject(event)
        fixture["schemaVersion"] = 6
        let data = try jsonData(fixture)
        XCTAssertNil(DiagnosticEventWireValidator.rejectionReason(for: data), file: file, line: line)
        let decoded = try JSONDecoder().decode(DiagnosticEvent.self, from: data)
        XCTAssertEqual(decoded.schemaVersion, 6, file: file, line: line)
        XCTAssertFalse(decoded.isWritableV5, file: file, line: line)
        // Aside from its original wire version, every content-free value must be retained.
        var roundTrip = try eventObject(decoded)
        roundTrip["schemaVersion"] = event.schemaVersion
        XCTAssertEqual(
            try JSONDecoder().decode(DiagnosticEvent.self, from: jsonData(roundTrip)),
            event, file: file, line: line
        )
    }

    private func measuredQueryEvent() -> DiagnosticEvent {
        DiagnosticEvent(
            utcTimestamp: Date(timeIntervalSince1970: 1_800_000_000),
            monotonicNanoseconds: 12,
            origin: .keyboardExtension,
            processInstanceID: UUID(),
            localSequence: 12,
            code: .typoRecallQueryMeasured,
            level: .info,
            category: .performance,
            fields: [
                .typoRecallQuery(
                    .init(
                        operationOrdinal: 9,
                        stage: .stageOne,
                        readiness: .ready,
                        resultState: .candidatesReturned,
                        returnedCandidateBucket: .oneToThree,
                        disposition: .applied,
                        facadeElapsedMicroseconds: 124,
                        durationState: .measured
                    )
                )
            ]
        )
    }

    private func eventObject(_ event: DiagnosticEvent) throws -> [String: Any] {
        try XCTUnwrap(JSONSerialization.jsonObject(with: JSONEncoder().encode(event)) as? [String: Any])
    }

    private func jsonData(_ object: [String: Any]) throws -> Data {
        try JSONSerialization.data(withJSONObject: object)
    }

    private func mutatingQueryField(
        _ field: [String: Any],
        update: (inout [String: Any]) -> Void
    ) -> [String: Any] {
        var copy = field
        guard var payload = copy["typoRecallQuery"] as? [String: Any] else { return copy }
        update(&payload)
        copy["typoRecallQuery"] = payload
        return copy
    }
}
