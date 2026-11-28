import KeyboardCore
import SwiftUI

/// 设置主页两处词典入口的文案与图标。
///
/// 与 `SettingsSearchCatalog` 的同名条目保持一致，避免主页与搜索结果各说各话。
enum SettingsTabCopy {
    static let userDictionaryTitle = "用户词典"
    static let userDictionarySubtitle = "备份 / 恢复 / 清空学习记录"
    static let userDictionarySystemImage = "text.book.closed"

    static let localDictionaryTitle = "词典文件"
    static let localDictionarySubtitle = "浏览与搜索词典文件"
    static let localDictionarySystemImage = "doc.text.magnifyingglass"
}

/// PB-015 PR-4 根页信息架构清单（设计 r1 §1.1 / A-08：4 组、12 条 Nav 行 + 5 张开关卡）。
///
/// `SettingsTab` 的各 Section 标题与页脚从这里取值；`navigationTitles` /
/// `toggleCardTitles` 逐行钉住每个组实际渲染的 Nav 行与开关卡（结构与
/// `AppPR4StructuralConsolidationTests` 共同回归）。移动或增删根页条目时必须同步更新此清单。
enum SettingsRootLayout {
    struct Group {
        let title: String
        let footer: String
        let navigationTitles: [String]
        let toggleCardTitles: [String]
    }

    static let typingHabits = Group(
        title: "打字习惯",
        footer: "布局、反馈、删除键和纠错都只影响本机打字习惯，可以随时改回来。这些不是人工智能功能。"
            + "粘贴需要系统完全访问。开关和完全访问都开启时，键盘会读取剪贴板文字用于预览，"
            + "只保存在内存里，不上传。未开启时键盘不显示粘贴条，打字不受影响。",
        navigationTitles: ["键盘布局", "键盘反馈", "删除键"],
        toggleCardTitles: [
            "显示剪贴板预览", "上屏后联想", "中英混排自动加空格",
            "英文候选自动补空格", "成对符号自动匹配",
        ]
    )

    static let rimeSchemes = Group(
        title: "输入方案",
        footer: "方案与候选偏好写在本地；改完后如需部署，会在后台安静处理。"
            + "高级输入功能、模糊音、候选数量与默认简体已并入 RIME 方案设置页。",
        navigationTitles: ["RIME 方案设置", "用户词典"],
        toggleCardTitles: []
    )

    static let dataAndTools = Group(
        title: "数据与工具",
        footer: "词典与同步都在你的设备侧处理，按需开启即可。",
        navigationTitles: ["RIME 云同步", "词典文件"],
        toggleCardTitles: []
    )

    static let general = Group(
        title: "通用",
        footer: "外观与通知只影响主 App；输入仍在键盘扩展里完成。"
            + "版本、联系与隐私说明在关于页，诊断入口也在关于页。启用指南可随时从右上角问号重看。",
        navigationTitles: ["显示与外观", "通知与提醒", "智能纠错", "输入洞察", "关于"],
        toggleCardTitles: []
    )

    static var groups: [Group] { [typingHabits, rimeSchemes, dataAndTools, general] }
    static var groupTitles: [String] { groups.map(\.title) }
}

struct SettingsTab: View {
    @Bindable var rimeStore: RimeSettingsStore
    @Bindable var syncModel: RimeSyncViewModel
    @Bindable var notificationSettings: AppNotificationSettingsModel
    var helpEntryNeedsAttention: Bool = false
    var onOpenActivationGuide: (() -> Void)?

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

    @AppStorage(
        KeyboardLayoutSettingsKey.layoutStyle,
        store: UserDefaults(suiteName: universeAppGroupID)
    )
    private var layoutStyleRaw = KeyboardLayoutStyle.twentySixKey.rawValue

    @AppStorage(
        KeyboardInputSettingsKey.clipboardPreviewEnabled,
        store: UserDefaults(suiteName: universeAppGroupID)
    )
    private var clipboardPreviewEnabled = false

    @AppStorage(
        KeyboardInputSettingsKey.mixedScriptSpacingEnabled,
        store: UserDefaults(suiteName: universeAppGroupID)
    )
    private var mixedScriptSpacingEnabled = true

    @AppStorage(
        KeyboardInputSettingsKey.englishCandidateAutospaceEnabled,
        store: UserDefaults(suiteName: universeAppGroupID)
    )
    private var englishCandidateAutospaceEnabled = true

