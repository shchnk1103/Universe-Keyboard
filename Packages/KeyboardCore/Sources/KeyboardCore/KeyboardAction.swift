public enum KeyboardAction: Equatable {
    case insertKey(String)
    case insertCandidate(String, kind: String)
    case insertDirectText(String)
    case toggleShift
    case togglePage
    case toggleInputMode
    case insertSpace
    case insertReturn
    case deleteBackward
    case keyboardTypeChanged(KeyboardType)
}
