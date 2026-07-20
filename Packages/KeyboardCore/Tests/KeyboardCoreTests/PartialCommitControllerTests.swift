import XCTest

@testable import KeyboardCore

@MainActor
final class PartialCommitControllerTests: XCTestCase {
    private let dictionary = [
        "nihaoanpai": ["你好安排", "你好"],
        "nihaoanpa": ["你好安帕"],
        "anpai": ["安排", "按排"],
        "anpaix": ["安排下"],
    ]

    func testNormalCandidatePartialCommitKeepsRemainingInputVisibleAndRefreshesCandidates() {
        let (controller, client, _) = makeController()
        type("nihaoanpai", into: controller)

        _ = controller.handle(
            .insertCandidate(
                "你好",
                kind: .candidate,
                selectionReference: CandidateSelectionReference(page: 0, indexOnPage: 1)
            )
        )

        XCTAssertEqual(client.text, "你好anpai")
        XCTAssertEqual(client.markedText, "你好anpai")
        XCTAssertEqual(controller.state.currentComposition, "anpai")
        XCTAssertEqual(controller.state.insertedPreeditText, "你好anpai")
        XCTAssertEqual(controller.state.lastRimeOutput?.rawInput, "anpai")
        XCTAssertEqual(controller.state.lastRimeOutput?.candidates.map(\.text), ["安排", "按排"])
        XCTAssertEqual(controller.state.partialCommit?.confirmedText, "你好")
        XCTAssertEqual(controller.state.partialCommit?.remainingRawInput, "anpai")
        XCTAssertNotNil(controller.state.partialCommit?.checkpoint)
        XCTAssertNil(controller.state.typoCorrection)
    }

    func testFirstDeleteRestoresPreviousCompositionAndSecondDeleteDeletesNormally() {
        let (controller, client, _) = makeController()
        type("nihaoanpai", into: controller)
        selectNihao(using: controller)

        _ = controller.handle(.deleteBackward)

        XCTAssertEqual(client.text, "nihaoanpai")
        XCTAssertEqual(client.markedText, "nihaoanpai")
        XCTAssertEqual(controller.state.currentComposition, "nihaoanpai")
        XCTAssertEqual(controller.state.lastRimeOutput?.rawInput, "nihaoanpai")
        XCTAssertNil(controller.state.partialCommit)

        _ = controller.handle(.deleteBackward)

        XCTAssertEqual(client.text, "nihaoanpa")
        XCTAssertEqual(controller.state.currentComposition, "nihaoanpa")
    }

    func testTypingAfterPartialCommitKeepsConfirmedPrefixAndInvalidatesCheckpoint() {
        let (controller, client, _) = makeController()
        type("nihaoanpai", into: controller)
        selectNihao(using: controller)

        _ = controller.handle(.insertKey("x"))

        XCTAssertEqual(client.text, "你好anpaix")
        XCTAssertEqual(client.markedText, "你好anpaix")
        XCTAssertEqual(controller.state.currentComposition, "anpaix")
        XCTAssertEqual(controller.state.partialCommit?.displayText, "你好anpaix")
        XCTAssertNil(controller.state.partialCommit?.checkpoint)

        _ = controller.handle(.deleteBackward)

        XCTAssertEqual(client.text, "你好anpai")
        XCTAssertEqual(client.markedText, "你好anpai")
        XCTAssertEqual(controller.state.currentComposition, "anpai")
        XCTAssertNotNil(controller.state.partialCommit)
    }

    func testFullCandidateSelectionKeepsExistingFullCommitBehavior() {
        let (controller, client, _) = makeController()
        type("nihaoanpai", into: controller)

        _ = controller.handle(
            .insertCandidate(
                "你好安排",
                kind: .candidate,
                selectionReference: CandidateSelectionReference(page: 0, indexOnPage: 0)
            )
        )

        XCTAssertEqual(client.text, "你好安排")
        XCTAssertEqual(client.markedText, "")
        XCTAssertEqual(controller.state.currentComposition, "")
        XCTAssertNil(controller.state.partialCommit)
    }

    func testFinalCandidateAfterPartialCommitCommitsCombinedText() {
        let (controller, client, _) = makeController()
        type("nihaoanpai", into: controller)
        selectNihao(using: controller)

        _ = controller.handle(
            .insertCandidate(
                "安排",
                kind: .candidate,
                selectionReference: CandidateSelectionReference(page: 0, indexOnPage: 0)
            )
        )

        XCTAssertEqual(client.text, "你好安排")
        XCTAssertEqual(client.markedText, "")
        XCTAssertEqual(controller.state.currentComposition, "")
        XCTAssertNil(controller.state.partialCommit)
    }

