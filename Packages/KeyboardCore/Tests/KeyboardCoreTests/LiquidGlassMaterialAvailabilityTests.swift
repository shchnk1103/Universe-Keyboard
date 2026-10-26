import XCTest

@testable import KeyboardCore

final class LiquidGlassMaterialAvailabilityTests: XCTestCase {
    func testDebugKeepsStoredValue() {
        XCTAssertTrue(liquidGlassMaterialEffectivelyEnabled(storedValue: true, isDebugBuild: true))
        XCTAssertFalse(liquidGlassMaterialEffectivelyEnabled(storedValue: false, isDebugBuild: true))
    }

    func testReleaseIgnoresStoredValue() {
        XCTAssertFalse(liquidGlassMaterialEffectivelyEnabled(storedValue: true, isDebugBuild: false))
        XCTAssertFalse(liquidGlassMaterialEffectivelyEnabled(storedValue: false, isDebugBuild: false))
    }

    func testReleaseClearRemovesOnlyTheLiquidGlassKey() {
        let suite = "liquid-glass-clear-\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }

        let otherKey = "keyboard_unrelated_setting"
        defaults.set(true, forKey: KeyboardAppearanceSettingsKey.liquidGlassMaterialEnabled)
        defaults.set("kept", forKey: otherKey)

        clearStoredLiquidGlassMaterialPreferenceIfRelease(defaults: defaults, isDebugBuild: false)

        XCTAssertNil(defaults.object(forKey: KeyboardAppearanceSettingsKey.liquidGlassMaterialEnabled))
        XCTAssertEqual(defaults.string(forKey: otherKey), "kept")

        clearStoredLiquidGlassMaterialPreferenceIfRelease(defaults: defaults, isDebugBuild: false)
        XCTAssertNil(defaults.object(forKey: KeyboardAppearanceSettingsKey.liquidGlassMaterialEnabled))
        XCTAssertEqual(defaults.string(forKey: otherKey), "kept")
    }

    func testDebugClearLeavesStoredValue() {
        let suite = "liquid-glass-debug-keep-\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }

        defaults.set(true, forKey: KeyboardAppearanceSettingsKey.liquidGlassMaterialEnabled)
        clearStoredLiquidGlassMaterialPreferenceIfRelease(defaults: defaults, isDebugBuild: true)
        XCTAssertEqual(
            defaults.bool(forKey: KeyboardAppearanceSettingsKey.liquidGlassMaterialEnabled),
            true
        )
    }
}
