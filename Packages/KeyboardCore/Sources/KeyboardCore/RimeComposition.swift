/// RIME 引擎的"正在编辑"状态：当前输入的拼音串及其光标位置。
/// 对应 librime C API 中 RimeComposition 结构体。
public struct RimeComposition: Equatable, Sendable {

    /// 正在编辑的拼音串，例如 "ni hao"
    public let preeditText: String

    /// 光标在 preeditText 中的字节位置（与 librime `cursor_pos` 一致）
    public let cursorPosition: Int

    /// librime `RimeComposition.sel_start`：preedit 上的选择/高亮起点（引擎原生单位）。
    /// Phase 0.5 Spike 只读透传；**不得**在 Architecture 确认前当作候选消费槽位权威。
    /// 缺失时为 `nil`（旧字典或无 composition 选择信息）。
    public let selectionStart: Int?

    /// librime `RimeComposition.sel_end`：preedit 上的选择/高亮终点（引擎原生单位）。
    public let selectionEnd: Int?

    /// librime `RimeComposition.length`（引擎原生；Phase 0.6 只读观测）。
    public let length: Int?

    public init(
        preeditText: String,
        cursorPosition: Int,
        selectionStart: Int? = nil,
        selectionEnd: Int? = nil,
        length: Int? = nil
    ) {
        self.preeditText = preeditText
        self.cursorPosition = cursorPosition
        self.selectionStart = selectionStart
        self.selectionEnd = selectionEnd
        self.length = length
    }
}
