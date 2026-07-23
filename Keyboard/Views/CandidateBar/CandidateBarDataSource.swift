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
///   路径 2（上屏后联想）：
///     条件：中文 letters 页面、没有活跃 composition 且短上下文有匹配建议
///     行为：显示独立的 continuationCandidate，不参与 RIME 分页。
///
///   路径 3（回退路径 — RIME 不可用时）：
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
        guard state.inputMode == .chinese else { return [] }

        if let rimeOutput = state.lastRimeOutput,
           let comp = rimeOutput.composition,
           !comp.preeditText.isEmpty
        {
            return candidateItems(
                from: controller,
                rimeCandidates: rimeOutput.candidates,
                preeditText: comp.preeditText,
                pageNumber: rimeOutput.candidatePageNumber
            )
        }

        return nonCompositionCandidateItems(from: controller)
    }

    /// Build candidate items from an already-captured RIME candidate page.
    /// Used by T9 atomic presentation so Path Bar and candidate bar share one snapshot.
    static func candidateItems(
        from controller: KeyboardController,
        rimeCandidates: [RimeCandidate],
        preeditText: String,
        pageNumber: Int
    ) -> [CandidateItem] {
        let state = controller.state
        guard state.inputMode == .chinese else { return [] }
        guard !preeditText.isEmpty else {
            return nonCompositionCandidateItems(from: controller)
        }

        var items: [CandidateItem] = []
        for (index, candidate) in rimeCandidates.enumerated() {
            items.append(
                CandidateItem.rimeCandidate(
                    candidate,
                    page: pageNumber,
                    indexOnPage: index,
                    globalIndex: candidate.globalIndex ?? (pageNumber == 0 ? index : nil)
                )
            )
        }

        if items.isEmpty {
            let correctionItems = correctionItems(from: state, excluding: [])
            if !correctionItems.isEmpty {
                return correctionItems + [CandidateItem(title: preeditText, kind: .composition)]
            }
            return [CandidateItem(title: preeditText, kind: .composition)]
        }

        return TypoCorrectionCandidateRanker.mergedCandidates(
            normalItems: items,
            correctionItems: correctionItems(from: state, excluding: []),
            learningSnapshot: controller.typoCorrectionLearningSnapshot
        )
    }

    private static func nonCompositionCandidateItems(
        from controller: KeyboardController
    ) -> [CandidateItem] {
        let state = controller.state
        guard state.inputMode == .chinese else { return [] }

        // 上屏后联想不是 RIME composition。只有当前没有活跃拼音时，
        // 才把独立的短上下文建议映射到候选栏。
        if state.currentPage == .letters,
           state.currentComposition.isEmpty,
           controller.isPostCommitContinuationEnabled,
           !state.continuation.suggestions.isEmpty
        {
            return state.continuation.suggestions.map {
                CandidateItem(title: $0, kind: .continuationCandidate)
            }
        }

        // ── 路径 3：回退（FakeCandidateProvider）──────────────
        // currentComposition 存储了用户当前输入的拼音字符串
        guard !state.currentComposition.isEmpty else { return [] }

        let candidates = controller.candidateProvider.candidates(
            for: state.currentComposition
        )

        if candidates.isEmpty {
            // 无匹配候选词时，展示拼音原始字符串（可提交）
            let correctionItems = correctionItems(from: state, excluding: [])
            if !correctionItems.isEmpty {
                return correctionItems + [CandidateItem(title: state.currentComposition, kind: .composition)]
            }
            return [CandidateItem(title: state.currentComposition, kind: .composition)]
        } else {
            // 将匹配的候选词包装为 CandidateItem
            let items = candidates.map { CandidateItem(title: $0, kind: .candidate) }
            return TypoCorrectionCandidateRanker.mergedCandidates(
                normalItems: items,
                correctionItems: correctionItems(from: state, excluding: []),
                learningSnapshot: controller.typoCorrectionLearningSnapshot
            )
        }
    }

    private static func correctionItems(from state: KeyboardState, excluding titles: [String]) -> [CandidateItem] {
        guard let typoCorrection = state.typoCorrection else { return [] }
        var seen = Set(titles)
        var items: [CandidateItem] = []

        for suggestion in typoCorrection.suggestions {
            for candidate in suggestion.candidates where seen.insert(candidate.text).inserted {
                let commit = TypoCorrectionCommit(
                    committedText: candidate.text,
                    originalInput: suggestion.originalInput,
                    correctedInput: suggestion.correctedInput,
                    edits: suggestion.edits
                )
                items.append(
                    CandidateItem(
                        title: candidate.text,
                        kind: .correctionCandidate,
                        correction: commit
                    )
                )
            }
        }

        return items
    }
}
