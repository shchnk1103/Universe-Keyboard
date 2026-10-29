import Foundation
import XCTest

@testable import KeyboardCore

final class NineKeyRegistryR4Tests: XCTestCase {
    func testRegistryAndValidation() {
        XCTAssertTrue(NineKeySchemeRegistry.isValid(NineKeySchemeRegistry.entries))
        XCTAssertEqual(NineKeySchemeRegistry.scheme("t9")?.familyID, "rime_ice")
        XCTAssertEqual(NineKeySchemeRegistry.scheme("wanxiang_t9i")?.familyID, "wanxiang")
        XCTAssertTrue(SchemeAdapterRegistry.wanxiang.layout.supportsNineKey)
        XCTAssertTrue(SchemeAdapterRegistry.isRegisteredNineKeyCapable("wanxiang_t9i"))
        XCTAssertFalse(RimeRuntimeSelection.isNineKeyCapable("wanxiang_t9i"))
        XCTAssertEqual(RimeSchemeCapabilityMatrix.normalizeRegisteredSchemaID("wanxiang_t9i"), "wanxiang")
        XCTAssertFalse(
            NineKeySchemeRegistry.isValid([
                NineKeyScheme(schemaID: "bad/../x", familyID: "wanxiang", markerKey: "x", compatibilityVersion: "1")
            ]))
        XCTAssertFalse(
            NineKeySchemeRegistry.isValid([NineKeySchemeRegistry.entries[0], NineKeySchemeRegistry.entries[0]]))
        XCTAssertFalse(
            NineKeySchemeRegistry.isValid([
                NineKeyScheme(schemaID: "valid", familyID: "missing", markerKey: "x", compatibilityVersion: "1")
            ]))
    }

    func testSchemeReadinessAndStateTable() {
        let defaults = MemoryNineKeyStore()
        let ice = RimeT9ReadinessMarker(ready: true, compatibilityVersion: "2", resourceFingerprint: "ice")
        let wan = RimeT9ReadinessMarker(ready: true, compatibilityVersion: "1", resourceFingerprint: "wan")
        NineKeyReadiness.save(ice, schemaID: "t9", defaults: defaults)
        NineKeyReadiness.save(wan, schemaID: "wanxiang_t9i", defaults: defaults)
        XCTAssertEqual(NineKeyReadiness.load(schemaID: "t9", defaults: defaults), ice)
        XCTAssertTrue(NineKeyReadiness.isMatched(schemaID: "t9", marker: ice, fingerprint: "ice"))
        XCTAssertTrue(NineKeyReadiness.isMatched(schemaID: "wanxiang_t9i", marker: wan, fingerprint: "wan"))
        XCTAssertFalse(NineKeyReadiness.isMatched(schemaID: "wanxiang_t9i", marker: ice, fingerprint: "ice"))
        NineKeyReadiness.invalidate(schemaID: "wanxiang_t9i", defaults: defaults)
        XCTAssertEqual(NineKeyReadiness.load(schemaID: "t9", defaults: defaults), ice)
        XCTAssertFalse(NineKeyReadiness.load(schemaID: "wanxiang_t9i", defaults: defaults)!.ready)
        func resolve(_ binding: String?, _ ready: [String: Bool], _ installed: Set<String>) -> String {
            RimeRuntimeSelection.resolve(
                baseSchemaID: "wanxiang", layoutRawValue: "nine_key", schemeBinding26: "wanxiang",
                schemeBinding9: binding, readinessBySchema: ready, installedFamilies: installed
            ).effectiveSchemaID
        }
        XCTAssertEqual(resolve(nil, ["t9": true], ["rime_ice"]), "t9")
        XCTAssertEqual(resolve("", ["t9": true], ["rime_ice"]), "t9")
        XCTAssertEqual(resolve(nil, [:], ["rime_ice"]), "wanxiang")
        XCTAssertEqual(resolve("t9", ["t9": true], []), "wanxiang")
        XCTAssertEqual(resolve("wanxiang_t9i", ["wanxiang_t9i": true], ["wanxiang"]), "wanxiang_t9i")
        XCTAssertEqual(resolve("wanxiang_t9i", ["t9": true], ["wanxiang", "rime_ice"]), "wanxiang")
        XCTAssertEqual(resolve("unknown", ["t9": true], ["rime_ice"]), "wanxiang")
    }

