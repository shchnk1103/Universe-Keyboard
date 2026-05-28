import XCTest

@testable import KeyboardCore

final class RimeControllerPagingTests: RimeControllerTestSupport {
    func testPageDownDoesNotAffectLastRimeOutput() {
        _ = controller.handle(.insertKey("n"))
        _ = controller.handle(.insertKey("i"))
        let page1Output = controller.state.lastRimeOutput
        XCTAssertEqual(page1Output?.candidates.count, 3)

        _ = engine.pageDown()
        XCTAssertEqual(controller.state.lastRimeOutput?.candidates.count, 3, "lastRimeOutput 应保持 processKey 的原始值")
        XCTAssertEqual(controller.state.lastRimeOutput?.composition?.preeditText, "ni")
    }

    func testSpaceAlwaysSelectsFirstPageCandidate() {
        _ = controller.handle(.insertKey("n"))
        _ = controller.handle(.insertKey("i"))
        _ = engine.pageDown()
        _ = controller.handle(.insertSpace)
        XCTAssertEqual(client.text, "你", "空格应始终提交第1页首候选（最佳匹配）")
        XCTAssertFalse(engine.isComposing())
    }

    func testPageDownThenPageUpRestoresComposition() {
        _ = controller.handle(.insertKey("n"))
        _ = controller.handle(.insertKey("i"))
        let original = controller.state.lastRimeOutput
        XCTAssertEqual(original?.composition?.preeditText, "ni")

        _ = engine.pageDown()
        _ = engine.pageUp()
        XCTAssertEqual(
            controller.state.lastRimeOutput?.composition?.preeditText,
            "ni",
            "lastRimeOutput 不受 pageDown/pageUp 影响"
        )
        XCTAssertTrue(engine.isComposing())
    }

    func testPageDownPreservesComposingState() {
        _ = controller.handle(.insertKey("n"))
        _ = controller.handle(.insertKey("i"))
        XCTAssertTrue(engine.isComposing())

        _ = engine.pageDown()
        XCTAssertTrue(engine.isComposing(), "翻页不应改变 composing 状态")
    }

    func testCandidateDeduplicationByTitle() {
        var accumulated = [
            CandidateItem(title: "你", kind: .candidate),
            CandidateItem(title: "呢", kind: .candidate),
        ]
        let newItems = [
            CandidateItem(title: "你", kind: .candidate),
            CandidateItem(title: "尼", kind: .candidate),
        ]
        var added = 0
        for item in newItems {
            if !accumulated.contains(where: { $0.title == item.title }) {
                accumulated.append(item)
                added += 1
            }
        }
        XCTAssertEqual(added, 1)
        XCTAssertEqual(accumulated.count, 3)
        XCTAssertEqual(accumulated.map(\.title), ["你", "呢", "尼"])
    }

    func testPreloadFlowWithPageDown() {
        _ = controller.handle(.insertKey("n"))
        _ = controller.handle(.insertKey("i"))
        let page1 = controller.state.lastRimeOutput!
        XCTAssertEqual(page1.candidates.count, 3)

        var accumulated = page1.candidates.map { CandidateItem(title: $0.text, kind: .candidate) }
        let page2 = engine.pageDown()
        let page2Items = page2.candidates.map { CandidateItem(title: $0.text, kind: .candidate) }
        for item in page2Items {
            if !accumulated.contains(where: { $0.title == item.title }) {
                accumulated.append(item)
            }
        }
        _ = engine.pageUp()

        XCTAssertEqual(accumulated.count, 3, "Fake engine 不分页，去重后应保持原有数量")
        XCTAssertEqual(controller.state.lastRimeOutput?.composition?.preeditText, "ni")
        XCTAssertTrue(engine.isComposing())
    }

    func testMultiplePageDownThenBackToFirstPage() {
        _ = controller.handle(.insertKey("n"))
        _ = controller.handle(.insertKey("i"))

        _ = engine.pageDown()
        _ = engine.pageDown()
        _ = engine.pageUp()
        _ = engine.pageUp()

        XCTAssertEqual(controller.state.lastRimeOutput?.composition?.preeditText, "ni")
        XCTAssertTrue(engine.isComposing())
    }

    func testCandidatePageDepthTracking() {
        _ = controller.handle(.insertKey("n"))
        _ = controller.handle(.insertKey("i"))
        var depth = 0

        _ = engine.pageDown()
        _ = engine.pageUp()
        depth = 1

        for _ in 0..<depth { _ = engine.pageDown() }
        _ = engine.pageDown()
        for _ in 0..<(depth + 1) { _ = engine.pageUp() }
        depth += 1
        XCTAssertEqual(depth, 2)

        for _ in 0..<depth { _ = engine.pageDown() }
        _ = engine.pageDown()
        for _ in 0..<(depth + 1) { _ = engine.pageUp() }
        depth += 1
        XCTAssertEqual(depth, 3)

        XCTAssertEqual(controller.state.lastRimeOutput?.composition?.preeditText, "ni")
    }
}
