import SwiftUI
import UIKit

/// 主 App 统一滑轨（PB-015-PR2-STYLE-COMPONENTS-001）。
///
/// 以 `UIViewRepresentable` 包装原生 `UISlider`（隐藏系统轨道、贴黑白拇指、
/// 垫银色渐变轨底），完整保留原生拖动/点击、RTL 与 VoiceOver 语义；装饰银层
/// 仅是垫底视图，不进无障碍树。消费 `AppSilverToken` 三层：轨底 `sliderTrack`
/// （顶部亮银渐变）、轨底描边 `hairline`（0.5pt）、拖动高亮拇指描边
/// `activePill`（`Color(.label)` @ 25%）。浅/深自动成对；Reduce Transparency
/// 退化为纯实色；Increase Contrast 切换 `opaqueSeparator`。
///
/// 数值按 `step` 取整（`step ≤ 0` 表示连续）。`onEditingChanged` 语义与原生
/// `Slider` 一致：拖动开始/结束时回调。
struct AppSlider<Number: BinaryFloatingPoint>: UIViewRepresentable {
    @Binding var value: Number
    let range: ClosedRange<Number>
    var step: Double = 0
    var onEditingChanged: (Bool) -> Void = { _ in }
    /// 传给 UISlider 的无障碍标签（原生 `Slider(label:)` 语义：不视觉展示）。
    var accessibilityLabel: String? = nil
    /// 显式数值播报文案；缺省由原生 UISlider 按百分比播报。
    var accessibilityValueText: String? = nil

    /// 外部标签沿用原生 `Slider(value:in:step:onEditingChanged:)` 形状。
    init(
        value: Binding<Number>,
        in range: ClosedRange<Number>,
        step: Double = 0,
        onEditingChanged: @escaping (Bool) -> Void = { _ in },
        accessibilityLabel: String? = nil,
        accessibilityValueText: String? = nil
    ) {
        _value = value
        self.range = range
        self.step = step
        self.onEditingChanged = onEditingChanged
        self.accessibilityLabel = accessibilityLabel
        self.accessibilityValueText = accessibilityValueText
    }

    // MARK: - Representable

    func makeUIView(context: Context) -> AppSliderHost {
        let host = AppSliderHost()
        let slider = host.slider
        slider.minimumTrackTintColor = .clear
        slider.maximumTrackTintColor = .clear
        slider.addTarget(
            context.coordinator, action: #selector(Coordinator.valueChanged),
            for: .valueChanged)
        slider.addTarget(
            context.coordinator, action: #selector(Coordinator.editingBegan),
            for: .editingDidBegin)
        slider.addTarget(
            context.coordinator, action: #selector(Coordinator.editingEnded),
            for: [.editingDidEnd, .editingDidEndOnExit])
        return host
    }

    func updateUIView(_ host: AppSliderHost, context: Context) {
        let slider = host.slider
        slider.minimumValue = 0
        slider.maximumValue = 1
        if !slider.isTracking {
            slider.value = Float(normalizedProgress)
        }
        slider.accessibilityLabel = accessibilityLabel
        slider.accessibilityValue = accessibilityValueText
        context.coordinator.parent = self
        host.refreshChrome()
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    @MainActor
    final class Coordinator: NSObject {
        var parent: AppSlider

        init(parent: AppSlider) {
            self.parent = parent
        }

        @objc func valueChanged(_ sender: UISlider) {
            parent.value = parent.mappedValue(fromNormalized: Double(sender.value))
        }

        @objc func editingBegan(_ sender: UISlider) {
            parent.onEditingChanged(true)
        }

        @objc func editingEnded(_ sender: UISlider) {
            // 结束时把停留位置按 step 收整并写回，保持与原生 Slider 相同的
            // 「结束才落定」手感（反馈强度即依赖此时机 commit）。
            parent.value = parent.mappedValue(fromNormalized: Double(sender.value))
            parent.onEditingChanged(false)
        }
    }

    // MARK: - 纯函数（供单测）

    private var normalizedProgress: Double {
        let span = Double(range.upperBound - range.lowerBound)
        guard span > 0 else { return 0 }
        return (Double(value) - Double(range.lowerBound)) / span
    }

    /// 把 UISlider 的 0...1 进度映射为区间内按 `step` 取整的值。
    nonisolated func mappedValue(fromNormalized progress: Double) -> Number {
        let clamped = max(min(progress, 1), 0)
        let raw = range.lowerBound + Number(clamped) * (range.upperBound - range.lowerBound)
        return Self.rounded(raw, in: range, step: step)
    }

    nonisolated static func rounded(
        _ raw: Number, in range: ClosedRange<Number>, step: Double
    ) -> Number {
        guard step > 0 else { return min(max(raw, range.lowerBound), range.upperBound) }
        let stepped = (Double(raw) / step).rounded() * step
        return min(max(Number(stepped), range.lowerBound), range.upperBound)
    }
}

/// `AppSlider` 的宿主视图：原生 `UISlider` + 垫底银轨装饰。
@MainActor
final class AppSliderHost: UIView {
    nonisolated static let thumbSize: CGFloat = 26
    nonisolated static let trackHeight: CGFloat = 6
    nonisolated static let rowHeight: CGFloat = 28

