import XCTest
@testable import KeyboardCore

@MainActor
final class T9ReversibleAutoAnchorTests: XCTestCase {
    private let compactConfiguration = T9ReversibleAutoAnchorPolicy.Configuration(
        minimumSourceDigitCount: 10,
        evidenceCandidateLimit: 5,
        minimumCompatibleCandidateCount: 1,
        minimumClosedSyllableCount: 2,
        minimumAnchoredSlotCount: 6,
        minimumUnresolvedSlotCount: 3,
        minimumCandidateOverlapPercent: 60
    )

    func testProposalBuildsCatalogLegalClosedPrefixAndLeavesDigitTail() {
        let source = digits(for: "jintianhenhao")
        let output = output(
            raw: source,
            texts: ["甲", "乙", "丙"],
            comments: [
                "jin tian hen hao",
                "jin tian gen hao",
                "jin tian hen gao",
            ],
            hasMorePages: true
        )

        let proposal = T9ReversibleAutoAnchorPolicy.proposal(
            sourceDigits: source,
            output: output,
            configuration: compactConfiguration
        )

        XCTAssertEqual(proposal?.anchoredSyllables, ["jin", "tian"])
        XCTAssertEqual(proposal?.anchoredSlotCount, 7)
        XCTAssertEqual(proposal?.unresolvedSlotCount, source.count - 7)
        XCTAssertEqual(
            proposal?.replacementRawInput,
            "jin'tian'" + String(source.dropFirst(7))
        )
        // Stage 2 intentionally permits bounded first-page preference even
        // when RIME reports later candidates.
        XCTAssertTrue(output.hasMorePages)
    }

    func testProposalRejectsCompatiblePathDivergenceRegardlessOfRanking() {
        let source = digits(for: "jintianhenhao")
        let jinFirst = output(
            raw: source,
            texts: ["甲", "乙", "丙"],
            comments: [
                "jin tian hen hao",
                "lin tian gen hao",
                "jin tian hen gao",
            ]
        )

        XCTAssertNil(
            T9ReversibleAutoAnchorPolicy.proposal(
                sourceDigits: source,
                output: jinFirst,
                configuration: compactConfiguration
            )
        )

        // `jin` and `lin` share the same T9 identity. Reordering them can
        // reflect local user-dictionary preference, but ranking alone must not
        // turn a real spelling disagreement into automatic Path authority.
        let linFirst = output(
            raw: source,
            texts: ["乙", "甲", "丙"],
            comments: [
                "lin tian gen hao",
                "jin tian hen hao",
                "lin tian hen gao",
            ]
        )
        XCTAssertNil(
            T9ReversibleAutoAnchorPolicy.proposal(
                sourceDigits: source,
                output: linFirst,
                configuration: compactConfiguration
            )
        )
    }

    func testProposalRequiresCompatibleFirstCandidateButIgnoresIncompatibleTail() {
        let source = digits(for: "jintianhenhao")
        let incompatibleTail = output(
            raw: source,
            texts: ["甲", "乙", "丙"],
            comments: ["jin tian hen hao", "", "jin tian hen gao"]
        )
        XCTAssertNotNil(
            T9ReversibleAutoAnchorPolicy.proposal(
                sourceDigits: source,
                output: incompatibleTail,
                configuration: compactConfiguration
            )
        )

        let missingFirst = output(
            raw: source,
            texts: ["甲", "乙", "丙"],
            comments: ["", "jin tian gen hao", "jin tian hen gao"]
        )
        XCTAssertNil(
            T9ReversibleAutoAnchorPolicy.proposal(
                sourceDigits: source,
                output: missingFirst,
                configuration: compactConfiguration
            )
        )

        // `jkn` is digit-compatible with 556, but is not a legal catalog
        // syllable and therefore cannot authorize the first-candidate path.
        let nonCatalogSource = digits(for: "jkntianhenhao")
        let nonCatalog = output(
            raw: nonCatalogSource,
            texts: ["甲", "乙", "丙"],
            comments: [
                "jkn tian hen hao",
                "jkn tian gen hao",
                "jkn tian hen gao",
            ]
        )
        XCTAssertNil(
            T9ReversibleAutoAnchorPolicy.proposal(
                sourceDigits: nonCatalogSource,
                output: nonCatalog,
                configuration: compactConfiguration
            )
        )
    }

