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
    @State private var loggingEnabled: Bool = {
        UserDefaults(suiteName: appGroupID)?.bool(forKey: "logging_enabled") ?? false
    }()
    @State private var diagRefreshToken = 0  // 递增以触发 SwiftUI 刷新

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    feedbackNavigationLink
                    rimeNavigationLink
                    diagnosticsSection
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("设置")
        }
    }

    // MARK: 键盘反馈

    private var feedbackNavigationLink: some View {
        NavigationLink(destination: FeedbackSettingsView()) {
            HStack(spacing: 14) {
                Image(systemName: "waveform")
                    .font(.title3)
                    .foregroundStyle(.blue)
                    .frame(width: 28)
                VStack(alignment: .leading, spacing: 2) {
                    Text("键盘反馈")
                        .font(.body)
                        .foregroundStyle(.primary)
                    Text("按键音、触感震动")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding()
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    private var keyboardDiagLog: [String] {
        let defaults = UserDefaults(suiteName: appGroupID)
        guard let log = defaults?.string(forKey: "rime_diag_log"), !log.isEmpty else { return [] }
        return log.components(separatedBy: "\n")
    }

    // MARK: RIME 方案设置

    private var rimeNavigationLink: some View {
        NavigationLink(destination: RimeSettingsView()) {
            HStack(spacing: 14) {
                Image(systemName: "character.book.closed.zh")
                    .font(.title3)
                    .frame(width: 28)
                VStack(alignment: .leading, spacing: 2) {
                    Text("RIME 方案设置")
                        .font(.body)
                        .foregroundStyle(.primary)
                    Text("候选数量、简繁转换、方案部署")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding()
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    // MARK: 诊断日志

    private var diagnosticsSection: some View {
        VStack(spacing: 0) {
            HStack(spacing: 14) {
                Image(systemName: "terminal")
                    .font(.title3)
                    .frame(width: 28)
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
            .padding()
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))

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
                        .clipShape(RoundedRectangle(cornerRadius: 12))
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
