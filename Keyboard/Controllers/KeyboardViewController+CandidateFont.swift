import KeyboardCore
import UIKit

extension KeyboardViewController {
    /// bootstrap与willAppear共用；只依赖存储和trait，不依赖尚未创建的Core控制器。
    /// 主线程内先发布快照、失效缓存、重配可见cell，再返回到既有展示/高度流程。
    func prepareCandidateFontForAppearance() {
        let settings: CandidateFontSettings
        if candidateFontNeedsRead {
            let raw: Any?
            if let source = candidateFontValueSource {
                raw = source()
            } else {
                raw = sharedDefaults?.object(forKey: CandidateFontSettings.storageKey)
            }
            settings = CandidateFontSettings(savedValue: raw)
            candidateFontNeedsRead = false
        } else {
            // 预创建到真正出现之间trait可能改变；重用档位，不再次读取共享设置。
            guard
                candidateFontSnapshot.traits.preferredContentSizeCategory
                    != traitCollection.preferredContentSizeCategory
            else { return }
            settings = candidateFontSnapshot.settings
        }
        candidateFontSnapshot = CandidateFontSnapshot(settings: settings, traits: traitCollection)
        candidateCellSizeCache.removeAll(keepingCapacity: true)
        for collection in [candidateCollectionView, expandedCandidateCollectionView].compactMap({ $0 }) {
            for cell in collection.visibleCells.compactMap({ $0 as? CandidateCollectionCell }) {
                cell.applyFontSnapshot(candidateFontSnapshot)
            }
            collection.collectionViewLayout.invalidateLayout()
            collection.reloadData()
        }
    }
}
