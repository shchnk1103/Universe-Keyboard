import XCTest

@testable import KeyboardCore

/// EN-AUTOSPACE-IMMEDIATE-001 (r3 §2)：英文点选候选立即尾随空格、回声归属、
/// 智能回删与防双空格的契约测试（红测先行）。
///
/// 断言全部基于宿主可观察行为（写入事务、宿主文本、回删调用次数），不依赖
/// 内部状态表示：
/// - 回删资格武装 ⇔ 附着标点键按下时宿主 `deleteBackward` 恰好被调用一次
///   （"Word " + "." → "Word."）；
/// - 回删资格撤销 ⇔ 附着标点键按下时不发生宿主回删（"Word " + "." → "Word ."）。
@MainActor
final class EnglishAutospaceImmediateTests: XCTestCase {
    private final class TrackingClient: TextInputClient {
        let inner = FakeTextInputClient()
        private(set) var insertCalls: [String] = []
        /// 宿主 deleteBackward 调用尝试次数（与是否实际删除无关）。
        private(set) var deleteAttempts = 0
        /// 宿主差异模拟：false 时 deleteBackward 是 no-op（Void API 无法确认
        /// 成功的现实限制）。
        var deletesTakeEffect = true

        var text: String { inner.text }

        var hasTextBeforeInput: Bool {
            inner.hasTextBeforeInput
        }

        func seed(_ text: String) {
            inner.text = text
        }

        func moveCursor(to offset: Int) {
            inner.cursorOffset = offset
        }

        /// 模拟真实外部编辑：不经控制器直接写宿主（光标随之前移）。
        func externalAppend(_ appended: String) {
            inner.insertText(appended)
        }

        func insertText(_ text: String) {
            insertCalls.append(text)
            inner.insertText(text)
        }

        func deleteBackward() {
            deleteAttempts += 1
            if deletesTakeEffect {
                inner.deleteBackward()
            }
        }

        func adjustTextPosition(byCharacterOffset offset: Int) {
            inner.adjustTextPosition(byCharacterOffset: offset)
        }

        func setMarkedText(_ text: String, selectedRange: Range<Int>) {
            inner.setMarkedText(text, selectedRange: selectedRange)
        }

        func unmarkText() {
            inner.unmarkText()
        }
    }

    private var now = Date(timeIntervalSince1970: 1_000)

    private func makeController(
        provider: (any EnglishCandidateProviding)? = BundledEnglishCandidateProvider(
            words: ["word", "hello", "world"],
            sourceVersion: "test-immediate"
        ),
        before: String = "",
        after: String? = ""
    ) -> (KeyboardController, TrackingClient) {
        let client = TrackingClient()
        client.seed(before)
        let controller = KeyboardController(
            state: KeyboardState(inputMode: .english),
            englishCandidateProvider: provider
        )
        controller.textClient = client
        controller.documentContextBeforeInput = { [client] in
            String(client.inner.text.prefix(client.inner.cursorOffset))
        }
        controller.documentContextAfterInput = { after }
        controller.currentDate = { [weak self] in self?.now ?? Date() }
        return (controller, client)
    }

    private func type(_ controller: KeyboardController, _ keys: String) {
        for key in keys.map(String.init) {
            _ = controller.handle(.insertKey(key))
        }
    }

    /// 提交候选 `Word` 并断言事务内已写出尾随空格。
    private func commitWord(_ controller: KeyboardController, _ client: TrackingClient) {
        type(controller, "Wor")
        _ = controller.handle(.insertCandidate("Word", kind: .englishCandidate))
    }

    /// 提交自身的前缀替换会产生 3 次宿主回删（"Wor" 逐字删除）；智能回删
    /// 断言一律使用按键增量（delta），不计入提交事务自身的回删。
    private func pressKeyDeltaDelete(
        _ controller: KeyboardController,
        _ client: TrackingClient,
        _ key: String
    ) -> Int {
        let attemptsBefore = client.deleteAttempts
        _ = controller.handle(.insertKey(key))
        return client.deleteAttempts - attemptsBefore
    }

    // MARK: - 立即尾随空格（r3 §2.1）

    func testImmediateTrailingSpaceWhenRightNeighborUnknown() {
        let (controller, client) = makeController(after: nil)
        commitWord(controller, client)

        XCTAssertEqual(client.insertCalls.last, "Word ")
        XCTAssertEqual(client.text, "Word ")
    }

    func testImmediateTrailingSpaceAtDocumentEnd() {
        let (controller, client) = makeController(after: "")
        commitWord(controller, client)

        XCTAssertEqual(client.insertCalls.last, "Word ")
        XCTAssertEqual(client.text, "Word ")
    }

