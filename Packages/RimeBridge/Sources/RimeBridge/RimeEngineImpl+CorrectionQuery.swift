import KeyboardCore

extension RimeEngineImpl: TypoCorrectionCandidateQuerying {
    /// Runs a bounded candidate lookup in RimeSessionManager's sidecar session.
    /// The live session remains responsible for the visible composition and selection.
    public func correctionCandidates(for input: String, limit: Int) -> [RimeCandidate] {
        let raw = bridge.correctionCandidates(forInput: input, limit: Int32(max(0, limit)))
        return Self.parseCandidateWindowDictionary(raw).candidates
    }
}
