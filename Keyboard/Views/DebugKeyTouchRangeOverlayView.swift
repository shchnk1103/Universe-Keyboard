import UIKit

#if DEBUG
    /// In-memory overlay flag. Set only from settings snapshots / visibility.
    /// `hitTest` must never read App Group to decide this.
    enum DebugHitboxOverlayPresentation {
        static var isShowing = false
        static var probeLine = "hit=—"
        static var refreshProbeLabel: (() -> Void)?

        static func publishProbeLine(_ line: String) {
            probeLine = line
            refreshProbeLabel?()
        }
    }

    /// Non-interactive paint of one live hit rectangle.
    ///
    /// Solid orange traces `touchFrame`. Dashed teal traces `visualFrame`.
    /// Both are shape-layer paths — the view border is not the touch outline,
    /// so a large parent frame cannot fake a single merged key box.
    final class DebugKeyTouchRangeOverlayView: UIView {
        private let touchOutline = CAShapeLayer()
        private let slopFill = CAShapeLayer()
        private let visualOutline = CAShapeLayer()
        private let contentOutline = CAShapeLayer()

        override init(frame: CGRect) {
            super.init(frame: frame)
            isUserInteractionEnabled = false
            isAccessibilityElement = false
            backgroundColor = .clear
            clipsToBounds = false
            slopFill.fillColor = UIColor.systemOrange.withAlphaComponent(0.18).cgColor
            slopFill.fillRule = .evenOdd
            slopFill.strokeColor = nil
            layer.addSublayer(slopFill)
            touchOutline.fillColor = UIColor.clear.cgColor
            touchOutline.strokeColor = UIColor.systemOrange.withAlphaComponent(0.95).cgColor
            touchOutline.lineWidth = 2
            layer.addSublayer(touchOutline)
            visualOutline.fillColor = UIColor.clear.cgColor
            visualOutline.strokeColor = UIColor.systemTeal.withAlphaComponent(0.95).cgColor
            visualOutline.lineWidth = 1.5
            visualOutline.lineDashPattern = [5, 3]
            layer.addSublayer(visualOutline)
            contentOutline.fillColor = UIColor.clear.cgColor
            contentOutline.strokeColor = UIColor.systemYellow.withAlphaComponent(0.95).cgColor
            contentOutline.lineWidth = 1
            contentOutline.lineDashPattern = [2, 2]
            contentOutline.isHidden = true
            layer.addSublayer(contentOutline)
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        func apply(
            touchFrame: CGRect,
            visualFrame: CGRect,
            contentFrame: CGRect? = nil,
            in host: UIView
        ) {
            let drawnTouch =
                touchFrame.isNull || touchFrame.isEmpty ? visualFrame : touchFrame
            let drawnVisual =
                visualFrame.isNull || visualFrame.isEmpty ? drawnTouch : visualFrame
            frame = drawnTouch.union(drawnVisual).insetBy(dx: -1.5, dy: -1.5)
            slopFill.frame = bounds
            touchOutline.frame = bounds
            visualOutline.frame = bounds
            contentOutline.frame = bounds

            let touchInSelf = convert(drawnTouch, from: host)
            var visualInSelf = convert(drawnVisual, from: host)
            if visualInSelf.nearlyEqual(to: touchInSelf) {
                visualInSelf = visualInSelf.insetBy(dx: 2.5, dy: 2.5)
            }

            let slopPath = UIBezierPath(roundedRect: touchInSelf, cornerRadius: 4)
            slopPath.append(UIBezierPath(roundedRect: visualInSelf, cornerRadius: 8))
            slopPath.usesEvenOddFillRule = true
            slopFill.path = slopPath.cgPath
            touchOutline.path =
                UIBezierPath(roundedRect: touchInSelf, cornerRadius: 4).cgPath
            visualOutline.path =
                UIBezierPath(roundedRect: visualInSelf, cornerRadius: 8).cgPath

            if let contentFrame, !contentFrame.nearlyEqual(to: drawnTouch) {
                contentOutline.isHidden = false
                contentOutline.path =
                    UIBezierPath(
                        roundedRect: convert(contentFrame, from: host),
                        cornerRadius: 4
                    ).cgPath
            } else {
                contentOutline.isHidden = true
                contentOutline.path = nil
            }
        }
    }

    /// Paints every key box on the keyboard surface. Must not live inside a
    /// `UIStackView` (unarranged stack children get stretched into columns).
    final class DebugKeyTouchRangeOverlayCanvas: UIView {
        private var itemViews: [DebugKeyTouchRangeOverlayView] = []
        private let probeLabel = UILabel()

        override init(frame: CGRect) {
            super.init(frame: frame)
            isUserInteractionEnabled = false
            isAccessibilityElement = false
            backgroundColor = .clear
            clipsToBounds = false
            probeLabel.font = .monospacedSystemFont(ofSize: 9, weight: .medium)
            probeLabel.textColor = .systemOrange
            probeLabel.numberOfLines = 2
            probeLabel.isUserInteractionEnabled = false
            addSubview(probeLabel)
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        func render(items: [(touch: CGRect, visual: CGRect)]) {
            while itemViews.count < items.count {
                let view = DebugKeyTouchRangeOverlayView()
                addSubview(view)
                itemViews.append(view)
            }
            while itemViews.count > items.count {
                itemViews.removeLast().removeFromSuperview()
            }
            for (index, item) in items.enumerated() {
                itemViews[index].apply(
                    touchFrame: item.touch,
                    visualFrame: item.visual,
                    in: self
                )
            }
            bringSubviewToFront(probeLabel)
        }

        func setProbeDigest(_ text: String) {
            probeLabel.text = text
            probeLabel.sizeToFit()
            probeLabel.frame.origin = CGPoint(x: 6, y: 2)
        }
    }

    extension CGRect {
        fileprivate func nearlyEqual(to other: CGRect, tolerance: CGFloat = 1) -> Bool {
            abs(minX - other.minX) <= tolerance
                && abs(minY - other.minY) <= tolerance
                && abs(width - other.width) <= tolerance
                && abs(height - other.height) <= tolerance
        }
    }
#endif
