import Foundation
import Synchronization

/// Native candidate provenance. Core/UI presentation revisions are separate identities.
public struct RimeOutputOrigin: Equatable, Hashable, Sendable {
    public let ownerID: UUID
    public let sessionEpoch: UInt64
    public let revision: UInt64

    init(ownerID: UUID, sessionEpoch: UInt64, revision: UInt64) {
        self.ownerID = ownerID
        self.sessionEpoch = sessionEpoch
        self.revision = revision
    }
}

public enum RimeCandidateAuthorityRejection: Equatable, Sendable {
    case stale
    case busy
    case unavailable
}

public struct RimeCandidateWindowPermit: Equatable, Sendable {
    public let origin: RimeOutputOrigin
    let version: UInt64
}

public struct RimeBoundCandidateWindow: Equatable, Sendable {
    public let window: RimeCandidateWindow
    public let permit: RimeCandidateWindowPermit
}

public enum RimeCandidateWindowReadResult: Equatable, Sendable {
    case available(RimeBoundCandidateWindow)
    case rejected(RimeCandidateAuthorityRejection)
}

public enum RimeCandidateConsumptionDecision: Equatable, Sendable {
    case accepted
    case rejected(RimeCandidateAuthorityRejection)
}

public enum RimeBoundCandidateSelectionResult: Equatable, Sendable {
    case applied(RimeOutput)
    case rejected(RimeCandidateAuthorityRejection)
}

/// Prepared outside the authority lock; contains no UIKit objects or callbacks.
public struct RimeCandidatePresentationPage: Equatable, Sendable {
    public var items: [CandidateItem]
    public var nextIndex: Int
    public var hasMore: Bool
    public var depth: Int

    public init(items: [CandidateItem] = [], nextIndex: Int = 0, hasMore: Bool = false, depth: Int = 0) {
        self.items = items
        self.nextIndex = nextIndex
        self.hasMore = hasMore
        self.depth = depth
    }
}

/// Owned by the UI actor; the owner only commits this fixed value operation.
/// Keeping the store concrete prevents running arbitrary UI code under its mutex.
@MainActor
public final class RimeCandidatePresentationStore {
    public var page = RimeCandidatePresentationPage()
    public init() {}
}

/// Additive affine capability; ordinary synchronous engines keep RimeEngine's API.
public protocol RimeCandidateAuthorityProviding: AnyObject {
    func readCandidateWindow(origin: RimeOutputOrigin, from: Int, limit: Int) -> RimeCandidateWindowReadResult
    @MainActor func consumeCandidateWindow(
        _ window: RimeBoundCandidateWindow,
        prepared: RimeCandidatePresentationPage,
        into store: RimeCandidatePresentationStore
    ) -> RimeCandidateConsumptionDecision
    func selectCandidate(
        origin: RimeOutputOrigin, pageIndex: Int, globalIndex: Int?
    ) -> RimeBoundCandidateSelectionResult
}

/// Separate reply preserves rejection versus a successful empty final page.
final class RimeBoundCandidateWindowReply: Sendable {
    private let result = Mutex<RimeCandidateWindowReadResult?>(nil)
    private let signal = DispatchSemaphore(value: 0)

    func fulfill(_ value: RimeCandidateWindowReadResult) {
        result.withLock { $0 = value }
        signal.signal()
    }

    func wait(timeout: DispatchTime) -> RimeCandidateWindowReadResult {
        if let value = result.withLock({ $0 }) { return value }
        _ = signal.wait(timeout: timeout)
        return result.withLock { $0 } ?? .rejected(.unavailable)
    }
}
