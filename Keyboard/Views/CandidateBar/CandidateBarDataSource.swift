import Foundation
import KeyboardCore

/// 候选栏数据源，从 KeyboardController 的 RIME 输出或回退路径构建候选词列表。
struct CandidateBarDataSource {

    /// 优先 RIME 引擎输出（state.lastRimeOutput），无 RIME 时回退到 CandidateProvider。
    static func candidateItems(from controller: KeyboardController) -> [CandidateItem] {
        let state = controller.state

        guard state.inputMode == .chinese else { return [] }

        // RIME 路径：拼音已通过 inline preedit 显示在输入框中，只显示候选词
        if let rimeOutput = state.lastRimeOutput,
           let comp = rimeOutput.composition,
           !comp.preeditText.isEmpty {
            var items: [CandidateItem] = []
            for candidate in rimeOutput.candidates {
                items.append(CandidateItem(title: candidate.text, kind: .candidate))
            }
            if items.isEmpty {
                items.append(CandidateItem(title: comp.preeditText, kind: .composition))
            }
            return items
        }

        // 回退路径
        guard !state.currentComposition.isEmpty else { return [] }

        let candidates = controller.candidateProvider.candidates(for: state.currentComposition)
        if candidates.isEmpty {
            return [CandidateItem(title: state.currentComposition, kind: .composition)]
        } else {
            return candidates.map { CandidateItem(title: $0, kind: .candidate) }
        }
    }
}
