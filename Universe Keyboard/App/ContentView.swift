//
//  ContentView.swift
//  Universe Keyboard
//
//  主页面：Tab 分为「引导」和「设置」。
//

import SwiftUI

let universeAppGroupID = "group.com.DoubleShy0N.Universe-Keyboard"

struct ContentView: View {
    @Environment(\.scenePhase) private var scenePhase
    @State private var rimeSettingsStore = RimeSettingsStore()
    @State private var operationToast: AppOperationToastState?
    @State private var showOperationToast = false
    @State private var toastDismissTask: Task<Void, Never>?

    var body: some View {
        TabView {
            GuideTab()
                .tabItem {
                    Label("引导", systemImage: "book.pages")
                }
            SettingsTab(rimeStore: rimeSettingsStore)
                .tabItem {
                    Label("设置", systemImage: "gearshape")
                }
        }
        .tint(.primary)
        .overlay(alignment: .bottom) {
            if showOperationToast, let operationToast {
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
        .onChange(of: scenePhase) { _, phase in
            guard phase == .inactive || phase == .background else { return }
            rimeSettingsStore.runAutomaticUserDictionaryBackupIfNeeded()
            Task { await rimeSettingsStore.triggerPendingDeploymentIfNeeded() }
        }
    }

    private func updateDeploymentToast(for state: RimeDeploymentState) {
        guard !(showOperationToast && operationToast?.source == .download) else { return }
        guard !rimeSettingsStore.downloadState.isActiveOperation else { return }
        guard let toastState = AppOperationToastState(deploymentState: state) else {
            hideToast()
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

    private func presentToast(_ state: AppOperationToastState) {
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
