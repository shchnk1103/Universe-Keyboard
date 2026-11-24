extension KeyboardController {
    @discardableResult
    public func setPostCommitContinuationEnabled(_ enabled: Bool) -> KeyboardEffect {
        guard enabled != isPostCommitContinuationEnabled else { return [] }
        isPostCommitContinuationEnabled = enabled
        if !enabled {
            state.continuation = ContinuationState()
            // PB-013：开关关闭同时退出标点续接态。
            state.punctuationContinuation = nil
        }
        return .continuationChanged
    }

    func didCommitText(_ text: String, source: CommittedTextSource) {
        clearT9UnconfirmedDeleteHistory()
        refreshContinuation(afterCommitting: text)
        onCommittedText?(CommittedTextEvent(text: text, source: source))
    }

    func refreshContinuation(afterCommitting text: String) {
        guard isPostCommitContinuationEnabled, state.inputMode == .chinese else {
            state.continuation = ContinuationState()
            return
        }
        // PB-013：标点续接态与普通联想二选一。续接武装期间（含连打链的
        // 同一次点选提交）跳过联想 context 写入，标点不污染上下文；
        // 退出矩阵清空续接态后普通字母提交照常走原联想。
        guard state.punctuationContinuation == nil else { return }
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
