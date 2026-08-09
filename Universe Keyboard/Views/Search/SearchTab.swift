import SwiftUI

/// Always-on Search tab: settings discovery + real text field for keyboard trial
/// (`PD-APP-SEARCH-001`).
struct SearchTab: View {
    @Bindable var rimeStore: RimeSettingsStore
    @Bindable var syncModel: RimeSyncViewModel
    @Bindable var notificationSettings: AppNotificationSettingsModel

    /// Incremented by ContentView when J4 requests focus.
    var focusRequestToken: Int

    @State private var query = ""
    @FocusState private var fieldFocused: Bool
    @State private var lastHandledFocusToken = 0

    private var results: [SettingsSearchItem] {
        SettingsSearchCatalog.matches(query: query)
    }

    private var trimmedQuery: String {
        query.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.section) {
                    searchFieldCard
                    if trimmedQuery.isEmpty {
                        hintsSection
                    } else if results.isEmpty {
                        emptyResultsSection
                    } else {
                        resultsSection
                    }
                }
                .padding(.horizontal, AppSpacing.screen)
                .padding(.vertical, AppSpacing.screen)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("搜索")
            .onChange(of: focusRequestToken) { _, token in
                guard token != lastHandledFocusToken else { return }
                lastHandledFocusToken = token
                // Defer so the tab is visible before becoming first responder.
                DispatchQueue.main.async {
                    fieldFocused = true
                }
            }
            .onAppear {
                rimeStore.load()
                if focusRequestToken != lastHandledFocusToken, focusRequestToken > 0 {
                    lastHandledFocusToken = focusRequestToken
                    DispatchQueue.main.async {
                        fieldFocused = true
                    }
                }
            }
        }
    }

    private var searchFieldCard: some View {
        VStack(alignment: .leading, spacing: AppSpacing.group) {
            Text("搜索设置，或切换到 Universe Keyboard 试用输入")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            HStack(spacing: AppSpacing.row) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                TextField("任意内容：设置名或试用输入", text: $query)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .focused($fieldFocused)
                    .submitLabel(.search)
                if !query.isEmpty {
                    Button {
                        query = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("清除")
                }
            }
            .padding(AppSpacing.card)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous))

            Text("试用键盘时请用地球键切换到 \(ActivationCopy.keyboardDisplayName)。输入任意内容即可；找到设置项可点进对应页面。")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private var hintsSection: some View {
        InfoSection(title: "可搜索", systemImage: "sparkle.magnifyingglass") {
            Text("试试：布局、雾凇、模糊、部署、诊断、隐私…")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text("启用阶段也可在此试用输入法，再回到帮助确认「试一次输入」。")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }

    private var emptyResultsSection: some View {
        InfoSection(title: "未找到设置项", systemImage: "text.magnifyingglass") {
            Text("没有与「\(trimmedQuery)」匹配的设置。")
                .font(.subheadline)
            Text("若你在试用 Universe Keyboard，这很正常——任意内容都可以。试用满意后可到「帮助」点「我已成功输入」。")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }

    private var resultsSection: some View {
        InfoSection(title: "设置", systemImage: "gearshape") {
            ForEach(Array(results.enumerated()), id: \.element.id) { index, item in
                if index > 0 { Divider() }
                NavigationLink {
                    destinationView(for: item.destination)
                } label: {
                    HStack(spacing: AppSpacing.row) {
                        AppIconTile(
                            systemImage: item.systemImage,
                            size: AppIconSize.standard,
                            cornerRadius: AppRadius.control,
                            symbolPointSize: 15
                        )
                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.title)
                                .font(.body.weight(.medium))
                                .foregroundStyle(.primary)
                                .multilineTextAlignment(.leading)
                            Text(item.subtitle)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.leading)
                        }
                        Spacer(minLength: 8)
                        Image(systemName: "chevron.right")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.tertiary)
                    }
                    .padding(.vertical, 4)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    // Full-row hit target (not only glyph/text bounds).
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
    }

    @ViewBuilder
    private func destinationView(for destination: SettingsSearchItem.Destination) -> some View {
        switch destination {
        case .keyboardLayout:
            KeyboardLayoutSettingsView(rimeStore: rimeStore)
        case .feedback:
            FeedbackSettingsView()
        case .typoCorrection:
            TypoCorrectionBenchmarkView()
        case .typingIntelligence:
            TypingIntelligenceView()
        case .rimeSchemes:
            RimeSettingsView(store: rimeStore)
        case .advancedInput:
            RimeAdvancedInputSettingsView(store: rimeStore)
        case .fuzzyPinyin:
            RimeFuzzyPinyinSettingsView(store: rimeStore)
        case .rimeSync:
            RimeSyncSettingsView(model: syncModel, notificationSettings: notificationSettings)
        case .userDictionary:
            RimeUserDictionarySettingsView(store: rimeStore)
        case .appearance:
            AppearanceSettingsView()
        case .notifications:
            NotificationSettingsView(
                model: notificationSettings,
                isRimeSyncMethodConfigured: syncModel.provider != .none
            )
        case .privacy:
            PrivacyDataView()
        case .localDictionary:
            DictionaryBrowserView()
        case .diagnostics:
            DiagnosticsSettingsView(notificationSettings: notificationSettings)
        case .activationHelp:
            GuideTab(embedsOwnNavigationStack: false, rimeStore: rimeStore)
        }
    }
}
