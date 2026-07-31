import XCTest

@testable import KeyboardCore

#if DEBUG
@MainActor
final class T9ShadowAnchorAnalyzerTests: XCTestCase {
    private let sharedPrefixDigits = "546842633842674"
    private let sharedPrefixComments = [
        "jin tian de tian qi",
        "jin tian de tian ri",
        "jin tian de tian si",
    ]

    func testCompleteSnapshotFindsClosedCommonPrefixBySyllable() {
        let observation = analyze(
            digits: sharedPrefixDigits,
            comments: sharedPrefixComments
        )

        XCTAssertEqual(observation.status, .proposalReady)
        XCTAssertTrue(observation.evidenceComplete)
        XCTAssertEqual(observation.candidateCount, 3)
        XCTAssertEqual(observation.compatibleCandidateCount, 3)
        XCTAssertEqual(observation.uniqueCompatiblePathCount, 3)
        XCTAssertEqual(observation.rejectedCandidateCount, 0)
        XCTAssertEqual(observation.observedCommonSyllableCount, 4)
        XCTAssertEqual(observation.closedCommonSyllableCount, 4)
        XCTAssertEqual(observation.anchorSlotCount, 13)
        XCTAssertEqual(observation.unresolvedSlotCount, 2)
    }

    func testSingleObservedPathKeepsLastSyllableUnresolved() {
        let observation = analyze(
            digits: "5468426",
            comments: ["jin tian"]
        )

        XCTAssertEqual(observation.status, .proposalReady)
        XCTAssertEqual(observation.observedCommonSyllableCount, 2)
        XCTAssertEqual(observation.closedCommonSyllableCount, 1)
        XCTAssertEqual(observation.anchorSlotCount, 3)
        XCTAssertEqual(observation.unresolvedSlotCount, 4)
    }

    func testCandidateRankingOrderDoesNotChangeCommonPrefixMetrics() {
        let forward = analyze(
            digits: sharedPrefixDigits,
            comments: sharedPrefixComments
        )
        let personalizedOrder = analyze(
            digits: sharedPrefixDigits,
            comments: sharedPrefixComments.reversed()
        )

        XCTAssertEqual(forward.status, personalizedOrder.status)
        XCTAssertEqual(
            forward.closedCommonSyllableCount,
            personalizedOrder.closedCommonSyllableCount
        )
        XCTAssertEqual(forward.anchorSlotCount, personalizedOrder.anchorSlotCount)
        XCTAssertEqual(forward.unresolvedSlotCount, personalizedOrder.unresolvedSlotCount)
    }

    func testPreferredTopCandidateCannotOverrideDivergentPath() {
        let observation = analyze(
            digits: "5468426",
            comments: [
                "jin tian", // Personalized top candidate.
                "lin tian",
            ]
        )

        XCTAssertEqual(observation.status, .noClosedCommonPrefix)
        XCTAssertTrue(observation.evidenceComplete)
        XCTAssertEqual(observation.closedCommonSyllableCount, 0)
        XCTAssertEqual(observation.anchorSlotCount, 0)
    }

    func testMoreCandidatePagesBlockProposalButKeepObservedCounts() {
        let observation = analyze(
            digits: sharedPrefixDigits,
            comments: sharedPrefixComments,
            hasMorePages: true
        )

        XCTAssertEqual(observation.status, .candidateSetIncomplete)
        XCTAssertFalse(observation.evidenceComplete)
        XCTAssertFalse(observation.isProposalReady)
        XCTAssertEqual(observation.observedCommonSyllableCount, 4)
        XCTAssertEqual(observation.closedCommonSyllableCount, 4)
        XCTAssertEqual(observation.anchorSlotCount, 13)
    }

    func testNonInitialCandidatePageBlocksProposal() {
        let observation = analyze(
            digits: sharedPrefixDigits,
            comments: sharedPrefixComments,
            candidatePageNumber: 1
        )

        XCTAssertEqual(observation.status, .nonInitialCandidatePage)
        XCTAssertFalse(observation.evidenceComplete)
        XCTAssertFalse(observation.isProposalReady)
    }

    func testMissingOrIncompatibleCommentBlocksProposal() {
        let candidates = [
            RimeCandidate(text: "合成候选", comment: "jin tian"),
            RimeCandidate(text: "缺少注音", comment: nil),
        ]
        let output = RimeOutput(
            rawInput: "5468426",
            candidates: candidates,
            candidatePageNumber: 0
        )

        let observation = T9ShadowAnchorAnalyzer.analyze(
            sourceDigits: "5468426",
            output: output,
            rawInputGeneration: 1,
            provenanceRevision: 1
        )

        XCTAssertEqual(observation.status, .incompletePathEvidence)
        XCTAssertFalse(observation.evidenceComplete)
        XCTAssertEqual(observation.compatibleCandidateCount, 1)
        XCTAssertEqual(observation.rejectedCandidateCount, 1)
        XCTAssertFalse(observation.isProposalReady)
    }

    func testStaleRevisionAndInvalidDigitIdentityFailClosed() {
        let output = makeOutput(
            comments: ["jin tian"]
        )

        let stale = T9ShadowAnchorAnalyzer.analyze(
            sourceDigits: "5468426",
            output: output,
            rawInputGeneration: 0,
            provenanceRevision: 1
        )
        XCTAssertEqual(stale.status, .staleSnapshot)

        let invalidDigits = T9ShadowAnchorAnalyzer.analyze(
            sourceDigits: "5461026",
            output: output,
            rawInputGeneration: 1,
            provenanceRevision: 1
        )
        XCTAssertEqual(invalidDigits.status, .invalidSourceDigits)
    }

    func testControllerObservationDoesNotMutateKeyboardState() {
        let output = makeOutput(comments: ["jin tian"])
        let pathState = T9PinyinPathState(
            rawInputGeneration: 3,
            provenanceRevision: 5,
            trackedRawInput: "5468426",
            segmentSourceDigits: "5468426"
        )
        let controller = KeyboardController(
            state: KeyboardState(
                currentComposition: "5468426",
                lastRimeOutput: output,
                t9PinyinPathState: pathState
            )
        )
        controller.usesT9InputSemantics = true
        let stateBefore = controller.state

        let observation = controller.t9ShadowAnchorObservation()

        XCTAssertEqual(observation.status, .proposalReady)
        XCTAssertEqual(controller.state, stateBefore)
    }

    private func analyze(
        digits: String,
        comments: some Sequence<String>,
        hasMorePages: Bool = false,
        candidatePageNumber: Int = 0
    ) -> T9ShadowAnchorObservation {
        T9ShadowAnchorAnalyzer.analyze(
            sourceDigits: digits,
            output: makeOutput(
                comments: comments,
                hasMorePages: hasMorePages,
                candidatePageNumber: candidatePageNumber
            ),
            rawInputGeneration: 7,
            provenanceRevision: 11
        )
    }

    private func makeOutput(
        comments: some Sequence<String>,
        hasMorePages: Bool = false,
        candidatePageNumber: Int = 0
    ) -> RimeOutput {
        RimeOutput(
            rawInput: sharedPrefixDigits,
            composition: RimeComposition(preeditText: "", cursorPosition: 0),
            candidates: comments.enumerated().map { index, comment in
                RimeCandidate(
                    text: "合成候选\(index)",
                    comment: comment,
                    globalIndex: index
                )
            },
            hasMorePages: hasMorePages,
            highlightedIndex: 0,
            candidatePageNumber: candidatePageNumber
        )
    }
}
#endif
