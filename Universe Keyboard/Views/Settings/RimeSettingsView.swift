import SwiftUI

struct RimeSettingsView: View {
    let store: RimeSettingsStore
    @State private var logExpanded = false

    var body: some View {
        Form {
            Section {
                ForEach(store.schemas) { schema in
                    NavigationLink {
                        RimeSchemaDetailView(store: store, initialSchema: schema)
                    } label: {
                        RimeSchemaListRow(
                            schema: schema,
                            statusText: schemaStatusText(for: schema),
                            symbol: schemaStatusSymbol(for: schema),
                            isActive: schema.schemaID == store.activeSchemaID
                        )
                    }
                }
            } header: {
                Text("输入方案")
            } footer: {
                Text("选择一个方案，查看说明、下载状态、更新和卸载选项。")
            }

            RimeDeploymentStatusSection(store: store, logExpanded: $logExpanded)
        }
        .navigationTitle("RIME 方案设置")
        .tint(.primary)
        .onAppear { store.load() }
        .onChange(of: store.downloadState) { _, _ in store.refreshDeploymentState() }
        .onDisappear { store.stop() }
    }

    private func schemaStatusText(for schema: SchemaMetadata) -> String {
        if schema.schemaID == store.activeSchemaID {
            return "当前使用"
        }
        if schema.installed {
            return "已安装"
        }
        switch store.downloadState {
        case .fetchingReleaseInfo, .downloading, .extracting, .postProcessing, .deploying:
            return schema.schemaID == "rime_ice" ? "正在下载" : "未安装"
        case .failed:
            return schema.schemaID == "rime_ice" ? "下载失败" : "未安装"
        default:
            return "可下载"
        }
    }

    private func schemaStatusSymbol(for schema: SchemaMetadata) -> RimeSchemaStatusSymbol {
        if schema.schemaID == store.activeSchemaID {
            return .active
        }
        if schema.installed {
            return .installed
        }
        switch store.downloadState {
        case .fetchingReleaseInfo, .downloading, .extracting, .postProcessing, .deploying:
            return schema.schemaID == "rime_ice" ? .working : .downloadable
        case .failed:
            return schema.schemaID == "rime_ice" ? .failed : .downloadable
        default:
            return .downloadable
        }
    }
}

private struct RimeSchemaDetailView: View {
    let store: RimeSettingsStore
    let initialSchema: SchemaMetadata
    @State private var showLicense = false
    @State private var showUninstallAlert = false

