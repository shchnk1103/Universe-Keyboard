import KeyboardCore
import SwiftUI

struct RimeAdvancedInputSettingsView: View {
    @Bindable var store: RimeSettingsStore

    private let groups: [AdvancedInputFeatureGroup] = [
        .init(
            title: "日期与时间",
            footer: "用于快速输入日期、时间、星期和农历信息。",
            features: [.dateTime, .lunar]
        ),
        .init(
            title: "计算与数字",
            footer: "用于简单计算、数字大写和金额格式转换。",
            features: [.calculator, .numberConversion]
        ),
        .init(
            title: "编码与工具",
            footer: "用于输入特殊编码、编号和辅助查询内容。",
            features: [.unicode, .uuid, .vMode, .search]
        ),
        .init(
            title: "候选优化",
            footer: "用于优化候选质量，减少不需要的候选或提示可能的输入问题。",
            features: [.correction, .longWordCandidates, .pinyinCandidateFilter, .englishCandidateFilter]
        ),
        .init(
            title: "输入辅助",
            footer: "用于选字和英文大小写相关辅助。",
            features: [.selectCharacter, .autoCapitalization]
        ),
    ]

    var body: some View {
        Form {
            Section {
                Toggle("启用高级输入功能", isOn: masterBinding)
                    .toggleStyle(MonochromeToggleStyle())
                    .disabled(!store.activeSchemaSupportsAdvancedInput)

                Text(store.activeSchemaAdvancedInputStatusText)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            } header: {
                Text("当前方案")
            } footer: {
                Text("这些是你的偏好设置。只有当前输入方案支持时，开关才可以调整并在重新部署后生效。")
            }

            Section {
                AdvancedInputHelpRow(
                    title: "输入日期和时间",
                    examples: "试试 rq、sj、xq、dt，可显示日期、时间、星期或完整日期时间。"
                )
                AdvancedInputHelpRow(
                    title: "输入计算结果",
                    examples: "输入简单算式时，候选里会出现计算结果。"
                )
                AdvancedInputHelpRow(
                    title: "输入数字格式",
                    examples: "输入数字时，可出现中文大写、金额等格式候选。"
                )
                AdvancedInputHelpRow(
                    title: "输入特殊内容",
                    examples: "可快速输入随机编号、特殊字符或更多符号内容。"
                )
            } header: {
                Text("怎么使用")
            } footer: {
                Text("高级输入会出现在候选栏里；不需要切换键盘页面。关闭某项后，重新部署完成才会在键盘中生效。")
            }

            ForEach(groups) { group in
                Section {
                    ForEach(group.features) { feature in
                        AdvancedInputFeatureToggle(
                            feature: feature,
                            isOn: featureBinding(for: feature),
                            isSupported: store.advancedInputFeatureIsSupported(feature),
                            masterEnabled: store.advancedInputMasterEnabled
                        )
                    }
                } header: {
                    Text(group.title)
                } footer: {
                    Text(group.footer)
                }
                .disabled(!store.activeSchemaSupportsAdvancedInput || !store.advancedInputMasterEnabled)
                .foregroundStyle(
                    store.activeSchemaSupportsAdvancedInput && store.advancedInputMasterEnabled
                        ? .primary
                        : .secondary
                )
            }
        }
        .navigationTitle("高级输入功能")
        .tint(.primary)
        .onAppear { store.load() }
        .onDisappear {
            Task { await store.triggerPendingDeploymentIfNeeded() }
        }
    }

    private var masterBinding: Binding<Bool> {
        Binding {
            store.advancedInputMasterEnabled
        } set: { newValue in
            store.advancedInputMasterEnabled = newValue
            store.saveAdvancedInputSettings()
        }
    }

    private func featureBinding(for feature: RimeAdvancedInputFeature) -> Binding<Bool> {
        Binding {
            store.isAdvancedInputFeatureEnabled(feature)
        } set: { newValue in
            store.setAdvancedInputFeature(feature, enabled: newValue)
        }
    }
}

private struct AdvancedInputFeatureToggle: View {
    let feature: RimeAdvancedInputFeature
    @Binding var isOn: Bool
    let isSupported: Bool
    let masterEnabled: Bool

    var body: some View {
        Toggle(isOn: $isOn) {
            VStack(alignment: .leading, spacing: 3) {
                Text(feature.displayTitle)
                    .font(.body)
                Text(description)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                AdvancedInputExamplesView(examples: feature.examples)
            }
        }
        .toggleStyle(MonochromeToggleStyle())
        .padding(.vertical, 2)
    }

    private var description: String {
        if !isSupported {
            return "当前方案暂不支持。你的选择会保留，切换到支持的方案后可用。"
        }
        if !masterEnabled {
            return "总开关关闭后，这项暂时不会生效。"
        }
        return feature.displayDescription
    }
}

private struct AdvancedInputHelpRow: View {
    let title: String
    let examples: String

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title)
                .font(.body)
            Text(examples)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 3)
    }
}

