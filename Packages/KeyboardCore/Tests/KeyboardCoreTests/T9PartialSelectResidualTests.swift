import XCTest

@testable import KeyboardCore

/// T9-PARTIAL-SELECT-FIX-001 red tests for the partial-select residual defect.
///
/// Diagnosis `diag-t9-partial-select-r1.md` (RC-1 / RC-2 / RC-3): after tapping
/// a candidate while librime retains the full pre-selection raw, Core must
/// peel the confirmed segment's slots from the raw, keep `remainingPreeditText`
/// free of the selected spelling, and never resurrect confirmed syllables as
/// selectable chips anchored before the confirmed slot count.
@MainActor
final class T9PartialSelectResidualTests: XCTestCase {
    /// Map a T9 digit run to a deterministic letter projection (one letter per
    /// key group) so fakes can model librime letter-tail preedit.
    private static func letterProjection(_ raw: String) -> String {
        let map: [Character: Character] = [
            "2": "a", "3": "d", "4": "g", "5": "j",
            "6": "m", "7": "p", "8": "t", "9": "w",
        ]
        return String(raw.map { map[$0] ?? $0 })
    }

    private func makeT9Controller(engine: FakeRimeEngine) -> (KeyboardController, FakeTextInputClient) {
        engine.appendDigitsToComposition = true
        engine.seedRuntimeSelection(
            RimeRuntimeSelection(
                baseSchemaID: "rime_ice",
                layoutStyle: .nineKey,
                t9ReadinessMatched: true
            )
        )
        let client = FakeTextInputClient()
        let controller = KeyboardController()
        controller.textClient = client
        controller.rimeEngine = engine
        controller.usesT9InputSemantics = true
        return (controller, client)
    }

    // MARK: - RC-2: retained full raw + letter-tail preedit

    /// librime keeps the full digit raw after 你 is selected while preedit
    /// becomes `你` + remaining letter tail. `remainingRawInput` must peel to
    /// the unresolved `426`, and the Path bar must rebuild from the peeled
    /// remainder — chips anchored at slot 0 of the retained raw resurrect the
    /// already-selected syllable.
    func testPartialSelectPeelsRetainedRawForLetterTailPreedit() throws {
        let engine = FakeRimeEngine(
            dictionary: [
                "64426": ["你好", "你"],
                "426": ["好", "号", "浩"],
            ],
            preeditFormatter: { Self.letterProjection($0) },
            selectedSegments: [
                "64426": [1: FakeRimeSelectedSegment(rawPrefix: "64", text: "你")]
            ],
            partialSelectionEmitsCommit: false
        )
        let (controller, client) = makeT9Controller(engine: engine)
        for digit in "64426" {
            _ = controller.handle(.insertKey(String(digit)))
        }

        _ = controller.handle(
            .insertCandidate(
                "你",
                kind: .candidate,
                selectionReference: CandidateSelectionReference(page: 0, indexOnPage: 1)
            )
        )

        let partial = try XCTUnwrap(controller.state.partialCommit)
        XCTAssertEqual(partial.confirmedText, "你")
        XCTAssertEqual(
            partial.remainingRawInput, "426",
            "RC-2: retained full raw must peel to the unresolved slots")
        let snapshot = controller.t9CompositionPresentationSnapshot()
        XCTAssertEqual(
            snapshot.sourceDigits, "426",
            "Path identity must rebuild from the peeled remainder")
        XCTAssertTrue(
            controller.state.t9PinyinPathState.compactPaths.allSatisfy { $0.consumedSlotCount <= 3 },
            "no chip may cover the confirmed slots (64 → ni)")
        XCTAssertFalse(
            client.markedText.unicodeScalars.contains(where: T9PinyinPathExtractor.isASCIIDigit),
            "host marked text must not leak raw digits")
    }

