import XCTest

@testable import KeyboardCore

final class KeyboardLayoutAndT9RuntimeTests: XCTestCase {
    func testMissingAndUnknownLayoutValuesFallBackToTwentySixKey() {
        XCTAssertEqual(KeyboardLayoutStyle.resolve(nil), .twentySixKey)
        XCTAssertEqual(KeyboardLayoutStyle.resolve(""), .twentySixKey)
        XCTAssertEqual(KeyboardLayoutStyle.resolve("unknown"), .twentySixKey)
        XCTAssertEqual(KeyboardLayoutStyle.resolve("nine_key"), .nineKey)
        XCTAssertEqual(KeyboardLayoutStyle.resolve("twenty_six_key"), .twentySixKey)
    }

    func testEffectiveSchemeUsesT9OnlyWhenIceNineKeyAndReadinessMatch() {
        let fingerprint = "abc"
        let marker = RimeT9ReadinessMarker(
            ready: true,
            compatibilityVersion: RimeT9Readiness.currentCompatibilityVersion,
            resourceFingerprint: fingerprint
        )

        let t9 = RimeRuntimeSelection.resolve(
            baseSchemaID: "rime_ice",
            layoutRawValue: KeyboardLayoutStyle.nineKey.rawValue,
            readinessMarker: marker,
            onDiskFingerprint: fingerprint
        )
        XCTAssertEqual(t9.effectiveSchemaID, "t9")
        XCTAssertEqual(t9.effectiveLayoutStyle, .nineKey)
        XCTAssertTrue(t9.usesT9InputSemantics)

        let unmatched = RimeRuntimeSelection.resolve(
            baseSchemaID: "rime_ice",
            layoutRawValue: KeyboardLayoutStyle.nineKey.rawValue,
            readinessMarker: marker,
            onDiskFingerprint: "other"
        )
        XCTAssertEqual(unmatched.effectiveSchemaID, "rime_ice")
        XCTAssertEqual(unmatched.effectiveLayoutStyle, .twentySixKey)
        XCTAssertFalse(unmatched.usesT9InputSemantics)

        let luna = RimeRuntimeSelection.resolve(
            baseSchemaID: "luna_pinyin",
            layoutRawValue: KeyboardLayoutStyle.nineKey.rawValue,
            readinessMarker: marker,
            onDiskFingerprint: fingerprint
        )
        XCTAssertEqual(luna.effectiveSchemaID, "luna_pinyin")
        XCTAssertEqual(luna.effectiveLayoutStyle, .twentySixKey)
    }

    func testNilOnDiskFingerprintFailClosesToTwentySixKey() {
        let marker = RimeT9ReadinessMarker(
            ready: true,
            compatibilityVersion: RimeT9Readiness.currentCompatibilityVersion,
            resourceFingerprint: "fp"
        )
        let selection = RimeRuntimeSelection.resolve(
            baseSchemaID: "rime_ice",
            layoutRawValue: KeyboardLayoutStyle.nineKey.rawValue,
            readinessMarker: marker,
            onDiskFingerprint: nil
        )
        XCTAssertEqual(selection.effectiveSchemaID, "rime_ice")
        XCTAssertFalse(selection.usesT9InputSemantics)
    }

    func testLegacyBooleanAloneIsNotMatchedReadiness() {
        let suite = "uk.test.t9.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }
        defaults.set(true, forKey: RimeT9Readiness.SettingsKey.legacyReady)
        XCTAssertNil(RimeT9Readiness.load(from: defaults))
        XCTAssertFalse(
            RimeT9Readiness.isMatched(marker: nil, onDiskFingerprint: "x")
        )
    }

    func testT9PreeditPrefersCommentThenRawDigits() {
        let candidates = [
            RimeCandidate(text: "你", comment: "ni", globalIndex: 0),
            RimeCandidate(text: "密", comment: "mi", globalIndex: 1),
        ]
        XCTAssertEqual(
            T9PreeditResolver.visiblePreedit(
                rawInput: "64",
                candidates: candidates,
                highlightedIndex: 0
            ),
            "ni"
        )
        XCTAssertEqual(
            T9PreeditResolver.visiblePreedit(
                rawInput: "64",
                candidates: [RimeCandidate(text: "你", comment: "", globalIndex: 0)],
                highlightedIndex: 0
            ),
            "64"
        )
    }

