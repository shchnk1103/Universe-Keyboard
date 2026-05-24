//
//  KeyboardViewController+CandidateBar.swift
//  Keyboard
//
//  候选栏的创建、刷新和数据源管理。
//
//  候选栏架构：
//    ┌──────────────────────────────────────────┐
//    │ [◀] [cand1] [cand2] ...  [scroll] [▶][▼]│ ← 翻页按钮 + 展开按钮
//    └──────────────────────────────────────────┘
//
//  展开后面板：
//    ┌──────────────────────────────────────────┐
//    │  [cand1]  [cand2]  [cand3]  [cand4]     │
//    │  [cand5]  [cand6]  [cand7]  [cand8]     │ ← 4 列网格，可纵向滚动
//    │  [cand9]  ...                            │
//    └──────────────────────────────────────────┘
//
//  UIScrollView 关键 API（Apple 文档）：
//  - contentLayoutGuide: 表示可滚动内容区域的 layout guide。
//    用于约束内容视图的尺寸 — 内容子视图应锚定到此 guide。
//  - frameLayoutGuide: 表示滚动视图自身 frame 的 layout guide。
//    用于约束内容视图的高度 = 滚动视图中可见部分的高度（保持单行）。
//  - contentInset: 内容区域的内边距（不会影响滚动指示器）。
//
//  渐隐遮罩原理：
//  使用 CAGradientLayer 作为 scrollView.layer.mask。
//  左侧和中间不透明（黑色在 mask 中 = 可见），右侧渐变为透明（清除 = 隐藏）。
//  0.82 → 1.0 的渐变段在右侧边缘产生平滑的淡出效果。
//

import UIKit
import KeyboardCore

// MARK: === UIScrollViewDelegate ===

extension KeyboardViewController: UIScrollViewDelegate {

    /// 候选栏滚动时的回调。
    /// 当前实现为空 — 保留以备将来需要跟踪滚动位置时使用。
    /// 例如：可以在滚动时暂停/恢复某些更新操作。
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // 预留：可在此追踪滚动位置或做懒加载
    }
}

// MARK: === 候选栏 ===

extension KeyboardViewController {

    // MARK: --- 候选栏容器 ---

