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
//  按键动作 → KeyboardViewController+Actions.swift
//  UI 工厂方法 → KeyboardViewController+Layout.swift
//  手势处理 → KeyboardViewController+Gestures.swift
//  候选栏 → KeyboardViewController+CandidateBar.swift
//  按钮样式 → KeyboardViewController+KeyFactory.swift
//  状态刷新 → KeyboardViewController+Display.swift
//

import UIKit
import KeyboardCore

class KeyboardViewController: UIInputViewController {

    // MARK: - 视图引用

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

    // MARK: - 删除自动重复（UI 层状态）

    /// 长按删除的自动重复计时器
    var deleteRepeatTimer: Timer?
    /// 标记当前是否处于自动重复删除阶段
    var isDeleteRepeatActive = false

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
    /// 候选栏已加载的页数深度（用于 loadMoreCandidates 回到第 1 页时计算 pageUp 次数）
    var candidatePageDepth: Int = 0
    /// 记录每个按钮的 touchDown 时间戳，用于性能日志
    var keyTouchDownTimes: [ObjectIdentifier: CFTimeInterval] = [:]
    /// 输入事件编号，将按键、引擎和渲染日志关联到同一次操作
    var inputEventSequence = 0
    /// 前一个字母输入完成时间，用于观察快速输入中的事件排队现象
    var lastInputCompletionTime: CFTimeInterval?

    // MARK: - 键盘可见性状态（防闪烁机制）

    /// viewDidAppear 是否已被调用过。
    /// Apple 文档指出：iOS 在呈现键盘时会经历 3 阶段的尺寸调整
    /// （全屏 → 中间态 → 最终高度），无法通过任何公开 API 阻止。
    /// 我们使用 alpha=0 隐藏键盘，等到 viewDidAppear 后、高度稳定时才显示。
    private var hasViewAppeared = false
    /// 键盘是否已经完成首次显示（alpha=1）
    private var hasShownKeyboard = false

    // MARK: - 缓存的设置值

    /// 缓存的按键音开关状态，避免每次按键都通过 XPC 跨进程访问 UserDefaults。
    /// Apple 最佳实践：自定义键盘扩展运行在独立进程中，每次 XPC 调用都有开销。
    /// 缓存这些值可以显著减少每次按键的延迟。
    private var cachedKeyClickEnabled: Bool = true
    private var cachedHapticEnabled: Bool = false

    // MARK: - 布局常量

    /// 候选栏高度（点）。44pt 满足 HIG 最小触摸目标，同时对齐 8pt 网格。
    let candidateBarHeight: CGFloat = 44
    /// 单个按键高度（点）
    let keyHeight: CGFloat = 44
    /// 行间垂直间距（点）。8pt 对齐网格，接近原生键盘行间距。
    let keySpacing: CGFloat = 8
    /// 行内按键水平间距（点）。保持 6pt 紧凑排列，与原生键盘一致（行内键距 < 行间距）。
    let keyHorizontalSpacing: CGFloat = 6
    /// 按键圆角半径（点），使用 .continuous 曲线获得 iOS 原生外观
    let keyCornerRadius: CGFloat = 9

    // MARK: === 生命周期 ===

