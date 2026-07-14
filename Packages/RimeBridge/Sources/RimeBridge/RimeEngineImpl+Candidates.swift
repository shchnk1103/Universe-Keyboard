import Foundation
import KeyboardCore
import QuartzCore

extension RimeEngineImpl {
    func chooseCandidate(at index: Int) -> KeyboardCore.RimeOutput {
        let output = parseOutput(bridge.selectCandidate(at: Int32(index)))
#if DEBUG
        Logger.shared.debug(
            "selectCandidate(\(index)) commitLength=\(output.committedText?.count ?? 0)",
            category: .engine
        )
#endif
        return output
    }

    func chooseCandidate(globalIndex index: Int) -> KeyboardCore.RimeOutput {
        let output = parseOutput(bridge.selectCandidate(atGlobalIndex: Int32(index)))
#if DEBUG
        Logger.shared.debug(
            "selectCandidate(global=\(index)) commitLength=\(output.committedText?.count ?? 0)",
            category: .engine
        )
#endif
        return output
    }

    func readCandidateWindow(from globalIndex: Int, limit: Int) -> KeyboardCore.RimeCandidateWindow {
#if DEBUG
        let start = CACurrentMediaTime()
#endif
        let safeLimit = max(0, limit)
        let window = Self.parseCandidateWindowDictionary(
            bridge.candidates(from: Int32(max(0, globalIndex)), limit: Int32(safeLimit))
        )
#if DEBUG
        Logger.shared.debug(
            "candidateWindow start=\(window.startIndex) limit=\(safeLimit) count=\(window.candidates.count) "
                + "hasMore=\(window.hasMoreCandidates) durationMs=\(String(format: "%.1f", (CACurrentMediaTime() - start) * 1000))",
            category: .engine
        )
#endif
        return window
    }

    /// 发送分页键码，同时保持原有的分页耗时诊断格式。
    func pageCandidates(keycode: Int32, diagnosticName: String) -> KeyboardCore.RimeOutput {
#if DEBUG
        let startTime = CACurrentMediaTime()
        Logger.shared.debug("RIME \(diagnosticName) BEGIN", category: .engine)
#endif
        let output = parseOutput(bridge.processKey(keycode, modifiers: 0))
#if DEBUG
        Logger.shared.debug(
            "RIME \(diagnosticName) END durationMs=\(String(format: "%.1f", (CACurrentMediaTime() - startTime) * 1000))",
            category: .engine
        )
#endif
        return output
    }
}
