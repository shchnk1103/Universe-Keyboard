import Foundation
import KeyboardCore

/// 候选栏数据源 — 从 KeyboardController 获取当前应显示的候选词列表。
///
/// 数据来源优先级（双路径设计）：
///
///   路径 1（RIME 引擎路径 — 优先级最高）：
///     条件：state.lastRimeOutput 存在 && composition.preeditText 非空
///     行为：从 rimeOutput.candidates 提取候选词列表。
///          拼音已通过 inline preedit 显示在宿主 App 输入框中，
///          候选栏只显示候选词（不含拼音组合文本）。
///
///   路径 2（回退路径 — RIME 不可用时）：
///     条件：RIME 无输出 或 composition 为空
///     行为：使用 KeyboardController.candidateProvider（FakeCandidateProvider）
///           根据 state.currentComposition 查表获取候选词。
///
/// 特殊情况处理：
///   - 输入模式为英文时：不显示任何候选词（返回空数组）
///   - RIME 有 composition 但无候选词时：将拼音组合文本作为 composition 类型
///     的候选项展示，让用户可以提交原始拼音（如输入英文名）
struct CandidateBarDataSource {

    /// 获取当前应显示的候选词列表。
    /// - Parameter controller: 键盘状态控制器
    /// - Returns: CandidateItem 数组（可能为空）
    static func candidateItems(from controller: KeyboardController) -> [CandidateItem] {
        let state = controller.state

        // 英文模式下不需要候选词
        guard state.inputMode == .chinese else { return [] }

        // ── 路径 1：RIME 引擎 ──────────────────────────────────
        // RIME 输出中有 composition 表示用户正在输入拼音
        // preeditText 已通过 inline preedit 显示在宿主 App 中
        // 候选栏只需显示候选词
        if let rimeOutput = state.lastRimeOutput,
           let comp = rimeOutput.composition,
           !comp.preeditText.isEmpty {

            var items: [CandidateItem] = []
            // 将 RIME 返回的每个候选文本包装为 CandidateItem
            for candidate in rimeOutput.candidates {
                items.append(CandidateItem(title: candidate.text, kind: .candidate))
            }

            // 如果 RIME 返回了 composition 但无候选词，
            // 将拼音原始文本作为 composition 类型展示
            // 这样用户可以点击来提交原始拼音（而非中文候选）
            if items.isEmpty {
                items.append(CandidateItem(title: comp.preeditText, kind: .composition))
            }

            return items
        }

        // ── 路径 2：回退（FakeCandidateProvider）──────────────
        // currentComposition 存储了用户当前输入的拼音字符串
        guard !state.currentComposition.isEmpty else { return [] }

        let candidates = controller.candidateProvider.candidates(
            for: state.currentComposition
        )

        if candidates.isEmpty {
            // 无匹配候选词时，展示拼音原始字符串（可提交）
            return [CandidateItem(title: state.currentComposition, kind: .composition)]
        } else {
            // 将匹配的候选词包装为 CandidateItem
            return candidates.map { CandidateItem(title: $0, kind: .candidate) }
        }
    }
}
