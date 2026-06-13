import SwiftUI

/// 主 App 内用于执行明确命令的统一操作按钮。
///
/// 导航、Toggle、Alert 和 Toolbar 继续使用系统控件；该组件只覆盖页面内容里的
/// “下载 / 部署 / 重置 / 卸载”等实体操作，避免各页面按钮风格分裂。
struct AppActionButton: View {
    enum Prominence {
        case primary
        case secondary
        case destructive
    }

    let title: String
    let systemImage: String
    var prominence: Prominence = .secondary
    var role: ButtonRole?
    var minHeight: CGFloat = 38
    let action: () -> Void

    var body: some View {
        Button(role: role, action: action) {
            Label(title, systemImage: systemImage)
                .font(.system(.subheadline, weight: .semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.85)
                .foregroundStyle(foregroundColor)
                .frame(maxWidth: .infinity, minHeight: minHeight)
        }
        .buttonStyle(.plain)
        .modifier(AppActionButtonSurface(prominence: prominence))
    }

    private var foregroundColor: Color {
        switch prominence {
        case .primary:
            return .white
        case .secondary:
            return .primary
        case .destructive:
            return .red
        }
    }
}

private struct AppActionButtonSurface: ViewModifier {
    let prominence: AppActionButton.Prominence
    private let cornerRadius: CGFloat = 16

    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content
                .padding(.horizontal, 10)
                .padding(.vertical, 7)
                .glassEffect(
                    .regular
                        .tint(glassTint)
                        .interactive(),
                    in: .rect(cornerRadius: cornerRadius)
                )
        } else {
            content
                .padding(.horizontal, 10)
                .padding(.vertical, 7)
                .background(backgroundColor, in: shape)
                .overlay(border)
        }
    }

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
    }

    private var glassTint: Color {
        switch prominence {
        case .primary:
            return .black.opacity(0.60)
        case .secondary:
            return Color(.systemBackground).opacity(0.16)
        case .destructive:
            return .red.opacity(0.16)
        }
    }

    private var backgroundColor: Color {
        switch prominence {
        case .primary:
            return .black
        case .secondary:
            return Color(.tertiarySystemGroupedBackground)
        case .destructive:
            return .red.opacity(0.10)
        }
    }

    private var border: some View {
        shape.stroke(borderColor, lineWidth: 0.7)
    }

    private var borderColor: Color {
        switch prominence {
        case .primary:
            return .clear
        case .secondary:
            return Color(.separator).opacity(0.30)
        case .destructive:
            return .red.opacity(0.18)
        }
    }
}
