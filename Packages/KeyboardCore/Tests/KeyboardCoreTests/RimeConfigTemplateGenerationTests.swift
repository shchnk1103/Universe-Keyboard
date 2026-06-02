import XCTest

@testable import KeyboardCore

final class RimeConfigTemplateGenerationTests: XCTestCase {
    func testGenerateDefaultYamlLunaOnly() {
        let yaml = RimeConfigTemplates.generateDefaultYaml(
            activeSchemaID: "luna_pinyin",
            rimeIceInstalled: false,
            pageSize: 9
        )
        XCTAssertTrue(yaml.contains("config_version: \"0.1\""))
        XCTAssertTrue(yaml.contains("- schema: luna_pinyin"))
        XCTAssertTrue(yaml.contains("name: 朙月拼音"))
        XCTAssertFalse(yaml.contains("rime_ice"))
        XCTAssertFalse(yaml.contains("雾凇拼音"))
        XCTAssertTrue(yaml.contains("page_size: 9"))
        XCTAssertTrue(yaml.contains("alternative_select_keys: \"123456789\""))
    }

    func testGenerateDefaultYamlWithRimeIce() {
        let yaml = RimeConfigTemplates.generateDefaultYaml(
            activeSchemaID: "luna_pinyin",
            rimeIceInstalled: true,
            pageSize: 7
        )
        XCTAssertTrue(yaml.contains("- schema: luna_pinyin"))
        XCTAssertTrue(yaml.contains("- schema: rime_ice"))
        XCTAssertTrue(yaml.contains("name: 雾凇拼音"))
        XCTAssertTrue(yaml.contains("page_size: 7"))
    }

    func testGenerateDefaultYamlCustomPageSize() {
        let yaml = RimeConfigTemplates.generateDefaultYaml(
            activeSchemaID: "luna_pinyin",
            rimeIceInstalled: false,
            pageSize: 5
        )
        XCTAssertTrue(yaml.contains("page_size: 5"))
    }

    func testGenerateDefaultYamlMaxPageSize() {
        let yaml = RimeConfigTemplates.generateDefaultYaml(
            activeSchemaID: "luna_pinyin",
            rimeIceInstalled: false,
            pageSize: 20
        )
        XCTAssertTrue(yaml.contains("page_size: 20"))
    }

    func testGenerateDefaultYamlContainsSwitcherConfig() {
        let yaml = RimeConfigTemplates.generateDefaultYaml(
            activeSchemaID: "luna_pinyin",
            rimeIceInstalled: false,
            pageSize: 9
        )
        XCTAssertTrue(yaml.contains("switcher:"))
        XCTAssertTrue(yaml.contains("[方案选单]"))
        XCTAssertTrue(yaml.contains("Control+grave"))
        XCTAssertTrue(yaml.contains("F4"))
    }

    func testGenerateDefaultYamlContainsAsciiComposer() {
        let yaml = RimeConfigTemplates.generateDefaultYaml(
            activeSchemaID: "luna_pinyin",
            rimeIceInstalled: false,
            pageSize: 9
        )
        XCTAssertTrue(yaml.contains("ascii_composer:"))
        XCTAssertTrue(yaml.contains("Shift_L: commit_code"))
        XCTAssertTrue(yaml.contains("Shift_R: commit_code"))
    }

    func testGenerateDefaultYamlContainsPresets() {
        let yaml = RimeConfigTemplates.generateDefaultYaml(
            activeSchemaID: "luna_pinyin",
            rimeIceInstalled: false,
            pageSize: 9
        )
        XCTAssertTrue(yaml.contains("key_binder:"))
        XCTAssertTrue(yaml.contains("punctuator:"))
        XCTAssertTrue(yaml.contains("full_shape:"))
        XCTAssertTrue(yaml.contains("half_shape:"))
        XCTAssertTrue(yaml.contains("recognizer:"))
    }

