import XCTest

@testable import KeyboardCore

final class T9PinyinCatalogTests: XCTestCase {
    func testCatalogMetadataMatchesGeneratedLunaPinyinBaseline() {
        XCTAssertEqual(T9PinyinSyllableCatalog.generatorVersion, "2")
        XCTAssertEqual(
            T9PinyinSyllableCatalog.sourceRelativePath,
            "Keyboard/Resources/luna_pinyin.dict.yaml"
        )
        XCTAssertEqual(T9PinyinSyllableCatalog.sourceVersion, "0.12.20120711")
        XCTAssertEqual(
            T9PinyinSyllableCatalog.sourceSHA256,
            "971baa1f38a42d3d82f858b5bbdcad6482371f8d93a2f5d5c4ab341046419e3b"
        )
        // 418 raw ASCII tokens minus filtered non-pinyin placeholders (`xx`).
        XCTAssertEqual(T9PinyinSyllableCatalog.syllableCount, 417)
        XCTAssertEqual(T9PinyinSyllableCatalog.syllables.count, 417)
        XCTAssertFalse(T9PinyinSyllableCatalog.syllables.contains("xx"))
        XCTAssertTrue(T9PinyinSyllableCatalog.completeSyllables(matchingDigits: "99").isEmpty)
        XCTAssertFalse(T9PinyinSyllableCatalog.sourceLicenseNote.isEmpty)
    }

    func testCatalogSignaturesForProductCriticalFoci() {
        XCTAssertEqual(
            T9PinyinSyllableCatalog.completeSyllables(matchingDigits: "28"),
            ["bu", "cu"]
        )
        XCTAssertEqual(
            T9PinyinSyllableCatalog.completeSyllables(matchingDigits: "94"),
            ["xi", "yi", "zi"]
        )
        XCTAssertEqual(
            T9PinyinSyllableCatalog.completeSyllables(matchingDigits: "2"),
            ["a"]
        )
        XCTAssertEqual(
            T9PinyinSyllableCatalog.completeSyllables(matchingDigits: "868"),
            ["tou"]
        )
    }

    func testFocus28PathsAreBuCuAAndLetterPrefixes() {
        let paths = T9PinyinLocalPathCatalog.pathsForFocus(
            focusDigits: "28",
            lockedLetterPrefix: nil,
            commentSyllableHints: [],
            confirmedSyllables: [],
            sourceDigits: "28",
            compositionRevision: 1
        )
        XCTAssertEqual(paths.map(\.displayText), ["bu", "cu", "a", "b", "c"])
        XCTAssertEqual(paths.map(\.kind), [
            .completeSyllable,
            .completeSyllable,
            .completeSyllable,
            .letterPrefix,
            .letterPrefix,
        ])
        XCTAssertEqual(paths.map(\.replacementRawInput), ["bu", "cu", "a8", "b8", "c8"])
    }

    func testFocus94KeepsXiYiZiEvenWithoutCommentHints() {
        let paths = T9PinyinLocalPathCatalog.pathsForFocus(
            focusDigits: "94",
            lockedLetterPrefix: nil,
            commentSyllableHints: ["yi"],
            confirmedSyllables: [],
            sourceDigits: "94",
            compositionRevision: 2
        )
        XCTAssertEqual(paths.prefix(3).map(\.displayText), ["yi", "xi", "zi"])
        XCTAssertTrue(paths.contains { $0.displayText == "xi" })
        XCTAssertTrue(paths.contains { $0.displayText == "zi" })
    }

    func testLockedPrefixBOn28NarrowsToBuAndB() {
        let paths = T9PinyinLocalPathCatalog.pathsForFocus(
            focusDigits: "28",
            lockedLetterPrefix: "b",
            commentSyllableHints: [],
            confirmedSyllables: [],
            sourceDigits: "28",
            compositionRevision: 3
        )
        XCTAssertEqual(paths.map(\.displayText), ["bu", "b"])
        XCTAssertEqual(paths.map(\.kind), [.completeSyllable, .letterPrefix])
        XCTAssertEqual(paths.map(\.replacementRawInput), ["bu", "b8"])
    }

    func testSingleDigitKeyGroupUsesCatalogSyllableKindsOnly() {
        let paths = T9PinyinLocalPathCatalog.pathsForFocus(
            focusDigits: "6",
            lockedLetterPrefix: nil,
            commentSyllableHints: [],
            confirmedSyllables: [],
            sourceDigits: "6",
            compositionRevision: 1
        )
        XCTAssertEqual(paths.map(\.displayText), ["m", "n", "o"])
        // PD option 1: only catalog-legal syllables are complete (here: o).
        XCTAssertEqual(paths.first { $0.displayText == "m" }?.kind, .letterPrefix)
        XCTAssertEqual(paths.first { $0.displayText == "n" }?.kind, .letterPrefix)
        XCTAssertEqual(paths.first { $0.displayText == "o" }?.kind, .completeSyllable)
    }

    func testMultiDigitLetterPrefixNeverLooksLikeCompleteSyllableForB() {
        let paths = T9PinyinLocalPathCatalog.pathsForFocus(
            focusDigits: "28",
            lockedLetterPrefix: nil,
            commentSyllableHints: [],
            confirmedSyllables: [],
            sourceDigits: "28",
            compositionRevision: 1
        )
        XCTAssertEqual(
            paths.first { $0.displayText == "b" }?.kind,
            .letterPrefix
        )
        XCTAssertEqual(
            paths.first { $0.displayText == "bu" }?.kind,
            .completeSyllable
        )
    }

