import SwiftUI

/// Slim J3 resource-prepare panel for Help (`PD-HELP-J3-RESOURCES-001`).
///
/// Reuses `RimeSettingsStore` — no second deployment path. Does not expose
/// uninstall, force redownload, or advanced management.
struct ActivationResourcePreparePanel: View {
    @Bindable var store: RimeSettingsStore

    /// User's in-panel selection (not necessarily active yet).
    @State private var selectedSchemaID: String = ActivationChecklistState.recommendedSchemaID
    @State private var showLicense = false

    private var orderedSchemas: [SchemaMetadata] {
        let schemas = store.schemas
        if schemas.isEmpty {
            return []
        }
        // Prefer 雾凇 first (recommended), then 朙月, then others.
        return schemas.sorted { lhs, rhs in
            rank(lhs.schemaID) < rank(rhs.schemaID)
        }
    }

    private func rank(_ id: String) -> Int {
        switch id {
        case ActivationChecklistState.recommendedSchemaID: return 0
        case ActivationChecklistState.builtinSchemaID: return 1
        default: return 2
        }
    }

    private var selectedSchema: SchemaMetadata? {
        orderedSchemas.first { $0.schemaID == selectedSchemaID }
            ?? orderedSchemas.first
    }

    private var isDownloadBusy: Bool {
        switch store.downloadState {
        case .fetchingReleaseInfo, .downloading, .extracting, .postProcessing, .deploying:
            return true
        default:
            return false
        }
    }

    private var isDeployBusy: Bool {
        switch store.deploymentState {
        case .triggered, .deploying:
            return true
        default:
            return false
        }
    }

