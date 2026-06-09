import UIKit

/// Presentation-only styling for candidate scroll views.
///
/// iOS 26 adds `UIScrollEdgeEffect` to scroll views. Inside the system keyboard
/// glass container, that edge effect visually washes the first candidate row,
/// so candidate lists opt out while keeping normal scrolling behavior.
@MainActor
enum CandidateScrollViewStyle {
    static func apply(to collectionView: UICollectionView) {
        collectionView.backgroundColor = .clear
        collectionView.backgroundView = nil
        collectionView.isOpaque = false
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.automaticallyAdjustsScrollIndicatorInsets = false

        if #available(iOS 26.0, *) {
            collectionView.topEdgeEffect.isHidden = true
            collectionView.leftEdgeEffect.isHidden = true
            collectionView.bottomEdgeEffect.isHidden = true
            collectionView.rightEdgeEffect.isHidden = true
        }
    }
}
