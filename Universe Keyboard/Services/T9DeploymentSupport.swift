import Foundation
import KeyboardCore
import RimeBridge

/// Main-App-only helpers for compatible T9 schema install, verify and readiness writes.
enum T9DeploymentSupport {
    /// Writes a Universe-compatible `t9.schema.yaml` into the shared RIME directory.
    @discardableResult
    static func ensureCompatibleT9Schema(in sharedDataURL: URL) throws -> String {
        let t9URL = sharedDataURL.appendingPathComponent("t9.schema.yaml")
        guard FileManager.default.fileExists(atPath: t9URL.path),
              let existing = try? String(contentsOf: t9URL, encoding: .utf8),
              !existing.isEmpty
        else {
            throw T9DeploymentError.missingUpstreamSchema
        }

        let compatible: String
        if existing.contains("t9_processor") {
            compatible = try T9SchemaCompatibility.makeCompatibleSchema(fromUpstreamYAML: existing)
        } else {
            for snippet in T9SchemaCompatibility.requiredDigitAlgebraSnippets {
                guard existing.contains(snippet) else {
                    throw T9SchemaCompatibilityError.missingDigitAlgebra(snippet)
                }
            }
            guard existing.contains("schema_id: t9") || existing.contains("schema_id:t9") else {
                throw T9SchemaCompatibilityError.missingSchemaID
            }
            compatible = existing
        }

        try compatible.write(to: t9URL, atomically: true, encoding: .utf8)
        return compatible
    }

    static func resourceFingerprint(sharedDataURL: URL) -> String? {
        RimeT9Readiness.fingerprint(
            ofFileAt: sharedDataURL.appendingPathComponent("t9.schema.yaml")
        )
    }

    static func verifyT9Smoke(sharedDataDir: String, userDataDir: String) -> Bool {
        RimeT9SmokeProbe.verify(sharedDataDir: sharedDataDir, userDataDir: userDataDir)
    }

    static func writeMatchedReadiness(
        fingerprint: String,
        upstreamVersion: String?,
        settings: SharedSettingsStoring
    ) {
        let marker = RimeT9ReadinessMarker(
            ready: true,
            compatibilityVersion: RimeT9Readiness.currentCompatibilityVersion,
            resourceFingerprint: fingerprint,
            upstreamSchemaVersion: upstreamVersion
        )
        if let data = try? JSONEncoder().encode(marker) {
            settings.set(data, forKey: RimeT9Readiness.SettingsKey.marker)
        }
        settings.set(true, forKey: RimeT9Readiness.SettingsKey.legacyReady)
        settings.synchronize()
    }

    static func invalidateReadiness(settings: SharedSettingsStoring) {
        let cleared = RimeT9ReadinessMarker(
            ready: false,
            compatibilityVersion: RimeT9Readiness.currentCompatibilityVersion,
            resourceFingerprint: ""
        )
        if let data = try? JSONEncoder().encode(cleared) {
            settings.set(data, forKey: RimeT9Readiness.SettingsKey.marker)
        }
        settings.set(false, forKey: RimeT9Readiness.SettingsKey.legacyReady)
        settings.synchronize()
    }

    static func loadMarker(settings: SharedSettingsStoring) -> RimeT9ReadinessMarker? {
        guard let data = settings.object(forKey: RimeT9Readiness.SettingsKey.marker) as? Data else {
            return nil
        }
        return try? JSONDecoder().decode(RimeT9ReadinessMarker.self, from: data)
    }

    static func persistLayout(_ style: KeyboardLayoutStyle, settings: SharedSettingsStoring) {
        settings.set(style.rawValue, forKey: KeyboardLayoutSettingsKey.layoutStyle)
        settings.synchronize()
    }
}

enum T9DeploymentError: Error {
    case missingUpstreamSchema
}
