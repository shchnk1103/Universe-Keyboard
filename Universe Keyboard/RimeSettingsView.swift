import SwiftUI

private let appGroupID = "group.com.DoubleShy0N.Universe-Keyboard"

/// RIME 方案设置 + 方案选择 + 部署管理子页面。
struct RimeSettingsView: View {
    @StateObject private var schemaManager = SchemaManager()

    @State private var pageSize: Double = 9
    @State private var simplified: Bool = true
    @State private var deployState: DeployState = .idle
    @State private var deployLog: [String] = []
    @State private var deployTimer: Timer?
    @State private var logExpanded = false
    @State private var showLicense = false
    @State private var showUninstallAlert = false

    enum DeployState {
        case idle, triggered, deploying, deployed, failed

        var icon: String {
            switch self {
            case .idle:      return "circle"
            case .triggered: return "hourglass"
            case .deploying: return "arrow.triangle.2.circlepath"
            case .deployed:  return "checkmark.circle.fill"
            case .failed:    return "xmark.circle.fill"
            }
        }

        var color: Color {
            switch self {
            case .idle, .triggered: return .orange
            case .deploying:        return .blue
            case .deployed:         return .green
            case .failed:           return .red
            }
        }

        var label: String {
            switch self {
            case .idle:      return "未部署"
            case .triggered: return "等待键盘启动…"
            case .deploying: return "正在部署…"
            case .deployed:  return "已部署"
            case .failed:    return "部署超时"
            }
        }
    }

    var body: some View {
        Form {
            // MARK: 方案选择
            schemaPickerSection

            // MARK: 雾凇拼音（未安装）— 介绍 + 下载
            if !schemaManager.schemas.contains(where: { $0.schemaID == "rime_ice" && $0.installed }) {
                rimeIceInfoSection
            }

            // MARK: 下载进度
            if case .downloading = schemaManager.rimeIceDownloadState,
               case .fetchingReleaseInfo = schemaManager.rimeIceDownloadState,
               case .extracting = schemaManager.rimeIceDownloadState,
               case .postProcessing = schemaManager.rimeIceDownloadState {
                downloadProgressSection
            } else if case .downloading = schemaManager.rimeIceDownloadState {
                downloadProgressSection
            } else if case .fetchingReleaseInfo = schemaManager.rimeIceDownloadState {
                downloadProgressSection
            } else if case .extracting = schemaManager.rimeIceDownloadState {
                downloadProgressSection
            } else if case .postProcessing = schemaManager.rimeIceDownloadState {
                downloadProgressSection
            }

            // MARK: 下载错误
            if case .failed(let message) = schemaManager.rimeIceDownloadState {
                downloadErrorSection(message)
            }

            // MARK: 雾凇拼音（已安装）— 管理
            if schemaManager.schemas.contains(where: { $0.schemaID == "rime_ice" && $0.installed }) {
                rimeIceManageSection
            }

            // MARK: 候选数量
            candidateCountSection

            // MARK: 简繁切换
            simplificationSection

            // MARK: 部署
            deploySection
        }
        .navigationTitle("RIME 方案设置")
        .onAppear { loadSettings() }
        .onDisappear { deployTimer?.invalidate() }
        .sheet(isPresented: $showLicense) {
            LicenseView { schemaManager.acceptLicense() }
        }
        .alert("确认卸载", isPresented: $showUninstallAlert) {
            Button("取消", role: .cancel) {}
            Button("卸载", role: .destructive) { schemaManager.uninstallRimeIce() }
        } message: {
            Text("卸载雾凇拼音后，将自动切换回朙月拼音。已下载的词库文件将被删除。")
        }
    }

    // MARK: - Schema picker

