import KeyboardCore
import UIKit

private final class WeakKeyboardViewControllerReference {
    weak var value: KeyboardViewController?

    init(_ value: KeyboardViewController) {
        self.value = value
    }
}

extension KeyboardViewController: UIScrollViewDelegate {
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        guard scrollView === candidateScrollView || scrollView === expandedPanelScrollView else { return }
        isCandidateScrollInteracting = true
#if DEBUG
        Logger.shared.debug(
            "candidate scroll begin: expanded=\(scrollView === expandedPanelScrollView), "
                + "items=\(accumulatedCandidates.count), offset=(\(Int(scrollView.contentOffset.x)),\(Int(scrollView.contentOffset.y))), "
                + "content=(\(Int(scrollView.contentSize.width)),\(Int(scrollView.contentSize.height)))",
            category: .display
        )
        Logger.shared.requestFlush()
#endif
    }

    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard scrollView === candidateScrollView || scrollView === expandedPanelScrollView else { return }
#if DEBUG
        Logger.shared.debug(
            "candidate scroll endDrag: decelerate=\(decelerate), offset=(\(Int(scrollView.contentOffset.x)),\(Int(scrollView.contentOffset.y)))",
            category: .display
        )
        Logger.shared.requestFlush()
#endif
        guard !decelerate else { return }
        isCandidateScrollInteracting = false
        requestMoreCandidatesIfNeeded(after: scrollView)
        runDeferredCandidatePrefetchIfNeeded()
    }

    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard scrollView === candidateScrollView || scrollView === expandedPanelScrollView else { return }
#if DEBUG
        Logger.shared.debug(
            "candidate scroll settled: offset=(\(Int(scrollView.contentOffset.x)),\(Int(scrollView.contentOffset.y))), "
                + "content=(\(Int(scrollView.contentSize.width)),\(Int(scrollView.contentSize.height)))",
            category: .display
        )
        Logger.shared.requestFlush()
#endif
        isCandidateScrollInteracting = false
        requestMoreCandidatesIfNeeded(after: scrollView)
        runDeferredCandidatePrefetchIfNeeded()
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
#if DEBUG
            Logger.shared.debug("candidate paging after scrolling settled", category: .display)
