import Foundation

/// Identities of supported nine-key schemas and their independent readiness records.
public struct NineKeyScheme: Sendable, Equatable {
    public let schemaID: String
    public let familyID: String
    public let markerKey: String
    public let compatibilityVersion: String
    public let schemaFileName: String

    public init(schemaID: String, familyID: String, markerKey: String, compatibilityVersion: String) {
        self.schemaID = schemaID
        self.familyID = familyID
        self.markerKey = markerKey
        self.compatibilityVersion = compatibilityVersion
        self.schemaFileName = "\(schemaID).schema.yaml"
    }
}

public enum NineKeySchemeRegistry {
    public static let entries: [NineKeyScheme] = [
        NineKeyScheme(
            schemaID: "t9", familyID: "rime_ice", markerKey: RimeT9Readiness.SettingsKey.marker,
            compatibilityVersion: RimeT9Readiness.currentCompatibilityVersion),
        NineKeyScheme(
            schemaID: "wanxiang_t9i", familyID: "wanxiang", markerKey: "rime_wanxiang_t9_readiness_marker",
            compatibilityVersion: "1"),
    ]

    /// Invalid registries cannot resolve any entry; callers fail closed.
    public static func isValid(_ entries: [NineKeyScheme]) -> Bool {
        let families: Set<String> = ["rime_ice", "wanxiang", "luna_pinyin"]
        let validID: (String) -> Bool = { value in
            !value.isEmpty
                && value.unicodeScalars.allSatisfy {
                    (97...122).contains($0.value) || (48...57).contains($0.value) || $0 == "_"
                }
        }
        return entries.allSatisfy {
            validID($0.schemaID) && families.contains($0.familyID)
                && !$0.markerKey.isEmpty && !$0.compatibilityVersion.isEmpty
        }
            && Set(entries.map(\.schemaID)).count == entries.count
            && Set(entries.map(\.markerKey)).count == entries.count
    }

    public static func scheme(_ schemaID: String) -> NineKeyScheme? {
        guard isValid(entries) else { return nil }
        return entries.first { $0.schemaID == schemaID }
    }

    public static func schemes(forFamily familyID: String) -> [NineKeyScheme] {
        guard isValid(entries) else { return [] }
        return entries.filter { $0.familyID == familyID }
    }
}

/// Minimal persistence seam, permitting a process-local store in tests.
public protocol NineKeySettingsStore: AnyObject {
    func data(forKey key: String) -> Data?
    func set(_ value: Any?, forKey key: String)
}

extension UserDefaults: NineKeySettingsStore {}

/// A scheme's marker uses the same matching strength as the existing fog contract.
public enum NineKeyReadiness {
    public static func load(schemaID: String, defaults: (any NineKeySettingsStore)?) -> RimeT9ReadinessMarker? {
        guard let scheme = NineKeySchemeRegistry.scheme(schemaID), let defaults,
            let data = defaults.data(forKey: scheme.markerKey)
        else { return nil }
        return try? JSONDecoder().decode(RimeT9ReadinessMarker.self, from: data)
    }

    public static func save(_ marker: RimeT9ReadinessMarker, schemaID: String, defaults: (any NineKeySettingsStore)?) {
        guard let scheme = NineKeySchemeRegistry.scheme(schemaID), let defaults else { return }
        guard let data = try? JSONEncoder().encode(marker) else { return }
        defaults.set(data, forKey: scheme.markerKey)
        if schemaID == "t9" { defaults.set(marker.ready, forKey: RimeT9Readiness.SettingsKey.legacyReady) }
    }

    public static func invalidate(schemaID: String, defaults: (any NineKeySettingsStore)?) {
        guard let scheme = NineKeySchemeRegistry.scheme(schemaID) else { return }
        save(
            RimeT9ReadinessMarker(
                ready: false, compatibilityVersion: scheme.compatibilityVersion,
                resourceFingerprint: ""), schemaID: schemaID, defaults: defaults)
    }

    public static func fingerprint(schemaID: String, sharedDirectory: URL) -> String? {
        guard let scheme = NineKeySchemeRegistry.scheme(schemaID) else { return nil }
        return RimeT9Readiness.fingerprint(ofFileAt: sharedDirectory.appendingPathComponent(scheme.schemaFileName))
    }

    public static func isMatched(schemaID: String, marker: RimeT9ReadinessMarker?, fingerprint: String?) -> Bool {
        guard let scheme = NineKeySchemeRegistry.scheme(schemaID) else { return false }
        return RimeT9Readiness.isMatched(
            marker: marker, onDiskFingerprint: fingerprint,
            compatibilityVersion: scheme.compatibilityVersion)
    }
}
