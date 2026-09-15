//
//  ContentView.swift
//  Universe Keyboard
//
//  主页面：首页 / 设置 / 搜索(最右，始终)。引导为设置「？」sheet。
//

import SwiftUI

let universeAppGroupID = "group.com.DoubleShy0N.Universe-Keyboard"

struct ContentView: View {
    /// Top-level tabs. Search is always last (`PD-APP-SEARCH-001`).
    private enum MainTab: Hashable {
        case home
        case settings
        case search
    }

    @Environment(\.scenePhase) private var scenePhase
    @AppStorage(AppAppearance.storageKey, store: AppAppearance.storage)
    private var appearanceRawValue = AppAppearance.system.rawValue
    /// J0 passed (开始设置). Not activation success.
    @AppStorage(ActivationPresentationStorage.welcomeSeenKey)
    private var activationWelcomeSeen = false
    /// Activation affirmations (standard defaults; same keys as GuideTab).
    @AppStorage("activation_keyboard_added_affirmed")
    private var keyboardAddedAffirmed = false
    @AppStorage("activation_full_access_affirmed")
    private var fullAccessAffirmed = false
    @AppStorage(ActivationPresentationStorage.fullAccessDeferredKey)
    private var fullAccessDeferred = false
    @AppStorage("activation_first_input_affirmed")
    private var firstInputAffirmed = false
    @AppStorage("activation_shared_data_unavailable")
    private var sharedDataUnavailable = false
    @AppStorage("rime_deployed", store: UserDefaults(suiteName: universeAppGroupID))
    private var rimeDeployed = false
    @State private var selectedTab: MainTab = .home
    @State private var showActivationGuide = false
    /// F2: dismisses the current process sheet only; next launch auto-presents again.
    @State private var deferredGuideThisProcess = false
    @State private var rimeSettingsStore: RimeSettingsStore
    @State private var rimeSyncViewModel: RimeSyncViewModel
    @State private var notificationSettingsModel: AppNotificationSettingsModel
    @State private var operationToast: AppOperationToastState?
    @State private var showOperationToast = false
    @State private var toastDismissTask: Task<Void, Never>?
    @State private var deploymentToastOperationActive = false

    init() {
        let rimeSettingsStore = RimeSettingsStore()
        _rimeSettingsStore = State(initialValue: rimeSettingsStore)
        _rimeSyncViewModel = State(
            initialValue: RimeSyncViewModel(rimeStore: rimeSettingsStore)
        )
        _notificationSettingsModel = State(initialValue: AppNotificationSettingsModel())
        #if DEBUG
            TypingIntelligencePreviewFixture.installIfRequested()
        #endif
    }

    private var helpChecklist: ActivationChecklistState {
        let isDeploying: Bool = {
            switch rimeSettingsStore.deploymentState {
            case .triggered, .deploying: return true
            default: return false
            }
        }()
        let deploymentFailed = rimeSettingsStore.deploymentState == .failed
        let fullAccess: ActivationChecklistState.FullAccessPresentation = {
            if sharedDataUnavailable { return .sharedDataUnavailable }
            if fullAccessAffirmed { return .userAffirmed }
            return .unknown
        }()
        let activeInstalled =
            rimeSettingsStore.schemas.first(where: { $0.schemaID == rimeSettingsStore.activeSchemaID })?
            .installed
            ?? (rimeSettingsStore.activeSchemaID == ActivationChecklistState.builtinSchemaID)
        return ActivationChecklistState(
            keyboardAddedAffirmed: keyboardAddedAffirmed,
            fullAccess: fullAccess,
            fullAccessDeferred: fullAccessDeferred,
            activeSchemaID: rimeSettingsStore.activeSchemaID,
            activeSchemaInstalled: activeInstalled,
            rimeDeployed: rimeDeployed,
            isDeploying: isDeploying,
            deploymentFailed: deploymentFailed,
            firstInputAffirmed: firstInputAffirmed
        )
    }

    private var isActivationGuideReRead: Bool {
        !helpChecklist.shouldOfferGuideSession
    }

