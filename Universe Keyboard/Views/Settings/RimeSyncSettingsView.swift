import SwiftUI
import UniformTypeIdentifiers

struct RimeSyncSettingsView: View {
    @Bindable var model: RimeSyncViewModel
    @State private var showFolderPicker = false
    @State private var showRecoveryCodeImport = false
    @State private var showStandardRimeSyncConfirmation = false
    @State private var showDisconnectConfirmation = false
    @State private var showRemoteDeletionConfirmation = false

    var body: some View {
        Form {
            statusSection
            providerSection
            if model.provider == .localFolder {
                automaticSyncSection
            }
            contentSection
            securitySection
            if model.provider != .none {
                managementSection
            }
        }
        .navigationTitle("RIME 云同步")
        .tint(.primary)
        .task { await model.loadSecrets() }
        .fileImporter(
            isPresented: $showFolderPicker,
            allowedContentTypes: [.folder],
            allowsMultipleSelection: false,
            onCompletion: handleFolderSelection
        )
        .alert("同步 RIME 数据？", isPresented: $showStandardRimeSyncConfirmation) {
            Button("取消", role: .cancel) {}
            Button("开始同步") {
                Task { await model.synchronizeAllNow() }
            }
        } message: {
            Text("这会先按 RIME 官方规则合并常用词快照、备份可移植 YAML/TXT，再同步 Universe 加密设置。请确认此时没有在使用键盘；标准 RIME 数据不由 Universe 端到端加密。完成后会默认开启安全的自动同步。")
        }
        .alert("断开同步？", isPresented: $showDisconnectConfirmation) {
            Button("取消", role: .cancel) {}
            Button("断开", role: .destructive) {
                Task { await model.disconnect(deleteRemoteData: false) }
            }
        } message: {
            Text("本机将停止 Universe 私密设置同步。已生成的 RIME 标准同步目录和其他设备数据会保留。")
        }
        .alert("删除云端同步数据？", isPresented: $showRemoteDeletionConfirmation) {
            Button("取消", role: .cancel) {}
            Button("删除并断开", role: .destructive) {
                Task { await model.disconnect(deleteRemoteData: true) }
            }
        } message: {
            Text("这只会删除当前同步位置中的 universe-rime-sync 加密设置包，并清除本机同步密钥。RIME 标准同步目录和其他设备数据不会被删除。")
        }
    }

