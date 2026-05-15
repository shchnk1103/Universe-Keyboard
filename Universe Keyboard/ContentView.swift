//
//  ContentView.swift
//  Universe Keyboard
//
//  主页面：Tab 分为「引导」和「设置」。
//

import SwiftUI

private let appGroupID = "group.com.DoubleShy0N.Universe-Keyboard"

struct ContentView: View {
    var body: some View {
        TabView {
            GuideTab()
                .tabItem {
                    Label("引导", systemImage: "book.pages")
                }
            SettingsTab()
                .tabItem {
                    Label("设置", systemImage: "gearshape")
                }
        }
    }
}

// MARK: - Tab 1: 引导

private struct GuideTab: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    headerSection
                    enableKeyboardSection
                    progressSection
                    testChecklistSection
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Universe Keyboard")
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: "keyboard")
                .font(.system(size: 34, weight: .semibold))
                .foregroundStyle(.blue)
            Text("基础键盘已经可以测试")
                .font(.title2)
                .fontWeight(.semibold)
            Text("本 App 负责引导启用键盘和配置引擎。真正输入文字的是 Keyboard Extension。")
                .font(.body)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var enableKeyboardSection: some View {
        InfoSection(title: "如何启用键盘", systemImage: "gearshape") {
            NumberedRow(number: 1, text: "打开系统设置")
            NumberedRow(number: 2, text: "进入 通用 → 键盘 → 键盘")
            NumberedRow(number: 3, text: "点 添加新键盘")
            NumberedRow(number: 4, text: "选择 Keyboard")
            NumberedRow(number: 5, text: "打开输入框，点地球键切换到 Universe Keyboard")
            Text("首次使用需要在系统设置中添加一次键盘，之后随时可通过地球键切换。")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .padding(.top, 6)
        }
    }

    private var progressSection: some View {
        InfoSection(title: "当前进度", systemImage: "checkmark.circle") {
            BulletRow(text: "26 键字母输入")
            BulletRow(text: "Shift 大小写切换 + Caps Lock")
            BulletRow(text: "123 数字/符号页")
            BulletRow(text: "Inline preedit（拼音内联显示）")
            BulletRow(text: "RIME 中文候选引擎")
            BulletRow(text: "长按删除")
            BulletRow(text: "长按变体字符弹出")
        }
    }

    private var testChecklistSection: some View {
        InfoSection(title: "测试清单", systemImage: "list.bullet.clipboard") {
            BulletRow(text: "输入 nihao，候选栏应显示候选词")
            BulletRow(text: "按空格，应上屏第一个候选")
            BulletRow(text: "按 return，应提交原始拼音")
            BulletRow(text: "长按删除键，应连续删除")
            BulletRow(text: "长按字母键，应弹出变体字符")
        }
    }
}

// MARK: - Tab 2: 设置

