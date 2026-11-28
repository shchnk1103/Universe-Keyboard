import Foundation
import XCTest
import os

@testable import KeyboardCore

/// 009 S1c J1–J10: background bridge, close generation, copy isolation. Uses the manual pump
/// scheduler and the ingress flush barrier; nothing here sleeps or asserts wall-clock time.
final class T9DiagnosticJournalS1cTests: XCTestCase {
    final class Flag: @unchecked Sendable {
        private let value = OSAllocatedUnfairLock<UInt64>(initialState: 0)
        func get() -> UInt64 { value.withLock { $0 } }
        func advance() { value.withLock { $0 += 1 } }
    }
    final class Switch: @unchecked Sendable {
        private let value = OSAllocatedUnfairLock<Bool>(initialState: true)
        func get() -> Bool { value.withLock { $0 } }
        func set(_ newValue: Bool) { value.withLock { $0 = newValue } }
    }

    struct Rig {
        let root: URL
        let admission: T9DiagnosticAdmission
        let runtime: DiagnosticsJournalRuntime
        let pump: T9DiagnosticsJournalPump
        let close: Flag
        let enabled: Switch
        let processID: UUID
    }

    nonisolated static func blockingWait(_ semaphore: DispatchSemaphore, seconds: Double) -> Bool {
        semaphore.wait(timeout: .now() + seconds) == .success
    }

    override func tearDown() {
        T9DiagnosticAdmission.shared.resetForTesting()
        super.tearDown()
    }

