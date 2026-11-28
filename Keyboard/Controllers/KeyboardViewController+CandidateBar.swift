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
            backgroundColor: .clear,
            interactionTarget: self,
            expandAction: #selector(handleCandidateBarTrailingButton)
        )
        #if DEBUG && KEYBOARD_WAKE_OWNER_PROBE
            installWakeOwnerProbeControls(on: view)
        #endif
        let collectionView = view.collectionView
        collectionView.dataSource = self
        collectionView.delegate = self
        candidateCollectionView = collectionView
        candidateScrollView = collectionView
        candidateExpandButton = view.expandButton
        candidateExpandButtonWidthConstraint = view.expandButtonWidthConstraint
        fillCandidateBar(on: view)
        view.onItemTap = { [weak self] indexPath in
            self?.commitCompactCandidate(at: indexPath)
        }
        refreshPasteToolbar(on: view)
        view.onPasteFailureTap = { [weak self] in
            guard let self else { return }
            // 点失败行只清失败并刷新，不记成输入，也不改 presentation。
            self.pasteSession.clearFailure()
            self.refreshPasteToolbar()
        }
        view.onQuickMenuEntryTap = { [weak self] in
            self?.toggleQuickMenu()
        }
        return view
    }

    /// 下滑展开旗标与尾按钮共用的展开口径（PB-021-NUMPAD-SWIPE-EXPAND-001）。
    /// 有可展开候选，或数字快捷栏激活；空闲非快捷栏态恒为 `false`。
    var canExpandCandidateBar: Bool {
        presentedCandidates.contains { $0.kind.expandsCandidateBarPanel }
            || isT9NumberPadShortcutStripActive
    }

    /// Idle trailing control dismisses the keyboard; expandable content still expands.
    @objc func handleCandidateBarTrailingButton() {
        if pasteSession.preview == .reading {
            pasteSession.discardPreview()
            refreshPasteToolbar()
        }
        guard !isKeyboardHeightAdjusting else { return }
        guard !shouldBlockT9RecoveryPresentation else { return }
        let canExpand = canExpandCandidateBar
        if canExpand {
            toggleCandidateExpand()
        } else {
            pasteSession.clearFailure()
            dismissKeyboard()
        }
    }

    /// 切换候选面板展开/收起。展开面板覆盖在现有键盘之上，
    /// 不拆除底层按键和候选栏，因此切换动画期间没有整页重排。
    @objc func toggleCandidateExpand() {
        guard !isKeyboardHeightAdjusting else { return }
        guard !shouldBlockT9RecoveryPresentation else { return }
        // UIKit reveal owns this short interaction boundary; do not race overlapping overlays.
        guard (candidateExpandedPanel as? ExpandedCandidatePanelContainerView)?.isTransitioning != true else { return }
        if isPinyinPathExpanded {
            dismissPinyinPathExpandedPanel(animated: false)
        }
        isCandidateExpanded.toggle()
        candidatePrefetchRequestSerial += 1
        deferredCandidatePrefetchMode = nil
        updateExpandButtonAppearance()
        if isCandidateExpanded {
            candidatePrefetchMode = .expanded
            if controller.state.pendingPunctuation != nil || controller.state.pendingKaomoji != nil {
                resetCandidateSnapshotFromController()
                fillCandidateBar()
            }
            presentExpandedCandidatePanel()
            if hasMoreCandidates {
                scheduleCandidatePrefetch(mode: .expanded)
            }
        } else {
            candidatePrefetchMode = .bar
            if controller.state.pendingPunctuation != nil || controller.state.pendingKaomoji != nil {
                resetCandidateSnapshotFromController()
                fillCandidateBar()
            }
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
        #if DEBUG
            let preeditLength = controller.state.lastRimeOutput?.composition?.preeditText.count ?? 0

            Logger.shared.info(
                "refreshCandidateBar: page1=\(accumulatedCandidates.count), next=\(nextCandidateGlobalIndex), "
                    + "hasMore=\(hasMoreCandidates), preeditLength=\(preeditLength)",
                category: .display
            )
        #endif

        fillCandidateBar()
        let refreshMs = (CACurrentMediaTime() - refreshStart) * 1000
        #if DEBUG
            Logger.shared.performance(
                "CANDIDATES refresh total=\(String(format: "%.1f", refreshMs))ms items=\(accumulatedCandidates.count)"
            )
        #endif
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
    func fillCandidateBar(keepScrollPosition: Bool = false, on targetBar: CandidateBarView? = nil) {
        guard let collectionView = candidateCollectionView else {
            Logger.shared.warning("fillCandidateBar: candidateCollectionView is nil", category: .general)
            return
        }
        #if DEBUG
            let renderStart = CACurrentMediaTime()
        #endif
        // PB-021-NUMPAD-SWIPE-EXPAND-001：重建路径期间 `self.candidateBar` 仍是旧 bar，
        // defer 的粘贴工具条刷新必须跟随同一 targetBar，否则快捷栏翻转会在旧 bar 上结算，
        // 新 bar 残留陈旧旗标。targetBar 为 nil 时与原行为一致。
        defer { refreshPasteToolbar(on: targetBar) }
        let items = presentedCandidates

        // Dual-mode trailing control (`PD-CANDIDATE-BAR-IDLE-DISMISS-001`):
        // expandable content keeps expand + swipe-down; idle shows dismiss.
        // PB-021-NUMPAD-SWIPE-EXPAND-001：重建路径（makeCandidateBar）期间
        // `self.candidateBar` 仍是旧 bar（或 nil），旗标必须落到 `targetBar` 上。
        let canExpand = canExpandCandidateBar
        candidateExpandButton?.isHidden = false
        let bar = targetBar ?? candidateBar as? CandidateBarView
        if let bar {
            bar.allowsSwipeToExpand = canExpand
        }
        updateExpandButtonAppearance(canExpand: canExpand)
        bar?.setInputRecoveryNotice(
            shouldBlockT9RecoveryPresentation ? controller.compositionInputRecoveryMessage : nil)
        #if DEBUG && KEYBOARD_WAKE_OWNER_PROBE
            refreshWakeOwnerProbeControls()
        #endif

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

        #if DEBUG
            Logger.shared.debug(
                "fillCandidateBar collection: items=\(items.count), "
                    + "durationMs=\(String(format: "%.1f", (CACurrentMediaTime() - renderStart) * 1000))",
                category: .display
            )
        #endif
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
        let expectedOldCount = max(0, presentedCandidates.count - insertedCount)
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
                let maxOffset = max(
                    0, self.candidateScrollView.contentSize.width - self.candidateScrollView.bounds.width)
                self.candidateScrollView.contentOffset.x = min(currentOffset.x, maxOffset)
                collectionView.alwaysBounceHorizontal = self.hasMoreCandidates && !self.presentedCandidates.isEmpty
            }
        }
    }

    // MARK: --- 候选数据 ---

    /// 获取当前应显示的候选词列表。
    ///
    /// 无极滑动模式下优先返回累积列表（包含已加载的所有页的候选），
    /// 确保候选栏和展开面板始终显示相同的候选集合。
    func candidateItems() -> [CandidateItem] {
        guard !shouldBlockT9RecoveryPresentation else { return [] }
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
        if controller.isCompositionInputRecoveryPending {
            invalidateCandidatesForInputRecovery()
            return
        }
        // Placeholder 是旧按钮式候选栏的安全哨兵，不属于当前 collection 快照。
        // 在唯一重建边界过滤一次，避免每个数据源回调都复制并过滤数组。
        let pendingItems: [CandidateItem]?
        if controller.state.pendingPunctuation != nil {
            pendingItems = controller.pendingPunctuationCandidateItems(expanded: isCandidateExpanded)
        } else if controller.state.pendingKaomoji != nil {
            pendingItems = controller.pendingKaomojiCandidateItems(expanded: isCandidateExpanded)
        } else {
            pendingItems = nil
        }
        accumulatedCandidates = (pendingItems ?? CandidateBarDataSource.candidateItems(from: controller)).filter {
            $0.kind != .placeholder
        }
        candidateSnapshotGeneration += 1
        candidateSnapshotCompositionRevision = controller.state.compositionRevision
        candidateSnapshotOrigin = controller.state.lastRimeOutput?.candidateOrigin
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

    /// Publish candidates from a captured T9 composition snapshot (same revision as Path Bar).
    func resetCandidateSnapshot(from snapshot: T9CompositionPresentationSnapshot) {
        if controller.isCompositionInputRecoveryPending {
            invalidateCandidatesForInputRecovery()
            return
        }
        // Nine-key pinyin in the candidate bar is the validated projection only.
        // An empty projection keeps the existing space placeholder and does not
        // fall back to the engine's raw composition text.
        let preedit = snapshot.visiblePreedit
        let items: [CandidateItem]
        if !preedit.isEmpty || !snapshot.candidates.isEmpty {
            items = CandidateBarDataSource.candidateItems(
                from: controller,
                rimeCandidates: snapshot.candidates,
                preeditText: preedit.isEmpty ? " " : preedit,
                pageNumber: snapshot.candidatePageNumber,
                candidateOrigin: snapshot.candidateOrigin
            )
        } else if shouldPublishAtomicT9Presentation {
            // Both the projection and the snapshot are empty. Do not read the
            // engine composition back into the bar; that string is still digits.
            items = []
        } else {
            items = CandidateBarDataSource.candidateItems(from: controller)
        }
        accumulatedCandidates = items.filter { $0.kind != .placeholder }
        candidateSnapshotGeneration += 1
        candidateSnapshotCompositionRevision = snapshot.revision
        candidateSnapshotOrigin = snapshot.candidateOrigin
        candidateSnapshotRawInput =
            snapshot.rimeRawInput
            ?? controller.state.currentComposition
        nextCandidateGlobalIndex = nextGlobalIndexAfterCurrentItems()
        hasMoreCandidates = snapshot.hasMorePages
        isLoadingMoreCandidates = false
        deferredCandidatePrefetchMode = nil
        candidatePrefetchRequestSerial += 1
        candidateCellSizeCache.removeAll(keepingCapacity: true)
        candidatePageDepth = 0
        candidatePrefetchMode = isCandidateExpanded ? .expanded : .bar
    }
}

