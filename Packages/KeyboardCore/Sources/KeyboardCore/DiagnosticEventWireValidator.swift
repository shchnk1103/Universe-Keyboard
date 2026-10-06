import Foundation

/// Performs the raw-key checks that `Codable` intentionally does not provide.
/// JSONSerialization cannot expose repeated object member occurrences; that parser
/// limitation is documented by the owning Assignment and is not treated as covered.
enum DiagnosticEventWireValidator {
    private typealias Object = [String: Any]

    private struct VersionEnvelope: Decodable {
        let schemaVersion: Int
    }

    private static let v4OnlyCodes: Set<DiagnosticEvent.Code> = [
        .keyboardLifecyclePhaseChanged,
        .rimeResumePhaseChanged,
        .textProxyOperationPhaseChanged,
    ]

    private static let v5OnlyCodes: Set<DiagnosticEvent.Code> = [
        .typoRecallDebounceScheduled,
        .typoRecallDebounceCancelled,
        .typoRecallEpochBumped,
        .typoRecallFenceDiscarded,
        .typoRecallQueryBegin,
        .typoRecallQueryOutcome,
        .typoRecallQueryMeasured,
    ]

    private static let v4PayloadKeys: Set<String> = [
        "keyboardLifecyclePayload",
        "rimeResumePayload",
        "textProxyPayload",
    ]

    private static let compositePayloadKeys: Set<String> = [
        "schemeDeliveryPayload",
        "runtimeRoutePayload",
        "rimeSyncPayload",
        "keyboardLifecyclePayload",
        "rimeResumePayload",
        "textProxyPayload",
    ]

    private static let envelopeKeys: Set<String> = [
        "schemaVersion",
        "utcTimestamp",
        "monotonicNanoseconds",
        "origin",
        "processInstanceID",
        "localSequence",
        "appearanceID",
        "actionSequence",
        "code",
        "level",
        "category",
        "fields",
        "schemeDeliveryPayload",
        "runtimeRoutePayload",
        "rimeSyncPayload",
        "keyboardLifecyclePayload",
        "rimeResumePayload",
        "textProxyPayload",
    ]

    private static let requiredEnvelopeKeys: Set<String> = [
        "schemaVersion",
        "utcTimestamp",
        "monotonicNanoseconds",
        "origin",
        "processInstanceID",
        "localSequence",
        "code",
        "level",
        "category",
        "fields",
    ]

    static func rejectionReason(for data: Data) -> DiagnosticsJournalRejectionReason? {
        guard let object = try? JSONSerialization.jsonObject(with: data),
            let event = object as? Object
        else { return .malformedRecord }
        guard event["schemaVersion"] != nil else { return .malformedRecord }
        guard let version = try? JSONDecoder().decode(VersionEnvelope.self, from: data).schemaVersion else {
            return .unsupportedSchemaVersion
        }

        guard DiagnosticEvent.supportsReading(schemaVersion: version) else {
            return .unsupportedSchemaVersion
        }
        guard
            let codeRawValue = event["code"] as? String,
            let code = DiagnosticEvent.Code(rawValue: codeRawValue)
        else {
            return .unsupportedCode
        }

        if !DiagnosticEvent.supportsWakeMarkers(schemaVersion: version), v4OnlyCodes.contains(code) {
            return .invalidPayloadPairing
        }
        if !DiagnosticEvent.supportsTypoRecall(schemaVersion: version), v5OnlyCodes.contains(code) {
            return .unsupportedCode
        }
        if !DiagnosticEvent.supportsWakeMarkers(schemaVersion: version),
            v4PayloadKeys.contains(where: event.keys.contains)
        {
            return .invalidPayloadPairing
        }

        return validateKnownEvent(event, code: code, version: version)
    }