    func testPairedSymbolAfterPartialCommitCommitsRemainingCandidateBeforePair() {
        let engine = FakeRimeEngine(
            dictionary: [
                "haizhaodedao": ["还找得到", "还找"],
                "dedao": ["得到"],
            ],
            selectionRemainders: ["haizhaodedao": [1: "dedao"]]
        )
        let (controller, client) = makeController(engine: engine)
        type("haizhaodedao", into: controller)

        _ = controller.handle(
            .insertCandidate(
                "还找",
                kind: .candidate,
                selectionReference: CandidateSelectionReference(page: 0, indexOnPage: 1)
            )
        )
        _ = controller.handle(.togglePage)
        let effects = controller.handle(.insertKey("（"))

        XCTAssertEqual(client.text, "还找得到（）")
        XCTAssertEqual(client.markedText, "")
        XCTAssertEqual(client.cursorOffset, "还找得到（".count)
        XCTAssertEqual(controller.state.currentComposition, "")
        XCTAssertNil(controller.state.partialCommit)
        XCTAssertNil(controller.state.lastRimeOutput?.composition)
        XCTAssertEqual(controller.state.lastRimeOutput?.candidates, [])
        XCTAssertEqual(controller.state.lastRimeOutput?.committedText, "还找得到")
        XCTAssertEqual(controller.state.currentPage, .letters)
        XCTAssertTrue(effects.contains(.compositionChanged))
        XCTAssertTrue(effects.contains(.pageChanged))
    }

    func testDisabledPairedSymbolCompletionAfterPartialCommitCommitsRemainingCandidateBeforeSingleSymbol() {
        let engine = FakeRimeEngine(
            dictionary: [
                "haizhaodedao": ["还找得到", "还找"],
                "dedao": ["得到"],
            ],
            selectionRemainders: ["haizhaodedao": [1: "dedao"]]
        )
        let (controller, client) = makeController(engine: engine)
        controller.isPairedSymbolCompletionEnabled = false
        type("haizhaodedao", into: controller)

        _ = controller.handle(
            .insertCandidate(
                "还找",
                kind: .candidate,
                selectionReference: CandidateSelectionReference(page: 0, indexOnPage: 1)
            )
        )
        _ = controller.handle(.togglePage)
        let effects = controller.handle(.insertKey("（"))

        XCTAssertEqual(client.text, "还找得到（")
        XCTAssertEqual(client.markedText, "")
        XCTAssertEqual(client.cursorOffset, "还找得到（".count)
        XCTAssertEqual(controller.state.currentComposition, "")
        XCTAssertNil(controller.state.partialCommit)
        XCTAssertNil(controller.state.lastRimeOutput?.composition)
        XCTAssertEqual(controller.state.lastRimeOutput?.candidates, [])
        XCTAssertEqual(controller.state.lastRimeOutput?.committedText, "还找得到")
        XCTAssertEqual(controller.state.currentPage, .letters)
        XCTAssertTrue(effects.contains(.compositionChanged))
        XCTAssertTrue(effects.contains(.pageChanged))
    }

    func testSelectionReferenceSelectsDuplicateCandidateByIndex() {
        let dictionary = ["nihaoanpai": ["你好", "你好"], "anpai": ["安排"]]
        let engine = FakeRimeEngine(
            dictionary: dictionary,
            selectionRemainders: ["nihaoanpai": [1: "anpai"]]
        )
        let (controller, client) = makeController(engine: engine)
        type("nihaoanpai", into: controller)

        _ = controller.handle(
            .insertCandidate(
                "你好",
                kind: .candidate,
                selectionReference: CandidateSelectionReference(page: 0, indexOnPage: 1)
            )
        )

        XCTAssertEqual(client.text, "你好anpai")
        XCTAssertEqual(client.markedText, "你好anpai")
        XCTAssertNotNil(controller.state.partialCommit)
    }

    func testPartialSelectionUsesTappedCandidateWhenRimeDoesNotEmitCommitText() {
        let engine = FakeRimeEngine(
            dictionary: dictionary,
            selectionRemainders: ["nihaoanpai": [1: "anpai"]],
            partialSelectionEmitsCommit: false
        )
        let (controller, client) = makeController(engine: engine)
        type("nihaoanpai", into: controller)

        selectNihao(using: controller)

        XCTAssertEqual(client.text, "你好anpai")
        XCTAssertEqual(client.markedText, "你好anpai")
        XCTAssertEqual(controller.state.partialCommit?.confirmedText, "你好")
    }

    func testRealRimeStylePartialSelectionDoesNotDuplicateConfirmedSegment() {
        let engine = FakeRimeEngine(
            dictionary: dictionary,
            preeditFormatter: segmentedPreedit,
            selectedSegments: [
                "nihaoanpai": [
                    1: FakeRimeSelectedSegment(rawPrefix: "nihao", text: "你好")
                ]
            ],
            partialSelectionEmitsCommit: false
        )
        let (controller, client) = makeController(engine: engine)
        type("nihaoanpai", into: controller)

        selectNihao(using: controller)

        XCTAssertEqual(client.text, "你好an pai")
        XCTAssertEqual(client.markedText, "你好an pai")
        XCTAssertEqual(controller.state.currentComposition, "an pai")
        XCTAssertEqual(controller.state.partialCommit?.confirmedText, "你好")
        XCTAssertEqual(controller.state.partialCommit?.remainingRawInput, "nihaoanpai")
        XCTAssertEqual(controller.state.partialCommit?.remainingPreeditText, "an pai")
        XCTAssertEqual(controller.state.partialCommit?.displayText, "你好an pai")
        XCTAssertEqual(controller.state.lastRimeOutput?.candidates.map(\.text), ["安排", "按排"])
    }

