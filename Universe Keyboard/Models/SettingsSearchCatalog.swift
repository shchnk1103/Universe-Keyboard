import Foundation

/// Local settings destinations for the Search tab (`PD-APP-SEARCH-001`).
///
/// Pure index — navigation is resolved in `SearchTab` via `destination` id.
nonisolated struct SettingsSearchItem: Identifiable, Equatable, Sendable {
    enum Destination: String, Equatable, Sendable {
        case keyboardLayout
        case feedback
        case typoCorrection
        case typingIntelligence
        case rimeSchemes
        case advancedInput
        case fuzzyPinyin
        case rimeSync
        case userDictionary
        case appearance
        case notifications
        case privacy
        case localDictionary
        case diagnostics
        case activationHelp
    }

    let id: String
    let title: String
    let subtitle: String
    let systemImage: String
    let keywords: [String]
    let destination: Destination

    /// Case- and diacritic-insensitive match against title, subtitle, and keywords.
    func matches(_ query: String) -> Bool {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { return false }
        let folded = q.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
        func hit(_ s: String) -> Bool {
            s.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
                .contains(folded)
        }
        if hit(title) || hit(subtitle) { return true }
        return keywords.contains { hit($0) }
    }
}

nonisolated enum SettingsSearchCatalog {
    static let all: [SettingsSearchItem] = [
        SettingsSearchItem(
            id: "keyboardLayout",
            title: "键盘布局",
            subtitle: "26键 / 9键",
            systemImage: "keyboard",
            keywords: ["布局", "九键", "9键", "26", "t9", "layout"],
            destination: .keyboardLayout
        ),
        SettingsSearchItem(
            id: "feedback",
            title: "键盘反馈",
            subtitle: "按键音、触感震动",
            systemImage: "waveform",
            keywords: ["震动", "音效", "反馈", "haptic", "声音"],
            destination: .feedback
        ),
        SettingsSearchItem(
            id: "typoCorrection",
            title: "智能纠错",
            subtitle: "本地邻键旁路建议，不自动改写",
            systemImage: "wand.and.stars",
            keywords: ["纠错", "typo", "误触", "智能", "AI"],
            destination: .typoCorrection
        ),
        SettingsSearchItem(
            id: "typingIntelligence",
            title: "输入洞察",
            subtitle: "本机字符计数，不是人工智能",
            systemImage: "chart.xyaxis.line",
            keywords: ["统计", "洞察", "今日", "字符", "趋势", "AI"],
            destination: .typingIntelligence
        ),
        SettingsSearchItem(
            id: "rimeSchemes",
            title: "RIME 方案设置",
            subtitle: "方案列表、下载与部署",
            systemImage: "character.book.closed.zh",
            keywords: ["雾凇", "朙月", "方案", "部署", "rime", "词库", "下载"],
            destination: .rimeSchemes
        ),
        SettingsSearchItem(
            id: "advancedInput",
            title: "高级输入功能",
            subtitle: "日期、计算器、数字转换",
            systemImage: "sparkles",
            keywords: ["日期", "计算器", "高级", "lua"],
            destination: .advancedInput
        ),
        SettingsSearchItem(
            id: "fuzzyPinyin",
            title: "模糊音设置",
            subtitle: "平翘舌、鼻边音",
            systemImage: "waveform.path",
            keywords: ["模糊", "平翘", "zh", "z", "ch", "sh"],
            destination: .fuzzyPinyin
        ),
        SettingsSearchItem(
            id: "rimeSync",
            title: "RIME 云同步",
            subtitle: "WebDAV 同步",
            systemImage: "icloud",
            keywords: ["同步", "云", "webdav", "备份"],
            destination: .rimeSync
        ),
        SettingsSearchItem(
            id: "userDictionary",
            title: "RIME 用户词典",
            subtitle: "候选学习与备份",
            systemImage: "text.book.closed",
            keywords: ["用户词典", "学习", "词典"],
            destination: .userDictionary
        ),
        SettingsSearchItem(
            id: "appearance",
            title: "外观",
            subtitle: "浅色、深色、跟随系统",
            systemImage: "circle.lefthalf.filled",
            keywords: ["深色", "浅色", "外观", "主题"],
            destination: .appearance
        ),
        SettingsSearchItem(
            id: "notifications",
            title: "通知与提醒",
            subtitle: "操作状态提示",
            systemImage: "bell.badge",
            keywords: ["通知", "提醒", "toast"],
            destination: .notifications
        ),
        SettingsSearchItem(
            id: "privacy",
            title: "隐私与数据",
            subtitle: "本地处理与完全访问说明",
            systemImage: "hand.raised",
            keywords: ["隐私", "完全访问", "数据", "full access"],
            destination: .privacy
        ),
        SettingsSearchItem(
            id: "localDictionary",
            title: "本地词典",
            subtitle: "浏览本机词库文件",
            systemImage: "character.book.closed",
            keywords: ["词典浏览器", "词库文件"],
            destination: .localDictionary
        ),
        SettingsSearchItem(
            id: "diagnostics",
            title: "诊断",
            subtitle: "本机记录、分类与高级排查",
            systemImage: "waveform.path.ecg.text",
            keywords: ["诊断", "日志", "卡顿", "debug", "force_gc", "九键", "触摸范围", "hitbox"],
            destination: .diagnostics
        ),
        SettingsSearchItem(
            id: "activationHelp",
            title: "使用帮助与启用指南",
            subtitle: "重看启用步骤",
            systemImage: "book.pages",
            keywords: ["帮助", "启用", "引导", "完全访问", "添加键盘"],
            destination: .activationHelp
        ),
    ]

    static func matches(query: String) -> [SettingsSearchItem] {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { return [] }
        return all.filter { $0.matches(q) }
    }
}
