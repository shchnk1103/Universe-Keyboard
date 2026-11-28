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

/// PB-015 SETTINGS-POLISH §2 修订（原 PR-4 根页信息架构清单，设计 r1 §1.1 / A-08）：
/// 4 组、13 条 Nav 行；原 5 张打字习惯开关卡迁入「打字习惯」子页（`typingHabitsPageToggles`）。
///
/// `SettingsTab` 的各 Section 标题与页脚从这里取值；`navigationTitles` /
/// `toggleCardTitles` 逐行钉住每个组实际渲染的 Nav 行与开关卡（结构与
/// `AppPR4StructuralConsolidationTests` 共同回归）。移动或增删根页条目时必须同步更新此清单。
/// PB-015 SETTINGS-POLISH §2：打字习惯子页的开关清单（标题 + SF Symbol 图标）。
///
/// 原 Settings 根页 Group 1 的 5 张内联开关卡整体迁入 `TypingHabitsSettingsView`；
/// `@AppStorage` 键、App Group store、默认值与描述文案保持不变，仅承载位置变化。
/// 图标与标题钉在此处，`TypingHabitsSettingsView` 与
/// `AppPR4StructuralConsolidationTests` 共同回归。
struct ToggleManifestEntry {
    let title: String
    let systemImage: String
}

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
        navigationTitles: ["打字习惯", "键盘布局", "键盘反馈", "删除键"],
        toggleCardTitles: []
    )

    static let typingHabitsPageToggles: [ToggleManifestEntry] = [
        ToggleManifestEntry(title: "显示剪贴板预览", systemImage: "doc.on.clipboard"),
        ToggleManifestEntry(title: "上屏后联想", systemImage: "text.append"),
        ToggleManifestEntry(title: "中英混排自动加空格", systemImage: "textformat.space"),
        ToggleManifestEntry(title: "英文候选自动补空格", systemImage: "character.cursor.ibeam"),
        ToggleManifestEntry(title: "成对符号自动匹配", systemImage: "parentheses"),
    ]

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
        KeyboardLayoutSettingsKey.layoutStyle,
        store: UserDefaults(suiteName: universeAppGroupID)
    )
    private var layoutStyleRaw = KeyboardLayoutStyle.twentySixKey.rawValue

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

    /// PB-015 SETTINGS-POLISH §2：原 5 张内联开关卡迁入 `TypingHabitsSettingsView` 子页，
    /// 根页 Group 1 以带图标与副标的 Nav 行链接该子页。
    private var typingHabitsSection: some View {
        SettingsGroup(
            title: SettingsRootLayout.typingHabits.title,
            footer: SettingsRootLayout.typingHabits.footer
        ) {
            SettingsNavigationLink(
                systemImage: "slider.horizontal.3",
                title: SettingsRootLayout.typingHabits.title,
                subtitle: "剪贴板预览、联想、自动加空格与成对符号"
            ) {
                TypingHabitsSettingsView()
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
                subtitle: "深色浅色、键盘高度、候选字大小与字符键样式"
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

/// PB-015 SETTINGS-POLISH §2：「打字习惯」子页。
///
/// 原 Settings 根页 Group 1 的 5 张内联开关卡整体迁入本页；`@AppStorage` 键、
/// App Group store、默认值与描述文案保持不变，仅承载位置变化。标题与图标钉在
/// `SettingsRootLayout.typingHabitsPageToggles`，与本结构共同渲染。
private struct TypingHabitsSettingsView: View {
    @AppStorage(
        KeyboardInputSettingsKey.clipboardPreviewEnabled,
        store: UserDefaults(suiteName: universeAppGroupID)
    )
    private var clipboardPreviewEnabled = false

    @AppStorage(
        KeyboardInputSettingsKey.postCommitContinuationEnabled,
        store: UserDefaults(suiteName: universeAppGroupID)
    )
    private var postCommitContinuationEnabled = true

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

    @AppStorage(
        KeyboardInputSettingsKey.pairedSymbolCompletionEnabled,
        store: UserDefaults(suiteName: universeAppGroupID)
    )
    private var pairedSymbolCompletionEnabled = true

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.sectionLoose) {
                SettingsGroup(
                    title: SettingsRootLayout.typingHabits.title,
                    footer: "以上开关只影响本机打字习惯，可以随时改回来。这些不是人工智能功能。"
                ) {
                    ForEach(SettingsRootLayout.typingHabitsPageToggles, id: \.title) { entry in
                        AppCard {
                            SettingsIconRow(systemImage: entry.systemImage) {
                                toggleRow(for: entry.title)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, AppSpacing.screen)
            .padding(.vertical, AppSpacing.screen)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(SettingsRootLayout.typingHabits.title)
    }

    @ViewBuilder
    private func toggleRow(for title: String) -> some View {
        switch title {
        case "显示剪贴板预览":
            ToggleRow(
                title: title,
                description: "关闭时不读取，也不触发系统弹窗，键盘上不显示粘贴条，也不能从键盘粘贴。",
                isOn: $clipboardPreviewEnabled
            )
        case "上屏后联想":
            ToggleRow(
                title: title,
                description: postCommitContinuationEnabled
                    ? "输入字词后，在候选栏显示本地常用接续建议"
                    : "上屏后不显示接续建议",
                isOn: $postCommitContinuationEnabled
            )
        case "中英混排自动加空格":
            ToggleRow(
                title: title,
                description: mixedScriptSpacingEnabled
                    ? "中文与英文、数字之间自动插入一个空格；英文与数字之间不加。需要键盘开启完全访问"
                    : "中文与英文、数字之间不自动插入空格",
                isOn: $mixedScriptSpacingEnabled
            )
        case "英文候选自动补空格":
            ToggleRow(
                title: title,
                description: englishCandidateAutospaceEnabled
                    ? "点选英文候选词后自动加一个空格；网址、邮箱和搜索框不补。需要键盘开启完全访问"
                    : "点选英文候选词后不自动加空格",
                isOn: $englishCandidateAutospaceEnabled
            )
        case "成对符号自动匹配":
            ToggleRow(
                title: title,
                description: pairedSymbolCompletionEnabled
                    ? "输入左括号、书名号等符号时自动补全右侧符号"
                    : "输入左侧符号时只插入当前符号",
                isOn: $pairedSymbolCompletionEnabled
            )
        default:
            EmptyView()
        }
    }
}