    func testCheckpointRestoreRebuildsSessionAndRefreshesFullRawCandidates() {
        let engine = FakeRimeEngine(
            dictionary: dictionary,
            preeditFormatter: segmentedPreedit,
            selectedSegments: [
                "nihaoanpai": [
                    1: FakeRimeSelectedSegment(rawPrefix: "nihao", text: "你好")
                ]
            ],
            partialSelectionEmitsCommit: false
        )
        let (controller, client) = makeController(engine: engine)
        type("nihaoanpai", into: controller)
        selectNihao(using: controller)

        _ = controller.handle(.deleteBackward)

        XCTAssertEqual(client.text, "ni hao an pai")
        XCTAssertEqual(client.markedText, "ni hao an pai")
        XCTAssertEqual(controller.state.currentComposition, "ni hao an pai")
        XCTAssertEqual(controller.state.lastRimeOutput?.rawInput, "nihaoanpai")
        XCTAssertEqual(controller.state.lastRimeOutput?.candidates.map(\.text), ["你好安排", "你好"])
        XCTAssertNil(controller.state.partialCommit)

        _ = controller.handle(.deleteBackward)

        XCTAssertEqual(client.text, "ni hao an pa")
        XCTAssertEqual(client.markedText, "ni hao an pa")
        XCTAssertEqual(controller.state.lastRimeOutput?.rawInput, "nihaoanpa")
        XCTAssertEqual(controller.state.lastRimeOutput?.candidates.map(\.text), ["你好安帕"])
    }

    func testDeleteAfterSecondPartialSelectionRestoresOnlyLatestCandidateThenDeletesSuffix() {
        let engine = FakeRimeEngine(
            dictionary: [
                "fangzidouhuizheng": ["房子都会震", "房子"],
                "douhuizheng": ["都会", "都汇"],
                "douhuizhen": ["都会真"],
                "zheng": ["震", "正"],
                "zhen": ["真"],
            ],
            selectedSegments: [
                "fangzidouhuizheng": [
                    1: FakeRimeSelectedSegment(rawPrefix: "fangzi", text: "房子"),
                    0: FakeRimeSelectedSegment(rawPrefix: "fangzidouhui", text: "房子都会"),
                ]
            ],
            partialSelectionEmitsCommit: false
        )
        let (controller, client) = makeController(engine: engine)
        type("fangzidouhuizheng", into: controller)

        _ = controller.handle(
            .insertCandidate(
                "房子",
                kind: .candidate,
                selectionReference: CandidateSelectionReference(page: 0, indexOnPage: 1)
            )
        )
        _ = controller.handle(
            .insertCandidate(
                "都会",
                kind: .candidate,
                selectionReference: CandidateSelectionReference(page: 0, indexOnPage: 0)
            )
        )

        XCTAssertEqual(client.markedText, "房子都会zheng")
        XCTAssertEqual(controller.state.currentComposition, "zheng")
        XCTAssertEqual(controller.state.partialCommit?.confirmedText, "房子都会")

        _ = controller.handle(.deleteBackward)

        XCTAssertEqual(client.text, "房子douhuizheng")
        XCTAssertEqual(client.markedText, "房子douhuizheng")
        XCTAssertEqual(controller.state.currentComposition, "douhuizheng")
        XCTAssertEqual(controller.state.lastRimeOutput?.rawInput, "douhuizheng")
        XCTAssertEqual(controller.state.partialCommit?.confirmedText, "房子")
        XCTAssertNil(controller.state.partialCommit?.checkpoint)

        _ = controller.handle(.deleteBackward)

        XCTAssertEqual(client.text, "房子douhuizhen")
        XCTAssertEqual(client.markedText, "房子douhuizhen")
        XCTAssertEqual(controller.state.currentComposition, "douhuizhen")
        XCTAssertEqual(controller.state.lastRimeOutput?.rawInput, "douhuizhen")
        XCTAssertFalse(client.text.contains("fangzi"))
    }

    func testFailedCheckpointRebuildDoesNotDeleteVisibleText() {
        let (controller, client, engine) = makeController()
        type("nihaoanpai", into: controller)
        selectNihao(using: controller)
        engine.processKeysToDrop = 1

        _ = controller.handle(.deleteBackward)

        XCTAssertEqual(client.text, "你好anpai")
        XCTAssertEqual(client.markedText, "你好anpai")
        XCTAssertEqual(controller.state.partialCommit?.displayText, "你好anpai")
        XCTAssertNil(controller.state.partialCommit?.checkpoint)
    }

    func testVisibilityRecoveryKeepsConfirmedPrefix() {
        let (controller, client, _) = makeController()
        type("nihaoanpai", into: controller)
        selectNihao(using: controller)

        controller.resetRimeSessionForVisibilityChange()
        _ = controller.handle(.insertKey("x"))

        XCTAssertEqual(client.text, "你好anpaix")
        XCTAssertEqual(client.markedText, "你好anpaix")
        XCTAssertEqual(controller.state.partialCommit?.confirmedText, "你好")
        XCTAssertEqual(controller.state.partialCommit?.remainingRawInput, "anpaix")
        XCTAssertNil(controller.state.partialCommit?.checkpoint)
    }

