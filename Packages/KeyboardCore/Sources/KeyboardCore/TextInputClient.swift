@MainActor
public protocol TextInputClient: AnyObject {
    func insertText(_ text: String)
    func deleteBackward()

    /// Replaces the active composing range in the host text field.
    /// `selectedRange` uses character offsets in KeyboardCore and is converted
    /// to `NSRange` at the UIKit adapter boundary.
    func setMarkedText(_ text: String, selectedRange: Range<Int>)

    /// Confirms the active marked range without changing its visible text.
    func unmarkText()
}
