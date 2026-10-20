import KeyboardCore
import UIKit

/// A presentation validity token, read from existing publication/lifecycle state. Not selection authority.
struct CandidateReadingSnapshot: Equatable {
    let generation: Int
    let publishedRevision: UInt64
    let liveRevision: UInt64
    let publishedOrigin: RimeOutputOrigin?
    let liveOrigin: RimeOutputOrigin?
    let rawInput: String?
    let compactView: ObjectIdentifier?
}

/// One observed cell, not a second candidate list. Index is used only after snapshot + value validation.
struct CandidateReadingAnchor {
    let index: Int
    let item: CandidateItem
    let visibleFraction: CGFloat
    let leadingOffset: CGFloat

    func isValid(in items: [CandidateItem]) -> Bool {
        items.indices.contains(index) && items[index] == item
    }

    static func capture(
        in collection: UICollectionView, items: [CandidateItem], horizontal: Bool, occluded: CGRect = .null
    ) -> CandidateReadingAnchor? {
        guard collection.numberOfItems(inSection: 0) == items.count else { return nil }
        let viewport = collection.bounds
        let attributes = (collection.collectionViewLayout.layoutAttributesForElements(in: viewport) ?? [])
            .filter { $0.representedElementCategory == .cell && items.indices.contains($0.indexPath.item) }
            .sorted { $0.indexPath.item < $1.indexPath.item }
        var fallback: CandidateReadingAnchor?
        var largestExtent: CGFloat = 0
        for attribute in attributes {
            let visible = attribute.frame.intersection(viewport)
            guard !visible.isNull, visible.width > 0, visible.height > 0 else { continue }
            let covered = visible.intersection(occluded)
            // Exclude cells entirely under the fixed action; outside portions still belong to candidates.
            if !covered.isNull && covered.width >= visible.width && covered.height >= visible.height { continue }
            let extent = horizontal ? visible.width : visible.height
            let fullExtent = horizontal ? attribute.frame.width : attribute.frame.height
            let anchor = CandidateReadingAnchor(
                index: attribute.indexPath.item, item: items[attribute.indexPath.item],
                visibleFraction: extent / max(1, fullExtent),
                leadingOffset: horizontal ? attribute.frame.minX - viewport.minX : attribute.frame.minY - viewport.minY)
            let threshold = min(
                fullExtent,
                max(
                    KeyboardDesignTokens.ExpandedCandidates.minimumReadableExtent,
                    fullExtent * KeyboardDesignTokens.ExpandedCandidates.minimumReadableFraction))
            if extent >= threshold { return anchor }
            if extent > largestExtent { fallback = anchor; largestExtent = extent }
        }
        // Degenerate/small viewports: keep the most visible real item, never invent an IndexPath.
        return fallback
    }
}

final class CandidateReadingPosition {
    var snapshot: CandidateReadingSnapshot
    var entryAnchor: CandidateReadingAnchor?
    var compactOffset: CGPoint
    var userScrolled = false

    init(snapshot: CandidateReadingSnapshot, anchor: CandidateReadingAnchor?, compactOffset: CGPoint) {
        self.snapshot = snapshot
        entryAnchor = anchor
        self.compactOffset = compactOffset
    }

    func reset(to snapshot: CandidateReadingSnapshot) {
        self.snapshot = snapshot
        entryAnchor = nil
        compactOffset = .zero
        userScrolled = false
    }
}

extension KeyboardViewController {
    var currentCandidateReadingSnapshot: CandidateReadingSnapshot {
        CandidateReadingSnapshot(
            generation: candidateSnapshotGeneration, publishedRevision: candidateSnapshotCompositionRevision,
            liveRevision: controller.state.compositionRevision, publishedOrigin: candidateSnapshotOrigin,
            liveOrigin: controller.state.lastRimeOutput?.candidateOrigin, rawInput: candidateSnapshotRawInput,
            compactView: candidateCollectionView.map(ObjectIdentifier.init))
    }

    func restoreCompactReadingPosition(from panel: ExpandedCandidatePanelContainerView) {
        guard let compact = candidateCollectionView else { return }
        // The active vertical scroll is ending with this view; do not leave paging in a dragging state.
        if let expanded = expandedCandidateCollectionView {
            expanded.setContentOffset(expanded.contentOffset, animated: false)
        }
        isCandidateScrollInteracting = false
        // Expanded paging updates only its active view. Rebind the same published list before positioning.
        compact.reloadData()
        compact.layoutIfNeeded()
        guard let position = panel.readingPosition,
            position.snapshot == currentCandidateReadingSnapshot,
            !shouldBlockT9RecoveryPresentation
        else { compact.setContentOffset(.zero, animated: false); return }
        let items = presentedCandidates
        if !position.userScrolled, position.entryAnchor?.isValid(in: items) == true {
            let maxX = max(0, compact.contentSize.width - compact.bounds.width)
            compact.setContentOffset(CGPoint(x: min(maxX, max(0, position.compactOffset.x)), y: 0), animated: false)
            return
        }
        guard position.userScrolled, let expanded = expandedCandidateCollectionView,
            let anchor = CandidateReadingAnchor.capture(
                in: expanded, items: items, horizontal: false, occluded: panel.actionFrame(in: expanded)),
            anchor.isValid(in: items),
            let attributes = compact.layoutAttributesForItem(at: IndexPath(item: anchor.index, section: 0))
        else { compact.setContentOffset(.zero, animated: false); return }
        let maxX = max(0, compact.contentSize.width - compact.bounds.width)
        compact.setContentOffset(CGPoint(x: min(maxX, max(0, attributes.frame.minX)), y: 0), animated: false)
    }
}
