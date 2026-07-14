import Foundation
import KeyboardCore
import QuartzCore

extension RimeEngineImpl {
    /// 处理输入热路径，并记录不包含输入正文的耗时诊断信息。
    func processInputKey(_ key: String) -> KeyboardCore.RimeOutput {
        let startTime = CACurrentMediaTime()
#if DEBUG
        Logger.shared.debug("RIME BEGIN keyLength=\(key.count)", category: .engine)
#endif

        let keycode = Self.keycode(for: key)

        let bridgeStartTime = CACurrentMediaTime()
#if DEBUG
        Logger.shared.debug("RIME BRIDGE BEGIN keyLength=\(key.count)", category: .engine)
#endif
        let raw = bridge.processKey(keycode, modifiers: 0)
        let bridgeElapsed = (CACurrentMediaTime() - bridgeStartTime) * 1000
        let firstKeyBridgeTiming = RimeFirstKeyBridgeTiming(rawOutput: raw)
#if DEBUG
        Logger.shared.debug(
            "RIME BRIDGE END keyLength=\(key.count) durationMs=\(String(format: "%.1f", bridgeElapsed))",
            category: .engine
        )
#endif

        let output = parseOutput(raw)

        // Release 不记录逐键成功日志，只保留超阈值告警，避免字符串格式化和日志队列进入热路径。
        if key != "BackSpace", key != "Delete" {
            let totalElapsed = (CACurrentMediaTime() - startTime) * 1000
#if DEBUG
            let firstKeyDetails = firstKeyBridgeTiming.map { ", \($0.diagnosticDescription)" } ?? ""
            Logger.shared.performance(
                "RIME processKey returned (bridge \(String(format: "%.1f", bridgeElapsed))ms, "
                    + "total \(String(format: "%.1f", totalElapsed))ms, "
                    + "candidates \(output.candidates.count)\(firstKeyDetails))"
            )
#endif
            if bridgeElapsed >= 30 || totalElapsed >= 50 {
                let firstKeyDetails = firstKeyBridgeTiming.map { " \($0.diagnosticDescription)" } ?? ""
                Logger.shared.warning(
                    "SLOW RIME keyLength=\(key.count) bridge=\(String(format: "%.1f", bridgeElapsed))ms "
                        + "total=\(String(format: "%.1f", totalElapsed))ms candidates=\(output.candidates.count)"
                        + firstKeyDetails,
                    category: .performance
                )
            }
        }

        // 诊断仅保留长度与数量，避免持久化真实输入及候选文本。
#if DEBUG
        if key != "BackSpace" && key != "Delete" {
            let preeditLength = output.composition?.preeditText.count ?? 0
            Logger.shared.debug(
                "RIME output preeditLength=\(preeditLength), candidates=\(output.candidates.count)",
                category: .engine
            )
        }
#endif

        if raw.isEmpty && !bridge.isComposing()
            && key != "BackSpace" && key != "Delete"
        {
            Logger.shared.warning(
                "processKey returned empty output for printable input",
                category: .engine
            )
        }

        return output
    }

    func processDeletion() -> KeyboardCore.RimeOutput {
        parseOutput(bridge.deleteBackward())
    }
}
