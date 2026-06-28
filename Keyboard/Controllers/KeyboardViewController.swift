//
//  KeyboardViewController.swift
//  Keyboard
//
//  Created by DoubleShy0N on 5/10/26.
//
//  UIInputViewController 主控制器 — 管理键盘生命周期、根布局和 UI 刷新。
//  所有状态逻辑委托给 KeyboardCore.KeyboardController。
//
//  根据 Apple 官方文档《Creating a Custom Keyboard》的要求：
//  1. 必须继承 UIInputViewController（✅ 已满足）
//  2. 通过 inputView 属性提供键盘 UI（✅ 系统自动管理，我们添加子视图即可）
//  3. 使用 textDocumentProxy 进行所有文本操作（✅ 通过 UITextDocumentProxyAdapter 封装）
//  4. 在 viewWillLayoutSubviews 中更新 needsInputModeSwitchKey（✅ 控制地球键显示）
//  5. 响应 textDidChange 以适应不同的键盘类型（✅ 同步 UIKeyboardType 变化）
//
//  输入动作 → KeyboardViewController+InputActions.swift
//  模式动作 → KeyboardViewController+ModeActions.swift
//  删除连发 → KeyboardViewController+DeleteActions.swift
//  UI 工厂方法 → KeyboardViewController+Layout.swift
//  手势处理 → KeyboardViewController+Gestures.swift
//  候选栏 → KeyboardViewController+CandidateBar.swift
//  按钮样式 → KeyboardViewController+KeyFactory.swift
//  状态刷新 → KeyboardViewController+Display.swift
//

import KeyboardCore
import RimeBridge
import UIKit

@MainActor
class KeyboardViewController: UIInputViewController {

    // MARK: - 视图引用

    /// Liquid Glass-inspired 外层承载面。只负责背景、圆角和轻量层次，不参与输入逻辑。
    var keyboardSurfaceView: UIView!
    /// 实验性系统材质层。默认关闭；由主 App 的实验开关控制。
    var keyboardSurfaceMaterialView: UIVisualEffectView!
    /// 统一 surface 底色层。覆盖整个键盘区域，避免候选栏单独形成矩形断层。
    var keyboardSurfaceFillView: UIView!
    /// Surface 顶部的克制高光，用于在浅色/深色模式下提供轻微玻璃层次。
    var keyboardSurfaceHighlightView: UIView!
    /// 自定义键盘高度约束。只约束整体输入视图高度，不改变单行按键高度。
    var keyboardHeightConstraint: NSLayoutConstraint?
    /// 根布局容器，垂直排列候选栏 + 4 行按键
    var rootStack: UIStackView!
    /// 候选栏的容器视图（包含 scrollView + 展开按钮）
    var candidateBar: UIView!
    /// 候选词横向滚动区域
    var candidateScrollView: UIScrollView!
    /// 横向候选集合视图，按需复用可见 cell
    var candidateCollectionView: UICollectionView?
    /// 地球键（输入法切换），iOS 要求所有第三方键盘必须提供
    var nextKeyboardButton: UIButton!
    /// Shift 键，位于第 3 行左侧
    var shiftButton: UIButton!
    /// 回车键，位于最后一行最右侧
    var returnButton: UIButton!
    /// 所有字母键按钮的引用，用于 Shift 状态下批量刷新标题
    var letterButtons: [UIButton] = []

    // MARK: - 业务逻辑控制器

    /// 状态机核心，处理所有按键逻辑（纯逻辑，无 UI 依赖）
    var controller: KeyboardController!

    // MARK: - 删除自动重复

    /// 长按删除的计时器生命周期由专用协调器单独持有。
    let deleteRepeatController = DeleteRepeatController()

    // MARK: - 长按变体字符（UI 层状态）