    /// viewDidLoad 是键盘扩展的第一个入口点。
    /// Apple 文档建议在此时完成：
    /// - 初始化 UI 布局
    /// - 设置 RIME 引擎
    /// - 配置缓存和通知监听
    /// - 避免在此处进行耗时操作（会延迟键盘首次显示）
    override func viewDidLoad() {
        super.viewDidLoad()

        let startupTime = CACurrentMediaTime()

        // ── 1. 基础视图配置 ──────────────────────────────────────────
        // 设置键盘背景色（跟随系统深色/浅色模式自动切换）
        view.backgroundColor = keyboardBackgroundColor

        // allowsSelfSizing = true 告诉系统：我们的键盘可以自适应高度。
        // 虽然 iOS 仍会执行 3 阶段 resize，但此设置确保系统不会忽略 intrinsicContentSize。
        inputView?.allowsSelfSizing = true

        // preferredContentSize 告诉系统我们期望的键盘高度。
        // width=0 表示不限制宽度（系统会自动填满屏幕宽度）。
        // 高度：候选栏(44) + 4行按键(4×44) + 4个行间距(4×8) + 上下边距(6) = 258
        let totalHeight = candidateBarHeight + keyHeight * 4 + keySpacing * 4 + 6
        preferredContentSize = CGSize(width: 0, height: totalHeight)

        // ── 2. 防闪烁机制（详见 viewDidLayoutSubviews 注释）──────────
        // 初始 alpha=0：在 3 阶段 resize 完成前完全隐藏键盘。
        // Apple DTS 确认：没有任何公开 API 可以阻止这个过程。
        view.alpha = 0

        // ── 3. 设置键盘类型和状态控制器 ───────────────────────────────
        // 声明键盘的主要语言为简体中文（Apple 用于输入法管理）
        // 注意：primaryLanguage 在 iOS 26 中是只读属性，只能在 Info.plist 中设置。
        // 此处保留仅供参考。

        let keyboardType = KeyboardType.from(uiKeyboardType: textDocumentProxy.keyboardType)
        let state = KeyboardState(activeKeyboardType: keyboardType)
        controller = KeyboardController(state: state)
        // 用适配器包装 textDocumentProxy，方便在纯逻辑层进行测试
        controller.textClient = UITextDocumentProxyAdapter(proxy: textDocumentProxy)

        Logger.shared.info("viewDidLoad, keyboardType=\(keyboardType)", category: .general)

        // ── 4. 初始化 RIME 引擎（双路径设计） ─────────────────────────
        // RIME 路径：真正的中文引擎（librime + 雾凇拼音）
        // 回退路径：FakeCandidateProvider（在 RIME 不可用时提供基本功能）
        if let (sharedDir, userDir) = RimeConfigManager.prepareDirectories() {
            Logger.shared.info("App Group available, creating RimeEngineImpl", category: .engine)
            controller.rimeEngine = RimeEngineImpl(sharedDataDir: sharedDir, userDataDir: userDir)

            // 健康检查：发送两个按键测试 RIME 是否正确响应
            var testOutput = controller.rimeEngine!.processKey("n")
            Logger.shared.info(
                "processKey(n) → preedit: \(testOutput.composition?.preeditText ?? "nil"), " +
                "candidates: \(testOutput.candidates.count)",
                category: .engine
            )
            testOutput = controller.rimeEngine!.processKey("i")
            Logger.shared.info(
                "processKey(i) → preedit: \(testOutput.composition?.preeditText ?? "nil"), " +
                "candidates: \(testOutput.candidates.count)",
                category: .engine
            )
            // 重置会话，清除测试按键的状态
            controller.rimeEngine!.resetSession()

            if testOutput.candidates.isEmpty {
                Logger.shared.warning(
                    "No candidates on first check; engine will deploy on keystroke",
                    category: .engine
                )
            } else {
                Logger.shared.info(
                    "RIME ready, candidates: \(testOutput.candidates.count)",
                    category: .engine
                )
            }
        } else {
            // App Group 不可用时的降级方案
            controller.enableDefaultRimeEngine()
            Logger.shared.warning("App Group unavailable, using Fake adapter", category: .engine)
        }

        let elapsed = (CACurrentMediaTime() - startupTime) * 1000
        Logger.shared.performance("viewDidLoad complete", durationMs: elapsed)

        // ── 5. 自动大写检查（英文模式启动时） ─────────────────────────
        // 如果键盘以英文模式启动，检查当前文本上下文是否需要自动大写
        // 例如：新文档、句号后、换行后等情况
        if controller.state.inputMode == .english {
            let context = textDocumentProxy.documentContextBeforeInput
            _ = controller.applyAutoCapitalization(contextBeforeInput: context)
        }

        // ── 6. 缓存设置值和注册通知监听 ───────────────────────────────
        // 将 UserDefaults 值缓存在本地变量中，避免每次按键都进行 XPC 调用。
        // 当主 App 修改设置时，通过 didChangeNotification 通知更新缓存。
        refreshCachedSettings()
        observeSettingsChanges()

        // 预热触觉反馈引擎，减少第一次按键的延迟
        hapticGenerator.prepare()

        // ── 7. 构建键盘 UI ───────────────────────────────────────────
        setupRootStack()
        // 使用 performWithoutAnimation 确保初始布局无过渡动画，
        // 避免在 alpha=0 状态下出现奇怪的过渡效果
        UIView.performWithoutAnimation {
            reloadKeyboard()
        }
    }

