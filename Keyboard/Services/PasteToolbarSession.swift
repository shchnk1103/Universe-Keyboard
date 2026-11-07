import KeyboardCore
import UIKit

/// One main-actor operation owns each provider result. Invalidated results are never replayed.
@MainActor
final class PasteToolbarSession {
    enum State: Equatable { case idle, loading, invalid }
    private(set) var state: State = .idle
    private(set) var activeOperationID: UInt64?
    private var nextOperationID: UInt64 = 1
    private(set) var pasteFailureVisible = false
    var isEligible: () -> Bool = { false }
    var commit: (String) -> PasteCommitResult = { _ in .rejectedNoClient }
    var onPresentationChanged: () -> Void = {}

    func begin() -> UInt64? {
        guard isEligible() else { invalidate(); return nil }
        let id = nextOperationID
        nextOperationID += 1
        activeOperationID = id
        state = .loading
        pasteFailureVisible = false
        onPresentationChanged()
        return id
    }

    func complete(_ text: String?, operationID: UInt64) {
        guard activeOperationID == operationID, state == .loading else { return }
        guard isEligible() else { invalidate(); return }
        guard let text, !text.isEmpty, text.utf16.count <= 8_000 else {
            finish(operationID, failed: true)
            return
        }
        // Keep loading through insertText: UIKit can synchronously reenter textDidChange.
        let result = commit(text)
        finish(operationID, failed: result != .inserted)
    }

    private func finish(_ id: UInt64, failed: Bool) {
        guard activeOperationID == id else { return }
        activeOperationID = nil
        state = .idle
        pasteFailureVisible = failed
        onPresentationChanged()
    }

    func invalidate(operationID: UInt64) {
        guard activeOperationID == operationID else { return }
        invalidate()
    }

    func invalidate() {
        activeOperationID = nil
        state = .invalid
        state = .idle
    }

    func clearFailure() { pasteFailureVisible = false }
}
