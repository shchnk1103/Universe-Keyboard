import XCTest

@testable import KeyboardCore

@MainActor
final class T9PinyinPathTests: XCTestCase {
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

        // Live provenance: ni must disappear; mi remains.
        XCTAssertFalse(controller.state.t9PinyinPathState.issuedReplacementKeys.contains("ni"))
        XCTAssertTrue(controller.state.t9PinyinPathState.issuedReplacementKeys.contains("mi"))
        XCTAssertFalse(
            controller.state.t9PinyinPathState.compactPaths
                .contains { $0.replacementRawInput == "ni" }
        )
        XCTAssertTrue(
            controller.state.t9PinyinPathState.compactPaths
                .contains { $0.replacementRawInput == "mi" }
        )
        XCTAssertNotEqual(
            controller.state.t9PinyinPathState.selectedPath?.replacementRawInput,
            "ni"
        )

        // Bare ni selection must be rejected after live rebuild.
        let niRejected = controller.handle(
            .selectT9PinyinPath(T9PinyinPath(displayText: "ni", replacementRawInput: "ni"))
        )
        XCTAssertTrue(niRejected.isEmpty)
        XCTAssertEqual(controller.state.lastRimeOutput?.rawInput, "64")

        // Live mi remains selectable.
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
        let failClosed = controller.handle(
            .selectT9PinyinPath(T9PinyinPath(displayText: "ni", replacementRawInput: "ni"))
        )
        XCTAssertTrue(failClosed.contains(.compositionChanged))
        XCTAssertTrue(controller.state.currentComposition.isEmpty)
        XCTAssertNil(controller.state.lastRimeOutput)
        XCTAssertTrue(controller.state.t9PinyinPathState.compactPaths.isEmpty)
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
        state.issuedReplacementKeys = ["ni"]
        state.compactPaths = [T9PinyinPath(displayText: "ni", replacementRawInput: "ni")]
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

        XCTAssertTrue(controller.state.t9PinyinPathState.compactPaths.isEmpty)
        XCTAssertTrue(controller.state.t9PinyinPathState.issuedReplacementKeys.isEmpty)
        XCTAssertTrue(controller.state.t9PinyinPathState.discoveryMayHaveMore)
        XCTAssertEqual(controller.t9PinyinPathAvailability(), .discoveryPending)
        XCTAssertTrue(controller.hasSelectableT9PinyinPaths())

        // Panel-sized window discovers issued paths past the hot-path frontier.
        let window = controller.t9PinyinPathWindow(from: 0, limit: 48)
        XCTAssertTrue(window.paths.map(\.replacementRawInput).contains("ni"))
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
        XCTAssertFalse(controller.state.t9PinyinPathState.issuedReplacementKeys.contains("ni"))
        XCTAssertTrue(controller.state.t9PinyinPathState.issuedReplacementKeys.contains("mi"))

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
        XCTAssertFalse(freshWindow.paths.map(\.replacementRawInput).contains("ni"))
        XCTAssertTrue(freshWindow.paths.map(\.replacementRawInput).contains("mi"))

        // ni revoked; mi still selectable under new provenance.
        XCTAssertTrue(
            controller.handle(
                .selectT9PinyinPath(T9PinyinPath(displayText: "ni", replacementRawInput: "ni"))
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
        XCTAssertFalse(controller.state.t9PinyinPathState.issuedReplacementKeys.contains("ni"))
        XCTAssertTrue(controller.state.t9PinyinPathState.issuedReplacementKeys.contains("mi"))
        XCTAssertTrue(
            controller.handle(
                .selectT9PinyinPath(T9PinyinPath(displayText: "ni", replacementRawInput: "ni"))
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

    func testHasSelectablePathsFalseWithoutValidComments() {
        let engine = FakeRimeEngine(
            dictionary: ["64": ["你", "密"]],
            comments: ["64": ["", "💯"]]
        )
        engine.appendDigitsToComposition = true
        let controller = makeController(engine: engine)
        controller.textClient = FakeTextInputClient()
        _ = controller.handle(.insertKey("6"))
        _ = controller.handle(.insertKey("4"))
        XCTAssertTrue(controller.state.t9PinyinPathState.compactPaths.isEmpty)
        XCTAssertFalse(controller.hasSelectableT9PinyinPaths())
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

    // MARK: - Helpers

    private func makeT9Engine() -> FakeRimeEngine {
        let engine = FakeRimeEngine(
            dictionary: [
                "6": ["吗", "你", "哦"],
                "64": ["你", "密"],
                "o": ["哦", "噢"],
                "ni": ["你", "呢"],
                "ni4": ["你"],
                "mi": ["密"],
            ],
            comments: [
                "6": ["m", "n", "o"],
                "64": ["ni", "mi"],
                "o": ["o", "o"],
                "ni": ["ni", "ne"],
                "ni4": ["ni"],
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
