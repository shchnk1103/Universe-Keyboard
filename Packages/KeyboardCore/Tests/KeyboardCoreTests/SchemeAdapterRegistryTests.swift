import XCTest

@testable import KeyboardCore

final class SchemeAdapterRegistryTests: XCTestCase {

    func testIceAdapterMirrorsTodaysHardcodes() {
        let adapter = SchemeAdapterRegistry.ice
        XCTAssertEqual(adapter.schemaID, "rime_ice")
        XCTAssertTrue(adapter.layout.supportsTwentySixKey)
        XCTAssertTrue(adapter.layout.supportsNineKey)
        XCTAssertEqual(adapter.layout.nineKeySchemaIDs, ["t9"])
        XCTAssertEqual(adapter.sharedDefaultMode, .privatePreset)
        XCTAssertEqual(adapter.ownershipStrategyID, .namedList)
        XCTAssertEqual(adapter.postProcessingRevision, "rime-ice-post-2")
        XCTAssertTrue(adapter.supportsManagedFuzzyPinyin)
        XCTAssertTrue(adapter.supportsProductAdvancedInput)
    }

    func testWanxiangAdapterMirrorsTodaysHardcodes() {
        let adapter = SchemeAdapterRegistry.wanxiang
        XCTAssertEqual(adapter.schemaID, "wanxiang")
        XCTAssertTrue(adapter.layout.supportsTwentySixKey)
        XCTAssertFalse(adapter.layout.supportsNineKey)
        XCTAssertEqual(adapter.layout.nineKeySchemaIDs, [])
        XCTAssertEqual(adapter.sharedDefaultMode, .consumePrelude)
        XCTAssertEqual(adapter.ownershipStrategyID, .exactHash)
        XCTAssertEqual(adapter.postProcessingRevision, "wanxiang-post-1")
        XCTAssertFalse(adapter.supportsManagedFuzzyPinyin)
        XCTAssertFalse(adapter.supportsProductAdvancedInput)
    }

    func testLunaAdapterMirrorsTodaysHardcodes() {
        let adapter = SchemeAdapterRegistry.luna
        XCTAssertEqual(adapter.schemaID, "luna_pinyin")
        XCTAssertTrue(adapter.layout.supportsTwentySixKey)
        XCTAssertFalse(adapter.layout.supportsNineKey)
        XCTAssertEqual(adapter.layout.nineKeySchemaIDs, [])
        XCTAssertEqual(adapter.sharedDefaultMode, .builtinPrelude)
        XCTAssertEqual(adapter.ownershipStrategyID, .none)
        XCTAssertNil(adapter.postProcessingRevision)
        XCTAssertTrue(adapter.supportsManagedFuzzyPinyin)
        XCTAssertFalse(adapter.supportsProductAdvancedInput)
    }

    func testT9LookupResolvesToIceFamilyAdapter() {
        XCTAssertEqual(SchemeAdapterRegistry.normalizeSchemaID("t9"), "rime_ice")
        XCTAssertEqual(SchemeAdapterRegistry.adapter(for: "t9"), SchemeAdapterRegistry.ice)
        XCTAssertEqual(SchemeAdapterRegistry.adapter(for: "rime_ice"), SchemeAdapterRegistry.ice)
    }

    func testLookupReturnsWanxiangAndLuna() {
        XCTAssertEqual(SchemeAdapterRegistry.adapter(for: "wanxiang"), SchemeAdapterRegistry.wanxiang)
        XCTAssertEqual(SchemeAdapterRegistry.adapter(for: "luna_pinyin"), SchemeAdapterRegistry.luna)
        XCTAssertNil(SchemeAdapterRegistry.adapter(for: "unknown_scheme"))
    }

