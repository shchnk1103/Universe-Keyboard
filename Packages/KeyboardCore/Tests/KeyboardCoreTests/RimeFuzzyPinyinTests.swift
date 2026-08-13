import XCTest

@testable import KeyboardCore

final class RimeFuzzyPinyinTests: XCTestCase {
    func testDefaultSettingsEnableCommonInitialFuzzyRules() {
        let settings = RimeFuzzyPinyinSettings()

        XCTAssertTrue(settings.enabled)
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

    func testDisabledMasterSwitchProducesNoRules() {
        let settings = RimeFuzzyPinyinSettings(enabled: false)

        XCTAssertFalse(settings.hasEnabledRules)
        XCTAssertEqual(settings.algebraRules, [])
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

    func testPostProcessorLeavesOfficialWanxiangAlgebraUnchanged() {
        let yaml = """
            schema:
              schema_id: wanxiang
            speller:
              alphabet: zyxwvutsrqponmlkjihgfedcba
              algebra:
                __patch:
                  #- 模糊音
                  - wanxiang_algebra:/base/全拼  #拼音转双拼码
            recognizer:
              import_preset: default
            """

        let result = RimeFuzzyPinyinPostProcessor.apply(settings: .init(), to: yaml)

        XCTAssertEqual(result.status, .unchanged)
        XCTAssertEqual(result.yaml, yaml)
        XCTAssertFalse(result.yaml.contains(RimeFuzzyPinyinPostProcessor.beginMarker))
        XCTAssertFalse(result.yaml.contains("wanxiang_algebra:/模糊音_"))
    }

    func testPostProcessorRepairsPreviouslyMisnestedWanxiangManagedBlock() {
        let malformedYaml = """
            schema:
              schema_id: wanxiang
            speller:
              algebra:
                __patch:
                  - wanxiang_algebra:/base/全拼
                # universe:fuzzy-pinyin begin
                - derive/^zh/z/
                # universe:fuzzy-pinyin end
            recognizer:
              import_preset: default
            """

        let result = RimeFuzzyPinyinPostProcessor.apply(settings: .init(), to: malformedYaml)

        XCTAssertEqual(result.status, .removed)
        XCTAssertTrue(result.yaml.contains("      - wanxiang_algebra:/base/全拼"))
        XCTAssertFalse(result.yaml.contains("      - derive/^zh/z/"))
        XCTAssertFalse(result.yaml.contains(RimeFuzzyPinyinPostProcessor.beginMarker))
        XCTAssertFalse(result.yaml.contains("wanxiang_algebra:/模糊音_"))
    }

    func testPostProcessorRemovesPreviouslyGeneratedWanxiangPatchBlockIdempotently() {
        let previousOutput = """
            schema:
              schema_id: wanxiang
            speller:
              algebra:
                __patch:
                  #- 模糊音
                  - wanxiang_algebra:/base/全拼  #拼音转双拼码
                  # universe:fuzzy-pinyin begin
                  - wanxiang_algebra:/模糊音_z_zh
                  - wanxiang_algebra:/模糊音_c_ch
                  - wanxiang_algebra:/模糊音_s_sh
                  - wanxiang_algebra:/模糊音_nl
                  # universe:fuzzy-pinyin end
            """
        let expectedCleanup = """
            schema:
              schema_id: wanxiang
            speller:
              algebra:
                __patch:
                  #- 模糊音
                  - wanxiang_algebra:/base/全拼  #拼音转双拼码
            """

        let first = RimeFuzzyPinyinPostProcessor.apply(settings: .init(), to: previousOutput)
        let second = RimeFuzzyPinyinPostProcessor.apply(settings: .init(), to: first.yaml)

        XCTAssertEqual(first.status, .removed)
        XCTAssertEqual(first.yaml, expectedCleanup)
        XCTAssertFalse(first.yaml.contains(RimeFuzzyPinyinPostProcessor.beginMarker))
        XCTAssertFalse(first.yaml.contains("wanxiang_algebra:/模糊音_"))
        XCTAssertEqual(second.status, .unchanged)
        XCTAssertEqual(second.yaml, first.yaml)
    }

    func testPostProcessorDoesNotApplyManagedFuzzySettingsToWanxiang() {
        let yaml = """
            schema:
              schema_id: wanxiang
            speller:
              algebra:
                __patch:
                  - wanxiang_algebra:/base/全拼
            """
        let settings = RimeFuzzyPinyinSettings(
            zhZEnabled: false,
            chCEnabled: true,
            shSEnabled: false,
            nLEnabled: true
        )

        let result = RimeFuzzyPinyinPostProcessor.apply(settings: settings, to: yaml)

        XCTAssertEqual(result.status, .unchanged)
        XCTAssertEqual(result.yaml, yaml)
        XCTAssertFalse(result.yaml.contains("wanxiang_algebra:/模糊音_"))
    }

    func testPostProcessorSkipsUnknownAlgebraMappingInsteadOfProducingInvalidYaml() {
        let yaml = """
            schema:
              schema_id: custom
            speller:
              algebra:
                derive_rules:
                  - derive/^n/l/
            """

        let result = RimeFuzzyPinyinPostProcessor.apply(settings: .init(), to: yaml)

        XCTAssertEqual(result.status, .skippedUnsupportedAlgebra)
        XCTAssertEqual(result.yaml, yaml)
    }

    func testPostProcessorRemovesOwnedBlockFromUnknownWanxiangPatchWithoutAddingRules() {
        let yaml = """
            schema:
              schema_id: wanxiang
            speller:
              algebra:
                __patch:
                  - wanxiang_algebra:/unknown
                  # universe:fuzzy-pinyin begin
                  - wanxiang_algebra:/模糊音_nl
                  # universe:fuzzy-pinyin end
            """

        let result = RimeFuzzyPinyinPostProcessor.apply(settings: .init(), to: yaml)

        XCTAssertEqual(result.status, .removed)
        XCTAssertTrue(result.yaml.contains("- wanxiang_algebra:/unknown"))
        XCTAssertFalse(result.yaml.contains(RimeFuzzyPinyinPostProcessor.beginMarker))
        XCTAssertFalse(result.yaml.contains("wanxiang_algebra:/模糊音_"))
    }

    func testPostProcessorRejectsWanxiangAnchorInAnotherSchema() {
        let yaml = """
            schema:
              schema_id: custom
            speller:
              algebra:
                __patch:
                  - wanxiang_algebra:/base/全拼
            """

        let result = RimeFuzzyPinyinPostProcessor.apply(settings: .init(), to: yaml)

        XCTAssertEqual(result.status, .skippedUnsupportedAlgebra)
        XCTAssertEqual(result.yaml, yaml)
    }

    func testPostProcessorLeavesWanxiangWithoutAlgebraUnchanged() {
        let yaml = """
            schema:
              schema_id: wanxiang
            speller:
              alphabet: zyxwvutsrqponmlkjihgfedcba
            """

        let result = RimeFuzzyPinyinPostProcessor.apply(settings: .init(), to: yaml)

        XCTAssertEqual(result.status, .unchanged)
        XCTAssertEqual(result.yaml, yaml)
    }

    func testPostProcessorLeavesWanxiangListAlgebraUnchanged() {
        let yaml = """
            schema:
              schema_id: wanxiang
            speller:
              algebra:
                - derive/^n/l/
            """

        let result = RimeFuzzyPinyinPostProcessor.apply(settings: .init(), to: yaml)

        XCTAssertEqual(result.status, .unchanged)
        XCTAssertEqual(result.yaml, yaml)
    }

    func testPostProcessorLeavesWanxiangEmptyAlgebraUnchanged() {
        let yaml = """
            schema:
              schema_id: wanxiang
            speller:
              algebra:
                # upstream structure unavailable
            """

        let result = RimeFuzzyPinyinPostProcessor.apply(settings: .init(), to: yaml)

        XCTAssertEqual(result.status, .unchanged)
        XCTAssertEqual(result.yaml, yaml)
    }

    func testPostProcessorLeavesWanxiangCustomAnchorUnchanged() {
        let yaml = """
            schema:
              schema_id: wanxiang
            speller:
              algebra:
                __patch:
                  - wanxiang_algebra:/base/全拼#unknown
            """

        let result = RimeFuzzyPinyinPostProcessor.apply(settings: .init(), to: yaml)

        XCTAssertEqual(result.status, .unchanged)
        XCTAssertEqual(result.yaml, yaml)
    }

    func testPostProcessorRejectsMalformedManagedMarkersWithoutChangingYaml() {
        let variants = [
            """
            speller:
              algebra:
                # universe:fuzzy-pinyin begin
                - derive/^zh/z/
            """,
            """
            speller:
              algebra:
                # universe:fuzzy-pinyin end
            """,
            """
            speller:
              algebra:
                # universe:fuzzy-pinyin end
                # universe:fuzzy-pinyin begin
            """,
            """
            speller:
              algebra:
                # universe:fuzzy-pinyin begin
                # universe:fuzzy-pinyin end
                # universe:fuzzy-pinyin begin
                # universe:fuzzy-pinyin end
            """,
            """
            speller:
              algebra:
                # universe:fuzzy-pinyin begin
                - derive/^zh/z/
              # universe:fuzzy-pinyin end
            """,
            """
            # universe:fuzzy-pinyin begin
            speller:
              algebra:
                - derive/^zh/z/
            # universe:fuzzy-pinyin end
            """,
        ]

        for yaml in variants {
            let result = RimeFuzzyPinyinPostProcessor.apply(settings: .init(), to: yaml)
            XCTAssertEqual(result.status, .skippedMalformedManagedBlock)
            XCTAssertEqual(result.yaml, yaml)
        }
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

    func testPostProcessorRemovesManagedBlockWhenMasterSwitchDisabled() {
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

        let result = RimeFuzzyPinyinPostProcessor.apply(settings: .init(enabled: false), to: withBlock)

        XCTAssertEqual(result.status, .removed)
        XCTAssertFalse(result.yaml.contains(RimeFuzzyPinyinPostProcessor.beginMarker))
        XCTAssertTrue(result.yaml.contains("    - erase/^xx$/"))
    }

    func testDeploymentSignatureIncludesSchemaAndAllSwitches() {
        let settings = RimeFuzzyPinyinSettings(
            enabled: true,
            zhZEnabled: false,
            chCEnabled: true,
            shSEnabled: false,
            nLEnabled: true
        )

        XCTAssertEqual(
            settings.deploymentSignature(activeSchemaID: "rime_ice"),
            "schema=rime_ice;enabled=1;zh_z=0;ch_c=1;sh_s=0;n_l=1"
        )
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

        let result = RimeFuzzyPinyinPostProcessor.apply(
            settings: .init(zhZEnabled: true, chCEnabled: false, shSEnabled: false, nLEnabled: false), to: yaml)

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
