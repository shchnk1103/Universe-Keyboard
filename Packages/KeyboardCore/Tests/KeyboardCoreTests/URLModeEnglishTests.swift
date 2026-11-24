import XCTest

@testable import KeyboardCore

/// URL-MODE-ENGLISH-IMPL-001: `.URL`/`.webSearch`/`.emailAddress` 会话生命周期
/// （快照/恢复/手动优先/m1/m2 收口）与 `.` 后大小写联动。
@MainActor
final class URLModeEnglishTests: XCTestCase {

    let client = FakeTextInputClient()
    lazy var controller: KeyboardController = {
        let controller = KeyboardController()
        controller.textClient = client
        return controller
    }()

    // MARK: - 会话生命周期：进入快照

    func testEnteringURLFromChineseSnapshotsModeAndSwitchesToEnglish() {
        XCTAssertEqual(controller.state.inputMode, .chinese)
        let effects = controller.handle(.keyboardTypeChanged(.URL))
        XCTAssertEqual(controller.state.inputMode, .english)
        XCTAssertEqual(controller.state.addressLikeSession?.originalMode, .chinese)
        XCTAssertEqual(controller.state.addressLikeSession?.manualSelection, false)
        XCTAssertTrue(effects.contains(.inputModeChanged))
    }

    func testEnteringEmailAddressSnapshotsEnglishMode() {
        controller.state.inputMode = .english
        _ = controller.handle(.keyboardTypeChanged(.emailAddress))
        XCTAssertEqual(controller.state.inputMode, .english)
        XCTAssertEqual(controller.state.addressLikeSession?.originalMode, .english)
    }

    // MARK: - 会话生命周期：三类互切保留快照与手动选择

    func testSwitchingBetweenAddressLikeTypesKeepsSnapshot() {
        _ = controller.handle(.keyboardTypeChanged(.URL))
        _ = controller.handle(.keyboardTypeChanged(.webSearch))
        _ = controller.handle(.keyboardTypeChanged(.emailAddress))
        XCTAssertEqual(controller.state.addressLikeSession?.originalMode, .chinese)
        XCTAssertEqual(controller.state.inputMode, .english)
    }

    func testRepeatedSameTypeCallbackDoesNotResnapshotOrReset() {
        _ = controller.handle(.keyboardTypeChanged(.URL))
        _ = controller.handle(.toggleInputMode)
        XCTAssertEqual(controller.state.inputMode, .chinese)
        let effects = controller.handle(.keyboardTypeChanged(.URL))
        XCTAssertEqual(effects, [])
        XCTAssertEqual(controller.state.inputMode, .chinese)
        XCTAssertEqual(controller.state.addressLikeSession?.originalMode, .chinese)
    }

    // MARK: - 会话生命周期：手动选择优先（m2 侧 A）

    func testManualToggleInAddressLikePreventsAutoResetOnTypeSwitch() {
        _ = controller.handle(.keyboardTypeChanged(.URL))
        _ = controller.handle(.toggleInputMode)
        XCTAssertEqual(controller.state.inputMode, .chinese)
        _ = controller.handle(.keyboardTypeChanged(.emailAddress))
        XCTAssertEqual(controller.state.inputMode, .chinese)
        XCTAssertEqual(controller.state.addressLikeSession?.manualSelection, true)
    }

    // MARK: - 会话生命周期：离开恢复

    func testLeavingAddressLikeRestoresOriginalModeAndClearsSession() {
        _ = controller.handle(.keyboardTypeChanged(.URL))
        let effects = controller.handle(.keyboardTypeChanged(.default))
        XCTAssertEqual(controller.state.inputMode, .chinese)
        XCTAssertNil(controller.state.addressLikeSession)
        XCTAssertTrue(effects.contains(.inputModeChanged))
    }

    func testLeavingAddressLikeWithManualSelectionKeepsUserChoice() {
        controller.state.inputMode = .english
        _ = controller.handle(.keyboardTypeChanged(.URL))
        _ = controller.handle(.toggleInputMode)
        _ = controller.handle(.keyboardTypeChanged(.default))
        // m2：手动选择优先于快照恢复，离开时保留用户最后一次手动选择的模式。
        XCTAssertEqual(controller.state.inputMode, .chinese)
        XCTAssertNil(controller.state.addressLikeSession)
    }

    // MARK: - m2 收口：恢复写入不得被记为手动选择

    func testRestoreWriteIsNotRecordedAsManualSelection() {
        _ = controller.handle(.keyboardTypeChanged(.URL))
        // 离开时 Core 直接写入恢复模式（不经 toggleInputMode），不得置 manualSelection。
        _ = controller.handle(.keyboardTypeChanged(.default))
        XCTAssertEqual(controller.state.inputMode, .chinese)
        // 再次进入：快照重新建立且手动标记为 false，后续自动切英文仍然生效。
        _ = controller.handle(.keyboardTypeChanged(.URL))
        XCTAssertEqual(controller.state.inputMode, .english)
        XCTAssertEqual(controller.state.addressLikeSession?.originalMode, .chinese)
        XCTAssertEqual(controller.state.addressLikeSession?.manualSelection, false)
    }

    // MARK: - m1 收口：无法证明同一字段时清理临时快照