    private static func validateKnownEvent(
        _ event: Object,
        code: DiagnosticEvent.Code,
        version: Int
    ) -> DiagnosticsJournalRejectionReason? {
        var allowedEnvelopeKeys = envelopeKeys
        if !DiagnosticEvent.supportsWakeMarkers(schemaVersion: version) {
            allowedEnvelopeKeys.subtract(v4PayloadKeys)
        }
        if let reason = validateKeys(
            event,
            allowed: allowedEnvelopeKeys,
            required: requiredEnvelopeKeys
        ) {
            return reason
        }

        if ["appearanceID", "actionSequence"].contains(where: { event[$0] is NSNull }) {
            return .malformedRecord
        }
        if let reason = validateEnvelopeEnums(event) {
            return reason
        }
        if let reason = validateFields(event["fields"], version: version) {
            return reason
        }
        if let reason = validateTypoRecallPairing(event, code: code, version: version) {
            return reason
        }
        if let reason = validateTypedEventEnvelope(event, code: code) {
            return reason
        }
        if let reason = validatePayloadPairing(event, code: code) {
            return reason
        }

        for key in compositePayloadKeys where event.keys.contains(key) {
            guard let value = event[key] else { return .malformedPayload }
            let reason: DiagnosticsJournalRejectionReason?
            switch key {
            case "schemeDeliveryPayload":
                reason = validateSchemeDeliveryPayload(value, code: code)
            case "runtimeRoutePayload":
                reason = validateRuntimeRoutePayload(value)
            case "rimeSyncPayload":
                reason = validateRimeSyncPayload(value, code: code)
            case "keyboardLifecyclePayload":
                reason = validateKeyboardLifecyclePayload(value, code: code)
            case "rimeResumePayload":
                reason = validateRimeResumePayload(value, code: code)
            case "textProxyPayload":
                reason = validateTextProxyPayload(value, code: code)
            default:
                reason = .unknownKey
            }
            if let reason { return reason }
        }
        return nil
    }

    private static func validateTypoRecallPairing(
        _ event: Object,
        code: DiagnosticEvent.Code,
        version: Int
    ) -> DiagnosticsJournalRejectionReason? {
        guard let fields = event["fields"] as? [Object] else { return .malformedRecord }
        let hasQueryPayload = fields.contains { $0["type"] as? String == "typoRecallQuery" }
        guard DiagnosticEvent.supportsTypoRecall(schemaVersion: version) else {
            return hasQueryPayload ? .invalidPayloadPairing : nil
        }
        if code == .typoRecallQueryMeasured {
            guard fields.count == 1, hasQueryPayload else { return .invalidPayloadPairing }
        } else if hasQueryPayload {
            return .invalidPayloadPairing
        }
        return nil
    }

    private static func validateTypedEventEnvelope(
        _ event: Object,
        code: DiagnosticEvent.Code
    ) -> DiagnosticsJournalRejectionReason? {
        let expectedCategory: String
        switch code {
        case .keyboardLifecyclePhaseChanged, .textProxyOperationPhaseChanged:
            expectedCategory = Logger.Category.display.rawValue
        case .rimeResumePhaseChanged:
            expectedCategory = Logger.Category.engine.rawValue
        default:
            return nil
        }
        guard event["origin"] as? String == DiagnosticEvent.Origin.keyboardExtension.rawValue,
            event["level"] as? String == Logger.Level.debug.rawValue,
            event["category"] as? String == expectedCategory,
            let fields = event["fields"] as? [Any], fields.isEmpty
        else {
            return .invalidPayloadPairing
        }
        return nil
    }

    private static func validateEnvelopeEnums(
        _ event: Object
    ) -> DiagnosticsJournalRejectionReason? {
        guard
            let origin = event["origin"] as? String,
            let level = event["level"] as? String,
            let category = event["category"] as? String
        else {
            return .malformedRecord
        }
        guard DiagnosticEvent.Origin(rawValue: origin) != nil,
            Logger.Level(rawValue: level) != nil,
            Logger.Category(rawValue: category) != nil
        else {
            return .unknownValue
        }
        return nil
    }

