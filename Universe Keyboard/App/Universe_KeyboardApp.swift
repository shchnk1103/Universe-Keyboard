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

    static var isProcessActive: Bool { shared.isProcessActive }

    static func apply(_ phase: ScenePhase, to lifecycle: DiagnosticsProcessLifecycle = shared) {
        switch phase {
        case .active:
            lifecycle.setActive(true)
        case .inactive, .background:
            // 顺序固定在同一同步段：先申请 token，再关活动标记并关闭新 append 登记，然后才异步等待。
            // 主线程不在这里等待锁、磁盘或排空。
            let token = beginJournalDrainTokenOnMainActor()
            lifecycle.setActive(false)
            lifecycle.closeAppendAdmission()
            let cancellationID = token.map(MainAppSuspensionGuard.cancellationID)
            let cancellation: @Sendable () -> Bool = {
                guard let cancellationID else { return true }
                return mainAppSuspensionReportsCancelled(id: cancellationID)
            }
            Task { @MainActor in
                let outcome = await lifecycle.waitForAppendDrain(cancellation: cancellation)
                if let token {
                    if outcome == .drained, !MainAppSuspensionGuard.shared.isCancelled(token) {
                        // 仅表示已登记的 append 已返回。不表示其它锁已结束，也不在申请失败时走到这里。
                    }
                    MainAppSuspensionGuard.shared.end(token)
                }
            }
        @unknown default:
            lifecycle.setActive(false)
        }
    }

    /// `apply` 仍可从非隔离调用。UIKit 申请必须在主 actor 上同步完成，再关登记。
    private static func beginJournalDrainTokenOnMainActor() -> MainAppSuspensionGuard.Token? {
        let begin: @MainActor () -> MainAppSuspensionGuard.Token? = {
            MainAppSuspensionGuard.shared.begin(reason: "journal-drain")
        }
        if Thread.isMainThread {
            return MainActor.assumeIsolated(begin)
        }
        return DispatchQueue.main.sync {
            MainActor.assumeIsolated(begin)
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
            // 真正请求回收前再看一次前台状态。已经开始的回收不在这里取消。
            guard DiagnosticsAppLifecycle.shared.isProcessActive else { return }
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
