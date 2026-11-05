import Foundation
import KeyboardCore
import XCTest

@testable import RimeBridge

final class RimeRuntimeSelectionBridgeTests: XCTestCase {
    func testResolveWithoutSharedDataDirCannotMatchReadiness() {
        let suite = "uk.bridge.t9.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }

        defaults.set("rime_ice", forKey: "rime_active_schema")
        defaults.set(KeyboardLayoutStyle.nineKey.rawValue, forKey: KeyboardLayoutSettingsKey.layoutStyle)
        let marker = RimeT9ReadinessMarker(
            ready: true,
            compatibilityVersion: RimeT9Readiness.currentCompatibilityVersion,
            resourceFingerprint: "expected-fp"
        )
        RimeT9Readiness.save(marker, to: defaults)

        let withoutDir = RimeRuntimeSelectionBridge.resolve(defaults: defaults, sharedDataDir: nil)
        XCTAssertEqual(withoutDir.effectiveSchemaID, "rime_ice")
        XCTAssertFalse(withoutDir.usesT9InputSemantics)
        XCTAssertEqual(withoutDir.effectiveLayoutStyle, .twentySixKey)
    }

    func testResolveWithMatchingFingerprintSelectsT9() throws {
        let suite = "uk.bridge.t9.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }

        let temp = FileManager.default.temporaryDirectory
            .appendingPathComponent("uk-t9-sel-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: temp, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: temp) }

        let schema = """
            schema:
              schema_id: t9
            engine:
              processors:
                - ascii_composer
            speller:
              algebra:
                - derive/[abc]/2/
                - derive/[def]/3/
                - derive/[hgi]/4/
                - derive/[jkl]/5/
                - derive/[omn]/6/
                - derive/[pqrs]/7/
                - derive/[tuv]/8/
                - derive/[wxyz]/9/
            """
        let schemaURL = temp.appendingPathComponent("t9.schema.yaml")
        try schema.write(to: schemaURL, atomically: true, encoding: .utf8)
        let fingerprint = try XCTUnwrap(RimeT9Readiness.fingerprint(ofFileAt: schemaURL))

        defaults.set("rime_ice", forKey: "rime_active_schema")
        defaults.set(KeyboardLayoutStyle.nineKey.rawValue, forKey: KeyboardLayoutSettingsKey.layoutStyle)
        RimeT9Readiness.save(
            RimeT9ReadinessMarker(
                ready: true,
                compatibilityVersion: RimeT9Readiness.currentCompatibilityVersion,
                resourceFingerprint: fingerprint
            ),
            to: defaults
        )

        let withDir = RimeRuntimeSelectionBridge.resolve(
            defaults: defaults,
            sharedDataDir: temp.path
        )
        XCTAssertEqual(withDir.effectiveSchemaID, "t9")
        XCTAssertTrue(withDir.usesT9InputSemantics)
        XCTAssertEqual(withDir.effectiveLayoutStyle, .nineKey)

        // Same inputs without directory must fail closed — the bug fixed by P1.
        let withoutDir = RimeRuntimeSelectionBridge.resolve(defaults: defaults, sharedDataDir: nil)
        XCTAssertEqual(withoutDir.effectiveSchemaID, "rime_ice")
        XCTAssertFalse(withoutDir.usesT9InputSemantics)
    }

    func testT9CustomYamlUsesIceUserDictionaryPreference() {
        let enabled = RimeConfigManager.makeSchemaCustomYamlContent(
            schemaID: "rime_ice",
            userDictionaryEnabled: true,
            fuzzyPinyinSettings: RimeFuzzyPinyinSettings(enabled: false)
        )
        XCTAssertTrue(enabled?.contains("enable_user_dict") == true)
        XCTAssertTrue(enabled?.contains("true") == true)
        XCTAssertFalse(enabled?.contains("switches/") == true)

        let disabled = RimeConfigManager.makeSchemaCustomYamlContent(
            schemaID: "rime_ice",
            userDictionaryEnabled: false,
            fuzzyPinyinSettings: RimeFuzzyPinyinSettings(enabled: false)
        )
        XCTAssertTrue(disabled?.contains("enable_user_dict") == true)
        XCTAssertTrue(disabled?.contains("false") == true)
        XCTAssertFalse(disabled?.contains("switches/") == true)
    }

    func testProductionCustomYamlPlanIncludesT9OnlyWhenIceInstalled() {
        let dict = RimeUserDictionarySettings(lunaPinyinEnabled: false, rimeIceEnabled: true)

        let withoutIce = RimeConfigManager.planSchemaCustomYamlFiles(
            targets: schemaTargets(includeIce: false),
            simplificationEnabled: true,
            userDictionarySettings: dict
        )
        XCTAssertEqual(Set(withoutIce.map(\.schemaID)), Set(["luna_pinyin", "rime_ice"]))
        XCTAssertFalse(withoutIce.contains { $0.filename == "t9.custom.yaml" })

        let withIce = RimeConfigManager.planSchemaCustomYamlFiles(
            targets: schemaTargets(includeIce: true),
            simplificationEnabled: false,
            userDictionarySettings: dict
        )
        XCTAssertEqual(Set(withIce.map(\.schemaID)), Set(["luna_pinyin", "rime_ice", "t9"]))
        guard let t9 = withIce.first(where: { $0.schemaID == "t9" }) else {
            return XCTFail("expected t9.custom.yaml in plan when ice installed")
        }
        XCTAssertEqual(t9.filename, "t9.custom.yaml")
        XCTAssertEqual(t9.userDictionarySchemaID, "rime_ice")
        // Ice preference is true → t9 custom enables user dict.
        XCTAssertTrue(t9.content.contains("enable_user_dict"))
        XCTAssertTrue(t9.content.contains("true"))
        XCTAssertFalse(t9.content.contains("switches/"))

        guard let luna = withIce.first(where: { $0.schemaID == "luna_pinyin" }) else {
            return XCTFail("expected luna_pinyin.custom.yaml in plan")
        }
        XCTAssertTrue(luna.content.contains("false"))  // luna dict disabled
        XCTAssertFalse(luna.content.contains("switches/"))
    }

    func testOfficialLunaOverlayCarriesFuzzyRulesWithoutReplacingUpstreamAlgebra() throws {
        let content = try XCTUnwrap(
            RimeConfigManager.makeSchemaCustomYamlContent(
                schemaID: "luna_pinyin",
                userDictionaryEnabled: true,
                fuzzyPinyinSettings: RimeFuzzyPinyinSettings(
                    enabled: true,
                    zhZEnabled: true,
                    chCEnabled: false,
                    shSEnabled: false,
                    nLEnabled: false
                )
            )
        )
        XCTAssertFalse(content.contains("switches/"))
        XCTAssertTrue(content.contains("speller/algebra/+"))
        XCTAssertTrue(content.contains("derive/^zh/z/"))
        XCTAssertTrue(content.contains("derive/^z/zh/"))
    }

    func testOfficialLunaOverlayOmitsFuzzyAppendWhenDisabled() throws {
        let content = try XCTUnwrap(
            RimeConfigManager.makeSchemaCustomYamlContent(
                schemaID: "luna_pinyin",
                userDictionaryEnabled: true,
                fuzzyPinyinSettings: RimeFuzzyPinyinSettings(enabled: false)
            )
        )
        XCTAssertFalse(content.contains("speller/algebra/+"))
    }

    func testProductionCustomYamlSyncWritesT9FileWhenIceInstalled() throws {
        let temp = FileManager.default.temporaryDirectory
            .appendingPathComponent("uk-custom-yaml-\(UUID().uuidString)", isDirectory: true)
        let userDir = temp.appendingPathComponent("Rime/user", isDirectory: true)
        try FileManager.default.createDirectory(at: userDir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: temp) }

        // Exercise the pure plan + same write path as production sync (filename/content).
        let dict = RimeUserDictionarySettings(lunaPinyinEnabled: true, rimeIceEnabled: false)
        let plan = RimeConfigManager.planSchemaCustomYamlFiles(
            targets: schemaTargets(includeIce: true),
            simplificationEnabled: true,
            userDictionarySettings: dict
        )
        for file in plan {
            try file.content.write(
                to: userDir.appendingPathComponent(file.filename),
                atomically: true,
                encoding: .utf8
            )
        }

        let t9URL = userDir.appendingPathComponent("t9.custom.yaml")
        XCTAssertTrue(FileManager.default.fileExists(atPath: t9URL.path))
        let t9Body = try String(contentsOf: t9URL, encoding: .utf8)
        XCTAssertTrue(t9Body.contains("enable_user_dict"))
        XCTAssertTrue(t9Body.contains("false"), "t9 must follow rime_ice dict preference (disabled)")
        XCTAssertFalse(t9Body.contains("switches/"))

        // Without ice, plan must not include t9.
        let noT9 = RimeConfigManager.planSchemaCustomYamlFiles(
            targets: schemaTargets(includeIce: false),
            simplificationEnabled: true,
            userDictionarySettings: dict
        )
        XCTAssertFalse(noT9.contains { $0.filename == "t9.custom.yaml" })
    }