    var body: some View {
        // Phase 1 — TabView structure + sheet + activation-tip .onChange
        let anchored = TabView(selection: $selectedTab) {
            HomeTab(rimeStore: rimeSettingsStore)
                .tabItem {
                    Label("首页", systemImage: "house")
                }
                .tag(MainTab.home)
            SettingsTab(
                rimeStore: rimeSettingsStore,
                syncModel: rimeSyncViewModel,
                notificationSettings: notificationSettingsModel,
                helpEntryNeedsAttention: helpChecklist.shouldMarkHelpEntryIncomplete,
                onOpenActivationGuide: { presentActivationGuide() }
            )
            .tabItem {
                Label("设置", systemImage: "gearshape")
            }
            .tag(MainTab.settings)
            // Always last (far right).
            SearchTab(
                rimeStore: rimeSettingsStore,
                syncModel: rimeSyncViewModel,
                notificationSettings: notificationSettingsModel,
                onOpenActivationGuide: { presentActivationGuide() }
            )
            .tabItem {
                Label("搜索", systemImage: "magnifyingglass")
            }
            .tag(MainTab.search)
        }
        .tint(.primary)
        .toggleStyle(.appSwitch)
        .preferredColorScheme(
            AppAppearance(rawValue: appearanceRawValue)?.colorScheme
        )
        .sheet(isPresented: $showActivationGuide) {
            ActivationGuideSheet(
                rimeStore: rimeSettingsStore,
                showsWelcome: !activationWelcomeSeen && helpChecklist.shouldOfferGuideSession,
                isReRead: isActivationGuideReRead,
                onStartFromWelcome: {
                    activationWelcomeSeen = true
                },
                onDefer: {
                    deferActivationGuideThisProcess()
                },
                onDismiss: {
                    showActivationGuide = false
                }
            )
        }
        .onAppear {
            presentActivationGuideIfNeeded()
            syncActivationTips()
        }
        .onChange(of: keyboardAddedAffirmed) { _, _ in syncActivationTips() }
        .onChange(of: fullAccessAffirmed) { _, _ in syncActivationTips() }
        .onChange(of: firstInputAffirmed) { _, _ in syncActivationTips() }
        .onChange(of: sharedDataUnavailable) { _, _ in syncActivationTips() }
        .onChange(of: rimeDeployed) { _, _ in syncActivationTips() }
        .onChange(of: rimeSettingsStore.deploymentState) { _, _ in syncActivationTips() }

        // Phase 2 — Overlay + operation-toast .onChange
        let withOverlay =
            anchored
            .overlay(alignment: .bottom) {
                if notificationSettingsModel.operationToastsEnabled,
                    showOperationToast,
                    let operationToast
                {
                    AppOperationToast(state: operationToast)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 74)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .animation(.easeInOut(duration: 0.2), value: showOperationToast)
            .onChange(of: rimeSettingsStore.deploymentState) { _, state in
                updateDeploymentToast(for: state)
            }
            .onChange(of: rimeSettingsStore.downloadState) { _, state in
                updateDownloadToast(for: state)
                rimeSettingsStore.handleDownloadStateChange()
            }
            .onChange(of: rimeSettingsStore.userDictionaryMessageVersion) { _, _ in
                updateUserDictionaryToast()
            }
            .onChange(of: rimeSettingsStore.layoutToastVersion) { _, _ in
                updateLayoutToast()
            }
            .onChange(of: rimeSyncViewModel.statusVersion) { _, _ in
                updateSyncToast()
            }
            .onChange(of: notificationSettingsModel.operationToastsEnabled) { _, enabled in
                if !enabled {
                    hideToast()
                }
            }

        // Phase 3 — Scene phase + task
        return
            withOverlay
            .onChange(of: scenePhase) { _, phase in
                switch phase {
                case .active:
                    Task {
                        await notificationSettingsModel.refreshAuthorizationStatus()
                        await rimeSyncViewModel.synchronizeIfNeeded()
                    }
                case .inactive, .background:
                    rimeSettingsStore.runAutomaticUserDictionaryBackupIfNeeded()
                    Task { await rimeSettingsStore.triggerPendingDeploymentIfNeeded() }
                    RimeAutomaticSyncScheduler.shared.refreshSchedule()
                @unknown default:
                    break
                }
            }
            .task {
                await notificationSettingsModel.refreshAuthorizationStatus()
                await rimeSyncViewModel.loadSecrets()
                await rimeSyncViewModel.synchronizeIfNeeded()
                RimeAutomaticSyncScheduler.shared.refreshSchedule()
                // Unit tests inject this process as the host app. Skip the
                // first-launch seed/deploy so librime does not run against
                // the unentitled simulator App Group.
                if ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] == nil {
                    rimeSettingsStore.load()
                    await rimeSettingsStore.triggerPendingDeploymentIfNeeded()
                }
            }
    }

