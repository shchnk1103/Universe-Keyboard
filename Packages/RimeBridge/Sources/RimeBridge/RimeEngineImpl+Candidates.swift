import Foundation
import KeyboardCore
import QuartzCore

extension RimeEngineImpl {
    func chooseCandidate(at index: Int) -> KeyboardCore.RimeOutput {
        let output = parseOutput(bridge.selectCandidate(at: Int32(index)))
        Logger.shared.debug(
            "selectCandidate(\(index)) commitLength=\(output.committedText?.count ?? 0)",
            category: .engine
        )
        return output
    }

    /// 发送分页键码，同时保持原有的分页耗时诊断格式。
    func pageCandidates(keycode: Int32, diagnosticName: String) -> KeyboardCore.RimeOutput {
        let startTime = CACurrentMediaTime()
        Logger.shared.debug("RIME \(diagnosticName) BEGIN", category: .engine)
        let output = parseOutput(bridge.processKey(keycode, modifiers: 0))
        Logger.shared.debug(
            "RIME \(diagnosticName) END durationMs=\(String(format: "%.1f", (CACurrentMediaTime() - startTime) * 1000))",
            category: .engine
        )
        return output
    }
}
