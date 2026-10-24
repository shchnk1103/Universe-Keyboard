import UIKit
import XCTest

@testable import KeyboardCore

/// 真正的 Controller/UIKit 层级与文本代理 spy；不启动 RIME，不冒充系统扩展或真机验证。
nonisolated final class KeyboardHeightAdjustmentTests: XCTestCase {
    @MainActor
    func testMarkerRequiresExactDocumentAndValidIdentity() {
        let owner = makeOwner()
        let marker = freshMarker()
        for text in [
            "ordinary", marker + "suffix", "prefix" + marker, KeyboardHeightAdjustmentMarker.prefix + "invalid",
        ] {
            owner.proxy.documentContextBeforeInput = text
            owner.textDidChange(nil)
            XCTAssertFalse(owner.isKeyboardHeightAdjusting)
        }
        owner.synchronizeKeyboardHeightAdjustment(before: marker, after: nil, documentIdentifier: nil)
        XCTAssertFalse(owner.isKeyboardHeightAdjusting)
        let split = marker.index(marker.startIndex, offsetBy: 20)
        owner.proxy.documentContextBeforeInput = String(marker[..<split])
        owner.proxy.documentContextAfterInput = String(marker[split...])
        owner.textDidChange(nil)
        XCTAssertTrue(owner.isKeyboardHeightAdjusting)
        owner.finishKeyboardHeightAdjustment(.cancelled)
    }

    @MainActor
    func testRepeatedMarkerDoesNotResetPreviewOrReenterAfterCancelOrControllerRecreation() {
        let owner = makeOwner()
        let marker = enter(owner)
        owner.previewKeyboardRowHeight(68)
        owner.textDidChange(nil)
        XCTAssertEqual(owner.keyboardHeightAdjustmentSession?.pendingRowHeight, 68)
        XCTAssertEqual(owner.keyHeight, 45)
        owner.cancelKeyboardHeightAdjustment()
        XCTAssertEqual(owner.dismissCount, 1)
        owner.textDidChange(nil)
        XCTAssertFalse(owner.isKeyboardHeightAdjusting)
        let second = makeOwner()
        second.proxy.documentContextBeforeInput = marker
        second.textDidChange(nil)
        XCTAssertFalse(second.isKeyboardHeightAdjusting)
        _ = enter(second)
        XCTAssertTrue(second.isKeyboardHeightAdjusting)
        second.finishKeyboardHeightAdjustment(.cancelled)
    }

    @MainActor
    func testConsumedUUIDSurvivesStoreRecreationWithoutPersistingSessionOrHostText() throws {
        let suite = "UI4-P3-" + UUID().uuidString
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        let token = UUID()
        XCTAssertTrue(KeyboardHeightAdjustmentTokenStore(defaults: defaults).consume(token))
        let reopened = try XCTUnwrap(UserDefaults(suiteName: suite))
        XCTAssertFalse(KeyboardHeightAdjustmentTokenStore(defaults: reopened).consume(token))
        XCTAssertEqual(
            reopened.stringArray(forKey: KeyboardHeightAdjustmentTokenStore.consumedTokensKey), [token.uuidString])
        XCTAssertNil(KeyboardHeightPreferenceStore(defaults: reopened).read())
    }

    @MainActor
    func testConsumedTokensKeepOnlyNewestSixtyFourAcrossStoreRecreation() throws {
        let suite = "UI4-Bounded-Tokens-" + UUID().uuidString
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        let store = KeyboardHeightAdjustmentTokenStore(defaults: defaults)
        let tokens = (0..<65).map { _ in UUID() }
        for token in tokens { XCTAssertTrue(store.consume(token)) }
        let expected = tokens.suffix(64).map(\.uuidString)
        XCTAssertEqual(defaults.stringArray(forKey: KeyboardHeightAdjustmentTokenStore.consumedTokensKey), expected)
        let reopened = KeyboardHeightAdjustmentTokenStore(defaults: defaults)
        for token in tokens.suffix(64) { XCTAssertFalse(reopened.consume(token)) }
        XCTAssertEqual(defaults.stringArray(forKey: KeyboardHeightAdjustmentTokenStore.consumedTokensKey)?.count, 64)
        // 被淘汰的UUID不再受去重承诺保护；再消费它应淘汰下一个最旧记录。
        XCTAssertTrue(reopened.consume(tokens[0]))
        XCTAssertEqual(
            defaults.stringArray(forKey: KeyboardHeightAdjustmentTokenStore.consumedTokensKey),
            tokens.suffix(63).map(\.uuidString) + [tokens[0].uuidString])
        XCTAssertFalse(KeyboardHeightAdjustmentTokenStore(defaults: defaults).consume(tokens[0]))
    }

    @MainActor
    func testDragIsIntegerPreviewOnlyAndClampsHandleAtBothEnds() throws {
        let owner = makeOwner(saved: 60)
        var writes: [Int?] = []
        owner.keyboardRowHeightSink = { writes.append($0) }
        _ = enter(owner)
        owner.previewKeyboardRowHeight(66.6)
        XCTAssertEqual(owner.keyboardHeightAdjustmentSession?.pendingRowHeight, 67)
        XCTAssertEqual(owner.keyHeight, 60)
        XCTAssertEqual(owner.keyboardHeightSettings.savedRowHeight, 60)
        XCTAssertTrue(writes.isEmpty)
        owner.previewKeyboardRowHeight(10_000)
        XCTAssertEqual(owner.keyboardHeightAdjustmentSession?.pendingRowHeight, 87)
        XCTAssertEqual(owner.keyHeight, 60)
        XCTAssertEqual(owner.keyboardHeightAdjustmentOverlay?.slider.value, 87)
        owner.previewKeyboardRowHeight(-100)
        XCTAssertEqual(owner.keyboardHeightAdjustmentSession?.pendingRowHeight, 40)
        XCTAssertEqual(owner.keyHeight, 60)
        XCTAssertEqual(owner.keyboardHeightAdjustmentOverlay?.slider.value, 40)
        owner.previewKeyboardRowHeight(.nan)
        XCTAssertEqual(owner.keyboardHeightAdjustmentSession?.pendingRowHeight, 40)
        XCTAssertEqual(owner.keyHeight, 60)
        owner.cancelKeyboardHeightAdjustment()
        XCTAssertEqual(owner.keyHeight, 60)
        XCTAssertTrue(writes.isEmpty)
        XCTAssertNil(owner.keyboardHeightAdjustmentOverlay)
        XCTAssertTrue(owner.keyboardSurfaceView.isUserInteractionEnabled)
        XCTAssertFalse(owner.keyboardSurfaceView.accessibilityElementsHidden)
    }

    @MainActor
    func testConfirmPersistsEffectiveValueToPrivateDefaultsAndNextAppearanceReadsIt() throws {
        let suite = "UI4-P3-" + UUID().uuidString
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        let store = KeyboardHeightPreferenceStore(defaults: defaults)
        store.write(70)
        let owner = makeOwner(saved: store.read())
        owner.sharedDefaults = nil
        owner.keyboardRowHeightSource = { store.read() }
        owner.keyboardRowHeightSink = { store.write($0) }
        XCTAssertFalse(owner.hasFullAccess)
        _ = enter(owner)
        owner.previewKeyboardRowHeight(67.2)
        XCTAssertEqual(store.read(), 70)
        owner.confirmKeyboardHeightAdjustment()
        XCTAssertEqual(store.read(), 67)
        XCTAssertEqual(defaults.object(forKey: KeyboardHeightPreferenceStore.rowHeightKey) as? Int, 67)
        XCTAssertFalse(owner.isKeyboardHeightAdjusting)
        XCTAssertEqual(owner.dismissCount, 1)
        owner.textDidChange(nil)
        XCTAssertFalse(owner.isKeyboardHeightAdjusting)
        let next = makeOwner(saved: store.read())
        XCTAssertEqual(next.keyHeight, 67)
    }

    @MainActor
    func testResetOnlyDeletesOnConfirmAndDragAfterResetSavesValue() throws {
        let suite = "UI4-P3-" + UUID().uuidString
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        let store = KeyboardHeightPreferenceStore(defaults: defaults)
        store.write(70)
        let owner = makeOwner(saved: 70)
        owner.keyboardRowHeightSink = { store.write($0) }
        _ = enter(owner)
        owner.resetKeyboardHeightPreview()
        XCTAssertEqual(owner.keyboardHeightAdjustmentSession?.pendingRowHeight, KeyboardHeightSettings.defaultRowHeight)
        XCTAssertEqual(owner.keyHeight, 70)
        XCTAssertEqual(store.read(), 70)
        owner.cancelKeyboardHeightAdjustment()
        XCTAssertEqual(store.read(), 70)
        XCTAssertEqual(owner.keyHeight, 70)
        _ = enter(owner)
        owner.resetKeyboardHeightPreview()
        owner.confirmKeyboardHeightAdjustment()
        XCTAssertNil(defaults.object(forKey: KeyboardHeightPreferenceStore.rowHeightKey))
        _ = enter(owner)
        owner.resetKeyboardHeightPreview()
        owner.previewKeyboardRowHeight(63)
        owner.confirmKeyboardHeightAdjustment()
        XCTAssertEqual(store.read(), 63)
    }

    @MainActor
    func testPageDepartureAndHostChangeRestoreWithoutWriting() {
        for changesHost in [false, true] {
            let owner = makeOwner(saved: 60)
            var writes = 0
            owner.keyboardRowHeightSink = { _ in writes += 1 }
            let marker = enter(owner)
            owner.previewKeyboardRowHeight(70)
            if changesHost {
                owner.proxy.documentIdentifier = UUID()
            } else {
                owner.proxy.documentContextBeforeInput = ""
            }
            owner.textDidChange(nil)
            XCTAssertFalse(owner.isKeyboardHeightAdjusting)
            XCTAssertNil(owner.keyboardHeightAdjustmentOverlay)
            XCTAssertEqual(owner.keyHeight, 60)
            XCTAssertEqual(writes, 0)
            owner.proxy.documentContextBeforeInput = marker
            owner.textDidChange(nil)
            XCTAssertFalse(owner.isKeyboardHeightAdjusting)
        }
    }

    @MainActor
    func testKeyboardSwitchExitsBeforeAdvancingAndDoesNotWrite() {
        let owner = makeOwner(saved: 60)
        var writes = 0
        owner.keyboardRowHeightSink = { _ in writes += 1 }
        _ = enter(owner)
        owner.previewKeyboardRowHeight(70)
        owner.switchKeyboardDuringHeightAdjustment()
        XCTAssertEqual(owner.switchCount, 1)
        XCTAssertFalse(owner.wasAdjustingWhenSwitched)
        XCTAssertFalse(owner.isKeyboardHeightAdjusting)
        XCTAssertEqual(owner.keyHeight, 60)
        XCTAssertEqual(writes, 0)
        owner.textDidChange(nil)
        XCTAssertFalse(owner.isKeyboardHeightAdjusting)
    }

    @MainActor
    func testWindowRemovalCancelsSessionAndRejectsCallbacksWhileHidden() {
        let owner = makeOwner(saved: 60)
        let window = attach(owner)
        defer { window.isHidden = true }
        var writes = 0
        owner.keyboardRowHeightSink = { _ in writes += 1 }
        _ = enter(owner)
        owner.previewKeyboardRowHeight(70)
        owner.view.removeFromSuperview()
        XCTAssertFalse(owner.isKeyboardHeightAdjusting)
        XCTAssertFalse(owner.keyboardHeightAdjustmentAcceptsMarkers)
        XCTAssertEqual(owner.keyHeight, 60)
        XCTAssertEqual(writes, 0)
        owner.proxy.documentContextBeforeInput = freshMarker()
        owner.textDidChange(nil)
        XCTAssertFalse(owner.isKeyboardHeightAdjusting)
    }

    @MainActor
    func testViewDisappearanceCancelsAndNextPresentationDoesNotReplayMarker() {
        let owner = makeOwner(saved: 60)
        var writes = 0
        owner.keyboardRowHeightSink = { _ in writes += 1 }
        _ = enter(owner)
        owner.previewKeyboardRowHeight(70)
        owner.viewWillDisappear(false)
        owner.viewDidDisappear(false)
        XCTAssertFalse(owner.isKeyboardHeightAdjusting)
        XCTAssertTrue(owner.keyboardHeightNeedsRead)
        XCTAssertEqual(owner.keyHeight, 60)
        XCTAssertEqual(writes, 0)
        owner.keyboardHeightAdjustmentAcceptsMarkers = true
        owner.prepareKeyboardHeightForAppearance()
        owner.textDidChange(nil)
        XCTAssertFalse(owner.isKeyboardHeightAdjusting)
    }

    @MainActor
    func testKeyDeleteCandidateAndGestureCallbacksCannotMutateHostOrComposition() throws {
        let owner = makeOwner()
        _ = enter(owner)
        // 合成宿主文本与候选；直接调用 UIKit selector/delegate，证明不依赖遮罩才阻止上屏。
        owner.proxy.documentContextBeforeInput = "synthetic-text"
        owner.proxy.calls.removeAll()
        let button = UIButton()
        button.setTitle("a", for: .normal)
        button.configuration = .plain()
        button.configuration?.title = "候选"
        button.tag = CandidateKind.continuationCandidate.rawValue
        let before = owner.controller.state.currentComposition
        owner.keyTouchDown(button)
        owner.insertKey(button)
        owner.insertDirectText(button)
        owner.insertSmartDoubleQuote(button)
        owner.insertEmoji(button)
        owner.insertCandidate(button)
        owner.insertSpace(button)
        owner.insertReturn(button)
        owner.insertT9CommonPunctuation(button)
        owner.insertKaomoji(button)
        owner.toggleInputMode(button)
        owner.toggleKeyboardPage(button)
        owner.toggleShift(button)
        owner.deleteKeyTouchDown(button, forEvent: UIEvent())
        XCTAssertNil(owner.deleteGestureSession)
        XCTAssertFalse(owner.performDeleteBackward())
        owner.performDeleteAllBeforeCursor()
        owner.restoreScrubbedGrapheme("synthetic")
        owner.commitExpandedCandidate(CandidateItem(title: "候选", kind: .continuationCandidate))
        owner.accumulatedCandidates = [CandidateItem(title: "候选", kind: .continuationCandidate)]
        owner.commitCompactCandidate(at: IndexPath(item: 0, section: 0))
        let collection = try XCTUnwrap(owner.candidateCollectionView)
        owner.collectionView(collection, didSelectItemAt: IndexPath(item: 0, section: 0))
        owner.handleKeyLongPress(UILongPressGestureRecognizer())
        owner.handleSpaceCursorLongPress(UILongPressGestureRecognizer())
        XCTAssertTrue(owner.proxy.calls.isEmpty)
        XCTAssertEqual(owner.controller.state.currentComposition, before)
        XCTAssertTrue(owner.keyPressFeedbackEmittedButtonIDs.isEmpty)
        XCTAssertFalse(owner.isCursorMovementModeActive)
        owner.finishKeyboardHeightAdjustment(.cancelled)
        // 退出后普通输入能通过同一个生产 selector；避免永久禁用输入的伪通过。
        owner.insertDirectText(button)
        XCTAssertTrue(owner.proxy.calls.contains("insert"))
    }

    @MainActor
    func testOverlayWinsHitTestingOverExpandedKeyCellsInPortraitAndLandscape() throws {
        for landscape in [false, true] {
            let owner = makeOwner(saved: 80, landscape: landscape)
            let window = attach(owner)
            defer { window.isHidden = true }
            _ = enter(owner)
            owner.previewKeyboardRowHeight(10_000)
            layout(owner, width: landscape ? 844 : 390)
            let overlay = try XCTUnwrap(owner.keyboardHeightAdjustmentOverlay)
            XCTAssertTrue(overlay.accessibilityViewIsModal)
            XCTAssertTrue(owner.keyboardSurfaceView.accessibilityElementsHidden)
            XCTAssertFalse(owner.keyboardSurfaceView.isUserInteractionEnabled)
            for control in [
                overlay.slider, overlay.resetButton, overlay.cancelButton, overlay.confirmButton,
                overlay.nextKeyboardButton,
            ] {
                let point = control.convert(CGPoint(x: control.bounds.midX, y: control.bounds.midY), to: owner.view)
                let hit = owner.view.hitTest(point, with: nil)
                XCTAssertTrue(hit === control || hit?.isDescendant(of: control) == true)
                XCTAssertGreaterThanOrEqual(control.bounds.height, 44)
            }
            // 系统隐藏的地球键可能位于根视图外；只验证当前可见按键的遮罩命中。
            let keys = descendants(owner.rootStack).compactMap { $0 as? KeyboardKeyButton }.filter { !$0.isHidden }
            XCTAssertFalse(keys.isEmpty)
            for key in keys {
                let point = key.convert(CGPoint(x: key.bounds.midX, y: key.bounds.midY), to: owner.view)
                let hit = owner.view.hitTest(point, with: nil)
                XCTAssertTrue(hit === overlay || hit?.isDescendant(of: overlay) == true)
            }
            owner.reloadKeyboard()
            layout(owner, width: landscape ? 844 : 390)
            XCTAssertTrue(owner.view.subviews.last === overlay)
            XCTAssertFalse(owner.keyboardSurfaceView.isUserInteractionEnabled)
            let image = UIGraphicsImageRenderer(size: owner.view.bounds.size).image { context in
                owner.view.layer.render(in: context.cgContext)
            }
            let attachment = XCTAttachment(image: image)
            attachment.name = "ui4-p3-" + (landscape ? "landscape" : "portrait")
            attachment.lifetime = .keepAlways
            add(attachment)
            owner.finishKeyboardHeightAdjustment(.cancelled)
        }
    }

    @MainActor
    func testLandscapeAndHostCompressionUseEffectiveHeightWithoutImplicitWriteback() {
        let owner = makeOwner(saved: 70)
        var writes: [Int?] = []
        owner.keyboardRowHeightSink = { writes.append($0) }
        _ = enter(owner)
        owner.keyboardHeightGeometrySource = { .init(screenHeight: 390, isLandscape: true) }
        owner.synchronizeKeyboardHeightLayout()
        owner.layoutKeyboardHeightAdjustmentOverlay()
        XCTAssertEqual(owner.keyHeight, 45)
        XCTAssertEqual(owner.keyboardHeightAdjustmentMaximum(), 45)
        XCTAssertTrue(writes.isEmpty)
        owner.confirmKeyboardHeightAdjustment()
        XCTAssertEqual(writes.count, 1)
        XCTAssertEqual(writes[0], 45)
        let compressed = makeOwner(saved: 70)
        compressed.keyboardRowHeightSink = { writes.append($0) }
        _ = enter(compressed)
        compressed.keyboardAcceptedHeight = 274
        compressed.synchronizeKeyboardHeightLayout()
        compressed.previewKeyboardRowHeight(70)
        XCTAssertEqual(compressed.keyHeight, 50)
        compressed.confirmKeyboardHeightAdjustment()
        XCTAssertEqual(writes.count, 2)
        XCTAssertEqual(writes[1], 50)
    }

    @MainActor
    func testSubminimumHostBudgetKeepsP2HideBehaviorAndCannotSave() {
        let owner = makeOwner(saved: 70)
        var writes = 0
        owner.keyboardRowHeightSink = { _ in writes += 1 }
        _ = enter(owner)
        owner.keyboardAcceptedHeight = 216
        owner.synchronizeKeyboardHeightLayout()
        XCTAssertEqual(owner.keyboardHeightStatus, "hostBudgetBelowMinimum")
        XCTAssertEqual(owner.view.alpha, 0)
        XCTAssertFalse(owner.keyboardHeightConstraint?.isActive ?? true)
        owner.confirmKeyboardHeightAdjustment()
        XCTAssertTrue(owner.isKeyboardHeightAdjusting)
        XCTAssertEqual(writes, 0)
        owner.finishKeyboardHeightAdjustment(.cancelled)
        XCTAssertEqual(owner.keyboardHeightSettings.savedRowHeight, 70)
    }

    @MainActor
    func testVoiceOverEscapeCancelsAndSliderHasAdjustableSemantics() throws {
        let owner = makeOwner(saved: 60)
        _ = enter(owner)
        let overlay = try XCTUnwrap(owner.keyboardHeightAdjustmentOverlay)
        XCTAssertEqual(overlay.slider.accessibilityLabel, "键盘行高")
        XCTAssertTrue(overlay.slider.accessibilityTraits.contains(.adjustable))
        XCTAssertEqual(overlay.slider.accessibilityValue, "60 点")
        owner.previewKeyboardRowHeight(70)
        XCTAssertTrue(overlay.accessibilityPerformEscape())
        XCTAssertFalse(owner.isKeyboardHeightAdjusting)
        XCTAssertEqual(owner.keyHeight, 60)
    }

    @MainActor
    func testWindowDragKeepsGeometryUntilOneEndAndCancelRestoresAppliedPreview() throws {
        let owner = makeOwner(saved: 60)
        let window = attach(owner)
        defer { window.isHidden = true }
        var writes = 0
        owner.keyboardRowHeightSink = { _ in writes += 1 }
        _ = enter(owner)
        layout(owner)
        let overlay = try XCTUnwrap(owner.keyboardHeightAdjustmentOverlay)
        let panel = try XCTUnwrap(overlay.slider.superview)
        let panelFrame = panel.frame
        let sliderFrame = overlay.slider.frame
        let request = owner.keyboardHeightConstraint?.constant
        let rows = owner.keyboardHeightConstraints.compactMap { $0.constraint?.constant }
        for value: Float in [65, 70, 75] {
            overlay.slider.value = value
            owner.changeKeyboardHeightPreview(overlay.slider)
            owner.viewDidLayoutSubviews()
            overlay.layoutIfNeeded()
            XCTAssertEqual(owner.keyHeight, 60)
            XCTAssertEqual(owner.keyboardHeightConstraint?.constant, request)
            XCTAssertEqual(owner.keyboardHeightConstraints.compactMap { $0.constraint?.constant }, rows)
            XCTAssertEqual(panel.frame, panelFrame)
            XCTAssertEqual(overlay.slider.frame, sliderFrame)
            XCTAssertEqual(overlay.slider.value, value)
            XCTAssertEqual(overlay.valueLabel.text, "键盘行高 · \(Int(value)) 点")
            XCTAssertEqual(writes, 0)
        }
        owner.endKeyboardHeightDrag()
        layout(owner)
        XCTAssertEqual(owner.keyHeight, 75)
        XCTAssertNotEqual(owner.keyboardHeightConstraint?.constant, request)
        let appliedRequest = owner.keyboardHeightConstraint?.constant
        let appliedPanel = panel.frame
        owner.endKeyboardHeightDrag()
        XCTAssertEqual(owner.keyHeight, 75)
        XCTAssertEqual(owner.keyboardHeightConstraint?.constant, appliedRequest)
        XCTAssertEqual(panel.frame, appliedPanel)
        XCTAssertNil(owner.keyboardHeightAdjustmentSession?.dragMaximum)
        overlay.slider.value = 80
        owner.changeKeyboardHeightPreview(overlay.slider)
        owner.cancelKeyboardHeightDrag()
        XCTAssertEqual(owner.keyHeight, 75)
        XCTAssertEqual(overlay.slider.value, 75)
        owner.endKeyboardHeightDrag()
        XCTAssertEqual(owner.keyHeight, 75)
        XCTAssertEqual(writes, 0)
        owner.cancelKeyboardHeightAdjustment()
        XCTAssertEqual(owner.keyHeight, 60)
    }

    @MainActor
    func testAccessibilityAppliesFivePointStepsWithoutTouchEnd() throws {
        let owner = makeOwner(saved: 60)
        _ = enter(owner)
        let slider = try XCTUnwrap(owner.keyboardHeightAdjustmentOverlay?.slider)
        slider.accessibilityIncrement()
        XCTAssertEqual(owner.keyHeight, 65)
        XCTAssertEqual(slider.accessibilityValue, "65 点")
        slider.accessibilityDecrement()
        XCTAssertEqual(owner.keyHeight, 60)
        XCTAssertEqual(slider.accessibilityValue, "60 点")
        owner.endKeyboardHeightDrag()
        XCTAssertEqual(owner.keyHeight, 60)
        owner.finishKeyboardHeightAdjustment(.cancelled)
    }

    @MainActor
    func testSavedSixtyRestoresAfterRotationHostRespondsToNewHeight() throws {
        let owner = makeOwner(saved: 60)
        var saved: Int? = 60
        var writes = 0
        owner.keyboardRowHeightSource = { saved }
        owner.keyboardRowHeightSink = {
            saved = $0; writes += 1
        }
        _ = enter(owner)
        owner.previewKeyboardRowHeight(60)
        owner.endKeyboardHeightDrag()
        owner.confirmKeyboardHeightAdjustment()
        XCTAssertEqual(saved, 60)
        XCTAssertEqual(writes, 1)
        let window = attach(owner)
        defer { window.isHidden = true }
        owner.hostLifecycleRecoveryGate.noteViewWillAppear(context: nil)
        owner.hostLifecycleRecoveryGate.noteViewDidAppear(hasWindow: true)
        XCTAssertEqual(owner.hostLifecycleRecoveryGate.phase, .visible)
        XCTAssertNotNil(owner.view.window)

        owner.view.bounds.size = CGSize(width: 390, height: 314)
        owner.synchronizeKeyboardHeightLayout()
        XCTAssertEqual(owner.keyHeight, 60)
        owner.keyboardHeightGeometrySource = { .init(screenHeight: 390, isLandscape: true) }
        owner.view.bounds.size = CGSize(width: 844, height: 254)
        owner.synchronizeKeyboardHeightLayout()
        owner.synchronizeKeyboardHeightLayout()
        XCTAssertEqual(owner.keyHeight, 45)
        XCTAssertEqual(saved, 60)
        XCTAssertEqual(owner.keyboardHeightSettings.savedRowHeight, 60)

        // 方向先回竖屏，宿主仍给旧的横屏高度；重复布局覆盖预算重采样。
        owner.keyboardHeightGeometrySource = { .init(screenHeight: 844, isLandscape: false) }
        owner.view.bounds.size = CGSize(width: 390, height: 254)
        owner.synchronizeKeyboardHeightLayout()
        owner.synchronizeKeyboardHeightLayout()
        print(
            "ORIENTATION_REPRO oldHost keyHeight=\(owner.keyHeight) accepted=\(String(describing: owner.keyboardAcceptedHeight))"
        )
        XCTAssertEqual(saved, 60)
        XCTAssertEqual(owner.keyboardHeightSettings.savedRowHeight, 60)
        XCTAssertEqual(owner.keyboardHeightConstraint?.constant, 314)

        // 随后宿主真正响应314pt，不用永久矮预算伪造“永久卡住”。
        owner.view.bounds.size = CGSize(width: 390, height: 314)
        owner.synchronizeKeyboardHeightLayout()
        owner.synchronizeKeyboardHeightLayout()
        print(
            "ORIENTATION_REPRO sufficientHost keyHeight=\(owner.keyHeight) accepted=\(String(describing: owner.keyboardAcceptedHeight))"
        )
        XCTAssertEqual(owner.keyHeight, 60)
        XCTAssertEqual(owner.preferredKeyboardHeight, 314)
        XCTAssertNil(owner.keyboardAcceptedHeight)
        XCTAssertEqual(saved, 60)
        XCTAssertEqual(owner.keyboardHeightSettings.savedRowHeight, 60)
        XCTAssertEqual(writes, 1)
    }

    @MainActor
    private func makeOwner(saved: Int? = nil, landscape: Bool = false) -> HeightAdjustmentTestController {
        let owner = HeightAdjustmentTestController()
        owner.loadViewIfNeeded()
        owner.controller = KeyboardController(state: KeyboardState(inputMode: .english))
        owner.keyboardHeightAdjustmentTokenConsumer = { HeightAdjustmentTestTokens.consumed.insert($0).inserted }
        owner.keyboardRowHeightSource = { saved }
        owner.keyboardRowHeightSink = { _ in XCTFail("Unexpected preference write") }
        owner.keyboardHeightGeometrySource = { .init(screenHeight: landscape ? 390 : 844, isLandscape: landscape) }
        owner.prepareKeyboardHeightForAppearance()
        owner.installKeyboardUIIfNeeded()
        owner.keyboardHeightAdjustmentAcceptsMarkers = true
        layout(owner, width: landscape ? 844 : 390)
        return owner
    }

    @MainActor
    private func enter(_ owner: HeightAdjustmentTestController) -> String {
        let marker = freshMarker()
        owner.proxy.documentContextBeforeInput = marker
        owner.proxy.documentContextAfterInput = ""
        owner.textDidChange(nil)
        XCTAssertTrue(owner.isKeyboardHeightAdjusting)
        return marker
    }

    @MainActor
    private func freshMarker() -> String {
        KeyboardHeightAdjustmentMarker.prefix + UUID().uuidString
    }

    @MainActor
    private func layout(_ owner: KeyboardViewController, width: CGFloat = 390) {
        owner.view.frame = CGRect(x: 0, y: 0, width: width, height: owner.preferredKeyboardHeight)
        owner.view.setNeedsLayout()
        owner.view.layoutIfNeeded()
        owner.rootStack.layoutIfNeeded()
        owner.keyboardHeightAdjustmentOverlay?.layoutIfNeeded()
    }

    @MainActor
    private func attach(_ owner: KeyboardViewController) -> UIWindow {
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: owner.view.bounds.width, height: 500))
        let host = UIViewController()
        window.rootViewController = host
        host.view.addSubview(owner.view)
        window.isHidden = false
        return window
    }

    @MainActor
    private func descendants(_ view: UIView) -> [UIView] {
        view.subviews.flatMap { [$0] + descendants($0) }
    }
}

