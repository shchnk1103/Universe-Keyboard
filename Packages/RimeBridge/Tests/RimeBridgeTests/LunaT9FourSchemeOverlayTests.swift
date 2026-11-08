import CryptoKit
import Foundation
import KeyboardCore
import XCTest

@testable import RimeBridge

/// Same inputs through the shared overlay emitter for the four schemes that
/// already existed before luna_pinyin_t9. Baseline bytes must come from the
/// archived planner at 81e181502f580300fa6152411641be636ef13146.
/// Fixture SHA-256: e1d2af1ef1abc2b51589c62fc2838fe77f39b8127becc31696bcf80d1a20d592.
@MainActor
final class LunaT9FourSchemeOverlayTests: XCTestCase {
    func testFourExistingSchemesMatchBaselineOverlayBytes() throws {
        let baselineURL = URL(fileURLWithPath: #filePath).deletingLastPathComponent()
            .appendingPathComponent("Fixtures/LunaT9/baseline-overlays.json")
        let fuzzy = RimeFuzzyPinyinSettings(enabled: true)
        var candidate: [String: String] = [:]
        for schema in ["luna_pinyin", "rime_ice", "wanxiang", "wanxiang_t9i"] {
            let content = try XCTUnwrap(
                RimeConfigManager.makeSchemaCustomYamlContent(
                    schemaID: schema,
                    userDictionaryEnabled: true,
                    fuzzyPinyinSettings: fuzzy
                )
            )
            candidate[schema] = content
        }
        let data = try JSONSerialization.data(withJSONObject: candidate, options: [.sortedKeys])
        try data.write(
            to: LunaT9EvidenceRoot.directory("output").appendingPathComponent("candidate-overlays.json"),
            options: .withoutOverwriting
        )
        let baseline = try XCTUnwrap(
            JSONSerialization.jsonObject(with: Data(contentsOf: baselineURL)) as? [String: String]
        )
        XCTAssertEqual(candidate, baseline)
    }
}