    private static func validatePayloadPairing(
        _ event: Object,
        code: DiagnosticEvent.Code
    ) -> DiagnosticsJournalRejectionReason? {
        let presentKeys = compositePayloadKeys.filter { event.keys.contains($0) }
        guard presentKeys.count <= 1 else { return .invalidPayloadPairing }

        let expectedKey: String?
        switch code {
        case .schemeDeliveryPhaseChanged, .schemeDeliveryIntegrityFailed,
            .schemeDeliveryFallback, .schemeDeliveryTerminal:
            expectedKey = "schemeDeliveryPayload"
        case .runtimeRoutePhaseChanged:
            expectedKey = "runtimeRoutePayload"
        case .rimeSyncInvoked, .rimeSyncPhaseChanged, .rimeSyncSkipped, .rimeSyncTerminal:
            expectedKey = "rimeSyncPayload"
        case .keyboardLifecyclePhaseChanged:
            expectedKey = "keyboardLifecyclePayload"
        case .rimeResumePhaseChanged:
            expectedKey = "rimeResumePayload"
        case .textProxyOperationPhaseChanged:
            expectedKey = "textProxyPayload"
        default:
            expectedKey = nil
        }
        guard presentKeys.first == expectedKey else { return .invalidPayloadPairing }
        return nil
    }

    private static func validateFields(
        _ value: Any?,
        version: Int
    ) -> DiagnosticsJournalRejectionReason? {
        guard let fields = value as? [Any] else { return .malformedRecord }
        for fieldValue in fields {
            guard let field = fieldValue as? Object,
                let type = field["type"] as? String
            else {
                return .malformedPayload
            }

            let allowed: Set<String>
            let required: Set<String>
            switch type {
            case "count", "duration":
                allowed = ["type", "name", "integerValue"]
                required = allowed
            case "flag":
                allowed = ["type", "name", "booleanValue"]
                required = allowed
            case "reason":
                allowed = ["type", "reason"]
                required = allowed
            case "typoRecallQuery":
                guard DiagnosticEvent.supportsTypoRecall(schemaVersion: version) else { return .unknownValue }
                allowed = ["type", "typoRecallQuery"]
                required = allowed
            default:
                return .unknownValue
            }
            if let reason = validateKeys(field, allowed: allowed, required: required) {
                return reason
            }

            if type == "typoRecallQuery" {
                guard let payload = field["typoRecallQuery"] as? Object else {
                    return .malformedPayload
                }
                if let reason = validateTypoRecallQueryPayload(payload) {
                    return reason
                }
                continue
            }

            if type == "reason" {
                guard let rawValue = field["reason"] as? String else { return .malformedPayload }
                guard let reason = DiagnosticEvent.Reason(rawValue: rawValue) else {
                    return .unknownValue
                }
                if !DiagnosticEvent.supportsTypoRecall(schemaVersion: version), Self.v5OnlyReasons.contains(reason) {
                    return .unknownValue
                }
                continue
            }

            guard let rawName = field["name"] as? String else { return .malformedPayload }
            let nameIsKnown: Bool
            switch type {
            case "count":
                if let metric = DiagnosticEvent.CountMetric(rawValue: rawName) {
                    nameIsKnown =
                        DiagnosticEvent.supportsTypoRecall(schemaVersion: version)
                        || !Self.v5OnlyCountMetrics.contains(metric)
                } else {
                    nameIsKnown = false
                }
            case "duration":
                nameIsKnown = DiagnosticEvent.DurationMetric(rawValue: rawName) != nil
            case "flag":
                nameIsKnown = DiagnosticEvent.Flag(rawValue: rawName) != nil
            default:
                nameIsKnown = false
            }
            if !nameIsKnown { return .unknownValue }
        }
        return nil
    }

    private static let v5OnlyReasons: Set<DiagnosticEvent.Reason> = [
        .typoRecallQuerySucceeded,
        .typoRecallQueryDiscarded,
        .typoRecallQueryCancelled,
    ]

    private static let v5OnlyCountMetrics: Set<DiagnosticEvent.CountMetric> = [
        .recallEpoch,
        .compositionRevision,
        .operationOrdinal,
        .compositionLength,
        .compositionFingerprint,
    ]

