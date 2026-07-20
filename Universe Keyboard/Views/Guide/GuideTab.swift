import SwiftUI

struct GuideTab: View {
    @AppStorage("rime_active_schema", store: UserDefaults(suiteName: universeAppGroupID))
    private var activeSchemaID = "luna_pinyin"
    @AppStorage("rime_deployed", store: UserDefaults(suiteName: universeAppGroupID))
    private var rimeDeployed = false
    @AppStorage("logging_enabled", store: UserDefaults(suiteName: universeAppGroupID))
    private var loggingEnabled = false

    /// Onboarding affirmations stay in standard defaults so Guide UX does not
    /// depend on inventing a live Extension Full Access flag in the App Group.
    @AppStorage("activation_keyboard_added_affirmed")
    private var keyboardAddedAffirmed = false
    @AppStorage("activation_full_access_affirmed")
    private var fullAccessAffirmed = false
    @AppStorage("activation_first_input_affirmed")
    private var firstInputAffirmed = false
    @AppStorage("activation_shared_data_unavailable")
    private var sharedDataUnavailable = false

    @Environment(\.scenePhase) private var scenePhase
    @State private var showAdvanced = false

    private var checklist: ActivationChecklistState {
        ActivationChecklistState(
            keyboardAddedAffirmed: keyboardAddedAffirmed,
            fullAccess: fullAccessPresentation,
            rimeDeployed: rimeDeployed,
            isDeploying: false,
            deploymentFailed: false,
            firstInputAffirmed: firstInputAffirmed
        )
    }