#endif
            scheduleCandidatePrefetch(mode: scrollView === expandedPanelScrollView ? .expanded : .bar)
        }
    }

    func scheduleCandidatePrefetch(mode: CandidatePrefetchMode) {
        let generation = candidateSnapshotGeneration
        candidatePrefetchRequestSerial += 1
        let requestSerial = candidatePrefetchRequestSerial
        let delay: TimeInterval
        switch mode {
        case .expanded:
            delay = 0.04
        case .bar:
            // 预取仍在主线程访问 librime；给当前按键和首屏渲染让出一小段时间。
            delay = accumulatedCandidates.count < 36 ? 0.06 : 0.14
        }
        let scheduledOwner = WeakKeyboardViewControllerReference(self)
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            // default mode 会避开用户拖动时的 tracking run loop，降低横向候选栏滑动被 RIME 查询打断的概率。
            RunLoop.main.perform(inModes: [.default]) {
                Task { @MainActor in
                    scheduledOwner.value?.runScheduledCandidatePrefetch(
                        mode: mode,
                        generation: generation,
                        requestSerial: requestSerial
                    )
                }
            }
        }
    }

    private func runScheduledCandidatePrefetch(
        mode: CandidatePrefetchMode,
        generation: Int,
        requestSerial: Int
    ) {
        guard candidateSnapshotGeneration == generation,
            candidatePrefetchRequestSerial == requestSerial,
            hasMoreCandidates,
            !isLoadingMoreCandidates
        else { return }
        if mode == .expanded, !isCandidateExpanded { return }
        if mode == .bar, isCandidateExpanded { return }
        guard !isCandidateScrollInteracting else {
            deferredCandidatePrefetchMode = mode
            return
        }
        loadMoreCandidates(mode: mode)
    }

    /// Reads later candidates by global index without changing the current RIME page.
    func loadMoreCandidates(mode: CandidatePrefetchMode? = nil) {
        guard let engine = controller.rimeEngine else { return }
        guard !isCandidateScrollInteracting else {
            deferredCandidatePrefetchMode = mode ?? candidatePrefetchMode
            return
        }
        let activeMode = mode ?? candidatePrefetchMode
        if activeMode == .expanded, !isCandidateExpanded { return }
        if activeMode == .bar, isCandidateExpanded { return }
        let batchLimit = batchLimitForCandidatePrefetch(mode: activeMode)
        let startIndex = nextCandidateGlobalIndex
        let generation = candidateSnapshotGeneration
        let rawInput = candidateSnapshotRawInput
#if DEBUG
        Logger.shared.info(
            "loadMoreCandidates START: start=\(startIndex), limit=\(batchLimit), mode=\(activeMode), "
                + "rawLength=\(rawInput?.count ?? 0), total=\(accumulatedCandidates.count)",
            category: .display
        )
        Logger.shared.requestFlush()
#endif
        isLoadingMoreCandidates = true
        let loadStart = CACurrentMediaTime()
        let window = engine.candidateWindow(from: startIndex, limit: batchLimit)
        guard candidateSnapshotGeneration == generation,
            candidateSnapshotRawInput == rawInput
        else {
            isLoadingMoreCandidates = false
#if DEBUG
            Logger.shared.debug("loadMoreCandidates discarded stale generation", category: .display)
#endif
            return
        }
        let nextItems = window.candidates.enumerated().map { offset, candidate in
            let globalIndex = candidate.globalIndex ?? (window.startIndex + offset)
            return CandidateItem.rimeCandidate(
                candidate,
                page: pageForGlobalCandidateIndex(globalIndex),
                indexOnPage: indexOnPageForGlobalCandidateIndex(globalIndex),
                globalIndex: globalIndex
            )
        }
#if DEBUG
        Logger.shared.info(
            "loadMoreCandidates RIME: rawNewItems=\(nextItems.count), hasMore=\(window.hasMoreCandidates)",
            category: .display
        )
#endif

        var newAppended: [CandidateItem] = []
        var loadedGlobalIndices = Set(
            accumulatedCandidates.compactMap { $0.selectionReference?.globalIndex }
        )
        // 保留旧的 Optional 索引去重语义；正常 candidateWindow 会为每项补齐全局索引。
        var hasLoadedCandidateWithoutGlobalIndex = accumulatedCandidates.contains {
            $0.selectionReference?.globalIndex == nil
        }
#if DEBUG
        var duplicateCount = 0
#endif
        for item in nextItems {
            let isNewCandidate: Bool
            if let globalIndex = item.selectionReference?.globalIndex {
                isNewCandidate = loadedGlobalIndices.insert(globalIndex).inserted
            } else {
                isNewCandidate = !hasLoadedCandidateWithoutGlobalIndex
                hasLoadedCandidateWithoutGlobalIndex = true
            }

            if isNewCandidate {
                accumulatedCandidates.append(item)
                newAppended.append(item)
            } else {
#if DEBUG
                duplicateCount += 1
#endif
            }
        }
        nextCandidateGlobalIndex = max(nextCandidateGlobalIndex, window.nextIndex)
        hasMoreCandidates = window.hasMoreCandidates
        if nextItems.isEmpty, window.nextIndex <= startIndex {
            hasMoreCandidates = false
            Logger.shared.warning(
                "candidate prefetch stopped: empty window without index progress start=\(startIndex) mode=\(activeMode)",
                category: .display
            )
        }
        candidatePageDepth = max(0, nextCandidateGlobalIndex - accumulatedCandidates.count)
        isLoadingMoreCandidates = false
        if !newAppended.isEmpty {
            isCandidateExpanded
                ? appendToExpandedCandidatePanel(insertedCount: newAppended.count)
                : appendToCandidateBar(insertedCount: newAppended.count)
        }
        let elapsedMs = (CACurrentMediaTime() - loadStart) * 1000
#if DEBUG
        Logger.shared.info(
            "loadMoreCandidates DONE: +\(newAppended.count) new, \(duplicateCount) dup, total=\(accumulatedCandidates.count), "
                + "next=\(nextCandidateGlobalIndex), hasMore=\(hasMoreCandidates), durationMs=\(String(format: "%.1f", elapsedMs))",
            category: .display
        )
#endif
        if elapsedMs >= 30 {
            Logger.shared.warning(
                "SLOW candidate prefetch duration=\(String(format: "%.1f", elapsedMs))ms "
                    + "start=\(startIndex) limit=\(batchLimit) mode=\(activeMode) rawLength=\(rawInput?.count ?? 0)",
                category: .performance
            )
        }
#if DEBUG
        Logger.shared.requestFlush()
#endif
        if shouldContinuePrefetching(mode: activeMode, elapsedMs: elapsedMs) {
            scheduleCandidatePrefetch(mode: activeMode)
        }
    }

    private func shouldContinuePrefetching(mode: CandidatePrefetchMode, elapsedMs: Double) -> Bool {
        guard hasMoreCandidates, !isLoadingMoreCandidates, elapsedMs < 24 else { return false }
        switch mode {
        case .bar:
            return accumulatedCandidates.count < 48
        case .expanded:
            return isCandidateExpanded && accumulatedCandidates.count < 80
        }
    }

    private func batchLimitForCandidatePrefetch(mode: CandidatePrefetchMode) -> Int {
        switch mode {
        case .bar:
            return accumulatedCandidates.count < 48 ? 16 : 8
        case .expanded:
            return accumulatedCandidates.count < 80 ? 24 : 12
        }
    }

    private func runDeferredCandidatePrefetchIfNeeded() {
        guard let mode = deferredCandidatePrefetchMode else { return }
        deferredCandidatePrefetchMode = nil
        scheduleCandidatePrefetch(mode: mode)
    }

    private func pageForGlobalCandidateIndex(_ globalIndex: Int) -> Int {
        guard let pageSize = controller.state.lastRimeOutput?.candidates.count, pageSize > 0 else { return 0 }
        return globalIndex / pageSize
    }

    private func indexOnPageForGlobalCandidateIndex(_ globalIndex: Int) -> Int {
        guard let pageSize = controller.state.lastRimeOutput?.candidates.count, pageSize > 0 else { return globalIndex }
        return globalIndex % pageSize
    }
}
