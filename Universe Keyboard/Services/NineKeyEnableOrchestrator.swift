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
}