    func testInputModeSwitchCommitsWholePartialDisplay() {
        let (controller, client, _) = makeController()
        type("nihaoanpai", into: controller)
        selectNihao(using: controller)

        _ = controller.handle(.toggleInputMode)

        XCTAssertEqual(client.text, "你好anpai")
        XCTAssertEqual(client.markedText, "")
        XCTAssertEqual(controller.state.currentComposition, "")
        XCTAssertNil(controller.state.partialCommit)
    }

    func testTypoCorrectionPartialCommitKeepsCorrectedRemainderAndRestoresOriginalInput() {
        let engine = FakeRimeEngine(
            dictionary: [
                "nihapanpai": ["你好安排"],
                "nihapanpa": ["你好安帕"],
                "nihaoanpai": ["你好安排", "你好"],
                "anpai": ["安排", "按排"],
            ],
            selectionRemainders: ["nihaoanpai": [1: "anpai"]]
        )
        let (controller, client) = makeController(engine: engine)
        controller.isTypoCorrectionPartialCommitEnabled = true
        type("nihapanpai", into: controller)

        _ = controller.handle(.insertCorrectionCandidate(nihapAnpaiCorrection()))

        XCTAssertEqual(client.text, "你好anpai")
        XCTAssertEqual(client.markedText, "你好anpai")
        XCTAssertEqual(controller.state.currentComposition, "anpai")
        XCTAssertEqual(controller.state.lastRimeOutput?.rawInput, "anpai")
        XCTAssertEqual(controller.state.lastRimeOutput?.candidates.map(\.text), ["安排", "按排"])
        XCTAssertEqual(controller.state.partialCommit?.confirmedText, "你好")
        XCTAssertEqual(controller.state.partialCommit?.source, .typoCorrection)
        XCTAssertEqual(controller.state.partialCommit?.checkpoint?.previousRawInput, "nihapanpai")

        _ = controller.handle(.deleteBackward)

        XCTAssertEqual(client.text, "nihapanpai")
        XCTAssertEqual(controller.state.currentComposition, "nihapanpai")
        XCTAssertEqual(controller.state.lastRimeOutput?.rawInput, "nihapanpai")
        XCTAssertEqual(controller.state.lastRimeOutput?.candidates.map(\.text), ["你好安排"])
        XCTAssertNil(controller.state.partialCommit)

        _ = controller.handle(.deleteBackward)

        XCTAssertEqual(client.text, "nihapanpa")
        XCTAssertEqual(controller.state.currentComposition, "nihapanpa")
        XCTAssertEqual(controller.state.lastRimeOutput?.rawInput, "nihapanpa")
        XCTAssertEqual(controller.state.lastRimeOutput?.candidates.map(\.text), ["你好安帕"])
    }

    func testTypoCorrectionPartialCommitHandlesRealRimeStyleSelectedSegmentWithoutDuplicateText() {
        let engine = FakeRimeEngine(
            dictionary: [
                "nihapanpai": ["你好安排"],
                "nihaoanpai": ["你好安排", "你好"],
                "anpai": ["安排", "按排"],
            ],
            preeditFormatter: { input in
                switch input {
                case "nihapanpai":
                    return "ni hap an pai"
                case "nihaoanpai":
                    return "ni hao an pai"
                case "anpai":
                    return "an pai"
                default:
                    return input
                }
            },
            selectedSegments: [
                "nihaoanpai": [
                    1: FakeRimeSelectedSegment(rawPrefix: "nihao", text: "你好")
                ]
            ],
            partialSelectionEmitsCommit: false
        )
        let (controller, client) = makeController(engine: engine)
        controller.isTypoCorrectionPartialCommitEnabled = true
        type("nihapanpai", into: controller)

        _ = controller.handle(.insertCorrectionCandidate(nihapAnpaiCorrection()))

        XCTAssertEqual(client.text, "你好an pai")
        XCTAssertEqual(controller.state.currentComposition, "an pai")
        XCTAssertEqual(controller.state.partialCommit?.displayText, "你好an pai")
        XCTAssertEqual(controller.state.partialCommit?.source, .typoCorrection)
        XCTAssertEqual(controller.state.lastRimeOutput?.candidates.map(\.text), ["安排", "按排"])
    }

    func testTypingAfterTypoCorrectionPartialCommitInvalidatesRestoreCheckpoint() {
        let engine = FakeRimeEngine(
            dictionary: [
                "nihapanpai": ["你好安排"],
                "nihaoanpai": ["你好安排", "你好"],
                "anpai": ["安排"],
                "anpaix": ["安排下"],
            ],
            selectionRemainders: ["nihaoanpai": [1: "anpai"]]
        )
        let (controller, client) = makeController(engine: engine)
        controller.isTypoCorrectionPartialCommitEnabled = true
        type("nihapanpai", into: controller)
        _ = controller.handle(.insertCorrectionCandidate(nihapAnpaiCorrection()))

        _ = controller.handle(.insertKey("x"))

        XCTAssertEqual(client.text, "你好anpaix")
        XCTAssertNil(controller.state.partialCommit?.checkpoint)

        _ = controller.handle(.deleteBackward)

        XCTAssertEqual(client.text, "你好anpai")
        XCTAssertEqual(controller.state.currentComposition, "anpai")
        XCTAssertEqual(controller.state.partialCommit?.source, .typoCorrection)
    }

