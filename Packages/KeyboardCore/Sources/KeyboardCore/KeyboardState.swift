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
    /// RIME 引擎最近一次操作的输出缓存。nil 表示未使用 RIME 路径。
    public var lastRimeOutput: RimeOutput?
    /// 当前已插入到文本输入框中的拼音串长度。用于实现 inline preedit：
    /// 每次按键更新拼音时，先删除旧拼音再插入新拼音。
    public var insertedPreeditCount: Int = 0

    public init(
        currentPage: KeyboardPage = .letters,
        inputMode: InputMode = .chinese,
        shiftState: ShiftState = .off,
        currentComposition: String = "",
        activeKeyboardType: KeyboardType = .default,
        lastShiftTapTime: Date? = nil,
        lastSpaceTapTime: Date? = nil,
        lastRimeOutput: RimeOutput? = nil,
        insertedPreeditCount: Int = 0
    ) {
        self.currentPage = currentPage
        self.inputMode = inputMode
        self.shiftState = shiftState
        self.currentComposition = currentComposition
        self.activeKeyboardType = activeKeyboardType
        self.lastShiftTapTime = lastShiftTapTime
        self.lastSpaceTapTime = lastSpaceTapTime
        self.lastRimeOutput = lastRimeOutput
        self.insertedPreeditCount = insertedPreeditCount
    }
}
