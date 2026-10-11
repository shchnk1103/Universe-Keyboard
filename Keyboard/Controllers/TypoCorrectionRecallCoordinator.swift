import Foundation

#if DEBUG && KEYBOARD_QUERY_COST_PROBE && KEYBOARD_QUERY_COST_PROBE_TESTING
    @testable import KeyboardCore
#else
    import KeyboardCore
#endif

/// The coordinator needs KeyboardCore state plus a small UI/diagnostics boundary.
/// Keeping that boundary typed lets the extension and the hostless XCTest bundle
/// compile the same coordinator source without linking the `.appex` product.
@MainActor
protocol TypoCorrectionRecallCoordinatorHost: AnyObject {
    var controller: KeyboardController! { get }
    var contextualTypoCorrectionWorkItem: DispatchWorkItem? { get set }
    var recallEpoch: UInt64 { get set }
    var recallCompositionRevision: UInt64 { get set }
    #if DEBUG
        var isHighFidelityDiagnosticsActive: Bool { get }
    #endif
    var diagnosticsAppearanceID: UUID? { get }

    func recordTypoRecallQueryMeasured(_ payload: DiagnosticEvent.TypoRecallQueryPayload)
    func recordTypoRecallMarker(
        code: DiagnosticEvent.Code,
        recallEpoch: UInt64,
        compositionRevision: UInt64,
        operationOrdinal: UInt64,
        normalizedComposition: String
    )
    func refreshCandidateBar()
    #if DEBUG && KEYBOARD_QUERY_COST_PROBE
        var queryCostDebugFullAccess: Bool { get }
        func queryCostDebugFacadeScope() -> QueryCostMemoryProbe.FacadeScope?
    #endif
}

#if DEBUG && KEYBOARD_QUERY_COST_PROBE
    extension TypoCorrectionRecallCoordinatorHost {
        var queryCostDebugFullAccess: Bool { false }
        func queryCostDebugFacadeScope() -> QueryCostMemoryProbe.FacadeScope? { nil }
    }
#endif

/// MainActor owner of one contextual-recall operation: debounce, epoch,
/// yielded one-query turns, fences and the final candidate-bar refresh.
@MainActor
final class TypoCorrectionRecallCoordinator: TypoCorrectionRecallInvalidating {
    #if DEBUG
        /// Keeps tests on the production coordinator while controlling only its
        /// yielded turns and observations; nil hooks preserve runtime behavior.
        struct TestingHooks {
            var beforeQueryFenceCheck: (@MainActor () -> Void)?
            var recordQueryMeasured: (@MainActor (DiagnosticEvent.TypoRecallQueryPayload) -> Void)?
            var recordMarker: (@MainActor (DiagnosticEvent.Code) -> Void)?
            var scheduleYieldedTurn: (@MainActor (@escaping @MainActor () -> Void) -> Void)?
            var refreshCandidateBar: (@MainActor () -> Void)?
        }

        private var testingHooks: TestingHooks?

        var testingHooksAreInstalled: Bool {
            testingHooks != nil
        }

        func installTestingHooks(_ hooks: TestingHooks) {
            testingHooks = hooks
        }

        func startOperationForTesting(expectedComposition: String) {
            startOperation(expectedComposition: expectedComposition)
        }
    #endif

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

    private unowned let host: any TypoCorrectionRecallCoordinatorHost
    private var debounceWorkItem: DispatchWorkItem?
    private var driver: TypoCorrectionRecallDriver?
    private var operationOrdinal: UInt64 = 0
    #if DEBUG && KEYBOARD_QUERY_COST_PROBE
        private static var nextProbeCoordinatorOrdinal: UInt64 = 0
        private(set) var probeCoordinatorOrdinal: UInt64 = 0
        let callbackLedger = TypoCorrectionCallbackLedger()
        private var probeTerminalOverride: QueryCostMemoryProbe.Terminal?
        // Runtime ownership cannot be replaced from a UI action or ordinary caller.
        private(set) var queryCostProbe = QueryCostMemoryProbe.shared
        #if KEYBOARD_QUERY_COST_PROBE_TESTING
            // This source is separately compiled into the hostless test target.
            // The flag is target-local; the real Extension never contains this seam.
            @discardableResult
            func installSyntheticQueryCostProbeForTesting(_ probe: QueryCostMemoryProbe) -> Bool {
                guard probe.isSyntheticForTesting, queryCostCallbacksQuiescent else { return false }
                queryCostProbe = probe
                return true
            }
        #endif
        var queryCostCallbacksQuiescent: Bool {
            driver == nil
                && callbackLedger.quiescent(
                    aliases: [debounceWorkItem, host.contextualTypoCorrectionWorkItem])
        }
    #endif

