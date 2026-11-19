import Foundation
import KeyboardCore

/// Shared App Group resolution for base scheme + layout + per-scheme readiness.
public enum RimeRuntimeSelectionBridge {
    public static let appGroupID = "group.com.DoubleShy0N.Universe-Keyboard"

    /// Marker match and family-installed facts for every registered nine-key scheme.
    public struct RegisteredSnapshot: Sendable {
        public var readinessBySchema: [String: Bool]
        public var installedFamilies: Set<String>
        public var fogMarker: RimeT9ReadinessMarker?
        public var fogFingerprint: String?
    }

    /// Family installation probe. `luna_pinyin` is decided by the schema file
    /// in the shared data directory (fail closed); other families keep the
    /// App Group installed flag. Read-only: no write, cleanup or deploy.
    static func isFamilyInstalled(
        _ familyID: String,
        defaults: UserDefaults?,
        sharedURL: URL?
    ) -> Bool {
        if familyID == "luna_pinyin" {
            return sharedURL.map {
                FileManager.default.fileExists(
                    atPath: $0.appendingPathComponent("luna_pinyin.schema.yaml").path)
            } ?? false
        }
        return defaults?.bool(forKey: "\(familyID)_installed") == true
    }

    /// Reads each registry marker key and that scheme's source fingerprint.
    /// Family installation is the App Group installed flag, not the fingerprint.
    public static func registeredSnapshot(
        defaults: UserDefaults?,
        sharedDataDir: String?
    ) -> RegisteredSnapshot {
        let sharedURL = sharedDataDir.map { URL(fileURLWithPath: $0, isDirectory: true) }
        var readinessBySchema: [String: Bool] = [:]
        var installedFamilies = Set<String>()
        for scheme in NineKeySchemeRegistry.entries {
            let marker = NineKeyReadiness.load(schemaID: scheme.schemaID, defaults: defaults)
            let fingerprint = sharedURL.flatMap {
                NineKeyReadiness.fingerprint(schemaID: scheme.schemaID, sharedDirectory: $0)
            }
            readinessBySchema[scheme.schemaID] = NineKeyReadiness.isMatched(
                schemaID: scheme.schemaID,
                marker: marker,
                fingerprint: fingerprint
            )
            if isFamilyInstalled(scheme.familyID, defaults: defaults, sharedURL: sharedURL) {
                installedFamilies.insert(scheme.familyID)
            }
        }
        let fogFingerprint = sharedURL.flatMap {
            RimeT9Readiness.fingerprint(
                ofFileAt: $0.appendingPathComponent("t9.schema.yaml")
            )
        }
        return RegisteredSnapshot(
            readinessBySchema: readinessBySchema,
            installedFamilies: installedFamilies,
            fogMarker: RimeT9Readiness.load(from: defaults),
            fogFingerprint: fogFingerprint
        )
    }

    public static func resolve(
        defaults: UserDefaults? = UserDefaults(suiteName: appGroupID),
        sharedDataDir: String? = nil
    ) -> RimeRuntimeSelection {
        let snapshot = registeredSnapshot(defaults: defaults, sharedDataDir: sharedDataDir)
        return RimeRuntimeSelection.resolveRegistered(
            baseSchemaID: defaults?.string(forKey: "rime_active_schema"),
            layoutRawValue: defaults?.string(forKey: KeyboardLayoutSettingsKey.layoutStyle),
            readinessMarker: snapshot.fogMarker,
            onDiskFingerprint: snapshot.fogFingerprint,
            schemeBinding26: defaults?.string(forKey: KeyboardLayoutSettingsKey.schemeBinding26),
            schemeBinding9: defaults?.string(forKey: KeyboardLayoutSettingsKey.schemeBinding9),
            readinessBySchema: snapshot.readinessBySchema,
            installedFamilies: snapshot.installedFamilies
        )
    }
}
