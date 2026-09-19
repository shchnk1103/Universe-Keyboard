import KeyboardCore
import UIKit

extension KeyboardViewController {
    /// 多错误检索的价值出现在用户完成一段连续拼音后，而不是每一个按键之后。
    /// 因此保留短暂防抖窗口：输入中的主路径只刷新普通 RIME 候选，停顿后再补充旁路候选。
    func scheduleContextualTypoCorrectionRefresh() {
        contextualTypoCorrectionWorkItem?.cancel()

        guard cachedContextualTypoCorrectionEnabled else { return }

        let expectedComposition = controller.state.currentComposition
        guard controller.state.currentPage == .letters,
            controller.state.inputMode == .chinese,
            expectedComposition.filter({ !$0.isWhitespace }).count >= 8
        else { return }

        let workItem = DispatchWorkItem { [weak self] in
            guard let self else { return }
            guard
                self.controller.refreshContextualTypoCorrectionSuggestions(
                    for: expectedComposition
                )
            else { return }

            // 该刷新只会发生在 composition 未变化时，因此无需重建键盘或更新其他控件。
            self.refreshCandidateBar()
        }
        contextualTypoCorrectionWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.18, execute: workItem)
    }

    #if DEBUG
        /// Converts the real sidecar observation into the typed, content-free
        /// journal. Invalid or unbound observations stay visible in Logger but
        /// are deliberately not promoted to evidence.
        func recordTypoCorrectionQueryDiagnostic(
            _ diagnostic: TypoCorrectionQueryDiagnostic
        ) {
            guard
                let event = DiagnosticEvent.TypoCorrectionSidecarQueryEvent(
                    diagnostic: diagnostic
                )
            else {
                Logger.shared.warning(
                    "TYPO-CORRECTION sidecar observation rejected by evidence bounds",
                    category: .engine
                )
                return
            }

            Logger.shared.info(
                "TYPO-CORRECTION sidecar observed route=\(diagnostic.route.rawValue) "
                    + "seq=\(diagnostic.sequence) schema=\(diagnostic.schemaID ?? "unknown") "
                    + "receipt=\(diagnostic.provenanceReceiptID?.uuidString ?? "unknown") "
                    + "results=\(diagnostic.resultCount) outcome=\(diagnostic.outcome.rawValue)",
                category: .engine
            )
            guard isHighFidelityDiagnosticsActive else { return }
            diagnosticsJournal.recordTypoCorrection(.sidecarQuery(event))
        }

        /// Records which query implementation was installed for this visible
        /// keyboard lifecycle. A real route is accepted only with a receipt ID.
        func recordTypoCorrectionQueryRoute(
            _ route: TypoCorrectionQueryRoute,
            schemaID: String?,
            provenanceReceiptID: UUID?
        ) {
            let event = DiagnosticEvent.TypoCorrectionQueryRouteEvent(
                route: route,
                schemaID: schemaID,
                provenanceReceiptID: provenanceReceiptID
            )
            guard event.isValidForRecording else {
                Logger.shared.warning(
                    "TYPO-CORRECTION query route rejected by evidence bounds",
                    category: .engine
                )
                return
            }
            Logger.shared.info(
                "TYPO-CORRECTION query route=\(route.rawValue) "
                    + "schema=\(schemaID ?? "unknown") "
                    + "receipt=\(provenanceReceiptID?.uuidString ?? "unknown")",
                category: .engine
            )
            guard isHighFidelityDiagnosticsActive else { return }
            diagnosticsJournal.recordTypoCorrection(.queryRoute(event))
        }
    #endif
}
