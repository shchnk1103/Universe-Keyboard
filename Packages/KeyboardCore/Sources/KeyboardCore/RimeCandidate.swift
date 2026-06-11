/// 单个候选词。对应 librime C API 中 RimeCandidate 结构体。
public struct RimeCandidate: Equatable, Sendable {

    /// 候选词文字，例如 "你好"
    public let text: String

    /// 可选注释，例如 "ni hao" 或 "💯"
    public let comment: String?

    /// librime candidate list 中的全局索引。普通当前页输出可能没有该值。
    public let globalIndex: Int?

    public init(text: String, comment: String? = nil, globalIndex: Int? = nil) {
        self.text = text
        self.comment = comment
        self.globalIndex = globalIndex
    }
}
