//
//  Universe_KeyboardApp.swift
//  Universe Keyboard
//
//  Created by DoubleShy0N on 5/10/26.
//

import Foundation
import KeyboardCore
import SwiftUI

nonisolated enum DiagnosticsAppLifecycle {
    static let shared = DiagnosticsProcessLifecycle()

    static func apply(_ phase: ScenePhase, to lifecycle: DiagnosticsProcessLifecycle = shared) {
        switch phase {
        case .active: lifecycle.setActive(true)
        case .inactive, .background: lifecycle.setActive(false)
        @unknown default: lifecycle.setActive(false)
        }
    }
}

@main
struct Universe_KeyboardApp: App {
    @Environment(\.scenePhase) private var scenePhase

    init() {
        #if T9_AUTO_ANCHOR_DEVICE_PREFLIGHT
            T9DevicePreflightRunCoordinator.handleLaunchEnvironment()
        #endif
        AppAppearance.migrateLegacyPreferenceIfNeeded()
        if let sharedDefaults = UserDefaults(suiteName: "group.com.DoubleShy0N.Universe-Keyboard") {
            #if DEBUG
                let liquidGlassDebugBuild = true
            #else
                let liquidGlassDebugBuild = false
            #endif
            clearStoredLiquidGlassMaterialPreferenceIfRelease(
                defaults: sharedDefaults,
                isDebugBuild: liquidGlassDebugBuild
            )
        }
        SystemAppNotificationClient.shared.configure()
        #if DEBUG
            if !RimeSyncUITestFixture.isRequested() {
                RimeAutomaticSyncScheduler.shared.registerBackgroundTask()
            }
        #else
            RimeAutomaticSyncScheduler.shared.registerBackgroundTask()
        #endif
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
                isMainAppWriter: true,
                writerVersion: .v6
            )
            guard (try? await writer.prepareRootIfOwnedByMainApp()) != nil else {
                return
            }
            // 只在 Main App 的 utility task 请求目录维护；scheduler 会合并启动、
            // 前台恢复和诊断页刷新，Extension 不会触碰其他 process 的段、lease
            // 或 tombstone。
            _ = await DiagnosticsJournalRetentionScheduler.shared.requestReclaim(rootURL: rootURL)
        }
    }

    var body: some Scene {
        WindowGroup {
            Group {
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
            .onAppear { DiagnosticsAppLifecycle.apply(scenePhase) }
        }
        .onChange(of: scenePhase) { _, phase in
            DiagnosticsAppLifecycle.apply(phase)
            guard phase == .active else { return }
            prepareDiagnosticsJournalRoot()
        }
    }
}
