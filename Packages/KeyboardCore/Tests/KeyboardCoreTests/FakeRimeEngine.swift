import KeyboardCore

/// 可控的测试用 RimeEngine，不依赖真实 CandidateProvider。
/// 所有行为由预设的字典控制，与 FakeCandidateProvider 使用相同的数据。
final class FakeRimeEngine: RimeEngine {

    private var composition: String = ""
    var sessionResetCount = 0
    var sessionRecoveryCount = 0
    var processKeysToDrop = 0

    private let dictionary: [String: [String]] = [
        "ni":       ["你", "呢", "尼"],
        "hao":      ["好", "号", "浩"],
        "nihao":    ["你好", "拟好", "你号"],
        "shi":      ["是", "时", "事"],
        "wo":       ["我", "握", "窝"],
    ]

    // MARK: - RimeEngine

    func processKey(_ key: String) -> RimeOutput {
        if processKeysToDrop > 0 {
            processKeysToDrop -= 1
            return RimeOutput()
        }
        composition += key.lowercased()
        return buildOutput()
    }

    func selectCandidate(at index: Int) -> RimeOutput {
        let candidates = dictionary[composition] ?? []
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

    func resetSession() {
        composition = ""
        sessionResetCount += 1
    }

    func recoverSession() {
        sessionRecoveryCount += 1
        resetSession()
    }

    func isComposing() -> Bool {
        !composition.isEmpty
    }

    func pageUp() -> RimeOutput { buildOutput() }

    func pageDown() -> RimeOutput { buildOutput() }

    // MARK: - Private

    private func buildOutput() -> RimeOutput {
        guard !composition.isEmpty else {
            return RimeOutput(composition: nil, candidates: [], highlightedIndex: -1)
        }
        let candidates = dictionary[composition] ?? []
        return RimeOutput(
            composition: RimeComposition(preeditText: composition, cursorPosition: composition.count),
            candidates: candidates.map { RimeCandidate(text: $0) },
            highlightedIndex: candidates.isEmpty ? -1 : 0
        )
    }
}