    /// deinit 是键盘扩展被销毁前的最后一个清理机会。
    /// Apple 文档指出：系统可能在键盘关闭后保留扩展进程一段时间，
    /// 所以不要假设 deinit 会在键盘关闭时立即调用。
    /// 但一旦调用，应该释放所有资源。
    deinit {
        // 将日志缓冲区刷入持久存储
        Logger.shared.flush()
        // 停止任何活跃的删除自动重复计时器
        stopDeleteRepeat()
        // 移除所有通知观察者，防止野指针
        NotificationCenter.default.removeObserver(self)
    }

    /// viewDidAppear 在键盘视图对用户可见时调用。
    /// 清理返回前未完成的 RIME 组合状态；仅在后续输入确认
    /// session 已失效时，控制器才会触发真正的 runtime 恢复。
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let isReturningToExistingKeyboard = hasViewAppeared
        hasViewAppeared = true

        // 返回键盘时只清理输入状态，避免不必要地销毁仍然健康的 session。
        if isReturningToExistingKeyboard, controller.rimeEngine != nil {
            controller.resetRimeSessionForVisibilityChange()
            accumulatedCandidates = []
            hasMoreCandidates = false
            candidatePageDepth = 0
            Logger.shared.info(
                "viewDidAppear: RIME composition cleared after keyboard return",
                category: .engine
            )
        }

