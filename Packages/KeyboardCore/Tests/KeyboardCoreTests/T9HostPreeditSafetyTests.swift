import XCTest

@testable import KeyboardCore

@MainActor
final class T9HostPreeditSafetyTests: XCTestCase {
    func testCompositionProjectionRejectsEveryTransientInternalDigitWrite() {
        let client = FakeTextInputClient()
        let controller = KeyboardController()
        controller.textClient = client
        // Digit rejection is a nine-key T9 host boundary (26-key may show digits).
        controller.usesT9InputSemantics = true

        controller.updateInlinePreedit("qiu", source: .compositionProjection)
        controller.updateInlinePreedit("qiu5", source: .compositionProjection)
        controller.updateInlinePreedit("748 53", source: .compositionProjection)

        XCTAssertEqual(client.markedText, "qiu")
        XCTAssertEqual(client.markedTextHistory, ["qiu"])
        XCTAssertTrue(client.markedTextHistory.allSatisfy { !$0.contains(where: \.isNumber) })
    }

    func testConfirmedNumericCandidateAndExplicitNumberSuffixRemainVisible() {
        let client = FakeTextInputClient()
        let controller = KeyboardController()
        controller.textClient = client
        controller.state.partialCommit = PartialCommitState(
            confirmedText: "3D打印",
            remainingRawInput: "748",
            remainingPreeditText: "qiu",
            displayText: "3D打印qiu"
        )

        controller.updateInlinePreedit("3D打印qiu", source: .compositionProjection)
        controller.updateInlinePreedit("3D打印qiu123", source: .compositionProjection)
        controller.updateInlinePreedit("3D打印qiu123", source: .explicitNumberSuffix)

        XCTAssertEqual(client.markedTextHistory, ["3D打印qiu", "3D打印qiu123"])
        XCTAssertEqual(client.markedText, "3D打印qiu123")
    }

    func testRuntimeFailClosedReturnUsesLastSafeProjectionInsteadOfT9Raw() {
        let (controller, client, engine) = makeFailClosedRawController()

        _ = controller.handle(.insertReturn)

        XCTAssertEqual(client.text, "ni")
        XCTAssertFalse(client.text.contains("64"))
        XCTAssertFalse(engine.isComposing())
    }

    func testRuntimeFailClosedSymbolNeverCommitsCandidateLessT9Raw() {
        let (controller, client, _) = makeFailClosedRawController()
        controller.state.currentPage = .symbols

        _ = controller.handleSymbolPageTextInput("！")

        XCTAssertEqual(client.text, "ni！")
        XCTAssertFalse(client.text.contains("64"))
    }

    func testUnexpectedDigitBearingEngineCommitFailsClosed() {
        let client = FakeTextInputClient()
        let controller = KeyboardController()
        controller.textClient = client
        controller.usesT9InputSemantics = true
        controller.updateInlinePreedit("ni", source: .compositionProjection)
        controller.state.currentComposition = "64"
        controller.state.lastRimeOutput = RimeOutput(
            rawInput: "64",
            composition: RimeComposition(preeditText: "64", cursorPosition: 2),
            candidates: []
        )

        controller.applyRimeOutput(
            RimeOutput(
                composition: nil,
                candidates: [],
                committedText: "64"
            )
        )

        XCTAssertFalse(client.text.contains("64"))
        XCTAssertEqual(client.markedText, "")
        XCTAssertNil(controller.state.partialCommit)
    }

    func testDigitBearingCandidateCommitRemainsAllowed() {
        let client = FakeTextInputClient()
        let controller = KeyboardController()
        controller.textClient = client
        controller.updateInlinePreedit("san d da yin", source: .compositionProjection)
        controller.state.lastRimeOutput = RimeOutput(
            rawInput: "sanddayin",
            composition: RimeComposition(preeditText: "san d da yin", cursorPosition: 12),
            candidates: [RimeCandidate(text: "3D打印")]
        )

        controller.applyRimeOutput(
            RimeOutput(
                composition: nil,
                candidates: [],
                committedText: "3D打印"
            )
        )

        XCTAssertEqual(client.text, "3D打印")
        XCTAssertFalse(client.markedTextHistory.contains("sanddayin"))
    }

    private func makeFailClosedRawController()
        -> (KeyboardController, FakeTextInputClient, FakeRimeEngine)
    {
        let engine = FakeRimeEngine(dictionary: [:])
        engine.appendDigitsToComposition = true
        let output = engine.replaceInput("64")
        let client = FakeTextInputClient()
        let controller = KeyboardController()
        controller.textClient = client
        controller.rimeEngine = engine
        controller.usesT9InputSemantics = true
        controller.updateInlinePreedit("ni", source: .compositionProjection)
        controller.state.currentComposition = "64"
        controller.state.lastRimeOutput = output
        // Mirrors runtime recovery publishing a fail-closed 26-key selection
        // while the old T9 session raw is still present.
        controller.usesT9InputSemantics = false
        return (controller, client, engine)
    }
}
