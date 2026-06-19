import SwiftUI

struct DiagnosticsSettingsView: View {
    @State private var loggingEnabled: Bool = {
        UserDefaults(suiteName: universeAppGroupID)?.bool(forKey: "logging_enabled") ?? false
    }()

    private var keyboardDiagLog: [String] {
        let defaults = UserDefaults(suiteName: universeAppGroupID)
        guard let log = defaults?.string(forKey: "rime_diag_log"), !log.isEmpty else { return [] }
        return log.components(separatedBy: "\n")
    }

    var body: some View {
        Form {
            Section {
                DiagnosticsToggleRow(loggingEnabled: $loggingEnabled)
            } footer: {
                Text("复现卡顿时请保留「性能」与「引擎」分类开启；卡住后返回本页查看最后一条 BEGIN 记录。")
            }

            if loggingEnabled {
                Section {
                    DiagnosticsCategoriesSection()
                } header: {
                    Text("记录分类")
                }
            }

            Section {
                NavigationLink(destination: DiagnosticsView()) {
                    HStack {
                        Label("查看记录", systemImage: "doc.text.magnifyingglass")
                        Spacer()
                        Text(keyboardDiagLog.isEmpty ? "暂无记录" : "\(keyboardDiagLog.count) 条")
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .navigationTitle("诊断日志")
        .tint(.primary)
    }
}

private struct DiagnosticsToggleRow: View {
    @Binding var loggingEnabled: Bool

    var body: some View {
        Toggle(isOn: $loggingEnabled) {
            VStack(alignment: .leading, spacing: 2) {
                Text("记录诊断日志")
                Text(loggingEnabled ? "正在捕获输入耗时与引擎边界" : "用于定位快速输入卡顿")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .toggleStyle(MonochromeToggleStyle())
        .onChange(of: loggingEnabled) { _, value in
            UserDefaults(suiteName: universeAppGroupID)?.set(value, forKey: "logging_enabled")
        }
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
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(width: 20)
            VStack(alignment: .leading, spacing: 2) {
                Text(name).font(.subheadline)
                Text(description).font(.caption2).foregroundStyle(.secondary)
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
    NavigationStack {
        DiagnosticsSettingsView()
    }
}
