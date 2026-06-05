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

    func testSelectingCachedLaterPageCandidateClearsEngineAndCompositionState() {
        prepareFixture()
        typeComposition()
        _ = engine.pageDown()

        _ = controller.handle(.insertCandidate("泥", kind: .candidate))

        XCTAssertEqual(input.text, "泥")
        XCTAssertNil(controller.state.lastRimeOutput)
        XCTAssertEqual(controller.state.currentComposition, "")
        XCTAssertEqual(engine.resetCount, 1)
    }

    private func typeComposition() {
        _ = controller.handle(.insertKey("n"))
        _ = controller.handle(.insertKey("i"))
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
        let candidates = page == 0 ? ["你", "呢"] : ["泥", "拟"]
        return RimeOutput(
            composition: RimeComposition(preeditText: composition, cursorPosition: composition.count),
            candidates: candidates.map { RimeCandidate(text: $0) },
            hasMorePages: page == 0,
            highlightedIndex: 0
        )
    }
}
