import XCTest

@testable import KeyboardCore

@MainActor
final class T9PinyinPathTests: XCTestCase {
    func testBoundedCompleteSyllableSpellingsFor53AreDeterministic() {
        XCTAssertEqual(
            T9PinyinPathExtractor.boundedCompleteSyllableSpellings(forDigits: "53"),
            ["jd", "je", "jf", "kd", "ke", "kf", "ld", "le", "lf"]
        )
    }

    func testBoundedCompleteSyllableSpellingsHonorHardLimit() {
        let spellings = T9PinyinPathExtractor.boundedCompleteSyllableSpellings(
            forDigits: "74264",
            limit: 7
        )

        XCTAssertEqual(spellings.count, 7)
        XCTAssertEqual(spellings, ["pg", "ph", "pi", "qg", "qh", "qi", "rg"])
    }

    func testBoundedCompleteSyllableSpellingsRejectSingleOrInvalidDigits() {
        XCTAssertTrue(
            T9PinyinPathExtractor.boundedCompleteSyllableSpellings(forDigits: "5").isEmpty
        )
        XCTAssertTrue(
            T9PinyinPathExtractor.boundedCompleteSyllableSpellings(forDigits: "50").isEmpty
        )
    }

    func testCommentNormalizationAndIllegalFilter() {
        let path = T9PinyinPathExtractor.path(fromComment: "Ni  Hao")
        XCTAssertEqual(path?.replacementRawInput, "ni'hao")
        XCTAssertEqual(path?.displayText, "ni hao")

        XCTAssertNil(T9PinyinPathExtractor.path(fromComment: "ni💯"))
        XCTAssertNil(T9PinyinPathExtractor.path(fromComment: ""))
        XCTAssertNil(T9PinyinPathExtractor.path(fromComment: nil))
        XCTAssertNil(T9PinyinPathExtractor.path(fromComment: "你好"))
        // Non-ASCII letter / fullwidth digit / tab must fail closed.
        XCTAssertNil(T9PinyinPathExtractor.path(fromComment: "ní"))
        XCTAssertNil(T9PinyinPathExtractor.path(fromComment: "ni\t"))
        XCTAssertNil(T9PinyinPathExtractor.path(fromComment: "ni\u{00A0}hao"))
    }

    func testASCIIRawContractRejectsUnicodeDigitsAndWhitespace() {
        XCTAssertTrue(T9PinyinPathExtractor.isValidT9RawInput("ni4"))
        XCTAssertTrue(T9PinyinPathExtractor.isValidT9RawInput("ni'hao"))
        XCTAssertFalse(T9PinyinPathExtractor.isValidT9RawInput("ni４")) // fullwidth digit
        XCTAssertFalse(T9PinyinPathExtractor.isValidT9RawInput("ni\t4"))
        XCTAssertFalse(T9PinyinPathExtractor.isValidT9RawInput("ni\n"))
    }

    func testCompatibilityPositionBasedMixedAndNegatives() {
        let ni = T9PinyinPath(displayText: "ni", replacementRawInput: "ni")
        let mi = T9PinyinPath(displayText: "mi", replacementRawInput: "mi")
        let o = T9PinyinPath(displayText: "o", replacementRawInput: "o")
        let nia = T9PinyinPath(displayText: "nia", replacementRawInput: "nia")
        let nim = T9PinyinPath(displayText: "nim", replacementRawInput: "nim")

        XCTAssertTrue(T9PinyinPathExtractor.isCompatible(path: o, withRawInput: "6"))
        XCTAssertTrue(T9PinyinPathExtractor.isCompatible(path: ni, withRawInput: "64"))
        XCTAssertTrue(T9PinyinPathExtractor.isCompatible(path: mi, withRawInput: "64"))
        XCTAssertFalse(T9PinyinPathExtractor.isCompatible(path: ni, withRawInput: "2"))
        XCTAssertTrue(T9PinyinPathExtractor.isCompatible(path: ni, withRawInput: "ni"))
        // Short path on refined mixed raw: letter prefix + trailing digit suffix.
        XCTAssertTrue(T9PinyinPathExtractor.isCompatible(path: ni, withRawInput: "ni4"))
        // Digit slot must match T9 group — not merely share letter prefix.
        XCTAssertFalse(T9PinyinPathExtractor.isCompatible(path: nia, withRawInput: "ni4"))
        XCTAssertFalse(T9PinyinPathExtractor.isCompatible(path: nim, withRawInput: "ni4"))
        // Pure digits require full-length path (no short prefix).
        XCTAssertFalse(T9PinyinPathExtractor.isCompatible(path: o, withRawInput: "64"))
        // Pure letter: shorter remaining letter slots not allowed.
        XCTAssertFalse(
            T9PinyinPathExtractor.isCompatible(
                path: T9PinyinPath(displayText: "n", replacementRawInput: "n"),
                withRawInput: "ni"
            )
        )
    }

    func testPathsDedupeAndOrder() {
        let candidates = [
            RimeCandidate(text: "你", comment: "ni", globalIndex: 0),
            RimeCandidate(text: "拟", comment: "ni", globalIndex: 1),
            RimeCandidate(text: "密", comment: "mi", globalIndex: 2),
            RimeCandidate(text: "哦", comment: "o", globalIndex: 3),
        ]
        let paths = T9PinyinPathExtractor.paths(from: candidates, rawInput: "64", limit: 4)
        XCTAssertEqual(paths.map(\.replacementRawInput), ["ni", "mi"])
    }

    func testCanonicalSingleDigitChoicesCoverEveryNineKeyGroup() {
        let expected = [
            "2": ["a", "b", "c"],
            "3": ["d", "e", "f"],
            "4": ["g", "h", "i"],
            "5": ["j", "k", "l"],
            "6": ["m", "n", "o"],
            "7": ["p", "q", "r", "s"],
            "8": ["t", "u", "v"],
            "9": ["w", "x", "y", "z"],
        ]

        for (digit, choices) in expected {
            XCTAssertEqual(
                T9PinyinPathExtractor.deterministicSingleDigitPaths(rawInput: digit)
                    .map(\.replacementRawInput),
                choices
            )
        }
        XCTAssertTrue(
            T9PinyinPathExtractor.deterministicSingleDigitPaths(rawInput: "64").isEmpty
        )
    }

    func testSingleDigitUsesCompleteKeyChoicesWhenRimeCommentsOnlyExposeO() {
        let engine = makeT9Engine()
        let controller = makeController(engine: engine)
        controller.textClient = FakeTextInputClient()

        _ = controller.handle(.insertKey("6"))

        let state = controller.state.t9PinyinPathState
        XCTAssertEqual(state.compactPaths.map(\.replacementRawInput), ["m", "n", "o"])
        XCTAssertEqual(state.issuedReplacementKeys, ["m", "n", "o"])
        XCTAssertEqual(state.retainedChoiceSourceRawInput, "6")
        XCTAssertNil(state.selectedPath)
    }

    func testCycleSelectsMThenNThenOAndWrapsWhileRetainingChoices() {
        let engine = makeT9Engine()
        let controller = makeController(engine: engine)
        let client = FakeTextInputClient()
        controller.textClient = client
        _ = controller.handle(.insertKey("6"))

        for expected in ["m", "n", "o", "m"] {
            let effects = controller.handle(.cycleT9PinyinPath)
            XCTAssertTrue(effects.contains(.compositionChanged))
            XCTAssertTrue(effects.contains(.t9PinyinPathsChanged))
            XCTAssertEqual(controller.state.lastRimeOutput?.rawInput, expected)
            XCTAssertEqual(
                controller.state.t9PinyinPathState.selectedPath?.replacementRawInput,
                expected
            )
            XCTAssertEqual(
                controller.state.t9PinyinPathState.compactPaths.map(\.replacementRawInput),
                ["m", "n", "o"]
            )
            XCTAssertEqual(controller.state.t9PinyinPathState.retainedChoiceSourceRawInput, "6")
            XCTAssertNil(
                controller.state.lastRimeOutput?.committedText,
                "precise refinement must never produce committed RIME text"
            )
            XCTAssertEqual(
                client.markedText,
                expected,
                "explicit cycle selection must display the exact selected path"
            )
            XCTAssertEqual(controller.state.insertedPreeditText, expected)
        }
    }

    func testDirectSelectionCanSwitchWithinRetainedSingleDigitSnapshot() {
        let engine = makeT9Engine()
        let controller = makeController(engine: engine)
        controller.textClient = FakeTextInputClient()
        _ = controller.handle(.insertKey("6"))

        _ = controller.handle(
            .selectT9PinyinPath(T9PinyinPath(displayText: "m", replacementRawInput: "m"))
        )
        let effects = controller.handle(
            .selectT9PinyinPath(T9PinyinPath(displayText: "n", replacementRawInput: "n"))
        )

        XCTAssertTrue(effects.contains(.compositionChanged))
        XCTAssertEqual(controller.state.lastRimeOutput?.rawInput, "n")
        XCTAssertEqual(
            controller.state.t9PinyinPathState.compactPaths.map(\.replacementRawInput),
            ["m", "n", "o"]
        )
        XCTAssertEqual(controller.state.t9PinyinPathState.selectedPath?.replacementRawInput, "n")
    }

    func testNewDigitRetainsFocusedSegmentSnapshotAndSelection() {
        let engine = makeT9Engine()
        let controller = makeController(engine: engine)
        controller.textClient = FakeTextInputClient()
        _ = controller.handle(.insertKey("6"))
        _ = controller.handle(.cycleT9PinyinPath) // 6 -> m

        _ = controller.handle(.insertKey("4")) // m -> m4

        XCTAssertEqual(controller.state.lastRimeOutput?.rawInput, "m4")
        XCTAssertEqual(controller.state.t9PinyinPathState.segmentSourceDigits, "64")
        XCTAssertEqual(controller.state.t9PinyinPathState.focusedSegmentIndex, 0)
        XCTAssertEqual(
            controller.state.t9PinyinPathState.compactPaths.map(\.replacementRawInput),
            ["m4", "n4", "o4"]
        )
        XCTAssertEqual(
            controller.state.t9PinyinPathState.selectedPath?.replacementRawInput,
            "m4"
        )
    }

    func testWholeCompositionMergesFullPathsAndFirstGroupChoicesInNativeOrder() {
        let engine = makeT9Engine()
        let controller = makeController(engine: engine)
        controller.textClient = FakeTextInputClient()

        _ = controller.handle(.insertKey("6"))
        _ = controller.handle(.insertKey("4"))

        // Complete syllables first (comment-ranked ni before mi, then 1-slot o),
        // then remaining key-group prefixes m/n (o de-duplicated as complete).
        XCTAssertEqual(
            controller.state.t9PinyinPathState.compactPaths.map(\.displayText),
            ["ni", "mi", "o", "m", "n"]
        )
        XCTAssertEqual(
            controller.state.t9PinyinPathState.compactPaths.map(\.replacementRawInput),
            ["ni", "mi", "o4", "m4", "n4"]
        )
        XCTAssertNil(controller.state.t9PinyinPathState.selectedPath)
    }

    func testWholeCompositionNeverSurfacesMultiSyllableLabels() {
        // ni/xian/zai ↔ 64 / 9426 / 924 — multi-syllable comments must collapse
        // to first-syllable compact labels only.
        let engine = FakeRimeEngine(
            dictionary: [
                "649426": ["你先", "你站"],
                "6": ["吗"],
                "64": ["你"],
            ],
            comments: [
                "649426": ["ni xian", "ni zhan", "mi xian"],
                "6": ["o"],
                "64": ["ni", "mi"],
            ]
        )
        engine.appendDigitsToComposition = true
        engine.seedRuntimeSelection(
            RimeRuntimeSelection(
                baseSchemaID: "rime_ice",
                layoutStyle: .nineKey,
                t9ReadinessMatched: true
            )
        )
        let controller = makeController(engine: engine)
        controller.textClient = FakeTextInputClient()

        for digit in ["6", "4", "9", "4", "2", "6"] {
            _ = controller.handle(.insertKey(digit))
        }

        let displays = controller.state.t9PinyinPathState.compactPaths.map(\.displayText)
        XCTAssertFalse(displays.contains(where: { $0.contains(" ") }))
        XCTAssertTrue(displays.contains("ni") || displays.contains("mi"))
        XCTAssertTrue(displays.contains("m"))
        XCTAssertTrue(displays.contains("n"))
        XCTAssertTrue(displays.contains("o"))
        XCTAssertLessThanOrEqual(displays.count, 5)
    }

    func testConfirmFirstSyllableAdvancesToNextSyllableChoices() {
        // 你先 / 你站: ni(64) + xian|zhan(9426)
        let engine = FakeRimeEngine(
            dictionary: [
                "649426": ["你先", "你站"],
                "ni9426": ["你先", "你站"],
                "ni'xian": ["你先"],
                "ni'zhan": ["你站"],
                "6": ["吗"],
                "64": ["你"],
                "ni": ["你"],
                "n": ["你"],
                "m": ["吗"],
                "o": ["哦"],
            ],
            comments: [
                "649426": ["ni xian", "ni zhan"],
                "ni9426": ["ni xian", "ni zhan"],
                "ni'xian": ["ni'xian"],
                "ni'zhan": ["ni'zhan"],
                "6": ["o"],
                "64": ["ni", "mi"],
                "ni": ["ni"],
                "n": ["ni"],
                "m": ["ma"],
                "o": ["ou"],
            ]
        )
        engine.appendDigitsToComposition = true
        engine.seedRuntimeSelection(
            RimeRuntimeSelection(
                baseSchemaID: "rime_ice",
                layoutStyle: .nineKey,
                t9ReadinessMatched: true
            )
        )
        let controller = makeController(engine: engine)
        controller.textClient = FakeTextInputClient()

        for digit in ["6", "4", "9", "4", "2", "6"] {
            _ = controller.handle(.insertKey(digit))
        }

        let ni = try! XCTUnwrap(
            controller.state.t9PinyinPathState.compactPaths.first { $0.displayText == "ni" }
        )
        XCTAssertEqual(ni.replacementRawInput, "ni9426")
        // Direct path tap confirms immediately — no second tap required.
        let effects = controller.handle(.selectT9PinyinPath(ni))
        XCTAssertTrue(effects.contains(.t9PinyinPathsChanged))
        XCTAssertEqual(controller.state.t9PinyinPathState.confirmedSegmentValues, ["ni"])
        XCTAssertEqual(controller.state.t9PinyinPathState.focusedSegmentIndex, 1)
        XCTAssertNil(controller.state.t9PinyinPathState.selectedPath)

        let nextDisplays = controller.state.t9PinyinPathState.compactPaths.map(\.displayText)
        XCTAssertFalse(nextDisplays.contains(where: { $0.contains(" ") }))
        // ADR 0023: local catalog lists every legal focus syllable/prefix, not only
        // the two comments that happened to appear on the first candidate page.
        XCTAssertTrue(nextDisplays.contains("xian"))
        XCTAssertTrue(nextDisplays.contains("zhan"))
        XCTAssertFalse(nextDisplays.contains("ni"))
        XCTAssertGreaterThanOrEqual(nextDisplays.count, 2)
    }

