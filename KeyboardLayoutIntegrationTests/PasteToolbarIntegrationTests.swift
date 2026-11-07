import KeyboardCore
import UIKit
import UniformTypeIdentifiers
import XCTest

@testable import KeyboardCore

/// Real production controller and bar; only engine bootstrap and Full Access are supplied by the fixture.
nonisolated final class PasteToolbarIntegrationTests: XCTestCase {
    @MainActor
    private func owner(enabled: Bool = true, access: Bool = true) -> PasteOwner {
        let owner = PasteOwner()
        owner.access = access
        owner.loadViewIfNeeded()
        owner.controller = KeyboardController()
        owner.controller.textClient = PasteClient()
        owner.cachedPasteToolbarEnabled = enabled
        owner.view.frame = CGRect(x: 0, y: 0, width: 390, height: 288)
        owner.setupRootStack()
        owner.reloadKeyboard()
        owner.isKeyboardUIInstalled = true
        owner.view.layoutIfNeeded()
        owner.rootStack.layoutIfNeeded()
        owner.refreshPasteToolbar()
        return owner
    }

    @MainActor
    func testDefaultsAndFullAccessGate() {
        XCTAssertNil(owner(enabled: false).pasteToolbar)
        XCTAssertNil(owner(access: false).pasteToolbar)
        XCTAssertNotNil(owner().pasteToolbar)
        XCTAssertEqual(KeyboardInputSettingsKey.pasteToolbarEnabled, "paste_toolbar_enabled")
    }

    @MainActor
    func testFivePagesKeepGeometryAndSeparateHitTargets() throws {
        let sut = owner()
        for nineKey in [false, true] {
            sut.cachedLayoutStyle = nineKey ? .nineKey : .twentySixKey
            for page in [KeyboardPage.letters, .numbers, .symbols, .emoji] {
                sut.controller.state.currentPage = page
                sut.reloadKeyboard()
                sut.view.layoutIfNeeded()
                sut.rootStack.layoutIfNeeded()
                let toolbar = try XCTUnwrap(sut.pasteToolbar)
                let bar = try XCTUnwrap(sut.candidateBar as? CandidateBarView)
                XCTAssertEqual(bar.bounds.height, 46)
                XCTAssertEqual(toolbar.frame.height, 46)
                XCTAssertGreaterThanOrEqual(toolbar.frame.width, 44)
                XCTAssertLessThanOrEqual(toolbar.frame.maxX, bar.expandButton.frame.minX)
                XCTAssertEqual(bar.expandButton.frame.width, 56)
                let rightHit = bar.hitTest(CGPoint(x: 370, y: 23), with: nil)
                XCTAssertTrue(rightHit === bar.expandButton || rightHit?.isDescendant(of: bar.expandButton) == true)
                let pasteHit = bar.hitTest(CGPoint(x: 20, y: 23), with: nil)
                XCTAssertTrue(pasteHit === toolbar || pasteHit?.isDescendant(of: toolbar) == true)
                var selections = 0
                bar.onItemTap = { _ in selections += 1 }
                let actions = bar.expandButton.actions(forTarget: sut, forControlEvent: .touchUpInside)
                XCTAssertEqual(actions, [NSStringFromSelector(#selector(sut.handleCandidateBarTrailingButton))])
                // This test target is unhosted; dispatch the registered selector directly.
                sut.perform(#selector(sut.handleCandidateBarTrailingButton))
                XCTAssertFalse(bar.gestureRecognizerShouldBegin(UIPanGestureRecognizer()))
                XCTAssertEqual(sut.dismissals, (nineKey ? 4 : 0) + pageOrdinal(page) + 1)
                XCTAssertEqual(selections, 0)
                XCTAssertNil(sut.pasteSession.activeOperationID)
            }
        }
    }

    @MainActor
    private func pageOrdinal(_ page: KeyboardPage) -> Int {
        switch page {
        case .letters: return 0;
        case .numbers: return 1;
        case .symbols: return 2;
        case .emoji: return 3
        }
    }

    @MainActor
    func testSuccessAndSynchronousUnchangedReentryPermitNextPaste() throws {
        let sut = owner()
        let client = PasteClient()
        sut.controller.textClient = client
        sut.commitTraceTestDocumentIdentifier = UUID()
        sut.synchronizeAfterTextChange()
        sut.controller.textClient = client
        client.onInsert = {
            XCTAssertEqual(sut.pasteSession.state, .loading)
            XCTAssertNotNil(sut.pasteSession.activeOperationID)
            sut.synchronizeAfterTextChange()
            XCTAssertEqual(sut.pasteSession.state, .loading)
            XCTAssertFalse(sut.pasteSession.pasteFailureVisible)
        }
        let first = try XCTUnwrap(sut.pasteSession.begin())
        sut.pasteSession.complete("乙", operationID: first)
        sut.controller.textClient = client
        let second = try XCTUnwrap(sut.pasteSession.begin())
        sut.pasteSession.complete("丙", operationID: second)
        XCTAssertEqual(client.inserted, ["乙", "丙"])
        XCTAssertEqual(sut.pasteSession.state, .idle)
    }

    @MainActor
    func testReplacementDiscardsOldResult() throws {
        let sut = owner()
        let client = PasteClient()
        sut.controller.textClient = client
        let old = try XCTUnwrap(sut.pasteSession.begin())
        let new = try XCTUnwrap(sut.pasteSession.begin())
        sut.pasteSession.complete("old", operationID: old)
        sut.pasteSession.complete("new", operationID: new)
        XCTAssertEqual(client.inserted, ["new"])
    }

    @MainActor
    func testCompositionStartThenCancelNeverReplays() throws {
        let sut = owner()
        let client = PasteClient()
        sut.controller.textClient = client
        let id = try XCTUnwrap(sut.pasteSession.begin())
        sut.controller.state.currentComposition = "ni"
        sut.syncUI(with: [])
        XCTAssertNil(sut.pasteToolbar)
        sut.pasteSession.complete("late while composing", operationID: id)
        XCTAssertEqual(sut.controller.state.currentComposition, "ni")
        XCTAssertTrue(client.inserted.isEmpty)
        sut.controller.state.currentComposition = ""
        sut.syncUI(with: [])
        sut.pasteSession.complete("late", operationID: id)
        XCTAssertTrue(client.inserted.isEmpty)
    }

    @MainActor
    func testChangedAndUnavailableInvalidateButInitialAndUnchangedDoNot() throws {
        let sut = owner()
        for observation in [KeyboardDocumentIdentityTracker.Observation.initial, .unchanged, .changed, .unavailable] {
            let client = PasteClient()
            sut.controller.textClient = client
            let id = try XCTUnwrap(sut.pasteSession.begin())
            sut.observePasteDocumentIdentity(observation)
            sut.pasteSession.complete("x", operationID: id)
            XCTAssertEqual(client.inserted.count, observation == .initial || observation == .unchanged ? 1 : 0)
        }
    }

    @MainActor
    func testDisappearAndHostResignInvalidateWithoutReplay() throws {
        let sut = owner()
        let client = PasteClient()
        sut.controller.textClient = client
        let id = try XCTUnwrap(sut.pasteSession.begin())
        sut.viewWillDisappear(false)
        sut.pasteSession.complete("late", operationID: id)
        XCTAssertTrue(client.inserted.isEmpty)
        sut.pasteToolbarSuspended = false
        sut.refreshPasteToolbar()
        let second = try XCTUnwrap(sut.pasteSession.begin())
        // Same selector used by the production host notification, with no disappear call.
        sut.perform(
            NSSelectorFromString("extensionHostWillResignActive:"),
            with: Notification(name: .NSExtensionHostWillResignActive))
        sut.pasteSession.complete("late2", operationID: second)
        XCTAssertTrue(client.inserted.isEmpty)
        sut.handleKeyboardDidAppear()
        XCTAssertTrue(client.inserted.isEmpty)
    }

    @MainActor
    func testFailureIsContentFreeAndLeavesTrailingActionEnabled() throws {
        let sut = owner()
        let client = PasteClient()
        sut.controller.textClient = client
        for value: String? in [nil, "", String(repeating: "😀", count: 4_001)] {
            let id = try XCTUnwrap(sut.pasteSession.begin())
            sut.pasteSession.complete(value, operationID: id)
            XCTAssertTrue(sut.pasteSession.pasteFailureVisible)
            let bar = try XCTUnwrap(sut.candidateBar as? CandidateBarView)
            XCTAssertTrue(bar.expandButton.isEnabled)
            XCTAssertFalse(bar.expandButton.isHidden)
            let label = try XCTUnwrap(
                bar.subviews.compactMap { $0 as? UILabel }.first {
                    $0.accessibilityIdentifier == "keyboard.paste.failure"
                })
            XCTAssertEqual(label.text, "无法粘贴纯文本")
            XCTAssertEqual(label.numberOfLines, 1)
        }
        XCTAssertTrue(client.inserted.isEmpty)
    }

    @MainActor
    func testExpansionPathAndPendingRemoveControl() {
        let sut = owner()
        sut.isPinyinPathExpanded = true
        XCTAssertNil(sut.pasteToolbar)
        sut.isPinyinPathExpanded = false
        XCTAssertNotNil(sut.pasteToolbar)
        sut.isCandidateExpanded = true
        XCTAssertNil(sut.pasteToolbar)
        sut.isCandidateExpanded = false
        sut.controller.state.insertedPreeditCount = 1
        sut.refreshPasteToolbar()
        XCTAssertNil(sut.pasteToolbar)
    }

    @MainActor
    func testRecoveryNoticeWinsAndTransitionPanelPreventsInstallation() throws {
        let sut = owner()
        let bar = try XCTUnwrap(sut.candidateBar as? CandidateBarView)
        bar.setInputRecoveryNotice("恢复输入")
        bar.setPasteFailureNotice("无法粘贴纯文本")
        XCTAssertTrue(bar.expandButton.isHidden)
        let failure = try XCTUnwrap(
            bar.subviews.compactMap { $0 as? UILabel }.first { $0.accessibilityIdentifier == "keyboard.paste.failure" })
        XCTAssertTrue(failure.isHidden)
        bar.setInputRecoveryNotice(nil)
        sut.candidateExpandedPanel = UIView()
        XCTAssertNil(sut.pasteToolbar)
        sut.candidateExpandedPanel = nil
        XCTAssertNotNil(sut.pasteToolbar)
    }

    @MainActor
    func testUnsuccessfulProviderShowsFailureWithoutInsertion() throws {
        let sut = owner()
        let client = PasteClient()
        sut.controller.textClient = client
        try XCTUnwrap(sut.pasteToolbar?.receiver).paste(itemProviders: [])
        XCTAssertTrue(sut.pasteSession.pasteFailureVisible)
        XCTAssertTrue(client.inserted.isEmpty)
    }

    @MainActor
    func testPasteDoesNotWritePreferencePayload() throws {
        let sut = owner()
        let defaults = try XCTUnwrap(UserDefaults(suiteName: "CLIPBOARD-002-\(UUID().uuidString)"))
        sut.sharedDefaults = defaults
        defaults.register(defaults: [KeyboardInputSettingsKey.pasteToolbarEnabled: true])
        sut.controller.textClient = PasteClient()
        let before = defaults.dictionaryRepresentation()
        let id = try XCTUnwrap(sut.pasteSession.begin())
        sut.pasteSession.complete("private clipboard text", operationID: id)
        XCTAssertEqual(defaults.dictionaryRepresentation() as NSDictionary, before as NSDictionary)
    }

    @MainActor
    func testBackgroundProviderCompletionAndReleasedReceiver() async throws {
        let sut = owner()
        let client = PasteClient()
        sut.controller.textClient = client
        let gate = PasteProviderGate()
        let provider = NSItemProvider()
        provider.registerObject(ofClass: NSString.self, visibility: .all) { completion in
            Task { await gate.install(completion) }
            return nil
        }
        let receiver = try XCTUnwrap(sut.pasteToolbar?.receiver)
        receiver.paste(itemProviders: [provider])
        for _ in 0..<100 {
            if await gate.hasPending { break }
            try await Task.sleep(for: .milliseconds(10))
        }
        let pending = await gate.hasPending
        XCTAssertTrue(pending)
        await gate.finish("background")
        for _ in 0..<100 where client.inserted.isEmpty {
            try await Task.sleep(for: .milliseconds(10))
        }
        XCTAssertEqual(client.inserted, ["background"])
        XCTAssertEqual(sut.pasteSession.state, .idle)
        weak var released: RetainedPasteReceiver?
        do {
            let transient = RetainedPasteReceiver(session: sut.pasteSession)
            released = transient
            transient.paste(itemProviders: [provider])
        }
        XCTAssertNil(released)
        for _ in 0..<100 {
            if await gate.hasPending { break }
            try await Task.sleep(for: .milliseconds(10))
        }
        await gate.finish("released result")
        try await Task.sleep(for: .milliseconds(50))
        XCTAssertEqual(client.inserted, ["background"])
    }
}

@MainActor
private final class PasteOwner: KeyboardViewController {
    var access = true
    var dismissals = 0
    override var hasFullAccess: Bool { access }
    override func viewDidLoad() {}
    override func dismissKeyboard() { dismissals += 1 }
}

@MainActor
private final class PasteClient: TextInputClient {
    var inserted: [String] = []
    var onInsert: (() -> Void)?
    var hasTextBeforeInput: Bool { false }
    func insertText(_ text: String) { XCTAssertTrue(Thread.isMainThread); inserted.append(text); onInsert?() }
    func deleteBackward() {}
    func adjustTextPosition(byCharacterOffset offset: Int) {}
    func setMarkedText(_ text: String, selectedRange: Range<Int>) {}
    func unmarkText() {}
}

/// The fixture controls both completion time and queue without asking for clipboard permission.
private actor PasteProviderGate {
    private var completion: (@Sendable ((any NSItemProviderWriting)?, (any Error)?) -> Void)?
    var hasPending: Bool { completion != nil }
    func install(_ completion: @escaping @Sendable ((any NSItemProviderWriting)?, (any Error)?) -> Void) {
        self.completion = completion
    }
    func finish(_ text: String) {
        let completion = completion
        self.completion = nil
        DispatchQueue.global().async { completion?(text as NSString, nil) }
    }
}
