import XCTest
@testable import KeyboardCore

final class LayoutBoundRimeRuntimeSelectionTests: XCTestCase {

    func testLegacyInitStillAutoSelectsT9() {
        let selection = RimeRuntimeSelection(
            baseSchemaID: "rime_ice",
            layoutStyle: .nineKey,
            t9ReadinessMatched: true
        )
        XCTAssertEqual(selection.effectiveSchemaID, "t9")
        XCTAssertEqual(selection.effectiveLayoutStyle, .nineKey)
        XCTAssertTrue(selection.usesT9InputSemantics)
    }

    func testLayoutBoundNineKeyUsesT9BindingWhenReady() {
        let selection = RimeRuntimeSelection(
            baseSchemaID: "luna_pinyin",
            layoutStyle: .nineKey,
            t9ReadinessMatched: true,
            schemeBinding26: "luna_pinyin",
            schemeBinding9: "t9"
        )
        XCTAssertEqual(selection.effectiveSchemaID, "t9")
        XCTAssertEqual(selection.effectiveLayoutStyle, .nineKey)
        XCTAssertTrue(selection.usesT9InputSemantics)
    }

    func testLayoutBoundAllowsWanxiang26WhileNineKeyIsT9() {
        let selection = RimeRuntimeSelection(
            baseSchemaID: "wanxiang",
            layoutStyle: .twentySixKey,
            t9ReadinessMatched: true,
            schemeBinding26: "wanxiang",
            schemeBinding9: "t9"
        )
        XCTAssertEqual(selection.effectiveSchemaID, "wanxiang")
        XCTAssertEqual(selection.effectiveLayoutStyle, .twentySixKey)
        XCTAssertFalse(selection.usesT9InputSemantics)
    }

    /// 26-key slot may be 万象 while layout preference is nine-key → fog T9 chrome.
    func testWanxiang26BindingDoesNotBlockNineKeyLayoutWhenT9Ready() {
        let selection = RimeRuntimeSelection(
            baseSchemaID: "wanxiang",
            layoutStyle: .nineKey,
            t9ReadinessMatched: true,
            schemeBinding26: "wanxiang",
            schemeBinding9: "t9"
        )
        XCTAssertEqual(selection.effectiveSchemaID, "t9")
        XCTAssertEqual(selection.effectiveLayoutStyle, .nineKey)
        XCTAssertTrue(selection.usesT9InputSemantics)
    }

    /// Missing binding9 still defaults to t9 when readiness matches (heal incomplete migration).
    func testNineKeyDefaultsBinding9ToT9WhenOmittedButReady() {
        let selection = RimeRuntimeSelection(
            baseSchemaID: "wanxiang",
            layoutStyle: .nineKey,
            t9ReadinessMatched: true,
            schemeBinding26: "wanxiang",
            schemeBinding9: nil
        )
        XCTAssertEqual(selection.effectiveSchemaID, "t9")
        XCTAssertTrue(selection.usesT9InputSemantics)
    }

    /// Legacy resolve path (no bindings): wanxiang base cannot drive T9 — documents why Extension must pass bindings.
    func testLegacyPathWithWanxiangBaseFailsClosedOnNineKey() {
        let selection = RimeRuntimeSelection(
            baseSchemaID: "wanxiang",
            layoutStyle: .nineKey,
            t9ReadinessMatched: true
        )
        XCTAssertEqual(selection.effectiveLayoutStyle, .twentySixKey)
        XCTAssertFalse(selection.usesT9InputSemantics)
        XCTAssertEqual(selection.effectiveSchemaID, "wanxiang")
    }

    func testNineKeyFailsClosedWithoutReadiness() {
        let selection = RimeRuntimeSelection(
            baseSchemaID: "rime_ice",
            layoutStyle: .nineKey,
            t9ReadinessMatched: false,
            schemeBinding26: "rime_ice",
            schemeBinding9: "t9"
        )
        XCTAssertEqual(selection.effectiveSchemaID, "rime_ice")
        XCTAssertEqual(selection.effectiveLayoutStyle, .twentySixKey)
        XCTAssertFalse(selection.usesT9InputSemantics)
    }

    func testNineKeyRejectsNonCapableBinding() {
        let selection = RimeRuntimeSelection(
            baseSchemaID: "rime_ice",
            layoutStyle: .nineKey,
            t9ReadinessMatched: true,
            schemeBinding26: "rime_ice",
            schemeBinding9: "luna_pinyin"
        )
        XCTAssertEqual(selection.effectiveLayoutStyle, .twentySixKey)
        XCTAssertFalse(selection.usesT9InputSemantics)
    }

    func testMigrationWritesBindingsOnce() {
        let suite = "LayoutBoundRimeRuntimeSelectionTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }
        defaults.set("rime_ice", forKey: "rime_active_schema")
        defaults.set(KeyboardLayoutStyle.nineKey.rawValue, forKey: KeyboardLayoutSettingsKey.layoutStyle)
        let fingerprint = "fp-test"
        let marker = RimeT9ReadinessMarker(
            ready: true,
            compatibilityVersion: RimeT9Readiness.currentCompatibilityVersion,
            resourceFingerprint: fingerprint
        )
        RimeT9Readiness.save(marker, to: defaults)

        RimeRuntimeSelection.migrateLayoutBindingsIfNeeded(
            defaults: defaults,
            onDiskFingerprint: fingerprint
        )
        XCTAssertEqual(defaults.string(forKey: KeyboardLayoutSettingsKey.schemeBinding26), "rime_ice")
        XCTAssertEqual(defaults.string(forKey: KeyboardLayoutSettingsKey.schemeBinding9), "t9")

        defaults.set("luna_pinyin", forKey: KeyboardLayoutSettingsKey.schemeBinding26)
        RimeRuntimeSelection.migrateLayoutBindingsIfNeeded(
            defaults: defaults,
            onDiskFingerprint: fingerprint
        )
        XCTAssertEqual(
            defaults.string(forKey: KeyboardLayoutSettingsKey.schemeBinding26),
            "luna_pinyin",
            "migration must not overwrite existing bindings"
        )
    }

    func testResolveDefaultsUsesBindings() {
        let suite = "LayoutBoundResolve.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }
        defaults.set("wanxiang", forKey: "rime_active_schema")
        defaults.set(KeyboardLayoutStyle.nineKey.rawValue, forKey: KeyboardLayoutSettingsKey.layoutStyle)
        defaults.set("wanxiang", forKey: KeyboardLayoutSettingsKey.schemeBinding26)
        defaults.set("t9", forKey: KeyboardLayoutSettingsKey.schemeBinding9)
        let fingerprint = "fp-2"
        RimeT9Readiness.save(
            RimeT9ReadinessMarker(
                ready: true,
                compatibilityVersion: RimeT9Readiness.currentCompatibilityVersion,
                resourceFingerprint: fingerprint
            ),
            to: defaults
        )

        let selection = RimeRuntimeSelection.resolve(
            defaults: defaults,
            onDiskFingerprint: fingerprint
        )
        XCTAssertEqual(selection.effectiveSchemaID, "t9")
        XCTAssertTrue(selection.usesT9InputSemantics)
    }
}
