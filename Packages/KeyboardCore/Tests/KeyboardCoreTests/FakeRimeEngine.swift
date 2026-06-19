import KeyboardCore

struct FakeRimeSelectedSegment {
    let rawPrefix: String
    let text: String

    init(rawPrefix: String, text: String) {
        self.rawPrefix = rawPrefix
        self.text = text
    }
}

/// 可控的测试用 RimeEngine，不依赖真实 CandidateProvider。
/// 所有行为由预设的字典控制，与 FakeCandidateProvider 使用相同的数据。
final class FakeRimeEngine: RimeEngine {

    private var composition: String = ""
    private var selectedSegment: FakeRimeSelectedSegment?
    var sessionResetCount = 0
    var sessionRecoveryCount = 0
    var processKeysToDrop = 0
    var replaceInputsToDrop = 0

    private let dictionary: [String: [String]]
    private let preeditFormatter: (String) -> String
    private let selectionRemainders: [String: [Int: String]]
    private let selectedSegments: [String: [Int: FakeRimeSelectedSegment]]
    private let partialSelectionEmitsCommit: Bool

    init(
        dictionary: [String: [String]] = FakeRimeEngine.defaultDictionary,
        preeditFormatter: @escaping (String) -> String = { $0 },
        selectionRemainders: [String: [Int: String]] = [:],
        selectedSegments: [String: [Int: FakeRimeSelectedSegment]] = [:],
        partialSelectionEmitsCommit: Bool = true
    ) {
        self.dictionary = dictionary
        self.preeditFormatter = preeditFormatter
        self.selectionRemainders = selectionRemainders
        self.selectedSegments = selectedSegments
        self.partialSelectionEmitsCommit = partialSelectionEmitsCommit
    }

    private static let defaultDictionary: [String: [String]] = [
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
        if let index = digitSelectionIndex(for: key),
           !(dictionary[composition] ?? []).isEmpty
        {
            return selectCandidate(at: index)
        }
        composition += key.lowercased()
        return buildOutput()
    }

    func selectCandidate(at index: Int) -> RimeOutput {
        selectCandidate(globalIndex: index)
    }

    func selectCandidate(globalIndex index: Int) -> RimeOutput {
        let candidates = dictionary[composition] ?? []
        let committed: String
        if index >= 0 && index < candidates.count {
            committed = candidates[index]
        } else {
            committed = composition
        }
        if let selectedSegment = selectedSegments[composition]?[index] {
            self.selectedSegment = selectedSegment
            let output = buildOutput()
            return RimeOutput(
                rawInput: output.rawInput,
                composition: output.composition,
                candidates: output.candidates,
                committedText: partialSelectionEmitsCommit ? committed : nil,
                hasMorePages: output.hasMorePages,
                highlightedIndex: output.highlightedIndex,
                candidatePageNumber: output.candidatePageNumber
            )
        } else if let remainingInput = selectionRemainders[composition]?[index], !remainingInput.isEmpty {
            composition = remainingInput
            let output = buildOutput()
            return RimeOutput(
                rawInput: output.rawInput,
                composition: output.composition,
                candidates: output.candidates,
                committedText: partialSelectionEmitsCommit ? committed : nil,
                hasMorePages: output.hasMorePages,
                highlightedIndex: output.highlightedIndex,
                candidatePageNumber: output.candidatePageNumber
            )
        } else {
            composition = ""
            return RimeOutput(
                composition: nil,
                candidates: [],
                committedText: committed,
                highlightedIndex: -1
            )
        }
    }

    func candidateWindow(from globalIndex: Int, limit: Int) -> RimeCandidateWindow {
        let output = buildOutput()
        let safeStart = max(0, globalIndex)
        let safeLimit = max(0, limit)
        guard safeStart < output.candidates.count, safeLimit > 0 else {
            return RimeCandidateWindow(
                candidates: [],
                startIndex: safeStart,
                nextIndex: safeStart,
                hasMoreCandidates: false
            )
        }
        let end = min(output.candidates.count, safeStart + safeLimit)
        return RimeCandidateWindow(
            candidates: Array(output.candidates[safeStart..<end]),
            startIndex: safeStart,
            nextIndex: end,
            hasMoreCandidates: end < output.candidates.count
        )
    }

    func deleteBackward() -> RimeOutput {
        if !composition.isEmpty {
            composition.removeLast()
        }
        return buildOutput()
    }

    func replaceInput(_ input: String) -> RimeOutput {
        if replaceInputsToDrop > 0 {
            replaceInputsToDrop -= 1
            return RimeOutput()
        }
        composition = input
        // Mirrors librime set_input behavior observed on-device: selected segment state
        // can survive input replacement until the session is reset.
        return buildOutput()
    }

    func resetSession() {
        composition = ""
        selectedSegment = nil
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
        let displayComposition: String
        let candidateKey: String
        if let selectedSegment,
            composition.hasPrefix(selectedSegment.rawPrefix)
        {
            candidateKey = String(composition.dropFirst(selectedSegment.rawPrefix.count))
            displayComposition = selectedSegment.text + preeditFormatter(candidateKey)
        } else {
            candidateKey = composition
            displayComposition = preeditFormatter(composition)
        }
        let candidates = dictionary[candidateKey] ?? []
        let preeditText = displayComposition
        return RimeOutput(
            rawInput: composition,
            composition: RimeComposition(preeditText: preeditText, cursorPosition: preeditText.count),
            candidates: candidates.map { RimeCandidate(text: $0) },
            highlightedIndex: candidates.isEmpty ? -1 : 0
        )
    }

    private func digitSelectionIndex(for key: String) -> Int? {
        guard key.count == 1, let scalar = key.unicodeScalars.first else { return nil }
        guard scalar.value >= 49 && scalar.value <= 57 else { return nil }
        return Int(scalar.value - 49)
    }
}