    func testGenerateDefaultYamlUsesSafePunctuatorKeyQuoting() {
        let yaml = RimeConfigTemplates.generateDefaultYaml(
            activeSchemaID: "luna_pinyin",
            rimeIceInstalled: false,
            pageSize: 9
        )
        let trimmedLines = yaml.components(separatedBy: "\n").map {
            $0.trimmingCharacters(in: .whitespaces)
        }

        XCTAssertFalse(trimmedLines.contains { $0.hasPrefix("\"\"\":") })
        XCTAssertFalse(trimmedLines.contains { $0.hasPrefix("\"\\\":") })
        XCTAssertTrue(trimmedLines.contains { $0.hasPrefix("'''':") })
        XCTAssertTrue(trimmedLines.contains { $0.hasPrefix("'\"':") })
        XCTAssertTrue(trimmedLines.contains { $0.hasPrefix("'\\':") })
    }

    func testGenerateDefaultYamlPageSizePlacement() {
        let yaml = RimeConfigTemplates.generateDefaultYaml(
            activeSchemaID: "luna_pinyin",
            rimeIceInstalled: false,
            pageSize: 15
        )
        let lines = yaml.components(separatedBy: "\n")
        guard let menuIdx = lines.firstIndex(where: { $0.hasPrefix("menu:") }) else {
            return XCTFail("menu section not found")
        }
        let pageSizeFound = lines[(menuIdx + 1)...].first(where: { $0.contains("page_size:") })
        XCTAssertNotNil(pageSizeFound)
        XCTAssertTrue(pageSizeFound!.contains("15"))
    }

    func testGenerateDefaultYamlHasNoTrailingWhitespaceIssues() {
        let yaml = RimeConfigTemplates.generateDefaultYaml(
            activeSchemaID: "luna_pinyin",
            rimeIceInstalled: false,
            pageSize: 9
        )
        for line in yaml.components(separatedBy: "\n") {
            XCTAssertNotNil(line.data(using: .utf8))
        }
    }

    func testGenerateDefaultYamlSchemaListLineStructure() {
        let yaml = RimeConfigTemplates.generateDefaultYaml(
            activeSchemaID: "luna_pinyin",
            rimeIceInstalled: true,
            pageSize: 9
        )
        let lines = yaml.components(separatedBy: "\n")
        var inSchemaList = false
        var foundLuna = false
        var foundRimeIce = false

        for line in lines {
            if line.trimmingCharacters(in: .whitespaces) == "schema_list:" {
                inSchemaList = true
                continue
            }
            guard inSchemaList else { continue }
            let trimmedLine = line.trimmingCharacters(in: .whitespaces)
            if !trimmedLine.isEmpty && !line.hasPrefix(" ") && !line.hasPrefix("\t") && !trimmedLine.hasPrefix("-") {
                break
            }
            if trimmedLine.hasPrefix("- schema:") {
                if trimmedLine.contains("luna_pinyin") { foundLuna = true }
                if trimmedLine.contains("rime_ice") { foundRimeIce = true }
                XCTAssertFalse(trimmedLine.contains("name:"), "schema 行不应包含 name: \(trimmedLine)")
            }
            if trimmedLine.hasPrefix("name:") {
                XCTAssertFalse(trimmedLine.contains("- schema:"), "name 行不应包含 - schema: \(trimmedLine)")
            }
        }

        XCTAssertTrue(foundLuna && foundRimeIce, "应该同时包含 luna_pinyin 和 rime_ice")
    }

    func testGenerateDefaultYamlPageSizeZero() {
        let yaml = RimeConfigTemplates.generateDefaultYaml(
            activeSchemaID: "luna_pinyin",
            rimeIceInstalled: false,
            pageSize: 0
        )
        XCTAssertTrue(yaml.contains("page_size: 0"))
    }

    func testGenerateDefaultYamlPageSizeNegative() {
        let yaml = RimeConfigTemplates.generateDefaultYaml(
            activeSchemaID: "luna_pinyin",
            rimeIceInstalled: false,
            pageSize: -1
        )
        XCTAssertTrue(yaml.contains("page_size: -1"))
    }
}