    /// Remaining-candidate comments may repeat the full-phrase spelling
    /// (`nihao`) even after 你 was selected. The visible remainder must start
    /// at the first unresolved syllable (`hao`) — marked text `你nihao` is the
    /// device-reported residual defect.
    func testPartialSelectDisplayDoesNotRepeatSelectedSpelling() throws {
        let engine = FakeRimeEngine(
            dictionary: [
                "64426": ["你好", "你"],
                "426": ["好", "号", "浩"],
            ],
            comments: [
                "64426": ["nihao", "ni"],
                "426": ["nihao", "nihao", "nihao"],
            ],
            preeditFormatter: { Self.letterProjection($0) },
            selectedSegments: [
                "64426": [1: FakeRimeSelectedSegment(rawPrefix: "64", text: "你")]
            ],
            partialSelectionEmitsCommit: false
        )
        let (controller, client) = makeT9Controller(engine: engine)
        for digit in "64426" {
            _ = controller.handle(.insertKey(String(digit)))
        }

        _ = controller.handle(
            .insertCandidate(
                "你",
                kind: .candidate,
                selectionReference: CandidateSelectionReference(page: 0, indexOnPage: 1)
            )
        )

        let partial = try XCTUnwrap(controller.state.partialCommit)
        XCTAssertEqual(partial.confirmedText, "你")
        // The visible remainder must start at the first unresolved syllable:
        // either the evidence comment projection with the confirmed spelling
        // stripped (`hao`), or a complete provisional Path for the remaining
        // slots (ADR 0023) — never a replay of the selected spelling `ni`.
        XCTAssertFalse(partial.remainingPreeditText.contains("ni"))
        XCTAssertFalse(
            partial.remainingPreeditText.unicodeScalars.contains(
                where: T9PinyinPathExtractor.isASCIIDigit))
        XCTAssertEqual(partial.displayText, "你" + partial.remainingPreeditText)
        XCTAssertEqual(client.markedText, partial.displayText)
        XCTAssertEqual(partial.remainingRawInput, "426")
    }

    // MARK: - RC-3: Path ledger vs full-phrase candidate

    /// Device morphology: user Path-selected `qing` over source `7464934`, then
    /// tapped 请 while librime shortened the raw to the equal unresolved tail
    /// `934`. The `count >= 2` gate (:171-174) rejects the single-syllable stack
    /// and `afterPartialCommit` fails closed on the equal tail — restore must
    /// still peel the one stack syllable through the relaxed ledger cursor.
    func testRestoreRelaxedGatePeelsSingleSyllableStackWithShortenedRaw() throws {
        let engine = FakeRimeEngine(dictionary: ["934": ["喂"]])
        engine.appendDigitsToComposition = true
        let (controller, _) = makeT9Controller(engine: engine)
        controller.state.lastRimeOutput = RimeOutput(
            rawInput: "934",
            composition: RimeComposition(preeditText: "wei", cursorPosition: 3)
        )
        let restored = controller.restoreSegmentedPathIdentityAfterNestedPartial(
            preservedSegmentSource: "7464934",
            preservedPathConfirmed: ["qing"],
            committedCandidate: "请"
        )
        XCTAssertTrue(
            restored,
            "relaxed gate must let the single-syllable ledger cursor peel")
        XCTAssertEqual(
            controller.state.t9PinyinPathState.segmentSourceDigits, "934",
            "cursor peel adopts the unresolved tail as the new source")
        XCTAssertEqual(
            controller.state.t9PinyinPathState.confirmedSegmentValues, [],
            "请 consumed the whole user stack; no confirmed syllables remain")
    }

    /// Device morphology B: user Path-selected `qing` + `wei` (the whole stack)
    /// and tapped the full-phrase candidate 请喂 while librime retained the
    /// unchanged pure-digit raw. Both identity paths nil out (cursor == source
    /// length; unchanged-raw fail-closed), so restore must fail-close rebuild
    /// from the preserved ledger instead of leaving the bar to a raw-only
    /// slot-0 rebuild that resurrects confirmed syllables as chips.
    func testRestoreFailClosedRebuildKeepsLedgerWhenFullStackConsumed() throws {
        let engine = FakeRimeEngine(dictionary: ["7464934": ["请喂"]])
        engine.appendDigitsToComposition = true
        let (controller, _) = makeT9Controller(engine: engine)
        controller.state.lastRimeOutput = RimeOutput(
            rawInput: "7464934",
            composition: RimeComposition(preeditText: "qingwei", cursorPosition: 7)
        )
        let restored = controller.restoreSegmentedPathIdentityAfterNestedPartial(
            preservedSegmentSource: "7464934",
            preservedPathConfirmed: ["qing", "wei"],
            committedCandidate: "请喂"
        )
        XCTAssertTrue(
            restored,
            "nil gates must fail-close rebuild from the preserved ledger")
        XCTAssertEqual(
            controller.state.t9PinyinPathState.segmentSourceDigits, "7464934",
            "ledger source survives the fail-closed rebuild")
        XCTAssertEqual(
            controller.state.t9PinyinPathState.confirmedSegmentValues, ["qing", "wei"],
            "preserved Path ledger stays confirmed; focus starts after it")
        let snapshot = controller.t9CompositionPresentationSnapshot()
        XCTAssertEqual(snapshot.focusSlotStart, 7)
    }
}
