import KeyboardCore
import XCTest

/// Decision coverage for the extension snapshot. The extension reads the same
/// registry marker keys and source fingerprints, then calls `resolveRegistered`.
/// This target does not link the keyboard extension, so the assertions call that
/// entry with the injected marker and fingerprint directly.
nonisolated final class NineKeySnapshotTests: XCTestCase {
    func testSnapshotInjectedMarkerAndFingerprintSelectsRegisteredScheme() throws {
        let scheme = try XCTUnwrap(NineKeySchemeRegistry.schemes(forFamily: "wanxiang").first)
        let selection = RimeRuntimeSelection.resolveRegistered(
            baseSchemaID: "wanxiang",
            layoutRawValue: KeyboardLayoutStyle.nineKey.rawValue,
            readinessMarker: nil,
            onDiskFingerprint: nil,
            schemeBinding26: "luna_pinyin",
            schemeBinding9: scheme.schemaID,
            readinessBySchema: [scheme.schemaID: true],
            installedFamilies: ["wanxiang"]
        )
        XCTAssertEqual(selection.effectiveSchemaID, scheme.schemaID)
        XCTAssertEqual(selection.effectiveLayoutStyle, .nineKey)
        XCTAssertTrue(selection.usesT9InputSemantics)
    }

    func testUnregisteredBindingFallsBackToTwentySix() throws {
        let scheme = try XCTUnwrap(NineKeySchemeRegistry.schemes(forFamily: "wanxiang").first)
        let selection = RimeRuntimeSelection.resolveRegistered(
            baseSchemaID: "wanxiang",
            layoutRawValue: KeyboardLayoutStyle.nineKey.rawValue,
            readinessMarker: nil,
            onDiskFingerprint: nil,
            schemeBinding26: "wanxiang",
            schemeBinding9: "not_registered",
            readinessBySchema: [scheme.schemaID: true],
            installedFamilies: ["wanxiang"]
        )
        XCTAssertEqual(selection.effectiveLayoutStyle, .twentySixKey)
        XCTAssertEqual(selection.effectiveSchemaID, "wanxiang")
    }

    func testFamilyNotInstalledFallsBackToTwentySix() throws {
        let scheme = try XCTUnwrap(NineKeySchemeRegistry.schemes(forFamily: "wanxiang").first)
        let selection = RimeRuntimeSelection.resolveRegistered(
            baseSchemaID: "wanxiang",
            layoutRawValue: KeyboardLayoutStyle.nineKey.rawValue,
            readinessMarker: nil,
            onDiskFingerprint: nil,
            schemeBinding26: "wanxiang",
            schemeBinding9: scheme.schemaID,
            readinessBySchema: [scheme.schemaID: true],
            installedFamilies: []
        )
        XCTAssertEqual(selection.effectiveLayoutStyle, .twentySixKey)
    }

    func testFingerprintMismatchFallsBackToTwentySix() throws {
        let scheme = try XCTUnwrap(NineKeySchemeRegistry.schemes(forFamily: "wanxiang").first)
        let selection = RimeRuntimeSelection.resolveRegistered(
            baseSchemaID: "wanxiang",
            layoutRawValue: KeyboardLayoutStyle.nineKey.rawValue,
            readinessMarker: nil,
            onDiskFingerprint: nil,
            schemeBinding26: "wanxiang",
            schemeBinding9: scheme.schemaID,
            readinessBySchema: [scheme.schemaID: false],
            installedFamilies: ["wanxiang"]
        )
        XCTAssertEqual(selection.effectiveLayoutStyle, .twentySixKey)
    }

    func testFogOnlyBindingMatchesLegacyResolve() {
        let marker = RimeT9ReadinessMarker(
            ready: true,
            compatibilityVersion: RimeT9Readiness.currentCompatibilityVersion,
            resourceFingerprint: "fog"
        )
        let registered = RimeRuntimeSelection.resolveRegistered(
            baseSchemaID: "rime_ice",
            layoutRawValue: KeyboardLayoutStyle.nineKey.rawValue,
            readinessMarker: marker,
            onDiskFingerprint: "fog",
            schemeBinding26: "rime_ice",
            schemeBinding9: nil,
            readinessBySchema: [:],
            installedFamilies: ["rime_ice"]
        )
        let legacy = RimeRuntimeSelection.resolve(
            baseSchemaID: "rime_ice",
            layoutRawValue: KeyboardLayoutStyle.nineKey.rawValue,
            readinessMarker: marker,
            onDiskFingerprint: "fog",
            schemeBinding26: "rime_ice",
            schemeBinding9: nil
        )
        XCTAssertEqual(registered.effectiveSchemaID, legacy.effectiveSchemaID)
        XCTAssertEqual(registered.effectiveLayoutStyle, legacy.effectiveLayoutStyle)
        XCTAssertEqual(registered.effectiveSchemaID, "t9")
    }
}