    func testNineKeyCapableRoutesThroughLayoutCapability() {
        let samples = ["t9", "rime_ice", "wanxiang", "luna_pinyin", "melt_eng", "wanxiang_t9"]
        for id in samples {
            XCTAssertEqual(
                SchemeAdapterRegistry.isNineKeyCapable(id),
                RimeRuntimeSelection.isNineKeyCapable(id),
                id
            )
        }
        // Ice-only literal t9; letter / Wanxiang / Luna stay false.
        XCTAssertTrue(SchemeAdapterRegistry.isNineKeyCapable("t9"))
        XCTAssertFalse(SchemeAdapterRegistry.isNineKeyCapable("rime_ice"))
        XCTAssertFalse(SchemeAdapterRegistry.isNineKeyCapable("wanxiang"))
        XCTAssertFalse(SchemeAdapterRegistry.isNineKeyCapable("luna_pinyin"))
        XCTAssertFalse(SchemeAdapterRegistry.isNineKeyCapable("wanxiang_t9"))
        XCTAssertFalse(SchemeAdapterRegistry.isNineKeyCapable("melt_eng"))
    }

    func testTwentySixKeyCapableRoutesThroughLayoutCapability() {
        let samples = ["t9", "rime_ice", "wanxiang", "luna_pinyin", "melt_eng"]
        for id in samples {
            XCTAssertEqual(
                SchemeAdapterRegistry.isTwentySixKeyCapable(id),
                RimeRuntimeSelection.isTwentySixKeyCapable(id),
                id
            )
        }
        XCTAssertTrue(SchemeAdapterRegistry.isTwentySixKeyCapable("rime_ice"))
        XCTAssertTrue(SchemeAdapterRegistry.isTwentySixKeyCapable("wanxiang"))
        XCTAssertTrue(SchemeAdapterRegistry.isTwentySixKeyCapable("luna_pinyin"))
        XCTAssertTrue(SchemeAdapterRegistry.isTwentySixKeyCapable("melt_eng"))
        // Literal t9 resolves to Ice family which is 26-capable (today’s normalize path).
        XCTAssertTrue(SchemeAdapterRegistry.isTwentySixKeyCapable("t9"))
    }

    func testFamilySupportsNineKeyPreservesIceLetterMigrationAnswers() {
        XCTAssertTrue(SchemeAdapterRegistry.familySupportsNineKey("rime_ice"))
        XCTAssertFalse(SchemeAdapterRegistry.familySupportsNineKey("t9"))
        XCTAssertFalse(SchemeAdapterRegistry.familySupportsNineKey("wanxiang"))
        XCTAssertFalse(SchemeAdapterRegistry.familySupportsNineKey("luna_pinyin"))
        XCTAssertFalse(SchemeAdapterRegistry.familySupportsNineKey("melt_eng"))
    }

    func testSetSchemeBinding9RejectsNonCapableIDs() {
        let suite = "test.scheme-adapter.binding9." + UUID().uuidString
        guard let store = UserDefaults(suiteName: suite) else {
            XCTFail("suite")
            return
        }
        defer { store.removePersistentDomain(forName: suite) }

        RimeRuntimeSelection.setSchemeBinding9("wanxiang", defaults: store)
        XCTAssertNil(store.string(forKey: KeyboardLayoutSettingsKey.schemeBinding9))

        RimeRuntimeSelection.setSchemeBinding9("rime_ice", defaults: store)
        XCTAssertNil(store.string(forKey: KeyboardLayoutSettingsKey.schemeBinding9))

        RimeRuntimeSelection.setSchemeBinding9("t9", defaults: store)
        XCTAssertEqual(store.string(forKey: KeyboardLayoutSettingsKey.schemeBinding9), "t9")
    }

    func testCapabilityHonestyMatchesCapabilityMatrix() {
        for schemaID in ["rime_ice", "t9", "wanxiang", "luna_pinyin"] {
            guard let adapter = SchemeAdapterRegistry.adapter(for: schemaID) else {
                XCTFail("missing adapter for \(schemaID)")
                continue
            }
            let profile = RimeSchemeCapabilityMatrix.profile(for: schemaID)
            XCTAssertEqual(adapter.supportsManagedFuzzyPinyin, profile.supportsManagedFuzzyPinyin, schemaID)
            XCTAssertEqual(adapter.supportsProductAdvancedInput, profile.supportsProductAdvancedInput, schemaID)
        }
    }

