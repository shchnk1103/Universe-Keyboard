import XCTest
@testable import Universe_Keyboard
import KeyboardCore

@MainActor
final class NineKeyEnableTransactionTests: XCTestCase {
    func testBeginTransactionForcesTwentySixKeyAndInvalidatesReadiness() {
        let suite = "uk.ninekey.tx.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }

        let settings = AppGroupSharedSettingsStoreForTests(defaults: defaults)
        // Seed matched readiness + nine key as if previously enabled.
        T9DeploymentSupport.persistLayout(.nineKey, settings: settings)
        T9DeploymentSupport.writeMatchedReadiness(
            fingerprint: "old-fp",
            upstreamVersion: "test",
            settings: settings
        )
        XCTAssertEqual(
            KeyboardLayoutStyle.resolve(settings.string(forKey: KeyboardLayoutSettingsKey.layoutStyle)),
            .nineKey
        )
        let before = T9DeploymentSupport.loadMarker(settings: settings)
        XCTAssertEqual(before?.ready, true)

        // Simulate beginNineKeyEnableTransaction without full SchemaManager.
        T9DeploymentSupport.persistLayout(.twentySixKey, settings: settings)
        T9DeploymentSupport.invalidateReadiness(settings: settings)

        XCTAssertEqual(
            KeyboardLayoutStyle.resolve(settings.string(forKey: KeyboardLayoutSettingsKey.layoutStyle)),
            .twentySixKey
        )
        let after = T9DeploymentSupport.loadMarker(settings: settings)
        XCTAssertEqual(after?.ready, false)
        XCTAssertFalse(
            RimeT9Readiness.isMatched(marker: after, onDiskFingerprint: "old-fp")
        )
    }

    func testSuccessOrderWritesReadinessBeforeNineKey() {
        let suite = "uk.ninekey.order.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }
        let settings = AppGroupSharedSettingsStoreForTests(defaults: defaults)

        // Transaction start
        T9DeploymentSupport.persistLayout(.twentySixKey, settings: settings)
        T9DeploymentSupport.invalidateReadiness(settings: settings)

        // After successful prepare/deploy/smoke (simulated):
        T9DeploymentSupport.writeMatchedReadiness(
            fingerprint: "new-fp",
            upstreamVersion: "v",
            settings: settings
        )
        // nineKey must still not be written until after readiness
        XCTAssertEqual(
            KeyboardLayoutStyle.resolve(settings.string(forKey: KeyboardLayoutSettingsKey.layoutStyle)),
            .twentySixKey
        )
        XCTAssertTrue(
            RimeT9Readiness.isMatched(
                marker: T9DeploymentSupport.loadMarker(settings: settings),
                onDiskFingerprint: "new-fp"
            )
        )

        T9DeploymentSupport.persistLayout(.nineKey, settings: settings)
        XCTAssertEqual(
            KeyboardLayoutStyle.resolve(settings.string(forKey: KeyboardLayoutSettingsKey.layoutStyle)),
            .nineKey
        )
    }
}

/// Minimal SharedSettingsStoring for transaction ordering tests.
@MainActor
final class AppGroupSharedSettingsStoreForTests: SharedSettingsStoring {
    private let defaults: UserDefaults
    init(defaults: UserDefaults) { self.defaults = defaults }
    func string(forKey key: String) -> String? { defaults.string(forKey: key) }
    func bool(forKey key: String) -> Bool { defaults.bool(forKey: key) }
    func object(forKey key: String) -> Any? { defaults.object(forKey: key) }
    func set(_ value: Any?, forKey key: String) { defaults.set(value, forKey: key) }
    func removeObject(forKey key: String) { defaults.removeObject(forKey: key) }
    func synchronize() { defaults.synchronize() }
}
