import SwiftUI

struct AppOperationToastState: Equatable {
    enum Source: Equatable {
        case deployment
        case download
        case userDictionary
    }

    enum Tone: Equatable {
        case progress
        case success
        case failure
        case info
    }

    let source: Source
    let message: String
    let systemImage: String
    let tone: Tone
    let automaticallyDismisses: Bool

    var showsProgress: Bool {
        tone == .progress
    }

    var iconColor: Color {
        switch tone {
        case .success:
            return .green
        case .failure:
            return .red
        case .progress, .info:
            return .primary
        }
    }
}

extension AppOperationToastState {
    init?(deploymentState: RimeDeploymentState) {
        switch deploymentState {
        case .triggered, .deploying:
            self.init(
                source: .deployment,
                message: "正在应用 RIME 设置…",
                systemImage: "arrow.triangle.2.circlepath",
                tone: .progress,
                automaticallyDismisses: false
            )
        case .deployed:
            self.init(
                source: .deployment,
                message: "RIME 设置已生效",
                systemImage: "checkmark.circle.fill",
                tone: .success,
                automaticallyDismisses: true
            )
        case .failed:
            self.init(
                source: .deployment,
                message: "RIME 部署失败，请进入 RIME 方案设置重试",
                systemImage: "xmark.circle.fill",
                tone: .failure,
                automaticallyDismisses: false
            )
        case .idle, .needsDeploy:
            return nil
        }
    }

    init?(downloadState: DownloadState) {
        switch downloadState {
        case .fetchingReleaseInfo:
            self.init(
                source: .download,
                message: "正在检查雾凇拼音更新…",
                systemImage: "arrow.triangle.2.circlepath",
                tone: .progress,
                automaticallyDismisses: false
            )
        case .downloading(let progress):
            self.init(
                source: .download,
                message: "正在下载雾凇拼音… \(Int(progress * 100))%",
                systemImage: "arrow.down.circle",
                tone: .progress,
                automaticallyDismisses: false
            )
        case .extracting:
            self.init(
                source: .download,
                message: "正在解压雾凇拼音…",
                systemImage: "archivebox",
                tone: .progress,
                automaticallyDismisses: false
            )
        case .postProcessing:
            self.init(
                source: .download,
                message: "正在处理雾凇拼音配置…",
                systemImage: "doc.text",
                tone: .progress,
                automaticallyDismisses: false
            )
        case .deploying:
            self.init(
                source: .download,
                message: "正在部署雾凇拼音…",
                systemImage: "arrow.triangle.2.circlepath",
                tone: .progress,
                automaticallyDismisses: false
            )
        case .completed:
            self.init(
                source: .download,
                message: "雾凇拼音已下载并部署",
                systemImage: "checkmark.circle.fill",
                tone: .success,
                automaticallyDismisses: true
            )
        case .failed:
            self.init(
                source: .download,
                message: "雾凇拼音下载或部署失败",
                systemImage: "xmark.circle.fill",
                tone: .failure,
                automaticallyDismisses: true
            )
        case .idle:
            return nil
        }
    }

    static func userDictionary(message: String, succeeded: Bool) -> AppOperationToastState {
        AppOperationToastState(
            source: .userDictionary,
            message: message,
            systemImage: succeeded ? "checkmark.circle.fill" : "exclamationmark.circle.fill",
            tone: succeeded ? .success : .info,
            automaticallyDismisses: true
        )
    }
}

struct AppOperationToast: View {
    let state: AppOperationToastState

    var body: some View {
        toastContent
            .padding(.horizontal, 14)
            .padding(.vertical, 11)
            .frame(maxWidth: 520)
            .modifier(RimeDeploymentToastSurface())
    }

    private var toastContent: some View {
        HStack(spacing: 11) {
            if state.showsProgress {
                ProgressView()
                    .controlSize(.small)
                    .tint(.primary)
            } else {
                Image(systemName: state.systemImage)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(state.iconColor)
                    .frame(width: 24, height: 24)
            }

            Text(state.message)
                .font(.system(.subheadline, weight: .semibold))
                .foregroundStyle(.primary)
                .lineLimit(2)
                .minimumScaleFactor(0.9)

            Spacer(minLength: 0)
        }
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
