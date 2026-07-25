import KeyboardCore
import SwiftUI

/// Diagnostics control surface.
///
/// **Crash contract (Form + AsyncRenderer / libdispatch):**
/// - Never insert/remove Form sections when the master switch flips.
/// - Use **system** `Toggle` (`.switch`) — project-wide default; custom
///   monochrome styles were retired after Form + custom styles correlated with
///   `SwiftUI.AsyncRenderer` / libdispatch asserts.
/// - No `.animation(_:value: loggingEnabled)` on Form sections (opacity/status).
/// - Category flags stay in a plain `@State` dictionary (no `@Observable` fan-out).
struct DiagnosticsSettingsView: View {
    @State private var loggingEnabled: Bool = {
        UserDefaults(suiteName: universeAppGroupID)?.bool(forKey: "logging_enabled") ?? false
    }()
    /// category id → enabled (default true when key absent).
    @State private var categoryEnabled: [String: Bool] = DiagnosticsCategoryCatalog.loadEnabledMap()
    @State private var forceGCCheckLines: [String] = []
    @State private var forceGCCheckHeadline: String?
    @State private var advancedExpanded = false

    private var defaults: UserDefaults? {
        UserDefaults(suiteName: universeAppGroupID)
    }

    private var logLineCount: Int {
        guard let log = defaults?.string(forKey: "rime_diag_log"), !log.isEmpty else { return 0 }
        return log.components(separatedBy: "\n").filter { !$0.isEmpty }.count
    }

    var body: some View {
        Form {
            statusSection
            recordingControlSection
            categoriesSection
            reviewSection
            advancedSection
        }
        .navigationTitle("诊断")
        .navigationBarTitleDisplayMode(.inline)
        .tint(.primary)
        .onAppear {
            categoryEnabled = DiagnosticsCategoryCatalog.loadEnabledMap()
            loggingEnabled = defaults?.bool(forKey: "logging_enabled") ?? false
        }
    }

    // MARK: - Status (style-only updates)

