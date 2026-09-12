import Foundation

/// Ice-reference uninstall layout-fallback kind (P1-5).
///
/// Full Discovery Section A/B productization is a later Assignment — this enum
/// only names today’s Ice hook semantics (`prepareRimeIceUninstallWithLayoutFallback`).
public enum SchemeUninstallLayoutFallbackKind: String, Sendable, Equatable {
    /// Ice today: persist 26-key layout + invalidate T9 readiness marker.
    case iceTwentySixKeyAndInvalidateReadiness
    /// No uninstall layout-fallback hook (Wanxiang / Luna / unknown).
    case none
}

/// Declarative uninstall-hook capability on a scheme adapter (P1-5).
public struct SchemeUninstallHooks: Sendable, Equatable {
    public let layoutFallback: SchemeUninstallLayoutFallbackKind

    public init(layoutFallback: SchemeUninstallLayoutFallbackKind) {
        self.layoutFallback = layoutFallback
    }

    public static let ice = SchemeUninstallHooks(
        layoutFallback: .iceTwentySixKeyAndInvalidateReadiness
    )
    public static let none = SchemeUninstallHooks(layoutFallback: .none)
}

/// Applies Ice’s current uninstall layout-fallback preference mutations.
///
/// Order matches `T9DeploymentSupport.persistLayout(.twentySixKey)` then
/// `invalidateReadiness` — behavior unchanged under automation.
public enum IceUninstallLayoutFallback {
    /// Apply Ice-today semantics via preference set/synchronize closures.
    ///
    /// Used by App `SharedSettingsStoring` and KeyboardCore unit tests alike.
    public static func apply(
        set: (Any?, String) -> Void,
        synchronize: () -> Void
    ) {
        set(
            KeyboardLayoutStyle.twentySixKey.rawValue,
            KeyboardLayoutSettingsKey.layoutStyle
        )
        let cleared = RimeT9ReadinessMarker(
            ready: false,
            compatibilityVersion: RimeT9Readiness.currentCompatibilityVersion,
            resourceFingerprint: ""
        )
        if let data = try? JSONEncoder().encode(cleared) {
            set(data, RimeT9Readiness.SettingsKey.marker)
        }
        set(false, RimeT9Readiness.SettingsKey.legacyReady)
        synchronize()
    }

    /// Convenience for `UserDefaults` (KeyboardCore tests / Extension-safe sinks).
    public static func apply(to defaults: UserDefaults) {
        apply(
            set: { value, key in defaults.set(value, forKey: key) },
            synchronize: { defaults.synchronize() }
        )
    }
}

extension SchemeAdapterRegistry {
    /// Uninstall hooks for known adapters (Ice layout fallback only in P1-5).
    public static func uninstallHooks(for schemaID: String) -> SchemeUninstallHooks {
        guard let adapter = adapter(for: schemaID) else { return .none }
        switch adapter.schemaID {
        case "rime_ice":
            return .ice
        default:
            return .none
        }
    }

    /// Whether `onUninstallPrepare` should run Ice layout-fallback semantics.
    public static func hasUninstallLayoutFallback(for schemaID: String) -> Bool {
        uninstallHooks(for: schemaID).layoutFallback
            != .none
    }

    /// Platform `onUninstallPrepare` — Ice still applies today’s layout fallback;
    /// other schemes are no-ops. Does **not** implement Discovery A-only picker UI.
    public static func prepareUninstallLayoutFallback(
        for schemaID: String,
        set: (Any?, String) -> Void,
        synchronize: () -> Void
    ) {
        switch uninstallHooks(for: schemaID).layoutFallback {
        case .iceTwentySixKeyAndInvalidateReadiness:
            IceUninstallLayoutFallback.apply(set: set, synchronize: synchronize)
        case .none:
            return
        }
    }
}
