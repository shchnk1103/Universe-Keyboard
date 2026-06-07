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

    func testMigrationWritesLevelsFromLegacyValuesWithoutDeletingLegacyKeys() {
        let defaults = makeIsolatedDefaults()
        defaults.set(0.30, forKey: KeyboardFeedbackSettingsKey.legacyKeyClickVolume)
        defaults.set(0.80, forKey: KeyboardFeedbackSettingsKey.legacyHapticIntensity)

        KeyboardFeedbackSettingsMigration.migrateLegacyLevelsIfNeeded(in: defaults)

        XCTAssertEqual(defaults.integer(forKey: KeyboardFeedbackSettingsKey.keyClickLevel), KeyboardFeedbackLevel.softer.rawValue)
        XCTAssertEqual(defaults.integer(forKey: KeyboardFeedbackSettingsKey.hapticLevel), KeyboardFeedbackLevel.stronger.rawValue)
        XCTAssertEqual(defaults.double(forKey: KeyboardFeedbackSettingsKey.legacyKeyClickVolume), 0.30, accuracy: 0.0001)
        XCTAssertEqual(defaults.double(forKey: KeyboardFeedbackSettingsKey.legacyHapticIntensity), 0.80, accuracy: 0.0001)
    }

    func testMigrationDoesNotOverwriteExistingDiscreteLevels() {
        let defaults = makeIsolatedDefaults()
        defaults.set(KeyboardFeedbackLevel.heavy.rawValue, forKey: KeyboardFeedbackSettingsKey.keyClickLevel)
        defaults.set(KeyboardFeedbackLevel.light.rawValue, forKey: KeyboardFeedbackSettingsKey.hapticLevel)
        defaults.set(0.10, forKey: KeyboardFeedbackSettingsKey.legacyKeyClickVolume)
        defaults.set(1.00, forKey: KeyboardFeedbackSettingsKey.legacyHapticIntensity)

        KeyboardFeedbackSettingsMigration.migrateLegacyLevelsIfNeeded(in: defaults)

        XCTAssertEqual(defaults.integer(forKey: KeyboardFeedbackSettingsKey.keyClickLevel), KeyboardFeedbackLevel.heavy.rawValue)
        XCTAssertEqual(defaults.integer(forKey: KeyboardFeedbackSettingsKey.hapticLevel), KeyboardFeedbackLevel.light.rawValue)
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