    private var statusSection: some View {
        Section {
            HStack(alignment: .top, spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: AppRadius.control, style: .continuous)
                        .fill(loggingEnabled ? Color.primary : Color(.tertiarySystemFill))
                    Image(systemName: "waveform.path.ecg")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(loggingEnabled ? Color(.systemBackground) : Color.secondary)
                }
                .frame(width: 40, height: 40)

                VStack(alignment: .leading, spacing: 4) {
                    Text(loggingEnabled ? "正在记录" : "记录已暂停")
                        .font(.body.weight(.semibold))
                    Text("仅保存在本机 App Group，不会上传。用于排查卡顿与引擎边界。")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                    HStack(spacing: 12) {
                        Label("\(logLineCount) 条", systemImage: "doc.text")
                        Label(
                            loggingEnabled ? "写入开启" : "写入关闭",
                            systemImage: loggingEnabled ? "circle.fill" : "circle"
                        )
                        .foregroundStyle(loggingEnabled ? Color.primary : Color.secondary)
                    }
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .padding(.top, 2)
                }
                Spacer(minLength: 0)
            }
            .padding(.vertical, 4)
            .accessibilityElement(children: .combine)
        } header: {
            Text("状态")
        }
    }

    // MARK: - Master switch

    private var recordingControlSection: some View {
        Section {
            Toggle(isOn: loggingEnabledBinding) {
                VStack(alignment: .leading, spacing: 3) {
                    Text("记录诊断数据")
                        .font(.body)
                    Text(
                        loggingEnabled
                            ? "键盘与主 App 可将事件写入本机诊断缓冲"
                            : "关闭后不再写入新记录；已有记录仍可查看"
                    )
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
            }
            // System switch: native animation + Form-safe interaction path.
            .toggleStyle(.switch)
        } header: {
            Text("记录控制")
        } footer: {
            Text("复现卡顿时建议开启，并保留下方「性能」与「引擎」分类。")
        }
    }

    private var loggingEnabledBinding: Binding<Bool> {
        Binding(
            get: { loggingEnabled },
            set: { newValue in
                loggingEnabled = newValue
                defaults?.set(newValue, forKey: "logging_enabled")
            }
        )
    }

    // MARK: - Categories (always present)

    private var categoriesSection: some View {
        Section {
            ForEach(DiagnosticsCategoryCatalog.items) { item in
                categoryRow(item)
            }
        } header: {
            Text("记录分类")
        } footer: {
            Text(
                loggingEnabled
                    ? "关闭某一类可减少噪音；热路径仍应保持克制。"
                    : "总开关关闭时分类不可改，且不会写入新事件。开启上方开关后可调整。"
            )
        }
        .disabled(!loggingEnabled)
        // Instant dim — no `.animation` on Form sections (crash surface).
        .opacity(loggingEnabled ? 1 : 0.48)
    }

    private func categoryRow(_ item: DiagnosticsCategoryCatalog.Item) -> some View {
        HStack(spacing: 12) {
            Image(systemName: item.icon)
                .font(.body)
                .foregroundStyle(loggingEnabled ? Color.primary : Color.secondary)
                .frame(width: 28, height: 28)
                .background(
                    RoundedRectangle(cornerRadius: 7, style: .continuous)
                        .fill(Color(.tertiarySystemFill))
                )
            VStack(alignment: .leading, spacing: 2) {
                Text(item.name).font(.body)
                Text(item.description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            Toggle(
                "",
                isOn: Binding(
                    get: { categoryEnabled[item.id] ?? true },
                    set: { newValue in
                        categoryEnabled[item.id] = newValue
                        defaults?.set(newValue, forKey: "log_category_\(item.id)")
                    }
                )
            )
            .labelsHidden()
            .toggleStyle(.switch)
            .fixedSize(horizontal: true, vertical: false)
        }
        .padding(.vertical, 2)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(item.name)，\(item.description)")
        .accessibilityValue((categoryEnabled[item.id] ?? true) ? "开启" : "关闭")
    }

    // MARK: - Review

    private var reviewSection: some View {
        Section {
            NavigationLink {
                DiagnosticsView()
            } label: {
                HStack {
                    Label("查看记录", systemImage: "doc.text.magnifyingglass")
                    Spacer()
                    Text(logLineCount == 0 ? "暂无记录" : "\(logLineCount) 条")
                        .foregroundStyle(.secondary)
                }
            }
        } header: {
            Text("查看与管理")
        } footer: {
            Text("可在记录页刷新、筛选、复制或清空。请勿分享含敏感上下文的日志。")
        }
    }

    // MARK: - Advanced

    private var advancedSection: some View {
        Section {
            DisclosureGroup(isExpanded: $advancedExpanded) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("以下工具面向九键 Schema 卫生与部署排查，日常使用无需打开。")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)

                    Button {
                        present(diagnostic: T9SchemaForceGCDiagnosticsRunner.runAndLog())
                    } label: {
                        Label("检查九键 Schema / force_gc", systemImage: "doc.text.magnifyingglass")
                    }

                    Button {
                        present(diagnostic: T9SchemaForceGCDiagnosticsRunner.applyPatchAndLog())
                    } label: {
                        Label("应用九键兼容补丁并复查", systemImage: "wrench.and.screwdriver")
                    }

                    if let forceGCCheckHeadline {
                        Text(forceGCCheckHeadline)
                            .font(.subheadline)
                            .foregroundStyle(
                                forceGCCheckHeadline.contains("仍注册")
                                    || forceGCCheckHeadline.contains("失败")
                                    || forceGCCheckHeadline.contains("请完整部署")
                                    ? .orange
                                    : .secondary
                            )
                    }
                    ForEach(forceGCCheckLines, id: \.self) { line in
                        Text(line)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 4)
            } label: {
                Label("高级", systemImage: "wrench.and.screwdriver")
            }
        } footer: {
            Text(
                "读取源文件与 build/t9.schema.yaml。源干净但编译产物仍含 force_gc 时，应用补丁后请完整部署并重开键盘。"
            )
        }
    }

    private func present(diagnostic: T9SchemaForceGCDiagnostic) {
        forceGCCheckLines = diagnostic.userFacingLines
        if !diagnostic.appGroupAvailable {
            forceGCCheckHeadline = "App Group 不可用"
        } else if !diagnostic.schemaExists {
            forceGCCheckHeadline = "未找到 t9.schema.yaml"
        } else if diagnostic.forceGCTranslatorPresent {
            forceGCCheckHeadline = "源文件仍注册 force_gc"
        } else if diagnostic.compiledForceGCTranslatorPresent {
            forceGCCheckHeadline = "源已干净，但编译产物仍含 force_gc — 请完整部署"
        } else if diagnostic.runtimeLikelyClean {
            forceGCCheckHeadline = "源与编译产物均无 force_gc"
        } else {
            forceGCCheckHeadline = "源文件未注册 force_gc"
        }
    }
}

// MARK: - Category catalog

enum DiagnosticsCategoryCatalog {
    struct Item: Identifiable {
        let id: String
        let icon: String
        let name: String
        let description: String
    }

    static let items: [Item] = [
        .init(id: "perf", icon: "gauge.with.dots.needle.33percent", name: "性能", description: "按键延迟、渲染耗时"),
        .init(id: "disp", icon: "rectangle.on.rectangle", name: "画面", description: "布局尺寸、淡入动画、候选栏刷新"),
        .init(id: "engine", icon: "gearshape.2", name: "引擎", description: "RIME 处理、候选生成"),
        .init(id: "config", icon: "doc.text", name: "配置", description: "YAML 生成、OpenCC"),
        .init(id: "deploy", icon: "arrow.down.circle", name: "部署", description: "词库编译、配置部署"),
        .init(id: "gen", icon: "text.alignleft", name: "通用", description: "生命周期、状态切换"),
    ]

    static func loadEnabledMap() -> [String: Bool] {
        let defaults = UserDefaults(suiteName: universeAppGroupID)
        var map: [String: Bool] = [:]
        for item in items {
            let key = "log_category_\(item.id)"
            if defaults?.object(forKey: key) == nil {
                map[item.id] = true
            } else {
                map[item.id] = defaults?.bool(forKey: key) ?? true
            }
        }
        return map
    }
}

#Preview {
    NavigationStack {
        DiagnosticsSettingsView()
    }
}