    init(host: any TypoCorrectionRecallCoordinatorHost) {
        self.host = host
        #if DEBUG && KEYBOARD_QUERY_COST_PROBE
            if Self.nextProbeCoordinatorOrdinal != .max {
                Self.nextProbeCoordinatorOrdinal += 1
                probeCoordinatorOrdinal = Self.nextProbeCoordinatorOrdinal
            }
        #endif
    }

    func invalidateTypoCorrectionRecall() {
        let hadPendingDebounce = debounceWorkItem != nil || host.contextualTypoCorrectionWorkItem != nil
        host.recallEpoch &+= 1
        host.recallCompositionRevision &+= 1
        debounceWorkItem?.cancel()
        #if DEBUG && KEYBOARD_QUERY_COST_PROBE
            callbackLedger.cancelObserved(debounceWorkItem)
        #endif
        debounceWorkItem = nil
        #if DEBUG && KEYBOARD_QUERY_COST_PROBE
            probeTerminalOverride = .cancelled
        #endif
        finishRecallOperation()
        host.contextualTypoCorrectionWorkItem?.cancel()
        #if DEBUG && KEYBOARD_QUERY_COST_PROBE
            callbackLedger.cancelObserved(host.contextualTypoCorrectionWorkItem)
        #endif
        host.contextualTypoCorrectionWorkItem = nil
        recordTypoRecallMarker(
            code: .typoRecallEpochBumped,
            normalizedComposition: host.controller.state.currentComposition
        )
        if hadPendingDebounce {
            recordTypoRecallMarker(
                code: .typoRecallDebounceCancelled,
                normalizedComposition: host.controller.state.currentComposition
            )
        }
    }

