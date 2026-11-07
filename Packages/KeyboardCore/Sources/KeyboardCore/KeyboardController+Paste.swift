public enum PasteCommitResult: Equatable, Sendable {
    case inserted
    case rejectedEmpty
    case rejectedNotIdle
    case rejectedNoClient
}

extension KeyboardController {
    /// Inserts user-requested plain text without feeding it into learning or statistics.
    @discardableResult
    public func commitPastedPlainText(_ text: String) -> PasteCommitResult {
        guard !text.isEmpty else { return .rejectedEmpty }
        guard state.currentComposition.isEmpty, state.insertedPreeditCount == 0,
            state.pendingPunctuation == nil, state.pendingKaomoji == nil
        else { return .rejectedNotIdle }
        guard let textClient else { return .rejectedNoClient }

        performOwnedHostMutation { textClient.insertText(text) }
        clearT9UnconfirmedDeleteHistory()
        state.continuation = ContinuationState()
        state.typoCorrection = nil
        return .inserted
    }
}
