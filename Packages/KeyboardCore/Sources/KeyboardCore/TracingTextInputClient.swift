/// Transparently forwards host operations while notifying the in-memory recorder.
@MainActor
public final class TracingTextInputClient: TextInputClient {
    private let base: any TextInputClient
    private let recorder: CommitTraceRecorder

    /// Wrap an existing client without changing its ownership or operation order.
    public init(_ base: any TextInputClient, recorder: CommitTraceRecorder) {
        self.base = base
        self.recorder = recorder
    }

    /// Forward the host's text-presence observation unchanged.
    public var hasTextBeforeInput: Bool { base.hasTextBeforeInput }

    /// Observe and forward an insertion.
    public func insertText(_ text: String) {
        recorder.willWrite(.insert, text: text)
        base.insertText(text)
    }

    /// Observe and forward a deletion.
    public func deleteBackward() {
        recorder.willWrite(.delete)
        base.deleteBackward()
    }

    /// Forward cursor movement unchanged.
    public func adjustTextPosition(byCharacterOffset offset: Int) {
        base.adjustTextPosition(byCharacterOffset: offset)
    }

    /// Observe and forward a marked-text update with its original range.
    public func setMarkedText(_ text: String, selectedRange: Range<Int>) {
        recorder.willWrite(text.isEmpty ? .clearMarked : .setMarked, text: text)
        base.setMarkedText(text, selectedRange: selectedRange)
    }

    /// Observe and forward marked-text confirmation.
    public func unmarkText() {
        recorder.willWrite(.unmark)
        base.unmarkText()
    }
}
