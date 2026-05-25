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
        .tint(.primary)
    }
}

// MARK: - Tab 1: 引导

private struct GuideTab: View {
    @AppStorage("rime_active_schema", store: UserDefaults(suiteName: appGroupID))
    private var activeSchemaID = "luna_pinyin"
    @AppStorage("rime_deployed", store: UserDefaults(suiteName: appGroupID))
    private var rimeDeployed = false
    @AppStorage("logging_enabled", store: UserDefaults(suiteName: appGroupID))
    private var loggingEnabled = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    headerSection
                    enableKeyboardSection
                    statusSection
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
                        .fill(.primary)
                    Image(systemName: "keyboard")
                        .font(.system(size: 25, weight: .semibold))
                        .foregroundStyle(Color(.systemBackground))
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

    private var statusSection: some View {
        InfoSection(title: "当前状态", systemImage: "keyboard.badge.ellipsis") {
            StatusRow(
                title: "输入方案",
                value: activeSchemaID == "rime_ice" ? "雾凇拼音" : "朙月拼音",
                color: .primary
            )
            Divider()
            StatusRow(
                title: "词库部署",
                value: rimeDeployed ? "已就绪" : "待部署",
                color: rimeDeployed ? .primary : .orange
            )
            Divider()
            StatusRow(
                title: "卡顿诊断",
                value: loggingEnabled ? "记录中" : "未开启",
                color: loggingEnabled ? .primary : .secondary
            )
        }
    }

    private var testChecklistSection: some View {
        InfoSection(title: "测试清单", systemImage: "list.bullet.clipboard") {
            BulletRow(text:"输入 nihao，确认候选出现且空格可选词", style: .checkmark)
            BulletRow(text:"连续快速输入一段拼音，观察是否停顿", style: .checkmark)
            BulletRow(text:"出现卡顿后回到「设置 > 诊断日志」查看记录", style: .checkmark)
        }
    }
}

// MARK: - Tab 2: 设置

private struct SettingsTab: View {
    @State private var loggingEnabled: Bool = {
        UserDefaults(suiteName: appGroupID)?.bool(forKey: "logging_enabled") ?? false
    }()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    appearanceNavigationLink
                    dictionaryNavigationLink
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

    private var appearanceNavigationLink: some View {
        SettingsNavigationLink(
            systemImage: "circle.lefthalf.filled",
            title: "外观",
            subtitle: "跟随系统、浅色或深色模式"
        ) {
            AppearanceSettingsView()
        }
    }

    private var dictionaryNavigationLink: some View {
        SettingsNavigationLink(
            systemImage: "character.book.closed",
            title: "本地词典",
            subtitle: "查看词典文件与搜索本地词条"
        ) {
            DictionaryBrowserView()
        }
    }

    private var feedbackNavigationLink: some View {
        SettingsNavigationLink(
            systemImage: "waveform",
            title: "键盘反馈",
            subtitle: "按键音、触感震动"
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
            subtitle: "候选数量、简繁转换、方案部署"
        ) {
            RimeSettingsView()
        }
    }

    // MARK: 诊断日志

    private var diagnosticsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 主开关行
            VStack(spacing: 0) {
                HStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 7, style: .continuous)
                            .fill(.primary)
                        Image(systemName: "waveform.path.ecg.text")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Color(.systemBackground))
                    }
                    .frame(width: 30, height: 30)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("诊断日志")
                            .font(.body)
                            .foregroundStyle(.primary)
                        Text(loggingEnabled ? "正在捕获输入耗时与引擎边界" : "用于定位快速输入卡顿")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Toggle("", isOn: $loggingEnabled)
                        .labelsHidden()
                        .toggleStyle(MonochromeToggleStyle())
                        .onChange(of: loggingEnabled) { _, newValue in
                            UserDefaults(suiteName: appGroupID)?.set(newValue, forKey: "logging_enabled")
                        }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)

                Divider().padding(.leading, 56)

                NavigationLink(destination: DiagnosticsView()) {
                    HStack(spacing: 12) {
                        Text("查看记录")
                            .font(.body)
                            .foregroundStyle(.primary)
                        Spacer()
                        let count = keyboardDiagLog.count
                        Text(count == 0 ? "暂无记录" : "\(count) 条")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                }
                .buttonStyle(.plain)
            }
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

            if loggingEnabled {
                Text("复现卡顿时请保留「性能」与「引擎」分类开启；卡住后返回本页查看最后一条 BEGIN 记录。")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 4)
                categoryTogglesSection
            }
        }
    }

    /// 日志分类开关：性能 (PERF) / 画面 (DISP) / 引擎 (ENGINE) / 配置 (CONFIG) / 部署 (DEPLOY) / 通用 (GEN)
    private var categoryTogglesSection: some View {
        let categories: [(String, String, String, String)] = [
            ("gauge.with.dots.needle.33percent", "性能", "perf", "按键延迟、渲染耗时"),
            ("rectangle.on.rectangle", "画面", "disp", "布局尺寸、淡入动画、候选栏刷新"),
            ("gearshape.2", "引擎", "engine", "RIME 处理、候选生成"),
            ("doc.text", "配置", "config", "YAML 生成、OpenCC"),
            ("arrow.down.circle", "部署", "deploy", "词库编译、配置部署"),
            ("text.alignleft", "通用", "gen", "生命周期、状态切换"),
        ]
        return VStack(spacing: 0) {
            ForEach(categories, id: \.2) { icon, name, key, desc in
                CategoryToggleRow(
                    icon: icon,
                    name: name,
                    description: desc,
                    defaultsKey: "log_category_\(key)"
                )
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}



private struct NumberedRow: View {
    let number: Int
    let text: String
    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            Text("\(number)")
                .font(.caption).fontWeight(.bold).foregroundStyle(Color(.systemBackground))
                .frame(width: 22, height: 22)
                .background(Color.primary).clipShape(Circle())
            Text(text).font(.body)
        }
    }
}

private struct StatusRow: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        HStack {
            Text(title)
                .foregroundStyle(.primary)
            Spacer()
            Text(value)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(color)
        }
    }
}

/// 日志分类开关行：图标 + 名称 + 描述 + Toggle
private struct CategoryToggleRow: View {
    let icon: String
    let name: String
    let description: String
    @AppStorage private var isOn: Bool

    init(icon: String, name: String, description: String, defaultsKey: String) {
        self.icon = icon
        self.name = name
        self.description = description
        _isOn = AppStorage(
            wrappedValue: true,
            defaultsKey,
            store: UserDefaults(suiteName: appGroupID)
        )
    }

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(width: 20)
            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.subheadline)
                Text(description)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .toggleStyle(MonochromeToggleStyle())
                .scaleEffect(0.85)
        }
        .padding(.vertical, 6)
    }
}

#Preview {
    ContentView()
}
