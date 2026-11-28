import Foundation
import KeyboardCore
import SwiftUI

/// PB-015 PR-4（M3–M5）：RIME 方案页并入区块的文案锚点（与
/// `AppPR4StructuralConsolidationTests` 共同回归）。
enum RimeSettingsPageCopy {
    static let preferenceSectionHeader = "输入偏好"
}

/// PB-015 PR-4（M3，设计 r2 §4 冻结）：候选数量 / 默认简体变更的触发链。
///
/// 迁移是纯视图层移动；两项偏好变更必须继续执行
/// `savePreferences()` + `triggerDeployment()`（简繁/页大小变更走部署重建），
/// 键名 `rime_page_size` / `rime_simplification` 不改，`RimeSettingsStore` 零改动。
@MainActor
func commitRimeCandidatePreference(_ store: RimeSettingsStore) {
    store.savePreferences()
    Task { await store.triggerDeployment() }
}

struct RimeSettingsView: View {
    @Bindable var store: RimeSettingsStore
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

            // PB-015 PR-4（M4）：高级输入功能并入方案页（复用独立 View 的内容，
            // 独立页保留给 Search 深链；不与方案详情页的
            // `RimeAdvancedInputStatusContent` 形成双份控件）。
            RimeAdvancedInputSettingsContent(store: store)

            // PB-015 PR-4（M5）：模糊音并入方案页（复用独立 View 的内容，
            // 独立页保留给 Search 深链）。
            RimeFuzzyPinyinSettingsContent(store: store)

            candidatePreferenceSection
        }
        .navigationTitle("RIME 方案设置")
        .tint(.primary)
        .onAppear { store.load() }
        .onDisappear {
            store.stop()
            // PB-015 PR-4：并入区块原先在各自独立页的 onDisappear 触发；
            // 并入后由方案页统一承担（无待部署变更时为 no-op）。
            Task { await store.triggerPendingDeploymentIfNeeded() }
        }
    }

    /// PB-015 PR-4（M3）：候选数量滑杆 + 默认简体开关，从根设置页迁入。
    private var candidatePreferenceSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("候选数量")
                        .font(.body)
                    Spacer()
                    Text("\(Int(store.pageSize)) 个")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                AppSlider(
                    value: $store.pageSize,
                    in: 5...20,
                    step: 1,
                    onEditingChanged: { editing in
                        if !editing {
                            commitRimeCandidatePreference(store)
                        }
                    },
                    accessibilityLabel: "候选数量",
                    accessibilityValueText: "\(Int(store.pageSize)) 个")
                Text("每页最多显示的候选词个数。数量越少选词越快，数量越多翻页更少。")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 2)

            ToggleRow(
                title: "默认简体",
                description: store.simplified
                    ? "开启后使用 OpenCC 将结果转为简体中文输出。"
                    : "关闭后保留词典原始字形。",
                isOn: $store.simplified
            )
        } header: {
            Text(RimeSettingsPageCopy.preferenceSectionHeader)
        } footer: {
            Text("修改后如需部署，会在后台安静处理。")
        }
        .onChange(of: store.simplified) { _, _ in
            commitRimeCandidatePreference(store)
        }
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
            return RimeSchemeCapabilityMatrix.isDistributionDownloadSubject(schema.schemaID) ? "正在下载" : "未安装"
        case .failed(let failedSchemaID, _, _) where failedSchemaID == schema.schemaID:
            return "下载失败"
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
            return RimeSchemeCapabilityMatrix.isDistributionDownloadSubject(schema.schemaID) ? .working : .downloadable
        case .failed(let failedSchemaID, _, _) where failedSchemaID == schema.schemaID:
            return .failed
        default:
            return .downloadable
        }
    }
}

private struct RimeSchemaDetailView: View {
    let store: RimeSettingsStore
    let initialSchema: SchemaMetadata
    @State private var licensePresentation: SchemeLicensePresentation?
    @State private var showUninstallAlert = false
    @State private var schemaPendingSwitch: SchemaMetadata?
    @State private var showSchemaSwitchAlert = false
    @State private var showProvenance = false