    func testTypoCorrectionPartialCommitFlagOffKeepsFullCommitBehavior() {
        let engine = FakeRimeEngine(
            dictionary: [
                "nihapanpai": ["你好安排"],
                "nihaoanpai": ["你好安排", "你好"],
                "anpai": ["安排"],
            ],
            selectionRemainders: ["nihaoanpai": [1: "anpai"]]
        )
        let (controller, client) = makeController(engine: engine)
        type("nihapanpai", into: controller)

        _ = controller.handle(.insertCorrectionCandidate(nihapAnpaiCorrection()))

        XCTAssertEqual(client.text, "你好")
        XCTAssertEqual(client.markedText, "")
        XCTAssertEqual(controller.state.currentComposition, "")
        XCTAssertNil(controller.state.partialCommit)
        XCTAssertFalse(engine.isComposing())
    }

    func testRepeatedFinalDeletionCorrectionDoesNotUsePartialCommitEvenWhenFlagEnabled() {
        let engine = FakeRimeEngine(
            dictionary: [
                "nihaoo": ["你好哦"],
                "nihao": ["你好"],
            ]
        )
        let (controller, client) = makeController(engine: engine)
        controller.isTypoCorrectionPartialCommitEnabled = true
        type("nihaoo", into: controller)
        let correction = TypoCorrectionCommit(
            committedText: "你好",
            originalInput: "nihaoo",
            correctedInput: "nihao",
            edits: [TypoCorrectionEdit(index: 5, original: "o", replacement: "o", kind: .deletion)]
        )

        _ = controller.handle(.insertCorrectionCandidate(correction))

        XCTAssertEqual(client.text, "你好")
        XCTAssertEqual(client.markedText, "")
        XCTAssertEqual(controller.state.currentComposition, "")
        XCTAssertNil(controller.state.partialCommit)
    }

    func testTypoCorrectionPartialCommitFallsBackWhenCorrectedCandidateCannotBeSelected() {
        let engine = FakeRimeEngine(
            dictionary: [
                "nihapanpai": ["你好安排"],
                "nihaoanpai": ["你好安排"],
            ]
        )
        let (controller, client) = makeController(engine: engine)
        controller.isTypoCorrectionPartialCommitEnabled = true
        type("nihapanpai", into: controller)

        _ = controller.handle(.insertCorrectionCandidate(nihapAnpaiCorrection()))

        XCTAssertEqual(client.text, "你好")
        XCTAssertEqual(client.markedText, "")
        XCTAssertEqual(controller.state.currentComposition, "")
        XCTAssertNil(controller.state.partialCommit)
        XCTAssertFalse(engine.isComposing())
    }

    func testTypoCorrectionPartialCommitFallsBackWhenNoRemainingCompositionExists() {
        let engine = FakeRimeEngine(
            dictionary: [
                "nihap": ["你好安排"],
                "nihao": ["你好"],
            ]
        )
        let (controller, client) = makeController(engine: engine)
        controller.isTypoCorrectionPartialCommitEnabled = true
        type("nihap", into: controller)
        let correction = TypoCorrectionCommit(
            committedText: "你好",
            originalInput: "nihap",
            correctedInput: "nihao",
            edits: [TypoCorrectionEdit(index: 4, original: "p", replacement: "o")]
        )

        _ = controller.handle(.insertCorrectionCandidate(correction))

        XCTAssertEqual(client.text, "你好")
        XCTAssertEqual(client.markedText, "")
        XCTAssertEqual(controller.state.currentComposition, "")
        XCTAssertNil(controller.state.partialCommit)
        XCTAssertFalse(engine.isComposing())
    }

    func testMultiEditTypoCorrectionDoesNotUsePartialCommitEvenWhenFlagEnabled() {
        let engine = FakeRimeEngine(
            dictionary: [
                "nixapanpai": ["你好安排"],
                "nihaoanpai": ["你好安排", "你好"],
                "anpai": ["安排"],
            ],
            selectionRemainders: ["nihaoanpai": [1: "anpai"]]
        )
        let (controller, client) = makeController(engine: engine)
        controller.isTypoCorrectionPartialCommitEnabled = true
        type("nixapanpai", into: controller)
        let correction = TypoCorrectionCommit(
            committedText: "你好",
            originalInput: "nixapanpai",
            correctedInput: "nihaoanpai",
            edits: [
                TypoCorrectionEdit(index: 2, original: "x", replacement: "h"),
                TypoCorrectionEdit(index: 4, original: "p", replacement: "o"),
            ]
        )

        _ = controller.handle(.insertCorrectionCandidate(correction))

        XCTAssertEqual(client.text, "你好")
        XCTAssertEqual(controller.state.currentComposition, "")
        XCTAssertNil(controller.state.partialCommit)
        XCTAssertFalse(engine.isComposing())
    }

    func testTypoCorrectionCandidateDuringActivePartialCommitUsesFullCommitFallback() {
        let engine = FakeRimeEngine(
            dictionary: [
                "nihapanpai": ["你好安排"],
                "nihaoanpai": ["你好安排", "你好"],
                "anpai": ["安排"],
            ],
            selectionRemainders: ["nihaoanpai": [1: "anpai"]]
        )
        let (controller, client) = makeController(engine: engine)
        controller.isTypoCorrectionPartialCommitEnabled = true
        type("nihapanpai", into: controller)
        _ = controller.handle(.insertCorrectionCandidate(nihapAnpaiCorrection()))

        _ = controller.handle(.insertCorrectionCandidate(nihapAnpaiCorrection()))

        XCTAssertEqual(client.text, "你好")
        XCTAssertEqual(controller.state.currentComposition, "")
        XCTAssertNil(controller.state.partialCommit)
        XCTAssertFalse(engine.isComposing())
    }