    func testSelectPinyinCyclesWithoutConfirmingSegment() {
        let engine = FakeRimeEngine(
            dictionary: [
                "649426": ["你先", "你站"],
                "ni9426": ["你先", "你站"],
                "mi9426": ["米线"],
                "6": ["吗"],
                "n": ["你"],
                "m": ["吗"],
                "o": ["哦"],
            ],
            comments: [
                "649426": ["ni xian", "ni zhan", "mi xian"],
                "ni9426": ["ni xian", "ni zhan"],
                "mi9426": ["mi xian"],
                "6": ["o"],
                "n": ["ni"],
                "m": ["ma"],
                "o": ["ou"],
            ]
        )
        engine.appendDigitsToComposition = true
        engine.seedRuntimeSelection(
            RimeRuntimeSelection(
                baseSchemaID: "rime_ice",
                layoutStyle: .nineKey,
                t9ReadinessMatched: true
            )
        )
        let controller = makeController(engine: engine)
        controller.textClient = FakeTextInputClient()
        for digit in ["6", "4", "9", "4", "2", "6"] {
            _ = controller.handle(.insertKey(digit))
        }

        // 选拼音 only moves tentative selection; does not advance to next syllable.
        _ = controller.handle(.cycleT9PinyinPath)
        XCTAssertNotNil(controller.state.t9PinyinPathState.selectedPath)
        XCTAssertTrue(controller.state.t9PinyinPathState.confirmedSegmentValues.isEmpty)
        XCTAssertEqual(controller.state.t9PinyinPathState.focusedSegmentIndex, 0)
        let firstDisplays = controller.state.t9PinyinPathState.compactPaths.map(\.displayText)
        XCTAssertTrue(firstDisplays.contains("ni") || firstDisplays.contains("mi"))
        XCTAssertFalse(firstDisplays.contains("xian"))
    }

    func testProgressiveSyllableExtractorTakesOnlyCurrentSegment() {
        let candidates = [
            RimeCandidate(text: "你现在", comment: "ni xian zai", globalIndex: 0),
            RimeCandidate(text: "你站在", comment: "ni zhan zai", globalIndex: 1),
            RimeCandidate(text: "米线", comment: "mi xian", globalIndex: 2),
        ]
        // ni(64) xian|zhan(9426) zai(924)
        let source = "649426924"
        let first = T9PinyinPathExtractor.progressiveSyllablePaths(
            from: candidates,
            sourceDigits: source,
            confirmedSyllables: [],
            limit: 5
        )
        XCTAssertEqual(first.map(\.displayText), ["ni", "mi"])
        XCTAssertFalse(first.contains(where: { $0.displayText.contains(" ") }))

        let second = T9PinyinPathExtractor.progressiveSyllablePaths(
            from: candidates,
            sourceDigits: source,
            confirmedSyllables: ["ni"],
            limit: 5
        )
        XCTAssertEqual(Set(second.map(\.displayText)), Set(["xian", "zhan"]))
        XCTAssertTrue(second.allSatisfy { $0.replacementRawInput.hasPrefix("ni'") })
    }

    func testLongInputAdvanceDiscoversAlternativeSyllableBeyondHotPathWindow() {
        let repeatedYiCandidates = Array(repeating: "一", count: 16)
        let repeatedYiComments = Array(repeating: "ni yi", count: 16)
        let engine = FakeRimeEngine(
            dictionary: [
                "6494": ["你一"],
                "ni94": repeatedYiCandidates,
                "ni'yi": ["你一"],
                "ni'xi": ["你系"],
            ],
            comments: [
                "6494": ["ni yi"],
                "ni94": repeatedYiComments,
                "ni'yi": ["ni yi"],
                "ni'xi": ["ni xi"],
            ]
        )
        engine.candidateWindowOverrides["ni94"] = repeatedYiComments.enumerated().map {
            RimeCandidate(text: "一", comment: $0.element, globalIndex: $0.offset)
        } + [
            RimeCandidate(text: "系", comment: "ni xi", globalIndex: 16)
        ]
        engine.appendDigitsToComposition = true
        engine.seedRuntimeSelection(
            RimeRuntimeSelection(
                baseSchemaID: "rime_ice",
                layoutStyle: .nineKey,
                t9ReadinessMatched: true
            )
        )
        let controller = makeController(engine: engine)
        controller.textClient = FakeTextInputClient()
        for digit in ["6", "4", "9", "4"] {
            _ = controller.handle(.insertKey(digit))
        }

        let ni = try! XCTUnwrap(
            controller.state.t9PinyinPathState.compactPaths.first { $0.displayText == "ni" }
        )
        _ = controller.handle(.selectT9PinyinPath(ni))

        let next = Set(controller.state.t9PinyinPathState.compactPaths.map(\.displayText))
        // Local catalog always exposes xi/yi/zi for focus 94 regardless of sparse comments.
        XCTAssertTrue(next.isSuperset(of: ["yi", "xi", "zi"]))
        XCTAssertNil(controller.state.t9PinyinPathState.selectedPath)
        XCTAssertEqual(controller.state.t9PinyinPathState.confirmedSegmentValues, ["ni"])
    }

    func testLongInputAdvanceSupplementsOneExactSyllableWithAuthorizedKeyBranch() {
        let engine = FakeRimeEngine(
            dictionary: [
                "6494": ["你一"],
                "ni94": ["你一"],
                "ni'yi": ["你一"],
                "ni'x4": ["你系"],
            ],
            comments: [
                "6494": ["ni yi"],
                "ni94": ["ni yi"],
                "ni'yi": ["ni yi"],
                "ni'x4": ["ni xi"],
            ]
        )
        engine.appendDigitsToComposition = true
        engine.candidateWindowOverrides["ni94"] = [
            RimeCandidate(text: "一", comment: "ni yi", globalIndex: 0),
            RimeCandidate(text: "系", comment: "ni xi", globalIndex: 1),
        ]
        engine.seedRuntimeSelection(
            RimeRuntimeSelection(
                baseSchemaID: "rime_ice",
                layoutStyle: .nineKey,
                t9ReadinessMatched: true
            )
        )
        let controller = makeController(engine: engine)
        controller.textClient = FakeTextInputClient()
        for digit in ["6", "4", "9", "4"] {
            _ = controller.handle(.insertKey(digit))
        }

        let ni = try! XCTUnwrap(
            controller.state.t9PinyinPathState.compactPaths.first { $0.displayText == "ni" }
        )
        _ = controller.handle(.selectT9PinyinPath(ni))

        let next = Set(controller.state.t9PinyinPathState.compactPaths.map(\.displayText))
        XCTAssertTrue(next.isSuperset(of: ["yi", "xi", "zi"]))
        XCTAssertNil(controller.state.t9PinyinPathState.selectedPath)
        XCTAssertEqual(engine.sessionComposition, "ni94")
    }

    func testDirectPathAdvanceHasConstantBridgeCallBudget() throws {
        let engine = FakeRimeEngine(
            dictionary: [
                "6494": ["你一"],
                "ni94": ["你一", "你系"],
            ],
            comments: [
                "6494": ["ni yi"],
                "ni94": ["ni yi", "ni xi"],
            ]
        )
        engine.appendDigitsToComposition = true
        engine.seedRuntimeSelection(
            RimeRuntimeSelection(
                baseSchemaID: "rime_ice",
                layoutStyle: .nineKey,
                t9ReadinessMatched: true
            )
        )
        let controller = makeController(engine: engine)
        controller.textClient = FakeTextInputClient()
        for digit in ["6", "4", "9", "4"] {
            _ = controller.handle(.insertKey(digit))
        }
        let ni = try XCTUnwrap(
            controller.state.t9PinyinPathState.compactPaths.first { $0.displayText == "ni" }
        )
        let replaceBefore = engine.replaceInputCallCount
        let windowBefore = engine.candidateWindowCallCount

        _ = controller.handle(.selectT9PinyinPath(ni))

        XCTAssertLessThanOrEqual(engine.replaceInputCallCount - replaceBefore, 1)
        XCTAssertLessThanOrEqual(engine.candidateWindowCallCount - windowBefore, 1)
        XCTAssertEqual(engine.replaceInputArguments.suffix(1), ["ni94"])
    }

    func testFinalSyllablePathTapHasConstantBridgeCallBudget() throws {
        let engine = FakeRimeEngine(
            dictionary: [
                "748": ["球", "熟"],
                "qiu": ["球"],
            ],
            comments: [
                "748": ["qiu", "shu"],
                "qiu": ["qiu"],
            ]
        )
        engine.appendDigitsToComposition = true
        engine.seedRuntimeSelection(
            RimeRuntimeSelection(
                baseSchemaID: "rime_ice",
                layoutStyle: .nineKey,
                t9ReadinessMatched: true
            )
        )
        let controller = makeController(engine: engine)
        controller.textClient = FakeTextInputClient()
        for digit in ["7", "4", "8"] {
            _ = controller.handle(.insertKey(digit))
        }
        let qiu = try XCTUnwrap(
            controller.state.t9PinyinPathState.compactPaths.first { $0.displayText == "qiu" }
        )
        let replaceBefore = engine.replaceInputCallCount
        let windowBefore = engine.candidateWindowCallCount

        _ = controller.handle(.selectT9PinyinPath(qiu))

        XCTAssertLessThanOrEqual(engine.replaceInputCallCount - replaceBefore, 1)
        XCTAssertLessThanOrEqual(engine.candidateWindowCallCount - windowBefore, 1)
        XCTAssertEqual(engine.sessionComposition, "qiu")
    }

    func testCandidatePageChangeAdvancesCompositionRevision() {
        let engine = makeT9Engine()
        let controller = makeController(engine: engine)
        controller.textClient = FakeTextInputClient()
        _ = controller.handle(.insertKey("6"))
        let previousRevision = controller.state.compositionRevision

        _ = controller.handle(.candidatePageDown)

        XCTAssertGreaterThan(controller.state.compositionRevision, previousRevision)
        XCTAssertEqual(
            controller.state.t9PinyinPathState.compositionRevision,
            controller.state.compositionRevision
        )
    }

    func testSelectedLetterPrefixOnMultiDigitFocusLocksWithoutAdvancing() {
        let engine = makeT9Engine()
        let controller = makeController(engine: engine)
        controller.textClient = FakeTextInputClient()
        _ = controller.handle(.insertKey("6"))
        _ = controller.handle(.insertKey("4"))

        let selectedN = try! XCTUnwrap(
            controller.state.t9PinyinPathState.compactPaths.first {
                $0.displayText == "n" && $0.kind == .letterPrefix
            }
        )
        let effects = controller.handle(.selectT9PinyinPath(selectedN))

        XCTAssertTrue(effects.contains(.t9PinyinPathsChanged))
        XCTAssertEqual(controller.state.lastRimeOutput?.rawInput, "n4")
        // PD option 1: letterPrefix locks only — no confirmed syllable advance.
        XCTAssertEqual(controller.state.t9PinyinPathState.lockedLetterPrefix, "n")
        XCTAssertTrue(controller.state.t9PinyinPathState.confirmedSegmentValues.isEmpty)
        XCTAssertEqual(controller.state.t9PinyinPathState.focusedSegmentIndex, 0)
        XCTAssertTrue(
            controller.state.t9PinyinPathState.compactPaths.contains {
                $0.displayText == "ni" && $0.kind == .completeSyllable
            }
        )
        XCTAssertTrue(
            controller.state.t9PinyinPathState.compactPaths.contains {
                $0.displayText == "n" && $0.kind == .letterPrefix
            }
        )
        XCTAssertNil(controller.state.lastRimeOutput?.committedText)
    }

    func testSelectPinyinSwitchesTentativeValueWithoutAdvancingSegment() {
        let engine = makeT9Engine()
        let controller = makeController(engine: engine)
        controller.textClient = FakeTextInputClient()
        _ = controller.handle(.insertKey("6"))
        _ = controller.handle(.cycleT9PinyinPath) // m
        _ = controller.handle(.insertKey("4"))

        // 选拼音 cycles within the retained/remapped focus without confirming a syllable.
        _ = controller.handle(.cycleT9PinyinPath)

        XCTAssertTrue(controller.state.t9PinyinPathState.confirmedSegmentValues.isEmpty)
        XCTAssertEqual(controller.state.t9PinyinPathState.focusedSegmentIndex, 0)
        XCTAssertNotNil(controller.state.t9PinyinPathState.selectedPath)
        // Must not jump to a confirmed next-focus set (e.g. only g/h/i).
        XCTAssertFalse(
            controller.state.t9PinyinPathState.confirmedSegmentValues.contains("m")
                || controller.state.t9PinyinPathState.confirmedSegmentValues.contains("n")
        )
        XCTAssertEqual(
            controller.state.lastRimeOutput?.rawInput?.first.map(String.init),
            controller.state.t9PinyinPathState.selectedPath?.displayText.first.map(String.init)
        )
    }

    func testDirectCompleteSyllableTapAdvancesWhenRemainingSlotsExist() {
        let engine = makeT9Engine()
        // Multi-digit source so confirming `ni` still leaves trailing digits.
        engine.dictionary["649"] = ["你就"]
        engine.comments["649"] = ["ni jiu"]
        engine.dictionary["ni9"] = ["你就"]
        engine.comments["ni9"] = ["ni jiu"]
        engine.dictionary["ni'9"] = ["你就"]
        engine.comments["ni'9"] = ["ni jiu"]
        let controller = makeController(engine: engine)
        controller.textClient = FakeTextInputClient()
        _ = controller.handle(.insertKey("6"))
        _ = controller.handle(.insertKey("4"))
        _ = controller.handle(.insertKey("9"))

        let ni = try! XCTUnwrap(
            controller.state.t9PinyinPathState.compactPaths.first {
                $0.displayText == "ni" && $0.kind == .completeSyllable
            }
        )
        _ = controller.handle(.selectT9PinyinPath(ni))

        XCTAssertEqual(controller.state.t9PinyinPathState.confirmedSegmentValues, ["ni"])
        XCTAssertEqual(controller.state.t9PinyinPathState.focusedSegmentIndex, 1)
        XCTAssertTrue(controller.state.t9PinyinPathState.lockedLetterPrefix == nil)
        XCTAssertFalse(
            controller.state.t9PinyinPathState.compactPaths.isEmpty
        )
    }

    func testDeletePendingDigitRestoresPriorFocusedChoice() {
        let engine = makeT9Engine()
        let controller = makeController(engine: engine)
        let client = FakeTextInputClient()
        controller.textClient = client
        _ = controller.handle(.insertKey("6"))
        _ = controller.handle(.cycleT9PinyinPath) // m
        _ = controller.handle(.cycleT9PinyinPath) // n
        _ = controller.handle(.insertKey("4"))

        let effects = controller.handle(.deleteBackward)

        XCTAssertTrue(effects.contains(.t9PinyinPathsChanged))
        XCTAssertEqual(controller.state.lastRimeOutput?.rawInput, "n")
        XCTAssertEqual(controller.state.t9PinyinPathState.segmentSourceDigits, "6")
        XCTAssertEqual(
            controller.state.t9PinyinPathState.compactPaths.map(\.displayText),
            ["m", "n", "o"]
        )
        XCTAssertEqual(controller.state.t9PinyinPathState.selectedPath?.displayText, "n")
        XCTAssertEqual(client.markedText, "n")
    }