    /// 当前显示的变体字符弹出面板
    var variantPopupView: KeyPopupView?
    /// 正在长按的按钮引用
    var longPressedButton: UIButton?
    /// 展开的候选面板（流式布局）
    var candidateExpandedPanel: UIView?
    /// 展开面板内部的纵向滚动视图（用于无限滚动检测）
    var expandedPanelScrollView: UIScrollView?
    /// 展开态使用的流式候选列表，支持增量插入而无需重建整个面板
    var expandedCandidateCollectionView: UICollectionView?
    /// 展开/收起候选面板的 SF Symbol 按钮
    var candidateExpandButton: UIButton?
    /// 展开按钮宽度约束（无候选时设为 0 隐藏）
    var candidateExpandButtonWidthConstraint: NSLayoutConstraint?
    /// 候选面板是否处于展开状态
    var isCandidateExpanded = false
    /// 上次滑动翻页的时间戳（用于防抖，避免连续触发）
    var lastPageSwipeTime: CFTimeInterval = 0
    /// 累积候选词列表（无极滑动：随着用户滚动持续追加后续页的候选）
    var accumulatedCandidates: [CandidateItem] = []
    /// RIME 是否还有更多页的候选
    var hasMoreCandidates: Bool = false
    /// 是否正在加载更多候选（防止重复触发）
    var isLoadingMoreCandidates: Bool = false
    /// 候选栏已加载的页数深度。旧分页诊断字段保留，当前全局索引预取路径不再依赖它。
    var candidatePageDepth: Int = 0
    /// 下一次从 RIME 全局候选列表读取的起始索引。
    var nextCandidateGlobalIndex: Int = 0
    /// 当前候选快照对应的 raw input，用于丢弃旧输入的延迟预取结果。
    var candidateSnapshotRawInput: String?
    /// 候选快照代数；每次 composition 变化递增。
    var candidateSnapshotGeneration: Int = 0
    /// 当前预取目标。展开态会加载更多候选，横向栏保持小批量。
    var candidatePrefetchMode: CandidatePrefetchMode = .bar
    /// 用户正在拖动候选栏或展开面板时不做同步 RIME 预取，避免滑动中卡住。
    var isCandidateScrollInteracting = false
    /// 滑动期间被推迟的预取请求，手势结束后再执行。
    var deferredCandidatePrefetchMode: CandidatePrefetchMode?
    /// 预取请求序号。新的输入、展开/收起或新的预取安排会让旧延迟任务自然失效。
    var candidatePrefetchRequestSerial = 0
    /// 候选 cell 尺寸缓存。滚动布局会频繁查询 sizeForItemAt，缓存可避免重复文本测量。
    var candidateCellSizeCache: [String: CGSize] = [:]
    /// 记录每个按钮的 touchDown 时间戳，用于性能日志
    var keyTouchDownTimes: [ObjectIdentifier: CFTimeInterval] = [:]
    /// 已在 touchDown 发出反馈的按钮，避免 touchUpInside 业务方法重复播放声音/触感。
    var keyPressFeedbackEmittedButtonIDs: Set<ObjectIdentifier> = []
    /// 输入事件编号，将按键、引擎和渲染日志关联到同一次操作
    var inputEventSequence = 0
    /// 前一个字母输入完成时间，用于观察快速输入中的事件排队现象
    var lastInputCompletionTime: CFTimeInterval?

    // MARK: - 光标移动状态

    /// 是否处于光标移动模式（长按空格键触发，此模式下其他按键禁用）
    var isCursorMovementModeActive: Bool = false
    /// 光标移动模式下，上一次有效计算的 X 坐标
    var spaceCursorLastLocationX: CGFloat?
    // MARK: - 键盘生命周期与尺寸状态

    /// viewDidAppear 是否已被调用过。
    var hasViewAppeared = false
    /// 按键内容仅在键盘即将呈现时安装，避免初始过渡容器绘制整份键盘。
    var isKeyboardUIInstalled = false

    // MARK: - 缓存的设置值

    /// 缓存的按键音开关状态，避免每次按键都通过 XPC 跨进程访问 UserDefaults。
    /// Apple 最佳实践：自定义键盘扩展运行在独立进程中，每次 XPC 调用都有开销。
    /// 缓存这些值可以显著减少每次按键的延迟。
    var cachedKeyClickEnabled: Bool = true
    var cachedHapticEnabled: Bool = false

