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
    @State private var showDeploymentToast = false
    @State private var showUserDictionaryToast = false
    @State private var toastDismissTask: Task<Void, Never>?
    @State private var userDictionaryToastDismissTask: Task<Void, Never>?

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
            if showDeploymentToast {
                RimeDeploymentToast(state: rimeSettingsStore.deploymentState)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 74)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            } else if showUserDictionaryToast, let message = rimeSettingsStore.userDictionaryMessage {
                RimeUserDictionaryOperationToast(
                    message: message,
                    succeeded: rimeSettingsStore.userDictionaryMessageSucceeded
                )
                .padding(.horizontal, 16)
                .padding(.bottom, 74)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: showDeploymentToast)
        .animation(.easeInOut(duration: 0.2), value: showUserDictionaryToast)
        .onChange(of: rimeSettingsStore.deploymentState) { _, state in
            updateDeploymentToast(for: state)
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
        toastDismissTask?.cancel()

        switch state {
        case .triggered, .deploying, .failed:
            showDeploymentToast = true
        case .deployed:
            guard showDeploymentToast else { return }
            showDeploymentToast = true
            toastDismissTask = Task {
                try? await Task.sleep(nanoseconds: 2_000_000_000)
                guard !Task.isCancelled else { return }
                await MainActor.run { showDeploymentToast = false }
            }
        case .idle, .needsDeploy:
            showDeploymentToast = false
        }
    }

    private func updateUserDictionaryToast() {
        userDictionaryToastDismissTask?.cancel()
        guard rimeSettingsStore.userDictionaryMessage != nil else {
            showUserDictionaryToast = false
            return
        }

        showUserDictionaryToast = true
        userDictionaryToastDismissTask = Task {
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            guard !Task.isCancelled else { return }
            await MainActor.run { showUserDictionaryToast = false }
        }
    }
}

#Preview {
    ContentView()
}