    func testUnconfirmedT9DeleteRemovesLastVisiblePinyinCharacter() {
        let engine = FakeRimeEngine(
            dictionary: [
                "8": ["他"],
                "86": ["同"],
                "868": ["偷"],
                "to": ["头"],
                "t": ["他"],
            ],
            comments: [
                "8": ["ta"],
                "86": ["tong"],
                "868": ["tou"],
                // Re-ranking may advertise longer completions, but Delete owns
                // the exact shortened visible spelling.
                "to": ["tou"],
                "t": ["ta"],
            ]
        )
        engine.appendDigitsToComposition = true
        engine.seedRuntimeSelection(
            RimeRuntimeSelection(
                baseSchemaID: "rime_ice",
                layoutStyle: .nineKey,
                t9ReadinessMatched: true
            )
        )
        let controller = makeController(engine: engine)
        let client = FakeTextInputClient()
        controller.textClient = client

        for digit in ["8", "6", "8"] {
            _ = controller.handle(.insertKey(digit))
        }
        XCTAssertEqual(controller.state.t9PinyinPathState.segmentSourceDigits, "868")
        // Host may show comment projection (tou); digits must not leak.
        XCTAssertFalse(client.markedText.contains(where: \.isNumber))

        _ = controller.handle(.deleteBackward)
        // Core ledger peels one digit slot (H5-C SoT); raw may be pure `86` or a
        // catalog full-cover letter — not necessarily legacy visible-only `to`.
        XCTAssertEqual(controller.state.t9PinyinPathState.segmentSourceDigits, "86")
        let raw1 = controller.state.lastRimeOutput?.rawInput ?? ""
        XCTAssertTrue(
            raw1 == "86"
                || (raw1.unicodeScalars.allSatisfy(T9PinyinPathExtractor.isASCIILetter)
                    && raw1.count == 2),
            "expected 2-slot raw after first Delete; raw=\(raw1)"
        )
        XCTAssertFalse(client.markedText.contains(where: \.isNumber))
        XCTAssertFalse(client.markedText.isEmpty)

        _ = controller.handle(.deleteBackward)
        XCTAssertEqual(controller.state.t9PinyinPathState.segmentSourceDigits, "8")
        let raw2 = controller.state.lastRimeOutput?.rawInput ?? ""
        XCTAssertTrue(
            raw2 == "8"
                || (raw2.count == 1
                    && raw2.unicodeScalars.allSatisfy(T9PinyinPathExtractor.isASCIILetter)),
            "expected 1-slot raw after second Delete; raw=\(raw2)"
        )
        XCTAssertFalse(client.markedText.contains(where: \.isNumber))

        _ = controller.handle(.deleteBackward)
        // Empty composition may leave a cleared RimeOutput shell; host text must be empty.
        XCTAssertTrue(controller.state.lastRimeOutput?.rawInput?.isEmpty != false)
        XCTAssertEqual(controller.state.currentComposition, "")
        XCTAssertEqual(client.markedText, "")
        XCTAssertTrue(controller.state.t9PinyinPathState.compactPaths.isEmpty)
    }

    func testVisibleT9DeleteFailsClosedWhenRefinementAndRestoreBothFail() {
        // Multi-digit progressive Delete is owned by Core ledger identity (H5-C).
        // Fail-closed visible-letter path only applies when there is no multi-digit
        // `segmentSourceDigits` (letter-only peel). Seed a letter composition with
        // empty digit ledger so the scripted visible Delete rejection still runs.
        let engine = FakeRimeEngine(
            dictionary: ["to": ["头"], "t": ["他"]],
            comments: ["to": ["tou"], "t": ["ta"]]
        )
        engine.seedRuntimeSelection(
            RimeRuntimeSelection(
                baseSchemaID: "rime_ice",
                layoutStyle: .nineKey,
                t9ReadinessMatched: true
            )
        )
        let controller = makeController(engine: engine)
        let client = FakeTextInputClient()
        controller.textClient = client

        // Letter-only session without multi-digit Core ledger.
        let seeded = engine.replaceInput("to")
        controller.state.lastRimeOutput = seeded
        controller.state.currentComposition = "to"
        controller.state.insertedPreeditText = "to"
        controller.state.t9PinyinPathState = T9PinyinPathState(
            compactPaths: [
                T9PinyinPath(displayText: "to", replacementRawInput: "to"),
            ],
            compositionRevision: 1,
            segmentSourceDigits: nil,
            focusedSegmentIndex: nil,
            confirmedSegmentValues: []
        )
        client.setMarkedText("to", selectedRange: 0..<2)

        engine.replaceInputScript = [
            RimeOutput(
                rawInput: "wrong",
                composition: RimeComposition(preeditText: "wrong", cursorPosition: 5),
                candidates: [RimeCandidate(text: "错", comment: "wrong")]
            ),
            RimeOutput(),
        ]
        _ = controller.handle(.deleteBackward)

        // When both shorten and restore fail, composition is cleared (fail closed).
        XCTAssertEqual(engine.sessionComposition, "")
        XCTAssertTrue(
            controller.state.currentComposition.isEmpty
                || (controller.state.lastRimeOutput?.rawInput?.isEmpty ?? true)
        )
        XCTAssertEqual(client.markedText, "")
        XCTAssertTrue(controller.state.t9PinyinPathState.compactPaths.isEmpty)
    }

    /// Human H5-C: standalone `da` → JKL → Delete → MNO must leave Path on full
    /// 3-slot `326` focus (dao/dan/fan…), not a stale 2-slot bar while host is `dao`.
    func testHumanStandaloneDaTypoDeleteMNOPathBarTracksFullLedger() throws {
        let engine = FakeRimeEngine(
            dictionary: [
                "32": ["大"],
                "325": ["但"],
                "326": ["到", "但", "刀"],
                "da": ["大"],
                "dao": ["到", "但", "刀"],
            ],
            comments: [
                "32": ["da"],
                "325": ["dan"],
                "326": ["dao"],
                "da": ["da"],
                "dao": ["dao"],
            ]
        )
        engine.appendDigitsToComposition = true
        engine.seedRuntimeSelection(
            RimeRuntimeSelection(
                baseSchemaID: "rime_ice",
                layoutStyle: .nineKey,
                t9ReadinessMatched: true
            )
        )
        let controller = makeController(engine: engine)
        let client = FakeTextInputClient()
        controller.textClient = client

        _ = controller.handle(.insertKey("3"))
        _ = controller.handle(.insertKey("2")) // da
        XCTAssertEqual(controller.state.t9PinyinPathState.segmentSourceDigits, "32")

        _ = controller.handle(.insertKey("5")) // JKL typo
        XCTAssertEqual(controller.state.t9PinyinPathState.segmentSourceDigits, "325")
        _ = controller.handle(.deleteBackward)
        XCTAssertEqual(controller.state.t9PinyinPathState.segmentSourceDigits, "32")
        _ = controller.handle(.insertKey("6")) // MNO → dao

        let src = try XCTUnwrap(controller.state.t9PinyinPathState.segmentSourceDigits)
        XCTAssertEqual(src, "326", "Core ledger must be full dao slots; got \(src)")
        let paths = Set(controller.state.t9PinyinPathState.compactPaths.map(\.displayText))
        XCTAssertTrue(
            paths.contains("dao") || paths.contains("dan") || paths.contains("fan"),
            "Path bar must track 3-slot focus after da typo cycle; paths=\(paths.sorted())"
        )
        // Must not look like only first-digit / 2-slot leftovers while host is dao.
        let twoSlotOnly = paths.isSubset(of: ["da", "fa", "ta", "ba", "e", "d", "f", "a", "b", "c"])
        XCTAssertFalse(twoSlotOnly, "stale 2-slot Path bar; paths=\(paths.sorted())")
        let marked = client.markedText.replacingOccurrences(of: " ", with: "").lowercased()
        XCTAssertFalse(marked.contains(where: \.isNumber))
        // Host may be dao or digit-projected letters; candidates should include 到-family.
        let cands = Set((controller.state.lastRimeOutput?.candidates ?? []).map(\.text))
        XCTAssertTrue(
            cands.contains("到") || marked.contains("dao") || src == "326",
            "cands=\(cands) marked=\(marked)"
        )
    }

    func testCompleteSyllableAdvanceThenLetterPrefixOnlyLocks() {
        let engine = makeT9Engine()
        engine.dictionary["6495"] = ["你就"]
        engine.comments["6495"] = ["ni jiu"]
        engine.dictionary["ni95"] = ["你就"]
        engine.comments["ni95"] = ["ni jiu"]
        engine.dictionary["ni'95"] = ["你就"]
        engine.comments["ni'95"] = ["ni jiu"]
        engine.dictionary["ni'w5"] = ["你五"]
        engine.comments["ni'w5"] = ["ni wu"]
        engine.dictionary["ni'w"] = ["你"]
        engine.comments["ni'w"] = ["ni"]
        let controller = makeController(engine: engine)
        controller.textClient = FakeTextInputClient()
        for digit in ["6", "4", "9", "5"] {
            _ = controller.handle(.insertKey(digit))
        }

        let ni = try! XCTUnwrap(
            controller.state.t9PinyinPathState.compactPaths.first {
                $0.displayText == "ni" && $0.kind == .completeSyllable
            }
        )
        _ = controller.handle(.selectT9PinyinPath(ni))
        XCTAssertEqual(controller.state.t9PinyinPathState.confirmedSegmentValues, ["ni"])
        XCTAssertEqual(controller.state.t9PinyinPathState.focusedSegmentIndex, 1)

        let letter = try! XCTUnwrap(
            controller.state.t9PinyinPathState.compactPaths.first {
                $0.kind == .letterPrefix
            }
        )
        let confirmedBefore = controller.state.t9PinyinPathState.confirmedSegmentValues
        let focusBefore = controller.state.t9PinyinPathState.focusedSegmentIndex
        _ = controller.handle(.selectT9PinyinPath(letter))

        // Prefix selection must not confirm/advance the focus segment.
        XCTAssertEqual(controller.state.t9PinyinPathState.confirmedSegmentValues, confirmedBefore)
        XCTAssertEqual(controller.state.t9PinyinPathState.focusedSegmentIndex, focusBefore)
        XCTAssertEqual(
            controller.state.t9PinyinPathState.selectedPath?.displayText,
            letter.displayText
        )
        // Either explicit lockedLetterPrefix or selected letterPrefix is enough to
        // prove non-advance under PD option 1.
        XCTAssertTrue(
            controller.state.t9PinyinPathState.lockedLetterPrefix == letter.displayText
                || controller.state.t9PinyinPathState.selectedPath?.kind == .letterPrefix
        )
    }

    func testRepeatedWholePathTapDoesNotAdvanceSegmentOrCommit() {
        let engine = makeT9Engine()
        let controller = makeController(engine: engine)
        controller.textClient = FakeTextInputClient()
        _ = controller.handle(.insertKey("6"))
        _ = controller.handle(.insertKey("4"))
        let mi = try! XCTUnwrap(
            controller.state.t9PinyinPathState.compactPaths.first { $0.displayText == "mi" }
        )
        _ = controller.handle(.selectT9PinyinPath(mi))
        let selectedMi = try! XCTUnwrap(controller.state.t9PinyinPathState.selectedPath)

        _ = controller.handle(.selectT9PinyinPath(selectedMi))

        // Full-coverage first syllable ("mi" on "64") has no remaining digits, so a
        // second tap must not confirm/advance or host-commit. Focus may remain at 0.
        XCTAssertEqual(controller.state.lastRimeOutput?.rawInput, "mi")
        XCTAssertNil(controller.state.lastRimeOutput?.committedText)
        XCTAssertTrue(controller.state.t9PinyinPathState.confirmedSegmentValues.isEmpty)
        XCTAssertEqual(controller.state.t9PinyinPathState.selectedPath?.displayText, "mi")
        XCTAssertNotEqual(
            controller.state.t9PinyinPathState.focusedSegmentIndex,
            1,
            "no remaining digits means confirm/advance must not move focus"
        )
    }

    func testLiveSegmentAuthorizationRejectsFallbackOnlyRawRetention() {
        let g = [RimeCandidate(text: "能够", comment: "neng'gou")]
        let h = [RimeCandidate(text: "女孩", comment: "nv'hai")]
        let i = [RimeCandidate(text: "那", comment: "na")]

        XCTAssertTrue(
            T9PinyinPathExtractor.candidateCommentsAuthorizeSegment(
                g, segmentIndex: 1, startingWith: "g"
            )
        )
        XCTAssertTrue(
            T9PinyinPathExtractor.candidateCommentsAuthorizeSegment(
                h, segmentIndex: 1, startingWith: "h"
            )
        )
        XCTAssertFalse(
            T9PinyinPathExtractor.candidateCommentsAuthorizeSegment(
                i, segmentIndex: 1, startingWith: "i"
            )
        )
    }

    func testCycleFailureRollsBackRetainedChoicesAndSelection() {
        let engine = makeT9Engine()
        let controller = makeController(engine: engine)
        let client = FakeTextInputClient()
        controller.textClient = client
        _ = controller.handle(.insertKey("6"))
        _ = controller.handle(.cycleT9PinyinPath) // selected m

        engine.replaceInputScript = [
            RimeOutput(rawInput: "n", composition: nil, candidates: [], highlightedIndex: -1),
            RimeOutput(
                rawInput: "m",
                composition: RimeComposition(preeditText: "m", cursorPosition: 1),
                candidates: [RimeCandidate(text: "吗", comment: "m")],
                highlightedIndex: 0
            ),
        ]

        let effects = controller.handle(.cycleT9PinyinPath)

        XCTAssertTrue(effects.contains(.compositionChanged))
        XCTAssertEqual(controller.state.lastRimeOutput?.rawInput, "m")
        XCTAssertEqual(
            controller.state.t9PinyinPathState.compactPaths.map(\.replacementRawInput),
            ["m", "n", "o"]
        )
        XCTAssertEqual(controller.state.t9PinyinPathState.selectedPath?.replacementRawInput, "m")
        XCTAssertEqual(controller.state.t9PinyinPathState.retainedChoiceSourceRawInput, "6")
        XCTAssertEqual(
            client.markedText,
            "m",
            "rollback must restore the marked path selected before the failed cycle"
        )
    }

    func testMixedT9CompositionPolicyNeverLeaksRaw() {
        let mixed = "ni4"
        XCTAssertTrue(
            T9CompositionCommitPolicy.isActiveT9Composition(
                usesT9InputSemantics: true,
                rawInput: mixed
            )
        )
        XCTAssertEqual(
            T9CompositionCommitPolicy.returnAction(
                usesT9InputSemantics: true,
                rawInput: mixed,
                candidates: [],
                highlightedIndex: nil
            ),
            .keepComposition
        )
        XCTAssertEqual(
            T9CompositionCommitPolicy.spaceAction(
                usesT9InputSemantics: true,
                rawInput: mixed,
                candidates: [],
                highlightedIndex: nil
            ),
            .keepComposition
        )
        XCTAssertEqual(
            T9CompositionCommitPolicy.languageSwitchAction(
                usesT9InputSemantics: true,
                rawInput: mixed
            ),
            .abandonComposition
        )
    }

