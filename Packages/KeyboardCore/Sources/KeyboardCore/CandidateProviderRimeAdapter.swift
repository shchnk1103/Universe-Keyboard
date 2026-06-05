/// 将现有的 CandidateProvider 适配为 RimeEngine 协议。
///
/// 在真正的 librime 引擎就绪之前，这个适配器作为默认引擎使用。
/// 内部维护一个拼音组合缓冲区，完全复制当前 KeyboardController 中的手动 composition 逻辑：
/// - processKey: 向缓冲区追加字符 → 调用 CandidateProvider.candidates(for:) → 返回 RimeOutput
/// - deleteBackward: 移除缓冲区末尾字符
/// - selectCandidate: 返回被选中的候选词作为 committedText，清空缓冲区
/// - resetSession: 清空缓冲区
///
/// 这确保切换到 RimeEngine 协议后，键盘行为与当前完全一致。
final class CandidateProviderRimeAdapter: RimeEngine {

    private let candidateProvider: CandidateProvider
    private var composition: String = ""

    init(candidateProvider: CandidateProvider) {
        self.candidateProvider = candidateProvider
    }

    // MARK: - RimeEngine

    func processKey(_ key: String) -> RimeOutput {
        // 拼音输入统一用小写
        composition += key.lowercased()
        return buildOutput()
    }

    func selectCandidate(at index: Int) -> RimeOutput {
        let candidates = candidateProvider.candidates(for: composition)
        let committed: String
        if index >= 0 && index < candidates.count {
            committed = candidates[index]
        } else {
            committed = composition
        }
        composition = ""
        return RimeOutput(
            composition: nil,
            candidates: [],
            committedText: committed,
            highlightedIndex: -1
        )
    }

    func deleteBackward() -> RimeOutput {
        if !composition.isEmpty {
            composition.removeLast()
        }
        return buildOutput()
    }

    func replaceInput(_ input: String) -> RimeOutput {
        composition = input
        return buildOutput()
    }

    func resetSession() {
        composition = ""
    }

    func recoverSession() {
        resetSession()
    }

    func isComposing() -> Bool {
        !composition.isEmpty
    }

    func pageUp() -> RimeOutput {
        // 回退路径无分页机制 — 返回当前输出
        return buildOutput()
    }

    func pageDown() -> RimeOutput {
        return buildOutput()
    }

    // MARK: - Private

    private func buildOutput() -> RimeOutput {
        guard !composition.isEmpty else {
            return RimeOutput(composition: nil, candidates: [], highlightedIndex: -1)
        }
        let candidates = candidateProvider.candidates(for: composition)
        return RimeOutput(
            rawInput: composition,
            composition: RimeComposition(
                preeditText: composition,
                cursorPosition: composition.count
            ),
            candidates: candidates.map { RimeCandidate(text: $0) },
            highlightedIndex: candidates.isEmpty ? -1 : 0
        )
    }
}
