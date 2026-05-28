import SwiftUI

struct RimePreferencesSections: View {
    @Bindable var store: RimeSettingsStore

    var body: some View {
        Section {
            VStack(spacing: 8) {
                HStack {
                    Text("\(Int(store.pageSize)) 个")
                        .font(.title3)
                        .fontWeight(.medium)
                        .foregroundStyle(.primary)
                    Spacer()
                }
                Slider(value: $store.pageSize, in: 5...20, step: 1)
            }
            .onChange(of: store.pageSize) { _, _ in store.savePreferences() }
        } header: {
            Text("候选数量")
        } footer: {
            Text("每页最多显示的候选词个数。数量越少选词越快，数量越多翻页更少。默认 9 个。")
        }

        Section {
            Toggle("默认简体", isOn: $store.simplified)
                .toggleStyle(MonochromeToggleStyle())
                .onChange(of: store.simplified) { _, _ in store.savePreferences() }
        } header: {
            Text("简繁转换")
        } footer: {
            Text(store.simplified ? "开启后使用 OpenCC 将结果转为简体中文输出。" : "关闭后保留词典原始字形。")
        }
    }
}