    func testSnapshotReadsInjectedMarkerAndFingerprint() throws {
        let wanxiangID = try XCTUnwrap(NineKeySchemeRegistry.schemes(forFamily: "wanxiang").first).schemaID
        let (defaults, root) = try makeSnapshotDefaults()
        defer {
            defaults.removePersistentDomain(forName: suiteName(defaults))
            try? FileManager.default.removeItem(at: root)
        }
        let shared = root.appendingPathComponent("shared", isDirectory: true)
        let source = shared.appendingPathComponent("\(wanxiangID).schema.yaml")
        try "schema_id: \(wanxiangID)\n".write(to: source, atomically: true, encoding: .utf8)
        let fingerprint = try XCTUnwrap(NineKeyReadiness.fingerprint(schemaID: wanxiangID, sharedDirectory: shared))
        NineKeyReadiness.save(
            RimeT9ReadinessMarker(ready: true, compatibilityVersion: "1", resourceFingerprint: fingerprint),
            schemaID: wanxiangID,
            defaults: defaults
        )
        defaults.set(wanxiangID, forKey: KeyboardLayoutSettingsKey.schemeBinding9)
        defaults.set(KeyboardLayoutStyle.nineKey.rawValue, forKey: KeyboardLayoutSettingsKey.layoutStyle)
        defaults.set("wanxiang", forKey: "rime_active_schema")
        defaults.set(true, forKey: "wanxiang_installed")

        let snapshot = RimeRuntimeSelectionBridge.registeredSnapshot(
            defaults: defaults, sharedDataDir: shared.path)
        XCTAssertEqual(snapshot.readinessBySchema[wanxiangID], true)
        let selection = RimeRuntimeSelectionBridge.resolve(defaults: defaults, sharedDataDir: shared.path)
        XCTAssertEqual(selection.effectiveSchemaID, wanxiangID)
        XCTAssertEqual(selection.effectiveLayoutStyle, .nineKey)
    }

