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

/// EN-AUTOSPACE-IMMEDIATE-001：英文候选提交事务末尾已补 1 个 ASCII 空格且
/// 本状态机对该空格拥有回删资格的标记。
///
/// 回声抑制与本标记生命周期绑定（同清同活）：抑制只在标记武装期间存在，
/// 标记被任何路径撤销（候选失效入口、归属不成立的通知）时抑制一并撤销。
struct EnglishTrailingSpaceMark: Equatable {
    /// 本次提交事务写宿主的完整内容（前导空格 + 候选 + 尾随空格）。仅用于
    /// 回删/回声归属前的所有权核验（同一文档、光标紧邻刚插入空格）。进程
    /// 内存态，不持久化、不落日志（ADR 0007）。
    let committedTransactionText: String
    /// 提交回声抑制：宿主对本事务的 `textDidChange` 回声最多吞一次；耗尽后
    /// 的通知无法归属，撤销整个标记。
    var suppressNextEcho: Bool

    init(committedTransactionText: String) {
        self.committedTransactionText = committedTransactionText
        self.suppressNextEcho = true
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
    /// EN-AUTOSPACE-IMMEDIATE-001「已补尾随空格且拥有回删资格」标记。
    /// 候选提交事务在同一次 `insertText` 末尾写出 1 个 ASCII 空格时武装；
    /// 一切候选失效入口（语言切换、键盘类型/页面切换、外部编辑、其余写入
    /// 入口）与归属不成立的通知一律撤销。进程内存态，不持久化。
    var englishTrailingSpaceMark: EnglishTrailingSpaceMark? = nil
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
