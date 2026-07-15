import Foundation

public enum KeyboardPage: Equatable {
    case letters
    case numbers
    case symbols
    case emoji
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
    /// 当前拼音串的可选误触纠错建议。nil 表示没有可展示的纠错候选。
    public var typoCorrection: TypoCorrectionState?
    /// 当前普通 RIME 候选的部分确认状态。nil 表示没有已确认片段。
    public var partialCommit: PartialCommitState?
    /// 当前进程内的上屏后联想状态；与 RIME composition 完全分离且不持久化。
    public var continuation: ContinuationState
    /// 当前已插入到文本输入框中的拼音串。用于实现 inline preedit 的差量更新。
    public var insertedPreeditText: String = ""
    /// 当前已插入到文本输入框中的拼音串长度。保留长度字段，方便删除时避免重复计算。
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
        typoCorrection: TypoCorrectionState? = nil,
        partialCommit: PartialCommitState? = nil,
        continuation: ContinuationState = ContinuationState(),
        insertedPreeditText: String = "",
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
        self.typoCorrection = typoCorrection
        self.partialCommit = partialCommit
        self.continuation = continuation
        self.insertedPreeditText = insertedPreeditText
        self.insertedPreeditCount = insertedPreeditCount
    }
}
