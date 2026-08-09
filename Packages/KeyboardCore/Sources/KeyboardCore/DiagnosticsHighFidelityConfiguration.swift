import Foundation

/// Debug-only 首屏高保真诊断的共享配置。持久化值是绝对过期时间而不是布尔值，
/// 因而主 App 或 Extension 被终止后也不会意外恢复一个永久开启的采样窗口。
public enum DiagnosticsHighFidelityConfiguration {
    public static let expirationKey = "diagnostics_high_fidelity_expiration"
    public static let duration: TimeInterval = 30 * 60

    /// Returns the shared absolute expiry without deciding whether the window is still active.
    /// Main-App notification scheduling needs this value to create one matching local reminder.
    public static func expiration(in defaults: UserDefaults?) -> Date? {
        defaults?.object(forKey: expirationKey) as? Date
    }

    public static func isEnabled(in defaults: UserDefaults?, now: Date = Date()) -> Bool {
        guard let expiration = expiration(in: defaults) else {
            return false
        }
        return expiration > now
    }
}
