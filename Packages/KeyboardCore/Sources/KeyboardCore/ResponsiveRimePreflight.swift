import Foundation
import CoreFoundation

/// Dual-gate thread-affine path arming (R5-Preflight + Product Gate).
///
/// After `PD-RESPONSIVE-DEFAULT-ON-001`, ordinary builds request dual-gate by
/// default (`productGateReleaseDefaultOn`). Install remains fail-closed in the
/// Extension bootstrap. Legacy Debug/UserDefaults and compile-flag arms remain
/// for preflight tooling when Product Gate default-on is tested as `false`.
public enum ResponsiveRimePreflight: Sendable {
    /// Product Gate: ordinary builds request dual-gate without Debug-only opt-in.
    public static let productGateReleaseDefaultOn = true

    /// App Group UserDefaults key. Used for DEBUG/preflight arms when Product
    /// Gate default-on is not applied (tests may pass `productDefaultOn: false`).
    public static let dualGateKey = "uk.t9resp.preflight.dualGate"
    public static let fixtureID = "T9RESP-R5P"
    public static let markerSchemaVersion = "v1"
    public static let appGroupID = Logger.appGroupID

    #if T9_RESPONSIVE_CANARY_INTERNAL
    /// CANARY-001 keys exist only in the explicitly compiled internal artifact.
    /// They are intentionally independent: enable never implies kill-off.
    public static let canaryEnableKey = "uk.t9resp.canary.enable"
    public static let canaryKillSwitchKey = "uk.t9resp.canary.kill"
    public static let canaryExpiryKey = "uk.t9resp.canary.expiresAt"
    public static let canaryRunIDKey = "uk.t9resp.canary.runID"

    public enum CanaryConfigActor: String, Sendable {
        case app
        case `extension`
    }

    public enum CanaryConfigPhase: String, Sendable {
        case prepare
        case startup
        case kill
    }

    public enum CanaryConfigDecision: String, Sendable {
        case prepared
        case startCanary
        case baseline
        case kill
        case failClosed
    }

    public enum CanaryConfigStatus: String, Sendable {
        case success
        case failure
        case readbackMismatch
    }

    /// Content-free receipt shared by the Main-App writer and Extension reader.
    /// It intentionally has no free-text field.
    public struct CanaryConfigReceipt: Sendable, Equatable {
        public let actor: CanaryConfigActor
        public let phase: CanaryConfigPhase
        public let runID: String
        public let enable: Bool
        public let kill: Bool
        public let expiryUnixSeconds: Int64
        public let valid: Bool
        public let expiryIsFuture: Bool
        public let decision: CanaryConfigDecision
        public let status: CanaryConfigStatus

        public var markerLine: String {
            "T9RESP marker=CANARY_CONFIG schema=T9RESP-CANARY-CONFIG-v1 "
                + "actor=\(actor.rawValue) phase=\(phase.rawValue) "
                + "run=\(runID) enable=\(enable ? 1 : 0) kill=\(kill ? 1 : 0) "
                + "expiry=\(expiryUnixSeconds) valid=\(valid ? 1 : 0) "
                + "expiryState=\(expiryIsFuture ? "future" : "expired") "
                + "decision=\(decision.rawValue) status=\(status.rawValue)"
        }
    }

    public static func canaryConfiguration(
        defaults: UserDefaults?,
        bootstrapAvailable: Bool
    ) -> ResponsiveRimeCanaryConfiguration {
        guard let defaults else {
            return invalidCanaryConfiguration(bootstrapAvailable: bootstrapAvailable)
        }

        let enableValue = typedBoolean(defaults.object(forKey: canaryEnableKey))
        let killValue = typedBoolean(defaults.object(forKey: canaryKillSwitchKey))
        let expiryValue = typedUnixSeconds(defaults.object(forKey: canaryExpiryKey))
        let runID = defaults.string(forKey: canaryRunIDKey) ?? ""
        let runIDIsContentFree = isCanonicalCanaryRunID(runID)

        return ResponsiveRimeCanaryConfiguration(
            explicitEnable: enableValue ?? false,
            killSwitch: killValue ?? true,
            bootstrapAvailable: bootstrapAvailable,
            configurationValid:
                enableValue != nil
                && killValue != nil
                && expiryValue != nil
                && runIDIsContentFree,
            expiresAtUnixSeconds: TimeInterval(expiryValue ?? 0),
            runID: runID
        )
    }

    public static func isCanonicalCanaryRunID(_ runID: String) -> Bool {
        !runID.isEmpty
            && runID.count <= 64
            && runID.unicodeScalars.allSatisfy {
                let value = $0.value
                return (48...57).contains(value)
                    || (65...90).contains(value)
                    || (97...122).contains(value)
                    || value == 45
                    || value == 95
            }
    }

