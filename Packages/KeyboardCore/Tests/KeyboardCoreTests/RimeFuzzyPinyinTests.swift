import XCTest

@testable import KeyboardCore

final class RimeFuzzyPinyinTests: XCTestCase {
    func testDefaultSettingsEnableCommonInitialFuzzyRules() {
        let settings = RimeFuzzyPinyinSettings()

        XCTAssertTrue(settings.zhZEnabled)
        XCTAssertTrue(settings.chCEnabled)
        XCTAssertTrue(settings.shSEnabled)
        XCTAssertTrue(settings.nLEnabled)
        XCTAssertEqual(
            settings.algebraRules,
            [
                "derive/^zh/z/",
                "derive/^z/zh/",
                "derive/^ch/c/",
                "derive/^c/ch/",
                "derive/^sh/s/",
                "derive/^s/sh/",
                "derive/^n/l/",
                "derive/^l/n/",
            ]
        )
    }

    func testRuleGeneratorOmitsDisabledGroups() {
        let settings = RimeFuzzyPinyinSettings(
            zhZEnabled: true,
            chCEnabled: false,
            shSEnabled: false,
            nLEnabled: true
        )

        XCTAssertEqual(
            settings.algebraRules,
            [
                "derive/^zh/z/",
                "derive/^z/zh/",
                "derive/^n/l/",
                "derive/^l/n/",
            ]
        )
    }

    func testPostProcessorAppendsManagedBlockToExistingAlgebra() {
        let yaml = """
        schema:
          schema_id: luna_pinyin
        speller:
          alphabet: zyxwvutsrqponmlkjihgfedcba
          algebra:
            - erase/^xx$/
            - abbrev/^([a-z]).+$/$1/
        translator:
          dictionary: luna_pinyin
        """

        let result = RimeFuzzyPinyinPostProcessor.apply(settings: .init(), to: yaml)

        XCTAssertEqual(result.status, .updated)
        XCTAssertTrue(result.yaml.contains("    # universe:fuzzy-pinyin begin"))
        XCTAssertTrue(result.yaml.contains("    - derive/^zh/z/"))
        XCTAssertTrue(result.yaml.contains("    - derive/^l/n/"))
        XCTAssertTrue(result.yaml.contains("    # universe:fuzzy-pinyin end"))
        XCTAssertTrue(result.yaml.contains("    - erase/^xx$/"))
    }

    func testPostProcessorIsIdempotent() {
        let yaml = """
        schema:
          schema_id: luna_pinyin
        speller:
          algebra:
            - erase/^xx$/
        """

        let first = RimeFuzzyPinyinPostProcessor.apply(settings: .init(), to: yaml)
        let second = RimeFuzzyPinyinPostProcessor.apply(settings: .init(), to: first.yaml)

        XCTAssertEqual(second.status, .unchanged)
        XCTAssertEqual(second.yaml.components(separatedBy: RimeFuzzyPinyinPostProcessor.beginMarker).count - 1, 1)
    }

    func testPostProcessorRemovesManagedBlockWhenAllRulesDisabled() {
        let withBlock = """
        schema:
          schema_id: luna_pinyin
        speller:
          algebra:
            - erase/^xx$/
            # universe:fuzzy-pinyin begin
            - derive/^zh/z/
            # universe:fuzzy-pinyin end
        """
        let disabled = RimeFuzzyPinyinSettings(
            zhZEnabled: false,
            chCEnabled: false,
            shSEnabled: false,
            nLEnabled: false
        )

        let result = RimeFuzzyPinyinPostProcessor.apply(settings: disabled, to: withBlock)

        XCTAssertEqual(result.status, .removed)
        XCTAssertFalse(result.yaml.contains(RimeFuzzyPinyinPostProcessor.beginMarker))
        XCTAssertTrue(result.yaml.contains("    - erase/^xx$/"))
    }

    func testPostProcessorCreatesAlgebraInsideExistingSpeller() {
        let yaml = """
        schema:
          schema_id: test
        speller:
          alphabet: zyxwvutsrqponmlkjihgfedcba
        translator:
          dictionary: test
        """

        let result = RimeFuzzyPinyinPostProcessor.apply(settings: .init(zhZEnabled: true, chCEnabled: false, shSEnabled: false, nLEnabled: false), to: yaml)

        XCTAssertEqual(result.status, .updated)
        XCTAssertTrue(result.yaml.contains("  algebra:\n    # universe:fuzzy-pinyin begin\n    - derive/^zh/z/"))
        XCTAssertTrue(result.yaml.contains("translator:"))
    }

    func testPostProcessorSkipsSchemaWithoutSpeller() {
        let yaml = """
        schema:
          schema_id: test
        translator:
          dictionary: test
        """

        let result = RimeFuzzyPinyinPostProcessor.apply(settings: .init(), to: yaml)

        XCTAssertEqual(result.status, .skippedNoSpeller)
        XCTAssertEqual(result.yaml, yaml)
    }
}
