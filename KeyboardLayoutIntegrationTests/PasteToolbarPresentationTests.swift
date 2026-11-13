import KeyboardCore
import UIKit
import XCTest

/// presentation、失败行和生命周期。不断言读取次数：B1 不读剪贴板。
nonisolated final class PasteToolbarPresentationTests: XCTestCase {
    @MainActor
    func testFailureStaysVisibleUntilTapAndDoesNotConsume() async throws {
        let sut = await PasteToolbarIntegrationHarness.make()
        let id = try XCTUnwrap(sut.pasteSession.begin())
        sut.pasteSession.complete(nil, operationID: id)
        XCTAssertEqual(sut.pasteSession.presentation, .armed)
        XCTAssertTrue(sut.pasteSession.pasteFailureVisible)
        sut.syncUI(with: [])
        let bar = try XCTUnwrap(sut.candidateBar as? CandidateBarView)
        bar.layoutIfNeeded()
        XCTAssertTrue(sut.pasteSession.pasteFailureVisible)
        let label = try failureLabel(bar)
        XCTAssertFalse(label.isHidden)
        XCTAssertTrue(label.isUserInteractionEnabled)
        let hit = bar.hitTest(CGPoint(x: 20, y: 23), with: nil)
        XCTAssertTrue(hit === label)
        bar.onPasteFailureTap?()
        XCTAssertFalse(sut.pasteSession.pasteFailureVisible)
        XCTAssertEqual(sut.pasteSession.presentation, .armed)
        XCTAssertNotNil(sut.pastePreviewView)
    }

    @MainActor
    func testArmedIsOutsideSessionEligibility() async {
        let sut = await PasteToolbarIntegrationHarness.make()
        sut.pasteSession.noteCountedInput()
        XCTAssertEqual(sut.pasteSession.presentation, .consumedByInput)
        XCTAssertTrue(sut.pasteSession.isEligible())
        XCTAssertNil(sut.pasteSession.begin())
    }

    @MainActor
    func testInputDuringLoadDiscardsThePaste() async throws {
        let sut = await PasteToolbarIntegrationHarness.make()
        let client = PasteClient()
        sut.controller.textClient = client
        let id = try XCTUnwrap(sut.pasteSession.begin())
        sut.controller.handle(.insertKey("a"))
        XCTAssertEqual(sut.pasteSession.presentation, .consumedByInput)
        XCTAssertNil(sut.pasteSession.activeOperationID)
        sut.pasteSession.complete("应丢弃", operationID: id)
        XCTAssertFalse(client.inserted.contains("应丢弃"))
    }

    @MainActor
    func testResultXAppearClearsPendingReturn() async {
        let sut = await PasteToolbarIntegrationHarness.make()
        sut.controller.handle(.insertKey("a"))
        let generation = sut.pasteSession.generation
        hostResign(sut)
        sut.viewWillDisappear(false)
        sut.handleKeyboardDidAppear()
        hostActive(sut)
        XCTAssertEqual(sut.pasteSession.presentation, .armed)
        XCTAssertFalse(sut.pasteSession.pendingReturn)
        XCTAssertEqual(sut.pasteSession.generation, generation + 1)
    }

    @MainActor
    func testResultYResetsAfterResignWithoutDisappear() async {
        let sut = await PasteToolbarIntegrationHarness.make()
        sut.pasteSession.noteCountedInput()
        sut.refreshPasteToolbar()
        let generation = sut.pasteSession.generation
        hostResign(sut)
        hostActive(sut)
        XCTAssertEqual(sut.pasteSession.presentation, .armed)
        XCTAssertFalse(sut.pasteSession.pendingReturn)
        XCTAssertEqual(sut.pasteSession.generation, generation + 1)
        await waitForFallback(sut)
        XCTAssertNotNil(sut.pastePreviewView)
    }

    @MainActor
    func testBecomeActiveWithoutResignLeavesPresentation() async {
        let sut = await PasteToolbarIntegrationHarness.make()
        sut.handleKeyboardDidAppear()
        sut.controller.handle(.insertKey("a"))
        let generation = sut.pasteSession.generation
        hostActive(sut)
        XCTAssertEqual(sut.pasteSession.presentation, .consumedByInput)
        XCTAssertEqual(sut.pasteSession.generation, generation)
    }

    @MainActor
    func testNotificationCenterReturnUsesResultY() async {
        let sut = await PasteToolbarIntegrationHarness.make()
        sut.handleKeyboardDidAppear()
        await waitForFallback(sut)
        XCTAssertNotNil(sut.pastePreviewView)
        let generation = sut.pasteSession.generation
        hostResign(sut)
        hostActive(sut)
        XCTAssertEqual(sut.pasteSession.presentation, .armed)
        XCTAssertEqual(sut.pasteSession.generation, generation + 1)
    }

    @MainActor
    private func waitForFallback(_ owner: PasteOwner) async {
        for _ in 0..<200 where owner.pastePreviewView == nil {
            try? await Task.sleep(for: .milliseconds(5))
        }
    }

    @MainActor
    func testCountedActionsConsumeAndIgnoredActionsDoNot() async {
        let sut = await PasteToolbarIntegrationHarness.make()
        let path = T9PinyinPath(displayText: "a", replacementRawInput: "a")
        let correction = TypoCorrectionCommit(
            committedText: "字",
            originalInput: "zi",
            correctedInput: "zi",
            edits: []
        )
        let counted: [KeyboardAction] = [
            .insertKey("a"),
            .insertCandidate("词", kind: .candidate),
            .insertCorrectionCandidate(correction),
            .insertDirectText("“"),
            .insertEmoji("😀"),
            .insertSpace,
            .insertReturn,
            .deleteBackward,
            .selectT9PinyinPath(path),
            .cycleT9PinyinPath,
            .pressT9CommonPunctuation,
            .pressKaomoji,
        ]
        for action in counted {
            sut.handleKeyboardDidAppear()
            sut.controller.handle(action)
            XCTAssertEqual(sut.pasteSession.presentation, .consumedByInput, "\(action)")
        }
        sut.handleKeyboardDidAppear()
        let ignored: [KeyboardAction] = [
            .toggleShift, .togglePage, .toggleInputMode, .candidatePageUp, .candidatePageDown,
            .keyboardTypeChanged(.default),
        ]
        for action in ignored {
            sut.controller.handle(action)
            XCTAssertEqual(sut.pasteSession.presentation, .armed, "\(action)")
        }
        _ = sut.performDeleteBackward(oneGraphemeBeforeCursor: true)
        XCTAssertEqual(sut.pasteSession.presentation, .consumedByInput)
    }

    @MainActor
    func testDeletingCompositionDoesNotRestoreTheStrip() async {
        let sut = await PasteToolbarIntegrationHarness.make()
        sut.controller.handle(.insertKey("n"))
        sut.controller.handle(.deleteBackward)
        sut.syncUI(with: [])
        XCTAssertEqual(sut.pasteSession.presentation, .consumedByInput)
        XCTAssertNil(sut.pastePreviewView)
    }

    @MainActor
    func testDocumentIdentityAndRelayoutDoNotResetPresentation() async {
        let sut = await PasteToolbarIntegrationHarness.make()
        sut.controller.handle(.insertKey("a"))
        sut.observePasteDocumentIdentity(.changed)
        sut.observePasteDocumentIdentity(.unavailable)
        sut.reloadKeyboard()
        XCTAssertEqual(sut.pasteSession.presentation, .consumedByInput)
    }

    @MainActor
    private func failureLabel(_ bar: CandidateBarView) throws -> UILabel {
        try XCTUnwrap(
            bar.subviews.compactMap { $0 as? UILabel }.first {
                $0.accessibilityIdentifier == "keyboard.paste.failure"
            })
    }

    @MainActor
    private func hostResign(_ sut: KeyboardViewController) {
        sut.perform(
            NSSelectorFromString("extensionHostWillResignActive:"),
            with: Notification(name: .NSExtensionHostWillResignActive)
        )
    }

    @MainActor
    private func hostActive(_ sut: KeyboardViewController) {
        sut.perform(
            NSSelectorFromString("extensionHostDidBecomeActive:"),
            with: Notification(name: .NSExtensionHostDidBecomeActive)
        )
    }
}

