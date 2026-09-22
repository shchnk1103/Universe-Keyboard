import KeyboardCore
import UIKit

/// MainActor owner of one contextual-recall operation: debounce, epoch,
/// yielded one-query turns, fences and the final candidate-bar refresh.
@MainActor
final class TypoCorrectionRecallCoordinator: TypoCorrectionRecallInvalidating {
    private struct YieldedTurnToken: Equatable, Sendable {
        let recallEpoch: UInt64
        let compositionRevision: UInt64
        let operationOrdinal: UInt64

        init(_ fence: TypoCorrectionRecallFenceSnapshot) {
            recallEpoch = fence.recallEpoch
            compositionRevision = fence.compositionRevision
            operationOrdinal = fence.operationOrdinal
        }

        func matches(_ fence: TypoCorrectionRecallFenceSnapshot) -> Bool {
            recallEpoch == fence.recallEpoch
                && compositionRevision == fence.compositionRevision
                && operationOrdinal == fence.operationOrdinal
        }
    }

    private unowned let host: KeyboardViewController
    private var debounceWorkItem: DispatchWorkItem?
    private var driver: TypoCorrectionRecallDriver?
    private var operationOrdinal: UInt64 = 0

    init(host: KeyboardViewController) {
        self.host = host
    }

    func invalidateTypoCorrectionRecall() {
        host.recallEpoch &+= 1
        host.recallCompositionRevision &+= 1
        debounceWorkItem?.cancel()
        debounceWorkItem = nil
        finishRecallOperation()
        host.contextualTypoCorrectionWorkItem?.cancel()
        host.contextualTypoCorrectionWorkItem = nil
    }

