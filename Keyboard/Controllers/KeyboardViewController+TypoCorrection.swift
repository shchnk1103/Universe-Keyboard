import KeyboardCore
import UIKit

extension KeyboardViewController {
    /// 多错误检索的价值出现在用户完成一段连续拼音后，而不是每一个按键之后。
    /// 因此保留短暂防抖窗口：输入中的主路径只刷新普通 RIME 候选，停顿后再补充旁路候选。
    func scheduleContextualTypoCorrectionRefresh() {
        contextualTypoCorrectionWorkItem?.cancel()

        let expectedComposition = controller.state.currentComposition
        guard controller.state.currentPage == .letters,
            controller.state.inputMode == .chinese,
            expectedComposition.filter({ !$0.isWhitespace }).count >= 8
        else { return }

        let workItem = DispatchWorkItem { [weak self] in
            guard let self else { return }
            guard self.controller.refreshContextualTypoCorrectionSuggestions(
                for: expectedComposition
            ) else { return }

            // 该刷新只会发生在 composition 未变化时，因此无需重建键盘或更新其他控件。
            self.refreshCandidateBar()
        }
        contextualTypoCorrectionWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.18, execute: workItem)
    }
}