    /// Feedback resources and cached levels stay owned by the view controller; methods live in +Feedback.
    let hapticGenerator = UIImpactFeedbackGenerator(style: .light)
    let modeEnterHapticGenerator = UIImpactFeedbackGenerator(style: .heavy)
    let clickPlayer = KeyClickPlayer()
    static let appGroupID = "group.com.DoubleShy0N.Universe-Keyboard"
    lazy var typoCorrectionLearningStore = TypoCorrectionLearningStore(
        defaults: UserDefaults(suiteName: Self.appGroupID)
    )
    var cachedKeyClickLevel: KeyboardFeedbackLevel = .defaultLevel
    var cachedHapticLevel: KeyboardFeedbackLevel = .defaultLevel
    var cachedKeyClickVolume: Float = 0.8
    var cachedHapticIntensity: CGFloat = 0.5
    var deleteRepeatEffectiveFeedbackCount = 0

    // MARK: - 布局常量

    /// 键盘内容顶部留白。保留少量空间，避免候选栏贴住系统外层圆角。
    let keyboardContentTopInset: CGFloat = 2
    /// 键盘内容底部留白。底部由系统容器提供圆角与安全区域，这里只保留极小间距。
    let keyboardContentBottomInset: CGFloat = 0
    /// 候选栏高度（点）。系统键盘外层容器已提供顶部承载面，候选栏保持更紧凑。
    let candidateBarHeight: CGFloat = 34
    /// 候选栏与第一行按键之间的间距。并入候选栏自身高度，保证这块区域也能接收候选手势。
    let candidateToKeySpacing: CGFloat = 14
    /// 仅用于裁切内部布局，避免透明内容超出系统外层大圆角；不绘制额外 surface。
    let keyboardSurfaceMaskCornerRadius: CGFloat = 34
    /// 单个按键高度（点）。45pt 比 HIG 最小触控目标略高，接近原生键盘手感。
    let keyHeight: CGFloat = 45
    /// 行间垂直间距（点）。8pt 对齐网格，接近原生键盘行间距。
    let keySpacing: CGFloat = 8
    /// 字母区与底部功能区之间的分组间距。只比常规行距略大，避免键盘显得松散。
    let keyboardGroupSpacing: CGFloat = 10
    /// 行内按键水平间距（点）。保持 6pt 紧凑排列，与原生键盘一致（行内键距 < 行间距）。
    let keyHorizontalSpacing: CGFloat = 6
    /// 第三行功能键与字母组之间的分组间距，对齐字母区与底部功能区的视觉节奏。
    let thirdRowFunctionSpacing: CGFloat = 10
    /// 主要功能键宽度（Shift、123、删除、语言切换），保持触控舒适但弱化视觉占比。
    let primaryFunctionKeyWidth: CGFloat = 46
    /// 功能键符号字号。略大于普通功能键文字，提高 Shift/Delete/Globe 可读性。
    let functionKeySymbolPointSize: CGFloat = 18
    /// 按键圆角半径（点），使用 .continuous 曲线获得 iOS 原生外观
    let keyCornerRadius: CGFloat = 9
    // MARK: === 生命周期 ===

    override func viewDidLoad() {
        super.viewDidLoad()
        bootstrapKeyboard()
    }

    /// deinit 是键盘扩展被销毁前的最后一个清理机会。
    /// Apple 文档指出：系统可能在键盘关闭后保留扩展进程一段时间，
    /// 所以不要假设 deinit 会在键盘关闭时立即调用。
    /// 但一旦调用，应该释放所有资源。
    deinit {
        // 提交尽力而为的后台日志刷新，不在析构路径等待共享存储。
        Logger.shared.requestFlush()
        // 连删协调器在 viewWillDisappear 中停止；闭包仅弱引用本控制器，
        // 析构路径无需跨 actor 访问 UIKit/Timer 状态。
        // 移除所有通知观察者，防止野指针
        NotificationCenter.default.removeObserver(self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        installKeyboardUIIfNeeded()
    }

    /// viewDidAppear 在键盘视图对用户可见时调用。
    /// 清理返回前未完成的 RIME 组合状态；仅在后续输入确认
    /// session 已失效时，控制器才会触发真正的 runtime 恢复。
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        handleKeyboardDidAppear()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let effects = cleanupTransientKeyboardState(
            reason: "viewWillDisappear",
            abandonsComposition: true
        )
        if !effects.isEmpty, isKeyboardUIInstalled {
            syncUI(with: effects)
        }
        Logger.shared.debug(
            "viewWillDisappear: bounds=\(view.bounds)",
            category: .display
        )
        Logger.shared.requestFlush()
    }