    func testValidationRequiresFirstCandidateAndBoundedOverlap() throws {
        let source = digits(for: "jintianhenhao")
        let baseline = output(
            raw: source,
            texts: ["首选", "第二", "第三", "第四", "第五"],
            comments: Array(repeating: "jin tian hen hao", count: 5)
        )
        let proposal = try XCTUnwrap(
            T9ReversibleAutoAnchorPolicy.proposal(
                sourceDigits: source,
                output: baseline,
                configuration: compactConfiguration
            )
        )

        let accepted = output(
            raw: proposal.replacementRawInput,
            texts: ["首选", "第三", "第五", "新一", "新二"],
            comments: Array(repeating: "jin tian hen hao", count: 5)
        )
        XCTAssertTrue(
            T9ReversibleAutoAnchorPolicy.validate(
                proposal: proposal,
                result: accepted,
                configuration: compactConfiguration
            ).isAccepted
        )

        let changedFirst = output(
            raw: proposal.replacementRawInput,
            texts: ["第二", "首选", "第三", "第四", "第五"],
            comments: Array(repeating: "jin tian hen hao", count: 5)
        )
        XCTAssertFalse(
            T9ReversibleAutoAnchorPolicy.validate(
                proposal: proposal,
                result: changedFirst,
                configuration: compactConfiguration
            ).isAccepted
        )

        let exactlyTwoOfFive = output(
            raw: proposal.replacementRawInput,
            texts: ["首选", "第三", "新一", "新二", "新三"],
            comments: Array(repeating: "jin tian hen hao", count: 5)
        )
        XCTAssertFalse(
            T9ReversibleAutoAnchorPolicy.validate(
                proposal: proposal,
                result: exactlyTwoOfFive,
                configuration: compactConfiguration
            ).isAccepted,
            "60% of a five-candidate evidence window requires three conserved candidates"
        )

        let insufficientOverlap = output(
            raw: proposal.replacementRawInput,
            texts: ["首选", "新一", "新二", "新三", "新四"],
            comments: Array(repeating: "jin tian hen hao", count: 5)
        )
        XCTAssertFalse(
            T9ReversibleAutoAnchorPolicy.validate(
                proposal: proposal,
                result: insufficientOverlap,
                configuration: compactConfiguration
            ).isAccepted
        )
    }

    func testValidationUsesOriginalWindowForRepeatedCandidateTexts() throws {
        let source = digits(for: "jintianhenhao")
        let baseline = output(
            raw: source,
            texts: ["首选", "首选", "第二", "第二", "第三"],
            comments: Array(repeating: "jin tian hen hao", count: 5)
        )
        let proposal = try XCTUnwrap(
            T9ReversibleAutoAnchorPolicy.proposal(
                sourceDigits: source,
                output: baseline,
                configuration: compactConfiguration
            )
        )

        let onlyTwoConservedSlots = output(
            raw: proposal.replacementRawInput,
            texts: ["首选", "第二", "新一", "新二", "新三"],
            comments: Array(repeating: "jin tian hen hao", count: 5)
        )
        let rejected = T9ReversibleAutoAnchorPolicy.validate(
            proposal: proposal,
            result: onlyTwoConservedSlots,
            configuration: compactConfiguration
        )
        XCTAssertFalse(
            rejected.isAccepted,
            "duplicate baseline text must not reduce a five-slot window below the 3/5 threshold"
        )
        XCTAssertEqual(rejected.overlappingCandidateCount, 2)

        let threeConservedSlots = output(
            raw: proposal.replacementRawInput,
            texts: ["首选", "首选", "第二", "新一", "新二"],
            comments: Array(repeating: "jin tian hen hao", count: 5)
        )
        let accepted = T9ReversibleAutoAnchorPolicy.validate(
            proposal: proposal,
            result: threeConservedSlots,
            configuration: compactConfiguration
        )
        XCTAssertTrue(accepted.isAccepted)
        XCTAssertEqual(accepted.overlappingCandidateCount, 3)
    }