    var body: some View {
        Form {
            Section {
                Button {
                    showProvenance = true
                } label: {
                    HStack(alignment: .top, spacing: 8) {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack(alignment: .firstTextBaseline, spacing: 8) {
                                Text(schema.name)
                                    .font(.headline)
                                    .foregroundStyle(.primary)
                                CapsuleBadge(text: sourceText, color: sourceColor, style: .tinted)
                                if schema.schemaID == store.activeSchemaID {
                                    CapsuleBadge(text: "当前使用", color: .green, style: .tinted)
                                }
                            }

                            Text(schema.description)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            LazyVGrid(
                                columns: [GridItem(.adaptive(minimum: 118), spacing: 8)],
                                spacing: 8
                            ) {
                                RimeSchemaMetricLabel(
                                    systemImage: schema.installed
                                        ? "checkmark.circle" : "arrow.down.circle",
                                    text: schema.installed ? "已安装" : "可下载"
                                )
                                RimeSchemaMetricLabel(
                                    systemImage: "internaldrive",
                                    text: schema.downloadSize
                                )
                                if let version = schema.version {
                                    RimeSchemaMetricLabel(systemImage: "tag", text: version)
                                }
                                if schema.requiresLua {
                                    RimeSchemaMetricLabel(systemImage: "sparkles", text: "高级输入")
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)

                        Image(systemName: "info.circle")
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .accessibilityHidden(true)
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("\(schema.name)方案信息")
                .accessibilityHint("查看版本与下载来源")
            } header: {
                Text("方案信息")
            }

            schemaActionSections
        }
        .navigationTitle(schema.name)
        .tint(.primary)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if schema.installed && schema.schemaID != store.activeSchemaID {
                    Button {
                        schemaPendingSwitch = schema
                        showSchemaSwitchAlert = true
                    } label: {
                        Label("使用", systemImage: "keyboard")
                    }
                    .disabled(store.deploymentState == .triggered || store.deploymentState == .deploying)
                }
            }
        }
        .sheet(isPresented: $showProvenance) {
            SchemeProvenanceSheet(presentation: provenancePresentation)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .sheet(item: $licensePresentation) { presentation in
            SchemeLicenseView(
                license: presentation.license,
                acceptTitle: presentation.action.buttonTitle,
                acceptSystemImage: presentation.action.buttonSystemImage
            ) {
                if presentation.action != .download {
                    store.acceptLicense(for: presentation.schemaID)
                }
                performLicenseAction(presentation.action, schemaID: presentation.schemaID)
            }
        }
        .alert("切换输入方案？", isPresented: $showSchemaSwitchAlert) {
            Button("切换并部署") {
                guard let selectedSchema = schemaPendingSwitch else { return }
                schemaPendingSwitch = nil
                Task { await store.switchToSchema(selectedSchema.schemaID) }
            }
            Button("取消", role: .cancel) {
                schemaPendingSwitch = nil
            }
        } message: {
            Text(switchConfirmationMessage)
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

    private var sourceVariant: RimeSchemeSourceVariant? {
        store.sourceVariant(for: schema.schemaID)
    }

    private var provenancePresentation: SchemeProvenancePresentation {
        SchemeProvenancePresentation.make(
            isDistributionBacked: schema.isDownloadable,
            installedVersion: schema.version,
            manifestVersion: store.manifestVersion(for: schema.schemaID),
            source: sourceVariant,
            hasVerifiedReceipt: store.hasVerifiedReceipt(for: schema.schemaID)
        )
    }

    private var switchConfirmationMessage: String {
        let name = schemaPendingSwitch?.name ?? schema.name
        return "切换到「\(name)」后，主 App 会自动重新部署 RIME。完成后回到键盘即可使用。"
    }

    @ViewBuilder
    private var schemaActionSections: some View {
        if RimeSchemeCapabilityMatrix.isProductAdvancedInputHost(schema.schemaID) {
            Section {
                RimeAdvancedInputStatusContent(
                    store: store,
                    onRedownload: {
                        performOrPresentLicense(.redownload, schema: schema)
                    }
                )
            } header: {
                Text("高级输入功能")
            } footer: {
                Text("这里显示日期、时间、计算器等动态候选的准备状态；具体开关可在高级输入功能设置中调整。")
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
                SchemaDownloadCardView(
                    schema: schema,
                    onShowLicense: { presentLicense(.download, schema: schema) }
                )
            } header: {
                Text("下载")
            }
        }

        if let failedSchemaID = store.downloadState.failedSchemaID,
            let message = store.downloadState.failureMessage(for: schema.schemaID),
            failedSchemaID == schema.schemaID
        {
            Section {
                RimeDownloadErrorContent(
                    message: message,
                    onRetry: { store.startDownload(schemaID: failedSchemaID) }
                )
            } header: {
                Text("下载失败")
            }
        }

        if schema.installed {
            Section {
                SchemaManageContent(
                    version: schema.version,
                    updateStatusMessage: store.updateStatusMessage,
                    onCheckForUpdate: { performOrPresentLicense(.checkForUpdate, schema: schema) },
                    onRedownload: { performOrPresentLicense(.redownload, schema: schema) },
                    onUninstall: { showUninstallAlert = true },
                    onShowLicense: { presentLicense(.review, schema: schema) }
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

    private func presentLicense(_ action: SchemeLicensePresentation.Action, schema: SchemaMetadata) {
        guard let license = schema.licenseDescriptor else { return }
        if action == .download {
            for effect in SchemeLicenseDownloadFlow.effects(
                for: .requestFirstDownload(entryPoint: .settingsDetail, schemaID: schema.schemaID)
            ) {
                guard case .presentLicense(_, let schemaID) = effect else {
                    assertionFailure("First-download request emitted an unexpected effect")
                    continue
                }
                licensePresentation = SchemeLicensePresentation(
                    schemaID: schemaID,
                    license: license,
                    action: .download
                )
            }
            return
        }
        licensePresentation = SchemeLicensePresentation(
            schemaID: schema.schemaID,
            license: license,
            action: action
        )
    }

    private func performOrPresentLicense(
        _ action: SchemeLicensePresentation.Action,
        schema: SchemaMetadata
    ) {
        guard store.licenseAccepted(for: schema.schemaID) else {
            presentLicense(action, schema: schema)
            return
        }
        performLicenseAction(action, schemaID: schema.schemaID)
    }

    private func performLicenseAction(
        _ action: SchemeLicensePresentation.Action,
        schemaID: String
    ) {
        switch action {
        case .review:
            break
        case .download:
            for effect in SchemeLicenseDownloadFlow.effects(
                for: .agreeToFirstDownload(entryPoint: .settingsDetail, schemaID: schemaID)
            ) {
                switch effect {
                case .acceptLicense(_, let selectedSchemaID):
                    store.acceptLicense(for: selectedSchemaID)
                case .startDownload(_, let selectedSchemaID):
                    store.startDownload(schemaID: selectedSchemaID)
                default:
                    assertionFailure("Download confirmation emitted an unexpected effect")
                }
            }
        case .redownload:
            store.forceRedownload(schemaID: schemaID)
        case .checkForUpdate:
            Task { await store.checkForUpdateAndDownload(schemaID: schemaID) }
        }
    }
}

private struct SchemeLicensePresentation: Identifiable {
    enum Action: String {
        case review
        case download
        case redownload
        case checkForUpdate

        var buttonTitle: String {
            switch self {
            case .review: return "我已阅读"
            case .download: return SchemeLicenseDownloadCopy.agreeAndDownload
            case .redownload: return "已阅读并重新下载"
            case .checkForUpdate: return "已阅读并检查更新"
            }
        }

        var buttonSystemImage: String {
            switch self {
            case .review: return "checkmark"
            case .download: return "arrow.down.to.line"
            case .redownload: return "arrow.down.circle"
            case .checkForUpdate: return "arrow.triangle.2.circlepath"
            }
        }
    }

    let schemaID: String
    let license: ThirdPartyLicenseDescriptor
    let action: Action

    var id: String { "\(schemaID)-\(action.rawValue)" }
}

private struct RimeAdvancedInputStatusContent: View {
    let store: RimeSettingsStore
    let onRedownload: () -> Void
    @State private var hasLoggedDiagnostic = false

    private var diagnostic: RimeLuaCapabilityDiagnostic {
        store.rimeIceAdvancedInputDiagnostic()
    }

    var body: some View {
        let currentDiagnostic = diagnostic
        Group {
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Label(
                        store.advancedInputStatusText(for: currentDiagnostic),
                        systemImage: statusImage(for: currentDiagnostic)
                    )
                    .font(.body)

                    Spacer()
                }

                Text(store.advancedInputStatusDetail(for: currentDiagnostic))
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 2)

            if let action = store.advancedInputRecoveryAction(for: currentDiagnostic) {
                AppActionButton(title: action.title, systemImage: action.systemImage) {
                    perform(action)
                }
            }

            NavigationLink(destination: RimeAdvancedInputSettingsView(store: store)) {
                Label("查看高级输入设置", systemImage: "slider.horizontal.3")
            }
            .font(.subheadline)

            NavigationLink(destination: DiagnosticsView()) {
                Label("查看诊断日志", systemImage: "doc.text.magnifyingglass")
            }
            .font(.subheadline)
        }
        .onAppear {
            guard !hasLoggedDiagnostic else { return }
            hasLoggedDiagnostic = true
            _ = store.rimeIceAdvancedInputDiagnostic(logResult: true)
        }
    }

    private func statusImage(for diagnostic: RimeLuaCapabilityDiagnostic) -> String {
        switch diagnostic.status {
        case .available:
            return "checkmark.circle"
        case .needsDeploy:
            return "exclamationmark.circle"
        case .notInstalled:
            return "arrow.down.circle"
        case .inactiveSchema:
            return "keyboard"
        case .engineUnavailable, .runtimeModuleMissing, .schemaMissing, .schemaStripped, .luaFilesMissing:
            return "xmark.circle"
        }
    }

    private func perform(_ action: RimeAdvancedInputRecoveryAction) {
        switch action {
        case .setCurrentSchema:
            guard let targetSchemaID = RimeSchemeCapabilityMatrix.productAdvancedInputTargetSchemaID() else {
                return
            }
            Task { await store.switchToSchema(targetSchemaID) }
        case .applySettings:
            Task { await store.triggerDeployment() }
        case .redownloadSchema:
            onRedownload()
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
