extension KeyboardController {
    @discardableResult
    public func setPostCommitContinuationEnabled(_ enabled: Bool) -> KeyboardEffect {
        guard enabled != isPostCommitContinuationEnabled else { return [] }
        isPostCommitContinuationEnabled = enabled
        if !enabled {
            state.continuation = ContinuationState()
        }
        return .continuationChanged
    }

    func didCommitText(_ text: String, source: CommittedTextSource) {
        refreshContinuation(afterCommitting: text)
        onCommittedText?(CommittedTextEvent(text: text, source: source))
    }

    func refreshContinuation(afterCommitting text: String) {
        guard isPostCommitContinuationEnabled, state.inputMode == .chinese else {
            state.continuation = ContinuationState()
            return
        }
        guard !text.contains(where: { $0 == "\n" || $0 == "\r" }) else {
            state.continuation = ContinuationState()
            return
        }

        let combined = state.continuation.context + text
        let boundedContext = String(combined.suffix(ContinuationState.maximumContextLength))
        state.continuation = ContinuationState(
            context: boundedContext,
            suggestions: continuationSuggestionProvider.suggestions(
                for: boundedContext,
                limit: ContinuationState.maximumSuggestionCount
            )
        )
    }

    @discardableResult
    func clearContinuation() -> KeyboardEffect {
        guard !state.continuation.isEmpty else { return [] }
        state.continuation = ContinuationState()
        return .continuationChanged
    }
}
