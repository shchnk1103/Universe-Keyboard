/// Queries candidates for a corrected pinyin hypothesis without changing the user's
/// live composition. RimeBridge provides the production implementation; the adapter
/// keeps deterministic tests and the fallback engine independent from RimeBridge.
public protocol TypoCorrectionCandidateQuerying: AnyObject {
    func correctionCandidates(for input: String, limit: Int) -> [RimeCandidate]
    func correctionQueryResult(for input: String, limit: Int) -> TypoCorrectionCandidateQueryResult
}

public enum TypoCorrectionQueryReadiness: String, Codable, Sendable {
    case ready
    case unavailable
    case unknown
}

public enum TypoCorrectionQueryResultState: String, Codable, Sendable {
    case candidatesReturned = "candidates_returned"
    case sidecarUnavailable = "sidecar_unavailable"
    case contextUnavailable = "context_unavailable"
    case emptyInput = "empty_input"
    case zeroLimit = "zero_limit"
}

public struct TypoCorrectionFacadeDuration: Equatable, Sendable {
    public let microseconds: UInt32
    public let state: DiagnosticEvent.TypoRecallQueryDurationState

    public init(startTick: UInt64, endTick: UInt64) {
        guard endTick >= startTick else {
            microseconds = 0
            state = .clockRegression
            return
        }
        let elapsedMicroseconds = (endTick - startTick) / 1_000
        guard elapsedMicroseconds <= UInt64(UInt32.max) else {
            microseconds = UInt32.max
            state = .saturated
            return
        }
        microseconds = UInt32(elapsedMicroseconds)
        state = .measured
    }
}

/// Result of one invocation of the installed candidate-query facade.
/// `candidates` is empty when the result state says no candidate array was returned.
public struct TypoCorrectionCandidateQueryResult: Equatable, Sendable {
    public let readiness: TypoCorrectionQueryReadiness
    public let state: TypoCorrectionQueryResultState
    public let candidates: [RimeCandidate]

    public init(
        readiness: TypoCorrectionQueryReadiness,
        state: TypoCorrectionQueryResultState,
        candidates: [RimeCandidate]
    ) {
        precondition(Self.isValid(readiness: readiness, state: state, candidates: candidates))
        self.readiness = readiness
        self.state = state
        self.candidates = candidates
    }

    public var returnedCandidateArrayExists: Bool {
        state == .candidatesReturned
    }

    public static func validated(
        readiness: TypoCorrectionQueryReadiness,
        state: TypoCorrectionQueryResultState,
        candidates: [RimeCandidate]
    ) -> Self? {
        guard isValid(readiness: readiness, state: state, candidates: candidates) else { return nil }
        return Self(readiness: readiness, state: state, candidates: candidates)
    }

    private static func isValid(
        readiness: TypoCorrectionQueryReadiness,
        state: TypoCorrectionQueryResultState,
        candidates: [RimeCandidate]
    ) -> Bool {
        switch state {
        case .candidatesReturned:
            return readiness == .ready || readiness == .unknown
        case .sidecarUnavailable:
            return readiness == .unavailable && candidates.isEmpty
        case .contextUnavailable:
            return readiness == .ready && candidates.isEmpty
        case .emptyInput, .zeroLimit:
            return readiness == .unknown && candidates.isEmpty
        }
    }
}

public extension TypoCorrectionCandidateQuerying {
    /// Existing non-RIME and test facades need no second implementation path.
    /// Empty input and a nonpositive limit are classified before invoking them.
    func correctionQueryResult(for input: String, limit: Int) -> TypoCorrectionCandidateQueryResult {
        if input.isEmpty {
            return TypoCorrectionCandidateQueryResult(
                readiness: .unknown,
                state: .emptyInput,
                candidates: []
            )
        }
        if limit <= 0 {
            return TypoCorrectionCandidateQueryResult(
                readiness: .unknown,
                state: .zeroLimit,
                candidates: []
            )
        }
        return TypoCorrectionCandidateQueryResult(
            readiness: .unknown,
            state: .candidatesReturned,
            candidates: correctionCandidates(for: input, limit: limit)
        )
    }
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
