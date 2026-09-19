import Foundation
import KeyboardCore
import RimeBridgeObjC

extension RimeEngineImpl: TypoCorrectionCandidateQuerying, TypoCorrectionQueryDiagnosticsProviding {
    /// Runs a bounded candidate lookup in RimeSessionManager's sidecar session.
    /// The live session remains responsible for the visible composition and selection.
    public func correctionCandidates(for input: String, limit: Int) -> [KeyboardCore.RimeCandidate] {
        let raw = bridge.correctionCandidates(forInput: input, limit: Int32(max(0, limit)))
        let candidates = Self.parseCandidateWindowDictionary(raw).candidates
        #if DEBUG
            lastTypoCorrectionQueryDiagnostic = Self.parseCorrectionQueryDiagnostic(
                bridge.lastCorrectionQueryDiagnostic(),
                provenanceReceiptID: runtimeProvenance?.receiptID
            )
            if let diagnostic = lastTypoCorrectionQueryDiagnostic {
                Logger.shared.debug(
                    "TYPO-CORRECTION sidecarQuery route=real_rime_sidecar "
                        + "seq=\(diagnostic.sequence) sidecarBefore=\(diagnostic.sidecarSessionIDBefore ?? 0) "
                        + "sidecarAfter=\(diagnostic.sidecarSessionIDAfter ?? 0) "
                        + "liveBefore=\(diagnostic.liveSessionIDBefore ?? 0) "
                        + "liveAfter=\(diagnostic.liveSessionIDAfter ?? 0) "
                        + "liveValidBefore=\(diagnostic.liveSessionValidBefore ? 1 : 0) "
                        + "liveValidAfter=\(diagnostic.liveSessionValidAfter ? 1 : 0) "
                        + "schema=\(diagnostic.schemaID ?? "unknown") "
                        + "limit=\(diagnostic.limit) results=\(diagnostic.resultCount) "
                        + "outcome=\(diagnostic.outcome.rawValue) "
                        + "elapsedMs=\(diagnostic.elapsedMilliseconds) "
                        + "provenance=\(diagnostic.provenanceReceiptID?.uuidString ?? "unknown")",
                    category: .engine
                )
            }
        #else
            lastTypoCorrectionQueryDiagnostic = nil
        #endif
        return candidates
    }

    /// Decodes only the fixed diagnostic fields emitted by the ObjC sidecar.
    /// Missing or malformed identity fields fail closed to `nil`.
    static func parseCorrectionQueryDiagnostic(
        _ raw: [AnyHashable: Any]?,
        provenanceReceiptID: UUID?
    ) -> TypoCorrectionQueryDiagnostic? {
        guard let raw,
            let sequence = nonNegativeUInt64(raw[RimeKeyCorrectionQuerySequence]),
            sequence > 0,
            let inputLength = nonNegativeInt(raw[RimeKeyCorrectionQueryInputLength]),
            let limit = nonNegativeInt(raw[RimeKeyCorrectionQueryLimit]),
            let resultCount = nonNegativeInt(raw[RimeKeyCorrectionQueryResultCount]),
            let elapsedMilliseconds = nonNegativeInt(
                raw[RimeKeyCorrectionQueryElapsedMilliseconds]
            ),
            let liveSessionValidBefore = raw[RimeKeyCorrectionQueryLiveSessionValidBefore]
                as? NSNumber,
            let liveSessionValidAfter = raw[RimeKeyCorrectionQueryLiveSessionValidAfter]
                as? NSNumber,
            let outcomeValue = raw[RimeKeyCorrectionQueryOutcome] as? String,
            let outcome = TypoCorrectionQueryOutcome(rawValue: outcomeValue)
        else { return nil }

        // Do not clamp malformed observations into an apparently valid
        // evidence record. The ObjC bridge bounds normal calls; this parser
        // rejects anything outside the journal contract.
        guard (1...30).contains(inputLength),
            (1...8).contains(limit),
            (0...8).contains(resultCount),
            (0...600_000).contains(elapsedMilliseconds)
        else { return nil }

        return TypoCorrectionQueryDiagnostic(
            sequence: sequence,
            inputLength: inputLength,
            limit: limit,
            resultCount: resultCount,
            elapsedMilliseconds: elapsedMilliseconds,
            liveSessionIDBefore: optionalNonZeroUInt64(
                raw[RimeKeyCorrectionQueryLiveSessionIDBefore]
            ),
            liveSessionIDAfter: optionalNonZeroUInt64(
                raw[RimeKeyCorrectionQueryLiveSessionIDAfter]
            ),
            liveSessionValidBefore: liveSessionValidBefore.boolValue,
            liveSessionValidAfter: liveSessionValidAfter.boolValue,
            sidecarSessionIDBefore: optionalNonZeroUInt64(
                raw[RimeKeyCorrectionQuerySidecarSessionIDBefore]
            ),
            sidecarSessionIDAfter: optionalNonZeroUInt64(
                raw[RimeKeyCorrectionQuerySidecarSessionIDAfter]
            ),
            schemaID: raw[RimeKeyCorrectionQuerySchemaID] as? String,
            provenanceReceiptID: provenanceReceiptID,
            outcome: outcome
        )
    }

    private static func nonNegativeInt(_ value: Any?) -> Int? {
        guard let number = value as? NSNumber, number.int64Value >= 0,
            number.int64Value <= Int64(Int.max)
        else { return nil }
        return number.intValue
    }

    private static func nonNegativeUInt64(_ value: Any?) -> UInt64? {
        guard let number = value as? NSNumber, number.int64Value >= 0 else { return nil }
        return UInt64(number.int64Value)
    }

    private static func optionalNonZeroUInt64(_ value: Any?) -> UInt64? {
        guard let value = nonNegativeUInt64(value), value > 0 else { return nil }
        return value
    }
}
