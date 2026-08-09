//
//  Universe_KeyboardApp.swift
//  Universe Keyboard
//
//  Created by DoubleShy0N on 5/10/26.
//

import Foundation
import KeyboardCore
import SwiftUI

@main
struct Universe_KeyboardApp: App {
    init() {
        #if T9_AUTO_ANCHOR_DEVICE_PREFLIGHT
            T9DevicePreflightRunCoordinator.handleLaunchEnvironment()
        #endif
        AppAppearance.migrateLegacyPreferenceIfNeeded()
        SystemAppNotificationClient.shared.configure()
        RimeAutomaticSyncScheduler.shared.registerBackgroundTask()
        prepareDiagnosticsJournalRoot()
        // Main-App TipKit only (`PD-HELP-TIPKIT-001` P3). Never configure tips in Keyboard Extension.
        ActivationTips.configure()
    }

    /// `Diagnostics/v1` 的目录只能由 Main App 创建。准备动作放在 utility task，
    /// 不把 App Group 文件操作带到 App 启动的主线程，也不影响键盘 Extension。
    private func prepareDiagnosticsJournalRoot() {
        Task.detached(priority: .utility) {
            guard
                let rootURL =
                    FileManager.default
                    .containerURL(
                        forSecurityApplicationGroupIdentifier: "group.com.DoubleShy0N.Universe-Keyboard"
                    )?
                    .appendingPathComponent("Diagnostics/v1", isDirectory: true)
            else {
                return
            }
            let writer = DiagnosticsJournalWriter(
                rootURL: rootURL,
                origin: .mainApp,
                isMainAppWriter: true
            )
            guard (try? await writer.prepareRootIfOwnedByMainApp()) != nil else {
                return
            }
            // 只在 Main App 的 utility task 执行目录维护；Extension 不会创建
            // coordinator，也不会触碰其他 process 的段、lease 或 tombstone。
            let coordinator = DiagnosticsJournalRetentionCoordinator(rootURL: rootURL)
            _ = await coordinator.runReclaim()
        }
    }

    var body: some Scene {
        WindowGroup {
            #if T9_AUTO_ANCHOR_DEVICE_PREFLIGHT
                if ProcessInfo.processInfo.environment["T9_S6A_EVIDENCE_VIEW"] == "1" {
                    T9DevicePreflightEvidenceView()
                } else {
                    ContentView()
                }
            #else
                ContentView()
            #endif
        }
    }
}
