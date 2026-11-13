import KeyboardCore
import UIKit
import UniformTypeIdentifiers
import XCTest

@testable import KeyboardCore

/// Real production controller and bar; only engine bootstrap and Full Access are supplied by the fixture.
nonisolated final class PasteToolbarIntegrationTests: XCTestCase {
    @MainActor
    private func owner(
        enabled: Bool = true, access: Bool = true, reader: any ClipboardPreviewReading = PasteTestTextReader()
    ) async -> PasteOwner {
        let owner = PasteOwner()
        owner.access = access
        let defaults = PasteMemoryDefaults()
        defaults.set(enabled, forKey: KeyboardInputSettingsKey.clipboardPreviewEnabled)
        owner.sharedDefaults = defaults
        owner.loadViewIfNeeded()
        owner.controller = KeyboardController()
        owner.pasteSession.previewReader = reader
        owner.controller.textClient = PasteClient()
        owner.cachedPasteToolbarEnabled = enabled
        owner.view.frame = CGRect(x: 0, y: 0, width: 390, height: 288)
        owner.setupRootStack()
        owner.reloadKeyboard()
        owner.isKeyboardUIInstalled = true
        owner.installPasteInputObservation()
        owner.view.layoutIfNeeded()
        owner.rootStack.layoutIfNeeded()
        owner.pasteSession.noteAppearance()
        owner.refreshPasteToolbar()
        for _ in 0..<200 where enabled && access && owner.pastePreviewView == nil {
            try? await Task.sleep(for: .milliseconds(5))
        }
        return owner
    }

    @MainActor
    func testDefaultsAndFullAccessGate() async {
        let disabledReader = CountingPreviewReader()
        let noAccessReader = CountingPreviewReader()
        let disabled = await owner(enabled: false, reader: disabledReader)
        let noAccess = await owner(access: false, reader: noAccessReader)
        let enabled = await owner()
        XCTAssertNil(disabled.pastePreviewView)
        XCTAssertNil(disabled.pastePreviewView)
        XCTAssertEqual(disabledReader.count, 0)
        XCTAssertNil(noAccess.pastePreviewView)
        XCTAssertNil(noAccess.pastePreviewView)
        XCTAssertEqual(noAccessReader.count, 0)
        XCTAssertNotNil(enabled.pastePreviewView)
        XCTAssertEqual(KeyboardInputSettingsKey.pasteToolbarEnabled, "paste_toolbar_enabled")
        XCTAssertEqual(KeyboardInputSettingsKey.clipboardPreviewEnabled, "clipboard_preview_enabled")
    }

    @MainActor
    func testAppearanceAndRepeatedRefreshStartOneReadPerGeneration() async throws {
        let reader = CountingPreviewReader()
        let sut = await owner(reader: reader)
        let baseline = reader.count
        sut.handleKeyboardDidAppear()
        for _ in 0..<100 where reader.count < baseline + 1 { try await Task.sleep(for: .milliseconds(5)) }
        XCTAssertEqual(reader.count, baseline + 1)
        sut.refreshPasteToolbar()
        sut.refreshPasteToolbar()
        try await Task.sleep(for: .milliseconds(30))
        XCTAssertEqual(reader.count, baseline + 1)
        sut.viewWillDisappear(false)
        sut.handleKeyboardDidAppear()
        for _ in 0..<100 where reader.count < baseline + 2 { try await Task.sleep(for: .milliseconds(5)) }
        XCTAssertEqual(reader.count, baseline + 2)
    }

    @MainActor
    func testNewSettingDoesNotMigrateOldSettingAndFailsClosed() async {
        let sut = await owner(enabled: false)
        let defaults = PasteMemoryDefaults()
        sut.sharedDefaults = defaults
        for old in [false, true] {
            for new in [false, true] {
                defaults.set(old, forKey: KeyboardInputSettingsKey.pasteToolbarEnabled)
                defaults.set(new, forKey: KeyboardInputSettingsKey.clipboardPreviewEnabled)
                sut.refreshCachedSettings()
                XCTAssertEqual(sut.cachedPasteToolbarEnabled, new)
            }
        }
        defaults.removeObject(forKey: KeyboardInputSettingsKey.clipboardPreviewEnabled)
        sut.refreshCachedSettings()
        XCTAssertFalse(sut.cachedPasteToolbarEnabled)
        defaults.set("true", forKey: KeyboardInputSettingsKey.clipboardPreviewEnabled)
        sut.refreshCachedSettings()
        XCTAssertFalse(sut.cachedPasteToolbarEnabled)
    }

    @MainActor
    func testFivePagesKeepGeometryAndSeparateHitTargets() async throws {
        let sut = await owner()
        for nineKey in [false, true] {
            sut.cachedLayoutStyle = nineKey ? .nineKey : .twentySixKey
            for page in [KeyboardPage.letters, .numbers, .symbols, .emoji] {
                sut.controller.state.currentPage = page
                sut.reloadKeyboard()
                sut.pasteSession.noteAppearance()
                sut.refreshPasteToolbar()
                for _ in 0..<100 where sut.pastePreviewView == nil { try await Task.sleep(for: .milliseconds(5)) }
                sut.view.layoutIfNeeded()
                sut.rootStack.layoutIfNeeded()
                let toolbar = try XCTUnwrap(sut.pastePreviewView)
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
                let pan = PasteLocationPan()
                pan.testLocation = CGPoint(x: toolbar.frame.minX + 1, y: toolbar.frame.midY)
                XCTAssertFalse(bar.gestureRecognizerShouldBegin(pan))
                pan.testLocation = CGPoint(x: toolbar.frame.maxX - 1, y: toolbar.frame.midY)
                XCTAssertFalse(bar.gestureRecognizerShouldBegin(pan))
                pan.testLocation = CGPoint(x: toolbar.frame.minX - 1, y: toolbar.frame.midY)
                XCTAssertTrue(bar.gestureRecognizerShouldBegin(pan))
                pan.testLocation = CGPoint(x: toolbar.frame.maxX + 1, y: toolbar.frame.midY)
                XCTAssertTrue(bar.gestureRecognizerShouldBegin(pan))
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
    func testSuccessAndSynchronousUnchangedReentryPermitNextPaste() async throws {
        let sut = await owner()
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
        XCTAssertEqual(sut.pasteSession.presentation, .consumedByPaste)
        XCTAssertNil(sut.pastePreviewView)
        XCTAssertNil(sut.pasteSession.begin())
        sut.handleKeyboardDidAppear()
        sut.controller.textClient = client
        let second = try XCTUnwrap(sut.pasteSession.begin())
        sut.pasteSession.complete("丙", operationID: second)
        XCTAssertEqual(client.inserted, ["乙", "丙"])
        XCTAssertEqual(sut.pasteSession.state, .idle)
    }

    @MainActor
    func testReplacementDiscardsOldResult() async throws {
        let sut = await owner()
        let client = PasteClient()
        sut.controller.textClient = client
        let old = try XCTUnwrap(sut.pasteSession.begin())
        let new = try XCTUnwrap(sut.pasteSession.begin())
        sut.pasteSession.complete("old", operationID: old)
        sut.pasteSession.complete("new", operationID: new)
        XCTAssertEqual(client.inserted, ["new"])
    }

    @MainActor
    func testCompositionStartThenCancelNeverReplays() async throws {
        let sut = await owner()
        let client = PasteClient()
        sut.controller.textClient = client
        let id = try XCTUnwrap(sut.pasteSession.begin())
        sut.controller.state.currentComposition = "ni"
        sut.syncUI(with: [])
        XCTAssertNil(sut.pastePreviewView)
        sut.pasteSession.complete("late while composing", operationID: id)
        XCTAssertEqual(sut.controller.state.currentComposition, "ni")
        XCTAssertTrue(client.inserted.isEmpty)
        sut.controller.state.currentComposition = ""
        sut.syncUI(with: [])
        sut.pasteSession.complete("late", operationID: id)
        XCTAssertTrue(client.inserted.isEmpty)
    }

    @MainActor
    func testChangedAndUnavailableInvalidateButInitialAndUnchangedDoNot() async throws {
        let sut = await owner()
        for observation in [KeyboardDocumentIdentityTracker.Observation.initial, .unchanged, .changed, .unavailable] {
            sut.pasteSession.noteAppearance()
            sut.refreshPasteToolbar()
            let client = PasteClient()
            sut.controller.textClient = client
            let id = try XCTUnwrap(sut.pasteSession.begin())
            sut.observePasteDocumentIdentity(observation)
            sut.pasteSession.complete("x", operationID: id)
            XCTAssertEqual(client.inserted.count, observation == .initial || observation == .unchanged ? 1 : 0)
        }
    }

    @MainActor
    func testDisappearAndHostResignInvalidateWithoutReplay() async throws {
        let sut = await owner()
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
        XCTAssertEqual(sut.pasteSession.presentation, .armed)
    }

    @MainActor
    func testFailureIsContentFreeAndLeavesTrailingActionEnabled() async throws {
        let sut = await owner()
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
    func testExpansionPathAndPendingRemoveControl() async {
        let sut = await owner()
        sut.isPinyinPathExpanded = true
        XCTAssertNil(sut.pastePreviewView)
        sut.isPinyinPathExpanded = false
        XCTAssertNil(sut.pastePreviewView, "eligibility loss must not resurrect a read")
        sut.isCandidateExpanded = true
        XCTAssertNil(sut.pastePreviewView)
        sut.isCandidateExpanded = false
        sut.controller.state.insertedPreeditCount = 1
        sut.refreshPasteToolbar()
        XCTAssertNil(sut.pastePreviewView)
    }

    @MainActor
    func testRecoveryNoticeWinsAndTransitionPanelPreventsInstallation() async throws {
        let sut = await owner()
        let bar = try XCTUnwrap(sut.candidateBar as? CandidateBarView)
        bar.setInputRecoveryNotice("恢复输入")
        bar.setPasteFailureNotice("无法粘贴纯文本")
        XCTAssertTrue(bar.expandButton.isHidden)
        let failure = try XCTUnwrap(
            bar.subviews.compactMap { $0 as? UILabel }.first { $0.accessibilityIdentifier == "keyboard.paste.failure" })
        XCTAssertTrue(failure.isHidden)
        bar.setInputRecoveryNotice(nil)
        sut.candidateExpandedPanel = UIView()
        XCTAssertNil(sut.pastePreviewView)
        sut.candidateExpandedPanel = nil
        XCTAssertNil(sut.pastePreviewView, "closing a panel must not resurrect a read")
    }

    @MainActor
    func testPasteDoesNotWritePreferencePayload() async throws {
        let sut = await owner()
        let defaults = PasteMemoryDefaults()
        sut.sharedDefaults = defaults
        defaults.set(true, forKey: KeyboardInputSettingsKey.clipboardPreviewEnabled)
        sut.controller.textClient = PasteClient()
        let before = defaults.dictionaryRepresentation()
        let id = try XCTUnwrap(sut.pasteSession.begin())
        sut.pasteSession.complete("private clipboard text", operationID: id)
        XCTAssertEqual(defaults.dictionaryRepresentation() as NSDictionary, before as NSDictionary)
    }

}

@MainActor
private final class PasteLocationPan: UIPanGestureRecognizer {
    var testLocation = CGPoint.zero

    override func location(in view: UIView?) -> CGPoint { testLocation }
}

@MainActor
final class PasteOwner: KeyboardViewController {
    var access = true
    var dismissals = 0
    override var hasFullAccess: Bool { access }
    override func viewDidLoad() {}
    override func dismissKeyboard() { dismissals += 1 }
}

@MainActor
final class PasteClient: TextInputClient {
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

/// Test-only preferences store; never writes a host preferences domain.
nonisolated final class PasteMemoryDefaults: UserDefaults {
    private let lock = NSLock()
    private var values: [String: Any] = [:]

    override func object(forKey defaultName: String) -> Any? {
        lock.lock()
        defer { lock.unlock() }
        return values[defaultName]
    }

    override func set(_ value: Any?, forKey defaultName: String) {
        lock.lock()
        values[defaultName] = value
        lock.unlock()
    }

    override func set(_ value: Bool, forKey defaultName: String) { set(value as Any, forKey: defaultName) }
    override func set(_ value: Int, forKey defaultName: String) { set(value as Any, forKey: defaultName) }
    override func set(_ value: Double, forKey defaultName: String) { set(value as Any, forKey: defaultName) }
    override func set(_ value: Float, forKey defaultName: String) { set(value as Any, forKey: defaultName) }
    override func bool(forKey defaultName: String) -> Bool { object(forKey: defaultName) as? Bool ?? false }
    override func integer(forKey defaultName: String) -> Int { object(forKey: defaultName) as? Int ?? 0 }
    override func double(forKey defaultName: String) -> Double { object(forKey: defaultName) as? Double ?? 0 }
    override func float(forKey defaultName: String) -> Float { object(forKey: defaultName) as? Float ?? 0 }
    override func register(defaults registrationDictionary: [String: Any]) {
        lock.lock()
        for (key, value) in registrationDictionary where values[key] == nil { values[key] = value }
        lock.unlock()
    }

    override func removeObject(forKey defaultName: String) {
        lock.lock()
        values.removeValue(forKey: defaultName)
        lock.unlock()
    }

    override func dictionaryRepresentation() -> [String: Any] {
        lock.lock()
        defer { lock.unlock() }
        return values
    }
}

private nonisolated struct PasteTestTextReader: ClipboardPreviewReading {
    func read() -> ClipboardPreviewResult { .text(full: "test", summary: "test", isLink: false) }
}
