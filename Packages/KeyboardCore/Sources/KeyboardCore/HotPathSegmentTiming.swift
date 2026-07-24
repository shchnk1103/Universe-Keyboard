import Foundation

#if DEBUG
/// DEBUG-only wall-time segments for one synthetic key on continuous T9 typing.
///
/// Purpose: attribute per-key latency by raw length into:
/// - `rime`: bridge `processKey` / collectOutput
/// - `pathLocal`: local Path catalog rebuild / focus retain
/// - `preedit`: visible preedit resolve + host marked-text update
/// - `pathUI` / `candidateUI`: Path Bar and candidate bar presentation
///
/// Does not change product control flow. Never logs composition text—only lengths
/// and path/candidate counts. Inactive until `beginKey` for the current event.
///
/// Keyboard input runs on the main actor; state is MainActor-isolated.
@MainActor
public enum HotPathSegmentTiming {
    public enum Segment: String, CaseIterable, Sendable {
        case rime
        case pathLocal
        case preedit
        case pathUI
        case candidateUI
    }

    private static var isActive = false
    private static var eventID: UInt64 = 0
    private static var keyLength = 0
    private static var compositionLengthBefore = 0
    private static var rawLengthAfter = 0
    private static var pathCount = 0
    private static var candidateCount = 0
    private static var segments: [Segment: Double] = [:]

    /// Start a sample for one digit/key event. Nested `beginKey` replaces the prior sample.
    public static func beginKey(
        eventID: UInt64,
        keyLength: Int,
        compositionLengthBefore: Int
    ) {
        isActive = true
        self.eventID = eventID
        self.keyLength = keyLength
        self.compositionLengthBefore = compositionLengthBefore
        rawLengthAfter = 0
        pathCount = 0
        candidateCount = 0
        segments.removeAll(keepingCapacity: true)
    }

    /// Accumulate wall time for `segment` while running `body`. No-op when inactive.
    @discardableResult
    public static func measure<T>(_ segment: Segment, _ body: () throws -> T) rethrows -> T {
        guard isActive else { return try body() }
        let start = CFAbsoluteTimeGetCurrent()
        defer {
            let ms = (CFAbsoluteTimeGetCurrent() - start) * 1000
            segments[segment, default: 0] += ms
        }
        return try body()
    }

    /// Record privacy-safe result sizes after Core handle completes.
    public static func noteResult(
        rawLength: Int,
        pathCount: Int,
        candidateCount: Int
    ) {
        guard isActive else { return }
        rawLengthAfter = rawLength
        self.pathCount = pathCount
        self.candidateCount = candidateCount
    }

    /// Emit one line and clear the sample. Safe if `beginKey` was never called.
    public static func endKey(
        totalMs: Double,
        engineMs: Double,
        uiMs: Double
    ) {
        guard isActive else { return }
        isActive = false

        func fmt(_ segment: Segment) -> String {
            String(format: "%.1f", segments[segment, default: 0])
        }
        let accounted =
            (segments[.rime] ?? 0)
            + (segments[.pathLocal] ?? 0)
            + (segments[.preedit] ?? 0)
            + (segments[.pathUI] ?? 0)
            + (segments[.candidateUI] ?? 0)
        let unaccounted = max(0, totalMs - accounted)

        Logger.shared.performance(
            "T9SEG #\(eventID) keyLen=\(keyLength) compBefore=\(compositionLengthBefore) "
                + "rawLen=\(rawLengthAfter) paths=\(pathCount) cands=\(candidateCount) "
                + "total=\(String(format: "%.1f", totalMs)) "
                + "engine=\(String(format: "%.1f", engineMs)) ui=\(String(format: "%.1f", uiMs)) "
                + "rime=\(fmt(.rime)) pathLocal=\(fmt(.pathLocal)) preedit=\(fmt(.preedit)) "
                + "pathUI=\(fmt(.pathUI)) candUI=\(fmt(.candidateUI)) "
                + "unaccounted=\(String(format: "%.1f", unaccounted))"
        )

        if totalMs >= 50 {
            Logger.shared.warning(
                "SLOW T9SEG #\(eventID) rawLen=\(rawLengthAfter) total=\(String(format: "%.1f", totalMs)) "
                    + "rime=\(fmt(.rime)) pathLocal=\(fmt(.pathLocal)) preedit=\(fmt(.preedit)) "
                    + "pathUI=\(fmt(.pathUI)) candUI=\(fmt(.candidateUI))",
                category: .performance
            )
        }

        segments.removeAll(keepingCapacity: true)
    }

    public static func cancel() {
        isActive = false
        segments.removeAll(keepingCapacity: true)
    }
}
#endif
