import SwiftUI

struct GuideTab: View {
    /// When `false`, content is pushed inside an existing `NavigationStack` (Settings).
    var embedsOwnNavigationStack: Bool = true
    @Bindable var rimeStore: RimeSettingsStore
    /// J4: switch to Search tab and focus the trial field (`PD-APP-SEARCH-001`).
    var onRequestTryInput: (() -> Void)?

    @AppStorage("rime_active_schema", store: UserDefaults(suiteName: universeAppGroupID))
    private var activeSchemaID = "luna_pinyin"
    @AppStorage("rime_deployed", store: UserDefaults(suiteName: universeAppGroupID))
    private var rimeDeployed = false

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
    /// Expanded step for re-read (instruction only; does not clear progress).
    @State private var expandedReReadStep: ActivationChecklistState.Step?

    private var isDeploying: Bool {
        switch rimeStore.deploymentState {
        case .triggered, .deploying: return true
        default: return false
        }
    }

    private var activeSchemaInstalled: Bool {
        if let match = rimeStore.schemas.first(where: { $0.schemaID == activeSchemaID }) {
            return match.installed
        }
        // Builtin 朙月 is always treated as installed when listed absent during load.
        return activeSchemaID == ActivationChecklistState.builtinSchemaID
    }

    private var checklist: ActivationChecklistState {
        ActivationChecklistState(
            keyboardAddedAffirmed: keyboardAddedAffirmed,
            fullAccess: fullAccessPresentation,
            activeSchemaID: activeSchemaID,
            activeSchemaInstalled: activeSchemaInstalled,
            rimeDeployed: rimeDeployed,
            isDeploying: isDeploying,
            deploymentFailed: rimeStore.deploymentState == .failed,
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
        Group {
            if embedsOwnNavigationStack {
                NavigationStack {
                    guideScrollContent
                }
            } else {
                guideScrollContent
            }
        }
    }

    private var guideScrollContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                headerSection
                if checklist.isFullyActivated {
                    reReadBannerSection
                }
                nextStepSection
                checklistSection
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("启用指南")
        .navigationBarTitleDisplayMode(embedsOwnNavigationStack ? .large : .inline)
        .onChange(of: scenePhase) { _, phase in
            guard phase == .active else { return }
            refreshSharedContainerObservation()
        }
        .onAppear {
            rimeStore.load()
            refreshSharedContainerObservation()
            ActivationTips.sync(from: checklist)
        }
        .onChange(of: keyboardAddedAffirmed) { _, _ in ActivationTips.sync(from: checklist) }
        .onChange(of: fullAccessAffirmed) { _, _ in ActivationTips.sync(from: checklist) }
        .onChange(of: firstInputAffirmed) { _, _ in ActivationTips.sync(from: checklist) }
        .onChange(of: sharedDataUnavailable) { _, _ in ActivationTips.sync(from: checklist) }
        .onChange(of: rimeDeployed) { _, _ in ActivationTips.sync(from: checklist) }
        .onChange(of: activeSchemaID) { _, _ in ActivationTips.sync(from: checklist) }
        .onChange(of: rimeStore.deploymentState) { _, _ in ActivationTips.sync(from: checklist) }
        .onChange(of: rimeStore.downloadState) { _, _ in
            rimeStore.handleDownloadStateChange()
            ActivationTips.sync(from: checklist)
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

    private var reReadBannerSection: some View {
        InfoSection(title: "重新走一遍", systemImage: "arrow.trianglehead.counterclockwise") {
            Text(ActivationCopy.reReadOnlyBanner)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text("点开下方清单步骤可重看各步说明与操作指引。")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
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
                // Step-specific detail lives with the step (not a separate always-on block).
                stepGuideContent(for: step)
                if step == .addKeyboard || step == .fullAccess {
                    AppActionButton(
                        title: "打开设置",
                        systemImage: "gearshape",
                        prominence: .primary
                    ) {
                        openSystemSettings()
                    }
                    .accessibilityHint(ActivationCopy.systemLimitation)
                    affirmButtons(for: step)
                    Text(ActivationCopy.systemLimitation)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                if step == .prepareResources {
                    Text(ActivationCopy.mainAppPreparesResources)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    ActivationResourcePreparePanel(store: rimeStore)
                }
                if step == .firstInput {
                    firstInputActions
                }
            }
            // Contextual TipKit tip for the current next step only (one tip / one action).
            .activationPopoverTip(for: step)
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
        let isExpanded = expandedReReadStep == step
        return VStack(alignment: .leading, spacing: 8) {
            Button {
                withAnimation(.easeInOut(duration: 0.15)) {
                    expandedReReadStep = isExpanded ? nil : step
                }
            } label: {
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: checklist.isStepComplete(step) ? "checkmark.circle.fill" : "circle")
                        .foregroundStyle(checklist.isStepComplete(step) ? Color.primary : Color.secondary)
                        .accessibilityHidden(true)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(ActivationCopy.title(for: step))
                            .font(.body.weight(.medium))
                            .foregroundStyle(.primary)
                        Text(checklist.statusTitle(for: step))
                            .font(.caption)
                            .foregroundStyle(statusColor(for: step))
                    }
                    Spacer(minLength: 0)
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .accessibilityHidden(true)
                }
            }
            .buttonStyle(.plain)
            .accessibilityLabel("\(ActivationCopy.title(for: step))，\(checklist.statusTitle(for: step))")
            .accessibilityHint(isExpanded ? "收起说明" : "展开重看说明，不会清除进度")

            if isExpanded {
                Text(detail(for: step))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text(ActivationCopy.nextActionTitle(for: step))
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(.secondary)
                // Numbered system steps / resource panel live under the matching checklist item.
                stepGuideContent(for: step)
                if step == .prepareResources, !checklist.isStepComplete(.prepareResources) {
                    ActivationResourcePreparePanel(store: rimeStore)
                } else if checklist.nextStep == step, step != .prepareResources {
                    if step == .addKeyboard || step == .fullAccess {
                        AppActionButton(
                            title: "打开设置",
                            systemImage: "gearshape",
                            prominence: .primary
                        ) {
                            openSystemSettings()
                        }
                        affirmButtons(for: step)
                    } else if step == .firstInput {
                        firstInputActions
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var firstInputActions: some View {
        Text(ActivationCopy.firstInputTryHint)
            .font(.footnote)
            .foregroundStyle(.secondary)
        Text(ActivationCopy.firstInputExample)
            .font(.caption)
            .foregroundStyle(.secondary)
        if onRequestTryInput != nil {
            AppActionButton(
                title: ActivationCopy.firstInputTryCTA,
                systemImage: "magnifyingglass",
                prominence: .primary
            ) {
                onRequestTryInput?()
            }
        }
        affirmButtons(for: stepFirstInput)
    }

    /// Affirm path for first-input only (avoids capturing wrong step in builders).
    private var stepFirstInput: ActivationChecklistState.Step { .firstInput }

    /// Per-step instructional content (was a separate always-visible「系统设置步骤」block).
    @ViewBuilder
    private func stepGuideContent(for step: ActivationChecklistState.Step) -> some View {
        switch step {
        case .addKeyboard:
            VStack(alignment: .leading, spacing: 8) {
                NumberedGuideRow(number: 1, text: "打开系统设置")
                NumberedGuideRow(number: 2, text: "进入 通用 → 键盘 → 键盘")
                NumberedGuideRow(number: 3, text: "点 添加新键盘")
                NumberedGuideRow(number: 4, text: "选择 \(ActivationCopy.keyboardDisplayName)")
                NumberedGuideRow(number: 5, text: "返回本 App 继续")
            }
        case .fullAccess:
            VStack(alignment: .leading, spacing: 8) {
                NumberedGuideRow(number: 1, text: "在键盘列表中点 \(ActivationCopy.keyboardDisplayName)")
                NumberedGuideRow(number: 2, text: "打开「允许完全访问」")
                NumberedGuideRow(number: 3, text: "在系统提示中确认")
                NumberedGuideRow(number: 4, text: "返回本 App")
                Text(ActivationCopy.fullAccessPurpose)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .padding(.top, 4)
                Text(ActivationCopy.fullAccessNotUpload)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                Text(ActivationCopy.degradedBasicTyping)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        case .prepareResources, .firstInput:
            EmptyView()
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
        }
    }

    private func detail(for step: ActivationChecklistState.Step) -> String {
        switch step {
        case .addKeyboard:
            return "在系统设置中添加 \(ActivationCopy.keyboardDisplayName)，然后返回这里。"
        case .fullAccess:
            return "\(ActivationCopy.fullAccessPurpose) \(ActivationCopy.fullAccessNotUpload)"
        case .prepareResources:
            return "在下方选择输入方案并完成安装与部署后，完整候选才可用。"
        case .firstInput:
            return "在「搜索」页输入框中切换到本键盘，输入任意内容试用即可。"
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



#Preview {
    GuideTab(rimeStore: RimeSettingsStore())
}
