import Foundation

/// R5-Rem-1: content-free felt-latency markers for responsive / dual-gate paths.
///
/// Measures accept → owner completion and accept → UI presentation,
/// plus pending depth / coalesce / burst signals. Never logs raw keys, pinyin,
/// candidates, or host text.
public enum ResponsiveRimeFeltMetrics: Sendable {
    public static let fixtureID = ResponsiveRimePreflight.fixtureID

    /// Pending-depth threshold at which dual-gate UI presentation prefers latest-only.
    /// Named constant only — not a product SLO.
    public static let presentationCoalescePendingThreshold = 2

    /// Burst window for counting UI applies (nanoseconds).
    public static let burstWindowNanoseconds: UInt64 = 50_000_000

    /// Minimum UI applies inside the window to emit a BURST marker.
    public static let burstCountThreshold = 3

    // MARK: - Marker lines (pure)

    public static func acceptMarkerLine(
        revision: UInt64,
        epoch: UInt64,
        pending: Int,
        runToken: String? = nil
    ) -> String {
        let runField = runToken.map { "run=\($0) " } ?? ""
        return "T9RESP marker=ACCEPT schema=\(ResponsiveRimePreflight.markerSchemaVersion) \(runField)action=k rev=\(revision) pending=\(pending) "
            + "epoch=\(epoch) fixture=\(fixtureID)"
    }

    public static func visibleMarkerLine(
        lagMs: UInt64,
        revision: UInt64,
        source: VisibleSource,
        runToken: String? = nil
    ) -> String {
        let runField = runToken.map { "run=\($0) " } ?? ""
        return "T9RESP marker=VISIBLE schema=\(ResponsiveRimePreflight.markerSchemaVersion) \(runField)lagMs=\(lagMs) rev=\(revision) "
            + "source=\(source.rawValue) fixture=\(fixtureID)"
    }

    public static func presentationLagMarkerLine(
        lagMs: UInt64,
        revision: UInt64,
        pendingAfter: Int,
        coalesced: Bool,
        runToken: String? = nil
    ) -> String {
        let runField = runToken.map { "run=\($0) " } ?? ""
        return "T9RESP marker=PAINT schema=\(ResponsiveRimePreflight.markerSchemaVersion) \(runField)lagMs=\(lagMs) rev=\(revision) "
            + "pendingAfter=\(pendingAfter) coalesced=\(coalesced ? "1" : "0") "
            + "fixture=\(fixtureID)"
    }

    public static func burstMarkerLine(
        count: Int,
        windowMs: UInt64,
        runToken: String? = nil
    ) -> String {
        let runField = runToken.map { "run=\($0) " } ?? ""
        return "T9RESP marker=BURST schema=\(ResponsiveRimePreflight.markerSchemaVersion) \(runField)count=\(count) windowMs=\(windowMs) fixture=\(fixtureID)"
    }

    public static func l1SkipMarkerLine(reason: ResponsiveProvisionalL1SkipReason) -> String {
        ResponsiveProvisionalComposition.l1SkipMarkerLine(reason: reason)
    }

    public enum VisibleSource: String, Sendable {
        case provisional
        case engine
    }

    /// Wall lag from accept uptime to now, clamped at 0.
    public static func lagMilliseconds(fromAcceptUptime acceptUptimeNs: UInt64, nowNs: UInt64) -> UInt64 {
        guard nowNs >= acceptUptimeNs else { return 0 }
        return (nowNs &- acceptUptimeNs) / 1_000_000
    }
}

/// MainActor tracker for accept timestamps and presentation burst detection.
@MainActor
public final class ResponsiveRimeFeltMetricsTracker {
    public static let shared = ResponsiveRimeFeltMetricsTracker()

    private struct AcceptRecord {
        var uptimeNs: UInt64
        var epoch: UInt64
        var pendingAtAccept: Int
        var runToken: String?
    }

    private var accepts: [UInt64: AcceptRecord] = [:]
    /// A snapshot can arrive through both the synchronous ordered path and the
    /// notification bridge. Keep owner completion evidence one-per-revision
    /// within the current engine epoch.
    private var completedOwnerRevisions: Set<UInt64> = []
    /// Revision numbers are only unique within an engine epoch. Clear the
    /// de-duplication window when a new session epoch starts so a reused
    /// revision can still produce valid owner-completion evidence.
    private var activeEpoch: UInt64?
    private var paintUptimesNs: [UInt64] = []
    private var lastVisibleRevision: UInt64 = 0
    private var lastVisibleSource: ResponsiveRimeFeltMetrics.VisibleSource?

    public init() {}

    public func reset() {
        accepts.removeAll(keepingCapacity: true)
        completedOwnerRevisions.removeAll(keepingCapacity: true)
        activeEpoch = nil
        paintUptimesNs.removeAll(keepingCapacity: true)
        lastVisibleRevision = 0
        lastVisibleSource = nil
    }

