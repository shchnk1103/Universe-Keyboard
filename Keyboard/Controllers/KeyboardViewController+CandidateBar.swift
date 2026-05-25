//
//  KeyboardViewController+CandidateBar.swift
//  Keyboard
//
//  候选栏的创建、刷新和数据源管理。
//
//  候选栏架构：
//    ┌──────────────────────────────────────────┐
//    │ [cand1] [cand2] ... [scroll right]  [▼] │ ← 左右无极滑动 + 展开按钮
//    └──────────────────────────────────────────┘
//
//  翻页：预加载 2 页候选（~18 个），向右滚动近末尾时自动追加后续页。
//
//  展开后面板（流式布局，填满整个键盘区域）：
//    ┌─────────────────────────────────[▲]─────┐
//    │  [你好] [你好吗] [你] [你们] [你好啊]    │ ← 宽度自适应 + 自动换行
//    │  [你好世界] [你好呀] [你的] ...          │
//    │  ...                          (scroll ↓) │
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

    /// 统一的滚动检测 — 同时处理候选栏（横向）和展开面板（纵向）的无限滚动。
    ///
    /// 候选栏：接近右边缘 60pt 时自动加载下一页候选。
    /// 展开面板：接近底部 60pt 时自动加载下一页候选。
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView === candidateScrollView {
            handleCandidateBarScroll(scrollView)
        } else if scrollView === expandedPanelScrollView {
            handleExpandedPanelScroll(scrollView)
        }
    }

    /// 候选栏拖拽结束时的额外检测：overscroll 超过 40pt 时也触发加载。
    /// 这是 handleCandidateBarScroll 的补充 — 当内容未溢出时作为备选触发方式。
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard scrollView === candidateScrollView else { return }
        guard hasMoreCandidates, !isLoadingMoreCandidates, !accumulatedCandidates.isEmpty else {
            Logger.shared.debug(
                "candidateBar dragEnd skip: hasMore=\(hasMoreCandidates), " +
                "loading=\(isLoadingMoreCandidates), accCount=\(accumulatedCandidates.count)",
                category: .display
            )
            return
        }

        let contentWidth = scrollView.contentSize.width
        let viewWidth = scrollView.bounds.width
        let maxOffset = max(0, contentWidth - viewWidth)
        let rightOverscroll = scrollView.contentOffset.x - maxOffset

        Logger.shared.debug(
            "candidateBar dragEnd: overscroll=\(Int(rightOverscroll))pt, " +
            "contentW=\(Int(contentWidth)), viewW=\(Int(viewWidth)), maxOffset=\(Int(maxOffset))",
            category: .display
        )

        if rightOverscroll > 40 {
            Logger.shared.info("candidateBar overscroll trigger: \(Int(rightOverscroll))pt", category: .display)
            loadMoreCandidates()
        }
    }

    // MARK: - 私有滚动处理

    /// 候选栏横向滚动：接近右边缘时自动加载更多。
    private func handleCandidateBarScroll(_ scrollView: UIScrollView) {
        guard hasMoreCandidates else {
            // hasMoreCandidates false 时不应触发，但若用户仍在滑动说明状态异常
            return
        }
        guard !isLoadingMoreCandidates else { return }
        guard !accumulatedCandidates.isEmpty else { return }

        let contentWidth = scrollView.contentSize.width
        let viewWidth = scrollView.bounds.width
        guard contentWidth > viewWidth else {
            // 内容未溢出：scrollViewDidEndDragging 的 overscroll 可作为备选触发
            return
        }

        let distanceToRightEdge = contentWidth - (scrollView.contentOffset.x + viewWidth)
        if distanceToRightEdge < 80 {
            Logger.shared.info(
                "candidateBar near right edge: distance=\(Int(distanceToRightEdge))pt, " +
                "contentW=\(Int(contentWidth)), viewW=\(Int(viewWidth)), " +
                "hasMore=\(hasMoreCandidates), total=\(accumulatedCandidates.count)",
                category: .display
            )
            loadMoreCandidates()
        }
    }

    /// 展开面板纵向滚动：接近底部时自动加载更多。
    private func handleExpandedPanelScroll(_ scrollView: UIScrollView) {
        guard hasMoreCandidates, !isLoadingMoreCandidates, !accumulatedCandidates.isEmpty else { return }

        let contentHeight = scrollView.contentSize.height
        let viewHeight = scrollView.bounds.height
        guard contentHeight > viewHeight else { return }

        let distanceToBottom = contentHeight - (scrollView.contentOffset.y + viewHeight)
        if distanceToBottom < 80 {
            loadMoreCandidates()
        }
    }

    /// 向 RIME 请求下一页候选并追加到累积列表。
    /// 使用直接 engine 调用避免污染 state.lastRimeOutput，加载后回到第 1 页
    /// 确保空格/候选选择始终对应当前最佳候选。
    func loadMoreCandidates() {
        guard let engine = controller.rimeEngine else { return }

        Logger.shared.info(
            "loadMoreCandidates START: accCount=\(accumulatedCandidates.count), depth=\(candidatePageDepth), expanded=\(isCandidateExpanded)",
            category: .display
        )
        isLoadingMoreCandidates = true

        // 前进到当前最深页
        for i in 0..<candidatePageDepth {
            _ = engine.pageDown()
        }
        // 获取下一页
        let nextPage = engine.pageDown()
        let nextItems = nextPage.candidates.map { CandidateItem(title: $0.text, kind: .candidate) }
        let newHasMore = nextPage.hasMorePages

        // 回到第 1 页，保持与 state.lastRimeOutput 一致
        for i in 0..<(candidatePageDepth + 1) {
            _ = engine.pageUp()
        }

        Logger.shared.info(
            "loadMoreCandidates RIME: rawNewItems=\(nextItems.count), hasMorePages=\(newHasMore)",
            category: .display
        )

        // 去重追加
        var newAppended: [CandidateItem] = []
        var dupCount = 0
        for item in nextItems {
            if !accumulatedCandidates.contains(where: { $0.title == item.title }) {
                accumulatedCandidates.append(item)
                newAppended.append(item)
            } else {
                dupCount += 1
            }
        }

        hasMoreCandidates = newHasMore
        candidatePageDepth += 1
        isLoadingMoreCandidates = false

        if !newAppended.isEmpty {
            if isCandidateExpanded {
                refreshExpandedPanel()
            } else {
                appendToCandidateBar(newItems: newAppended)
            }
        }

        Logger.shared.info(
            "loadMoreCandidates DONE: +\(newAppended.count) new, \(dupCount) dup, " +
            "total=\(accumulatedCandidates.count), depth=\(candidatePageDepth), hasMore=\(hasMoreCandidates)",
            category: .display
        )
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
        stack.spacing = 4
        stack.alignment = .center
        stack.distribution = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        candidateStack = stack

        scrollView.addSubview(stack)
        container.addSubview(scrollView)

        let expandWidth = expandBtn.widthAnchor.constraint(equalToConstant: 44)
        candidateExpandButtonWidthConstraint = expandWidth

        // ── Auto Layout: [scrollView 填充空间] [▼(44)] ─
        NSLayoutConstraint.activate([
            expandBtn.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -3),
            expandBtn.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            expandWidth,
            expandBtn.heightAnchor.constraint(equalToConstant: candidateBarHeight),

            scrollView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 2),
            scrollView.trailingAnchor.constraint(equalTo: expandBtn.leadingAnchor, constant: -2),
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
        button.accessibilityLabel = "展开更多候选词"
        button.accessibilityHint = "双击以查看完整候选列表"
        return button
    }

    /// 切换候选面板展开/收起。
    ///
    /// 视觉效果：
    ///   - 展开按钮旋转 180°（chevron.down ↔ chevron.up），spring 动画匹配 Liquid Glass
    ///   - 颜色从 secondaryLabel → tintColor（强调"已激活"状态）
    ///   - 键盘内容区以交叉溶解过渡到展开面板/恢复按键行
    @objc func toggleCandidateExpand() {
        isCandidateExpanded.toggle()

        if let btn = candidateExpandButton {
            if !UIAccessibility.isReduceMotionEnabled {
                UIView.animate(
                    withDuration: 0.4,
                    delay: 0,
                    usingSpringWithDamping: 0.75,
                    initialSpringVelocity: 0.5,
                    options: []
                ) {
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

    /// 构建展开的候选面板（流式布局，自适应宽度和列数）。
    ///
    /// 特性：
    ///   - 流式布局：按钮宽度 = 文字宽度 + 内边距，溢出换行
    ///   - 每行末尾添加 spacer 吸收剩余空间，防止单独按钮被 .fill 分布拉伸
    ///   - 面板填满整个键盘内容区（236pt）
    ///   - 右上角收起按钮（chevron.up），首行右侧留空，z-order 在最上
    ///   - 纵向无限滚动
    func makeExpandedCandidatePanel(with precomputedItems: [CandidateItem]? = nil) -> UIView {
        let container = UIView()
        container.backgroundColor = keyboardBackgroundColor
        container.clipsToBounds = true

        let items = precomputedItems ?? candidateItems()
        let candidates = items.filter { $0.kind != .placeholder }

        let fullContentHeight = candidateBarHeight + keyHeight * 4 + keySpacing * 4

        guard !candidates.isEmpty else {
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
                container.heightAnchor.constraint(equalToConstant: fullContentHeight)
            ])
            return container
        }

        let collapseBtnSize: CGFloat = 44

        // ── 纵向滚动视图 ────────────────────────────────────────
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.bounces = true
        scrollView.delegate = self
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        expandedPanelScrollView = scrollView

        let verticalStack = UIStackView()
        verticalStack.axis = .vertical
        verticalStack.spacing = 4
        verticalStack.distribution = .fill
        verticalStack.alignment = .leading
        verticalStack.translatesAutoresizingMaskIntoConstraints = false

        // ── 流式布局 ──────────────────────────────────────────
        let totalAvailableWidth = view.bounds.width - 12 - 16
        let rowSpacing: CGFloat = 4

        var currentRowStack: UIStackView?
        var currentRowWidth: CGFloat = 0
        var firstCandidateFound = false
        var rowIndex = 0
        var totalRows = 0

        /// 结束当前行：添加 trailing spacer 吸收剩余宽度，防止按钮被拉伸
        func finishRow() {
            guard let row = currentRowStack else { return }
            let spacer = UIView()
            spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
            spacer.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
            row.addArrangedSubview(spacer)
            totalRows += 1
        }

        for item in candidates {
            let isFirstCandidate: Bool = {
                if firstCandidateFound { return false }
                if item.kind == .candidate {
                    firstCandidateFound = true
                    return true
                }
                return false
            }()

            let color: UIColor = item.kind == .composition ? .secondaryLabel : .label
            let button = CandidateButtonFactory.makeCandidateButton(
                title: item.title,
                kind: item.kind,
                color: color,
                bold: isFirstCandidate,
                height: 38,
                highlighted: isFirstCandidate
            )
            button.tag = item.kind.rawValue
            button.addTarget(self, action: #selector(insertCandidateFromPanel(_:)), for: .touchUpInside)
            button.accessibilityLabel = item.kind == .composition
                ? "提交拼音 \(item.title)" : item.title
            button.accessibilityHint = item.kind == .composition
                ? "双击以提交原始拼音" : "双击选择候选词并关闭面板"

            let buttonWidth = button.systemLayoutSizeFitting(
                CGSize(width: totalAvailableWidth, height: 38),
                withHorizontalFittingPriority: .defaultLow,
                verticalFittingPriority: .required
            ).width

            // 首行右侧留空给收起按钮
            let rowAvailableWidth: CGFloat = (rowIndex == 0)
                ? totalAvailableWidth - collapseBtnSize - 6
                : totalAvailableWidth

            let widthWithSpacing = buttonWidth + (currentRowStack != nil ? rowSpacing : 0)

            if currentRowStack != nil, currentRowWidth + widthWithSpacing > rowAvailableWidth {
                finishRow()
                currentRowStack = nil
                currentRowWidth = 0
                rowIndex += 1
            }

            if currentRowStack == nil {
                currentRowStack = UIStackView()
                currentRowStack!.axis = .horizontal
                currentRowStack!.spacing = rowSpacing
                currentRowStack!.distribution = .fill
                currentRowStack!.alignment = .center
                verticalStack.addArrangedSubview(currentRowStack!)
            }

            currentRowStack!.addArrangedSubview(button)
            currentRowWidth += widthWithSpacing
        }
        finishRow()  // 结束最后一行

        scrollView.addSubview(verticalStack)
        container.addSubview(scrollView)

        // ── 收起按钮（浮动在右上角，scrollView 之后添加以保持最上层） ──
        var collapseConfig = UIButton.Configuration.plain()
        collapseConfig.contentInsets = .zero
        collapseConfig.image = UIImage(
            systemName: "chevron.up",
            withConfiguration: UIImage.SymbolConfiguration(pointSize: 12, weight: .medium)
        )
        collapseConfig.baseForegroundColor = view.tintColor
        let collapseBtn = UIButton(configuration: collapseConfig, primaryAction: nil)
        collapseBtn.translatesAutoresizingMaskIntoConstraints = false
        collapseBtn.addTarget(self, action: #selector(toggleCandidateExpand), for: .touchUpInside)
        collapseBtn.accessibilityLabel = "收起候选面板"
        collapseBtn.accessibilityHint = "双击以返回键盘"
        container.addSubview(collapseBtn)  // 最后添加 = 最上层

        NSLayoutConstraint.activate([
            collapseBtn.topAnchor.constraint(equalTo: container.topAnchor, constant: 2),
            collapseBtn.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -4),
            collapseBtn.widthAnchor.constraint(equalToConstant: collapseBtnSize),
            collapseBtn.heightAnchor.constraint(equalToConstant: collapseBtnSize),

            scrollView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: container.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: container.bottomAnchor),

            verticalStack.leadingAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 8),
            verticalStack.trailingAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -8),
            verticalStack.topAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 6),
            verticalStack.bottomAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -6),
            verticalStack.widthAnchor.constraint(
                equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -16),

            container.heightAnchor.constraint(equalToConstant: fullContentHeight)
        ])

        Logger.shared.info(
            "expandedPanel: \(candidates.count) candidates → \(totalRows) rows, availW=\(Int(totalAvailableWidth))",
            category: .display
        )

        return container
    }

    /// 增量刷新展开面板 — 清除并重建流式布局（保留滚动位置）。
    func refreshExpandedPanel() {
        guard let scrollView = expandedPanelScrollView,
              let verticalStack = scrollView.subviews.first as? UIStackView,
              isCandidateExpanded else { return }

        let currentOffset = scrollView.contentOffset.y
        let candidates = accumulatedCandidates.filter { $0.kind != .placeholder }

        // 清除垂直栈中所有现有行
        for row in verticalStack.arrangedSubviews.reversed() {
            verticalStack.removeArrangedSubview(row)
            row.removeFromSuperview()
        }

        // 重建流式布局
        let totalAvailableWidth = view.bounds.width - 12 - 16
        let rowSpacing: CGFloat = 4
        let collapseBtnSize: CGFloat = 44

        var currentRowStack: UIStackView?
        var currentRowWidth: CGFloat = 0
        var firstCandidateFound = false
        var rowIndex = 0
        var totalRows = 0

        func finishRow() {
            guard let row = currentRowStack else { return }
            let spacer = UIView()
            spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
            spacer.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
            row.addArrangedSubview(spacer)
            totalRows += 1
        }

        for item in candidates {
            let isFirstCandidate: Bool = {
                if firstCandidateFound { return false }
                if item.kind == .candidate {
                    firstCandidateFound = true
                    return true
                }
                return false
            }()

            let color: UIColor = item.kind == .composition ? .secondaryLabel : .label
            let button = CandidateButtonFactory.makeCandidateButton(
                title: item.title,
                kind: item.kind,
                color: color,
                bold: isFirstCandidate,
                height: 38,
                highlighted: isFirstCandidate
            )
            button.tag = item.kind.rawValue
            button.addTarget(self, action: #selector(insertCandidateFromPanel(_:)), for: .touchUpInside)
            button.accessibilityLabel = item.kind == .composition
                ? "提交拼音 \(item.title)" : item.title
            button.accessibilityHint = item.kind == .composition
                ? "双击以提交原始拼音" : "双击选择候选词并关闭面板"

            let buttonWidth = button.systemLayoutSizeFitting(
                CGSize(width: totalAvailableWidth, height: 38),
                withHorizontalFittingPriority: .defaultLow,
                verticalFittingPriority: .required
            ).width

            let rowAvailableWidth: CGFloat = (rowIndex == 0)
                ? totalAvailableWidth - collapseBtnSize - 6
                : totalAvailableWidth

            let widthWithSpacing = buttonWidth + (currentRowStack != nil ? rowSpacing : 0)

            if currentRowStack != nil, currentRowWidth + widthWithSpacing > rowAvailableWidth {
                finishRow()
                currentRowStack = nil
                currentRowWidth = 0
                rowIndex += 1
            }

            if currentRowStack == nil {
                currentRowStack = UIStackView()
                currentRowStack!.axis = .horizontal
                currentRowStack!.spacing = rowSpacing
                currentRowStack!.distribution = .fill
                currentRowStack!.alignment = .center
                verticalStack.addArrangedSubview(currentRowStack!)
            }

            currentRowStack!.addArrangedSubview(button)
            currentRowWidth += widthWithSpacing
        }
        finishRow()

        // 布局后恢复滚动位置
        verticalStack.layoutIfNeeded()
        if currentOffset > 0 {
            let maxOffset = max(0, scrollView.contentSize.height - scrollView.bounds.height)
            scrollView.contentOffset.y = min(currentOffset, maxOffset)
        }

        Logger.shared.info(
            "expandedPanel refresh: \(candidates.count) candidates → \(totalRows) rows",
            category: .display
        )
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
    /// 使用 CAGradientLayer 作为 view.layer.mask。
    /// 渐变范围设为 92%→100%，仅在最右边缘轻柔渐隐，
    /// 避免最后一个候选词颜色明显变淡。
    ///
    /// 需要与 viewDidLayoutSubviews 配合，在每次 layout 时更新 gradient.frame。
    private func addFadeMask(to view: UIView) {
        let gradient = CAGradientLayer()
        gradient.colors = [
            UIColor.black.cgColor,
            UIColor.black.cgColor,
            UIColor.clear.cgColor
        ]
        gradient.locations = [0, 0.92, 1]
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        gradient.frame = view.bounds
        view.layer.mask = gradient
        candidateFadeGradient = gradient
    }

    // MARK: --- 刷新 ---

    /// 刷新候选栏内容。
    ///
    /// 每次新的拼音输入时：
    ///   1. 从 RIME 获取第一页候选
    ///   2. 如果有更多页，立即预加载第二页（让初始滚动更平滑，首次即有 ~18 个候选）
    ///   3. 用户向右滚动接近末尾时自动加载后续页
    func refreshCandidateBar() {
        guard candidateStack != nil else { return }

        // 重置累积列表，从当前 RIME 第一页开始
        accumulatedCandidates = CandidateBarDataSource.candidateItems(from: controller)
        hasMoreCandidates = controller.state.lastRimeOutput?.hasMorePages ?? false
        isLoadingMoreCandidates = false
        candidatePageDepth = 0
        let preedit = controller.state.lastRimeOutput?.composition?.preeditText ?? "nil"

        Logger.shared.info(
            "refreshCandidateBar: page1=\(accumulatedCandidates.count), hasMore=\(hasMoreCandidates), preedit=\(preedit)",
            category: .display
        )

        // ── 预加载第二页（直接用 engine，不污染 state.lastRimeOutput） ──
        if hasMoreCandidates, let engine = controller.rimeEngine {
            let page2 = engine.pageDown()
            let page2Candidates = page2.candidates.map { CandidateItem(title: $0.text, kind: .candidate) }
            var page2Added = 0
            for item in page2Candidates {
                if !accumulatedCandidates.contains(where: { $0.title == item.title }) {
                    accumulatedCandidates.append(item)
                    page2Added += 1
                }
            }
            hasMoreCandidates = page2.hasMorePages
            candidatePageDepth = 1  // 已加载第 2 页
            // 回到第一页，保持 RIME 内部状态与 lastRimeOutput 一致
            _ = engine.pageUp()
            Logger.shared.info(
                "refreshCandidateBar preload page2: +\(page2Added) items, total=\(accumulatedCandidates.count), hasMore=\(hasMoreCandidates)",
                category: .display
            )
        }

        fillCandidateBar()

        // 滚动回最左侧
        if candidateScrollView.contentOffset.x != 0 {
            candidateScrollView.setContentOffset(.zero, animated: false)
        }

        if isCandidateExpanded {
            refreshExpandedPanel()
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
    ///
    /// - Parameter keepScrollPosition: true 时保留当前滚动位置（用于加载更多候选后追加）
    func fillCandidateBar(keepScrollPosition: Bool = false) {
        guard let stack = candidateStack else {
            Logger.shared.warning("fillCandidateBar: candidateStack is nil", category: .general)
            return
        }

        let items = accumulatedCandidates.filter { $0.kind != .placeholder }

        // ── 控制展开按钮可见性 ─────────────────────────────────────
        let hasCandidates = items.contains { $0.kind == .candidate }
        candidateExpandButton?.isHidden = !hasCandidates

        let targetWidth: CGFloat = hasCandidates ? 44 : 0
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

        // ── 保存滚动位置 ─────────────────────────────────────────
        let currentOffset = candidateScrollView.contentOffset.x

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
            button.accessibilityLabel = item.kind == .composition
                ? "提交拼音 \(item.title)" : item.title
            button.accessibilityHint = item.kind == .composition
                ? "双击以提交原始拼音" : "双击选择候选词"
            stack.addArrangedSubview(button)
        }

        // ── trailing spacer：吸收多余宽度，防止首候选被 .fill 分布拉伸 ─
        let trailingSpacer = UIView()
        trailingSpacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
        trailingSpacer.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        stack.addArrangedSubview(trailingSpacer)

        // ── "更多"指示器（提示用户可继续滚动查看后续候选） ──────────
        if hasMoreCandidates {
            let moreLabel = UILabel()
            moreLabel.text = "\u{22EF}"  // ⋯ 水平省略号
            moreLabel.font = .systemFont(ofSize: 14)
            moreLabel.textColor = .quaternaryLabel
            moreLabel.textAlignment = .center
            moreLabel.accessibilityLabel = "更多候选词可用，继续滚动以查看"
            stack.addArrangedSubview(moreLabel)
        }

        // ── 恢复滚动位置 ─────────────────────────────────────────
        if keepScrollPosition {
            stack.layoutIfNeeded()
            let maxOffset = max(0, candidateScrollView.contentSize.width - candidateScrollView.bounds.width)
            candidateScrollView.contentOffset.x = min(currentOffset, maxOffset)
        }

        // ── 控制弹性滚动 ─────────────────────────────────────────
        candidateScrollView.alwaysBounceHorizontal = hasMoreCandidates

        Logger.shared.debug(
            "fillCandidateBar: cleared \(oldCount) old views, " +
            "added \(items.count) new buttons, kinds=\(items.map { $0.kind.rawValue })",
            category: .display
        )
    }

    /// 向现有候选栏追加按钮（不清除已有按钮）。
    /// 用于加载更多候选时平滑追加，避免清除+重建造成的视觉闪烁。
    func appendToCandidateBar(newItems: [CandidateItem]) {
        guard let stack = candidateStack else { return }

        // 移除旧的"更多"指示器（始终是最后一个子视图）
        if let lastView = stack.arrangedSubviews.last as? UILabel,
           lastView.text == "\u{22EF}" {
            stack.removeArrangedSubview(lastView)
            lastView.removeFromSuperview()
        }

        for item in newItems {
            guard item.kind != .placeholder else { continue }
            let color: UIColor = item.kind == .composition ? .secondaryLabel : .label
            let button = CandidateButtonFactory.makeCandidateButton(
                title: item.title,
                kind: item.kind,
                color: color,
                bold: false,
                height: candidateBarHeight,
                highlighted: false
            )
            button.addTarget(self, action: #selector(insertCandidate(_:)), for: .touchUpInside)
            button.accessibilityLabel = item.kind == .composition
                ? "提交拼音 \(item.title)" : item.title
            button.accessibilityHint = item.kind == .composition
                ? "双击以提交原始拼音" : "双击选择候选词"
            stack.addArrangedSubview(button)
        }

        // 重新添加"更多"指示器（如果仍有更多候选）
        if hasMoreCandidates {
            let moreLabel = UILabel()
            moreLabel.text = "\u{22EF}"
            moreLabel.font = .systemFont(ofSize: 14)
            moreLabel.textColor = .quaternaryLabel
            moreLabel.textAlignment = .center
            moreLabel.accessibilityLabel = "更多候选词可用，继续滚动以查看"
            stack.addArrangedSubview(moreLabel)
        }

        // trailing spacer：吸收多余宽度，防止首候选被 .fill 分布拉伸
        let trailingSpacer = UIView()
        trailingSpacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
        trailingSpacer.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        stack.addArrangedSubview(trailingSpacer)

        // 无更多候选时禁用横向弹性
        candidateScrollView.alwaysBounceHorizontal = hasMoreCandidates

        Logger.shared.debug(
            "appendToCandidateBar: +\(newItems.count) buttons, alwaysBounce=\(hasMoreCandidates)",
            category: .display
        )
    }

    // MARK: --- 候选数据 ---

    /// 获取当前应显示的候选词列表。
    ///
    /// 无极滑动模式下优先返回累积列表（包含已加载的所有页的候选），
    /// 确保候选栏和展开面板始终显示相同的候选集合。
    func candidateItems() -> [CandidateItem] {
        if !accumulatedCandidates.isEmpty {
            return accumulatedCandidates
        }
        return CandidateBarDataSource.candidateItems(from: controller)
    }
}