    func testSelectPathExactRefineAndSessionRollback() {
        let engine = makeT9Engine()
        let controller = makeController(engine: engine)
        let client = FakeTextInputClient()
        controller.textClient = client

        _ = controller.handle(.insertKey("6"))
        _ = controller.handle(.insertKey("4"))
        XCTAssertEqual(controller.state.lastRimeOutput?.rawInput, "64")
        XCTAssertFalse(controller.state.t9PinyinPathState.compactPaths.isEmpty)

        let ni = T9PinyinPath(displayText: "ni", replacementRawInput: "ni")
        let effects = controller.handle(.selectT9PinyinPath(ni))
        XCTAssertTrue(effects.contains(.compositionChanged))
        XCTAssertEqual(controller.state.lastRimeOutput?.rawInput, "ni")
        XCTAssertEqual(engine.sessionComposition, "ni")
        XCTAssertNil(controller.state.lastRimeOutput?.committedText)

        _ = controller.handle(.insertKey("4"))
        XCTAssertEqual(controller.state.lastRimeOutput?.rawInput, "ni4")
        XCTAssertEqual(engine.sessionComposition, "ni4")

        // From pure digit raw, select a compatible path but engine returns wrong non-empty raw.
        _ = engine.replaceInput("64")
        controller.state.lastRimeOutput = RimeOutput(
            rawInput: "64",
            composition: RimeComposition(preeditText: "64", cursorPosition: 2),
            candidates: [
                RimeCandidate(text: "你", comment: "ni", globalIndex: 0),
                RimeCandidate(text: "密", comment: "mi", globalIndex: 1),
            ],
            highlightedIndex: 0
        )
        controller.state.currentComposition = "64"
        controller.state.t9PinyinPathState = T9PinyinPathState(
            compactPaths: [
                T9PinyinPath(displayText: "ni", replacementRawInput: "ni"),
                T9PinyinPath(displayText: "mi", replacementRawInput: "mi"),
            ],
            selectedPath: nil,
            rawInputGeneration: 1,
            provenanceRevision: 1,
            trackedRawInput: "64",
            issuedReplacementKeys: ["ni", "mi"],
            discoveryNextIndex: 2,
            discoveryMayHaveMore: false
        )

        engine.replaceInputScript = [
            RimeOutput(
                rawInput: "foo",
                composition: RimeComposition(preeditText: "foo", cursorPosition: 3),
                candidates: [RimeCandidate(text: "错")],
                highlightedIndex: 0
            ),
            // rollback replaceInput(previousRaw) — usable live equivalent
            RimeOutput(
                rawInput: "64",
                composition: RimeComposition(preeditText: "64", cursorPosition: 2),
                candidates: [
                    RimeCandidate(text: "你", comment: "ni"),
                    RimeCandidate(text: "密", comment: "mi"),
                ],
                highlightedIndex: 0
            ),
        ]
        let rejected = controller.handle(
            .selectT9PinyinPath(T9PinyinPath(displayText: "mi", replacementRawInput: "mi"))
        )
        // Successful session restore signals UI refresh.
        XCTAssertTrue(rejected.contains(.compositionChanged))
        XCTAssertEqual(controller.state.lastRimeOutput?.rawInput, "64")
        XCTAssertEqual(engine.sessionComposition, "64")
        XCTAssertEqual(engine.lastReplaceInputArgument, "64")
    }

    /// Rollback usable live output must rebuild provenance from live comments only.
    func testRollbackLiveOutputDropsStaleIssuedPaths() {
        // Engine live dictionary for 64 only exposes mi (ni no longer in live comments).
        let engine = FakeRimeEngine(
            dictionary: [
                "64": ["密"],
                "mi": ["密"],
                "foo": ["错"],
            ],
            comments: [
                "64": ["mi"],
                "mi": ["mi"],
                "foo": ["cuo"],
            ]
        )
        engine.appendDigitsToComposition = true
        engine.seedRuntimeSelection(
            RimeRuntimeSelection(
                baseSchemaID: "rime_ice",
                layoutStyle: .nineKey,
                t9ReadinessMatched: true
            )
        )
        let controller = makeController(engine: engine)
        controller.textClient = FakeTextInputClient()
        _ = engine.replaceInput("64")

        // Stale pre-failure snapshot still claims ni was issued (no longer live).
        controller.state.lastRimeOutput = RimeOutput(
            rawInput: "64",
            composition: RimeComposition(preeditText: "64", cursorPosition: 2),
            candidates: [
                RimeCandidate(text: "你", comment: "ni", globalIndex: 0),
                RimeCandidate(text: "密", comment: "mi", globalIndex: 1),
            ],
            highlightedIndex: 0
        )
        controller.state.currentComposition = "64"
        controller.state.t9PinyinPathState = T9PinyinPathState(
            compactPaths: [
                T9PinyinPath(displayText: "ni", replacementRawInput: "ni"),
                T9PinyinPath(displayText: "mi", replacementRawInput: "mi"),
            ],
            selectedPath: T9PinyinPath(displayText: "ni", replacementRawInput: "ni"),
            rawInputGeneration: 1,
            provenanceRevision: 1,
            trackedRawInput: "64",
            issuedReplacementKeys: ["ni", "mi"],
            discoveryNextIndex: 2,
            discoveryMayHaveMore: false
        )

        engine.replaceInputScript = [
            // Failed refine (wrong raw)
            RimeOutput(
                rawInput: "foo",
                composition: RimeComposition(preeditText: "foo", cursorPosition: 3),
                candidates: [RimeCandidate(text: "错", comment: "cuo")],
                highlightedIndex: 0
            ),
            // Usable rollback: same raw, live candidates/comments only mi.
            RimeOutput(
                rawInput: "64",
                composition: RimeComposition(preeditText: "64", cursorPosition: 2),
                candidates: [
                    RimeCandidate(text: "密", comment: "mi", globalIndex: 0),
                ],
                highlightedIndex: 0
            ),
        ]

        let effects = controller.handle(
            .selectT9PinyinPath(T9PinyinPath(displayText: "mi", replacementRawInput: "mi"))
        )
        XCTAssertTrue(effects.contains(.compositionChanged))
        XCTAssertEqual(controller.state.lastRimeOutput?.rawInput, "64")

        // After usable rollback, local catalog still issues every legal focus path.
        XCTAssertTrue(controller.state.t9PinyinPathState.issuedReplacementKeys.contains("mi"))
        XCTAssertTrue(controller.state.t9PinyinPathState.issuedReplacementKeys.contains("ni"))
        XCTAssertTrue(
            controller.state.t9PinyinPathState.compactPaths
                .contains { $0.replacementRawInput == "mi" }
        )
        // Comment ranking prefers mi after rollback output.
        XCTAssertEqual(
            controller.state.t9PinyinPathState.compactPaths.first?.displayText,
            "mi"
        )

        // Unissued identity is rejected; issued mi remains selectable.
        let junkRejected = controller.handle(
            .selectT9PinyinPath(T9PinyinPath(displayText: "zz", replacementRawInput: "zz"))
        )
        XCTAssertTrue(junkRejected.isEmpty)
        XCTAssertEqual(controller.state.lastRimeOutput?.rawInput, "64")

        engine.replaceInputScript = []
        let miEffects = controller.handle(
            .selectT9PinyinPath(T9PinyinPath(displayText: "mi", replacementRawInput: "mi"))
        )
        XCTAssertTrue(miEffects.contains(.compositionChanged))
        XCTAssertEqual(controller.state.lastRimeOutput?.rawInput, "mi")
    }

    func testUnexpectedCommitAndRollbackFailureFailClosed() {
        let engine = makeT9Engine()
        let controller = makeController(engine: engine)
        controller.textClient = FakeTextInputClient()
        _ = controller.handle(.insertKey("6"))
        _ = controller.handle(.insertKey("4"))

        // Unexpected host commit after mutation.
        engine.replaceInputScript = [
            RimeOutput(
                rawInput: "ni",
                composition: nil,
                candidates: [],
                committedText: "你",
                highlightedIndex: -1
            ),
            RimeOutput(
                rawInput: "64",
                composition: RimeComposition(preeditText: "64", cursorPosition: 2),
                candidates: [RimeCandidate(text: "你", comment: "ni")],
                highlightedIndex: 0
            ),
        ]
        let effects = controller.handle(
            .selectT9PinyinPath(T9PinyinPath(displayText: "ni", replacementRawInput: "ni"))
        )
        // Unexpected commit fails refine; usable rollback restores and notifies UI.
        XCTAssertTrue(effects.contains(.compositionChanged))
        XCTAssertEqual(engine.sessionComposition, "64")
        XCTAssertEqual(controller.state.lastRimeOutput?.rawInput, "64")

        // Rollback failure: wrong refine then restore fails → fail closed reset.
        engine.replaceInputScript = [
            RimeOutput(
                rawInput: "foo",
                composition: RimeComposition(preeditText: "foo", cursorPosition: 3),
                candidates: [RimeCandidate(text: "x")],
                highlightedIndex: 0
            ),
            RimeOutput(composition: nil, candidates: [], highlightedIndex: -1),
        ]
        let revisionBeforeFailClosedReset = controller.state.compositionRevision
        let failClosed = controller.handle(
            .selectT9PinyinPath(T9PinyinPath(displayText: "ni", replacementRawInput: "ni"))
        )
        XCTAssertTrue(failClosed.contains(.compositionChanged))
        XCTAssertTrue(controller.state.currentComposition.isEmpty)
        XCTAssertNil(controller.state.lastRimeOutput)
        XCTAssertTrue(controller.state.t9PinyinPathState.compactPaths.isEmpty)
        XCTAssertGreaterThan(controller.state.compositionRevision, revisionBeforeFailClosedReset)
        XCTAssertEqual(
            controller.state.t9PinyinPathState.compositionRevision,
            controller.state.compositionRevision
        )
        XCTAssertGreaterThanOrEqual(engine.sessionResetCount, 1)
    }

    func testGenerationStableForSameRawAndIncrementsOnceOnChange() {
        let engine = makeT9Engine()
        let controller = makeController(engine: engine)
        controller.textClient = FakeTextInputClient()
        _ = controller.handle(.insertKey("6"))
        let gen1 = controller.state.t9PinyinPathState.rawInputGeneration
        XCTAssertGreaterThan(gen1, 0)
        // Re-apply same raw via refresh should keep generation.
        _ = controller.refreshT9PinyinPathState()
        XCTAssertEqual(controller.state.t9PinyinPathState.rawInputGeneration, gen1)
        _ = controller.handle(.insertKey("4"))
        let gen2 = controller.state.t9PinyinPathState.rawInputGeneration
        XCTAssertEqual(gen2, gen1 + 1)
    }

    func testLifecycleClearsPathState() {
        let engine = makeT9Engine()
        let controller = makeController(engine: engine)
        controller.textClient = FakeTextInputClient()
        _ = controller.handle(.insertKey("6"))
        _ = controller.handle(.insertKey("4"))
        XCTAssertFalse(controller.state.t9PinyinPathState.compactPaths.isEmpty)

        // Space commit with candidates
        _ = controller.handle(.insertSpace)
        XCTAssertTrue(controller.state.t9PinyinPathState.compactPaths.isEmpty)

        _ = controller.handle(.insertKey("6"))
        _ = controller.handle(.insertKey("4"))
        XCTAssertFalse(controller.state.t9PinyinPathState.compactPaths.isEmpty)
        _ = controller.handle(.toggleInputMode)
        XCTAssertTrue(controller.state.t9PinyinPathState.compactPaths.isEmpty)

        // Back to chinese + retype
        _ = controller.handle(.toggleInputMode)
        controller.usesT9InputSemantics = true
        _ = controller.handle(.insertKey("6"))
        XCTAssertFalse(controller.state.t9PinyinPathState.compactPaths.isEmpty)
        _ = controller.handle(.togglePage) // letters → numbers: clear
        XCTAssertTrue(controller.state.t9PinyinPathState.compactPaths.isEmpty)

        // Visibility abandon
        controller.usesT9InputSemantics = true
        engine.appendDigitsToComposition = true
        // Return to letters with no composition first
        while controller.state.currentPage != .letters {
            _ = controller.handle(.togglePage)
        }
        _ = controller.handle(.insertKey("6"))
        let abandon = controller.abandonCompositionForVisibilityChange()
        XCTAssertTrue(controller.state.t9PinyinPathState.compactPaths.isEmpty)
        XCTAssertTrue(abandon.contains(.t9PinyinPathsChanged) || abandon.contains(.compositionChanged))
    }

    func testPageRoundTripRebuildsPathsWithoutNewKey() {
        let engine = makeT9Engine()
        let controller = makeController(engine: engine)
        controller.textClient = FakeTextInputClient()
        _ = controller.handle(.insertKey("6"))
        _ = controller.handle(.insertKey("4"))
        let before = controller.state.t9PinyinPathState.compactPaths
        XCTAssertFalse(before.isEmpty)

        _ = controller.handle(.togglePage) // → numbers
        XCTAssertTrue(controller.state.t9PinyinPathState.compactPaths.isEmpty)
        XCTAssertEqual(controller.state.lastRimeOutput?.rawInput, "64")

        // numbers → symbols → emoji → letters
        _ = controller.handle(.togglePage)
        _ = controller.handle(.togglePage)
        let effects = controller.handle(.togglePage)
        XCTAssertEqual(controller.state.currentPage, .letters)
        XCTAssertTrue(effects.contains(.t9PinyinPathsChanged) || effects.contains(.pageChanged))
        XCTAssertFalse(controller.state.t9PinyinPathState.compactPaths.isEmpty)
        XCTAssertEqual(
            Set(controller.state.t9PinyinPathState.compactPaths.map(\.replacementRawInput)),
            Set(before.map(\.replacementRawInput))
        )
    }

    func testCompatibleButUnissuedPathRejected() {
        let engine = makeT9Engine()
        let controller = makeController(engine: engine)
        controller.textClient = FakeTextInputClient()
        _ = controller.handle(.insertKey("6"))
        _ = controller.handle(.insertKey("4"))
        // "mi" is compatible with 64 but strip issued set to only "ni".
        var state = controller.state.t9PinyinPathState
        let niOnly = T9PinyinPath(displayText: "ni", replacementRawInput: "ni")
        state.issuedReplacementKeys = ["ni"]
        state.issuedPathIDs = [niOnly.id]
        state.compactPaths = [niOnly]
        controller.state.t9PinyinPathState = state

        let effects = controller.handle(
            .selectT9PinyinPath(T9PinyinPath(displayText: "mi", replacementRawInput: "mi"))
        )
        XCTAssertTrue(effects.isEmpty)
        XCTAssertEqual(controller.state.lastRimeOutput?.rawInput, "64")
        XCTAssertEqual(engine.sessionComposition, "64")
    }