    /// Record accept and return the content-free marker line.
    @discardableResult
    public func recordAccept(
        revision: UInt64,
        epoch: UInt64,
        pending: Int,
        uptimeNs: UInt64 = DispatchTime.now().uptimeNanoseconds
    ) -> String {
        if activeEpoch != nil, activeEpoch != epoch {
            // A new session epoch invalidates every older timing/presentation
            // record. This also prevents a late snapshot from the old owner
            // thread from producing a misleading PUBLISH marker.
            accepts.removeAll(keepingCapacity: true)
            completedOwnerRevisions.removeAll(keepingCapacity: true)
            paintUptimesNs.removeAll(keepingCapacity: true)
            lastVisibleRevision = 0
            lastVisibleSource = nil
        }
        activeEpoch = epoch
        #if T9_AUTO_ANCHOR_DEVICE_PREFLIGHT
        let runToken = HotPathSegmentTiming.devicePreflightContext?.token
        #else
        let runToken: String? = nil
        #endif
        accepts[revision] = AcceptRecord(
            uptimeNs: uptimeNs,
            epoch: epoch,
            pendingAtAccept: pending,
            runToken: runToken
        )
        return ResponsiveRimeFeltMetrics.acceptMarkerLine(
            revision: revision,
            epoch: epoch,
            pending: pending,
            runToken: runToken
        )
    }

    /// Visible composition update for this revision (or nearest accept ≤ revision).
    ///
    /// Rem-3: allows a second paint at the same revision when source upgrades from
    /// provisional → engine (L2 atomic replace). Older revisions still fail closed.
    @discardableResult
    public func recordVisible(
        revision: UInt64,
        source: ResponsiveRimeFeltMetrics.VisibleSource,
        uptimeNs: UInt64 = DispatchTime.now().uptimeNanoseconds
    ) -> String? {
        // Prefer exact revision; under coalesce, match nearest accept ≤ revision.
        let accept = accepts[revision] ?? nearestAccept(atOrBefore: revision)
        guard let accept else { return nil }
        if revision < lastVisibleRevision { return nil }
        // Same revision: only allow provisional → engine upgrade (or first paint).
        if revision == lastVisibleRevision,
           lastVisibleSource == .engine
        {
            return nil
        }
        if revision == lastVisibleRevision,
           lastVisibleSource == .provisional,
           source == .provisional
        {
            return nil
        }
        lastVisibleRevision = revision
        lastVisibleSource = source
        let lag = ResponsiveRimeFeltMetrics.lagMilliseconds(
            fromAcceptUptime: accept.uptimeNs,
            nowNs: uptimeNs
        )
        return ResponsiveRimeFeltMetrics.visibleMarkerLine(
            lagMs: lag,
            revision: revision,
            source: source,
            runToken: accept.runToken
        )
    }

    /// Owner completion for a revision.
    ///
    /// This marker is intentionally separate from UI presentation. It is emitted
    /// when a snapshot produced by the serial owner reaches the controller, even
    /// if the MainActor later coalesces that snapshot and does not paint it.
    @discardableResult
    public func recordOwnerCompletion(
        epoch: UInt64,
        revision: UInt64
    ) -> String? {
        guard let accept = accepts[revision], accept.epoch == epoch else {
            return nil
        }
        guard completedOwnerRevisions.insert(revision).inserted else {
            return nil
        }
        return ResponsiveRimePreflight.publishMarkerLine(
            epoch: epoch,
            revision: revision,
            runToken: accept.runToken
        )
    }

    /// UI presentation timing for a revision.
    ///
    /// The returned `PAINT` marker is supplementary evidence. It may be
    /// coalesced and must never stand in for the owner-completion `PUBLISH`.
    @discardableResult
    public func recordPresentation(
        revision: UInt64,
        pendingAfter: Int,
        coalesced: Bool,
        uptimeNs: UInt64 = DispatchTime.now().uptimeNanoseconds
    ) -> (presentationLine: String, burstLine: String?, runToken: String?) {
        let accept = accepts[revision] ?? nearestAccept(atOrBefore: revision)
        let runToken = accept?.runToken
        let lag: UInt64
        if let accept {
            lag = ResponsiveRimeFeltMetrics.lagMilliseconds(
                fromAcceptUptime: accept.uptimeNs,
                nowNs: uptimeNs
            )
        } else {
            lag = 0
        }
        // Drop older accepts that are no longer needed.
        accepts = accepts.filter { $0.key >= revision }
        let presentationLine = ResponsiveRimeFeltMetrics.presentationLagMarkerLine(
            lagMs: lag,
            revision: revision,
            pendingAfter: pendingAfter,
            coalesced: coalesced,
            runToken: runToken
        )
        paintUptimesNs.append(uptimeNs)
        let window = ResponsiveRimeFeltMetrics.burstWindowNanoseconds
        paintUptimesNs.removeAll { uptimeNs &- $0 > window }
        var burstLine: String?
        if paintUptimesNs.count >= ResponsiveRimeFeltMetrics.burstCountThreshold {
            let windowMs = window / 1_000_000
            burstLine = ResponsiveRimeFeltMetrics.burstMarkerLine(
                count: paintUptimesNs.count,
                windowMs: windowMs,
                runToken: runToken
            )
        }
        return (presentationLine, burstLine, runToken)
    }

    private func nearestAccept(atOrBefore revision: UInt64) -> AcceptRecord? {
        accepts
            .filter { $0.key <= revision }
            .max(by: { $0.key < $1.key })?
            .value
    }
}
