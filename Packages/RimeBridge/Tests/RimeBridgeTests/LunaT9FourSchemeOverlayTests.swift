import CryptoKit
import Foundation
import KeyboardCore
import XCTest

@testable import RimeBridge

/// Same inputs through the shared overlay emitter for the four schemes that
/// already existed before luna_pinyin_t9. Baseline bytes come from the archived
/// planner source compiled in scratch, not from this candidate alone.
@MainActor
final class LunaT9FourSchemeOverlayTests: XCTestCase {
    func testFourExistingSchemesMatchBaselineOverlayBytes() throws {
        let baselineURL = URL(
            fileURLWithPath:
                "/Users/doubleshy0n/.kos-work/Universe-Keyboard/LUNA-PLANNER-IMPL-001/scratch/impl-b/baseline-overlays.json"
        )
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
            to: URL(
                fileURLWithPath:
                    "/Users/doubleshy0n/.kos-work/Universe-Keyboard/LUNA-PLANNER-IMPL-001/scratch/impl-b/candidate-overlays.json"
            )
        )
        let baseline = try XCTUnwrap(
            JSONSerialization.jsonObject(with: Data(contentsOf: baselineURL)) as? [String: String]
        )
        XCTAssertEqual(candidate, baseline)
    }
}