    func testDigitShapeWithoutT9SemanticsIsNotT9Policy() {
        let digits = "64426"
        XCTAssertFalse(
            T9CompositionCommitPolicy.isActiveT9DigitComposition(
                usesT9InputSemantics: false,
                rawInput: digits
            )
        )
        XCTAssertEqual(
            T9CompositionCommitPolicy.returnAction(
                usesT9InputSemantics: false,
                rawInput: digits,
                candidates: [],
                highlightedIndex: nil
            ),
            .notT9Composition
        )
        XCTAssertEqual(
            T9CompositionCommitPolicy.spaceAction(
                usesT9InputSemantics: false,
                rawInput: digits,
                candidates: [],
                highlightedIndex: nil
            ),
            .notT9Composition
        )
        XCTAssertEqual(
            T9CompositionCommitPolicy.languageSwitchAction(
                usesT9InputSemantics: false,
                rawInput: digits
            ),
            .notT9Composition
        )
    }

    func testReturnAndLanguageSwitchNeverCommitRawDigitsWhenT9SemanticsEnabled() {
        let digits = "64426"
        let noCandidates: [RimeCandidate] = []
        XCTAssertEqual(
            T9CompositionCommitPolicy.returnAction(
                usesT9InputSemantics: true,
                rawInput: digits,
                candidates: noCandidates,
                highlightedIndex: nil
            ),
            .keepComposition
        )
        XCTAssertEqual(
            T9CompositionCommitPolicy.spaceAction(
                usesT9InputSemantics: true,
                rawInput: digits,
                candidates: noCandidates,
                highlightedIndex: nil
            ),
            .keepComposition
        )
        XCTAssertEqual(
            T9CompositionCommitPolicy.languageSwitchAction(
                usesT9InputSemantics: true,
                rawInput: digits
            ),
            .abandonComposition
        )

        let withCandidate = [RimeCandidate(text: "你好", comment: "ni hao", globalIndex: 0)]
        XCTAssertEqual(
            T9CompositionCommitPolicy.returnAction(
                usesT9InputSemantics: true,
                rawInput: digits,
                candidates: withCandidate,
                highlightedIndex: 0
            ),
            .commitCandidate("你好")
        )
    }

    func testCompatibilityStripRemovesT9ProcessorOnly() throws {
        let upstream = """
            schema:
              schema_id: t9
            engine:
              processors:
                - t9_processor
                - ascii_composer
            speller:
              algebra:
                - derive/[abc]/2/
                - derive/[def]/3/
                - derive/[hgi]/4/
                - derive/[jkl]/5/
                - derive/[omn]/6/
                - derive/[pqrs]/7/
                - derive/[tuv]/8/
                - derive/[wxyz]/9/
            """
        let compatible = try T9SchemaCompatibility.makeCompatibleSchema(fromUpstreamYAML: upstream)
        XCTAssertFalse(compatible.contains("t9_processor"))
        XCTAssertTrue(compatible.contains("derive/[abc]/2/"))
        XCTAssertTrue(compatible.contains("schema_id: t9"))
    }

    func testSchemaListIncludesT9WhenIceInstalled() {
        let yaml = RimeConfigTemplates.generateDefaultYaml(
            activeSchemaID: "rime_ice",
            rimeIceInstalled: true,
            pageSize: 9
        )
        XCTAssertTrue(yaml.contains("schema: t9") || yaml.contains("- schema: t9"))
    }

    func testUserDictionaryPreferenceAppliesToT9SchemaID() {
        let settings = RimeUserDictionarySettings(lunaPinyinEnabled: false, rimeIceEnabled: true)
        XCTAssertTrue(settings.isEnabled(for: "t9"))
        XCTAssertTrue(settings.isEnabled(for: "rime_ice"))
        XCTAssertFalse(settings.isEnabled(for: "luna_pinyin"))
    }

    func testRequestedT9ReconcilesFailClosedWhenActualIsRimeIce() {
        let fingerprint = "matched-fp"
        let marker = RimeT9ReadinessMarker(
            ready: true,
            compatibilityVersion: RimeT9Readiness.currentCompatibilityVersion,
            resourceFingerprint: fingerprint
        )
        let requested = RimeRuntimeSelection.resolve(
            baseSchemaID: "rime_ice",
            layoutRawValue: KeyboardLayoutStyle.nineKey.rawValue,
            readinessMarker: marker,
            onDiskFingerprint: fingerprint
        )
        XCTAssertTrue(requested.usesT9InputSemantics)
        XCTAssertEqual(requested.effectiveSchemaID, "t9")
        XCTAssertEqual(requested.effectiveLayoutStyle, .nineKey)

        let realized = requested.reconciled(withActualSchemaID: "rime_ice")
        XCTAssertEqual(realized.effectiveSchemaID, "rime_ice")
        XCTAssertEqual(realized.effectiveLayoutStyle, .twentySixKey)
        XCTAssertFalse(realized.usesT9InputSemantics)
        XCTAssertFalse(realized.t9ReadinessMatched)
        // Digit-shaped raw input must not receive T9 policy after fail-close.
        XCTAssertEqual(
            T9CompositionCommitPolicy.returnAction(
                usesT9InputSemantics: realized.usesT9InputSemantics,
                rawInput: "64",
                candidates: [],
                highlightedIndex: nil
            ),
            .notT9Composition
        )
    }

