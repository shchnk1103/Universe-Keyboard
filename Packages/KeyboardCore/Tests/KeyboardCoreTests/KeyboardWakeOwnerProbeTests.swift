#if DEBUG
    import Synchronization
    import XCTest
    @testable import KeyboardCore

    final class KeyboardWakeOwnerProbeTests: XCTestCase {
        private static let headerWords = 11
        private static let recordWords = 11
        private static let lifetime = KeyboardWakeOwnerProbe.lifetimeNanoseconds

        func testStartsDisabledAndRequiresOneExplicitArm() {
            let (probe, _) = makeProbe()

            XCTAssertFalse(probe.isArmed)
            XCTAssertFalse(probe.isFrozen)
            XCTAssertFalse(
                probe.record(stage: .appearance, coordinatorOrdinal: 1, ownerPresent: false)
            )
            XCTAssertNil(probe.freeze())

            XCTAssertTrue(probe.arm())
            XCTAssertTrue(probe.isArmed)
            XCTAssertFalse(probe.arm())
        }

        func testCoordinatorAndAttemptOrdinalsBindOnlyWithinSynchronousWindow() throws {
            let (probe, _) = makeProbe()
            let coordinatorOrdinal = probe.nextCoordinatorOrdinal()
            XCTAssertEqual(coordinatorOrdinal, 1)
            XCTAssertTrue(probe.arm())

            let attempt = probe.beginAttempt(appearanceOrdinal: 7)
            XCTAssertEqual(attempt, 1)
            XCTAssertTrue(
                probe.record(
                    stage: .insertBegin,
                    coordinatorOrdinal: coordinatorOrdinal,
                    ownerPresent: true,
                    receiptPresent: true,
                    epoch: 42,
                    revision: 9
                )
            )
            XCTAssertTrue(probe.endAttempt(attempt!))
            XCTAssertTrue(
                probe.record(
                    stage: .schedule,
                    coordinatorOrdinal: coordinatorOrdinal,
                    ownerPresent: false
                )
            )

            let snapshot = try XCTUnwrap(probe.freeze())
            let insert = record(snapshot, index: 1)
            XCTAssertEqual(insert[2], KeyboardWakeOwnerProbe.Stage.insertBegin.rawValue)
            XCTAssertEqual(insert[3], coordinatorOrdinal)
            XCTAssertEqual(insert[4], 7)
            XCTAssertEqual(insert[5], 1)
            XCTAssertEqual(insert[6], 1)
            XCTAssertEqual(insert[7], 1)
            XCTAssertEqual(insert[9], 42)
            XCTAssertEqual(insert[10], 9)

            let scheduled = record(snapshot, index: 2)
            XCTAssertEqual(scheduled[4], 7)
            XCTAssertEqual(scheduled[5], 0)
        }

        func testExpiryClosesCaptureAndProducesIncompleteSnapshotWithoutWaiting() throws {
            let (probe, clock) = makeProbe()
            clock.set(100)
            XCTAssertTrue(probe.arm())
            XCTAssertTrue(
                probe.record(stage: .resumeBegin, coordinatorOrdinal: 3, ownerPresent: true)
            )

            clock.set(100 + Self.lifetime)
            XCTAssertFalse(probe.isArmed)
            XCTAssertTrue(probe.isFrozen)
            XCTAssertFalse(
                probe.record(stage: .resumeEnd, coordinatorOrdinal: 3, ownerPresent: true)
            )

            let snapshot = try XCTUnwrap(probe.freeze())
            XCTAssertTrue(snapshot.isIncomplete)
            XCTAssertTrue(probe.isFrozen)
            XCTAssertFalse(probe.arm())
            XCTAssertEqual(snapshot.words[Self.headerWords - 2], 2)
        }

        func testOverflowPreservesFirst128RecordsAndMarksSnapshotIncomplete() throws {
            let (probe, _) = makeProbe()
            XCTAssertTrue(probe.arm())
            for _ in 0..<129 {
                _ = probe.record(
                    stage: .schedule,
                    coordinatorOrdinal: 5,
                    ownerPresent: false
                )
            }

            let snapshot = try XCTUnwrap(probe.freeze())
            XCTAssertTrue(snapshot.isIncomplete)
            XCTAssertEqual(snapshot.words[Self.headerWords - 2], 128)
            XCTAssertEqual(snapshot.words[Self.headerWords - 1], 2)
            XCTAssertEqual(record(snapshot, index: 0)[0], 1)
            XCTAssertEqual(record(snapshot, index: 127)[0], 128)
        }

        func testFreezeIsImmutableAndExposesOnlyFiniteBorrowedTransport() throws {
            let (probe, _) = makeProbe()
            XCTAssertTrue(probe.arm())
            XCTAssertTrue(
                probe.record(stage: .teardown, coordinatorOrdinal: 2, ownerPresent: false)
            )

            let first = try XCTUnwrap(probe.freeze())
            XCTAssertFalse(first.isIncomplete)
            XCTAssertFalse(probe.record(stage: .replacement, coordinatorOrdinal: 2, ownerPresent: true))
            XCTAssertEqual(probe.freeze(), first)
            XCTAssertTrue(probe.isFrozen)

            let byteCount = first.withUnsafeBytes { bytes in
                XCTAssertFalse(bytes.isEmpty)
                return bytes.count
            }
            XCTAssertEqual(byteCount, first.words.count * MemoryLayout<UInt64>.size)
        }

        func testStageCodesAreClosedAndStable() {
            XCTAssertEqual(
                KeyboardWakeOwnerProbe.Stage.allCases.map(\.rawValue),
                Array(UInt64(1)...UInt64(11))
            )
        }

        func testOwnerAbsentAndOwnerPresentWithoutReceiptRemainDistinct() throws {
            let (probe, _) = makeProbe()
            XCTAssertTrue(probe.arm())
            let attempt = try XCTUnwrap(probe.beginAttempt(appearanceOrdinal: 1))
            probe.record(stage: .schedule, coordinatorOrdinal: 1, ownerPresent: false)
            probe.record(stage: .schedule, coordinatorOrdinal: 1, ownerPresent: true)
            probe.record(
                stage: .schedule, coordinatorOrdinal: 1, ownerPresent: true, receiptPresent: true, epoch: 2, revision: 3
            )
            XCTAssertTrue(probe.endAttempt(attempt))
            let snapshot = try XCTUnwrap(probe.freeze())
            XCTAssertEqual(record(snapshot, index: 1)[6...7], [0, 0])
            XCTAssertEqual(record(snapshot, index: 2)[6...7], [1, 0])
            XCTAssertEqual(record(snapshot, index: 3)[6...7], [1, 1])
        }

        func testReentrantAttemptCannotBeMisattributedToOuterInput() throws {
            let (probe, _) = makeProbe()
            XCTAssertTrue(probe.arm())
            let outer = try XCTUnwrap(probe.beginAttempt(appearanceOrdinal: 1))
            XCTAssertNil(probe.beginAttempt(appearanceOrdinal: 1))
            probe.record(stage: .schedule, coordinatorOrdinal: 1, ownerPresent: false)
            XCTAssertFalse(probe.endAttempt(outer))
            let snapshot = try XCTUnwrap(probe.freeze())
            XCTAssertTrue(snapshot.isIncomplete)
            XCTAssertEqual(record(snapshot, index: 1)[5], 0)
        }

        func testFreezeDuringUnfinishedAttemptMarksSnapshotIncomplete() throws {
            let (probe, _) = makeProbe()
            XCTAssertTrue(probe.arm())
            let attempt = try XCTUnwrap(probe.beginAttempt(appearanceOrdinal: 1))
            probe.record(stage: .insertBegin, coordinatorOrdinal: 1, ownerPresent: true)
            let snapshot = try XCTUnwrap(probe.freeze())
            XCTAssertTrue(snapshot.isIncomplete)
            XCTAssertFalse(probe.endAttempt(attempt))
        }

        func testControlStaysAvailableForArmedFaultWithStaleCandidates() {
            XCTAssertFalse(
                KeyboardWakeOwnerProbe.showsControl(
                    isObserving: false, hasCandidates: true, hasActiveTouches: false,
                    elapsedIdleNanoseconds: 2_000_000_000))
            XCTAssertTrue(
                KeyboardWakeOwnerProbe.showsControl(
                    isObserving: false, hasCandidates: false, hasActiveTouches: false,
                    elapsedIdleNanoseconds: 2_000_000_000))
            XCTAssertTrue(
                KeyboardWakeOwnerProbe.showsControl(
                    isObserving: true, hasCandidates: true, hasActiveTouches: false,
                    elapsedIdleNanoseconds: 2_000_000_000))
            XCTAssertFalse(
                KeyboardWakeOwnerProbe.showsControl(
                    isObserving: true, hasCandidates: true, hasActiveTouches: true,
                    elapsedIdleNanoseconds: 10_000_000_000))
            XCTAssertFalse(
                KeyboardWakeOwnerProbe.showsControl(
                    isObserving: true, hasCandidates: false, hasActiveTouches: false,
                    elapsedIdleNanoseconds: 1_999_999_999))
        }

        private func makeProbe() -> (KeyboardWakeOwnerProbe, ProbeClock) {
            let clock = ProbeClock()
            let probe = KeyboardWakeOwnerProbe(now: { clock.now() })
            return (probe, clock)
        }

        private func record(_ snapshot: KeyboardWakeOwnerProbe.Snapshot, index: Int) -> [UInt64] {
            let start = Self.headerWords + index * Self.recordWords
            return Array(snapshot.words[start..<(start + Self.recordWords)])
        }
    }

    private final class ProbeClock: Sendable {
        private let value = Mutex<UInt64>(0)

        func now() -> UInt64 {
            value.withLock { $0 }
        }

        func set(_ nanoseconds: UInt64) {
            value.withLock { $0 = nanoseconds }
        }
    }
#endif
