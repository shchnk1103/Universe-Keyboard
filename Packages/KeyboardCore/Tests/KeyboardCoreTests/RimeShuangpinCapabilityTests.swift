import XCTest

@testable import KeyboardCore

/// PB-017 PR-1：双拼方案注册与能力矩阵查询单测。
///
/// 冻结口径：双拼仅注册 26 键槽位（`schemeBinding26`），九宫格槽位（t9 registry）零触碰；
/// 能力矩阵新增双拼行 `supportsManagedFuzzyPinyin = false`、
/// `supportsProductAdvancedInput = true`。
final class RimeShuangpinCapabilityTests: XCTestCase {
    static let shuangpinSchemaIDs = ["double_pinyin_flypy", "double_pinyin"]

    func testShuangpinProfilesDeclareFrozenCapabilities() {
        for schemaID in Self.shuangpinSchemaIDs {
            let profile = RimeSchemeCapabilityMatrix.profile(for: schemaID)
            XCTAssertEqual(profile.schemaID, schemaID)
            XCTAssertFalse(profile.supportsManagedFuzzyPinyin, schemaID)
            XCTAssertTrue(profile.supportsProductAdvancedInput, schemaID)
        }
    }

    func testShuangpinAdaptersMirrorCapabilityMatrix() {
        for schemaID in Self.shuangpinSchemaIDs {
            let adapter = SchemeAdapterRegistry.adapter(for: schemaID)
            XCTAssertNotNil(adapter, schemaID)
            let profile = RimeSchemeCapabilityMatrix.profile(for: schemaID)
            XCTAssertEqual(adapter?.supportsManagedFuzzyPinyin, profile.supportsManagedFuzzyPinyin, schemaID)
            XCTAssertEqual(adapter?.supportsProductAdvancedInput, profile.supportsProductAdvancedInput, schemaID)
        }
    }

    /// 双拼注册到 26 键槽位；九宫格槽位（t9 registry）零触碰。
    func testShuangpinRegisteredForTwentySixKeySlotOnly() {
        for schemaID in Self.shuangpinSchemaIDs {
            XCTAssertTrue(SchemeAdapterRegistry.isTwentySixKeyCapable(schemaID), schemaID)
            XCTAssertTrue(RimeRuntimeSelection.isTwentySixKeyCapable(schemaID), schemaID)
            XCTAssertFalse(SchemeAdapterRegistry.isNineKeyCapable(schemaID), schemaID)
            XCTAssertFalse(SchemeAdapterRegistry.isRegisteredNineKeyCapable(schemaID), schemaID)
            XCTAssertFalse(SchemeAdapterRegistry.familySupportsNineKey(schemaID), schemaID)
        }
        // 九宫格既有语义不变：t9 仍解析到 Ice 家族。
        XCTAssertEqual(SchemeAdapterRegistry.normalizeSchemaID("t9"), "rime_ice")
        XCTAssertEqual(SchemeAdapterRegistry.adapter(for: "t9"), SchemeAdapterRegistry.ice)
        XCTAssertTrue(SchemeAdapterRegistry.isNineKeyCapable("t9"))
        XCTAssertTrue(RimeRuntimeSelection.isNineKeyCapable("t9"))
    }

    func testShuangpinAdapterShapeIsBuiltinMinimalTemplate() {
        for schemaID in Self.shuangpinSchemaIDs {
            let adapter = SchemeAdapterRegistry.adapter(for: schemaID)
            XCTAssertEqual(adapter?.schemaID, schemaID)
            XCTAssertTrue(adapter?.layout.supportsTwentySixKey ?? false, schemaID)
            XCTAssertFalse(adapter?.layout.supportsNineKey ?? true, schemaID)
            XCTAssertEqual(adapter?.layout.nineKeySchemaIDs, [], schemaID)
            // 内置模板：无 SharedDefault post-extract、无下载所有权、无后处理修订。
            XCTAssertEqual(adapter?.sharedDefaultMode, SchemeSharedDefaultMode.builtinPrelude, schemaID)
            XCTAssertEqual(adapter?.ownershipStrategyID, SchemeOwnershipStrategyID.none, schemaID)
            XCTAssertNil(adapter?.postProcessingRevision, schemaID)
            XCTAssertNil(SchemeAdapterRegistry.sharedDefaultApplicator(for: schemaID), schemaID)
            XCTAssertNil(SchemeAdapterRegistry.postProcessingRevision(for: schemaID), schemaID)
        }
    }

    func testShuangpinRegistrationDoesNotDisturbExistingAdapters() {
        XCTAssertEqual(SchemeAdapterRegistry.adapter(for: "rime_ice"), SchemeAdapterRegistry.ice)
        XCTAssertEqual(SchemeAdapterRegistry.adapter(for: "wanxiang"), SchemeAdapterRegistry.wanxiang)
        XCTAssertEqual(SchemeAdapterRegistry.adapter(for: "luna_pinyin"), SchemeAdapterRegistry.luna)
        XCTAssertNil(SchemeAdapterRegistry.adapter(for: "unknown_scheme"))
        // 双拼 ID 不得被误归一化到其它家族。
        XCTAssertEqual(
            RimeSchemeCapabilityMatrix.normalizeSchemaID("double_pinyin_flypy"),
            "double_pinyin_flypy"
        )
        XCTAssertEqual(RimeSchemeCapabilityMatrix.normalizeSchemaID("double_pinyin"), "double_pinyin")
    }

    /// RimeSettingsView 迁移查询：下载进度归属（TD-009/TD-010）。
    func testDistributionDownloadSubjectQueryStaysOnIceLetterFamily() {
        XCTAssertTrue(RimeSchemeCapabilityMatrix.isDistributionDownloadSubject("rime_ice"))
        XCTAssertFalse(RimeSchemeCapabilityMatrix.isDistributionDownloadSubject("luna_pinyin"))
        XCTAssertFalse(RimeSchemeCapabilityMatrix.isDistributionDownloadSubject("wanxiang"))
        for schemaID in Self.shuangpinSchemaIDs {
            XCTAssertFalse(RimeSchemeCapabilityMatrix.isDistributionDownloadSubject(schemaID), schemaID)
        }
    }

    /// RimeSettingsView 迁移查询：高级输入宿主与目标 schema。
    func testProductAdvancedInputHostQueriesResolveThroughMatrix() {
        XCTAssertTrue(RimeSchemeCapabilityMatrix.isProductAdvancedInputHost("rime_ice"))
        XCTAssertFalse(RimeSchemeCapabilityMatrix.isProductAdvancedInputHost("luna_pinyin"))
        XCTAssertFalse(RimeSchemeCapabilityMatrix.isProductAdvancedInputHost("wanxiang"))
        for schemaID in Self.shuangpinSchemaIDs {
            XCTAssertFalse(RimeSchemeCapabilityMatrix.isProductAdvancedInputHost(schemaID), schemaID)
        }
        XCTAssertEqual(RimeSchemeCapabilityMatrix.productAdvancedInputTargetSchemaID(), "rime_ice")
    }
}