    func scheduleAfterCompositionSettled() {
        let hadPendingDebounce = debounceWorkItem != nil || host.contextualTypoCorrectionWorkItem != nil
        debounceWorkItem?.cancel()
        #if DEBUG && KEYBOARD_QUERY_COST_PROBE
            callbackLedger.cancelObserved(debounceWorkItem)
        #endif
        host.contextualTypoCorrectionWorkItem?.cancel()
        #if DEBUG && KEYBOARD_QUERY_COST_PROBE
            callbackLedger.cancelObserved(host.contextualTypoCorrectionWorkItem)
        #endif

        let expectedComposition = host.controller.state.currentComposition
        if hadPendingDebounce {
            recordTypoRecallMarker(
                code: .typoRecallDebounceCancelled,
                normalizedComposition: expectedComposition
            )
        }

        guard isEligible(for: expectedComposition) else { return }

        #if DEBUG && KEYBOARD_QUERY_COST_PROBE
            let callbackToken = callbackLedger.schedule()
        #endif
        let workItem = DispatchWorkItem { [weak self] in
            #if DEBUG && KEYBOARD_QUERY_COST_PROBE
                self?.callbackLedger.enter(callbackToken)
                defer { self?.callbackLedger.complete(callbackToken) }
            #endif
            self?.startOperation(expectedComposition: expectedComposition)
        }
        #if DEBUG && KEYBOARD_QUERY_COST_PROBE
            callbackLedger.bind(workItem, to: callbackToken)
        #endif
        debounceWorkItem = workItem
        host.contextualTypoCorrectionWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.18, execute: workItem)
        recordTypoRecallMarker(
            code: .typoRecallDebounceScheduled,
            normalizedComposition: expectedComposition
        )
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
        #if DEBUG && KEYBOARD_QUERY_COST_PROBE
            queryCostProbe.beginOperation(token.operationOrdinal)
        #endif
        owner.beginTypoCorrectionRecall()
        continueOperation()
    }

    private func continueOperation() {
        guard var currentDriver = driver else { return }
        let live = liveFence(matching: currentDriver.token)
        switch currentDriver.nextEvent(currentFence: live) {
        case .discarded:
            recordFenceDiscarded(token: currentDriver.token)
            finishRecallOperation()
        case .waitForYield:
            driver = currentDriver
            scheduleYieldedTurn(for: YieldedTurnToken(currentDriver.token))
        case .query(let query):
            driver = currentDriver
            performQuery(query)
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
            recordFenceDiscarded(token: currentDriver.token)
            finishRecallOperation()
        case .waitForYield:
            driver = currentDriver
            scheduleYieldedTurn(for: YieldedTurnToken(currentDriver.token))
        case .query(let query):
            driver = currentDriver
            performQuery(query)
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

    private func performQuery(_ query: TypoCorrectionRecallQuery) {
        guard var currentDriver = driver else { return }
        #if DEBUG
            testingHooks?.beforeQueryFenceCheck?()
        #endif
        let pre = liveFence(matching: currentDriver.token)
        guard pre == currentDriver.token else {
            recordFenceDiscarded(token: currentDriver.token)
            finishRecallOperation()
            return
        }

        let owner = host.controller.typoCorrectionCandidateQuery
        #if DEBUG && KEYBOARD_QUERY_COST_PROBE
            if queryCostProbe.status == .armed {
                queryCostProbe.verifyScope(
                    facade: host.queryCostDebugFacadeScope(),
                    fullAccess: host.queryCostDebugFullAccess, coordinatorOrdinal: probeCoordinatorOrdinal)
            }
            let reservation = queryCostProbe.beginInvocation(
                operation: currentDriver.token.operationOrdinal, stage: query.stage,
                epoch: currentDriver.token.recallEpoch, revision: currentDriver.token.compositionRevision)
        #endif
        let startTick = DispatchTime.now().uptimeNanoseconds
        let result = owner.correctionQueryResult(
            for: query.suggestion.correctedInput,
            limit: TypoCorrectionRecallRuntimeBudget.candidateLimit
        )
        let endTick = DispatchTime.now().uptimeNanoseconds
        let duration = TypoCorrectionFacadeDuration(startTick: startTick, endTick: endTick)
        let post = liveFence(matching: currentDriver.token)
        let event = currentDriver.finishQuery(currentFence: post, candidates: result.candidates)
        driver = currentDriver

        let bucket = DiagnosticEvent.TypoRecallCandidateBucket.classify(
            candidates: result.candidates,
            resultState: result.state
        )
        let disposition: DiagnosticEvent.TypoRecallQueryDisposition
        if case .discarded = event {
            disposition = .discardedAfterFacade
        } else {
            disposition = .applied
        }
        let payload = DiagnosticEvent.TypoRecallQueryPayload(
            operationOrdinal: currentDriver.token.operationOrdinal,
            stage: query.stage,
            readiness: result.readiness,
            resultState: result.state,
            returnedCandidateBucket: bucket,
            disposition: disposition,
            facadeElapsedMicroseconds: duration.microseconds,
            durationState: duration.state
        )
        #if DEBUG && KEYBOARD_QUERY_COST_PROBE
            queryCostProbe.finishInvocation(reservation, payload: payload)
            if queryCostProbe.status == .armed {
                queryCostProbe.verifyScope(
                    facade: host.queryCostDebugFacadeScope(),
                    fullAccess: host.queryCostDebugFullAccess, coordinatorOrdinal: probeCoordinatorOrdinal)
            }
        #endif
        recordQueryMeasured(payload)

        if case .discarded = event {
            finishRecallOperation()
            return
        }
        scheduleYieldedTurn(for: YieldedTurnToken(currentDriver.token))
    }

    private func scheduleYieldedTurn(for expectedToken: YieldedTurnToken) {
        #if DEBUG
            if let scheduleYieldedTurn = testingHooks?.scheduleYieldedTurn {
                #if DEBUG && KEYBOARD_QUERY_COST_PROBE
                    let callbackToken = callbackLedger.schedule()
                #endif
                scheduleYieldedTurn { [weak self] in
                    #if DEBUG && KEYBOARD_QUERY_COST_PROBE
                        self?.callbackLedger.enter(callbackToken)
                        defer { self?.callbackLedger.complete(callbackToken) }
                    #endif
                    self?.performYieldedTurn(for: expectedToken)
                }
                return
            }
        #endif
        #if DEBUG && KEYBOARD_QUERY_COST_PROBE
            let callbackToken = callbackLedger.schedule(.runLoopPending)
        #endif
        RunLoop.main.perform(inModes: [.default]) { [weak self] in
            #if DEBUG && KEYBOARD_QUERY_COST_PROBE
                callbackToken?.observeRunLoopHandoff()
            #endif
            Task { @MainActor [weak self] in
                #if DEBUG && KEYBOARD_QUERY_COST_PROBE
                    self?.callbackLedger.handoff(callbackToken)
                    self?.callbackLedger.enter(callbackToken)
                    defer { self?.callbackLedger.complete(callbackToken) }
                #endif
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
            recordFenceDiscarded(token: currentDriver.token)
            finishRecallOperation()
            return
        }
        driver = currentDriver
        continueOperation()
    }

    private func apply(_ material: TypoCorrectionRecallMaterial) {
        let live = liveFence(matching: material.token)
        guard live == material.token else {
            recordFenceDiscarded(token: material.token)
            finishRecallOperation()
            return
        }
        let didApply = host.controller.applyTypoCorrectionRecallMaterial(material)
        let refreshFence = liveFence(matching: material.token)
        finishRecallOperation()
        guard didApply, refreshFence == material.token else { return }
        #if DEBUG
            if let refreshCandidateBar = testingHooks?.refreshCandidateBar {
                refreshCandidateBar()
                return
            }
        #endif
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
        #if DEBUG && KEYBOARD_QUERY_COST_PROBE
            // A reentrant invalidation may finish this driver during its synchronous facade call.
            // Its later post-fence cleanup is the same terminal, not a second operation.
            // The probe retains terminal identity in its bounded wire records,
            // including nonadjacent A/B/A reentry; no coordinator-local last-ID heuristic.
            if let token = driver?.token {
                let terminal: QueryCostMemoryProbe.Terminal =
                    probeTerminalOverride ?? (liveFence(matching: token) == token ? .completed : .fenced)
                queryCostProbe.endOperation(token.operationOrdinal, terminal: terminal)
            }
            probeTerminalOverride = nil
        #endif
        driver = nil
        sidecarOwner?.endTypoCorrectionRecall()
    }

    // MARK: - INT-003 journal markers (HF-gated; observe-only)

    private func recordFenceDiscarded(token: TypoCorrectionRecallFenceSnapshot) {
        recordTypoRecallMarker(code: .typoRecallFenceDiscarded, token: token)
    }

    private func recordQueryMeasured(
        _ payload: DiagnosticEvent.TypoRecallQueryPayload
    ) {
        #if DEBUG
            guard host.isHighFidelityDiagnosticsActive else { return }
            if let recordQueryMeasured = testingHooks?.recordQueryMeasured {
                recordQueryMeasured(payload)
                return
            }
            host.recordTypoRecallQueryMeasured(payload)
        #endif
    }

    private func recordTypoRecallMarker(
        code: DiagnosticEvent.Code,
        token: TypoCorrectionRecallFenceSnapshot
    ) {
        recordTypoRecallMarker(
            code: code,
            recallEpoch: token.recallEpoch,
            compositionRevision: token.compositionRevision,
            operationOrdinal: token.operationOrdinal,
            normalizedComposition: token.normalizedComposition
        )
    }

    private func recordTypoRecallMarker(
        code: DiagnosticEvent.Code,
        normalizedComposition: String
    ) {
        let normalized = host.controller.normalizedTypoCorrectionInput(normalizedComposition)
        recordTypoRecallMarker(
            code: code,
            recallEpoch: host.recallEpoch,
            compositionRevision: host.recallCompositionRevision,
            operationOrdinal: operationOrdinal,
            normalizedComposition: normalized
        )
    }

    private func recordTypoRecallMarker(
        code: DiagnosticEvent.Code,
        recallEpoch: UInt64,
        compositionRevision: UInt64,
        operationOrdinal: UInt64,
        normalizedComposition: String
    ) {
        #if DEBUG
            guard host.isHighFidelityDiagnosticsActive else { return }
            if let recordMarker = testingHooks?.recordMarker {
                recordMarker(code)
                return
            }
            host.recordTypoRecallMarker(
                code: code,
                recallEpoch: recallEpoch,
                compositionRevision: compositionRevision,
                operationOrdinal: operationOrdinal,
                normalizedComposition: normalizedComposition
            )
        #endif
    }
}
