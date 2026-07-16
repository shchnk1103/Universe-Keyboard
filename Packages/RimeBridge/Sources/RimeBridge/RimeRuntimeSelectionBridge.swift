import Foundation
import KeyboardCore

/// Shared App Group resolution for base scheme + layout + T9 readiness.
enum RimeRuntimeSelectionBridge {
    static let appGroupID = "group.com.DoubleShy0N.Universe-Keyboard"

    static func resolve(
        defaults: UserDefaults? = UserDefaults(suiteName: appGroupID),
        sharedDataDir: String? = nil
    ) -> RimeRuntimeSelection {
        let fingerprint = sharedDataDir.flatMap { dir in
            let url = URL(fileURLWithPath: dir).appendingPathComponent("t9.schema.yaml")
            return RimeT9Readiness.fingerprint(ofFileAt: url)
        }
        return RimeRuntimeSelection.resolve(defaults: defaults, onDiskFingerprint: fingerprint)
    }
}
