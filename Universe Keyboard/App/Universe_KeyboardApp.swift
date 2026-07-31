//
//  Universe_KeyboardApp.swift
//  Universe Keyboard
//
//  Created by DoubleShy0N on 5/10/26.
//

import SwiftUI
#if T9_AUTO_ANCHOR_DEVICE_PREFLIGHT
import KeyboardCore
#endif

@main
struct Universe_KeyboardApp: App {
    init() {
        #if T9_AUTO_ANCHOR_DEVICE_PREFLIGHT
        T9DevicePreflightRunCoordinator.handleLaunchEnvironment()
        #endif
        AppAppearance.migrateLegacyPreferenceIfNeeded()
        SystemAppNotificationClient.shared.configure()
        RimeAutomaticSyncScheduler.shared.registerBackgroundTask()
        // Main-App TipKit only (`PD-HELP-TIPKIT-001` P3). Never configure tips in Keyboard Extension.
        ActivationTips.configure()
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
