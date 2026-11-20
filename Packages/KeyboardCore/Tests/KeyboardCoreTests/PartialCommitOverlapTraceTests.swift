import XCTest

@testable import KeyboardCore

/// PF054-DIAG-001: content-free overlap diagnostics at the two `finalText`
/// splice points. The emitted payload must be booleans/lengths only — no input
/// text, pinyin or candidate strings — and the `finalText` result must stay
/// byte-identical to the pre-PF054 behavior.
@MainActor
final class PartialCommitOverlapTraceTests: XCTestCase {
    private var events: [PartialCommitOverlapDiagnostic] = []

    override func setUp() {
        super.setUp()
        events = []
    }

    private func makeController() -> (KeyboardController, FakeTextInputClient) {
        let client = FakeTextInputClient()
        let controller = KeyboardController()
        controller.textClient = client
        controller.onPartialCommitOverlap = { [weak self] diagnostic in
            self?.events.append(diagnostic)
        }
        return (controller, client)
    }

    private func assertNoCJKText(_ diagnostic: PartialCommitOverlapDiagnostic) {
        let hasCJK = String(describing: diagnostic).unicodeScalars.contains {
            (0x4E00...0x9FFF).contains($0.value)
        }
        XCTAssertFalse(hasCJK, "overlap diagnostic must never carry CJK text: \(diagnostic)")
    }

    // MARK: - Preserve path (applyRimeOutputPreservingPartialCommit)

    func testPreservePathEmitsOverlapFieldsForSuffixPrefixOverlap() throws {
        let (controller, client) = makeController()
        controller.state.partialCommit = PartialCommitState(
            confirmedText: "记进任务",
            remainingRawInput: "mulu",
            remainingPreeditText: "目录里",
            displayText: "记进任务目录里"
        )

        controller.applyRimeOutput(
            RimeOutput(committedText: "任务目录里", hasMorePages: false)
        )

        // finalText splice is untouched: confirmed + committed. The suffix/prefix
        // overlap ("任务") is duplicated — exactly the PF054 symptom.
        XCTAssertEqual(client.text, "记进任务任务目录里")
        XCTAssertEqual(events.count, 1)
        let diagnostic = try XCTUnwrap(events.first)
        XCTAssertEqual(diagnostic.path, .preserve)
        XCTAssertEqual(diagnostic.committedHasPrefix, false)
        XCTAssertEqual(diagnostic.confirmedLen, 4)
        XCTAssertEqual(diagnostic.committedLen, 5)
        XCTAssertEqual(diagnostic.overlapLen, 2)
        assertNoCJKText(diagnostic)
    }

    func testPreservePathEmitsZeroOverlapWhenSuffixAndPrefixDiffer() throws {
        let (controller, client) = makeController()
        controller.state.partialCommit = PartialCommitState(
            confirmedText: "日记",
            remainingRawInput: "renwu",
            remainingPreeditText: "任务目录里",
            displayText: "日记任务目录里"
        )

        controller.applyRimeOutput(
            RimeOutput(committedText: "任务目录里", hasMorePages: false)
        )

        XCTAssertEqual(client.text, "日记任务目录里")
        XCTAssertEqual(events.count, 1)
        let diagnostic = try XCTUnwrap(events.first)
        XCTAssertEqual(diagnostic.path, .preserve)
        XCTAssertEqual(diagnostic.committedHasPrefix, false)
        XCTAssertEqual(diagnostic.confirmedLen, 2)
        XCTAssertEqual(diagnostic.committedLen, 5)
        XCTAssertEqual(diagnostic.overlapLen, 0)
        assertNoCJKText(diagnostic)
    }

    func testPreservePathFlagsFullPrefixHitWithoutSplicing() throws {
        let (controller, client) = makeController()
        controller.state.partialCommit = PartialCommitState(
            confirmedText: "任务",
            remainingRawInput: "mulu",
            remainingPreeditText: "目录里",
            displayText: "任务目录里"
        )

        controller.applyRimeOutput(
            RimeOutput(committedText: "任务目录里", hasMorePages: false)
        )

        // Full prefix hit: committedText is used as-is, no double splice.
        XCTAssertEqual(client.text, "任务目录里")
        XCTAssertEqual(events.count, 1)
        let diagnostic = try XCTUnwrap(events.first)
        XCTAssertEqual(diagnostic.path, .preserve)
        XCTAssertEqual(diagnostic.committedHasPrefix, true)
        XCTAssertEqual(diagnostic.confirmedLen, 2)
        XCTAssertEqual(diagnostic.committedLen, 5)
        // Max common length of the confirmed suffix and committed prefix.
        XCTAssertEqual(diagnostic.overlapLen, 2)
        assertNoCJKText(diagnostic)
    }

