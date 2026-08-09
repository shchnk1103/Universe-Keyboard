import UIKit

/// Content-free UIKit tracking terminals used only by Debug diagnostics.
/// They describe pointer lifecycle, never the key label or document content.
enum KeyboardKeyTrackingPhase: String {
    case began
    case endedInside
    case endedOutside
    case cancelled
}

final class KeyboardKeyButton: UIButton {
    /// UIControl still asks the target button whether a tracked touch is inside.
    /// The root hit-test stack assigns visual gaps to explicit per-key cells, and
    /// this slop keeps small finger drift valid through touch-up and long press.
    var touchSlop: CGFloat = 4
    var expandedTouchOutsets: UIEdgeInsets = .zero
    var visualStyle: KeyVisualStyle = .character

    #if DEBUG
    /// Kept on the button so diagnostics see UIKit's real tracking terminals,
    /// including cancellations that do not result in a business key action.
    var trackingEventHandler: ((KeyboardKeyButton, KeyboardKeyTrackingPhase) -> Void)?
    #endif

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        guard isEnabled, !isHidden, alpha > 0.01 else {
            return false
        }
        let outsets = UIEdgeInsets(
            top: -max(touchSlop, expandedTouchOutsets.top),
            left: -max(touchSlop, expandedTouchOutsets.left),
            bottom: -max(touchSlop, expandedTouchOutsets.bottom),
            right: -max(touchSlop, expandedTouchOutsets.right)
        )
        return bounds.inset(by: outsets).contains(point)
    }

    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let accepted = super.beginTracking(touch, with: event)
        #if DEBUG
        if accepted {
            trackingEventHandler?(self, .began)
        }
        #endif
        return accepted
    }

    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        #if DEBUG
        let phase: KeyboardKeyTrackingPhase
        if let touch {
            phase = point(inside: touch.location(in: self), with: event) ? .endedInside : .endedOutside
        } else {
            phase = .endedOutside
        }
        trackingEventHandler?(self, phase)
        #endif
        super.endTracking(touch, with: event)
    }

    override func cancelTracking(with event: UIEvent?) {
        #if DEBUG
        trackingEventHandler?(self, .cancelled)
        #endif
        super.cancelTracking(with: event)
    }
}