    private static func validateTypoRecallQueryPayload(
        _ payload: Object
    ) -> DiagnosticsJournalRejectionReason? {
        let keys: Set<String> = [
            "operationOrdinal", "stage", "readiness", "resultState",
            "returnedCandidateBucket", "disposition", "facadeElapsedMicroseconds", "durationState",
        ]
        if let reason = validateKeys(payload, allowed: keys, required: keys) {
            return reason
        }
        if let reason = validateStringEnum(
            payload["stage"],
            as: TypoCorrectionRecallStage.self
        ) {
            return reason
        }
        if let reason = validateStringEnum(
            payload["readiness"],
            as: TypoCorrectionQueryReadiness.self
        ) {
            return reason
        }
        if let reason = validateStringEnum(
            payload["resultState"],
            as: TypoCorrectionQueryResultState.self
        ) {
            return reason
        }
        if let reason = validateStringEnum(
            payload["returnedCandidateBucket"],
            as: DiagnosticEvent.TypoRecallCandidateBucket.self
        ) {
            return reason
        }
        if let reason = validateStringEnum(
            payload["disposition"],
            as: DiagnosticEvent.TypoRecallQueryDisposition.self
        ) {
            return reason
        }
        return validateStringEnum(
            payload["durationState"],
            as: DiagnosticEvent.TypoRecallQueryDurationState.self
        )
    }

    private static func validateKeyboardLifecyclePayload(
        _ value: Any,
        code: DiagnosticEvent.Code
    ) -> DiagnosticsJournalRejectionReason? {
        guard code == .keyboardLifecyclePhaseChanged,
            let payload = value as? Object
        else {
            return .invalidPayloadPairing
        }
        if let reason = validateKeys(payload, allowed: ["phase"], required: ["phase"]) {
            return reason
        }
        guard let rawPhase = payload["phase"] as? String else { return .malformedPayload }
        guard DiagnosticEvent.KeyboardLifecyclePhase(rawValue: rawPhase) != nil else {
            return .unknownValue
        }
        return nil
    }

    private static func validateRimeResumePayload(
        _ value: Any,
        code: DiagnosticEvent.Code
    ) -> DiagnosticsJournalRejectionReason? {
        guard code == .rimeResumePhaseChanged,
            let payload = value as? Object
        else {
            return .invalidPayloadPairing
        }
        if let reason = validateKeys(
            payload,
            allowed: ["phase", "failure", "sessionEpoch", "revision"],
            required: ["phase"]
        ) {
            return reason
        }
        guard let rawPhase = payload["phase"] as? String,
            let phase = DiagnosticEvent.RimeResumePhase(rawValue: rawPhase)
        else {
            return payload["phase"] is String ? .unknownValue : .malformedPayload
        }
        let hasFailure = payload.keys.contains("failure")
        guard (phase == .failed) == hasFailure else { return .invalidPayloadPairing }
        if hasFailure {
            guard let rawFailure = payload["failure"] as? String else { return .malformedPayload }
            guard DiagnosticEvent.RimeResumeFailure(rawValue: rawFailure) != nil else {
                return .unknownValue
            }
        }
        for key in ["sessionEpoch", "revision"] where payload[key] is NSNull {
            return .malformedPayload
        }
        return nil
    }

    private static func validateTextProxyPayload(
        _ value: Any,
        code: DiagnosticEvent.Code
    ) -> DiagnosticsJournalRejectionReason? {
        guard code == .textProxyOperationPhaseChanged,
            let payload = value as? Object
        else {
            return .invalidPayloadPairing
        }
        if let reason = validateKeys(
            payload,
            allowed: ["operation", "phase"],
            required: ["operation", "phase"]
        ) {
            return reason
        }
        guard let rawOperation = payload["operation"] as? String,
            let rawPhase = payload["phase"] as? String
        else {
            return .malformedPayload
        }
        guard DiagnosticEvent.TextProxyOperation(rawValue: rawOperation) != nil,
            DiagnosticEvent.TextProxyPhase(rawValue: rawPhase) != nil
        else {
            return .unknownValue
        }
        return nil
    }

