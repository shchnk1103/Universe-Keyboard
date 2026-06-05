/// `processKey` 或 `selectCandidate` 调用后的完整返回值。
/// 一次返回 UI 层需要的所有信息：当前拼音、候选列表、要上屏的文字。
public struct RimeOutput: Equatable, Sendable {

    /// RIME 当前未格式化的原始输入，例如 "nihao"。
    /// 与可能包含分段空格的 composition.preeditText 分离。
    public let rawInput: String?

    /// 当前的拼音编辑状态。nil 表示不在输入中（composition 已被清除）。
    public let composition: RimeComposition?

    /// 当前页的候选词列表
    public let candidates: [RimeCandidate]

    /// 需要插入到文档中的文字。nil 表示本次操作没有产生上屏文字。
    public let committedText: String?

    /// 是否存在更多候选词（翻页用）
    public let hasMorePages: Bool

    /// 当前高亮的候选词索引（-1 表示没有高亮）
    public let highlightedIndex: Int

    /// 当前候选页码。librime 首页为 0。
    public let candidatePageNumber: Int

    public init(
        rawInput: String? = nil,
        composition: RimeComposition? = nil,
        candidates: [RimeCandidate] = [],
        committedText: String? = nil,
        hasMorePages: Bool = false,
        highlightedIndex: Int = -1,
        candidatePageNumber: Int = 0
    ) {
        self.rawInput = rawInput
        self.composition = composition
        self.candidates = candidates
        self.committedText = committedText
        self.hasMorePages = hasMorePages
        self.highlightedIndex = highlightedIndex
        self.candidatePageNumber = candidatePageNumber
    }
}
