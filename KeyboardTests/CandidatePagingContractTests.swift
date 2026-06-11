import KeyboardCore
import XCTest

@MainActor
final class CandidatePagingContractTests: XCTestCase {
    private var controller: KeyboardController!
    private var input: FakeTextInputClient!
    private var engine: PagedRimeEngine!

    private func prepareFixture() {
        input = FakeTextInputClient()
        engine = PagedRimeEngine()
        controller = KeyboardController()
        controller.textClient = input
        controller.rimeEngine = engine
    }

    func testBrowsingLaterPageDoesNotReplaceFirstPageSelectionState() {
        prepareFixture()
        typeComposition()
        let firstPage = controller.state.lastRimeOutput

        _ = engine.pageDown()

        XCTAssertEqual(controller.state.lastRimeOutput, firstPage)
        XCTAssertEqual(controller.state.lastRimeOutput?.candidates.first?.text, "你")
    }

    func testSpaceAfterBrowsingLaterPageCommitsFirstPagePreferredCandidate() {
        prepareFixture()
        typeComposition()
        _ = engine.pageDown()

        _ = controller.handle(.insertSpace)

        XCTAssertEqual(input.text, "你")
        XCTAssertEqual(engine.resetCount, 1)
        XCTAssertEqual(controller.state.currentComposition, "")
    }

    func testSelectingCachedLaterPageCandidateWithGlobalIndexKeepsRemainingComposition() {
        prepareFixture()
        typeLongComposition()

        _ = controller.handle(
            .insertCandidate(
                "今",
                kind: .candidate,
                selectionReference: CandidateSelectionReference(page: 1, indexOnPage: 0, globalIndex: 2)
            )
        )

        XCTAssertEqual(input.text, "今tiantianqizhenhao")
        XCTAssertEqual(controller.state.currentComposition, "tiantianqizhenhao")
        XCTAssertEqual(controller.state.lastRimeOutput?.rawInput, "tiantianqizhenhao")
        XCTAssertEqual(engine.resetCount, 0)
        XCTAssertEqual(controller.state.partialCommit?.confirmedText, "今")
    }

    func testStaleLaterPageCandidateWithoutReferenceKeepsCurrentComposition() {
        prepareFixture()
        typeComposition()

        _ = controller.handle(.insertCandidate("泥", kind: .candidate))

        XCTAssertEqual(input.text, "ni")
        XCTAssertEqual(controller.state.currentComposition, "ni")
        XCTAssertEqual(engine.resetCount, 0)
    }

    private func typeComposition() {
        _ = controller.handle(.insertKey("n"))
        _ = controller.handle(.insertKey("i"))
    }

    private func typeLongComposition() {
        for character in "jintiantianqizhenhao" {
            _ = controller.handle(.insertKey(String(character)))
        }
    }
}

private final class PagedRimeEngine: RimeEngine {
    private var composition = ""
    private var page = 0
    private(set) var resetCount = 0

    func processKey(_ key: String) -> RimeOutput {
        composition += key
        page = 0
        return output()
    }

    func selectCandidate(at index: Int) -> RimeOutput {
        selectCandidate(globalIndex: page == 0 ? index : index + 2)
    }

    func selectCandidate(globalIndex index: Int) -> RimeOutput {
        if composition == "jintiantianqizhenhao", index == 2 {
            composition = "tiantianqizhenhao"
            let output = self.output()
            return RimeOutput(
                rawInput: output.rawInput,
                composition: output.composition,
                candidates: output.candidates,
                committedText: "今",
                hasMorePages: output.hasMorePages,
                highlightedIndex: output.highlightedIndex,
                candidatePageNumber: output.candidatePageNumber
            )
        }
        let allCandidates = allCandidatesForCurrentComposition()
        let committedText = allCandidates.indices.contains(index) ? allCandidates[index] : nil
        composition = ""
        return RimeOutput(committedText: committedText)
    }

    func candidateWindow(from globalIndex: Int, limit: Int) -> RimeCandidateWindow {
        let allCandidates = allCandidatesForCurrentComposition()
        let safeStart = max(0, globalIndex)
        let safeLimit = max(0, limit)
        guard safeStart < allCandidates.count, safeLimit > 0 else {
            return RimeCandidateWindow(
                candidates: [],
                startIndex: safeStart,
                nextIndex: safeStart,
                hasMoreCandidates: false
            )
        }
        let end = min(allCandidates.count, safeStart + safeLimit)
        return RimeCandidateWindow(
            candidates: allCandidates[safeStart..<end].map { RimeCandidate(text: $0) },
            startIndex: safeStart,
            nextIndex: end,
            hasMoreCandidates: end < allCandidates.count
        )
    }

    func legacySelectCandidate(at index: Int) -> RimeOutput {
        let candidates = page == 0 ? ["你", "呢"] : ["泥", "拟"]
        let committedText = candidates.indices.contains(index) ? candidates[index] : nil
        composition = ""
        return RimeOutput(committedText: committedText)
    }

    func deleteBackward() -> RimeOutput {
        if !composition.isEmpty {
            composition.removeLast()
        }
        return output()
    }

    func replaceInput(_ input: String) -> RimeOutput {
        composition = input
        page = 0
        return output()
    }

    func resetSession() {
        composition = ""
        page = 0
        resetCount += 1
    }

    func recoverSession() {}

    func isComposing() -> Bool {
        !composition.isEmpty
    }

    func pageUp() -> RimeOutput {
        page = 0
        return output()
    }

    func pageDown() -> RimeOutput {
        page = 1
        return output()
    }

    private func output() -> RimeOutput {
        guard !composition.isEmpty else { return RimeOutput() }
        let candidates: [String]
        if composition == "jintiantianqizhenhao" {
            candidates = page == 0 ? ["今天天气真好", "今天"] : ["今", "金"]
        } else {
            candidates = page == 0 ? ["你", "呢"] : ["泥", "拟"]
        }
        return RimeOutput(
            rawInput: composition,
            composition: RimeComposition(preeditText: composition, cursorPosition: composition.count),
            candidates: candidates.map { RimeCandidate(text: $0) },
            hasMorePages: page == 0,
            highlightedIndex: 0
        )
    }

    private func allCandidatesForCurrentComposition() -> [String] {
        if composition == "jintiantianqizhenhao" {
            return ["今天天气真好", "今天", "今", "金"]
        }
        return ["你", "呢", "泥", "拟"]
    }
}
