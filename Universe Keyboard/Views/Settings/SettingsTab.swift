import KeyboardCore
import SwiftUI

struct SettingsTab: View {
    @Bindable var rimeStore: RimeSettingsStore

    @AppStorage(
        KeyboardInputSettingsKey.pairedSymbolCompletionEnabled,
        store: UserDefaults(suiteName: universeAppGroupID)
    )
    private var pairedSymbolCompletionEnabled = true

    @State private var loggingEnabled: Bool = {
        UserDefaults(suiteName: universeAppGroupID)?.bool(forKey: "logging_enabled") ?? false
    }()

    private var keyboardDiagLog: [String] {
        let defaults = UserDefaults(suiteName: universeAppGroupID)
        guard let log = defaults?.string(forKey: "rime_diag_log"), !log.isEmpty else { return [] }
        return log.components(separatedBy: "\n")
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    settingsLinks
                    inputBehaviorSection
                    diagnosticsSection
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("设置")
        }
    }

    private var inputBehaviorSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("输入体验")
                .font(.footnote.weight(.medium))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 4)
            
            SettingsNavigationLink(systemImage: "waveform", title: "键盘反馈", subtitle: "按键音、触感震动") {
                FeedbackSettingsView()
            }

            VStack(spacing: 0) {
                HStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 7, style: .continuous).fill(.primary)
                        Image(systemName: "parentheses")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Color(.systemBackground))
                    }
                    .frame(width: 30, height: 30)

                    ToggleRow(
                        title: "成对符号自动匹配",
                        description: pairedSymbolCompletionEnabled
                            ? "输入左括号、书名号等符号时自动补全右侧符号"
                            : "输入左侧符号时只插入当前符号",
                        isOn: $pairedSymbolCompletionEnabled
                    )
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
            }
            .background(Color(.secondarySystemGroupedBackground))
           .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

            VStack(spacing: 0) {
                HStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 7, style: .continuous).fill(.primary)
                        Image(systemName: "textformat.size")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Color(.systemBackground))
                    }
                    .frame(width: 30, height: 30)

                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("候选数量")
                                .font(.body)
                            Spacer()
                            Text("\(Int(rimeStore.pageSize)) 个")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        Slider(value: $rimeStore.pageSize, in: 5...20, step: 1) { editing in
                            if !editing {
                                rimeStore.savePreferences()
                                Task { await rimeStore.triggerDeployment() }
                            }
                        }
                        Text("每页最多显示的候选词个数。数量越少选词越快，数量越多翻页更少。")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
            }
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

            VStack(spacing: 0) {
                HStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 7, style: .continuous).fill(.primary)
                        Image(systemName: "a.circle")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Color(.systemBackground))
                    }
                    .frame(width: 30, height: 30)

                    ToggleRow(
                        title: "默认简体",
                        description: rimeStore.simplified
                            ? "开启后使用 OpenCC 将结果转为简体中文输出。"
                            : "关闭后保留词典原始字形。",
                        isOn: $rimeStore.simplified
                    )
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
            }
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .onChange(of: rimeStore.simplified) { _, _ in
                rimeStore.savePreferences()
                Task { await rimeStore.triggerDeployment() }
            }
        }
    }

    private var settingsLinks: some View {
        Group {
            SettingsNavigationLink(
                systemImage: "character.book.closed.zh", title: "RIME 方案设置", subtitle: "方案列表、方案部署"
            ) {
                RimeSettingsView(store: rimeStore)
            }
            SettingsNavigationLink(systemImage: "circle.lefthalf.filled", title: "外观", subtitle: "跟随系统、浅色或深色模式") {
                AppearanceSettingsView()
            }
            SettingsNavigationLink(systemImage: "character.book.closed", title: "本地词典", subtitle: "查看词典文件与搜索本地词条") {
                DictionaryBrowserView()
            }
            SettingsNavigationLink(systemImage: "waveform.path", title: "模糊音设置", subtitle: "平翘舌、鼻边音") {
                RimeFuzzyPinyinSettingsView(store: rimeStore)
            }
            SettingsNavigationLink(systemImage: "text.badge.checkmark", title: "候选学习", subtitle: "记住常选词、清空学习记录") {
                RimeUserDictionarySettingsView(store: rimeStore)
            }
        }
    }

    private var diagnosticsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(spacing: 0) {
                DiagnosticsToggleRow(loggingEnabled: $loggingEnabled)
                Divider().padding(.leading, 56)
                NavigationLink(destination: DiagnosticsView()) {
                    HStack(spacing: 12) {
                        Text("查看记录").font(.body).foregroundStyle(.primary)
                        Spacer()
                        Text(keyboardDiagLog.isEmpty ? "暂无记录" : "\(keyboardDiagLog.count) 条")
                            .font(.subheadline).foregroundStyle(.secondary)
                        Image(systemName: "chevron.right").font(.caption).foregroundStyle(.tertiary)
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
                    .font(.footnote).foregroundStyle(.secondary).padding(.horizontal, 4)
                DiagnosticsCategoriesSection()
            }
        }
    }
}

private struct DiagnosticsToggleRow: View {
    @Binding var loggingEnabled: Bool

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 7, style: .continuous).fill(.primary)
                Image(systemName: "waveform.path.ecg.text")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color(.systemBackground))
            }
            .frame(width: 30, height: 30)
            VStack(alignment: .leading, spacing: 2) {
                Text("诊断日志").font(.body).foregroundStyle(.primary)
                Text(loggingEnabled ? "正在捕获输入耗时与引擎边界" : "用于定位快速输入卡顿")
                    .font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            Toggle("", isOn: $loggingEnabled)
                .labelsHidden()
                .toggleStyle(MonochromeToggleStyle())
                .onChange(of: loggingEnabled) { _, value in
                    UserDefaults(suiteName: universeAppGroupID)?.set(value, forKey: "logging_enabled")
                }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
    }
}

private struct DiagnosticsCategoriesSection: View {
    private let categories: [(String, String, String, String)] = [
        ("gauge.with.dots.needle.33percent", "性能", "perf", "按键延迟、渲染耗时"),
        ("rectangle.on.rectangle", "画面", "disp", "布局尺寸、淡入动画、候选栏刷新"),
        ("gearshape.2", "引擎", "engine", "RIME 处理、候选生成"),
        ("doc.text", "配置", "config", "YAML 生成、OpenCC"),
        ("arrow.down.circle", "部署", "deploy", "词库编译、配置部署"),
        ("text.alignleft", "通用", "gen", "生命周期、状态切换"),
    ]

    var body: some View {
        VStack(spacing: 0) {
            ForEach(categories, id: \.2) { icon, name, key, description in
                CategoryToggleRow(icon: icon, name: name, description: description, defaultsKey: "log_category_\(key)")
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}

private struct CategoryToggleRow: View {
    let icon: String
    let name: String
    let description: String
    @AppStorage private var isOn: Bool

    init(icon: String, name: String, description: String, defaultsKey: String) {
        self.icon = icon
        self.name = name
        self.description = description
        _isOn = AppStorage(wrappedValue: true, defaultsKey, store: UserDefaults(suiteName: universeAppGroupID))
    }

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon).font(.caption).foregroundStyle(.secondary).frame(width: 20)
            VStack(alignment: .leading, spacing: 2) {
                Text(name).font(.subheadline)
                Text(description).font(.caption2).foregroundStyle(.secondary)
            }
            Spacer()
            Toggle("", isOn: $isOn).labelsHidden().toggleStyle(MonochromeToggleStyle()).scaleEffect(0.85)
        }
        .padding(.vertical, 6)
    }
}