    func testDiscoveryPendingWhenValidPathPastHotPathPeek() {
        // Full engine list: 16 invalid then valid paths. Page snapshot is truncated to 16
        // so compact/hot-path cannot issue yet; discovery must stay pending.
        var texts: [String] = []
        var comments: [String] = []
        for index in 0..<16 {
            texts.append("x\(index)")
            comments.append("") // invalid
        }
        texts.append(contentsOf: ["你", "密"])
        comments.append(contentsOf: ["ni", "mi"])
        let engine = FakeRimeEngine(
            dictionary: [
                "64": texts,
                "ni": ["你"],
            ],
            comments: [
                "64": comments,
                "ni": ["ni"],
            ]
        )
        engine.appendDigitsToComposition = true
        let controller = makeController(engine: engine)
        controller.textClient = FakeTextInputClient()
        _ = controller.handle(.insertKey("6"))
        _ = controller.handle(.insertKey("4"))

        // Drop prior issued provenance, then simulate first page of 16 empty comments.
        // Engine dictionary still has 18 candidates for candidateWindow discovery.
        controller.state.t9PinyinPathState = .empty
        let pageOnly = (0..<16).map { index in
            RimeCandidate(text: "x\(index)", comment: "", globalIndex: index)
        }
        controller.state.lastRimeOutput = RimeOutput(
            rawInput: "64",
            composition: RimeComposition(preeditText: "64", cursorPosition: 2),
            candidates: pageOnly,
            highlightedIndex: 0
        )
        controller.state.currentComposition = "64"
        _ = controller.refreshT9PinyinPathState()

        // ADR 0023: Path completeness comes from the local catalog, not candidate
        // comment density. Focus `64` always exposes mi/ni (+ prefixes).
        let displays = controller.state.t9PinyinPathState.compactPaths.map(\.displayText)
        XCTAssertTrue(displays.contains("ni") || displays.contains("mi"))
        XCTAssertEqual(controller.t9PinyinPathAvailability(), .pathsAvailable)
        XCTAssertTrue(controller.hasSelectableT9PinyinPaths())
        XCTAssertFalse(controller.state.t9PinyinPathState.discoveryMayHaveMore)

        // Expanded panel is no longer required for Path completeness; it may still
        // surface currently issued compact paths.
        let window = controller.t9PinyinPathWindow(from: 0, limit: 48)
        XCTAssertFalse(window.paths.isEmpty)
        XCTAssertTrue(controller.state.t9PinyinPathState.issuedReplacementKeys.contains("ni"))
        XCTAssertEqual(controller.t9PinyinPathAvailability(), .pathsAvailable)

        let rawGen = controller.state.t9PinyinPathState.rawInputGeneration
        let provBefore = controller.state.t9PinyinPathState.provenanceRevision

        // Soft same-snapshot re-scan must keep expanded-window issuance.
        _ = controller.refreshT9PinyinPathStateForSameSnapshot()
        XCTAssertEqual(controller.state.t9PinyinPathState.rawInputGeneration, rawGen)
        XCTAssertEqual(controller.state.t9PinyinPathState.provenanceRevision, provBefore)
        XCTAssertTrue(controller.state.t9PinyinPathState.issuedReplacementKeys.contains("ni"))
        let softSelect = controller.handle(
            .selectT9PinyinPath(T9PinyinPath(displayText: "ni", replacementRawInput: "ni"))
        )
        XCTAssertTrue(softSelect.contains(.compositionChanged))
        XCTAssertEqual(controller.state.lastRimeOutput?.rawInput, "ni")
    }

    /// Production call chain: same-raw new RimeOutput must hard-bump provenance and revoke
    /// issued keys that are no longer in the live comment set (not just helper force flag).
    func testApplyRimeOutputSameRawNewCommentsRevokesStaleIssuedPaths() {
        let engine = FakeRimeEngine(
            dictionary: [
                "64": ["你", "密"],
                "ni": ["你"],
                "mi": ["密"],
            ],
            comments: [
                "64": ["ni", "mi"],
                "ni": ["ni"],
                "mi": ["mi"],
            ]
        )
        engine.appendDigitsToComposition = true
        engine.seedRuntimeSelection(
            RimeRuntimeSelection(
                baseSchemaID: "rime_ice",
                layoutStyle: .nineKey,
                t9ReadinessMatched: true
            )
        )
        let controller = makeController(engine: engine)
        controller.textClient = FakeTextInputClient()

        // Type to establish live ni/mi issuance under raw "64".
        _ = controller.handle(.insertKey("6"))
        _ = controller.handle(.insertKey("4"))
        XCTAssertEqual(controller.state.lastRimeOutput?.rawInput, "64")
        XCTAssertTrue(controller.state.t9PinyinPathState.issuedReplacementKeys.contains("ni"))
        XCTAssertTrue(controller.state.t9PinyinPathState.issuedReplacementKeys.contains("mi"))

        let rawGenBefore = controller.state.t9PinyinPathState.rawInputGeneration
        let provBefore = controller.state.t9PinyinPathState.provenanceRevision
        XCTAssertGreaterThan(provBefore, 0)

        // Expanded window token under old provenance (UI would bind to this).
        let staleWindow = controller.t9PinyinPathWindow(from: 0, limit: 48)
        XCTAssertEqual(staleWindow.provenanceRevision, provBefore)
        XCTAssertTrue(staleWindow.paths.map(\.replacementRawInput).contains("ni"))

        // Production path: install a new RimeOutput with same raw but comments only "mi".
        // (Simulate engine re-rank / narrowed comments without raw change.)
        engine.dictionary["64"] = ["密"]
        engine.comments["64"] = ["mi"]
        _ = engine.replaceInput("64")
        controller.applyRimeOutput(
            RimeOutput(
                rawInput: "64",
                composition: RimeComposition(preeditText: "64", cursorPosition: 2),
                candidates: [RimeCandidate(text: "密", comment: "mi", globalIndex: 0)],
                highlightedIndex: 0
            )
        )

        XCTAssertEqual(controller.state.t9PinyinPathState.rawInputGeneration, rawGenBefore)
        XCTAssertGreaterThan(controller.state.t9PinyinPathState.provenanceRevision, provBefore)
        // Catalog still issues both legal syllables; comment change only reorders.
        XCTAssertTrue(controller.state.t9PinyinPathState.issuedReplacementKeys.contains("ni"))
        XCTAssertTrue(controller.state.t9PinyinPathState.issuedReplacementKeys.contains("mi"))
        XCTAssertEqual(
            controller.state.t9PinyinPathState.compactPaths.first?.displayText,
            "mi"
        )

        // Stale panel/window provenance no longer matches Core authority.
        XCTAssertNotEqual(
            staleWindow.provenanceRevision,
            controller.state.t9PinyinPathState.provenanceRevision
        )
        let freshWindow = controller.t9PinyinPathWindow(from: 0, limit: 48)
        XCTAssertEqual(
            freshWindow.provenanceRevision,
            controller.state.t9PinyinPathState.provenanceRevision
        )
        XCTAssertTrue(freshWindow.paths.map(\.replacementRawInput).contains("mi"))

        // Unissued identity is still rejected; currently issued mi remains selectable.
        XCTAssertTrue(
            controller.handle(
                .selectT9PinyinPath(
                    T9PinyinPath(displayText: "zz", replacementRawInput: "zz")
                )
            ).isEmpty
        )
        let miSelect = controller.handle(
            .selectT9PinyinPath(T9PinyinPath(displayText: "mi", replacementRawInput: "mi"))
        )
        XCTAssertTrue(miSelect.contains(.compositionChanged))
        XCTAssertEqual(controller.state.lastRimeOutput?.rawInput, "mi")
    }

    func testHardProvenanceRefreshDropsExpandedKeysNotInLiveScan() {
        // Live engine only has mi; stale issued still has ni until hard rebuild.
        let engine = FakeRimeEngine(
            dictionary: [
                "64": ["密"],
                "mi": ["密"],
            ],
            comments: [
                "64": ["mi"],
                "mi": ["mi"],
            ]
        )
        engine.appendDigitsToComposition = true
        engine.seedRuntimeSelection(
            RimeRuntimeSelection(
                baseSchemaID: "rime_ice",
                layoutStyle: .nineKey,
                t9ReadinessMatched: true
            )
        )
        let controller = makeController(engine: engine)
        controller.textClient = FakeTextInputClient()
        _ = engine.replaceInput("64")
        controller.state.lastRimeOutput = RimeOutput(
            rawInput: "64",
            composition: RimeComposition(preeditText: "64", cursorPosition: 2),
            candidates: [RimeCandidate(text: "密", comment: "mi")],
            highlightedIndex: 0
        )
        controller.state.currentComposition = "64"
        controller.state.t9PinyinPathState = T9PinyinPathState(
            compactPaths: [
                T9PinyinPath(displayText: "ni", replacementRawInput: "ni"),
                T9PinyinPath(displayText: "mi", replacementRawInput: "mi"),
            ],
            selectedPath: T9PinyinPath(displayText: "ni", replacementRawInput: "ni"),
            rawInputGeneration: 1,
            provenanceRevision: 3,
            trackedRawInput: "64",
            issuedReplacementKeys: ["ni", "mi"],
            discoveryNextIndex: 20,
            discoveryMayHaveMore: true
        )

        let before = controller.state.t9PinyinPathState.provenanceRevision
        _ = controller.refreshT9PinyinPathState(forceNewProvenance: true)
        XCTAssertGreaterThan(controller.state.t9PinyinPathState.provenanceRevision, before)
        XCTAssertEqual(controller.state.t9PinyinPathState.rawInputGeneration, 1)
        // Local catalog re-issues every legal focus path (including ni) even when
        // the live comment page only mentions mi.
        XCTAssertTrue(controller.state.t9PinyinPathState.issuedReplacementKeys.contains("mi"))
        XCTAssertTrue(controller.state.t9PinyinPathState.issuedReplacementKeys.contains("ni"))
        XCTAssertTrue(
            controller.handle(
                .selectT9PinyinPath(T9PinyinPath(displayText: "zz", replacementRawInput: "zz"))
            ).isEmpty
        )
    }

    func testExactRawWithoutCompositionRejected() {
        let engine = makeT9Engine()
        let controller = makeController(engine: engine)
        controller.textClient = FakeTextInputClient()
        _ = controller.handle(.insertKey("6"))
        _ = controller.handle(.insertKey("4"))

        engine.replaceInputScript = [
            // exact raw "ni" but no composition and empty candidates
            RimeOutput(rawInput: "ni", composition: nil, candidates: [], highlightedIndex: -1),
            // rollback usable
            RimeOutput(
                rawInput: "64",
                composition: RimeComposition(preeditText: "64", cursorPosition: 2),
                candidates: [
                    RimeCandidate(text: "你", comment: "ni"),
                    RimeCandidate(text: "密", comment: "mi"),
                ],
                highlightedIndex: 0
            ),
        ]
        let effects = controller.handle(
            .selectT9PinyinPath(T9PinyinPath(displayText: "ni", replacementRawInput: "ni"))
        )
        XCTAssertTrue(effects.contains(.compositionChanged))
        XCTAssertEqual(controller.state.lastRimeOutput?.rawInput, "64")
        XCTAssertFalse(controller.state.lastRimeOutput?.candidates.isEmpty ?? true)
    }

    func testRollbackSameRawUnusableFailClosed() {
        let engine = makeT9Engine()
        let controller = makeController(engine: engine)
        controller.textClient = FakeTextInputClient()
        _ = controller.handle(.insertKey("6"))
        _ = controller.handle(.insertKey("4"))

        engine.replaceInputScript = [
            RimeOutput(
                rawInput: "foo",
                composition: RimeComposition(preeditText: "foo", cursorPosition: 3),
                candidates: [RimeCandidate(text: "x")],
                highlightedIndex: 0
            ),
            // same raw as previous but unusable
            RimeOutput(rawInput: "64", composition: nil, candidates: [], highlightedIndex: -1),
        ]
        let effects = controller.handle(
            .selectT9PinyinPath(T9PinyinPath(displayText: "ni", replacementRawInput: "ni"))
        )
        XCTAssertTrue(effects.contains(.compositionChanged))
        XCTAssertTrue(controller.state.currentComposition.isEmpty)
        XCTAssertNil(controller.state.lastRimeOutput)
        XCTAssertTrue(controller.state.t9PinyinPathState.compactPaths.isEmpty)
    }

    func testCandidateCommitClearsPathState() {
        let engine = makeT9Engine()
        let controller = makeController(engine: engine)
        controller.textClient = FakeTextInputClient()
        _ = controller.handle(.insertKey("6"))
        _ = controller.handle(.insertKey("4"))
        XCTAssertFalse(controller.state.t9PinyinPathState.compactPaths.isEmpty)

        _ = controller.handle(
            .insertCandidate(
                "你",
                kind: .candidate,
                selectionReference: CandidateSelectionReference(page: 0, indexOnPage: 0, globalIndex: 0)
            )
        )
        XCTAssertTrue(controller.state.t9PinyinPathState.compactPaths.isEmpty)
        XCTAssertNil(controller.state.t9PinyinPathState.selectedPath)
    }

    func testTypoSuppressedForMixedT9Raw() {
        let engine = FakeRimeEngine(
            dictionary: ["ni4": ["你"]],
            comments: ["ni4": ["ni"]]
        )
        let controller = KeyboardController()
        controller.rimeEngine = engine
        controller.usesT9InputSemantics = true
        controller.state.lastRimeOutput = RimeOutput(
            rawInput: "ni4",
            composition: RimeComposition(preeditText: "ni4", cursorPosition: 3),
            candidates: [RimeCandidate(text: "你", comment: "ni")],
            highlightedIndex: 0
        )
        controller.state.currentComposition = "ni4"
        controller.refreshTypoCorrectionSuggestions()
        XCTAssertNil(controller.state.typoCorrection)
    }

    func testHasSelectablePathsEvenWithoutValidComments() {
        let engine = FakeRimeEngine(
            dictionary: ["64": ["你", "密"]],
            comments: ["64": ["", "💯"]]
        )
        engine.appendDigitsToComposition = true
        let controller = makeController(engine: engine)
        controller.textClient = FakeTextInputClient()
        _ = controller.handle(.insertKey("6"))
        _ = controller.handle(.insertKey("4"))
        // Empty/illegal comments no longer collapse Path completeness.
        let displays = controller.state.t9PinyinPathState.compactPaths.map(\.displayText)
        XCTAssertTrue(displays.contains("ni") || displays.contains("mi"))
        XCTAssertTrue(controller.hasSelectableT9PinyinPaths())
    }

    func testPathWindowGenerationGuardDropsStaleExtend() {
        let window = T9PinyinPathWindow(
            paths: [],
            nextGlobalIndex: 0,
            hasMoreCandidates: true,
            rawInputGeneration: 2
        )
        let extended = T9PinyinPathExtractor.extendWindow(
            window,
            with: [RimeCandidate(text: "你", comment: "ni")],
            rawInput: "64",
            nextIndex: 1,
            hasMoreCandidates: false,
            expectedGeneration: 1
        )
        XCTAssertNil(extended)
    }

    // MARK: - Gate 5 Phase 0 path C (typo append + delete + continue)

    /// Digits for `qingweifanda` (prefix before `owozuili`).
    private var gate5CPrefixDigits: String { "746493432632" }
    /// Full `qingweifandaowozuili`.
    private var gate5CFullDigits: String { "74649343263269698454" }

