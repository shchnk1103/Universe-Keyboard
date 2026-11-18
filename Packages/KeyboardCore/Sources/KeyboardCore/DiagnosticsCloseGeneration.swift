import Foundation

/// 009 S1c: advance-only diagnostics close generation.
///
/// The Settings switch publishes one commit each time diagnostics are closed. The keyboard
/// pump (never the key path) reads it before every batch take; the first read of a newer
/// generation is the keyboard's "awareness" of the close. The value is persisted in the App
/// Group so it survives a close followed by a reopen.
public enum DiagnosticsCloseGeneration {
    public static let defaultsKey = "logging_close_generation"

    /// Live read from the App Group. Returns 0 when the suite is unavailable.
    public static func liveRead() -> UInt64 {
        read(from: UserDefaults(suiteName: Logger.appGroupID))
    }

    public static func read(from defaults: UserDefaults?) -> UInt64 {
        guard let defaults, let number = defaults.object(forKey: defaultsKey) as? NSNumber else { return 0 }
        return number.uint64Value
    }

    /// Advance-only publish; returns the new generation.
    @discardableResult
    public static func publishClose(to defaults: UserDefaults?) -> UInt64 {
        guard let defaults else { return 0 }
        let next = read(from: defaults) &+ 1
        defaults.set(NSNumber(value: next), forKey: defaultsKey)
        return next
    }
}
