import XCTest
@testable import KeyboardCore

final class RimeSchemeNativeUsageGuideTests: XCTestCase {
    func testFogTipsMentionBareRq() {
        let tips = RimeSchemeNativeUsageGuide.advancedInputTips(for: "rime_ice")
        let joined = tips.map(\.examples).joined(separator: " ")
        XCTAssertTrue(joined.contains("rq"))
        XCTAssertFalse(joined.contains("/rq"))
    }

    func testWanxiangTipsMentionSlashOrOPrefixNotBareRqOnly() {
        let tips = RimeSchemeNativeUsageGuide.advancedInputTips(for: "wanxiang")
        let joined = tips.map(\.examples).joined(separator: " ")
        XCTAssertTrue(joined.contains("/rq") || joined.contains("orq"))
        XCTAssertTrue(joined.contains("V"))
        // Must not present fog bare-rq as the primary 万象 recipe.
        XCTAssertFalse(joined.contains("试试 rq、sj"))
    }

    func testWanxiangStatusNoteMentionsNativeTriggers() {
        let note = RimeSchemeNativeUsageGuide.advancedInputStatusNote(for: "wanxiang")
        XCTAssertNotNil(note)
        XCTAssertTrue(note?.contains("/rq") == true || note?.contains("orq") == true)
    }

    func testT9UsageFollowsFogFamily() {
        let fog = RimeSchemeNativeUsageGuide.advancedInputTips(for: "rime_ice")
        let t9 = RimeSchemeNativeUsageGuide.advancedInputTips(for: "t9")
        XCTAssertEqual(fog.map(\.examples), t9.map(\.examples))
    }
}