    /// Fail-closed cross-process prepare transaction. Kill remains asserted
    /// until the complete typed snapshot has been written and read back.
    ///
    /// `UserDefaults.synchronize()` is best-effort only: on device App Groups it
    /// may return false even when the in-process typed values are correct.
    /// Same-process gates therefore use typed memory readback; flush still runs
    /// so a later Extension reader is more likely to observe the snapshot.
    public static func prepareCanaryConfiguration(
        defaults: UserDefaults?,
        runID: String,
        expiryUnixSeconds: TimeInterval,
        nowUnixSeconds: TimeInterval
    ) -> CanaryConfigReceipt {
        guard let defaults else {
            return receipt(
                actor: .app,
                phase: .prepare,
                runID: sanitizedReceiptRunID(runID),
                enable: true,
                kill: true,
                expiryUnixSeconds: safeExpiryInteger(expiryUnixSeconds),
                nowUnixSeconds: nowUnixSeconds,
                valid: false,
                decision: .failClosed,
                status: .failure
            )
        }

        guard isCanonicalCanaryRunID(runID),
              let expiryInteger = unixSeconds(expiryUnixSeconds),
              TimeInterval(expiryInteger) > nowUnixSeconds
        else {
            return forceKillReceipt(
                defaults: defaults,
                phase: .prepare,
                runID: runID,
                fallbackExpiryUnixSeconds: expiryUnixSeconds,
                nowUnixSeconds: nowUnixSeconds,
                status: .failure
            )
        }

        writeTypedBoolean(true, forKey: canaryKillSwitchKey, defaults: defaults)
        flushDefaults(defaults)
        guard typedBoolean(defaults.object(forKey: canaryKillSwitchKey)) == true
        else {
            return forceKillReceipt(
                defaults: defaults,
                phase: .prepare,
                runID: runID,
                fallbackExpiryUnixSeconds: expiryUnixSeconds,
                nowUnixSeconds: nowUnixSeconds,
                status: .readbackMismatch
            )
        }

        defaults.set(runID, forKey: canaryRunIDKey)
        writeTypedUnixSeconds(expiryInteger, forKey: canaryExpiryKey, defaults: defaults)
        writeTypedBoolean(true, forKey: canaryEnableKey, defaults: defaults)
        flushDefaults(defaults)
        guard typedBoolean(defaults.object(forKey: canaryKillSwitchKey)) == true,
              typedBoolean(defaults.object(forKey: canaryEnableKey)) == true,
              typedUnixSeconds(defaults.object(forKey: canaryExpiryKey)) == expiryInteger,
              defaults.string(forKey: canaryRunIDKey) == runID
        else {
            return forceKillReceipt(
                defaults: defaults,
                phase: .prepare,
                runID: runID,
                fallbackExpiryUnixSeconds: expiryUnixSeconds,
                nowUnixSeconds: nowUnixSeconds,
                status: .readbackMismatch
            )
        }

        writeTypedBoolean(false, forKey: canaryKillSwitchKey, defaults: defaults)
        flushDefaults(defaults)
        guard typedBoolean(defaults.object(forKey: canaryKillSwitchKey)) == false,
              typedBoolean(defaults.object(forKey: canaryEnableKey)) == true,
              typedUnixSeconds(defaults.object(forKey: canaryExpiryKey)) == expiryInteger,
              defaults.string(forKey: canaryRunIDKey) == runID
        else {
            return forceKillReceipt(
                defaults: defaults,
                phase: .prepare,
                runID: runID,
                fallbackExpiryUnixSeconds: expiryUnixSeconds,
                nowUnixSeconds: nowUnixSeconds,
                status: .readbackMismatch
            )
        }

        return receipt(
            actor: .app,
            phase: .prepare,
            runID: runID,
            enable: true,
            kill: false,
            expiryUnixSeconds: expiryInteger,
            nowUnixSeconds: nowUnixSeconds,
            valid: true,
            decision: .prepared,
            status: .success
        )
    }

    /// The safety action writes only kill=true and reports success after typed
    /// readback. Existing run/enable/expiry values are never removed.
    public static func assertCanaryKill(
        defaults: UserDefaults?,
        runID: String,
        nowUnixSeconds: TimeInterval
    ) -> CanaryConfigReceipt {
        guard let defaults else {
            return receipt(
                actor: .app,
                phase: .kill,
                runID: sanitizedReceiptRunID(runID),
                enable: false,
                kill: true,
                expiryUnixSeconds: 0,
                nowUnixSeconds: nowUnixSeconds,
                valid: false,
                decision: .failClosed,
                status: .failure
            )
        }

        writeTypedBoolean(true, forKey: canaryKillSwitchKey, defaults: defaults)
        flushDefaults(defaults)
        let configuration = canaryConfiguration(
            defaults: defaults,
            bootstrapAvailable: true
        )
        let readbackMatches =
            typedBoolean(defaults.object(forKey: canaryKillSwitchKey)) == true
            && configuration.runID == runID
        return receipt(
            actor: .app,
            phase: .kill,
            configuration: configuration,
            nowUnixSeconds: nowUnixSeconds,
            decision: readbackMatches ? .kill : .failClosed,
            status: readbackMatches ? .success : .readbackMismatch
        )
    }

