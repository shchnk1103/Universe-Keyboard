import KeyboardCore
import SwiftUI

struct AppearanceSettingsView: View {
    @AppStorage(AppAppearance.storageKey, store: AppAppearance.storage)
    private var appearanceRawValue = AppAppearance.system.rawValue
    @AppStorage(KeyboardAppearanceSettingsKey.liquidGlassMaterialEnabled, store: UserDefaults(suiteName: universeAppGroupID))
    private var liquidGlassMaterialEnabled = false

    private var appearance: AppAppearance {
        AppAppearance(rawValue: appearanceRawValue) ?? .system
    }

    var body: some View {
        Form {
            Section {
                ForEach(AppAppearance.allCases) { option in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            appearanceRawValue = option.rawValue
                        }
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: option.symbolName)
                                .font(.body.weight(.medium))
                                .frame(width: 28, height: 28)
                                .foregroundStyle(.primary)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(option.title)
                                    .foregroundStyle(.primary)
                                Text(option.subtitle)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            if option == appearance {
                                Image(systemName: "checkmark")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(.primary)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            } header: {
                Text("应用显示模式")
            } footer: {
                Text("仅调整 Universe Keyboard 主 App 的显示模式；键盘会自动匹配当前输入环境的浅色或深色外观。")
            }

            Section {
                HStack(spacing: 16) {
                    ThemeSample(title: "浅色", background: .white, foreground: .black)
                    ThemeSample(title: "深色", background: .black, foreground: .white)
                }
                .padding(.vertical, 6)
            } header: {
                Text("强调色")
            } footer: {
                Text("按钮与选中状态采用随外观切换的黑白高对比样式。")
            }

            Section {
                ToggleRow(
                    title: "实验性 Liquid Glass 材质",
                    description: "开启后键盘扩展会尝试使用系统公开材质层；如可读性或性能不稳定，可关闭回到统一 tint surface。",
                    isOn: $liquidGlassMaterialEnabled
                )
            } header: {
                Text("实验性功能")
            } footer: {
                Text("该开关用于调试键盘外观。开启后需要重新唤起键盘，才能稳定观察扩展中的材质变化。")
            }
        }
        .navigationTitle("外观")
        .tint(.primary)
    }
}

private struct ThemeSample: View {
    let title: String
    let background: Color
    let foreground: Color

    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(foreground)
                .frame(width: 12, height: 12)
            Text(title)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(foreground)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 40)
        .background(background)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(Color.primary.opacity(0.12), lineWidth: 1)
        }
    }
}

#Preview {
    NavigationStack {
        AppearanceSettingsView()
    }
}
