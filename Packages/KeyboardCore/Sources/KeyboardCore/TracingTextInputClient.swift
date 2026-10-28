@MainActor
public final class TracingTextInputClient: TextInputClient {
    private let base: any TextInputClient
    private let recorder: CommitTraceRecorder
    public init(_ base: any TextInputClient, recorder: CommitTraceRecorder) {
        self.base = base; self.recorder = recorder
    }
    public var hasTextBeforeInput: Bool { base.hasTextBeforeInput }
    public func insertText(_ text: String) { recorder.willWrite(.insert, text: text); base.insertText(text) }
    public func deleteBackward() { recorder.willWrite(.delete); base.deleteBackward() }
    public func adjustTextPosition(byCharacterOffset offset: Int) { base.adjustTextPosition(byCharacterOffset: offset) }
    public func setMarkedText(_ text: String, selectedRange: Range<Int>) {
        recorder.willWrite(text.isEmpty ? .clearMarked : .setMarked, text: text);
        base.setMarkedText(text, selectedRange: selectedRange)
    }
    public func unmarkText() { recorder.willWrite(.unmark); base.unmarkText() }
}
