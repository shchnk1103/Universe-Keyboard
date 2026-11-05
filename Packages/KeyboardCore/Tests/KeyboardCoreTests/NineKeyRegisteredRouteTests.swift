import XCTest

@testable import KeyboardCore

final class NineKeyRegisteredRouteTests: XCTestCase {
    private let wanxiangNineKeyID = "wanxiang_t9i"

    func testFogBindingsMatchLegacyResolveForEveryListedCombination() {
        let bases = ["rime_ice", "luna_pinyin", "wanxiang"]
        let layouts = ["twenty_six_key", "nine_key"]
        let fingerprint = "fp"
        let matched = RimeT9ReadinessMarker(
            ready: true,
            compatibilityVersion: RimeT9Readiness.currentCompatibilityVersion,
            resourceFingerprint: fingerprint
        )
        let mismatched = RimeT9ReadinessMarker(
            ready: true,
            compatibilityVersion: RimeT9Readiness.currentCompatibilityVersion,
            resourceFingerprint: "other"
        )
        let markers: [RimeT9ReadinessMarker?] = [matched, mismatched, nil]
        let bindings: [String?] = [nil, "", "t9"]
        let distractingReady = [wanxiangNineKeyID: true]
        let distractingInstalled: Set<String> = ["wanxiang", "rime_ice"]

        for base in bases {
            for layout in layouts {
                for marker in markers {
                    for binding in bindings {
                        let legacy = RimeRuntimeSelection.resolve(
                            baseSchemaID: base,
                            layoutRawValue: layout,
                            readinessMarker: marker,
                            onDiskFingerprint: fingerprint,
                            schemeBinding26: base,
                            schemeBinding9: binding
                        )
                        let registered = RimeRuntimeSelection.resolveRegistered(
                            baseSchemaID: base,
                            layoutRawValue: layout,
                            readinessMarker: marker,
                            onDiskFingerprint: fingerprint,
                            schemeBinding26: base,
                            schemeBinding9: binding,
                            readinessBySchema: distractingReady,
                            installedFamilies: distractingInstalled
                        )
                        XCTAssertEqual(registered.effectiveSchemaID, legacy.effectiveSchemaID)
                        XCTAssertEqual(registered.effectiveLayoutStyle, legacy.effectiveLayoutStyle)
                        XCTAssertEqual(registered.usesT9InputSemantics, legacy.usesT9InputSemantics)
                    }
                }
            }
        }
    }

    func testWanxiangBindingUsesRegisteredReadiness() {
        func selection(ready: Bool, installed: Bool, binding: String) -> RimeRuntimeSelection {
            RimeRuntimeSelection.resolveRegistered(
                baseSchemaID: "wanxiang",
                layoutRawValue: "nine_key",
                readinessMarker: nil,
                onDiskFingerprint: nil,
                schemeBinding26: "wanxiang",
                schemeBinding9: binding,
                readinessBySchema: [wanxiangNineKeyID: ready],
                installedFamilies: installed ? ["wanxiang"] : []
            )
        }

        let ready = selection(ready: true, installed: true, binding: wanxiangNineKeyID)
        XCTAssertEqual(ready.effectiveSchemaID, wanxiangNineKeyID)
        XCTAssertEqual(ready.effectiveLayoutStyle, .nineKey)
        XCTAssertTrue(ready.usesT9InputSemantics)

        for closed in [
            selection(ready: false, installed: true, binding: wanxiangNineKeyID),
            selection(ready: true, installed: false, binding: wanxiangNineKeyID),
            selection(ready: true, installed: true, binding: "not_registered"),
        ] {
            XCTAssertEqual(closed.effectiveLayoutStyle, .twentySixKey)
            XCTAssertFalse(closed.usesT9InputSemantics)
            XCTAssertEqual(closed.effectiveSchemaID, "wanxiang")
        }
    }
}