    private var selectedIsActiveAndReady: Bool {
        guard let schema = selectedSchema else { return false }
        let deployedFlag = UserDefaults(suiteName: universeAppGroupID)?.bool(forKey: "rime_deployed") == true
        let deployLooksHealthy =
            store.deploymentState == .deployed
            || (deployedFlag && store.deploymentState != .failed && !isDeployBusy)
        return schema.schemaID == store.activeSchemaID
            && schema.installed
            && deployLooksHealthy
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.group) {
            Text(ActivationCopy.resourcesRecommendRimeIce)
                .font(.footnote)
                .foregroundStyle(.secondary)
            Text(ActivationCopy.resourcesSelectThenPrepare)
                .font(.footnote)
                .foregroundStyle(.secondary)

            if orderedSchemas.isEmpty {
                Text("正在加载方案列表…")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(orderedSchemas) { schema in
                    schemeRow(schema)
                }
            }

            if let schema = selectedSchema {
                selectedActions(for: schema)
            }

            downloadStatusBlock

            deployStatusBlock

            NavigationLink {
                RimeSettingsView(store: store)
            } label: {
                Label(ActivationCopy.resourcesOpenFullSettings, systemImage: "gearshape")
                    .font(.subheadline.weight(.semibold))
            }
        }
        .onAppear {
            store.load()
            // Default selection: recommended if present, else current active.
            if orderedSchemas.contains(where: { $0.schemaID == ActivationChecklistState.recommendedSchemaID }) {
                selectedSchemaID = ActivationChecklistState.recommendedSchemaID
            } else if !store.activeSchemaID.isEmpty {
                selectedSchemaID = store.activeSchemaID
            }
        }
        .sheet(isPresented: $showLicense) {
            LicenseView(
                acceptTitle: ActivationCopy.resourcesAcceptLicenseAndDownload,
                acceptSystemImage: "arrow.down.to.line"
            ) {
                let schemaID = selectedSchemaID
                store.acceptLicense(for: schemaID)
                store.startDownload(schemaID: schemaID)
            }
        }
    }

    private func schemeRow(_ schema: SchemaMetadata) -> some View {
        let isSelected = schema.schemaID == selectedSchemaID
        let isRecommended = schema.schemaID == ActivationChecklistState.recommendedSchemaID
        return Button {
            selectedSchemaID = schema.schemaID
        } label: {
            HStack(alignment: .top, spacing: AppSpacing.row) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isSelected ? Color.primary : Color.secondary)
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text(schema.name)
                            .font(.body.weight(.medium))
                            .foregroundStyle(.primary)
                        if isRecommended {
                            CapsuleBadge(text: "推荐", color: .primary, style: .tinted)
                        }
                        if schema.source == .downloaded {
                            CapsuleBadge(text: "开源", color: .orange, style: .tinted)
                        } else {
                            CapsuleBadge(text: "内置", color: .blue, style: .tinted)
                        }
                    }
                    Text(schema.description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                    Text(schema.installed ? "已安装" : (schema.isDownloadable ? "需下载" : "未安装"))
                        .font(.caption2)
                        .foregroundStyle(schema.installed ? Color.secondary : Color.orange)
                }
                Spacer(minLength: 0)
            }
            .padding(AppSpacing.card)
            .background(
                RoundedRectangle(cornerRadius: AppRadius.control, style: .continuous)
                    .fill(Color(.tertiarySystemGroupedBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.control, style: .continuous)
                    .strokeBorder(isSelected ? Color.primary.opacity(0.35) : Color.clear, lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(schema.name)\(isRecommended ? "，推荐" : "")，\(schema.installed ? "已安装" : "需下载")")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    @ViewBuilder
    private func selectedActions(for schema: SchemaMetadata) -> some View {
        if schema.isDownloadable, !schema.installed {
            VStack(alignment: .leading, spacing: AppSpacing.group) {
                if let licenseName = schema.licenseName {
                    Text("开源许可证：\(licenseName)。下载前请阅读并接受。")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                // Single CTA: open license sheet; accept there starts download.
                // If already accepted (e.g. previous session), download directly.
                let alreadyAccepted = store.licenseAccepted(for: schema.schemaID)
                AppActionButton(
                    title: isDownloadBusy
                        ? "正在处理…"
                        : (alreadyAccepted
                            ? "下载并安装"
                            : ActivationCopy.resourcesViewLicenseAndDownload),
                    systemImage: alreadyAccepted ? "arrow.down.to.line" : "doc.text.magnifyingglass",
                    prominence: .primary
                ) {
                    if alreadyAccepted {
                        store.startDownload(schemaID: schema.schemaID)
                    } else {
                        showLicense = true
                    }
                }
                .disabled(isDownloadBusy)
            }
        } else if schema.installed {
            if schema.schemaID != store.activeSchemaID || !selectedIsActiveAndReady {
                AppActionButton(
                    title: ActivationCopy.resourcesActivateAndDeploy,
                    systemImage: "arrow.triangle.2.circlepath",
                    prominence: .primary
                ) {
                    Task { await store.switchToSchema(schema.schemaID) }
                }
                .disabled(isDeployBusy || isDownloadBusy)
            } else {
                Label("当前方案已安装并部署成功", systemImage: "checkmark.circle.fill")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.primary)
            }
        }
    }

    @ViewBuilder
    private var downloadStatusBlock: some View {
        switch store.downloadState {
        case .idle, .completed:
            EmptyView()
        case .fetchingReleaseInfo:
            statusLine(systemImage: "arrow.down.circle", text: "正在获取版本信息…", color: .secondary)
        case .downloading(let progress):
            statusLine(
                systemImage: "arrow.down.circle",
                text: "正在下载… \(Int(progress * 100))%",
                color: .secondary
            )
        case .extracting, .postProcessing:
            statusLine(systemImage: "archivebox", text: "正在安装…", color: .secondary)
        case .deploying:
            statusLine(systemImage: "arrow.triangle.2.circlepath", text: "下载后正在部署…", color: .secondary)
        case .failed(let message):
            VStack(alignment: .leading, spacing: 8) {
                statusLine(systemImage: "exclamationmark.triangle.fill", text: message, color: .orange)
                AppActionButton(
                    title: "重试下载",
                    systemImage: "arrow.clockwise",
                    prominence: .secondary
                ) {
                    store.startDownload(schemaID: selectedSchemaID)
                }
            }
        }
    }

    @ViewBuilder
    private var deployStatusBlock: some View {
        switch store.deploymentState {
        case .idle, .needsDeploy, .deployed:
            EmptyView()
        case .triggered, .deploying:
            statusLine(
                systemImage: "arrow.triangle.2.circlepath",
                text: store.deploymentStatusHint,
                color: .secondary
            )
        case .failed:
            VStack(alignment: .leading, spacing: 8) {
                statusLine(
                    systemImage: "exclamationmark.triangle.fill",
                    text: store.deploymentStatusHint,
                    color: .orange
                )
                AppActionButton(
                    title: "重试部署",
                    systemImage: "arrow.clockwise",
                    prominence: .secondary
                ) {
                    Task { await store.triggerDeployment() }
                }
            }
        }
    }

    private func statusLine(systemImage: String, text: String, color: Color) -> some View {
        Label(text, systemImage: systemImage)
            .font(.footnote)
            .foregroundStyle(color)
            .fixedSize(horizontal: false, vertical: true)
    }
}
