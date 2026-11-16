import UIKit

/// Content-free UIKit tracking terminals used only by Debug diagnostics.
/// They describe pointer lifecycle, never the key label or document content.
enum KeyboardKeyTrackingPhase: String {
    case began
    case endedInside
    case endedOutside
    case cancelled
}

/// Tracking lifecycle events forwarded from an ordinary character key button
/// to `KeyboardViewController`'s press-order rollover coordinator.
enum OrdinaryKeyTrackingEvent {
    case began(ObjectIdentifier)
    case dragExit(ObjectIdentifier)
    case endedInside(ObjectIdentifier?)
    case endedOutside(ObjectIdentifier?)
    case cancelled(ObjectIdentifier?)
}

/// Unifies visible key face buttons and gap controls for long-press ownership
/// resolution and same-key multi-touch gating.
@MainActor
protocol OrdinaryRolloverTouchControl: UIControl {
    var ordinaryRolloverSourceButton: KeyboardKeyButton? { get }
    var isTrackingOrdinaryRolloverTouch: Bool { get }
}

final class KeyboardKeyButton: UIButton, OrdinaryRolloverTouchControl {
    /// UIControl still asks the target button whether a tracked touch is inside.
    /// The root hit-test stack assigns visual gaps to explicit per-key cells, and
    /// this slop keeps small finger drift valid through touch-up and long press.
    var touchSlop: CGFloat = 4
    var expandedTouchOutsets: UIEdgeInsets = .zero
    /// Same snapshot `touchFrame`, in this button's coordinates. Overlay on/off
    /// must not change this; `touchUpInside` reads it instead of a second box.
    var localTouchBounds: CGRect?
    var visualStyle: KeyVisualStyle = .character
    /// Per r3 §3: only ordinary character keys (26-key letters, text-row insertKey
    /// keys, and nine-key 2–9) participate in press-order rollover; function keys stay false.
    var isOrdinaryRolloverParticipant = false
    var supportsOrdinaryLongPressVariants = false
    weak var ordinaryRolloverGapControl: UIControl?
    weak var ordinaryLongPressTarget: AnyObject?
    var ordinaryLongPressAction: Selector?
    weak var ordinaryLongPressDelegate: (any UIGestureRecognizerDelegate)?
    var canBeginOrdinaryRolloverTouch: ((KeyboardKeyButton) -> Bool)?
    var onOrdinaryRolloverTrackingEvent: ((KeyboardKeyButton, OrdinaryKeyTrackingEvent) -> Void)?
    private var activeRolloverTouchID: ObjectIdentifier?
    private var didEmitRolloverDragExit = false
    private var isSuppressingTrackingTouchUpInsideInsert = false

    var isTrackingOrdinaryRolloverTouch: Bool {
        activeRolloverTouchID != nil
    }

    var ordinaryRolloverSourceButton: KeyboardKeyButton? {
        self
    }

    #if DEBUG
        /// Kept on the button so diagnostics see UIKit's real tracking terminals,
        /// including cancellations that do not result in a business key action.
        var trackingEventHandler: ((KeyboardKeyButton, KeyboardKeyTrackingPhase) -> Void)?
    #endif

    /// Touch geometry follows layout, not the transient press-feedback scale.
    /// UIButton's center/bounds stay stable while its transform animates.
    func touchLayoutFrame(in view: UIView) -> CGRect {
        guard let superview else { return .zero }
        return superview.convert(
            CGRect(
                x: center.x - bounds.width / 2, y: center.y - bounds.height / 2,
                width: bounds.width, height: bounds.height), to: view)
    }

    func touchLayoutBounds(_ rect: CGRect, from view: UIView) -> CGRect {
        guard let superview else { return .zero }
        return superview.convert(rect, from: view).offsetBy(
            dx: bounds.minX - center.x + bounds.width / 2,
            dy: bounds.minY - center.y + bounds.height / 2)
    }

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        guard isEnabled, !isHidden, alpha > 0.01 else {
            return false
        }
        if let localTouchBounds {
            return localTouchBounds.contains(point)
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
        if isOrdinaryRolloverParticipant,
            activeRolloverTouchID != nil || !(canBeginOrdinaryRolloverTouch?(self) ?? true)
        {
            return false
        }
        let accepted = super.beginTracking(touch, with: event)
        if accepted, isOrdinaryRolloverParticipant {
            let touchID = ObjectIdentifier(touch)
            activeRolloverTouchID = touchID
            didEmitRolloverDragExit = false
            onOrdinaryRolloverTrackingEvent?(self, .began(touchID))
        }
        #if DEBUG
            if accepted {
                trackingEventHandler?(self, .began)
            }
        #endif
        return accepted
    }

    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let continued = super.continueTracking(touch, with: event)
        if isOrdinaryRolloverParticipant,
            let activeRolloverTouchID,
            ObjectIdentifier(touch) == activeRolloverTouchID,
            !didEmitRolloverDragExit,
            !point(inside: touch.location(in: self), with: event)
        {
            didEmitRolloverDragExit = true
            onOrdinaryRolloverTrackingEvent?(self, .dragExit(activeRolloverTouchID))
        }
        return continued
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isOrdinaryRolloverParticipant {
            // UIControl dispatches `.touchUpInside` -> `sendAction` inside `touchesEnded`
            // *after* `endTracking` returns, so suppression must span `super.touchesEnded`.
            isSuppressingTrackingTouchUpInsideInsert = true
            defer { isSuppressingTrackingTouchUpInsideInsert = false }
            super.touchesEnded(touches, with: event)
            return
        }
        super.touchesEnded(touches, with: event)
    }

    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        let inside = touch.map { point(inside: $0.location(in: self), with: event) } ?? false
        #if DEBUG
            let phase: KeyboardKeyTrackingPhase = inside ? .endedInside : .endedOutside
            trackingEventHandler?(self, phase)
        #endif
        if isOrdinaryRolloverParticipant {
            let touchID = touch.map(ObjectIdentifier.init) ?? activeRolloverTouchID
            activeRolloverTouchID = nil
            didEmitRolloverDragExit = false
            onOrdinaryRolloverTrackingEvent?(
                self,
                inside ? .endedInside(touchID) : .endedOutside(touchID)
            )
            super.endTracking(touch, with: event)
            return
        }
        super.endTracking(touch, with: event)
    }

    override func cancelTracking(with event: UIEvent?) {
        #if DEBUG
            trackingEventHandler?(self, .cancelled)
        #endif
        if isOrdinaryRolloverParticipant {
            let touchID = activeRolloverTouchID
            activeRolloverTouchID = nil
            didEmitRolloverDragExit = false
            onOrdinaryRolloverTrackingEvent?(self, .cancelled(touchID))
        }
        super.cancelTracking(with: event)
    }

    override func sendAction(_ action: Selector, to target: Any?, for event: UIEvent?) {
        if isSuppressingTrackingTouchUpInsideInsert,
            NSStringFromSelector(action) == "insertKey:"
        {
            return
        }
        super.sendAction(action, to: target, for: event)
    }

}
