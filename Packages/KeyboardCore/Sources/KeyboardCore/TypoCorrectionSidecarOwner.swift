import Foundation

/// Controller-owned recall may invalidate through the installed query facade.
/// This is not a second RIME entry and does not expose a raw engine.
public protocol TypoCorrectionRecallInvalidating: AnyObject {
    func invalidateTypoCorrectionRecall()
}

/// One adapter over the already-installed correction-query facade.
///
/// `routeLocalOwnerEpoch` is an optional observation. Default `RimeEngineImpl`
/// supplies `nil`. A non-nil value may only fail a fence.
public protocol TypoCorrectionSidecarOwner: TypoCorrectionCandidateQuerying {
    @MainActor var routeLocalOwnerEpoch: UInt64? { get }
    var recallInvalidation: TypoCorrectionRecallInvalidating? { get set }
    var isTypoCorrectionRecallActive: Bool { get }
    func beginTypoCorrectionRecall()
    func endTypoCorrectionRecall()
}

/// Records which already-installed facade the sidecar owner may call. The
/// route is descriptive only: it never unwraps an engine or creates a session.
public enum TypoCorrectionSidecarRoute: String, CaseIterable, Sendable {
    case defaultMainActor
    case mainActorResponsive
    case threadAffine
}

/// Wraps the installed `TypoCorrectionCandidateQuerying` object without
/// reaching through to an underlying engine.
public final class InstalledTypoCorrectionSidecarOwner: TypoCorrectionSidecarOwner {
    private let query: TypoCorrectionCandidateQuerying
    private let routeLocalOwnerEpochProvider: @MainActor () -> UInt64?

    public let route: TypoCorrectionSidecarRoute

    public var recallInvalidation: TypoCorrectionRecallInvalidating?
    /// The MainActor coordinator owns this lifecycle. The Core hot path reads it
    /// only to avoid becoming a second writer while the coordinator is current.
    public private(set) var isTypoCorrectionRecallActive = false

    public init(
        query: TypoCorrectionCandidateQuerying,
        route: TypoCorrectionSidecarRoute = .defaultMainActor,
        routeLocalOwnerEpochProvider: @escaping @MainActor () -> UInt64? = { nil }
    ) {
        self.query = query
        self.route = route
        self.routeLocalOwnerEpochProvider = routeLocalOwnerEpochProvider
    }

    @MainActor
    public var routeLocalOwnerEpoch: UInt64? {
        routeLocalOwnerEpochProvider()
    }

    public func correctionCandidates(for input: String, limit: Int) -> [RimeCandidate] {
        query.correctionCandidates(for: input, limit: limit)
    }

    public func beginTypoCorrectionRecall() {
        isTypoCorrectionRecallActive = true
    }

    public func endTypoCorrectionRecall() {
        isTypoCorrectionRecallActive = false
    }
}