    private func makeRig(root existing: URL? = nil, close: Flag = Flag()) async throws -> Rig {
        let root =
            existing
            ?? FileManager.default.temporaryDirectory
            .appendingPathComponent("s1c-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        let rootWriter = DiagnosticsJournalWriter(rootURL: root, origin: .mainApp, isMainAppWriter: true)
        try await rootWriter.prepareRootIfOwnedByMainApp()
        let processID = UUID()
        let admission = T9DiagnosticAdmission()
        let runtime = DiagnosticsJournalRuntime(
            origin: .keyboardExtension,
            processInstanceID: processID,
            isMainAppWriter: false,
            rootURL: { root },
            isCategoryEnabled: { _ in true },
            writerVersion: .v7,
            flushDelay: 60,
            closeGenerationProvider: { close.get() }
        )
        let enabled = Switch()
        let pump = T9DiagnosticsJournalPump(
            admission: admission,
            runtime: runtime,
            isSwitchEnabled: { enabled.get() },
            closeGeneration: { close.get() },
            scheduler: .manual
        )
        pump.enable()
        pump.drainForTesting()
        return Rig(
            root: root, admission: admission, runtime: runtime, pump: pump, close: close,
            enabled: enabled, processID: processID)
    }

    private func events(_ rig: Rig) async throws -> [DiagnosticEvent] {
        await rig.runtime.flushAndWaitForTesting()
        return try await DiagnosticsJournalReader(rootURL: rig.root).latest().events
            .filter { $0.t9Payload != nil }
            .sorted { ($0.t9Payload?.admissionSequence ?? 0) < ($1.t9Payload?.admissionSequence ?? 0) }
    }

    private func jsonl(_ root: URL) throws -> String {
        var text = ""
        let enumerator = FileManager.default.enumerator(at: root, includingPropertiesForKeys: nil)
        while let url = enumerator?.nextObject() as? URL {
            guard url.pathExtension == "jsonl" else { continue }
            text += (try? String(contentsOf: url, encoding: .utf8)) ?? ""
        }
        return text
    }

    private func cycle(_ terminal: T9CycleDiagnostic.Terminal = .succeeded) -> T9CycleDiagnostic {
        T9CycleDiagnostic(
            terminal: terminal, candidateBand: .nonzero, preeditShape: .segmented, usable: .yes, exact: .yes)
    }

    // MARK: J1 end to end

    func testJ1CycleAndDeleteReachReaderInAdmissionOrder() async throws {
        let rig = try await makeRig()
        XCTAssertTrue(rig.admission.tryEnqueue(cycle()))
        XCTAssertTrue(rig.admission.tryEnqueue(T9DeleteDiagnostic(branch: .engineDelete, restored: .yes)))
        XCTAssertTrue(rig.admission.tryEnqueue(cycle(.rolledBack)))
        rig.pump.tick()
        let read = try await events(rig)
        XCTAssertEqual(read.map(\.code), [.t9CycleResult, .t9DeletePath, .t9CycleResult])
        XCTAssertEqual(read.compactMap(\.t9Payload?.admissionSequence), [0, 1, 2])
        XCTAssertEqual(read[0].t9Payload?.terminal, .succeeded)
        XCTAssertEqual(read[1].t9Payload?.branch, .engineDelete)
        XCTAssertEqual(read[1].t9Payload?.restored, .yes)
        XCTAssertEqual(read[2].t9Payload?.terminal, .rolledBack)
        XCTAssertTrue(read.allSatisfy { $0.fields.isEmpty && $0.schemaVersion == 7 })
        XCTAssertTrue(read.allSatisfy { $0.origin == .keyboardExtension && $0.processInstanceID == rig.processID })
    }

    // MARK: J2 cross process

    func testJ2TwoWritersKeepDistinctProcessIdentity() async throws {
        let first = try await makeRig()
        let second = try await makeRig(root: first.root)
        XCTAssertNotEqual(first.processID, second.processID)
        XCTAssertTrue(first.admission.tryEnqueue(cycle()))
        XCTAssertTrue(second.admission.tryEnqueue(T9DeleteDiagnostic(branch: .other, restored: .no)))
        first.pump.tick()
        second.pump.tick()
        await first.runtime.flushAndWaitForTesting()
        let read = try await events(second)
        XCTAssertEqual(Set(read.map(\.processInstanceID)), [first.processID, second.processID])
        XCTAssertTrue(read.allSatisfy { $0.origin == .keyboardExtension })
    }

    // MARK: J3 wire and privacy

    func testJ3WireIsV7OnlyAndCanaryNeverWritten() async throws {
        let rig = try await makeRig()
        let canary = "CANARY'ninh"
        XCTAssertTrue(
            rig.admission.tryEnqueue(
                T9CycleDiagnostic(
                    terminal: .succeeded, candidateBand: .nonzero,
                    preeditShape: T9CycleDiagnostic.Shape.shape(of: canary), usable: .yes, exact: .yes)))
        rig.pump.tick()
        _ = try await events(rig)
        let text = try jsonl(rig.root)
        XCTAssertTrue(text.contains("t9.cycle_result"))
        XCTAssertFalse(text.contains("CANARY"))
        XCTAssertFalse(text.contains("ninh"))
        for version in 3...7 { XCTAssertTrue(DiagnosticEvent.supportsReading(schemaVersion: version)) }
        XCTAssertFalse(DiagnosticEvent.supportsReading(schemaVersion: 8))
        // A T9 code on a lower wire version is not a valid event: v7 only.
        let downgraded = text.split(separator: "\n").first { $0.contains("t9.cycle_result") }.map {
            $0.replacingOccurrences(of: "\"schemaVersion\":7", with: "\"schemaVersion\":6")
        }
        XCTAssertNotNil(downgraded)
        XCTAssertFalse(downgraded?.contains("\"schemaVersion\":7") ?? true)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        XCTAssertNil(try? decoder.decode(DiagnosticEvent.self, from: Data((downgraded ?? "").utf8)))
        // A v6 writer cannot emit the typed event at all.
        let v6 = DiagnosticsJournalRuntime(
            origin: .keyboardExtension, isMainAppWriter: false, rootURL: { rig.root },
            isCategoryEnabled: { _ in true }, writerVersion: .v6)
        XCTAssertFalse(
            v6.recordAdmittedT9(
                T9AdmittedEnvelope(
                    payload: .cycle(cycle()), admissionSequence: 0, admittedMonotonicNanoseconds: 1)))
    }

    // MARK: J4 stable off

    func testJ4SwitchOffWritesNothingPhysically() async throws {
        let rig = try await makeRig()
        rig.enabled.set(false)
        XCTAssertTrue(rig.admission.tryEnqueue(cycle()))
        rig.pump.tick()
        let read = try await events(rig)
        XCTAssertTrue(read.isEmpty)
        XCTAssertFalse(try jsonl(rig.root).contains("t9."))
        XCTAssertTrue(rig.admission.cycles().isEmpty)
    }

    /// Counterexample A: close lands after write permission, before the first handle.write.
    func testJ4ACloseBetweenPermissionAndFirstWriteWritesNothing() async throws {
        let rig = try await makeRig()
        // Warm up so the production writer exists, then hook it.
        rig.runtime.record(code: .presentationAppeared, category: .display)
        await rig.runtime.flushAndWaitForTesting()
        let writer = try XCTUnwrap(rig.runtime.productionWriterForTesting())
        let close = rig.close
        await writer.installAfterAdmissionForTesting { close.advance() }
        XCTAssertTrue(rig.admission.tryEnqueue(cycle()))
        rig.pump.tick()
        let read = try await events(rig)
        XCTAssertTrue(read.isEmpty, "close published after permission must stop the first write")
    }

    func testB1ObservedCloseAfterBatchTakenBeforeFirstWriteDoesNotWrite() async throws {
        let rig = try await makeRig()
        rig.runtime.record(code: .presentationAppeared, category: .display)
        await rig.runtime.flushAndWaitForTesting()
        let writer = try XCTUnwrap(rig.runtime.productionWriterForTesting())
        await writer.installAfterAdmissionForTesting {
            rig.close.advance()
            _ = rig.runtime.observeCloseGeneration()
        }
        XCTAssertTrue(rig.admission.tryEnqueue(cycle()))
        rig.pump.tick()
        let read = try await events(rig)
        XCTAssertTrue(read.isEmpty, "an observed close must reject a taken batch before its first write")
        XCTAssertFalse(try jsonl(rig.root).contains("t9.cycle_result"))
    }

    /// An in-flight first write may finish: no close is visible before the write begins.
    func testJ4AInFlightBatchFinishesWhenCloseArrivesAfterItBegan() async throws {
        let rig = try await makeRig()
        XCTAssertTrue(rig.admission.tryEnqueue(cycle()))
        rig.pump.tick()
        let read = try await events(rig)
        XCTAssertEqual(read.count, 1)
        rig.close.advance()
        rig.pump.tick()
        let after = try await events(rig)
        XCTAssertEqual(after.count, 1, "the batch already written is untouched by a later close")
    }

    /// Counterexample B: close then reopen between samples; both booleans are true again.
    func testJ4BCloseAndReopenBetweenTicksDiscardsOldTails() async throws {
        let rig = try await makeRig()
        // Old admission tail: closed and reopened before the pump ever looked.
        XCTAssertTrue(rig.admission.tryEnqueue(cycle()))
        rig.enabled.set(false)
        rig.close.advance()
        rig.enabled.set(true)
        rig.pump.tick()
        // Old Ingress batch: already handed over, then close + reopen before the flush.
        XCTAssertTrue(rig.admission.tryEnqueue(cycle()))
        rig.pump.tick()
        rig.close.advance()
        let afterIngressClose = try await events(rig)
        XCTAssertTrue(afterIngressClose.isEmpty, "old admission and old Ingress batch are not replayed")
        // New events after awareness are written normally.
        rig.pump.tick()
        XCTAssertTrue(rig.admission.tryEnqueue(cycle(.rollbackFailed)))
        rig.pump.tick()
        let fresh = try await events(rig)
        XCTAssertEqual(fresh.compactMap(\.t9Payload?.terminal), [.rollbackFailed])
    }

    // MARK: J5 replaceInput parity

    @MainActor
    func testJ5ReplaceInputCountsMatchWithCaptureOnAndOff() {
        func run(capture: Bool) -> Int {
            let engine = FakeRimeEngine()
            engine.seedRuntimeSelection(
                RimeRuntimeSelection(baseSchemaID: "rime_ice", layoutStyle: .nineKey, t9ReadinessMatched: true))
            let controller = KeyboardController()
            controller.usesT9InputSemantics = true
            controller.t9DiagnosticCaptureEnabled = capture
            controller.rimeEngine = engine
            let choice = T9PinyinPath(displayText: "ni", replacementRawInput: "ni", compositionRevision: 0)
            controller.state.lastRimeOutput = RimeOutput(
                rawInput: "64", composition: RimeComposition(preeditText: "64", cursorPosition: 2),
                candidates: [RimeCandidate(text: "你")])
            controller.state.t9PinyinPathState = T9PinyinPathState(
                compactPaths: [choice], rawInputGeneration: 1, provenanceRevision: 1,
                issuedReplacementKeys: [choice.replacementRawInput], issuedPathIDs: [choice.id])
            engine.replaceInputScript = [
                RimeOutput(
                    rawInput: "ni", composition: RimeComposition(preeditText: "ni", cursorPosition: 2),
                    candidates: [RimeCandidate(text: "你")])
            ]
            engine.resetCallCounts()
            _ = controller.handleCycleT9PinyinPath()
            return engine.replaceInputCallCount
        }
        T9DiagnosticAdmission.shared.resetForTesting()
        let on = run(capture: true)
        T9DiagnosticAdmission.shared.resetForTesting()
        let off = run(capture: false)
        XCTAssertEqual(on, off)
        XCTAssertTrue(T9DiagnosticAdmission.shared.cycles().isEmpty)
    }

    // MARK: J6 non waiting

    func testJ6KeyPathReturnsImmediatelyWhenBlocked() async throws {
        let rig = try await makeRig()
        // Admission lock held: enqueue is refused, nothing recorded, no forbidden call.
        rig.admission.holdLockForTesting()
        XCTAssertFalse(rig.admission.tryEnqueue(cycle(), now: 1))
        XCTAssertFalse(rig.admission.tryEnqueue(T9DeleteDiagnostic(branch: .other, restored: .no), now: 1))
        rig.pump.tick()  // busy take: returns, drops nothing
        rig.admission.releaseLockForTesting()
        XCTAssertEqual(rig.admission.recordTouchCount, 0)
        // Blocked writer: the key path and the pump tick never wait for it.
        rig.runtime.record(code: .presentationAppeared, category: .display)
        await rig.runtime.flushAndWaitForTesting()
        let writer = try XCTUnwrap(rig.runtime.productionWriterForTesting())
        let entered = DispatchSemaphore(value: 0)
        let release = DispatchSemaphore(value: 0)
        await writer.installAfterAdmissionForTesting {
            entered.signal()
            _ = Self.blockingWait(release, seconds: 30)
        }
        XCTAssertTrue(rig.admission.tryEnqueue(cycle()))
        rig.pump.tick()
        let runtime = rig.runtime
        let flushTask = Task { await runtime.flushAndWaitForTesting() }
        XCTAssertTrue(Self.blockingWait(entered, seconds: 20), "writer never reached its first write")
        // Writer is blocked inside its append; the key path still returns at once.
        XCTAssertTrue(rig.admission.tryEnqueue(cycle(.criteriaRejected)))
        rig.pump.tick()
        for index in 0..<260 {
            _ = rig.admission.tryEnqueue(cycle(), now: UInt64(index) * 10_000_000_001)
        }
        XCTAssertEqual(rig.admission.recordTouchCount, 0)
        release.signal()
        _ = await flushTask.value
    }

    // MARK: J7 scheduling isolation

    func testJ7KeyPathOnlyEnqueuesAndTickKeepsQueueOnBusy() async throws {
        let rig = try await makeRig()
        let before = rig.pump.tickCount
        XCTAssertTrue(rig.admission.tryEnqueue(cycle()))
        XCTAssertTrue(rig.admission.tryEnqueue(T9DeleteDiagnostic(branch: .identityDelete, restored: .no)))
        XCTAssertTrue(rig.admission.tryEnqueue(cycle(.criteriaRejected)))
        XCTAssertEqual(rig.pump.tickCount, before, "enqueue never ticks")
        rig.admission.holdLockForTesting()
        rig.pump.tick()
        rig.admission.releaseLockForTesting()
        XCTAssertEqual(rig.admission.cycles().count, 2, "busy take keeps the queue")
        XCTAssertEqual(rig.admission.deletes().count, 1)
        rig.pump.tick()
        let read = try await events(rig)
        XCTAssertEqual(read.compactMap(\.t9Payload?.admissionSequence), [0, 1, 2])
        XCTAssertEqual(read.map(\.code), [.t9CycleResult, .t9DeletePath, .t9CycleResult])
        XCTAssertEqual(rig.pump.tickCount, before + 2)
    }

    // MARK: J8 lifecycle and drops

    func testJ8SuspendDropsTailAndResumeDoesNotReplay() async throws {
        let rig = try await makeRig()
        XCTAssertTrue(rig.admission.tryEnqueue(cycle()))
        rig.pump.revoke()
        rig.pump.drainForTesting()
        rig.pump.tick()
        XCTAssertFalse(rig.pump.writableForTesting)
        XCTAssertFalse(rig.admission.tryEnqueue(cycle()), "suspended admission refuses new events")
        rig.pump.enable()
        rig.pump.drainForTesting()
        rig.pump.tick()
        let none = try await events(rig)
        XCTAssertTrue(none.isEmpty, "resume never replays the dropped tail")
        XCTAssertTrue(rig.admission.tryEnqueue(cycle()))
        rig.pump.tick()
        let read = try await events(rig)
        XCTAssertEqual(read.count, 1)
        // 1 dropped tail event + 1 enqueue refused while suspended; both are admission drops.
        XCTAssertEqual(read[0].t9Payload?.priorDrops, 2)
    }

    func testJ8PriorDropsSaturateAt255AndDownstreamDropIsNotAdmissionDrop() async throws {
        let rig = try await makeRig()
        var now: UInt64 = 0
        for index in 0..<256 {
            if index > 0, index.isMultiple(of: 20) { now &+= 10_000_000_001 }
            XCTAssertTrue(rig.admission.tryEnqueue(cycle(), now: now))
        }
        rig.pump.revoke()
        rig.pump.drainForTesting()
        rig.pump.enable()
        rig.pump.drainForTesting()
        XCTAssertTrue(rig.admission.tryEnqueue(cycle(), now: now &+ 20_000_000_000))
        rig.pump.tick()
        var read = try await events(rig)
        XCTAssertEqual(read.last?.t9Payload?.priorDrops, 255)
        // Downstream (Ingress) drop after close does not count as an admission drop.
        XCTAssertTrue(rig.admission.tryEnqueue(cycle()))
        rig.pump.tick()
        rig.close.advance()
        await rig.runtime.flushAndWaitForTesting()
        rig.pump.tick()  // awareness
        XCTAssertTrue(rig.admission.tryEnqueue(cycle()))
        rig.pump.tick()
        read = try await events(rig)
        XCTAssertEqual(read.last?.t9Payload?.priorDrops, 0)
    }

    // MARK: J10 provisional return point

    @MainActor
    func testJ10ProvisionalAheadReturnPointIsNotStartedWithoutReplaceInput() {
        let engine = FakeRimeEngine()
        let controller = KeyboardController()
        controller.usesT9InputSemantics = true
        controller.t9DiagnosticCaptureEnabled = true
        controller.rimeEngine = engine
        controller.seedProvisionalAheadForTesting()
        XCTAssertTrue(controller.isResponsiveProvisionalAhead)
        XCTAssertFalse(controller.isCompositionInputRecoveryPending)
        engine.resetCallCounts()
        _ = controller.handleCycleT9PinyinPath()
        let cycles = T9DiagnosticAdmission.shared.cycles()
        XCTAssertEqual(cycles.count, 1)
        XCTAssertEqual(cycles[0].terminal, .notStarted)
        XCTAssertEqual(cycles[0].candidateBand, .notApplicable)
        XCTAssertEqual(cycles[0].preeditShape, .notApplicable)
        XCTAssertEqual(cycles[0].usable, .notApplicable)
        XCTAssertEqual(cycles[0].exact, .notApplicable)
        XCTAssertEqual(engine.replaceInputCallCount, 0)
    }
}
