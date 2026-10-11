import KeyboardCore
import RimeBridge
import UIKit

extension KeyboardViewController: TypoCorrectionRecallCoordinatorHost {
    /// 多错误检索的价值出现在用户完成一段连续拼音后，而不是每一个按键之后。
    /// 因此保留短暂防抖窗口：输入中的主路径只刷新普通 RIME 候选，停顿后再补充旁路候选。
    func scheduleContextualTypoCorrectionRefresh() {
        typoCorrectionRecallCoordinator.scheduleAfterCompositionSettled()
    }

    func installTypoCorrectionSidecarOwner(_ query: TypoCorrectionCandidateQuerying) {
        // Rebinding the facade changes the route-local owner used by an active recall.
        // Fence it before replacing the query object so stale work cannot publish.
        #if DEBUG && KEYBOARD_QUERY_COST_PROBE
            typoCorrectionRecallCoordinator.queryCostProbe.invalidate(.scopeChange)
        #endif
        typoCorrectionRecallCoordinator.invalidateTypoCorrectionRecall()
        let owner = TypoCorrectionSidecarOwnerAdapters.wrapping(
            query,
            route: typoCorrectionSidecarRoute,
            routeLocalOwnerEpochProvider: { [weak self] in
                self?.typoCorrectionRouteLocalOwnerEpoch()
            }
        )
        owner.recallInvalidation = typoCorrectionRecallCoordinator
        controller.typoCorrectionCandidateQuery = owner
    }

    private var typoCorrectionSidecarRoute: TypoCorrectionSidecarRoute {
        // The controller flags define the live route. Keeping this mapping here
        // prevents a bootstrap call site from declaring a route that disagrees
        // with the owner that will actually service the recall.
        if controller.isThreadAffineRimeOwnerEnabled {
            return .threadAffine
        }
        if controller.isResponsiveRimePipelineEnabled {
            return .mainActorResponsive
        }
        return .defaultMainActor
    }

    func typoCorrectionRouteLocalOwnerEpoch() -> UInt64? {
        if let epoch = controller.threadAffineRimeCoordinator?.diagnostics.sessionEpoch {
            return epoch
        }
        if let epoch = controller.responsiveRimeCoordinator?.diagnostics.sessionEpoch {
            return epoch
        }
        return nil
    }

    func recordTypoRecallQueryMeasured(_ payload: DiagnosticEvent.TypoRecallQueryPayload) {
        #if DEBUG
            diagnosticsJournal.record(
                code: .typoRecallQueryMeasured,
                category: .performance,
                appearanceID: diagnosticsAppearanceID,
                fields: [.typoRecallQuery(payload)]
            )
        #endif
    }

    func recordTypoRecallMarker(
        code: DiagnosticEvent.Code,
        recallEpoch: UInt64,
        compositionRevision: UInt64,
        operationOrdinal: UInt64,
        normalizedComposition: String
    ) {
        #if DEBUG
            diagnosticsJournal.record(
                code: code,
                category: .performance,
                appearanceID: diagnosticsAppearanceID,
                fields: TypoCorrectionRecallDiagnosticMarkers.fenceFields(
                    recallEpoch: recallEpoch,
                    compositionRevision: compositionRevision,
                    operationOrdinal: operationOrdinal,
                    normalizedComposition: normalizedComposition
                )
            )
        #endif
    }
}

#if DEBUG && KEYBOARD_QUERY_COST_PROBE
    extension KeyboardViewController {
        var queryCostDebugFullAccess: Bool { hasFullAccess }
        func queryCostDebugFacadeScope() -> QueryCostMemoryProbe.FacadeScope? {
            guard let controller,
                let owner = controller.typoCorrectionCandidateQuery as? InstalledTypoCorrectionSidecarOwner
            else { return nil }
            let ordinal = owner.queryCostFacadeOrdinal
            switch owner.route {
            case .defaultMainActor:
                guard !controller.isThreadAffineRimeOwnerEnabled, !controller.isResponsiveRimePipelineEnabled,
                    let session = owner.existingCorrectionQueryDebugScope()
                else { return .unavailable(kind: .nativeCorrectionSession, facadeOrdinal: ordinal) }
                return .init(
                    kind: .nativeCorrectionSession, facadeOrdinal: ordinal,
                    lifetimeOrdinal: session.sessionOrdinal, schema: session.schema)
            case .mainActorResponsive:
                return .unavailable(kind: .unsupportedResponsive, facadeOrdinal: ordinal)
            case .threadAffine:
                guard controller.isThreadAffineRimeOwnerEnabled, controller.isResponsiveRimePipelineEnabled,
                    controller.rimeEngine is ThreadAffineRimeEngineBridge,
                    owner.queryCostUsesCandidateProvider,
                    let coordinator = controller.threadAffineRimeCoordinator
                else {
                    return .unavailable(kind: .threadAffineProvider, facadeOrdinal: ordinal)
                }
                // Published value snapshots only; never call through to the owner-thread engine.
                let before = coordinator.diagnostics
                let schema: TypoCorrectionQueryDebugScope.Schema =
                    before.runtimeSelection?.effectiveSchemaID == "luna_pinyin" ? .lunaPinyin : .unknown
                let ready = coordinator.isOwnerReady
                let after = coordinator.diagnostics
                let unchanged =
                    before.runtimeSelection == after.runtimeSelection
                    && before.diagnosticSessionSnapshot == after.diagnosticSessionSnapshot
                return QueryCostMemoryProbe.FacadeScope.threadAffineProvider(
                    facadeOrdinal: ordinal, epochBefore: before.sessionEpoch, epochAfter: after.sessionEpoch,
                    ownerReady: ready && coordinator.isOwnerReady,
                    nativeSessionValid: unchanged && before.diagnosticSessionSnapshot?.isValid == true,
                    schema: schema) ?? .unavailable(kind: .threadAffineProvider, facadeOrdinal: ordinal)
            }
        }
    }
#endif