    func testFinalCandidateAfterTypoCorrectionPartialCommitCommitsCombinedText() {
        let engine = FakeRimeEngine(
            dictionary: [
                "nihapanpai": ["你好安排"],
                "nihaoanpai": ["你好安排", "你好"],
                "anpai": ["安排", "按排"],
            ],
            selectionRemainders: ["nihaoanpai": [1: "anpai"]]
        )
        let (controller, client) = makeController(engine: engine)
        controller.isTypoCorrectionPartialCommitEnabled = true
        type("nihapanpai", into: controller)
        _ = controller.handle(.insertCorrectionCandidate(nihapAnpaiCorrection()))

        _ = controller.handle(
            .insertCandidate(
                "安排",
                kind: .candidate,
                selectionReference: CandidateSelectionReference(page: 0, indexOnPage: 0)
            )
        )

        XCTAssertEqual(client.text, "你好安排")
        XCTAssertEqual(client.markedText, "")
        XCTAssertEqual(controller.state.currentComposition, "")
        XCTAssertNil(controller.state.partialCommit)
    }

    func testSpaceReturnAndDirectTextCommitTypoCorrectionPartialDisplay() {
        let engine = FakeRimeEngine(
            dictionary: [
                "nihapanpai": ["你好安排"],
                "nihaoanpai": ["你好安排", "你好"],
                "anpai": ["安排"],
            ],
            selectionRemainders: ["nihaoanpai": [1: "anpai"]]
        )

        do {
            let (controller, client) = makeController(engine: engine)
            controller.isTypoCorrectionPartialCommitEnabled = true
            type("nihapanpai", into: controller)
            _ = controller.handle(.insertCorrectionCandidate(nihapAnpaiCorrection()))

            _ = controller.handle(.insertSpace)

            XCTAssertEqual(client.text, "你好安排")
            XCTAssertEqual(client.markedText, "")
            XCTAssertNil(controller.state.partialCommit)
        }

        do {
            let engine = FakeRimeEngine(
                dictionary: [
                    "nihapanpai": ["你好安排"],
                    "nihaoanpai": ["你好安排", "你好"],
                    "anpai": ["安排"],
                ],
                selectionRemainders: ["nihaoanpai": [1: "anpai"]]
            )
            let (controller, client) = makeController(engine: engine)
            controller.isTypoCorrectionPartialCommitEnabled = true
            type("nihapanpai", into: controller)
            _ = controller.handle(.insertCorrectionCandidate(nihapAnpaiCorrection()))

            _ = controller.handle(.insertReturn)

            XCTAssertEqual(client.text, "你好anpai")
            XCTAssertEqual(client.markedText, "")
            XCTAssertNil(controller.state.partialCommit)
        }

        do {
            let engine = FakeRimeEngine(
                dictionary: [
                    "nihapanpai": ["你好安排"],
                    "nihaoanpai": ["你好安排", "你好"],
                    "anpai": ["安排"],
                ],
                selectionRemainders: ["nihaoanpai": [1: "anpai"]]
            )
            let (controller, client) = makeController(engine: engine)
            controller.isTypoCorrectionPartialCommitEnabled = true
            type("nihapanpai", into: controller)
            _ = controller.handle(.insertCorrectionCandidate(nihapAnpaiCorrection()))

            _ = controller.handle(.insertDirectText("，"))

            XCTAssertEqual(client.text, "你好anpai，")
            XCTAssertEqual(client.markedText, "")
            XCTAssertNil(controller.state.partialCommit)
        }
    }

    func testVisibilityRecoveryAfterTypoCorrectionPartialCommitKeepsConfirmedPrefix() {
        let engine = FakeRimeEngine(
            dictionary: [
                "nihapanpai": ["你好安排"],
                "nihaoanpai": ["你好安排", "你好"],
                "anpai": ["安排"],
                "anpaix": ["安排下"],
            ],
            selectionRemainders: ["nihaoanpai": [1: "anpai"]]
        )
        let (controller, client) = makeController(engine: engine)
        controller.isTypoCorrectionPartialCommitEnabled = true
        type("nihapanpai", into: controller)
        _ = controller.handle(.insertCorrectionCandidate(nihapAnpaiCorrection()))

        controller.resetRimeSessionForVisibilityChange()
        _ = controller.handle(.insertKey("x"))

        XCTAssertEqual(client.text, "你好anpaix")
        XCTAssertEqual(client.markedText, "你好anpaix")
        XCTAssertEqual(controller.state.partialCommit?.confirmedText, "你好")
        XCTAssertEqual(controller.state.partialCommit?.remainingRawInput, "anpaix")
        XCTAssertNil(controller.state.partialCommit?.checkpoint)
    }

