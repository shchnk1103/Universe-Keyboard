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

    // MARK: - Q-004-09 Partial paging coverage

    func testCandidatePagingDuringNormalPartialCommitDoesNotInvalidateCheckpoint() {
        let engine = FakeRimeEngine(
            dictionary: [
                "nihaoanpai": ["你好安排", "你好"],
                "anpai": ["安排", "按排", "安拍"],
            ],
            selectionRemainders: ["nihaoanpai": [1: "anpai"]]
        )
        let (controller, client) = makeController(engine: engine)
        type("nihaoanpai", into: controller)
        selectNihao(using: controller)

        XCTAssertNotNil(controller.state.partialCommit?.checkpoint)
        let revisionBefore = controller.state.compositionRevision

        _ = controller.handle(.candidatePageDown)
        _ = controller.handle(.candidatePageUp)

        XCTAssertGreaterThanOrEqual(controller.state.compositionRevision, revisionBefore)
        XCTAssertNotNil(controller.state.partialCommit?.checkpoint)
        XCTAssertEqual(controller.state.partialCommit?.confirmedText, "你好")
        XCTAssertEqual(controller.state.partialCommit?.remainingRawInput, "anpai")

        _ = controller.handle(.deleteBackward)
        XCTAssertEqual(client.markedText, "nihaoanpai")
        XCTAssertNil(controller.state.partialCommit)
    }

    func testCandidatePagingDuringT9PartialCommitKeepsPathsAndCheckpoint() {
        let fullRaw = "74853"
        let engine = FakeRimeEngine(
            dictionary: [
                fullRaw: ["偷偷买球了", "偷偷买"],
                "748": ["偷偷买"],
                "53": ["了", "乐"],
                "qiu'53": ["球了", "球"],
                "qiu53": ["球了"],
                "5": ["了"],
            ],
            comments: [
                fullRaw: ["tou tou mai qiu le", "tou tou mai"],
                "748": ["tou tou mai"],
                "53": ["le", "le"],
                "qiu'53": ["qiu le", "qiu"],
                "qiu53": ["qiu le"],
                "5": ["le"],
            ],
            selectionRemainders: [
                fullRaw: [1: "53"]
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
        let (controller, client) = makeController(engine: engine)
        controller.usesT9InputSemantics = true
        for digit in fullRaw.map(String.init) {
            _ = controller.handle(.insertKey(String(digit)))
        }
        _ = controller.handle(
            .insertCandidate(
                "偷偷买",
                kind: .candidate,
                selectionReference: CandidateSelectionReference(page: 0, indexOnPage: 1)
            )
        )

        XCTAssertNotNil(controller.state.partialCommit?.checkpoint)
        XCTAssertFalse(controller.state.t9PinyinPathState.compactPaths.isEmpty)
        let pathsBefore = controller.state.t9PinyinPathState.compactPaths.map(\.displayText)
        let revisionBefore = controller.state.compositionRevision

        _ = controller.handle(.candidatePageDown)
        _ = controller.handle(.candidatePageUp)

        XCTAssertNotNil(controller.state.partialCommit?.checkpoint)
        XCTAssertEqual(controller.state.partialCommit?.confirmedText, "偷偷买")
        XCTAssertFalse(controller.state.t9PinyinPathState.compactPaths.isEmpty)
        // Path set may re-rank but must remain published for remaining identity.
        XCTAssertFalse(pathsBefore.isEmpty)
        XCTAssertGreaterThanOrEqual(controller.state.compositionRevision, revisionBefore)
        XCTAssertFalse(client.markedTextHistory.contains { text in
            text.unicodeScalars.contains(where: T9PinyinPathExtractor.isASCIIDigit)
        })

        _ = controller.handle(.deleteBackward)
        XCTAssertNil(controller.state.partialCommit)
        XCTAssertFalse(client.markedTextHistory.contains { text in
            text.unicodeScalars.contains(where: T9PinyinPathExtractor.isASCIIDigit)
        })
    }

    func testTypingAfterCandidatePagingInvalidatesPartialCheckpoint() {
        let engine = FakeRimeEngine(
            dictionary: [
                "nihaoanpai": ["你好安排", "你好"],
                "anpai": ["安排", "按排"],
                "anpaix": ["安排下"],
            ],
            selectionRemainders: ["nihaoanpai": [1: "anpai"]]
        )
        let (controller, client) = makeController(engine: engine)
        type("nihaoanpai", into: controller)
        selectNihao(using: controller)

        _ = controller.handle(.candidatePageDown)
        XCTAssertNotNil(controller.state.partialCommit?.checkpoint)

        _ = controller.handle(.insertKey("x"))
        XCTAssertNil(controller.state.partialCommit?.checkpoint)
        XCTAssertEqual(controller.state.partialCommit?.confirmedText, "你好")

        // Delete should not resurrect pre-partial original input once checkpoint is gone.
        _ = controller.handle(.deleteBackward)
        XCTAssertNotEqual(client.markedText, "nihaoanpai")
        XCTAssertEqual(controller.state.partialCommit?.confirmedText, "你好")
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

    /// Delete after T9 partial must restore host-visible pinyin, never leak full digit raw.
    func testT9PartialCommitDeleteRestoresPinyinNotRawDigits() {
        let engine = FakeRimeEngine(
            dictionary: [
                "6442692": ["你好呀", "你好"],
                "92": ["呀", "哇"],
            ],
            comments: [
                "6442692": ["ni hao ya", "ni hao"],
                "92": ["ya", "wa"],
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
        // Host should already show comment-preferred preedit, not digits.
        XCTAssertFalse(
            client.markedText.unicodeScalars.allSatisfy(T9PinyinPathExtractor.isASCIIDigit),
            "pre-partial host marked leaked digits: \(client.markedText)"
        )
        let prePartialMarked = client.markedText

        _ = controller.handle(
            .insertCandidate(
                "你好",
                kind: .candidate,
                selectionReference: CandidateSelectionReference(page: 0, indexOnPage: 1)
            )
        )
        XCTAssertEqual(client.markedText, "你好ya")

        _ = controller.handle(.deleteBackward)

        XCTAssertNil(controller.state.partialCommit)
        XCTAssertFalse(
            client.markedText.unicodeScalars.allSatisfy(T9PinyinPathExtractor.isASCIIDigit),
            "delete restore leaked raw digits to host: \(client.markedText)"
        )
        XCTAssertNotEqual(client.markedText, "6442692")
        XCTAssertFalse(client.markedText.contains("6442692"))
        // Prefer restored pinyin-style preedit (comment or prior host snapshot).
        XCTAssertTrue(
            client.markedText.contains("ni")
                || client.markedText.contains("hao")
                || client.markedText == prePartialMarked
                || client.markedText.rangeOfCharacter(from: .letters) != nil,
            "expected pinyin-like restore, got \(client.markedText)"
        )
        XCTAssertEqual(controller.state.lastRimeOutput?.rawInput, "6442692")
    }

    func testT9PartialCommitTreatsSpacedDigitTailAsInternalAndAlignsQiuRemainder() {
        let fullRaw = "86886862474853"
        let engine = FakeRimeEngine(
            dictionary: [
                fullRaw: ["偷偷买球了", "偷偷买"],
                "74853": ["球了", "熟了"],
            ],
            comments: [
                fullRaw: ["tou tou mai qiu le", "tou tou mai"],
                "74853": ["qiu le", "shu le"],
            ],
            preeditFormatter: { raw in
                raw == "74853" ? "748 53" : "868 868 624 748 53"
            },
            selectedSegments: [
                fullRaw: [
                    1: FakeRimeSelectedSegment(rawPrefix: "868868624", text: "偷偷买")
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

        for digit in fullRaw.map(String.init) {
            _ = controller.handle(.insertKey(digit))
        }
        _ = controller.handle(
            .insertCandidate(
                "偷偷买",
                kind: .candidate,
                selectionReference: CandidateSelectionReference(page: 0, indexOnPage: 1)
            )
        )

        XCTAssertEqual(controller.state.partialCommit?.confirmedText, "偷偷买")
        XCTAssertEqual(controller.state.partialCommit?.remainingRawInput, "74853")
        XCTAssertEqual(controller.state.partialCommit?.remainingPreeditText, "qiu le")
        XCTAssertEqual(controller.state.partialCommit?.displayText, "偷偷买qiu le")
        XCTAssertEqual(controller.state.currentComposition, "74853")
        XCTAssertEqual(controller.state.lastRimeOutput?.rawInput, "74853")
        XCTAssertEqual(controller.state.t9PinyinPathState.segmentSourceDigits, "74853")
        XCTAssertTrue(
            controller.state.t9PinyinPathState.compactPaths.contains { $0.displayText == "qiu" }
        )
        XCTAssertFalse(
            controller.state.t9PinyinPathState.compactPaths.contains { ["t", "u", "v"].contains($0.displayText) }
        )
        XCTAssertFalse(client.markedText.contains(where: \.isNumber))

        // Session-loss fallback may retain the last safe spelling, but it must
        // never append the next internal digit to host marked text.
        controller.rimeEngine = nil
        _ = controller.handle(.insertKey("2"))
        XCTAssertEqual(controller.state.partialCommit?.remainingRawInput, "748532")
        XCTAssertFalse(client.markedText.contains(where: \.isNumber))
    }

    func testT9PartialCommitSelectingQiuPreservesConfirmedPrefixWhenRimeReranks() throws {
        let fullRaw = "86886862474853"
        let engine = FakeRimeEngine(
            dictionary: [
                fullRaw: ["偷偷买球了", "偷偷买"],
                "74853": ["球了", "熟了"],
                // Mirrors the reported device failure: exact raw survives, but
                // the first live comment is a different spelling branch.
                "qiu53": ["填了", "添课"],
                // The anchored session is on the correct qiu branch, but may
                // rank another 53 spelling before `le` (as seen on device).
                "qiu'53": ["球", "裘科"],
                "qiu'ke": ["裘科"],
                "qiu'le": ["球了"],
                "qiu'5": ["球"],
                "qiu'3": ["球饿"],
                "qiu": ["球"],
                "748": ["球", "熟"],
                "5": ["了"],
                // Old checkpoint restore rebuilt the visible `qiule` spelling
                // instead of the already anchored `qiu'53` raw. Model the
                // resulting mixed preedit that leaked an internal digit.
                "qiule": ["球了"],
            ],
            comments: [
                fullRaw: ["tou tou mai qiu le", "tou tou mai"],
                "74853": ["qiu le", "shu le"],
                "748": ["qiu", "shu"],
                "qiu53": ["tian le", "tian ke"],
                "qiu'53": ["qiu ke", "qiu ne"],
                "qiu'ke": ["qiu ke"],
                "qiu'le": ["qiu le"],
                "qiu'5": ["qiu l"],
                "qiu'3": ["qiu e"],
                "qiu": ["qiu"],
                "5": ["le"],
                "qiule": ["qiu le"],
            ],
            preeditFormatter: { raw in
                switch raw {
                case "74853": "748 53"
                case "748": "748"
                case "qiu53": "tian le"
                case "qiu'53": "qiu ke"
                case "qiu'ke": "qiu ke"
                case "qiu'le": "qiu le"
                case "qiu'5": "qiu l"
                case "qiu'3": "qiu e"
                case "qiu": "qiu"
                case "5": "5"
                case "qiule": "qiu5"
                default: "868 868 624 748 53"
                }
            },
            selectionRemainders: [
                "qiu'53": [0: "5"]
            ],
            selectedSegments: [
                fullRaw: [
                    1: FakeRimeSelectedSegment(rawPrefix: "868868624", text: "偷偷买")
                ]
            ],
            partialSelectionEmitsCommit: false
        )
        // ADR 0022 Stage A: lower-ranked live comments are obtained from one
        // fixed window; no per-spelling `qiu'le` probe is permitted on tap.
        engine.candidateWindowOverrides["qiu'53"] = [
            RimeCandidate(text: "球", comment: "qiu ke", globalIndex: 0),
            RimeCandidate(text: "裘科", comment: "qiu ne", globalIndex: 1),
            RimeCandidate(text: "球了", comment: "qiu le", globalIndex: 2),
        ]
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

        for digit in fullRaw.map(String.init) {
            _ = controller.handle(.insertKey(digit))
        }
        _ = controller.handle(
            .insertCandidate(
                "偷偷买",
                kind: .candidate,
                selectionReference: CandidateSelectionReference(page: 0, indexOnPage: 1)
            )
        )
        let qiu = try XCTUnwrap(
            controller.state.t9PinyinPathState.compactPaths.first { $0.displayText == "qiu" }
        )

        _ = controller.handle(.selectT9PinyinPath(qiu))

        XCTAssertEqual(controller.state.lastRimeOutput?.rawInput, "qiu'53")
        XCTAssertEqual(controller.state.lastRimeOutput?.candidates.first?.comment, "qiu ke")
        XCTAssertEqual(controller.state.t9PinyinPathState.confirmedSegmentValues, ["qiu"])
        XCTAssertEqual(controller.state.t9PinyinPathState.focusedSegmentIndex, 1)
        XCTAssertTrue(
            controller.state.t9PinyinPathState.compactPaths.contains { $0.displayText == "le" }
        )
        XCTAssertFalse(
            controller.state.t9PinyinPathState.compactPaths.contains { $0.displayText == "tian" },
            "a comment whose first segment is not qiu must not authorize the next focus"
        )
        // After confirming `qiu`, the Path Bar must not collapse to a single
        // confirmed-label option. Next focus keeps multi-choice parity with a
        // standalone remaining digit run (syllables and/or key letters).
        XCTAssertGreaterThan(
            controller.state.t9PinyinPathState.compactPaths.count,
            1,
            "path bar must keep multiple next-focus choices after selecting qiu"
        )
        XCTAssertEqual(controller.state.partialCommit?.remainingPreeditText, "qiule")
        XCTAssertEqual(controller.state.partialCommit?.displayText, "偷偷买qiule")
        XCTAssertEqual(client.markedText, "偷偷买qiule")
        _ = controller.handle(
            .insertCandidate(
                "球",
                kind: .candidate,
                selectionReference: CandidateSelectionReference(page: 0, indexOnPage: 0)
            )
        )
        XCTAssertEqual(controller.state.partialCommit?.confirmedText, "偷偷买球")
        XCTAssertEqual(controller.state.lastRimeOutput?.rawInput, "5")
        XCTAssertEqual(controller.state.t9PinyinPathState.confirmedSegmentValues, ["qiu"])
        XCTAssertEqual(controller.state.t9PinyinPathState.segmentSourceDigits, "7485")

        _ = controller.handle(.deleteBackward)

        XCTAssertEqual(controller.state.lastRimeOutput?.rawInput, "qiu'53")
        XCTAssertEqual(controller.state.partialCommit?.confirmedText, "偷偷买")
        XCTAssertEqual(controller.state.partialCommit?.remainingPreeditText, "qiule")
        XCTAssertEqual(controller.state.partialCommit?.displayText, "偷偷买qiule")
        XCTAssertEqual(client.markedText, "偷偷买qiule")
        XCTAssertFalse(client.markedText.contains(where: \.isNumber))

        _ = controller.handle(.deleteBackward)

        // Last-entered slot: drop trailing `e` / raw `3`, not focus-head `l` / `5`.
        XCTAssertEqual(controller.state.lastRimeOutput?.rawInput, "qiu'5")
        XCTAssertEqual(controller.state.partialCommit?.remainingPreeditText, "qiul")
        XCTAssertEqual(controller.state.partialCommit?.displayText, "偷偷买qiul")
        XCTAssertEqual(client.markedText, "偷偷买qiul")
        XCTAssertFalse(client.markedText.contains(where: \.isNumber))

        _ = controller.handle(.deleteBackward)

        // Dropping the last unresolved digit leaves letter-only `qiu`. Path Bar
        // must rebuild first-focus siblings for digit identity `748`, not ghost
        // next-focus letters `j/k/l` for a deleted trailing `5`.
        XCTAssertEqual(controller.state.lastRimeOutput?.rawInput, "qiu")
        XCTAssertEqual(controller.state.partialCommit?.remainingPreeditText, "qiu")
        XCTAssertEqual(controller.state.partialCommit?.displayText, "偷偷买qiu")
        XCTAssertEqual(client.markedText, "偷偷买qiu")
        XCTAssertEqual(controller.state.t9PinyinPathState.segmentSourceDigits, "748")
        XCTAssertEqual(controller.state.t9PinyinPathState.focusedSegmentIndex, 0)
        XCTAssertTrue(controller.state.t9PinyinPathState.confirmedSegmentValues.isEmpty)
        let pathDisplays = Set(
            controller.state.t9PinyinPathState.compactPaths.map(\.displayText)
        )
        XCTAssertTrue(pathDisplays.contains("qiu"))
        XCTAssertTrue(
            pathDisplays.contains("shu") || pathDisplays.contains("p"),
            "letter-only qiu must keep multi-choice siblings, got \(pathDisplays.sorted())"
        )
        XCTAssertFalse(
            pathDisplays.isSubset(of: ["j", "k", "l"]),
            "must not show only next-focus j/k/l after trailing digits are gone"
        )
        XCTAssertFalse(client.markedText.contains(where: \.isNumber))
        XCTAssertTrue(
            client.markedTextHistory.allSatisfy { !$0.contains(where: \.isNumber) },
            "no transient host marked-text write may expose internal T9 digits"
        )
    }

    func testWholeUnresolvedTailDoesNotRestoreStaleConfirmedPathSnapshot() {
        let engine = FakeRimeEngine(
            dictionary: ["9698454": ["我嘴里"]],
            comments: ["9698454": ["wo zui li"]]
        )
        engine.appendDigitsToComposition = true
        engine.seedRuntimeSelection(
            RimeRuntimeSelection(
                baseSchemaID: "rime_ice",
                layoutStyle: .nineKey,
                t9ReadinessMatched: true
            )
        )
        let (controller, _) = makeController(engine: engine)
        controller.usesT9InputSemantics = true
        controller.state.lastRimeOutput = RimeOutput(
            rawInput: "9698454",
            composition: RimeComposition(preeditText: "wo zui li", cursorPosition: 9),
            candidates: [RimeCandidate(text: "我嘴里", comment: "wo zui li")]
        )
        let currentPath = T9PinyinPath(
            displayText: "wo",
            replacementRawInput: "wo98454"
        )
        controller.state.t9PinyinPathState = T9PinyinPathState(
            compactPaths: [currentPath],
            rawInputGeneration: 7,
            provenanceRevision: 11,
            trackedRawInput: "9698454",
            issuedReplacementKeys: [currentPath.replacementRawInput],
            segmentSourceDigits: "9698454",
            focusedSegmentIndex: 0
        )

        let restored = controller.restoreSegmentedPathIdentityAfterNestedPartial(
            preservedSegmentSource: "74649343263269698454",
            preservedPathConfirmed: ["qing", "wei", "fan", "dao"]
        )

        XCTAssertFalse(restored)
        XCTAssertEqual(controller.state.t9PinyinPathState.compactPaths, [currentPath])
        XCTAssertEqual(controller.state.t9PinyinPathState.confirmedSegmentValues, [])
        XCTAssertEqual(controller.state.t9PinyinPathState.provenanceRevision, 11)
    }

    func testQingWeiFanDaoCandidateSelectionPublishesWoPathsFromNewRemainder() throws {
        let fullRaw = "74649343263269698454"
        let qingRaw = "qing9343263269698454"
        let qingWeiRaw = "qing'wei'3263269698454"
        let qingWeiFanRaw = "qing'wei'fan'3269698454"
        let qingWeiFanDaoRaw = "qing'wei'fan'dao'9698454"
        let remainderRaw = "9698454"
        let fullComment = "qing wei fan dao wo zui li"
        let engine = FakeRimeEngine(
            dictionary: [
                fullRaw: ["请喂饭到我嘴里"],
                qingRaw: ["请喂饭到我嘴里"],
                qingWeiRaw: ["请喂饭到我嘴里"],
                qingWeiFanRaw: ["请喂饭到我嘴里"],
                qingWeiFanDaoRaw: ["请喂饭到我嘴里", "请喂饭到"],
                remainderRaw: ["我嘴里"],
            ],
            comments: [
                fullRaw: [fullComment],
                qingRaw: [fullComment],
                qingWeiRaw: [fullComment],
                qingWeiFanRaw: [fullComment],
                qingWeiFanDaoRaw: [fullComment, "qing wei fan dao"],
                remainderRaw: ["wo zui li"],
            ],
            selectionRemainders: [qingWeiFanDaoRaw: [1: remainderRaw]],
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
        let (controller, client) = makeController(engine: engine)
        controller.usesT9InputSemantics = true
        for digit in fullRaw.map(String.init) {
            _ = controller.handle(.insertKey(digit))
        }

        for expected in ["qing", "wei", "fan", "dao"] {
            let path = try XCTUnwrap(
                controller.state.t9PinyinPathState.compactPaths.first {
                    $0.displayText == expected
                },
                "missing \(expected); raw=\(controller.state.lastRimeOutput?.rawInput ?? "nil") paths=\(controller.state.t9PinyinPathState.compactPaths.map(\.displayText))"
            )
            _ = controller.handle(.selectT9PinyinPath(path))
        }
        XCTAssertEqual(controller.state.lastRimeOutput?.rawInput, qingWeiFanDaoRaw)
        let revisionBeforeCandidate = controller.state.compositionRevision

        _ = controller.handle(
            .insertCandidate(
                "请喂饭到",
                kind: .candidate,
                selectionReference: CandidateSelectionReference(page: 0, indexOnPage: 1)
            )
        )

        XCTAssertEqual(controller.state.lastRimeOutput?.rawInput, remainderRaw)
        XCTAssertGreaterThan(controller.state.compositionRevision, revisionBeforeCandidate)
        XCTAssertEqual(
            controller.state.t9PinyinPathState.compositionRevision,
            controller.state.compositionRevision
        )
        XCTAssertEqual(controller.state.partialCommit?.confirmedText, "请喂饭到")
        XCTAssertEqual(controller.state.t9PinyinPathState.confirmedSegmentValues, [])
        XCTAssertEqual(controller.state.t9PinyinPathState.focusedSegmentIndex, 0)
        XCTAssertTrue(
            controller.state.t9PinyinPathState.compactPaths.contains {
                $0.displayText == "wo"
            }
        )
        XCTAssertFalse(
            controller.state.t9PinyinPathState.compactPaths.contains {
                ["qing", "wei", "fan", "dao"].contains($0.displayText)
            }
        )
        XCTAssertTrue(client.markedText.hasPrefix("请喂饭到"))
        XCTAssertTrue(client.markedTextHistory.allSatisfy { !$0.contains(where: \.isNumber) })
    }

    func testQingCandidateWithRetainedFullAnchoredRawStillPublishesWoPaths() throws {
        let fullRaw = "74649343263269698454"
        let qingRaw = "qing9343263269698454"
        let qingWeiRaw = "qing'wei'3263269698454"
        let qingWeiFanRaw = "qing'wei'fan'3269698454"
        let finalRaw = "qing'wei'fan'dao'9698454"
        let fullComment = "qing wei fan dao wo zui li"
        let dictionaries = [fullRaw, qingRaw, qingWeiRaw, qingWeiFanRaw]
        var dictionary = Dictionary(uniqueKeysWithValues: dictionaries.map {
            ($0, ["请喂饭到我嘴里"])
        })
        var comments = Dictionary(uniqueKeysWithValues: dictionaries.map {
            ($0, [fullComment])
        })
        dictionary[finalRaw] = ["请喂饭到我嘴里", "请喂饭到"]
        dictionary["9698454"] = ["我嘴里"]
        comments[finalRaw] = [fullComment, "qing wei fan dao"]
        comments["9698454"] = ["wo zui li"]
        let engine = FakeRimeEngine(
            dictionary: dictionary,
            comments: comments,
            selectedSegments: [
                finalRaw: [
                    1: FakeRimeSelectedSegment(
                        rawPrefix: "qing'wei'fan'dao'",
                        text: "请喂饭到"
                    )
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
        let (controller, client) = makeController(engine: engine)
        controller.usesT9InputSemantics = true
        for digit in fullRaw.map(String.init) {
            _ = controller.handle(.insertKey(digit))
        }
        for expected in ["qing", "wei", "fan", "dao"] {
            let path = try XCTUnwrap(
                controller.state.t9PinyinPathState.compactPaths.first {
                    $0.displayText == expected
                }
            )
            _ = controller.handle(.selectT9PinyinPath(path))
        }

        _ = controller.handle(
            .insertCandidate(
                "请喂饭到",
                kind: .candidate,
                selectionReference: CandidateSelectionReference(page: 0, indexOnPage: 1)
            )
        )

        XCTAssertEqual(controller.state.lastRimeOutput?.rawInput, "9698454")
        XCTAssertEqual(controller.state.t9PinyinPathState.confirmedSegmentValues, [])
        XCTAssertTrue(controller.state.t9PinyinPathState.compactPaths.contains {
            $0.displayText == "wo"
        })
        XCTAssertTrue(client.markedTextHistory.allSatisfy { !$0.contains(where: \.isNumber) })
    }

    func testT9PartialCommitSelectingShuReplacesOnlyCorrespondingVisibleSegment() throws {
        let fullRaw = "86886862474853"
        let engine = FakeRimeEngine(
            dictionary: [
                fullRaw: ["偷偷买球了", "偷偷买"],
                "74853": ["球了", "熟了"],
                "shu53": ["熟了"],
                "shu'53": ["熟了"],
                "shu'le": ["熟了"],
            ],
            comments: [
                fullRaw: ["tou tou mai qiu le", "tou tou mai"],
                "74853": ["qiu le", "shu le"],
                "shu53": ["shu le"],
                "shu'53": ["shu le"],
                "shu'le": ["shu le"],
            ],
            preeditFormatter: { raw in
                switch raw {
                case "74853": "748 53"
                case "shu53", "shu'53", "shu'le": "shu le"
                default: "868 868 624 748 53"
                }
            },
            selectedSegments: [
                fullRaw: [
                    1: FakeRimeSelectedSegment(rawPrefix: "868868624", text: "偷偷买")
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

        for digit in fullRaw.map(String.init) {
            _ = controller.handle(.insertKey(digit))
        }
        _ = controller.handle(
            .insertCandidate(
                "偷偷买",
                kind: .candidate,
                selectionReference: CandidateSelectionReference(page: 0, indexOnPage: 1)
            )
        )
        let shu = try XCTUnwrap(
            controller.state.t9PinyinPathState.compactPaths.first { $0.displayText == "shu" }
        )

        _ = controller.handle(.selectT9PinyinPath(shu))

        XCTAssertEqual(controller.state.lastRimeOutput?.rawInput, "shu'53")
        XCTAssertEqual(controller.state.t9PinyinPathState.confirmedSegmentValues, ["shu"])
        XCTAssertEqual(controller.state.partialCommit?.remainingPreeditText, "shule")
        XCTAssertEqual(controller.state.partialCommit?.displayText, "偷偷买shule")
        XCTAssertEqual(client.markedText, "偷偷买shule")
        XCTAssertFalse(client.markedText.contains(where: \.isNumber))
    }

    // MARK: - Gate 5 Phase 0 red tests (qingweifandaowozuili)

    /// Source digit ledger for `qingweifandaowozuili`.
    private var gate5FullDigits: String { "74649343263269698454" }
    private var gate5FullComment: String { "qing wei fan dao wo zui li" }

    private func makeGate5Engine(
        finalCandidates: [String],
        selectionRemainders: [String: [Int: String]],
        selectedSegments: [String: [Int: FakeRimeSelectedSegment]] = [:]
    ) -> FakeRimeEngine {
        let full = gate5FullDigits
        let qingRaw = "qing9343263269698454"
        let qingWeiRaw = "qing'wei'3263269698454"
        let qingWeiFanRaw = "qing'wei'fan'3269698454"
        let qingWeiFanDaoRaw = "qing'wei'fan'dao'9698454"
        let remainderDigits = "9698454"
        var dictionary: [String: [String]] = [
            full: ["请喂饭到我嘴里"],
            qingRaw: ["请喂饭到我嘴里"],
            qingWeiRaw: ["请喂饭到我嘴里"],
            qingWeiFanRaw: ["请喂饭到我嘴里"],
            qingWeiFanDaoRaw: finalCandidates,
            remainderDigits: ["我嘴里", "我", "握"],
            // Mixed remaining after single-char 请 (device-like anchored form).
            "wei'fan'dao'9698454": ["喂饭到我嘴里", "喂饭到", "喂饭"],
            "wei fan dao wo zui li": ["喂饭到我嘴里"],
        ]
        var comments: [String: [String]] = [
            full: [gate5FullComment],
            qingRaw: [gate5FullComment],
            qingWeiRaw: [gate5FullComment],
            qingWeiFanRaw: [gate5FullComment],
            qingWeiFanDaoRaw: [gate5FullComment, "qing wei fan dao", "qing"],
            remainderDigits: ["wo zui li", "wo", "wo"],
            "wei'fan'dao'9698454": ["wei fan dao wo zui li", "wei fan dao", "wei fan"],
        ]
        // Support progressive path replace targets used during selection.
        for key in [qingRaw, qingWeiRaw, qingWeiFanRaw, qingWeiFanDaoRaw] {
            dictionary[key] = dictionary[key] ?? finalCandidates
            comments[key] = comments[key] ?? [gate5FullComment]
        }
        let engine = FakeRimeEngine(
            dictionary: dictionary,
            comments: comments,
            selectionRemainders: selectionRemainders,
            selectedSegments: selectedSegments,
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
        return engine
    }

    @discardableResult
    private func gate5TypeFullDigits(into controller: KeyboardController) -> [String] {
        var trail: [String] = []
        for digit in gate5FullDigits {
            _ = controller.handle(.insertKey(String(digit)))
            trail.append(
                "digit=\(digit) raw=\(controller.state.lastRimeOutput?.rawInput ?? "nil") "
                    + "src=\(controller.state.t9PinyinPathState.segmentSourceDigits ?? "nil") "
                    + "conf=\(controller.state.t9PinyinPathState.confirmedSegmentValues) "
                    + "paths=\(controller.state.t9PinyinPathState.compactPaths.map(\.displayText).prefix(6))"
            )
        }
        return trail
    }

    @discardableResult
    private func gate5SelectPaths(
        _ syllables: [String],
        controller: KeyboardController
    ) throws -> [String] {
        var trail: [String] = []
        for expected in syllables {
            let path = try XCTUnwrap(
                controller.state.t9PinyinPathState.compactPaths.first {
                    $0.displayText == expected
                },
                "missing path \(expected); raw=\(controller.state.lastRimeOutput?.rawInput ?? "nil") "
                    + "paths=\(controller.state.t9PinyinPathState.compactPaths.map(\.displayText))"
            )
            let windowBefore = (controller.rimeEngine as? FakeRimeEngine)?.candidateWindowCallCount ?? -1
            _ = controller.handle(.selectT9PinyinPath(path))
            let windowAfter = (controller.rimeEngine as? FakeRimeEngine)?.candidateWindowCallCount ?? -1
            trail.append(
                "select=\(expected) raw=\(controller.state.lastRimeOutput?.rawInput ?? "nil") "
                    + "src=\(controller.state.t9PinyinPathState.segmentSourceDigits ?? "nil") "
                    + "conf=\(controller.state.t9PinyinPathState.confirmedSegmentValues) "
                    + "focus=\(String(describing: controller.state.t9PinyinPathState.focusedSegmentIndex)) "
                    + "paths=\(controller.state.t9PinyinPathState.compactPaths.map(\.displayText).prefix(8)) "
                    + "windowDelta=\(windowAfter - windowBefore)"
            )
        }
        return trail
    }

    /// Path A: full candidate「请喂饭到」must rebase Path to `wo…`.
    func testGate5AFullCandidateRebasesPathToWo() throws {
        #if DEBUG
        T9Gate5CompositionTrace.reset()
        #endif
        let qingWeiFanDaoRaw = "qing'wei'fan'dao'9698454"
        let remainderRaw = "9698454"
        let engine = makeGate5Engine(
            finalCandidates: ["请喂饭到我嘴里", "请喂饭到", "请"],
            selectionRemainders: [qingWeiFanDaoRaw: [1: remainderRaw]]
        )
        let (controller, client) = makeController(engine: engine)
        controller.usesT9InputSemantics = true

        let typeTrail = gate5TypeFullDigits(into: controller)
        let pathTrail = try gate5SelectPaths(
            ["qing", "wei", "fan", "dao"],
            controller: controller
        )
        XCTAssertEqual(controller.state.lastRimeOutput?.rawInput, qingWeiFanDaoRaw)
        XCTAssertEqual(controller.state.t9PinyinPathState.confirmedSegmentValues, ["qing", "wei", "fan", "dao"])

        let windowBefore = engine.candidateWindowCallCount
        _ = controller.handle(
            .insertCandidate(
                "请喂饭到",
                kind: .candidate,
                selectionReference: CandidateSelectionReference(page: 0, indexOnPage: 1)
            )
        )
        let windowAfter = engine.candidateWindowCallCount

        // Phase 0 evidence capture (not private text — structural only).
        let snapshot = controller.t9CompositionPresentationSnapshot()
        fputs(
            "GATE5_A capture: prevRawClass=anchoredMixed resultRaw=\(controller.state.lastRimeOutput?.rawInput ?? "nil") "
                + "partialRemaining=\(controller.state.partialCommit?.remainingRawInput ?? "nil") "
                + "src=\(controller.state.t9PinyinPathState.segmentSourceDigits ?? "nil") "
                + "conf=\(controller.state.t9PinyinPathState.confirmedSegmentValues) "
                + "focus=\(String(describing: controller.state.t9PinyinPathState.focusedSegmentIndex)) "
                + "paths=\(controller.state.t9PinyinPathState.compactPaths.map(\.displayText)) "
                + "snapshotRev=\(snapshot.revision) "
                + "windowDelta=\(windowAfter - windowBefore) "
                + "typeSteps=\(typeTrail.count) pathSteps=\(pathTrail.count)\n",
            stderr
        )

        XCTAssertEqual(controller.state.partialCommit?.confirmedText, "请喂饭到")
        XCTAssertEqual(controller.state.lastRimeOutput?.rawInput, remainderRaw)
        XCTAssertTrue(
            controller.state.t9PinyinPathState.compactPaths.contains { $0.displayText == "wo" },
            "Path A must focus remainder wo…; paths=\(controller.state.t9PinyinPathState.compactPaths.map(\.displayText))"
        )
        XCTAssertFalse(
            controller.state.t9PinyinPathState.compactPaths.contains {
                ["qing", "wei", "fan", "dao"].contains($0.displayText)
            }
        )
        XCTAssertTrue(client.markedText.hasPrefix("请喂饭到"))
        XCTAssertTrue(client.markedTextHistory.allSatisfy { !$0.contains(where: \.isNumber) })
        XCTAssertEqual(windowAfter - windowBefore, 0, "identity rebase must not open candidateWindow")
    }

    /// Path B: single-char「请」must keep remaining Path identity (wei/fan/dao → focus wo).
    /// Phase 0 RED: destructive clear + pure-digit restore guard + missing slot-rebase model.
    func testGate5BSingleCharacterPartialKeepsRemainingSelectedSegmentsAndFocusesWo() throws {
        #if DEBUG
        T9Gate5CompositionTrace.reset()
        #endif
        let qingWeiFanDaoRaw = "qing'wei'fan'dao'9698454"
        // Device-like mixed remaining after single-char partial (not pure digits).
        let mixedRemaining = "wei'fan'dao'9698454"
        let engine = makeGate5Engine(
            finalCandidates: ["请喂饭到我嘴里", "请喂饭到", "请"],
            selectionRemainders: [qingWeiFanDaoRaw: [2: mixedRemaining]]
        )
        let (controller, client) = makeController(engine: engine)
        controller.usesT9InputSemantics = true

        _ = gate5TypeFullDigits(into: controller)
        _ = try gate5SelectPaths(["qing", "wei", "fan", "dao"], controller: controller)
        XCTAssertEqual(controller.state.t9PinyinPathState.confirmedSegmentValues, ["qing", "wei", "fan", "dao"])
        let sourceBefore = controller.state.t9PinyinPathState.segmentSourceDigits
        let windowBefore = engine.candidateWindowCallCount

        _ = controller.handle(
            .insertCandidate(
                "请",
                kind: .candidate,
                selectionReference: CandidateSelectionReference(page: 0, indexOnPage: 2)
            )
        )
        let windowAfter = engine.candidateWindowCallCount

        fputs(
            "GATE5_B capture: resultRaw=\(controller.state.lastRimeOutput?.rawInput ?? "nil") "
                + "rawIsPureDigits=\(controller.state.lastRimeOutput?.rawInput?.allSatisfy(\.isNumber) ?? false) "
                + "partialRemaining=\(controller.state.partialCommit?.remainingRawInput ?? "nil") "
                + "srcBefore=\(sourceBefore ?? "nil") "
                + "srcAfter=\(controller.state.t9PinyinPathState.segmentSourceDigits ?? "nil") "
                + "conf=\(controller.state.t9PinyinPathState.confirmedSegmentValues) "
                + "focus=\(String(describing: controller.state.t9PinyinPathState.focusedSegmentIndex)) "
                + "paths=\(controller.state.t9PinyinPathState.compactPaths.map(\.displayText)) "
                + "pathEmpty=\(controller.state.t9PinyinPathState.compactPaths.isEmpty) "
                + "windowDelta=\(windowAfter - windowBefore)\n",
            stderr
        )

        XCTAssertEqual(controller.state.partialCommit?.confirmedText, "请")
        // Remaining must not require pure-digit raw only — mixed remaining is the B failure shape.
        XCTAssertEqual(controller.state.lastRimeOutput?.rawInput, mixedRemaining)

        // Contract: 请 only consumes `qing`; wei/fan/dao stay as confirmed path segments;
        // focus advances to wo on remaining source suffix.
        XCTAssertEqual(
            controller.state.t9PinyinPathState.confirmedSegmentValues,
            ["wei", "fan", "dao"],
            "single-char 请 must not wipe wei/fan/dao path selections"
        )
        XCTAssertTrue(
            controller.state.t9PinyinPathState.compactPaths.contains { $0.displayText == "wo" },
            "Path B must focus wo… after 请; paths=\(controller.state.t9PinyinPathState.compactPaths.map(\.displayText))"
        )
        XCTAssertFalse(
            controller.state.t9PinyinPathState.compactPaths.isEmpty,
            "Path bar must not go empty after single-char partial"
        )
        XCTAssertFalse(
            controller.state.t9PinyinPathState.compactPaths.map(\.displayText).contains("qing"),
            "qing was consumed by 请 and must not remain as a path choice"
        )
        XCTAssertTrue(client.markedText.hasPrefix("请"))
        XCTAssertTrue(client.markedTextHistory.allSatisfy { !$0.contains(where: \.isNumber) })
        XCTAssertEqual(windowAfter - windowBefore, 0)
    }

    /// Device-calibrated Path B morphology (iPhone 13 Pro, 2026-07-23):
    /// selecting single-character 请 leaves RIME raw **unchanged**.
    ///
    /// Residual-B (PD residual-B Path-ledger peel): Path-confirmed syllables are
    /// authority — peel leading `qing` only; keep `wei/fan/dao` and focus `wo`.
    /// Still forbidden: invent slots from 汉字数 / comment / sel_* / caret.
    func testGate5BDeviceUnchangedRawStillConsumesQingAndPreservesRemainingIdentity() throws {
        let qingWeiFanDaoRaw = "qing'wei'fan'dao'9698454"
        let engine = makeGate5Engine(
            finalCandidates: ["请喂饭到我嘴里", "请喂饭到", "请"],
            selectionRemainders: [:],
            selectedSegments: [
                qingWeiFanDaoRaw: [
                    2: FakeRimeSelectedSegment(rawPrefix: "qing'", text: "请")
                ]
            ]
        )
        let (controller, client) = makeController(engine: engine)
        controller.usesT9InputSemantics = true

        _ = gate5TypeFullDigits(into: controller)
        _ = try gate5SelectPaths(["qing", "wei", "fan", "dao"], controller: controller)
        let sourceBefore = try XCTUnwrap(controller.state.t9PinyinPathState.segmentSourceDigits)
        XCTAssertEqual(controller.state.t9PinyinPathState.confirmedSegmentValues, ["qing", "wei", "fan", "dao"])

        let windowBefore = engine.candidateWindowCallCount
        _ = controller.handle(
            .insertCandidate(
                "请",
                kind: .candidate,
                selectionReference: CandidateSelectionReference(page: 0, indexOnPage: 2)
            )
        )
        let windowAfter = engine.candidateWindowCallCount

        // Precondition: engine left raw unchanged before Path-ledger peel resync.
        // After residual-B peel, Core peels first Path syllable and resyncs remaining.
        XCTAssertEqual(controller.state.partialCommit?.confirmedText, "请")
        XCTAssertEqual(
            controller.state.t9PinyinPathState.confirmedSegmentValues,
            ["wei", "fan", "dao"],
            "Path-ledger peel must keep wei/fan/dao after single-char 请"
        )
        XCTAssertEqual(
            controller.state.t9PinyinPathState.segmentSourceDigits,
            String(sourceBefore.dropFirst(4)),
            "peel qing slots from Path ledger (7464), not invent via 汉字数"
        )
        XCTAssertTrue(
            controller.state.t9PinyinPathState.compactPaths.contains { $0.displayText == "wo" },
            "Path B must focus wo…; paths=\(controller.state.t9PinyinPathState.compactPaths.map(\.displayText))"
        )
        XCTAssertFalse(controller.state.t9PinyinPathState.compactPaths.isEmpty)
        XCTAssertTrue(client.markedText.hasPrefix("请"))
        XCTAssertTrue(client.markedTextHistory.allSatisfy { !$0.contains(where: \.isNumber) })
        XCTAssertEqual(windowAfter - windowBefore, 0)
        // Engine was resynced off full pre-selection raw onto remaining identity.
        XCTAssertNotEqual(
            controller.state.lastRimeOutput?.rawInput,
            qingWeiFanDaoRaw,
            "resync must leave full qing'wei'fan'dao'… after Path-ledger peel"
        )
    }

    /// Path B root-cause contract: after Partial consumes only `qing`, unconsumed
    /// `wei/fan/dao` must be slot-rebased onto the remaining source — not merely
    /// rejected by a pure-digit liveRaw guard. Phase 0: RED on current production.
    func testGate5BPartialConsumesQingRequiresSlotRebaseOfRemainingSegments() throws {
        let qingWeiFanDaoRaw = "qing'wei'fan'dao'9698454"
        let mixedRemaining = "wei'fan'dao'9698454"
        let engine = makeGate5Engine(
            finalCandidates: ["请喂饭到我嘴里", "请喂饭到", "请"],
            selectionRemainders: [qingWeiFanDaoRaw: [2: mixedRemaining]]
        )
        let (controller, _) = makeController(engine: engine)
        controller.usesT9InputSemantics = true
        _ = gate5TypeFullDigits(into: controller)
        _ = try gate5SelectPaths(["qing", "wei", "fan", "dao"], controller: controller)

        let sourceBefore = try XCTUnwrap(controller.state.t9PinyinPathState.segmentSourceDigits)
        XCTAssertEqual(sourceBefore, gate5FullDigits)

        // Slot map before partial: qing[0..<4] wei[4..<7] fan[7..<10] dao[10..<13] wo…[13...]
        let expectedQingRange = 0..<4
        let expectedWeiRange = 4..<7
        let expectedFanRange = 7..<10
        let expectedDaoRange = 10..<13
        XCTAssertEqual(String(sourceBefore[sourceBefore.index(sourceBefore.startIndex, offsetBy: expectedQingRange.lowerBound)..<sourceBefore.index(sourceBefore.startIndex, offsetBy: expectedQingRange.upperBound)]), "7464")
        XCTAssertEqual(String(sourceBefore[sourceBefore.index(sourceBefore.startIndex, offsetBy: expectedWeiRange.lowerBound)..<sourceBefore.index(sourceBefore.startIndex, offsetBy: expectedWeiRange.upperBound)]), "934")
        XCTAssertEqual(String(sourceBefore[sourceBefore.index(sourceBefore.startIndex, offsetBy: expectedFanRange.lowerBound)..<sourceBefore.index(sourceBefore.startIndex, offsetBy: expectedFanRange.upperBound)]), "326")
        XCTAssertEqual(String(sourceBefore[sourceBefore.index(sourceBefore.startIndex, offsetBy: expectedDaoRange.lowerBound)..<sourceBefore.index(sourceBefore.startIndex, offsetBy: expectedDaoRange.upperBound)]), "326")

        _ = controller.handle(
            .insertCandidate(
                "请",
                kind: .candidate,
                selectionReference: CandidateSelectionReference(page: 0, indexOnPage: 2)
            )
        )

        // Shortened mixed remainder **is** an authorized β-limited branch — expect
        // successful slot realign (no longer RED / slotRebaseMissing).
        #if DEBUG
        let lines = T9Gate5CompositionTrace.snapshotLines()
        XCTAssertTrue(
            lines.contains { $0.contains("event=partialCommit") && $0.contains("restore=true") },
            "shortened remainder must restore identity; lines=\(lines.suffix(3))"
        )
        #endif

        // Contract after consuming qing only:
        // - remaining source = drop first 4 slots
        // - confirmed rebases to wei/fan/dao on the new ledger (not empty)
        // - focus on wo
        let expectedRemainingSource = String(sourceBefore.dropFirst(4))
        XCTAssertEqual(
            controller.state.t9PinyinPathState.segmentSourceDigits,
            expectedRemainingSource,
            "B requires slot rebase of remaining source after consuming qing"
        )
        XCTAssertEqual(
            controller.state.t9PinyinPathState.confirmedSegmentValues,
            ["wei", "fan", "dao"],
            "B root cause: no slot-rebase model for unconsumed wei/fan/dao after qing partial"
        )
        XCTAssertTrue(
            controller.state.t9PinyinPathState.compactPaths.contains { $0.displayText == "wo" }
        )
    }

    /// Snapshot after Path B partial must publish non-empty Path + candidates + marked text
    /// on the same revision. Phase 0: RED while Path is wiped (no vacuous empty-path pass).
    func testGate5PartialTransitionPublishesSingleCoherentRevision() throws {
        let qingWeiFanDaoRaw = "qing'wei'fan'dao'9698454"
        let engine = makeGate5Engine(
            finalCandidates: ["请喂饭到我嘴里", "请喂饭到", "请"],
            selectionRemainders: [qingWeiFanDaoRaw: [2: "wei'fan'dao'9698454"]]
        )
        let (controller, client) = makeController(engine: engine)
        controller.usesT9InputSemantics = true
        _ = gate5TypeFullDigits(into: controller)
        _ = try gate5SelectPaths(["qing", "wei", "fan", "dao"], controller: controller)
        _ = controller.handle(
            .insertCandidate(
                "请",
                kind: .candidate,
                selectionReference: CandidateSelectionReference(page: 0, indexOnPage: 2)
            )
        )
        let snapshot = controller.t9CompositionPresentationSnapshot()
        XCTAssertEqual(snapshot.revision, controller.state.compositionRevision)
        XCTAssertFalse(
            snapshot.paths.isEmpty,
            "coherent revision requires non-empty Path after single-char partial"
        )
        XCTAssertFalse(
            snapshot.candidates.isEmpty,
            "coherent revision requires non-empty candidates after single-char partial"
        )
        XCTAssertFalse(snapshot.visiblePreedit.isEmpty || client.markedText.isEmpty)
        XCTAssertEqual(
            snapshot.paths.map(\.displayText),
            controller.state.t9PinyinPathState.compactPaths.map(\.displayText)
        )
        XCTAssertEqual(
            snapshot.candidates.map(\.text),
            controller.state.lastRimeOutput?.candidates.map(\.text)
        )
        XCTAssertTrue(
            controller.state.t9PinyinPathState.compactPaths.contains { $0.displayText == "wo" }
        )
        XCTAssertTrue(client.markedText.hasPrefix("请"))
    }

    /// After Path B partial, first Delete must restore exact pre-partial T9 semantic checkpoint
    /// (digits + confirmed syllables + focus), not a collapsed empty Path.
    /// Phase 0: RED while B identity is wiped.
    func testGate5BFirstDeleteRestoresExactT9SemanticCheckpoint() throws {
        let qingWeiFanDaoRaw = "qing'wei'fan'dao'9698454"
        let mixedRemaining = "wei'fan'dao'9698454"
        let engine = makeGate5Engine(
            finalCandidates: ["请喂饭到我嘴里", "请喂饭到", "请"],
            selectionRemainders: [qingWeiFanDaoRaw: [2: mixedRemaining]]
        )
        let (controller, client) = makeController(engine: engine)
        controller.usesT9InputSemantics = true

        _ = gate5TypeFullDigits(into: controller)
        _ = try gate5SelectPaths(["qing", "wei", "fan", "dao"], controller: controller)

        let prePartialSource = controller.state.t9PinyinPathState.segmentSourceDigits
        let prePartialConfirmed = controller.state.t9PinyinPathState.confirmedSegmentValues
        let prePartialRaw = controller.state.lastRimeOutput?.rawInput
        let prePartialFocus = controller.state.t9PinyinPathState.focusedSegmentIndex

        _ = controller.handle(
            .insertCandidate(
                "请",
                kind: .candidate,
                selectionReference: CandidateSelectionReference(page: 0, indexOnPage: 2)
            )
        )
        XCTAssertEqual(controller.state.partialCommit?.confirmedText, "请")
        XCTAssertNotNil(controller.state.partialCommit?.checkpoint)

        let windowBefore = engine.candidateWindowCallCount
        _ = controller.handle(.deleteBackward)
        let windowAfter = engine.candidateWindowCallCount

        fputs(
            "GATE5_B_DELETE capture: raw=\(controller.state.lastRimeOutput?.rawInput ?? "nil") "
                + "src=\(controller.state.t9PinyinPathState.segmentSourceDigits ?? "nil") "
                + "conf=\(controller.state.t9PinyinPathState.confirmedSegmentValues) "
                + "focus=\(String(describing: controller.state.t9PinyinPathState.focusedSegmentIndex)) "
                + "paths=\(controller.state.t9PinyinPathState.compactPaths.map(\.displayText).prefix(8)) "
                + "partial=\(controller.state.partialCommit?.confirmedText ?? "nil") "
                + "windowDelta=\(windowAfter - windowBefore)\n",
            stderr
        )

        // First Delete undoes Partial checkpoint semantics, not a raw slot peel.
        XCTAssertNil(controller.state.partialCommit)
        XCTAssertEqual(controller.state.t9PinyinPathState.segmentSourceDigits, prePartialSource)
        XCTAssertEqual(controller.state.t9PinyinPathState.confirmedSegmentValues, prePartialConfirmed)
        XCTAssertEqual(controller.state.t9PinyinPathState.focusedSegmentIndex, prePartialFocus)
        XCTAssertEqual(controller.state.lastRimeOutput?.rawInput, prePartialRaw)
        XCTAssertTrue(
            controller.state.t9PinyinPathState.compactPaths.contains { $0.displayText == "wo" }
                || controller.state.t9PinyinPathState.confirmedSegmentValues == ["qing", "wei", "fan", "dao"],
            "checkpoint restore must reattach pre-partial path identity"
        )
        XCTAssertTrue(client.markedTextHistory.allSatisfy { !$0.contains(where: \.isNumber) })
        XCTAssertEqual(windowAfter - windowBefore, 0, "checkpoint restore must not open candidateWindow")
    }

    /// Phase 0 structural proof: mixed remaining after single-char partial is a unique
    /// T9 digit suffix of the original source (no need to guess by hanzi count).
    /// Strict mixed-raw validation for Path B remaining form.
    /// Rejects illegal chars; requires apostrophe segment boundaries, catalog-legal
    /// syllables, and exact slot ranges on the original source — not mere hasSuffix.
    func testGate5BMixedRemainingStrictSlotAndCatalogValidation() throws {
        let source = gate5FullDigits
        let mixed = "wei'fan'dao'9698454"

        XCTAssertThrowsError(try gate5ParseMixedRemaining("wei'fan'dao'9698454!", source: source))
        XCTAssertThrowsError(try gate5ParseMixedRemaining("wei fan dao 9698454", source: source))
        XCTAssertThrowsError(try gate5ParseMixedRemaining("wei'fan'dao", source: source))
        XCTAssertThrowsError(try gate5ParseMixedRemaining("xyz'fan'dao'9698454", source: source))

        let parsed = try gate5ParseMixedRemaining(mixed, source: source)
        XCTAssertEqual(parsed.syllables, ["wei", "fan", "dao"])
        XCTAssertEqual(parsed.trailingDigits, "9698454")
        XCTAssertEqual(parsed.encodedSignature, "9343263269698454")
        XCTAssertEqual(parsed.slotRanges.map(\.lowerBound), [4, 7, 10])
        XCTAssertEqual(parsed.slotRanges.map(\.upperBound), [7, 10, 13])
        for (syllable, range) in zip(parsed.syllables, parsed.slotRanges) {
            let start = source.index(source.startIndex, offsetBy: range.lowerBound)
            let end = source.index(source.startIndex, offsetBy: range.upperBound)
            let slice = String(source[start..<end])
            XCTAssertEqual(slice, gate5EncodeLettersAndDigitsToT9Signature(syllable))
            XCTAssertTrue(
                gate5IsCatalogLegalSyllable(syllable),
                "syllable \(syllable) must be catalog-legal"
            )
        }
        XCTAssertEqual(parsed.trailingDigitRange, 13..<20)
        XCTAssertEqual(String(source.dropFirst(13)), "9698454")
        XCTAssertEqual(parsed.consumedPrefixSlots, 4)
        XCTAssertEqual(String(source.prefix(4)), "7464")
        XCTAssertNotEqual(parsed.consumedPrefixSlots, 7)
    }

    private struct Gate5MixedRemainingParse {
        let syllables: [String]
        let trailingDigits: String
        let encodedSignature: String
        let slotRanges: [Range<Int>]
        let trailingDigitRange: Range<Int>
        let consumedPrefixSlots: Int
    }

    private enum Gate5ParseError: Error {
        case illegalCharacter
        case missingApostropheBoundary
        case missingDigitTail
        case missingSyllables
        case illegalSyllableToken
        case notCatalogLegal
        case notSourceSuffix
        case slotMismatch
        case trailingSlotMismatch
    }

    private func gate5ParseMixedRemaining(
        _ raw: String,
        source: String
    ) throws -> Gate5MixedRemainingParse {
        for ch in raw {
            let ok = ch.isASCII && (ch.isLetter || ch.isNumber || ch == "'")
            if !ok { throw Gate5ParseError.illegalCharacter }
        }
        let parts = raw.split(separator: "'", omittingEmptySubsequences: false).map(String.init)
        guard parts.count >= 2 else { throw Gate5ParseError.missingApostropheBoundary }
        let trailing = parts.last!
        guard !trailing.isEmpty, trailing.allSatisfy(\.isNumber) else {
            throw Gate5ParseError.missingDigitTail
        }
        let syllables = Array(parts.dropLast())
        guard !syllables.isEmpty else { throw Gate5ParseError.missingSyllables }
        for s in syllables {
            guard !s.isEmpty, s.allSatisfy(\.isLetter) else {
                throw Gate5ParseError.illegalSyllableToken
            }
            guard gate5IsCatalogLegalSyllable(s) else {
                throw Gate5ParseError.notCatalogLegal
            }
        }
        let letterSig = syllables.map { gate5EncodeLettersAndDigitsToT9Signature($0) }.joined()
        let encoded = letterSig + trailing
        guard source.hasSuffix(encoded) else { throw Gate5ParseError.notSourceSuffix }
        let consumed = source.count - encoded.count
        var ranges: [Range<Int>] = []
        var cursor = consumed
        for s in syllables {
            let len = s.count
            let range = cursor..<(cursor + len)
            let start = source.index(source.startIndex, offsetBy: range.lowerBound)
            let end = source.index(source.startIndex, offsetBy: range.upperBound)
            let slice = String(source[start..<end])
            guard slice == gate5EncodeLettersAndDigitsToT9Signature(s) else {
                throw Gate5ParseError.slotMismatch
            }
            ranges.append(range)
            cursor += len
        }
        let digitRange = cursor..<(cursor + trailing.count)
        guard digitRange.upperBound == source.count else { throw Gate5ParseError.trailingSlotMismatch }
        return Gate5MixedRemainingParse(
            syllables: syllables,
            trailingDigits: trailing,
            encodedSignature: encoded,
            slotRanges: ranges,
            trailingDigitRange: digitRange,
            consumedPrefixSlots: consumed
        )
    }

    private func gate5IsCatalogLegalSyllable(_ syllable: String) -> Bool {
        T9PinyinSyllableCatalog.syllables.contains(syllable)
    }

    /// Map ASCII letters via standard T9 groups; keep pure digit runs; drop apostrophes/spaces.
    private func gate5EncodeLettersAndDigitsToT9Signature(_ raw: String) -> String {
        let map: [Character: Character] = [
            "a": "2", "b": "2", "c": "2",
            "d": "3", "e": "3", "f": "3",
            "g": "4", "h": "4", "i": "4",
            "j": "5", "k": "5", "l": "5",
            "m": "6", "n": "6", "o": "6",
            "p": "7", "q": "7", "r": "7", "s": "7",
            "t": "8", "u": "8", "v": "8",
            "w": "9", "x": "9", "y": "9", "z": "9",
        ]
        var out = ""
        for ch in raw.lowercased() {
            if ch.isNumber { out.append(ch) }
            else if let d = map[ch] { out.append(d) }
        }
        return out
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