@MainActor
private enum PasteToolbarIntegrationHarness {
    static func make() async -> PasteOwner {
        let owner = PasteOwner()
        owner.access = true
        let defaults = PasteMemoryDefaults()
        defaults.set(true, forKey: KeyboardInputSettingsKey.clipboardPreviewEnabled)
        owner.sharedDefaults = defaults
        owner.loadViewIfNeeded()
        owner.controller = KeyboardController()
        owner.pasteSession.previewReader = PresentationTextReader()
        owner.controller.textClient = PasteClient()
        owner.cachedPasteToolbarEnabled = true
        owner.view.frame = CGRect(x: 0, y: 0, width: 390, height: 288)
        owner.setupRootStack()
        owner.reloadKeyboard()
        owner.isKeyboardUIInstalled = true
        owner.installPasteInputObservation()
        owner.view.layoutIfNeeded()
        owner.rootStack.layoutIfNeeded()
        owner.pasteSession.noteAppearance()
        owner.refreshPasteToolbar()
        for _ in 0..<200 where owner.pastePreviewView == nil {
            try? await Task.sleep(for: .milliseconds(5))
        }
        return owner
    }
}

private nonisolated struct PresentationTextReader: ClipboardPreviewReading {
    func read() -> ClipboardPreviewResult { .text(full: "test", summary: "test", isLink: false) }
}
