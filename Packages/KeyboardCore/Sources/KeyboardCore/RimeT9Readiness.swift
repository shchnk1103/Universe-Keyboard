import CryptoKit
import Foundation

/// Versioned T9 readiness marker written only by the main App after install/deploy/verify.
public struct RimeT9ReadinessMarker: Codable, Sendable, Equatable {
    public var ready: Bool
    public var compatibilityVersion: String
    public var resourceFingerprint: String
    public var upstreamSchemaVersion: String?

    public init(
        ready: Bool,
        compatibilityVersion: String,
        resourceFingerprint: String,
        upstreamSchemaVersion: String? = nil
    ) {
        self.ready = ready
        self.compatibilityVersion = compatibilityVersion
        self.resourceFingerprint = resourceFingerprint
        self.upstreamSchemaVersion = upstreamSchemaVersion
    }
}

public enum RimeT9Readiness {
    /// Bump when compatibility patch rules or required digit algebra change.
    /// v2: strip T9 hot-path force_gc translator; re-apply after every full deploy.
    public static let currentCompatibilityVersion = "2"

    public enum SettingsKey {
        /// JSON-encoded `RimeT9ReadinessMarker` (preferred).
        public static let marker = "rime_t9_readiness_marker"
        /// Legacy single boolean — treated as unmatched without fingerprint.
        public static let legacyReady = "rime_t9_ready"
    }

    public static func load(from defaults: UserDefaults?) -> RimeT9ReadinessMarker? {
        guard let defaults else { return nil }
        if let data = defaults.data(forKey: SettingsKey.marker),
           let marker = try? JSONDecoder().decode(RimeT9ReadinessMarker.self, from: data)
        {
            return marker
        }
        // Legacy boolean alone cannot prove which resources were verified.
        return nil
    }

    public static func save(_ marker: RimeT9ReadinessMarker, to defaults: UserDefaults?) {
        guard let defaults else { return }
        if let data = try? JSONEncoder().encode(marker) {
            defaults.set(data, forKey: SettingsKey.marker)
        }
        // Keep legacy key aligned for simple diagnostics; resolver ignores it alone.
        defaults.set(marker.ready, forKey: SettingsKey.legacyReady)
    }

    public static func invalidate(in defaults: UserDefaults?) {
        guard let defaults else { return }
        let cleared = RimeT9ReadinessMarker(
            ready: false,
            compatibilityVersion: currentCompatibilityVersion,
            resourceFingerprint: ""
        )
        save(cleared, to: defaults)
    }

    /// Readiness matches only when ready, version equals current contract, and fingerprint matches on-disk resources.
    public static func isMatched(
        marker: RimeT9ReadinessMarker?,
        onDiskFingerprint: String?,
        compatibilityVersion: String = currentCompatibilityVersion
    ) -> Bool {
        guard let marker, marker.ready else { return false }
        guard marker.compatibilityVersion == compatibilityVersion else { return false }
        guard !marker.resourceFingerprint.isEmpty else { return false }
        guard let onDiskFingerprint, !onDiskFingerprint.isEmpty else { return false }
        return marker.resourceFingerprint == onDiskFingerprint
    }

    public static func fingerprint(ofCompatibleSchemaUTF8 schemaUTF8: String) -> String {
        sha256Hex(Data(schemaUTF8.utf8))
    }

    public static func fingerprint(ofFileAt url: URL) -> String? {
        guard let data = try? Data(contentsOf: url) else { return nil }
        return sha256Hex(data)
    }

    private static func sha256Hex(_ data: Data) -> String {
        SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
    }
}
