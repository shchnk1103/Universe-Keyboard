import XCTest

@testable import KeyboardCore

private final class InvalidationNineKeyStore: NineKeySettingsStore {
    var values: [String: Any] = [:]
    func data(forKey key: String) -> Data? { values[key] as? Data }
    func set(_ value: Any?, forKey key: String) {
        if let value { values[key] = value } else { values.removeValue(forKey: key) }
    }
}

final class NineKeyReadinessInvalidationTests: XCTestCase {
    func testInvalidateAllClearsEverySchemeAndInvalidateFamilyKeepsTheOther() {
        let defaults = InvalidationNineKeyStore()
        for scheme in NineKeySchemeRegistry.entries {
            NineKeyReadiness.save(
                RimeT9ReadinessMarker(
                    ready: true, compatibilityVersion: scheme.compatibilityVersion,
                    resourceFingerprint: scheme.schemaID),
                schemaID: scheme.schemaID, defaults: defaults)
        }
        NineKeyReadiness.invalidate(familyID: "wanxiang", defaults: defaults)
        XCTAssertEqual(NineKeyReadiness.load(schemaID: "t9", defaults: defaults)?.ready, true)
        let wanID = NineKeySchemeRegistry.schemes(forFamily: "wanxiang")[0].schemaID
        XCTAssertEqual(NineKeyReadiness.load(schemaID: wanID, defaults: defaults)?.ready, false)

        NineKeyReadiness.invalidateAll(defaults: defaults)
        for scheme in NineKeySchemeRegistry.entries {
            XCTAssertEqual(
                NineKeyReadiness.load(schemaID: scheme.schemaID, defaults: defaults)?.ready, false,
                scheme.schemaID)
        }
    }
}