    /// 切回主 App 查看诊断时，确保最后一批异步合并日志已经写入共享容器。
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        Logger.shared.debug(
            "viewDidDisappear: bounds=\(view.bounds)",
            category: .display
        )
        Logger.shared.requestFlush()
    }

    /// viewWillLayoutSubviews 在子视图布局之前调用。
    /// Apple 文档要求：在此更新 needsInputModeSwitchKey 的可见性。
    /// 该属性告知系统是否需要显示"地球键"让用户在多个键盘间切换。
    /// 如果返回 true 但不显示地球键，用户将无法切换到其他键盘（违反 App Store 审核要求）。
    override func viewWillLayoutSubviews() {
        // Apple 文档明确要求：在此生命周期方法中更新地球键可见性
        // 这是因为 needsInputModeSwitchKey 的值可能在键盘生命周期中改变
        // （例如用户启用了新键盘），必须实时响应
        nextKeyboardButton?.isHidden = !needsInputModeSwitchKey
        if keyboardSurfaceView != nil {
            applyKeyboardSurfaceStyle()
        }
        super.viewWillLayoutSubviews()
    }

    /// viewDidLayoutSubviews 记录系统实际采用的输入视图尺寸。
    /// 若仍出现临时高度，此日志可区分系统容器行为与已安装内容布局。
    private var lastLoggedBounds: CGRect = .zero

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // 仅在 bounds 变化时记录（避免 layout 循环时刷屏日志）
        if view.bounds != lastLoggedBounds {
            lastLoggedBounds = view.bounds
            Logger.shared.debug(
                "viewDidLayoutSubviews: bounds=\(view.bounds)",
                category: .display
            )
        }
    }

    // MARK: === 文本变化回调 ===

    /// textWillChange 在宿主 App 的文本即将变化时调用。
    /// Apple 文档：可在此准备键盘状态以响应即将到来的文本变更。
    /// 当前我们不需要在文本变化前做任何预处理，保留空实现。
    override func textWillChange(_ textInput: UITextInput?) {
        // 预留：可在文本变化前做预处理
    }

    /// textDidChange 在宿主 App 的文本发生变化后调用。
    /// Apple 文档要求自定义键盘在此方法中：
    /// 1. 检查 textDocumentProxy.keyboardType 以识别宿主 App 期望的键盘类型
    /// 2. 根据键盘类型调整布局
    /// 3. 更新地球键的文本颜色以匹配键盘外观（浅色/深色模式）
    ///
    /// 我们的实现额外检查：
    /// - 自动大写是否需要重新应用（切换键盘类型后）
    /// - RIME 引擎部署状态
    override func textDidChange(_ textInput: UITextInput?) {
        synchronizeAfterTextChange()
    }

    // MARK: === 内存警告处理 ===

    /// Apple 文档《Creating a Custom Keyboard》明确指出：
    /// "自定义键盘扩展运行在独立进程中，有着严格的内存限制；
    ///  超出这些限制会导致系统终止你的扩展。"
    ///
    /// "始终处理低内存通知，释放非必要资源。"
    ///
    /// 我们的键盘扩展内存上限约 50-80MB（取决于设备型号）。
    /// 当系统内存紧张时，UIKit 会调用此方法。
    /// 我们应该释放可重新创建的缓存和资源。
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        releaseRecoverableResourcesAfterMemoryWarning()
    }

}

enum CandidatePrefetchMode {
    case bar
    case expanded
}
