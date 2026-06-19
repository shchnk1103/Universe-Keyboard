import XCTest

@testable import KeyboardCore

final class RimeAdvancedInputSettingsTests: XCTestCase {
    func testDisabledComponentsUsesMasterSwitch() {
        let settings = RimeAdvancedInputSettings(masterEnabled: false)
        let disabled = settings.disabledComponentNames(supportedFeatures: [.dateTime, .calculator])

        XCTAssertEqual(disabled, ["date_translator", "calc_translator"])
    }

    func testDisabledComponentsOnlyIncludesSupportedDisabledFeatures() {
        let settings = RimeAdvancedInputSettings(
            featureEnabled: [
                .dateTime: false,
                .calculator: false,
                .uuid: false,
            ]
        )

        let disabled = settings.disabledComponentNames(supportedFeatures: [.dateTime, .uuid])

        XCTAssertEqual(disabled, ["date_translator", "uuid"])
    }

    func testEachFeatureMapsToAtLeastOneRuntimeComponent() {
        for feature in RimeAdvancedInputFeature.allCases {
            XCTAssertFalse(feature.componentNames.isEmpty, "\(feature.rawValue) should map to runtime components")
        }
    }

    func testDeploymentSignatureIncludesActiveSchemeSupportAndFeatureState() {
        let settings = RimeAdvancedInputSettings(
            masterEnabled: true,
            featureEnabled: [.dateTime: false, .calculator: true]
        )

        let signature = settings.deploymentSignature(
            activeSchemaID: "rime_ice",
            supportedFeatures: [.dateTime, .calculator]
        )

        XCTAssertTrue(signature.contains("schema=rime_ice"))
        XCTAssertTrue(signature.contains("master=1"))
        XCTAssertTrue(signature.contains("dateTime=0:1"))
        XCTAssertTrue(signature.contains("calculator=1:1"))
        XCTAssertTrue(signature.contains("uuid=1:0"))
    }

    func testPostProcessorDisablesAndRestoresComponentsFromBackup() throws {
        let directory = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent("advanced-input-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let schemaURL = directory.appendingPathComponent("rime_ice.schema.yaml")
        let original = """
        engine:
          translators:
            - lua_translator@*date_translator
              date_locale: zh
            - lua_translator@*calc_translator
            - script_translator
          filters:
            - lua_filter@*corrector
            - simplifier
        """
        try original.write(to: schemaURL, atomically: true, encoding: .utf8)

        let disabledResult = RimeAdvancedInputPostProcessor.apply(
            settings: RimeAdvancedInputSettings(featureEnabled: [.dateTime: false]),
            supportedFeatures: [.dateTime, .calculator, .correction],
            schemaURL: schemaURL
        )
        let disabledYaml = try String(contentsOf: schemaURL, encoding: .utf8)

        XCTAssertEqual(disabledResult.disabledComponentNames, ["date_translator"])
        XCTAssertFalse(disabledYaml.contains("date_translator"))
        XCTAssertFalse(disabledYaml.contains("date_locale"))
        XCTAssertTrue(disabledYaml.contains("calc_translator"))
        XCTAssertTrue(disabledYaml.contains("corrector"))

        let restoredResult = RimeAdvancedInputPostProcessor.apply(
            settings: RimeAdvancedInputSettings(),
            supportedFeatures: [.dateTime, .calculator, .correction],
            schemaURL: schemaURL
        )
        let restoredYaml = try String(contentsOf: schemaURL, encoding: .utf8)

        XCTAssertEqual(restoredResult.status, .restoredAllFeatures)
        XCTAssertEqual(restoredYaml, original)
    }

    func testPostProcessorMasterSwitchDisablesAllSupportedFeatures() throws {
        let directory = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent("advanced-input-master-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let schemaURL = directory.appendingPathComponent("rime_ice.schema.yaml")
        let original = """
        engine:
          translators:
            - lua_translator@*date_translator
            - lua_translator@*calc_translator
            - script_translator
          filters:
            - lua_filter@*corrector
            - simplifier
        """
        try original.write(to: schemaURL, atomically: true, encoding: .utf8)

        let result = RimeAdvancedInputPostProcessor.apply(
            settings: RimeAdvancedInputSettings(masterEnabled: false),
            supportedFeatures: [.dateTime, .calculator, .correction],
            schemaURL: schemaURL
        )
        let processedYaml = try String(contentsOf: schemaURL, encoding: .utf8)

        XCTAssertEqual(result.disabledComponentNames, ["calc_translator", "corrector", "date_translator"])
        XCTAssertFalse(processedYaml.contains("date_translator"))
        XCTAssertFalse(processedYaml.contains("calc_translator"))
        XCTAssertFalse(processedYaml.contains("corrector"))
        XCTAssertTrue(processedYaml.contains("script_translator"))
        XCTAssertTrue(processedYaml.contains("simplifier"))
    }
}
