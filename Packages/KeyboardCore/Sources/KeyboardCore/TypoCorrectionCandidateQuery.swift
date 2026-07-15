/// Queries candidates for a corrected pinyin hypothesis without changing the user's
/// live composition. RimeBridge provides the production implementation; the adapter
/// keeps deterministic tests and the fallback engine independent from RimeBridge.
public protocol TypoCorrectionCandidateQuerying: AnyObject {
    func correctionCandidates(for input: String, limit: Int) -> [RimeCandidate]
}

public final class CandidateProviderTypoCorrectionQuery: TypoCorrectionCandidateQuerying {
    private let candidateProvider: CandidateProvider

    public init(candidateProvider: CandidateProvider) {
        self.candidateProvider = candidateProvider
    }

    public func correctionCandidates(for input: String, limit: Int) -> [RimeCandidate] {
        guard limit > 0 else { return [] }
        return candidateProvider.candidates(for: input)
            .prefix(limit)
            .map { RimeCandidate(text: $0) }
    }
}