    private var layoutSubtitle: String {
        switch KeyboardLayoutStyle.resolve(layoutStyleRaw) {
        case .twentySixKey: return "26键"
        case .nineKey: return "9键"
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.sectionLoose) {
                    typingHabitsSection
                    rimeSchemesSection
                    dataAndToolsSection
                    generalSection
                }
                .padding(.horizontal, AppSpacing.screen)
                .padding(.vertical, AppSpacing.screen)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("设置")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        onOpenActivationGuide?()
                    } label: {
                        Image(systemName: "questionmark.circle")
                            .foregroundStyle(helpEntryNeedsAttention ? Color.red : Color.primary)
                    }
                    .accessibilityLabel(ActivationCopy.settingsHelpEntryTitle)
                    .accessibilityValue(
                        helpEntryNeedsAttention
                            ? ActivationCopy.helpEntryIncompleteValue
                            : ActivationCopy.helpEntryCompleteValue
                    )
                    .accessibilityHint(ActivationCopy.settingsHelpEntrySubtitle)
                }
            }
            .onAppear { rimeStore.load() }
        }
    }

    // MARK: - Group 1: 打字习惯

    private var typingHabitsSection: some View {
        SettingsGroup(
            title: SettingsRootLayout.typingHabits.title,
            footer: SettingsRootLayout.typingHabits.footer
        ) {
            AppCard {
                SettingsIconRow(systemImage: "doc.on.clipboard") {
                    ToggleRow(
                        title: "显示剪贴板预览",
                        description: "关闭时不读取，也不触发系统弹窗，键盘上不显示粘贴条，也不能从键盘粘贴。",
                        isOn: $clipboardPreviewEnabled
                    )
                }
            }
            AppCard {
                SettingsIconRow(systemImage: "text.append") {
                    ToggleRow(
                        title: "上屏后联想",
                        description: postCommitContinuationEnabled
                            ? "输入字词后，在候选栏显示本地常用接续建议"
                            : "上屏后不显示接续建议",
                        isOn: $postCommitContinuationEnabled
                    )
                }
            }

            AppCard {
                SettingsIconRow(systemImage: "textformat.space") {
                    ToggleRow(
                        title: "中英混排自动加空格",
                        description: mixedScriptSpacingEnabled
                            ? "中文与英文、数字之间自动插入一个空格；英文与数字之间不加。需要键盘开启完全访问"
                            : "中文与英文、数字之间不自动插入空格",
                        isOn: $mixedScriptSpacingEnabled
                    )
                }
            }

            AppCard {
                SettingsIconRow(systemImage: "character.cursor.ibeam") {
                    ToggleRow(
                        title: "英文候选自动补空格",
                        description: englishCandidateAutospaceEnabled
                            ? "点选英文候选词后自动加一个空格；网址、邮箱和搜索框不补。需要键盘开启完全访问"
                            : "点选英文候选词后不自动加空格",
                        isOn: $englishCandidateAutospaceEnabled
                    )
                }
            }

            AppCard {
                SettingsIconRow(systemImage: "parentheses") {
                    ToggleRow(
                        title: "成对符号自动匹配",
                        description: pairedSymbolCompletionEnabled
                            ? "输入左括号、书名号等符号时自动补全右侧符号"
                            : "输入左侧符号时只插入当前符号",
                        isOn: $pairedSymbolCompletionEnabled
                    )
                }
            }

            SettingsNavigationLink(
                systemImage: "keyboard",
                title: "键盘布局",
                subtitle: layoutSubtitle
            ) {
                KeyboardLayoutSettingsView(rimeStore: rimeStore)
            }

            SettingsNavigationLink(
                systemImage: "waveform",
                title: "键盘反馈",
                subtitle: "按键音、触感震动"
            ) {
                FeedbackSettingsView()
            }

            SettingsNavigationLink(
                systemImage: "delete.left",
                title: "删除键",
                subtitle: "垃圾桶、滑动擦除、组字左滑"
            ) {
                DeleteKeySettingsView()
            }
        }
    }

    // MARK: - Group 2: 输入方案

    /// PB-015 PR-4（M3–M5）：高级输入、模糊音、候选数量与默认简体并入
    /// `RimeSettingsView`；根页只保留方案设置与用户词典两条 Nav。
    private var rimeSchemesSection: some View {
        SettingsGroup(
            title: SettingsRootLayout.rimeSchemes.title,
            footer: SettingsRootLayout.rimeSchemes.footer
        ) {
            SettingsNavigationLink(
                systemImage: "character.book.closed.zh",
                title: "RIME 方案设置",
                subtitle: "方案列表、部署与输入偏好"
            ) {
                RimeSettingsView(store: rimeStore)
            }

            SettingsNavigationLink(
                systemImage: SettingsTabCopy.userDictionarySystemImage,
                title: SettingsTabCopy.userDictionaryTitle,
                subtitle: SettingsTabCopy.userDictionarySubtitle
            ) {
                RimeUserDictionarySettingsView(store: rimeStore)
            }
        }
    }

    // MARK: - Group 3: 数据与工具

    private var dataAndToolsSection: some View {
        SettingsGroup(
            title: SettingsRootLayout.dataAndTools.title,
            footer: SettingsRootLayout.dataAndTools.footer
        ) {
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
                systemImage: SettingsTabCopy.localDictionarySystemImage,
                title: SettingsTabCopy.localDictionaryTitle,
                subtitle: SettingsTabCopy.localDictionarySubtitle
            ) {
                DictionaryBrowserView()
            }
        }
    }

    // MARK: - Group 4: 通用

    private var generalSection: some View {
        SettingsGroup(
            title: SettingsRootLayout.general.title,
            footer: SettingsRootLayout.general.footer
        ) {
            SettingsNavigationLink(
                systemImage: "circle.lefthalf.filled",
                title: "显示与外观",
                subtitle: "深色浅色、键盘高度与候选字大小"
            ) {
                AppearanceSettingsView()
            }

            SettingsNavigationLink(
                systemImage: "bell.badge",
                title: "通知与提醒",
                subtitle: notificationSettings.notificationsEnabled
                    ? "管理通知和操作状态提示"
                    : "通知已关闭，可单独保留操作状态提示"
            ) {
                NotificationSettingsView(
                    model: notificationSettings,
                    isRimeSyncMethodConfigured: syncModel.provider != .none
                )
            }

            SettingsNavigationLink(
                systemImage: "wand.and.stars",
                title: "智能纠错",
                subtitle: "本地邻键旁路建议，不自动改写"
            ) {
                TypoCorrectionBenchmarkView()
            }

            SettingsNavigationLink(
                systemImage: "chart.xyaxis.line",
                title: "输入洞察",
                subtitle: "本机字符计数，不是人工智能"
            ) {
                TypingIntelligenceView()
            }

            SettingsNavigationLink(
                systemImage: "info.circle",
                title: "关于",
                subtitle: "版本、联系、隐私与诊断"
            ) {
                AboutSettingsView(notificationSettings: notificationSettings)
            }
        }
    }
}
