import SwiftUI

struct RimeIceDownloadCardView: View {
    let schema: SchemaMetadata
    let isLicenseAccepted: Bool
    let onShowLicense: () -> Void
    let onDownload: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text(schema.name)
                            .font(.body.bold())
                        CapsuleBadge(text: "需要下载", color: .orange, style: .tinted)
                    }
                    Text(schema.description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
                Spacer()
            }

            HStack(spacing: 12) {
                Label(schema.downloadSize, systemImage: "arrow.down.circle")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                if let licenseName = schema.licenseName {
                    Label(licenseName, systemImage: "doc.text")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                if let installedSize = schema.installedSize {
                    Label(installedSize, systemImage: "internaldrive")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            HStack(spacing: 10) {
                AppActionButton(
                    title: "查看许可证",
                    systemImage: "doc.text.magnifyingglass",
                    action: onShowLicense
                )

                AppActionButton(
                    title: "同意并下载",
                    systemImage: "arrow.down.to.line",
                    prominence: .primary,
                    action: onDownload
                )
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
                AppActionButton(
                    title: "取消",
                    systemImage: "xmark",
                    minHeight: 30,
                    action: onCancel
                )
                .frame(maxWidth: 92)
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
            AppActionButton(
                title: "重试",
                systemImage: "arrow.clockwise",
                minHeight: 30,
                action: onRetry
            )
            .frame(maxWidth: 92)
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

    private let columns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Label("版本：\(version ?? "未知")", systemImage: "tag")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
            }

            LazyVGrid(columns: columns, spacing: 10) {
                AppActionButton(
                    title: "检查更新",
                    systemImage: "arrow.triangle.2.circlepath",
                    action: onCheckForUpdate
                )
                AppActionButton(
                    title: "重新下载",
                    systemImage: "arrow.down.circle",
                    action: onRedownload
                )
                AppActionButton(
                    title: "卸载",
                    systemImage: "trash",
                    prominence: .destructive,
                    role: .destructive,
                    action: onUninstall
                )
                AppActionButton(
                    title: "许可证",
                    systemImage: "doc.text",
                    action: onShowLicense
                )
            }

            if let updateStatusMessage {
                Label(updateStatusMessage, systemImage: "checkmark.circle.fill")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
