import XCTest

@testable import KeyboardCore

final class RimeUserDictionarySettingsTests: XCTestCase {
    func testDefaultsEnableBuiltInPinyinSchemas() {
        let settings = RimeUserDictionarySettings()

        XCTAssertTrue(settings.isEnabled(for: "luna_pinyin"))
        XCTAssertTrue(settings.isEnabled(for: "rime_ice"))
    }

    func testSchemaSpecificSwitchesAreIndependent() {
        let settings = RimeUserDictionarySettings(
            lunaPinyinEnabled: false,
            rimeIceEnabled: true
        )

        XCTAssertFalse(settings.isEnabled(for: "luna_pinyin"))
        XCTAssertTrue(settings.isEnabled(for: "rime_ice"))
    }

    func testDeploymentSignatureCapturesBothSchemas() {
        let settings = RimeUserDictionarySettings(
            lunaPinyinEnabled: false,
            rimeIceEnabled: true
        )

        XCTAssertEqual(settings.deploymentSignature(), "luna_pinyin=0;rime_ice=1")
    }
}
