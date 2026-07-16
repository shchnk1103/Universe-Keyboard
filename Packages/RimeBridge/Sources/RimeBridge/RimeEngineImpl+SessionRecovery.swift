import Foundation
import KeyboardCore
import QuartzCore

extension RimeEngineImpl {
    /// 仅重建输入 session 或运行时，不在键盘进程执行配置部署或落盘修复。
    func restoreInputSession() {
        let now = CACurrentMediaTime()
        guard now >= nextRecoveryAttemptTime else { return }

        _ = bridge.destroySession()
        let sessionReady: Bool
        if bridge.createSession() {
            sessionReady = true
        } else {
            Logger.shared.warning(
                "RIME session recreation failed; restarting engine runtime",
                category: .engine
            )
            sessionReady = bridge.restartEngineAndCreateSession()
        }

        guard sessionReady else {
            nextRecoveryAttemptTime = now + 0.5
            Logger.shared.warning("RIME engine restart failed after keyboard return", category: .engine)
            // Session is unusable; fail closed so chrome cannot keep T9 against a dead runtime.
            publishFailClosedSelection(reason: "recovery-session-recreate-failed")
            return
        }
        nextRecoveryAttemptTime = 0

        let requested = resolveRuntimeSelection()
        let schema = requested.effectiveSchemaID
        let fallback = requested.baseSchemaID == "rime_ice" ? "rime_ice" : "luna_pinyin"
        let actual = selectAndVerifySchema(schema, fallback: fallback)
        // actual may be nil or a non-T9 fallback; applyRealizedSelection always publishes + notifies.
        applyRealizedSelection(requested: requested, actualSchemaID: actual)
        Logger.shared.info(
            "RIME session recreated after keyboard return; requested=\(schema) actual=\(actual ?? "nil") "
                + "realized=\(runtimeSelection?.effectiveSchemaID ?? "nil")",
            category: .engine
        )
    }
}
