public final class FakeTextInputClient: TextInputClient {
    public internal(set) var text: String = "" {
        didSet {
            if !isUpdatingTextInternally {
                cursorOffset = text.count
            }
        }
    }
    public internal(set) var deletedCount = 0
    public internal(set) var markedText: String = ""
    /// Every value sent through `setMarkedText`, including transient values that
    /// a later update may replace. Tests use this to enforce host-display safety
    /// at the write boundary rather than checking only the final state.
    public internal(set) var markedTextHistory: [String] = []
    public internal(set) var cursorOffset = 0
    private var isUpdatingTextInternally = false

    public var hasTextBeforeInput: Bool {
        cursorOffset > 0
    }

    public init() {}

    public func insertText(_ text: String) {
        if !markedText.isEmpty {
            removeMarkedSuffix()
            markedText = ""
        }
        insert(text, at: cursorOffset)
        cursorOffset += text.count
    }

    public func deleteBackward() {
        guard cursorOffset > 0, !text.isEmpty else { return }
        let deleteIndex = text.index(text.startIndex, offsetBy: cursorOffset - 1)
        updateTextInternally {
            text.remove(at: deleteIndex)
        }
        cursorOffset -= 1
        if !markedText.isEmpty {
            markedText.removeLast()
        }
        deletedCount += 1
    }

    public func adjustTextPosition(byCharacterOffset offset: Int) {
        cursorOffset = min(max(0, cursorOffset + offset), text.count)
    }

    public func setMarkedText(_ text: String, selectedRange: Range<Int>) {
        markedTextHistory.append(text)
        let markedStart = max(0, cursorOffset - markedText.count)
        removeMarkedSuffix()
        insert(text, at: cursorOffset)
        markedText = text
        let selectedOffset = min(max(0, selectedRange.upperBound), text.count)
        cursorOffset = markedStart + selectedOffset
    }

    public func unmarkText() {
        markedText = ""
    }

    private func removeMarkedSuffix() {
        guard !markedText.isEmpty else { return }
        let markedStart = max(0, cursorOffset - markedText.count)
        for _ in markedText {
            guard text.count > markedStart else { break }
            let index = text.index(text.startIndex, offsetBy: markedStart)
            updateTextInternally {
                text.remove(at: index)
            }
        }
        cursorOffset = markedStart
    }

    private func insert(_ insertedText: String, at offset: Int) {
        let index = text.index(text.startIndex, offsetBy: min(max(0, offset), text.count))
        updateTextInternally {
            text.insert(contentsOf: insertedText, at: index)
        }
    }

    private func updateTextInternally(_ update: () -> Void) {
        isUpdatingTextInternally = true
        update()
        isUpdatingTextInternally = false
    }
}
