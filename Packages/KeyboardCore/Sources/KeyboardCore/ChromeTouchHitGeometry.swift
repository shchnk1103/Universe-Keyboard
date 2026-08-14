import CoreGraphics
import Foundation

/// Shared hit rectangles for candidate-bar and Path-bar chrome.
///
/// Debug overlay must paint these exact values. Changing a number here changes
/// both hit-testing and the orange frame; do not fork a second layout for drawing.
public enum ChromeTouchHitGeometry {
    public static let pathBarMinimumHitHeight: CGFloat = 44

    /// Path bar `point(inside:)` expands vertically toward 44 pt without growing
    /// the reserved 34 pt chrome.
    public static func pathBarExpandedHitBounds(barBounds: CGRect) -> CGRect {
        let verticalPad = max(0, (pathBarMinimumHitHeight - barBounds.height) / 2)
        return barBounds.insetBy(dx: 0, dy: -verticalPad)
    }

    /// Expand-button hit rect: the button's own outset box, clipped to the bar.
    /// Do not flatten this into a full-height trailing slab — that paints a
    /// second rectangle behind the chevron and steals the last candidate.
    public static func candidateExpandButtonHitFrame(
        buttonFrame: CGRect,
        topOutset: CGFloat,
        leftOutset: CGFloat,
        bottomOutset: CGFloat,
        rightOutset: CGFloat,
        barBounds: CGRect
    ) -> CGRect {
        let widened = buttonFrame.inset(
            by: CGRectEdgeInsets(
                top: -topOutset,
                left: -leftOutset,
                bottom: -bottomOutset,
                right: -rightOutset
            )
        )
        return widened.intersection(barBounds)
    }
}

/// CoreGraphics-only inset helper so KeyboardCore stays UIKit-free.
private struct CGRectEdgeInsets {
    var top: CGFloat
    var left: CGFloat
    var bottom: CGFloat
    var right: CGFloat
}

extension CGRect {
    fileprivate func inset(by insets: CGRectEdgeInsets) -> CGRect {
        CGRect(
            x: minX + insets.left,
            y: minY + insets.top,
            width: width - insets.left - insets.right,
            height: height - insets.top - insets.bottom
        )
    }
}
