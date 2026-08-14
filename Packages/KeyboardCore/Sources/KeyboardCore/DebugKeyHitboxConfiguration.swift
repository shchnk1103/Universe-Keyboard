import Foundation

/// Debug-only preference for drawing the live key touch-cell snapshot.
///
/// Release builds must ignore the stored flag. The Keyboard Extension may read
/// this key only at visibility / settings-snapshot boundaries, never inside
/// `hitTest` or key handling.
public enum DebugKeyHitboxConfiguration {
    public static let enabledKey = "debug_key_hitbox_overlay_enabled"

    public static func isEnabled(in defaults: UserDefaults?, isDebugBuild: Bool) -> Bool {
        guard isDebugBuild else { return false }
        return defaults?.bool(forKey: enabledKey) ?? false
    }
}
