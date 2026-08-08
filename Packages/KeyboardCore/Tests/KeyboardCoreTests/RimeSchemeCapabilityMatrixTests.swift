import XCTest
@testable import KeyboardCore

final class RimeSchemeCapabilityMatrixTests: XCTestCase {
    func testFogSupportsFuzzyAndAdvanced() {
        let profile = RimeSchemeCapabilityMatrix.profile(for: "rime_ice")
        XCTAssertTrue(profile.supportsManagedFuzzyPinyin)
        XCTAssertTrue(profile.supportsProductAdvancedInput)
    }

    func testWanxiangClaimsNeitherManagedFuzzyNorProductAdvanced() {
        let profile = RimeSchemeCapabilityMatrix.profile(for: "wanxiang")
        XCTAssertFalse(profile.supportsManagedFuzzyPinyin)
        XCTAssertFalse(profile.supportsProductAdvancedInput)
    }

    func testLunaSupportsFuzzyOnly() {
        let profile = RimeSchemeCapabilityMatrix.profile(for: "luna_pinyin")
        XCTAssertTrue(profile.supportsManagedFuzzyPinyin)
        XCTAssertFalse(profile.supportsProductAdvancedInput)
    }

    func testT9NormalizesToFogCapabilities() {
        XCTAssertEqual(RimeSchemeCapabilityMatrix.normalizeSchemaID("t9"), "rime_ice")
        let profile = RimeSchemeCapabilityMatrix.profile(for: "t9")
        XCTAssertTrue(profile.supportsManagedFuzzyPinyin)
        XCTAssertTrue(profile.supportsProductAdvancedInput)
    }

    func testSettingsCapabilityUsesTwentySixKeyBinding() {
        let id = RimeSchemeCapabilityMatrix.settingsCapabilitySchemaID(
            layoutStyle: .twentySixKey,
            schemeBinding26: "wanxiang",
            schemeBinding9: "t9",
            activeSchemaID: "rime_ice"
        )
        XCTAssertEqual(id, "wanxiang")
    }

    func testSettingsCapabilityUsesNineKeyBindingMappedToFog() {
        let id = RimeSchemeCapabilityMatrix.settingsCapabilitySchemaID(
            layoutStyle: .nineKey,
            schemeBinding26: "wanxiang",
            schemeBinding9: "t9",
            activeSchemaID: "wanxiang"
        )
        XCTAssertEqual(id, "rime_ice")
    }
}
