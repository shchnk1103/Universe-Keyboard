import XCTest

@testable import KeyboardCore

@MainActor
final class TypoCorrectionRuntimeIntegrationTests: XCTestCase {
    func testCoverageDeficitRequiresEmptyStageOneAndRemainingBudget() {
        XCTAssertTrue(
            typoCorrectionRecallHasCoverageDeficit(
                acceptedDisplayCount: 0,
                unaccountedSelectedGroupCount: 2,
                remainingQueryAttempts: 8
            )
        )
        XCTAssertFalse(
            typoCorrectionRecallHasCoverageDeficit(
                acceptedDisplayCount: 1,
                unaccountedSelectedGroupCount: 2,
                remainingQueryAttempts: 8
            )
        )
        XCTAssertFalse(
            typoCorrectionRecallHasCoverageDeficit(
                acceptedDisplayCount: 0,
                unaccountedSelectedGroupCount: 0,
                remainingQueryAttempts: 8
            )
        )
        XCTAssertFalse(
            typoCorrectionRecallHasCoverageDeficit(
                acceptedDisplayCount: 0,
                unaccountedSelectedGroupCount: 2,
                remainingQueryAttempts: 0
            )
        )
    }

    func testDriverYieldsAfterEachQueryAndDoesNotStartTheNextOnTheReturnStack() {
        let token = fence(composition: "wimenjintianquhongyuan")
        let first = suggestion("womenjintianquhongyuan")
        var driver = TypoCorrectionRecallDriver(token: token, stageOneHypotheses: [first])

        guard case .query(let query) = driver.nextEvent(currentFence: token) else {
            return XCTFail("expected first query")
        }
        XCTAssertEqual(query.correctedInput, first.correctedInput)

        let afterReturn = driver.finishQuery(
            currentFence: token,
            candidates: [RimeCandidate(text: "我们今天去公园")]
        )
        XCTAssertEqual(afterReturn, .waitForYield)
        XCTAssertEqual(driver.nextEvent(currentFence: token), .waitForYield)

        XCTAssertTrue(driver.acknowledgeYield(currentFence: token))
        guard case .assessCoverage = driver.nextEvent(currentFence: token) else {
            return XCTFail("expected coverage assessment after the yielded turn")
        }
    }

    func testStaleFenceAfterReturnDiscardsAndDoesNotApply() {
        let token = fence(composition: "wimenjintianquhongyuan")
        var driver = TypoCorrectionRecallDriver(
            token: token,
            stageOneHypotheses: [suggestion("womenjintianquhongyuan")]
        )
        _ = driver.nextEvent(currentFence: token)
        var stale = token
        stale.recallEpoch += 1
        XCTAssertEqual(
            driver.finishQuery(currentFence: stale, candidates: [RimeCandidate(text: "我们")]),
            .discarded
        )
    }

    func testStageTwoAbstainsWhenStageOneAlreadyHasAcceptedDisplayResults() {
        let token = fence(composition: "wimenjintianquhongyuan")
        var driver = TypoCorrectionRecallDriver(
            token: token,
            stageOneHypotheses: [suggestion("womenjintianquhongyuan")]
        )
        _ = driver.nextEvent(currentFence: token)
        _ = driver.finishQuery(
            currentFence: token,
            candidates: [RimeCandidate(text: "我们今天去公园")]
        )
        XCTAssertTrue(driver.acknowledgeYield(currentFence: token))
        guard case .assessCoverage(let stageOne) = driver.nextEvent(currentFence: token) else {
            return XCTFail("expected coverage assessment")
        }
        XCTAssertEqual(stageOne.count, 1)
        guard
            case .readyToApply(let material) = driver.completeCoverageAssessment(
                currentFence: token,
                acceptedDisplayCount: 1
            )
        else {
            return XCTFail("stage two must abstain")
        }
        XCTAssertTrue(material.stageTwo.isEmpty)
        XCTAssertEqual(material.stageOne.count, 1)
    }

