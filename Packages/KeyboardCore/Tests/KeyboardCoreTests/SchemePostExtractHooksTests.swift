import XCTest

@testable import KeyboardCore

final class SchemePostExtractHooksTests: XCTestCase {

    func testPostExtractHooksIceOnly() {
        XCTAssertEqual(
            SchemeAdapterRegistry.postExtractHooks(for: "rime_ice").kind,
            .iceT9SanitizeAndPreDeploy
        )
        XCTAssertEqual(
            SchemeAdapterRegistry.postExtractHooks(for: "t9").kind,
            .iceT9SanitizeAndPreDeploy
        )
        XCTAssertEqual(
            SchemeAdapterRegistry.postExtractHooks(for: "wanxiang").kind,
            .none
        )
        XCTAssertEqual(
            SchemeAdapterRegistry.postExtractHooks(for: "luna_pinyin").kind,
            .none
        )
        XCTAssertEqual(
            SchemeAdapterRegistry.postExtractHooks(for: "unknown_scheme").kind,
            .none
        )
        XCTAssertTrue(SchemeAdapterRegistry.shouldSanitizeT9OnExtract(for: "rime_ice"))
        XCTAssertTrue(SchemeAdapterRegistry.shouldEnsureCompatibleT9PreDeploy(for: "rime_ice"))
        XCTAssertTrue(SchemeAdapterRegistry.shouldSanitizeT9OnExtract(for: "t9"))
        XCTAssertFalse(SchemeAdapterRegistry.shouldSanitizeT9OnExtract(for: "wanxiang"))
        XCTAssertFalse(SchemeAdapterRegistry.shouldEnsureCompatibleT9PreDeploy(for: "luna_pinyin"))
    }
}
