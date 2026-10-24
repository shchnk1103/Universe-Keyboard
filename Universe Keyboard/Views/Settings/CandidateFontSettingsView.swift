import KeyboardCore
import SwiftUI
import UIKit

struct CandidateFontSettingsEntry: View {
    var body: some View {
        Section {
            NavigationLink {
                CandidateFontSettingsView()
            } label: {
                Label(CandidateFontSettingsCopy.title, systemImage: "textformat.size")
            }
        } footer: {
            Text(CandidateFontSettingsCopy.subtitle)
        }
    }
}

struct CandidateFontSettingsView: View {
    @State private var model = CandidateFontSettingsPageModel()

    var body: some View {
        Form {
            Section("预览") {
                CandidateFontPreview(tier: model.tier)
                    .frame(height: 60)
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel(CandidateFontSettingsCopy.preview)
            }
            Section {
                HStack {
                    Text("\(model.tier)")
                    if model.tier == 17 { Text("默认").foregroundStyle(.secondary) }
                    Spacer()
                }
                Slider(
                    value: Binding(get: { Double(model.tier) }, set: { model.select(Int($0)) }),
                    in: 13...22, step: 1
                ) {
                    Text(CandidateFontSettingsCopy.title)
                } minimumValueLabel: {
                    Text("小")
                } maximumValueLabel: {
                    Text("大")
                }
                .accessibilityLabel(CandidateFontSettingsCopy.title)
                .accessibilityValue(model.accessibilityValue)
                // 第五档为默认；刻度位置与滑杆的整数档位一致。
                HStack(spacing: 0) {
                    ForEach(Array(CandidateFontSettingsPageModel.tiers), id: \.self) { tier in
                        Text(tier == 17 ? "默认" : "·")
                            .font(.caption2)
                            .frame(maxWidth: .infinity)
                    }
                }
                .accessibilityHidden(true)
            } footer: {
                Text(CandidateFontSettingsCopy.footer)
            }
        }
        .navigationTitle(CandidateFontSettingsCopy.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct CandidateFontPreview: UIViewRepresentable {
    let tier: Int

    func makeUIView(context: Context) -> CandidateFontPreviewBar { CandidateFontPreviewBar() }

    func updateUIView(_ uiView: CandidateFontPreviewBar, context: Context) {
        uiView.update(tier: tier)
    }
}

/// 静态 UILabel 示例，不创建输入框、引擎或真实键盘连接。
final class CandidateFontPreviewBar: UIStackView {
    private(set) var sampleLabels: [UILabel] = []
    private var tier = 17

    init() {
        super.init(frame: .zero)
        axis = .horizontal
        alignment = .center
        distribution = .equalSpacing
        spacing = 8
        for (index, text) in ["ni hao", "你好", "您好", "你们"].enumerated() {
            let label = UILabel()
            label.text = text
            label.textColor = index == 0 ? .secondaryLabel : .label
            if index == 1 {
                label.backgroundColor = .tertiarySystemFill
                label.layer.cornerRadius = 6
                label.clipsToBounds = true
            }
            label.adjustsFontForContentSizeCategory = false
            sampleLabels.append(label)
            addArrangedSubview(label)
        }
        registerForTraitChanges([UITraitPreferredContentSizeCategory.self]) {
            (view: CandidateFontPreviewBar, _: UITraitCollection) in
            view.update(tier: view.tier)
        }
        update(tier: tier)
    }

    required init(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func update(tier: Int) {
        self.tier = tier
        apply(CandidateFontSnapshot(settings: CandidateFontSettings(savedValue: tier), traits: traitCollection))
    }

    func apply(_ snapshot: CandidateFontSnapshot) {
        for (index, label) in sampleLabels.enumerated() {
            label.font = snapshot.titleFont(kind: index == 0 ? .composition : .candidate, preferred: index == 1)
        }
    }
}