    var body: some View {
        Form {
            Section {
                VStack(alignment: .leading, spacing: 10) {
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Text(schema.name)
                            .font(.headline)
                        CapsuleBadge(text: sourceText, color: sourceColor, style: .tinted)
                        if schema.schemaID == store.activeSchemaID {
                            CapsuleBadge(text: "当前使用", color: .green, style: .tinted)
                        }
                    }

                    Text(schema.description)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 118), spacing: 8)], spacing: 8) {
                        RimeSchemaMetricLabel(
                            systemImage: schema.installed ? "checkmark.circle" : "arrow.down.circle",
                            text: schema.installed ? "已安装" : "可下载"
                        )
                        RimeSchemaMetricLabel(systemImage: "internaldrive", text: schema.downloadSize)
                        if let version = schema.version {
                            RimeSchemaMetricLabel(systemImage: "tag", text: version)
                        }
                        if schema.requiresLua {
                            RimeSchemaMetricLabel(systemImage: "puzzlepiece.extension", text: "需要 Lua")
                        }
                    }
                }
            } header: {
                Text("方案信息")
            }

            schemaActionSections
        }
        .navigationTitle(schema.name)
        .tint(.primary)
        .sheet(isPresented: $showLicense) {
            LicenseView { store.acceptLicense(for: schema.schemaID) }
        }
        .alert("确认卸载", isPresented: $showUninstallAlert) {
            Button("取消", role: .cancel) {}
            Button("卸载", role: .destructive) { store.uninstallSchema(schema.schemaID) }
        } message: {
            Text("卸载\(schema.name)后，将自动切换回朙月拼音。已下载的词库文件将被删除。")
        }
    }

    private var schema: SchemaMetadata {
        store.schemas.first { $0.schemaID == initialSchema.schemaID } ?? initialSchema
    }

    @ViewBuilder
    private var schemaActionSections: some View {
        if schema.installed {
            Section {
                AppActionButton(
                    title: schema.schemaID == store.activeSchemaID ? "正在使用" : "设为当前方案",
                    systemImage: schema.schemaID == store.activeSchemaID ? "checkmark.circle.fill" : "keyboard",
                    prominence: schema.schemaID == store.activeSchemaID ? .secondary : .primary
                ) {
                    Task { await store.switchToSchema(schema.schemaID) }
                }
                .disabled(schema.schemaID == store.activeSchemaID)
            } header: {
                Text("使用")
            } footer: {
                Text("切换方案后，主 App 会自动应用设置。完成后回到键盘即可使用。")
            }
        }

        if schema.isDownloadable {
            downloadableSchemaSections
        }
    }

    @ViewBuilder
    private var downloadableSchemaSections: some View {
        if !schema.installed {
            Section {
                RimeIceDownloadCardView(
                    schema: schema,
                    isLicenseAccepted: store.licenseAccepted(for: schema.schemaID),
                    onShowLicense: { showLicense = true },
                    onDownload: { store.startDownload(schemaID: schema.schemaID) }
                )
            } header: {
                Text("下载")
            }
        }

        if store.isShowingDownloadProgress {
            Section {
                RimeDownloadProgressContent(
                    statusLabel: store.downloadStatusLabel,
                    state: store.downloadState,
                    onCancel: { store.cancelDownload() }
                )
            } header: {
                Text("下载进度")
            }
        }

        if case .failed(let message) = store.downloadState {
            Section {
                RimeDownloadErrorContent(message: message, onRetry: { store.startDownload(schemaID: schema.schemaID) })
            } header: {
                Text("下载失败")
            }
        }

        if schema.installed {
            Section {
                RimeIceManageContent(
                    version: schema.version,
                    updateStatusMessage: store.updateStatusMessage,
                    onCheckForUpdate: { Task { await store.checkForUpdateAndDownload(schemaID: schema.schemaID) } },
                    onRedownload: { store.forceRedownload(schemaID: schema.schemaID) },
                    onUninstall: { showUninstallAlert = true },
                    onShowLicense: { showLicense = true }
                )
            } header: {
                Text("管理")
            } footer: {
                Text("更新、重新下载和卸载只影响\(schema.name)。默认方案会保留。")
            }
        }
    }

    private var sourceText: String {
        switch schema.source {
        case .builtin: return "内置"
        case .downloaded: return "开源方案"
        }
    }

    private var sourceColor: Color {
        switch schema.source {
        case .builtin: return .blue
        case .downloaded: return .orange
        }
    }
}

private struct RimeSchemaListRow: View {
    let schema: SchemaMetadata
    let statusText: String
    let symbol: RimeSchemaStatusSymbol
    let isActive: Bool

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 3) {
                Text(schema.name)
                    .font(.body)
                    .foregroundStyle(.primary)
                Text(rowSubtitle)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 6) {
                RimeSchemaStatusIcon(symbol: symbol)
                Text(statusText)
                    .font(.caption2)
                    .foregroundStyle(isActive ? .green : .secondary)
            }
        }
        .padding(.vertical, 2)
    }

    private var rowSubtitle: String {
        if let version = schema.version, !version.isEmpty {
            return "\(schema.downloadSize) · \(version)"
        }
        return schema.downloadSize
    }
}

private struct RimeSchemaStatusIcon: View {
    let symbol: RimeSchemaStatusSymbol

    var body: some View {
        ZStack {
            Circle()
                .fill(backgroundColor)
            if symbol == .working {
                ProgressView()
                    .controlSize(.mini)
                    .tint(.primary)
            } else {
                Image(systemName: systemImage)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(imageColor)
            }
        }
        .frame(width: 24, height: 24)
    }

    private var systemImage: String {
        switch symbol {
        case .active:
            return "checkmark"
        case .installed:
            return "tray.full"
        case .downloadable:
            return "arrow.down"
        case .failed:
            return "exclamationmark"
        case .working:
            return "arrow.triangle.2.circlepath"
        }
    }

    private var backgroundColor: Color {
        switch symbol {
        case .active:
            return .green
        case .installed:
            return Color(.tertiarySystemFill)
        case .downloadable, .working:
            return .orange.opacity(0.18)
        case .failed:
            return .red.opacity(0.18)
        }
    }

    private var imageColor: Color {
        switch symbol {
        case .active:
            return .white
        case .installed:
            return .secondary
        case .downloadable, .working:
            return .orange
        case .failed:
            return .red
        }
    }
}

private struct RimeSchemaMetricLabel: View {
    let systemImage: String
    let text: String

    var body: some View {
        Label(text, systemImage: systemImage)
            .font(.caption)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private enum RimeSchemaStatusSymbol {
    case active
    case installed
    case downloadable
    case failed
    case working
}

#Preview {
    NavigationStack {
        RimeSettingsView(store: RimeSettingsStore())
    }
}