    /// 构建候选栏容器视图。
    ///
    /// 布局结构：
    ///   container
    ///     ├── expandButton (固定在右侧，34pt 宽)
    ///     ├── separator (底部分隔线，0.5pt 高)
    ///     └── scrollView (填充剩余空间)
    ///           └── candidateStack (水平 UIStackView)
    ///
    /// UIScrollView + contentLayoutGuide 的正确用法（Apple 文档建议）：
    ///   - stack.leading/trailing → scrollView.contentLayoutGuide (内容区域)
    ///   - stack.top/bottom → scrollView.contentLayoutGuide
    ///   - stack.height → scrollView.frameLayoutGuide (与可见区域等高)
    ///   这样 stack 的高度固定为滚动视图的可见高度，宽度随内容增长，
    ///   实现水平单行滚动。
    func makeCandidateBar() -> UIView {
        let container = UIView()
        container.backgroundColor = keyboardBackgroundColor
        container.layer.cornerRadius = 0
        container.clipsToBounds = true

        // ── 翻页按钮 (◀ ◀) ──────────────────────────────────────
        let pageUpBtn = makePageButton(title: "◀", action: #selector(candidatePageUp))
        container.addSubview(pageUpBtn)
        candidatePageUpButton = pageUpBtn

        let pageDownBtn = makePageButton(title: "▶", action: #selector(candidatePageDown))
        container.addSubview(pageDownBtn)
        candidatePageDownButton = pageDownBtn

        // ── 展开按钮 ──────────────────────────────────────────────
        let expandBtn = makeExpandButton()
        container.addSubview(expandBtn)
        candidateExpandButton = expandBtn

        // ── 滚动视图 ──────────────────────────────────────────────
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.bounces = true
        scrollView.alwaysBounceHorizontal = true
        scrollView.decelerationRate = .fast
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.delegate = self
        candidateScrollView = scrollView

        // ── 水平候选词 Stack ─────────────────────────────────────
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 3
        stack.alignment = .center
        stack.distribution = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        candidateStack = stack

        scrollView.addSubview(stack)
        container.addSubview(scrollView)

        let expandWidth = expandBtn.widthAnchor.constraint(equalToConstant: 34)
        candidateExpandButtonWidthConstraint = expandWidth
        let pageBtnWidth: CGFloat = 24

        // ── Auto Layout 约束: [◀(24)][scrollView][▶(24)][▼(28)] ─
        NSLayoutConstraint.activate([
            pageUpBtn.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 2),
            pageUpBtn.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            pageUpBtn.widthAnchor.constraint(equalToConstant: pageBtnWidth),
            pageUpBtn.heightAnchor.constraint(equalToConstant: candidateBarHeight),

            pageDownBtn.trailingAnchor.constraint(equalTo: expandBtn.leadingAnchor, constant: -2),
            pageDownBtn.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            pageDownBtn.widthAnchor.constraint(equalToConstant: pageBtnWidth),
            pageDownBtn.heightAnchor.constraint(equalToConstant: candidateBarHeight),

            expandBtn.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -3),
            expandBtn.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            expandWidth,
            expandBtn.heightAnchor.constraint(equalToConstant: candidateBarHeight),

            scrollView.leadingAnchor.constraint(equalTo: pageUpBtn.trailingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: pageDownBtn.leadingAnchor),
            scrollView.topAnchor.constraint(equalTo: container.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: container.bottomAnchor),

            // Apple 文档推荐的 UIScrollView Auto Layout 模式：
            //   内容子视图锚定到 contentLayoutGuide（表示可滚动内容区域）
            //   高度锚定到 frameLayoutGuide（保持与可见区域等高，实现单行滚动）
            stack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            stack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            stack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            stack.heightAnchor.constraint(equalTo: scrollView.frameLayoutGuide.heightAnchor)
        ])

        container.heightAnchor.constraint(equalToConstant: candidateBarHeight).isActive = true

        // ── 底部分隔线 ────────────────────────────────────────────
        // 候选栏和第一行按键之间的视觉分隔
        let separator = UIView()
        separator.backgroundColor = UIColor.separator.withAlphaComponent(0.22)
        separator.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(separator)
        NSLayoutConstraint.activate([
            separator.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            separator.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            separator.heightAnchor.constraint(equalToConstant: 0.5)
        ])

        // 填充初始候选数据
        fillCandidateBar()

        // 添加右侧渐隐遮罩
        addFadeMask(to: scrollView)

        return container
    }

    // MARK: --- 翻页按钮 ---

