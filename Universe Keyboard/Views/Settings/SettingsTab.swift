import KeyboardCore
import SwiftUI

struct SettingsTab: View {
    @Bindable var rimeStore: RimeSettingsStore
    @Bindable var syncModel: RimeSyncViewModel
    @Bindable var notificationSettings: AppNotificationSettingsModel

    @AppStorage(
        KeyboardInputSettingsKey.pairedSymbolCompletionEnabled,
        store: UserDefaults(suiteName: universeAppGroupID)
    )
    private var pairedSymbolCompletionEnabled = true

    @AppStorage(
        KeyboardInputSettingsKey.postCommitContinuationEnabled,
        store: UserDefaults(suiteName: universeAppGroupID)
    )
    private var postCommitContinuationEnabled = true

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    inputBehaviorSection
                    rimeInputSection
                    dataAndSyncSection
                    appSettingsSection
                    toolsSection
                    diagnosticsSection
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("设置")
            .onAppear { rimeStore.load() }
        }
    }

    private var dataAndSyncSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("数据与同步")
                .font(.footnote.weight(.medium))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 4)

            SettingsNavigationLink(
                systemImage: "icloud",
                title: "RIME 云同步",
                subtitle: syncModel.statusText
            ) {
                RimeSyncSettingsView(
                    model: syncModel,
                    notificationSettings: notificationSettings
                )
            }

            SettingsNavigationLink(
                systemImage: "text.badge.checkmark",
                title: "RIME 用户词典",
                subtitle: "候选学习、备份与安全恢复"
            ) {
                RimeUserDictionarySettingsView(store: rimeStore)
            }
        }
    }

    private var appSettingsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("App 设置")
                .font(.footnote.weight(.medium))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 4)

            SettingsNavigationLink(
                systemImage: "circle.lefthalf.filled",
                title: "外观",
                subtitle: "跟随系统、浅色或深色模式"
            ) {
                AppearanceSettingsView()
            }

            SettingsNavigationLink(
                systemImage: "bell.badge",
                title: "通知与提醒",
                subtitle: notificationSettings.notificationsEnabled ? "管理通知和操作状态提示" : "通知已关闭，可单独保留操作状态提示"
            ) {
                NotificationSettingsView(model: notificationSettings)
            }

            SettingsNavigationLink(
                systemImage: "hand.raised",
                title: "隐私与数据",
                subtitle: "本地处理、完全访问与数据控制"
            ) {
                PrivacyDataView()
            }
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

            SettingsNavigationLink(systemImage: "wand.and.stars", title: "智能纠错", subtitle: "误触纠错、基准覆盖") {
                TypoCorrectionBenchmarkView()
            }

            SettingsNavigationLink(
                systemImage: "chart.xyaxis.line",
                title: "输入洞察",
                subtitle: "本地统计、趋势与字符构成"
            ) {
                TypingIntelligenceView()
            }

            VStack(spacing: 0) {
                HStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 7, style: .continuous).fill(.primary)
                        Image(systemName: "text.append")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Color(.systemBackground))
                    }
                    .frame(width: 30, height: 30)

                    ToggleRow(
                        title: "上屏后联想",
                        description: postCommitContinuationEnabled
                            ? "输入字词后，在候选栏显示本地常用接续建议"
                            : "上屏后不显示接续建议",
                        isOn: $postCommitContinuationEnabled
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
        }
    }

    private var rimeInputSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("输入方案")
                .font(.footnote.weight(.medium))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 4)

            SettingsNavigationLink(
                systemImage: "character.book.closed.zh",
                title: "RIME 方案设置",
                subtitle: "方案列表、方案部署"
            ) {
                RimeSettingsView(store: rimeStore)
            }

            SettingsNavigationLink(
                systemImage: "sparkles",
                title: "高级输入功能",
                subtitle: rimeStore.activeSchemaSupportsAdvancedInput ? "日期、计算器、数字转换" : "当前方案暂不支持"
            ) {
                RimeAdvancedInputSettingsView(store: rimeStore)
            }

            SettingsNavigationLink(systemImage: "waveform.path", title: "模糊音设置", subtitle: "平翘舌、鼻边音") {
                RimeFuzzyPinyinSettingsView(store: rimeStore)
            }

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

    private var toolsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("词库与工具")
                .font(.footnote.weight(.medium))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 4)

            SettingsNavigationLink(systemImage: "character.book.closed", title: "本地词典", subtitle: "查看词典文件与搜索本地词条") {
                DictionaryBrowserView()
            }
        }
    }

    private var diagnosticsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("诊断")
                .font(.footnote.weight(.medium))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 4)

            SettingsNavigationLink(
                systemImage: "waveform.path.ecg.text",
                title: "诊断日志",
                subtitle: "开关、分类和日志记录"
            ) {
                DiagnosticsSettingsView()
            }
        }
    }
}
