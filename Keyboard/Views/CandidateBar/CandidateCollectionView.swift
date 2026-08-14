import KeyboardCore
import UIKit

@MainActor
enum CandidateTouchDiagnostics {
    private static var cachedDisplayEnabled = false

    static var isEnabled: Bool {
        cachedDisplayEnabled
    }

    /// 与其他共享设置一起在键盘启动/重新显示时刷新。
    /// 触控回调只读取内存值，避免在 `pointInside` / `hitTest` 中访问 App Group。
    static func refreshFromSharedSettings() {
        cachedDisplayEnabled = Logger.isLiveCategoryEnabled(.display)
    }
    static let minimumLogInterval: CFTimeInterval = 0.08

    static func viewName(_ view: UIView?) -> String {
        guard let view else { return "nil" }
        return String(describing: type(of: view))
    }

    static func viewPath(_ view: UIView?, limit: Int = 4) -> String {
        guard let view else { return "nil" }
        var parts: [String] = []
        var current: UIView? = view
        var depth = 0
        while let node = current, depth < limit {
            parts.append(String(describing: type(of: node)))
            current = node.superview
            depth += 1
        }
        return parts.joined(separator: "<")
    }

    static func gestureStateName(_ state: UIGestureRecognizer.State) -> String {
        switch state {
        case .possible: return "possible"
        case .began: return "began"
        case .changed: return "changed"
        case .ended: return "ended"
        case .cancelled: return "cancelled"
        case .failed: return "failed"
        @unknown default: return "unknown"
        }
    }

    static func pointDescription(_ point: CGPoint) -> String {
        "(\(Int(point.x)),\(Int(point.y)))"
    }
}

final class CandidateCollectionView: UICollectionView {
    private var lastPointInsideDiagnosticLogTime: CFTimeInterval = 0
    private var lastHitTestDiagnosticLogTime: CFTimeInterval = 0
    private var lastPanDiagnosticLogTime: CFTimeInterval = 0
    private var lastPanDiagnosticState: UIGestureRecognizer.State = .possible
    #if DEBUG
        var onCandidateGestureTerminal: ((_ didBegin: Bool, _ wasCancelled: Bool) -> Void)?
        private var didCurrentPanBegin = false
    #endif

    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        panGestureRecognizer.addTarget(self, action: #selector(logPanState(_:)))
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let result = super.point(inside: point, with: event)
        logTouch(
            "collection pointInside",
            point: point,
            lastLogTime: &lastPointInsideDiagnosticLogTime,
            extra: "inside=\(result)"
        )
        return result
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let result = super.hitTest(point, with: event)
        let indexPath = indexPathForItem(at: point)
        let resolved = resolvedItemHitView(
            at: point,
            indexPath: indexPath,
            defaultHit: result,
            event: event
        )
        logTouch(
            "collection hitTest",
            point: point,
            lastLogTime: &lastHitTestDiagnosticLogTime,
            extra: "hit=\(CandidateTouchDiagnostics.viewName(resolved)) "
                + "raw=\(CandidateTouchDiagnostics.viewName(result)) "
                + "index=\(indexPath.map { String($0.item) } ?? "nil") "
                + "pan=\(CandidateTouchDiagnostics.gestureStateName(panGestureRecognizer.state))"
        )
        return resolved
    }

    /// Layout already owns this point (`indexPathForItem`). If a non-item chrome
    /// view — typically an iOS 26 scroll-edge `UIView` — sits in front of the
    /// cell, selection never fires. Prefer the cell without changing its frame.
    private func resolvedItemHitView(
        at point: CGPoint,
        indexPath: IndexPath?,
        defaultHit: UIView?,
        event: UIEvent?
    ) -> UIView? {
        guard let indexPath, let cell = cellForItem(at: indexPath) else {
            return defaultHit
        }
        if let defaultHit, defaultHit === cell || defaultHit.isDescendant(of: cell) {
            return defaultHit
        }
        let cellPoint = convert(point, to: cell)
        return cell.hitTest(cellPoint, with: event) ?? cell
    }

    @objc private func logPanState(_ recognizer: UIPanGestureRecognizer) {
        #if DEBUG
            recordStructuredPanTerminalIfNeeded(recognizer.state)
        #endif
        guard CandidateTouchDiagnostics.isEnabled else { return }
        let now = CACurrentMediaTime()
        let state = recognizer.state
        let isStateTransition = state != lastPanDiagnosticState
        guard isStateTransition || now - lastPanDiagnosticLogTime >= CandidateTouchDiagnostics.minimumLogInterval else {
            return
        }
        lastPanDiagnosticLogTime = now
        lastPanDiagnosticState = state
        let point = recognizer.location(in: self)
        let translation = recognizer.translation(in: self)
        let velocity = recognizer.velocity(in: self)
        Logger.shared.debug(
            "candidateTouch collection pan state=\(CandidateTouchDiagnostics.gestureStateName(state)) "
                + "point=\(CandidateTouchDiagnostics.pointDescription(point)) "
                + "translation=\(CandidateTouchDiagnostics.pointDescription(translation)) "
                + "velocity=\(CandidateTouchDiagnostics.pointDescription(velocity))",
            category: .display
        )
    }

    #if DEBUG
        private func recordStructuredPanTerminalIfNeeded(_ state: UIGestureRecognizer.State) {
            switch state {
            case .began:
                didCurrentPanBegin = true
            case .ended, .cancelled, .failed:
                onCandidateGestureTerminal?(didCurrentPanBegin, state == .cancelled)
                didCurrentPanBegin = false
            default:
                break
            }
        }
    #endif

    private func logTouch(
        _ name: String,
        point: CGPoint,
        lastLogTime: inout CFTimeInterval,
        extra: String
    ) {
        guard CandidateTouchDiagnostics.isEnabled else { return }
        let now = CACurrentMediaTime()
        guard now - lastLogTime >= CandidateTouchDiagnostics.minimumLogInterval else { return }
        lastLogTime = now
        Logger.shared.debug(
            "candidateTouch \(name) point=\(CandidateTouchDiagnostics.pointDescription(point)) "
                + "bounds=\(Int(bounds.width))x\(Int(bounds.height)) \(extra)",
            category: .display
        )
    }
}
