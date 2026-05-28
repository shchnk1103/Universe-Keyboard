import KeyboardCore
import UIKit

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
        cell.configure(with: item, preferred: indexPath.item == 0 && item.kind == .candidate, expanded: isExpanded)
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
        guard items.indices.contains(indexPath.item) else { return CGSize(width: 44, height: 38) }
        let item = items[indexPath.item]
        let fontSize: CGFloat = item.kind == .composition ? 14 : 16
        let weight: UIFont.Weight = indexPath.item == 0 && item.kind == .candidate ? .semibold : .regular
        let font = UIFontMetrics(forTextStyle: .body).scaledFont(
            for: .systemFont(ofSize: fontSize, weight: weight),
            maximumPointSize: 28
        )
        let horizontalInsets: CGFloat = indexPath.item == 0 ? 16 : 24
        let naturalWidth = max(
            44, ceil((item.title as NSString).size(withAttributes: [.font: font]).width + horizontalInsets))
        if collectionView === candidateCollectionView { return CGSize(width: naturalWidth, height: 38) }
        return CGSize(width: min(max(44, collectionView.bounds.width - 16), naturalWidth), height: 38)
    }

    private func commitCandidate(_ item: CandidateItem) {
        playKeyClick()
        playHaptic()
        let effects = controller.handle(.insertCandidate(item.title, kind: item.kind))
        syncUI(with: effects)
    }
}
