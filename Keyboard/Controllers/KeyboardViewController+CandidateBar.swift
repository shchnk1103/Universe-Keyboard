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
//  翻页：输入更新后准备多页数据，UICollectionView 仅渲染屏幕附近候选。
//
//  展开后面板（流式布局，填满整个键盘区域）：
//    ┌─────────────────────────────────[▲]─────┐
//    │  [你好] [你好吗] [你] [你们] [你好啊]    │ ← 宽度自适应 + 自动换行
//    │  [你好世界] [你好呀] [你的] ...          │
//    │  ...                          (scroll ↓) │
//    └──────────────────────────────────────────┘
//
import UIKit
import KeyboardCore

private final class CandidateCollectionCell: UICollectionViewCell {
    static let barReuseIdentifier = "CandidateBarCell"
    static let expandedReuseIdentifier = "ExpandedCandidateCell"

    private let button = UIButton(configuration: .plain())

    override init(frame: CGRect) {
        super.init(frame: frame)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isUserInteractionEnabled = false
        contentView.addSubview(button)
        NSLayoutConstraint.activate([
            button.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            button.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            button.topAnchor.constraint(equalTo: contentView.topAnchor),
            button.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with item: CandidateItem, preferred: Bool, expanded: Bool) {
        let color: UIColor = item.kind == .composition ? .secondaryLabel : .label
        CandidateButtonFactory.configureCandidateButton(
            button,
            title: item.title,
            kind: item.kind,
            color: color,
            bold: preferred,
            highlighted: preferred
        )
        accessibilityLabel = item.kind == .composition ? "提交拼音 \(item.title)" : item.title
        accessibilityHint = item.kind == .composition
            ? "双击以提交原始拼音"
            : expanded ? "双击选择候选词并关闭面板" : "双击选择候选词"
    }
}

// MARK: === UIScrollViewDelegate ===

extension KeyboardViewController: UIScrollViewDelegate {

    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        guard scrollView === candidateScrollView || scrollView === expandedPanelScrollView else { return }
        candidatePrefetchWorkItem?.cancel()
        candidatePrefetchWorkItem = nil
        Logger.shared.debug(
            "candidate scroll begin: expanded=\(scrollView === expandedPanelScrollView), " +
            "items=\(accumulatedCandidates.count), offset=(\(Int(scrollView.contentOffset.x)),\(Int(scrollView.contentOffset.y))), " +
            "content=(\(Int(scrollView.contentSize.width)),\(Int(scrollView.contentSize.height)))",
            category: .display
        )
    }

    /// 在触控结束且滚动静止后再追加候选，避免改变手指下方的内容宽度。
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView === candidateScrollView || scrollView === expandedPanelScrollView {
            Logger.shared.debug(
                "candidate scroll endDrag: decelerate=\(decelerate), offset=(\(Int(scrollView.contentOffset.x)),\(Int(scrollView.contentOffset.y)))",
                category: .display
            )
        }
        guard !decelerate else { return }
        requestMoreCandidatesIfNeeded(after: scrollView)
    }

    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView === candidateScrollView || scrollView === expandedPanelScrollView {
            Logger.shared.debug(
                "candidate scroll settled: offset=(\(Int(scrollView.contentOffset.x)),\(Int(scrollView.contentOffset.y))), " +
                "content=(\(Int(scrollView.contentSize.width)),\(Int(scrollView.contentSize.height)))",
                category: .display
            )
        }
        requestMoreCandidatesIfNeeded(after: scrollView)
    }

    private func requestMoreCandidatesIfNeeded(after scrollView: UIScrollView) {
        guard hasMoreCandidates, !isLoadingMoreCandidates, !accumulatedCandidates.isEmpty else { return }

        let shouldLoad: Bool
        if scrollView === candidateScrollView {
            let maxOffset = max(0, scrollView.contentSize.width - scrollView.bounds.width)
            let rightOverscroll = scrollView.contentOffset.x - maxOffset
            let nearEnd = maxOffset > 0 && maxOffset - scrollView.contentOffset.x <= scrollView.bounds.width * 0.35
            shouldLoad = nearEnd || rightOverscroll >= 12
        } else if scrollView === expandedPanelScrollView {
            let maxOffset = max(0, scrollView.contentSize.height - scrollView.bounds.height)
            let bottomOverscroll = scrollView.contentOffset.y - maxOffset
            let nearEnd = maxOffset > 0 && maxOffset - scrollView.contentOffset.y <= scrollView.bounds.height * 0.25
            shouldLoad = nearEnd || bottomOverscroll >= 12
        } else {
            return
        }

        if shouldLoad {
            Logger.shared.debug("candidate paging after scrolling settled", category: .display)
            loadMoreCandidates()
        }
    }

    /// 向 RIME 请求下一页候选并追加到累积列表。
    /// 使用直接 engine 调用避免污染 state.lastRimeOutput，加载后回到第 1 页
    /// 确保空格/候选选择始终对应当前最佳候选。
    func loadMoreCandidates(updateVisibleUI: Bool = true) {
        guard let engine = controller.rimeEngine else { return }
        candidatePrefetchWorkItem = nil

        Logger.shared.info(
            "loadMoreCandidates START: accCount=\(accumulatedCandidates.count), depth=\(candidatePageDepth), expanded=\(isCandidateExpanded)",
            category: .display
        )
        isLoadingMoreCandidates = true

        // 前进到当前最深页
        for _ in 0..<candidatePageDepth {
            _ = engine.pageDown()
        }
        // 获取下一页
        let nextPage = engine.pageDown()
        let nextItems = nextPage.candidates.map { CandidateItem(title: $0.text, kind: .candidate) }
        let newHasMore = nextPage.hasMorePages

        // 回到第 1 页，保持与 state.lastRimeOutput 一致
        for _ in 0..<(candidatePageDepth + 1) {
            _ = engine.pageUp()
        }

        Logger.shared.info(
            "loadMoreCandidates RIME: rawNewItems=\(nextItems.count), hasMorePages=\(newHasMore)",
            category: .display
        )

        // 去重追加
        let visibleStartIndex = accumulatedCandidates.filter { $0.kind != .placeholder }.count
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

        if updateVisibleUI, !newAppended.isEmpty {
            if isCandidateExpanded {
                appendToExpandedCandidatePanel(newItems: newAppended, startingAt: visibleStartIndex)
            } else {
                appendToCandidateBar(newItems: newAppended, startingAt: visibleStartIndex)
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

    /// 构建候选栏容器。横向集合视图只创建可见候选 cell，
    /// 能承载预先准备好的多页数据而不会让输入阶段大量创建按钮。
    func makeCandidateBar() -> UIView {
        let container = UIView()
        container.backgroundColor = keyboardBackgroundColor
        container.layer.cornerRadius = 0
        container.clipsToBounds = true

        // ── 展开按钮 ──────────────────────────────────────────────
        let expandBtn = makeExpandButton()
        container.addSubview(expandBtn)
        candidateExpandButton = expandBtn

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 4
        layout.minimumInteritemSpacing = 4
        layout.sectionInset = UIEdgeInsets(top: 3, left: 4, bottom: 3, right: 8)

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.bounces = true
        collectionView.alwaysBounceHorizontal = false
        collectionView.decelerationRate = .normal
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(
            CandidateCollectionCell.self,
            forCellWithReuseIdentifier: CandidateCollectionCell.barReuseIdentifier
        )
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        candidateCollectionView = collectionView
        candidateScrollView = collectionView
        container.addSubview(collectionView)

        let expandWidth = expandBtn.widthAnchor.constraint(equalToConstant: 44)
        candidateExpandButtonWidthConstraint = expandWidth

        // ── Auto Layout: [scrollView 填充空间] [▼(44)] ─
        NSLayoutConstraint.activate([
            expandBtn.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -3),
            expandBtn.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            expandWidth,
            expandBtn.heightAnchor.constraint(equalToConstant: candidateBarHeight),

            collectionView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 2),
            collectionView.trailingAnchor.constraint(equalTo: expandBtn.leadingAnchor, constant: -2),
            collectionView.topAnchor.constraint(equalTo: container.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: container.bottomAnchor)
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

    /// 切换候选面板展开/收起。展开面板覆盖在现有键盘之上，
    /// 不拆除底层按键和候选栏，因此切换动画期间没有整页重排。
    @objc func toggleCandidateExpand() {
        candidatePrefetchWorkItem?.cancel()
        candidatePrefetchWorkItem = nil
        isCandidateExpanded.toggle()
        updateExpandButtonAppearance()
        if isCandidateExpanded {
            presentExpandedCandidatePanel()
        } else {
            dismissExpandedCandidatePanel(animated: true)
        }
    }

    // MARK: --- 展开面板 ---

    private func updateExpandButtonAppearance() {
        guard let button = candidateExpandButton else { return }
        let transform = isCandidateExpanded ? CGAffineTransform(rotationAngle: .pi) : .identity
        var config = button.configuration
        config?.baseForegroundColor = isCandidateExpanded ? view.tintColor : .secondaryLabel
        button.configuration = config

        if UIAccessibility.isReduceMotionEnabled {
            button.imageView?.transform = transform
        } else {
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut) {
                button.imageView?.transform = transform
            }
        }
    }

    private func presentExpandedCandidatePanel() {
        candidateExpandedPanel?.removeFromSuperview()

        let panel = makeExpandedCandidatePanel()
        panel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(panel)
        NSLayoutConstraint.activate([
            panel.leadingAnchor.constraint(equalTo: rootStack.leadingAnchor),
            panel.trailingAnchor.constraint(equalTo: rootStack.trailingAnchor),
            panel.topAnchor.constraint(equalTo: rootStack.topAnchor),
            panel.bottomAnchor.constraint(equalTo: rootStack.bottomAnchor)
        ])
        candidateExpandedPanel = panel
        rootStack.isUserInteractionEnabled = false

        guard !UIAccessibility.isReduceMotionEnabled else {
            rootStack.alpha = 0
            return
        }
        panel.alpha = 0
        panel.transform = CGAffineTransform(translationX: 0, y: 8)
        UIView.animate(
            withDuration: 0.18,
            delay: 0,
            options: [.curveEaseOut, .beginFromCurrentState]
        ) {
            panel.alpha = 1
            panel.transform = .identity
            self.rootStack.alpha = 0
        }
    }

    func dismissExpandedCandidatePanel(animated: Bool) {
        guard let panel = candidateExpandedPanel else {
            rootStack.alpha = 1
            rootStack.isUserInteractionEnabled = true
            expandedPanelScrollView = nil
            expandedCandidateCollectionView = nil
            return
        }

        let completion: (Bool) -> Void = { _ in
            panel.removeFromSuperview()
            self.candidateExpandedPanel = nil
            self.expandedPanelScrollView = nil
            self.expandedCandidateCollectionView = nil
            self.rootStack.isUserInteractionEnabled = true
        }

        guard animated, !UIAccessibility.isReduceMotionEnabled else {
            rootStack.alpha = 1
            completion(true)
            return
        }
        UIView.animate(
            withDuration: 0.16,
            delay: 0,
            options: [.curveEaseIn, .beginFromCurrentState]
        ) {
            panel.alpha = 0
            panel.transform = CGAffineTransform(translationX: 0, y: 6)
            self.rootStack.alpha = 1
        } completion: { finished in
            completion(finished)
        }
    }

    /// 构建展开的候选面板。流式集合视图允许仅插入新候选，
    /// 避免分页后销毁所有按钮导致跳动或短暂空白。
    func makeExpandedCandidatePanel(with precomputedItems: [CandidateItem]? = nil) -> UIView {
        let container = UIView()
        container.backgroundColor = keyboardBackgroundColor
        container.clipsToBounds = true

        let items = precomputedItems ?? candidateItems()
        let candidates = items.filter { $0.kind != .placeholder }
        let collapseBtnSize: CGFloat = 44

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 4
        layout.minimumInteritemSpacing = 4
        layout.sectionInset = UIEdgeInsets(top: 5, left: 8, bottom: 8, right: collapseBtnSize + 8)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.alwaysBounceVertical = hasMoreCandidates
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(
            CandidateCollectionCell.self,
            forCellWithReuseIdentifier: CandidateCollectionCell.expandedReuseIdentifier
        )
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        expandedCandidateCollectionView = collectionView
        expandedPanelScrollView = collectionView
        container.addSubview(collectionView)

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
        container.addSubview(collapseBtn)

        NSLayoutConstraint.activate([
            collapseBtn.topAnchor.constraint(equalTo: container.topAnchor, constant: 2),
            collapseBtn.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -4),
            collapseBtn.widthAnchor.constraint(equalToConstant: collapseBtnSize),
            collapseBtn.heightAnchor.constraint(equalToConstant: collapseBtnSize),

            collectionView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: container.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])

        Logger.shared.info(
            "expandedPanel: \(candidates.count) candidates in incremental collection",
            category: .display
        )

        return container
    }

    /// 输入状态改变时刷新集合内容；分页路径使用增量插入而不触发全量刷新。
    func refreshExpandedPanel() {
        guard isCandidateExpanded, let collectionView = expandedCandidateCollectionView else { return }
        collectionView.reloadData()
        collectionView.alwaysBounceVertical = hasMoreCandidates
    }

    func appendToExpandedCandidatePanel(newItems: [CandidateItem], startingAt firstIndex: Int) {
        guard isCandidateExpanded, let collectionView = expandedCandidateCollectionView else { return }
        let indexPaths = newItems.enumerated().compactMap { offset, item -> IndexPath? in
            guard item.kind != .placeholder else { return nil }
            return IndexPath(item: firstIndex + offset, section: 0)
        }
        guard !indexPaths.isEmpty else { return }
        collectionView.performBatchUpdates {
            collectionView.insertItems(at: indexPaths)
        }
        collectionView.alwaysBounceVertical = hasMoreCandidates
    }

    /// 展开面板中候选按钮的点击处理。
    /// 与普通候选栏的 insertCandidate 不同，选择后会自动关闭展开面板。
    @objc func insertCandidateFromPanel(_ sender: UIButton) {
        guard let candidate = sender.configuration?.title,
              let kind = CandidateKind(rawValue: sender.tag) else { return }
        commitExpandedCandidate(CandidateItem(title: candidate, kind: kind))
    }

    func commitExpandedCandidate(_ item: CandidateItem) {
        playKeyClick()
        playHaptic()
        let effects = controller.handle(.insertCandidate(item.title, kind: item.kind))
        isCandidateExpanded = false
        updateExpandButtonAppearance()
        dismissExpandedCandidatePanel(animated: true)
        syncUI(with: effects)
    }

    // MARK: --- 刷新 ---

    /// 刷新候选栏内容。
    ///
    /// 每次新的拼音输入时：
    ///   1. 从 RIME 获取第一页候选
    ///   2. 集合视图立即显示第一页，仅渲染可见 cell
    ///   3. 下一轮主线程准备后续多页数据，供连续快速滑动直接浏览
    func refreshCandidateBar() {
        guard candidateCollectionView != nil else { return }
        let refreshStart = CACurrentMediaTime()

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

        fillCandidateBar()
        scheduleIdleCandidatePrefetch()
        let refreshMs = (CACurrentMediaTime() - refreshStart) * 1000
        Logger.shared.performance(
            "CANDIDATES refresh total=\(String(format: "%.1f", refreshMs))ms items=\(accumulatedCandidates.count)"
        )
        if refreshMs >= 30 {
            Logger.shared.warning(
                "SLOW CANDIDATES refresh duration=\(String(format: "%.1f", refreshMs))ms " +
                "items=\(accumulatedCandidates.count) depth=\(candidatePageDepth)",
                category: .performance
            )
        }

        // 滚动回最左侧
        if candidateScrollView.contentOffset.x != 0 {
            candidateScrollView.setContentOffset(.zero, animated: false)
        }

        if isCandidateExpanded {
            refreshExpandedPanel()
        }
    }

    /// 下一轮主线程准备多页数据。横向集合视图只创建可见 cell，
    /// 因而数据量增加不会重新引入大量按钮布局开销。
    private func scheduleIdleCandidatePrefetch() {
        candidatePrefetchWorkItem?.cancel()
        candidatePrefetchWorkItem = nil
        guard hasMoreCandidates, !isCandidateExpanded, !accumulatedCandidates.isEmpty else { return }

        let workItem = DispatchWorkItem { [weak self] in
            guard let self,
                  self.hasMoreCandidates,
                  !self.isCandidateExpanded,
                  !self.isLoadingMoreCandidates,
                  !self.candidateScrollView.isTracking,
                  !self.candidateScrollView.isDragging,
                  !self.candidateScrollView.isDecelerating else { return }
            let prefetchStart = CACurrentMediaTime()
            var pagesLoaded = 0
            while self.hasMoreCandidates && pagesLoaded < 6 {
                self.loadMoreCandidates(updateVisibleUI: false)
                pagesLoaded += 1
            }
            self.candidateCollectionView?.reloadData()
            let elapsedMs = (CACurrentMediaTime() - prefetchStart) * 1000
            Logger.shared.performance(
                "CANDIDATES prefetch pages=\(pagesLoaded) items=\(self.accumulatedCandidates.count) " +
                "duration=\(String(format: "%.1f", elapsedMs))ms"
            )
        }
        candidatePrefetchWorkItem = workItem
        DispatchQueue.main.async(execute: workItem)
    }

    /// 刷新横向候选列表的数据呈现。`UICollectionView` 自行复用可见 cell，
    /// 不需要为每个已加载候选创建常驻 UIButton。
    func fillCandidateBar(keepScrollPosition: Bool = false) {
        guard let collectionView = candidateCollectionView else {
            Logger.shared.warning("fillCandidateBar: candidateCollectionView is nil", category: .general)
            return
        }
        let renderStart = CACurrentMediaTime()
        let items = horizontalVisibleCandidates

        // ── 控制展开按钮可见性 ─────────────────────────────────────
        let hasCandidates = items.contains { $0.kind == .candidate }
        candidateExpandButton?.isHidden = !hasCandidates

        let targetWidth: CGFloat = hasCandidates ? 44 : 0
        if candidateExpandButtonWidthConstraint?.constant != targetWidth {
            candidateExpandButtonWidthConstraint?.constant = targetWidth
        }

        let currentOffset = candidateScrollView.contentOffset.x
        collectionView.reloadData()
        if keepScrollPosition {
            collectionView.layoutIfNeeded()
            let maxOffset = max(0, candidateScrollView.contentSize.width - candidateScrollView.bounds.width)
            candidateScrollView.contentOffset.x = min(currentOffset, maxOffset)
        } else if items.isEmpty {
            candidateScrollView.setContentOffset(.zero, animated: false)
        }
        collectionView.alwaysBounceHorizontal = hasMoreCandidates && !items.isEmpty

        Logger.shared.debug(
            "fillCandidateBar collection: items=\(items.count), " +
            "durationMs=\(String(format: "%.1f", (CACurrentMediaTime() - renderStart) * 1000))",
            category: .display
        )
    }

    func appendToCandidateBar(newItems: [CandidateItem], startingAt firstIndex: Int) {
        guard let collectionView = candidateCollectionView else { return }
        let indexPaths = newItems.enumerated().compactMap { offset, item -> IndexPath? in
            guard item.kind != .placeholder else { return nil }
            return IndexPath(item: firstIndex + offset, section: 0)
        }
        guard !indexPaths.isEmpty else { return }
        collectionView.performBatchUpdates {
            collectionView.insertItems(at: indexPaths)
        }
        collectionView.alwaysBounceHorizontal = hasMoreCandidates
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

// MARK: === 展开候选集合视图 ===

extension KeyboardViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    private var horizontalVisibleCandidates: [CandidateItem] {
        accumulatedCandidates.filter { $0.kind != .placeholder }
    }

    private var expandedVisibleCandidates: [CandidateItem] {
        accumulatedCandidates.filter { $0.kind != .placeholder }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView === candidateCollectionView {
            return horizontalVisibleCandidates.count
        }
        if collectionView === expandedCandidateCollectionView {
            return expandedVisibleCandidates.count
        }
        return 0
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let isExpanded = collectionView === expandedCandidateCollectionView
        let identifier = isExpanded
            ? CandidateCollectionCell.expandedReuseIdentifier
            : CandidateCollectionCell.barReuseIdentifier
        guard collectionView === candidateCollectionView || isExpanded,
              let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: identifier,
                for: indexPath
              ) as? CandidateCollectionCell else {
            return UICollectionViewCell()
        }
        let item = isExpanded
            ? expandedVisibleCandidates[indexPath.item]
            : horizontalVisibleCandidates[indexPath.item]
        cell.configure(
            with: item,
            preferred: indexPath.item == 0 && item.kind == .candidate,
            expanded: isExpanded
        )
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView === candidateCollectionView {
            commitCandidate(horizontalVisibleCandidates[indexPath.item])
        } else if collectionView === expandedCandidateCollectionView {
            commitExpandedCandidate(expandedVisibleCandidates[indexPath.item])
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let items = collectionView === candidateCollectionView
            ? horizontalVisibleCandidates
            : expandedVisibleCandidates
        let item = items[indexPath.item]
        let fontSize: CGFloat = item.kind == .composition ? 14 : 16
        let weight: UIFont.Weight = indexPath.item == 0 && item.kind == .candidate ? .semibold : .regular
        let font = UIFontMetrics(forTextStyle: .body).scaledFont(
            for: .systemFont(ofSize: fontSize, weight: weight),
            maximumPointSize: 28
        )
        let horizontalInsets: CGFloat = indexPath.item == 0 ? 16 : 24
        let textWidth = (item.title as NSString).size(withAttributes: [.font: font]).width
        let maximumWidth = max(44, collectionView.bounds.width - 16)
        return CGSize(width: min(maximumWidth, ceil(textWidth + horizontalInsets)), height: 38)
    }

    private func commitCandidate(_ item: CandidateItem) {
        playKeyClick()
        playHaptic()
        let effects = controller.handle(.insertCandidate(item.title, kind: item.kind))
        syncUI(with: effects)
    }
}