    let slider = UISlider()
    private let trackLayer = CAShapeLayer()
    private let outlineLayer = CAShapeLayer()
    private let gradientLayer = CAGradientLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        isAccessibilityElement = false
        layer.addSublayer(trackLayer)
        layer.addSublayer(outlineLayer)
        addSubview(slider)
        slider.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            slider.leadingAnchor.constraint(equalTo: leadingAnchor),
            slider.trailingAnchor.constraint(equalTo: trailingAnchor),
            slider.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
        registerForTraitChanges([UITraitUserInterfaceStyle.self]) {
            (host: AppSliderHost, _: UITraitCollection) in
            host.setNeedsLayout()
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        slider.setThumbImage(
            AppSliderChrome.thumbImage(isDark: traitCollection.isDark), for: .normal)
        slider.setThumbImage(
            AppSliderChrome.thumbImage(isDark: traitCollection.isDark, highlighted: true),
            for: .highlighted)
        refreshChrome()
        let trackRect = CGRect(
            x: 0, y: bounds.midY - AppSliderChrome.trackHeight / 2,
            width: bounds.width, height: AppSliderChrome.trackHeight)
        let path = UIBezierPath(
            roundedRect: trackRect, cornerRadius: AppSliderChrome.trackHeight / 2)
        trackLayer.frame = bounds
        outlineLayer.frame = bounds
        gradientLayer.frame = bounds
        trackLayer.path = path.cgPath
        outlineLayer.path = path.cgPath
        outlineLayer.lineWidth = 0.5
    }

    /// 按 4 态（浅/深 × RT × IC）刷新银轨填充与描边。
    func refreshChrome() {
        let reduced = UIAccessibility.isReduceTransparencyEnabled
        let increased = traitCollection.accessibilityContrast == UIAccessibilityContrast.high
        let fill = AppSliderChrome.trackFill(
            reduceTransparency: reduced, increaseContrast: increased)
        let outline = AppSliderChrome.trackOutline(
            reduceTransparency: reduced, increaseContrast: increased)
        switch fill {
        case let .gradient(base, topLight):
            gradientLayer.isHidden = false
            gradientLayer.colors = [topLight.cgColor, base.cgColor]
            gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
            gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
            gradientLayer.mask = trackLayer
            trackLayer.fillColor = UIColor.white.cgColor
        case let .solid(color):
            gradientLayer.isHidden = true
            trackLayer.fillColor = color.cgColor
        }
        if case let .solid(outlineColor) = outline {
            outlineLayer.strokeColor = outlineColor.cgColor
        } else if case let .gradient(base, _) = outline {
            // hairline 正常态同样是渐变；0.5pt 描边以渐变 base 近似（差异不可辨）。
            outlineLayer.strokeColor = base.cgColor
        }
    }
}

/// `AppSlider` 的可测 chrome 解析（纯静态函数，先例 `AppActionButtonChrome`）。
enum AppSliderChrome {
    nonisolated static let thumbSize: CGFloat = 26
    nonisolated static let trackHeight: CGFloat = 6
    nonisolated static let rowHeight: CGFloat = 28

    /// 轨底填充：`sliderTrack` 层。
    nonisolated static func trackFill(
        reduceTransparency: Bool, increaseContrast: Bool
    ) -> AppSilverToken.Resolved {
        AppSilverToken.resolved(
            .sliderTrack, reduceTransparency: reduceTransparency,
            increaseContrast: increaseContrast)
    }

    /// 轨底 0.5pt 描边：`hairline` 层。
    nonisolated static func trackOutline(
        reduceTransparency: Bool, increaseContrast: Bool
    ) -> AppSilverToken.Resolved {
        AppSilverToken.resolved(
            .hairline, reduceTransparency: reduceTransparency,
            increaseContrast: increaseContrast)
    }

    /// 拖动高亮拇指描边：`activePill` 层。
    nonisolated static func activeThumbStroke(
        reduceTransparency: Bool, increaseContrast: Bool
    ) -> AppSilverToken.Resolved {
        AppSilverToken.resolved(
            .activePill, reduceTransparency: reduceTransparency,
            increaseContrast: increaseContrast)
    }

    /// 拇指色：`AppSwitchChrome` 黑白拇指对（浅色黑、深色白）。
    nonisolated static func thumbColor(isDark: Bool) -> UIColor {
        isDark ? .white : .black
    }

    /// 生成拇指贴图：黑/白圆形；高亮态加 1pt `activePill` 描边环。
    nonisolated static func thumbImage(isDark: Bool, highlighted: Bool = false) -> UIImage {
        let ring: CGFloat = highlighted ? 2 : 0
        let canvas = CGSize(width: thumbSize + ring * 2, height: thumbSize + ring * 2)
        let renderer = UIGraphicsImageRenderer(size: canvas)
        return renderer.image { _ in
            let circle = UIBezierPath(
                ovalIn: CGRect(x: ring, y: ring, width: thumbSize, height: thumbSize))
            thumbColor(isDark: isDark).setFill()
            circle.fill()
            if highlighted {
                if case let .solid(strokeColor) = activeThumbStroke(
                    reduceTransparency: false, increaseContrast: false)
                {
                    strokeColor.setStroke()
                }
                circle.lineWidth = 1
                circle.stroke()
            }
        }
    }
}

private extension UITraitCollection {
    var isDark: Bool { userInterfaceStyle == .dark }
}
