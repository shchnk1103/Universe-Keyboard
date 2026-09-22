import KeyboardCore
import RimeBridge
import UIKit

extension KeyboardViewController {
    /// 多错误检索的价值出现在用户完成一段连续拼音后，而不是每一个按键之后。
    /// 因此保留短暂防抖窗口：输入中的主路径只刷新普通 RIME 候选，停顿后再补充旁路候选。
    func scheduleContextualTypoCorrectionRefresh() {
        typoCorrectionRecallCoordinator.scheduleAfterCompositionSettled()
    }

    func installTypoCorrectionSidecarOwner(_ query: TypoCorrectionCandidateQuerying) {
        // Rebinding the facade changes the route-local owner used by an active recall.
        // Fence it before replacing the query object so stale work cannot publish.
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
}
