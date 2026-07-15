public struct KeyboardEffect: OptionSet, Equatable, Sendable {
    public let rawValue: UInt8

    public init(rawValue: UInt8) {
        self.rawValue = rawValue
    }

    public static let compositionChanged  = KeyboardEffect(rawValue: 1 << 0)
    public static let shiftStateChanged   = KeyboardEffect(rawValue: 1 << 1)
    public static let pageChanged         = KeyboardEffect(rawValue: 1 << 2)
    public static let inputModeChanged    = KeyboardEffect(rawValue: 1 << 3)
    public static let keyboardTypeChanged = KeyboardEffect(rawValue: 1 << 4)
    public static let continuationChanged = KeyboardEffect(rawValue: 1 << 5)
}
