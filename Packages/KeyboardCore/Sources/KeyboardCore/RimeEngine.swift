/// RIME 输入引擎的抽象协议。
///
/// 这是整个 RIME 集成的"架构接缝"：KeyboardController 只依赖这个协议，
/// 不关心底层是真实的 librime C++ 引擎、CandidateProvider 适配器、还是测试用的 Fake。
///
/// 协议使用 `AnyObject`（class-bound），因为 RIME session 是状态化、堆分配的对象。
/// processKey/selectCandidate/deleteBackward 都返回 `RimeOutput`，
/// 一次调用提供 UI 层需要的全部信息：当前拼音、候选列表、要上屏的文字。
public protocol RimeEngine: AnyObject {
    /// 处理一个按键。key 是按键的字符串标签，例如 "n", "a"。
    /// 返回更新后的拼音编辑状态、候选列表和可能的上屏文字。
    func processKey(_ key: String) -> RimeOutput

    /// 选择第 index 个候选词（0-based）。返回更新后的状态。
    func selectCandidate(at index: Int) -> RimeOutput

    /// 选择全局候选列表中的第 index 个候选词（0-based）。
    ///
    /// 与 `selectCandidate(at:)` 不同，这个索引不局限于当前页，供候选栏
    /// 无极滚动和展开面板点击后续候选使用。
    func selectCandidate(globalIndex index: Int) -> RimeOutput

    /// 从全局候选列表读取一段候选，不改变当前 RIME 候选页。
    func candidateWindow(from globalIndex: Int, limit: Int) -> RimeCandidateWindow

    /// 从 composition 中删除一个字符。返回更新后的状态。
    func deleteBackward() -> RimeOutput

    /// 用指定的未格式化输入替换当前 composition，并返回更新后的状态。
    /// 空字符串表示清空 composition。
    func replaceInput(_ input: String) -> RimeOutput

    /// 重置当前 session（清空未完成的拼音输入）。
    func resetSession()

    /// 宿主切换键盘后重建可用会话，并恢复用户选择的输入方案。
    ///
    /// Implementations must publish a fail-closed `runtimeSelection` when recovery
    /// cannot restore a usable session or the requested schema, and invoke
    /// `onRuntimeSelectionChanged` so chrome/input policy stay aligned.
    func recoverSession()

    /// 键盘即将不可见时同步释放底层运行时持有的文件资源。
    ///
    /// 这与 `resetSession()` 不同：后者只清空输入状态，不保证释放
    /// librime 及其数据库文件锁。
    func suspendForVisibilityChange()

    /// 键盘重新可见时重建运行时与输入会话。
    ///
    /// On any early failure (runtime init, session create, schema select), publish a
    /// fail-closed realized selection before returning so callers never reapply a
    /// stale T9 chrome/semantics snapshot.
    func resumeAfterVisibilityChange()

    /// Last realized selection after cold start, resume, recovery, or fail-closed publish.
    var runtimeSelection: RimeRuntimeSelection? { get }

    /// Fired whenever `runtimeSelection` is published (success or fail-closed).
    /// Extension UI wires this to reload chrome and controller T9 policy immediately.
    var onRuntimeSelectionChanged: ((RimeRuntimeSelection) -> Void)? { get set }

    /// 当前是否正在输入中（有活跃的拼音组合）。
    func isComposing() -> Bool

    /// 候选词翻页（上一页）。RIME 发送 Page_Up 按键码。
    /// 返回更新后的候选列表和拼音状态。
    func pageUp() -> RimeOutput

    /// 候选词翻页（下一页）。RIME 发送 Page_Down 按键码。
    /// 返回更新后的候选列表和拼音状态。
    func pageDown() -> RimeOutput
}
