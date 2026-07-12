import Foundation

@MainActor
public final class KeyboardController {

    // MARK: - Public properties

    public internal(set) var state: KeyboardState
    public var textClient: TextInputClient?
    public let candidateProvider: CandidateProvider
    public var rimeEngine: RimeEngine?

    public var currentDate: () -> Date = { Date() }
    public var isTypoCorrectionPartialCommitEnabled = false
    public var typoCorrectionExperimentalEdits: TypoCorrectionExperimentalEdits = []
    public var typoCorrectionLearningSnapshot: TypoCorrectionLearningSnapshot = .empty
    public var onTypoCorrectionSelected: ((TypoCorrectionCommit) -> Void)?
    /// Called synchronously with ephemeral final text. Consumers must convert
    /// it to content-free aggregates before returning and must not persist it.
    public var onCommittedText: ((CommittedTextEvent) -> Void)?
    public var isPairedSymbolCompletionEnabled = true
    var shouldRestoreRimeComposition = false
    var shouldRebuildSessionDuringRestore = false

    // MARK: - Init

    public init(
        state: KeyboardState = KeyboardState(),
        candidateProvider: CandidateProvider = FakeCandidateProvider()
    ) {
        self.state = state
        self.candidateProvider = candidateProvider
    }

    /// 启用基于 CandidateProvider 的 RIME 适配器引擎。
    /// 在真正的 librime 就绪之前，此方法将现有的 FakeCandidateProvider 包装为 RimeEngine，
    /// 使键盘通过新架构运行，但行为与当前完全一致。
    public func enableDefaultRimeEngine() {
        rimeEngine = CandidateProviderRimeAdapter(candidateProvider: candidateProvider)
    }

    /// Reset RIME after the keyboard becomes visible again while preserving
    /// enough state to reconstruct an in-progress inline composition.
    public func resetRimeSessionForVisibilityChange() {
        guard let engine = rimeEngine else { return }
        engine.resetSession()
        shouldRestoreRimeComposition = !state.currentComposition.isEmpty
        shouldRebuildSessionDuringRestore = false
    }

    /// Drops unfinished input when the keyboard is hidden or shown again.
    ///
    /// Visibility changes are different from a transient RIME session loss:
    /// the user sees a newly presented keyboard, so stale composition and
    /// candidates must not remain visible from the previous host interaction.
    @discardableResult
    public func abandonCompositionForVisibilityChange() -> KeyboardEffect {
        let hadVisibleComposition =
            !state.currentComposition.isEmpty
            || state.lastRimeOutput != nil
            || state.partialCommit != nil
            || state.typoCorrection != nil
            || state.insertedPreeditCount > 0
            || !state.insertedPreeditText.isEmpty

        rimeEngine?.resetSession()
        shouldRestoreRimeComposition = false
        shouldRebuildSessionDuringRestore = false
        deleteInlinePreedit()
        state.currentComposition = ""
        state.lastRimeOutput = nil
        state.partialCommit = nil
        state.typoCorrection = nil
        state.insertedPreeditText = ""
        state.insertedPreeditCount = 0

        return hadVisibleComposition ? .compositionChanged : []
    }

    // MARK: - Public entry point

    @discardableResult
    public func handle(_ action: KeyboardAction) -> KeyboardEffect {
        switch action {
        case .insertKey(let key):
            return handleInsertKey(key)
        case .insertCandidate(let candidate, let kind, let selectionReference):
            return handleInsertCandidate(
                candidate,
                kind: kind,
                selectionReference: selectionReference
            )
        case .insertCorrectionCandidate(let correction):
            return handleInsertCorrectionCandidate(correction)
        case .insertDirectText(let text):
            return handleInsertDirectText(text, source: .directText)
        case .insertEmoji(let emoji):
            return handleInsertDirectText(emoji, source: .emoji)
        case .toggleShift:
            return handleToggleShift()
        case .togglePage:
            return handleTogglePage()
        case .toggleInputMode:
            return handleToggleInputMode()
        case .insertSpace:
            return handleInsertSpace()
        case .insertReturn:
            return handleInsertReturn()
        case .deleteBackward:
            return handleDeleteBackward()
        case .keyboardTypeChanged(let type):
            return handleKeyboardTypeChanged(type)
        case .candidatePageUp:
            return handleCandidatePageUp()
        case .candidatePageDown:
            return handleCandidatePageDown()
        }
    }
}