    func testCandidatePagingDuringTypoCorrectionPartialCommitDoesNotInvalidateCheckpoint() {
        let engine = FakeRimeEngine(
            dictionary: [
                "nihapanpai": ["你好安排"],
                "nihaoanpai": ["你好安排", "你好"],
                "anpai": ["安排", "按排"],
            ],
            selectionRemainders: ["nihaoanpai": [1: "anpai"]]
        )
        let (controller, client) = makeController(engine: engine)
        controller.isTypoCorrectionPartialCommitEnabled = true
        type("nihapanpai", into: controller)
        _ = controller.handle(.insertCorrectionCandidate(nihapAnpaiCorrection()))

        _ = controller.handle(.candidatePageDown)
        _ = controller.handle(.candidatePageUp)

        XCTAssertEqual(client.text, "你好anpai")
        XCTAssertEqual(client.markedText, "你好anpai")
        XCTAssertEqual(controller.state.currentComposition, "anpai")
        XCTAssertNotNil(controller.state.partialCommit?.checkpoint)

        _ = controller.handle(.deleteBackward)

        XCTAssertEqual(client.text, "nihapanpai")
        XCTAssertEqual(client.markedText, "nihapanpai")
        XCTAssertNil(controller.state.partialCommit)
    }

    func testCorrectionCandidateStillUsesFullCommitPath() {
        let (controller, client, _) = makeController()
        type("nihaoanpai", into: controller)
        let correction = TypoCorrectionCommit(
            committedText: "你好",
            originalInput: "nihap",
            correctedInput: "nihao",
            edits: [TypoCorrectionEdit(index: 4, original: "p", replacement: "o")]
        )

        _ = controller.handle(.insertCorrectionCandidate(correction))

        XCTAssertEqual(client.text, "你好")
        XCTAssertEqual(client.markedText, "")
        XCTAssertNil(controller.state.partialCommit)
        XCTAssertEqual(controller.state.currentComposition, "")
    }

    /// T9 partial commit must show comment-preferred remaining preedit (`ya`), never raw
    /// digits (`92`), and must rebuild path choices from the remaining digit sequence.
    func testT9PartialCommitShowsCommentPreferredRemainderAndRefreshesPathBar() {
        // nihao=64426, ya=92 → nihaoya=6442692
        // selectionRemainders: session raw becomes remaining `92` immediately.
        let engine = FakeRimeEngine(
            dictionary: [
                "6442692": ["你好呀", "你好"],
                "92": ["呀", "哇", "牙"],
                "6": ["吗"],
                "9": ["呀", "我"],
            ],
            comments: [
                "6442692": ["ni hao ya", "ni hao"],
                "92": ["ya", "wa", "za"],
                "6": ["o"],
                "9": ["ya", "wo"],
            ],
            selectionRemainders: [
                "6442692": [1: "92"]
            ],
            partialSelectionEmitsCommit: true
        )
        engine.appendDigitsToComposition = true
        engine.seedRuntimeSelection(
            RimeRuntimeSelection(
                baseSchemaID: "rime_ice",
                layoutStyle: .nineKey,
                t9ReadinessMatched: true
            )
        )
        let client = FakeTextInputClient()
        let controller = KeyboardController()
        controller.textClient = client
        controller.rimeEngine = engine
        controller.usesT9InputSemantics = true

        for digit in ["6", "4", "4", "2", "6", "9", "2"] {
            _ = controller.handle(.insertKey(digit))
        }
        XCTAssertEqual(controller.state.lastRimeOutput?.rawInput, "6442692")

        _ = controller.handle(
            .insertCandidate(
                "你好",
                kind: .candidate,
                selectionReference: CandidateSelectionReference(page: 0, indexOnPage: 1)
            )
        )

        XCTAssertEqual(controller.state.partialCommit?.confirmedText, "你好")
        XCTAssertEqual(controller.state.partialCommit?.remainingRawInput, "92")
        XCTAssertEqual(controller.state.partialCommit?.remainingPreeditText, "ya")
        XCTAssertEqual(controller.state.partialCommit?.displayText, "你好ya")
        XCTAssertEqual(client.markedText, "你好ya")
        XCTAssertEqual(controller.state.insertedPreeditText, "你好ya")
        // T9 composition tracker stays on remaining raw for recovery semantics.
        XCTAssertEqual(controller.state.currentComposition, "92")
        XCTAssertEqual(controller.state.lastRimeOutput?.rawInput, "92")
        let candidateTexts = controller.state.lastRimeOutput?.candidates.map(\.text) ?? []
        XCTAssertEqual(Array(candidateTexts.prefix(2)), ["呀", "哇"])
        // Path bar must rebuild from remaining `92` (WXYZ / ya family), not MNO.
        XCTAssertEqual(controller.state.t9PinyinPathState.segmentSourceDigits, "92")
        let pathDisplays = controller.state.t9PinyinPathState.compactPaths.map(\.displayText)
        XCTAssertFalse(pathDisplays.isEmpty)
        XCTAssertNotEqual(pathDisplays, ["m", "n", "o"])
        XCTAssertTrue(
            pathDisplays.contains("ya") || pathDisplays.contains("wa") || pathDisplays.contains("za"),
            "expected first-syllable choices for remaining ya, got \(pathDisplays)"
        )
        XCTAssertTrue(
            pathDisplays.contains("y") || pathDisplays.contains("w") || pathDisplays.contains("x"),
            "expected first-key letters for digit 9, got \(pathDisplays)"
        )
        XCTAssertFalse(
            client.markedText.contains("92"),
            "host marked text must not leak remaining T9 raw digits"
        )
    }