    private var statusSection: some View {
        Section {
            HStack(spacing: 12) {
                Image(systemName: model.statusSystemImage)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(statusColor)
                    .frame(width: 30)

                VStack(alignment: .leading, spacing: 3) {
                    Text(statusTitle)
                        .font(.body.weight(.medium))
                    Text(model.statusText)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                if case .syncing(_) = model.status {
                    ProgressView()
                        .controlSize(.small)
                }
            }

            if model.isConfigured {
                AppActionButton(
                    title: "立即同步",
                    systemImage: "arrow.triangle.2.circlepath",
                    prominence: .primary
                ) {
                    if model.canSynchronizeStandardRimeData {
                        showStandardRimeSyncConfirmation = true
                    } else {
                        Task { await model.synchronizeAllNow() }
                    }
                }
                .disabled(isSynchronizing)
            } else if model.folderSelectionNeedsRepair {
                AppActionButton(
                    title: "重新选择同步文件夹",
                    systemImage: "folder.badge.questionmark",
                    prominence: .primary
                ) {
                    showFolderPicker = true
                }
            }
        } header: {
            Text("同步状态")
        } footer: {
            Text("选择共享文件夹后，“立即同步”会先同步常用词，再同步 Universe 私密设置。键盘输入始终保持离线。")
        }
    }

    private var automaticSyncSection: some View {
        Section {
            Toggle(
                "自动同步",
                isOn: Binding(
                    get: { model.automaticSyncEnabled },
                    set: { model.setAutomaticSyncEnabled($0) }
                )
            )
            .disabled(!model.canEnableAutomaticStandardSync)

            if model.automaticSyncEnabled {
                Toggle(
                    isOn: Binding(
                        get: { model.automaticStandardRimeDataEnabled },
                        set: { model.setAutomaticStandardRimeDataEnabled($0) }
                    )
                ) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text("RIME 标准同步")
                        Text("合并常用词和候选学习，并按 RIME 官方规则备份每台设备的配置。")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Toggle(
                    isOn: Binding(
                        get: { model.automaticPrivateSettingsEnabled },
                        set: { model.setAutomaticPrivateSettingsEnabled($0) }
                    )
                ) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Universe 设置同步")
                        Text("同步方案、候选数量、简繁、模糊音等 App 设置，并使用端到端加密。")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Picker(
                    "同步间隔",
                    selection: Binding(
                        get: { model.automaticSyncCadence },
                        set: { model.setAutomaticSyncCadence($0) }
                    )
                ) {
                    ForEach(RimeAutomaticSyncCadence.allCases) { cadence in
                        Text(cadence.title).tag(cadence)
                    }
                }

                Toggle(
                    "同步通知",
                    isOn: Binding(
                        get: { model.automaticSyncNotificationsEnabled },
                        set: { enabled in
                            Task { await model.setAutomaticSyncNotificationsEnabled(enabled) }
                        }
                    )
                )
                .disabled(!model.hasEnabledAutomaticSyncScope)
            }

            if let notice = model.automaticSyncNotice {
                Text(notice)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        } header: {
            Text("自动同步")
        } footer: {
            Text("\(model.automaticSyncScheduleText) 总开关关闭后，两项都不会自动运行；“立即同步”仍会完整同步两部分。同步间隔表示两次尝试之间至少等待多久，不保证固定时刻。RIME 标准同步会在键盘正在使用时跳过；开启通知并允许系统权限后，会明确告诉你本次同步的是哪一部分。")
        }
    }

    private var providerSection: some View {
        Section {
            Picker("同步方式", selection: providerBinding) {
                ForEach(RimeSyncProvider.allCases) { provider in
                    Text(provider.title).tag(provider)
                }
            }

            switch model.provider {
            case .none:
                Text("选择共享文件夹可启用与其他 RIME 输入法兼容的标准同步；WebDAV 只同步 Universe 私密设置。")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            case .localFolder:
                HStack {
                    Label(localFolderTitle, systemImage: "folder.badge.gearshape")
                    Spacer()
                    Button(model.folderName == nil ? "选择" : "重新选择") {
                        showFolderPicker = true
                    }
                }
                if let recoveryMessage = model.localFolderRecoveryMessage {
                    Text(recoveryMessage)
                        .font(.footnote)
                        .foregroundStyle(.orange)
                }
            case .webDAV:
                TextField("服务器地址", text: $model.webDAVURL, prompt: Text("https://example.com/dav/user"))
                    .keyboardType(.URL)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                TextField("用户名", text: $model.webDAVUsername)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                SecureField("密码或应用专用密码", text: $model.webDAVPassword)
                    .textContentType(.password)
                AppActionButton(title: "保存 WebDAV 设置", systemImage: "checkmark") {
                    Task { await model.saveWebDAVConfiguration() }
                }
            }
        } header: {
            Text("同步方式")
        } footer: {
            Text(providerFooter)
        }
    }

    private var contentSection: some View {
        Section {
            Label {
                VStack(alignment: .leading, spacing: 2) {
                    Text(model.canSynchronizeStandardRimeData ? "RIME 标准资料" : "Universe RIME 设置")
                    Text(model.canSynchronizeStandardRimeData
                        ? "常用词快照、custom YAML/TXT 和方案选择"
                        : "方案、候选数量、简繁、模糊音和高级输入")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            } icon: {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
            }

            Label {
                VStack(alignment: .leading, spacing: 2) {
                    Text("自定义配置文件")
                    Text(model.canSynchronizeStandardRimeData
                        ? "按 RIME 官方规则备份到每台设备的目录"
                        : "需要选择 RIME 标准文件夹后才会同步")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            } icon: {
                Image(systemName: "clock")
                    .foregroundStyle(.secondary)
            }

            Label {
                VStack(alignment: .leading, spacing: 2) {
                    Text("候选学习记录")
                    Text(model.canSynchronizeStandardRimeData
                        ? "通过官方常用词快照合并，不复制运行数据库"
                        : "当前不会上传你的输入习惯")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            } icon: {
                Image(systemName: "lock.fill")
                    .foregroundStyle(.secondary)
            }
        } header: {
            Text("同步内容")
        } footer: {
            Text(model.canSynchronizeStandardRimeData
                ? "共享文件夹中的资料可被兼容的 RIME 输入法读取。输入洞察、诊断日志、运行数据库和下载资源不会同步。"
                : "私密设置同步不包含用户词典、输入洞察、诊断日志或键盘输入。")
        }
    }

    private var securitySection: some View {
        Section {
            Label("端到端加密", systemImage: "lock.shield.fill")
                .foregroundStyle(model.recoveryCode.isEmpty ? .secondary : .primary)

            if !model.recoveryCode.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    Text("恢复码")
                        .font(.subheadline.weight(.medium))
                    Text(model.recoveryCode)
                        .font(.caption.monospaced())
                        .textSelection(.enabled)
                        .foregroundStyle(.secondary)

                    AppActionButton(
                        title: "保存恢复码",
                        systemImage: "square.and.arrow.up",
                        prominence: .primary,
                        shareText: model.recoveryCode
                    )

                    AppActionButton(
                        title: "使用已有恢复码",
                        systemImage: "key.fill"
                    ) {
                        showRecoveryCodeImport.toggle()
                    }
                }
                .padding(.vertical, 3)

                if showRecoveryCodeImport {
                    recoveryCodeImportFields
                }
            } else {
                recoveryCodeImportFields
            }
        } header: {
            Text("Universe 私密设置")
        } footer: {
            Text("恢复码只用于 Universe 加密设置包。它不会加密 RIME 标准同步资料；恢复码丢失后无法读取私密设置包。")
        }
    }

    private var recoveryCodeImportFields: some View {
        Group {
            SecureField("输入另一台设备的恢复码", text: $model.recoveryCodeInput)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
            Button("导入恢复码") {
                Task {
                    await model.importRecoveryCode()
                    if model.recoveryCodeInput.isEmpty {
                        showRecoveryCodeImport = false
                    }
                }
            }
            .disabled(model.recoveryCodeInput.isEmpty)
        }
    }

    private var managementSection: some View {
        Section {
            Button("断开本机同步", role: .destructive) {
                showDisconnectConfirmation = true
            }
            Button("删除云端数据并断开", role: .destructive) {
                showRemoteDeletionConfirmation = true
            }
        } header: {
            Text("管理")
        }
    }

    private var providerBinding: Binding<RimeSyncProvider> {
        Binding {
            model.provider
        } set: { provider in
            model.selectProvider(provider)
            if provider == .localFolder, model.folderName == nil {
                showFolderPicker = true
            }
        }
    }

    private var statusTitle: String {
        switch model.status {
        case .syncing(_): return "正在同步"
        case .succeeded(_, _): return "同步正常"
        case .failed: return "需要处理"
        case .idle, .notConfigured: return model.isConfigured ? "同步已配置" : "设置云同步"
        }
    }

    private var statusColor: Color {
        switch model.status {
        case .succeeded(_, _): return .green
        case .failed: return .orange
        case .syncing(_), .idle, .notConfigured: return .primary
        }
    }

    private var isSynchronizing: Bool {
        if case .syncing(_) = model.status { return true }
        return false
    }

    private var providerFooter: String {
        switch model.provider {
        case .none:
            return "当前没有数据离开设备。"
        case .localFolder:
            if model.folderSelectionNeedsRepair {
                return "新选择未生效；同步已暂停，请重新选择一个可写文件夹。"
            }
            return "所选文件夹就是 RIME 的共享资料夹。请在其他设备的 RIME 中配置同一路径；里面的标准 RIME 资料不由 Universe 加密。"
        case .webDAV:
            return "推荐使用 HTTPS。WebDAV 仅存放加密的 Universe 私密设置，不能直接供其他 RIME 输入法作为 sync_dir 使用。"
        }
    }

    private var localFolderTitle: String {
        guard let folderName = model.folderName else { return "尚未选择文件夹" }
        return model.folderSelectionNeedsRepair ? "之前的：\(folderName)" : folderName
    }

    private func handleFolderSelection(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            // 必须在 fileImporter 回调结束前获取安全作用域。后续异步 Task 仍持有
            // 此访问，才能稳定地预检 iCloud Drive 或第三方文件提供器目录。
            let didStartAccess = url.startAccessingSecurityScopedResource()
            Task {
                defer {
                    if didStartAccess {
                        url.stopAccessingSecurityScopedResource()
                    }
                }
                await model.configureLocalFolder(
                    url,
                    hasActivePickerScope: didStartAccess
                )
            }
        case .failure(let error):
            model.reportLocalFolderPickerFailure(error)
        }
    }
}

@MainActor
private func previewSyncModel(
    provider: RimeSyncProvider = .none,
    status: RimeSyncStatus = .notConfigured
) -> RimeSyncViewModel {
    let defaults = UserDefaults(suiteName: "rime-sync-preview-\(UUID().uuidString)") ?? .standard
    if provider == .localFolder {
        let folderURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("RIME Standard Sync Preview", isDirectory: true)
        try? FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: true)
        if let bookmark = try? folderURL.bookmarkData(
            options: [],
            includingResourceValuesForKeys: nil,
            relativeTo: nil
        ) {
            defaults.set(bookmark, forKey: "rime_sync_folder_bookmark")
            defaults.set(folderURL.lastPathComponent, forKey: "rime_sync_folder_name")
        }
    }
    let model = RimeSyncViewModel(rimeStore: RimeSettingsStore(), defaults: defaults)
    model.selectProvider(provider)
    model.status = status
    return model
}

#Preview("未配置") {
    NavigationStack {
        RimeSyncSettingsView(model: previewSyncModel())
    }
}

#Preview("同步失败") {
    NavigationStack {
        RimeSyncSettingsView(
            model: previewSyncModel(
                provider: .webDAV,
                status: .failed("WebDAV 认证失败，请检查账号和权限。")
            )
        )
    }
}

#Preview("RIME 标准同步") {
    NavigationStack {
        RimeSyncSettingsView(
            model: previewSyncModel(provider: .localFolder, status: .idle)
        )
    }
}
