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
            if defaults?.bool(forKey: "\(scheme.familyID)_installed") == true {
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
