import KeyboardCore
//
//  KeyboardViewController+CandidateBar.swift
//  Keyboard
//
//  候选栏与控制器状态之间的薄适配。
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

// MARK: === 候选栏 ===

extension KeyboardViewController {

    // MARK: --- 候选栏容器 ---

    /// Connects the presentation-only candidate container to controller state.
    func makeCandidateBar() -> UIView {
        let view = CandidateBarView(
            height: candidateBarHeight,
            bottomHitExtension: candidateToKeySpacing,
            backgroundColor: .clear,
            interactionTarget: self,
            expandAction: #selector(toggleCandidateExpand)
        )
        let collectionView = view.collectionView
        collectionView.dataSource = self
        collectionView.delegate = self
        candidateCollectionView = collectionView
        candidateScrollView = collectionView
        candidateExpandButton = view.expandButton
        candidateExpandButtonWidthConstraint = view.expandButtonWidthConstraint
        fillCandidateBar()
        return view
    }

    /// 切换候选面板展开/收起。展开面板覆盖在现有键盘之上，
    /// 不拆除底层按键和候选栏，因此切换动画期间没有整页重排。
    @objc func toggleCandidateExpand() {
        isCandidateExpanded.toggle()
        candidatePrefetchRequestSerial += 1
        deferredCandidatePrefetchMode = nil
        updateExpandButtonAppearance()
        if isCandidateExpanded {
            candidatePrefetchMode = .expanded
            presentExpandedCandidatePanel()
            if hasMoreCandidates {
                scheduleCandidatePrefetch(mode: .expanded)
            }
        } else {
            candidatePrefetchMode = .bar
            dismissExpandedCandidatePanel(animated: true)
        }
    }

    // MARK: --- 刷新 ---

    /// 刷新候选栏内容。
    ///
    /// 每次新的拼音输入时：
    ///   1. 从 RIME 获取第一页候选
    ///   2. 集合视图立即显示第一页，仅渲染可见 cell
    ///   3. 用户实际滚动到末尾时，再按需请求后续页
    func refreshCandidateBar() {
        guard candidateCollectionView != nil else { return }
        let refreshStart = CACurrentMediaTime()

        resetCandidateSnapshotFromController()
        let preeditLength = controller.state.lastRimeOutput?.composition?.preeditText.count ?? 0

        Logger.shared.info(
            "refreshCandidateBar: page1=\(accumulatedCandidates.count), next=\(nextCandidateGlobalIndex), "
                + "hasMore=\(hasMoreCandidates), preeditLength=\(preeditLength)",
            category: .display
        )

        fillCandidateBar()
        let refreshMs = (CACurrentMediaTime() - refreshStart) * 1000
        Logger.shared.performance(
            "CANDIDATES refresh total=\(String(format: "%.1f", refreshMs))ms items=\(accumulatedCandidates.count)"
        )
        if refreshMs >= 30 {
            Logger.shared.warning(
                "SLOW CANDIDATES refresh duration=\(String(format: "%.1f", refreshMs))ms "
                    + "items=\(accumulatedCandidates.count) depth=\(candidatePageDepth)",
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
        if hasMoreCandidates {
            scheduleCandidatePrefetch(mode: candidatePrefetchMode)
        }
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

        let targetWidth: CGFloat = hasCandidates ? 56 : 0
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
            "fillCandidateBar collection: items=\(items.count), "
                + "durationMs=\(String(format: "%.1f", (CACurrentMediaTime() - renderStart) * 1000))",
            category: .display
        )
    }

    func appendToCandidateBar(insertedCount: Int? = nil) {
        guard let collectionView = candidateCollectionView,
            let insertedCount,
            insertedCount > 0
        else {
            fillCandidateBar(keepScrollPosition: true)
            return
        }

        let currentCount = collectionView.numberOfItems(inSection: 0)
        let expectedOldCount = max(0, horizontalVisibleCandidates.count - insertedCount)
        guard currentCount == expectedOldCount else {
            fillCandidateBar(keepScrollPosition: true)
            return
        }

        let indexPaths = (expectedOldCount..<(expectedOldCount + insertedCount)).map {
            IndexPath(item: $0, section: 0)
        }
        let currentOffset = candidateScrollView.contentOffset
        let generation = candidateSnapshotGeneration
        UIView.performWithoutAnimation {
            collectionView.performBatchUpdates {
                collectionView.insertItems(at: indexPaths)
            } completion: { _ in
                guard self.candidateSnapshotGeneration == generation,
                    collectionView === self.candidateCollectionView
                else { return }
                let maxOffset = max(0, self.candidateScrollView.contentSize.width - self.candidateScrollView.bounds.width)
                self.candidateScrollView.contentOffset.x = min(currentOffset.x, maxOffset)
                collectionView.alwaysBounceHorizontal = self.hasMoreCandidates && !self.horizontalVisibleCandidates.isEmpty
            }
        }
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

    private func nextGlobalIndexAfterCurrentItems() -> Int {
        let referencedNextIndex = accumulatedCandidates.compactMap { item in
            item.selectionReference?.globalIndex.map { $0 + 1 }
        }.max()
        if let referencedNextIndex { return referencedNextIndex }
        return controller.state.lastRimeOutput?.candidates.count ?? 0
    }

    /// Rebuilds the presentation cache from the controller state.
    ///
    /// Page changes rebuild the keyboard before `refreshCandidateBar()` can run.
    /// When a key both commits composition and returns to letters, this prevents
    /// the newly created candidate bar from reusing stale accumulated candidates.
    func resetCandidateSnapshotFromController() {
        accumulatedCandidates = CandidateBarDataSource.candidateItems(from: controller)
        candidateSnapshotGeneration += 1
        candidateSnapshotRawInput = controller.state.lastRimeOutput?.rawInput ?? controller.state.currentComposition
        nextCandidateGlobalIndex = nextGlobalIndexAfterCurrentItems()
        hasMoreCandidates = controller.state.lastRimeOutput?.hasMorePages ?? false
        isLoadingMoreCandidates = false
        deferredCandidatePrefetchMode = nil
        candidatePrefetchRequestSerial += 1
        candidateCellSizeCache.removeAll(keepingCapacity: true)
        candidatePageDepth = 0
        candidatePrefetchMode = isCandidateExpanded ? .expanded : .bar
    }
}
