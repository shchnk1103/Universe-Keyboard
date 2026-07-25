//
//  Universe_KeyboardApp.swift
//  Universe Keyboard
//
//  Created by DoubleShy0N on 5/10/26.
//

import SwiftUI

@main
struct Universe_KeyboardApp: App {
    init() {
        AppAppearance.migrateLegacyPreferenceIfNeeded()
        SystemAppNotificationClient.shared.configure()
        RimeAutomaticSyncScheduler.shared.registerBackgroundTask()
        // Main-App TipKit only (`PD-HELP-TIPKIT-001` P3). Never configure tips in Keyboard Extension.
        ActivationTips.configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
