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
    var visibilitySuspendCount = 0
    var visibilityResumeCount = 0
    var processKeysToDrop = 0
    var replaceInputsToDrop = 0

    /// Mirrors production realized-selection publishing for lifecycle tests.
    private(set) var runtimeSelection: RimeRuntimeSelection?
    var onRuntimeSelectionChanged: ((RimeRuntimeSelection) -> Void)?

    /// When true, `resumeAfterVisibilityChange` fails init/session and publishes fail-closed.
    var resumeInitShouldFail = false
    /// When true, resume reaches schema selection failure and publishes fail-closed.
    var resumeSchemaSelectShouldFail = false
    /// When true, `recoverSession` cannot recreate a session and publishes fail-closed.
    var recoverSessionShouldFail = false
    /// When set, recovery succeeds but reconciles against this actual schema id.
    var recoverActualSchemaID: String?

    private var isSuspendedForVisibilityChange = false

    /// Candidate texts by composition key. Mutable so tests can simulate same-raw re-rank.
    var dictionary: [String: [String]]
    /// Parallel comments for dictionary candidates (same key, same order). Used for T9 path Spike tests.
    var comments: [String: [String]]
    /// Optional full-window evidence keyed by live composition.
    /// This lets tests model a paged RIME output whose first page is narrower
    /// than `candidateWindow`, without changing the default fake behavior.
    var candidateWindowOverrides: [String: [RimeCandidate]] = [:]
    private let preeditFormatter: (String) -> String
    private let selectionRemainders: [String: [Int: String]]
    private let selectedSegments: [String: [Int: FakeRimeSelectedSegment]]
    private let partialSelectionEmitsCommit: Bool
    /// When set, `replaceInput` returns empty composition to simulate Rime rejection.
    var replaceInputShouldFail = false
    /// When true, digit keys append to composition (T9 algebra) instead of selecting candidates.
    var appendDigitsToComposition = false
    /// Queued `replaceInput` results (consumed in order). Used for wrong-raw / rollback tests.
    var replaceInputScript: [RimeOutput] = []
    /// Last argument passed to `replaceInput` (session inspection).
    private(set) var lastReplaceInputArgument: String?
    /// Current raw composition string (session mirror for tests).
    var sessionComposition: String { composition }

    init(
        dictionary: [String: [String]] = FakeRimeEngine.defaultDictionary,
        comments: [String: [String]] = [:],
        preeditFormatter: @escaping (String) -> String = { $0 },
        selectionRemainders: [String: [Int: String]] = [:],
        selectedSegments: [String: [Int: FakeRimeSelectedSegment]] = [:],
        partialSelectionEmitsCommit: Bool = true
    ) {
        self.dictionary = dictionary
        self.comments = comments
        self.preeditFormatter = preeditFormatter
        self.selectionRemainders = selectionRemainders
        self.selectedSegments = selectedSegments
        self.partialSelectionEmitsCommit = partialSelectionEmitsCommit
    }

    /// Seed a realized selection as if cold-start already selected this runtime.
    func seedRuntimeSelection(_ selection: RimeRuntimeSelection) {
        publish(selection)
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
        if !appendDigitsToComposition,
           let index = digitSelectionIndex(for: key),
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
        let candidates = candidateWindowOverrides[composition] ?? buildOutput().candidates
        let safeStart = max(0, globalIndex)
        let safeLimit = max(0, limit)
        guard safeStart < candidates.count, safeLimit > 0 else {
            return RimeCandidateWindow(
                candidates: [],
                startIndex: safeStart,
                nextIndex: safeStart,
                hasMoreCandidates: false
            )
        }
        let end = min(candidates.count, safeStart + safeLimit)
        return RimeCandidateWindow(
            candidates: Array(candidates[safeStart..<end]),
            startIndex: safeStart,
            nextIndex: end,
            hasMoreCandidates: end < candidates.count
        )
    }

    func deleteBackward() -> RimeOutput {
        if !composition.isEmpty {
            composition.removeLast()
        }
        return buildOutput()
    }

    func replaceInput(_ input: String) -> RimeOutput {
        lastReplaceInputArgument = input
        if replaceInputsToDrop > 0 {
            replaceInputsToDrop -= 1
            return RimeOutput()
        }
        if !replaceInputScript.isEmpty {
            let scripted = replaceInputScript.removeFirst()
            if let raw = scripted.rawInput {
                composition = raw
            } else if scripted.composition == nil, scripted.committedText == nil {
                // Empty rejection without mutating session composition.
            } else if let committed = scripted.committedText, !committed.isEmpty {
                composition = ""
            }
            return scripted
        }
        if replaceInputShouldFail {
            return RimeOutput(composition: nil, candidates: [], highlightedIndex: -1)
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
        if recoverSessionShouldFail {
            // Production: session recreate failure publishes fail-closed before return.
            publishFailClosed()
            resetSession()
            return
        }
        if let actual = recoverActualSchemaID {
            let requested = runtimeSelection
                ?? RimeRuntimeSelection(
                    baseSchemaID: "rime_ice",
                    layoutStyle: .nineKey,
                    t9ReadinessMatched: true
                )
            publish(requested.reconciled(withActualSchemaID: actual))
        }
        resetSession()
    }

    func suspendForVisibilityChange() {
        visibilitySuspendCount += 1
        isSuspendedForVisibilityChange = true
        resetSession()
    }

    func resumeAfterVisibilityChange() {
        visibilityResumeCount += 1
        guard isSuspendedForVisibilityChange else { return }
        if resumeInitShouldFail {
            // Production: stay suspended + fail-closed (do not reapply stale T9).
            publishFailClosed()
            return
        }
        if resumeSchemaSelectShouldFail {
            publishFailClosed()
            return
        }
        // Successful resume: re-publish current selection (already realized).
        if let current = runtimeSelection {
            publish(current)
        }
        isSuspendedForVisibilityChange = false
    }

    func isComposing() -> Bool {
        !composition.isEmpty
    }

    private func publishFailClosed() {
        let requested = runtimeSelection
            ?? RimeRuntimeSelection(
                baseSchemaID: "rime_ice",
                layoutStyle: .nineKey,
                t9ReadinessMatched: true
            )
        publish(requested.reconciled(withActualSchemaID: nil))
    }

    private func publish(_ selection: RimeRuntimeSelection) {
        runtimeSelection = selection
        onRuntimeSelectionChanged?(selection)
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
        let commentsForKey = comments[candidateKey] ?? []
        let preeditText = displayComposition
        let rimeCandidates: [RimeCandidate] = candidates.enumerated().map { index, text in
            let comment = index < commentsForKey.count ? commentsForKey[index] : nil
            return RimeCandidate(text: text, comment: comment, globalIndex: index)
        }
        return RimeOutput(
            rawInput: composition,
            composition: RimeComposition(preeditText: preeditText, cursorPosition: preeditText.count),
            candidates: rimeCandidates,
            highlightedIndex: candidates.isEmpty ? -1 : 0
        )
    }

    private func digitSelectionIndex(for key: String) -> Int? {
        guard key.count == 1, let scalar = key.unicodeScalars.first else { return nil }
        guard scalar.value >= 49 && scalar.value <= 57 else { return nil }
        return Int(scalar.value - 49)
    }
}