    func testImmediateTrailingSpaceBeforeWordLikeNeighbor() {
        let (controller, client) = makeController(after: "here")
        commitWord(controller, client)

        XCTAssertEqual(client.insertCalls.last, "Word ")
        XCTAssertEqual(client.text, "Word ")
    }

    func testNoTrailingSpaceBeforeWhitespaceRightNeighbor() {
        let (controller, client) = makeController(after: " here")
        commitWord(controller, client)

        XCTAssertEqual(client.insertCalls.last, "Word")
        XCTAssertEqual(client.text, "Word")
    }

    /// 冻结附着标点集合：右邻命中时不补空格。
    func testNoTrailingSpaceBeforeAttachedPunctuation() {
        for after in [".", ",", "?", "!", ";", ":", ")", "]", "}"] {
            let (controller, client) = makeController(after: after)
            commitWord(controller, client)

            XCTAssertEqual(client.insertCalls.last, "Word", "right neighbor \(after)")
            XCTAssertEqual(client.text, "Word", "right neighbor \(after)")
        }
    }

    /// 非附着符号（`/`、`@`、`#`、中文轮换标点、连字符等）按普通字符补空格
    /// （取代旧版排除 connector 的右侧规则）。
    func testTrailingSpaceBeforeNonAttachedSymbols() {
        for after in ["/", "@", "#", "。", "-", "\""] {
            let (controller, client) = makeController(after: after)
            commitWord(controller, client)

            XCTAssertEqual(client.insertCalls.last, "Word ", "right neighbor \(after)")
            XCTAssertEqual(client.text, "Word ", "right neighbor \(after)")
        }
    }

    /// 前导/尾随两侧决策独立，一次 insertText 拼接 leading + candidate + trailing。
    func testLeadingAndTrailingDecisionsIndependentInSingleTransaction() {
        let (controller, client) = makeController(
            provider: BundledEnglishCandidateProvider(words: ["hello"], sourceVersion: "t"),
            before: "Word.",
            after: ""
        )
        type(controller, "hel")
        _ = controller.handle(.insertCandidate("hello", kind: .englishCandidate))

        XCTAssertEqual(client.insertCalls.last, " hello ")
        XCTAssertEqual(client.text, "Word. hello ")
    }

    func testDisabledHostTypesNeverAddTrailingSpace() {
        for hostType in [KeyboardType.URL, .emailAddress, .webSearch] {
            let (controller, client) = makeController(after: "")
            controller.state.activeKeyboardType = hostType
            commitWord(controller, client)

            XCTAssertEqual(client.insertCalls.last, "Word", "\(hostType)")
            XCTAssertEqual(client.text, "Word", "\(hostType)")
        }
    }

    func testAutospaceSettingOffNeverAddsTrailingSpace() {
        let (controller, client) = makeController(after: "")
        controller.englishCandidateAutospaceEnabled = false
        commitWord(controller, client)

        XCTAssertEqual(client.insertCalls.last, "Word")
        XCTAssertEqual(client.text, "Word")
    }

    // MARK: - 回声归属与失效（r3 §2.2）

    func testNoEchoStillEligibleForSmartDelete() {
        let (controller, client) = makeController(after: "")
        commitWord(controller, client)

        let delta = pressKeyDeltaDelete(controller, client, ".")

        XCTAssertEqual(client.text, "Word.")
        XCTAssertEqual(delta, 1)
    }

    func testOwnCommitEchoKeepsDeleteEligibility() {
        let (controller, client) = makeController(after: "")
        commitWord(controller, client)

        // 宿主对本事务的一次 textDidChange 回声（光标未动、同一文档）。
        _ = controller.noteExternalDocumentChange()

        let delta = pressKeyDeltaDelete(controller, client, ".")

        XCTAssertEqual(client.text, "Word.")
        XCTAssertEqual(delta, 1)
    }

    /// 回声抑制一次性：第二个通知无法归属（本事务至多一个回声）→
    /// 撤销回删资格，不得删宿主字符。
    func testSecondEchoRevokesDeleteEligibility() {
        let (controller, client) = makeController(after: "")
        commitWord(controller, client)

        _ = controller.noteExternalDocumentChange()  // 自身回声
        _ = controller.noteExternalDocumentChange()  // 无法归属的第二个通知

        let delta = pressKeyDeltaDelete(controller, client, ".")

        XCTAssertEqual(client.text, "Word .")
        XCTAssertEqual(delta, 0)
    }