    public static func extensionConfigReceipt(
        phase: CanaryConfigPhase,
        configuration: ResponsiveRimeCanaryConfiguration,
        nowUnixSeconds: TimeInterval,
        decision: CanaryConfigDecision
    ) -> CanaryConfigReceipt {
        receipt(
            actor: .extension,
            phase: phase,
            configuration: configuration,
            nowUnixSeconds: nowUnixSeconds,
            decision: decision,
            status: .success
        )
    }

    private static func typedBoolean(_ object: Any?) -> Bool? {
        guard let number = object as? NSNumber,
              CFGetTypeID(number) == CFBooleanGetTypeID()
        else { return nil }
        return number.boolValue
    }

    private static func typedUnixSeconds(_ object: Any?) -> Int64? {
        guard let number = object as? NSNumber,
              CFGetTypeID(number) != CFBooleanGetTypeID()
        else { return nil }
        return unixSeconds(number.doubleValue)
    }

    private static func unixSeconds(_ value: TimeInterval) -> Int64? {
        guard value.isFinite,
              value >= 0,
              value < TimeInterval(Int64.max),
              value.rounded(.towardZero) == value
        else { return nil }
        return Int64(value)
    }

    /// Prefer `setBool` so App Group storage keeps CFBoolean rather than an
    /// untyped numeric stand-in that typed readback must reject.
    private static func writeTypedBoolean(
        _ value: Bool,
        forKey key: String,
        defaults: UserDefaults
    ) {
        defaults.set(value, forKey: key)
    }

    /// Persist expiry as an integer-backed number so readback does not depend
    /// on floating TimeInterval encoding.
    private static func writeTypedUnixSeconds(
        _ value: Int64,
        forKey key: String,
        defaults: UserDefaults
    ) {
        defaults.set(NSNumber(value: value), forKey: key)
    }

    /// Best-effort disk flush. Callers must not treat the return value as the
    /// prepare/kill success gate.
    @discardableResult
    private static func flushDefaults(_ defaults: UserDefaults) -> Bool {
        defaults.synchronize()
    }

    private static func forceKillReceipt(
        defaults: UserDefaults,
        phase: CanaryConfigPhase,
        runID: String,
        fallbackExpiryUnixSeconds: TimeInterval,
        nowUnixSeconds: TimeInterval,
        status: CanaryConfigStatus
    ) -> CanaryConfigReceipt {
        writeTypedBoolean(true, forKey: canaryKillSwitchKey, defaults: defaults)
        flushDefaults(defaults)
        let killReadback = typedBoolean(
            defaults.object(forKey: canaryKillSwitchKey)
        ) == true
        let enableReadback = typedBoolean(
            defaults.object(forKey: canaryEnableKey)
        ) ?? false
        let expiryReadback = typedUnixSeconds(
            defaults.object(forKey: canaryExpiryKey)
        ) ?? safeExpiryInteger(fallbackExpiryUnixSeconds)
        return receipt(
            actor: .app,
            phase: phase,
            runID: runID,
            enable: enableReadback,
            kill: killReadback,
            expiryUnixSeconds: expiryReadback,
            nowUnixSeconds: nowUnixSeconds,
            valid: false,
            decision: .failClosed,
            // Success of the safety write is typed kill readback only.
            status: killReadback ? status : .readbackMismatch
        )
    }

    private static func receipt(
        actor: CanaryConfigActor,
        phase: CanaryConfigPhase,
        configuration: ResponsiveRimeCanaryConfiguration,
        nowUnixSeconds: TimeInterval,
        decision: CanaryConfigDecision,
        status: CanaryConfigStatus
    ) -> CanaryConfigReceipt {
        receipt(
            actor: actor,
            phase: phase,
            runID: sanitizedReceiptRunID(configuration.runID),
            enable: configuration.explicitEnable,
            kill: configuration.killSwitch,
            expiryUnixSeconds: safeExpiryInteger(configuration.expiresAtUnixSeconds),
            nowUnixSeconds: nowUnixSeconds,
            valid: configuration.configurationValid,
            decision: decision,
            status: status
        )
    }

