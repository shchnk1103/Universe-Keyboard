import KeyboardCore
import SwiftUI

/// 设置 → 输入体验 → 删除键。点按和长按重复始终可用，不在本页出现。
struct DeleteKeySettingsView: View {
    private let defaults = UserDefaults(suiteName: universeAppGroupID)

    @AppStorage(DeleteKeyHoldFlags.trashBubbleKey, store: UserDefaults(suiteName: universeAppGroupID))
    private var trashBubbleEnabled = true
    @AppStorage(DeleteKeyHoldFlags.scrubKey, store: UserDefaults(suiteName: universeAppGroupID))
    private var scrubEnabled = true
    @AppStorage(DeleteKeyHoldFlags.composingAbandonKey, store: UserDefaults(suiteName: universeAppGroupID))
    private var composingAbandonEnabled = true

    var body: some View {
        Form {
            Section {
                Toggle("长按垃圾桶", isOn: $trashBubbleEnabled)
                    .toggleStyle(.appSwitch)
            } footer: {
                Text(
                    trashBubbleEnabled
                        ? "按住后出现垃圾桶。移进去松手，清空光标前能看见的文字。"
                        : "按住后不出现垃圾桶。")
            }

            Section {
                Toggle("滑动擦除", isOn: $scrubEnabled)
                    .toggleStyle(.appSwitch)
            } footer: {
                Text(
                    scrubEnabled
                        ? "按住后向左按距离删除，向右滑回刚删的字。"
                        : "手指离开删除键就停止这一次删除。")
            }

            Section {
                Toggle("组字时左滑", isOn: $composingAbandonEnabled)
                    .toggleStyle(.appSwitch)
            } footer: {
                Text(
                    composingAbandonEnabled
                        ? "正在组字时向左滑，放弃还没上屏的拼音。"
                        : "正在组字时向左滑，不再放弃剩余拼音。")
            }
        }
        .navigationTitle("删除键")
        .tint(.primary)
        .onChange(of: trashBubbleEnabled) { _, _ in defaults?.synchronize() }
        .onChange(of: scrubEnabled) { _, _ in defaults?.synchronize() }
        .onChange(of: composingAbandonEnabled) { _, _ in defaults?.synchronize() }
    }
}
