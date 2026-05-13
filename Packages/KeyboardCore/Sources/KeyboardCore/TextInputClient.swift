public protocol TextInputClient: AnyObject {
    func insertText(_ text: String)
    func deleteBackward()
}