extension KeyboardViewController {
    var isPasteToolbarEligible: Bool {
        guard controller != nil else { return false }
        let state = controller.state
        return cachedPasteToolbarEnabled && hasFullAccess && !pasteToolbarSuspended
            && !isCandidateExpanded && !isPinyinPathExpanded && candidateExpandedPanel == nil
            && (candidateExpandedPanel as? ExpandedCandidatePanelContainerView)?.isTransitioning != true
            && state.currentComposition.isEmpty && state.insertedPreeditCount == 0
            && state.pendingPunctuation == nil && state.pendingKaomoji == nil
            && presentedCandidates.isEmpty && state.continuation.suggestions.isEmpty
            && !shouldBlockT9RecoveryPresentation
    }

    func refreshPasteToolbar(on newBar: CandidateBarView? = nil) {
        guard controller != nil else { return }
        // PB-016 PR-2: the single quick-menu entry visibility hook (r3 §4.1).
        // Runs before every early return so the number-pad shortcut-strip
        // branch still refreshes the entry.
        refreshQuickMenuEntryVisibility(on: newBar)
        let bar = newBar ?? candidateBar as? CandidateBarView
        if syncT9NumberPadShortcutStrip(on: bar) {
            pasteSession.invalidate()
            bar?.clearPasteContent()
            return
        }
        let eligible = isPasteToolbarEligible && pasteSession.presentation == .armed
        if !eligible || bar == nil {
            pasteSession.invalidate()
            if !pasteToolbarSuspended || !pasteSession.inquiryOpen || !cachedPasteToolbarEnabled || !hasFullAccess {
                pasteSession.discardPreview()
            }
            (pastePreviewView?.superview as? CandidateBarView)?.clearPasteContent()
            pastePreviewView = nil
        } else if let bar {
            pasteSession.startPreviewIfNeeded()
            switch pasteSession.preview {
            case .notRead, .reading, .unavailable:
                (pastePreviewView?.superview as? CandidateBarView)?.clearPasteContent()
                pastePreviewView = nil
            case .suppressed:
                // PB-013 Level 0 命中：不武装、不安装预览，清栏即可（previewWasShown 保持 false）。
                (pastePreviewView?.superview as? CandidateBarView)?.clearPasteContent()
                pastePreviewView = nil
            case .ready(let result):
                switch result {
                case .unavailable, .denied:
                    bar.clearPasteContent()
                    pastePreviewView = nil
                case .text(_, let summary, let isLink), .oversized(let summary, _, let isLink):
                    if pastePreviewView?.superview !== bar {
                        if pasteSession.previewWasShown {
                            pasteSession.discardPreview()
                            bar.clearPasteContent()
                            pastePreviewView = nil
                            break
                        }
                        let preview = PastePreviewView(summary: summary, isLink: isLink)
                        // Inherit the bar's current dynamic type before the initial fit check.
                        preview.isHidden = true
                        preview.accessibilityElementsHidden = true
                        bar.addSubview(preview)
                        bar.updateTraitsIfNeeded()
                        preview.updateTraitsIfNeeded()
                        let titleFont = UIFontMetrics(forTextStyle: .body).scaledFont(
                            for: .systemFont(ofSize: 15, weight: .semibold), compatibleWith: bar.traitCollection)
                        let summaryFont = UIFontMetrics(forTextStyle: .caption1).scaledFont(
                            for: .systemFont(ofSize: 12), compatibleWith: bar.traitCollection)
                        let fitsInheritedTraits =
                            titleFont.pointSize <= 18
                            && titleFont.lineHeight + summaryFont.lineHeight <= 46
                        if preview.fitsCandidateBar && fitsInheritedTraits {
                            preview.isHidden = false
                            preview.accessibilityElementsHidden = false
                            preview.onCannotFit = { [weak self, weak bar] in
                                guard let self, let bar else { return }
                                self.pasteSession.discardPreview()
                                bar.clearPasteContent()
                                self.pastePreviewView = nil
                            }
                            // PB-013 关闭按钮：写 closed 抑制并收栏，绝不粘贴。
                            preview.onClose = { [weak self] in
                                guard let self else { return }
                                self.pasteSession.closePreview()
                                self.refreshPasteToolbar()
                            }
                            preview.addTarget(self, action: #selector(pastePreviewTapped), for: .touchUpInside)
                            pastePreviewView = preview
                            bar.setPasteContent(preview)
                            pasteSession.didInstallPreview()
                        } else {
                            preview.removeFromSuperview()
                            pasteSession.discardPreview()
                            bar.clearPasteContent()
                            pastePreviewView = nil
                        }
                    }
                }
            }
        }
        let failure = pasteSession.pasteFailureVisible ? "无法粘贴纯文本" : nil
        bar?.setPasteFailureNotice(failure)
    }

    @objc private func pastePreviewTapped() {
        guard case .ready(let result) = pasteSession.preview else { return }
        switch result {
        case .text(let full, _, _):
            guard let operation = pasteSession.begin() else { return }
            pasteSession.complete(full, operationID: operation)
        case .oversized:
            pasteSession.failOversizedPreview()
        case .unavailable, .denied:
            break
        }
    }

    func observePasteDocumentIdentity(_ observation: KeyboardDocumentIdentityTracker.Observation) {
        if observation == .changed || observation == .unavailable {
            pasteSession.invalidate()
            if pasteSession.preview == .reading { pasteSession.discardPreview() }
        }
    }
}

extension KeyboardViewController {
    /// 数字页快捷栏激活时，点候选栏项按数字页字面量上屏（PB-009-SHORTCUT-BAR-REUSE-001）。
    /// 返回 true 表示已按快捷栏语义消费，调用方不再走候选提交管线。
    func commitNumberPadShortcutStripItemIfActive(_ item: CandidateItem) -> Bool {
        guard isT9NumberPadShortcutStripActive,
            T9NumberPadLayout.shortcutSymbols.contains(item.title)
        else { return false }
        // 旧按钮行为：展开态点符号先收面板再上屏。
        if isCandidateExpanded { toggleCandidateExpand() }
        emitFeedback(for: .commit)
        let effects = controller.handle(.insertT9NumberPadText(item.title))
        syncUI(with: effects)
        return true
    }