    /// 创建候选栏翻页按钮（◀ 或 ◀）。
    /// 只有有候选词时才显示，置于滚动视图两侧。
    private func makePageButton(title: String, action: Selector) -> UIButton {
        var config = UIButton.Configuration.plain()
        config.contentInsets = .zero
        config.title = title
        config.baseForegroundColor = .secondaryLabel

        let button = UIButton(configuration: config, primaryAction: nil)
        button.titleLabel?.font = .systemFont(ofSize: 12, weight: .medium)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: action, for: .touchUpInside)
        // 默认隐藏，有候选时在 fillCandidateBar 中显示
        button.isHidden = true
        return button
    }

    // MARK: --- 展开按钮 ---

    private func makeExpandButton() -> UIButton {
        var config = UIButton.Configuration.plain()
        config.contentInsets = .zero  // 移除默认内边距，让图标精确居中
        config.image = UIImage(
            systemName: "chevron.down",
            withConfiguration: UIImage.SymbolConfiguration(pointSize: 12, weight: .medium)
        )
        config.baseForegroundColor = .secondaryLabel

        let button = UIButton(configuration: config, primaryAction: nil)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(toggleCandidateExpand), for: .touchUpInside)
        return button
    }

    /// 切换候选面板展开/收起。
    ///
    /// 视觉效果：
    ///   - 展开按钮旋转 180°（chevron.down → chevron.up）
    ///   - 颜色从 secondaryLabel → tintColor（强调"已激活"状态）
    ///   - 键盘内容区以交叉溶解过渡到展开面板/恢复按键行
    @objc func toggleCandidateExpand() {
        isCandidateExpanded.toggle()

        if let btn = candidateExpandButton {
            // 图标旋转动画（0.25s，弹性曲线），尊重 Reduce Motion
            if !UIAccessibility.isReduceMotionEnabled {
                UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut) {
                    btn.imageView?.transform = self.isCandidateExpanded
                        ? CGAffineTransform(rotationAngle: .pi)
                        : .identity
                }
            } else {
                btn.imageView?.transform = self.isCandidateExpanded
                    ? CGAffineTransform(rotationAngle: .pi)
                    : .identity
            }
            // 同步更新颜色
            var config = btn.configuration
            config?.baseForegroundColor = isCandidateExpanded ? view.tintColor : .secondaryLabel
            btn.configuration = config
        }

        // 以交叉溶解过渡重建键盘内容区（展开面板 ↔ 按键行）
        UIView.transition(
            with: rootStack,
            duration: 0.2,
            options: .transitionCrossDissolve
        ) {
            self.reloadKeyboardContent()
        }
    }

    // MARK: --- 展开面板 ---

    /// 构建展开的候选面板（4 列网格，可纵向滚动）。
    ///
    /// 面板高度严格限制为 keyHeight * 4 + keySpacing * 3 = 194pt，
    /// 匹配正常 4 行按键区域的高度。防止键盘突然升高到半屏。
    /// 超出 4 行的候选从纵向滚动。
    ///
    /// 候选类型区分：
    ///   - .candidate 用 .label 颜色 + 16pt 字体
    ///   - .composition 用 .secondaryLabel 颜色 + 14pt 字体（表示拼音正输入中）
    ///   - 第一个真正的候选词（.candidate）加粗 + 高亮背景
    func makeExpandedCandidatePanel(with precomputedItems: [CandidateItem]? = nil) -> UIView {
        let container = UIView()
        container.backgroundColor = keyboardBackgroundColor
        container.layer.cornerRadius = keyCornerRadius
        container.clipsToBounds = true

        // 面板高度 = 正常 4 行按键区域高度
        let keyRowsHeight = keyHeight * 4 + keySpacing * 3

        let items = precomputedItems ?? candidateItems()
        let candidates = items.filter { $0.kind != .placeholder }

        guard !candidates.isEmpty else {
            // 空状态：居中显示提示文字
            let label = UILabel()
            label.text = "暂无候选"
            label.font = .systemFont(ofSize: 14)
            label.textColor = .secondaryLabel
            label.textAlignment = .center
            label.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview(label)
            NSLayoutConstraint.activate([
                label.centerXAnchor.constraint(equalTo: container.centerXAnchor),
                label.centerYAnchor.constraint(equalTo: container.centerYAnchor),
                container.heightAnchor.constraint(equalToConstant: keyRowsHeight)
            ])
            return container
        }

        let columns = 4
        let rows = (candidates.count + columns - 1) / columns
        let rowHeight: CGFloat = 44

        // 纵向滚动视图 — 候选词超出 4 行时使用
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.bounces = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        let verticalStack = UIStackView()
        verticalStack.axis = .vertical
        verticalStack.spacing = 4
        verticalStack.distribution = .fill
        verticalStack.translatesAutoresizingMaskIntoConstraints = false

        // 追踪是否已找到第一个真正的候选词（用于加粗 + 高亮）
        var firstCandidateFound = false

        for rowIndex in 0..<rows {
            let rowStack = UIStackView()
            rowStack.axis = .horizontal
            rowStack.spacing = 4
            rowStack.distribution = .fillEqually

            for colIndex in 0..<columns {
                let itemIndex = rowIndex * columns + colIndex
                if itemIndex < candidates.count {
                    let item = candidates[itemIndex]

                    let isFirstCandidate: Bool = {
                        if firstCandidateFound { return false }
                        if item.kind == .candidate {
                            firstCandidateFound = true
                            return true
                        }
                        return false
                    }()

                    let color: UIColor = item.kind == .composition
                        ? .secondaryLabel
                        : .label

                    let button = CandidateButtonFactory.makeCandidateButton(
                        title: item.title,
                        kind: item.kind,
                        color: color,
                        bold: isFirstCandidate,
                        height: rowHeight,
                        highlighted: isFirstCandidate
                    )
                    // tag 存储 CandidateKind.rawValue，用于 insertCandidateFromPanel 识别
                    button.tag = item.kind.rawValue
                    button.addTarget(
                        self,
                        action: #selector(insertCandidateFromPanel(_:)),
                        for: .touchUpInside
                    )
                    rowStack.addArrangedSubview(button)
                } else {
                    // 填充空位，保持网格对齐
                    let spacer = UIView()
                    rowStack.addArrangedSubview(spacer)
                }
            }

            verticalStack.addArrangedSubview(rowStack)
        }

        scrollView.addSubview(verticalStack)
        container.addSubview(scrollView)

        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: container.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: container.bottomAnchor),

            // 垂直栈锚定到 scrollView 的 contentLayoutGuide
            verticalStack.leadingAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.leadingAnchor,
                constant: 8
            ),
            verticalStack.trailingAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.trailingAnchor,
                constant: -8
            ),
            verticalStack.topAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.topAnchor,
                constant: 6
            ),
            verticalStack.bottomAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.bottomAnchor,
                constant: -6
            ),
            // 宽度锚定到 frameLayoutGuide（让垂直栈宽度 = 滚动视图可见宽度，减去 padding）
            verticalStack.widthAnchor.constraint(
                equalTo: scrollView.frameLayoutGuide.widthAnchor,
                constant: -16
            ),

            container.heightAnchor.constraint(equalToConstant: keyRowsHeight)
        ])

        return container
    }

    /// 展开面板中候选按钮的点击处理。
    /// 与普通候选栏的 insertCandidate 不同，选择后会自动关闭展开面板。
    @objc func insertCandidateFromPanel(_ sender: UIButton) {
        guard let candidate = sender.configuration?.title,
              let kind = CandidateKind(rawValue: sender.tag) else { return }
        playKeyClick()
        playHaptic()
        let effects = controller.handle(.insertCandidate(candidate, kind: kind))
        syncUI(with: effects)

        // 选择后自动关闭展开面板
        isCandidateExpanded = false
        UIView.transition(
            with: rootStack,
            duration: 0.2,
            options: .transitionCrossDissolve
        ) {
            self.reloadKeyboardContent()
        }
    }

    // MARK: --- 右侧渐隐遮罩 ---

    /// 为滚动视图添加右侧渐隐效果。
    ///
    /// 使用 CAGradientLayer 作为 view.layer.mask：
    /// 在灰度颜色空间中，mask 中黑色的部分 → 显示，白色 → 隐藏。
    /// 但此处使用的是 RGBA 颜色空间：
    ///   - blackColor (R=0,G=0,B=0,A=1)：完全不透明 → 内容完全可见
    ///   - clearColor (A=0)：完全透明 → 内容被隐藏（在此 mask 中是显示，因为 mask 用 alpha 控制可见性）
    ///
    /// 实际上 layer.mask 使用 alpha 通道：alpha=1 处可见，alpha=0 处隐藏。
    /// 所以：
    ///   locations [0, 0.82, 1]：
    ///     0% → 82% 完全可见（alpha=1）
    ///     82% → 100% 逐渐隐藏（alpha 从 1 过渡到 0）
    ///
    /// 需要与 viewDidLayoutSubviews 配合，在每次 layout 时更新 gradient.frame。
    private func addFadeMask(to view: UIView) {
        let gradient = CAGradientLayer()
        gradient.colors = [
            UIColor.black.cgColor,   // 位置 0-82%：完全可见
            UIColor.black.cgColor,   // （保持可见）
            UIColor.clear.cgColor    // 位置 82-100%：渐隐
        ]
        gradient.locations = [0, 0.82, 1]
        gradient.startPoint = CGPoint(x: 0, y: 0.5)    // 水平渐变（左 → 右）
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        gradient.frame = view.bounds
        view.layer.mask = gradient
        candidateFadeGradient = gradient
    }

    // MARK: --- 刷新 ---

    /// 刷新候选栏内容。
    ///
    /// 刷新流程：
    ///   1. 从 CandidateBarDataSource 获取最新候选列表
    ///   2. 重建候选按钮（fillCandidateBar）
    ///   3. 滚动回最左侧（因为候选列表可能完全换了）
    ///   4. 如果展开面板处于打开状态，同步更新面板内容
    func refreshCandidateBar() {
        guard candidateStack != nil else { return }

        let allItems = candidateItems()
        Logger.shared.debug(
            "refreshCandidateBar: items=\(allItems.count), expanded=\(isCandidateExpanded)",
            category: .display
        )
        fillCandidateBar(precomputedItems: allItems)

        // 新候选列表出现时，滚动回最左侧
        if candidateScrollView.contentOffset.x != 0 {
            candidateScrollView.setContentOffset(.zero, animated: false)
        }

        // 展开状态下同步更新面板
        if isCandidateExpanded {
            UIView.transition(
                with: rootStack,
                duration: 0.15,
                options: .transitionCrossDissolve
            ) {
                self.reloadKeyboardContent(with: allItems)
            }
        }
    }

    /// 填充候选栏按钮。
    ///
    /// 设计决策：每次刷新时完全清除旧按钮后重建，而非复用。
    /// 理由：
    ///   1. 创建 20 个 UIButton < 0.5ms，而 RIME 处理耗时 2-5ms
    ///      — 按钮创建的额外开销可忽略不计（不到总延迟的 20%）
    ///   2. 复用逻辑的边界错误难以追踪（曾导致 Bold 状态不一致、
    ///      associatedObject 桥接失败等难以调试的问题）
    ///   3. 清除+重建保证了 UI 始终与数据源完全一致
    func fillCandidateBar(precomputedItems: [CandidateItem]? = nil) {
        guard let stack = candidateStack else {
            Logger.shared.warning("fillCandidateBar: candidateStack is nil", category: .general)
            return
        }

        let allItems = precomputedItems ?? candidateItems()
        let items = allItems.filter { $0.kind != .placeholder }

        // ── 控制翻页和展开按钮可见性 ───────────────────────────────
        // 有候选词时显示翻页和展开按钮，无候选词时隐藏
        let hasCandidates = items.contains { $0.kind == .candidate }
        candidateExpandButton?.isHidden = !hasCandidates
        candidatePageUpButton?.isHidden = !hasCandidates
        candidatePageDownButton?.isHidden = !hasCandidates

        // 检查 RIME 返回的 hasMorePages 标志 — 末页时禁用下一页按钮
        if let lastOutput = controller.state.lastRimeOutput {
            candidatePageDownButton?.isEnabled = lastOutput.hasMorePages
            // 上一页按钮始终启用（只要不是第一页），RIME 会自行处理
        }

        let targetWidth: CGFloat = hasCandidates ? 34 : 0
        if candidateExpandButtonWidthConstraint?.constant != targetWidth {
            candidateExpandButtonWidthConstraint?.constant = targetWidth
        }

        // ── 清除所有旧按钮 ───────────────────────────────────────
        let oldCount = stack.arrangedSubviews.count
        for subview in stack.arrangedSubviews.reversed() {
            stack.removeArrangedSubview(subview)
            subview.removeFromSuperview()
        }

        guard !items.isEmpty else {
            Logger.shared.debug(
                "fillCandidateBar: cleared \(oldCount) old views, 0 new items",
                category: .display
            )
            return
        }

        // ── 创建新按钮 ───────────────────────────────────────────
        var firstCandidateFound = false

        for item in items {
            // 第一个真正的候选词（.candidate）加粗 + 高亮背景
            let isFirstCandidate: Bool = {
                if firstCandidateFound { return false }
                if item.kind == .candidate {
                    firstCandidateFound = true
                    return true
                }
                return false
            }()

            let color: UIColor = item.kind == .composition
                ? .secondaryLabel   // 拼音组合用次要标签色
                : .label            // 候选词用主标签色

            let button = CandidateButtonFactory.makeCandidateButton(
                title: item.title,
                kind: item.kind,
                color: color,
                bold: isFirstCandidate,
                height: candidateBarHeight,
                highlighted: isFirstCandidate
            )
            button.addTarget(self, action: #selector(insertCandidate(_:)), for: .touchUpInside)
            stack.addArrangedSubview(button)
        }

        Logger.shared.debug(
            "fillCandidateBar: cleared \(oldCount) old views, " +
            "added \(items.count) new buttons, kinds=\(items.map { $0.kind.rawValue })",
            category: .display
        )
    }

    // MARK: --- 候选数据 ---

    /// 从 CandidateBarDataSource 获取当前候选词列表。
    /// 封装为方法，方便在不同位置（普通栏和展开面板）以相同方式获取。
    func candidateItems() -> [CandidateItem] {
        CandidateBarDataSource.candidateItems(from: controller)
    }
}
