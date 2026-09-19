import Foundation

/// Finite routes used by the typo-correction query seam.
public enum TypoCorrectionQueryRoute: String, Codable, Equatable, Sendable {
    case realRimeSidecar = "real_rime_sidecar"
    case providerAdapter = "provider_adapter"
    case unavailable
}

/// Finite outcomes emitted by a real sidecar query.
public enum TypoCorrectionQueryOutcome: String, Codable, Equatable, Sendable {
    case returned
    case emptyInput = "empty_input"
    case invalidLimit = "invalid_limit"
    case unavailable
    case contextUnavailable = "context_unavailable"
}

/// Content-free observation of one bounded typo-correction query.
///
/// The input and candidate text are deliberately absent. Length, counts,
/// session identities, schema identity, timing, and the deployment receipt ID
/// are sufficient to correlate a sidecar call with provenance and isolation
/// evidence without persisting typed content.
public struct TypoCorrectionQueryDiagnostic: Codable, Equatable, Sendable {
    public let route: TypoCorrectionQueryRoute
    public let sequence: UInt64
    public let inputLength: Int
    public let limit: Int
    public let resultCount: Int
    public let elapsedMilliseconds: Int
    public let liveSessionIDBefore: UInt64?
    public let liveSessionIDAfter: UInt64?
    public let liveSessionValidBefore: Bool
    public let liveSessionValidAfter: Bool
    public let sidecarSessionIDBefore: UInt64?
    public let sidecarSessionIDAfter: UInt64?
    public let schemaID: String?
    public let provenanceReceiptID: UUID?
    public let outcome: TypoCorrectionQueryOutcome

    public init(
        route: TypoCorrectionQueryRoute = .realRimeSidecar,
        sequence: UInt64,
        inputLength: Int,
        limit: Int,
        resultCount: Int,
        elapsedMilliseconds: Int,
        liveSessionIDBefore: UInt64?,
        liveSessionIDAfter: UInt64?,
        liveSessionValidBefore: Bool,
        liveSessionValidAfter: Bool,
        sidecarSessionIDBefore: UInt64?,
        sidecarSessionIDAfter: UInt64?,
        schemaID: String?,
        provenanceReceiptID: UUID?,
        outcome: TypoCorrectionQueryOutcome
    ) {
        self.route = route
        self.sequence = sequence
        self.inputLength = max(0, inputLength)
        self.limit = max(0, limit)
        self.resultCount = max(0, resultCount)
        self.elapsedMilliseconds = max(0, elapsedMilliseconds)
        self.liveSessionIDBefore = liveSessionIDBefore
        self.liveSessionIDAfter = liveSessionIDAfter
        self.liveSessionValidBefore = liveSessionValidBefore
        self.liveSessionValidAfter = liveSessionValidAfter
        self.sidecarSessionIDBefore = sidecarSessionIDBefore
        self.sidecarSessionIDAfter = sidecarSessionIDAfter
        self.schemaID = schemaID
        self.provenanceReceiptID = provenanceReceiptID
        self.outcome = outcome
    }
}