    private var fullAccessPresentation: ActivationChecklistState.FullAccessPresentation {
        if sharedDataUnavailable {
            return .sharedDataUnavailable
        }
        if fullAccessAffirmed {
            return .userAffirmed
        }
        return .unknown
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    headerSection
                    nextStepSection
                    checklistSection
                    enableDetailSection
                    statusSection
                    advancedSection
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("启用指南")
            .onChange(of: scenePhase) { _, phase in
                guard phase == .active else { return }
                refreshSharedContainerObservation()
            }
            .onAppear {
                refreshSharedContainerObservation()
            }
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
            Text(ActivationCopy.valueLocal)
                .font(.body)
            Text(ActivationCopy.privacyNoUpload)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            if checklist.isFullyActivated {
                Text("基本启用步骤已确认。完整体验仍取决于系统中的键盘、完全访问与本地资源是否真实可用。")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder
    private var nextStepSection: some View {
        if let step = checklist.nextStep {
            InfoSection(title: "下一步", systemImage: "arrow.right.circle") {
                Text(ActivationCopy.title(for: step))
                    .font(.headline)
                Text(detail(for: step))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                if step == .addKeyboard || step == .fullAccess {
                    AppActionButton(
                        title: "打开设置",
                        systemImage: "gearshape",
                        prominence: .primary
                    ) {
                        openSystemSettings()
                    }
                    .accessibilityHint(ActivationCopy.systemLimitation)
                }
                if step == .prepareResources {
                    Text("请到「设置」页的 RIME / 部署区域准备资源。\(ActivationCopy.mainAppPreparesResources)")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                affirmButtons(for: step)
                Text(ActivationCopy.systemLimitation)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        } else {
            InfoSection(title: "启用状态", systemImage: "checkmark.circle") {
                Text("清单步骤已确认完成")
                    .font(.headline)
                Text(ActivationCopy.liveStateUnknown)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                NavigationLink {
                    PrivacyDataView()
                } label: {
                    Label("查看隐私与数据说明", systemImage: "hand.raised")
                        .font(.subheadline.weight(.semibold))
                }
            }
        }
    }

    private var checklistSection: some View {
        InfoSection(title: "启用清单", systemImage: "checklist") {
            ForEach(ActivationChecklistState.Step.allCases, id: \.rawValue) { step in
                if step != .addKeyboard {
                    Divider()
                }
                checklistRow(step)
            }
        }
    }

    private func checklistRow(_ step: ActivationChecklistState.Step) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: checklist.isStepComplete(step) ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(checklist.isStepComplete(step) ? Color.primary : Color.secondary)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 4) {
                Text(ActivationCopy.title(for: step))
                    .font(.body.weight(.medium))
                Text(checklist.statusTitle(for: step))
                    .font(.caption)
                    .foregroundStyle(statusColor(for: step))
            }
            Spacer(minLength: 0)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(ActivationCopy.title(for: step))，\(checklist.statusTitle(for: step))")
    }

    private var enableDetailSection: some View {
        InfoSection(title: "系统设置步骤", systemImage: "gearshape") {
            Text("添加键盘")
                .font(.subheadline.weight(.semibold))
            NumberedGuideRow(number: 1, text: "打开系统设置")
            NumberedGuideRow(number: 2, text: "进入 通用 → 键盘 → 键盘")
            NumberedGuideRow(number: 3, text: "点 添加新键盘")
            NumberedGuideRow(number: 4, text: "选择 \(ActivationCopy.keyboardDisplayName)")
            NumberedGuideRow(number: 5, text: "返回本 App 继续")

            Divider().padding(.vertical, 4)

            Text("允许完全访问")
                .font(.subheadline.weight(.semibold))
            NumberedGuideRow(number: 1, text: "在键盘列表中点 \(ActivationCopy.keyboardDisplayName)")
            NumberedGuideRow(number: 2, text: "打开「允许完全访问」")
            NumberedGuideRow(number: 3, text: "在系统提示中确认")
            NumberedGuideRow(number: 4, text: "返回本 App")

            Text(ActivationCopy.fullAccessPurpose)
                .font(.footnote)
                .foregroundStyle(.secondary)
                .padding(.top, 6)
            Text(ActivationCopy.fullAccessNotUpload)
                .font(.footnote)
                .foregroundStyle(.secondary)
            Text(ActivationCopy.degradedBasicTyping)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }

    private var statusSection: some View {
        InfoSection(title: "当前状态", systemImage: "keyboard.badge.ellipsis") {
            GuideStatusRow(
                title: "输入方案",
                value: activeSchemaID == "rime_ice" ? "雾凇拼音" : "朙月拼音",
                color: .primary
            )
            Divider()
            GuideStatusRow(
                title: "词库部署",
                value: rimeDeployed ? "已就绪" : "待部署",
                color: rimeDeployed ? .primary : .orange
            )
            Divider()
            GuideStatusRow(
                title: "共享数据",
                value: sharedDataUnavailable ? "不可用" : "可访问（主 App）",
                color: sharedDataUnavailable ? .orange : .secondary
            )
            Divider()
            GuideStatusRow(
                title: "卡顿诊断",
                value: loggingEnabled ? "记录中" : "未开启",
                color: loggingEnabled ? .primary : .secondary
            )
            Text(ActivationCopy.mainAppPreparesResources)
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.top, 4)
            Text(ActivationCopy.fallbackNotReady)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private var advancedSection: some View {
        InfoSection(title: "高级", systemImage: "wrench.and.screwdriver") {
            Button {
                showAdvanced.toggle()
            } label: {
                HStack {
                    Text(showAdvanced ? "收起诊断说明" : "显示诊断与验证说明")
                        .font(.subheadline.weight(.semibold))
                    Spacer()
                    Image(systemName: showAdvanced ? "chevron.up" : "chevron.down")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
            }
            .buttonStyle(.plain)
            .accessibilityHint("诊断项不是新用户必做步骤")

            if showAdvanced {
                BulletRow(text: "输入 nihao，确认候选出现且空格可选词", style: .checkmark)
                BulletRow(text: "连续快速输入一段拼音，观察是否停顿", style: .checkmark)
                BulletRow(text: "出现卡顿后到「设置 > 诊断日志」查看记录", style: .checkmark)
                Text(ActivationCopy.liveStateUnknown)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.top, 4)
            }
        }
    }

    @ViewBuilder
    private func affirmButtons(for step: ActivationChecklistState.Step) -> some View {
        switch step {
        case .addKeyboard:
            AppActionButton(
                title: "我已添加，继续",
                systemImage: "checkmark",
                prominence: .secondary
            ) {
                keyboardAddedAffirmed = true
            }
        case .fullAccess:
            AppActionButton(
                title: "我已开启，继续",
                systemImage: "checkmark",
                prominence: .secondary
            ) {
                fullAccessAffirmed = true
                sharedDataUnavailable = false
                refreshSharedContainerObservation()
            }
            Text("可稍后再开启。未开启时按键震动等共享反馈可能不可用，完整体验不保证。")
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(ActivationCopy.degradedBasicTyping)
                .font(.caption)
                .foregroundStyle(.secondary)
        case .prepareResources:
            EmptyView()
        case .firstInput:
            AppActionButton(
                title: "我已成功输入",
                systemImage: "checkmark",
                prominence: .secondary
            ) {
                firstInputAffirmed = true
            }
            Text("示例：打开备忘录，用地球键切换到 \(ActivationCopy.keyboardDisplayName)，输入 nihao 并上屏。")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private func detail(for step: ActivationChecklistState.Step) -> String {
        switch step {
        case .addKeyboard:
            return "在系统设置中添加 \(ActivationCopy.keyboardDisplayName)，然后返回这里。"
        case .fullAccess:
            return "\(ActivationCopy.fullAccessPurpose) \(ActivationCopy.fullAccessNotUpload)"
        case .prepareResources:
            return "主 App 需要准备本地 RIME 资源后，完整候选才可用。"
        case .firstInput:
            return "切换到本键盘并完成一次拼音上屏，确认激活成功。"
        }
    }

    private func statusColor(for step: ActivationChecklistState.Step) -> Color {
        if checklist.isStepComplete(step) { return .primary }
        if step == .fullAccess, fullAccessPresentation == .sharedDataUnavailable {
            return .orange
        }
        if step == .prepareResources, !rimeDeployed {
            return .orange
        }
        return .secondary
    }

    private func openSystemSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }

    /// Observes main-App App Group container reachability only.
    /// A reachable main-App container is not proof of Extension Full Access.
    private func refreshSharedContainerObservation() {
        let container = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: universeAppGroupID
        )
        if container == nil {
            sharedDataUnavailable = true
            return
        }
        // If the user previously hit an unavailable state but the main App can
        // resolve the container again, clear only the hard unavailable flag.
        // Do not auto-set Full Access to "on".
        if sharedDataUnavailable, fullAccessAffirmed == false {
            // Keep unavailable visible until the user re-affirms or a later
            // shared operation succeeds elsewhere; main-App container presence
            // alone is insufficient to claim Extension access.
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
        .accessibilityElement(children: .combine)
        .accessibilityLabel("第 \(number) 步，\(text)")
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
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title)，\(value)")
    }
}

#Preview {
    GuideTab()
}