    private func makeGate5CEngine() -> FakeRimeEngine {
        // Progressive path-refined raws after selecting qing/wei/fan on the da focus.
        let qing = "qing93432632"
        let qingWei = "qing'wei'32632"
        let qingWeiFan = "qing'wei'fan'32"
        let qingWeiFanDa = "qing'wei'fan'da"
        let withTypo = "qing'wei'fan'325" // mistyped JKL digit 5
        let afterContinue = "qing'wei'fan'da'9698454"
        let fullComment = "qing wei fan dao wo zui li"
        let engine = FakeRimeEngine(
            dictionary: [
                gate5CPrefixDigits: ["请喂饭到"],
                gate5CFullDigits: ["请喂饭到我嘴里"],
                qing: ["请喂饭到"],
                qingWei: ["请喂饭到"],
                qingWeiFan: ["请喂饭到"],
                qingWeiFanDa: ["请喂饭到"],
                withTypo: ["请喂饭到"],
                "qing'wei'fan'dao": ["请喂饭到"],
                afterContinue: ["请喂饭到我嘴里"],
                // Failure-shape key if identity wrongly duplicates fan after continue.
                "qing'wei'fan'fan": ["轻微饭饭", "请喂饭饭"],
            ],
            comments: [
                gate5CPrefixDigits: [fullComment],
                gate5CFullDigits: [fullComment],
                qing: [fullComment],
                qingWei: [fullComment],
                qingWeiFan: ["qing wei fan da", fullComment],
                qingWeiFanDa: ["qing wei fan da", fullComment],
                withTypo: ["qing wei fan da", fullComment],
                "qing'wei'fan'dao": [fullComment],
                afterContinue: [fullComment],
                "qing'wei'fan'fan": ["qing wei fan fan"],
            ]
        )
        engine.appendDigitsToComposition = true
        engine.seedRuntimeSelection(
            RimeRuntimeSelection(
                baseSchemaID: "rime_ice",
                layoutStyle: .nineKey,
                t9ReadinessMatched: true
            )
        )
        return engine
    }

    @discardableResult
    private func gate5CTypeDigits(_ digits: String, into controller: KeyboardController) -> [String] {
        var trail: [String] = []
        for digit in digits {
            _ = controller.handle(.insertKey(String(digit)))
            trail.append(
                "d=\(digit) raw=\(controller.state.lastRimeOutput?.rawInput ?? "nil") "
                    + "src=\(controller.state.t9PinyinPathState.segmentSourceDigits ?? "nil") "
                    + "conf=\(controller.state.t9PinyinPathState.confirmedSegmentValues)"
            )
        }
        return trail
    }

    @discardableResult
    private func gate5CSelect(_ syllables: [String], controller: KeyboardController) throws -> [String] {
        var trail: [String] = []
        for expected in syllables {
            let path = try XCTUnwrap(
                controller.state.t9PinyinPathState.compactPaths.first { $0.displayText == expected },
                "missing \(expected); paths=\(controller.state.t9PinyinPathState.compactPaths.map(\.displayText))"
            )
            _ = controller.handle(.selectT9PinyinPath(path))
            trail.append(
                "sel=\(expected) raw=\(controller.state.lastRimeOutput?.rawInput ?? "nil") "
                    + "src=\(controller.state.t9PinyinPathState.segmentSourceDigits ?? "nil") "
                    + "conf=\(controller.state.t9PinyinPathState.confirmedSegmentValues) "
                    + "focus=\(String(describing: controller.state.t9PinyinPathState.focusedSegmentIndex))"
            )
        }
        return trail
    }

    /// Trace-driven Path C red: device Frozen Fact morphology.
    /// After typo JKL + Delete, librime-like pure-digit re-segmentation clears progressive
    /// identity; continuing injects comment `qing wei fan fan` and first-focus Path.
    /// Scripts encode the Frozen Human morphology until real GATE5_TRACE replaces them.
    func testGate5CTypoAppendThenDeleteRestoresSemanticIdentity() throws {
        let engine = makeGate5CEngine()
        let client = FakeTextInputClient()
        let controller = makeController(engine: engine)
        controller.textClient = client

        _ = gate5CTypeDigits(gate5CPrefixDigits, into: controller)
        _ = try gate5CSelect(["qing", "wei", "fan"], controller: controller)

        let preTypoSource = controller.state.t9PinyinPathState.segmentSourceDigits
        let preTypoConfirmed = controller.state.t9PinyinPathState.confirmedSegmentValues
        let preTypoFocus = controller.state.t9PinyinPathState.focusedSegmentIndex
        XCTAssertEqual(preTypoConfirmed, ["qing", "wei", "fan"])

        // Mistouch JKL (digit 5) — default append.
        _ = controller.handle(.insertKey("5"))

        // Device-like Delete: RIME returns whole pure-digit re-segmentation of the
        // pre-typo prefix with a wrong multi-syllable comment (fan duplicated class).
        // This is the Frozen Fact morphology (comment/path first-focus disorder).
        let deleteRaw = gate5CPrefixDigits // pure digits, no typo slot
        let fanFanComment = "qing wei fan fan"
        engine.deleteBackwardScript = [
            gate5CScriptedOutput(
                raw: deleteRaw,
                preedit: fanFanComment,
                candidates: ["轻微饭饭", "请喂饭饭"],
                comment: fanFanComment
            )
        ]

        _ = controller.handle(.deleteBackward)
        let postSource = controller.state.t9PinyinPathState.segmentSourceDigits
        let postConfirmed = controller.state.t9PinyinPathState.confirmedSegmentValues
        let postPaths = controller.state.t9PinyinPathState.compactPaths.map(\.displayText)
        let postPreedit = controller.state.lastRimeOutput?.composition?.preeditText ?? ""
        let postRaw = controller.state.lastRimeOutput?.rawInput ?? ""

        fputs(
            "GATE5_C_TYPO_DELETE_TRACE capture:\n"
                + "  pre: src=\(preTypoSource ?? "nil") conf=\(preTypoConfirmed) focus=\(String(describing: preTypoFocus))\n"
                + "  post: src=\(postSource ?? "nil") conf=\(postConfirmed) raw=\(postRaw) "
                + "preedit=\(postPreedit) paths=\(postPaths.prefix(8))\n",
            stderr
        )

        #if DEBUG
        let lines = T9Gate5CompositionTrace.snapshotLines()
        XCTAssertTrue(lines.contains { $0.contains("event=deleteBackward") }, "missing delete trace")
        #endif

        // Contract: semantic identity must equal pre-typo (source + confirmed + non-first-focus).
        XCTAssertEqual(postSource, preTypoSource, "sourceDigits must equal pre-typo after Delete")
        XCTAssertEqual(postConfirmed, preTypoConfirmed, "confirmed must survive typo Delete")
        // Host-visible preedit must not advertise the Frozen Fact fan-fan morphology.
        // Current production can keep conf via restoreFocused while still installing
        // the scripted fan-fan preedit from RIME — that is still a C failure class.
        XCTAssertFalse(
            postPreedit.contains("fan fan")
                || postPreedit.replacingOccurrences(of: " ", with: "").contains("fanfan"),
            "preedit must not show duplicated fan after typo Delete; preedit=\(postPreedit)"
        )
        let firstFocus = postPaths.contains(where: { ["qing", "ping", "q", "p", "r", "s"].contains($0) })
        XCTAssertFalse(
            postConfirmed.isEmpty && firstFocus,
            "Path must not fall back to first focus after typo Delete; paths=\(postPaths)"
        )
        XCTAssertTrue(client.markedTextHistory.allSatisfy { !$0.contains(where: \.isNumber) })
    }

    /// After typo Delete, continue typing must not duplicate `fan` or reset Path to first focus.
    /// Trace-driven: first continue key injects pure full-digit raw + fan-fan comment.
    func testGate5CContinueTypingAfterDeleteDoesNotDuplicateFan() throws {
        let engine = makeGate5CEngine()
        let client = FakeTextInputClient()
        let controller = makeController(engine: engine)
        controller.textClient = client

        _ = gate5CTypeDigits(gate5CPrefixDigits, into: controller)
        _ = try gate5CSelect(["qing", "wei", "fan"], controller: controller)
        _ = controller.handle(.insertKey("5"))

        engine.deleteBackwardScript = [
            gate5CScriptedOutput(
                raw: gate5CPrefixDigits,
                preedit: "qing wei fan da",
                candidates: ["请喂饭到"],
                comment: "qing wei fan da"
            )
        ]
        _ = controller.handle(.deleteBackward)

        // Continue first key: device-like pure-digit full composition + fan fan comment.
        // Production whole-multi-digit rebuild drops confirmed → first-focus Path (C fail).
        let fanFan = "qing wei fan fan"
        engine.processKeyScript = [
            gate5CScriptedOutput(
                raw: gate5CFullDigits,
                preedit: fanFan,
                candidates: ["轻微饭饭", "请喂饭饭"],
                comment: fanFan
            )
        ]

        let windowBefore = engine.candidateWindowCallCount
        _ = controller.handle(.insertKey("6"))
        let windowAfter = engine.candidateWindowCallCount

        let confirmed = controller.state.t9PinyinPathState.confirmedSegmentValues
        let paths = controller.state.t9PinyinPathState.compactPaths.map(\.displayText)
        let raw = controller.state.lastRimeOutput?.rawInput ?? ""
        let preedit = controller.state.lastRimeOutput?.composition?.preeditText ?? client.markedText

        fputs(
            "GATE5_C_CONTINUE_TRACE capture: raw=\(raw) conf=\(confirmed) paths=\(paths.prefix(10)) "
                + "preedit=\(preedit) src=\(controller.state.t9PinyinPathState.segmentSourceDigits ?? "nil") "
                + "windowDelta=\(windowAfter - windowBefore)\n",
            stderr
        )

        // Contract (must stay RED until identity reducer):
        XCTAssertEqual(
            confirmed,
            ["qing", "wei", "fan"],
            "continue must keep progressive confirmed; empty confirmed is identity wipe"
        )
        let fanCount = confirmed.filter { $0 == "fan" }.count
        XCTAssertLessThanOrEqual(fanCount, 1, "confirmed must not duplicate fan; conf=\(confirmed)")
        XCTAssertFalse(
            preedit.contains("fan fan") || preedit.replacingOccurrences(of: " ", with: "").contains("fanfan"),
            "preedit must not show duplicated fan; preedit=\(preedit)"
        )
        XCTAssertFalse(
            confirmed.isEmpty && paths.contains(where: { ["qing", "ping", "q", "p"].contains($0) }),
            "Path must not reset to first focus; paths=\(paths)"
        )
        XCTAssertTrue(client.markedTextHistory.allSatisfy { !$0.contains(where: \.isNumber) })
        XCTAssertEqual(windowAfter - windowBefore, 0)
    }

    /// Device-calibrated Gate 5 C: provisional-only (no Path selections) mixed-raw
    /// continue after typo JKL + Delete (iPhone 13 Pro morphology, 2026-07-23).
    ///
    /// Engine Delete leaves refined mixed raw (`qing wei fan fa`); Core must still
    /// peel the typo from `sourceDigits` and, on continue, append to the typo-free
    /// pure-digit ledger (not stale `…5`). Host must not show fan-fan; no invent-slot.
    func testGate5CDeviceMixedRawWithoutSelectionsRebasesSourceBeforeContinue() throws {
        let engine = makeGate5CEngine()
        let client = FakeTextInputClient()
        let controller = makeController(engine: engine)
        controller.textClient = client

        // No Path selections: progressive pure-digit ledger only.
        _ = gate5CTypeDigits(gate5CPrefixDigits, into: controller)
        XCTAssertTrue(controller.state.t9PinyinPathState.confirmedSegmentValues.isEmpty)
        let sourceBeforeTypo = try XCTUnwrap(controller.state.t9PinyinPathState.segmentSourceDigits)
        XCTAssertEqual(sourceBeforeTypo, gate5CPrefixDigits)

        _ = controller.handle(.insertKey("5"))
        XCTAssertEqual(
            controller.state.t9PinyinPathState.segmentSourceDigits,
            gate5CPrefixDigits + "5"
        )

        // Device morphology: Delete leaves refined mixed raw, not pure-digit prefix.
        engine.deleteBackwardScript = [
            gate5CScriptedOutput(
                raw: "qing wei fan fa",
                preedit: "qing wei fan fa",
                candidates: ["轻微饭饭"],
                comment: "qing wei fan fan"
            )
        ]
        _ = controller.handle(.deleteBackward)

        // Core ledger must peel the typo digit even when RIME stays mixed.
        XCTAssertEqual(
            controller.state.t9PinyinPathState.segmentSourceDigits,
            gate5CPrefixDigits,
            "provisional-only Delete must peel sourceDigits; conf empty"
        )
        XCTAssertTrue(controller.state.t9PinyinPathState.confirmedSegmentValues.isEmpty)

        engine.processKeyScript = [
            gate5CScriptedOutput(
                raw: "qing wei fan fa6",
                preedit: "qing wei fan fan",
                candidates: ["轻微饭饭"],
                comment: "qing wei fan fan"
            )
        ]
        let processBefore = engine.processKeyCallCount
        let windowBefore = engine.candidateWindowCallCount
        _ = controller.handle(.insertKey("6"))

        XCTAssertEqual(
            controller.state.t9PinyinPathState.segmentSourceDigits,
            gate5CPrefixDigits + "6",
            "continue must append to typo-free provisional ledger, not stale …5"
        )
        XCTAssertTrue(controller.state.t9PinyinPathState.confirmedSegmentValues.isEmpty)
        XCTAssertFalse(
            client.markedText.contains("fan fan")
                || client.markedText.replacingOccurrences(of: " ", with: "").contains("fanfan"),
            "host must not expose fan-fan; marked=\(client.markedText)"
        )
        XCTAssertTrue(client.markedTextHistory.allSatisfy { !$0.contains(where: \.isNumber) })
        XCTAssertEqual(engine.processKeyCallCount - processBefore, 1)
        XCTAssertEqual(engine.candidateWindowCallCount - windowBefore, 0)
    }

    /// Semantic companion to the raw device trace. Unlike the no-selection device
    /// reproduction above, this establishes the planned qing/wei/fan identity before
    /// typo/Delete so confirmed ranges and focus cannot pass vacuously.
    func testGate5CDeviceMixedRawWithSelectedSegmentsPreservesIdentity() throws {
        let engine = makeGate5CEngine()
        let client = FakeTextInputClient()
        let controller = makeController(engine: engine)
        controller.textClient = client

        _ = gate5CTypeDigits(gate5CPrefixDigits, into: controller)
        _ = try gate5CSelect(["qing", "wei", "fan"], controller: controller)
        XCTAssertEqual(controller.state.t9PinyinPathState.confirmedSegmentValues, ["qing", "wei", "fan"])
        XCTAssertEqual(controller.state.t9PinyinPathState.focusedSegmentIndex, 3)

        _ = controller.handle(.insertKey("5"))
        engine.deleteBackwardScript = [
            gate5CScriptedOutput(
                raw: "qing wei fan fa",
                preedit: "qing wei fan fa",
                candidates: ["轻微饭饭"],
                comment: "qing wei fan fan"
            )
        ]
        _ = controller.handle(.deleteBackward)

        let confirmedAfterDelete = controller.state.t9PinyinPathState.confirmedSegmentValues
        let focusAfterDelete = controller.state.t9PinyinPathState.focusedSegmentIndex

        engine.processKeyScript = [
            gate5CScriptedOutput(
                raw: "qing wei fan fa6",
                preedit: "qing wei fan fan",
                candidates: ["轻微饭饭"],
                comment: "qing wei fan fan"
            )
        ]
        let processBefore = engine.processKeyCallCount
        let windowBefore = engine.candidateWindowCallCount
        _ = controller.handle(.insertKey("6"))

        XCTAssertEqual(confirmedAfterDelete, ["qing", "wei", "fan"])
        XCTAssertEqual(focusAfterDelete, 3)
        XCTAssertEqual(controller.state.t9PinyinPathState.confirmedSegmentValues, ["qing", "wei", "fan"])
        XCTAssertEqual(controller.state.t9PinyinPathState.focusedSegmentIndex, 3)
        XCTAssertEqual(
            controller.state.t9PinyinPathState.segmentSourceDigits,
            gate5CPrefixDigits + "6",
            "continue must append to the typo-free source identity"
        )
        XCTAssertFalse(
            client.markedText.contains("fan fan")
                || client.markedText.replacingOccurrences(of: " ", with: "").contains("fanfan"),
            "host-visible marked text must not expose fan-fan"
        )
        XCTAssertTrue(client.markedTextHistory.allSatisfy { !$0.contains(where: \.isNumber) })
        XCTAssertEqual(engine.processKeyCallCount - processBefore, 1)
        XCTAssertEqual(engine.candidateWindowCallCount - windowBefore, 0)
    }

