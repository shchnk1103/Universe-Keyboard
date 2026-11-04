import Foundation
import KeyboardCore

/// Production enable orchestration for nine-key / T9.
///
/// Pure step order over injectable dependencies so unit tests exercise the real
/// transaction contract (not a hand-simulated reconstruction).
///
/// Order (ADR 0018 fail-closed):
/// 1. Preconditions (ice installed, directories)
/// 2. `beginTransaction` → force 26-key + invalidate readiness **before** asset mutation
/// 3. prepare → deploy → smoke → fingerprint
/// 4. write matched readiness, then publish nine-key **last**
enum NineKeyEnableOrchestrator {
    enum Failure: Equatable {
        case iceNotInstalled
        case directoriesUnavailable
        case prepareFailed
        case deployFailed
        case smokeFailed
        case fingerprintUnavailable
    }

    struct Directories: Equatable {
        let sharedDataURL: URL
        let userDataURL: URL
    }

    struct Dependencies {
        var iceInstalled: () -> Bool
        var resolveDirectories: () -> Directories?
        /// Must force observable 26-key and unmatched readiness.
        var beginTransaction: () -> Void
        var prepare: (URL) throws -> Void
        var deploy: () async -> Bool
        var smoke: (_ sharedDataDir: String, _ userDataDir: String) -> Bool
        var fingerprint: (URL) -> String?
        var writeMatchedReadiness: (_ fingerprint: String) -> Void
        var publishNineKey: () -> Void
    }

    /// Returns `nil` on success, or the first failure that left the system fail-closed.
    static func enable(using deps: Dependencies) async -> Failure? {
        guard deps.iceInstalled() else {
            return .iceNotInstalled
        }
        guard let directories = deps.resolveDirectories() else {
            // No asset mutation yet; keep previous state.
            return .directoriesUnavailable
        }

        // Before any operation that can alter T9/RIME assets.
        deps.beginTransaction()

        do {
            try deps.prepare(directories.sharedDataURL)
        } catch {
            return .prepareFailed
        }

        let deployed = await deps.deploy()
        guard deployed else {
            return .deployFailed
        }

        let verified = deps.smoke(
            directories.sharedDataURL.path,
            directories.userDataURL.path
        )
        guard verified else {
            return .smokeFailed
        }

        guard let fingerprint = deps.fingerprint(directories.sharedDataURL) else {
            return .fingerprintUnavailable
        }
        deps.writeMatchedReadiness(fingerprint)
        // Layout last.
        deps.publishNineKey()
        return nil
    }

    /// Parameterized enable. The legacy `enable(using:)` path is unchanged.
    ///
    /// Before the transaction starts, a missing family or directories leave state alone.
    /// The transaction invalidates only the target. Entering the shared deploy invalidates
    /// every marker. After a successful deploy each listed scheme is checked on its own.
    /// Passers are published; restore failure forces 26-key and does not publish the binding.
    struct ActiveDependencies {
        var target: NineKeyScheme
        var familyInstalled: () -> Bool
        var resolveDirectories: () -> Directories?
        var beginTargetTransaction: () -> Void
        var prepare: (URL) throws -> Void
        var invalidateAllMarkers: () -> Void
        var deploy: () async -> Bool
        var schemesToVerify: () -> [NineKeyScheme]
        var rewriteCheck: (NineKeyScheme, URL) -> Bool
        var smoke: (NineKeyScheme, String, String) -> Bool
        var fingerprint: (NineKeyScheme, URL) -> String?
        var restoreRoute: () -> Bool
        var forceTwentySix: () -> Void
        var writeMarker: (NineKeyScheme, String) -> Void
        var publishBinding: (String) -> Void
        var publishLayout: () -> Void
    }

    enum ActiveFailure: Equatable {
        case familyNotInstalled
        case directoriesUnavailable
        case prepareFailed
        case deployFailed
        case rewriteFailed(String)
        case smokeFailed(String)
        case fingerprintUnavailable(String)
        case restoreFailed
        case targetNotReady
    }

    static func enable(using deps: ActiveDependencies) async -> ActiveFailure? {
        guard deps.familyInstalled() else { return .familyNotInstalled }
        guard let directories = deps.resolveDirectories() else {
            return .directoriesUnavailable
        }

        deps.beginTargetTransaction()
        do {
            try deps.prepare(directories.sharedDataURL)
        } catch {
            return .prepareFailed
        }

        deps.invalidateAllMarkers()
        let deployed = await deps.deploy()
        guard deployed else {
            deps.forceTwentySix()
            return .deployFailed
        }

        var passed: [String: String] = [:]
        var targetFailure: ActiveFailure?
        for scheme in deps.schemesToVerify() {
            if !deps.rewriteCheck(scheme, directories.sharedDataURL) {
                if scheme.schemaID == deps.target.schemaID {
                    targetFailure = .rewriteFailed(scheme.schemaID)
                }
                continue
            }
            let smoked = deps.smoke(
                scheme,
                directories.sharedDataURL.path,
                directories.userDataURL.path
            )
            if !smoked {
                if scheme.schemaID == deps.target.schemaID {
                    targetFailure = .smokeFailed(scheme.schemaID)
                }
                continue
            }
            guard let fingerprint = deps.fingerprint(scheme, directories.sharedDataURL) else {
                if scheme.schemaID == deps.target.schemaID {
                    targetFailure = .fingerprintUnavailable(scheme.schemaID)
                }
                continue
            }
            passed[scheme.schemaID] = fingerprint
            deps.writeMarker(scheme, fingerprint)
        }

        if !deps.restoreRoute() {
            deps.forceTwentySix()
            return .restoreFailed
        }

        guard let targetFingerprint = passed[deps.target.schemaID] else {
            deps.forceTwentySix()
            return targetFailure ?? .targetNotReady
        }
        deps.writeMarker(deps.target, targetFingerprint)
        deps.publishBinding(deps.target.schemaID)
        deps.publishLayout()
        return nil
    }
}
