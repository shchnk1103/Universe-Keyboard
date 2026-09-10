import XCTest

@testable import KeyboardCore

final class SchemeAdapterRegistryTests: XCTestCase {

    func testIceAdapterMirrorsTodaysHardcodes() {
        let adapter = SchemeAdapterRegistry.ice
        XCTAssertEqual(adapter.schemaID, "rime_ice")
        XCTAssertTrue(adapter.layout.supportsTwentySixKey)
        XCTAssertTrue(adapter.layout.supportsNineKey)
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

    func testNineKeyCapableMatchesRimeRuntimeSelectionHardcode() {
        let samples = ["t9", "rime_ice", "wanxiang", "luna_pinyin", "melt_eng"]
        for id in samples {
            XCTAssertEqual(
                SchemeAdapterRegistry.isNineKeyCapable(id),
                RimeRuntimeSelection.isNineKeyCapable(id),
                id
            )
        }
        XCTAssertTrue(SchemeAdapterRegistry.isNineKeyCapable("t9"))
        XCTAssertFalse(SchemeAdapterRegistry.isNineKeyCapable("rime_ice"))
        XCTAssertFalse(SchemeAdapterRegistry.isNineKeyCapable("wanxiang"))
        XCTAssertFalse(SchemeAdapterRegistry.isNineKeyCapable("luna_pinyin"))
    }

    func testTwentySixKeyCapableMatchesRimeRuntimeSelectionHardcode() {
        let samples = ["t9", "rime_ice", "wanxiang", "luna_pinyin", "melt_eng"]
        for id in samples {
            XCTAssertEqual(
                SchemeAdapterRegistry.isTwentySixKeyCapable(id),
                RimeRuntimeSelection.isTwentySixKeyCapable(id),
                id
            )
        }
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
}
