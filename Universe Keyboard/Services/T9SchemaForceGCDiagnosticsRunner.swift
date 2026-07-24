import Foundation
import KeyboardCore

/// Main-App runner: inspect on-disk T9 force_gc registration and write to shared Logger.
enum T9SchemaForceGCDiagnosticsRunner {
    /// Reads App Group `Rime/shared`, builds a diagnostic, logs it (deployment category), and flushes.
    @MainActor
    @discardableResult
    static func runAndLog(
        appGroupID: String = universeAppGroupID,
        fileManager: FileManager = .default
    ) -> T9SchemaForceGCDiagnostic {
        let diagnostic = inspectOnly(appGroupID: appGroupID, fileManager: fileManager)
        log(diagnostic)
        return diagnostic
    }

    /// Apply T9 compatibility rewrite, then re-inspect and log before/after.
    @MainActor
    @discardableResult
    static func applyPatchAndLog(
        appGroupID: String = universeAppGroupID,
        fileManager: FileManager = .default
    ) -> T9SchemaForceGCDiagnostic {
        let before = inspectOnly(appGroupID: appGroupID, fileManager: fileManager)
        Logger.shared.info(
            "t9Schema force_gc applyPatch BEFORE \(before.developerSummary)",
            category: .deployment
        )

        guard
            let sharedURL = fileManager
                .containerURL(forSecurityApplicationGroupIdentifier: appGroupID)?
                .appendingPathComponent("Rime/shared", isDirectory: true)
        else {
            Logger.shared.warning("t9Schema force_gc applyPatch: App Group unavailable", category: .deployment)
            log(before)
            return before
        }

        do {
            _ = try T9DeploymentSupport.ensureCompatibleT9Schema(in: sharedURL)
            // Also clear user/build if present (librime often compiles there).
            let userURL = fileManager
                .containerURL(forSecurityApplicationGroupIdentifier: appGroupID)?
                .appendingPathComponent("Rime/user", isDirectory: true)
            let removed = T9DeploymentSupport.invalidateT9BuildProducts(
                in: sharedURL,
                userDataURL: userURL
            )
            Logger.shared.info(
                "t9Schema force_gc applyPatch: rewrite succeeded invalidatedBuild=\(removed) "
                    + "— full RIME deploy required to recompile",
                category: .deployment
            )
            // Force next explicit deploy path to recompile schemas.
            UserDefaults(suiteName: appGroupID)?.set(false, forKey: "rime_deployed")
            UserDefaults(suiteName: appGroupID)?.set(true, forKey: "rime_needs_deploy")
            UserDefaults(suiteName: appGroupID)?.synchronize()
        } catch {
            Logger.shared.warning(
                "t9Schema force_gc applyPatch failed: \(error.localizedDescription)",
                category: .deployment
            )
        }

        let after = inspectOnly(appGroupID: appGroupID, fileManager: fileManager)
        Logger.shared.info(
            "t9Schema force_gc applyPatch AFTER \(after.developerSummary)",
            category: .deployment
        )
        log(after)
        return after
    }

    @MainActor
    private static func inspectOnly(
        appGroupID: String,
        fileManager: FileManager
    ) -> T9SchemaForceGCDiagnostic {
        let container = fileManager.containerURL(forSecurityApplicationGroupIdentifier: appGroupID)
        let sharedURL = container?.appendingPathComponent("Rime/shared", isDirectory: true)
        let defaults = UserDefaults(suiteName: appGroupID)
        let layout = defaults?.string(forKey: KeyboardLayoutSettingsKey.layoutStyle)
        let t9Ready: Bool? = {
            guard let defaults else { return nil }
            if defaults.object(forKey: RimeT9Readiness.SettingsKey.legacyReady) != nil {
                return defaults.bool(forKey: RimeT9Readiness.SettingsKey.legacyReady)
            }
            return nil
        }()
        let marker: RimeT9ReadinessMarker? = {
            guard let data = defaults?.data(forKey: RimeT9Readiness.SettingsKey.marker) else { return nil }
            return try? JSONDecoder().decode(RimeT9ReadinessMarker.self, from: data)
        }()

        if container == nil {
            return T9SchemaForceGCDiagnostic(
                appGroupAvailable: false,
                layoutStyleRaw: layout,
                t9Ready: t9Ready,
                readinessCompatibilityVersion: marker?.compatibilityVersion,
                readinessFingerprintPrefix: marker.map { String($0.resourceFingerprint.prefix(12)) }
            )
        }
        let userURL = container?.appendingPathComponent("Rime/user", isDirectory: true)
        return T9SchemaForceGCInspector.inspect(
            sharedDataURL: sharedURL,
            userDataURL: userURL,
            layoutStyleRaw: layout,
            t9Ready: t9Ready,
            readinessMarker: marker,
            fileManager: fileManager
        )
    }

    @MainActor
    private static func log(_ diagnostic: T9SchemaForceGCDiagnostic) {
        Logger.shared.info(diagnostic.developerSummary, category: .deployment)
        for line in diagnostic.userFacingLines {
            Logger.shared.info("t9Schema force_gc: \(line)", category: .deployment)
        }
        Logger.shared.requestFlush()
    }
}
