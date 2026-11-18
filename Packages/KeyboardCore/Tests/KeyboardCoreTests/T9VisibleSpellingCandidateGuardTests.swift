import XCTest

@testable import KeyboardCore

@MainActor
final class T9VisibleSpellingCandidateGuardTests: XCTestCase {
    /// Branch-level counterexample: seed letter preedit `ni` over digit raw `64`
    /// with no Core digit ledger, so Delete takes the visible-spelling peel path.
    /// Dictionary has `64`/`6` candidates but not `n`. Without the candidate-nonempty
    /// guard, replaceInput("n") is accepted with empty candidates; with the guard,
    /// restore `64` then engine Delete yields raw `6` with candidates.
    func testVisibleSpellingBackspaceRejectsEmptyCandidatesLunaNineKey() {
        runVisibleSpellingEmptyCandidateCounterexample(
            schemaID: "luna_pinyin",
            label: "luna"
        )
    }

    func testVisibleSpellingBackspaceRejectsEmptyCandidatesIceNineKey() {
        runVisibleSpellingEmptyCandidateCounterexample(
            schemaID: "rime_ice",
            label: "ice"
        )
    }

    private func runVisibleSpellingEmptyCandidateCounterexample(
        schemaID: String,
        label: String
    ) {
        let engine = FakeRimeEngine(
            dictionary: [
                "64": ["你", "密"],
                "6": ["吗", "你", "哦"],
            ],
            comments: [
                "64": ["ni", "mi"],
                "6": ["ma", "ni", "o"],
            ]
        )
        engine.seedRuntimeSelection(
            RimeRuntimeSelection(
                baseSchemaID: schemaID,
                layoutStyle: .nineKey,
                t9ReadinessMatched: true
            )
        )
        let controller = makeController(engine: engine)
        let client = FakeTextInputClient()
        controller.textClient = client

        let seeded = engine.replaceInput("64")
        XCTAssertFalse(
            seeded.candidates.isEmpty,
            "\(label) seed 64 must have candidates"
        )
        engine.seedSessionComposition("64")
        controller.state.lastRimeOutput = seeded
        controller.state.currentComposition = "64"
        controller.state.insertedPreeditText = "ni"
        controller.state.t9PinyinPathState = T9PinyinPathState(
            compactPaths: [
                T9PinyinPath(displayText: "ni", replacementRawInput: "ni")
            ],
            compositionRevision: 1,
            segmentSourceDigits: nil,
            focusedSegmentIndex: nil,
            confirmedSegmentValues: []
        )
        client.setMarkedText("ni", selectedRange: 0..<2)

        _ = controller.handle(.deleteBackward)

        let raw = controller.state.lastRimeOutput?.rawInput ?? ""
        let candCount = controller.state.lastRimeOutput?.candidates.count ?? 0
        let committed = hostCommitted(client)
        print(
            "S2B_GUARD_CORE label=\(label) raw=\(raw) cands=\(candCount) marked=\(client.markedText) committed=\(committed) session=\(engine.sessionComposition) replaceArgs=\(engine.replaceInputArguments)"
        )

        XCTAssertEqual(committed, "", "\(label) host committed must stay empty")
        XCTAssertFalse(
            raw.unicodeScalars.allSatisfy(T9PinyinPathExtractor.isASCIILetter)
                && candCount == 0,
            "\(label) must not end as letter raw with empty candidates; raw=\(raw) cands=\(candCount)"
        )
        XCTAssertEqual(raw, "6", "\(label) expected engine Delete after restore → raw 6; got \(raw)")
        XCTAssertGreaterThan(candCount, 0, "\(label) raw 6 must have candidates")
        XCTAssertEqual(engine.sessionComposition, "6")
    }

    private func makeController(engine: FakeRimeEngine) -> KeyboardController {
        let controller = KeyboardController()
        controller.rimeEngine = engine
        controller.usesT9InputSemantics = true
        return controller
    }

    private func hostCommitted(_ client: FakeTextInputClient) -> String {
        let mark = client.markedText.count
        if mark == 0 { return client.text }
        if mark >= client.text.count { return "" }
        return String(client.text.dropLast(mark))
    }
}