    func testClearAddressLikeSessionSnapshotDropsSessionWithoutTouchingMode() {
        _ = controller.handle(.keyboardTypeChanged(.URL))
        controller.clearAddressLikeSessionSnapshot()
        XCTAssertNil(controller.state.addressLikeSession)
        // 已生效的英文保持不变（fail-safe），但下次类型回调不再受会话保护。
        XCTAssertEqual(controller.state.inputMode, .english)
    }

    func testClearedSessionRestartsFreshSnapshotOnNextEntry() {
        _ = controller.handle(.keyboardTypeChanged(.URL))
        _ = controller.handle(.toggleInputMode)
        controller.clearAddressLikeSessionSnapshot()
        _ = controller.handle(.keyboardTypeChanged(.emailAddress))
        // 快照被清后重新进入：以当前模式为原模式建立新快照。
        XCTAssertEqual(controller.state.addressLikeSession?.originalMode, .chinese)
        XCTAssertEqual(controller.state.addressLikeSession?.manualSelection, false)
    }

    // MARK: - `.` 后大小写联动

    func testPeriodGluedToWordDoesNotCapitalize() {
        XCTAssertFalse(
            controller.shouldAutoCapitalize(contextBeforeInput: "google."))
    }

    func testPeriodFollowedBySpaceStillCapitalizes() {
        XCTAssertTrue(
            controller.shouldAutoCapitalize(contextBeforeInput: "Hello. "))
    }

    func testPeriodFollowedByNewlineStillCapitalizes() {
        XCTAssertTrue(
            controller.shouldAutoCapitalize(contextBeforeInput: "done.\n"))
    }

    func testURLWithDotComDoesNotCapitalize() {
        XCTAssertFalse(
            controller.shouldAutoCapitalize(contextBeforeInput: "google.com"))
    }

    func testOtherTerminatorsKeepOriginalSemantics() {
        XCTAssertTrue(controller.shouldAutoCapitalize(contextBeforeInput: "wow! "))
        XCTAssertTrue(controller.shouldAutoCapitalize(contextBeforeInput: "really?"))
        XCTAssertTrue(controller.shouldAutoCapitalize(contextBeforeInput: "你好。"))
    }

    // MARK: - addressLike 禁用自动大写

    func testAddressLikeDisablesAutoCapitalization() {
        controller.state.inputMode = .english
        controller.state.activeKeyboardType = .URL
        let effect = controller.applyAutoCapitalization(contextBeforeInput: nil)
        XCTAssertEqual(controller.state.shiftState, .off)
        XCTAssertEqual(effect, [])
        controller.state.activeKeyboardType = .emailAddress
        let emailEffect = controller.applyAutoCapitalization(
            contextBeforeInput: "Hello. ")
        XCTAssertEqual(controller.state.shiftState, .off)
        XCTAssertEqual(emailEffect, [])
        controller.state.activeKeyboardType = .webSearch
        let webEffect = controller.applyAutoCapitalization(contextBeforeInput: "")
        XCTAssertEqual(controller.state.shiftState, .off)
        XCTAssertEqual(webEffect, [])
    }

    func testExplicitShiftSurvivesInAddressLike() {
        controller.state.inputMode = .english
        controller.state.activeKeyboardType = .URL
        controller.state.shiftState = .capsLock
        _ = controller.applyAutoCapitalization(contextBeforeInput: "Hello. ")
        XCTAssertEqual(controller.state.shiftState, .capsLock)
        controller.state.shiftState = .singleUse
        _ = controller.applyAutoCapitalization(contextBeforeInput: nil)
        XCTAssertEqual(controller.state.shiftState, .singleUse)
    }

    func testNormalFieldStillAutoCapitalizes() {
        controller.state.inputMode = .english
        controller.state.activeKeyboardType = .default
        let effect = controller.applyAutoCapitalization(contextBeforeInput: "Hello. ")
        XCTAssertEqual(controller.state.shiftState, .singleUse)
        XCTAssertTrue(effect.contains(.shiftStateChanged))
    }

    // MARK: - addressLike 下句末符不触发自动大写（直接输入与符号页两条入口）

    func testTerminatorKeyInAddressLikeDoesNotArmSingleUse() {
        controller.state.inputMode = .english
        controller.state.activeKeyboardType = .URL
        let effects = controller.handle(.insertKey("."))
        XCTAssertEqual(client.text, ".")
        XCTAssertEqual(controller.state.shiftState, .off)
        XCTAssertFalse(effects.contains(.shiftStateChanged))
    }

    func testTerminatorKeyInNormalFieldArmsSingleUse() {
        controller.state.inputMode = .english
        controller.state.activeKeyboardType = .default
        _ = controller.handle(.insertKey("."))
        XCTAssertEqual(client.text, ".")
        XCTAssertEqual(controller.state.shiftState, .singleUse)
    }

    func testSymbolPageTerminatorInAddressLikeDoesNotArmSingleUse() {
        controller.state.inputMode = .english
        controller.state.activeKeyboardType = .emailAddress
        controller.state.currentPage = .symbols
        let effects = controller.handle(.insertDirectText("."))
        XCTAssertEqual(client.text, ".")
        XCTAssertEqual(controller.state.shiftState, .off)
        XCTAssertFalse(effects.contains(.shiftStateChanged))
    }
}