    private func updateDeploymentToast(for state: RimeDeploymentState) {
        guard !(showOperationToast && operationToast?.source == .download) else { return }
        guard !rimeSettingsStore.downloadState.isActiveOperation else { return }

        switch state {
        case .triggered, .deploying:
            deploymentToastOperationActive = true
        case .deployed, .failed:
            guard deploymentToastOperationActive else {
                if operationToast?.source == .deployment {
                    hideToast()
                }
                return
            }
            deploymentToastOperationActive = false
        case .idle, .needsDeploy:
            deploymentToastOperationActive = false
            if operationToast?.source == .deployment {
                hideToast()
            }
            return
        }

        guard let toastState = AppOperationToastState(deploymentState: state) else {
            if operationToast?.source == .deployment {
                hideToast()
            }
            return
        }
        presentToast(toastState)
    }

    private func updateDownloadToast(for state: DownloadState) {
        guard let toastState = AppOperationToastState(downloadState: state) else {
            hideToast()
            return
        }
        presentToast(toastState)
    }

    private func updateUserDictionaryToast() {
        guard let message = rimeSettingsStore.userDictionaryMessage else { return }
        presentToast(
            .userDictionary(
                message: message,
                succeeded: rimeSettingsStore.userDictionaryMessageSucceeded
            )
        )
    }

    private func updateLayoutToast() {
        guard let message = rimeSettingsStore.layoutToastMessage else { return }
        presentToast(
            .layout(
                message: message,
                succeeded: rimeSettingsStore.layoutToastSucceeded
            )
        )
    }

    private func updateSyncToast() {
        guard let toastState = AppOperationToastState(syncStatus: rimeSyncViewModel.status) else {
            if operationToast?.source == .sync {
                hideToast()
            }
            return
        }
        presentToast(toastState)
    }

    private func presentToast(_ state: AppOperationToastState) {
        guard notificationSettingsModel.operationToastsEnabled else { return }
        toastDismissTask?.cancel()
        operationToast = state
        showOperationToast = true

        guard state.automaticallyDismisses else { return }
        toastDismissTask = Task {
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            guard !Task.isCancelled else { return }
            await MainActor.run { showOperationToast = false }
        }
    }

    private func hideToast() {
        toastDismissTask?.cancel()
        showOperationToast = false
    }

    private var isRunningUnderXCTest: Bool {
        ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
    }

    private func presentActivationGuideIfNeeded() {
        guard !isRunningUnderXCTest else { return }
        guard helpChecklist.shouldOfferGuideSession else { return }
        guard !deferredGuideThisProcess else { return }
        // Defer one turn so TabView is on-screen before the sheet.
        DispatchQueue.main.async {
            guard helpChecklist.shouldOfferGuideSession else { return }
            guard !deferredGuideThisProcess else { return }
            showActivationGuide = true
        }
    }

    /// User-initiated present (toolbar **？** or Search). Allowed after 「稍后再说」 in this process.
    private func presentActivationGuide() {
        showActivationGuide = true
    }

    private func deferActivationGuideThisProcess() {
        deferredGuideThisProcess = true
        showActivationGuide = false
    }

    /// Keep TipKit `@Parameter` flags aligned with checklist (P3 invalidation).
    private func syncActivationTips() {
        ActivationTips.sync(from: helpChecklist)
    }
}

#Preview {
    ContentView()
}

private extension DownloadState {
    var isActiveOperation: Bool {
        switch self {
        case .fetchingReleaseInfo, .downloading, .extracting, .postProcessing, .deploying:
            return true
        case .idle, .completed, .failed:
            return false
        }
    }
}
