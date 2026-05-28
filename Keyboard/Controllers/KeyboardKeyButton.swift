import UIKit

final class KeyboardKeyButton: UIButton {
    var touchSlop: CGFloat = 10
    var visualStyle: KeyVisualStyle = .character

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        guard isEnabled, !isHidden, alpha > 0.01 else {
            return false
        }
        return bounds.insetBy(dx: -touchSlop, dy: -touchSlop).contains(point)
    }
}
