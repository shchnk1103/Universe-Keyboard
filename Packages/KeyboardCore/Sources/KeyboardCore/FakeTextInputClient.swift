public final class FakeTextInputClient: TextInputClient {
    public internal(set) var text: String = ""
    public internal(set) var deletedCount = 0

    public init() {}

    public func insertText(_ text: String) {
        self.text += text
    }

    public func deleteBackward() {
        guard !text.isEmpty else { return }
        text.removeLast()
        deletedCount += 1
    }
}