    @MainActor
    func testPartialCommitRejectsUnverifiedEngineTails() {
        let samples = ["ya〔表情：👋〕", "ya[", "yalongtail", "emoji", "ya"]
        for tail in samples {
            for withPrefix in [true, false] {
                let engine = FakeRimeEngine(
                    dictionary: ["6442692": ["你好"], "92": ["呀"]],
                    comments: ["6442692": ["ni hao ya"], "92": ["ya"]],
                    preeditFormatter: { raw in raw == "92" ? tail : raw },
                    selectionRemainders: withPrefix ? [:] : ["6442692": [0: "92"]],
                    selectedSegments: withPrefix
                        ? ["6442692": [0: FakeRimeSelectedSegment(rawPrefix: "64426", text: "你好")]] : [:],
                    partialSelectionEmitsCommit: false)
                engine.appendDigitsToComposition = true
                let client = FakeTextInputClient()
                let controller = KeyboardController()
                controller.rimeEngine = engine
                controller.usesT9InputSemantics = true
                controller.textClient = client
                for key in "6442692" { _ = controller.handle(.insertKey(String(key))) }
                _ = controller.handle(
                    .insertCandidate(
                        "你好", kind: .candidate,
                        selectionReference: CandidateSelectionReference(page: 0, indexOnPage: 0)))
                XCTAssertEqual(client.markedText, "你好ya", "tail=\(tail), prefix=\(withPrefix)")
                XCTAssertEqual(controller.state.partialCommit?.remainingPreeditText, "ya")
            }
        }
    }

    func testSourceValidationAndFallback() {
        for fragment in ["〔x〕", "【x】", "[x]", "(x)", "（x）"] {
            XCTAssertEqual(T9PreeditResolver.validatedSource("ni" + fragment), "ni")
        }
        XCTAssertEqual(T9PreeditResolver.validatedSource("NÜ〔表情：👋〕"), "nv")
        XCTAssertEqual(T9PreeditResolver.validatedSource("ni（a[💥]） hao"), "ni hao")
        for value in ["ni[", "ni]", "ni([)]", "nǐ", "ni2", "K", "", " ' "] {
            XCTAssertNil(T9PreeditResolver.validatedSource(value), value)
        }
        XCTAssertEqual(T9PreeditResolver.validatedSource("emoji"), "emoji")
        XCTAssertEqual(
            T9PreeditResolver.visiblePreedit(
                rawInput: "64", candidates: [], highlightedIndex: nil, provisionalPathDisplay: "NI",
                provisionalConsumedSlots: 2), "ni")
        XCTAssertEqual(T9PreeditResolver.visiblePreedit(rawInput: "ni", candidates: [], highlightedIndex: nil), "ni")
        XCTAssertEqual(T9PreeditResolver.visiblePreedit(rawInput: "64", candidates: [], highlightedIndex: nil), "")
        let candidates = [
            RimeCandidate(text: "你", comment: "ni"), RimeCandidate(text: "呢", comment: "ni💥"),
            RimeCandidate(text: "泥", comment: "mi"),
        ]
        XCTAssertEqual(
            T9PreeditResolver.visiblePreedit(rawInput: "64", candidates: candidates, highlightedIndex: 1), "ni")
        XCTAssertEqual(
            T9PreeditResolver.visiblePreedit(rawInput: "64", candidates: candidates, highlightedIndex: 2), "mi")
    }
}

private final class MemoryNineKeyStore: NineKeySettingsStore {
    private var values: [String: Any] = [:]
    func data(forKey key: String) -> Data? { values[key] as? Data }
    func set(_ value: Any?, forKey key: String) { values[key] = value }
}
