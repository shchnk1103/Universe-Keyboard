import Foundation
import KeyboardCore
import RimeBridge

/// Main-App-only helpers for compatible T9 schema install, verify and readiness writes.
enum T9DeploymentSupport {
    /// Writes a Universe-compatible `t9.schema.yaml` into the shared RIME directory.
    ///
    /// Always rewrites through `T9SchemaCompatibility.makeCompatibleSchema` so
    /// `t9_processor` and T9-only hot-path `force_gc` translator entries are stripped
    /// even when the upstream already lacks `t9_processor`.
    ///
    /// Scope is **T9 only**: does not modify `rime_ice.schema.yaml`, other ice variants,
    /// or shared `lua/force_gc.lua`. 26-key keeps upstream force_gc behavior.
    ///
    /// Must run **after** install/deploy steps that may restore upstream `t9.schema.yaml`,
    /// not only before deploy (otherwise a later full deploy can leave force_gc in place
    /// if prepare was skipped — e.g. plain「重部署」).
    @discardableResult
    static func ensureCompatibleT9Schema(in sharedDataURL: URL) throws -> String {
        let t9URL = sharedDataURL.appendingPathComponent("t9.schema.yaml")
        guard FileManager.default.fileExists(atPath: t9URL.path),
              let existing = try? String(contentsOf: t9URL, encoding: .utf8),
              !existing.isEmpty
        else {
            throw T9DeploymentError.missingUpstreamSchema
        }

        let hadForceGC = T9SchemaForceGCInspector.forceGCTranslatorPresent(inYAML: existing)
        let compatible = try T9SchemaCompatibility.makeCompatibleSchema(fromUpstreamYAML: existing)
        try compatible.write(to: t9URL, atomically: true, encoding: .utf8)

        // Re-read to confirm the write is what diagnostics will see.
        let onDisk = (try? String(contentsOf: t9URL, encoding: .utf8)) ?? ""
        let stillHasForceGC = T9SchemaForceGCInspector.forceGCTranslatorPresent(inYAML: onDisk)
        Logger.shared.info(
            "ensureCompatibleT9Schema path=\(t9URL.lastPathComponent) "
                + "hadForceGC=\(hadForceGC) stillHasForceGC=\(stillHasForceGC) "
                + "bytes=\(onDisk.utf8.count)",
            category: .deployment
        )
        if stillHasForceGC {
            throw T9DeploymentError.forceGCStillPresentAfterRewrite
        }

        // librime runs from compiled `build/t9.schema.yaml`. Stale build keeps force_gc
        // even after source strip — drop T9 build products so the next deploy recompiles.
        let removed = invalidateT9BuildProducts(in: sharedDataURL)
        Logger.shared.info(
            "ensureCompatibleT9Schema invalidatedT9BuildProducts=\(removed)",
            category: .deployment
        )
        return compatible
    }

    /// Removes compiled T9 schema artifacts under `shared/build` (and sibling user/build if present).
    @discardableResult
    static func invalidateT9BuildProducts(
        in sharedDataURL: URL,
        userDataURL: URL? = nil,
        fileManager: FileManager = .default
    ) -> Int {
        var roots = [sharedDataURL.appendingPathComponent("build", isDirectory: true)]
        if let userDataURL {
            roots.append(userDataURL.appendingPathComponent("build", isDirectory: true))
        } else {
            // Conventional layout: …/Rime/shared and …/Rime/user
            let rimeRoot = sharedDataURL.deletingLastPathComponent()
            roots.append(rimeRoot.appendingPathComponent("user/build", isDirectory: true))
        }

        var removed = 0
        for buildDir in roots {
            guard fileManager.fileExists(atPath: buildDir.path) else { continue }
            guard let items = try? fileManager.contentsOfDirectory(
                at: buildDir,
                includingPropertiesForKeys: nil
            ) else { continue }
            for item in items where item.lastPathComponent.hasPrefix("t9.") {
                try? fileManager.removeItem(at: item)
                removed += 1
            }
        }
        return removed
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
    /// Written file still lists force_gc — strip/write failed or wrong path.
    case forceGCStillPresentAfterRewrite
}
