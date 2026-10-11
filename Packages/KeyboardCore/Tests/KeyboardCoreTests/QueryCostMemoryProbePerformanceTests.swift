#if DEBUG && KEYBOARD_QUERY_COST_PROBE
    import Dispatch
    import Foundation
    import Synchronization
    import XCTest
    @testable import KeyboardCore

    /// Fixed synthetic schedules, not production MainActor concurrency or a latency threshold.
    /// Execution needs its own AUTH binding this timeout, toolchain and flag configuration.
    nonisolated final class QueryCostMemoryProbePerformanceTests: XCTestCase {
        private static let barrierTimeoutSeconds: Double = 5
        private struct CallSample: Codable, Sendable {
            let worker: Int, epoch: Int
            let beginNanoseconds: UInt64, fillNanoseconds: UInt64, pairNanoseconds: UInt64
            let clockInvalid: Bool
            let payloadChecksum: UInt64
        }
        private struct Unit: Codable, Sendable {
            let group: Int, mode: Int
            let elapsedNanoseconds: UInt64, freezeNanoseconds: UInt64
            let clockInvalid: Bool, scheduleFailed: Bool, overlapAvailable: Bool
            let header: [UInt64], byteCount: Int, calls: [CallSample]
            let minimumPair: UInt64, medianPair: UInt64, worstPair: UInt64
        }
        private struct Comparison: Codable, Sendable {
            let group: Int
            let armedMinusDisabledNanoseconds: Int64, armedMinusControlNanoseconds: Int64
        }
        private struct FreezeUnit: Codable, Sendable {
            let group: Int, schedule: Int
            let elapsedNanoseconds: UInt64, clockInvalid: Bool
            let header: [UInt64], byteCount: Int, immutableAfterLaterCalls: Bool
        }
        private struct WorkerResults: Sendable {
            var samples: [CallSample?] = Array(repeating: nil, count: 1000)
            var failed = false
        }
        // Each worker owns one receive semaphore; start/end are separate handshakes.
        // All waits happen in the test harness, outside the probe lock and MainActor.
        private final class PairBarrier: Sendable {
            let receives = [DispatchSemaphore(value: 0), DispatchSemaphore(value: 0)]
            func meet(worker: Int) -> Bool {
                receives[1 - worker].signal()
                return receives[worker].wait(
                    timeout: .now() + QueryCostMemoryProbePerformanceTests.barrierTimeoutSeconds) == .success
            }
        }
        private func interval(_ start: UInt64, _ end: UInt64) -> (UInt64, Bool) {
            end >= start ? (end - start, false) : (0, true)
        }
        private func signedDifference(_ value: UInt64, _ reference: UInt64) -> Int64 {
            // Clock-domain magnitudes are checked, never clamp a negative paired difference.
            guard value <= UInt64(Int64.max), reference <= UInt64(Int64.max) else {
                XCTFail("measurement outside signed reporting range"); return 0
            }
            return Int64(value) - Int64(reference)
        }
        private func attach<T: Encodable>(_ value: T, name: String) throws {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.sortedKeys]
            let data = try encoder.encode(value)
            // Persist the same bytes only when this test run binds an output directory.
            // All call sites have finished measuring; evidence I/O stays outside measured intervals.
            if let directory = ProcessInfo.processInfo.environment["UK_QUERY_COST_PERF_RAW_DIR"] {
                let output = URL(fileURLWithPath: directory, isDirectory: true)
                    .appendingPathComponent(name).appendingPathExtension("json")
                try data.write(to: output, options: .withoutOverwriting)
            }
            let attachment = XCTAttachment(data: data, uniformTypeIdentifier: "public.json")
            attachment.name = name
            attachment.lifetime = .keepAlways
            add(attachment)
        }
        func testThirtyCompetingWriterComparisonGroupsWithoutThresholdOrRetries() throws {
            var units: [Unit] = []
            var comparisons: [Comparison] = []
            for group in 0..<30 {
                var current: [Unit] = []
                for position in 0..<3 {
                    let mode = (group + position) % 3  // 0 disabled, 1 armed, 2 no-probe control.
                    let unit = try competingUnit(group: group, mode: mode)
                    current.append(unit)
                    units.append(unit)
                }
                let disabled = try XCTUnwrap(current.first { $0.mode == 0 })
                let armed = try XCTUnwrap(current.first { $0.mode == 1 })
                let control = try XCTUnwrap(current.first { $0.mode == 2 })
                comparisons.append(
                    Comparison(
                        group: group,
                        armedMinusDisabledNanoseconds: signedDifference(
                            armed.elapsedNanoseconds, disabled.elapsedNanoseconds),
                        armedMinusControlNanoseconds: signedDifference(
                            armed.elapsedNanoseconds, control.elapsedNanoseconds)))
            }
            XCTAssertEqual(units.count, 90)
            try attach(units, name: "C-raw-units-all-90-no-replacement")
            try attach(comparisons, name: "C-signed-paired-differences")
        }
        private func competingUnit(group: Int, mode: Int) throws -> Unit {
            let probe = QueryCostMemoryProbe.makeSyntheticForTesting()
            if mode == 1 {
                XCTAssertEqual(probe.arm(QueryCostProbeTestFixture.scope(), eligible: true), .armed)
                XCTAssertTrue(probe.beginSequence(ordinal: 1, fixture: 1, arm: 1, eligible: true))
            }
            if mode != 2 {
                probe.beginOperation(1)
                probe.beginOperation(2)
            }
            let startBarrier = PairBarrier()
            let endBarrier = PairBarrier()
            let results = Mutex(WorkerResults())
            let start = DispatchTime.now().uptimeNanoseconds
            DispatchQueue.concurrentPerform(iterations: 2) { worker in
                let operation = UInt64(worker + 1)
                let payload = QueryCostProbeTestFixture.payload(operation: operation)
                for epoch in 0..<500 {
                    guard startBarrier.meet(worker: worker) else {
                        results.withLock { $0.failed = true }
                        break
                    }
                    let pairStart = DispatchTime.now().uptimeNanoseconds
                    let reservation = mode == 2 ? nil : probe.beginInvocation(operation: operation, stage: .stageOne)
                    let beginEnd = DispatchTime.now().uptimeNanoseconds
                    let payloadChecksum = payload.operationOrdinal + UInt64(payload.facadeElapsedMicroseconds)
                    if mode != 2 { probe.finishInvocation(reservation, payload: payload) }
                    let fillEnd = DispatchTime.now().uptimeNanoseconds
                    let begin = beginEnd >= pairStart ? beginEnd - pairStart : 0
                    let fill = fillEnd >= beginEnd ? fillEnd - beginEnd : 0
                    let pair = fillEnd >= pairStart ? fillEnd - pairStart : 0
                    let sample = CallSample(
                        worker: worker, epoch: epoch,
                        beginNanoseconds: begin, fillNanoseconds: fill, pairNanoseconds: pair,
                        clockInvalid: beginEnd < pairStart || fillEnd < beginEnd, payloadChecksum: payloadChecksum)
                    results.withLock { $0.samples[worker * 500 + epoch] = sample }
                    guard endBarrier.meet(worker: worker) else {
                        results.withLock { $0.failed = true }
                        break
                    }
                }
            }
            let end = DispatchTime.now().uptimeNanoseconds
            if mode != 2 {
                probe.endOperation(1, terminal: .completed)
                probe.endOperation(2, terminal: .completed)
            }
            if mode == 1 { XCTAssertTrue(probe.endSequence(eligible: true)) }
            let freezeStart = DispatchTime.now().uptimeNanoseconds
            let snapshot = probe.freeze()
            let bytes = snapshot.map(QueryCostProbeTestFixture.bytes) ?? []
            let freezeEnd = DispatchTime.now().uptimeNanoseconds
            let result = results.withLock { $0 }
            let samples = result.samples.compactMap { $0 }
            let clock = interval(start, end)
            let freezeClock = interval(freezeStart, freezeEnd)
            XCTAssertFalse(result.failed, "finite barrier budget exhausted; no retry")
            XCTAssertEqual(samples.count, 1000)
            if mode == 1 {
                let snapshot = try XCTUnwrap(snapshot)
                XCTAssertFalse(snapshot.isIncomplete);
                XCTAssertEqual(snapshot.words[20...25], [1000, 1000, 0, 2, 2, 0])
                // Reviewed §9's 1004 is Q+2O. The wire also has the required 2S records.
                // C3 explicitly distinguishes full wire records from nonsequence records.
                XCTAssertEqual(snapshot.words[4], 1006)
                XCTAssertEqual(snapshot.words[4] - snapshot.words[27] - snapshot.words[28], 1004)
                XCTAssertEqual(bytes.count, 161_216)
                XCTAssertEqual(QueryCostMemoryProbe.decode(bytes), snapshot)
            } else {
                XCTAssertNil(snapshot)
            }
            let sorted = samples.map(\.pairNanoseconds).sorted()
            return Unit(
                group: group, mode: mode, elapsedNanoseconds: clock.0, freezeNanoseconds: freezeClock.0,
                clockInvalid: clock.1 || freezeClock.1 || samples.contains(where: \.clockInvalid),
                scheduleFailed: result.failed, overlapAvailable: false,
                header: snapshot.map { Array($0.words.prefix(32)) } ?? [], byteCount: bytes.count, calls: samples,
                minimumPair: sorted.first ?? 0, medianPair: sorted.isEmpty ? 0 : sorted[sorted.count / 2],
                worstPair: sorted.last ?? 0)
        }
        func testThirtyInstancesForEachExplicitFreezeSchedule() throws {
            var units: [FreezeUnit] = []
            for schedule in 0..<3 {
                for group in 0..<30 { units.append(try orderedFreeze(group: group, schedule: schedule)) }
            }
            XCTAssertEqual(units.count, 90)
            // R1 incomplete is expected and kept as its own cohort, never dropped or replaced.
            for schedule in 0..<3 {
                try attach(units.filter { $0.schedule == schedule }, name: "R\(schedule)-raw-30")
            }
        }
        private func orderedFreeze(group: Int, schedule: Int) throws -> FreezeUnit {
            let probe = QueryCostMemoryProbe.makeSyntheticForTesting()
            XCTAssertEqual(probe.arm(QueryCostProbeTestFixture.scope(), eligible: true), .armed)
            var frozen: QueryCostMemoryProbe.Snapshot?
            var elapsed: (UInt64, Bool) = (0, false)
            func freeze() {
                let start = DispatchTime.now().uptimeNanoseconds
                frozen = probe.freeze()
                _ = frozen.map(QueryCostProbeTestFixture.bytes)
                elapsed = interval(start, DispatchTime.now().uptimeNanoseconds)
            }
            if schedule == 0 { freeze() }
            _ = probe.beginSequence(ordinal: 1, fixture: 1, arm: 1, eligible: true)
            probe.beginOperation(1)
            probe.beginOperation(2)
            let reservations = Mutex<[QueryCostMemoryProbe.Reservation?]>([nil, nil])
            // concurrentPerform return is the explicit join: both reservations precede R1 freeze.
            DispatchQueue.concurrentPerform(iterations: 2) { worker in
                let token = probe.beginInvocation(operation: UInt64(worker + 1), stage: .stageOne)
                reservations.withLock { $0[worker] = token }
            }
            if schedule == 1 { freeze() }
            DispatchQueue.concurrentPerform(iterations: 2) { worker in
                let token = reservations.withLock { $0[worker] }
                probe.finishInvocation(token, payload: QueryCostProbeTestFixture.payload(operation: UInt64(worker + 1)))
            }
            probe.endOperation(1, terminal: .completed)
            probe.endOperation(2, terminal: .completed)
            _ = probe.endSequence(eligible: true)
            if schedule == 2 { freeze() }
            let snapshot = try XCTUnwrap(frozen)
            let before = QueryCostProbeTestFixture.bytes(snapshot)
            let after = try XCTUnwrap(probe.freeze())
            XCTAssertEqual(before, QueryCostProbeTestFixture.bytes(after))
            XCTAssertEqual(QueryCostMemoryProbe.decode(before), snapshot)
            let expectedRecordCounts: [UInt64] = [0, 5, 8]
            let expectedByteCounts = [256, 1056, 1536]
            XCTAssertEqual(snapshot.words[4], expectedRecordCounts[schedule])
            XCTAssertEqual(before.count, expectedByteCounts[schedule])
            switch schedule {
            case 0:
                XCTAssertEqual(snapshot.words[20...25], [0, 0, 0, 0, 0, 0])
                XCTAssertFalse(snapshot.isIncomplete)
            case 1:
                XCTAssertEqual(snapshot.words[20...25], [2, 0, 2, 2, 0, 2])
                XCTAssertTrue(snapshot.isIncomplete)
            default:
                XCTAssertEqual(snapshot.words[20...25], [2, 2, 0, 2, 2, 0])
                XCTAssertFalse(snapshot.isIncomplete)
            }
            return FreezeUnit(
                group: group, schedule: schedule, elapsedNanoseconds: elapsed.0,
                clockInvalid: elapsed.1, header: Array(snapshot.words.prefix(32)), byteCount: before.count,
                immutableAfterLaterCalls: before == QueryCostProbeTestFixture.bytes(after))
        }
        func testSequentialHookAndFreezeCohortsKeepEveryRawSample() throws {
            var hookUnits: [Unit] = []
            var freezeUnits: [FreezeUnit] = []
            for group in 0..<30 {
                for offset in 0..<2 {
                    let mode = (group + offset) % 2
                    let probe = QueryCostMemoryProbe.makeSyntheticForTesting()
                    if mode == 1 {
                        XCTAssertEqual(probe.arm(QueryCostProbeTestFixture.scope(), eligible: true), .armed)
                        XCTAssertTrue(probe.beginSequence(ordinal: 1, fixture: 1, arm: 1, eligible: true))
                    }
                    probe.beginOperation(1)
                    let payload = QueryCostProbeTestFixture.payload()
                    let start = DispatchTime.now().uptimeNanoseconds
                    for _ in 0..<1000 {
                        let token = probe.beginInvocation(operation: 1, stage: .stageOne)
                        probe.finishInvocation(token, payload: payload)
                    }
                    let timing = interval(start, DispatchTime.now().uptimeNanoseconds)
                    probe.endOperation(1, terminal: .completed)
                    _ = probe.endSequence(eligible: true)
                    let snapshot = probe.freeze()
                    let bytes = snapshot.map(QueryCostProbeTestFixture.bytes) ?? []
                    if mode == 1 {
                        XCTAssertEqual(snapshot?.queryCount, 1000)
                        XCTAssertEqual(snapshot?.isIncomplete, false)
                    }
                    hookUnits.append(
                        Unit(
                            group: group, mode: mode, elapsedNanoseconds: timing.0,
                            freezeNanoseconds: 0, clockInvalid: timing.1, scheduleFailed: false,
                            overlapAvailable: false,
                            header: snapshot.map { Array($0.words.prefix(32)) } ?? [], byteCount: bytes.count,
                            calls: [], minimumPair: 0, medianPair: 0, worstPair: 0))
                }
                for cohort in 0..<3 {
                    let count = [0, 359, 4092][cohort]
                    let probe = QueryCostMemoryProbe.makeSyntheticForTesting()
                    XCTAssertEqual(probe.arm(QueryCostProbeTestFixture.scope(), eligible: true), .armed)
                    if count != 0 {
                        XCTAssertTrue(probe.beginSequence(ordinal: 1, fixture: 1, arm: 1, eligible: true));
                        probe.beginOperation(1)
                        for _ in 0..<count {
                            let token = probe.beginInvocation(operation: 1, stage: .stageOne)
                            probe.finishInvocation(token, payload: QueryCostProbeTestFixture.payload())
                        }
                        probe.endOperation(1, terminal: .completed)
                        XCTAssertTrue(probe.endSequence(eligible: true))
                    }
                    let start = DispatchTime.now().uptimeNanoseconds
                    let snapshot = try XCTUnwrap(probe.freeze())
                    let bytes = QueryCostProbeTestFixture.bytes(snapshot)
                    let timing = interval(start, DispatchTime.now().uptimeNanoseconds)
                    XCTAssertFalse(snapshot.isIncomplete)
                    XCTAssertEqual(snapshot.queryCount, UInt64(count))
                    if cohort == 2 { XCTAssertEqual(bytes.count, QueryCostMemoryProbe.maximumBytes) }
                    freezeUnits.append(
                        FreezeUnit(
                            group: group, schedule: cohort, elapsedNanoseconds: timing.0,
                            clockInvalid: timing.1, header: Array(snapshot.words.prefix(32)), byteCount: bytes.count,
                            immutableAfterLaterCalls: probe.freeze() == snapshot))
                }
            }
            try attach(hookUnits, name: "sequential-hooks-60-raw")
            for cohort in 0..<3 {
                try attach(freezeUnits.filter { $0.schedule == cohort }, name: "freeze-cohort-\(cohort)-30-raw")
            }
        }
    }
#endif