    func testUnregisteredBindingFamilyMissingAndFingerprintMismatchFallBackToTwentySix() throws {
        let wanxiangID = try XCTUnwrap(NineKeySchemeRegistry.schemes(forFamily: "wanxiang").first).schemaID
        let (defaults, root) = try makeSnapshotDefaults()
        let shared = root.appendingPathComponent("shared", isDirectory: true)
        defer {
            defaults.removePersistentDomain(forName: suiteName(defaults))
            try? FileManager.default.removeItem(at: root)
        }
        let source = shared.appendingPathComponent("\(wanxiangID).schema.yaml")
        try "schema_id: \(wanxiangID)\n".write(to: source, atomically: true, encoding: .utf8)
        let fingerprint = try XCTUnwrap(NineKeyReadiness.fingerprint(schemaID: wanxiangID, sharedDirectory: shared))
        defaults.set(KeyboardLayoutStyle.nineKey.rawValue, forKey: KeyboardLayoutSettingsKey.layoutStyle)
        defaults.set("wanxiang", forKey: "rime_active_schema")
        defaults.set("luna_pinyin", forKey: KeyboardLayoutSettingsKey.schemeBinding26)

        defaults.set("not_registered", forKey: KeyboardLayoutSettingsKey.schemeBinding9)
        defaults.set(true, forKey: "wanxiang_installed")
        NineKeyReadiness.save(
            RimeT9ReadinessMarker(ready: true, compatibilityVersion: "1", resourceFingerprint: fingerprint),
            schemaID: wanxiangID, defaults: defaults)
        XCTAssertEqual(
            RimeRuntimeSelectionBridge.resolve(defaults: defaults, sharedDataDir: shared.path).effectiveLayoutStyle,
            .twentySixKey)

        defaults.set(wanxiangID, forKey: KeyboardLayoutSettingsKey.schemeBinding9)
        defaults.set(false, forKey: "wanxiang_installed")
        XCTAssertEqual(
            RimeRuntimeSelectionBridge.resolve(defaults: defaults, sharedDataDir: shared.path).effectiveSchemaID,
            "wanxiang")
        XCTAssertEqual(
            RimeRuntimeSelectionBridge.resolve(defaults: defaults, sharedDataDir: shared.path).effectiveLayoutStyle,
            .twentySixKey)

        defaults.set(true, forKey: "wanxiang_installed")
        NineKeyReadiness.save(
            RimeT9ReadinessMarker(ready: true, compatibilityVersion: "1", resourceFingerprint: "other"),
            schemaID: wanxiangID, defaults: defaults)
        XCTAssertEqual(
            RimeRuntimeSelectionBridge.resolve(defaults: defaults, sharedDataDir: shared.path).effectiveLayoutStyle,
            .twentySixKey)
    }