    /// 真实外部编辑先于回声到达：宿主内容已变化 → 通知无法归属 →
    /// 撤销回删资格；后续标点直插，不删宿主字符。
    func testRealExternalEditBeforeEchoRevokesEligibilityWithoutHostDelete() {
        let (controller, client) = makeController(after: "")
        commitWord(controller, client)
        client.externalAppend("x")

        _ = controller.noteExternalDocumentChange()  // 外改先到（回声未到）

        let delta = pressKeyDeltaDelete(controller, client, ".")

        XCTAssertEqual(client.text, "Word x.")
        XCTAssertEqual(delta, 0)
    }

    /// 用户下一动作（字母 h）先于回声：h 直插不带延后空格（旧「待补空格」
    /// 语义废除），回声到达时资格已被清掉，不得复活。
    func testUserNextActionBeforeEchoClearsEligibility() {
        let (controller, client) = makeController(after: "")
        commitWord(controller, client)

        type(controller, "h")
        XCTAssertEqual(client.insertCalls.last, "h")
        XCTAssertEqual(client.text, "Word h")

        _ = controller.noteExternalDocumentChange()  // 迟到的回声

        let delta = pressKeyDeltaDelete(controller, client, ".")

        XCTAssertEqual(client.text, "Word h.")
        XCTAssertEqual(delta, 0)
    }

    /// 光标切换先于回声：归属核验失败 → 撤销资格。
    func testCursorMovedBeforeEchoRevokesEligibility() {
        let (controller, client) = makeController(after: "")
        commitWord(controller, client)
        client.moveCursor(to: 0)

        _ = controller.noteExternalDocumentChange()

        client.moveCursor(to: client.text.count)
        let delta = pressKeyDeltaDelete(controller, client, ".")

        XCTAssertEqual(client.text, "Word .")
        XCTAssertEqual(delta, 0)
    }

    // MARK: - 智能回删（r3 §2.2 / §2.3）

    /// 冻结附着标点集合内的键：回删归属成立时 deleteBackward() 后插标点
    /// （"Word " + "." → "Word."）。
    func testAttachedPunctuationKeysReplaceOwnedTrailingSpace() {
        for key in [".", ",", "?", "!", ";", ":", ")", "]", "}"] {
            let (controller, client) = makeController(after: "")
            commitWord(controller, client)
            _ = controller.noteExternalDocumentChange()  // 自身回声

            let delta = pressKeyDeltaDelete(controller, client, key)

            XCTAssertEqual(client.text, "Word\(key)", "key \(key)")
            XCTAssertEqual(delta, 1, "key \(key)")
            XCTAssertEqual(client.insertCalls.last, key, "key \(key)")
        }
    }

    /// 非附着键不触发回删：先清态再按普通写入处理。
    func testNonAttachedKeyDoesNotDeleteOwnedSpace() {
        let (controller, client) = makeController(after: "")
        commitWord(controller, client)
        _ = controller.noteExternalDocumentChange()

        let delta = pressKeyDeltaDelete(controller, client, "/")

        XCTAssertEqual(client.text, "Word /")
        XCTAssertEqual(delta, 0)
    }

    /// 上下文未知（读取 nil）：清态直接插标点（"Word ." 退化可接受），
    /// 严禁盲目删除。
    func testSmartDeleteDegradesToDirectInsertWhenContextUnreadable() {
        let (controller, client) = makeController(after: "")
        commitWord(controller, client)
        controller.documentContextBeforeInput = { nil }

        let delta = pressKeyDeltaDelete(controller, client, ".")

        XCTAssertEqual(client.text, "Word .")
        XCTAssertEqual(delta, 0)
    }

    /// 所有者核验在回删时刻执行：外改未被通知（「下一次通知」不可依赖）也
    /// 不得删除非本状态机写入的宿主字符。
    func testSmartDeleteNeverDeletesWhenOwnershipLostWithoutNotification() {
        let (controller, client) = makeController(after: "")
        commitWord(controller, client)
        client.externalAppend("x")  // 外改未送达通知

        let delta = pressKeyDeltaDelete(controller, client, ".")

        XCTAssertEqual(client.text, "Word x.")
        XCTAssertEqual(delta, 0)
    }

