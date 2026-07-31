import XCTest
@testable import KeyboardCore

#if DEBUG
@MainActor
final class T9AutoAnchorRetryShadowAnalyzerTests: XCTestCase {
    func testObserverStartsOnlyAfterRejectedSourceLength() {
        let rejected = digits(for: "jintiandetianqihen")
        let sameLengthOutput = output(
            raw: rejected,
            comments: ["jin tian de tian qi hen"]
        )

        XCTAssertNil(
            T9AutoAnchorRetryShadowAnalyzer.analyze(
                rejectedAtSourceDigits: rejected,
                currentSourceDigits: rejected,
                output: sameLengthOutput
            )
        )
    }

    func testLaterEligibleSnapshotReportsProposalWithoutMutation() throws {
        let rejected = digits(for: "jintiandetianqihen")
        let later = digits(for: "jintiandetianqihenhao")
        let laterOutput = output(
            raw: later,
            comments: ["jin tian de tian qi hen hao"]
        )
        let controller = KeyboardController()
        controller.usesT9InputSemantics = true
        controller.isReversibleT9AutoAnchorEnabled = true
        controller.state.lastRimeOutput = laterOutput
        controller.state.t9ReversibleAutoAnchorState =
            T9ReversibleAutoAnchorState(
                phase: .rejected,
                sourceDigits: rejected
            )
        let stateBefore = controller.state

        let observation = try XCTUnwrap(
            controller.t9AutoAnchorRetryShadowObservation()
        )

        XCTAssertEqual(observation.status, .proposalReady)
        XCTAssertEqual(observation.sourceDigitCount, later.count)
        XCTAssertEqual(observation.rejectedAtSourceDigitCount, rejected.count)
        XCTAssertEqual(observation.candidateCount, 5)
        XCTAssertGreaterThanOrEqual(observation.anchoredSlotCount, 6)
        XCTAssertGreaterThanOrEqual(observation.unresolvedSlotCount, 4)
        XCTAssertEqual(controller.state, stateBefore)
    }

    func testLaterIneligibleSnapshotReportsCountsOnly() throws {
        let rejected = digits(for: "jintiandetianqihen")
        let later = rejected + "2"
        let observation = try XCTUnwrap(
            T9AutoAnchorRetryShadowAnalyzer.analyze(
                rejectedAtSourceDigits: rejected,
                currentSourceDigits: later,
                output: output(raw: later, comments: [""])
            )
        )

        XCTAssertEqual(observation.status, .notEligible)
        XCTAssertEqual(observation.sourceDigitCount, later.count)
        XCTAssertEqual(observation.rejectedAtSourceDigitCount, rejected.count)
        XCTAssertEqual(observation.anchoredSlotCount, 0)
        XCTAssertEqual(observation.unresolvedSlotCount, later.count)
    }

    func testControllerObserverRequiresRejectedPhaseAndPureLiveRaw() {
        let rejected = digits(for: "jintiandetianqihen")
        let later = digits(for: "jintiandetianqihenhao")
        let controller = KeyboardController()
        controller.usesT9InputSemantics = true
        controller.isReversibleT9AutoAnchorEnabled = true
        controller.state.lastRimeOutput = output(
            raw: "jin'tian'" + String(later.dropFirst(7)),
            comments: ["jin tian de tian qi hen hao"]
        )
        controller.state.t9ReversibleAutoAnchorState =
            T9ReversibleAutoAnchorState(
                phase: .rejected,
                sourceDigits: rejected
            )

        XCTAssertNil(controller.t9AutoAnchorRetryShadowObservation())

        controller.state.lastRimeOutput = output(
            raw: later,
            comments: ["jin tian de tian qi hen hao"]
        )
        controller.state.t9ReversibleAutoAnchorState =
            T9ReversibleAutoAnchorState(
                phase: .accepted,
                sourceDigits: rejected
            )
        XCTAssertNil(controller.t9AutoAnchorRetryShadowObservation())
    }

    private func output(raw: String, comments: [String]) -> RimeOutput {
        RimeOutput(
            rawInput: raw,
            composition: RimeComposition(
                preeditText: raw,
                cursorPosition: raw.count
            ),
            candidates: comments.enumerated().map { index, comment in
                RimeCandidate(
                    text: "候选\(index)",
                    comment: comment,
                    globalIndex: index
                )
            } + (comments.count..<5).map { index in
                RimeCandidate(
                    text: "候选\(index)",
                    comment: comments.first ?? "",
                    globalIndex: index
                )
            }
        )
    }

    private func digits(for pinyin: String) -> String {
        let mapping: [Character: Character] = [
            "a": "2", "b": "2", "c": "2",
            "d": "3", "e": "3", "f": "3",
            "g": "4", "h": "4", "i": "4",
            "j": "5", "k": "5", "l": "5",
            "m": "6", "n": "6", "o": "6",
            "p": "7", "q": "7", "r": "7", "s": "7",
            "t": "8", "u": "8", "v": "8",
            "w": "9", "x": "9", "y": "9", "z": "9",
        ]
        return String(pinyin.compactMap { mapping[$0] })
    }
}
#endif