    func testConditionalApplyWritesOnceAndIsDisplayNoOpWhenCompositionChanged() {
        let query = RecordingRuntimeTypoCorrectionQuery(
            dictionary: ["womenjintianquhongyuan": ["我们今天去公园"]]
        )
        let controller = KeyboardController()
        controller.rimeEngine = FakeRimeEngine(dictionary: ["wimenjintianquhongyuan": ["无关"]])
        controller.typoCorrectionCandidateQuery = query

        for key in "wimenjintianquhongyuan" {
            _ = controller.handle(.insertKey(String(key)))
        }

        let token = fence(composition: "wimenjintianquhongyuan")
        let material = TypoCorrectionRecallMaterial(
            token: token,
            originalInput: "wimenjintianquhongyuan",
            stageOne: [
                TypoCorrectionSuggestion(
                    originalInput: "wimenjintianquhongyuan",
                    correctedInput: "womenjintianquhongyuan",
                    edits: [
                        TypoCorrectionEdit(index: 1, original: "i", replacement: "o"),
                        TypoCorrectionEdit(index: 14, original: "h", replacement: "g"),
                    ],
                    candidates: [RimeCandidate(text: "我们今天去公园")]
                )
            ],
            stageTwo: []
        )

        XCTAssertTrue(controller.applyTypoCorrectionRecallMaterial(material))
        XCTAssertEqual(
            controller.state.typoCorrection?.suggestions.first?.candidates.first?.text,
            "我们今天去公园"
        )

        _ = controller.handle(.insertKey("a"))
        XCTAssertFalse(controller.applyTypoCorrectionRecallMaterial(material))
    }

    func testEmptyRecallMaterialDoesNotMutateExistingDisplayState() {
        let controller = KeyboardController()
        controller.rimeEngine = FakeRimeEngine(dictionary: ["nihap": ["无关"]])
        controller.typoCorrectionCandidateQuery = RecordingRuntimeTypoCorrectionQuery(
            dictionary: ["nihao": ["你好"]]
        )

        for key in "nihap" {
            _ = controller.handle(.insertKey(String(key)))
        }
        controller.refreshTypoCorrectionSuggestions()
        let before = controller.state.typoCorrection
        XCTAssertNotNil(before)

        let empty = TypoCorrectionRecallMaterial(
            token: fence(composition: "nihap"),
            originalInput: "nihap",
            stageOne: [],
            stageTwo: []
        )

        XCTAssertFalse(controller.applyTypoCorrectionRecallMaterial(empty))
        XCTAssertEqual(controller.state.typoCorrection, before)
    }

    func testActiveRecallOwnerBlocksTheLegacyHotPathUntilItEnds() throws {
        let input = "wimenjintianquhongyuan"
        let expectedInput = try XCTUnwrap(
            ContextualTypoCorrectionHypothesisEngine()
                .hypotheses(for: input)
                .first?
                .correctedInput
        )
        let query = RecordingRuntimeTypoCorrectionQuery(
            dictionary: [expectedInput: ["我们今天去公园"]]
        )
        let owner = InstalledTypoCorrectionSidecarOwner(query: query)
        let controller = KeyboardController()
        controller.rimeEngine = FakeRimeEngine(dictionary: [input: ["无关"]])
        controller.typoCorrectionCandidateQuery = owner

        for key in input {
            _ = controller.handle(.insertKey(String(key)))
        }
        let queryCountBeforeRecall = query.inputs.count

        owner.beginTypoCorrectionRecall()
        XCTAssertTrue(controller.refreshContextualTypoCorrectionSuggestions(for: input))
        XCTAssertEqual(query.inputs.count, queryCountBeforeRecall)
        XCTAssertNil(controller.state.typoCorrection)

        owner.endTypoCorrectionRecall()
        XCTAssertTrue(controller.refreshContextualTypoCorrectionSuggestions(for: input))
        XCTAssertGreaterThan(query.inputs.count, queryCountBeforeRecall)
        XCTAssertEqual(
            controller.state.typoCorrection?.suggestions.first?.candidates.first?.text,
            "我们今天去公园"
        )
    }