    /// Real librime often keeps the full digit raw after partial select while preedit
    /// becomes `你好` + remainder. Path identity must still peel to remaining `92`.
    func testT9PartialCommitPeelsFullRawToRemainingDigitsForPathBar() {
        let engine = FakeRimeEngine(
            dictionary: [
                "6442692": ["你好呀", "你好"],
                // After selected-segment model, candidateKey is remaining digits.
                "92": ["呀", "哇", "砸"],
            ],
            comments: [
                "6442692": ["ni hao ya", "ni hao"],
                "92": ["ya", "wa", "za"],
            ],
            selectedSegments: [
                "6442692": [
                    1: FakeRimeSelectedSegment(rawPrefix: "64426", text: "你好")
                ]
            ],
            partialSelectionEmitsCommit: false
        )
        engine.appendDigitsToComposition = true
        engine.seedRuntimeSelection(
            RimeRuntimeSelection(
                baseSchemaID: "rime_ice",
                layoutStyle: .nineKey,
                t9ReadinessMatched: true
            )
        )
        let client = FakeTextInputClient()
        let controller = KeyboardController()
        controller.textClient = client
        controller.rimeEngine = engine
        controller.usesT9InputSemantics = true

        for digit in ["6", "4", "4", "2", "6", "9", "2"] {
            _ = controller.handle(.insertKey(digit))
        }

        _ = controller.handle(
            .insertCandidate(
                "你好",
                kind: .candidate,
                selectionReference: CandidateSelectionReference(page: 0, indexOnPage: 1)
            )
        )

        // Session composition may still report full raw; Core peels remaining for path.
        XCTAssertEqual(controller.state.partialCommit?.confirmedText, "你好")
        XCTAssertEqual(controller.state.partialCommit?.remainingRawInput, "92")
        XCTAssertEqual(controller.state.partialCommit?.displayText, "你好ya")
        XCTAssertEqual(client.markedText, "你好ya")
        XCTAssertEqual(controller.state.lastRimeOutput?.rawInput, "92")
        XCTAssertEqual(controller.state.t9PinyinPathState.segmentSourceDigits, "92")
        let pathDisplays = controller.state.t9PinyinPathState.compactPaths.map(\.displayText)
        XCTAssertNotEqual(pathDisplays, ["m", "n", "o"])
        XCTAssertTrue(
            pathDisplays.contains("ya") || pathDisplays.contains("wa") || pathDisplays.contains("za"),
            "got \(pathDisplays)"
        )
    }

    func testRemainingT9RawAfterPartialCommitHelper() {
        XCTAssertEqual(
            T9PinyinPathExtractor.remainingT9RawAfterPartialCommit(
                previousRaw: "6442692",
                resultRaw: "6442692",
                remainingDisplayPreedit: "ya"
            ),
            "92"
        )
        XCTAssertEqual(
            T9PinyinPathExtractor.remainingT9RawAfterPartialCommit(
                previousRaw: "6442692",
                resultRaw: "92",
                remainingDisplayPreedit: "ya"
            ),
            "92"
        )
        XCTAssertEqual(
            T9PinyinPathExtractor.remainingT9RawAfterPartialCommit(
                previousRaw: "6442692",
                resultRaw: "ya",
                remainingDisplayPreedit: "ya"
            ),
            "92"
        )
    }

    private func nihapAnpaiCorrection() -> TypoCorrectionCommit {
        TypoCorrectionCommit(
            committedText: "你好",
            originalInput: "nihapanpai",
            correctedInput: "nihaoanpai",
            edits: [TypoCorrectionEdit(index: 4, original: "p", replacement: "o")]
        )
    }

    private func makeController() -> (KeyboardController, FakeTextInputClient, FakeRimeEngine) {
        let engine = FakeRimeEngine(
            dictionary: dictionary,
            selectionRemainders: ["nihaoanpai": [1: "anpai"]]
        )
        let (controller, client) = makeController(engine: engine)
        return (controller, client, engine)
    }

    private func makeController(engine: FakeRimeEngine) -> (KeyboardController, FakeTextInputClient) {
        let client = FakeTextInputClient()
        let controller = KeyboardController()
        controller.textClient = client
        controller.rimeEngine = engine
        return (controller, client)
    }

    private func type(_ input: String, into controller: KeyboardController) {
        for character in input {
            _ = controller.handle(.insertKey(String(character)))
        }
    }

    private func selectNihao(using controller: KeyboardController) {
        _ = controller.handle(
            .insertCandidate(
                "你好",
                kind: .candidate,
                selectionReference: CandidateSelectionReference(page: 0, indexOnPage: 1)
            )
        )
    }

    private func segmentedPreedit(_ input: String) -> String {
        switch input {
        case "nihaoanpai":
            return "ni hao an pai"
        case "nihaoanpa":
            return "ni hao an pa"
        case "anpai":
            return "an pai"
        case "anpa":
            return "an pa"
        default:
            return input
        }
    }
}
