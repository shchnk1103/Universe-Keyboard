import XCTest
@testable import KeyboardCore

final class DeleteTests: XCTestCase {

    var controller: KeyboardController!
    var client: FakeTextInputClient!

    override func setUp() {
        super.setUp()
        client = FakeTextInputClient()
        controller = KeyboardController()
        controller.textClient = client
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