    func testInstalledSidecarOwnerForwardsToTheFacadeAndNeverInventDefaultEpoch() {
        let inner = RecordingRuntimeTypoCorrectionQuery(dictionary: ["nihao": ["你好"]])
        let owner = InstalledTypoCorrectionSidecarOwner(query: inner)
        XCTAssertEqual(owner.route, .defaultMainActor)
        XCTAssertNil(owner.routeLocalOwnerEpoch)
        XCTAssertFalse(owner.isTypoCorrectionRecallActive)
        owner.beginTypoCorrectionRecall()
        XCTAssertTrue(owner.isTypoCorrectionRecallActive)
        owner.endTypoCorrectionRecall()
        XCTAssertFalse(owner.isTypoCorrectionRecallActive)
        XCTAssertEqual(
            owner.correctionCandidates(for: "nihao", limit: 3).map(\.text),
            ["你好"]
        )
        XCTAssertEqual(inner.inputs, ["nihao"])
    }

    func testInstalledSidecarOwnerPreservesEveryExplicitRouteWithoutUnwrappingItsFacade() {
        for route in TypoCorrectionSidecarRoute.allCases {
            let inner = RecordingRuntimeTypoCorrectionQuery(dictionary: ["nihao": ["你好"]])
            let owner = InstalledTypoCorrectionSidecarOwner(query: inner, route: route)

            XCTAssertEqual(owner.route, route)
            XCTAssertEqual(
                owner.correctionCandidates(for: "nihao", limit: 3).map(\.text),
                ["你好"]
            )
            XCTAssertEqual(inner.inputs, ["nihao"])
        }
    }

    func testClearingCorrectionInvalidatesThroughTheInstalledOwner() {
        let inner = RecordingRuntimeTypoCorrectionQuery(dictionary: [:])
        let owner = InstalledTypoCorrectionSidecarOwner(query: inner)
        let invalidator = RecallInvalidationProbe()
        owner.recallInvalidation = invalidator
        let controller = KeyboardController()
        controller.typoCorrectionCandidateQuery = owner
        controller.clearTypoCorrectionSuggestions()
        XCTAssertEqual(invalidator.count, 1)
    }

    private func fence(composition: String) -> TypoCorrectionRecallFenceSnapshot {
        TypoCorrectionRecallFenceSnapshot(
            recallEpoch: 1,
            compositionRevision: 1,
            operationOrdinal: 1,
            normalizedComposition: composition,
            page: .letters,
            inputMode: .chinese,
            routeLocalOwnerEpoch: nil
        )
    }

    private func suggestion(_ corrected: String) -> TypoCorrectionSuggestion {
        TypoCorrectionSuggestion(
            originalInput: "wimenjintianquhongyuan",
            correctedInput: corrected,
            edits: [
                TypoCorrectionEdit(index: 1, original: "i", replacement: "o"),
                TypoCorrectionEdit(index: 14, original: "h", replacement: "g"),
            ],
            candidates: []
        )
    }
}

private final class RecordingRuntimeTypoCorrectionQuery: TypoCorrectionCandidateQuerying {
    private let dictionary: [String: [String]]
    private(set) var inputs: [String] = []

    init(dictionary: [String: [String]]) {
        self.dictionary = dictionary
    }

    func correctionCandidates(for input: String, limit: Int) -> [RimeCandidate] {
        inputs.append(input)
        return (dictionary[input] ?? []).prefix(max(0, limit)).map { RimeCandidate(text: $0) }
    }
}

private final class RecallInvalidationProbe: TypoCorrectionRecallInvalidating {
    private(set) var count = 0

    func invalidateTypoCorrectionRecall() {
        count += 1
    }
}
