import UIKit

final class KeyboardKeyButton: UIButton {
    /// UIControl still asks the target button whether a tracked touch is inside.
    /// The root hit-test stack assigns visual gaps to explicit per-key cells, and
    /// this slop keeps small finger drift valid through touch-up and long press.
    var touchSlop: CGFloat = 4
    var expandedTouchOutsets: UIEdgeInsets = .zero
    var visualStyle: KeyVisualStyle = .character

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
}
