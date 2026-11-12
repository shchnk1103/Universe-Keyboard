import Foundation
import KeyboardCore
import UIKit
import XCTest

nonisolated final class ClipboardPreviewTests: XCTestCase {
    func testEmptyAndOversizedContent() {
        XCTAssertEqual(ClipboardPreviewFormatter.makeResult(" \n"), .unavailable)
        let long = String(repeating: "a", count: 8_001)
        guard case .oversized(let summary, let length, _) = ClipboardPreviewFormatter.makeResult(long) else {
            return XCTFail("Expected oversized result")
        }
        XCTAssertEqual(length, 8_001)
        XCTAssertLessThanOrEqual(summary.count, 64)
    }

    @MainActor
    func testIneligibleAndConsumedSessionsNeverStartReader() async throws {
        let reader = CountingPreviewReader()
        let session = PasteToolbarSession()
        session.previewReader = reader
        session.isEligible = { false }
        session.noteAppearance()
        session.startPreviewIfNeeded()
        session.isEligible = { true }
        session.noteCountedInput()
        session.startPreviewIfNeeded()
        try await Task.sleep(for: .milliseconds(30))
        XCTAssertEqual(reader.count, 0)
    }

    @MainActor
    func testDeniedDoesNotRetryUntilNextAppearance() async throws {
        let reader = CountingPreviewReader()
        let session = PasteToolbarSession()
        session.previewReader = reader
        session.isEligible = { true }
        session.noteAppearance()
        session.startPreviewIfNeeded()
        for _ in 0..<100 where session.preview == .reading {
            try await Task.sleep(for: .milliseconds(2))
        }
        XCTAssertTrue(session.deniedThisAppearance)
        XCTAssertFalse(reader.ranOnMainThread)
        XCTAssertEqual(session.preview, .unavailable)
        session.didInstallPreview()
        session.noteHostResign()
        session.noteHostBecomeActive()
        session.startPreviewIfNeeded()
        try await Task.sleep(for: .milliseconds(30))
        XCTAssertEqual(reader.count, 1)
        session.noteAppearance()
        session.startPreviewIfNeeded()
        for _ in 0..<100 where session.preview == .reading {
            try await Task.sleep(for: .milliseconds(2))
        }
        XCTAssertEqual(reader.count, 2)
    }

    @MainActor
    func testSessionReadsOnlyOnceAndDiscardsLateResult() async throws {
        let reader = BlockingPreviewReader()
        let session = PasteToolbarSession()
        session.isEligible = { true }
        session.previewReader = reader
        session.noteAppearance()
        session.startPreviewIfNeeded()
        session.startPreviewIfNeeded()
        XCTAssertEqual(session.preview, .reading)
        try await Task.sleep(for: .milliseconds(650))
        XCTAssertEqual(session.preview, .unavailable)
        reader.release.signal()
        try await Task.sleep(for: .milliseconds(50))
        XCTAssertEqual(session.preview, .unavailable)
        XCTAssertEqual(reader.count, 1)
    }

    @MainActor
    func testSuspendedResultIsDiscardedBeforeResume() async throws {
        let reader = BlockingPreviewReader()
        let session = PasteToolbarSession()
        session.isEligible = { true }
        session.previewReader = reader
        session.noteAppearance()
        session.startPreviewIfNeeded()
        XCTAssertEqual(reader.started.wait(timeout: .now() + 2), .success)
        session.noteHostResign()
        reader.release.signal()
        for _ in 0..<100 where session.preview == .reading {
            try await Task.sleep(for: .milliseconds(2))
        }
        XCTAssertEqual(session.preview, .unavailable)
        let generation = session.generation
        session.noteHostBecomeActive()
        XCTAssertEqual(session.generation, generation)
        XCTAssertEqual(session.preview, .unavailable)
        XCTAssertEqual(reader.count, 1)
    }

    @MainActor
    func testDeniedDuringSuspensionPreventsLaterRetry() async throws {
        let reader = BlockingPreviewReader(result: .denied)
        let session = PasteToolbarSession()
        session.isEligible = { true }
        session.previewReader = reader
        session.noteAppearance()
        session.startPreviewIfNeeded()
        XCTAssertEqual(reader.started.wait(timeout: .now() + 2), .success)
        session.noteHostResign()
        reader.release.signal()
        for _ in 0..<100 where session.preview == .reading {
            try await Task.sleep(for: .milliseconds(2))
        }
        XCTAssertTrue(session.deniedThisAppearance)
        session.noteHostBecomeActive()
        session.didInstallPreview()
        session.noteHostResign()
        session.noteHostBecomeActive()
        session.startPreviewIfNeeded()
        try await Task.sleep(for: .milliseconds(30))
        XCTAssertEqual(reader.count, 1)
        XCTAssertEqual(session.preview, .unavailable)
    }

    @MainActor
    func testReadyBeforeSuspensionExpiresBeforeResume() async throws {
        let reader = BlockingPreviewReader()
        let session = PasteToolbarSession()
        session.isEligible = { true }
        session.previewReader = reader
        session.noteAppearance()
        session.startPreviewIfNeeded()
        XCTAssertEqual(reader.started.wait(timeout: .now() + 2), .success)
        reader.release.signal()
        for _ in 0..<100 where session.preview == .reading {
            try await Task.sleep(for: .milliseconds(2))
        }
        guard case .ready = session.preview else { return XCTFail("Expected ready") }
        session.noteHostResign()
        try await Task.sleep(for: .milliseconds(550))
        session.noteHostBecomeActive()
        XCTAssertEqual(session.preview, .unavailable)
        XCTAssertEqual(reader.count, 1)
    }

    @MainActor
    func testReadyBeforeSuspensionResumesWithinDeadline() async throws {
        let reader = BlockingPreviewReader()
        let session = PasteToolbarSession()
        session.isEligible = { true }
        session.previewReader = reader
        session.noteAppearance()
        session.startPreviewIfNeeded()
        XCTAssertEqual(reader.started.wait(timeout: .now() + 2), .success)
        reader.release.signal()
        for _ in 0..<100 where session.preview == .reading {
            try await Task.sleep(for: .milliseconds(2))
        }
        guard case .ready = session.preview else { return XCTFail("Expected ready") }
        let generation = session.generation
        session.noteHostResign()
        session.noteHostBecomeActive()
        guard case .ready = session.preview else { return XCTFail("Expected retained preview") }
        XCTAssertEqual(session.generation, generation)
        XCTAssertEqual(reader.count, 1)
    }

    @MainActor
    func testGenerationChangeDiscardsSuspendedReadyModel() async throws {
        for afterDeadline in [false, true] {
            let reader = BlockingPreviewReader()
            let session = PasteToolbarSession()
            session.isEligible = { true }
            session.previewReader = reader
            session.noteAppearance()
            session.startPreviewIfNeeded()
            XCTAssertEqual(reader.started.wait(timeout: .now() + 2), .success)
            reader.release.signal()
            for _ in 0..<100 where session.preview == .reading {
                try await Task.sleep(for: .milliseconds(2))
            }
            guard case .ready = session.preview else { return XCTFail("Expected ready") }
            session.noteHostResign()
            if afterDeadline { try await Task.sleep(for: .milliseconds(550)) }
            let oldGeneration = session.generation
            session.noteAppearance()
            session.noteHostBecomeActive()
            XCTAssertEqual(session.generation, oldGeneration + 1)
            XCTAssertEqual(session.preview, .notRead)
        }
    }

    @MainActor
    func testInputCancelsInFlightPreview() async throws {
        let reader = BlockingPreviewReader()
        let session = PasteToolbarSession()
        session.isEligible = { true }
        session.previewReader = reader
        session.noteAppearance()
        session.startPreviewIfNeeded()
        XCTAssertEqual(reader.started.wait(timeout: .now() + 2), .success)
        session.noteCountedInput()
        reader.release.signal()
        try await Task.sleep(for: .milliseconds(30))
        XCTAssertEqual(session.presentation, .consumedByInput)
        XCTAssertEqual(session.preview, .unavailable)
    }

    @MainActor
    func testTimeoutReleasesLogicalSlotForNextAppearance() async throws {
        let old = BlockingPreviewReader()
        let next = CountingPreviewReader()
        let session = PasteToolbarSession()
        session.isEligible = { true }
        session.previewReader = old
        session.noteAppearance()
        session.startPreviewIfNeeded()
        XCTAssertEqual(old.started.wait(timeout: .now() + 2), .success)
        try await Task.sleep(for: .milliseconds(550))
        XCTAssertEqual(session.preview, .unavailable)
        session.noteAppearance()
        session.previewReader = next
        session.startPreviewIfNeeded()
        old.release.signal()
        for _ in 0..<100 where session.preview == .reading {
            try await Task.sleep(for: .milliseconds(2))
        }
        XCTAssertEqual(next.count, 1)
        XCTAssertEqual(session.preview, .unavailable)
        XCTAssertEqual(old.count, 1)
    }

    @MainActor
    func testOldGenerationResultCannotReplaceNewGeneration() async throws {
        let old = BlockingPreviewReader()
        let session = PasteToolbarSession()
        session.previewReader = old
        session.isEligible = { true }
        session.noteAppearance()
        session.startPreviewIfNeeded()
        XCTAssertEqual(old.started.wait(timeout: .now() + 2), .success)
        session.noteAppearance()
        session.previewReader = FixedPreviewReader(result: .text(full: "new", summary: "new", isLink: false))
        session.startPreviewIfNeeded()
        old.release.signal()
        for _ in 0..<100 where session.preview == .reading {
            try await Task.sleep(for: .milliseconds(2))
        }
        XCTAssertEqual(session.preview, .ready(.text(full: "new", summary: "new", isLink: false)))
        XCTAssertEqual(old.count, 1)
    }

    func testQueuedWorkerChecksCancelledGateBeforeReading() {
        let first = BlockingPreviewReader()
        let second = BlockingPreviewReader()
        defer { first.release.signal(); second.release.signal() }
        let completed = expectation(description: "queue drained")
        let deadline = DispatchTime.now().uptimeNanoseconds + 5_000_000_000
        let firstGate = ClipboardPreviewGate(deadline: deadline)
        let secondGate = ClipboardPreviewGate(deadline: deadline)
        let lastGate = ClipboardPreviewGate(deadline: deadline)
        ClipboardPreviewWorker.shared.submit(reader: first, gate: firstGate) { _ in }
        XCTAssertEqual(first.started.wait(timeout: .now() + 2), .success)
        ClipboardPreviewWorker.shared.submit(reader: second, gate: secondGate) { _ in
            XCTFail("Cancelled reader must not return")
        }
        secondGate.cancel()
        ClipboardPreviewWorker.shared.submit(reader: ImmediatePreviewReader(), gate: lastGate) { _ in
            completed.fulfill()
        }
        first.release.signal()
        wait(for: [completed], timeout: 3)
        XCTAssertEqual(second.count, 0)
    }

    @MainActor
    func testQueuedReadIsRevokedByOffAccessLossOrNewGeneration() async {
        for scenario in 0..<3 {
            let blocker = BlockingPreviewReader()
            let deadline = DispatchTime.now().uptimeNanoseconds + 3_000_000_000
            ClipboardPreviewWorker.shared.submit(reader: blocker, gate: ClipboardPreviewGate(deadline: deadline)) { _ in
            }
            XCTAssertEqual(blocker.started.wait(timeout: .now() + 2), .success)
            let candidate = CountingPreviewReader()
            let owner = await pendingOwner(reader: candidate)
            switch scenario {
            case 0:
                owner.cachedPasteToolbarEnabled = false
                owner.refreshPasteToolbar()
            case 1:
                owner.access = false
                owner.refreshPasteToolbar()
            default:
                owner.pasteSession.noteAppearance()
            }
            let drained = DispatchSemaphore(value: 0)
            ClipboardPreviewWorker.shared.submit(
                reader: ImmediatePreviewReader(), gate: ClipboardPreviewGate(deadline: deadline)
            ) { _ in drained.signal() }
            blocker.release.signal()
            XCTAssertEqual(drained.wait(timeout: .now() + 2), .success)
            XCTAssertEqual(candidate.count, 0)
        }
    }

    @MainActor
    func testSuspendedReturnRechecksEligibilityBeforeInstalling() async throws {
        for scenario in 0..<6 {
            let afterDeadline = scenario >= 3
            let reader = BlockingPreviewReader()
            let owner = await pendingOwner(reader: reader)
            XCTAssertEqual(reader.started.wait(timeout: .now() + 2), .success)
            owner.pasteToolbarSuspended = true
            owner.pasteSession.noteHostResign()
            owner.refreshPasteToolbar()
            reader.release.signal()
            for _ in 0..<100 where owner.pasteSession.preview == .reading {
                try await Task.sleep(for: .milliseconds(2))
            }
            if afterDeadline { try await Task.sleep(for: .milliseconds(550)) }
            switch scenario % 3 {
            case 0: owner.cachedPasteToolbarEnabled = false
            case 1: owner.access = false
            default: owner.pasteSession.noteCountedInput()
            }
            owner.pasteToolbarSuspended = false
            owner.pasteSession.noteHostBecomeActive()
            owner.refreshPasteToolbar()
            XCTAssertNil(owner.pasteToolbar)
            XCTAssertNil(owner.pastePreviewView)
            XCTAssertEqual(reader.count, 1)
        }
    }

    @MainActor
    private func pendingOwner(reader: any ClipboardPreviewReading) async -> PasteOwner {
        let owner = PasteOwner()
        let defaults = PasteMemoryDefaults()
        defaults.set(true, forKey: KeyboardInputSettingsKey.clipboardPreviewEnabled)
        owner.sharedDefaults = defaults
        owner.access = true
        owner.loadViewIfNeeded()
        owner.controller = KeyboardController()
        owner.controller.textClient = PasteClient()
        owner.pasteSession.previewReader = reader
        owner.cachedPasteToolbarEnabled = true
        owner.view.frame = CGRect(x: 0, y: 0, width: 390, height: 288)
        owner.setupRootStack()
        owner.reloadKeyboard()
        owner.isKeyboardUIInstalled = true
        owner.installPasteInputObservation()
        owner.view.layoutIfNeeded()
        owner.pasteSession.noteAppearance()
        owner.refreshPasteToolbar()
        return owner
    }

    @MainActor
    func testPreviewTapCommitsFullTextButNotSummary() async throws {
        let result = ClipboardPreviewResult.text(full: "original clipboard", summary: "original", isLink: false)
        let (owner, client, defaults) = await previewOwner(result: result)
        var commitEvents = 0
        owner.controller.onCommittedText = { _ in commitEvents += 1 }
        XCTAssertTrue(owner.controller.state.continuation.context.isEmpty)
        XCTAssertTrue(owner.controller.state.continuation.suggestions.isEmpty)
        let before = defaults.dictionaryRepresentation() as NSDictionary
        XCTAssertTrue(owner.isPasteToolbarEligible, "eligibility")
        XCTAssertNil(owner.pasteToolbar, "unexpected system fallback")
        if case .ready = owner.pasteSession.preview {} else { XCTFail("preview state was not ready") }
        let view = try XCTUnwrap(owner.pastePreviewView)
        XCTAssertEqual(view.actions(forTarget: owner, forControlEvent: .touchUpInside), ["pastePreviewTapped"])
        XCTAssertTrue(view.isEnabled)
        owner.view.layoutIfNeeded()
        let bar = try XCTUnwrap(owner.candidateBar as? CandidateBarView)
        bar.layoutIfNeeded()
        let hit = bar.hitTest(CGPoint(x: view.frame.midX, y: view.frame.midY), with: nil)
        XCTAssertTrue(hit === view || hit?.isDescendant(of: view) == true)
        XCTAssertGreaterThanOrEqual(view.frame.height, 44)
        // The unhosted target does not dispatch UIControl actions; invoke its registered selector.
        owner.perform(NSSelectorFromString("pastePreviewTapped"))
        XCTAssertEqual(client.inserted, ["original clipboard"])
        XCTAssertEqual(owner.pasteSession.presentation, .consumedByPaste)
        XCTAssertTrue(owner.controller.state.continuation.context.isEmpty)
        XCTAssertTrue(owner.controller.state.continuation.suggestions.isEmpty)
        XCTAssertEqual(commitEvents, 0)
        XCTAssertEqual(defaults.dictionaryRepresentation() as NSDictionary, before)
    }

    @MainActor
    func testOversizedPreviewTapShowsFailureWithoutCommit() async throws {
        let result = ClipboardPreviewResult.oversized(summary: "••••••（8001 字）", utf16Length: 8_001, isLink: false)
        let (owner, client, _) = await previewOwner(result: result)
        XCTAssertTrue(owner.isPasteToolbarEligible, "eligibility")
        XCTAssertNil(owner.pasteToolbar, "unexpected system fallback")
        if case .ready = owner.pasteSession.preview {} else { XCTFail("preview state was not ready") }
        let view = try XCTUnwrap(owner.pastePreviewView)
        XCTAssertEqual(view.actions(forTarget: owner, forControlEvent: .touchUpInside), ["pastePreviewTapped"])
        XCTAssertTrue(view.isEnabled)
        owner.view.layoutIfNeeded()
        let bar = try XCTUnwrap(owner.candidateBar as? CandidateBarView)
        bar.layoutIfNeeded()
        let hit = bar.hitTest(CGPoint(x: view.frame.midX, y: view.frame.midY), with: nil)
        XCTAssertTrue(hit === view || hit?.isDescendant(of: view) == true)
        XCTAssertGreaterThanOrEqual(view.frame.height, 44)
        // The unhosted target does not dispatch UIControl actions; invoke its registered selector.
        owner.perform(NSSelectorFromString("pastePreviewTapped"))
        XCTAssertTrue(owner.pasteSession.pasteFailureVisible)
        XCTAssertEqual(owner.pasteSession.presentation, .armed)
        XCTAssertTrue(client.inserted.isEmpty)
    }

    @MainActor
    private func previewOwner(result: ClipboardPreviewResult) async -> (PasteOwner, PasteClient, PasteMemoryDefaults) {
        let owner = PasteOwner()
        let defaults = PasteMemoryDefaults()
        defaults.set(true, forKey: KeyboardInputSettingsKey.clipboardPreviewEnabled)
        owner.sharedDefaults = defaults
        owner.access = true
        owner.loadViewIfNeeded()
        owner.controller = KeyboardController()
        let client = PasteClient()
        owner.controller.textClient = client
        owner.pasteSession.previewReader = FixedPreviewReader(result: result)
        owner.cachedPasteToolbarEnabled = true
        owner.view.frame = CGRect(x: 0, y: 0, width: 390, height: 288)
        owner.setupRootStack()
        owner.reloadKeyboard()
        owner.isKeyboardUIInstalled = true
        owner.installPasteInputObservation()
        owner.view.layoutIfNeeded()
        owner.pasteSession.noteAppearance()
        owner.refreshPasteToolbar()
        for _ in 0..<200 where owner.pastePreviewView == nil {
            try? await Task.sleep(for: .milliseconds(5))
        }
        return (owner, client, defaults)
    }

    @MainActor
    func testPreviewAppearanceAndAccessibleHitArea() {
        let view = PastePreviewView(summary: "example.com/path", isLink: true)
        view.frame = CGRect(x: 0, y: 0, width: 300, height: 46)
        view.layoutIfNeeded()
        XCTAssertTrue(view.fitsCandidateBar)
        XCTAssertGreaterThanOrEqual(view.bounds.height, 44)
        XCTAssertTrue(view.accessibilityTraits.contains(.button))
        XCTAssertEqual(view.accessibilityLabel, "粘贴，example.com/path")
        let stack = view.subviews.compactMap { $0 as? UIStackView }.first
        let labels = stack?.arrangedSubviews.compactMap { $0 as? UILabel } ?? []
        XCTAssertEqual(labels.count, 2)
        XCTAssertEqual(labels.first?.text, "example.com/path")
        XCTAssertEqual(labels.last?.text, "点按粘贴链接")
        XCTAssertEqual(labels.first?.font.pointSize ?? 0, 15, accuracy: 0.1)
        XCTAssertEqual(labels.last?.font.pointSize ?? 0, 12, accuracy: 0.1)
        for style in [UIUserInterfaceStyle.light, .dark] {
            let traits = UITraitCollection(userInterfaceStyle: style)
            XCTAssertEqual(
                labels.first?.textColor.resolvedColor(with: traits), UIColor.label.resolvedColor(with: traits))
            XCTAssertEqual(
                labels.last?.textColor.resolvedColor(with: traits),
                KeyboardDesignTokens.CandidateActionAppearance.symbolColor.resolvedColor(with: traits))
        }
    }

    @MainActor
    func testLargeDynamicTypeSignalsFallback() async throws {
        let view = PastePreviewView(summary: "example", isLink: false)
        let controller = UIViewController()
        controller.loadViewIfNeeded()
        controller.view.addSubview(view)
        var fellBack = false
        view.onCannotFit = { fellBack = true }
        view.traitOverrides.preferredContentSizeCategory = .accessibilityExtraExtraExtraLarge
        view.updateTraitsIfNeeded()
        controller.view.layoutIfNeeded()
        for _ in 0..<50 where !fellBack { try await Task.sleep(for: .milliseconds(2)) }
        XCTAssertFalse(view.fitsCandidateBar)
        XCTAssertTrue(fellBack)
        XCTAssertEqual(view.accessibilityLabel, "粘贴，example")
    }

    @MainActor
    func testDynamicTypeFallbackInstallsAccessibleSystemControl() async throws {
        let result = ClipboardPreviewResult.text(full: "example", summary: "example", isLink: false)
        let (owner, _, _) = await previewOwner(result: result)
        let view = try XCTUnwrap(owner.pastePreviewView)
        view.traitOverrides.preferredContentSizeCategory = .accessibilityExtraExtraExtraLarge
        view.updateTraitsIfNeeded()
        owner.view.layoutIfNeeded()
        for _ in 0..<50 where owner.pasteToolbar == nil { try await Task.sleep(for: .milliseconds(2)) }
        let systemControl = try XCTUnwrap(owner.pasteToolbar)
        XCTAssertNil(owner.pastePreviewView)
        XCTAssertEqual(systemControl.control.accessibilityLabel, "粘贴，example")
        XCTAssertEqual(owner.pasteSession.preview, .unavailable)
    }

    func testSensitiveValuesAreMaskedAndURLsLoseQuery() {
        let values = ["4532.0151.2345.6781", "-----BEGIN PRIVATE KEY-----", "MeetingNotes2026Q4BudgetReviewFinal"]
        for value in values {
            guard case .text(_, let summary, _) = ClipboardPreviewFormatter.makeResult(value) else {
                return XCTFail("Expected a preview")
            }
            XCTAssertTrue(summary.hasPrefix("••••••"))
        }
        let url = "https://example.com/path?secret=hidden#fragment"
        guard case .text(let original, let summary, _) = ClipboardPreviewFormatter.makeResult(url) else {
            return XCTFail("Expected a preview")
        }
        XCTAssertEqual(original, url)
        XCTAssertEqual(summary, "example.com/path")
    }

    func testOrdinarySamplesRemainReadable() {
        let examples = [
            "iPhone15ProMax", "COVID-19", "MacBookPro2024", "Universe-Keyboard-2026", "user@example.com",
            "12345678901", "482913", "明天下午 3 点在 B2 会议室", "https://github.com/org/repo/pull/2",
            "https://www.example.com/learn?ignored=1", "Wi-Fi6E", "AirPods Pro 2", "2026-11-10",
            "SN: ABC123", "akia" + String(repeating: "a", count: 15) + "1",
        ]
        for (index, text) in examples.enumerated() {
            guard case .text(_, let summary, _) = ClipboardPreviewFormatter.makeResult(text) else {
                return XCTFail("Expected preview for sample \(index)")
            }
            XCTAssertFalse(summary.hasPrefix("••••••"), "ordinary sample \(index)")
        }
    }

    func testSummaryMasksSensitiveTokensBeforeTruncation() {
        let jwt =
            String(repeating: "a", count: 12) + "." + String(repeating: "b", count: 12) + "."
            + String(repeating: "c", count: 12)
        let mixed = "Ab1!" + "Ab1!" + "z"
        let alternating = String(repeating: "a1", count: 10)
        let identifier = "AKIA" + String(repeating: "A", count: 16)
        for text in [jwt, mixed, alternating, identifier, String(repeating: "a", count: 40) + "1"] {
            guard case .text(_, let summary, _) = ClipboardPreviewFormatter.makeResult(text) else {
                return XCTFail("Expected text")
            }
            XCTAssertTrue(summary.hasPrefix("••••••"))
            XCTAssertLessThanOrEqual(summary.count, 64)
        }
        let url = "https://www.example.com/reset/" + identifier + "?hidden=1#hidden"
        guard case .text(_, let summary, let isLink) = ClipboardPreviewFormatter.makeResult(url) else {
            return XCTFail("Expected URL")
        }
        XCTAssertTrue(isLink)
        XCTAssertEqual(summary, "example.com/reset/…")
    }
}

