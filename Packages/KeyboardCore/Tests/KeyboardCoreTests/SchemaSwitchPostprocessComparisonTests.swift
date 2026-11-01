import CryptoKit
import XCTest

@testable import KeyboardCore

/// Compares switch identity before and after the production post-processors.
/// Fixed-source equality is not a guarantee for an arbitrary user copy.
final class SchemaSwitchPostprocessComparisonTests: XCTestCase {
    func testListedCombinationsKeepSwitchIdentity() throws {
        let ice = try fixedSource("SWITCH_RESOLVER_RIME_ICE", expectedSHA256: iceSHA)
        let wanxiang = try fixedSource("SWITCH_RESOLVER_WANXIANG", expectedSHA256: wanxiangSHA)
        let t9 = try fixedSource("SWITCH_RESOLVER_T9", expectedSHA256: t9SHA)
        let fuzzy = RimeFuzzyPinyinSettings(
            enabled: true,
            zhZEnabled: true,
            chCEnabled: true,
            shSEnabled: true,
            nLEnabled: true
        )
        let disabled = RimeAdvancedInputSettings(masterEnabled: false)
            .disabledComponentNames(supportedFeatures: Set(RimeAdvancedInputFeature.allCases))

        assertSameIdentity(ice, ice, label: "rime_ice-original")
        assertSameIdentity(
            ice,
            RimeAdvancedInputPostProcessor.previewRemovingDisabledComponents(disabled, from: ice),
            label: "rime_ice-advanced"
        )
        assertSameIdentity(
            ice,
            RimeFuzzyPinyinPostProcessor.apply(settings: fuzzy, to: ice).yaml,
            label: "rime_ice-fuzzy"
        )
        let iceBoth = RimeFuzzyPinyinPostProcessor.apply(
            settings: fuzzy,
            to: RimeAdvancedInputPostProcessor.previewRemovingDisabledComponents(disabled, from: ice)
        ).yaml
        assertSameIdentity(ice, iceBoth, label: "rime_ice-advanced-and-fuzzy")
        assertSameIdentity(
            ice,
            RimeConfigPostProcessor.stripLuaDependencies(from: ice),
            label: "rime_ice-stripLua"
        )

        XCTAssertEqual(SchemaSwitchResolver.recognize(t9).failure, .switchesPatched, "t9-original")
        let compatible = try T9SchemaCompatibility.makeCompatibleSchema(fromUpstreamYAML: t9)
        XCTAssertEqual(
            SchemaSwitchResolver.recognize(compatible).failure,
            .switchesPatched,
            "t9-compatibility"
        )

        assertSameIdentity(wanxiang, wanxiang, label: "wanxiang-original")
        assertSameIdentity(
            wanxiang,
            RimeFuzzyPinyinPostProcessor.apply(settings: fuzzy, to: wanxiang).yaml,
            label: "wanxiang-fuzzy"
        )
    }

    private func assertSameIdentity(_ before: String, _ after: String, label: String) {
        let left = SchemaSwitchResolver.recognize(before).identity
        let right = SchemaSwitchResolver.recognize(after).identity
        XCTAssertEqual(left, right, label)
        XCTAssertNotNil(left, label)
    }

    private func fixedSource(_ name: String, expectedSHA256: String) throws -> String {
        guard let path = ProcessInfo.processInfo.environment[name] else {
            throw XCTSkip("\(name) is unset")
        }
        let text = try String(contentsOfFile: path, encoding: .utf8)
        XCTAssertEqual(sha256(text), expectedSHA256)
        return text
    }

    private func sha256(_ text: String) -> String {
        SHA256.hash(data: Data(text.utf8)).map { String(format: "%02x", $0) }.joined()
    }

    private let iceSHA = "ec4b0dd02ac287f53fe401f315cde648913eb60bb8cf8d9a8a613d1eb4f9698b"
    private let wanxiangSHA = "e52cc55fb71157c72098c44e5cd79deb58f5538dcd76c7f1b27648ae91a204b7"
    private let t9SHA = "56bc593d2c846666361b3394bdc0bdb0c6f1a663f1fd810dceab2d222b5bf8f6"
}

extension Result where Success == [SchemaSwitchResolver.Item], Failure == SchemaSwitchResolver.Failure {
    fileprivate var failure: SchemaSwitchResolver.Failure? {
        switch self {
        case .success:
            return nil
        case .failure(let failure):
            return failure
        }
    }

    fileprivate var identity: [String]? {
        guard case .success(let items) = self else { return nil }
        return items.map { item in
            let options = item.options?.joined(separator: ",") ?? ""
            let states = item.states?.joined(separator: ",") ?? ""
            let reset = item.reset.map(String.init) ?? ""
            return "\(item.index)|\(item.name ?? "")|\(options)|\(states)|\(reset)"
        }
    }
}
