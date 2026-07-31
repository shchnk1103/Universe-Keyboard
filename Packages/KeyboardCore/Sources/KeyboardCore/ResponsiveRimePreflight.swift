import Foundation

/// R5-Preflight: Debug/internal arming for dual-gate thread-affine path.
///
/// Release builds never arm from UserDefaults. DEBUG (or an explicit compile
/// flag) may arm via App Group key or `T9_RESPONSIVE_DEVICE_PREFLIGHT_ENABLED`.
public enum ResponsiveRimePreflight: Sendable {
    /// App Group UserDefaults key. `true` requests dual-gate on DEBUG/preflight arms only.
    public static let dualGateKey = "uk.t9resp.preflight.dualGate"
    public static let fixtureID = "T9RESP-R5P"
    public static let appGroupID = Logger.appGroupID

    public enum PathMarker: String, Sendable {
        case sync = "sync"
        case mainActorResponsive = "mainActor-responsive"
        case threadAffine = "thread-affine"
        case fallbackMissingRuntime = "fallback-missing-runtime"
    }

    /// Pure resolution for tests and call sites.
    public static func shouldArmDualGate(
        defaults: UserDefaults?,
        isDebugBuild: Bool,
        compileFlagEnabled: Bool
    ) -> Bool {
        if compileFlagEnabled { return true }
        guard isDebugBuild else { return false }
        return defaults?.bool(forKey: dualGateKey) == true
    }

    public static func pathMarkerLine(
        path: PathMarker,
        dualGateRequested: Bool,
        dualGateActive: Bool
    ) -> String {
        "T9RESP marker=PATH path=\(path.rawValue) fixture=\(fixtureID) "
            + "dualGateRequested=\(dualGateRequested ? "1" : "0") "
            + "dualGateActive=\(dualGateActive ? "1" : "0")"
    }

    public static func publishMarkerLine(epoch: UInt64, revision: UInt64) -> String {
        "T9RESP marker=PUBLISH fixture=\(fixtureID) epoch=\(epoch) rev=\(revision)"
    }

    public static func fallbackMarkerLine(reason: String) -> String {
        // reason must remain content-free (enum-like tokens only).
        "T9RESP marker=FALLBACK reason=\(reason) fixture=\(fixtureID) dualGate=requested"
    }
}