private nonisolated final class BlockingPreviewReader: ClipboardPreviewReading, @unchecked Sendable {
    let release = DispatchSemaphore(value: 0)
    let started = DispatchSemaphore(value: 0)
    private let lock = NSLock()
    private var reads = 0
    private let result: ClipboardPreviewResult

    init(result: ClipboardPreviewResult = .text(full: "hello", summary: "hello", isLink: false)) {
        self.result = result
    }

    var count: Int {
        lock.lock()
        defer { lock.unlock() }
        return reads
    }

    func read() -> ClipboardPreviewResult {
        lock.lock()
        reads += 1
        lock.unlock()
        started.signal()
        release.wait()
        return result
    }
}

nonisolated struct ImmediatePreviewReader: ClipboardPreviewReading {
    func read() -> ClipboardPreviewResult { .unavailable }
}

private nonisolated struct FixedPreviewReader: ClipboardPreviewReading {
    let result: ClipboardPreviewResult
    func read() -> ClipboardPreviewResult { result }
}

nonisolated final class CountingPreviewReader: ClipboardPreviewReading, @unchecked Sendable {
    private let lock = NSLock()
    private var reads = 0
    private var mainThread = false
    var ranOnMainThread: Bool {
        lock.lock()
        defer { lock.unlock() }
        return mainThread
    }
    var count: Int {
        lock.lock()
        defer { lock.unlock() }
        return reads
    }
    func read() -> ClipboardPreviewResult {
        lock.lock()
        reads += 1
        mainThread = Thread.isMainThread
        lock.unlock()
        return .denied
    }
}
