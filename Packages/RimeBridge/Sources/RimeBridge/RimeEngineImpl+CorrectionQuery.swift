import KeyboardCore
import RimeBridgeObjC

extension RimeEngineImpl: TypoCorrectionCandidateQuerying {
    /// Runs a bounded candidate lookup in RimeSessionManager's sidecar session.
    /// The live session remains responsible for the visible composition and selection.
    public func correctionCandidates(for input: String, limit: Int) -> [KeyboardCore.RimeCandidate] {
        correctionQueryResult(for: input, limit: limit).candidates
    }

    public func correctionQueryResult(
        for input: String,
        limit: Int
    ) -> TypoCorrectionCandidateQueryResult {
        let raw = bridge.correctionCandidates(forInput: input, limit: Int32(max(0, limit)))
        guard let result = Self.parseCorrectionQueryResult(raw) else {
            preconditionFailure("Rime correction query returned invalid finite state metadata")
        }
        return result
    }

    static func parseCorrectionQueryResult(
        _ raw: [AnyHashable: Any]
    ) -> TypoCorrectionCandidateQueryResult? {
        guard
            let readinessValue = raw[RimeKeyCorrectionQueryReadiness] as? String,
            let readiness = TypoCorrectionQueryReadiness(rawValue: readinessValue),
            let stateValue = raw[RimeKeyCorrectionQueryResultState] as? String,
            let state = TypoCorrectionQueryResultState(rawValue: stateValue)
        else { return nil }

        return TypoCorrectionCandidateQueryResult.validated(
            readiness: readiness,
            state: state,
            candidates: Self.parseCandidateWindowDictionary(raw).candidates
        )
    }
}
