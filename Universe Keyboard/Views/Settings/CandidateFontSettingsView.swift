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
                    .frame(height: 46)
                    .listRowInsets(EdgeInsets())
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
final class CandidateFontPreviewBar: UIView {
    private(set) var sampleLabels: [UILabel] = []
    private let candidates = UIStackView()
    private let viewport = UIScrollView()
    private let actionZone = UIView()
    private var tier = 17

    // 等值镜像，不搬动扩展常量：Keyboard/Views/KeyboardDesignTokens.swift 的 CandidateBar，
    // totalHeight=46、actionZoneWidth=56、actionSymbolSize=22。
    private enum Metrics {
        static let height: CGFloat = 46
        static let actionWidth: CGFloat = 56
        static let symbolSize: CGFloat = 22
    }

    init() {
        super.init(frame: .zero)
        // 对应 Keyboard/Controllers/KeyboardViewController+KeyStyle.swift 的 keyboardBackgroundColor。
        backgroundColor = UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(red: 30 / 255, green: 30 / 255, blue: 32 / 255, alpha: 1)
                : UIColor(red: 209 / 255, green: 209 / 255, blue: 214 / 255, alpha: 1)
        }
        // 只读示例：没有候选选择、展开动作或输入连接。
        isUserInteractionEnabled = false
        viewport.showsHorizontalScrollIndicator = false
        viewport.contentInsetAdjustmentBehavior = .never
        viewport.isScrollEnabled = false
        viewport.clipsToBounds = true
        viewport.backgroundColor = .clear
        if #available(iOS 26.0, *) {
            // 对应 Keyboard/Views/CandidateBar/CandidateScrollViewStyle.swift 的 apply(to:)：不叠加边缘淡化。
            viewport.leftEdgeEffect.isHidden = true
            viewport.rightEdgeEffect.isHidden = true
        }
        candidates.axis = .horizontal
        candidates.alignment = .center
        candidates.spacing = 0
        viewport.translatesAutoresizingMaskIntoConstraints = false
        candidates.translatesAutoresizingMaskIntoConstraints = false
        actionZone.translatesAutoresizingMaskIntoConstraints = false
        addSubview(viewport)
        addSubview(actionZone)
        viewport.addSubview(candidates)

        for (index, text) in ["ni hao", "你好", "您好", "你们"].enumerated() {
            let label = UILabel()
            label.text = text
            label.textColor = index == 0 ? .secondaryLabel : (index == 1 ? .systemBackground : .label)
            label.adjustsFontForContentSizeCategory = false
            label.setContentCompressionResistancePriority(.required, for: .horizontal)
            label.translatesAutoresizingMaskIntoConstraints = false
            let cell = UIView()
            let title = UIView()
            title.translatesAutoresizingMaskIntoConstraints = false
            cell.addSubview(title)
            title.addSubview(label)
            // 对应 Keyboard/Views/CandidateBar/CandidateCell.swift 的 VisualSpacing.horizontalGap / configureTitle：
            // cell内缩左右各2；首选8、普通12；文字上下4；高亮连续圆角8。
            let inset: CGFloat = index == 1 ? 8 : 12
            if index == 1 {
                title.backgroundColor = .label
                title.layer.cornerRadius = 8
                title.layer.cornerCurve = .continuous
            }
            NSLayoutConstraint.activate([
                cell.heightAnchor.constraint(equalToConstant: Metrics.height),
                cell.widthAnchor.constraint(greaterThanOrEqualToConstant: 48),
                title.leadingAnchor.constraint(equalTo: cell.leadingAnchor, constant: 2),
                title.trailingAnchor.constraint(equalTo: cell.trailingAnchor, constant: -2),
                title.centerYAnchor.constraint(equalTo: cell.centerYAnchor),
                label.leadingAnchor.constraint(equalTo: title.leadingAnchor, constant: inset),
                label.trailingAnchor.constraint(equalTo: title.trailingAnchor, constant: -inset),
                label.topAnchor.constraint(equalTo: title.topAnchor, constant: 4),
                label.bottomAnchor.constraint(equalTo: title.bottomAnchor, constant: -4),
            ])
            sampleLabels.append(label)
            candidates.addArrangedSubview(cell)
        }

        // 对应 Keyboard/Views/CandidateBar/CandidateBarView.swift 的 expandButton 操作区；不注册动作。
        let chevron = UIImageView(
            image: UIImage(
                systemName: "chevron.down",
                withConfiguration: UIImage.SymbolConfiguration(pointSize: Metrics.symbolSize, weight: .medium)))
        chevron.tintColor = .secondaryLabel
        chevron.contentMode = .center
        chevron.translatesAutoresizingMaskIntoConstraints = false
        actionZone.addSubview(chevron)
        NSLayoutConstraint.activate([
            viewport.leadingAnchor.constraint(equalTo: leadingAnchor),
            viewport.topAnchor.constraint(equalTo: topAnchor),
            viewport.bottomAnchor.constraint(equalTo: bottomAnchor),
            viewport.trailingAnchor.constraint(equalTo: actionZone.leadingAnchor),
            actionZone.trailingAnchor.constraint(equalTo: trailingAnchor),
            actionZone.topAnchor.constraint(equalTo: topAnchor),
            actionZone.bottomAnchor.constraint(equalTo: bottomAnchor),
            actionZone.widthAnchor.constraint(equalToConstant: Metrics.actionWidth),
            chevron.centerXAnchor.constraint(equalTo: actionZone.centerXAnchor),
            chevron.centerYAnchor.constraint(equalTo: actionZone.centerYAnchor),
            candidates.leadingAnchor.constraint(equalTo: viewport.contentLayoutGuide.leadingAnchor),
            candidates.trailingAnchor.constraint(equalTo: viewport.contentLayoutGuide.trailingAnchor),
            candidates.topAnchor.constraint(equalTo: viewport.contentLayoutGuide.topAnchor),
            candidates.bottomAnchor.constraint(equalTo: viewport.contentLayoutGuide.bottomAnchor),
            candidates.heightAnchor.constraint(equalTo: viewport.frameLayoutGuide.heightAnchor),
        ])
        registerForTraitChanges([UITraitPreferredContentSizeCategory.self]) {
            (view: CandidateFontPreviewBar, _: UITraitCollection) in
            view.update(tier: view.tier)
        }
        update(tier: tier)
    }

    required init(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: Metrics.height)
    }

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
