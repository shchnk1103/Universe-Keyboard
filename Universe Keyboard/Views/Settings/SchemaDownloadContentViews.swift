import SwiftUI

struct RimeIceDownloadCardView: View {
    let isLicenseAccepted: Bool
    let onShowLicense: () -> Void
    let onDownload: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text("雾凇拼音")
                            .font(.body.bold())
                        CapsuleBadge(text: "需要下载", color: .orange, style: .tinted)
                    }
                    Text("社区维护的高质量简体词库，词条丰富、更新活跃。")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
                Spacer()
            }

            HStack(spacing: 12) {
                Label("约 16 MB", systemImage: "arrow.down.circle")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Label("GPL-3.0", systemImage: "doc.text")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Label("解压约 60 MB", systemImage: "internaldrive")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 10) {
                Button(action: onShowLicense) {
                    Label("查看许可证", systemImage: "doc.text.magnifyingglass")
                        .font(.subheadline)
                }
                .buttonStyle(.bordered)
                .controlSize(.small)

                Button(action: onDownload) {
                    Label("同意并下载", systemImage: "arrow.down.to.line")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(Color(.systemBackground))
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
                .disabled(!isLicenseAccepted)
            }
        }
        .padding(12)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

struct RimeIceInfoContent: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("关于雾凇拼音", systemImage: "info.circle")
                .font(.headline)
            Text("雾凇拼音 (rime-ice) 是一个开源的简体中文 RIME 配置方案，由社区维护。它包含：")
                .font(.caption)
                .foregroundStyle(.secondary)
            VStack(alignment: .leading, spacing: 4) {
                BulletRow(text: "完整 cn_dicts 词库（8105 + base + ext + tencent），大幅提高候选准确率", style: .dot)
                BulletRow(text: "支持简繁转换", style: .dot)
                BulletRow(text: "支持 emoji 候选", style: .dot)
                BulletRow(text: "部分高级功能（如日期输入、计算器）需要 Lua 插件，暂不可用", style: .dot)
            }
            Text("下载后可在方案列表中选择切换，随时可卸载恢复默认方案。")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

struct RimeDownloadProgressContent: View {
    let statusLabel: String
    let state: DownloadState
    let onCancel: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 10) {
                ProgressView()
                Text(statusLabel)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
                Button("取消", action: onCancel)
                    .font(.caption)
                    .buttonStyle(.bordered)
                    .controlSize(.small)
            }

            switch state {
            case .downloading(let progress):
                ProgressView(value: progress)
            case .fetchingReleaseInfo, .extracting, .postProcessing, .deploying:
                ProgressView()
            default:
                EmptyView()
            }
        }
    }
}

struct RimeDownloadErrorContent: View {
    let message: String
    let onRetry: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.red)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.red)
            Spacer()
            Button("重试", action: onRetry)
                .font(.caption)
                .buttonStyle(.bordered)
                .controlSize(.small)
        }
    }
}

struct RimeIceManageContent: View {
    let version: String?
    let updateStatusMessage: String?
    let onCheckForUpdate: () -> Void
    let onRedownload: () -> Void
    let onUninstall: () -> Void
    let onShowLicense: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label("版本：\(version ?? "未知")", systemImage: "tag")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
            }

            HStack(spacing: 10) {
                Button(action: onCheckForUpdate) {
                    Label("检查更新", systemImage: "arrow.triangle.2.circlepath")
                        .font(.subheadline)
                }
                .buttonStyle(.bordered)
                .controlSize(.small)

                Button(action: onRedownload) {
                    Label("重新下载", systemImage: "arrow.down.circle")
                        .font(.subheadline)
                }
                .buttonStyle(.bordered)
                .controlSize(.small)

                Button(role: .destructive, action: onUninstall) {
                    Label("卸载", systemImage: "trash")
                        .font(.subheadline)
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
                .tint(.red)

                Button(action: onShowLicense) {
                    Label("许可证", systemImage: "doc.text")
                        .font(.subheadline)
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            }

            if let updateStatusMessage {
                Text(updateStatusMessage)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
