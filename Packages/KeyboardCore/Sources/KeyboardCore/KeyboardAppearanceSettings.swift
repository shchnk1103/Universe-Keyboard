import Foundation

public enum KeyboardAppearanceSettingsKey {
    public static let liquidGlassMaterialEnabled = "keyboard_liquid_glass_material_enabled"
}

/// Effective Liquid Glass switch. Release builds ignore any stored value.
/// Debug builds keep the stored preference. Compile-time `#if DEBUG` supplies `isDebugBuild`.
public func liquidGlassMaterialEffectivelyEnabled(storedValue: Bool, isDebugBuild: Bool) -> Bool {
    isDebugBuild && storedValue
}

/// Release startup drops a previously saved experimental flag so the key returns to unset.
/// Debug leaves the preference alone. Idempotent: a missing key is a no-op.
public func clearStoredLiquidGlassMaterialPreferenceIfRelease(
    defaults: UserDefaults,
    isDebugBuild: Bool
) {
    guard !isDebugBuild else { return }
    defaults.removeObject(forKey: KeyboardAppearanceSettingsKey.liquidGlassMaterialEnabled)
}
