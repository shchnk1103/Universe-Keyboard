import KeyboardCore
import SwiftUI

struct HomeTab: View {
    @Bindable var rimeStore: RimeSettingsStore
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var model = TypingIntelligenceViewModel()
    /// One-shot staggered entrance for home cards (kept for the view lifetime).
    @State private var todayCardVisible = false
    @State private var keyboardCardVisible = false
    @State private var didPlayEntrance = false

    @AppStorage(
        KeyboardLayoutSettingsKey.layoutStyle,
        store: UserDefaults(suiteName: universeAppGroupID)
    )
    private var layoutStyleRaw = KeyboardLayoutStyle.twentySixKey.rawValue

    @AppStorage("rime_deployed", store: UserDefaults(suiteName: universeAppGroupID))
    private var rimeDeployed = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.section) {
                    todaySection
                        .appCardEntrance(isVisible: todayCardVisible, reduceMotion: reduceMotion)
                    keyboardStatusSection
                        .appCardEntrance(isVisible: keyboardCardVisible, reduceMotion: reduceMotion)
                }
                .padding(.horizontal, AppSpacing.screen)
                .padding(.vertical, AppSpacing.screen)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("首页")
            .onAppear {
                model.reload()
                rimeStore.load()
                playEntranceIfNeeded()
            }
            .onChange(of: scenePhase) { _, phase in
                guard phase == .active else { return }
                model.reload()
                rimeStore.load()
            }
        }
    }

    private func playEntranceIfNeeded() {
        guard !didPlayEntrance else { return }
        didPlayEntrance = true
        if reduceMotion {
            todayCardVisible = true
            keyboardCardVisible = true
            return
        }
        withAnimation(AppMotion.entranceAnimation) {
            todayCardVisible = true
        }
        withAnimation(AppMotion.entranceAnimation.delay(AppMotion.entranceStagger)) {
            keyboardCardVisible = true
        }
    }

    // MARK: - Today

    private var todaySection: some View {
        NavigationLink {
            TypingIntelligenceView()
        } label: {
            AppCard(
                horizontalPadding: AppSpacing.cardComfort,
                verticalPadding: AppSpacing.cardComfort
            ) {
                VStack(alignment: .leading, spacing: AppSpacing.screen) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 6) {
                            HStack(alignment: .firstTextBaseline, spacing: 8) {
                                Text("今日输入")
                                    .font(.title3.weight(.semibold))
                                streakIndicator
                            }
                            Text(statusCaption)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                                .contentTransition(.opacity)
                                .animation(AppMotion.statusAnimation, value: statusCaption)
                        }
                        Spacer(minLength: AppSpacing.row)
                        AppIconTile(
                            systemImage: "text.cursor",
                            size: AppIconSize.large,
                            cornerRadius: AppRadius.iconTileLarge,
                            symbolPointSize: AppIconSize.largeSymbol
                        )
                    }

                    if isStatisticsAvailable {
                        HStack(alignment: .lastTextBaseline, spacing: 6) {
                            Text(model.todayCounts.committedGraphemeCount.formatted())
                                .font(.system(.largeTitle, design: .rounded).weight(.bold))
                                .monospacedDigit()
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                                .contentTransition(.numericText())
                                .animation(
                                    AppMotion.statusAnimation,
                                    value: model.todayCounts.committedGraphemeCount
                                )
                            Text("字符")
                                .font(.body)
                                .foregroundStyle(.secondary)
                        }
                        .accessibilityElement(children: .ignore)
                        .accessibilityLabel("今日已输入 \(model.todayCounts.committedGraphemeCount) 个字符")
                    } else {
                        Text(todayUnavailableValue)
                            .font(.title2.weight(.semibold))
                            .foregroundStyle(.secondary)
                            .contentTransition(.opacity)
                            .animation(AppMotion.statusAnimation, value: todayUnavailableValue)
                    }

                    HStack(spacing: 0) {
                        MetricCell(
                            value: model.todayCounts.cjkCharacterCount.formatted(),
                            label: "中文",
                            valueFont: .title3.weight(.semibold).monospacedDigit(),
                            valueColor: isStatisticsAvailable ? .primary : .secondary,
                            labelFont: .subheadline
                        )
                        metricDivider
                        MetricCell(
                            value: model.todayCounts.latinLetterCount.formatted(),
                            label: "字母",
                            valueFont: .title3.weight(.semibold).monospacedDigit(),
                            valueColor: isStatisticsAvailable ? .primary : .secondary,
                            labelFont: .subheadline
                        )
                        metricDivider
                        MetricCell(
                            value: model.todayCounts.emojiCount.formatted(),
                            label: "Emoji",
                            valueFont: .title3.weight(.semibold).monospacedDigit(),
                            valueColor: isStatisticsAvailable ? .primary : .secondary,
                            labelFont: .subheadline
                        )
                    }
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(AppPressableButtonStyle())
        .accessibilityHint("打开输入趋势、字符构成与数据管理")
    }

    // MARK: - Keyboard status

    private var keyboardStatusSection: some View {
        AppCard(
            horizontalPadding: AppSpacing.cardComfort,
            verticalPadding: AppSpacing.cardComfort
        ) {
            VStack(alignment: .leading, spacing: AppSpacing.card) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("键盘与方案")
                            .font(.title3.weight(.semibold))
                        Text(keyboardStatusCaption)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                            .contentTransition(.opacity)
                            .animation(AppMotion.statusAnimation, value: keyboardStatusCaption)
                    }
                    Spacer(minLength: AppSpacing.row)
                    AppIconTile(
                        systemImage: "keyboard",
                        size: AppIconSize.large,
                        cornerRadius: AppRadius.iconTileLarge,
                        symbolPointSize: AppIconSize.largeSymbol
                    )
                }

                VStack(spacing: 0) {
                    statusNavigationRow(
                        systemImage: layoutRowIcon,
                        title: "键盘布局",
                        value: layoutTitle,
                        accessibilityHint: "打开键盘布局设置"
                    ) {
                        KeyboardLayoutSettingsView(rimeStore: rimeStore)
                    }

                    rowDivider

                    statusNavigationRow(
                        systemImage: "character.book.closed.zh",
                        title: "输入方案",
                        value: schemaDisplayName,
                        accessibilityHint: "打开 RIME 方案设置"
                    ) {
                        RimeSettingsView(store: rimeStore)
                    }

                    rowDivider

                    statusNavigationRow(
                        systemImage: resourceRowIcon,
                        title: "资源状态",
                        value: resourceStatusTitle,
                        accessibilityHint: "打开 RIME 方案与部署"
                    ) {
                        RimeSettingsView(store: rimeStore)
                    }
                }
            }
        }
        .accessibilityElement(children: .contain)
    }

    private func statusNavigationRow<Destination: View>(
        systemImage: String,
        title: String,
        value: String,
        accessibilityHint: String,
        @ViewBuilder destination: () -> Destination
    ) -> some View {
        NavigationLink {
            destination()
        } label: {
            HStack(spacing: AppSpacing.row) {
                AppIconTile(
                    systemImage: systemImage,
                    size: AppIconSize.standard,
                    cornerRadius: AppRadius.control,
                    symbolPointSize: 15
                )
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text(value)
                        .font(.body.weight(.medium))
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                        .contentTransition(.opacity)
                        .animation(AppMotion.statusAnimation, value: value)
                }
                Spacer(minLength: 8)
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.tertiary)
            }
            .padding(.vertical, 10)
            .contentShape(Rectangle())
        }
        .buttonStyle(AppPressableButtonStyle())
        .accessibilityHint(accessibilityHint)
    }

    private var rowDivider: some View {
        Rectangle()
            .fill(Color.primary.opacity(0.08))
            .frame(height: 1)
            .padding(.leading, 42)
    }

    // MARK: - Today helpers

    private var metricDivider: some View {
        Rectangle()
            .fill(Color.primary.opacity(0.08))
            .frame(width: 1, height: 40)
            .padding(.horizontal, 4)
    }

    private var isStatisticsAvailable: Bool {
        model.isEnabled && model.storeIssueDescription == nil
    }

    private var hasInputToday: Bool {
        isStatisticsAvailable && model.todayCounts.committedGraphemeCount > 0
    }

    private var displayedStreak: Int {
        isStatisticsAvailable ? model.homeStreak : 0
    }

    private var todayUnavailableValue: String {
        model.isEnabled ? "暂不可用" : "未开启"
    }

    private var statusCaption: String {
        if !model.isEnabled {
            return "本地统计未开启。需要时在输入趋势里打开即可。"
        }
        if model.storeIssueDescription != nil {
            return "暂时读不到统计，稍后再看也没关系。"
        }
        let count = model.todayCounts.committedGraphemeCount
        if count == 0 {
            return "今天还没输入，打开键盘写一句就好。"
        }
        return "今天写了 \(count.formatted()) 个字符，慢慢来也很好。"
    }

    private var streakIndicator: some View {
        HStack(spacing: 3) {
            Image(systemName: "flame.fill")
                .modifier(StreakFlameBounce(isActive: hasInputToday, reduceMotion: reduceMotion))
            Text(displayedStreak.formatted())
                .monospacedDigit()
                .contentTransition(.numericText())
                .animation(AppMotion.statusAnimation, value: displayedStreak)
        }
        .font(.subheadline.weight(.semibold))
        .foregroundStyle(hasInputToday ? .orange : .secondary)
        .animation(
            reduceMotion ? .linear(duration: 0) : .spring(duration: 0.32, bounce: 0.25),
            value: hasInputToday
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(
            hasInputToday
                ? "连续记录 \(displayedStreak) 天"
                : "今天尚未输入，连续记录 \(displayedStreak) 天"
        )
    }

    // MARK: - Keyboard status helpers

    private var resolvedLayout: KeyboardLayoutStyle {
        KeyboardLayoutStyle.resolve(layoutStyleRaw)
    }

    private var layoutTitle: String {
        switch resolvedLayout {
        case .twentySixKey: return "全键盘拼音"
        case .nineKey: return "九宫格拼音"
        }
    }

    private var layoutRowIcon: String {
        switch resolvedLayout {
        case .twentySixKey: return "keyboard"
        case .nineKey: return "square.grid.3x3.fill"
        }
    }

    private var schemaDisplayName: String {
        let id = rimeStore.activeSchemaID
        if let name = rimeStore.schemas.first(where: { $0.schemaID == id })?.name {
            return name
        }
        switch id {
        case "rime_ice": return "雾凇拼音"
        case "luna_pinyin": return "朙月拼音"
        default: return id
        }
    }

    private var resourceStatusTitle: String {
        switch rimeStore.deploymentState {
        case .triggered, .deploying:
            return "准备中"
        case .failed:
            return "需要重试"
        case .needsDeploy:
            return "待应用"
        case .deployed:
            return "已就绪"
        case .idle:
            return rimeDeployed ? "已就绪" : "待部署"
        }
    }

    private var resourceRowIcon: String {
        switch rimeStore.deploymentState {
        case .triggered, .deploying:
            return "arrow.triangle.2.circlepath"
        case .failed:
            return "exclamationmark.triangle"
        case .needsDeploy:
            return "clock"
        case .deployed:
            return "checkmark.circle"
        case .idle:
            return rimeDeployed ? "checkmark.circle" : "tray.and.arrow.down"
        }
    }

    private var keyboardStatusCaption: String {
        switch rimeStore.deploymentState {
        case .triggered, .deploying:
            return "正在准备方案资源，稍等片刻就好。"
        case .failed:
            return "上次部署没有完成，去方案设置里重试一下。"
        case .needsDeploy:
            return "设置有更新，到方案页应用后就会生效。"
        case .deployed:
            return layoutReadyCaption
        case .idle:
            if rimeDeployed {
                return layoutReadyCaption
            }
            return "方案资源还没就绪，去设置里部署一下就好。"
        }
    }

    private var layoutReadyCaption: String {
        switch resolvedLayout {
        case .nineKey:
            return "当前是九宫格；英文场景仍会走全键盘。"
        case .twentySixKey:
            return "布局和方案都准备好了，打开任意 App 就能用。"
        }
    }
}

/// Applies flame bounce only when motion is allowed.
private struct StreakFlameBounce: ViewModifier {
    let isActive: Bool
    let reduceMotion: Bool

    func body(content: Content) -> some View {
        if reduceMotion {
            content
        } else {
            content.symbolEffect(.bounce, value: isActive)
        }
    }
}

#Preview {
    HomeTab(rimeStore: RimeSettingsStore())
}