    /// deleteBackward() Void 限制的宿主差异红测：忽略回删的宿主上仍按序
    /// 发出一次回删尝试并插入标点；空格未被删掉，标点落在空格之后
    /// （"Word ."，与降级直插结果一致——该限制由回删尝试次数区分）。
    func testDeleteBackwardHostDifferenceWhenDeleteIsNoOp() {
        let (controller, client) = makeController(after: "")
        commitWord(controller, client)
        _ = controller.noteExternalDocumentChange()
        client.deletesTakeEffect = false

        let delta = pressKeyDeltaDelete(controller, client, ".")

        XCTAssertEqual(delta, 1)
        XCTAssertEqual(client.insertCalls.last, ".")
        XCTAssertEqual(client.text, "Word .")
    }

    /// Shift 不清态：武装资格在 Shift 后仍可用于智能回删。
    func testShiftDoesNotRevokeEligibility() {
        let (controller, client) = makeController(after: "")
        commitWord(controller, client)
        _ = controller.noteExternalDocumentChange()

        _ = controller.handle(.toggleShift)
        let delta = pressKeyDeltaDelete(controller, client, ".")

        XCTAssertEqual(client.text, "Word.")
        XCTAssertEqual(delta, 1)
    }

    // MARK: - 入口清态矩阵（r3 §2.3）

    func testLanguageSwitchRoundTripClearsEligibility() {
        let (controller, client) = makeController(after: "")
        commitWord(controller, client)
        _ = controller.noteExternalDocumentChange()

        _ = controller.handle(.toggleInputMode)
        _ = controller.handle(.toggleInputMode)
        let delta = pressKeyDeltaDelete(controller, client, ".")

        XCTAssertEqual(client.text, "Word .")
        XCTAssertEqual(delta, 0)
    }

    func testKeyboardTypeChangeRoundTripClearsEligibility() {
        let (controller, client) = makeController(after: "")
        commitWord(controller, client)
        _ = controller.noteExternalDocumentChange()

        _ = controller.handle(.keyboardTypeChanged(.other))
        _ = controller.handle(.keyboardTypeChanged(.default))
        let delta = pressKeyDeltaDelete(controller, client, ".")

        XCTAssertEqual(client.text, "Word .")
        XCTAssertEqual(delta, 0)
    }

    func testSymbolAndNumberPageSwitchClearsEligibility() {
        let (controller, client) = makeController(after: "")
        commitWord(controller, client)
        _ = controller.noteExternalDocumentChange()

        for _ in 0..<4 { _ = controller.handle(.togglePage) }  // letters→…→letters
        let delta = pressKeyDeltaDelete(controller, client, ".")

        XCTAssertEqual(client.text, "Word .")
        XCTAssertEqual(delta, 0)
    }

    func testTypingLetterAfterCommitRevokesEligibility() {
        let (controller, client) = makeController(after: "")
        commitWord(controller, client)
        _ = controller.noteExternalDocumentChange()

        type(controller, "h")
        let delta = pressKeyDeltaDelete(controller, client, ".")

        XCTAssertEqual(client.text, "Word h.")
        XCTAssertEqual(delta, 0)
    }

    func testBackspaceClearsEligibilityAndDeletesTheSpace() {
        let (controller, client) = makeController(after: "")
        commitWord(controller, client)
        _ = controller.noteExternalDocumentChange()

        let attemptsBefore = client.deleteAttempts
        _ = controller.handle(.deleteBackward)
        let backspaceDelta = client.deleteAttempts - attemptsBefore
        XCTAssertEqual(client.text, "Word")

        let punctuationDelta = pressKeyDeltaDelete(controller, client, ".")

        XCTAssertEqual(client.text, "Word.")
        // 退格恰好一次宿主回删（删除刚补的空格）；标点键不得再次回删。
        XCTAssertEqual(backspaceDelta, 1)
        XCTAssertEqual(punctuationDelta, 0)
    }

    func testReturnClearsEligibility() {
        let (controller, client) = makeController(after: "")
        commitWord(controller, client)
        _ = controller.noteExternalDocumentChange()

        _ = controller.handle(.insertReturn)
        XCTAssertEqual(client.text, "Word \n")

        let delta = pressKeyDeltaDelete(controller, client, ".")
        XCTAssertEqual(client.text, "Word \n.")
        XCTAssertEqual(delta, 0)
    }

    func testInsertDirectTextClearsEligibility() {
        let (controller, client) = makeController(after: "")
        commitWord(controller, client)
        _ = controller.noteExternalDocumentChange()
        let attemptsBefore = client.deleteAttempts

        _ = controller.handle(.insertDirectText("."))

        XCTAssertEqual(client.text, "Word .")
        XCTAssertEqual(client.deleteAttempts - attemptsBefore, 0)
    }