    func testControllerAcceptsOnlyOneAnchorAndExtendsRollbackLedger() {
        let fixture = makeControllerFixture()

        type(fixture.sourceDigits, on: fixture.controller)

        XCTAssertEqual(
            fixture.controller.state.t9ReversibleAutoAnchorState.phase,
            .accepted
        )
        XCTAssertEqual(
            fixture.controller.state.t9ReversibleAutoAnchorState.sourceDigits,
            fixture.sourceDigits
        )
        XCTAssertEqual(fixture.engine.replaceInputArguments, [fixture.anchoredRaw])
        XCTAssertEqual(fixture.engine.candidateWindowCallCount, 0)

        fixture.engine.dictionary[fixture.anchoredRaw + "2"] = fixture.candidates
        fixture.engine.comments[fixture.anchoredRaw + "2"] = fixture.comments
        _ = fixture.controller.handle(.insertKey("2"))

        XCTAssertEqual(
            fixture.engine.sessionComposition,
            fixture.anchoredRaw + "2",
            "继续输入时不应被 Path 重同步回纯数字，从而丢失已经生效的锚定"
        )
        XCTAssertEqual(
            fixture.controller.state.lastRimeOutput?.rawInput,
            fixture.anchoredRaw + "2"
        )
        XCTAssertEqual(fixture.engine.replaceInputCallCount, 1)
        XCTAssertEqual(
            fixture.engine.replaceInputArguments.filter {
                $0 == fixture.anchoredRaw
            }.count,
            1
        )
        XCTAssertEqual(
            fixture.controller.state.t9ReversibleAutoAnchorState.phase,
            .accepted
        )
        XCTAssertEqual(
            fixture.controller.state.t9ReversibleAutoAnchorState.sourceDigits,
            fixture.sourceDigits + "2"
        )
    }

    func testControllerRejectsCandidateDriftRestoresDigitsAndDoesNotRetry() {
        let fixture = makeControllerFixture()
        fixture.engine.dictionary[fixture.anchoredRaw] = [
            "不同首选", fixture.candidates[0], fixture.candidates[1],
        ]
        fixture.engine.comments[fixture.anchoredRaw] = fixture.comments

        type(fixture.sourceDigits, on: fixture.controller)

        XCTAssertEqual(
            fixture.controller.state.t9ReversibleAutoAnchorState.phase,
            .rejected
        )
        XCTAssertEqual(
            fixture.controller.state.lastRimeOutput?.rawInput,
            fixture.sourceDigits
        )
        XCTAssertEqual(
            fixture.engine.replaceInputArguments,
            [fixture.anchoredRaw, fixture.sourceDigits]
        )

        fixture.engine.dictionary[fixture.sourceDigits + "2"] = fixture.candidates
        fixture.engine.comments[fixture.sourceDigits + "2"] = fixture.comments
        _ = fixture.controller.handle(.insertKey("2"))
        XCTAssertEqual(fixture.engine.replaceInputCallCount, 2)
    }

    func testDeleteRestoresDigitLedgerBeforeNormalDeletion() {
        let fixture = makeControllerFixture()
        type(fixture.sourceDigits, on: fixture.controller)
        let callsBeforeDelete = fixture.engine.replaceInputCallCount

        _ = fixture.controller.handle(.deleteBackward)

        XCTAssertGreaterThan(fixture.engine.replaceInputCallCount, callsBeforeDelete)
        XCTAssertEqual(
            fixture.engine.replaceInputArguments[callsBeforeDelete],
            fixture.sourceDigits
        )
        XCTAssertNotEqual(
            fixture.controller.state.t9ReversibleAutoAnchorState.phase,
            .accepted
        )
        XCTAssertFalse(
            fixture.controller.state.insertedPreeditText.contains {
                $0.isNumber
            }
        )
    }