    // MARK: - Finish path (finishNormalCandidateSelection)

    func testFinishPathEmitsOverlapFieldsForSuffixPrefixOverlap() throws {
        let (controller, client) = makeController()
        controller.state.partialCommit = PartialCommitState(
            confirmedText: "记进任务",
            remainingRawInput: "mulu",
            remainingPreeditText: "目录里",
            displayText: "记进任务目录里"
        )

        // A result without raw/preedit forces applyNormalCandidateSelection
        // into finishNormalCandidateSelection (the final splice point).
        controller.applyNormalCandidateSelection(
            candidate: "任务目录里",
            result: RimeOutput(hasMorePages: false),
            previousOutput: RimeOutput(
                rawInput: "mulu",
                composition: RimeComposition(preeditText: "目录里", cursorPosition: 3),
                hasMorePages: false
            )
        )

        XCTAssertEqual(client.text, "记进任务任务目录里")
        XCTAssertEqual(events.count, 1)
        let diagnostic = try XCTUnwrap(events.first)
        XCTAssertEqual(diagnostic.path, .finish)
        XCTAssertEqual(diagnostic.committedHasPrefix, false)
        XCTAssertEqual(diagnostic.confirmedLen, 4)
        XCTAssertEqual(diagnostic.committedLen, 5)
        XCTAssertEqual(diagnostic.overlapLen, 2)
        assertNoCJKText(diagnostic)
    }

    func testFinishPathEmitsZeroOverlapWhenSuffixAndPrefixDiffer() throws {
        let (controller, client) = makeController()
        controller.state.partialCommit = PartialCommitState(
            confirmedText: "日记",
            remainingRawInput: "renwu",
            remainingPreeditText: "任务目录里",
            displayText: "日记任务目录里"
        )

        controller.applyNormalCandidateSelection(
            candidate: "任务目录里",
            result: RimeOutput(hasMorePages: false),
            previousOutput: RimeOutput(
                rawInput: "renwu",
                composition: RimeComposition(preeditText: "任务目录里", cursorPosition: 5),
                hasMorePages: false
            )
        )

        XCTAssertEqual(client.text, "日记任务目录里")
        XCTAssertEqual(events.count, 1)
        let diagnostic = try XCTUnwrap(events.first)
        XCTAssertEqual(diagnostic.path, .finish)
        XCTAssertEqual(diagnostic.committedHasPrefix, false)
        XCTAssertEqual(diagnostic.confirmedLen, 2)
        XCTAssertEqual(diagnostic.committedLen, 5)
        XCTAssertEqual(diagnostic.overlapLen, 0)
        assertNoCJKText(diagnostic)
    }

    func testFinishPathWithoutPartialCommitStillEmitsEmptyConfirmedFields() throws {
        let (controller, client) = makeController()

        controller.applyNormalCandidateSelection(
            candidate: "任务目录里",
            result: RimeOutput(hasMorePages: false),
            previousOutput: RimeOutput(
                rawInput: "renwu",
                composition: RimeComposition(preeditText: "任务目录里", cursorPosition: 5),
                hasMorePages: false
            )
        )

        XCTAssertEqual(client.text, "任务目录里")
        XCTAssertEqual(events.count, 1)
        let diagnostic = try XCTUnwrap(events.first)
        XCTAssertEqual(diagnostic.path, .finish)
        XCTAssertEqual(diagnostic.committedHasPrefix, true)
        XCTAssertEqual(diagnostic.confirmedLen, 0)
        XCTAssertEqual(diagnostic.committedLen, 5)
        XCTAssertEqual(diagnostic.overlapLen, 0)
        assertNoCJKText(diagnostic)
    }

    // MARK: - Wire validator coverage

    func testWireValidatorAcceptsPartialCommitOverlapEvent() throws {
        let event = DiagnosticEvent(
            utcTimestamp: Date(),
            monotonicNanoseconds: 1,
            origin: .keyboardExtension,
            processInstanceID: UUID(),
            localSequence: 1,
            code: .partialCommitOverlap,
            level: .info,
            category: .display,
            fields: [
                .reason(.partialCommitPathFinish),
                .flag(.partialCommitCommittedHasPrefix, false),
                .count(.partialCommitConfirmedLen, 4),
                .count(.partialCommitCommittedLen, 5),
                .count(.partialCommitOverlapLen, 2),
            ]
        )
        let data = try JSONEncoder().encode(event)
        XCTAssertNil(DiagnosticEventWireValidator.rejectionReason(for: data))
    }
}