    func testEmojiInsertClearsEligibility() {
        let (controller, client) = makeController(after: "")
        commitWord(controller, client)
        _ = controller.noteExternalDocumentChange()
        let attemptsBefore = client.deleteAttempts

        _ = controller.handle(.insertEmoji("😀"))

        XCTAssertEqual(client.text, "Word 😀")
        XCTAssertEqual(client.deleteAttempts - attemptsBefore, 0)
    }

    func testNonEnglishCandidateTapClearsEligibility() {
        let (controller, client) = makeController(after: "")
        commitWord(controller, client)
        _ = controller.noteExternalDocumentChange()

        // 无 pending 标点时点选标点候选不产生宿主写入，但必须先清态。
        _ = controller.handle(.insertCandidate(",", kind: .punctuationCandidate))
        XCTAssertEqual(client.text, "Word ")

        let delta = pressKeyDeltaDelete(controller, client, ".")
        XCTAssertEqual(client.text, "Word .")
        XCTAssertEqual(delta, 0)
    }

    func testNineKeyPunctuationTapClearsEligibility() {
        let (controller, client) = makeController(after: "")
        commitWord(controller, client)
        _ = controller.noteExternalDocumentChange()
        let attemptsBefore = client.deleteAttempts

        _ = controller.handle(.pressT9CommonPunctuation)

        XCTAssertEqual(client.text, "Word ，")
        XCTAssertEqual(client.deleteAttempts - attemptsBefore, 0)
    }

    // MARK: - 方案 A：空格键消耗顺序（r3 §2.3）

    /// 附着空格标记被空格键消耗：不重复写空格（保持 "Word "），且发生在
    /// lastSpaceTapTime 更新之前（被消耗的首空格不参与双击空格转句号）。
    func testSpaceKeyConsumesMarkWithoutWritingAnotherSpace() {
        let (controller, client) = makeController(after: "")
        commitWord(controller, client)
        _ = controller.noteExternalDocumentChange()

        now = Date(timeIntervalSince1970: 2_000)
        _ = controller.handle(.insertSpace)

        XCTAssertEqual(client.text, "Word ")
        XCTAssertEqual(client.insertCalls, ["W", "o", "r", "Word "])

        // 被消耗的首空格不参与双击空格转句号：紧随的空格不是句号转换。
        now = Date(timeIntervalSince1970: 2_000.2)
        _ = controller.handle(.insertSpace)

        XCTAssertEqual(client.text, "Word  ")
        XCTAssertFalse(client.text.contains(". "))
    }

    /// 防双空格基线（标记未参与时既有行为不回退）。
    func testDoubleSpaceToPeriodStillWorksWhenMarkNotInvolved() {
        let (controller, client) = makeController(after: "")
        now = Date(timeIntervalSince1970: 3_000)
        _ = controller.handle(.insertSpace)
        now = Date(timeIntervalSince1970: 3_000.2)
        _ = controller.handle(.insertSpace)

        XCTAssertEqual(client.text, ". ")
    }

    // MARK: - 状态机固定（内部状态表示；实现后补充的绿测）

    /// 提交后武装「已补尾随空格且拥有回删资格」，回声抑制随之武装（同活）。
    func testCommitArmsTrailingSpaceMarkWithEchoSuppression() {
        let (controller, client) = makeController(after: "")
        commitWord(controller, client)

        XCTAssertEqual(controller.state.englishTrailingSpaceMark?.committedTransactionText, "Word ")
        XCTAssertEqual(controller.state.englishTrailingSpaceMark?.suppressNextEcho, true)
    }

    /// 归属成立的回声：抑制耗尽一次，标记保持武装；第二个通知撤销整个标记
    /// （抑制与标记同清）。
    func testEchoSuppressionLifecycleBoundToMark() {
        let (controller, client) = makeController(after: "")
        commitWord(controller, client)
        _ = controller.noteExternalDocumentChange()
        XCTAssertEqual(controller.state.englishTrailingSpaceMark?.suppressNextEcho, false)

        _ = controller.noteExternalDocumentChange()
        XCTAssertNil(controller.state.englishTrailingSpaceMark)
    }

    /// 候选失效入口（clearEnglishCandidates）与标记同清。
    func testCandidateInvalidationRevokesMark() {
        let (controller, client) = makeController(after: "")
        commitWord(controller, client)

        _ = controller.clearEnglishCandidates()
        XCTAssertNil(controller.state.englishTrailingSpaceMark)

        commitWord(controller, client)
        _ = controller.handle(.toggleInputMode)
        XCTAssertNil(controller.state.englishTrailingSpaceMark)
    }
}
