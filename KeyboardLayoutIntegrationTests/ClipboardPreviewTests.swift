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
    func testPreviouslyAllowedTextThenDeniedResult() async throws {
        let session = PasteToolbarSession()
        session.isEligible = { true }
        session.previewReader = FixedPreviewReader(result: .text(full: "old", summary: "old", isLink: false))
        session.noteAppearance()
        session.startPreviewIfNeeded()
        for _ in 0..<100 where session.preview == .reading {
            try await Task.sleep(for: .milliseconds(2))
        }
        XCTAssertEqual(session.preview, .ready(.text(full: "old", summary: "old", isLink: false)))
        session.didInstallPreview()
        session.noteHostResign()
        session.noteHostBecomeActive()
        let denied = CountingPreviewReader()
        session.previewReader = denied
        session.startPreviewIfNeeded()
        for _ in 0..<100 where session.preview == .reading {
            try await Task.sleep(for: .milliseconds(2))
        }
        XCTAssertEqual(session.preview, .unavailable)
        XCTAssertTrue(session.deniedThisAppearance)
        XCTAssertEqual(denied.count, 1)
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
    func testSuspendedResultWaitsUntilResume() async throws {
        let reader = BlockingPreviewReader()
        let session = PasteToolbarSession()
        session.isEligible = { true }
        session.previewReader = reader
        session.noteAppearance()
        session.startPreviewIfNeeded()
        await waitForReadStarted(reader)
        session.noteHostResign()
        reader.release.signal()
        try await Task.sleep(for: .milliseconds(30))
        XCTAssertEqual(session.preview, .reading)
        let generation = session.generation
        session.noteHostBecomeActive()
        XCTAssertEqual(session.generation, generation)
        XCTAssertEqual(session.preview, .ready(.text(full: "hello", summary: "hello", isLink: false)))
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
        await waitForReadStarted(reader)
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
        await waitForReadStarted(reader)
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
        await waitForReadStarted(reader)
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
            await waitForReadStarted(reader)
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
        await waitForReadStarted(reader)
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
        await waitForReadStarted(old)
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
        await waitForReadStarted(old)
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
            await waitForReadStarted(reader)
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
            XCTAssertNil(owner.pastePreviewView)
            XCTAssertEqual(reader.count, 1)
        }
    }

    @MainActor
    func testOnlyUserInitiatedNonCountingActionsDiscardReadingPreview() {
        let path = T9PinyinPath(displayText: "a", replacementRawInput: "a")
        let correction = TypoCorrectionCommit(
            committedText: "字",
            originalInput: "zi",
            correctedInput: "zi",
            edits: []
        )
        let samples: [KeyboardAction] = [
            .insertKey("a"),
            .insertCandidate("词", kind: .candidate),
            .insertCorrectionCandidate(correction),
            .insertDirectText("“"),
            .insertT9NumberPadText("1"),
            .insertEmoji("😀"),
            .toggleShift,
            .togglePage,
            .toggleInputMode,
            .insertSpace,
            .insertReturn,
            .deleteBackward,
            .keyboardTypeChanged(.default),
            .candidatePageUp,
            .candidatePageDown,
            .selectT9PinyinPath(path),
            .cycleT9PinyinPath,
            .pressT9CommonPunctuation,
            .pressKaomoji,
        ]
        for action in samples {
            let expected: Bool
            switch action {
            case .toggleShift, .togglePage, .toggleInputMode, .candidatePageUp, .candidatePageDown:
                expected = true
            case .keyboardTypeChanged, .insertKey, .insertCandidate, .insertCorrectionCandidate,
                .insertDirectText, .insertT9NumberPadText, .insertEmoji, .insertSpace, .insertReturn, .deleteBackward,
                .selectT9PinyinPath, .cycleT9PinyinPath, .pressT9CommonPunctuation, .pressKaomoji:
                expected = false
            }
            XCTAssertEqual(pasteDiscardsReadingPreview(action), expected, "\(action)")
            XCTAssertFalse(
                pasteDiscardsReadingPreview(action) && pastePresentationCounts(action), "\(action)")
        }
        XCTAssertFalse(pasteDiscardsReadingPreview(.keyboardTypeChanged(.default)))
        XCTAssertFalse(pasteDiscardsReadingPreview(.keyboardTypeChanged(.URL)))
        XCTAssertTrue(pasteDiscardsReadingPreview(.toggleShift))
    }

    @MainActor
    func testHostKeyboardTypeCallbackKeepsReadingPreview() async throws {
        let reader = BlockingPreviewReader()
        let owner = await pendingOwner(reader: reader)
        await waitForReadStarted(reader)
        _ = owner.controller.handle(.keyboardTypeChanged(.default))
        _ = owner.controller.handle(.keyboardTypeChanged(.URL))
        XCTAssertEqual(owner.pasteSession.preview, .reading)
        _ = owner.controller.handle(.toggleShift)
        XCTAssertNotEqual(owner.pasteSession.preview, .reading)
        reader.release.signal()
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
    private func previewOwner(
        result: ClipboardPreviewResult, largeText: Bool = false
    ) async -> (PasteOwner, PasteClient, PasteMemoryDefaults) {
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
        if largeText, let bar = owner.candidateBar as? CandidateBarView {
            bar.traitOverrides.preferredContentSizeCategory = .accessibilityExtraExtraExtraLarge
            bar.updateTraitsIfNeeded()
        }
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
    func testT78InitialLargeTextDoesNotInstallPreview() async {
        let result = ClipboardPreviewResult.text(full: "example", summary: "example", isLink: false)
        let (owner, _, _) = await previewOwner(result: result, largeText: true)
        XCTAssertNil(owner.pastePreviewView)
        XCTAssertEqual(owner.pasteSession.preview, .unavailable)
        XCTAssertEqual(owner.pasteSession.presentation, .armed)
        owner.refreshPasteToolbar()
        XCTAssertNil(owner.pastePreviewView)
    }

    @MainActor
    func testT79DynamicTypeRemovalDoesNotInstallFallback() async throws {
        let result = ClipboardPreviewResult.text(full: "example", summary: "example", isLink: false)
        let (owner, _, _) = await previewOwner(result: result)
        let view = try XCTUnwrap(owner.pastePreviewView)
        view.traitOverrides.preferredContentSizeCategory = .accessibilityExtraExtraExtraLarge
        view.updateTraitsIfNeeded()
        owner.view.layoutIfNeeded()
        for _ in 0..<50 where owner.pastePreviewView != nil { try await Task.sleep(for: .milliseconds(2)) }
        XCTAssertNil(owner.pastePreviewView)
        XCTAssertEqual(owner.pasteSession.preview, .unavailable)
        XCTAssertEqual(owner.pasteSession.presentation, .armed)
        owner.refreshPasteToolbar()
        XCTAssertNil(owner.pastePreviewView)
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

    func testFrozenMaskVectors() {
        let vectors: [(String, String)] = [
            ("P1", "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxMjM0NTY3ODkwIn0.dozjgNryP4J3jVmNHl0w5N_XgL0n3I9PlFUP0THsR8U"),
            ("P2", "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASC\n-----END PRIVATE KEY-----"),
            ("P3", "sk-proj-4fT9xQ2mL8vR1zK7pW3n"),
            ("P4", "3f2a9c1e7b4d8f6a0c5e2b9d7f1a3c8e6b4d2f0a"),
            ("P5", "4111 1111 1111 1111"),
            ("P6", "6222-0212-3456-7890"),
            ("P7", "Tr0ub4dor&3"),
            ("P8", "我的 token 是 ghp_16C7e42F292c6912E7710c838347Ae178B4a 别外传"),
            ("P9", "https://example.com/reset/a8F3kQ9zL2xW7mN4pR6tY1vB"),
            ("P10", "6217002710000684874"),
            ("N1", "iPhone15ProMax"),
            ("N2", "COVID-19"),
            ("N3", "MacBookPro2024"),
            ("N4", "Universe-Keyboard-2026"),
            ("N5", "user@example.com"),
            ("N6", "13800138000"),
            ("N7", "482913"),
            ("N8", "明天下午 3 点在 B2 会议室"),
            ("N9", "https://github.com/shchnk1103/UniverseWeb/pull/2"),
            ("N10", "https://www.zh-hans.react.dev/learn?x=1"),
            ("N11", "Wi-Fi6E"),
            ("N12", "AirPods Pro 2"),
            ("N13", "2026-11-10"),
            ("N14", "SN: F2LXK0ABHG7F"),
            ("P11", "AKIAIOSFODNN7EXAMPLE"),
            ("P12", "4532.0151.2345.6781"),
            ("P13", "https://example.com/AKIAIOSFODNN7EXAMPLE"),
            ("N15", "MeetingNotes2026Q4BudgetReviewFinal"),
            ("N16", "ASIAORDER2026ABCDEFX"),
            ("N17", "akiaiosfodnn7example"),
        ]
        for (label, input) in vectors {
            guard case .text(_, let summary, _) = ClipboardPreviewFormatter.makeResult(input) else {
                XCTFail("Missing result for vector \(label)")
                continue
            }
            if label == "P9" || label == "P13" {
                XCTAssertTrue(summary.contains("…"), "Vector \(label) should mask its URL segment")
            } else if label.hasPrefix("P") || label == "N15" || label == "N16" {
                XCTAssertTrue(summary.hasPrefix("••••••"), "Vector \(label) should mask")
            } else {
                XCTAssertFalse(summary.hasPrefix("••••••"), "Vector \(label) should remain readable")
            }
            XCTAssertLessThanOrEqual(summary.count, 64)
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

    @MainActor
    func testT66T67OnlyTextShowsPreview() async throws {
        for result: ClipboardPreviewResult in [
            .text(full: "test", summary: "test", isLink: false), .denied, .unavailable,
        ] {
            let session = PasteToolbarSession()
            session.isEligible = { true }
            session.previewReader = FixedPreviewReader(result: result)
            session.noteAppearance()
            session.startPreviewIfNeeded()
            for _ in 0..<100 where session.preview == .reading { try await Task.sleep(for: .milliseconds(2)) }
            if case .text = result {
                XCTAssertEqual(session.preview, .ready(result))
            } else {
                XCTAssertEqual(session.preview, .unavailable)
            }
        }
    }

    @MainActor
    func testT68T69NoReadWhenGatesClosed() async throws {
        for (enabled, access, eligible) in [(false, true, true), (true, false, true), (true, true, false)] {
            let reader = CountingPreviewReader()
            let session = PasteToolbarSession()
            session.previewReader = reader
            session.probeSwitchEnabled = { enabled }
            session.probeFullAccess = { access }
            session.isEligible = { eligible }
            session.noteAppearance()
            session.startPreviewIfNeeded()
            try await Task.sleep(for: .milliseconds(20))
            XCTAssertEqual(reader.count, 0)
        }
    }

    @MainActor
    func testNormalDeadlineIncludesExactly500Milliseconds() async throws {
        for (elapsed, expected) in [(500_000_000 as UInt64, true), (500_000_001, false)] {
            let clock = ProbeTestClock(1_000_000_000)
            let reader = VersionedTestReader(before: nil, after: nil)
            let session = PasteToolbarSession()
            session.monotonicNow = { clock.read() }
            session.isEligible = { true }
            session.previewReader = reader
            session.noteAppearance()
            session.startPreviewIfNeeded()
            await waitForReadStarted(reader)
            clock.set(1_000_000_000 + elapsed)
            reader.release.signal()
            for _ in 0..<100 where session.preview == .reading { try await Task.sleep(for: .milliseconds(2)) }
            if expected {
                XCTAssertEqual(session.preview, .ready(.text(full: "x", summary: "x", isLink: false)))
            } else {
                XCTAssertEqual(session.preview, .unavailable)
            }
        }
    }

    func testT71ExactTenSecondDeadline() {
        let clock = ProbeTestClock(100)
        let gate = ClipboardPreviewGate(deadline: 10_000_000_100, now: { clock.read() })
        XCTAssertTrue(gate.begin())
        clock.set(10_000_000_100)
        XCTAssertFalse(gate.finish(at: clock.read()))
        let queued = ClipboardPreviewGate(deadline: 10_000_000_100, now: { clock.read() })
        XCTAssertFalse(queued.begin())
    }

    @MainActor
    func testT74RepeatedRefreshDoesNotReread() async throws {
        let reader = CountingPreviewReader()
        let session = PasteToolbarSession()
        session.isEligible = { true }
        session.previewReader = reader
        session.noteAppearance()
        session.startPreviewIfNeeded()
        for _ in 0..<100 where session.preview == .reading { try await Task.sleep(for: .milliseconds(2)) }
        session.startPreviewIfNeeded()
        session.startPreviewIfNeeded()
        XCTAssertEqual(reader.count, 1)
        XCTAssertEqual(session.preview, .unavailable)
    }

    @MainActor
    func testT75FailureDoesNotConsumeSuccessDoes() {
        let session = PasteToolbarSession()
        session.isEligible = { true }
        session.noteAppearance()
        let failed = session.begin()!
        session.complete(nil, operationID: failed)
        XCTAssertEqual(session.presentation, .armed)
        session.commit = { _ in .inserted }
        let successful = session.begin()!
        session.complete("text", operationID: successful)
        XCTAssertEqual(session.presentation, .consumedByPaste)
    }

    func testT81OversizedNeverRetainsFullText() {
        let source = String(repeating: "secret", count: 2_000)
        guard case .oversized(let summary, let length, _) = ClipboardPreviewFormatter.makeResult(source) else {
            return XCTFail("oversized input must use the summary-only case")
        }
        XCTAssertEqual(length, source.utf16.count)
        XCTAssertLessThanOrEqual(summary.count, 64)
        XCTAssertFalse(summary.contains(source))
    }

    @MainActor
    func testT70LateRequiresOptInAndEqualVersions() async throws {
        let cases: [(Bool, Int?, Int?, Bool)] = [
            (false, 1, 1, false), (true, 1, 1, true), (true, 1, 2, false),
            (true, nil, 1, false), (true, 1, nil, false),
        ]
        for (enabled, before, after, expected) in cases {
            let clock = ProbeTestClock(1_000_000_000)
            // probe 仅在 latePreviewEnabled=false 时存在并消费第一个采样槽；
            // late 路径无 probe，整读直接消费 before/after 两槽。
            let reader =
                enabled
                ? VersionedTestReader(samples: [before, after])
                : VersionedTestReader(samples: [before, before, after])
            let session = PasteToolbarSession()
            session.monotonicNow = { clock.read() }
            session.latePreviewEnabled = enabled
            session.isEligible = { true }
            session.previewReader = reader
            session.noteAppearance()
            session.startPreviewIfNeeded()
            await waitForReadStarted(reader)
            clock.set(1_600_000_000)
            reader.release.signal()
            for _ in 0..<100 where session.preview == .reading { try await Task.sleep(for: .milliseconds(2)) }
            if expected {
                XCTAssertEqual(session.preview, .ready(.text(full: "x", summary: "x", isLink: false)))
            } else {
                XCTAssertEqual(session.preview, .unavailable)
            }
            XCTAssertEqual(reader.count, 1)
        }
    }

    @MainActor
    func testT70InquiryResumesLateResultWithoutReread() async throws {
        let clock = ProbeTestClock(1_000_000_000)
        let reader = VersionedTestReader(before: 4, after: 4)
        let session = PasteToolbarSession()
        session.monotonicNow = { clock.read() }
        session.latePreviewEnabled = true
        session.isEligible = { true }
        session.previewReader = reader
        session.noteAppearance()
        session.startPreviewIfNeeded()
        await waitForReadStarted(reader)
        session.noteHostResign()
        clock.set(1_600_000_000)
        reader.release.signal()
        try await Task.sleep(for: .milliseconds(30))
        XCTAssertEqual(session.preview, .reading)
        clock.set(1_700_000_000)
        session.noteHostBecomeActive()
        XCTAssertEqual(session.preview, .ready(.text(full: "x", summary: "x", isLink: false)))
        session.startPreviewIfNeeded()
        XCTAssertEqual(reader.count, 1)
    }

    @MainActor
    func testT72T73T80CancellationAfterGetterStarts() async throws {
        for mode in 0..<3 {
            let clock = ProbeTestClock(1_000_000_000)
            let reader = VersionedTestReader(before: 1, after: 1)
            let session = PasteToolbarSession()
            session.monotonicNow = { clock.read() }
            session.latePreviewEnabled = true
            session.isEligible = { true }
            session.previewReader = reader
            session.noteAppearance()
            session.startPreviewIfNeeded()
            await waitForReadStarted(reader)
            clock.set(1_300_000_000)
            if mode == 0 { session.discardPreview() }
            if mode == 1 { session.noteCountedInput() }
            if mode == 2 { session.noteAppearance() }
            reader.release.signal()
            try await Task.sleep(for: .milliseconds(40))
            if case .ready = session.preview { XCTFail("cancelled or stale result was displayed") }
            XCTAssertEqual(reader.count, 1)
        }
    }

    @MainActor
    func testT72ChangedEligibilityRejectsInFlightResult() async throws {
        for mode in 0..<3 {
            let reader = VersionedTestReader(before: 1, after: 1)
            let session = PasteToolbarSession()
            var enabled = true
            var access = true
            var eligible = true
            session.probeSwitchEnabled = { enabled }
            session.probeFullAccess = { access }
            session.isEligible = { eligible }
            session.latePreviewEnabled = true
            session.previewReader = reader
            session.noteAppearance()
            session.startPreviewIfNeeded()
            await waitForReadStarted(reader)
            if mode == 0 { enabled = false }
            if mode == 1 { access = false }
            if mode == 2 { eligible = false }
            reader.release.signal()
            for _ in 0..<100 where session.preview == .reading { try await Task.sleep(for: .milliseconds(2)) }
            XCTAssertEqual(session.preview, .unavailable)
            XCTAssertEqual(reader.count, 1)
        }
    }

    @MainActor
    func testT76QueuedSessionPastTenSecondsNeverReadsOrRequeues() async throws {
        let blocker = BlockingPreviewReader()
        ClipboardPreviewWorker.shared.submit(reader: blocker, gate: ClipboardPreviewGate(deadline: UInt64.max)) { _ in }
        XCTAssertEqual(blocker.started.wait(timeout: .now() + 2), .success)
        let clock = ProbeTestClock(1_000_000_000)
        let reader = CountingPreviewReader()
        let session = PasteToolbarSession()
        session.monotonicNow = { clock.read() }
        session.latePreviewEnabled = true
        session.isEligible = { true }
        session.previewReader = reader
        session.noteAppearance()
        session.startPreviewIfNeeded()
        clock.set(11_000_000_000)
        blocker.release.signal()
        try await Task.sleep(for: .milliseconds(50))
        session.startPreviewIfNeeded()
        try await Task.sleep(for: .milliseconds(20))
        XCTAssertEqual(reader.count, 0)
        if case .ready = session.preview { XCTFail("expired queued read displayed a preview") }
        session.discardPreview()
    }

    @MainActor
    func testT77QueuedSessionReleasedWithin500msDisplaysText() async throws {
        let blocker = BlockingPreviewReader()
        ClipboardPreviewWorker.shared.submit(reader: blocker, gate: ClipboardPreviewGate(deadline: UInt64.max)) { _ in }
        XCTAssertEqual(blocker.started.wait(timeout: .now() + 2), .success)
        let clock = ProbeTestClock(1_000_000_000)
        let reader = VersionedTestReader(before: nil, after: nil)
        let session = PasteToolbarSession()
        session.monotonicNow = { clock.read() }
        session.isEligible = { true }
        session.previewReader = reader
        session.noteAppearance()
        session.startPreviewIfNeeded()
        clock.set(1_400_000_000)
        reader.release.signal()
        blocker.release.signal()
        for _ in 0..<100 where session.preview == .reading { try await Task.sleep(for: .milliseconds(2)) }
        XCTAssertEqual(reader.count, 1)
        XCTAssertEqual(session.preview, .ready(.text(full: "x", summary: "x", isLink: false)))
        session.startPreviewIfNeeded()
        XCTAssertEqual(reader.count, 1)
    }

    @MainActor
    func testQueuedCancelBeforeGetterNeverReads() async throws {
        let blocker = BlockingPreviewReader()
        ClipboardPreviewWorker.shared.submit(reader: blocker, gate: ClipboardPreviewGate(deadline: UInt64.max)) { _ in }
        XCTAssertEqual(blocker.started.wait(timeout: .now() + 2), .success)
        let reader = CountingPreviewReader()
        let session = PasteToolbarSession()
        session.isEligible = { true }
        session.previewReader = reader
        session.noteAppearance()
        session.startPreviewIfNeeded()
        session.discardPreview()
        blocker.release.signal()
        try await Task.sleep(for: .milliseconds(50))
        XCTAssertEqual(reader.count, 0)
        XCTAssertEqual(session.preview, .unavailable)
    }

    func testT76T77QueuedDeadlineAndCancellation() {
        for expires in [true, false] {
            let clock = ProbeTestClock(1_000)
            let blocker = BlockingPreviewReader()
            ClipboardPreviewWorker.shared.submit(reader: blocker, gate: ClipboardPreviewGate(deadline: UInt64.max)) {
                _ in
            }
            XCTAssertEqual(blocker.started.wait(timeout: .now() + 2), .success)
            let reader = CountingPreviewReader()
            let deadline: UInt64 = 10_000_001_000
            let gate = ClipboardPreviewGate(deadline: deadline, now: { clock.read() })
            let done = expectation(description: "queue drained")
            ClipboardPreviewWorker.shared.submit(reader: reader, gate: gate) { _ in }
            ClipboardPreviewWorker.shared.submit(
                reader: ImmediatePreviewReader(), gate: ClipboardPreviewGate(deadline: UInt64.max)
            ) { _ in done.fulfill() }
            clock.set(expires ? deadline : 400_001_000)
            blocker.release.signal()
            wait(for: [done], timeout: 3)
            XCTAssertEqual(reader.count, expires ? 0 : 1)
        }
    }

    // MARK: - PB-013 剪贴板横向去重与持久抑制（两级去重：probe → 复用/抑制 → 整读）

    /// sampleVersions 恒 true 的代价：每次整读多两次 changeCount 采样（probe 1 次 + before/after 各 1 次，
    /// 共 3 次版本采样）。采样代价量级可忽略但属行为变化，此断言防止后续误改回。
    @MainActor
    func testPB013ColdStartFullReadThenLevel1CacheHitSkipsSecondFullRead() async throws {
        let reader = DedupTestReader(counts: [7, 7, 7, 7])
        let session = PasteToolbarSession()
        session.previewReader = reader
        session.suppressStore = MemorySuppressStore()
        session.isEligible = { true }
        session.probeEnabled = true
        // probeEnabled=true 注入覆盖：probe 路径语义保持回归覆盖（默认已按方案 B 关闭）。
        session.noteAppearance()
        session.startPreviewIfNeeded()
        for _ in 0..<200 where session.preview == .reading { try await Task.sleep(for: .milliseconds(2)) }
        XCTAssertEqual(session.preview, .ready(.text(full: "x", summary: "x", isLink: false)))
        XCTAssertEqual(reader.readCount, 1)
        XCTAssertEqual(reader.countCalls, 3, "cold start: probe + before/after sampling")
        session.didInstallPreview()
        session.noteAppearance()
        session.startPreviewIfNeeded()
        for _ in 0..<200 where session.preview == .reading { try await Task.sleep(for: .milliseconds(2)) }
        XCTAssertEqual(session.preview, .ready(.text(full: "x", summary: "x", isLink: false)))
        XCTAssertEqual(reader.readCount, 1, "Level 1 cache hit must not full-read again")
        XCTAssertEqual(reader.countCalls, 4, "Level 1 still probes changeCount once")
    }

    @MainActor
    func testPB013ChangedChangeCountRereadsAndUpdatesCache() async throws {
        let reader = DedupTestReader(counts: [7, 7, 7, 9, 9, 9, 9])
        let session = PasteToolbarSession()
        session.previewReader = reader
        session.suppressStore = MemorySuppressStore()
        session.isEligible = { true }
        session.probeEnabled = true
        // probeEnabled=true 注入覆盖：probe 路径语义保持回归覆盖（默认已按方案 B 关闭）。
        session.noteAppearance()
        session.startPreviewIfNeeded()
        for _ in 0..<200 where session.preview == .reading { try await Task.sleep(for: .milliseconds(2)) }
        XCTAssertEqual(session.preview, .ready(.text(full: "x", summary: "x", isLink: false)))
        XCTAssertEqual(reader.readCount, 1)
        session.didInstallPreview()
        session.noteAppearance()
        session.startPreviewIfNeeded()
        for _ in 0..<200 where session.preview == .reading { try await Task.sleep(for: .milliseconds(2)) }
        XCTAssertEqual(session.preview, .ready(.text(full: "x", summary: "x", isLink: false)))
        XCTAssertEqual(reader.readCount, 2, "changed count must trigger a fresh full read")
        XCTAssertEqual(reader.countCalls, 6)
        session.didInstallPreview()
        session.noteAppearance()
        session.startPreviewIfNeeded()
        for _ in 0..<200 where session.preview == .reading { try await Task.sleep(for: .milliseconds(2)) }
        XCTAssertEqual(session.preview, .ready(.text(full: "x", summary: "x", isLink: false)))
        XCTAssertEqual(reader.readCount, 2, "cache must be updated to the new count")
        XCTAssertEqual(reader.countCalls, 7)
    }

    @MainActor
    func testPB013DeniedResultIsNeverCached() async throws {
        let reader = DedupTestReader(
            counts: [3, 3, 3, 3, 3, 3, 3],
            results: [.denied, .text(full: "x", summary: "x", isLink: false)])
        let session = PasteToolbarSession()
        session.previewReader = reader
        session.suppressStore = MemorySuppressStore()
        session.isEligible = { true }
        session.probeEnabled = true
        // probeEnabled=true 注入覆盖：probe 路径语义保持回归覆盖（默认已按方案 B 关闭）。
        session.noteAppearance()
        session.startPreviewIfNeeded()
        for _ in 0..<200 where session.preview == .reading { try await Task.sleep(for: .milliseconds(2)) }
        XCTAssertEqual(session.preview, .unavailable)
        XCTAssertEqual(reader.readCount, 1)
        session.noteAppearance()
        session.startPreviewIfNeeded()
        for _ in 0..<200 where session.preview == .reading { try await Task.sleep(for: .milliseconds(2)) }
        XCTAssertEqual(session.preview, .ready(.text(full: "x", summary: "x", isLink: false)))
        XCTAssertEqual(reader.readCount, 2, "denied must not be cached; same count rereads")
        session.didInstallPreview()
        session.noteAppearance()
        session.startPreviewIfNeeded()
        for _ in 0..<200 where session.preview == .reading { try await Task.sleep(for: .milliseconds(2)) }
        XCTAssertEqual(session.preview, .ready(.text(full: "x", summary: "x", isLink: false)))
        XCTAssertEqual(reader.readCount, 2, "successful text result is cached")
    }

    @MainActor
    func testPB013PastedCountIsSuppressedOnNextAppearance() async throws {
        let reader = DedupTestReader(counts: [5, 5, 5, 5, 8, 8, 8, 8])
        let store = MemorySuppressStore()
        let session = PasteToolbarSession()
        session.previewReader = reader
        session.suppressStore = store
        session.isEligible = { true }
        session.probeEnabled = true
        // probeEnabled=true 注入覆盖：probe 路径语义保持回归覆盖（默认已按方案 B 关闭）。
        session.commit = { _ in .inserted }
        session.noteAppearance()
        session.startPreviewIfNeeded()
        for _ in 0..<200 where session.preview == .reading { try await Task.sleep(for: .milliseconds(2)) }
        XCTAssertEqual(session.preview, .ready(.text(full: "x", summary: "x", isLink: false)))
        session.didInstallPreview()
        let operation = try XCTUnwrap(session.begin())
        session.complete("x", operationID: operation)
        XCTAssertEqual(session.presentation, .consumedByPaste)
        XCTAssertEqual(store.suppressedCount(), 5)
        XCTAssertEqual(store.lastReason, .pasted)
        session.noteAppearance()
        session.startPreviewIfNeeded()
        for _ in 0..<200 where session.preview == .reading { try await Task.sleep(for: .milliseconds(2)) }
        XCTAssertEqual(session.preview, .suppressed, "handled count must be Level-0 suppressed")
        XCTAssertEqual(reader.readCount, 1, "Level 0 must not full-read")
        XCTAssertEqual(reader.countCalls, 4, "Level 0 only probes changeCount")
        XCTAssertFalse(session.previewWasShown)
        session.noteAppearance()
        session.startPreviewIfNeeded()
        for _ in 0..<200 where session.preview == .reading { try await Task.sleep(for: .milliseconds(2)) }
        XCTAssertEqual(session.preview, .ready(.text(full: "x", summary: "x", isLink: false)))
        XCTAssertEqual(reader.readCount, 2, "a new copy (count+1) shows the preview again")
    }

    @MainActor
    func testPB013CloseSuppressesButCountedInputDoesNot() async throws {
        let reader = DedupTestReader(counts: [11, 11, 11, 11, 12, 12, 12, 12])
        let store = MemorySuppressStore()
        let session = PasteToolbarSession()
        session.previewReader = reader
        session.suppressStore = store
        session.isEligible = { true }
        session.probeEnabled = true
        // probeEnabled=true 注入覆盖：probe 路径语义保持回归覆盖（默认已按方案 B 关闭）。
        session.noteAppearance()
        session.startPreviewIfNeeded()
        for _ in 0..<200 where session.preview == .reading { try await Task.sleep(for: .milliseconds(2)) }
        XCTAssertEqual(session.preview, .ready(.text(full: "x", summary: "x", isLink: false)))
        session.didInstallPreview()
        session.closePreview()
        XCTAssertEqual(store.suppressedCount(), 11)
        XCTAssertEqual(store.lastReason, .closed)
        session.noteAppearance()
        session.startPreviewIfNeeded()
        for _ in 0..<200 where session.preview == .reading { try await Task.sleep(for: .milliseconds(2)) }
        XCTAssertEqual(session.preview, .suppressed)
        XCTAssertEqual(reader.readCount, 1)
        XCTAssertEqual(reader.countCalls, 4)
        session.noteAppearance()
        session.startPreviewIfNeeded()
        for _ in 0..<200 where session.preview == .reading { try await Task.sleep(for: .milliseconds(2)) }
        XCTAssertEqual(session.preview, .ready(.text(full: "x", summary: "x", isLink: false)))
        session.noteCountedInput()
        XCTAssertEqual(store.suppressedCount(), 11, "first typed input must not write suppression")
        XCTAssertEqual(store.lastReason, .closed)
    }

    @MainActor
    func testPB013StaleSmallerSuppressedCountReadsNormally() async throws {
        let reader = DedupTestReader(counts: [9, 9, 9])
        let store = MemorySuppressStore()
        store.suppress(2, reason: .pasted)
        let session = PasteToolbarSession()
        session.previewReader = reader
        session.suppressStore = store
        session.isEligible = { true }
        session.probeEnabled = true
        // probeEnabled=true 注入覆盖：probe 路径语义保持回归覆盖（默认已按方案 B 关闭）。
        session.noteAppearance()
        session.startPreviewIfNeeded()
        for _ in 0..<200 where session.preview == .reading { try await Task.sleep(for: .milliseconds(2)) }
        XCTAssertEqual(session.preview, .ready(.text(full: "x", summary: "x", isLink: false)))
        XCTAssertEqual(reader.readCount, 1, "stale smaller store value must not suppress a fresh count")
    }

    @MainActor
    func testPB013NilProbeCountFallsBackToFullReadWithoutCache() async throws {
        let reader = DedupTestReader(counts: [nil, nil, nil, nil, nil, nil])
        let session = PasteToolbarSession()
        session.previewReader = reader
        session.suppressStore = MemorySuppressStore()
        session.isEligible = { true }
        session.probeEnabled = true
        // probeEnabled=true 注入覆盖：probe 路径语义保持回归覆盖（默认已按方案 B 关闭）。
        session.noteAppearance()
        session.startPreviewIfNeeded()
        for _ in 0..<200 where session.preview == .reading { try await Task.sleep(for: .milliseconds(2)) }
        XCTAssertEqual(session.preview, .ready(.text(full: "x", summary: "x", isLink: false)))
        XCTAssertEqual(reader.readCount, 1)
        XCTAssertEqual(reader.countCalls, 3)
        session.didInstallPreview()
        session.noteAppearance()
        session.startPreviewIfNeeded()
        for _ in 0..<200 where session.preview == .reading { try await Task.sleep(for: .milliseconds(2)) }
        XCTAssertEqual(session.preview, .ready(.text(full: "x", summary: "x", isLink: false)))
        XCTAssertEqual(reader.readCount, 2, "nil version samples must never be cached")
        XCTAssertEqual(reader.countCalls, 6)
    }

    @MainActor
    func testPB013PasteSupplementarySampleWritesStoreWhenCacheMissing() async throws {
        let reader = DedupTestReader(counts: [nil, nil, nil, 6, 6])
        let store = MemorySuppressStore()
        let session = PasteToolbarSession()
        session.previewReader = reader
        session.suppressStore = store
        session.isEligible = { true }
        session.probeEnabled = true
        session.commit = { _ in .inserted }
        session.noteAppearance()
        session.startPreviewIfNeeded()
        for _ in 0..<200 where session.preview == .reading { try await Task.sleep(for: .milliseconds(2)) }
        XCTAssertEqual(session.preview, .ready(.text(full: "x", summary: "x", isLink: false)))
        session.didInstallPreview()
        let operation = try XCTUnwrap(session.begin())
        session.complete("x", operationID: operation)
        XCTAssertEqual(session.presentation, .consumedByPaste)
        XCTAssertEqual(store.suppressedCount(), 6, "missing after sample must be re-sampled once on paste")
        XCTAssertEqual(store.lastReason, .pasted)
        session.noteAppearance()
        session.startPreviewIfNeeded()
        for _ in 0..<200 where session.preview == .reading { try await Task.sleep(for: .milliseconds(2)) }
        XCTAssertEqual(session.preview, .suppressed)
        XCTAssertEqual(reader.readCount, 1)
    }

    @MainActor
    func testPB013ResignDuringProbeDropsResultWithoutCache() async throws {
        let reader = DedupTestReader(counts: [7, 7, 7, 7], blockingCounts: 1)
        let session = PasteToolbarSession()
        session.previewReader = reader
        session.suppressStore = MemorySuppressStore()
        session.isEligible = { true }
        session.probeEnabled = true
        // probeEnabled=true 注入覆盖：probe 路径语义保持回归覆盖（默认已按方案 B 关闭）。
        session.noteAppearance()
        session.startPreviewIfNeeded()
        XCTAssertEqual(reader.started.wait(timeout: .now() + 2), .success)
        session.noteHostResign()
        reader.release.signal()
        for _ in 0..<200 where session.preview == .reading { try await Task.sleep(for: .milliseconds(2)) }
        XCTAssertEqual(session.preview, .unavailable, "probe result arriving during suspension is dropped")
        session.noteHostBecomeActive()
        session.noteAppearance()
        session.startPreviewIfNeeded()
        for _ in 0..<200 where session.preview == .reading { try await Task.sleep(for: .milliseconds(2)) }
        XCTAssertEqual(session.preview, .ready(.text(full: "x", summary: "x", isLink: false)))
        XCTAssertEqual(reader.readCount, 1, "dropped probe must not have written a cache entry")
        XCTAssertEqual(reader.countCalls, 4, "two probes + before/after of the fresh full read")
    }

    @MainActor
    func testPB013GenerationChangeDropsProbeResultWithoutCache() async throws {
        let reader = DedupTestReader(counts: [7, 7, 7, 7], blockingCounts: 1)
        let session = PasteToolbarSession()
        session.previewReader = reader
        session.suppressStore = MemorySuppressStore()
        session.isEligible = { true }
        session.probeEnabled = true
        // probeEnabled=true 注入覆盖：probe 路径语义保持回归覆盖（默认已按方案 B 关闭）。
        session.noteAppearance()
        session.startPreviewIfNeeded()
        XCTAssertEqual(reader.started.wait(timeout: .now() + 2), .success)
        session.noteAppearance()
        reader.release.signal()
        try await Task.sleep(for: .milliseconds(50))
        session.startPreviewIfNeeded()
        for _ in 0..<200 where session.preview == .reading { try await Task.sleep(for: .milliseconds(2)) }
        XCTAssertEqual(session.preview, .ready(.text(full: "x", summary: "x", isLink: false)))
        XCTAssertEqual(reader.readCount, 1, "stale-generation probe must not full-read or cache")
        XCTAssertEqual(reader.countCalls, 4)
    }

    @MainActor
    func testPB013ClosedGatesZeroAccessIncludingProbe() async throws {
        let reader = DedupTestReader(counts: [7, 7, 7])
        let session = PasteToolbarSession()
        session.previewReader = reader
        session.suppressStore = MemorySuppressStore()
        var switchOn = false
        var fullAccess = false
        session.probeSwitchEnabled = { switchOn }
        session.probeFullAccess = { fullAccess }
        session.isEligible = { true }
        session.probeEnabled = true
        // probeEnabled=true 注入覆盖：probe 路径语义保持回归覆盖（默认已按方案 B 关闭）。
        session.noteAppearance()
        session.startPreviewIfNeeded()
        try await Task.sleep(for: .milliseconds(30))
        XCTAssertEqual(reader.countCalls, 0, "gates closed: not even changeCount may be read")
        XCTAssertEqual(reader.readCount, 0)
        XCTAssertEqual(session.preview, .notRead)
        switchOn = true
        fullAccess = true
        session.startPreviewIfNeeded()
        for _ in 0..<200 where session.preview == .reading { try await Task.sleep(for: .milliseconds(2)) }
        XCTAssertEqual(session.preview, .ready(.text(full: "x", summary: "x", isLink: false)))
        XCTAssertEqual(reader.readCount, 1)
    }

    /// m3：probe 200ms 超时后整读重起自己的 500ms 正常窗（不是从 probe 起点继续计时）。
    @MainActor
    func testPB013ProbeTimeoutFallsBackToFullReadWithFreshDeadline() async throws {
        let reader = DedupTestReader(counts: [7, 7, 7], blockingCounts: 1, blockingReads: 1)
        let session = PasteToolbarSession()
        session.previewReader = reader
        session.suppressStore = MemorySuppressStore()
        session.isEligible = { true }
        session.probeEnabled = true
        // probeEnabled=true 注入覆盖：probe 路径语义保持回归覆盖（默认已按方案 B 关闭）。
        session.noteAppearance()
        session.startPreviewIfNeeded()
        XCTAssertEqual(reader.started.wait(timeout: .now() + 2), .success, "probe changeCount is blocked")
        try await Task.sleep(for: .milliseconds(260))
        reader.release.signal()
        XCTAssertEqual(reader.started.wait(timeout: .now() + 2), .success, "full read must start after probe timeout")
        try await Task.sleep(for: .milliseconds(300))
        reader.release.signal()
        for _ in 0..<300 where session.preview == .reading { try await Task.sleep(for: .milliseconds(2)) }
        XCTAssertEqual(
            session.preview, .ready(.text(full: "x", summary: "x", isLink: false)),
            "full read issued ~260ms after probe start must still fit its own restarted 500ms window")
        XCTAssertEqual(reader.readCount, 1)
        XCTAssertEqual(reader.countCalls, 3)
    }

    func testPB013ProbeTimeoutConstantIs200Milliseconds() {
        XCTAssertEqual(PasteToolbarSession.probeTimeout, 200_000_000)
    }

    /// sampleVersions 恒 true：latePreviewEnabled=false 时 before/after 也必采样（代价：每次整读多两次
    /// changeCount 采样，量级可忽略；此断言防止误改回）。
    @MainActor
    func testPB013FullReadAlwaysSamplesBeforeAndAfter() async throws {
        let reader = DedupTestReader(counts: [7, 7, 7])
        let session = PasteToolbarSession()
        session.previewReader = reader
        session.suppressStore = MemorySuppressStore()
        session.isEligible = { true }
        session.probeEnabled = true
        // probeEnabled=true 注入覆盖：probe 路径语义保持回归覆盖（默认已按方案 B 关闭）。
        XCTAssertFalse(session.latePreviewEnabled)
        session.noteAppearance()
        session.startPreviewIfNeeded()
        for _ in 0..<200 where session.preview == .reading { try await Task.sleep(for: .milliseconds(2)) }
        XCTAssertEqual(session.preview, .ready(.text(full: "x", summary: "x", isLink: false)))
        XCTAssertEqual(reader.countCalls, 3, "probe + before/after sampled even with late preview off")
    }

    /// Scheme B 默认路径（真机 O5 实测：读取 changeCount 本身亦触发系统「已粘贴」横幅）：
    /// 默认 probeEnabled == false，首现无缓存直接整读（无 probe，仅 before/after 采样）。
    @MainActor
    func testPB013ProbeDisabledByDefaultUsesPlanBPath() async throws {
        let reader = DedupTestReader(counts: [5, 5, 5])
        let session = PasteToolbarSession()
        XCTAssertFalse(
            session.probeEnabled,
            "device O5 evidence: reading changeCount itself triggers the system paste banner; probe must be off by default"
        )
        session.previewReader = reader
        session.suppressStore = MemorySuppressStore()
        session.isEligible = { true }
        session.noteAppearance()
        session.startPreviewIfNeeded()
        for _ in 0..<200 where session.preview == .reading { try await Task.sleep(for: .milliseconds(2)) }
        XCTAssertEqual(session.preview, .ready(.text(full: "x", summary: "x", isLink: false)))
        XCTAssertEqual(reader.readCount, 1, "default path: cold start performs exactly one full read")
        XCTAssertEqual(reader.countCalls, 2, "default path: no probe, only before/after sampling")
    }

    /// 方案 B 注入路径（probeEnabled 显式置 false）：同 changeCount 复现直接复用缓存/抑制，
    /// 零 pasteboard 访问；粘贴后写 Level 0 抑制。
    @MainActor
    func testPB013PlanBReusesCacheWithoutProbeAndAppliesSuppression() async throws {
        let reader = DedupTestReader(counts: [5, 5, 5])
        let store = MemorySuppressStore()
        let session = PasteToolbarSession()
        session.previewReader = reader
        session.suppressStore = store
        session.isEligible = { true }
        session.commit = { _ in .inserted }
        session.probeEnabled = false
        session.noteAppearance()
        session.startPreviewIfNeeded()
        for _ in 0..<200 where session.preview == .reading { try await Task.sleep(for: .milliseconds(2)) }
        XCTAssertEqual(session.preview, .ready(.text(full: "x", summary: "x", isLink: false)))
        XCTAssertEqual(reader.readCount, 1, "plan B: at most one full read per process")
        XCTAssertEqual(reader.countCalls, 2, "plan B: no probe, only before/after sampling")
        session.didInstallPreview()
        session.noteAppearance()
        session.startPreviewIfNeeded()
        try await Task.sleep(for: .milliseconds(30))
        XCTAssertEqual(session.preview, .ready(.text(full: "x", summary: "x", isLink: false)))
        XCTAssertEqual(reader.readCount, 1, "plan B: same-changeCount appearance reuses the cache")
        XCTAssertEqual(reader.countCalls, 2, "plan B: zero pasteboard access on cache reuse")
        let operation = try XCTUnwrap(session.begin())
        session.complete("x", operationID: operation)
        XCTAssertEqual(store.suppressedCount(), 5)
        XCTAssertEqual(store.lastReason, .pasted)
        session.noteAppearance()
        session.startPreviewIfNeeded()
        try await Task.sleep(for: .milliseconds(30))
        XCTAssertEqual(session.preview, .suppressed, "plan B: suppression applies via sampled count")
        XCTAssertEqual(reader.readCount, 1)
        XCTAssertEqual(reader.countCalls, 2)
    }

    /// 方案 B 冷启动整读补口（PB-013 Fix 1）：本进程缓存为空、持久抑制已含当前 changeCount
    /// （跨进程粘贴/关闭残留）时，整读结果不得展示——解析为 .suppressed，previewWasShown 保持
    /// false；抑制判定复用本次整读已采样的 before，零额外粘贴板读取。
    @MainActor
    func testPB013PlanBFreshSessionFullReadSuppressedByPersistedCount() async throws {
        let reader = DedupTestReader(counts: [5, 5, 5])
        let store = MemorySuppressStore()
        store.suppress(5, reason: .closed)
        let session = PasteToolbarSession()
        session.previewReader = reader
        session.suppressStore = store
        session.isEligible = { true }
        XCTAssertFalse(session.probeEnabled)
        session.noteAppearance()
        session.startPreviewIfNeeded()
        for _ in 0..<200 where session.preview == .reading { try await Task.sleep(for: .milliseconds(2)) }
        XCTAssertEqual(
            session.preview, .suppressed,
            "persisted suppression must win over a cold-start full read")
        XCTAssertFalse(session.previewWasShown)
        XCTAssertEqual(
            reader.readCount, 1,
            "suppression rides the already-issued full read; no extra pasteboard read")
        XCTAssertEqual(reader.countCalls, 2, "plan B: no probe, only before/after sampling")
    }

    /// 方案 B 整读补口不得误伤：持久抑制计数与当前 changeCount 不同时，整读照常解析为 .ready。
    @MainActor
    func testPB013PlanBFullReadStaysReadyWhenStoreCountDiffers() async throws {
        let reader = DedupTestReader(counts: [5, 5, 5])
        let store = MemorySuppressStore()
        store.suppress(9, reason: .closed)
        let session = PasteToolbarSession()
        session.previewReader = reader
        session.suppressStore = store
        session.isEligible = { true }
        session.noteAppearance()
        session.startPreviewIfNeeded()
        for _ in 0..<200 where session.preview == .reading { try await Task.sleep(for: .milliseconds(2)) }
        XCTAssertEqual(session.preview, .ready(.text(full: "x", summary: "x", isLink: false)))
        XCTAssertEqual(reader.readCount, 1)
        XCTAssertFalse(session.previewWasShown)
    }

    func testPB013SuppressStorePersistsOnlyIntegerCountAndReason() throws {
        let suiteName = "pb013.suppress.type.test"
        UserDefaults().removePersistentDomain(forName: suiteName)
        defer { UserDefaults().removePersistentDomain(forName: suiteName) }
        let defaults = UserDefaults(suiteName: suiteName)
        let store = PastePreviewSuppressStore(defaults: defaults)
        XCTAssertNil(store.suppressedCount())
        store.suppress(42, reason: .pasted)
        let count = try XCTUnwrap(defaults?.object(forKey: PastePreviewSuppressStore.countKey))
        XCTAssertTrue(count is Int, "store must persist the changeCount as an integer")
        XCTAssertEqual(count as? Int, 42)
        let reason = try XCTUnwrap(defaults?.object(forKey: PastePreviewSuppressStore.reasonKey))
        XCTAssertTrue(reason is String, "store persists only the non-content reason enum")
        XCTAssertEqual(reason as? String, "pasted")
        let storedKeys = (defaults?.dictionaryRepresentation() ?? [:]).keys.filter { $0.hasPrefix("paste_preview_") }
        XCTAssertEqual(
            Set(storedKeys), [PastePreviewSuppressStore.countKey, PastePreviewSuppressStore.reasonKey],
            "no clipboard content, summary or hash may ever be persisted")
        defaults?.set("junk", forKey: PastePreviewSuppressStore.countKey)
        XCTAssertNil(store.suppressedCount(), "non-integer stored values must be ignored")
        store.suppress(7, reason: .closed)
        XCTAssertEqual(store.suppressedCount(), 7)
    }

    @MainActor
    func testPB013CloseButtonInvokesCallbackAndClearsBar() async throws {
        let (owner, client, _) = await previewOwner(result: .text(full: "clip", summary: "clip", isLink: false))
        let view = try XCTUnwrap(owner.pastePreviewView)
        let closeButton = try XCTUnwrap(view.findPasteCloseButton())
        XCTAssertEqual(closeButton.accessibilityIdentifier, "keyboard.paste.preview.close")
        // The unhosted target does not dispatch UIControl actions; invoke its registered selector.
        view.perform(NSSelectorFromString("closeTapped"))
        for _ in 0..<100 where owner.pastePreviewView != nil { try await Task.sleep(for: .milliseconds(5)) }
        XCTAssertNil(owner.pastePreviewView, "closing must clear the installed preview")
        XCTAssertEqual(owner.pasteSession.preview, .unavailable)
        XCTAssertTrue(client.inserted.isEmpty, "closing must not paste")
    }

    @MainActor
    func testPB013SuppressedAppearanceClearsBarWithoutInstalling() async throws {
        let owner = PasteOwner()
        let defaults = PasteMemoryDefaults()
        defaults.set(true, forKey: KeyboardInputSettingsKey.clipboardPreviewEnabled)
        owner.sharedDefaults = defaults
        owner.access = true
        owner.loadViewIfNeeded()
        owner.controller = KeyboardController()
        let client = PasteClient()
        owner.controller.textClient = client
        let store = MemorySuppressStore()
        store.suppress(4, reason: .pasted)
        owner.pasteSession.suppressStore = store
        owner.pasteSession.probeEnabled = true
        owner.pasteSession.previewReader = DedupTestReader(counts: [4, 4, 4])
        owner.cachedPasteToolbarEnabled = true
        owner.view.frame = CGRect(x: 0, y: 0, width: 390, height: 288)
        owner.setupRootStack()
        owner.reloadKeyboard()
        owner.isKeyboardUIInstalled = true
        owner.installPasteInputObservation()
        owner.view.layoutIfNeeded()
        owner.pasteSession.noteAppearance()
        owner.refreshPasteToolbar()
        try await Task.sleep(for: .milliseconds(60))
        XCTAssertEqual(owner.pasteSession.preview, .suppressed)
        XCTAssertNil(owner.pastePreviewView, "suppressed appearance must not install a preview view")
        XCTAssertTrue(client.inserted.isEmpty)
        XCTAssertFalse(owner.pasteSession.previewWasShown)
    }

}

extension UIView {
    fileprivate func findPasteCloseButton() -> UIButton? {
        if let button = self as? UIButton, accessibilityIdentifier == "keyboard.paste.preview.close" { return button }
        for child in subviews {
            if let found = child.findPasteCloseButton() { return found }
        }
        return nil
    }
}

private nonisolated final class MemorySuppressStore: PastePreviewSuppressStoring, @unchecked Sendable {
    private let lock = NSLock()
    private var stored: Int?
    private var storedReason: PastePreviewSuppressReason?
    var lastReason: PastePreviewSuppressReason? {
        lock.lock()
        defer { lock.unlock() }
        return storedReason
    }
    func suppressedCount() -> Int? {
        lock.lock()
        defer { lock.unlock() }
        return stored
    }
    func suppress(_ count: Int, reason: PastePreviewSuppressReason) {
        lock.lock()
        stored = count
        storedReason = reason
        lock.unlock()
    }
}

/// changeCount()/read() 按序返回预设值的假读取器；前 N 次调用可阻塞以模拟慢 probe/慢整读。
private nonisolated final class DedupTestReader: ClipboardPreviewReading, @unchecked Sendable {
    let started = DispatchSemaphore(value: 0)
    let release = DispatchSemaphore(value: 0)
    private let lock = NSLock()
    private let counts: [Int?]
    private let results: [ClipboardPreviewResult]
    private let blockingCounts: Int
    private let blockingReads: Int
    private var versionIndex = 0
    private var resultIndex = 0
    private var versionCalls = 0
    private var readCalls = 0

    init(
        counts: [Int?],
        results: [ClipboardPreviewResult] = [.text(full: "x", summary: "x", isLink: false)],
        blockingCounts: Int = 0,
        blockingReads: Int = 0
    ) {
        self.counts = counts
        self.results = results
        self.blockingCounts = blockingCounts
        self.blockingReads = blockingReads
    }

    var countCalls: Int {
        lock.lock()
        defer { lock.unlock() }
        return versionCalls
    }

    var readCount: Int {
        lock.lock()
        defer { lock.unlock() }
        return readCalls
    }

    func changeCount() -> Int? {
        lock.lock()
        let value = counts[min(versionIndex, counts.count - 1)]
        versionIndex += 1
        let call = versionCalls
        versionCalls += 1
        let block = call < blockingCounts
        lock.unlock()
        if block {
            started.signal()
            release.wait()
        }
        return value
    }

    func read() -> ClipboardPreviewResult {
        lock.lock()
        let result = results[min(resultIndex, results.count - 1)]
        resultIndex += 1
        let call = readCalls
        readCalls += 1
        let block = call < blockingReads
        lock.unlock()
        if block {
            started.signal()
            release.wait()
        }
        return result
    }
}

extension UIView {
    fileprivate func findPasteSeparator() -> UIView? {
        if accessibilityIdentifier == "pasteLeadingSeparator" { return self }
        for child in subviews {
            if let found = child.findPasteSeparator() { return found }
        }
        return nil
    }
}

/// PB-013：probe→整读交接需一次主 actor 跳转，测试不得用信号量阻塞主线程等待 read() 启动；
/// 改为异步轮询读计数（契约不变：整读必须在 ~2s 内启动）。
private protocol StartedCountingTestReader {
    var count: Int { get }
}
extension BlockingPreviewReader: StartedCountingTestReader {}
extension VersionedTestReader: StartedCountingTestReader {}

@MainActor
private func waitForReadStarted(_ reader: some StartedCountingTestReader) async {
    for _ in 0..<400 where reader.count == 0 {
        try? await Task.sleep(for: .milliseconds(5))
    }
    XCTAssertGreaterThan(reader.count, 0, "full read must start promptly")
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

private nonisolated final class ProbeTestClock: @unchecked Sendable {
    private let lock = NSLock()
    private var value: UInt64
    init(_ value: UInt64) { self.value = value }
    func read() -> UInt64 { lock.lock(); defer { lock.unlock() }; return value }
    func set(_ value: UInt64) { lock.lock(); self.value = value; lock.unlock() }
}

private nonisolated final class VersionedTestReader: ClipboardPreviewReading, @unchecked Sendable {
    let started = DispatchSemaphore(value: 0)
    let release = DispatchSemaphore(value: 0)
    private let lock = NSLock()
    private let versions: [Int?]
    private var reads = 0
    private var versionReads = 0
    init(before: Int?, after: Int?) { versions = [before, after] }
    /// PB-013：三槽构造（probe, before, after），用于验证 probe 消费一个采样槽后的整读语义。
    init(samples: [Int?]) { versions = samples }
    var count: Int { lock.lock(); defer { lock.unlock() }; return reads }
    func changeCount() -> Int? {
        lock.lock()
        defer { lock.unlock() }
        let result = versions[min(versionReads, versions.count - 1)]
        versionReads += 1
        return result
    }
    func read() -> ClipboardPreviewResult {
        lock.lock()
        reads += 1
        lock.unlock()
        started.signal()
        release.wait()
        return .text(full: "x", summary: "x", isLink: false)
    }
}
