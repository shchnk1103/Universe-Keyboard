/// RIME 引擎的"正在编辑"状态：当前输入的拼音串及其光标位置。
/// 对应 librime C API 中 RimeComposition 结构体。
public struct RimeComposition: Equatable, Sendable {

    /// 正在编辑的拼音串，例如 "ni hao"
    public let preeditText: String

    /// 光标在 preeditText 中的字节位置
    public let cursorPosition: Int

    public init(preeditText: String, cursorPosition: Int) {
        self.preeditText = preeditText
        self.cursorPosition = cursorPosition
    }
}