private struct AdvancedInputExamplesView: View {
    let examples: [AdvancedInputExample]

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            ForEach(examples) { example in
                HStack(alignment: .top, spacing: 8) {
                    Text(example.input)
                        .font(.caption.monospaced().weight(.semibold))
                        .foregroundStyle(.primary)
                        .frame(minWidth: 58, alignment: .leading)
                    Text(example.output)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .padding(.top, 3)
    }
}

private struct AdvancedInputExample: Identifiable {
    var id: String { input }
    let input: String
    let output: String
}

private struct AdvancedInputFeatureGroup: Identifiable {
    var id: String { title }
    let title: String
    let footer: String
    let features: [RimeAdvancedInputFeature]
}

private extension RimeAdvancedInputFeature {
    var displayTitle: String {
        switch self {
        case .dateTime:
            return "日期与时间"
        case .lunar:
            return "农历"
        case .calculator:
            return "计算器"
        case .numberConversion:
            return "数字大写"
        case .unicode:
            return "特殊字符"
        case .uuid:
            return "随机编号"
        case .vMode:
            return "更多符号入口"
        case .search:
            return "辅助查询"
        case .correction:
            return "输入提示"
        case .longWordCandidates:
            return "长词候选优化"
        case .pinyinCandidateFilter:
            return "拼音候选优化"
        case .englishCandidateFilter:
            return "英文候选降噪"
        case .selectCharacter:
            return "选字辅助"
        case .autoCapitalization:
            return "英文大小写辅助"
        }
    }

    var displayDescription: String {
        switch self {
        case .dateTime:
            return "输入简短触发词时显示当前日期、时间、星期等候选。"
        case .lunar:
            return "显示农历日期相关候选。"
        case .calculator:
            return "输入简单算式时显示计算结果。"
        case .numberConversion:
            return "把数字转换成中文大写或金额格式。"
        case .unicode:
            return "辅助输入不常用符号或编码内容。"
        case .uuid:
            return "快速生成随机编号。"
        case .vMode:
            return "输入特定前缀时显示更多符号和特殊内容。"
        case .search:
            return "提供辅助查询类候选。"
        case .correction:
            return "提示可能的输入问题，帮助减少错选。"
        case .longWordCandidates:
            return "优化较长词语的候选表现。"
        case .pinyinCandidateFilter:
            return "减少不需要的拼音相关候选。"
        case .englishCandidateFilter:
            return "降低英文候选对中文输入的干扰。"
        case .selectCharacter:
            return "提供按字选择的辅助候选。"
        case .autoCapitalization:
            return "辅助英文大小写相关输入。"
        }
    }

    var examples: [AdvancedInputExample] {
        switch self {
        case .dateTime:
            return [
                .init(input: "rq", output: "日期：2026-06-19、2026/06/19、2026年6月19日"),
                .init(input: "sj", output: "时间：15:xx、15:xx:xx、下午 03:xx"),
                .init(input: "xq", output: "星期：星期五、礼拜五、周五"),
                .init(input: "dt", output: "日期时间：ISO 格式、普通日期时间、紧凑格式"),
                .init(input: "ts", output: "时间戳：10 位 Unix 时间戳"),
                .init(input: "rqzh", output: "中文日期：二〇二六年六月十九日"),
                .init(input: "rqen", output: "英文日期：19 June 2026、June 19, 2026"),
            ]
        case .lunar:
            return [
                .init(input: "nl", output: "今日农历：类似「丙午马年正月初一」"),
                .init(input: "N20260619", output: "指定日期转农历：格式为 N + 年月日"),
            ]
        case .calculator:
            return [
                .init(input: "cC1+2*3", output: "计算结果：7，也会显示原算式结果"),
            ]
        case .numberConversion:
            return [
                .init(input: "R1234.56", output: "数字/金额大写：人民币大写等格式"),
            ]
        case .unicode:
            return [
                .init(input: "U62fc", output: "特殊字符：得到「拼」，并给出相邻编码候选"),
            ]
        case .uuid:
            return [
                .init(input: "uuid", output: "随机编号：生成一个 UUID v4"),
            ]
        case .vMode:
            return [
                .init(input: "v...", output: "更多符号：按方案内置前缀显示符号和特殊内容"),
            ]
        case .search:
            return [
                .init(input: "自动", output: "辅助查询：在候选栏补充相关查询类结果"),
            ]
        case .correction:
            return [
                .init(input: "自动", output: "输入提示：发现可能输错时给出提示候选"),
            ]
        case .longWordCandidates:
            return [
                .init(input: "自动", output: "长词优化：输入较长拼音时改善候选表现"),
            ]
        case .pinyinCandidateFilter:
            return [
                .init(input: "自动", output: "拼音降噪：减少不需要的拼音类候选"),
            ]
        case .englishCandidateFilter:
            return [
                .init(input: "自动", output: "英文降噪：降低英文候选对中文输入的干扰"),
            ]
        case .selectCharacter:
            return [
                .init(input: "自动", output: "选字辅助：需要逐字选择时显示辅助候选"),
            ]
        case .autoCapitalization:
            return [
                .init(input: "英文", output: "大小写辅助：在英文输入场景中辅助大小写"),
            ]
        }
    }
}

#Preview {
    NavigationStack {
        RimeAdvancedInputSettingsView(store: RimeSettingsStore())
    }
}
