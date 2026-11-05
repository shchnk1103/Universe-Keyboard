import XCTest

@testable import KeyboardCore

final class SchemeUninstallHooksTests: XCTestCase {

    func testUninstallHooksIceOnly() {
        XCTAssertEqual(
            SchemeAdapterRegistry.uninstallHooks(for: "rime_ice").layoutFallback,
            .iceTwentySixKeyAndInvalidateReadiness
        )
        XCTAssertEqual(
            SchemeAdapterRegistry.uninstallHooks(for: "t9").layoutFallback,
            .iceTwentySixKeyAndInvalidateReadiness
        )
        XCTAssertEqual(
            SchemeAdapterRegistry.uninstallHooks(for: "wanxiang").layoutFallback,
            .wanxiangInvalidateNineKeyMarkerAndMaybeTwentySixKey
        )
        XCTAssertEqual(
            SchemeAdapterRegistry.uninstallHooks(for: "luna_pinyin").layoutFallback,
            .none
        )
        XCTAssertEqual(
            SchemeAdapterRegistry.uninstallHooks(for: "unknown_scheme").layoutFallback,
            .none
        )
        XCTAssertTrue(SchemeAdapterRegistry.hasUninstallLayoutFallback(for: "rime_ice"))
        XCTAssertTrue(SchemeAdapterRegistry.hasUninstallLayoutFallback(for: "t9"))
        XCTAssertTrue(SchemeAdapterRegistry.hasUninstallLayoutFallback(for: "wanxiang"))
        XCTAssertFalse(SchemeAdapterRegistry.hasUninstallLayoutFallback(for: "luna_pinyin"))
    }

    func testIceUninstallLayoutFallbackForcesTwentySixKeyAndInvalidatesReadiness() {
        let suite = "test.ice-uninstall-layout-fallback." + UUID().uuidString
        guard let defaults = UserDefaults(suiteName: suite) else {
            XCTFail("suite")
            return
        }
        defer { defaults.removePersistentDomain(forName: suite) }

        defaults.set(KeyboardLayoutStyle.nineKey.rawValue, forKey: KeyboardLayoutSettingsKey.layoutStyle)
        let ready = RimeT9ReadinessMarker(
            ready: true,
            compatibilityVersion: RimeT9Readiness.currentCompatibilityVersion,
            resourceFingerprint: "abc123",
            upstreamSchemaVersion: "test"
        )
        RimeT9Readiness.save(ready, to: defaults)
        XCTAssertTrue(
            RimeT9Readiness.isMatched(marker: RimeT9Readiness.load(from: defaults), onDiskFingerprint: "abc123")
        )

        IceUninstallLayoutFallback.apply(to: defaults)

        XCTAssertEqual(
            defaults.string(forKey: KeyboardLayoutSettingsKey.layoutStyle),
            KeyboardLayoutStyle.twentySixKey.rawValue
        )
        let marker = RimeT9Readiness.load(from: defaults)
        XCTAssertEqual(marker?.ready, false)
        XCTAssertEqual(marker?.resourceFingerprint, "")
        XCTAssertEqual(defaults.bool(forKey: RimeT9Readiness.SettingsKey.legacyReady), false)
        XCTAssertFalse(
            RimeT9Readiness.isMatched(marker: marker, onDiskFingerprint: "abc123")
        )
    }

    func testPrepareUninstallLayoutFallbackRoutesIceAndNoopsWanxiang() {
        let suite = "test.prepare-uninstall-layout-fallback." + UUID().uuidString
        guard let defaults = UserDefaults(suiteName: suite) else {
            XCTFail("suite")
            return
        }
        defer { defaults.removePersistentDomain(forName: suite) }

        defaults.set(KeyboardLayoutStyle.nineKey.rawValue, forKey: KeyboardLayoutSettingsKey.layoutStyle)
        RimeT9Readiness.save(
            RimeT9ReadinessMarker(
                ready: true,
                compatibilityVersion: RimeT9Readiness.currentCompatibilityVersion,
                resourceFingerprint: "fp"
            ),
            to: defaults
        )

        SchemeAdapterRegistry.prepareUninstallLayoutFallback(
            for: "wanxiang",
            set: { value, key in defaults.set(value, forKey: key) },
            synchronize: { defaults.synchronize() }
        )
        XCTAssertEqual(
            defaults.string(forKey: KeyboardLayoutSettingsKey.layoutStyle),
            KeyboardLayoutStyle.nineKey.rawValue
        )
        XCTAssertEqual(RimeT9Readiness.load(from: defaults)?.ready, true)

        SchemeAdapterRegistry.prepareUninstallLayoutFallback(
            for: "rime_ice",
            set: { value, key in defaults.set(value, forKey: key) },
            synchronize: { defaults.synchronize() }
        )
        XCTAssertEqual(
            defaults.string(forKey: KeyboardLayoutSettingsKey.layoutStyle),
            KeyboardLayoutStyle.twentySixKey.rawValue
        )
        XCTAssertEqual(RimeT9Readiness.load(from: defaults)?.ready, false)
    }

