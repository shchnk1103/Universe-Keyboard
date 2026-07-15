import KeyboardCore
import UIKit

private enum CandidateSizing {
    /// 视觉间距并入 cell 尺寸；layout spacing 保持为 0，避免候选之间出现真实触控空洞。
    static let visualHorizontalGap: CGFloat = 4
    static let expandedVisualVerticalGap: CGFloat = 4
    static let minimumTouchWidth: CGFloat = 44
    static let correctionHintSpacing: CGFloat = 3
}

/// 使用结构化键避免每次布局查询都拼接包含候选文本的临时字符串。
struct CandidateCellSizeCacheKey: Hashable {
    let isExpanded: Bool
    let isPreferred: Bool
    let collectionWidth: Int
    let kindRawValue: Int
    let title: String
    let correctionHint: String?
}

extension KeyboardViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    /// `resetCandidateSnapshotFromController()` 在唯一重建边界移除 placeholder。
    /// 分页窗口只生成普通 RIME candidate，因此数据源回调可以直接复用同一数组。
    var presentedCandidates: [CandidateItem] {
        accumulatedCandidates
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView === candidateCollectionView { return presentedCandidates.count }
        if collectionView === expandedCandidateCollectionView { return presentedCandidates.count }
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
        let items = presentedCandidates
        guard items.indices.contains(indexPath.item) else { return cell }
        let item = items[indexPath.item]
        cell.configure(with: item, preferred: isPreferredCandidate(item, at: indexPath.item), expanded: isExpanded)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView === candidateCollectionView {
            let items = presentedCandidates
            guard items.indices.contains(indexPath.item) else { return }
            commitCandidate(items[indexPath.item])
        } else if collectionView === expandedCandidateCollectionView {
            let items = presentedCandidates
            guard items.indices.contains(indexPath.item) else { return }
            commitExpandedCandidate(items[indexPath.item])
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let items = presentedCandidates
        let isExpanded = collectionView === expandedCandidateCollectionView
        let visualHeight: CGFloat = isExpanded ? 38 : 32
        let itemHeight = visualHeight + (isExpanded ? CandidateSizing.expandedVisualVerticalGap : 0)
        guard items.indices.contains(indexPath.item) else { return CGSize(width: 44, height: itemHeight) }
        let item = items[indexPath.item]
        let preferred = isPreferredCandidate(item, at: indexPath.item)
        let title = item.title
        let correctionHint = correctionHint(for: item)
        let cacheKey = CandidateCellSizeCacheKey(
            isExpanded: isExpanded,
            isPreferred: preferred,
            collectionWidth: Int(collectionView.bounds.width),
            kindRawValue: item.kind.rawValue,
            title: title,
            correctionHint: correctionHint
        )
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
        index == 0
            && (item.kind == .candidate
                || item.kind == .correctionCandidate
                || item.kind == .continuationCandidate)
    }

    private func correctionHint(for item: CandidateItem) -> String? {
        guard let correction = item.correction else { return nil }
        let summary = correction.edits.map { "\($0.original)→\($0.replacement)" }.joined(separator: " ")
        return summary.isEmpty ? nil : summary
    }
}