    private static func validateRuntimeRoutePayload(
        _ value: Any
    ) -> DiagnosticsJournalRejectionReason? {
        if let reason = validateKeys(
            value,
            allowed: [
                "operationID", "phase", "result", "schema", "layout", "state",
                "elapsedMilliseconds",
            ],
            required: [
                "operationID", "phase", "result", "schema", "layout", "state",
                "elapsedMilliseconds",
            ]
        ) {
            return reason
        }
        guard let payload = value as? Object else { return .malformedPayload }
        if let reason = validateStringEnum(
            payload["phase"],
            as: DiagnosticEvent.RuntimeRoutePhase.self
        ) {
            return reason
        }
        if let reason = validateStringEnum(
            payload["result"],
            as: DiagnosticEvent.RuntimeRouteResult.self
        ) {
            return reason
        }
        if let reason = validateStringEnum(
            payload["schema"],
            as: DiagnosticEvent.RuntimeRouteSchema.self
        ) {
            return reason
        }
        if let reason = validateStringEnum(
            payload["layout"],
            as: DiagnosticEvent.RuntimeRouteLayout.self
        ) {
            return reason
        }
        if let reason = validateStringEnum(
            payload["state"],
            as: DiagnosticEvent.RuntimeRouteState.self
        ) {
            return reason
        }
        guard let elapsedMilliseconds = payload["elapsedMilliseconds"] as? Int,
            (0...600_000).contains(elapsedMilliseconds)
        else {
            return .malformedPayload
        }
        return nil
    }

    private static func validateRimeSyncPayload(
        _ value: Any,
        code: DiagnosticEvent.Code
    ) -> DiagnosticsJournalRejectionReason? {
        let (caseName, caseValue, caseError) = singleCase(
            value,
            allowedCases: ["invoked", "phaseChanged", "skipped", "terminal"]
        )
        if let caseError { return caseError }
        guard let caseName, let caseValue else { return .malformedPayload }
        let expectedCase: String
        let eventKeys: Set<String>
        let requiredEventKeys: Set<String>
        switch code {
        case .rimeSyncInvoked:
            expectedCase = "invoked"
            eventKeys = ["context", "requestedPhases"]
            requiredEventKeys = eventKeys
        case .rimeSyncPhaseChanged:
            expectedCase = "phaseChanged"
            eventKeys = ["context", "phase", "result"]
            requiredEventKeys = eventKeys
        case .rimeSyncSkipped:
            expectedCase = "skipped"
            eventKeys = ["context", "reason"]
            requiredEventKeys = eventKeys
        case .rimeSyncTerminal:
            expectedCase = "terminal"
            eventKeys = ["context", "result", "phase", "failure"]
            requiredEventKeys = ["context", "result"]
        default:
            return .invalidPayloadPairing
        }
        guard caseName == expectedCase else { return .invalidPayloadPairing }
        let (event, eventError) = associatedValue(caseValue)
        if let eventError { return eventError }
        guard let event else { return .malformedPayload }
        if let reason = validateKeys(event, allowed: eventKeys, required: requiredEventKeys) {
            return reason
        }
        if let reason = validateRimeSyncContext(event["context"]) {
            return reason
        }

        switch caseName {
        case "invoked":
            guard let phases = event["requestedPhases"] as? [Any] else {
                return .malformedPayload
            }
            for phase in phases {
                if let reason = validateStringEnum(phase, as: DiagnosticEvent.RimeSyncPhase.self) {
                    return reason
                }
            }
        case "phaseChanged":
            if let reason = validateStringEnum(
                event["phase"],
                as: DiagnosticEvent.RimeSyncPhase.self
            ) {
                return reason
            }
            if let reason = validateStringEnum(
                event["result"],
                as: DiagnosticEvent.RimeSyncPhaseResult.self
            ) {
                return reason
            }
        case "skipped":
            return validateStringEnum(
                event["reason"],
                as: DiagnosticEvent.RimeSyncSkipReason.self
            )
        case "terminal":
            if let reason = validateStringEnum(
                event["result"],
                as: DiagnosticEvent.RimeSyncTerminalResult.self
            ) {
                return reason
            }
            if let reason = validateOptionalStringEnum(
                event["phase"],
                as: DiagnosticEvent.RimeSyncPhase.self
            ) {
                return reason
            }
            return validateOptionalStringEnum(
                event["failure"],
                as: DiagnosticEvent.RimeSyncFailure.self
            )
        default:
            return .invalidPayloadPairing
        }
        return nil
    }

