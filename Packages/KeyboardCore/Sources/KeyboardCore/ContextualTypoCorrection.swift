import Foundation

/// 有界的多错误拼音假设搜索。
///
/// 这个类型只负责从按键误触模型生成少量假设，不查询 RIME、不持久化输入，也不决定
/// 候选最终位置。查询和排序仍由控制器在同一轮刷新中完成，避免搜索层获得 UI 或 session
/// 的副作用。
struct ContextualTypoCorrectionHypothesisEngine: Sendable {
    private static let maximumInputLength = 30
    private static let maximumEdits = 2
    private static let minimumInputLength = 8
    private static let insertionCharacters: [Character] = ["a", "e", "i", "o", "u"]

    private let budget: ContextualTypoCorrectionSearchBudget

    /// 默认预算是已经发布的 V2.0 生产合同（12/8）。扩大预算必须显式传入，
    /// 避免纯预检能力被意外带入按键后的生产查询路径。
    init(budget: ContextualTypoCorrectionSearchBudget = .productionV2) {
        self.budget = budget
    }

    func hypotheses(for input: String) -> [TypoCorrectionSuggestion] {
        let normalized = input.lowercased()
        let letters = Array(normalized)
        guard letters.count >= Self.minimumInputLength,
            letters.count <= Self.maximumInputLength
        else { return [] }

        var frontier = [State(input: normalized, edits: [], cost: 0)]
        var completed: [State] = []

        for depth in 1...Self.maximumEdits {
            var nextByInput: [String: State] = [:]
            for state in frontier {
                for candidate in oneEditStates(from: state) {
                    if let existing = nextByInput[candidate.input] {
                        // 相同字符串可能经由不同编辑路径得到；保留更符合误触模型的一条，
                        // 避免“恰好字典序较小”的路径主导后续 beam。
                        guard Self.isPreferred(candidate, existing) else { continue }
                    }
                    nextByInput[candidate.input] = candidate
                }
            }

            let orderedNext = nextByInput.values.sorted(by: Self.isPreferred)
            if depth == Self.maximumEdits {
                // 最后一层不再扩展，不应因 beam 截断丢失已形成的两处误触组合。
                // 这些纯字符串状态会在下面按显式预算压缩；生产默认仍是 8，
                // 渐进式预检必须显式选择更大的纯搜索预算。
                completed = orderedNext
                break
            }
            frontier = Self.diverseBeam(
                from: orderedNext,
                maximumCount: budget.maximumFirstLayerStates
            )
        }

        return completed
            .filter { $0.input != normalized }
            .sorted(by: Self.isPreferred)
            .prefix(budget.maximumHypotheses)
            .map {
                TypoCorrectionSuggestion(
                    originalInput: normalized,
                    correctedInput: $0.input,
                    edits: $0.edits,
                    candidates: []
                )
            }
    }

    private func oneEditStates(from state: State) -> [State] {
        let letters = Array(state.input)
        guard !letters.isEmpty else { return [] }

        let lastIndex = letters.count - 1
        var result: [State] = []

        for index in letters.indices {
            let original = letters[index]
            for replacement in TypoCorrectionKeyboard.nearbyKeys[original] ?? [] {
                guard TypoCorrectionKeyboard.isSafeReplacement(
                    original,
                    replacement,
                    at: index,
                    lastIndex: lastIndex
                ) else { continue }

                var corrected = letters
                corrected[index] = replacement
                result.append(
                    state.appending(
                        input: String(corrected),
                        edit: TypoCorrectionEdit(
                            index: index,
                            original: original,
                            replacement: replacement,
                            kind: .substitution
                        ),
                        cost: 1.0
                    )
                )
            }
        }

        for index in letters.indices.dropLast() where letters[index] != letters[index + 1] {
            var corrected = letters
            corrected.swapAt(index, index + 1)
            result.append(
                state.appending(
                    input: String(corrected),
                    edit: TypoCorrectionEdit(
                        index: index,
                        original: letters[index],
                        replacement: letters[index + 1],
                        kind: .transposition,
                        secondIndex: index + 1
                    ),
                    cost: 1.15
                )
            )
        }

        if let last = letters.last, letters.count >= 2, letters[letters.count - 2] == last {
            var corrected = letters
            corrected.removeLast()
            result.append(
                state.appending(
                    input: String(corrected),
                    edit: TypoCorrectionEdit(
                        index: lastIndex,
                        original: last,
                        replacement: last,
                        kind: .deletion
                    ),
                    cost: 1.25
                )
            )
        }

        let insertionStart = max(0, letters.count - 2)
        for index in insertionStart...letters.count {
            for inserted in Self.insertionCharacters {
                var corrected = letters
                corrected.insert(inserted, at: index)
                result.append(
                    state.appending(
                        input: String(corrected),
                        edit: TypoCorrectionEdit(
                            index: index,
                            original: inserted,
                            replacement: inserted,
                            kind: .insertion,
                            inserted: inserted
                        ),
                        cost: 1.35
                    )
                )
            }
        }

        return result
    }

