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
        XCTAssertEqual(reader.started.wait(timeout: .now() + 2), .success)
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
            XCTAssertEqual(reader.started.wait(timeout: .now() + 2), .success)
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
            let reader = VersionedTestReader(before: before, after: after)
            let session = PasteToolbarSession()
            session.monotonicNow = { clock.read() }
            session.latePreviewEnabled = enabled
            session.isEligible = { true }
            session.previewReader = reader
            session.noteAppearance()
            session.startPreviewIfNeeded()
            XCTAssertEqual(reader.started.wait(timeout: .now() + 2), .success)
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
        XCTAssertEqual(reader.started.wait(timeout: .now() + 2), .success)
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
            XCTAssertEqual(reader.started.wait(timeout: .now() + 2), .success)
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
            XCTAssertEqual(reader.started.wait(timeout: .now() + 2), .success)
            if mode == 0 { enabled = false }
            if mode == 1 { access = false }
            if mode == 2 { eligible = false }
            reader.release.signal()
            for _ in 0..<100 where session.preview == .reading { try await Task.sleep(for: .milliseconds(2)) }
            XCTAssertEqual(session.preview, .unavailable)
            XCTAssertEqual(reader.count, 1)
        }
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