    private static func validateRimeSyncContext(
        _ value: Any?
    ) -> DiagnosticsJournalRejectionReason? {
        guard let context = value as? Object else { return .malformedPayload }
        if let reason = validateKeys(
            context,
            allowed: ["operationID", "source"],
            required: ["operationID", "source"]
        ) {
            return reason
        }
        return validateStringEnum(context["source"], as: DiagnosticEvent.RimeSyncSource.self)
    }

    private static func validateSchemeDeliveryPayload(
        _ value: Any,
        code: DiagnosticEvent.Code
    ) -> DiagnosticsJournalRejectionReason? {
        let (caseName, caseValue, caseError) = singleCase(
            value,
            allowedCases: ["phaseChanged", "integrityFailed", "fallback", "terminal"]
        )
        if let caseError { return caseError }
        guard let caseName, let caseValue else { return .malformedPayload }

        let expectedCase: String
        switch code {
        case .schemeDeliveryPhaseChanged: expectedCase = "phaseChanged"
        case .schemeDeliveryIntegrityFailed: expectedCase = "integrityFailed"
        case .schemeDeliveryFallback: expectedCase = "fallback"
        case .schemeDeliveryTerminal: expectedCase = "terminal"
        default: return .invalidPayloadPairing
        }
        guard caseName == expectedCase else { return .invalidPayloadPairing }
        let (event, eventError) = associatedValue(caseValue)
        if let eventError { return eventError }
        guard let event else { return .malformedPayload }

        let eventKeys: Set<String>
        let requiredEventKeys: Set<String>
        switch caseName {
        case "phaseChanged":
            eventKeys = ["context", "attempt", "source", "host", "phase", "result", "probeFailure"]
            requiredEventKeys = ["context", "phase", "result"]
        case "integrityFailed":
            eventKeys = ["context", "attempt", "source", "host", "phase", "observation"]
            requiredEventKeys = eventKeys
        case "fallback":
            eventKeys = [
                "context", "fromAttempt", "toAttempt", "from", "to", "fromHost", "toHost", "reason",
            ]
            requiredEventKeys = ["context", "fromAttempt", "toAttempt", "from", "to", "reason"]
        case "terminal":
            eventKeys = ["context", "result", "installed", "deployed", "failure"]
            requiredEventKeys = ["context", "result", "installed", "deployed"]
        default:
            return .malformedPayload
        }
        if let reason = validateKeys(event, allowed: eventKeys, required: requiredEventKeys) {
            return reason
        }
        if let reason = validateSchemeDeliveryContext(event["context"]) {
            return reason
        }

        switch caseName {
        case "phaseChanged":
            if let reason = validateStringEnum(
                event["phase"],
                as: DiagnosticEvent.SchemeDeliveryPhase.self
            ) {
                return reason
            }
            if let reason = validateStringEnum(
                event["result"],
                as: DiagnosticEvent.SchemeDeliveryResult.self
            ) {
                return reason
            }
            if let reason = validateOptionalStringEnum(
                event["source"],
                as: DiagnosticEvent.SchemeSource.self
            ) {
                return reason
            }
            if let reason = validateOptionalStringEnum(
                event["host"],
                as: DiagnosticEvent.SchemeHost.self
            ) {
                return reason
            }
            return validateOptionalStringEnum(
                event["probeFailure"],
                as: DiagnosticEvent.SchemeSourceProbeFailure.self
            )
        case "integrityFailed":
            if let reason = validateStringEnum(
                event["source"],
                as: DiagnosticEvent.SchemeSource.self
            ) {
                return reason
            }
            if let reason = validateStringEnum(
                event["host"],
                as: DiagnosticEvent.SchemeHost.self
            ) {
                return reason
            }
            if let reason = validateStringEnum(
                event["phase"],
                as: DiagnosticEvent.SchemeDeliveryPhase.self
            ) {
                return reason
            }
            return validateIntegrityObservation(event["observation"])
        case "fallback":
            if let reason = validateStringEnum(
                event["from"],
                as: DiagnosticEvent.SchemeSource.self
            ) {
                return reason
            }
            if let reason = validateStringEnum(
                event["to"],
                as: DiagnosticEvent.SchemeSource.self
            ) {
                return reason
            }
            if let reason = validateOptionalStringEnum(
                event["fromHost"],
                as: DiagnosticEvent.SchemeHost.self
            ) {
                return reason
            }
            if let reason = validateOptionalStringEnum(
                event["toHost"],
                as: DiagnosticEvent.SchemeHost.self
            ) {
                return reason
            }
            return validateStringEnum(
                event["reason"],
                as: DiagnosticEvent.SchemeDeliveryFallbackReason.self
            )
        case "terminal":
            if let reason = validateStringEnum(
                event["result"],
                as: DiagnosticEvent.SchemeDeliveryTerminalResult.self
            ) {
                return reason
            }
            return validateOptionalStringEnum(
                event["failure"],
                as: DiagnosticEvent.SchemeDeliveryTerminalFailure.self
            )
        default:
            return .invalidPayloadPairing
        }
    }

