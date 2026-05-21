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
        .tint(.blue)
    }
}

// MARK: - Tab 1: 引导

private struct GuideTab: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    headerSection
                    enableKeyboardSection
                    progressSection
                    testChecklistSection
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Universe Keyboard")
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(.blue)
                    Image(systemName: "keyboard")
                        .font(.system(size: 25, weight: .semibold))
                        .foregroundStyle(.white)
                }
                .frame(width: 52, height: 52)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Universe Keyboard")
                        .font(.title3)
                        .fontWeight(.semibold)
                    Text("RIME 中文输入法")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            Text("先在系统设置中添加键盘，再回到这里管理方案、候选数量和按键反馈。")
                .font(.body)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
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
            BulletRow(text:"26 键字母输入", style: .checkmark)
            BulletRow(text:"Shift 大小写切换 + Caps Lock", style: .checkmark)
            BulletRow(text:"123 数字/符号页", style: .checkmark)
            BulletRow(text:"Inline preedit（拼音内联显示）", style: .checkmark)
            BulletRow(text:"RIME 中文候选引擎", style: .checkmark)
            BulletRow(text:"长按删除", style: .checkmark)
            BulletRow(text:"长按变体字符弹出", style: .checkmark)
        }
    }

    private var testChecklistSection: some View {
        InfoSection(title: "测试清单", systemImage: "list.bullet.clipboard") {
            BulletRow(text:"输入 nihao，候选栏应显示候选词", style: .checkmark)
            BulletRow(text:"按空格，应上屏第一个候选", style: .checkmark)
            BulletRow(text:"按 return，应提交原始拼音", style: .checkmark)
            BulletRow(text:"长按删除键，应连续删除", style: .checkmark)
            BulletRow(text:"长按字母键，应弹出变体字符", style: .checkmark)
        }
    }
}

// MARK: - Tab 2: 设置

private struct SettingsTab: View {
    @State private var loggingEnabled: Bool = {
        UserDefaults(suiteName: appGroupID)?.bool(forKey: "logging_enabled") ?? false
    }()
    @State private var diagRefreshToken = 0  // 递增以触发 SwiftUI 刷新

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    feedbackNavigationLink
                    rimeNavigationLink
                    diagnosticsSection
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("设置")
        }
    }

    // MARK: 键盘反馈

    private var feedbackNavigationLink: some View {
        SettingsNavigationLink(
            systemImage: "waveform",
            title: "键盘反馈",
            subtitle: "按键音、触感震动",
            imageColor: .blue
        ) {
            FeedbackSettingsView()
        }
    }

    private var keyboardDiagLog: [String] {
        let defaults = UserDefaults(suiteName: appGroupID)
        guard let log = defaults?.string(forKey: "rime_diag_log"), !log.isEmpty else { return [] }
        return log.components(separatedBy: "\n")
    }

    // MARK: RIME 方案设置

    private var rimeNavigationLink: some View {
        SettingsNavigationLink(
            systemImage: "character.book.closed.zh",
            title: "RIME 方案设置",
            subtitle: "候选数量、简繁转换、方案部署",
            imageColor: .indigo
        ) {
            RimeSettingsView()
        }
    }

    // MARK: 诊断日志

    private var diagnosticsSection: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 7, style: .continuous)
                        .fill(.gray)
                    Image(systemName: "terminal")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.white)
                }
                .frame(width: 30, height: 30)
                VStack(alignment: .leading, spacing: 2) {
                    Text("诊断日志")
                        .font(.body)
                        .foregroundStyle(.primary)
                    Text("键盘引擎运行记录")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Toggle("", isOn: $loggingEnabled)
                    .labelsHidden()
                    .onChange(of: loggingEnabled) { _, newValue in
                        UserDefaults(suiteName: appGroupID)?.set(newValue, forKey: "logging_enabled")
                    }
                    .onChange(of: loggingEnabled) { _, _ in
                        diagRefreshToken += 1
                    }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

            // 仅当开关打开且有日志时才显示查看入口
            if loggingEnabled {
                let diagLines = keyboardDiagLog
                if !diagLines.isEmpty {
                    NavigationLink(destination: DiagnosticsView()) {
                        HStack {
                            Text("查看日志 (\(diagLines.count) 条)")
                                .font(.subheadline)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding()
                        .background(Color(.secondarySystemGroupedBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    }
                } else {
                    HStack {
                        Image(systemName: "info.circle")
                            .font(.caption).foregroundStyle(.secondary)
                        Text("已开启，切换到键盘输入后即可查看日志")
                            .font(.caption).foregroundStyle(.secondary)
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                }
            }
        }
        .id(diagRefreshToken)
        .onAppear { diagRefreshToken += 1 }
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
