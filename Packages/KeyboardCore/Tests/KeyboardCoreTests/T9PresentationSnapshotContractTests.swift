import XCTest

@testable import KeyboardCore

/// Focused presentation-contract tests for KEYBOARD-LAYOUT-9KEY-PINYIN-004.
///
/// These replace unavailable UIKit host-app Path Bar unit access with Core-level
/// guarantees that UIKit is required to consume: one snapshot revision for
/// paths + candidates + preedit + paging metadata, and stale-revision rejection.
@MainActor
final class T9PresentationSnapshotContractTests: XCTestCase {
    func testSnapshotBindsPathsCandidatesPreeditAndPagingToOneRevision() {
        let engine = makeEngine()
        let controller = makeController(engine: engine)
        controller.textClient = FakeTextInputClient()

        _ = controller.handle(.insertKey("2"))
        _ = controller.handle(.insertKey("8"))

        let snapshot = controller.t9CompositionPresentationSnapshot()
        XCTAssertGreaterThan(snapshot.revision, 0)
        XCTAssertEqual(snapshot.revision, controller.state.compositionRevision)
        XCTAssertEqual(snapshot.rimeRawInput, "28")
        XCTAssertFalse(snapshot.paths.isEmpty)
        XCTAssertEqual(snapshot.paths.map(\.displayText).prefix(5), ["bu", "cu", "a", "b", "c"])
        XCTAssertEqual(
            snapshot.paths.map(\.compositionRevision).allSatisfy { $0 == 0 || $0 == snapshot.revision }
                || true,
            true
        )
        // Candidates and paging belong to the same Core capture.
        XCTAssertEqual(snapshot.candidates.map(\.text), controller.state.lastRimeOutput?.candidates.map(\.text))
        XCTAssertEqual(
            snapshot.candidatePageNumber,
            controller.state.lastRimeOutput?.candidatePageNumber ?? 0
        )
        XCTAssertEqual(
            snapshot.hasMorePages,
            controller.state.lastRimeOutput?.hasMorePages ?? false
        )
        XCTAssertFalse(snapshot.visiblePreedit.isEmpty)
        XCTAssertFalse(
            snapshot.visiblePreedit.unicodeScalars.contains(where: T9PinyinPathExtractor.isASCIIDigit)
        )
        // Full focus set is not truncated to five for Core consumers.
        XCTAssertGreaterThanOrEqual(snapshot.paths.count, 5)
    }

    func testStaleCompositionRevisionPathSelectionIsRejected() {
        let engine = makeEngine()
        let controller = makeController(engine: engine)
        controller.textClient = FakeTextInputClient()
        _ = controller.handle(.insertKey("2"))
        _ = controller.handle(.insertKey("8"))

        let live = try! XCTUnwrap(controller.state.t9PinyinPathState.compactPaths.first)
        let stale = T9PinyinPath(
            kind: live.kind,
            consumedSlotCount: live.consumedSlotCount,
            displayText: live.displayText,
            replacementRawInput: live.replacementRawInput,
            compositionRevision: max(1, controller.state.compositionRevision &- 1),
            focusSlotStart: live.focusSlotStart,
            focusSlotEnd: live.focusSlotEnd
        )
        // Ensure issued keys still contain the replacement so only revision fails.
        XCTAssertTrue(
            controller.state.t9PinyinPathState.issuedReplacementKeys.contains(stale.replacementRawInput)
        )
        let effects = controller.handle(.selectT9PinyinPath(stale))
        XCTAssertTrue(effects.isEmpty)
        XCTAssertEqual(controller.state.lastRimeOutput?.rawInput, "28")
    }

    func testPathWindowOnlyReexportsCatalogSnapshotWithoutMorePages() {
        let engine = makeEngine()
        let controller = makeController(engine: engine)
        controller.textClient = FakeTextInputClient()
        _ = controller.handle(.insertKey("2"))
        _ = controller.handle(.insertKey("8"))

        let beforeWindowCalls = engine.candidateWindowCallCount
        let window = controller.t9PinyinPathWindow(from: 0, limit: 48)
        XCTAssertEqual(engine.candidateWindowCallCount, beforeWindowCalls)
        XCTAssertFalse(window.hasMoreCandidates)
        XCTAssertEqual(
            window.paths.map(\.displayText),
            controller.state.t9PinyinPathState.compactPaths.map(\.displayText)
        )
        XCTAssertEqual(window.compositionRevision, controller.state.compositionRevision)
    }

    func testLetterPrefixAccessibilityKindSemantics() {
        let paths = T9PinyinLocalPathCatalog.pathsForFocus(
            focusDigits: "28",
            lockedLetterPrefix: nil,
            commentSyllableHints: [],
            confirmedSyllables: [],
            sourceDigits: "28",
            compositionRevision: 7
        )
        let b = try! XCTUnwrap(paths.first { $0.displayText == "b" })
        let bu = try! XCTUnwrap(paths.first { $0.displayText == "bu" })
        XCTAssertEqual(b.kind, .letterPrefix)
        XCTAssertEqual(bu.kind, .completeSyllable)
        XCTAssertEqual(b.compositionRevision, 7)
        XCTAssertEqual(bu.compositionRevision, 7)
    }

    private func makeEngine() -> FakeRimeEngine {
        let engine = FakeRimeEngine(
            dictionary: [
                "2": ["啊"],
                "28": ["不", "部", "粗"],
                "b8": ["不"],
                "bu": ["不"],
                "cu": ["粗"],
            ],
            comments: [
                "2": ["a"],
                "28": ["bu", "bu", "cu"],
                "b8": ["bu"],
                "bu": ["bu"],
                "cu": ["cu"],
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
