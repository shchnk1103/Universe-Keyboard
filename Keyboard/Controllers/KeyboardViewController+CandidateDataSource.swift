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
        if collectionView === pinyinPathCollectionView { return accumulatedPinyinPaths.count }
        if collectionView === candidateCollectionView { return presentedCandidates.count }
        if collectionView === expandedCandidateCollectionView { return presentedCandidates.count }
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        if collectionView === pinyinPathCollectionView {
            guard
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: T9PinyinPathCell.reuseID,
                    for: indexPath
                ) as? T9PinyinPathCell,
                accumulatedPinyinPaths.indices.contains(indexPath.item)
            else {
                return UICollectionViewCell()
            }
            cell.configure(path: accumulatedPinyinPaths[indexPath.item])
            return cell
        }

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
        if collectionView === pinyinPathCollectionView {
            guard accumulatedPinyinPaths.indices.contains(indexPath.item) else { return }
            let path = accumulatedPinyinPaths[indexPath.item]
            // Fail closed if the coherent composition snapshot moved.
            let pathState = controller.state.t9PinyinPathState
            guard pathState.compositionRevision == pinyinPathPanelGeneration,
                pathState.provenanceRevision == pinyinPathPanelProvenanceRevision
            else {
                dismissPinyinPathExpandedPanel(animated: true)
                return
            }
            emitFeedback(for: .commit)
            dismissPinyinPathExpandedPanel(animated: true)
            let effects = controller.handle(.selectT9PinyinPath(path))
            syncUI(with: effects.union(.t9PinyinPathsChanged))
            return
        }
        if collectionView === candidateCollectionView {
            let items = presentedCandidates
            guard items.indices.contains(indexPath.item) else { return }
            #if DEBUG
                recordCandidateSelectionDelivered()
            #endif
            commitCandidate(items[indexPath.item])
        } else if collectionView === expandedCandidateCollectionView {
            let items = presentedCandidates
            guard items.indices.contains(indexPath.item) else { return }
            commitExpandedCandidate(items[indexPath.item])
        }
    }

    /// UIKit 的 cell 可见性是候选栏“真实画面”而非 Core 快照的证据。
    /// 高保真事件只携带数量、revision 和终端方向，不记录候选索引或文字。
    func collectionView(
        _ collectionView: UICollectionView,
        willDisplay _: UICollectionViewCell,
        forItemAt _: IndexPath
    ) {
        guard collectionView === candidateCollectionView || collectionView === expandedCandidateCollectionView
        else { return }
        #if DEBUG
            scheduleCandidateVisibilityDiagnostic(for: collectionView)
        #endif
    }

    func collectionView(
        _ collectionView: UICollectionView,
        didEndDisplaying _: UICollectionViewCell,
        forItemAt _: IndexPath
    ) {
        guard collectionView === candidateCollectionView || collectionView === expandedCandidateCollectionView
        else { return }
        #if DEBUG
            scheduleCandidateVisibilityDiagnostic(for: collectionView)
        #endif
    }

    #if DEBUG
        /// UICollectionView reports visibility once per cell. Coalesce that
        /// layout burst and persist only the stable aggregate snapshot.
        private func scheduleCandidateVisibilityDiagnostic(for collectionView: UICollectionView) {
            guard isHighFidelityDiagnosticsActive else { return }
            candidateVisibilityDiagnosticsTask?.cancel()
            candidateVisibilityDiagnosticsTask = Task { @MainActor [weak self, weak collectionView] in
                try? await Task.sleep(for: .milliseconds(40))
                guard !Task.isCancelled,
                    let self,
                    let collectionView,
                    self.isHighFidelityDiagnosticsActive
                else { return }
                self.diagnosticsJournal.record(
                    code: .candidateVisibilityChanged,
                    category: .display,
                    appearanceID: self.diagnosticsAppearanceID,
                    fields: [
                        .count(.candidateCount, self.presentedCandidates.count),
                        .count(.visibleCandidateCellCount, collectionView.visibleCells.count),
                        .count(.revision, Int(clamping: self.controller.state.compositionRevision)),
                        .flag(.isCandidateBarVisible, !collectionView.visibleCells.isEmpty),
                    ]
                )
            }
        }

        func cancelCandidateVisibilityDiagnostic() {
            candidateVisibilityDiagnosticsTask?.cancel()
            candidateVisibilityDiagnosticsTask = nil
        }
    #endif

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        if collectionView === pinyinPathCollectionView {
            guard accumulatedPinyinPaths.indices.contains(indexPath.item) else {
                return CGSize(width: 44, height: 44)
            }
            let title = accumulatedPinyinPaths[indexPath.item].displayText
            let font = UIFont.systemFont(ofSize: 17, weight: .regular)
            let width = ceil((title as NSString).size(withAttributes: [.font: font]).width + 24)
            return CGSize(width: max(44, width), height: 44)
        }
        let items = presentedCandidates
        let isExpanded = collectionView === expandedCandidateCollectionView
        let visualHeight: CGFloat = isExpanded ? 38 : 32
        // The compact bar is 48 pt tall (34 pt visible bar + 14 pt gesture
        // bridge). A 32 pt cell was centered at y=8, leaving most of the
        // visible upper third outside every selectable cell. Expanding only
        // the cell bounds preserves the label's center and visual size.
        let itemHeight =
            isExpanded
            ? visualHeight + CandidateSizing.expandedVisualVerticalGap
            : candidateBarHeight + candidateToKeySpacing
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
            hintWidth =
                CandidateSizing.correctionHintSpacing
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
