import Foundation
import KeyboardCore
import XCTest

@testable import RimeBridge

/// PB-017-SHUANGPIN-INPUT-FIX-001：双拼 schema 的部署注册（FIX-1）
/// 与启动回退候选（FIX-2）的行为门。
final class ShuangpinSchemaRegistrationTests: XCTestCase {
    // MARK: - Fixtures

    private func makeSyncFixture(
        binding26: String?,
        materializeVariant: RimeShuangpinVariant? = nil
    ) throws -> (rimeRoot: URL, defaults: UserDefaults, suite: String) {
        let runtime = try RimeBuiltinResourceInstallerTests.makeInstalledRuntimeFixture()
        if let materializeVariant {
            _ = try RimeConfigTemplates.materializeShuangpinSchema(
                variant: materializeVariant,
                baseSchemaID: "luna_pinyin",
                into: runtime.rimeRoot.appendingPathComponent("shared", isDirectory: true)
            )
        }
        let suite = "uk.shuangpin-reg.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defaults.set("luna_pinyin", forKey: "rime_active_schema")
        if let binding26 {
            defaults.set(binding26, forKey: KeyboardLayoutSettingsKey.schemeBinding26)
        }
        return (runtime.rimeRoot, defaults, suite)
    }

    private func readDefaultCustomYaml(rimeRoot: URL) throws -> String {
        try String(
            contentsOf:
                rimeRoot
                .appendingPathComponent("user", isDirectory: true)
                .appendingPathComponent("default.custom.yaml"),
            encoding: .utf8
        )
    }

    // MARK: - FIX-1 (a)：绑定 + 已物化 schema → schema_list 注册

    func testSyncRegistersMaterializedShuangpinBindingInSchemaList() throws {
        let (rimeRoot, defaults, suite) = try makeSyncFixture(
            binding26: "double_pinyin_flypy",
            materializeVariant: .flypy
        )
        defer {
            defaults.removePersistentDomain(forName: suite)
            try? FileManager.default.removeItem(at: rimeRoot.deletingLastPathComponent())
        }

        XCTAssertTrue(
            RimeConfigManager.syncCustomYamlFiles(defaults: defaults, rimeRoot: rimeRoot)
        )
        let yaml = try readDefaultCustomYaml(rimeRoot: rimeRoot)
        XCTAssertTrue(yaml.contains("- schema: double_pinyin_flypy"), yaml)
        // 宿主全拼 schema 仍在列表中，回退路径可用。
        XCTAssertTrue(yaml.contains("- schema: luna_pinyin"), yaml)
    }

    // MARK: - FIX-1 (b)：物化文件缺失 → fail-closed 排除

    func testSyncExcludesShuangpinBindingWhenMaterializedFileMissing() throws {
        let (rimeRoot, defaults, suite) = try makeSyncFixture(
            binding26: "double_pinyin_flypy",
            materializeVariant: nil
        )
        defer {
            defaults.removePersistentDomain(forName: suite)
            try? FileManager.default.removeItem(at: rimeRoot.deletingLastPathComponent())
        }

        XCTAssertTrue(
            RimeConfigManager.syncCustomYamlFiles(defaults: defaults, rimeRoot: rimeRoot)
        )
        let yaml = try readDefaultCustomYaml(rimeRoot: rimeRoot)
        XCTAssertFalse(yaml.contains("double_pinyin_flypy"), yaml)
        XCTAssertTrue(yaml.contains("- schema: luna_pinyin"), yaml)
    }

    func testSyncRegistersNaturalCodeBindingWhenMaterialized() throws {
        let (rimeRoot, defaults, suite) = try makeSyncFixture(
            binding26: "double_pinyin",
            materializeVariant: .zrm
        )
        defer {
            defaults.removePersistentDomain(forName: suite)
            try? FileManager.default.removeItem(at: rimeRoot.deletingLastPathComponent())
        }

        XCTAssertTrue(
            RimeConfigManager.syncCustomYamlFiles(defaults: defaults, rimeRoot: rimeRoot)
        )
        let yaml = try readDefaultCustomYaml(rimeRoot: rimeRoot)
        XCTAssertTrue(yaml.contains("- schema: double_pinyin"), yaml)
    }

    // MARK: - FIX-2 (c)：启动回退候选解析到 base schema

    func testStartupFallbackForShuangpinBindingResolvesToBaseSchema() {
        XCTAssertEqual(
            RimeStartupSchemaSelector.fallbackSchemaID(
                baseSchemaID: "luna_pinyin",
                schemeBinding26: "double_pinyin_flypy",
                effectiveSchemaID: "double_pinyin_flypy"
            ),
            "luna_pinyin"
        )
        XCTAssertEqual(
            RimeStartupSchemaSelector.fallbackSchemaID(
                baseSchemaID: "rime_ice",
                schemeBinding26: "double_pinyin",
                effectiveSchemaID: "double_pinyin"
            ),
            "rime_ice"
        )
    }

    func testStartupFallbackPreservesNonShuangpinBehavior() {
        // fog T9 绑定 → rime_ice；无绑定 → base；万象绑定保持自身。
        XCTAssertEqual(
            RimeStartupSchemaSelector.fallbackSchemaID(
                baseSchemaID: "rime_ice",
                schemeBinding26: "t9",
                effectiveSchemaID: "t9"
            ),
            "rime_ice"
        )
        XCTAssertEqual(
            RimeStartupSchemaSelector.fallbackSchemaID(
                baseSchemaID: "luna_pinyin",
                schemeBinding26: nil,
                effectiveSchemaID: "luna_pinyin"
            ),
            "luna_pinyin"
        )
        XCTAssertEqual(
            RimeStartupSchemaSelector.fallbackSchemaID(
                baseSchemaID: "luna_pinyin",
                schemeBinding26: "wanxiang",
                effectiveSchemaID: "wanxiang"
            ),
            "wanxiang"
        )
    }

    func testSelectorNeverReAttemptsUnavailableShuangpinRequest() {
        var attempted: [String] = []
        let result = RimeStartupSchemaSelector.select(
            requested: "double_pinyin_flypy",
            fallback: "luna_pinyin",
            attempt: { id in
                attempted.append(id)
                return id == "luna_pinyin"
            },
            availableSchemaIDs: { ["double_pinyin_flypy", "luna_pinyin", "t9"] }
        )
        XCTAssertEqual(result.selectedSchemaID, "luna_pinyin")
        XCTAssertFalse(result.usedSchemaEnumeration)
        // 只尝试请求一次、回退一次；绝不重试 double_pinyin_flypy。
        XCTAssertEqual(attempted, ["double_pinyin_flypy", "luna_pinyin"])
    }
}
