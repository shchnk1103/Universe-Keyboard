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
            return
        }
        nextRecoveryAttemptTime = 0

        let schema =
            UserDefaults(
                suiteName: "group.com.DoubleShy0N.Universe-Keyboard"
            )?.string(forKey: "rime_active_schema") ?? "luna_pinyin"
        let actual = selectAndVerifySchema(schema, fallback: "luna_pinyin")
        Logger.shared.info(
            "RIME session recreated after keyboard return; requested=\(schema), actual=\(actual ?? "nil")",
            category: .engine
        )
    }
}