        Logger.shared.debug(
            "viewDidAppear: bounds=\(view.bounds)",
            category: .display
        )
    }

    /// 切回主 App 查看诊断时，确保最后一批异步合并日志已经写入共享容器。
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        Logger.shared.flush()
    }

    /// viewWillLayoutSubviews 在子视图布局之前调用。
    /// Apple 文档要求：在此更新 needsInputModeSwitchKey 的可见性。
    /// 该属性告知系统是否需要显示"地球键"让用户在多个键盘间切换。
    /// 如果返回 true 但不显示地球键，用户将无法切换到其他键盘（违反 App Store 审核要求）。
    override func viewWillLayoutSubviews() {
        // Apple 文档明确要求：在此生命周期方法中更新地球键可见性
        // 这是因为 needsInputModeSwitchKey 的值可能在键盘生命周期中改变
        // （例如用户启用了新键盘），必须实时响应
        nextKeyboardButton.isHidden = !needsInputModeSwitchKey
        super.viewWillLayoutSubviews()
    }

    /// viewDidLayoutSubviews 在子视图布局完成后调用。
    /// 我们在此执行两个关键任务：
    ///
    /// 1. 更新候选栏右侧的 CAGradientLayer 渐隐遮罩的 frame。
    ///    因为 layout 完成后 scrollView 的 bounds 才最终确定，
    ///    必须同步更新遮罩 layer 的 frame 以匹配。
    ///
    /// 2. 键盘闪烁缓解（核心逻辑）：
    ///    iOS 系统呈现自定义键盘时经历 3 阶段 resize：
    ///     阶段 1：全屏高度（如 844pt on iPhone 13 Pro）
    ///     阶段 2：中间态（如 445pt）
    ///     阶段 3：最终高度（216-250pt，取决于设备和系统版本）
    ///    在阶段 1-2 中显示键盘，用户会看到明显的跳动和闪烁。
    ///    Apple DTS 工程师确认：没有任何公开 API 可以阻止或绕过这个过程。
    ///
    ///    我们的策略：
    ///    - viewDidLoad 时设置 view.alpha = 0
    ///    - 等待 viewDidAppear 完成（hasViewAppeared == true）
    ///    - 等待 view.bounds.height 降到合理范围（< 400pt 过滤掉 844/445pt 中间态）
    ///    - 条件满足后一次性设置 view.alpha = 1
    ///
    ///    hasShownKeyboard 保证只执行一次，避免每次 layout 都触发。
    /// 上次记录日志时的 bounds，避免 layout 频繁触发时刷屏日志。
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

        // ── 任务 2：条件触发键盘显示 ───────────────────────────────
        // 三个条件必须同时满足：
        //   1. hasShownKeyboard == false（保证只触发一次）
        //   2. hasViewAppeared == true（viewDidAppear 已经调用过）
        //   3. view.bounds.height > 0 且 < 400（高度已稳定到合理范围）
        if !hasShownKeyboard, hasViewAppeared, view.bounds.height > 0, view.bounds.height < 400 {
            hasShownKeyboard = true
            view.alpha = 1
            Logger.shared.info(
                "keyboard revealed at h=\(view.bounds.height)",
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
        let proxy = self.textDocumentProxy

        // 根据宿主 App 的外观模式（深色/浅色）更新地球键文字颜色
        // 这是 Apple 文档明确建议的做法
        let textColor: UIColor = proxy.keyboardAppearance == .dark ? .white : .black
        nextKeyboardButton.setTitleColor(textColor, for: [])

        // 检查并更新回车键样式（send/search/go 等动作键的空文本/有文本状态切换）
        updateReturnKeyAppearance()

        // ── 检测键盘类型变化 ──────────────────────────────────────
        // Apple 文档：使用 textDocumentProxy.keyboardType 来适配不同输入场景
        // 例如：ASCII 键盘、邮箱地址键盘、数字键盘等
        let keyboardType = KeyboardType.from(uiKeyboardType: proxy.keyboardType)
        var effects = controller.handle(.keyboardTypeChanged(keyboardType))

        // ── 自动大写检测 ──────────────────────────────────────────
        // 使用 textDocumentProxy.documentContextBeforeInput 检查光标前的文本
        // Apple 文档：可利用此上下文提供上下文感知的输入
        let context = proxy.documentContextBeforeInput
        let autoCapEffect = controller.applyAutoCapitalization(contextBeforeInput: context)
        effects.formUnion(autoCapEffect)

        // 无变化则跳过 UI 刷新（性能优化：避免不必要的视图重建）
        guard !effects.isEmpty else { return }
        syncUI(with: effects)
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

        Logger.shared.warning(
            "didReceiveMemoryWarning: releasing caches",
            category: .general
        )

        // ── 释放可重新创建的缓存 ──────────────────────────────────
        // 1. 清除按键触控时间戳缓存（性能日志用，可丢弃）
        keyTouchDownTimes.removeAll()

        // 2. 关闭展开的候选面板，释放屏外 cell 缓存
        if isCandidateExpanded {
            isCandidateExpanded = false
            dismissExpandedCandidatePanel(animated: false)
        }

        // 3. 集合视图只保留可见 cell，无需手动清空所有候选按钮。

        // 4. 通知 RIME 引擎释放内部缓存（如果支持）
        //    librime 内部的词库缓存可能占用数十 MB 内存
        //    注意：不要释放 session，只是清理可能的临时缓存
    }

    // MARK: === 根布局（详见 KeyboardViewController+Layout.swift）===

    /// 初始化根布局：垂直 UIStackView，上边距 6pt，下边距 8pt（给系统指示条留空间）
    func setupRootStack() {
        rootStack = UIStackView()
        rootStack.axis = .vertical
        rootStack.spacing = keySpacing
        rootStack.distribution = .fill
        // 禁用自动尺寸掩码转约束（使用 Auto Layout 时必须设置为 false）
        rootStack.translatesAutoresizingMaskIntoConstraints = false

        // clipsToBounds = true 防止子视图溢出到键盘区域之外
        view.clipsToBounds = true
        view.addSubview(rootStack)

        NSLayoutConstraint.activate([
            rootStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 4),
            rootStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -4),
            rootStack.topAnchor.constraint(equalTo: view.topAnchor, constant: 4),
            rootStack.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -2)
        ])

        Logger.shared.debug("setupRootStack: top+4, bottom-2, hMargin=4", category: .display)
    }

    /// 完整重建键盘：清除所有行 → 构建候选栏 → 构建按键行
    func reloadKeyboard() {
        isCandidateExpanded = false
        candidateExpandedPanel?.removeFromSuperview()
        candidateExpandedPanel = nil
        candidateCollectionView = nil
        expandedPanelScrollView = nil
        expandedCandidateCollectionView = nil
        rootStack.alpha = 1
        rootStack.isUserInteractionEnabled = true
        clearAllRows()
        candidateBar = makeCandidateBar()
        rootStack.addArrangedSubview(candidateBar)
        addKeyboardRows(for: controller.state)
        updateReturnKeyAppearance()
        Logger.shared.debug(
            "reloadKeyboard: candidateBar=\(candidateBar != nil ? "OK" : "nil"), " +
            "rows=\(rootStack.arrangedSubviews.count)",
            category: .display
        )
    }

    /// 仅重建键盘内容区，用于展开/收起候选面板时。
    ///
    /// 展开时：移除候选栏和所有按键行，面板填满整个键盘区域。
    /// 收起时：重建候选栏和按键行。
    func reloadKeyboardContent(with precomputedCandidates: [CandidateItem]? = nil) {
        // ── 清除所有视图（包括候选栏） ─────────────────────────────
        clearAllRows()

        if isCandidateExpanded {
            // 展开状态：只显示展开面板（填满整个内容区）
            let panel = makeExpandedCandidatePanel(with: precomputedCandidates)
            rootStack.addArrangedSubview(panel)
            candidateExpandedPanel = panel
        } else {
            // 收起状态：重建候选栏 + 按键行
            candidateBar = makeCandidateBar()
            rootStack.addArrangedSubview(candidateBar)
            addKeyboardRows(for: controller.state)
        }
    }

    // MARK: === 键盘行构建（私有，详见 +Layout.swift）===

    /// 根据键盘页面状态（字母/数字/符号）添加对应按键行
    private func addKeyboardRows(for state: KeyboardState) {
        // 清理上一次的字母按钮引用（Shift 状态刷新需要最新的引用列表）
        letterButtons.removeAll()
        candidateExpandedPanel = nil
        expandedPanelScrollView = nil

        switch state.currentPage {
        case .letters:
            // 字母页：3 行字母 + 1 行底部功能键
            rootStack.addArrangedSubview(makeLetterRow(["q", "w", "e", "r", "t", "y", "u", "i", "o", "p"]))
            // 第二行有水平内缩(horizontalInset=18)，模拟原生键盘的错位布局
            rootStack.addArrangedSubview(makeLetterRow(
                ["a", "s", "d", "f", "g", "h", "j", "k", "l"],
                horizontalInset: 18
            ))
            rootStack.addArrangedSubview(makeLetterThirdRow())
            rootStack.addArrangedSubview(makeBottomRow(pageSwitchTitle: pageSwitchTitle, includeDelete: false))

        case .numbers:
            // 数字页：3 行符号 + 1 行底部功能键
            rootStack.addArrangedSubview(makeTextRow(["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"]))
            if state.inputMode == .chinese {
                // 中文模式下显示中文标点符号
                rootStack.addArrangedSubview(makeTextRow(
                    ["-", "/", "：", "；", "（", "）", "¥", "\u{201C}", "\u{201D}", "\u{2018}"]
                ))
                rootStack.addArrangedSubview(makeTextRow(
                    ["。", "，", "、", "？", "！", "…", "·", "《", "》"]
                ))
            } else {
                // 英文模式下显示英文标点符号
                rootStack.addArrangedSubview(makeTextRow(
                    ["-", "/", ":", ";", "(", ")", "$", "&", "@", "\""]
                ))
                rootStack.addArrangedSubview(makeTextRow(
                    [".", ",", "?", "!", "'", "\"", "—", "…", "~"]
                ))
            }
            rootStack.addArrangedSubview(makeBottomRow(pageSwitchTitle: pageSwitchTitle, includeDelete: true))

        case .symbols:
            // 符号页：根据当前输入模式显示中文或英文符号
            if state.inputMode == .chinese {
                // 中文模式：中文括号、全角标点、数学符号
                rootStack.addArrangedSubview(makeTextRow(
                    ["【", "】", "「", "」", "『", "』", "《", "》", "［", "］"]
                ))
                rootStack.addArrangedSubview(makeTextRow(
                    ["～", "—", "…", "·", "￥", "$", "€", "£", "¥", "&"]
                ))
                rootStack.addArrangedSubview(makeTextRow(
                    ["#", "%", "^", "*", "+", "=", "｜", "\\", "/", "<"]
                ))
            } else {
                // 英文模式：ASCII 括号、数学符号、英文标点
                rootStack.addArrangedSubview(makeTextRow(
                    ["[", "]", "{", "}", "#", "%", "^", "*", "+", "="]
                ))
                rootStack.addArrangedSubview(makeTextRow(
                    ["_", "\\", "|", "~", "<", ">", "€", "£", "¥", "&"]
                ))
                rootStack.addArrangedSubview(makeTextRow(
                    ["·", "•", "…", "—", "–", "/", "'", "\"", "!", "?"]
                ))
            }
            rootStack.addArrangedSubview(makeBottomRow(pageSwitchTitle: pageSwitchTitle, includeDelete: true))
        case .emoji:
            // Emoji 页：分类标签 + emoji 网格
            rootStack.addArrangedSubview(makeEmojiPage())
            rootStack.addArrangedSubview(makeBottomRow(pageSwitchTitle: pageSwitchTitle, includeDelete: true))
        }
    }

    /// 从 rootStack 中清除所有子视图。
    /// 注意：removeArrangedSubview 只是从布局中移除，不会 removeFromSuperview。
    /// 必须同时调用两者才能彻底清除视图。
    private func clearAllRows() {
        for view in rootStack.arrangedSubviews {
            rootStack.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        expandedPanelScrollView = nil
        expandedCandidateCollectionView = nil
    }

    /// 移除除候选栏以外的所有子视图。
    /// 用于页面切换时保留候选栏，只重建按键区域。
    private func removeContentRows() {
        var foundBar = false
        for view in rootStack.arrangedSubviews {
            if view === candidateBar {
                foundBar = true
                continue
            }
            if foundBar {
                rootStack.removeArrangedSubview(view)
                view.removeFromSuperview()
            }
        }
    }

    // MARK: === 按键反馈（触感 + 音效）===

    /// 触觉反馈生成器 — 使用 UIImpactFeedbackGenerator 提供轻量级振动。
    /// Apple 建议在 viewDidLoad 中调用 prepare() 预热以减少首次触发的延迟。
    private let hapticGenerator = UIImpactFeedbackGenerator(style: .light)
    /// 按键点击音效播放器 — 使用 AVAudioPlayer + 动态生成的 WAV 文件。
    /// 不需要 Full Access（音效完全在扩展内生成和播放）。
    private let clickPlayer = KeyClickPlayer()
    /// App Group ID，用于在主 App 和键盘扩展间共享 UserDefaults。
    private static let appGroupID = "group.com.DoubleShy0N.Universe-Keyboard"

    /// 缓存的按键音量和触感强度（避免每次按键都读 UserDefaults）
    private var cachedKeyClickVolume: Float = 0.8
    private var cachedHapticIntensity: CGFloat = 0.5

    /// 播放按键点击音效（如果已在设置中启用）
    func playKeyClick() {
        guard cachedKeyClickEnabled else { return }
        clickPlayer.play(volume: cachedKeyClickVolume)
    }

    /// 触发触觉反馈（如果已在设置中启用）
    func playHaptic() {
        guard cachedHapticEnabled else { return }
        hapticGenerator.impactOccurred(intensity: cachedHapticIntensity)
        // 每次触发后重新预热，确保下次触发延迟最低
        hapticGenerator.prepare()
    }

    /// 从 App Group UserDefaults 刷新所有缓存设置值。
    /// Apple 最佳实践：键盘扩展进程与主 App 进程独立，
    /// 每次访问 UserDefaults(suiteName:) 都会产生 XPC 跨进程通信开销。
    /// 缓存这些值可以避免在每次按键（可能每秒 10 次以上）时产生 XPC 调用。
    private func refreshCachedSettings() {
        let defaults = UserDefaults(suiteName: Self.appGroupID)
        cachedKeyClickEnabled = defaults?.bool(forKey: "key_click_enabled") ?? true
        cachedHapticEnabled = defaults?.bool(forKey: "haptic_enabled") ?? false
        let volume = defaults?.double(forKey: "key_click_volume") ?? 0
        cachedKeyClickVolume = volume > 0 ? Float(volume) : 0.8
        let intensity = defaults?.double(forKey: "haptic_intensity") ?? 0
        cachedHapticIntensity = intensity > 0 ? CGFloat(intensity) : 0.5
    }

    /// 注册 UserDefaults 变化通知监听。
    /// 当主 App 修改设置时，键盘扩展缓存自动同步更新。
    private func observeSettingsChanges() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleSettingsChanged),
            name: UserDefaults.didChangeNotification,
            object: UserDefaults(suiteName: Self.appGroupID)
        )
    }

    @objc private func handleSettingsChanged() {
        refreshCachedSettings()
    }

    // MARK: === UI 同步 ===

    /// 根据 KeyboardEffect 集合更新 UI。
    /// KeyboardEffect 是一个 OptionSet，一次操作可能同时触发多种 UI 变化。
    /// 例如：按键插入 + 候选更新 = .compositionChanged
    ///       切换模式     = .inputModeChanged | .pageChanged | .shiftStateChanged
    func syncUI(with effects: KeyboardEffect) {
        let startTime = CACurrentMediaTime()
        defer {
            logKeyPerformance("syncUI \(effects)", startTime: startTime)
        }

        updateReturnKeyAppearance()

        // ── 大范围变化：页面、输入模式或键盘类型改变 → 重建整个键盘 ─
        if effects.contains(.pageChanged)
            || effects.contains(.inputModeChanged)
            || effects.contains(.keyboardTypeChanged) {
            if hasViewAppeared {
                reloadKeyboard()
            } else {
                // viewDidAppear 之前使用无动画重建，避免初始加载闪烁
                UIView.performWithoutAnimation {
                    reloadKeyboard()
                }
            }
            return
        }

        // ── 候选栏变化：拼音输入更新 → 刷新候选栏 ───────────────
        if effects.contains(.compositionChanged) {
            refreshCandidateBar()
        }

        // ── Shift 状态变化 → 刷新字母键大小写 + Shift 按钮外观 ──
        if effects.contains(.shiftStateChanged) {
            refreshLetterButtons()
            updateShiftButtonAppearance()
        }
    }

    /// 性能日志辅助方法：当 Logger 启用时，记录操作的耗时（毫秒）。
    func logKeyPerformance(_ message: String, startTime: CFTimeInterval) {
        guard Logger.shared.isEnabled else { return }
        let elapsed = (CACurrentMediaTime() - startTime) * 1000
        Logger.shared.performance("\(message) (\(String(format: "%.1f", elapsed))ms)")
    }
}
