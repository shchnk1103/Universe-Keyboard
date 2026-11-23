import XCTest

@testable import KeyboardCore

final class KeyboardFeedbackSettingsTests: XCTestCase {

    func testFeedbackLevelClampKeepsValuesInFiveLevelRange() {
        XCTAssertEqual(KeyboardFeedbackLevel.clamped(-10), .light)
        XCTAssertEqual(KeyboardFeedbackLevel.clamped(0), .light)
        XCTAssertEqual(KeyboardFeedbackLevel.clamped(3), .normal)
        XCTAssertEqual(KeyboardFeedbackLevel.clamped(5), .heavy)
        XCTAssertEqual(KeyboardFeedbackLevel.clamped(99), .heavy)
    }

    func testLegacyContinuousValuesMigrateToNearestDiscreteLevel() {
        XCTAssertEqual(KeyboardFeedbackLevel.migratedLevel(from: 0.10), .light)
        XCTAssertEqual(KeyboardFeedbackLevel.migratedLevel(from: 0.30), .softer)
        XCTAssertEqual(KeyboardFeedbackLevel.migratedLevel(from: 0.55), .normal)
        XCTAssertEqual(KeyboardFeedbackLevel.migratedLevel(from: 0.80), .stronger)
        XCTAssertEqual(KeyboardFeedbackLevel.migratedLevel(from: 1.00), .heavy)
    }

    func testMigrationWritesHapticLevelFromLegacyValueWithoutDeletingLegacyKey() {
        let defaults = makeIsolatedDefaults()
        defaults.set(0.80, forKey: KeyboardFeedbackSettingsKey.legacyHapticIntensity)

        KeyboardFeedbackSettingsMigration.migrateLegacyLevelsIfNeeded(in: defaults)

        XCTAssertEqual(defaults.integer(forKey: KeyboardFeedbackSettingsKey.hapticLevel), KeyboardFeedbackLevel.stronger.rawValue)
        XCTAssertEqual(defaults.double(forKey: KeyboardFeedbackSettingsKey.legacyHapticIntensity), 0.80, accuracy: 0.0001)
    }

    func testMigrationDoesNotOverwriteExistingDiscreteLevels() {
        let defaults = makeIsolatedDefaults()
        defaults.set(KeyboardFeedbackLevel.light.rawValue, forKey: KeyboardFeedbackSettingsKey.hapticLevel)
        defaults.set(1.00, forKey: KeyboardFeedbackSettingsKey.legacyHapticIntensity)

        KeyboardFeedbackSettingsMigration.migrateLegacyLevelsIfNeeded(in: defaults)

        XCTAssertEqual(defaults.integer(forKey: KeyboardFeedbackSettingsKey.hapticLevel), KeyboardFeedbackLevel.light.rawValue)
    }

    func testContinuousIntensityClampsAndRoundTrips() {
        XCTAssertEqual(KeyboardFeedbackIntensity.clamped(-0.2), 0.0, accuracy: 0.0001)
        XCTAssertEqual(KeyboardFeedbackIntensity.clamped(1.4), 1.0, accuracy: 0.0001)
        XCTAssertEqual(KeyboardFeedbackIntensity.clamped(0.42), 0.42, accuracy: 0.0001)

        let defaults = makeIsolatedDefaults()
        KeyboardFeedbackSettingsStore.writeContinuousIntensity(0.42, in: defaults)
        XCTAssertEqual(KeyboardFeedbackSettingsStore.readContinuousIntensity(from: defaults), 0.42, accuracy: 0.0001)
    }

    func testContinuousReadFallsBackToLegacyHapticLevel() {
        let defaults = makeIsolatedDefaults()
        defaults.set(KeyboardFeedbackLevel.stronger.rawValue, forKey: KeyboardFeedbackSettingsKey.hapticLevel)
        XCTAssertNil(defaults.object(forKey: KeyboardFeedbackSettingsKey.hapticIntensityContinuous))
        XCTAssertEqual(
            KeyboardFeedbackSettingsStore.readContinuousIntensity(from: defaults),
            KeyboardFeedbackLevel.stronger.hapticIntensity,
            accuracy: 0.0001
        )
    }

    func testIntensityMapsToHardwareStyle() {
        XCTAssertEqual(KeyboardFeedbackIntensity.hardwareStyle(for: 0.0), .light)
        XCTAssertEqual(KeyboardFeedbackIntensity.hardwareStyle(for: 0.49), .light)
        XCTAssertEqual(KeyboardFeedbackIntensity.hardwareStyle(for: 0.5), .medium)
        XCTAssertEqual(KeyboardFeedbackIntensity.hardwareStyle(for: 0.79), .medium)
        XCTAssertEqual(KeyboardFeedbackIntensity.hardwareStyle(for: 0.8), .heavy)
        XCTAssertEqual(KeyboardFeedbackIntensity.hardwareStyle(for: 1.0), .heavy)
    }

    private func makeIsolatedDefaults() -> UserDefaults {
        let suiteName = "KeyboardFeedbackSettingsTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)
        addTeardownBlock {
            UserDefaults(suiteName: suiteName)?.removePersistentDomain(forName: suiteName)
        }
        return defaults
    }
}