    func testPartialCommitClearsAcceptedLedgerBeforeContinuedTyping() throws {
        let fixture = makeControllerFixture(partialSelectionRemainder: "42")
        type(fixture.sourceDigits, on: fixture.controller)
        XCTAssertEqual(
            fixture.controller.state.t9ReversibleAutoAnchorState.phase,
            .accepted
        )

        _ = fixture.controller.handle(
            .insertCandidate(
                fixture.candidates[1],
                kind: .candidate,
                selectionReference: CandidateSelectionReference(page: 0, indexOnPage: 1)
            )
        )

        let partialRemainder = try XCTUnwrap(
            fixture.controller.state.partialCommit?.remainingRawInput
        )
        XCTAssertFalse(partialRemainder.isEmpty)
        XCTAssertEqual(
            fixture.controller.state.t9ReversibleAutoAnchorState,
            T9ReversibleAutoAnchorState(phase: .rejected)
        )

        _ = fixture.controller.handle(.insertKey("6"))

        XCTAssertEqual(
            fixture.controller.state.partialCommit?.remainingRawInput,
            partialRemainder + "6"
        )
        XCTAssertEqual(
            fixture.controller.state.t9ReversibleAutoAnchorState,
            T9ReversibleAutoAnchorState(phase: .rejected),
            "continued remainder input must not append to the previous composition ledger"
        )
    }

    func testPartialCommitDeleteDoesNotRestoreOldAutoAnchorLedger() {
        let fixture = makeControllerFixture(partialSelectionRemainder: "42")
        type(fixture.sourceDigits, on: fixture.controller)

        _ = fixture.controller.handle(
            .insertCandidate(
                fixture.candidates[1],
                kind: .candidate,
                selectionReference: CandidateSelectionReference(page: 0, indexOnPage: 1)
            )
        )
        XCTAssertNotNil(fixture.controller.state.partialCommit)
        XCTAssertEqual(
            fixture.controller.state.t9ReversibleAutoAnchorState,
            T9ReversibleAutoAnchorState(phase: .rejected)
        )
        let callsBeforeDelete = fixture.engine.replaceInputCallCount

        _ = fixture.controller.handle(.deleteBackward)

        XCTAssertEqual(
            fixture.engine.replaceInputArguments[callsBeforeDelete],
            fixture.anchoredRaw,
            "Delete should restore the user-owned partial checkpoint, not the old digit ledger"
        )
        XCTAssertEqual(
            fixture.controller.state.t9ReversibleAutoAnchorState,
            T9ReversibleAutoAnchorState(phase: .rejected)
        )
        XCTAssertFalse(
            fixture.engine.replaceInputArguments.dropFirst(callsBeforeDelete)
                .contains(fixture.sourceDigits),
            "the ended auto-anchor transaction must not run a second rollback"
        )

        _ = fixture.controller.handle(.insertKey("6"))
        XCTAssertEqual(
            fixture.controller.state.t9ReversibleAutoAnchorState,
            T9ReversibleAutoAnchorState(phase: .rejected),
            "undoing the partial must not grant a second auto-anchor attempt or restore old ledger data"
        )
    }

    func testDisabledGateNeverCallsReplaceInput() {
        let fixture = makeControllerFixture()
        fixture.controller.isReversibleT9AutoAnchorEnabled = false

        type(fixture.sourceDigits, on: fixture.controller)

        XCTAssertEqual(fixture.engine.replaceInputCallCount, 0)
        XCTAssertEqual(
            fixture.controller.state.t9ReversibleAutoAnchorState,
            .empty
        )
    }

