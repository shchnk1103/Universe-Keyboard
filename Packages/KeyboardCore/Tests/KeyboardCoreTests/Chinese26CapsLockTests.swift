import XCTest

@testable import KeyboardCore

/// ZH26-CAPSLOCK-FIX-001: 中文 26 键 Caps Lock 直出大写字母（方案 A）。
/// 覆盖 diag-zh26-capslock-r1.md 的 5 组用例。
@MainActor
final class Chinese26CapsLockTests: XCTestCase {

    let client = FakeTextInputClient()
    lazy var controller: KeyboardController = {
        let controller = KeyboardController()
        controller.textClient = client
        return controller
    }()

    override func setUp() {
        super.setUp()
        client.text = ""
    }

    // MARK: - 1. 键帽 payload：chinese26 尊重 shifted

    func testChinese26InputPayloadRespectsShifted() {
        let style = CharacterKeyStyle(defaults: nil)
        XCTAssertEqual(style.inputPayload("a", layout: .chinese26, shifted: true), "A")
        XCTAssertEqual(style.inputPayload("a", layout: .chinese26, shifted: false), "a")
        XCTAssertEqual(style.inputPayload("A", layout: .chinese26, shifted: false), "a")
        // T9 与英文 26 键行为不变
        XCTAssertEqual(style.inputPayload("a", layout: .chinese9, shifted: true), "a")
        XCTAssertEqual(style.inputPayload("a", layout: .english26, shifted: true), "A")
    }

    // MARK: - 2. 中文 Caps Lock 直出大写且不消费 capsLock

    func testChineseCapsLockBypassesRimeAndEmitsUppercase() {
        controller.state.inputMode = .chinese
        controller.state.currentPage = .letters
        controller.state.shiftState = .capsLock

        let effects = controller.handle(.insertKey("a"))

        XCTAssertEqual(client.text, "A")
        XCTAssertEqual(controller.state.currentComposition, "")
        XCTAssertEqual(controller.state.shiftState, .capsLock, "capsLock 不应被消费")
        XCTAssertFalse(effects.contains(.compositionChanged))
    }

    // MARK: - 3. composing 中先提交组词再直出大写

    func testChineseCapsLockDuringCompositionCommitsThenEmits() {
        controller.state.inputMode = .chinese
        controller.state.currentPage = .letters
        _ = controller.handle(.insertKey("n"))
        _ = controller.handle(.insertKey("i"))
        XCTAssertEqual(controller.state.currentComposition, "ni")
        controller.state.shiftState = .capsLock

        _ = controller.handle(.insertKey("a"))

        XCTAssertEqual(client.text, "niA", "先上屏已组词文本，再直出大写 A")
        XCTAssertEqual(controller.state.currentComposition, "")
        XCTAssertEqual(controller.state.shiftState, .capsLock, "capsLock 保持，可连续直出")
    }

    // MARK: - 4. singleUse 不回归：仍进 RIME 组词并消费

    func testSingleUseStillComposesAndIsConsumed() {
        // UI 层 singleUse 的 payload 已是大写（isShiftActive 含 singleUse），
        // 与既有 CompositionTests.testChineseModeShiftActiveEntersComposition 一致
        controller.state.inputMode = .chinese
        controller.state.currentPage = .letters
        controller.state.shiftState = .singleUse

        _ = controller.handle(.insertKey("N"))

        XCTAssertEqual(controller.state.currentComposition, "N")
        XCTAssertEqual(controller.state.shiftState, .off, "singleUse 应被消费")
    }

    // MARK: - 5. 英文 Caps Lock 不回归

    func testEnglishCapsLockStillEmitsUppercase() {
        // UI 层 english26 + capsLock 的 payload 已是大写（isShiftActive 含 capsLock）
        controller.state.inputMode = .english
        controller.state.shiftState = .capsLock

        _ = controller.handle(.insertKey("A"))

        XCTAssertEqual(client.text, "A")
        XCTAssertEqual(controller.state.shiftState, .capsLock)
    }
}