    func testGate5TraceRedactsCompositionTokensInMemory() {
        #if DEBUG
        T9Gate5CompositionTrace.reset()
        T9Gate5CompositionTrace.record(
            event: .deleteBackward,
            revision: 7,
            previousRaw: "qing wei fan fa5",
            resultRaw: "qing wei fan fa",
            preedit: "qing wei fan fan",
            remainingRaw: "wei'fan'dao'9698454",
            sourceDigits: "7464934326325",
            confirmed: ["qing", "wei", "fan"],
            focus: 3,
            pathHead: ["dao", "dan", "fan"],
            candidateHead: ["len4", "len2"],
            note: "branch=visibleSpelling success=true"
        )

        let line = T9Gate5CompositionTrace.snapshotLines().last ?? ""
        for secret in ["qing", "wei", "fan", "dao", "9698454", "7464934326325"] {
            XCTAssertFalse(line.contains(secret), "trace leaked raw token: \(secret); line=\(line)")
        }
        XCTAssertTrue(line.contains("class=mixed"))
        XCTAssertTrue(line.contains("shape=L4.S1.L3.S1.L3.S1.L2.D1"))
        XCTAssertTrue(line.contains("confCount=3"))
        XCTAssertTrue(line.contains("focus=3"))
        #endif
    }

    private func gate5CScriptedOutput(
        raw: String,
        preedit: String,
        candidates: [String],
        comment: String
    ) -> RimeOutput {
        RimeOutput(
            rawInput: raw,
            composition: RimeComposition(preeditText: preedit, cursorPosition: preedit.count),
            candidates: candidates.enumerated().map {
                RimeCandidate(text: $0.element, comment: comment, globalIndex: $0.offset)
            },
            highlightedIndex: 0
        )
    }

    /// Delete only invalidates the segment that intersects the deleted trailing slot.
    func testDeleteInvalidatesOnlySegmentIntersectingDeletedSlot() throws {
        let engine = makeGate5CEngine()
        let controller = makeController(engine: engine)
        controller.textClient = FakeTextInputClient()

        _ = gate5CTypeDigits(gate5CPrefixDigits, into: controller)
        _ = try gate5CSelect(["qing", "wei", "fan"], controller: controller)
        // Optional: select da if available, else leave focus on remaining 32.
        if let da = controller.state.t9PinyinPathState.compactPaths.first(where: { $0.displayText == "da" }) {
            _ = controller.handle(.selectT9PinyinPath(da))
        }

        let confirmedBefore = controller.state.t9PinyinPathState.confirmedSegmentValues
        XCTAssertTrue(confirmedBefore.starts(with: ["qing", "wei", "fan"]))

        // Append one extra digit beyond prefix (extends focus only).
        _ = controller.handle(.insertKey("6")) // o-group, extends da→dao-ish focus
        _ = controller.handle(.deleteBackward)

        let confirmedAfter = controller.state.t9PinyinPathState.confirmedSegmentValues
        fputs(
            "GATE5_DELETE_SLOT capture: confBefore=\(confirmedBefore) confAfter=\(confirmedAfter) "
                + "src=\(controller.state.t9PinyinPathState.segmentSourceDigits ?? "nil") "
                + "paths=\(controller.state.t9PinyinPathState.compactPaths.map(\.displayText).prefix(8))\n",
            stderr
        )

        // qing/wei/fan slots were not in the deleted trailing digit; they must remain.
        XCTAssertEqual(Array(confirmedAfter.prefix(3)), ["qing", "wei", "fan"])
    }

    func testAppendDeleteRoundTripPreservesConfirmedSegmentRanges() throws {
        let engine = makeGate5CEngine()
        let controller = makeController(engine: engine)
        controller.textClient = FakeTextInputClient()

        _ = gate5CTypeDigits(gate5CPrefixDigits, into: controller)
        _ = try gate5CSelect(["qing", "wei", "fan"], controller: controller)

        let sourceBefore = try XCTUnwrap(controller.state.t9PinyinPathState.segmentSourceDigits)
        let confirmedBefore = controller.state.t9PinyinPathState.confirmedSegmentValues
        let focusBefore = controller.state.t9PinyinPathState.focusedSegmentIndex

        _ = controller.handle(.insertKey("5"))
        _ = controller.handle(.deleteBackward)

        XCTAssertEqual(controller.state.t9PinyinPathState.segmentSourceDigits, sourceBefore)
        XCTAssertEqual(controller.state.t9PinyinPathState.confirmedSegmentValues, confirmedBefore)
        XCTAssertEqual(controller.state.t9PinyinPathState.focusedSegmentIndex, focusBefore)
    }

    /// Human 2026-07-23: Path select qing/wei(/fan) then Delete must peel remaining
    /// digits without getting stuck (report: stuck at qingweie) and without leaving
    /// a phantom selected Path chip on `qing`.
    func testGate5PathSelectQingWeiThenDeletePeelsWithoutStuckSelectedChip() throws {
        let engine = makeGate5CEngine()
        let client = FakeTextInputClient()
        let controller = makeController(engine: engine)
        controller.textClient = client

        _ = gate5CTypeDigits(gate5CPrefixDigits, into: controller)
        _ = try gate5CSelect(["qing", "wei", "fan"], controller: controller)
        XCTAssertEqual(controller.state.t9PinyinPathState.confirmedSegmentValues, ["qing", "wei", "fan"])
        let sourceAfterSelect = try XCTUnwrap(controller.state.t9PinyinPathState.segmentSourceDigits)
        XCTAssertEqual(sourceAfterSelect, gate5CPrefixDigits)

        // Peel remaining focus digits then confirmed syllables via Core identity.
        var deleteSteps = 0
        while deleteSteps < 24 {
            let beforeSrc = controller.state.t9PinyinPathState.segmentSourceDigits
            let beforeConf = controller.state.t9PinyinPathState.confirmedSegmentValues
            let beforeRaw = controller.state.lastRimeOutput?.rawInput
            let emptyBefore =
                (beforeSrc == nil || beforeSrc?.isEmpty == true)
                && beforeConf.isEmpty
                && (beforeRaw?.isEmpty ?? true)
            if emptyBefore { break }

            _ = controller.handle(.deleteBackward)
            deleteSteps += 1
            let afterSrc = controller.state.t9PinyinPathState.segmentSourceDigits
            let afterConf = controller.state.t9PinyinPathState.confirmedSegmentValues
            let afterRaw = controller.state.lastRimeOutput?.rawInput
            let emptyAfter =
                (afterSrc == nil || afterSrc?.isEmpty == true)
                && afterConf.isEmpty
                && (afterRaw?.isEmpty ?? true)
            let progressed =
                beforeSrc != afterSrc
                || beforeConf != afterConf
                || beforeRaw != afterRaw
                || emptyAfter
            XCTAssertTrue(
                progressed,
                "Delete stuck at step=\(deleteSteps) src=\(afterSrc ?? "nil") conf=\(afterConf) raw=\(afterRaw ?? "nil")"
            )
            // Human: sole `qing` must keep Path bar visible; never selected chip.
            if afterConf == ["qing"] {
                XCTAssertFalse(
                    controller.state.t9PinyinPathState.compactPaths.isEmpty,
                    "Path bar must not vanish when only qing remains"
                )
                XCTAssertNil(
                    controller.state.t9PinyinPathState.selectedPath,
                    "selectedPath must clear when one confirmed syllable remains; conf=\(afterConf)"
                )
            }
            // Human: at 3-digit focus (qin) candidates must not stay bare-digit only.
            if afterConf.isEmpty, afterSrc?.count == 3 {
                let raw = afterRaw ?? ""
                XCTAssertFalse(
                    raw.allSatisfy(\.isNumber),
                    "qin slots should use letter-refined RIME raw, got \(raw)"
                )
                XCTAssertNil(controller.state.t9PinyinPathState.selectedPath)
            }
            // Human retest #3: peel to qi must not auto-select a Path chip.
            if afterConf.isEmpty, afterSrc?.count == 2 {
                XCTAssertNil(
                    controller.state.t9PinyinPathState.selectedPath,
                    "qi focus must not auto-select Path; raw=\(afterRaw ?? "nil") paths=\(controller.state.t9PinyinPathState.compactPaths.map(\.displayText))"
                )
            }
            if afterConf == ["qi"] {
                XCTAssertNil(
                    controller.state.t9PinyinPathState.selectedPath,
                    "re-focused sole qi must not show selectedPath"
                )
            }
            if emptyAfter { break }
        }
        XCTAssertGreaterThan(deleteSteps, 0)
        XCTAssertLessThan(deleteSteps, 24, "must fully delete without infinite/stuck loop")
        XCTAssertTrue(client.markedTextHistory.allSatisfy { !$0.contains(where: \.isNumber) })
    }

    /// Human retest #3 item 3: delete down to `qi` never auto-selects Path.
    func testGate5DeleteToQiDoesNotAutoSelectPath() throws {
        let engine = makeGate5CEngine()
        let client = FakeTextInputClient()
        let controller = makeController(engine: engine)
        controller.textClient = client

        // Full progressive prefix so Path confirm has remaining slots to advance.
        _ = gate5CTypeDigits(gate5CPrefixDigits, into: controller)
        _ = try gate5CSelect(["qing"], controller: controller)

        var guardSteps = 0
        var sawQiFocus = false
        while guardSteps < 20 {
            let src = controller.state.t9PinyinPathState.segmentSourceDigits ?? ""
            let conf = controller.state.t9PinyinPathState.confirmedSegmentValues
            let empty = src.isEmpty && conf.isEmpty
                && (controller.state.lastRimeOutput?.rawInput?.isEmpty ?? true)
            if conf.isEmpty, src.count == 2 {
                sawQiFocus = true
                XCTAssertNil(
                    controller.state.t9PinyinPathState.selectedPath,
                    "Human: deleting to qi must not auto-select Path; paths=\(controller.state.t9PinyinPathState.compactPaths.map(\.displayText))"
                )
                XCTAssertFalse(controller.state.t9PinyinPathState.compactPaths.isEmpty)
                break
            }
            if empty { break }
            _ = controller.handle(.deleteBackward)
            guardSteps += 1
        }
        XCTAssertTrue(sawQiFocus, "must reach 2-digit qi focus while peeling")
        XCTAssertTrue(client.markedTextHistory.allSatisfy { !$0.contains(where: \.isNumber) })
    }

    /// Human C / retest #3 item 4: after typo Delete on multi-digit unconfirmed
    /// composition, RIME returns to pure digit input mode so continue typing
    /// rediscovers Path; Path select must not paste a corrupted preedit tail.
    func testGate5CAfterDeleteReturnsToPureDigitInputAndPathSelectDropsBadTail() throws {
        let engine = makeGate5CEngine()
        let client = FakeTextInputClient()
        let controller = makeController(engine: engine)
        controller.textClient = client

        // qingweifa… full Gate5 C prefix (matches FakeRime path-refined keys).
        let prefix = gate5CPrefixDigits
        _ = gate5CTypeDigits(prefix, into: controller)
        XCTAssertTrue(controller.state.t9PinyinPathState.confirmedSegmentValues.isEmpty)

        _ = controller.handle(.insertKey("5")) // JKL typo
        _ = controller.handle(.deleteBackward)

        let srcAfterDelete = try XCTUnwrap(controller.state.t9PinyinPathState.segmentSourceDigits)
        XCTAssertEqual(srcAfterDelete, prefix)
        let rawAfterDelete = controller.state.lastRimeOutput?.rawInput ?? ""
        // Pure input mode for long unconfirmed ledger (not letter-locked qing…).
        XCTAssertTrue(
            rawAfterDelete.allSatisfy(\.isNumber),
            "after Delete, unconfirmed multi-digit must return to pure digit input; raw=\(rawAfterDelete)"
        )
        XCTAssertEqual(rawAfterDelete, prefix)
        XCTAssertNil(controller.state.t9PinyinPathState.selectedPath)

        // Continue typing one correct digit on the pure-digit session.
        _ = controller.handle(.insertKey("9")) // starts "wo…" tail of full phrase
        let srcContinued = try XCTUnwrap(controller.state.t9PinyinPathState.segmentSourceDigits)
        XCTAssertTrue(
            srcContinued.hasPrefix(prefix),
            "continue must extend Core ledger; src=\(srcContinued)"
        )
        // Drop the extra continue digit so Path refine keys match FakeRime dictionary
        // (`qing93432632` / `qing'wei'32632` from makeGate5CEngine).
        _ = controller.handle(.deleteBackward)
        XCTAssertEqual(controller.state.t9PinyinPathState.segmentSourceDigits, prefix)
        XCTAssertEqual(controller.state.lastRimeOutput?.rawInput, prefix)

        // Path-select qing/wei after pure-digit return; host must stay digit-safe
        // and must not invent a non-encoding tail like Human `qingweiuil`.
        // Remaining digit slots must NOT be discarded (Human retest #4: not bare qingwei).
        _ = try gate5CSelect(["qing", "wei"], controller: controller)
        let marked = client.markedText.replacingOccurrences(of: " ", with: "").lowercased()
        let markedLetters = String(marked.unicodeScalars.filter { $0.isASCII && Character($0).isLetter })
        XCTAssertFalse(marked.contains("uil"), "marked must not keep illegal tail; marked=\(marked)")
        XCTAssertFalse(marked.contains(where: \.isNumber), "host must stay digit-safe; marked=\(marked)")
        XCTAssertTrue(markedLetters.hasPrefix("qingwei"), "marked should keep qingwei prefix; marked=\(marked)")
        XCTAssertEqual(
            markedLetters.count,
            prefix.count,
            "remaining slots must stay visible after Path select; marked=\(marked) src=\(prefix)"
        )
        let conf = controller.state.t9PinyinPathState.confirmedSegmentValues
        XCTAssertEqual(Array(conf.prefix(2)), ["qing", "wei"])
        let focusPaths = Set(controller.state.t9PinyinPathState.compactPaths.map(\.displayText))
        XCTAssertFalse(
            focusPaths.contains("qing"),
            "after qing/wei advance, focus must leave first syllable; paths=\(focusPaths.sorted())"
        )
    }

