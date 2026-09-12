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
        XCTAssertEqual(adapter.sharedDefaultMode, .privatePreset)
        XCTAssertEqual(adapter.ownershipStrategyID, .exactHash)
        XCTAssertEqual(adapter.postProcessingRevision, "wanxiang-post-2")
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
        XCTAssertEqual(SchemeAdapterRegistry.postProcessingRevision(for: "wanxiang"), "wanxiang-post-2")
        XCTAssertNil(SchemeAdapterRegistry.postProcessingRevision(for: "luna_pinyin"))
        XCTAssertEqual(SchemeAdapterRegistry.postProcessingRevision(for: "t9"), "rime-ice-post-2")
        XCTAssertNil(SchemeAdapterRegistry.postProcessingRevision(for: "unknown_scheme"))
    }

    func testSharedDefaultApplicatorRoutesIceAndWanxiangPrivatePreset() {
        let ice = SchemeAdapterRegistry.sharedDefaultApplicator(for: "rime_ice")
        XCTAssertEqual(ice?.mode, .privatePreset)
        XCTAssertTrue(ice is RimeIceSharedDefaultAdapter)
        // t9 normalizes to Ice family → same Ice privatePreset applicator.
        let t9 = SchemeAdapterRegistry.sharedDefaultApplicator(for: "t9")
        XCTAssertEqual(t9?.mode, .privatePreset)
        XCTAssertTrue(t9 is RimeIceSharedDefaultAdapter)
        // Wanxiang P2 privatePreset — dedicated applicator, never Ice.
        let wanxiang = SchemeAdapterRegistry.sharedDefaultApplicator(for: "wanxiang")
        XCTAssertEqual(wanxiang?.mode, .privatePreset)
        XCTAssertTrue(wanxiang is RimeWanxiangSharedDefaultAdapter)
        XCTAssertFalse(wanxiang is RimeIceSharedDefaultAdapter)
        XCTAssertNil(SchemeAdapterRegistry.sharedDefaultApplicator(for: "luna_pinyin"))
        XCTAssertNil(SchemeAdapterRegistry.sharedDefaultApplicator(for: "unknown_scheme"))
    }

    func testApplySharedDefaultPostExtractRoutesIceAndWanxiangPresets() throws {
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
        let wanxiangDefault = "config_version: wanxiang\n"
        try wanxiangDefault.write(
            to: wanxiangRoot.appendingPathComponent("default.yaml"),
            atomically: true,
            encoding: .utf8
        )
        try "recognizer:\n  import_preset: default\n".write(
            to: wanxiangRoot.appendingPathComponent("wanxiang.schema.yaml"),
            atomically: true,
            encoding: .utf8
        )
        try SchemeAdapterRegistry.applySharedDefaultPostExtract(for: "wanxiang", in: wanxiangRoot)
        XCTAssertFalse(
            FileManager.default.fileExists(
                atPath: wanxiangRoot.appendingPathComponent("rime_ice_preset.yaml").path
            )
        )
        XCTAssertEqual(
            try String(
                contentsOf: wanxiangRoot.appendingPathComponent("wanxiang_preset.yaml"),
                encoding: .utf8
            ),
            wanxiangDefault
        )
        XCTAssertEqual(
            try String(contentsOf: wanxiangRoot.appendingPathComponent("default.yaml"), encoding: .utf8),
            wanxiangDefault
        )
        let wanxiangSchema = try String(
            contentsOf: wanxiangRoot.appendingPathComponent("wanxiang.schema.yaml"),
            encoding: .utf8
        )
        XCTAssertTrue(wanxiangSchema.contains("import_preset: wanxiang_preset"))
        XCTAssertFalse(wanxiangSchema.contains("import_preset: default"))
    }

    func testResourceCapabilityRoutesOwnershipHonesty() {
        XCTAssertEqual(
            SchemeAdapterRegistry.resourceCapability(for: "rime_ice")?.ownershipStrategyID,
            .namedList
        )
        XCTAssertEqual(SchemeAdapterRegistry.resourceCapability(for: "rime_ice")?.admitsOpenCC, true)
        XCTAssertEqual(
            SchemeAdapterRegistry.resourceCapability(for: "wanxiang")?.ownershipStrategyID,
            .exactHash
        )
        XCTAssertEqual(SchemeAdapterRegistry.resourceCapability(for: "wanxiang")?.admitsOpenCC, false)
        XCTAssertNil(SchemeAdapterRegistry.resourceCapability(for: "unknown_scheme"))
    }

    func testUninstallHooksIceLayoutFallbackOnly() {
        XCTAssertEqual(
            SchemeAdapterRegistry.uninstallHooks(for: "rime_ice"),
            .ice
        )
        XCTAssertEqual(SchemeAdapterRegistry.uninstallHooks(for: "wanxiang"), .none)
        XCTAssertEqual(SchemeAdapterRegistry.uninstallHooks(for: "luna_pinyin"), .none)
        XCTAssertTrue(SchemeAdapterRegistry.hasUninstallLayoutFallback(for: "rime_ice"))
        XCTAssertFalse(SchemeAdapterRegistry.hasUninstallLayoutFallback(for: "wanxiang"))
    }
}