private struct SettingsTab: View {
    @State private var keyClickEnabled: Bool = {
        UserDefaults(suiteName: appGroupID)?.bool(forKey: "key_click_enabled") ?? true
    }()
    @State private var hapticEnabled: Bool = {
        UserDefaults(suiteName: appGroupID)?.bool(forKey: "haptic_enabled") ?? false
    }()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    feedbackSection
                    if keyClickEnabled {
                        fullAccessGuideSection
                    }
                    rimeDeploySection
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("设置")
        }
    }

    // MARK: 键盘反馈

    private var feedbackSection: some View {
        InfoSection(title: "键盘反馈", systemImage: "waveform") {
            ToggleRow(
                title: "按键音",
                description: "按下按键时播放系统键盘音。需要「允许完全访问」。",
                isOn: $keyClickEnabled
            )
            .onChange(of: keyClickEnabled) { _, newValue in
                UserDefaults(suiteName: appGroupID)?.set(newValue, forKey: "key_click_enabled")
            }
            Divider()
            ToggleRow(
                title: "按键震动",
                description: "按下按键时提供触感反馈，无需额外权限。",
                isOn: $hapticEnabled
            )
            .onChange(of: hapticEnabled) { _, newValue in
                UserDefaults(suiteName: appGroupID)?.set(newValue, forKey: "haptic_enabled")
            }
        }
    }

    private var fullAccessGuideSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("需要开启「允许完全访问」", systemImage: "exclamationmark.shield.fill")
                .font(.headline)
                .foregroundStyle(.orange)
            Text("按键音和触感反馈需要键盘获得「允许完全访问」权限才能播放系统声音。")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            VStack(alignment: .leading, spacing: 8) {
                guideStep(number: 1, text: "打开系统「设置」")
                guideStep(number: 2, text: "进入「通用」→「键盘」→「键盘」")
                guideStep(number: 3, text: "点选「Keyboard」")
                guideStep(number: 4, text: "开启「允许完全访问」")
            }
            HStack(spacing: 6) {
                Image(systemName: "hand.raised.fill")
                    .font(.caption).foregroundStyle(.green)
                Text("键盘不会上传任何输入内容，所有数据仅存储在本地。")
                    .font(.caption).foregroundStyle(.secondary)
            }
            .padding(.top, 4)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemOrange).opacity(0.08))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.orange.opacity(0.3), lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func guideStep(number: Int, text: String) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            Text("\(number)")
                .font(.caption2).fontWeight(.bold).foregroundStyle(.orange)
                .frame(width: 18, height: 18)
                .background(Color.orange.opacity(0.15)).clipShape(Circle())
            Text(text).font(.subheadline)
        }
    }

    // MARK: RIME 部署

    @State private var deployPhase: DeployPhase = .idle
    @State private var deployLog: [String] = []

    enum DeployPhase {
        case idle        // 未部署
        case triggered   // 已触发，等待键盘启动
        case deploying   // 键盘正在部署中
        case deployed    // 部署成功
        case failed      // 部署超时

        var label: String {
            switch self {
            case .idle:      return "未部署"
            case .triggered: return "等待键盘启动…"
            case .deploying: return "正在部署…"
            case .deployed:  return "已部署"
            case .failed:    return "部署超时"
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

        var icon: String {
            switch self {
            case .idle:      return "circle"
            case .triggered: return "hourglass"
            case .deploying: return "arrow.triangle.2.circlepath"
            case .deployed:  return "checkmark.circle.fill"
            case .failed:    return "xmark.circle.fill"
            }
        }
    }

    private var rimeDeploySection: some View {
        InfoSection(title: "RIME 中文引擎", systemImage: "gearshape.2") {
            VStack(alignment: .leading, spacing: 12) {

                // 状态指示器
                HStack(spacing: 12) {
                    Image(systemName: deployPhase.icon)
                        .font(.title2)
                        .foregroundStyle(deployPhase.color)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(deployPhase.label)
                            .font(.headline)
                            .foregroundStyle(deployPhase.color)
                        Text(phaseDescription)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    if deployPhase == .triggered || deployPhase == .deploying {
                        ProgressView()
                            .progressViewStyle(.circular)
                    }
                }

                Divider()

                // 部署步骤说明
                VStack(alignment: .leading, spacing: 8) {
                    deployStep(number: 1, text: "点击下方「部署」按钮", done: deployPhase != .idle)
                    deployStep(number: 2, text: "在任何输入框中切换到 Universe Keyboard，开始打字", done: deployPhase == .deploying || deployPhase == .deployed)
                    deployStep(number: 3, text: "首次按键时自动完成部署（约 5-10 秒）", done: deployPhase == .deployed)
                }

                // 部署日志（可折叠）
                if !deployLog.isEmpty {
                    Divider()
                    collapsibleLogSection(title: "部署日志", lines: deployLog)
                }

                // 键盘诊断日志（可折叠）
                let diagLog = keyboardDiagLog
                if !diagLog.isEmpty {
                    Divider()
                    collapsibleLogSection(title: "键盘诊断", lines: diagLog)
                }

                // 操作按钮
                HStack(spacing: 12) {
                    Button(action: triggerDeploy) {
                        Label(
                            deployPhase == .deployed ? "重新部署" : "部署",
                            systemImage: "arrow.triangle.2.circlepath"
                        )
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(deployPhase == .triggered || deployPhase == .deploying)

                    if deployPhase == .triggered || deployPhase == .deploying || deployPhase == .failed {
                        Button("取消") {
                            cancelDeploy()
                        }
                        .buttonStyle(.bordered)
                    }

                    Spacer()

                    // 清空日志按钮
                    let hasLogs = !deployLog.isEmpty || !keyboardDiagLog.isEmpty
                    if hasLogs {
                        Button(role: .destructive, action: clearAllLogs) {
                            Label("清空日志", systemImage: "trash")
                                .font(.caption)
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                    }
                }
            }
            .onAppear { checkInitialState() }
        }
    }

    private var phaseDescription: String {
        switch deployPhase {
        case .idle:
            return "RIME 是开源中文输入引擎。部署后即可使用真实词库进行拼音输入，只需执行一次。"
        case .triggered:
            return "已设置部署标记。请切换到键盘，部署将自动开始。"
        case .deploying:
            return "键盘正在编译词库和配置，请保持键盘打开…"
        case .deployed:
            return "RIME 引擎已就绪，键盘可以使用完整的中文输入功能。"
        case .failed:
            return "部署超时。请确认已切换到键盘，然后重试。"
        }
    }

    private func deployStep(number: Int, text: String, done: Bool) -> some View {
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
                .font(.subheadline)
                .foregroundStyle(done ? .primary : .secondary)
        }
    }

    // MARK: Deploy actions

    private func checkInitialState() {
        let defaults = UserDefaults(suiteName: appGroupID)
        let deployed = defaults?.bool(forKey: "rime_deployed") ?? false
        let needsDeploy = defaults?.bool(forKey: "rime_needs_deploy") ?? false

        if deployed {
            deployPhase = .deployed
            deployLog = ["✓ RIME 已部署"]
        } else if needsDeploy {
            deployPhase = .triggered
            deployLog = ["→ 检测到待处理的部署标记", "等待键盘扩展启动…"]
        } else {
            deployPhase = .idle
        }
    }

    private func triggerDeploy() {
        deployPhase = .triggered
        deployLog = ["→ 已设置部署标记"]
        let defaults = UserDefaults(suiteName: appGroupID)
        defaults?.set(false, forKey: "rime_deployed")
        defaults?.set(true, forKey: "rime_needs_deploy")
        defaults?.synchronize()

        // 开始轮询部署状态
        addLog("等待键盘扩展启动…")
        pollDeployStatus(attempt: 0)
    }

    private func pollDeployStatus(attempt: Int) {
        guard deployPhase == .triggered || deployPhase == .deploying else { return }

        let defaults = UserDefaults(suiteName: appGroupID)
        let deployed = defaults?.bool(forKey: "rime_deployed") ?? false
        let deploying = defaults?.bool(forKey: "rime_deploying") ?? false

        if deployed {
            deployPhase = .deployed
            addLog("✓ 部署成功！RIME 引擎已就绪")
            return
        }

        if deploying && deployPhase == .triggered {
            deployPhase = .deploying
            addLog("→ 键盘正在部署中…")
        }

        if attempt >= 60 { // 2 分钟超时
            deployPhase = .failed
            addLog("✗ 部署超时（2 分钟）。请确认键盘已打开并重试")
            return
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [self] in
            pollDeployStatus(attempt: attempt + 1)
        }
    }

    private func addLog(_ message: String) {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        let timestamp = formatter.string(from: Date())
        deployLog.append("[\(timestamp)] \(message)")
    }

    private var keyboardDiagLog: [String] {
        let defaults = UserDefaults(suiteName: appGroupID)
        guard let log = defaults?.string(forKey: "rime_diag_log"), !log.isEmpty else { return [] }
        return log.components(separatedBy: "\n")
    }

    @State private var deployLogExpanded = false
    @State private var diagLogExpanded = false

    private func collapsibleLogSection(title: String, lines: [String]) -> some View {
        let expanded = title == "部署日志" ? $deployLogExpanded : $diagLogExpanded
        return VStack(alignment: .leading, spacing: 4) {
            DisclosureGroup(isExpanded: expanded) {
                VStack(alignment: .leading, spacing: 2) {
                    ForEach(lines, id: \.self) { line in
                        Text(line)
                            .font(.system(.caption, design: .monospaced))
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.top, 4)
            } label: {
                HStack {
                    Text(title)
                        .font(.caption)
                        .fontWeight(.medium)
                    Text("(\(lines.count) 条)")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Button {
                        UIPasteboard.general.string = lines.joined(separator: "\n")
                    } label: {
                        Label("复制", systemImage: "doc.on.doc")
                            .font(.caption2)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.mini)
                }
            }
        }
    }

    private func clearAllLogs() {
        deployLog = []
        deployPhase = .idle
        let defaults = UserDefaults(suiteName: appGroupID)
        defaults?.removeObject(forKey: "rime_diag_log")
        defaults?.removeObject(forKey: "rime_diag_summary")
        defaults?.synchronize()
    }

    private func cancelDeploy() {
        deployPhase = .idle
        deployLog.append("→ 已取消")
        let defaults = UserDefaults(suiteName: appGroupID)
        defaults?.set(false, forKey: "rime_needs_deploy")
        defaults?.synchronize()
    }
}

// MARK: - 共用小组件

private struct BulletRow: View {
    let text: String
    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            Image(systemName: "checkmark").font(.caption).foregroundStyle(.green)
            Text(text).font(.body)
        }
    }
}

private struct NumberedRow: View {
    let number: Int
    let text: String
    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            Text("\(number)")
                .font(.caption).fontWeight(.bold).foregroundStyle(.white)
                .frame(width: 22, height: 22)
                .background(Color.blue).clipShape(Circle())
            Text(text).font(.body)
        }
    }
}

#Preview {
    ContentView()
}