    func testFogOnlyInstallationMatchesLegacyBridgeResolve() throws {
        let (defaults, root) = try makeSnapshotDefaults()
        defer {
            defaults.removePersistentDomain(forName: suiteName(defaults))
            try? FileManager.default.removeItem(at: root)
        }
        let shared = root.appendingPathComponent("shared", isDirectory: true)
        let schemaURL = shared.appendingPathComponent("t9.schema.yaml")
        try "schema:\n  schema_id: t9\n".write(to: schemaURL, atomically: true, encoding: .utf8)
        let fingerprint = try XCTUnwrap(RimeT9Readiness.fingerprint(ofFileAt: schemaURL))
        defaults.set("rime_ice", forKey: "rime_active_schema")
        defaults.set(KeyboardLayoutStyle.nineKey.rawValue, forKey: KeyboardLayoutSettingsKey.layoutStyle)
        defaults.set(true, forKey: "rime_ice_installed")
        RimeT9Readiness.save(
            RimeT9ReadinessMarker(
                ready: true,
                compatibilityVersion: RimeT9Readiness.currentCompatibilityVersion,
                resourceFingerprint: fingerprint
            ),
            to: defaults
        )
        let bridged = RimeRuntimeSelectionBridge.resolve(defaults: defaults, sharedDataDir: shared.path)
        let legacy = RimeRuntimeSelection.resolve(
            baseSchemaID: "rime_ice",
            layoutRawValue: KeyboardLayoutStyle.nineKey.rawValue,
            readinessMarker: RimeT9Readiness.load(from: defaults),
            onDiskFingerprint: fingerprint,
            schemeBinding26: nil,
            schemeBinding9: nil
        )
        XCTAssertEqual(bridged.effectiveSchemaID, legacy.effectiveSchemaID)
        XCTAssertEqual(bridged.effectiveLayoutStyle, legacy.effectiveLayoutStyle)
        XCTAssertEqual(bridged.usesT9InputSemantics, legacy.usesT9InputSemantics)
        XCTAssertEqual(bridged.effectiveSchemaID, "t9")
    }

    private func makeSnapshotDefaults() throws -> (UserDefaults, URL) {
        let name = "uk.bridge.snapshot.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: name))
        defaults.set(name, forKey: "uk.suite.name")
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent("uk-bridge-snapshot-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(
            at: root.appendingPathComponent("shared", isDirectory: true),
            withIntermediateDirectories: true)
        return (defaults, root)
    }

    private func suiteName(_ defaults: UserDefaults) -> String {
        defaults.string(forKey: "uk.suite.name") ?? ""
    }

    private func schemaTargets(includeIce: Bool) -> [RimeConfigManager.SchemaSwitchTarget] {
        var rows: [(String, String, Bool)] = [
            ("luna_pinyin", "luna_pinyin", false),
            ("rime_ice", "rime_ice", false),
        ]
        if includeIce {
            rows.append(("t9", "rime_ice", false))
        }
        return rows.map { schemaID, dictionaryID, wanxiang in
            RimeConfigManager.SchemaSwitchTarget(
                schemaID: schemaID,
                userDictionarySchemaID: dictionaryID,
                sourceText: nil,
                wanxiangFamily: wanxiang
            )
        }
    }
}