    private static func validateSchemeDeliveryContext(
        _ value: Any?
    ) -> DiagnosticsJournalRejectionReason? {
        guard let context = value as? Object else { return .malformedPayload }
        if let reason = validateKeys(
            context,
            allowed: ["operationID", "artifact", "stagedIdentity"],
            required: ["operationID", "artifact", "stagedIdentity"]
        ) {
            return reason
        }
        if let reason = validateStringEnum(
            context["artifact"],
            as: DiagnosticEvent.SchemeArtifactIdentity.self
        ) {
            return reason
        }
        return validateStringEnum(
            context["stagedIdentity"],
            as: DiagnosticEvent.SchemeStagedIdentity.self
        )
    }

    private static func validateIntegrityObservation(
        _ value: Any?
    ) -> DiagnosticsJournalRejectionReason? {
        let (caseName, caseValue, caseError) = singleCase(
            value,
            allowedCases: ["archiveSize", "archiveDigest", "stagedContent"]
        )
        if let caseError { return caseError }
        guard let caseName, let caseValue else { return .malformedPayload }
        guard ["archiveSize", "archiveDigest", "stagedContent"].contains(caseName) else {
            return .unknownValue
        }
        return validateKeys(caseValue, allowed: ["expected", "actual"], required: ["expected", "actual"])
    }

    private static func validateKeys(
        _ value: Any,
        allowed: Set<String>,
        required: Set<String>
    ) -> DiagnosticsJournalRejectionReason? {
        guard let object = value as? Object else { return .malformedPayload }
        let keys = Set(object.keys)
        if !keys.isSubset(of: allowed) { return .unknownKey }
        if !required.isSubset(of: keys) { return .malformedPayload }
        return nil
    }

    private static func validateStringEnum<Value: RawRepresentable>(
        _ value: Any?,
        as type: Value.Type
    ) -> DiagnosticsJournalRejectionReason? where Value.RawValue == String {
        guard let rawValue = value as? String else { return .malformedPayload }
        return Value(rawValue: rawValue) == nil ? .unknownValue : nil
    }

    private static func validateOptionalStringEnum<Value: RawRepresentable>(
        _ value: Any?,
        as type: Value.Type
    ) -> DiagnosticsJournalRejectionReason? where Value.RawValue == String {
        guard let value else { return nil }
        return validateStringEnum(value, as: type)
    }

    private static func singleCase(
        _ value: Any?,
        allowedCases: Set<String>
    ) -> (String?, Any?, DiagnosticsJournalRejectionReason?) {
        guard let value, let object = value as? Object else {
            return (nil, nil, .malformedPayload)
        }
        guard object.count == 1, let (caseName, caseValue) = object.first else {
            return (nil, nil, .malformedPayload)
        }
        guard allowedCases.contains(caseName) else { return (nil, nil, .unknownValue) }
        return (caseName, caseValue, nil)
    }

    private static func associatedValue(
        _ value: Any
    ) -> (Object?, DiagnosticsJournalRejectionReason?) {
        guard let object = value as? Object else { return (nil, .malformedPayload) }
        if let reason = validateKeys(object, allowed: ["_0"], required: ["_0"]) {
            return (nil, reason)
        }
        guard let associated = object["_0"] as? Object else { return (nil, .malformedPayload) }
        return (associated, nil)
    }
}