    func testPathQueryDoesNotExceedSixDigitSignatures() {
        let long = "23456789"
        let paths = T9PinyinLocalPathCatalog.pathsForFocus(
            focusDigits: long,
            lockedLetterPrefix: nil,
            commentSyllableHints: [],
            confirmedSyllables: [],
            sourceDigits: long,
            compositionRevision: 1
        )
        XCTAssertFalse(paths.isEmpty)
        XCTAssertTrue(paths.allSatisfy { $0.consumedSlotCount <= 6 })
    }
}

@MainActor
final class T9PinyinCatalogControllerTests: XCTestCase {
    func testDigit28PublishesFullLocalCatalogWithoutExtraCandidateWindow() {
        let engine = makeCatalogT9Engine()
        let controller = makeCatalogController(engine: engine)
        controller.textClient = FakeTextInputClient()

        engine.resetCallCounts()
        _ = controller.handle(.insertKey("2"))
        _ = controller.handle(.insertKey("8"))

        let displays = controller.state.t9PinyinPathState.compactPaths.map(\.displayText)
        XCTAssertEqual(displays, ["bu", "cu", "a", "b", "c"])
        // Two digit keys → two processKey; Path logic must not open candidate windows.
        XCTAssertEqual(engine.processKeyCallCount, 2)
        XCTAssertEqual(engine.candidateWindowCallCount, 0)
        // Provisional complete path `bu` covers both slots.
        XCTAssertEqual(controller.state.insertedPreeditText, "bu")
        XCTAssertFalse(
            controller.state.insertedPreeditText.unicodeScalars.contains(
                where: T9PinyinPathExtractor.isASCIIDigit
            )
        )
    }

    func testPrefixBLocksWithoutAdvancingFocus() {
        let engine = makeCatalogT9Engine()
        let controller = makeCatalogController(engine: engine)
        let client = FakeTextInputClient()
        controller.textClient = client
        _ = controller.handle(.insertKey("2"))
        _ = controller.handle(.insertKey("8"))

        let pathState = controller.state.t9PinyinPathState
        guard let prefixB = pathState.compactPaths.first(where: {
            $0.displayText == "b" && $0.kind == .letterPrefix
        }) else {
            return XCTFail("missing letter prefix b")
        }

        engine.resetCallCounts()
        let effects = controller.handle(.selectT9PinyinPath(prefixB))
        XCTAssertTrue(effects.contains(.compositionChanged))
        XCTAssertEqual(controller.state.lastRimeOutput?.rawInput, "b8")
        XCTAssertEqual(controller.state.t9PinyinPathState.lockedLetterPrefix, "b")
        XCTAssertEqual(
            controller.state.t9PinyinPathState.confirmedSegmentValues,
            []
        )
        XCTAssertEqual(controller.state.t9PinyinPathState.focusedSegmentIndex, 0)
        XCTAssertEqual(
            controller.state.t9PinyinPathState.compactPaths.map(\.displayText),
            ["bu", "b"]
        )
        XCTAssertEqual(engine.replaceInputCallCount, 1)
        XCTAssertEqual(engine.candidateWindowCallCount, 0)
        XCTAssertFalse(client.markedTextHistory.contains { text in
            text.unicodeScalars.contains(where: T9PinyinPathExtractor.isASCIIDigit)
        })
    }

    func testUsesT9FalseDoesNotLoadCatalogPaths() {
        let engine = FakeRimeEngine()
        let controller = makeCatalogController(engine: engine)
        controller.usesT9InputSemantics = false
        controller.textClient = FakeTextInputClient()
        _ = controller.handle(.insertKey("n"))
        _ = controller.handle(.insertKey("i"))
        XCTAssertTrue(controller.state.t9PinyinPathState.compactPaths.isEmpty)
        XCTAssertNil(controller.state.t9PinyinPathState.segmentSourceDigits)
    }

    private func makeCatalogT9Engine() -> FakeRimeEngine {
        let engine = FakeRimeEngine(
            dictionary: [
                "2": ["啊", "不", "才"],
                "28": ["不", "部", "步", "粗"],
                "a": ["啊"],
                "a8": ["啊"],
                "b": ["不"],
                "b8": ["不", "部", "步"],
                "bu": ["不", "部", "步"],
                "c": ["才"],
                "c8": ["粗", "醋"],
                "cu": ["粗", "醋"],
                "6": ["吗", "你", "哦"],
                "m": ["吗"],
                "n": ["你"],
                "o": ["哦"],
            ],
            comments: [
                "2": ["a", "b", "c"],
                "28": ["bu", "bu", "bu", "cu"],
                "a8": ["a"],
                "b8": ["bu", "bu", "bu"],
                "bu": ["bu", "bu", "bu"],
                "c8": ["cu", "cu"],
                "cu": ["cu", "cu"],
                "6": ["o", "o", "o"],
                "m": ["ma"],
                "n": ["ni"],
                "o": ["o"],
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

    private func makeCatalogController(engine: FakeRimeEngine) -> KeyboardController {
        let controller = KeyboardController()
        controller.rimeEngine = engine
        controller.usesT9InputSemantics = true
        return controller
    }
}