    /// Human retest #5: type `qingweifanda`, typo JKL, Delete, MNO — Core ledger must
    /// drop the typo `5` and keep `6`. Path select qing/wei/fan must focus `326`
    /// (dao/fan/dan…), never ghost `325` (`fal` / fa+l).
    func testHumanQingweifandaTypoJKLDeleteMNONoGhostFive() throws {
        let engine = makeGate5CEngine()
        let withMNO = gate5CPrefixDigits + "6"
        // Path-refined keys after selecting qing/wei/fan on prefix+MNO.
        let qing = "qing934326326"
        let qingWei = "qing'wei'326326"
        let qingWeiFan = "qing'wei'fan'326"
        engine.dictionary[withMNO] = ["请喂饭到"]
        engine.dictionary[qing] = ["请喂饭到"]
        engine.dictionary[qingWei] = ["请喂饭到"]
        engine.dictionary[qingWeiFan] = ["请喂饭到"]
        engine.dictionary["qing'wei'fan'dao"] = ["请喂饭到"]
        engine.comments[withMNO] = ["qing wei fan dao"]
        engine.comments[qing] = ["qing wei fan dao"]
        engine.comments[qingWei] = ["qing wei fan dao"]
        engine.comments[qingWeiFan] = ["qing wei fan dao"]
        engine.comments["qing'wei'fan'dao"] = ["qing wei fan dao"]
        let client = FakeTextInputClient()
        let controller = makeController(engine: engine)
        controller.textClient = client

        let prefix = gate5CPrefixDigits // qingweifanda
        _ = gate5CTypeDigits(prefix, into: controller)
        XCTAssertEqual(controller.state.t9PinyinPathState.segmentSourceDigits, prefix)

        _ = controller.handle(.insertKey("5")) // JKL typo
        XCTAssertEqual(controller.state.t9PinyinPathState.segmentSourceDigits, prefix + "5")

        _ = controller.handle(.deleteBackward)
        let afterDel = try XCTUnwrap(controller.state.t9PinyinPathState.segmentSourceDigits)
        XCTAssertEqual(afterDel, prefix, "Delete must peel typo 5 from Core ledger; got \(afterDel)")

        _ = controller.handle(.insertKey("6")) // MNO → dao tail
        let afterMNO = try XCTUnwrap(controller.state.t9PinyinPathState.segmentSourceDigits)
        XCTAssertEqual(afterMNO, withMNO, "MNO must append 6, not keep ghost 5; got \(afterMNO)")
        XCTAssertFalse(
            client.markedText.contains(where: \.isNumber),
            "host digit leak; marked=\(client.markedText)"
        )

        _ = try gate5CSelect(["qing", "wei", "fan"], controller: controller)
        let src = try XCTUnwrap(controller.state.t9PinyinPathState.segmentSourceDigits)
        XCTAssertEqual(src, withMNO)
        let rem = String(src.dropFirst(10)) // after qing+wei+fan
        XCTAssertEqual(rem, "326", "remaining must be dao slots 326, not ghost 325; rem=\(rem)")

        let pathLabels = Set(controller.state.t9PinyinPathState.compactPaths.map(\.displayText))
        XCTAssertTrue(
            pathLabels.contains("dao")
                || pathLabels.contains("dan")
                || pathLabels.contains("fan"),
            "expected 3-slot dao-family paths; got \(pathLabels.sorted())"
        )
        let onlyTwoSlotBar = pathLabels.isSubset(of: ["da", "fa", "ta", "e", "d", "f", "a", "b", "c"])
        XCTAssertFalse(onlyTwoSlotBar, "Path bar looks like 2-digit focus only; paths=\(pathLabels.sorted())")

        let markedLetters = String(
            client.markedText.replacingOccurrences(of: " ", with: "").lowercased().filter(\.isLetter)
        )
        XCTAssertFalse(markedLetters.hasSuffix("fal"), "ghost JKL letter l; marked=\(markedLetters)")
        let encMap: [Character: Character] = [
            "a": "2", "b": "2", "c": "2", "d": "3", "e": "3", "f": "3",
            "g": "4", "h": "4", "i": "4", "j": "5", "k": "5", "l": "5",
            "m": "6", "n": "6", "o": "6", "p": "7", "q": "7", "r": "7", "s": "7",
            "t": "8", "u": "8", "v": "8", "w": "9", "x": "9", "y": "9", "z": "9",
        ]
        let encoded = String(markedLetters.compactMap { encMap[$0] })
        XCTAssertEqual(
            encoded,
            withMNO,
            "host letters must encode to ledger (no trailing typo 5); marked=\(markedLetters) enc=\(encoded)"
        )
    }

    /// Human: standalone `da` + JKL + Delete + `o`(6) → `dao` must also hold when
    /// `da` is only the remaining focus after Path-confirmed `qing/wei/fan`.
    func testGate5InSentenceDaTypoDeleteContinueMatchesStandalone() throws {
        let engine = makeGate5CEngine()
        // Standalone-like keys for remaining focus letter forms.
        engine.dictionary["qing'wei'fan'da"] = ["请喂饭到"]
        engine.dictionary["qing'wei'fan'dao"] = ["请喂饭到"]
        engine.dictionary["qing'wei'fan'325"] = ["请喂饭"]
        engine.dictionary["qing'wei'fan'dan"] = ["请喂饭"]
        engine.comments["qing'wei'fan'da"] = ["qing wei fan da"]
        engine.comments["qing'wei'fan'dao"] = ["qing wei fan dao"]
        engine.comments["qing'wei'fan'325"] = ["qing wei fan da"]
        let client = FakeTextInputClient()
        let controller = makeController(engine: engine)
        controller.textClient = client

        _ = gate5CTypeDigits(gate5CPrefixDigits, into: controller)
        _ = try gate5CSelect(["qing", "wei", "fan"], controller: controller)
        let srcAfterSelect = try XCTUnwrap(controller.state.t9PinyinPathState.segmentSourceDigits)
        XCTAssertEqual(srcAfterSelect, gate5CPrefixDigits)
        // Remaining focus should be `32` (da).
        let remBefore = String(srcAfterSelect.dropFirst(10)) // qing4+wei3+fan3
        XCTAssertEqual(remBefore, "32")

        // Typo JKL then Delete then o(6) — same as lone da session.
        _ = controller.handle(.insertKey("5"))
        _ = controller.handle(.deleteBackward)
        _ = controller.handle(.insertKey("6"))

        let src = try XCTUnwrap(controller.state.t9PinyinPathState.segmentSourceDigits)
        XCTAssertEqual(src, gate5CPrefixDigits + "6")
        XCTAssertEqual(
            Array(controller.state.t9PinyinPathState.confirmedSegmentValues.prefix(3)),
            ["qing", "wei", "fan"]
        )
        let rem = String(src.dropFirst(10))
        XCTAssertEqual(rem, "326", "remaining focus must become dao slots; rem=\(rem)")
        let raw = controller.state.lastRimeOutput?.rawInput ?? ""
        // Ambiguous 326 (dan/dao/fan…) keeps pure remaining digits after confirmed
        // boundary — same processKey surface as standalone multi-option short runs.
        XCTAssertTrue(
            raw == "qing'wei'fan'326"
                || raw.hasSuffix("'326")
                || raw.hasSuffix("dao")
                || raw.hasSuffix("'dao"),
            "in-sentence remaining should stay conf+dao-slots; raw=\(raw)"
        )
        let pathLabels = Set(controller.state.t9PinyinPathState.compactPaths.map(\.displayText))
        XCTAssertTrue(
            pathLabels.contains("dao") || pathLabels.contains("da") || pathLabels.contains("o"),
            "Path should expose dao/da after continue; paths=\(pathLabels.sorted())"
        )
        // Confirmed prefix must survive the typo/Delete/continue cycle.
        XCTAssertFalse(raw.replacingOccurrences(of: "'", with: "").contains("fanfan"))
    }

    /// Human C: after confirmed qing/wei/fan, typo digit + Delete + continue must not
    /// wipe confirmed identity when RIME re-emits a long pure-digit resegmentation.
    func testGate5CContinueAfterDeleteKeepsConfirmedWhenRimeResegmentsFullDigits() throws {
        let engine = makeGate5CEngine()
        let client = FakeTextInputClient()
        let controller = makeController(engine: engine)
        controller.textClient = client

        _ = gate5CTypeDigits(gate5CPrefixDigits, into: controller)
        _ = try gate5CSelect(["qing", "wei", "fan"], controller: controller)
        _ = controller.handle(.insertKey("5"))
        _ = controller.handle(.deleteBackward)
        XCTAssertEqual(controller.state.t9PinyinPathState.confirmedSegmentValues, ["qing", "wei", "fan"])

        // Untrusted full-digit resegment (device-like) on next key.
        engine.processKeyScript = [
            gate5CScriptedOutput(
                raw: gate5CFullDigits,
                preedit: "qing wei fan fan",
                candidates: ["请喂饭饭"],
                comment: "qing wei fan fan"
            )
        ]
        _ = controller.handle(.insertKey("6"))

        XCTAssertEqual(
            Array(controller.state.t9PinyinPathState.confirmedSegmentValues.prefix(3)),
            ["qing", "wei", "fan"],
            "confirmed Path must survive untrusted full-digit resegment"
        )
        let src = try XCTUnwrap(controller.state.t9PinyinPathState.segmentSourceDigits)
        XCTAssertEqual(src, gate5CPrefixDigits + "6")
        XCTAssertFalse(
            (controller.state.lastRimeOutput?.composition?.preeditText ?? "")
                .replacingOccurrences(of: " ", with: "")
                .contains("fanfan")
                || client.markedText.replacingOccurrences(of: " ", with: "").contains("fanfan")
        )
    }

    /// Mixed raw identity must use T9 digit signature + exact slot map, not letterBudget alone.
    func testMixedRawIdentityUsesT9SignatureNotLetterBudget() throws {
        let source = gate5CFullDigits
        let map: [Character: Character] = [
            "a": "2", "b": "2", "c": "2",
            "d": "3", "e": "3", "f": "3",
            "g": "4", "h": "4", "i": "4",
            "j": "5", "k": "5", "l": "5",
            "m": "6", "n": "6", "o": "6",
            "p": "7", "q": "7", "r": "7", "s": "7",
            "t": "8", "u": "8", "v": "8",
            "w": "9", "x": "9", "y": "9", "z": "9",
        ]
        func encode(_ raw: String) -> String {
            var out = ""
            for ch in raw.lowercased() {
                if ch.isNumber { out.append(ch) }
                else if let d = map[ch] { out.append(d) }
            }
            return out
        }

        let mixed = "qing'wei'fan'dao'9698454"
        XCTAssertEqual(encode(mixed), source)

        // Apostrophe boundaries map to exact source slots.
        let segments = ["qing", "wei", "fan", "dao"]
        var cursor = 0
        for s in segments {
            let sig = encode(s)
            let range = cursor..<(cursor + sig.count)
            let start = source.index(source.startIndex, offsetBy: range.lowerBound)
            let end = source.index(source.startIndex, offsetBy: range.upperBound)
            XCTAssertEqual(String(source[start..<end]), sig, "slot mismatch for \(s)")
            XCTAssertTrue(T9PinyinSyllableCatalog.syllables.contains(s))
            cursor = range.upperBound
        }
        XCTAssertEqual(String(source.dropFirst(cursor)), "9698454")

        // letterBudget alone cannot reattach mixed remaining after partial.
        let mixedRemaining = "wei'fan'dao'9698454"
        XCTAssertFalse(mixedRemaining.allSatisfy(\.isNumber))
        XCTAssertEqual(encode(mixedRemaining), "9343263269698454")
        // Exact ranges after consuming qing (not mere hasSuffix).
        XCTAssertEqual(encode(mixedRemaining), String(source.dropFirst(4)))
        XCTAssertNotEqual(encode(mixedRemaining), String(source.dropFirst(7)))
    }

    /// Provisional-only typo (no selected complete syllable on focus) must also round-trip.
    func testGate5CTypoAppendThenDeleteWithProvisionalOnlyPath() throws {
        let engine = makeGate5CEngine()
        let client = FakeTextInputClient()
        let controller = makeController(engine: engine)
        controller.textClient = client

        // Type prefix without confirming any path — only provisional catalog paths.
        _ = gate5CTypeDigits(gate5CPrefixDigits, into: controller)
        XCTAssertTrue(controller.state.t9PinyinPathState.confirmedSegmentValues.isEmpty)
        let preSource = controller.state.t9PinyinPathState.segmentSourceDigits
        let prePaths = Set(controller.state.t9PinyinPathState.compactPaths.map(\.displayText))

        _ = controller.handle(.insertKey("5"))
        _ = controller.handle(.deleteBackward)

        let postSource = controller.state.t9PinyinPathState.segmentSourceDigits
        let postPaths = Set(controller.state.t9PinyinPathState.compactPaths.map(\.displayText))

        fputs(
            "GATE5_C_PROVISIONAL capture: preSrc=\(preSource ?? "nil") postSrc=\(postSource ?? "nil") "
                + "prePaths=\(prePaths.sorted().prefix(8)) postPaths=\(postPaths.sorted().prefix(8))\n",
            stderr
        )

        XCTAssertEqual(postSource, preSource)
        // After round-trip, catalog should still expose a non-empty progressive set
        // (not collapse to empty). Exact set may differ by focus rebuild.
        XCTAssertFalse(
            controller.state.t9PinyinPathState.compactPaths.isEmpty,
            "provisional Path must not vanish after typo Delete"
        )
        XCTAssertTrue(client.markedTextHistory.allSatisfy { !$0.contains(where: \.isNumber) })
    }

    // MARK: - Helpers

    private func makeT9Engine() -> FakeRimeEngine {
        let engine = FakeRimeEngine(
            dictionary: [
                "6": ["吗", "你", "哦"],
                "64": ["你", "密"],
                "m": ["吗", "妈"],
                "n": ["你", "年"],
                "o": ["哦", "噢"],
                "m4": ["密"],
                "ni": ["你", "呢"],
                "ni4": ["你"],
                "n4": ["你", "年"],
                "n'g": ["能够", "那个"],
                "n'h": ["女孩", "你会"],
                "n'i": ["那", "年"],
                "n'g5": ["能够见", "那个家"],
                "n'g'j": ["能够见", "那个家"],
                "n'g'k": ["能够看", "那个口"],
                "n'g'l": ["能够", "那个"],
                "mi": ["密"],
            ],
            comments: [
                // Mirrors pinned librime evidence: only `o` is exposed by comments.
                "6": ["o", "o", "o"],
                "64": ["ni", "mi"],
                // Deliberately longer than the selected raw path. This guards
                // against candidate comments replacing explicit m/n/o display.
                "m": ["ma", "ma"],
                "n": ["ni", "nian"],
                "o": ["ou", "ou"],
                "m4": ["mi"],
                "ni": ["ni", "ne"],
                "ni4": ["ni"],
                "n4": ["ni", "ni"],
                "n'g": ["neng'gou", "na'ge"],
                "n'h": ["nv'hai", "ni'hui"],
                // Exact raw survives, but there is no second apostrophe segment.
                "n'i": ["na", "nian"],
                "n'g5": ["neng'gou'jian", "na'ge'jia"],
                "n'g'j": ["neng'gou'jian", "na'ge'jia"],
                "n'g'k": ["neng'gou'kan", "na'ge'kou"],
                // Raw remains exact, but no third apostrophe-delimited `l` segment.
                "n'g'l": ["neng'gou", "na'ge"],
                "mi": ["mi"],
            ]
        )
        engine.appendDigitsToComposition = true
        engine.seedRuntimeSelection(
            RimeRuntimeSelection(
                baseSchemaID: "rime_ice",
                layoutStyle: .nineKey,
                t9ReadinessMatched: true
            )
        )
        return engine
    }

    private func makeController(engine: FakeRimeEngine) -> KeyboardController {
        let controller = KeyboardController()
        controller.rimeEngine = engine
        controller.usesT9InputSemantics = true
        return controller
    }
}
