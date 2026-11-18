import KeyboardCore
import SwiftUI

struct CharacterKeyStyleSettingsView: View {
    @State private var size = 17
    @State private var bold = false
    @State private var chinese26 = "upper"
    @State private var chinese9 = "upper"
    @State private var english26 = "followShift"
    private var defaults: UserDefaults? { UserDefaults(suiteName: "group.com.DoubleShy0N.Universe-Keyboard") }

    var body: some View {
        Form {
            Section("预览") {
                HStack {
                    ForEach(["A", "WXYZ", ","], id: \.self) { label in
                        Text(label).font(.system(size: CGFloat(size), weight: bold ? .bold : .regular))
                            .frame(maxWidth: .infinity, minHeight: 40)
                    }
                }
            }
            Section {
                HStack {
                    Text("\(size)"); if size == 17 { Text("默认").foregroundStyle(.secondary) }
                }
                Slider(
                    value: Binding(
                        get: { Double(size) },
                        set: { value in
                            size = Int(value)
                            CharacterKeyStyle.saveSize(size, defaults: defaults)
                        }), in: 13...22, step: 1
                ) {
                    Text("字符字号")
                } minimumValueLabel: {
                    Text("小")
                } maximumValueLabel: {
                    Text("大")
                }
                Toggle(
                    "加粗",
                    isOn: Binding(
                        get: { bold },
                        set: {
                            bold = $0; defaults?.set($0, forKey: CharacterKeyStyle.boldKey)
                        }))
                Picker(
                    "中文 26 键",
                    selection: Binding(
                        get: { chinese26 },
                        set: {
                            chinese26 = $0; defaults?.set($0, forKey: CharacterKeyStyle.chinese26Key)
                        })
                ) {
                    Text("大写").tag("upper"); Text("小写").tag("lower")
                }
                Picker(
                    "中文九宫格",
                    selection: Binding(
                        get: { chinese9 },
                        set: {
                            chinese9 = $0; defaults?.set($0, forKey: CharacterKeyStyle.chinese9Key)
                        })
                ) {
                    Text("大写").tag("upper"); Text("小写").tag("lower")
                }
                Picker(
                    "英文 26 键",
                    selection: Binding(
                        get: { english26 },
                        set: {
                            english26 = $0; defaults?.set($0, forKey: CharacterKeyStyle.english26Key)
                        })
                ) {
                    Text("跟随 Shift").tag("followShift"); Text("固定大写").tag("upper"); Text("固定小写").tag("lower")
                }
            } footer: {
                Text("更改在键盘下次出现时生效。未开启完全访问时共享设置可能不可用，键盘使用默认样式。")
            }
        }
        .navigationTitle("字符键样式")
        .onAppear {
            let style = CharacterKeyStyle(defaults: defaults)
            size = style.size; bold = style.bold
            chinese26 = style.chinese26.rawValue; chinese9 = style.chinese9.rawValue;
            english26 = style.english26.rawValue
        }
    }
}