    func testFailedRollbackClearsUntrustedCompositionWithoutLeakingDigits() {
        let fixture = makeControllerFixture()
        fixture.engine.replaceInputScript = [
            output(
                raw: fixture.anchoredRaw,
                texts: ["不同首选", fixture.candidates[0], fixture.candidates[1]],
                comments: fixture.comments
            ),
            RimeOutput(),
        ]

        type(fixture.sourceDigits, on: fixture.controller)

        XCTAssertEqual(fixture.engine.sessionResetCount, 1)
        XCTAssertNil(fixture.controller.state.lastRimeOutput)
        XCTAssertTrue(fixture.controller.state.currentComposition.isEmpty)
        XCTAssertTrue(fixture.controller.state.insertedPreeditText.isEmpty)
        XCTAssertEqual(
            fixture.controller.state.t9ReversibleAutoAnchorState.phase,
            .rejected
        )
        XCTAssertFalse(
            (fixture.controller.textClient as? FakeTextInputClient)?
                .text.contains(where: \.isNumber)
                ?? false
        )
    }

    // MARK: - Fixtures

    private func makeControllerFixture(
        partialSelectionRemainder: String? = nil
    ) -> (
        controller: KeyboardController,
        engine: FakeRimeEngine,
        sourceDigits: String,
        anchoredRaw: String,
        candidates: [String],
        comments: [String]
    ) {
        let source = digits(for: "jintiandetianqihen")
        let anchored = "jin'tian'de'tian'" + String(source.dropFirst(13))
        let candidates = ["今天天气很好", "今天的天气很", "今日天气很好", "今天气候很好", "今天的天很好"]
        let comments = Array(repeating: "jin tian de tian qi hen", count: candidates.count)
        var dictionary = [
            source: candidates,
            anchored: candidates,
        ]
        var candidateComments = [
            source: comments,
            anchored: comments,
        ]
        var selectionRemainders: [String: [Int: String]] = [:]
        if let partialSelectionRemainder {
            dictionary[partialSelectionRemainder] = ["嘎", "哈", "伽"]
            candidateComments[partialSelectionRemainder] = ["ga", "ha", "ga"]
            dictionary[partialSelectionRemainder + "6"] = ["干", "喊", "感"]
            candidateComments[partialSelectionRemainder + "6"] = ["gan", "han", "gan"]
            selectionRemainders[anchored] = [1: partialSelectionRemainder]
        }
        let engine = FakeRimeEngine(
            dictionary: dictionary,
            comments: candidateComments,
            selectionRemainders: selectionRemainders
        )
        engine.appendDigitsToComposition = true
        let controller = KeyboardController()
        controller.textClient = FakeTextInputClient()
        controller.rimeEngine = engine
        controller.usesT9InputSemantics = true
        controller.isReversibleT9AutoAnchorEnabled = true
        return (controller, engine, source, anchored, candidates, comments)
    }

    private func type(_ digits: String, on controller: KeyboardController) {
        for digit in digits {
            _ = controller.handle(.insertKey(String(digit)))
        }
    }

    private func output(
        raw: String,
        texts: [String],
        comments: [String],
        hasMorePages: Bool = false
    ) -> RimeOutput {
        RimeOutput(
            rawInput: raw,
            composition: RimeComposition(preeditText: raw, cursorPosition: raw.count),
            candidates: texts.enumerated().map { index, text in
                RimeCandidate(
                    text: text,
                    comment: comments.indices.contains(index) ? comments[index] : nil,
                    globalIndex: index
                )
            },
            hasMorePages: hasMorePages,
            highlightedIndex: texts.isEmpty ? -1 : 0
        )
    }

    private func digits(for pinyin: String) -> String {
        let groups: [(String, Character)] = [
            ("abc", "2"), ("def", "3"), ("ghi", "4"), ("jkl", "5"),
            ("mno", "6"), ("pqrs", "7"), ("tuv", "8"), ("wxyz", "9"),
        ]
        let mapping = Dictionary(
            uniqueKeysWithValues: groups.flatMap { letters, digit in
                letters.map { ($0, digit) }
            }
        )
        return String(pinyin.map { mapping[$0]! })
    }
}
