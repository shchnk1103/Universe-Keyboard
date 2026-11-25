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

/// 地址类输入字段分类。三类互切属于同一会话，共用一份快照（URL-MODE-ENGLISH-DESIGN-001）。
public enum AddressLikeKeyboardType: Equatable {
    case URL
    case webSearch
    case emailAddress

    public init?(keyboardType: KeyboardType) {
        switch keyboardType {
        case .URL: self = .URL
        case .webSearch: self = .webSearch
        case .emailAddress: self = .emailAddress
        default: return nil
        }
    }
}

/// 进入 addressLike 字段会话时的输入模式快照。
/// 手动选择（用户点击中/英）优先于快照恢复；恢复写入不记为手动选择（m2）。
public struct AddressLikeSessionState: Equatable {
    /// 从非 addressLike 首次进入时用户原本的输入模式。
    public var originalMode: InputMode
    /// 本会话内用户是否手动切换过输入模式。
    public var manualSelection: Bool

    public init(originalMode: InputMode, manualSelection: Bool = false) {
        self.originalMode = originalMode
        self.manualSelection = manualSelection
    }
}

public struct KeyboardState: Equatable {
    public var currentPage: KeyboardPage
    public var inputMode: InputMode
    public var shiftState: ShiftState
    public var currentComposition: String
    public var activeKeyboardType: KeyboardType
    /// 当前 addressLike 会话的输入模式快照；nil 表示不处于地址类会话。
    public var addressLikeSession: AddressLikeSessionState? = nil
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
    /// PB-013 标点回弹后候选栏续接状态。nil 表示未武装。进程内存态，不持久化。
    public var punctuationContinuation: PunctuationContinuationState? = nil
    /// 英文模式前缀候选状态（当前词前缀 + 大小写对齐建议 + 来源版本）。
    /// 与中文 continuation 完全分离且不持久化。
    public var englishCandidate: EnglishCandidateState = EnglishCandidateState()
    /// 英文候选提交后延后补空格标记（设计 r1「标记未补」；EN-mode fix r1）。
    /// 仅当候选提交时右邻为已知空上下文（文档尾）才武装：英文模式下一个直
    /// 输 ASCII 字母携带该空格；标点与其他输入豁免撤回；退格与一切候选失
    /// 效（模式/页面/宿主类型切换、外部编辑）一并撤回。进程内存态，不持久化。
    public var pendingEnglishAutospace: Bool = false
    /// 当前已插入到文本输入框中的拼音串。用于实现 inline preedit 的差量更新。
    public var insertedPreeditText: String = ""
    /// 当前已插入到文本输入框中的拼音串长度。保留长度字段，方便删除时避免重复计算。
    public var insertedPreeditCount: Int = 0
    /// Monotonic Core-owned presentation revision for composition output.
    /// Candidates, marked text and T9 Path state installed by one transition
    /// must be observed under the same value (ADR 0022).
    public var compositionRevision: UInt64 = 0
    /// Precise T9 pinyin path bar state (ADR 0020). Empty when not composing under T9.
    public var t9PinyinPathState: T9PinyinPathState = .empty
    /// Experimental reversible automatic-anchor ledger (ADR 0024 Stage 2).
    public var t9ReversibleAutoAnchorState: T9ReversibleAutoAnchorState = .empty
    /// 九键待确认标点（ADR 0029）。nil 表示当前没有可替换标点。
    public var pendingPunctuation: PendingPunctuationState? = nil
    /// 待确认颜表情（ADR 0030）。与 pendingPunctuation 互斥。
    public var pendingKaomoji: PendingKaomojiState? = nil

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
        punctuationContinuation: PunctuationContinuationState? = nil,
        insertedPreeditText: String = "",
        insertedPreeditCount: Int = 0,
        compositionRevision: UInt64 = 0,
        t9PinyinPathState: T9PinyinPathState = .empty,
        t9ReversibleAutoAnchorState: T9ReversibleAutoAnchorState = .empty,
        pendingPunctuation: PendingPunctuationState? = nil,
        pendingKaomoji: PendingKaomojiState? = nil
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
        self.punctuationContinuation = punctuationContinuation
        self.insertedPreeditText = insertedPreeditText
        self.insertedPreeditCount = insertedPreeditCount
        self.compositionRevision = compositionRevision
        self.t9PinyinPathState = t9PinyinPathState
        self.t9ReversibleAutoAnchorState = t9ReversibleAutoAnchorState
        self.pendingPunctuation = pendingPunctuation
        self.pendingKaomoji = pendingKaomoji
    }
}
