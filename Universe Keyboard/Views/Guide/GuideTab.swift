import SwiftUI

struct GuideTab: View {
    @AppStorage("rime_active_schema", store: UserDefaults(suiteName: universeAppGroupID))
    private var activeSchemaID = "luna_pinyin"
    @AppStorage("rime_deployed", store: UserDefaults(suiteName: universeAppGroupID))
    private var rimeDeployed = false
    @AppStorage("logging_enabled", store: UserDefaults(suiteName: universeAppGroupID))
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
                    RoundedRectangle(cornerRadius: 12, style: .continuous).fill(.primary)
                    Image(systemName: "keyboard")
                        .font(.system(size: 25, weight: .semibold))
                        .foregroundStyle(Color(.systemBackground))
                }
                .frame(width: 52, height: 52)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Universe Keyboard").font(.title3).fontWeight(.semibold)
                    Text("RIME 中文输入法").font(.subheadline).foregroundStyle(.secondary)
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
            NumberedGuideRow(number: 1, text: "打开系统设置")
            NumberedGuideRow(number: 2, text: "进入 通用 → 键盘 → 键盘")
            NumberedGuideRow(number: 3, text: "点 添加新键盘")
            NumberedGuideRow(number: 4, text: "选择 Keyboard")
            NumberedGuideRow(number: 5, text: "打开输入框，点地球键切换到 Universe Keyboard")
            Text("首次使用需要在系统设置中添加一次键盘，之后随时可通过地球键切换。")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .padding(.top, 6)
        }
    }

    private var statusSection: some View {
        InfoSection(title: "当前状态", systemImage: "keyboard.badge.ellipsis") {
            GuideStatusRow(title: "输入方案", value: activeSchemaID == "rime_ice" ? "雾凇拼音" : "朙月拼音", color: .primary)
            Divider()
            GuideStatusRow(title: "词库部署", value: rimeDeployed ? "已就绪" : "待部署", color: rimeDeployed ? .primary : .orange)
            Divider()
            GuideStatusRow(
                title: "卡顿诊断", value: loggingEnabled ? "记录中" : "未开启", color: loggingEnabled ? .primary : .secondary)
        }
    }

    private var testChecklistSection: some View {
        InfoSection(title: "测试清单", systemImage: "list.bullet.clipboard") {
            BulletRow(text: "输入 nihao，确认候选出现且空格可选词", style: .checkmark)
            BulletRow(text: "连续快速输入一段拼音，观察是否停顿", style: .checkmark)
            BulletRow(text: "出现卡顿后回到「设置 > 诊断日志」查看记录", style: .checkmark)
        }
    }
}

private struct NumberedGuideRow: View {
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

private struct GuideStatusRow: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        HStack {
            Text(title).foregroundStyle(.primary)
            Spacer()
            Text(value).font(.subheadline.weight(.medium)).foregroundStyle(color)
        }
    }
}