    private static func receipt(
        actor: CanaryConfigActor,
        phase: CanaryConfigPhase,
        runID: String,
        enable: Bool,
        kill: Bool,
        expiryUnixSeconds: Int64,
        nowUnixSeconds: TimeInterval,
        valid: Bool,
        decision: CanaryConfigDecision,
        status: CanaryConfigStatus
    ) -> CanaryConfigReceipt {
        CanaryConfigReceipt(
            actor: actor,
            phase: phase,
            runID: sanitizedReceiptRunID(runID),
            enable: enable,
            kill: kill,
            expiryUnixSeconds: expiryUnixSeconds,
            valid: valid,
            expiryIsFuture: TimeInterval(expiryUnixSeconds) > nowUnixSeconds,
            decision: decision,
            status: status
        )
    }

    private static func sanitizedReceiptRunID(_ runID: String) -> String {
        isCanonicalCanaryRunID(runID) ? runID : "invalid"
    }

    private static func safeExpiryInteger(_ value: TimeInterval) -> Int64 {
        unixSeconds(value) ?? 0
    }

    private static func invalidCanaryConfiguration(
        bootstrapAvailable: Bool
    ) -> ResponsiveRimeCanaryConfiguration {
        ResponsiveRimeCanaryConfiguration(
            explicitEnable: false,
            killSwitch: true,
            bootstrapAvailable: bootstrapAvailable,
            configurationValid: false,
            expiresAtUnixSeconds: 0,
            runID: ""
        )
    }

    public static func shouldTerminateActiveCanary(
        configuration: ResponsiveRimeCanaryConfiguration,
        currentRunID: String,
        nowUnixSeconds: TimeInterval
    ) -> Bool {
        configuration.killSwitch
            || !configuration.explicitEnable
            || !configuration.configurationValid
            || !configuration.bootstrapAvailable
            || !configuration.expiresAtUnixSeconds.isFinite
            || configuration.runID != currentRunID
            || nowUnixSeconds >= configuration.expiresAtUnixSeconds
    }
    #endif

    public enum PathMarker: String, Sendable {
        case sync = "sync"
        case mainActorResponsive = "mainActor-responsive"
        case threadAffine = "thread-affine"
        case fallbackMissingRuntime = "fallback-missing-runtime"
    }

    /// Pure resolution for tests and call sites.
    ///
    /// - Parameters:
    ///   - productDefaultOn: When `true` (Product Gate Release default), always
    ///     request dual-gate. Install failure still fail-closes to ADR 0004 sync.
    public static func shouldArmDualGate(
        defaults: UserDefaults?,
        isDebugBuild: Bool,
        compileFlagEnabled: Bool,
        productDefaultOn: Bool = productGateReleaseDefaultOn
    ) -> Bool {
        if productDefaultOn { return true }
        if compileFlagEnabled { return true }
        guard isDebugBuild else { return false }
        return defaults?.bool(forKey: dualGateKey) == true
    }

    public static func pathMarkerLine(
        path: PathMarker,
        dualGateRequested: Bool,
        dualGateActive: Bool,
        runToken: String? = nil
    ) -> String {
        let runField = runToken.map { "run=\($0) " } ?? ""
        return "T9RESP marker=PATH schema=\(markerSchemaVersion) \(runField)path=\(path.rawValue) fixture=\(fixtureID) "
            + "dualGateRequested=\(dualGateRequested ? "1" : "0") "
            + "dualGateActive=\(dualGateActive ? "1" : "0")"
    }

    /// Owner readiness is a separate marker so a timeout cannot be mistaken
    /// for a successful READY line. The run token is mandatory for explicit
    /// device-preflight evidence and remains content-free.
    public static func ownerReadinessMarkerLine(
        runToken: String,
        isReady: Bool,
        reason: String? = nil
    ) -> String {
        if isReady {
            return "T9RESP marker=READY schema=\(markerSchemaVersion) run=\(runToken) fixture=\(fixtureID) "
                + "bootstrap=config-only session=owner-thread"
        }
        let readinessReason = reason ?? "owner-not-ready"
        return "T9RESP marker=NOT_READY schema=\(markerSchemaVersion) run=\(runToken) fixture=\(fixtureID) "
            + "reason=\(readinessReason) bootstrap=config-only session=owner-thread"
    }

    public static func publishMarkerLine(
        epoch: UInt64,
        revision: UInt64,
        runToken: String? = nil
    ) -> String {
        let runField = runToken.map { "run=\($0) " } ?? ""
        return "T9RESP marker=PUBLISH schema=\(markerSchemaVersion) \(runField)fixture=\(fixtureID) epoch=\(epoch) rev=\(revision)"
    }

    public static func fallbackMarkerLine(
        reason: String,
        runToken: String? = nil
    ) -> String {
        // reason must remain content-free (enum-like tokens only).
        let runField = runToken.map { "run=\($0) " } ?? ""
        return "T9RESP marker=FALLBACK schema=\(markerSchemaVersion) \(runField)reason=\(reason) "
            + "fixture=\(fixtureID) dualGate=requested"
    }
}
