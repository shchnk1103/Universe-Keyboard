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

    func chooseCandidate(globalIndex index: Int) -> KeyboardCore.RimeOutput {
        let output = parseOutput(bridge.selectCandidate(atGlobalIndex: Int32(index)))
        Logger.shared.debug(
            "selectCandidate(global=\(index)) commitLength=\(output.committedText?.count ?? 0)",
            category: .engine
        )
        return output
    }

    func readCandidateWindow(from globalIndex: Int, limit: Int) -> KeyboardCore.RimeCandidateWindow {
        let start = CACurrentMediaTime()
        let safeLimit = max(0, limit)
        let window = Self.parseCandidateWindowDictionary(
            bridge.candidates(from: Int32(max(0, globalIndex)), limit: Int32(safeLimit))
        )
        Logger.shared.debug(
            "candidateWindow start=\(window.startIndex) limit=\(safeLimit) count=\(window.candidates.count) "
                + "hasMore=\(window.hasMoreCandidates) durationMs=\(String(format: "%.1f", (CACurrentMediaTime() - start) * 1000))",
            category: .engine
        )
        return window
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
