import XCTest

@testable import KeyboardCore

@MainActor
final class DeleteTests: XCTestCase {

    let client = FakeTextInputClient()
    lazy var controller: KeyboardController = {
        let controller = KeyboardController()
        controller.textClient = client
        return controller
    }()

    func testDropRemainingPreeditKeepsConfirmedPrefixAndCheckpoint() {
        controller.state.partialCommit = PartialCommitState(
            confirmedText: "你",
            remainingRawInput: "hao",
            remainingPreeditText: "hao",
            displayText: "你好",
            checkpoint: PartialCommitCheckpoint(
                previousRawInput: "nihao",
                previousPreeditText: "nihao",
                previousDisplayText: "nihao"
            )
        )
        controller.state.currentComposition = "hao"
        controller.state.continuation = ContinuationState(context: "前文", suggestions: ["啊"])
        client.setMarkedText("你好", selectedRange: 2..<2)

        _ = controller.dropRemainingPreeditKeepingConfirmedPrefix()

        XCTAssertEqual(controller.state.partialCommit?.confirmedText, "你")
        XCTAssertEqual(controller.state.partialCommit?.remainingRawInput, "")
        XCTAssertEqual(controller.state.partialCommit?.checkpoint?.previousRawInput, "nihao")
        XCTAssertEqual(controller.state.currentComposition, "")
        XCTAssertNil(controller.state.lastRimeOutput)
        XCTAssertEqual(controller.state.continuation.context, "前文")
        XCTAssertEqual(client.markedText, "你")
        XCTAssertFalse(client.text.contains("hao"))
    }

    func testDeleteOneGraphemeLeavesCloserAfterCursor() {
        client.text = "ab（）"
        client.adjustTextPosition(byCharacterOffset: -1)
        controller.state.pendingPunctuation = PendingPunctuationState(
            text: "（）",
            beforeCursor: "（",
            afterCursor: "）",
            ownsHostSpan: true,
            lastSameKeyTap: Date(),
            cycleArmed: false
        )

        _ = controller.deleteOneGraphemeBeforeCursor()

        XCTAssertNil(controller.state.pendingPunctuation)
        XCTAssertEqual(client.text, "ab）")
        XCTAssertEqual(client.cursorOffset, 2)
        XCTAssertEqual(client.deletedCount, 1)
    }

    func testDeleteOneGraphemeDoesNotSwallowWholeOwnedSpan() {
        client.text = "ab……"
        controller.state.pendingPunctuation = PendingPunctuationState(
            text: "……",
            beforeCursor: "……",
            afterCursor: "",
            ownsHostSpan: true,
            lastSameKeyTap: Date(),
            cycleArmed: false
        )

        _ = controller.deleteOneGraphemeBeforeCursor()

        XCTAssertNil(controller.state.pendingPunctuation)
        XCTAssertEqual(client.text, "ab…")
        XCTAssertEqual(client.deletedCount, 1)
    }

    func testOwnedPairDeleteStillRemovesBothSides() {
        client.text = "ab（）"
        client.adjustTextPosition(byCharacterOffset: -1)
        controller.state.pendingPunctuation = PendingPunctuationState(
            text: "（）",
            beforeCursor: "（",
            afterCursor: "）",
            ownsHostSpan: true,
            lastSameKeyTap: Date(),
            cycleArmed: false
        )

        _ = controller.handle(.deleteBackward)

        XCTAssertNil(controller.state.pendingPunctuation)
        XCTAssertEqual(client.text, "ab")
    }

    func testDeleteFromCompositionFirst() {
        controller.state.currentComposition = "nihao"
        _ = controller.handle(.deleteBackward)
        XCTAssertEqual(controller.state.currentComposition, "niha")
    }

    func testDeleteLastCharOfComposition() {
        controller.state.currentComposition = "n"
        _ = controller.handle(.deleteBackward)
        XCTAssertEqual(controller.state.currentComposition, "")
    }

    func testDeleteEmptyCompositionHitsProxy() {
        controller.state.currentComposition = ""
        client.text = "hello"
        _ = controller.handle(.deleteBackward)
        XCTAssertEqual(client.text, "hell")
    }

    func testDeleteWhenBothEmpty() {
        _ = controller.handle(.deleteBackward)
        XCTAssertEqual(controller.state.currentComposition, "")
        XCTAssertEqual(client.text, "")
    }

    func testCompositionDeleteSequence() {
        // Type "ni"
        controller.state.currentComposition = "ni"
        // Delete once → "n"
        _ = controller.handle(.deleteBackward)
        XCTAssertEqual(controller.state.currentComposition, "n")
        // Delete again → ""
        _ = controller.handle(.deleteBackward)
        XCTAssertEqual(controller.state.currentComposition, "")
        // Delete again → hits proxy
        client.text = "abc"
        _ = controller.handle(.deleteBackward)
        XCTAssertEqual(client.text, "ab")
    }

    // MARK: - Inline preedit delete tracking

    func testDeleteWithInlinePreeditDecrementsCount() {
        // 模拟 inline preedit 状态：插入了 5 个字符
        controller.state.insertedPreeditCount = 5
        controller.state.currentComposition = "nihao"
        _ = controller.handle(.deleteBackward)
        // controller 应该在删除前先清理 inline preedit
        // 验证 composition 减少
        XCTAssertEqual(controller.state.currentComposition, "niha")
    }

    func testDeleteWithEmptyCompositionHitsProxyDecrementsDeleteCount() {
        client.text = "hello"
        _ = controller.handle(.deleteBackward)
        XCTAssertEqual(client.deletedCount, 1)
        XCTAssertEqual(client.text, "hell")
    }

    // MARK: - Rapid delete sequence

    func testRapidDeleteClearsEntireComposition() {
        controller.state.currentComposition = "nihao"
        for _ in 0..<5 {
            _ = controller.handle(.deleteBackward)
        }
        XCTAssertEqual(controller.state.currentComposition, "")
    }

    func testRapidDeleteBeyondCompositionHitsProxyRepeatedly() {
        controller.state.currentComposition = "n"
        client.text = "hello"
        // Delete 3 times: 1 clears "n", 2 more hit proxy
        for _ in 0..<3 {
            _ = controller.handle(.deleteBackward)
        }
        XCTAssertEqual(controller.state.currentComposition, "")
        // "hello" → "hel" (2 proxy deletions after composition cleared)
        XCTAssertEqual(client.text, "hel")
    }

    // MARK: - Delete with mode context

    func testDeleteInEnglishModeGoesDirectlyToProxy() {
        controller.state.inputMode = .english
        client.text = "hello"
        _ = controller.handle(.deleteBackward)
        XCTAssertEqual(client.deletedCount, 1)
        XCTAssertEqual(client.text, "hell")
        // 英文模式无 composition，删除直接命中 proxy
    }

    func testDeleteInChineseModeWithCompositionPrioritizesComposition() {
        controller.state.inputMode = .chinese
        controller.state.currentComposition = "ni"
        // 注意：中文模式下删除会从 composition 移除字符，
        // 然后 inline preedit 机制会插入缩短后的拼音到 proxy。
        // 所以 proxy.text 会包含更新后的 preedit，而非保持不变。
        _ = controller.handle(.deleteBackward)
        // composition 从 "ni" → "n"
        XCTAssertEqual(controller.state.currentComposition, "n")
        // proxy 的 deleteBackward 未被调用（composition 优先）
        XCTAssertEqual(client.deletedCount, 0)
    }
}
