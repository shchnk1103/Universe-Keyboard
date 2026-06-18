import KeyboardCore
import UIKit

@MainActor
enum CandidateTouchDiagnostics {
    private static var cachedDisplayEnabled = false
    private static var lastRefreshTime: CFTimeInterval = 0

    static var isEnabled: Bool {
        let now = CACurrentMediaTime()
        guard now - lastRefreshTime >= 0.25 else {
            return cachedDisplayEnabled
        }
        lastRefreshTime = now
        cachedDisplayEnabled = Logger.isLiveCategoryEnabled(.display)
        return cachedDisplayEnabled
    }
    static let minimumLogInterval: CFTimeInterval = 0.08

    static func viewName(_ view: UIView?) -> String {
        guard let view else { return "nil" }
        return String(describing: type(of: view))
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
        logTouch(
            "collection hitTest",
            point: point,
            lastLogTime: &lastHitTestDiagnosticLogTime,
            extra: "hit=\(CandidateTouchDiagnostics.viewName(result)) "
                + "index=\(indexPath.map { String($0.item) } ?? "nil") "
                + "pan=\(CandidateTouchDiagnostics.gestureStateName(panGestureRecognizer.state))"
        )
        return result
    }

    @objc private func logPanState(_ recognizer: UIPanGestureRecognizer) {
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