    /// 数字页符号快捷栏：直接复用 `CandidateBarView` 原候选栏 `collectionView`
    /// 渲染 `T9NumberPadLayout.shortcutSymbols`（PB-009-SHORTCUT-BAR-REUSE-001）。
    ///
    /// 激活/去激活只翻转 `isT9NumberPadShortcutStripActive` 并触发一次
    /// `fillCandidateBar()`：数据源通过 `presentedCandidates` 覆盖喂入伪候选，
    /// 字体、滑动、点击高亮与展开按钮交互全部继承原生管线，不再有叠层模糊。
    @discardableResult
    func syncT9NumberPadShortcutStrip(on bar: CandidateBarView?) -> Bool {
        guard let bar else { return false }
        let state = controller.state
        let usesNumberPad =
            (state.inputMode == .chinese && cachedLayoutStyle == .nineKey && cachedT9ReadinessMatched)
            || (cachedLayoutStyle == .twentySixKey && cachedTwentySixKeyNumberPadEnabled)
        let show =
            state.currentPage == .numbers && usesNumberPad && state.currentComposition.isEmpty
            && state.pendingPunctuation == nil && state.pendingKaomoji == nil
            && accumulatedCandidates.isEmpty && !controller.isCompositionInputRecoveryPending
            && !shouldBlockT9RecoveryPresentation
        if show == isT9NumberPadShortcutStripActive {
            if show {
                removeLegacyNumberPadShortcutOverlays(on: bar)
                // PB-021-NUMPAD-SWIPE-EXPAND-001：整建路径（makeCandidateBar →
                // refreshPasteToolbar(on:)）不会经过 fillCandidateBar()，
                // 在 early-return 处把旗标按统一口径落到传入的新 bar 上。
                bar.allowsSwipeToExpand = canExpandCandidateBar
            }
            return show
        }
        isT9NumberPadShortcutStripActive = show
        removeLegacyNumberPadShortcutOverlays(on: bar)
        // 重新加载候选栏：激活时数据源覆盖为快捷符号，去激活时恢复普通候选。
        fillCandidateBar(on: bar)
        return show
    }

    /// 旧叠层实现的防御性清理（升级会话内不应再出现）。
    private func removeLegacyNumberPadShortcutOverlays(on bar: CandidateBarView) {
        bar.subviews.first { $0.accessibilityIdentifier == "numberPadShortcuts" }?.removeFromSuperview()
        bar.collectionView.isHidden = false
        bar.collectionView.isUserInteractionEnabled = true
    }
}