    func testWanxiangUninstallClearsFamilyMarkerAndFallsBackOnlyForWanxiangBinding() {
        let suite = "test.wanxiang-uninstall-layout-fallback." + UUID().uuidString
        guard let defaults = UserDefaults(suiteName: suite) else {
            XCTFail("suite")
            return
        }
        defer { defaults.removePersistentDomain(forName: suite) }

        let wanxiangID = NineKeySchemeRegistry.schemes(forFamily: "wanxiang")[0].schemaID
        defaults.set(KeyboardLayoutStyle.nineKey.rawValue, forKey: KeyboardLayoutSettingsKey.layoutStyle)
        defaults.set(wanxiangID, forKey: KeyboardLayoutSettingsKey.schemeBinding9)
        let fog = RimeT9ReadinessMarker(
            ready: true,
            compatibilityVersion: RimeT9Readiness.currentCompatibilityVersion,
            resourceFingerprint: "fog-fp"
        )
        RimeT9Readiness.save(fog, to: defaults)
        NineKeyReadiness.save(
            RimeT9ReadinessMarker(
                ready: true,
                compatibilityVersion: "1",
                resourceFingerprint: "wan-fp"
            ),
            schemaID: wanxiangID,
            defaults: defaults
        )

        SchemeAdapterRegistry.prepareUninstallTargetMarkerBeforeFileDeletion(
            for: "wanxiang",
            set: { value, key in defaults.set(value, forKey: key) },
            synchronize: { defaults.synchronize() },
            schemeBinding9: defaults.string(forKey: KeyboardLayoutSettingsKey.schemeBinding9)
        )

        XCTAssertEqual(
            defaults.string(forKey: KeyboardLayoutSettingsKey.layoutStyle),
            KeyboardLayoutStyle.twentySixKey.rawValue
        )
        XCTAssertEqual(NineKeyReadiness.load(schemaID: wanxiangID, defaults: defaults)?.ready, false)
        XCTAssertEqual(
            NineKeyReadiness.load(schemaID: wanxiangID, defaults: defaults)?.resourceFingerprint, ""
        )
        XCTAssertEqual(RimeT9Readiness.load(from: defaults)?.ready, true)
        XCTAssertEqual(RimeT9Readiness.load(from: defaults)?.resourceFingerprint, "fog-fp")

        defaults.set(KeyboardLayoutStyle.nineKey.rawValue, forKey: KeyboardLayoutSettingsKey.layoutStyle)
        SchemeAdapterRegistry.prepareUninstallTargetMarkerBeforeFileDeletion(
            for: "wanxiang",
            set: { value, key in defaults.set(value, forKey: key) },
            synchronize: { defaults.synchronize() },
            schemeBinding9: "t9"
        )
        XCTAssertEqual(
            defaults.string(forKey: KeyboardLayoutSettingsKey.layoutStyle),
            KeyboardLayoutStyle.nineKey.rawValue
        )
        SchemeAdapterRegistry.prepareUninstallTargetMarkerBeforeFileDeletion(
            for: "rime_ice",
            set: { value, key in defaults.set(value, forKey: key) },
            synchronize: { defaults.synchronize() },
            schemeBinding9: wanxiangID
        )
        XCTAssertEqual(RimeT9Readiness.load(from: defaults)?.resourceFingerprint, "fog-fp")
    }
}
