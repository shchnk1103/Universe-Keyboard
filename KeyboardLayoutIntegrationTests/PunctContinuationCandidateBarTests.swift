import KeyboardCore
import UIKit
import XCTest

@testable import KeyboardCore

/// PB-013：标点回弹续接条目在候选栏的优先级与不混排语义。
/// CandidateBarDataSource 为 Keyboard app target 内部类型，仅在 app 侧可达。
nonisolated final class PunctContinuationCandidateBarTests: XCTestCase {
    @MainActor
    private func makeArmedController() -> KeyboardController {
        let controller = KeyboardController(
            continuationSuggestionProvider: BundledContinuationSuggestionProvider(entries: [
                ContinuationEntry(context: "吃了", suggestions: ["吗", "饭"])
            ])
        )
        controller.textClient = FakeTextInputClient()
        controller.state.continuation = ContinuationState(
            context: "吃了",
            suggestions: ["吗", "饭"]
        )
        // 模拟符号页 ！ 回弹后的武装结果。
        controller.state.punctuationContinuation = PunctuationContinuationState(
            trigger: "！",
            candidates: ["？", "！", "……", "——", "”", "）"]
        )
        return controller
    }

    @MainActor
    func testArmedContinuationShowsOnlyPunctuationItemsNotMixedWithSuggestions() {
        let controller = makeArmedController()

        let items = CandidateBarDataSource.candidateItems(from: controller)

        XCTAssertEqual(
            items.map(\.title),
            ["？", "！", "……", "——", "”", "）"]
        )
        XCTAssertTrue(items.allSatisfy { $0.kind == .continuationCandidate })
        // 不与普通联想混排。
        XCTAssertFalse(items.contains { $0.title == "吗" })
        XCTAssertFalse(items.contains { $0.title == "饭" })
    }

    @MainActor
    func testPendingPunctuationTakesPriorityOverArmedContinuation() {
        let controller = makeArmedController()
        controller.state.pendingPunctuation = PendingPunctuationState(
            text: "，",
            beforeCursor: "",
            lastSameKeyTap: Date(timeIntervalSince1970: 0),
            cycleArmed: false
        )

        let items = CandidateBarDataSource.candidateItems(from: controller)

        // 同帧冲突：pending 态优先、续接态静默（不互抢）。
        XCTAssertTrue(items.allSatisfy { $0.kind == .punctuationCandidate })
        XCTAssertFalse(items.contains { $0.title == "？" && $0.kind == .continuationCandidate })
    }

    @MainActor
    func testActiveCompositionHidesArmedContinuationItems() {
        let controller = makeArmedController()
        controller.state.currentComposition = "ni"

        let items = CandidateBarDataSource.candidateItems(from: controller)

        XCTAssertFalse(items.contains { $0.kind == .continuationCandidate && $0.title == "？" })
    }

    @MainActor
    func testDisarmedStateKeepsOrdinaryAssociationItems() {
        let controller = makeArmedController()
        controller.state.punctuationContinuation = nil

        let items = CandidateBarDataSource.candidateItems(from: controller)

        XCTAssertEqual(items.map(\.title), ["吗", "饭"])
    }
}
