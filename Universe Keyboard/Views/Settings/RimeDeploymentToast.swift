import SwiftUI

struct RimeDeploymentToast: View {
    let state: RimeDeploymentState

    var body: some View {
        toastContent
            .padding(.horizontal, 14)
            .padding(.vertical, 11)
            .frame(maxWidth: 520)
            .modifier(RimeDeploymentToastSurface())
    }

    private var toastContent: some View {
        HStack(spacing: 11) {
            if state == .triggered || state == .deploying {
                ProgressView()
                    .controlSize(.small)
                    .tint(.primary)
            } else {
                Image(systemName: state.icon)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(iconColor)
                    .frame(width: 24, height: 24)
            }

            Text(message)
                .font(.system(.subheadline, weight: .semibold))
                .foregroundStyle(.primary)
                .lineLimit(2)
                .minimumScaleFactor(0.9)

            Spacer(minLength: 0)
        }
    }

    private var message: String {
        switch state {
        case .triggered, .deploying:
            return "正在应用 RIME 设置…"
        case .deployed:
            return "RIME 设置已生效"
        case .failed:
            return "RIME 部署失败，请进入 RIME 方案设置重试"
        case .idle, .needsDeploy:
            return ""
        }
    }

    private var iconColor: Color {
        switch state {
        case .deployed:
            return .green
        case .failed:
            return .red
        case .triggered, .deploying, .idle, .needsDeploy:
            return .primary
        }
    }
}

struct RimeUserDictionaryOperationToast: View {
    let message: String
    let succeeded: Bool

    var body: some View {
        HStack(spacing: 11) {
            Image(systemName: succeeded ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(succeeded ? .green : .orange)
                .frame(width: 24, height: 24)

            Text(message)
                .font(.system(.subheadline, weight: .semibold))
                .foregroundStyle(.primary)
                .lineLimit(2)
                .minimumScaleFactor(0.9)

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 11)
        .frame(maxWidth: 520)
        .modifier(RimeDeploymentToastSurface())
    }
}

private struct RimeDeploymentToastSurface: ViewModifier {
    private let cornerRadius: CGFloat = 24

    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content
                .glassEffect(.regular.tint(Color(.systemBackground).opacity(0.18)), in: .rect(cornerRadius: cornerRadius))
                .overlay(stroke)
                .shadow(color: .black.opacity(0.08), radius: 20, y: 8)
        } else {
            content
                .background(.ultraThinMaterial, in: shape)
                .overlay(stroke)
                .shadow(color: .black.opacity(0.10), radius: 18, y: 8)
        }
    }

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
    }

    private var stroke: some View {
        shape
            .stroke(.white.opacity(0.28), lineWidth: 0.7)
    }
}
