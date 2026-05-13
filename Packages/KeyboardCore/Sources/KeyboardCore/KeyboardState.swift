import Foundation

public enum KeyboardPage: Equatable {
    case letters
    case numbers
    case symbols
}

public enum InputMode: Equatable {
    case chinese
    case english
}

public enum ShiftState: Equatable {
    case off
    case singleUse
    case capsLock
}

public enum KeyboardType: Equatable {
    case `default`
    case emailAddress
    case URL
    case webSearch
    case other
}

public struct KeyboardState: Equatable {
    public var currentPage: KeyboardPage
    public var inputMode: InputMode
    public var shiftState: ShiftState
    public var currentComposition: String
    public var activeKeyboardType: KeyboardType
    public var lastShiftTapTime: Date?
    public var lastSpaceTapTime: Date?

    public init(
        currentPage: KeyboardPage = .letters,
        inputMode: InputMode = .chinese,
        shiftState: ShiftState = .off,
        currentComposition: String = "",
        activeKeyboardType: KeyboardType = .default,
        lastShiftTapTime: Date? = nil,
        lastSpaceTapTime: Date? = nil
    ) {
        self.currentPage = currentPage
        self.inputMode = inputMode
        self.shiftState = shiftState
        self.currentComposition = currentComposition
        self.activeKeyboardType = activeKeyboardType
        self.lastShiftTapTime = lastShiftTapTime
        self.lastSpaceTapTime = lastSpaceTapTime
    }
}