    func scheduleAfterCompositionSettled() {
        debounceWorkItem?.cancel()
        host.contextualTypoCorrectionWorkItem?.cancel()

        let expectedComposition = host.controller.state.currentComposition
        guard isEligible(for: expectedComposition) else { return }

        let workItem = DispatchWorkItem { [weak self] in
            self?.startOperation(expectedComposition: expectedComposition)
        }
        debounceWorkItem = workItem
        host.contextualTypoCorrectionWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.18, execute: workItem)
    }

    private func startOperation(expectedComposition: String) {
        let fence = currentFence(expectedComposition: expectedComposition)
        // A recall may not begin until its query facade is wrapped. This keeps
        // the controller-owned lifetime visible to the Core hot path and avoids
        // a transient raw-query writer before bootstrap finishes.
        guard fenceMatchesLiveState(fence), let owner = sidecarOwner else { return }

        operationOrdinal &+= 1
        var token = fence
        token.operationOrdinal = operationOrdinal
        let hypotheses = host.controller.typoCorrectionStageOneHypotheses(
            for: token.normalizedComposition,
            includingContextual: true
        )
        driver = TypoCorrectionRecallDriver(token: token, stageOneHypotheses: hypotheses)
        owner.beginTypoCorrectionRecall()
        continueOperation()
    }

    private func continueOperation() {
        guard var currentDriver = driver else { return }
        let live = liveFence(matching: currentDriver.token)
        switch currentDriver.nextEvent(currentFence: live) {
        case .discarded:
            finishRecallOperation()
        case .waitForYield:
            driver = currentDriver
            scheduleYieldedTurn(for: YieldedTurnToken(currentDriver.token))
        case .query(let suggestion):
            driver = currentDriver
            performQuery(suggestion)
        case .assessCoverage(let stageOne):
            let accepted = host.controller.acceptedDisplayCount(for: stageOne)
            let event = currentDriver.completeCoverageAssessment(
                currentFence: live,
                acceptedDisplayCount: accepted
            )
            driver = currentDriver
            handle(event)
        case .readyToApply(let material):
            driver = currentDriver
            apply(material)
        }
    }

    private func handle(_ event: TypoCorrectionRecallDriveEvent) {
        guard var currentDriver = driver else { return }
        switch event {
        case .discarded:
            finishRecallOperation()
        case .waitForYield:
            driver = currentDriver
            scheduleYieldedTurn(for: YieldedTurnToken(currentDriver.token))
        case .query(let suggestion):
            driver = currentDriver
            performQuery(suggestion)
        case .assessCoverage(let stageOne):
            let accepted = host.controller.acceptedDisplayCount(for: stageOne)
            let nested = currentDriver.completeCoverageAssessment(
                currentFence: liveFence(matching: currentDriver.token),
                acceptedDisplayCount: accepted
            )
            driver = currentDriver
            handle(nested)
        case .readyToApply(let material):
            apply(material)
        }
    }

    private func performQuery(_ suggestion: TypoCorrectionSuggestion) {
        guard var currentDriver = driver else { return }
        let pre = liveFence(matching: currentDriver.token)
        guard pre == currentDriver.token else {
            finishRecallOperation()
            return
        }

        let owner = host.controller.typoCorrectionCandidateQuery
        let candidates = owner.correctionCandidates(
            for: suggestion.correctedInput,
            limit: TypoCorrectionRecallRuntimeBudget.candidateLimit
        )
        let post = liveFence(matching: currentDriver.token)
        let event = currentDriver.finishQuery(currentFence: post, candidates: candidates)
        driver = currentDriver
        if case .discarded = event {
            finishRecallOperation()
            return
        }
        scheduleYieldedTurn(for: YieldedTurnToken(currentDriver.token))
    }

    private func scheduleYieldedTurn(for expectedToken: YieldedTurnToken) {
        RunLoop.main.perform(inModes: [.default]) { [weak self] in
            Task { @MainActor [weak self] in
                self?.performYieldedTurn(for: expectedToken)
            }
        }
    }

    private func performYieldedTurn(for expectedToken: YieldedTurnToken) {
        guard var currentDriver = driver else { return }
        // RunLoop has no cancellation handle. The operation token is therefore
        // the cancellation fence: an old callback must not advance a later
        // driver after invalidate → start has reused this coordinator.
        guard expectedToken.matches(currentDriver.token) else { return }
        let live = liveFence(matching: currentDriver.token)
        guard currentDriver.acknowledgeYield(currentFence: live) else {
            finishRecallOperation()
            return
        }
        driver = currentDriver
        continueOperation()
    }

    private func apply(_ material: TypoCorrectionRecallMaterial) {
        let live = liveFence(matching: material.token)
        guard live == material.token else {
            finishRecallOperation()
            return
        }
        let didApply = host.controller.applyTypoCorrectionRecallMaterial(material)
        let refreshFence = liveFence(matching: material.token)
        finishRecallOperation()
        guard didApply, refreshFence == material.token else { return }
        host.refreshCandidateBar()
    }

    func isEligible(for composition: String) -> Bool {
        host.controller.state.currentPage == .letters
            && host.controller.state.inputMode == .chinese
            && composition.filter { !$0.isWhitespace }.count >= 8
    }

    private func currentFence(expectedComposition: String) -> TypoCorrectionRecallFenceSnapshot {
        TypoCorrectionRecallFenceSnapshot(
            recallEpoch: host.recallEpoch,
            compositionRevision: host.recallCompositionRevision,
            operationOrdinal: operationOrdinal,
            normalizedComposition: host.controller.normalizedTypoCorrectionInput(
                expectedComposition
            ),
            page: host.controller.state.currentPage,
            inputMode: host.controller.state.inputMode,
            routeLocalOwnerEpoch: (host.controller.typoCorrectionCandidateQuery
                as? TypoCorrectionSidecarOwner)?.routeLocalOwnerEpoch
        )
    }

    private func liveFence(
        matching token: TypoCorrectionRecallFenceSnapshot
    ) -> TypoCorrectionRecallFenceSnapshot {
        var live = currentFence(expectedComposition: host.controller.state.currentComposition)
        live.operationOrdinal = token.operationOrdinal
        return live
    }

    private func fenceMatchesLiveState(_ fence: TypoCorrectionRecallFenceSnapshot) -> Bool {
        fence.normalizedComposition
            == host.controller.normalizedTypoCorrectionInput(
                host.controller.state.currentComposition
            )
            && fence.page == host.controller.state.currentPage
            && fence.inputMode == host.controller.state.inputMode
            && fence.recallEpoch == host.recallEpoch
    }

    private var sidecarOwner: TypoCorrectionSidecarOwner? {
        host.controller.typoCorrectionCandidateQuery as? TypoCorrectionSidecarOwner
    }

    private func finishRecallOperation() {
        driver = nil
        sidecarOwner?.endTypoCorrectionRecall()
    }
}
