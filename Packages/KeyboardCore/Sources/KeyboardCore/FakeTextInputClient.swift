public final class FakeTextInputClient: TextInputClient {
    public internal(set) var text: String = ""
    public internal(set) var deletedCount = 0
    public internal(set) var markedText: String = ""

    public init() {}

    public func insertText(_ text: String) {
        if !markedText.isEmpty {
            removeMarkedSuffix()
            markedText = ""
        }
        self.text += text
    }

    public func deleteBackward() {
        guard !text.isEmpty else { return }
        text.removeLast()
        if !markedText.isEmpty {
            markedText.removeLast()
        }
        deletedCount += 1
    }

    public func setMarkedText(_ text: String, selectedRange _: Range<Int>) {
        removeMarkedSuffix()
        self.text += text
        markedText = text
    }

    public func unmarkText() {
        markedText = ""
    }

    private func removeMarkedSuffix() {
        guard !markedText.isEmpty else { return }
        for _ in markedText {
            guard !text.isEmpty else { break }
            text.removeLast()
        }
    }
}
