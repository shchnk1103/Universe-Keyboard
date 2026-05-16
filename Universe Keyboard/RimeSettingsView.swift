import SwiftUI

private let appGroupID = "group.com.DoubleShy0N.Universe-Keyboard"

/// RIME 方案设置 + 部署管理子页面。
struct RimeSettingsView: View {
    @State private var pageSize: Double = 9
    @State private var simplified: Bool = true
    @State private var deployState: DeployState = .idle
    @State private var deployLog: [String] = []
    @State private var deployTimer: Timer?
    @State private var logExpanded = false

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
            // MARK: 当前方案
            Section {
                HStack {
                    Text("当前方案")
                    Spacer()
                    Text("朙月拼音")
                        .foregroundStyle(.secondary)
                }
            } header: {
                Text("输入方案")
            } footer: {
                Text("基于 RIME 官方 Luna Pinyin 方案，支持全拼输入。更多方案即将推出。")
            }

            // MARK: 候选数量
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

            // MARK: 简繁切换
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
                     : "关闭后保留词典原始字形（可能包含繁体或异体字，待引入雾凇拼音方案后改善）。")
            }

            // MARK: 部署
            Section {
                VStack(alignment: .leading, spacing: 14) {
                    // 状态指示器
                    HStack(spacing: 12) {
                        Image(systemName: deployState.icon)
                            .font(.title2)
                            .foregroundStyle(deployState.color)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(deployState.label)
                                .font(.headline)
                                .foregroundStyle(deployState.color)
                            Text(statusHint)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        if deployState == .triggered || deployState == .deploying {
                            ProgressView()
                        }
                    }

                    // 部署步骤清单
                    VStack(alignment: .leading, spacing: 6) {
                        stepView(number: 1, text: "修改上方设置（候选数量或简繁）", done: deployState != .idle)
                        stepView(number: 2, text: "点击「应用并重新部署」按钮", done: deployState == .triggered || deployState == .deploying || deployState == .deployed)
                        stepView(number: 3, text: "切换到键盘，在任意输入框打一个字", done: deployState == .deploying || deployState == .deployed)
                        stepView(number: 4, text: "键盘自动完成部署（约 5-10 秒）", done: deployState == .deployed)
                    }

                    // 部署日志（可折叠）
                    if !deployLog.isEmpty {
                        DisclosureGroup(isExpanded: $logExpanded) {
                            VStack(alignment: .leading, spacing: 2) {
                                ForEach(deployLog, id: \.self) { line in
                                    Text(line)
                                        .font(.system(.caption, design: .monospaced))
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .padding(.top, 4)
                        } label: {
                            Text("部署日志 (\(deployLog.count) 条)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }

                    // 操作按钮
                    HStack(spacing: 12) {
                        Button(action: triggerDeploy) {
                            Label(
                                deployState == .deployed ? "重新部署" : "应用并重新部署",
                                systemImage: "arrow.triangle.2.circlepath"
                            )
                            .font(.subheadline)
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(deployState == .triggered || deployState == .deploying)

                        if deployState == .triggered || deployState == .deploying || deployState == .failed {
                            Button("取消") {
                                cancelDeploy()
                            }
                            .buttonStyle(.bordered)
                        }

                        Spacer()

                        if !deployLog.isEmpty {
                            Button(role: .destructive, action: {
                                deployLog = []
                                deployState = .idle
                            }) {
                                Label("重置", systemImage: "arrow.counterclockwise")
                                    .font(.caption)
                            }
                            .buttonStyle(.bordered)
                            .controlSize(.small)
                        }
                    }
                }
            } header: {
                Text("部署")
            } footer: {
                Text("修改设置后需要「部署」才能生效。部署由键盘扩展在后台执行——点击按钮后，切换到键盘打字即可自动触发。整个过程约需 5-10 秒，只需部署一次。")
            }
        }
        .navigationTitle("RIME 方案设置")
        .onAppear { loadSettings() }
        .onDisappear { deployTimer?.invalidate() }
    }

    // MARK: - Status hint

    private var statusHint: String {
        switch deployState {
        case .idle:
            return "修改设置后需重新部署方可生效"
        case .triggered:
            return "已设置部署标记，请切换到键盘打一个键"
        case .deploying:
            return "键盘正在编译配置和词库，请保持键盘打开…"
        case .deployed:
            return "配置已生效 ✓"
        case .failed:
            return "部署超时，请确认键盘已打开并重试"
        }
    }

    private func stepView(number: Int, text: String, done: Bool) -> some View {
        HStack(alignment: .top, spacing: 10) {
            ZStack {
                if done {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                } else {
                    Text("\(number)")
                        .font(.caption2).fontWeight(.bold)
                        .foregroundStyle(.secondary)
                        .frame(width: 18, height: 18)
                        .background(Color(.systemGray5)).clipShape(Circle())
                }
            }
            Text(text)
                .font(.caption)
                .foregroundStyle(done ? .primary : .secondary)
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
        let deployed = defaults?.bool(forKey: "rime_deployed") ?? false
        let deploying = defaults?.bool(forKey: "rime_deploying") ?? false

        if deployed {
            deployState = .deployed
            addLog("✓ 部署成功！RIME 引擎已就绪")
            return
        }
        if deploying && deployState == .triggered {
            deployState = .deploying
            addLog("→ 键盘正在部署中…")
        }
        if attempt >= 60 {
            deployState = .failed
            addLog("✗ 部署超时（2 分钟），请确认键盘已打开并重试")
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
        let defaults = UserDefaults(suiteName: appGroupID)
        defaults?.set(false, forKey: "rime_needs_deploy")
        defaults?.synchronize()
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
        let timestamp = formatter.string(from: Date())
        deployLog.append("[\(timestamp)] \(message)")
    }
}

#Preview {
    NavigationStack {
        RimeSettingsView()
    }
}
