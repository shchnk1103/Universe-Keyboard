import KeyboardCore
import UIKit

private enum CandidateSizing {
    /// 视觉间距并入 cell 尺寸；layout spacing 保持为 0，避免候选之间出现真实触控空洞。
    static let visualHorizontalGap: CGFloat = 4
    static let expandedVisualVerticalGap: CGFloat = 4
    static let minimumTouchWidth: CGFloat = 44
    static let correctionHintSpacing: CGFloat = 3
}

extension KeyboardViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    var horizontalVisibleCandidates: [CandidateItem] {
        accumulatedCandidates.filter { $0.kind != .placeholder }
    }

    private var expandedVisibleCandidates: [CandidateItem] {
        accumulatedCandidates.filter { $0.kind != .placeholder }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView === candidateCollectionView { return horizontalVisibleCandidates.count }
        if collectionView === expandedCandidateCollectionView { return expandedVisibleCandidates.count }
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let isExpanded = collectionView === expandedCandidateCollectionView
        let identifier =
            isExpanded ? CandidateCollectionCell.expandedReuseIdentifier : CandidateCollectionCell.barReuseIdentifier
        guard collectionView === candidateCollectionView || isExpanded,
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
                as? CandidateCollectionCell
        else {
            return UICollectionViewCell()
        }
        let items = isExpanded ? expandedVisibleCandidates : horizontalVisibleCandidates
        guard items.indices.contains(indexPath.item) else { return cell }
        let item = items[indexPath.item]
        cell.configure(with: item, preferred: isPreferredCandidate(item, at: indexPath.item), expanded: isExpanded)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView === candidateCollectionView {
            let items = horizontalVisibleCandidates
            guard items.indices.contains(indexPath.item) else { return }
            commitCandidate(items[indexPath.item])
        } else if collectionView === expandedCandidateCollectionView {
            let items = expandedVisibleCandidates
            guard items.indices.contains(indexPath.item) else { return }
            commitExpandedCandidate(items[indexPath.item])
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let items = collectionView === candidateCollectionView ? horizontalVisibleCandidates : expandedVisibleCandidates
        let isExpanded = collectionView === expandedCandidateCollectionView
        let visualHeight: CGFloat = isExpanded ? 38 : 32
        let itemHeight = visualHeight + (isExpanded ? CandidateSizing.expandedVisualVerticalGap : 0)
        guard items.indices.contains(indexPath.item) else { return CGSize(width: 44, height: itemHeight) }
        let item = items[indexPath.item]
        let preferred = isPreferredCandidate(item, at: indexPath.item)
        let title = item.title
        let correctionHint = correctionHint(for: item)
        let cacheKey =
            "\(isExpanded)|\(preferred)|\(Int(collectionView.bounds.width))|\(item.kind.rawValue)|\(title)|\(correctionHint ?? "")"
        if let cachedSize = candidateCellSizeCache[cacheKey] {
            return cachedSize
        }

        let fontSize: CGFloat = item.kind == .composition ? 15 : 17
        let weight: UIFont.Weight = preferred ? .semibold : .regular
        let font = UIFontMetrics(forTextStyle: .body).scaledFont(
            for: .systemFont(ofSize: fontSize, weight: weight),
            maximumPointSize: 28
        )
        let titleInsets: CGFloat = preferred ? 16 : 24
        let titleWidth = ceil((title as NSString).size(withAttributes: [.font: font]).width + titleInsets)
        let hintWidth: CGFloat
        if let correctionHint {
            let hintFont = UIFontMetrics(forTextStyle: .caption1).scaledFont(
                for: .systemFont(ofSize: 13, weight: .semibold),
                maximumPointSize: 18
            )
            hintWidth = CandidateSizing.correctionHintSpacing
                + ceil((correctionHint as NSString).size(withAttributes: [.font: hintFont]).width)
        } else {
            hintWidth = 0
        }
        let naturalWidth = max(
            CandidateSizing.minimumTouchWidth,
            titleWidth + hintWidth
        )
        let size: CGSize
        if collectionView === candidateCollectionView {
            size = CGSize(width: naturalWidth + CandidateSizing.visualHorizontalGap, height: itemHeight)
        } else {
            let maxWidth = max(44, collectionView.bounds.width - 16)
            size = CGSize(
                width: min(maxWidth, naturalWidth + CandidateSizing.visualHorizontalGap),
                height: itemHeight
            )
        }
        candidateCellSizeCache[cacheKey] = size
        return size
    }

    private func commitCandidate(_ item: CandidateItem) {
        emitFeedback(for: .commit)
        let effects: KeyboardEffect
        if let correction = item.correction {
            effects = controller.handle(.insertCorrectionCandidate(correction))
        } else {
            effects = controller.handle(
                .insertCandidate(
                    item.title,
                    kind: item.kind,
                    selectionReference: item.selectionReference
                )
            )
        }
        syncUI(with: effects)
    }

    private func isPreferredCandidate(_ item: CandidateItem, at index: Int) -> Bool {
        index == 0 && (item.kind == .candidate || item.kind == .correctionCandidate)
    }

    private func correctionHint(for item: CandidateItem) -> String? {
        guard let correction = item.correction else { return nil }
        let summary = correction.edits.map { "\($0.original)→\($0.replacement)" }.joined(separator: " ")
        return summary.isEmpty ? nil : summary
    }
}
