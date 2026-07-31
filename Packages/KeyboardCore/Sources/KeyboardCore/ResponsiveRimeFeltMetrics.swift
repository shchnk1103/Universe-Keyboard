import Foundation

/// R5-Rem-1: content-free felt-latency markers for responsive / dual-gate paths.
///
/// Measures accept → first visible composition update and accept → engine publish,
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
        pending: Int
    ) -> String {
        "T9RESP marker=ACCEPT action=k rev=\(revision) pending=\(pending) "
            + "epoch=\(epoch) fixture=\(fixtureID)"
    }

    public static func visibleMarkerLine(
        lagMs: UInt64,
        revision: UInt64,
        source: VisibleSource
    ) -> String {
        "T9RESP marker=VISIBLE lagMs=\(lagMs) rev=\(revision) "
            + "source=\(source.rawValue) fixture=\(fixtureID)"
    }

    public static func publishLagMarkerLine(
        lagMs: UInt64,
        revision: UInt64,
        pendingAfter: Int,
        coalesced: Bool
    ) -> String {
        "T9RESP marker=PUBLISH lagMs=\(lagMs) rev=\(revision) "
            + "pendingAfter=\(pendingAfter) coalesced=\(coalesced ? "1" : "0") "
            + "fixture=\(fixtureID)"
    }

    public static func burstMarkerLine(count: Int, windowMs: UInt64) -> String {
        "T9RESP marker=BURST count=\(count) windowMs=\(windowMs) fixture=\(fixtureID)"
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
    }

    private var accepts: [UInt64: AcceptRecord] = [:]
    private var paintUptimesNs: [UInt64] = []
    private var lastVisibleRevision: UInt64 = 0
    private var lastVisibleSource: ResponsiveRimeFeltMetrics.VisibleSource?

    public init() {}

    public func reset() {
        accepts.removeAll(keepingCapacity: true)
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
        accepts[revision] = AcceptRecord(
            uptimeNs: uptimeNs,
            epoch: epoch,
            pendingAtAccept: pending
        )
        return ResponsiveRimeFeltMetrics.acceptMarkerLine(
            revision: revision,
            epoch: epoch,
            pending: pending
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
            source: source
        )
    }

    /// Engine/UI publish completion for a revision.
    @discardableResult
    public func recordPublish(
        revision: UInt64,
        pendingAfter: Int,
        coalesced: Bool,
        uptimeNs: UInt64 = DispatchTime.now().uptimeNanoseconds
    ) -> (publishLine: String, burstLine: String?) {
        let accept = accepts[revision] ?? nearestAccept(atOrBefore: revision)
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
        let publishLine = ResponsiveRimeFeltMetrics.publishLagMarkerLine(
            lagMs: lag,
            revision: revision,
            pendingAfter: pendingAfter,
            coalesced: coalesced
        )
        paintUptimesNs.append(uptimeNs)
        let window = ResponsiveRimeFeltMetrics.burstWindowNanoseconds
        paintUptimesNs.removeAll { uptimeNs &- $0 > window }
        var burstLine: String?
        if paintUptimesNs.count >= ResponsiveRimeFeltMetrics.burstCountThreshold {
            let windowMs = window / 1_000_000
            burstLine = ResponsiveRimeFeltMetrics.burstMarkerLine(
                count: paintUptimesNs.count,
                windowMs: windowMs
            )
        }
        return (publishLine, burstLine)
    }

    private func nearestAccept(atOrBefore revision: UInt64) -> AcceptRecord? {
        accepts
            .filter { $0.key <= revision }
            .max(by: { $0.key < $1.key })?
            .value
    }
}
