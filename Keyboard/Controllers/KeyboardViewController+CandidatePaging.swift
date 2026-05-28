import KeyboardCore
import UIKit

extension KeyboardViewController: UIScrollViewDelegate {
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        guard scrollView === candidateScrollView || scrollView === expandedPanelScrollView else { return }
        Logger.shared.debug(
            "candidate scroll begin: expanded=\(scrollView === expandedPanelScrollView), "
                + "items=\(accumulatedCandidates.count), offset=(\(Int(scrollView.contentOffset.x)),\(Int(scrollView.contentOffset.y))), "
                + "content=(\(Int(scrollView.contentSize.width)),\(Int(scrollView.contentSize.height)))",
            category: .display
        )
        Logger.shared.requestFlush()
    }

    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView === candidateScrollView || scrollView === expandedPanelScrollView {
            Logger.shared.debug(
                "candidate scroll endDrag: decelerate=\(decelerate), offset=(\(Int(scrollView.contentOffset.x)),\(Int(scrollView.contentOffset.y)))",
                category: .display
            )
            Logger.shared.requestFlush()
        }
        guard !decelerate else { return }
        requestMoreCandidatesIfNeeded(after: scrollView)
    }

    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView === candidateScrollView || scrollView === expandedPanelScrollView {
            Logger.shared.debug(
                "candidate scroll settled: offset=(\(Int(scrollView.contentOffset.x)),\(Int(scrollView.contentOffset.y))), "
                    + "content=(\(Int(scrollView.contentSize.width)),\(Int(scrollView.contentSize.height)))",
                category: .display
            )
            Logger.shared.requestFlush()
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

    /// Requests a later page without replacing `lastRimeOutput`, which remains the first-page selection state.
    func loadMoreCandidates() {
        guard let engine = controller.rimeEngine else { return }
        Logger.shared.info(
            "loadMoreCandidates START: accCount=\(accumulatedCandidates.count), depth=\(candidatePageDepth), expanded=\(isCandidateExpanded)",
            category: .display
        )
        Logger.shared.requestFlush()
        isLoadingMoreCandidates = true
        for _ in 0..<candidatePageDepth { _ = engine.pageDown() }
        let nextPage = engine.pageDown()
        let nextItems = nextPage.candidates.map { CandidateItem(title: $0.text, kind: .candidate) }
        for _ in 0..<(candidatePageDepth + 1) { _ = engine.pageUp() }
        Logger.shared.info(
            "loadMoreCandidates RIME: rawNewItems=\(nextItems.count), hasMorePages=\(nextPage.hasMorePages)",
            category: .display
        )

        var newAppended: [CandidateItem] = []
        var duplicateCount = 0
        for item in nextItems {
            if !accumulatedCandidates.contains(where: { $0.title == item.title }) {
                accumulatedCandidates.append(item)
                newAppended.append(item)
            } else {
                duplicateCount += 1
            }
        }
        hasMoreCandidates = nextPage.hasMorePages
        candidatePageDepth += 1
        isLoadingMoreCandidates = false
        if !newAppended.isEmpty {
            isCandidateExpanded ? appendToExpandedCandidatePanel() : appendToCandidateBar()
        }
        Logger.shared.info(
            "loadMoreCandidates DONE: +\(newAppended.count) new, \(duplicateCount) dup, total=\(accumulatedCandidates.count), depth=\(candidatePageDepth), hasMore=\(hasMoreCandidates)",
            category: .display
        )
        Logger.shared.requestFlush()
    }
}