    func testPostProcessingRevisionMirrorsTodaysSwitch() {
        XCTAssertEqual(SchemeAdapterRegistry.postProcessingRevision(for: "rime_ice"), "rime-ice-post-2")
        XCTAssertEqual(SchemeAdapterRegistry.postProcessingRevision(for: "wanxiang"), "wanxiang-post-1")
        XCTAssertNil(SchemeAdapterRegistry.postProcessingRevision(for: "luna_pinyin"))
        XCTAssertEqual(SchemeAdapterRegistry.postProcessingRevision(for: "t9"), "rime-ice-post-2")
        XCTAssertNil(SchemeAdapterRegistry.postProcessingRevision(for: "unknown_scheme"))
    }

    func testSharedDefaultApplicatorIsIcePrivatePresetOnly() {
        let ice = SchemeAdapterRegistry.sharedDefaultApplicator(for: "rime_ice")
        XCTAssertEqual(ice?.mode, .privatePreset)
        // t9 normalizes to Ice family → same privatePreset applicator.
        XCTAssertEqual(
            SchemeAdapterRegistry.sharedDefaultApplicator(for: "t9")?.mode,
            .privatePreset
        )
        // Wanxiang transitional consumePrelude — no post-extract applicator in P1.
        XCTAssertNil(SchemeAdapterRegistry.sharedDefaultApplicator(for: "wanxiang"))
        XCTAssertNil(SchemeAdapterRegistry.sharedDefaultApplicator(for: "luna_pinyin"))
        XCTAssertNil(SchemeAdapterRegistry.sharedDefaultApplicator(for: "unknown_scheme"))
    }

    func testApplySharedDefaultPostExtractRoutesIceAndNoopsWanxiang() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(
            "shared-default-seam-\(UUID().uuidString)",
            isDirectory: true
        )
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: root) }

        try "config_version: ice\n".write(
            to: root.appendingPathComponent("default.yaml"),
            atomically: true,
            encoding: .utf8
        )
        try "punctuator:\n  __include: default:/punctuator\n".write(
            to: root.appendingPathComponent("rime_ice.schema.yaml"),
            atomically: true,
            encoding: .utf8
        )

        try SchemeAdapterRegistry.applySharedDefaultPostExtract(for: "rime_ice", in: root)

        XCTAssertTrue(
            FileManager.default.fileExists(
                atPath: root.appendingPathComponent("rime_ice_preset.yaml").path
            )
        )
        let schema = try String(
            contentsOf: root.appendingPathComponent("rime_ice.schema.yaml"),
            encoding: .utf8
        )
        XCTAssertTrue(schema.contains("__include: rime_ice_preset:/punctuator"))
        // Prelude upstream default remains in the extract tree (skip-list keeps it out).
        XCTAssertEqual(
            try String(contentsOf: root.appendingPathComponent("default.yaml"), encoding: .utf8),
            "config_version: ice\n"
        )

        let wanxiangRoot = FileManager.default.temporaryDirectory.appendingPathComponent(
            "shared-default-wanxiang-\(UUID().uuidString)",
            isDirectory: true
        )
        try FileManager.default.createDirectory(at: wanxiangRoot, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: wanxiangRoot) }
        try "config_version: wanxiang\n".write(
            to: wanxiangRoot.appendingPathComponent("default.yaml"),
            atomically: true,
            encoding: .utf8
        )
        try SchemeAdapterRegistry.applySharedDefaultPostExtract(for: "wanxiang", in: wanxiangRoot)
        XCTAssertFalse(
            FileManager.default.fileExists(
                atPath: wanxiangRoot.appendingPathComponent("rime_ice_preset.yaml").path
            )
        )
        // No Wanxiang private preset migration in P1.
        let wanxiangNames = try FileManager.default.contentsOfDirectory(atPath: wanxiangRoot.path)
        XCTAssertEqual(Set(wanxiangNames), ["default.yaml"])
    }
}
