import SwiftUI
import UIKit

/// Contrast tokens for every main-App content action button (`PD-APP-ACTION-BUTTON-CONTRAST-001`).
enum AppActionButtonChrome: Sendable {
    enum Prominence: Sendable {
        case primary
        case secondary
        case destructive
    }

    nonisolated static let primaryGlassTintOpacity: CGFloat = 0.92
    nonisolated static let disabledOpacity: CGFloat = 0.40
    nonisolated static let destructiveGlassTintOpacityLight: CGFloat = 0.22
    nonisolated static let destructiveGlassTintOpacityDark: CGFloat = 0.28
    nonisolated static let destructiveSolidFillOpacity: CGFloat = 0.12
    nonisolated static let destructiveSolidBorderOpacity: CGFloat = 0.18
    nonisolated static let fallbackSecondaryBorderWidth: CGFloat = 0.5
    nonisolated static let cornerRadius: CGFloat = 16

    /// iOS 26 Liquid Glass is used unless Reduce Transparency is on.
    nonisolated static func usesGlassMaterial(reduceTransparency: Bool) -> Bool {
        !reduceTransparency
    }

    nonisolated static func controlOpacity(isEnabled: Bool) -> CGFloat {
        isEnabled ? 1 : disabledOpacity
    }

    nonisolated static func destructiveGlassTintOpacity(isDark: Bool) -> CGFloat {
        isDark ? destructiveGlassTintOpacityDark : destructiveGlassTintOpacityLight
    }

    /// Primary text is the inverse of label (white on black in light, black on white in dark).
    nonisolated static func labelColor(prominence: Prominence) -> UIColor {
        switch prominence {
        case .primary:
            return .systemBackground
        case .secondary:
            return .label
        case .destructive:
            return .systemRed
        }
    }

    nonisolated static func solidFillColor(prominence: Prominence) -> UIColor {
        switch prominence {
        case .primary:
            return .label
        case .secondary:
            return .secondarySystemGroupedBackground
        case .destructive:
            return UIColor.systemRed.withAlphaComponent(destructiveSolidFillOpacity)
        }
    }

    nonisolated static func solidBorderColor(prominence: Prominence) -> UIColor {
        switch prominence {
        case .primary:
            return .clear
        case .secondary:
            return .separator
        case .destructive:
            return UIColor.systemRed.withAlphaComponent(destructiveSolidBorderOpacity)
        }
    }
}

/// 主 App 内用于执行明确命令的统一操作按钮。
///
/// 导航、Toggle、Alert 和 Toolbar 继续使用系统控件；该组件只覆盖页面内容里的
/// “下载 / 部署 / 重置 / 卸载”等实体操作，避免各页面按钮风格分裂。
struct AppActionButton: View {
    typealias Prominence = AppActionButtonChrome.Prominence

    let title: String
    let systemImage: String
    var prominence: Prominence = .secondary
    var role: ButtonRole?
    var minHeight: CGFloat = 38
    private let interaction: Interaction

    @Environment(\.isEnabled) private var isEnabled

    /// 普通命令按钮。
    init(
        title: String,
        systemImage: String,
        prominence: Prominence = .secondary,
        role: ButtonRole? = nil,
        minHeight: CGFloat = 38,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.systemImage = systemImage
        self.prominence = prominence
        self.role = role
        self.minHeight = minHeight
        interaction = .action(action)
    }

    /// 需要调用系统分享面板的文本操作，也复用和普通命令相同的视觉样式。
    init(
        title: String,
        systemImage: String,
        prominence: Prominence = .secondary,
        minHeight: CGFloat = 38,
        shareText: String
    ) {
        self.title = title
        self.systemImage = systemImage
        self.prominence = prominence
        role = nil
        self.minHeight = minHeight
        interaction = .shareText(shareText)
    }

    var body: some View {
        Group {
            switch interaction {
            case .action(let action):
                Button(role: role, action: action) {
                    label
                }
                .buttonStyle(.plain)
                .modifier(AppActionButtonSurface(prominence: prominence))
            case .shareText(let text):
                ShareLink(item: text) {
                    label
                }
                .buttonStyle(.plain)
                .modifier(AppActionButtonSurface(prominence: prominence))
            }
        }
        .opacity(AppActionButtonChrome.controlOpacity(isEnabled: isEnabled))
    }

    private var label: some View {
        Label(title, systemImage: systemImage)
            .font(.system(.subheadline, weight: .semibold))
            .lineLimit(1)
            .minimumScaleFactor(0.85)
            .foregroundStyle(Color(uiColor: AppActionButtonChrome.labelColor(prominence: prominence)))
            .frame(maxWidth: .infinity, minHeight: minHeight)
    }

    private enum Interaction {
        case action(() -> Void)
        case shareText(String)
    }
}

private struct AppActionButtonSurface: ViewModifier {
    let prominence: AppActionButtonChrome.Prominence

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    func body(content: Content) -> some View {
        let padded =
            content
            .padding(.horizontal, 10)
            .padding(.vertical, 7)

        if AppActionButtonChrome.usesGlassMaterial(reduceTransparency: reduceTransparency) {
            if #available(iOS 26.0, *) {
                glass(padded)
            } else {
                solid(padded)
            }
        } else {
            solid(padded)
        }
    }

    @available(iOS 26.0, *)
    @ViewBuilder
    private func glass(_ content: some View) -> some View {
        switch prominence {
        case .primary:
            content.glassEffect(
                .regular
                    .tint(Color.primary.opacity(AppActionButtonChrome.primaryGlassTintOpacity))
                    .interactive(),
                in: .rect(cornerRadius: AppActionButtonChrome.cornerRadius)
            )
        case .secondary:
            content.glassEffect(
                .regular.interactive(),
                in: .rect(cornerRadius: AppActionButtonChrome.cornerRadius)
            )
        case .destructive:
            content.glassEffect(
                .regular
                    .tint(
                        Color.red.opacity(
                            AppActionButtonChrome.destructiveGlassTintOpacity(
                                isDark: colorScheme == .dark
                            )
                        )
                    )
                    .interactive(),
                in: .rect(cornerRadius: AppActionButtonChrome.cornerRadius)
            )
        }
    }

    private func solid(_ content: some View) -> some View {
        content
            .background(
                Color(uiColor: AppActionButtonChrome.solidFillColor(prominence: prominence)),
                in: shape
            )
            .overlay(border)
    }

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: AppActionButtonChrome.cornerRadius, style: .continuous)
    }

    @ViewBuilder
    private var border: some View {
        switch prominence {
        case .primary:
            shape.stroke(Color.clear, lineWidth: 0)
        case .secondary:
            shape.stroke(
                Color(uiColor: AppActionButtonChrome.solidBorderColor(prominence: prominence)),
                lineWidth: AppActionButtonChrome.fallbackSecondaryBorderWidth
            )
        case .destructive:
            shape.stroke(
                Color(uiColor: AppActionButtonChrome.solidBorderColor(prominence: prominence)),
                lineWidth: 0.7
            )
        }
    }
}