@MainActor
private final class HeightAdjustmentTestController: KeyboardViewController {
    let proxy = HeightAdjustmentTextProxy()
    var dismissCount = 0
    var switchCount = 0
    var wasAdjustingWhenSwitched = false
    override var textDocumentProxy: UITextDocumentProxy { proxy }
    override var hasFullAccess: Bool { false }
    override func viewDidLoad() { /* 只跳过引擎 bootstrap，仍使用生产 loadView 与动作。 */  }
    override func dismissKeyboard() { dismissCount += 1 }
    override func advanceToNextInputMode() {
        wasAdjustingWhenSwitched = isKeyboardHeightAdjusting
        switchCount += 1
    }
}

@MainActor
private final class HeightAdjustmentTextProxy: NSObject, UITextDocumentProxy {
    var documentContextBeforeInput: String?
    var documentContextAfterInput: String?
    var selectedText: String?
    var documentInputMode: UITextInputMode?
    var documentIdentifier = UUID()
    var keyboardType: UIKeyboardType = .asciiCapable
    var keyboardAppearance: UIKeyboardAppearance = .default
    var returnKeyType: UIReturnKeyType = .default
    var hasText: Bool { !(documentContextBeforeInput ?? "").isEmpty }
    var calls: [String] = []
    func insertText(_ text: String) { calls.append("insert") }
    func deleteBackward() { calls.append("delete") }
    func adjustTextPosition(byCharacterOffset offset: Int) { calls.append("cursor") }
    func setMarkedText(_ markedText: String, selectedRange: NSRange) { calls.append("marked") }
    func unmarkText() { calls.append("unmark") }
}

@MainActor
private enum HeightAdjustmentTestTokens {
    static var consumed: Set<UUID> = []
}