    private static func isPreferred(_ lhs: State, _ rhs: State) -> Bool {
        if lhs.cost != rhs.cost { return lhs.cost < rhs.cost }
        let lhsHeuristic = heuristicScore(for: lhs)
        let rhsHeuristic = heuristicScore(for: rhs)
        if lhsHeuristic != rhsHeuristic { return lhsHeuristic < rhsHeuristic }
        if lhs.edits.map(\.index) != rhs.edits.map(\.index) {
            return lhs.edits.map(\.index).lexicographicallyPrecedes(rhs.edits.map(\.index))
        }
        return lhs.input < rhs.input
    }

    /// 首轮按编辑位置轮转取样，确保每个按键都有机会保留第二近的替代键。
    /// 这避免了键盘左侧字符恰好字典序靠前时，吞掉后续位置的真实误触。
    private static func diverseBeam(from states: [State], maximumCount: Int) -> [State] {
        var groups: [Int: [State]] = [:]
        for state in states {
            guard let index = state.edits.last?.index else { continue }
            groups[index, default: []].append(state)
        }

        let indexes = groups.keys.sorted()
        var selected: [State] = []
        var offset = 0
        while selected.count < maximumCount {
            var appended = false
            for index in indexes {
                guard let group = groups[index], offset < group.count else { continue }
                let state = group[offset]
                selected.append(state)
                appended = true
                if selected.count == maximumCount { break }
            }
            guard appended else { break }
            offset += 1
        }
        return selected
    }

    /// 将无法在候选栏中逐一验证的两处误触，按可解释的输入信号压缩为小集合。
    ///
    /// - 同类元音替换通常是窄键盘上的临近误触；
    /// - 两次误触分布在输入的不同位置，比连续改动同一段更像独立误触；
    /// - 键位表中的前项代表更近的按键。
    ///
    /// 这只是检索优先级而非置信度，最终是否展示仍以 RIME 候选与
    /// `TypoCorrectionAssessment` 为准。
    private static func heuristicScore(for state: State) -> Int {
        let replacementOrder = state.edits.reduce(into: 0) { score, edit in
            score += TypoCorrectionKeyboard.nearbyKeys[edit.original]?
                .firstIndex(of: edit.replacement) ?? 4
        }
        let vowelReplacementBonus = state.edits.reduce(into: 0) { bonus, edit in
            if isVowel(edit.original), isVowel(edit.replacement) {
                bonus -= 2
            }
        }

        let spreadPenalty: Int
        if state.edits.count >= 2 {
            let indices = state.edits.map(\.index).sorted()
            let distance = indices.last! - indices.first!
            let targetDistance = max(1, state.input.count / 2)
            spreadPenalty = abs(distance - targetDistance)
        } else {
            spreadPenalty = 0
        }

        return replacementOrder + vowelReplacementBonus + spreadPenalty
    }

    private static func isVowel(_ character: Character) -> Bool {
        ["a", "e", "i", "o", "u", "v"].contains(character)
    }

    private struct State: Sendable {
        let input: String
        let edits: [TypoCorrectionEdit]
        let cost: Double

        func appending(input: String, edit: TypoCorrectionEdit, cost: Double) -> State {
            State(input: input, edits: edits + [edit], cost: self.cost + cost)
        }
    }
}

/// 纯字符串搜索的显式预算。这里不包含 RIME 查询数或候选显示数；后两者仍由
/// 生产控制器合同独立约束。
struct ContextualTypoCorrectionSearchBudget: Sendable {
    let maximumFirstLayerStates: Int
    let maximumHypotheses: Int

    static let productionV2 = ContextualTypoCorrectionSearchBudget(
        maximumFirstLayerStates: 12,
        maximumHypotheses: 8
    )

    static let progressiveRecallPreflight = ContextualTypoCorrectionSearchBudget(
        maximumFirstLayerStates: 60,
        maximumHypotheses: 64
    )
}

/// 默认关闭的渐进召回预检计划。
///
/// 构造计划只生成内存中的拼音假设，不访问 RIME。批次边界用于证明未来可以把
/// 查询工作拆分为可取消的小片段；本类型当前没有接入生产控制器或 Keyboard UI。
struct ContextualTypoCorrectionSearchPlan: Sendable {
    static let maximumBatchSize = 8

    let hypotheses: [TypoCorrectionSuggestion]

    init(input: String) {
        hypotheses = ContextualTypoCorrectionHypothesisEngine(
            budget: .progressiveRecallPreflight
        ).hypotheses(for: input)
    }

    var batches: [[TypoCorrectionSuggestion]] {
        stride(from: 0, to: hypotheses.count, by: Self.maximumBatchSize).map { start in
            let end = min(start + Self.maximumBatchSize, hypotheses.count)
            return Array(hypotheses[start..<end])
        }
    }
}