    private var schemaPickerSection: some View {
        Section {
            VStack(spacing: 10) {
                ForEach(schemaManager.schemas) { schema in
                    if schema.schemaID == "rime_ice" && !schema.installed {
                        // 未安装，点击触发下载流程
                        rimeIceDownloadCard
                    } else {
                        SchemaPickerRow(
                            schema: schema,
                            isActive: schema.schemaID == schemaManager.activeSchemaID,
                            onSelect: { schemaManager.switchToSchema(schema.schemaID) }
                        )
                    }
                }
            }
        } header: {
            Text("输入方案")
        } footer: {
            if schemaManager.activeSchemaID == "rime_ice" {
                Text("雾凇拼音词库来源于社区维护的 rime-ice 项目，通过 OpenCC 实现简繁转换。部分高级功能（日期输入、计算器等）暂不可用。")
            } else {
                Text("基于 RIME 官方 Luna Pinyin 方案。更多方案请下载安装。")
            }
        }
    }

    // MARK: - rime-ice download card

    private var rimeIceDownloadCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text("雾凇拼音")
                            .font(.body.bold())
                        Text("需要下载")
                            .font(.caption2)
                            .foregroundStyle(.orange)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 1)
                            .background(Color.orange.opacity(0.12))
                            .clipShape(Capsule())
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
                Button {
                    showLicense = true
                } label: {
                    Label("查看许可证", systemImage: "doc.text.magnifyingglass")
                        .font(.subheadline)
                }
                .buttonStyle(.bordered)
                .controlSize(.small)

                Button {
                    schemaManager.startDownload()
                } label: {
                    Label("同意并下载", systemImage: "arrow.down.to.line")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
                .disabled(!schemaManager.rimeIceLicenseAccepted)
            }
        }
        .padding(12)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    // MARK: - rime-ice info

    private var rimeIceInfoSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 8) {
                Label("关于雾凇拼音", systemImage: "info.circle")
                    .font(.headline)
                Text("雾凇拼音 (rime-ice) 是一个开源的简体中文 RIME 配置方案，由社区维护。它包含：")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                VStack(alignment: .leading, spacing: 4) {
                    bullet("完整 cn_dicts 词库（8105 + base + ext + tencent），大幅提高候选准确率")
                    bullet("支持简繁转换")
                    bullet("支持 emoji 候选")
                    bullet("部分高级功能（如日期输入、计算器）需要 Lua 插件，暂不可用")
                }
                Text("下载后可在方案列表中选择切换，随时可卸载恢复默认方案。")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        } header: {
            Text("可用方案")
        }
    }

    private func bullet(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 6) {
            Text("•").foregroundStyle(.blue)
            Text(text)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Download progress

    private var downloadProgressSection: some View {
        Section {
            VStack(spacing: 12) {
                HStack(spacing: 10) {
                    ProgressView()
                    Text(downloadStatusLabel)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Button("取消") { schemaManager.cancelDownload() }
                        .font(.caption)
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                }
                if case .downloading(let progress) = schemaManager.rimeIceDownloadState {
                    ProgressView(value: progress)
                } else if case .extracting = schemaManager.rimeIceDownloadState {
                    ProgressView()
                } else if case .postProcessing = schemaManager.rimeIceDownloadState {
                    ProgressView()
                }
            }
        } header: {
            Text("下载进度")
        }
    }

    private var downloadStatusLabel: String {
        switch schemaManager.rimeIceDownloadState {
        case .fetchingReleaseInfo: return "正在获取最新版本信息…"
        case .downloading(let p):   return "正在下载… \(Int(p * 100))%"
        case .extracting:           return "正在解压配置文件…"
        case .postProcessing:       return "正在处理配置（剥离 Lua 依赖）…"
        default:                    return "准备中…"
        }
    }

    // MARK: - Download error

    private func downloadErrorSection(_ message: String) -> some View {
        Section {
            HStack(spacing: 10) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(.red)
                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(.red)
                Spacer()
                Button("重试") { schemaManager.startDownload() }
                    .font(.caption)
                    .buttonStyle(.bordered)
                    .controlSize(.small)
            }
        } header: {
            Text("下载失败")
        }
    }

    // MARK: - rime-ice manage (已安装)

    private var rimeIceManageSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Label("版本：\(schemaManager.rimeIceVersion ?? "未知")", systemImage: "tag")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Spacer()
                }
                HStack(spacing: 10) {
                    Button {
                        Task {
                            let hasUpdate = await schemaManager.checkForUpdate()
                            if hasUpdate {
                                schemaManager.startDownload()
                            }
                        }
                    } label: {
                        Label("检查更新", systemImage: "arrow.triangle.2.circlepath")
                            .font(.subheadline)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)

                    Button(role: .destructive) {
                        showUninstallAlert = true
                    } label: {
                        Label("卸载", systemImage: "trash")
                            .font(.subheadline)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                    .tint(.red)

                    Button {
                        showLicense = true
                    } label: {
                        Label("许可证", systemImage: "doc.text")
                            .font(.subheadline)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                }
            }
        } header: {
            Text("雾凇拼音管理")
        }
    }

    // MARK: - Candidate count

    private var candidateCountSection: some View {
        Section {
            VStack(spacing: 8) {
                HStack {
                    Text("\(Int(pageSize)) 个")
                        .font(.title3)
                        .fontWeight(.medium)
                        .foregroundStyle(.blue)
                    Spacer()
                }
                Slider(value: $pageSize, in: 5...20, step: 1)
            }
            .onChange(of: pageSize) { _, newValue in
                saveSettings()
            }
        } header: {
            Text("候选数量")
        } footer: {
            Text("每页最多显示的候选词个数。数量越少选词越快，数量越多翻页更少。默认 9 个。")
        }
    }

    // MARK: - Simplification

    private var simplificationSection: some View {
        Section {
            Toggle("默认简体", isOn: $simplified)
                .onChange(of: simplified) { _, _ in
                    saveSettings()
                }
        } header: {
            Text("简繁转换")
        } footer: {
            Text(simplified
                 ? "开启后使用 OpenCC 将结果转为简体中文输出。"
                 : "关闭后保留词典原始字形。")
        }
    }

    // MARK: - Deploy

    private var deploySection: some View {
        Section {
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 12) {
                    Image(systemName: deployState.icon).font(.title2).foregroundStyle(deployState.color)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(deployState.label).font(.headline).foregroundStyle(deployState.color)
                        Text(statusHint).font(.caption).foregroundStyle(.secondary)
                    }
                    Spacer()
                    if deployState == .triggered || deployState == .deploying { ProgressView() }
                }

                VStack(alignment: .leading, spacing: 6) {
                    deployStep(number: 1, text: "修改上方设置", done: deployState != .idle)
                    deployStep(number: 2, text: "点击「应用并重新部署」", done: deployState == .triggered || deployState == .deploying || deployState == .deployed)
                    deployStep(number: 3, text: "切换到键盘，打一个字", done: deployState == .deploying || deployState == .deployed)
                    deployStep(number: 4, text: "键盘自动完成部署（约 5-10 秒）", done: deployState == .deployed)
                }

                if !deployLog.isEmpty {
                    DisclosureGroup(isExpanded: $logExpanded) {
                        VStack(alignment: .leading, spacing: 2) {
                            ForEach(deployLog, id: \.self) { line in
                                Text(line)
                                    .font(.system(.caption, design: .monospaced))
                                    .foregroundStyle(.secondary)
                            }
                        }.padding(.top, 4)
                    } label: {
                        Text("部署日志 (\(deployLog.count) 条)").font(.caption).foregroundStyle(.secondary)
                    }
                }

                HStack(spacing: 12) {
                    Button(action: triggerDeploy) {
                        Label(
                            deployState == .deployed ? "重新部署" : "应用并重新部署",
                            systemImage: "arrow.triangle.2.circlepath"
                        ).font(.subheadline)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(deployState == .triggered || deployState == .deploying)

                    if deployState == .triggered || deployState == .deploying || deployState == .failed {
                        Button("取消") { cancelDeploy() }.buttonStyle(.bordered)
                    }
                    Spacer()
                    if !deployLog.isEmpty {
                        Button(role: .destructive, action: { deployLog = []; deployState = .idle }) {
                            Label("重置", systemImage: "arrow.counterclockwise").font(.caption)
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                    }
                }
            }
        } header: {
            Text("部署")
        } footer: {
            Text("修改设置后需要「部署」才能生效。部署由键盘扩展在后台执行。")
        }
    }

    private func deployStep(number: Int, text: String, done: Bool) -> some View {
        HStack(alignment: .top, spacing: 10) {
            ZStack {
                if done {
                    Image(systemName: "checkmark.circle.fill").foregroundStyle(.green)
                } else {
                    Text("\(number)").font(.caption2).fontWeight(.bold)
                        .foregroundStyle(.secondary).frame(width: 18, height: 18)
                        .background(Color(.systemGray5)).clipShape(Circle())
                }
            }
            Text(text).font(.caption).foregroundStyle(done ? .primary : .secondary)
        }
    }

    private var statusHint: String {
        switch deployState {
        case .idle:      return "修改设置后需重新部署方可生效"
        case .triggered: return "已设置部署标记，请切换到键盘打一个键"
        case .deploying: return "键盘正在编译配置和词库，请保持键盘打开…"
        case .deployed:  return "配置已生效 ✓"
        case .failed:    return "部署超时，请确认键盘已打开并重试"
        }
    }

    // MARK: - Actions

    private func loadSettings() {
        let defaults = UserDefaults(suiteName: appGroupID)
        let saved = defaults?.integer(forKey: "rime_page_size") ?? 0
        pageSize = Double(saved > 0 ? saved : 9)
        if defaults?.object(forKey: "rime_simplification") == nil {
            simplified = true
        } else {
            simplified = defaults?.bool(forKey: "rime_simplification") ?? true
        }
        checkDeployState()
    }

    private func saveSettings() {
        let defaults = UserDefaults(suiteName: appGroupID)
        defaults?.set(Int(pageSize), forKey: "rime_page_size")
        defaults?.set(simplified, forKey: "rime_simplification")
        defaults?.synchronize()
    }

    private func triggerDeploy() {
        deployState = .triggered
        deployLog = []
        addLog("→ 已设置部署标记")
        let defaults = UserDefaults(suiteName: appGroupID)
        defaults?.set(false, forKey: "rime_deployed")
        defaults?.set(true, forKey: "rime_needs_deploy")
        defaults?.synchronize()
        addLog("等待键盘扩展启动…")
        pollDeployStatus(attempt: 0)
    }

    private func pollDeployStatus(attempt: Int) {
        guard deployState == .triggered || deployState == .deploying else { return }
        let defaults = UserDefaults(suiteName: appGroupID)
        if defaults?.bool(forKey: "rime_deployed") ?? false {
            deployState = .deployed
            addLog("✓ 部署成功！RIME 引擎已就绪")
            return
        }
        if (defaults?.bool(forKey: "rime_deploying") ?? false) && deployState == .triggered {
            deployState = .deploying
            addLog("→ 键盘正在部署中…")
        }
        if attempt >= 60 {
            deployState = .failed
            addLog("✗ 部署超时（2 分钟）")
            return
        }
        deployTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { _ in
            pollDeployStatus(attempt: attempt + 1)
        }
    }

    private func cancelDeploy() {
        deployTimer?.invalidate()
        deployState = .idle
        addLog("→ 已取消")
        UserDefaults(suiteName: appGroupID)?.set(false, forKey: "rime_needs_deploy")
    }

    private func checkDeployState() {
        let defaults = UserDefaults(suiteName: appGroupID)
        if defaults?.bool(forKey: "rime_deployed") ?? false {
            deployState = .deployed
            deployLog = ["✓ RIME 已部署"]
        } else if defaults?.bool(forKey: "rime_deploying") ?? false {
            deployState = .deploying
        } else if defaults?.bool(forKey: "rime_needs_deploy") ?? false {
            deployState = .triggered
        }
    }

    private func addLog(_ message: String) {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        deployLog.append("[\(formatter.string(from: Date()))] \(message)")
    }
}

#Preview {
    NavigationStack {
        RimeSettingsView()
    }
}
