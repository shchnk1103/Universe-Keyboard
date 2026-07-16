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
            simplificationEnabled: true,
            userDictionaryEnabled: true
        )
        XCTAssertTrue(enabled?.contains("enable_user_dict") == true)
        XCTAssertTrue(enabled?.contains("true") == true)
        XCTAssertTrue(enabled?.contains("switches/@1/reset") == true)

        let disabled = RimeConfigManager.makeSchemaCustomYamlContent(
            simplificationEnabled: false,
            userDictionaryEnabled: false
        )
        XCTAssertTrue(disabled?.contains("enable_user_dict") == true)
        XCTAssertTrue(disabled?.contains("false") == true)
        XCTAssertTrue(disabled?.contains(": 0") == true)
    }
}