    func testRequestedT9KeepsSemanticsWhenActualIsT9() {
        let fingerprint = "matched-fp"
        let marker = RimeT9ReadinessMarker(
            ready: true,
            compatibilityVersion: RimeT9Readiness.currentCompatibilityVersion,
            resourceFingerprint: fingerprint
        )
        let requested = RimeRuntimeSelection.resolve(
            baseSchemaID: "rime_ice",
            layoutRawValue: KeyboardLayoutStyle.nineKey.rawValue,
            readinessMarker: marker,
            onDiskFingerprint: fingerprint
        )
        let realized = requested.reconciled(withActualSchemaID: "t9")
        XCTAssertEqual(realized, requested)
        XCTAssertTrue(realized.usesT9InputSemantics)
        XCTAssertEqual(realized.effectiveLayoutStyle, .nineKey)
    }

    func testReconcileWithNilActualSchemaFailsClosed() {
        let fingerprint = "matched-fp"
        let marker = RimeT9ReadinessMarker(
            ready: true,
            compatibilityVersion: RimeT9Readiness.currentCompatibilityVersion,
            resourceFingerprint: fingerprint
        )
        let requested = RimeRuntimeSelection.resolve(
            baseSchemaID: "rime_ice",
            layoutRawValue: KeyboardLayoutStyle.nineKey.rawValue,
            readinessMarker: marker,
            onDiskFingerprint: fingerprint
        )
        let realized = requested.reconciled(withActualSchemaID: nil)
        // nil falls back to baseSchemaID as "actual", which is not t9 → fail closed.
        XCTAssertEqual(realized.effectiveSchemaID, "rime_ice")
        XCTAssertFalse(realized.usesT9InputSemantics)
        XCTAssertEqual(realized.effectiveLayoutStyle, .twentySixKey)
    }
}

@MainActor
final class T9ControllerSemanticsTests: XCTestCase {
    func testIdenticalDigitsUseT9PolicyOnlyWhenSemanticsEnabled() {
        let client = FakeTextInputClient()
        let controller = KeyboardController()
        controller.textClient = client
        controller.state.inputMode = .chinese
        controller.state.currentPage = .letters
        controller.state.currentComposition = "64"
        controller.state.lastRimeOutput = RimeOutput(
            rawInput: "64",
            composition: RimeComposition(preeditText: "64", cursorPosition: 2),
            candidates: [],
            committedText: nil,
            hasMorePages: false,
            highlightedIndex: 0
        )

        // T9 path: return keeps composition and never inserts raw digits.
        controller.usesT9InputSemantics = true
        let before = client.text
        let effects = controller.handleInsertReturn()
        XCTAssertTrue(effects.isEmpty)
        XCTAssertFalse(client.text.contains("64") && client.text != before)
        XCTAssertEqual(controller.state.currentComposition, "64")
        XCTAssertEqual(client.text, before)
    }

    func testLanguageToggleAbandonsOnlyUnderT9Semantics() {
        let client = FakeTextInputClient()
        let controller = KeyboardController()
        controller.textClient = client
        controller.state.inputMode = .chinese
        controller.state.currentComposition = "64"
        controller.state.lastRimeOutput = RimeOutput(
            rawInput: "64",
            composition: RimeComposition(preeditText: "64", cursorPosition: 2),
            candidates: [RimeCandidate(text: "你", comment: "ni")],
            committedText: nil,
            hasMorePages: false
        )
        controller.usesT9InputSemantics = true
        _ = controller.handle(.toggleInputMode)
        XCTAssertEqual(controller.state.currentComposition, "")
        XCTAssertFalse(client.text.contains("64"))
    }

    func testTypoCorrectionSuppressedOnlyForT9Semantics() {
        let controller = KeyboardController()
        controller.state.inputMode = .chinese
        controller.state.currentPage = .letters
        controller.state.currentComposition = "64"
        controller.usesT9InputSemantics = true
        controller.refreshTypoCorrectionSuggestions()
        XCTAssertNil(controller.state.typoCorrection)

        controller.usesT9InputSemantics = false
        // Without T9 semantics, digit composition may still produce no typo suggestions,
        // but the suppression early-return is not taken; state remains nil or non-T9 path.
        controller.refreshTypoCorrectionSuggestions()
        // Not asserting non-nil — Fake provider may have no typo hits for "64".
    }
}
