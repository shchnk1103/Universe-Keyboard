import Foundation

@MainActor
public final class KeyboardController {

    // MARK: - Public properties

    public internal(set) var state: KeyboardState
    public var textClient: TextInputClient?
    public let candidateProvider: CandidateProvider
    public let continuationSuggestionProvider: any ContinuationSuggestionProviding
    public var typoCorrectionCandidateQuery: TypoCorrectionCandidateQuerying
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
    public internal(set) var isPostCommitContinuationEnabled = true
    /// Derived from the same `RimeRuntimeSelection` used for schema + layout.
    /// Digit shape alone never enables T9 policies.
    public var usesT9InputSemantics = false
    var shouldRestoreRimeComposition = false
    var shouldRebuildSessionDuringRestore = false

    // MARK: - Init

    public init(
        state: KeyboardState = KeyboardState(),
        candidateProvider: CandidateProvider = FakeCandidateProvider(),
        continuationSuggestionProvider: any ContinuationSuggestionProviding = BundledContinuationSuggestionProvider.shared
    ) {
        self.state = state
        self.candidateProvider = candidateProvider
        self.continuationSuggestionProvider = continuationSuggestionProvider
        self.typoCorrectionCandidateQuery = CandidateProviderTypoCorrectionQuery(
            candidateProvider: candidateProvider
        )
    }

    /// 启用基于 CandidateProvider 的 RIME 适配器引擎。
    /// 在真正的 librime 就绪之前，此方法将现有的 FakeCandidateProvider 包装为 RimeEngine，
    /// 使键盘通过新架构运行，但行为与当前完全一致。
    public func enableDefaultRimeEngine() {
        rimeEngine = CandidateProviderRimeAdapter(candidateProvider: candidateProvider)
        typoCorrectionCandidateQuery = CandidateProviderTypoCorrectionQuery(
            candidateProvider: candidateProvider
        )
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
            || !state.continuation.isEmpty
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
        state.continuation = ContinuationState()
        state.insertedPreeditText = ""
        state.insertedPreeditCount = 0

        return hadVisibleComposition ? [.compositionChanged, .continuationChanged] : []
    }

    /// 在扩展进入不可见状态前释放 RIME 的进程级资源。
    /// 必须由 UI 生命周期同步调用，不能推迟到不可预测的 `deinit`。
    public func suspendRimeForVisibilityChange() {
        rimeEngine?.suspendForVisibilityChange()
    }

    /// 在扩展重新可见时恢复 RIME runtime 与 session。
    /// Also reapplies fail-closed / realized T9 semantics from the engine selection.
    public func resumeRimeAfterVisibilityChange() {
        rimeEngine?.resumeAfterVisibilityChange()
        applyRealizedSelectionFromEngine()
    }

    /// Align `usesT9InputSemantics` with the engine's last published realized selection.
    /// Extension chrome still reloads via `onRuntimeSelectionChanged`.
    public func applyRealizedSelectionFromEngine() {
        guard let selection = rimeEngine?.runtimeSelection else { return }
        usesT9InputSemantics = selection.usesT9InputSemantics
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
